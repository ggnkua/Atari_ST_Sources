head	1.1;
access;
symbols
	TRLPR11B:1.1;
locks
	Thomas:1.1; strict;
comment	@ * @;


1.1
date	99.12.30.13.03.18;	author Thomas;	state Exp;
branches;
next	;


desc
@User interface interface declaration for BOTH lprui.c and lpruig.c
@


1.1
log
@Initial revision
@
text
@/* user interface for lpr printer client.
(C) Dr. Thomas redelberger, Dec 1999
interface for LPRUI.C and LPRUIG.C 
*/

/* $Id$
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
@
