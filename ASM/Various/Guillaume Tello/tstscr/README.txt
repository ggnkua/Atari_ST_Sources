-----------
TEST SCREEN
-----------

This is a program that detects the screen encoding on any machine from Monochrome to True Color.
It tells you the number of bits per pixel, if there are planes or not, the order of the bits in High and True color.

GEM_APP folder
--------------
	The standalone version

TSTSCR_F.PRG	french version
TSTSCR_E.PRG	english version
TSTSCR.S	source for ASSEMBLE.
	The program displays the results into an alert box and can save it to a text file.


PUREC.OBJ folder
----------------
	The OBJ version to be linked to a PureC program.
	It contains the function ScreenEncoding()

LIB\TSTSCR.O	the object file to be linked to your program
INCLUDE\TSTSCR.H	the definitions to include
TSTSCR.S	the source code of the library for ASSEMBLE

TESTSCR.C	a simple demo program that calls ScreenEncoding
TESTSCR.PRJ	the project file for PureC
TESTSCR.PRG	the binary of the demo with DirectAccess disabled (see TSTSCR.H)
TESTSCRD.PRG	the same with DirectAccess enabled

	Most of the informations to include and call the routine can be found in TSTSCR.H

Guillaume Tello 2020.
guillaume.tello@orange.fr

