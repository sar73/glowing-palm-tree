:: POINTS TO LASTOOLS
set PATH=%PATH%;C:\lastools\bin;

:: CHANGES DIRECTORY
cd/d X:\Arch^&CivilEng\ResearchProjects\GGiardina\PhD\sar73\CaseStudies\Napa\Data

::Adapted from this material
::https://rapidlasso.com/2013/10/13/tutorial-lidar-preparation/
::https://groups.google.com/forum/#!topic/lastools/R9d5cMFb2_o

::Indexing significantly improves the speed of spatial queries
::lasindex -i Laser\2011_n\2011_n\*.laz -cores 3

::Before processing sanity check. Take before processing screenshot
::lasview -i Laser\2011_n\2011_n\*.laz -gui

::Now make sure that our work will be worthwhile by running a quick visualization based of how well the flight strips fit together
::Examine how well the flightstrips fit together by identifying 
::lasoverlap -i laser\2011_n\overlapped\*.laz ^
::            -odir LasTools\Overlap ^
::            -odix "merged-overlap" -opng ^

::Create a temporary tiles directory
rmdir LasTools\Tiles\2011_n /s /q
mkdir LasTools\Tiles\2011_n

:: create a temporary and reversible tiles with a size of 250 and a buffer of 25
::pastes all at once 
lastile -i laser\2011\*.laz ^
            -reversible -tile_size 500 -buffer 10 ^
           -odir LasTools\Tiles\2011_n ^
            -o tiled.laz -olaz 

::lasview -i LasTools\Tiles\2011_n*.laz -gui

:: create a temporary ground directory
::rmdir LasTools\Ground\2011_n /s /q
mkdir LasTools\Ground\2011_n

:: This is a tool for bare-earth extraction: it classifies LIDAR points into ground points (class = 2) and non-ground points
::(class = 1). This will run it on 4 cores (one tile per core) with town settings and ultra_fine refinement
::Pastes after a while
lasground -i LasTools\Tiles\2011_n\*.laz ^
            -town -ultra_fine ^
            -odir LasTools\Ground\2011_n -olaz ^
            -cores 4

::deletes the original tile directory and it's contents 
rmdir LasTools\Tiles\2011_n /s /q

::create a height tiles directory
::rmdir LasTools\Height\2011_n /s /q
mkdir LasTools\Height\2011_n

::Las Height uses the points classified as ground to construct a TIN and then calculates the height of all other points in respect to this ground 
::surface. This will ignore points 2m below ground and 30m above it
lasheight -i LasTools\Ground\2011_n\*.laz ^
            -drop_below 2 -drop_above 30 ^
            -odir LasTools\Height\2011_n -olaz ^
            -cores 4

::deletes the lasground directory and it's contents
rmdir LasTools\Ground\2011_n /s /q

::create a classify tiles directory
rmdir LasTools\Classify\2011_n /s /q
mkdir LasTools\Classify\2011_n

::This tool classifies buildings and high vegetation. It requires that both bare-earth points (lasground) and points above ground (lasheight) have been 
::computed. Step is for computing planarity/ruggedness. Higher = less false positives but it may miss smaller buildings. This can be verified with 
:: lasboundary and a kml output. Step size is the grid cell size for planar analysis. Lower = more accuracy, 
:: but the data must exist for interpolation to be accurate. Tutorial was 3
:: default is 2
lasclassify -i LasTools\Height\2011_n\*.laz ^
            -step 2 ^
            -odir LasTools\Classify\2011_n -olaz ^
            -cores 4

::deletes the las height directory and it's contents
::rmdir Lastools\Height\2011_n /s /q

::create a final tiles directory 
::rmdir LasTools\Final\2011_n /s /q
mkdir LasTools\Final\2011_n

::Create the final tiles and remove the buffer
::This is very quick...
lastile -i LasTools\Classify\2011_n\*.laz ^
            -set_user_data 0 ^
            -remove_buffer ^
            -odir LasTools\Final\2011_n -olaz

::delete the LasClassify
::rmdir LasTools\Classify\2011_n /s /q

::View 2011_n after processing. This can also be compared with the original
::to assess the quality of the process
::lasview -i LasTools\Final\2011_n.*laz -gui

mkdir LasTools\Footprints\2011_n
::Determines the building footprints. lower concavity is better but more computationally expensive
::default is 1.5, but 1.2 is the lowest without building loss Class 6 is buildings, if this was changed to 5 if would identify vegetation
lasboundary -i LasTools\Final\2011_n\*.laz -merged ^
            -keep_class 6 ^
            -concavity 1.5 -disjoint ^
            -odir LasTools\Footprints\2011_n ^
            -o 2011-ALL_step-2_concavity-2.kml
