:: POINTS TO LASTOOLS
set PATH=%PATH%;C:\lastools\bin;

:: CHANGES DIRECTORY
cd/d X:\Arch^&CivilEng\ResearchProjects\GGiardina\PhD\sar73\CaseStudies\Napa\Data

::Adapted from this material
::https://rapidlasso.com/2013/10/13/tutorial-lidar-preparation/
::https://groups.google.com/forum/#!topic/lastools/R9d5cMFb2_o


::  ------------------ PRE ANALYSIS CHECKS -----------------------

::Indexing significantly improves the speed of spatial queries
::lasindex -i Laser\2014\Sample\*.laz -cores 4

::Before processing sanity check. Take before processing screenshot
::lasview -i Laser\2014\Sample\*.laz -gui

::Now make sure that our work will be worthwhile by running a quick visualization based of how well the flight strips fit together
::Examine how well the flightstrips fit togethser by identifying 
::lasoverlap -i laser\2014\overlapped\*.laz ^
::            -odir LasTools\Overlap ^
::            -odix "merged-overlap" -opng ^

::pause

:: ----------------- EXTRACT BUILDINGS ONLY --------------------

::Create a temporary tiles directory
rmdir LasTools\FootprintExtraction\1_Tiles\2014 /s /q
mkdir LasTools\FootprintExtraction\1_Tiles\2014

:: create a temporary and reversible tiles with a size of 250 and a buffer of 25
::pastes all at once 
lastile -i laser\2014\Sample\*.laz ^
            -tile_size 250 -buffer 25 ^
           -odir LasTools\Tiles\2014 ^
            -o tiled.laz -olaz 

::lasview -i LasTools\Tiles\2014\*.laz -gui

::pause

:: create a temporary ground directory
rmdir LasTools\FootprintExtraction\2_Ground\2014 /s /q
mkdir LasTools\FootprintExtraction\2_Ground\2014

:: This is a tool for bare-earth extraction: it classifies LIDAR points into ground points (class = 2) and non-ground points
::(class = 1). This will run it on 4 cores (one tile per core) with town settings and ultra_fine refinement
::Pastes after a while
lasground -i LasTools\Tiles\2014\*.laz ^
            ::-town - ultra_fine ^ Town is 10. Lower is better for forests
            -step 8 -fine ^
            -odir LasTools\Ground\2014 -olaz ^
            -cores 4

::deletes the original tile directory and it's contents 
rmdir LasTools\Tiles\2014 /s /q

::create a height tiles directory
::rmdir LasTools\Height\2014 /s /q
mkdir LasTools\Height\2014

::Las Height uses the points classified as ground to construct a TIN and then calculates the height of all other points in respect to this ground 
::surface. This will ignore points below 2m below and 30m above
lasheight -i LasTools\Ground\2014\*.laz ^
            ::-replace_z ^
            -drop_below 1 -drop_above 10 ^
            ::-class 2 6 ^
            -odir LasTools\Height\2014 -olaz ^
            -cores 4

::lasheight -i LasTools\Ground\2014\*.laz ^
::           -drop_below 2 -drop_above 30 ^
::            -odir LasTools\Height\2014 -olaz ^
::            -cores 4

::deletes the lasground directory and it's contents
::rmdir LasTools\Ground\2014 /s /q


::create a classify tiles directory
::rmdir LasTools\Classify\2014 /s /q
mkdir LasTools\Classify\2014

::This tool classifies buildings and high vegetation. It requires that both bare-earth points (lasground) and points above ground (lasheight) have been 
::computed. Step is for computing planarity/ruggedness. Higher = less false positives but it may miss smaller buildings. This can be verified with 
:: lasboundary and a kml output. Step size is the grid cell size for planar analysis. Lower = more accuracy, 
:: but the data must exist for interpolation to be accurate. Tutorial was 3
:: default is 2
lasclassify -i LasTools\Height\2014\*.laz ^
            -step 2 ^
            -odir LasTools\Classify\2014 -olaz ^
            -cores 4

::deletes the las height directory and it's contents
::rmdir Lastools\Height\2014 /s /q

::create a final tiles directory 
rmdir LasTools\Final\2014 /s /q
mkdir LasTools\Final\2003_new

::Create the final tiles and remove the buffer
::This is very quick...
lastile -i LasTools\Classify\2014\*.laz ^
            -set_user_data 0 ^
            -remove_buffer ^
            -odir LasTools\Final\2003_new -olaz

::delete the LasClassify
::rmdir LasTools\Classify\2014 /s /q

::View 2014 after processing. This can also be compared with the original
::to assess the quality of the process

lasview -i LasTools\Final\2003_new\*.laz -gui

pause

:: ----------------- CONVERT INTO FOOTPRINTS ----------------------

::mkdir LasTools\Footprints\2014
::Determines the building footprints. lower concavity is better but more computationally expensive
::default is 1.5, but 1.2 is the lowest without building loss Class 6 is buildings, if this was changed to 5 if would identify vegetation
lasboundary -i LasTools\Final\2003_new\*.laz -merged ^
            -keep_class 6 ^
            -concavity 1.9 -disjoint ^
            -odir LasTools\Footprints\2014 ^
            -o 2014_Browns_1-10_2_2.shp
            ::-o 2003_Browns_3-10_3_1-9.shp
