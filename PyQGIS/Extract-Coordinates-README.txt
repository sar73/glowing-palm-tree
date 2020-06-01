This is the read-me guide for the Extract-Coordinates.py script file.
It should NOT be referred to for any other files. 

The Extract-Coordinates tool will extract the coordinates from the laser files and
a user defind polygon.  

In order to apply the script to a new environment, 5 parameters 
need updating:
    class Extract_LasInfo_Coors(object):
        1.lasinfo_import_location - This points the programme to the laser file location
        2.lasinfo_coor_export_location - This is where the .csv file containing coordinates will be exported to
        def request_information(self)
            3. self.user_coors - Define the input CRS. This can be found through LasInfo + QGIS
        def convert_lasinfo_coors(self):
            4. output_projection - Define the output CRS. This should match QGIS
    class Extract_Polygon_Coors(object):
        5. polygon_coor_export_location - This is where the .csv file containing the polygon coors will be exported to
    
The above has been further highlighted in the .py file through the use of comment colours, where
Orange comments instruct that variables need changing, whereas Green provides general information.

Both the .py file and this document were created by Sachin Alexander Reddy, Feb 2020 - May 2020.
