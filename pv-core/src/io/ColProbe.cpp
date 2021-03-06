/*
 * ColProbe.cpp
 *
 *  Created on: Nov 25, 2010
 *      Author: pschultz
 */

#include "ColProbe.hpp"

namespace PV {

ColProbe::ColProbe() { // Default constructor to be called by derived classes.
   // They should call ColProbe::initialize from their own initialization routine
   // instead of calling a non-default constructor.
   initialize_base();
}

ColProbe::ColProbe(const char * probeName, HyPerCol * hc) {
   initialize_base();
   initialize(probeName, hc);
}

ColProbe::~ColProbe() {
}

int ColProbe::initialize_base() {
   parent = NULL;
   return PV_SUCCESS;
}

int ColProbe::initialize(const char * probeName, HyPerCol * hc) {
   int status = BaseProbe::initialize(probeName, hc);
   return status;
}

int ColProbe::ioParamsFillGroup(enum ParamsIOFlag ioFlag) {
   ioParam_probeOutputFile(ioFlag);
   return PV_SUCCESS;
}

void ColProbe::ioParam_targetName(enum ParamsIOFlag ioFlag) {
   if (ioFlag==PARAMS_IO_READ) {
      targetName = strdup(this->getParent()->getName());
   }
}

int ColProbe::initOutputStream(const char * filename) {
   int status = BaseProbe::initOutputStream(filename);
   if (status != PV_SUCCESS) {
      status = outputHeader();
   }
   return status;
}

int ColProbe::communicateInitInfo() {
   int status = BaseProbe::communicateInitInfo();
   if (status==PV_SUCCESS) {
      //Set target layer  
      owner = this->getParent();
      this->getParent()->insertProbe(this);
   }
   return status;
}

}  // end namespace PV
