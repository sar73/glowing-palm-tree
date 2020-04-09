#This document contains the two coordinate extraction methods
#The first class extracts the polygon, the second the those form the laser data
#Once this stage is complete, they will need to then be compared and modified

import glob, os #this is for w+r files in a directory
import re #extracts numerical characters from strings
import pandas as pd #columnises data and outputs to .csv
from pyproj import Proj, transform #converts coordinates
import numpy as np #has to be run with pandass
#from PyQt5.QtWidgets import QInputDialog #This enables user inputs


#lasinfo_import_location =  r"X:\Arch&CivilEng\ResearchProjects\GGiardina\PhD\sar73\CaseStudies\Napa\Data\LasTools\Info\2003"
#lasinfo_coor_export_location =  r"C:\Users\sar73\OneDrive - University of Bath\Doctorate\Case Studies\Napa Valley\Data\QGis\April"

class Extract_LasInfo_Coors(object):

    lasinfo_import_location =  r"X:\Arch&CivilEng\ResearchProjects\GGiardina\PhD\sar73\CaseStudies\Napa\Data\LasTools\Info\2014"
    lasinfo_coor_export_location =  r"C:\Users\sar73\OneDrive - University of Bath\Doctorate\Case Studies\Napa Valley\Data\QGis\April"

    def request_information(self):
        #Ask the user for a filename and year, then concatinates with director
        # concatinate it with the export path
        self.user_coors = 26910 #This is fixed for now, but delete when in use
        #self.user_coors = input("Please choose CRS: ")
        self.user_filename = input("Save file as: ")
        self.export_file = self.lasinfo_coor_export_location + "\\" + self.user_filename + ".csv"
        
        #Validation to ensure filename contains no spaces
        if " " in self.user_filename:
            print ("Spaces are not allowed")
            self.request_information()
        else:
            self.clean_lasinfo_coors()

    def read_lasinfo_coors(self, file):
        global min, max
        with open(file, 'rt') as fd:
            for i, line in enumerate(fd):
                if i == 19:
                    min = str(line)
                elif i == 20:
                    max = str(line)
        return str(min) + str(max)


    def clean_lasinfo_coors(self):
        #Complete the folder path & load all the txt files in that directory
        complete_folder_path = self.lasinfo_import_location + "\\"
        lasinfo_files = glob.glob(complete_folder_path + "*.txt")
        
        #Map extract lines from read_lasinfo_coors() and to the various
        #LasInfo .txt files
        map_lines_and_files = list(map(self.read_lasinfo_coors, lasinfo_files))
        output_strings = re.findall("\d+\.\d+", str(map_lines_and_files))
        
        #Remove the z coordinate info and create x and y lists
        del output_strings[2::3]
        self.x_coor = output_strings[::2]
        self.y_coor = output_strings[1::2]

        self.convert_lasinfo_coors()

    def convert_lasinfo_coors(self):
        #Convert coordinates into floats and then the correct CRS
        #input_projection = Proj('epsg:26910')
        input_projection = Proj('epsg:'+ str(self.user_coors))
        output_projection = Proj('epsg:4326')
        x1, y1 = np.array(self.x_coor,float), np.array(self.y_coor, float)
        x2, y2 = transform(input_projection, output_projection, x1, y1)

        #Convert original original data and new data to columns for export
        data = pd.DataFrame()
        data ["Pre-Conversion X"] = x1
        data ["Pre-Conversion Y"] = y1
        data ["Converted X"] = x2
        data ["Converted Y"] = y2
        print(data)

        #Output to a .csv
        if not data.to_csv (self.export_file, index = False, header=True):
            print (self.user_filename, "created")
        else:
            print (self.user_filename, "creation FAILED")

class Extract_Polgygon_Coors(object):

    #layer = iface.activeLayer()
    #features = layer.getFeatures()

    #Asks the user to choose a filename
    def request_filename():
        #global self.export_file
        
        #Captures the users filename and concatinates it to the the directory
        request_filename = QInputDialog.getText(None, "Save file as","File name:")
        clean_filename = list((request_filename[0]).split(','))
        self.export_file = (polygon_coor_export_location + "\\" + ((''.join(clean_filename))) + ".csv")
        
        #Validation to prevent spaces in file name. NEEDS WORK
        if " " in clean_filename:
            print ("Spaces are not allowed")
            return request_filename
        else:
            return polygon_coor_extract()
    
    #Extracts the coordinates of the polygon(s)
    def polygon_coor_extract():
        #global self.x_coor
        #global self.y_coor
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
            self.x_coor = float_coor[::2]
            self.y_coor = float_coor[1::2]
            #xy = float_coor[0:1]
            #print(self.x_coor, self.y_coor)
            #print(xy)
            return polygon_coor_export()
            
    #Exports the coordinates to a csv file
    def polygon_coor_export():
        data = pd.DataFrame()
        #col_names = ['Latitude','Logitude']
        data ["X Coordinates"] = self.x_coor
        data ["Y Coordinates"] = self.y_coor
        drop_last = data.drop(data.index[len(data)-1]) #This removes the repeated 1st coordinate
        print (drop_last)

        #creates .csv
        if not drop_last.to_csv(self.export_file):
            print ("File created")
        else:
            print ("File failed")    


a = Extract_LasInfo_Coors()
a.request_information()

#b = Extract_Polgygon_Coors()
