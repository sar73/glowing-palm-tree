:: POINTS TO LASTOOLS
set PATH=%PATH%;C:\lastools\bin;

:: CHANGES DIRECTORY
cd/d X:\Arch^&CivilEng\ResearchProjects\GGiardina\PhD\sar73\CaseStudies\Napa\Data

::Indexing significantly improves the speed of spatial queries
::lasindex -i 2014\overlapped\*.laz -cores 3
::lasview -i 2014\overlapped\*.laz -gui

:: wo make sure that our work will be worthwhile by running a quick visualization based of how well the flight strips fit togeth
::Examine how well the flightstrips fit together by identifying 
lasoverlap -i laser\2014\overlapped\*.laz ^
            -odir LasTools\Overlap ^
            -odix "merged-overlap" -opng ^