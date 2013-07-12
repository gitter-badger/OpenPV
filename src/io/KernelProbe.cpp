/*
 * KernelPactchProbe.cpp
 *
 *  Created on: Oct 21, 2011
 *      Author: pschultz
 */

#include "KernelProbe.hpp"

namespace PV {

KernelProbe::KernelProbe() {
   initialize_base();
}

KernelProbe::KernelProbe(const char * probename, HyPerCol * hc) {
   initialize_base();
   int status = initialize(probename, hc);
   assert(status == PV_SUCCESS);
}

KernelProbe::~KernelProbe() {
}

int KernelProbe::initialize_base() {
   targetKConn = NULL;
   return PV_SUCCESS;
}

int KernelProbe::initialize(const char * probename, HyPerCol * hc) {
   int status = BaseConnectionProbe::initialize(probename, hc);
   assert(name && parent);
   if(status==PV_SUCCESS) {
      PVParams * params = parent->parameters();
      kernelIndex = params->value(name, "kernelIndex", 0);
      arborID = params->value(name, "arborId", 0);
      outputWeights = params->value(probename, "outputWeights", true) != 0.f;
      outputPlasticIncr = params->value(probename, "outputPlasticIncr", false) != 0.f;
      outputPatchIndices = params->value(probename, "outputPatchIndices", false) != 0.f;
   }

   return status;
}

int KernelProbe::communicate() {
   int status = PV_SUCCESS;
   assert(targetConn);
   targetKConn = dynamic_cast<KernelConn *>(targetConn);
   if(getTargetKConn() == NULL) {
      fprintf(stderr, "KernelProbe \"%s\": connection \"%s\" is not a KernelConn.\n", name, targetConn->getName());
      status = PV_FAILURE;
   }
   MPI_Barrier(parent->icCommunicator()->communicator());
   if (status != PV_SUCCESS) {
      exit(EXIT_FAILURE);
   }
   return status;
}

int KernelProbe::allocateProbe() {
   int status = PV_SUCCESS;
   assert(getTargetKConn());
   if (getKernelIndex()<0 || getKernelIndex()>=getTargetKConn()->getNumDataPatches()) {
      fprintf(stderr, "KernelProbe \"%s\": kernelIndex %d is out of bounds.  (min 0, max %d)\n", name, getKernelIndex(), getTargetKConn()->getNumDataPatches()-1);
      exit(EXIT_FAILURE);
   }
   if (getArbor()<0 || getArbor()>=getTargetKConn()->numberOfAxonalArborLists()) {
      fprintf(stderr, "KernelProbe \"%s\": arborId %d is out of bounds. (min 0, max %d)\n", name, getArbor(), getTargetKConn()->numberOfAxonalArborLists()-1);
      exit(EXIT_FAILURE);
   }

   if(stream) {
      fprintf(stream->fp, "Probe \"%s\", kernel index %d, arbor index %d.\n", name, getKernelIndex(), getArbor());
   }
   if(getOutputPatchIndices()) {
      patchIndices(getTargetKConn());
   }

   return status;
}

int KernelProbe::outputState(double timed) {
#ifdef PV_USE_MPI
   InterColComm * icComm = parent->icCommunicator();
   const int rank = icComm->commRank();
   if( rank != 0 ) return PV_SUCCESS;
#endif // PV_USE_MPI
   assert(getTargetKConn()!=NULL);
   int nxp = getTargetKConn()->xPatchSize();
   int nyp = getTargetKConn()->yPatchSize();
   int nfp = getTargetKConn()->fPatchSize();
   int patchSize = nxp*nyp*nfp;

   const pvdata_t * wdata = getTargetKConn()->get_wDataStart(arborID)+patchSize*kernelIndex;
   const pvdata_t * dwdata = outputPlasticIncr ?
         getTargetKConn()->get_dwDataStart(arborID)+patchSize*kernelIndex : NULL;
   fprintf(stream->fp, "Time %f, KernelConn \"%s\", nxp=%d, nyp=%d, nfp=%d\n",
           timed, getTargetKConn()->getName(),nxp, nyp, nfp);
   for(int f=0; f<nfp; f++) {
      for(int y=0; y<nyp; y++) {
         for(int x=0; x<nxp; x++) {
            int k = kIndex(x,y,f,nxp,nyp,nfp);
            fprintf(stream->fp, "    x=%d, y=%d, f=%d (index %d):", x, y, f, k);
            if(getOutputWeights()) {
               fprintf(stream->fp, "  weight=%f", wdata[k]);
            }
            if(getOutputPlasticIncr()) {
               fprintf(stream->fp, "  dw=%f", dwdata[k]);
            }
            fprintf(stream->fp,"\n");
         }
      }
   }

   return PV_SUCCESS;
}

int KernelProbe::patchIndices(KernelConn * kconn) {
   int nxp = kconn->xPatchSize();
   int nyp = kconn->yPatchSize();
   int nfp = kconn->fPatchSize();
   int nPreExt = kconn->getNumWeightPatches();
   assert(nPreExt == kconn->preSynapticLayer()->getNumExtended());
   const PVLayerLoc * loc = kconn->preSynapticLayer()->getLayerLoc();
   int marginWidth = loc->nb;
   int nxPre = loc->nx;
   int nyPre = loc->ny;
   int nfPre = loc->nf;
   int nxPreExt = nxPre+2*marginWidth;
   int nyPreExt = nyPre+2*marginWidth;
   for( int kPre = 0; kPre < nPreExt; kPre++ ) {
      PVPatch * w = kconn->getWeights(kPre,arborID);
      int xOffset = kxPos(w->offset, nxp, nyp, nfp);
      int yOffset = kyPos(w->offset, nxp, nyp, nfp);
      int kxPre = kxPos(kPre,nxPreExt,nyPreExt,nfPre)-marginWidth;
      int kyPre = kyPos(kPre,nxPreExt,nyPreExt,nfPre)-marginWidth;
      int kfPre = featureIndex(kPre,nxPreExt,nyPreExt,nfPre);
      fprintf(stream->fp,"    presynaptic neuron %d (x=%d, y=%d, f=%d) uses kernel index %d, starting at x=%d, y=%d\n",
            kPre, kxPre, kyPre, kfPre, kconn->patchIndexToDataIndex(kPre), xOffset, yOffset);
   }
   return PV_SUCCESS;
}

}  // end of namespace PV block
