/***************************************************************************
*
*		O P T I O N   H e a d e r   F i l e
*		-----------------------------------
*		Copyright 1983 by Digital Research Inc.
*
* Date: 3/7/84
*
*	The CLEAR*.L86 libraries provide a large number of functions which
* are not needed by every program, but which must be linked into the program
* because their usage is data driven.  One example is the floating point 
* conversion routines in the "printf()" function.  The programmer can specify
* "%f", "%g" or "%e" conversions which the linker can not detect.  If the
* program never needs or uses these conversions, the code in the "printf()"
* routine will never be used.  The "option.h" module gives the programmer
* a mechanism of communicating to the linker that certain low level functions
* are optional (not used by the program), and can be left out to save space
* in the program load image (.CMD file).
*
*	"option.h" provides a set of definitions which allow the programmer
* to specify certain options of the CLEAR* Run Time libraries (CLEARS.L86 or
* CLEARL.L86) which the program does not use.  The programmer can 
* choose broad sets of options (i.e. "MINIMAL"), or can choose specific 
* options to stub out of the final program (i.e. "NOFLOAT").
*
*	Each definition contains a "tag declaration".  The tag declaration
* will link in a module from the OPTION*.L86 (OPTIONS.L86 or OPTIONL.L86)
* library which also contains a "stubroutine" for some internal 
* function of the CLEAR* Run Time Library.
*
*	For example, the definition of NOFLOAT is "int nofloat();".  When
* the programmer specifies "NOFLOAT" in the source file and then links the
* final program with the OPTION* library, the linker links in the module from
* the OPTION* library which contains "nofloat()".  This module also contains
* certain stubroutines which satisfy functional references to the floating
* point conversion routines in "printf()".  Thus, the code for these
* conversions will not be linked into the final program load image.  If
* the program happens to use the "%f", "%g" or "%e" printf() conversions, 
* the stubroutines provided will print an error message and exit.
*
*	We recommend that the programmer compile a separate module containing
* the tag definitions, and then link this module and the OPTION* library
* along with the rest of the program.  For example, to reduce the size of
* the "hello.c" program load image, the programmer could prepare a file 
* (named "opt.c" in this example) that looks like:
*    opt.c:
*	#include "option.h"
*	MINIMAL
* Then, after compiling hello.c and opt.c, the link command should look like:
*     LINK86 HELLO,OPT,OPTIONS.L86[SEARCH
* Note that the "[SEARCH]" option is very important, since LINK86 will pull
* in all routines in OPTIONS.L86 if you do not use this option.
*
*
*	Specific options are documented below.
*
****************************************************************************/


/*************
* NOFLOAT: link out floating point conversion routines in "printf()",
* "fprintf()", and "sprintf()".
**************/
#define NOFLOAT _nofloat(){ nofloat(); }

/*************
* NOLONG: link out long integer conversion routines in "printf()",
* "fprintf()", and "sprintf()".
* Saves: CPM small 3200, big 3500
**************/
#define NOLONG _nolong(){ nolong(); }


/*************
* NOTTYIN: eliminates the functions to "read()" from the console.
* Watch out when you use STDIN on reads.
* Saves: CPM small 300, big 350
*************/
#define NOTTYIN _nottyin(){ nottyin(); }



/*************
* NOWILDCARDS: eliminates wildcard expansion on command line.
* Saves: CPM small 500, big 650
*************/
#define NOWILDCARDS _nowildcards(){ nowildcards(); }



/*************************************************************************
* DISK I/O Options
*************************************************************************/

/*************
* MAXFILES5: reduces the maximum number of open files allowed from 16 to 5.
* Note: this includes console files.
* Saves: CPM small 1950, big 1950
*************/
#define MAXFILES5 maxf5(){ maxfiles5(); }

/*************
* NOFILESZ: eliminates the functions to calculate the size of a file.
* Watch out when you append 'fopen(name,"a")' or use 'lseek(fd,xx,2)'.
* Saves: CPM small 550, big 800
*************/
#define NOFILESZ _nofilesz(){ nofilesz(); }

/*************
* NOBINARY: eliminates BINARY low level Disk I/O subroutines.
* Watch out when you do binary file i/o: openb(), creatb(), 
* fopenb(), freopb().
* Saves: CPM small 2200, big 2900
*************/
#define NOBINARY _nobinary(){ nobinary(); }

/*************
* NOASCII: eliminates ASCII low level Disk I/O subroutines.
* Watch out when you redirect output to a file, or do any ascii file i/o:
* open(), opena(), creat(), creatb(), fopen(), fopena(), freopen().
* Saves: CPM small 1100, big 1500
*************/
#define NOASCII noascii(){ noascii(); }



/*************
* MINIMAL: tags to make "hello.c" as small as possible.
*************/
#define MINIMAL    	NOFLOAT NOTTYIN NOFILESZ MAXFILES5 NOWILDCARDS \
			NOASCII NOBINARY



/*************
* NOSTARTUP: links out all of the CLEAR initialization routines, including
* command line redirection (">", "<", and ">>" command line ops) and
* wildcard expansion.  Also leaves out opening STDIN, STDOUT, and STDERR.
* Warning: this could have peculiar side effects, and should be used only
* by experienced programmers.
**************/
#define NOSTARTUP _nostartup(){ nostartup(); }
