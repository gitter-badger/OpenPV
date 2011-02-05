#include "LIF_params.h"
#include "cl_random.hcl"
#include "../utils/pv_random.h"

#ifndef PV_USE_OPENCL
#  include <math.h>
#  define EXP expf
#  define CL_KERNEL
#  define CL_MEM_GLOBAL
#  define CL_MEM_LOCAL
#else  /* compiling with OpenCL */
#  define EXP exp
#  define CL_KERNEL       __kernel
#  define CL_MEM_GLOBAL   __global
#  define CL_MEM_LOCAL    __local
#  include "conversions.hcl"
#endif

//
// update the state of a retinal layer (spiking)
//
//    assume called with 1D kernel
//
CL_KERNEL
void LIF_update_state(
    const float time, 
    const float dt,

    const int nx,
    const int ny,
    const int nf,
    const int nb,

    CL_MEM_GLOBAL LIF_params * params,
    CL_MEM_GLOBAL uint4 * rnd,
    CL_MEM_GLOBAL float * V,
    CL_MEM_GLOBAL float * Vth,
    CL_MEM_GLOBAL float * G_E,
    CL_MEM_GLOBAL float * G_I,
    CL_MEM_GLOBAL float * G_IB,
    CL_MEM_GLOBAL float * phiExc,
    CL_MEM_GLOBAL float * phiInh,
    CL_MEM_GLOBAL float * phiInhB,
    CL_MEM_GLOBAL float * R,
    CL_MEM_GLOBAL float * activity)
{
   int k;

   const float exp_tauE    = EXP(-dt/params->tauE);
   const float exp_tauI    = EXP(-dt/params->tauI);
   const float exp_tauIB   = EXP(-dt/params->tauIB);
   const float exp_tauVth  = EXP(-dt/params->tauVth);

   const float dt_sec = .001 * dt;   // convert to seconds
   const float exp_tauRate = EXP(-dt/params->tauRate);

#ifndef PV_USE_OPENCL

for (k = 0; k < nx*ny*nf; k++) {
#else   
   k = get_global_id(0);
#endif

   int kex = kIndexExtended(k, nx, ny, nf, nb);

   //
   // kernel (nonheader part) begins here
   //

   // local param variables
   float tau, Vrest, VthRest, Vexc, Vinh, VinhB, deltaVth;

   const float GMAX = 10.0;

   // local variables
   float l_activ;

   uint4 l_rnd = rnd[k];

   float l_V   = V[k];
   float l_Vth = Vth[k];

   float l_G_E  = G_E[k];
   float l_G_I  = G_I[k];
   float l_G_IB = G_IB[k];

   float l_phiExc  = phiExc[k];
   float l_phiInh  = phiInh[k];
   float l_phiInhB = phiInhB[k];
   
   float l_R = R[k];

   // temporary arrays
   float tauInf, VmemInf;

   //
   // start of LIF2_update_exact_linear
   //

   // define local param variables
   //
   tau   = params->tau;
   Vexc  = params->Vexc;
   Vinh  = params->Vinh;
   VinhB = params->VinhB;
   Vrest = params->Vrest;

   VthRest  = params->VthRest;
   deltaVth = params->deltaVth;

   // add noise
   //

#undef CLRANDOM

#ifdef CLRANDOM
   l_rnd = cl_random_get(l_rnd);
   if (cl_random_prob(l_rnd) < dt_sec*params->noiseFreqE) {
      l_rnd = cl_random_get(l_rnd);
      l_phiExc = l_phiExc + params->noiseAmpE*cl_random_prob(l_rnd);
   }

   l_rnd = cl_random_get(l_rnd);
   if (cl_random_prob(l_rnd) < dt_sec*params->noiseFreqI) {
      l_rnd = cl_random_get(l_rnd);
      l_phiInh = l_phiInh + params->noiseAmpI*cl_random_prob(l_rnd);
   }

   l_rnd = cl_random_get(l_rnd);
   if (cl_random_prob(l_rnd) < dt_sec*params->noiseFreqIB) {
      l_rnd = cl_random_get(l_rnd);
      l_phiInhB = l_phiInhB + params->noiseAmpIB*cl_random_prob(l_rnd);
   }
#else
   if (pv_random_prob() < dt_sec*params->noiseFreqE) {
      l_phiExc = l_phiExc + params->noiseAmpE*pv_random_prob();
   }

   if (pv_random_prob() < dt_sec*params->noiseFreqI) {
      l_phiInh = l_phiInh + params->noiseAmpI*pv_random_prob();
   }

   if (pv_random_prob() < dt_sec*params->noiseFreqIB) {
      l_phiInhB = l_phiInhB + params->noiseAmpIB*pv_random_prob();
   }
#endif

   l_G_E  = l_phiExc  + l_G_E *exp_tauE;
   l_G_I  = l_phiInh  + l_G_I *exp_tauI;
   l_G_IB = l_phiInhB + l_G_IB*exp_tauIB;
   
   l_G_E  = (l_G_E  > GMAX) ? GMAX : l_G_E;
   l_G_I  = (l_G_I  > GMAX) ? GMAX : l_G_I;
   l_G_IB = (l_G_IB > GMAX) ? GMAX : l_G_IB;

   tauInf  = (dt/tau) * (1.0 + l_G_E + l_G_I + l_G_IB);
   VmemInf = (Vrest + l_G_E*Vexc + l_G_I*Vinh + l_G_IB*VinhB)
           / (1.0 + l_G_E + l_G_I + l_G_IB);

   l_V = VmemInf + (l_V - VmemInf)*EXP(-tauInf);;

   //
   // start of LIF2_update_finish
   //

   l_Vth = VthRest + (l_Vth - VthRest)*exp_tauVth;

   //
   // start of update_f
   //

//   l_G_E  = (l_G_E  > GMAX) ? GMAX : l_G_E;
//   l_G_I  = (l_G_I  > GMAX) ? GMAX : l_G_I;
//   l_G_IB = (l_G_IB > GMAX) ? GMAX : l_G_IB;

   bool fired_flag = (l_V > l_Vth);

   l_activ = fired_flag ? 1.0f             : 0.0f;
   l_V     = fired_flag ? Vrest            : l_V;
   l_Vth   = fired_flag ? l_Vth + deltaVth : l_Vth;
   l_G_IB  = fired_flag ? l_G_IB + 1.0f    : l_G_IB;

   // update average rate
   l_R = l_activ + l_R*exp_tauRate;
   
   //
   // These actions must be done outside of kernel
   //    1. set activity to 0 in boundary (if needed)
   //    2. update active indices
   //

   // store local variables back to global memory
   //
   activity[kex] = l_activ;
   
   R[k] = l_R;

   V[k]   = l_V;
   Vth[k] = l_Vth;

   G_E[k]  = l_G_E;
   G_I[k]  = l_G_I;
   G_IB[k] = l_G_IB;

   phiExc[k]  = 0.0f;
   phiInh[k]  = 0.0f;
   phiInhB[k] = 0.0f;

#ifndef PV_USE_OPENCL
   } // loop over k
#endif

}
