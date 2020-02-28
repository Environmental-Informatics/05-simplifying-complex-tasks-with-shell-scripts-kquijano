#!/bin/bash

# Karoll Quijano - kquijano
# 02/21/2020



## Part I. Identify and separate out high elevation stations

# Check for directories

if [ -d ./StationData ]
then
	echo 'StationData directory exists'
else
	echo 'StationData directory missing'
	break 
fi

if [ -d ./HigherElevation ]
then
	echo 'HigherElevation directory exists'
else
	mkdir ./HigherElevation	
	echo 'Creating directory HigherEvation'
fi


# Identify stations and copy to HigherElevation directory

for file in ./StationData/*
do 
	name=`basename "$file"`

	if 
		grep "Altitude: [>200]" $file
		then cp ./StationData/$name ./HigherElevation/$name
	fi

done



## Part II. plot the locations of all stations, highlighting the higher elevation stations

# Extract Lat Long from files. Multiply Long *-1 for west location
awk '/Longitude/ {print -1 * $NF}' StationData/Station_*.txt > Long.list
awk '/Latitude/ {print $NF}' StationData/Station_*.txt > Lat.list
paste Long.list Lat.list > AllStations.xy

# Repeat for HigherElevation directory
awk '/Longitude/ {print -1 * $NF}' HigherElevation/Station_*.txt > HELong.list
awk '/Latitude/ {print $NF}' HigherElevation/Station_*.txt > HELat.list
paste HELong.list HELat.list > HEStations.xy


# Load module GMT
module load gmt

# Generate plots with GMT commands
# Draw rivers and borders with a higher resolution database
gmt pscoast -JU16/4i -R-93/-86/36/43 -B2f0.5 -Cl/blue -Dh[+] -Ia/blue -Na/orange -P -K -V > SoilMoistureStations.ps
# Adds small black circles for all station locations
gmt psxy AllStations.xy -J -R -Sc0.15 -Gblack -K -O -V >> SoilMoistureStations.ps
# Adds red circles for all higher elevation stations with smaller symbol size than AllStations
gmt psxy HEStations.xy -J -R -Sc0.10 -Gred -O -V >> SoilMoistureStations.ps

# View figure
gv SoilMoistureStations.ps &


## Part III: Convert the figure into other image format

# Convert to epsi 
ps2epsi SoilMoistureStations.ps SoilMoistureStations.epsi

# Convert to tiff

convert SoilMoistureStations.ps -density 150x150 SoilMoistureStations.tiff






