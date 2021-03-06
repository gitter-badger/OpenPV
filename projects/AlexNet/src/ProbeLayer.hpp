#ifndef MAXPOOLTESTLAYER_HPP_ 
#define MAXPOOLTESTLAYER_HPP_

#include <layers/ANNLayer.hpp>

namespace PV {

class ProbeLayer: public PV::ANNLayer{
public:
	ProbeLayer(const char* name, HyPerCol * hc);

protected:
   int updateState(double timef, double dt);
   double sumDistance;
   long numExamples;
   long numCorrect;
   int dispPeriod;

private:
};

} /* namespace PV */
#endif
