import os, sys
lib_path = os.path.abspath("/home/slundquist/workspace/PetaVision/plab/")
sys.path.append(lib_path)
from plotRecon import plotRecon
from plotReconError import plotReconError

#For plotting
#import matplotlib.pyplot as plt

outputDir = "/nh/compneuro/Data/Depth/LCA/benchmark/stereo_train_rcorr_np_pop_code/"
skipFrames = 1
doPlotRecon = True
doPlotErr = False
errShowPlots = False
layers = [
   "a3_LeftReconS2",
   "a4_LeftReconS4",
   "a5_LeftReconS8",
   "a6_LeftReconAll",
   "a7_RightReconS2",
   "a8_RightReconS4",
   "a9_RightReconS8",
   "a10_RightReconAll",
   "a18_WTAGT",
   "a19_RCorrReconS2",
   "a20_RCorrReconS4",
   "a21_RCorrReconS8",
   "a22_RCorrReconAll",
   ]
#Layers for constructing recon error
preErrLayers = [
   "a2_LeftRescale",
   "a2_LeftRescale",
   "a2_LeftRescale",
   "a7_LeftReconAll",
   "a7_LeftReconAll",
   "a7_LeftReconAll",
]

postErrLayers = [
   "a4_LeftReconS2",
   "a5_LeftReconS4",
   "a6_LeftReconS8",
   "a4_LeftReconS2",
   "a5_LeftReconS4",
   "a6_LeftReconS8",
]

gtLayers = None
#gtLayers = [
#   #"a25_DepthRescale",
#   #"a25_DepthRescale",
#   #"a25_DepthRescale",
#   "a25_DepthRescale",
#   "a25_DepthRescale",
#   "a25_DepthRescale",
#]

preToPostScale = [
   .0294,
   .0294,
   .0294,
   1,
   1,
   1,
]


if(doPlotRecon):
   print "Plotting reconstructions"
   plotRecon(layers, outputDir, skipFrames)

if(doPlotErr):
   print "Plotting reconstruction error"
   plotReconError(preErrLayers, postErrLayers, preToPostScale, outputDir, errShowPlots, skipFrames, gtLayers)
