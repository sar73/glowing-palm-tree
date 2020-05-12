#This document contains the two coordinate extraction methods
#The first class extracts the polygon, the second the those form the laser data
#Once this stage is complete, they will need to then be compared and modified

import glob #this is for w+r files in a directory
import re #extracts numerical characters from strings
import pandas as pd #columnises data and outputs to .csv
from pyproj import Proj, transform #converts coordinates
import numpy as np #has to be run with pandass
from PyQt5.QtWidgets import QInputDialog #This enables user inputs
from os import listdir
from os.path import isfile, join


class Extract_LasInfo_Coors(object):

    lasinfo_import_location =  (r"X:\Arch&CivilEng\ResearchProjects\GGiardina\PhD\sar73\CaseStudies\Napa\Data\LasTools\Info" + "\\" + "2011_all")
    lasinfo_coor_export_location =  r"C:\Users\sar73\OneDrive - University of Bath\Doctorate\Case Studies\Napa Valley\Data\QGis\May"

    #Gathers information on filenames, directories and CRS'
    def request_information(self):
        global import_filenames, export_file
        #Ask user for filename, acquisition year and CRS
        self.user_filename = "Laser_Coordinates_2014"
        #self.user_coors = 26910 #2003 and 2014 (opentopo)
        self.user_coors = 6418 #2011 (USGS)
        
        #Below request input from the user
        '''self.user_filename = input("Save file as: ")
        self.user_coors = input("Please choose CRS: ")'''
        
        #Import the filenames form the dir and create an export path + file
        import_filenames = [f for f in listdir(self.lasinfo_import_location) if isfile(join(self.lasinfo_import_location, f))]
        #self.import_filenames = [f for f in listdir(self.lasinfo_import_location) if isfile(join(self.lasinfo_import_location, f))]
        #self.export_file = self.lasinfo_coor_export_location + "\\" + self.user_filename + ".csv"
        export_file = self.lasinfo_coor_export_location + "\\" + self.user_filename + ".csv"

        #Validation to ensure filename contains no spaces
        if " " in self.user_filename:
            print ("Spaces are not allowed")
            self.request_information()
        else:
            self.clean_lasinfo_coors()
            #self.read_lasfiles()

    def read_lasinfo_coors(self, file):
        with open(file, 'rt') as fd:
            for i, line in enumerate(fd):
                if i == 19:
                    self.min = str(line)
                elif i == 20:
                    self.max = str(line)
        return str(self.min) + str(self.max)

    def clean_lasinfo_coors(self):
        #Complete the folder path & load all the txt files in that directory
        complete_folder_path = self.lasinfo_import_location + "\\"
        lasinfo_files = glob.glob(complete_folder_path + "*.txt")
        
        #Map extracted lines from read_lasinfo_coors() to the various
        #LasInfo .txt files
        map_lines_and_files = list(map(self.read_lasinfo_coors, lasinfo_files))
        output_strings = re.findall("\d+\.\d+", str(map_lines_and_files))

        #Remove the z coordinate info and create x and y lists
        del output_strings[2::3]
        self.x_min = output_strings[::4] 
        self.y_min = output_strings[1::4] 
        self.x_max = output_strings[2::4] 
        self.y_max = output_strings[3::4] 
        #print (self.x_min, self.y_min, self.x_max, self.y_max)
        
        self.convert_lasinfo_coors()

    #Covert coordinates and output to .csv
    def convert_lasinfo_coors(self):
        global x2, x3, y2, y3
        #Select the input and output CRS. Input is selected by user
        input_projection = Proj('epsg:'+ str(self.user_coors))
        output_projection = Proj('epsg:4326') #Match to baseline CRS

        #Covert coordinates from list to array
        xmin, ymin = np.array(self.x_min,float), np.array(self.y_min,float)
        xmax, ymax = np.array(self.x_max,float), np.array(self.y_max,float)
    
        #Transform coordinates
        y2, x2 = transform(input_projection, output_projection, xmin, ymin)
        y3, x3 = transform(input_projection, output_projection, xmax, ymax)
        
        '''
        #Define column headers
        data = pd.DataFrame()
        data ["Filename"] = self.import_filenames
        data ["X-Min"] = x2 
        data ["X-Max"] = x3
        data ["Y-Min"] = y2
        data ["Y-Max"] = y3
        #print(data)
        
        #Output to a .csv
        if not data.to_csv (self.export_file, index = False, header=True):
            print (self.user_filename, "created")
        else:
            print (self.user_filename, "creation FAILED")'''

