As of v0.93 of FLDLIB, an extra file is required to compile FLDLIB. 
This file is ICON.C, and contains the image data to be displayed in an 
iconified dialog. It is constructed using DERCS from a resource file 
contain 1 object tree. This tree consists of a white-filled rectangle 
of border thickness 1 as the root object, containing the image data 
for the icon (named FLD_ICONFORM).

If you do not wish to use the iconify features, you can remove ICON.C 
and compile by taking out the

#include "icon.c"

and adding an

OBJECT *FLD_ICONFORM=NULL;

global variable in FLDLIB.C.

Martin Maisey

21/5/94
