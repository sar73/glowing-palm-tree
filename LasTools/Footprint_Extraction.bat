:: POINTS TO LASTOOLS
set PATH=%PATH%;C:\lastools\bin;

:: CHANGES DIRECTORY
cd/d X:\Arch^&CivilEng\ResearchProjects\GGiardina\PhD\sar73\CaseStudies\Napa\Data

::Adapted from this material
::https://rapidlasso.com/2013/10/13/tutorial-lidar-preparation/
::https://groups.google.com/forum/#!topic/lastools/R9d5cMFb2_o


::  ------------------ PRE ANALYSIS CHECKS -----------------------

::Indexing significantly improves the speed of spatial queries
::lasindex -i Laser\2011\Sample\*.laz -cores 4

::Before processing sanity check. Take before processing screenshot
::lasview -i Laser\2011\Sample\*.laz -gui

::Now make sure that our work will be worthwhile by running a quick visualization based of how well the flight strips fit together
::Examine how well the flightstrips fit togethser by identifying 
::lasoverlap -i laser\2011\overlapped\*.laz ^
::            -odir LasTools\Overlap ^
::            -odix "merged-overlap" -opng ^

:: ---------------------------------------------------
:: ----------------- PREPARE DATA --------------------
:: ---------------------------------------------------

::Create a temporary tiles directory
::rmdir LasTools\FootprintExtraction\1_Tiles\2011 /s /q
::mkdir LasTools\FootprintExtraction\1_Tiles\2011

:: ---------   LAS TILES    ---------
:: This is a tool for bare-earth extraction: it classifies LIDAR
::points into ground points (class = 2) and non-ground points (class = 1).

:: PARAMETERS TO CHANGE 
:: Tile Size: decrease if sample is small
:: Buffer: This is necessary for triangulation during Las Height. 

::lastile -i laser\2011\Sample\*.laz ^
::            -tile_size 500 -buffer 25 ^
::            -odir LasTools\FootprintExtraction\1_Tiles\2011 ^
::            -o tiled.laz -olaz 

::Check if tiles and buffers seem sensible
::lasview -i LasTools\FootprintExtraction\1_Tiles\2011\*.laz -gui

::pause

:: ---------------------------------------------------
:: ----------------- EXTRACT BUILDINGS ONLY ----------
:: ---------------------------------------------------

:: create a temporary ground directory
::rmdir LasTools\FootprintExtraction\2_Ground\2011 /s /q
::mkdir LasTools\FootprintExtraction\2_Ground\2011


:: ---------   LAS GROUND    ---------
:: This is a tool for bare-earth extraction: it classifies LIDAR
::points into ground points (class = 2) and non-ground points (class = 1).

:: PARAMETERS TO CHANGE 
:: Step 5 = forests 10 = towns, 25 = cities.
:: Refinement: Ultra fine = steep hills, fine = hills, nothing = flat
:: Unlike other tools, this pastes right at the end of the process.

::lasground -i LasTools\FootprintExtraction\1_Tiles\2011\*.laz ^
::            -town -fine ^
::            -odir LasTools\FootprintExtraction\2_Ground\2011 -olaz ^
::            -cores 4

::deletes the original tile directory and it's contents 
::rmdir LasTools\FootprintExtaction\1_Tiles\2011 /s /q


::create a height tiles directory
::rmdir LasTools\FootprintExtraction\3_Height\2011 /s /q
::mkdir LasTools\FootprintExtraction\3_Height\2011

:: ---------   LAS HEIGHT    ---------
::Las Height uses the points classified in LasGround to construct a TIN. 
::Then calculates the height of all other points in respect to this ground

:: PARAMETERS TO CHANGE (x3.28 for imperial)
:: Drop_below will ignore points below this
:: Drop_above will ignore points above this 

::lasheight -i LasTools\FootprintExtraction\2_Ground\2011\*.laz ^
::            -drop_below 6 -drop_above 30 ^
::           -odir LasTools\FootprintExtraction\3_Height\2011 -olaz ^
::            -cores 4

::deletes the lasground directory and it's contents
::rmdir LasTools\FootprintExtraction\2_Ground\2011 /s /q


::create a classify tiles directory
::rmdir LasTools\FootprintExtraction\4_Classify\2011 /s /q
::mkdir LasTools\FootprintExtraction\4_Classify\2011

:: ---------   LAS CLASSIFY    ---------
::This tool classifies buildings and high vegetation. It requires both
::bare-earth points (lasground) and points above ground (lasheight)

:: PARAMETERS TO CHANGE
:: Step: computers the planarity and ruggenedness. Higher = less false positives
::LasClassify -i LasTools\FootprintExtraction\3_Height\2011\*.laz ^
::            -step 3 ^
::            -odir LasTools\FootprintExtraction\4_Classify\2011 -olaz ^
::            -cores 4

::deletes the las height directory and it's contents
::rmdir Lastools\Height\2011 /s /q

::lasview -i LasTools\FootprintExtraction\4_Classify\2011\*.laz -gui

::pause

:: ----------------------------------------------------
:: ----------------- REMOVE BUFFER --------------------
:: ----------------------------------------------------

rmdir LasTools\FootprintExtraction\5_Clean\2011 /s /q
mkdir LasTools\FootprintExtraction\5_Clean\2011

:: ---------   LAS TILE    ---------
:: This tool removes the buffer as triangulation is now complete
:: PARAMETERS TO CHANGE
:: NONE
lastile -i LasTools\FootprintExtraction\4_Classify\2011\*.laz ^
           -set_user_data 0 ^
            -remove_buffer ^
            -odir LasTools\FootprintExtraction\5_Clean\2011 -olaz


::delete the LasClassify
::rmdir LasTools\Classify\2011 /s /q

::View classified laser data. This can also be compared with the original
::to assess the quality of the process, or just used as a santiy check
::lasview -i LasTools\FootprintExtraction\5_Clean\2011\*.laz -gui

::pause

:: ----------------------------------------------------------------
:: ----------------- CONVERT INTO FOOTPRINTS ----------------------
:: ----------------------------------------------------------------

::rmdir LasTools\FootprintExtraction\6_Footprints\2011 /s /q
::mkdir LasTools\FootprintExtraction\6_Footprints\2011
::Determines the building footprints. lower concavity is better but more computationally expensive
::default is 1.5, but 1.2 is the lowest without building loss Class 6 is buildings, if this was changed to 5 if would identify vegetation
::lasboundary -i LasTools\FootprintExtraction\5_Clean\2011\*.laz -merged ^
::            -keep_class 6 ^
::            -concavity 2 -disjoint ^
::            -odir LasTools\FootprintExtraction\6_Footprints\2011 ^
::            -o 2011_Browns_6-30_3_2.shp
