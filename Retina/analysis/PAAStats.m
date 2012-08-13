
close all
[time,avgON]=pvp_readLayerStatsProbe("PAAmacrineON");
[time,avgOFF]=pvp_readLayerStatsProbe("PAAmacrineOFF");

rtime = 1:time

semilogy(rtime,avgON,"1",rtime,avgOFF,"3");


titlestring = ["PAA Spike Response (",dirname,") to 1/f  background with luminance of 128"] 
title(titlestring,"fontsize",15);

t1=text (250,5,"ON cells");
set(t1,'color',[1 0 0],"fontsize",20)
t2=text (250,2,"OFF cells");
set(t2,'color',[0 0 1],"fontsize",20);
xlabel("time [msec]","fontsize",20);

ylabel("Average Spike Frequency in Hz (/dt ms)","fontsize",20);
ymax = 1.5 * max(avgOFF);

grid;
axis([0,duration,0.1,ymax]);
;
 
outname = ["../octave/PAAmacrineStats_",dirname,".pdf"]
print(outname,"-dpdf");
