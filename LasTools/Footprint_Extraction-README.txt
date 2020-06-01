This is the read-me guide for the Footprint_Extraction.bat script file.
It should NOT be referred to for any other files. 

The Footprint_extraction tool will extract the footprints of buildings from .las or .laz files
and ouput a .shp file. This can be read by QGIS or ArcQGIS

In order to apply the script to a new environment, 11 parameters 
need updating:

1. The LasTools Path
2. ALL Directories
Pre-Analysis Checks
    NONE
Prepare Data
    LasTiles
        3. -tile_size
        4. -buffer
Extract Buildings Only
    Las Ground
        5. -town (e.g. -city)
        6. -fine (e.g. -coarse or -ultra_file)
        7. -cores (e.g. 6 if available)
    Las Height
        8. -cores (e.g. 6 if available)
    Las Classify
        9. -step 
        10. -cores (e.g. 6 if available)
Remove Buffer
    NONE
Convert into footprints
    Las Boundary
        11. -concavity

This should be viewed as a checklist for changes. Details of what the actual
paramters are can be found within the .bat file.

Both the .bat file and this docuemnt were created by Sachin Alexander Reddy, Feb 2020 - May 2020.
