#include "../src/layers/PVLayer.h"
#include <stdio.h>
#include <stdlib.h>

#define POS_ERROR 0.1

int main(int argc, char* argv[])
{
   float x, y;
   int k, kg, kf;

   int nf = 3;
   float nx = 64;
   float ny = 128;

   float x0 = -1.5;
   float y0 =  2.4;
   float dx = 2;
   float dy = 3;

   int inx = (int) nx;
   int iny = (int) ny;

   for (k = 0; k < inx*iny*nf; k++) {
      x  = xPos(k, x0, dx, nx, ny, nf);
      y  = yPos(k, y0, dy, nx, ny, nf);
      kf = featureIndex(k, nx, ny, nf);

      kg = globalIndex(kf, x, y, x0, y0, dx, dy, nx, ny, nf);

      if (kg != k) {
         printf("FAILED:TEST_POS: (old,new) = (%d,%d)\n", k, kg);
         exit(1);
      }
   }

   /*
    * calculation of index should be stable to small errors in position
    */
   for (k = 0; k < inx*iny*nf; k++) {
      x  = xPos(k, x0, dx, nx, ny, nf);
      y  = yPos(k, y0, dy, nx, ny, nf);
      kf = featureIndex(k, nx, ny, nf);

      x += POS_ERROR;
      y -= POS_ERROR;
      kg = globalIndex(kf, x, y, x0, y0, dx, dy, nx, ny, nf);

      if (kg != k) {
         printf("FAILED:TEST_POS: on shift (old,new) = (%d,%d)\n", k, kg);
         exit(1);
      }

      x -= 2*POS_ERROR;
      y += 2*POS_ERROR;
      kg = globalIndex(kf, x, y, x0, y0, dx, dy, nx, ny, nf);

      if (kg != k) {
         printf("FAILED:TEST_POS: on shift (old,new) = (%d,%d)\n", k, kg);
         exit(1);
      }
   }

  return 0;
}
