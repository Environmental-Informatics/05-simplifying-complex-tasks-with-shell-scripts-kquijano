# Environmental Informatics

## Assignment 05 - Simplifying Complex Tasks with Shell Scripts

### Lab Objectives

On completion of this lab, students will be able to:
1. Use basic commands in the Linux OS to automate complex processing tasks especially relating to a large number of files; and
2. Create simple plots using the Generic Mapping Tools (gmt) and convert the resulting figures into other image formats.

### Reading Assignment

Work through this tutorial for practical experience in using the Bash scripting language:  

- [Ryans Tutorials](https://ryanstutorials.net/): [Bash Scripting Tutorial](https://ryanstutorials.net/bash-scripting-tutorial/)

Bash (the **B**ourne **A**gain **Sh**ell) is another programming language, much like Python, but shell scripting languages are an integral part of the Linux operating system. Once you have completed the tutorial, you should have the skills required to write a bash script to complete the rest of the assignment.

To get more in-depth into Linux and the Bash scripting language, I reccommend the book [A Practical Guide to Linux](https://learning.oreilly.com/library/view/practical-guide-to/9780134774626/).  The following chapters are most relevent to this week's assignment:

- Chapter 8: The Bourne Again Shell (bash)
- Chapter 10: Programming the Bourne Again Shell (bash)

If you want to drill deeper on either of the two most common text file editors, then also check out:

- Chapter 6: The vim Editor
- Chapter 7: The emacs Editor

### The Lab Assignment

Clone this repository.  You are welcome to work through the tutorial in the repository directory, though I suggest that you make a subdirectory called "bash_tutorial" os something similar so that the main folder structure remains clean.  You can leave everything related to the tutorial in this directory and push it to the repository to preserve it, or do the tutorial somewhere else as nothing from it is required for the assingment this week.
      
For this week's assignment, you will write a single Bash script called **"ProcessStations.sh"**, which will run from the main directory of this repository and will work when the subdirectory StationData is present.  

The script should do the following:

#### Part I: Identify and separate out "high elevation" stations from the rest

1. Search through the contents of the station files in the StationData directory (try: a loop, for example `for file in StationData/*`), 
4. Identify those stations at altitudes equal to or greater than 200 feet (try: grep or awk), and 
5. Copy those stations above an elevation of 200 feet (try: cp) to a new directory called "HigherElevation" (try: mkdir).

- The program should run without errors, whether or not the directory "HigherElevation" exists.  So your program should use a conditional chack to see if the "HigherElevation" directory already exists (see [This page on how to check if a directory exists with Bash](https://www.cyberciti.biz/faq/howto-check-if-a-directory-exists-in-a-bash-shellscript/))
- In order to copy a file from one directory to another, you will need to be able to extract just the filename (e.g., remove the path from the filename string).  There are many ways to do this, but [here is a page I think will be helpful](https://www.cyberciti.biz/faq/bash-get-basename-of-filename-or-directory-name/).
- Note that Bash works only with integer math, which affects conditional statments in odd ways.  You cannot simply use `if [[ ${altitude} >= 200 ]]; then` to check the elevation, instead you will need to bring in additional tools.  You can do all of this using `awk`, but you can also use Bash's numerical context.  [Both of these methods are discussed on this site](https://stackoverflow.com/questions/8654051/how-to-compare-two-floating-point-numbers-in-bash), but there are other options as well.

#### Part II: Plot the locations of all stations, while highlighting the higher elevation stations

Once Part 1 is completed, you should have two directories in the repository: StationsData and HigherElevation.  The first contains all of the station files, while the second contains only those stations that are at or above 200 feet.  For this part of the assignment, you will use several additional Linux tools to construct a location plot, and convert that plot to an image file.  In particular, we will be using the [Generic Mapping Tools (GMT)](https://github.com/GenericMappingTools/gmt), a suite of 90+ command line tools for manipulating geographic and Cartesian data sets and producing PostScript illustrations.  This is my favorite tool for making presentation graphics - something we will get to later in the course.

8. Use command line tools to extract latitude and longitude for each file in the StationData folder, and again in the HigherElevation folder.
   - There are many ways to do this, but I used a combination of `awk` commands to strip data from the files, and teh `paste` command line tool to put them back together into a single file.
   - For example, the command `awk '/Longitude/ {print -1 * $NF}' StationData/Station_*.txt > Long.list` 
     - uses the regular expression `/Longitude/` to extract the line from each file in `StationData_*.txt` that includes the word "Longitude", 
     - it then prints the last item on the line (`print $NF`), which is the longitude value (but it also multiplies that values by "-1", why?), and
     - it sends the output from the command to a new file called "Long.list".
   - Modify the command so that it extracts the Latitude values to a file called "Lat.list"
   - Finally use the Linux command `paste Long.list Lat.list > AllStation.xy`.
   - Look at the contents of the file "AllStations.xy", does it look like latitude and longitude coordinates?
   - modify those commands again to extract the same information from the HigherEelvation stations, and save that data to a file called "HEStations.xy".
   - When run, your script **ProcessStations.py**, should now create the files AllStations.xy and HEStations.xy.
7. Your script should now load the `gmt` package using the command `module load gmt`.  
   - Add this command to your script, then the package is loaded while the script is running.  It will always be there when needed, and will not conflict with other modules you might use for other parts of your processing.
9. You will now use 2 command from GMT to generate a plot.
   - The `gmt pscoast` command will draw land and water surfaces as well as politcal boundaries.  Details of the command and its options can be found at [http://gmt.soest.hawaii.edu/doc/5.3.2/pscoast.html](http://gmt.soest.hawaii.edu/doc/5.3.2/pscoast.html).
   - The `gmt psxy` command will draw X-Y pairs of data in cartesian or geographic coordinates.  Details of the command and its options can be found at [http://gmt.soest.hawaii.edu/doc/5.3.2/psxy.html](http://gmt.soest.hawaii.edu/doc/5.3.2/psxy.html).
   - Add this block of code to your Bash script to generate a basic figure:
   
     ```
     gmt pscoast -JU16/4i -R-93/-86/36/43 -B2f0.5 -Ia/blue -Na/orange -P -K -V > SoilMoistureStations.ps
     gmt psxy AllStation.xy -J -R -Sc0.15 -Gblack -K -O -V >> SoilMoistureStations.ps
     gmt psxy HEStation.xy -J -R -Sc0.15 -Gred -O -V >> SoilMoistureStations.ps
     ```

   - The first line drawns rivers, coastlines and political boundaries.
   - The second line adds small black circles for all station locations.
   - The third line adds red circles for all higher elevation stations.
   - use the command `gv SoilMoistureStations.ps &` to view the figure.  Note that you can leave it running and use the "reload" button as you complete the next steps.
   - Make the following changes to the code I gave you (use the links I provided to the on-line help pages, or the command plus `--help` to access local information; the `man` command does not work for the gmt module maintained by ITaP):
     - Fill the lakes with the color "blue".
     - Draw coastlines and political boundaries with the higher resolution database.
     - Make the symbol for the higher elevation stations smaller, so that you can see the underlying black circle.
     
#### Part III: Convert the figure into other imge formats

1. Now that you have the figure drawn, lets clean it up and convert it to a TIFF image file
    - Use the command `ps2epsi` to convert the postscript file created by GMT into a standard conforming encapsulated postscript file that is correctly cropped to its bounding box and includes a preview image.  Use `man ps2epsi` or `ps2epsi --help` to learn about the command.
      - Try opening the new file "SoilMoistureStations.epsi" using `gv`, do you see any differences?
    - Finally, use the ImageMagic `convert` comamnd to change image file formats.
      - Convert the EPSI file into a TIF image, using a density of 150 dots per inch (dpi).
      - Both this image and the EPSI file can be imported into Word or other document editors.
      - The EPSI file is a vector format, so will always print at the maximum resolution of the printer, but when displayed in a program like Word only the low resolution preview image may be seen.
      - The TIF image is only as good as the original conversion, so in this case it will never be better than 150 dpi.  That is too low resolution for a journal, and probably too high for a web site, but it is a reasonable balance for a draft document that needs to be shared (and should not be too large).
      
1. When run, your program should now process the station data files and generate three versions of a figure showing their locations (a PS, an EPSI, and a TIF file).
      
#### What to turn in...

Push the repository with the working and well commented code to GitHub.  Your program must work by called **ProcessStations.sh** and must work with the file structure and filenames that I have provided (so be sure to use relative, not absolute path names).
