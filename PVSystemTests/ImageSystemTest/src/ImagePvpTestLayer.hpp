/*
 * ImagePvpTestLayer.hpp
 * Author: slundquist
 */

#ifndef IMAGEPVPTESTLAYER_HPP_
#define IMAGEPVPTESTLAYER_HPP_
#include <layers/ImagePvp.hpp>

namespace PV{

class ImagePvpTestLayer : public PV::ImagePvp{
public:
   ImagePvpTestLayer(const char * name, HyPerCol * hc);
   virtual int updateStateWrapper(double time, double dt);
};

}
#endif /* PVPTESTLAYER_HPP */