class Extract_Polygon_Coors(object):
    polygon_coor_export_location = r"C:\Users\sar73\OneDrive - University of Bath\Doctorate\Case Studies\Napa Valley\Data\QGis\May"
   
    #Asks the user to choose a filename
    def request_filename(self):
        #global self.export_file
        #Captures the users filename and concatinates it to the the directory
        #request_filename = QInputDialog.getText(None, "Save file as","File name:")
        request_filename = 'Sach'
        clean_filename = list((request_filename[0]).split(','))
        self.export_file = (self.polygon_coor_export_location + "\\" + ((''.join(clean_filename))) + ".csv")
        
        #Validation to prevent spaces in file name. NEEDS WORK
        if " " in clean_filename:
            print ("Spaces are not allowed")
            self.request_filename()
        else:
            self.polygon_coor_extract()
    
    #Extracts the coordinates of the polygon(s)
    def polygon_coor_extract(self):
        global x_coor, y_coor
        layer = iface.activeLayer()
        features = layer.getFeatures()

        for feature in features:  
            geom = feature.geometry()
            geomSingleType = QgsWkbTypes.isSingleType(geom.wkbType())
            
            #Determine polygon type and filter out coordinates
            if geom.type() == QgsWkbTypes.PolygonGeometry:
                if geomSingleType:
                    x = re.findall("[-+]?\d*\.\d+|\d+", str(geom.asPolygon()))
                else:
                    x = re.findall("[-+]?\d*\.\d+|\d+", str(geom.asMultiPolygon()))
            else:
                print ("""Active layer is non-polygon geometry. 
                Could be point or line. See https://bit.ly/2UgufpF""")
                break
            
            #Round coordinates to correct length and split into x y lists
            float_coor = [round(float(i),6) for i in x]
            #self.xy = zip(float_coor[::2], float_coor[1::2])
            #self.x_coor = float_coor[::2]
            #self.y_coor = float_coor[1::2]
            x_coor = float_coor[::2]
            y_coor = float_coor[1::2]
            #return self.x_coor
            #print(list(self.xy))
            
            #self.polygon_coor_export()
            
    #Exports the coordinates to a csv file
    def polygon_coor_export(self):
        data = pd.DataFrame()
        data ["X Coordinates"] = self.x_coor
        data ["Y Coordinates"] = self.y_coor
        drop_last = data.drop(data.index[len(data)-1]) #This removes the repeated 1st coordinate
        #print (drop_last)

        #creates .csv
        if not drop_last.to_csv(self.export_file):
            print ("File created")
        else:
            print ("File failed")    

class compare_coors(object):
    def load_coors(self):
        x_min = x2 
        x_max = x3 
        y_min = y2
        y_max = y3
        files = import_filenames
        x_user = x_coor
        y_user = y_coor
        #print(x_min, x_max, y_min)
        #print(x_coor, y_coor)

        #minn = list(zip(x_min, y_min))
        #maxx = list(zip(x_max, y_max))
        #mima =  list(zip(minn,maxx))

        minn = [1, 1]
        maxx = [3, 3]
        user = [(2, 2), (1,2)]


        #print(mima)
        #user = list(zip(x_user, y_user))

        print  (minn [0] <user[0] < maxx[0] and\
                minn [1] <user[1] < maxx[1])

        results [(a, b) for a, b in minn if (a < 

        '''x = list(zip(x_min, x_max))
        y = list(zip(y_min, y_max))
        
        x_result = [(a, b) for a, b in x if any(a <= item <= b for item in x_user)]
        print(x_result)

        y_result = [(a, b) for a, b in y if any(a <= item <= b for item in y_user)]
        print(y_result) 
        '''
        #Assigning coors to a dataframe
        data = pd.DataFrame()
        data ["Filename"] = files
        data ["X-Min"] = x_min
        data ["Y-Min"] = y_min
        data ["X-Max"] = x_max
        data ["Y-Max"] = y_max
        #data ["X-Coor"] = x_coor
        #data ["Y-Coor"] = y_coor
        #print(data)

        #Export dataframe to .csv
        if not data.to_csv (export_file, index = False, header=True):
            print ("created")
        else:
            print ( "creation FAILED")

#Extract coordinates from the laser files
a = Extract_LasInfo_Coors()
a.request_information()

#Extract coordinates from the polygon
b = Extract_Polygon_Coors()
b.request_filename()

#Compare the laser and file coordinates
c = compare_coors()
c.load_coors()