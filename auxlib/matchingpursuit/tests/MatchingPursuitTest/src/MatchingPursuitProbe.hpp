/*
 * MatchingPursuitProbe.hpp
 *
 *  Created on: Aug 12, 2013
 *      Author: pschultz
 */

#ifndef MATCHINGPURSUITPROBE_HPP_
#define MATCHINGPURSUITPROBE_HPP_

#include <io/LayerProbe.hpp>
#include <columns/HyPerCol.hpp>

namespace PV {

class MatchingPursuitProbe: public LayerProbe {
public:
   MatchingPursuitProbe(const char * name, HyPerCol * hc);
   virtual ~MatchingPursuitProbe();

   virtual int outputState(double timed);

protected:
   MatchingPursuitProbe();
   int initMatchingPursuitProbe(const char * name, HyPerCol * hc);

private:
   int initMatchingPursuitProbe_base();

};

} /* namespace PV */
#endif /* MATCHINGPURSUITPROBE_HPP_ */
