/*
 * FirmThresholdCostFnProbe.hpp
 *
 *  Created on: Aug 14, 2015
 *      Author: pschultz
 */

#ifndef FIRMTHRESHOLDCOSTFNPROBE_HPP_
#define FIRMTHRESHOLDCOSTFNPROBE_HPP_

#include "AbstractNormProbe.hpp"

namespace PV {

/**
 * A class for computing the cost function corresponding to a transfer function
 * intermediate between soft threshold and hard threshold:
 * If |V|<VThresh, activity is zero.  If |V|>VThresh+VWidth, activity is the same as V.
 * Otherwise, activity is sgn(V)*(|V|-VThresh)*(VThresh/VWidth+1)
 * Note that this defines a continuous, pointwise linear function of the membrane potential,
 * with breaks where |V|=VThresh and |V|=VThresh+VWidth.
 * Also, as VWidth->0, the transfer function approaches the hard threshold case, and as
 * VWidth->infinity, the transfer function approaches the soft threshold case.
 */
class FirmThresholdCostFnProbe : public AbstractNormProbe {
public:
   FirmThresholdCostFnProbe(const char * probeName, HyPerCol * hc);
   virtual ~FirmThresholdCostFnProbe();
   
   virtual int communicateInitInfo();

protected:
   FirmThresholdCostFnProbe();
   int initFirmThresholdCostFnProbe(const char * probeName, HyPerCol * hc);
   virtual double getValueInternal(double timevalue, int index);
   virtual int ioParamsFillGroup(enum ParamsIOFlag ioFlag);

   /** 
    * List of parameters for the FirmThresholdCostFnProbe class
    * @name FirmThresholdCostFnProbe Parameters
    * @{
    */

   /**
    * @brief VThresh: The threshold where the transfer function returns 0 if |V|<VThresh.
    * The default is zero.
    */
   virtual void ioParam_VThresh(enum ParamsIOFlag ioFlag);

   /**
    * @brief VWidth: The width of the interval over which the transfer function
    * changes from hard to soft threshold.  The default is zero.
    */
   virtual void ioParam_VWidth(enum ParamsIOFlag ioFlag);
   /** @} */

   /**
    * Overrides AbstractNormProbe::setNormDescription() to set normDescription to "Cost function".
    * Return values and errno are set by a call to setNormDescriptionToString.
    */
   virtual int setNormDescription();

private:
   int initFirmThresholdCostFnProbe_base();

// Member variables
protected:
   pvpotentialdata_t VThresh;
   pvpotentialdata_t VWidth;
}; // end class FirmThresholdCostFnProbe

}  // end namespace PV

#endif /* FIRMTHRESHOLDCOSTFNPROBE_HPP_ */
