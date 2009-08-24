/*
 * InterColComm.h
 *
 *  Created on: Aug 28, 2008
 *      Author: rasmussn
 */

#ifndef INTERCOLCOMM_HPP_
#define INTERCOLCOMM_HPP_

#include "Communicator.hpp"
#include "DataStore.hpp"
#include "../include/pv_common.h"
#include "../layers/PVLayer.h"

// maximum number of messages (each layer publishes to all neighbors)
#define MAX_MESSAGES    MAX_NEIGHBORS
#define MAX_PUBLISHERS  MAX_LAYERS
#define MAX_SUBSCRIBERS MAX_LAYERS

namespace PV {

class HyPerCol;
class HyPerLayer;
class HyPerConn;

class Publisher {
public:
   Publisher(int pubId, int numType1, size_t size1, int numType2, size_t size2, int numLevels);
   virtual ~Publisher();

   int publish(HyPerLayer * pub,
               int neighbors[], int numNeighbors,
               int borders[], int numBorders, PVLayerCube * data);
   int subscribe(HyPerConn * conn);
   int deliver(HyPerCol * hc, int numNeighbors, int numBorders);

   static int borderStoreIndex(int i, int numNeighbors)  {return i+numNeighbors;}

   int increaseTimeLevel()   {return store->newLevelIndex();}

   void setCommunicator(MPI_Comm comm)  {this->comm = comm;}

   DataStore * dataStore()   {return store;}

private:

   PVLayerCube * recvBuffer(int neighborId)
         {return (PVLayerCube *) store->buffer(neighborId);}
   PVLayerCube * recvBuffer(int neighborId, int delay)
         {return (PVLayerCube *) store->buffer(neighborId, delay);}

   int pubId;
   int numSubscribers;
   HyPerConn *  connection[MAX_SUBSCRIBERS];
   MPI_Request  request[MAX_MESSAGES];
   MPI_Comm     comm;
   DataStore *  store;
};

class InterColComm: public PV::Communicator {
public:
   InterColComm(int * argc, char *** argv);
   virtual ~InterColComm();

   int addPublisher(HyPerLayer * pub, size_t size1, size_t size2, int numLevels);
   int publish(HyPerLayer * pub, PVLayerCube * cube);
   int subscribe(HyPerConn * conn);
   int deliver(HyPerCol * hc, int pubId);
   int increaseTimeLevel(int pubId)       {return publishers[pubId]->increaseTimeLevel();}

   DataStore* publisherStore(int pubId)   {return publishers[pubId]->dataStore();}

private:

   int numPublishers;
   Publisher* publishers[MAX_PUBLISHERS];
};

}

#endif /* INTERCOLCOMM_HPP_ */
