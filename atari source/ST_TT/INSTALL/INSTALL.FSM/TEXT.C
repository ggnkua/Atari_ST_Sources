/* TEXT.C
 * ================================================================
 * DATE: December 12, 1990
 * DESCRIPTION: Text for the FSM installation program.
 */
#include "country.h"



/* FILE.C
 * ================================================================
 */
char alert1[] = "[3][ | No Installation Data File.| Installation Cancelled.][ Sorry ]";
char alert2[] = "[3][ | There is not enough memory| to continue. Installation| has been Cancelled ][ OK ]";
char alert3[] = "[1][ | No EXTEND.SYS to copy.| Copy Cancelled.][OK]";
char alert4[] = "[1][ | EXTEND.SYS Write Error| Write Cancelled.][OK]";
char alert5[] = "[1][ | No ASSIGN.SYS to copy.| Copy Cancelled.][OK]";
char alert6[] = "[1][ | ASSIGN.SYS Write Error| Write Cancelled.][OK]";
char tosalert[] = "[1][|Warning: The Bezier routines|will not work properly with |TOS Version 3.01. Please update|your OS to a newer version.][ OK ]";
char diskalert[]= "[1][ | A disk write error has | occurred. The installation | has been cancelled. ][ Sorry ]";

char *fx80text[] = {
		   "ATSS10EP.FNT",
		   "ATSS12EP.FNT",
		   "ATSS18EP.FNT",
		   "ATSS24EP.FNT",
		   "ATTR10EP.FNT",
		   "ATTR12EP.FNT",
		   "ATTR18EP.FNT",
		   "ATTR24EP.FNT"
		  };

char *nb15text[] = {
		   "ATSS10SP.FNT",
		   "ATSS12SP.FNT",
		   "ATSS18SP.FNT",
		   "ATSS24SP.FNT",
		   "ATTR10SP.FNT",
		   "ATTR12SP.FNT",
		   "ATTR18SP.FNT",
		   "ATTR24SP.FNT"
		  };

char *slmtext[] = {
		   "ATSS10LS.FNT",
		   "ATSS12LS.FNT",
		   "ATSS18LS.FNT",
		   "ATSS24LS.FNT",
		   "ATTR10LS.FNT",
		   "ATTR12LS.FNT",
		   "ATTR18LS.FNT",
		   "ATTR24LS.FNT"
		  };


/* INSTALL.C
 * ================================================================
 */
char alert7[] = "[1][ | Installation Completed.| Please reboot your computer.][ OK ]";
char alert8[] = "[1][ | Installation Cancelled. ][ OK ]";
char alert9[] = "[1][ | Please insert Disk %d | into Drive A. ][OK|Cancel]";
char alert10[]= "[1][ | File Not Found -| %s| Copy Cancelled.][OK]";


/* MAINSTUF.C
 * ================================================================
 */
char alert11[] = "[3][ | No Hard Disk Installed.  | Installation Cancelled.  ][  OK  ]";
char alert12[] = "[2][ | FSM GDOS is already installed.| Install FSM GDOS Again?][ OK | Cancel ]";
char alert14[] = "[2][ | FONT GDOS is already installed.| Install FONT GDOS Again?][ OK | Cancel ]";
char *DriveNames[] = { 
		       "   Drive C   ",
		       "   Drive D   ",
		       "   Drive E   ",
		       "   Drive F   ",
		       "   Drive G   ",
		       "   Drive H   ",
		       "   Drive I   ",
		       "   Drive J   ",
		       "   Drive K   ",
		       "   Drive L   ",
		       "   Drive M   ",
		       "   Drive N   ",
		       "   Drive O   ",
		       "   Drive P   "
		    };

char *APathNames[] = { 
		       "   Drive C   ",
		       "   Drive D   ",
		       "   Drive E   ",
		       "   Drive F   ",
		       "   Drive G   ",
		       "   Drive H   ",
		       "   Drive I   ",
		       "   Drive J   ",
		       "   Drive K   ",
		       "   Drive L   ",
		       "   Drive M   ",
		       "   Drive N   ",
		       "   Drive O   ",
		       "   Drive P   "
		    };

char *DriverNames[] = {
			"None Selected",
			"Atari SMM804",
			"Atari SLM",
			"Canon Bubble Jet",
			"Epson FX-80",
			"HP Deskjet 500",
			"HP Laserjet",
			"HP Paintjet",
			"NEC P-Series",
			"Okimate 20",
			"Star NB24-15",
			"Star NX1000"
		      }; 

char *DriverIndex[] = {
			"",
			"SMM804.SYS",
			"SLM.SYS",
			"BJ10.SYS",
			"FX80.SYS",
			"DJ5.SYS",
			"LASERJET.SYS",
			"PAINTJET.SYS",
			"NECP.SYS",
			"OKI20.SYS",
			"NB15.SYS",
			"NX1000.SYS"
		      };
		      
char *BFontNames[] = {
   		        "None Selected",
   		        "Atari SLM",
   		        "Epson FX-80",
   		        "Star NB15"
		     };

char *CurBStyle[] = {
			"",
			"Atari SLM",
			"FX80",
			"NB15"
		    };
		    
		    
char *CPXNames[] = {
		     "Neither",
		     "CPX Only ",
		     "Acc Only",
		     "Both"
		   };		     

char *MetaNames[] = {
		     "Neither",
		     "META.SYS",
		     "MEMORY.SYS",
		     "Both"
		    };
		    		     
char *AssNames[] = {		     
		      "Current Path",
		      "Set New Path",
		      "FSM GDOS Path"
		    };

char *NoAssNames[] = {		     
		      "FSM GDOS Path ",
		      "Set New Path"
		    };

char *NoAssOther[] = { 
		       "",
		       "The ASSIGN.SYS file does NOT exist.",
		       "The ASSIGN.SYS file does NOT have a path.",
		       "The ASSIGN.SYS file has an INVALID drive.",
		       "The ASSIGN.SYS file has an INVALID path."
		     };		   
 
char commence[] = "[2][ | Commence Installation? ][ OK | Cancel ]";
char acancel[] = "[2][ | Cancel Installation? ][ YES | No ]";
char *ECPXNames[] = {
		      "",
		      "The CONTROL.INF file does not exist.",
		      "The CONTROL.INF path is invalid."
		    };

char *iheader[] = {
		   " FONT GDOS Installation ",
		   " FSM GDOS Installation "
		 };
		 
/* GEMSKEL.C
 * ================================================================
 */
char alow[] = "[3][The install program needs an|80 column screen to display|its dialog boxes. Please|re-boot in a higher resolution.][ Sorry ]";
