/* TEXT.C
 * ================================================================
 * DATE: December 12, 1990
 * DESCRIPTION: Text for the FSM installation program.
 */
#include "country.h"



/* FILE.C
 * ================================================================
 */
char alert1[] = "[3][INSTALL.DAT is missing.|The file must be in the same|directory as INSTALL.PRG. |The installation has been|cancelled.][ Exit ]";
char alert2[] = "[3][ | There is not enough memory| to continue. Installation| has been Cancelled ][ OK ]";
char tosalert[] = "[1][|Warning: The Bezier routines|will not work properly with |TOS Version 3.01. Please update|your OS to a newer version.][ OK ]";
char arsc[] = "[3][ | Can't load resource file. ][ OK ]";



/* INSTALL.C
 * ================================================================
 */
char inserta[] = "Please insert %s into";
char insertb[] = "Drive %c and press RETURN.";

/* MAINSTUF.C
 * ================================================================
 */
char alert11[] = "[3][ | No Hard Disk Installed.  | Installation Cancelled.  ][  OK  ]";

char no_cpxfile[] = "[1][ | The CONTROL.INF file does not | exist. The CPXs cannot be | installed.][ OK ]";
char no_cpxpath[] = "[1][ | The CONTROL.INF path is | invalid. The CPXs cannot| be installed.][ OK ]";
char wfsm[]   = " Atari FSM GDOS Installation ";
char wfont[]  = " Atari FONT GDOS Installation ";
char wtitle[] = " Atari Font Installation ";

char nowin[] = "[1][ | There are no more windows.| Please close a window and| run Install again.][ OK ]";
char aexit[] = "[2][ | The installation is not yet | complete. Are you sure you | want to exit Install? ][ Yes | NO ]";
char anone[] = "None Selected";

char bad_path[] = "[1][ |The directory that you typed|is invalid. Please type in a|complete path.][ OK ]";
char dirmake[] = "[1][ | The directory that you typed | does not exist. Do you want | to create the directory?][ OK | No ]";
char bad_drive[] = "[1][ |The Drive you typed is invalid.|The drive must be an active |partition between C:\\ and P:\\.][ OK ]";

char read_error[]   = "[1][ | An error has occurred | while reading the file.][RETRY|Skip|Quit]";
char write_error[]  = "[1][ | An error has occurred | while writing to the | file. ][RETRY|Skip|Quit]";
char mem_error[]    = "[1][ | There is not enough memory | to transfer this file.][RETRY|Skip|Quit]";
char open_error[]   = "[1][ | An error has occurred | while opening this file.][RETRY|Skip|Quit]";
char no_file_error[]= "[1][ |  File not found! ][RETRY|Skip|Quit]";

/* GEMSKEL.C
 * ================================================================
 */
char alow[] = "[3][The install program needs an|80 column screen to display|its dialog boxes. Please|re-boot in a higher resolution.][ Sorry ]";
