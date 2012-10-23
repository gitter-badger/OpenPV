/*
 * CPTestInputLayer.cpp
 *
 *  Created on: Nov 10, 2011
 *      Author: pschultz
 */

#include "CPTestInputLayer.hpp"

#ifdef __cplusplus
extern "C" {
#endif

void CPTestInputLayer_update_state(
    const int numNeurons,
    const int nx,
    const int ny,
    const int nf,
    const int nb,

    float * V,
    const float Vth,
    const float VMax,
    const float VMin,
    float * GSynHead,
/*    float * GSynExc,
    float * GSynInh,*/
    float * activity);

#ifdef __cplusplus
}
#endif

namespace PV {

CPTestInputLayer::CPTestInputLayer(const char * name, HyPerCol * hc) : ANNLayer(name, hc) {
   initialize();
}

CPTestInputLayer::~CPTestInputLayer() {
}

int CPTestInputLayer::initialize() {
   initializeV();
   return PV_SUCCESS;
}

int CPTestInputLayer::initializeV() {
   assert(parent->parameters()->value(name, "restart", 0.0f, false)==0.0f); // initializeV should only be called if restart is false
   const PVLayerLoc * loc = getLayerLoc();
   for (int k = 0; k < getNumNeurons(); k++){
      int kx = kxPos(k,loc->nx,loc->nx,loc->nf);
      int ky = kyPos(k,loc->nx,loc->ny,loc->nf);
      int kf = featureIndex(k,loc->nx,loc->ny,loc->nf);
      int kGlobal = kIndex(loc->kx0+kx,loc->ky0+ky,kf,loc->nxGlobal,loc->nyGlobal,loc->nf);
      getV()[k] = (pvdata_t) kGlobal;
   }
   return PV_SUCCESS;
}

#ifdef PV_USE_OPENCL
/**
 * Initialize OpenCL buffers.  This must be called after PVLayer data have
 * been allocated.
 */
int CPTestInputLayer::initializeThreadBuffers(const char * kernel_name)
{
   int status = ANNLayer::initializeThreadBuffers(kernel_name);
   //There are no CPTestInputLayer-specific buffers...
   return status;
}

int CPTestInputLayer::initializeThreadKernels(const char * kernel_name)
{
   return ANNLayer::initializeThreadKernels(kernel_name);
}
int CPTestInputLayer::updateStateOpenCL(double timed, double dt)
{
   //at the moment there's no reason to do anything differently
   //for CPTestInputLayer, but I still defined the method in case
   //that changes in the future.
   int status = ANNLayer::updateStateOpenCL(timed, dt);
   return status;
}

#endif // PV_USE_OPENCL


int CPTestInputLayer::updateState(double timed, double dt) {
   update_timer->start();
#ifdef PV_USE_OPENCL
   if(gpuAccelerateFlag) {
      updateStateOpenCL(timef, dt);
      //HyPerLayer::updateState(time, dt);
   }
   else {
#endif
      const int nx = clayer->loc.nx;
      const int ny = clayer->loc.ny;
      const int nf = clayer->loc.nf;
      const int nb = clayer->loc.nb;
      const int numNeurons = getNumNeurons();

      //pvdata_t * GSynExc   = getChannel(CHANNEL_EXC);
      //pvdata_t * GSynInh   = getChannel(CHANNEL_INH);
      pvdata_t * GSynHead   = GSyn[0];
      pvdata_t * V = getV();
      pvdata_t * activity = clayer->activity->data;

      CPTestInputLayer_update_state(numNeurons, nx, ny, nf, nb, V, VThresh, VMax, VMin, GSynHead, activity);
#ifdef PV_USE_OPENCL
   }
#endif

   update_timer->stop();
   return PV_SUCCESS;
}

}  // end of namespace PV block


#ifdef __cplusplus
extern "C" {
#endif

#ifndef PV_USE_OPENCL
#  include "CPTestInputLayer_update_state.cl"
#else
#  undef PV_USE_OPENCL
#  include "CPTestInputLayer_update_state.cl"
#  define PV_USE_OPENCL
#endif

#ifdef __cplusplus
}
#endif

