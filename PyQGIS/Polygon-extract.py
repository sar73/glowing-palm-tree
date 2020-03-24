import re
import numpy as np
layer = iface.activeLayer()
features = layer.getFeatures()

def polygon_coordinates():
    for feature in features:
        #print the feature ID
        print ("Feature ID", feature.id())
        #fetch the geometry and coordinates
        geom = feature.geometry()
        geomSingleType = QgsWkbTypes.isSingleType(geom.wkbType())
        if geom.type() == QgsWkbTypes.PolygonGeometry:
            if geomSingleType:
                #x = str(geom.asPolygon())
                #y = re.findall("[-+]?\d*\.\d+|\d+",x)
                # Cleansing the coordinates extraction, by ouputting to 6 dp
                x = re.findall("[-+]?\d*\.\d+|\d+", str(geom.asPolygon()))
                floating_coor = [round(float(i),6) for i in x]
                print ("Polygon Coordinates:" , floating_coor, sep ='\n')
                print ( "Area: ", geom.area())
            else:
                x = geom.asMultiPolygon()
                print("MultiPolygon: ", x, "Area: ", geom.area())
        else:
            print ("Unknown Geometry")
polygon_coordinates()