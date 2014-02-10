/*
 * Movie.hpp
 *
 *  Created on: Sep 25, 2009
 *      Author: travel
 */

#ifndef MOVIE_HPP_
#define MOVIE_HPP_

#include "Image.hpp"
#include <sstream>

namespace PV {

class Movie: public PV::Image {
public:
   Movie(const char * name, HyPerCol * hc, const char * fileOfFileNames);
   Movie(const char * name, HyPerCol * hc, const char * fileOfFileNames, float displayPeriod);
   virtual ~Movie();

   virtual int allocateDataStructures();

   virtual pvdata_t * getImageBuffer();
   virtual PVLayerLoc getImageLoc();

   virtual int checkpointRead(const char * cpDir, double * timef);
   virtual int checkpointWrite(const char * cpDir);
   virtual int outputState(double time, bool last=false);
   virtual bool needUpdate(double time, double dt);
   //virtual int updateStateWrapper(double time, double dt);
   virtual int updateState(double time, double dt);
   bool        updateImage(double time, double dt);
   // bool        getNewImageFlag();
   const char * getCurrentImage();

   int  randomFrame();

   virtual double getLastUpdateTime() {return lastUpdateTime;}

protected:
   Movie();
   int initialize(const char * name, HyPerCol * hc, const char * fileOfFileNames, float defaultDisplayPeriod);
   virtual int setParams(PVParams * params);

private:
   int initialize_base();
   int initializeMovie(const char * name, HyPerCol * hc, const char * fileOfFileNames, float displayPeriod);
   int copyReducedImagePortion();
   const char * getNextFileName();
   const char * getNextFileName(int n_skip);

   double displayPeriod;   // length of time a frame is displayed
   double nextDisplayTime; // time of next frame

   int randomMovie;       // these are used for performing a reverse correlation analysis
   float randomMovieProb;

   bool echoFramePathnameFlag; // if true, echo the frame pathname to stdout
   // bool newImageFlag; // true when a new image was presented this timestep;

   int startFrameIndex;
   int skipFrameIndex; // skip this number of frames between each load

   bool autoResizeFlag;

   char inputfile[PV_PATH_MAX];  // current input file name
   char * movieOutputPath;  // path to output file directory for movie frames

   int numFrames; //Number of frames
   bool readPvpFile;
   char * fileOfFileNames;

   PV_Stream * filenamestream;

   bool writeFrameToTimestamp;
   PV_Stream * timestampFile;
   //bool updateThisTimestep;
};

}

#endif /* MOVIE_HPP_ */
