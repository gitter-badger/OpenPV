import os, sys
lib_path = os.path.abspath("../")
sys.path.append(lib_path)
import numpy as np
from readPvpFile import readHeaderFile, readData, toFrame
from scipy.misc import imsave

#For plotting
#import matplotlib.pyplot as plt

#datasetVal = 2
#eyeVal = 1
#depthFileListDir = "/nh/compneuro/Data/Depth/depth_data_"+str(datasetVal) + "/list/"
#depthFileList = depthFileListDir + "depth_0" + str(eyeVal) + ".txt"
#pvpFileName = "/nh/compneuro/Data/Depth/depth_data_1/pvp/depth_0" + str(eyeVal)+ ".pvp"
outputDir = "/nh/compneuro/Data/Depth/LCA/binoc_new_err_test/"
#outputDir = "/nh/compneuro/Data/Depth/LCA/dataset02/"
readFromCheckpoint = False
lastCheckpoint = 200000
skipFrames = 1 #Only print every 20th frame
layers = [
   #"a0_LeftImage",
   #"a1_LeftBipolar",
   #"a2_LeftGanglion1",
   #"a3_LeftGanglion2",
   #"a4_LeftDownsample1",
   #"a5_LeftDownsample2",
   "a6_LeftRescale1",
   "a7_LeftRescale2",
   #"a8_LeftError1",
   #"a9_LeftError2",
   "a10_LeftRecon1",
   "a11_LeftRecon2",
   #"a12_LeftDepthImage",
   #"a13_LeftDepthDownsample",
   #"a14_LeftDepthBin",
   #"a15_LeftDepthBuffer",
   "a16_LeftDepthRescale",
   "a17_LeftDepthRecon",
   #"a18_RightImage",
   #"a19_RightBipolar",
   #"a20_RightGanglion1",
   #"a21_RightGanglion2",
   #"a22_RightDownsample1",
   #"a23_RightDownsample2",
   #"a24_RightRescale1",
   #"a25_RightRescale2",
   #"a26_RightError1",
   #"a27_RightError2",
   #"a28_RightRecon1",
   #"a29_RightRecon2",
   #"a30_RightDepthImage",
   #"a31_RightDepthDownsample",
   #"a32_RightDepthBin",
   #"a33_RightDepthBuffer",
   "a34_RightDepthRescale",
   "a35_RightDepthRecon",
   #"a36_Position",
   #"a37_PosDownsample",
   "a38_PosRescale",
   #"a39_PosError",
   "a40_PosRecon",
   #"a41_BinocularV1S1",
   #"a42_BinocularV1S2",
   ]

checkpointDir = outputDir + "Checkpoints/Checkpoint"+str(lastCheckpoint)+"/"

def matToImage(mat):
   (Y, X, Z) = np.shape(mat)
   #Get stepsize
   stepSize = float(1)/Z
   #Grab max value of bins
   maxMat = np.max(mat, 2)
   #Tile maxmat into shape of origonal mat
   maxMat = np.tile(maxMat, (Z, 1, 1))
   #Change back into origonal shape
   maxMat = np.swapaxes(maxMat, 0, 1)
   maxMat = np.swapaxes(maxMat, 1, 2)
   #Grab indicides of matrix where it matches
   m1 = mat != 0
   m2 = mat == maxMat
   bolMat = m1*m2
   (yidx, xidx, zidx) = bolMat.nonzero()
   outimg = np.zeros((Y, X))
   upthresh = stepSize*(zidx+1)
   lowthresh = stepSize*zidx
   idxVal = lowthresh + (upthresh - lowthresh)/2
   outimg[yidx, xidx] = idxVal
   return outimg

#Scales mat to be between 0 and 1 for image saving
def scaleMat(mat):
   (Y, X, Z) = np.shape(mat)
   assert Z == 1
   img = mat[:, :, 0]
   img = (img - np.min(img)) / (np.max(img) - np.min(img))
   return img


reconDir = outputDir + "Recon/"
if not os.path.exists(reconDir):
   os.makedirs(reconDir)

#Open file
for layername in layers:
#layername = layers[0]
   if readFromCheckpoint:
      pvpFile = open(checkpointDir + layername + ".pvp", 'rb')
   else:
      pvpFile = open(outputDir + layername + ".pvp", 'rb')

   #Grab header
   header = readHeaderFile(pvpFile)
   shape = (header["ny"], header["nx"], header["nf"])
   numPerFrame = shape[0] * shape[1] * shape[2]

   if readFromCheckpoint:
      #Read only one timestamp
      (idx, mat) = readData(pvpFile, shape, numPerFrame)
      if header["nf"] > 1:
         img = matToImage(mat)
      else:
         img = scaleMat(mat)
      imsave(reconDir + layername + ".png", img)
   else:
      #Skip start frame
      #toFrame(startFrame, pvpFile, numPerFrame, header["headersize"])

      #Read until errors out (EOF)
      (idx, mat) = readData(pvpFile, shape, numPerFrame)
      #While not eof
      while idx != -1:
         if header["nf"] > 1:
            img = matToImage(mat)
         else:
            img = scaleMat(mat)
         imsave(reconDir + layername + str(int(idx[0])) + ".png", img)
         #Read a few extra for skipping frames
         for i in range(skipFrames):
             (idx, mat) = readData(pvpFile, shape, numPerFrame)
             if(idx == -1):
                 break


#plt.imshow(img)
#plt.show()
