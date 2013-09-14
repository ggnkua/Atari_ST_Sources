/*==========================================================================
 * FILE: TEXT.C
 *==========================================================================
 * DATE: Sept 21, 1990
 * DESCRIPTION: Country Specific Text Strings
 * COMPILER: TURBO C Version 2.0
 */
#include "country.h"
 
#if USA | UK

/* FILE:  FSM.C */
char *command_txt[] = {
			"   Active Fonts   ",
			"  Inactive Fonts  "
		      };

char *status_txt[] =  {
			"Show Active Fonts...",
			"Show Inactive Fonts..."
		      };

char *move_txt[] =    { "Activate Font(s)...",
			"Deactivate Font(s)..."
		      };
		      		

char *move2_txt[] = { "Activate",
		      "Deactivate"
		    };
		    		      		
char *menu_items[] = {
			"Outline Font Setup... ",
			"                      ",
			"FSM Cache Options...  ",
			"Build Width Tables... ",
			"                      "
		     };

char alert0[] = "[3][ | Would you like to save the | EXTEND.SYS? The old file | will be overwritten. ][ YES | No ]";
char alert1[] = "[3][ | The options have been| changed. Would you like| to save the 'EXTEND.SYS'?][  YES  |  No  ]";


/* FILE: BUILDWD.C */
char alert2[] = "[3][ | Build Width Tables?][  OK  | Cancel ]";
char alert3[] = "[3][ | There are no active fonts.| Width Table files will| not be built.][  OK  ]";
char alert4[] = "[1][ File Creation Error][OK]";
char alert5[] = "[1][ | %s is not| in the EXTEND.SYS| file. The WIDTH file| will not be built.][OK]";
char alert16[] = "[1][ | |Cancel building Width Tables? ][ YES | No ]";

/* FILE: FSMIO.C */
char alert6[]  = "[3][ | Unable to open| %s.| The font will not | be used.][ OK ]"; 
char alert7[]  = "[3][ | Bad font id read in | %s.| The font will not | be used.][ OK ]";
char alert8[]  = "[3][ | Bad font read in | %s.| The font will not | be used.][ OK ]";
char alert9[]  = "[3][ | Bad font name in | %s.| The font will not | be used.][ OK ]";
char alert10[] = "[3][ | Bad font name read in | %s.| The font will not | be used.][ OK ]";
char alert11[] = "[3][ | Error opening the | EXTEND.SYS file. The | operation is cancelled.][ OK ]";
char alert12[] = "[3][ | The maximum number of | fonts have been loaded. | The current limit is 250 | fonts.][ OK ]";	/* Exceed the Number of Fonts that we can load. */

char msg1[] = "; Last modified on %d/%d/%d %02d:%02d\r\n";


/* FILE: OUTLINE.C */
char title_fsmpath[] = "Select Font Directory Path";
char title_symbol[]  = "Select Symbol Font";
char title_hebrew[]  = "Select Hebrew Font";
char *width_text[] = {"No",
		      "Yes"
		     };
		     
char sym_alert[] = "[3][ | Please save the EXTEND.SYS | file. The changes to the| Symbol-Hebrew font will take | effect at that time. ][ OK ]";

char none_text[] = "None";

/* FILE: POINTS.C */
char *use_default_text[] = { "Use Defaults",
			     "Set All Fonts",
			     "Use Defaults"
			   };
			   
char *name_text[] = { "dummy",
		      " Default Point Sizes",
		      " Group Point Sizes"
		    };
		    

char alert14[] = "[3][ | Set the Current | Font to the Default| Point Sizes?][OK|Cancel]";
char alert15[] = "[3][ | Set All Fonts| To the Default| Point Sizes?][OK|Cancel]";
char alert20[] = "[3][ |Fonts must have at least|ONE point size available.|Either Add a Point Size|or Cancel the operation.][ADD|Cancel]";
char alert23[] = "[3][ | The width tables are no | longer valid. Please | update your width tables. ][OK|Cancel]";

/* FILE: CACHEOPT.C */
char alert17[] = "[3][ | Clear the Cache Buffer? ][OK|Cancel]";
char alert18[] = "[3][ | A workstation error| has occurred. The| operation has been| cancelled. ][ Sorry ]";
char alert19[] = "[3][ | Cache I/O Error!| The operation has| been cancelled.][ Sorry ]";

/* FILE: STATUS.C */
char alert21[] = "[3][ | WARNING: The size of the | FSM cache may be too small. | Please increase the size | of the FSM cache. ][ OK ]";
char alert22[] = "[3][ |WARNING: The size of the FSM |cache may be too small. Please |increase the size of the |FSM cache at a later time. ][ OK ]";
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


 
 
