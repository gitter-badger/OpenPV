import os, sys
lib_path = os.path.abspath("/home/ec2-user/workspace/PetaVision/plab/")
sys.path.append(lib_path)
from plotRecon import plotRecon
from plotReconError import plotReconError

#For plotting
#import matplotlib.pyplot as plt

outputDir = "/home/ec2-user/mountData/occDom/"
skipFrames = 1 #Only print every 20th frame
doPlotRecon = True
doPlotErr = False
errShowPlots = False
layers = [
   "a6_LeftReconOccDom",
   "a13_RightReconOccDom",
   "a5_LeftRecon",
   "a12_RightRecon",
   "a3_LeftRescale",
   "a10_RightRescale"
   ]
#Layers for constructing recon error
preErrLayers = [
   "a2_LeftRescale",
   #"a26_DepthGT",
   #"a26_DepthGT",
   #"a31_RCorrReconAll",
   #"a31_RCorrReconAll",
   #"a31_RCorrReconAll",
]

postErrLayers = [
   "a7_LeftReconAll",
   #"a23_ForwardLayer",
   #"a31_RCorrReconAll",
   #"a28_RCorrReconS2",
   #"a29_RCorrReconS4",
   #"a30_RCorrReconS8",
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
   #.0294,
   #.0294,
   #.0294,
   #1,
   #1,
   #1,
   #1,
   #1,
   #1,
   #1,
   #1,
]


if(doPlotRecon):
   print("Plotting reconstructions")
   plotRecon(layers, outputDir, skipFrames)

if(doPlotErr):
   print("Plotting reconstruction error")
   plotReconError(preErrLayers, postErrLayers, preToPostScale, outputDir, errShowPlots, skipFrames, gtLayers)
