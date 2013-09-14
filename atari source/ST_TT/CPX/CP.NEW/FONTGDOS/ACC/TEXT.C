/*==========================================================================
 * FILE: TEXT.C
 *==========================================================================
 * DATE: January 17, 1991
 *       September 11, 1991
 *
 * DESCRIPTION: Country Specific Text Strings
 * COMPILER: TURBO C Version 2.0
 */
#include "country.h"

char notice1[] = "FontGDOS Printer Selector Accessory by CJG";
char notice2[] = "Copyright (c) 1991 Atari Corporation";

 
#if USA | UK
/* MAINSTUF.C */
char menu_title[] = "  Printer Selector";
char alert13[] = "[1][The GEM Desktop has no more|windows. Please close a|window that you are not|using.][ OK ]";

char driver_null[] = "None";	/* Text if there is no device 21 active    */
char *amenu_text[] = { "Show Inactive Fonts...",
		       "Exit to Main Menu...  ",
		       "Remove Font(s)...     "
		     };


/* WINDOWS.C */
char window_title[] = " Printer Selector ";


/* EDIT.C */
char alert1[] = "[1][ | Delete the Current Device? ][OK|Cancel]";
char alert2[] = "[1][ | Add a new device? ][OK|Cancel]";
char *DevTitles[] = { " Available Screen Devices ",
		      " Available Plotter Devices ",
		      " Available Printer Devices ",
		      " Available Metafile Devices ",
		      " Available Camera Devices ",
		      " Available Tablet Devices ",
		      " Available Other Devices "
		    };


/* FSMIO.C */
char alert3[] = "[3][Error reading!][ OK ]";
char alert4[] = "[1][ | There is not enough | memory to read the | ASSIGN.SYS file. ][ OK ]";
char alert5[] = "[3][ | Cannot open ASSIGN.SYS][ OK ]";
char alert6[] = "[3][ | Error opening the | ASSIGN.SYS file. The | operation is cancelled.][ OK ]";
char alert7[] = "[1][ | There is no more room | for any more devices. ][ OK ]";
char alert8[] = "[1][ This device already exists ][OK]";
char AlertFull[] = "[3][ | The maximum number of | fonts have been loaded. | The current limit is 250 | fonts.][ OK ]";

char data_null[] =    "Unknown          ";
char *page_data[] = { "Letter  ",
		      "Legal   ",
		      "A4      ",
		      "B5      ",
		      "Other   "
		    };

char rez_map[] = "%2.1f x %2.1f inches";
char rez_map2[] = "%3.1f x %3.1f cm";
char dpi_map[] = "%d x %d dpi";


/* INACTIVE.C */
char alert9[] = "[1][ | Append the font(s) to | the current device? ][OK|Cancel]";
char alert10[] = "[1][ | Save the ASSIGN.SYS? ][OK|Cancel]";
char alert11[] = "[1][ | Remove the font(s) from | the current device? ][OK|Cancel]";
char alert12[] = "[1][ | The ASSIGN.SYS parameters | have been changed. Save | the ASSIGN.SYS file? ][OK|Cancel]";
char *imenu_text[] = {"Show Active Fonts...",
		      "Exit to Main Menu...",
		      "Append Font(s)... "
	             };
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


 
 
