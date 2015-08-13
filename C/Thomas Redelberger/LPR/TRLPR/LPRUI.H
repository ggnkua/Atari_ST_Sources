/* user interface for lpr printer client.
(C) Dr. Thomas redelberger, Dec 1999
interface for LPRUI.C and LPRUIG.C 
*/

/* $Id: lprui.h 1.1 1999/12/30 13:03:18 Thomas Exp Thomas $
*/


extern void* uiH;			/* opaque pointer to UI context */
extern void* uiOpen   (char* title);
extern void  uiYield  (void *uiH, long waitMilliSecs);
/* uiPrintf types */
#define uiPrOK		0		/* no Icon, no text */
#define uiPrINF		1		/* exclamation icon, no text */
#define uiPrWARN	2		/* question mark icon, text warning */
#define uiPrERR		3		/* stop sign icon, text error */
extern void  uiPrintf (void* uiH, int type, char *format, ...);
extern void  uiClose  (void* uiH);
