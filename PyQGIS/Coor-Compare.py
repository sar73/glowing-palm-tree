
x_list = [-122.339095, -122.340415, -122.340893, -122.341033, -122.340331, -122.340471, -122.340921, -122.341173, -122.34123, -122.340893, -122.340247, -122.339854, -122.33932, -122.338927, -122.338646, -122.338478, -122.338197, -122.337832, -122.337467, -122.337214, -122.336933, -122.336765, -122.336624, -122.336456, -122.336287, -122.335922, -122.335866, -122.336175, -122.336371, -122.336428, -122.336287, -122.336063, -122.335866, -122.339095]

x_min = [-122.35527054, -122.35757635, -122.34822123, -122.34814061, -122.33678721, -122.33670519, -122.32543664, -122.32535324, -122.3252698,  -122.31400412, -122.3129227]
x_max = [-122.34814073, -122.34806008, -122.3367053,  -122.33662324, -122.32526991, -122.32518643, -122.31391941, -122.31383456, -122.3143454,  -122.30776797, -122.31119643]


#found = filter(lambda x: 1.50 <= x <= 2.50, list_number)
found = filter(lambda x: -123 <= x <= -121, x_list)

for value in found:
    print(value)