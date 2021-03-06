#include "MovieTestLayer.hpp"

namespace PV {

MovieTestLayer::MovieTestLayer(const char * name, HyPerCol * hc) {
   Movie::initialize(name, hc);
}

int MovieTestLayer::updateStateWrapper(double time, double dt)
{
   Movie::updateStateWrapper(time, dt);
   const PVLayerLoc * loc = getLayerLoc();
   int nx = loc->nx;
   int ny = loc->ny;
   int nf = loc->nf;
   int nbatch = loc->nbatch;
   for(int b = 0; b < nbatch; b++){
      pvdata_t * dataBatch = data + b * getNumExtended();
      int frameIdx;
      if(strcmp(getBatchMethod(), "byImage") == 0){
         frameIdx = (time-1) * nbatch + b;
      }
      else if(strcmp(getBatchMethod(), "byMovie") == 0){
         frameIdx = b * 2 + (time-1);
      }
      
      for(int nkRes = 0; nkRes < getNumNeurons(); nkRes++){
         //Calculate extended index
         int nkExt = kIndexExtended(nkRes, nx, ny, nf, loc->halo.lt, loc->halo.rt, loc->halo.dn, loc->halo.up);  
         //checkVal is the value from batch index 0
         pvdata_t checkVal = dataBatch[nkExt] * 255;

         int kxGlobal = kxPos(nkRes, nx, ny, nf) + loc->kx0;
         int kyGlobal = kyPos(nkRes, nx, ny, nf) + loc->ky0; 
         int kf = featureIndex(nkRes, nx, ny, nf);

         pvdata_t expectedVal = kIndex(kxGlobal, kyGlobal, kf, loc->nxGlobal, loc->nyGlobal, nf) + 10*frameIdx;
         if(fabs(checkVal - expectedVal) >= 1e-4){
            std::cout << name << " time: " << time << " batch: " << b << " Expected: " << expectedVal << " Actual: " << checkVal << "\n";
            exit(-1);
         }
      }
   }
   return PV_SUCCESS;
}

}

