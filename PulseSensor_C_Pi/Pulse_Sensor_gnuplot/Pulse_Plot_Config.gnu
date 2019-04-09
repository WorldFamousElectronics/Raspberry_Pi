#	GNUPLOT CONFIG FILE
#	You can use as-is or modify as needed

unset log                               # remove any log-scaling
unset title								# remove any titles
unset label                             # remove any previous labels
set title "Pulse Sensor"
set xlabel "Samples"
set ylabel "Pulse Wave"
#set key 0.01,100
set xr [0:100]
set yr [0:1024]
