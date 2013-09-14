/*==========================================================================
 * FILE: TEXT.C
 *==========================================================================
 * DATE: Sept 21, 1990
 * DESCRIPTION: Country Specific Text Strings
 * COMPILER: TURBO C Version 2.0
 */
#include "country.h"

char notice1[] = "FSM Printer Configuration Accessory by CJG";
char notice2[] = "Copyright (c) 1991 Atari Corporation";
 
#if USA | UK

/* FILE:  MAINSTUF.C */
char *print_text[] = {
		      "Draft    ",
		      "Final",
		      "Draft",
		      "Final"
		     };


char *size_text[] = {
		      "Letter   ",
		      "Legal",
		      "A4",
		      "B5",
		      "Other~2",
		      "Letter",
		      "Legal",
		      "A4",
		      "B5",
		      "Other"
		    };

char *rez_text[] = {
		    "                   ",
		    "                   "
		   };

char rez_width[] = "Width: %2.1f inches";
char rez_height[] = "Height: %2.1f inches";

char rez2_width[] = "Width: %2.2f cm";
char rez2_height[] = "Height: %2.2f cm";

char xy1_unit[] = "Units: Inches";
char xy2_unit[] = "Units: Centimeters";


char *color_text[] = {
			"B/W",
			"4 Colors",
			"8 Colors",
			"16 Colors"
		     };

char *port_text[] = {
			"Printer  ",
			"Modem",
			"Printer",
			"Modem"
		    };
		    

char *tray_text[] = {
			"Tractor  ",
			"Tray 1",
			"Tray 2",
			"Manual",
			"Tractor",
			"Tray 1",
			"Tray 2",
			"Manual"
		    };		    		     

char alert0[] = "[1][ | Save the Driver? ][ OK | Cancel ]";
char NoDrivers[]  = "No FSM Drivers Found";
char YesDrivers[] = "Select Drivers";


/* FILE:  FILEIO.C   */
char alert1[] = "[1][ | | File I/O Error ][ OK ]";
char alert2[] = "[1][ | File Load Error!| The operation is | cancelled. ][ OK ]";
char alert3[] = "[1][ | This driver is not | an FSM GDOS driver.| The operation is| cancelled. ][ OK ]";
char alert4[] = "[1][ | Memory Allocation Error! ][ OK ]";

char menu_title[] = "  Printer Config ";
char alert5[] = "[1][The GEM Desktop has no more|windows.  Please close a|window that you are not|using.][ OK ]";

/* FILE: WINDOWS.C */
char window_title[] = " FSM Printer Configuration ";


#endif


#if GERMAN
#endif
		
#if FRENCH
#endif

#if SPAIN
#endif

#if SWEDEN
#endif

#if ITALY
#endif


 
 
