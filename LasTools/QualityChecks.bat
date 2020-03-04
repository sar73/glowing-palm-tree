:: POINTS TO LASTOOLS
set PATH=%PATH%;C:\lastools\bin;

:: CHANGES DIRECTORY
cd/d X:\Arch^&CivilEng\ResearchProjects\GGiardina\PhD\sar73\CaseStudies\Napa\Data

::Adapted from this tutorial
::https://rapidlasso.com/2013/10/13/tutorial-lidar-preparation/

::Indexing significantly improves the speed of spatial queries
lasindex -i Laser\2014\Sample\*.laz -cores 3
lasview -i Laser\2014\Sample\*.laz -gui

::Now make sure that our work will be worthwhile by running a quick visualization based of how well the flight strips fit togeth
::Examine how well the flightstrips fit together by identifying 
lasoverlap -i laser\2014\overlapped\*.laz ^
            -odir LasTools\Overlap ^
            -odix "merged-overlap" -opng ^

::Create a temporary tiles directory
rmdir LasTools\Tiles\Sample /s /q
mkdir LasTools\Tiles\Sample

:: create a temporary and reversible tiles with a size of 250 and a buffer of 25
::pastes all at once 
lastile -i laser\2014\sample\*.laz ^
            -reversible -tile_size 250 -buffer 25 ^
           -odir LasTools\Tiles\Sample ^
            -o tiled.laz -olaz 

:: create a temporary ground directory
rmdir LasTools\Ground\Sample /s /q
mkdir LasTools\Ground\Sample

:: This is a tool for bare-earth extraction: it classifies LIDAR
::points into ground points (class = 2) and non-ground points::
::(class = 1). This will run it on 4 cores (one tile per core) with
::town settings and ultra_fine refinement
::Pastes after a while
lasground -i LasTools\Tiles\Sample\*.laz ^
            -town -ultra_fine ^
            -odir LasTools\Ground\Sample -olaz ^
            -cores 4

::deletes the original tile directory and it's contents 
rmdir LasTools\Tiles\Sample /s /q

::create a height tiles directory
rmdir LasTools\Height\Sample /s /q
mkdir LasTools\Height\Sample

::Las Height uses the points classified as ground to construct a TIN and 
::then calculates the height of all other points in respect to this ground 
::surface. This will ignore points 2m below ground and 30m above it
lasheight -i LasTools\Ground\Sample\*.laz ^
            -drop_below 2 -drop_above 30 ^
            -odir LasTools\Height\Sample -olaz ^
            -cores 4

::create a height tiles directory
rmdir LasTools\Classify\Sample /s /q
mkdir LasTools\Classify\Sample

::This tool classifies buildings and high vegetation. It requires that both
::bare-earth points (lasground) and points above ground (lasheight) have been 
::computed. Step is for computing planarity/ruggedness. Higher = less false
::positives but it may miss smaller buildings

lasclassify -i LasTools\Height\Sample\*.laz ^
            -step 3 ^
            -odir LasTools\Classify\Sample -olaz ^
            -cores 4

::create a final tiles directory 

rmdir LasTools\Final\Sample /s /q
mkdir LasTools\Final\Sample

::Create the final tiles and remove the buffer
::This is very quick...
lastile -i LasTools\Classify\Sample\*.laz ^
            -set_user_data 0 ^
            -remove_buffer ^
            -odir LasTools\Final\Sample -olaz

::Measure-Command { .\io.exe }
::start "" /wait cmd /c "echo Quality checking complete!&echo(&pause"

