/* EZ-Score Plus
 * Score printout controller
 * Main definition file (ezp.h)
 *
 * by Craig Dickson
 * for Hybrid Arts, Inc.
 * Copyright 1987, 1988 Hybrid Arts, Inc.
 * All Rights Reserved
 *
 * File opened:   26 June 1987
 * Last modified: 28 March 1988
 */

#define  DEBUG FALSE                /* compile all the ALT-dependent msgs? */

#define  TBUF  30480                /* size of Tom's redraw buffer         */
#define  ONESPACE 15                /* pixel dist. one staff line to next  */
#define  INDENT   64                /* amount to indent first line         */

#define  SYSTOPX  90                /* Tom's guaranteed no-pass y limits   */
#define  SYSBOTX  90

#define  MAXCON   12                /* max of any one type of connector    */
#define  MAXSTV   3                 /* max number of staves in a system    */
#define  MAXSYS   24                /* maximum number of staves on a page  */

#define  MAXTITLE 5                 /* max of each type of text line       */
#define  MAXCOPR  2
#define  MAXLIN   (MAXTITLE+MAXCOPR)	/* max of text lines on title page */

#define  ILLEGAL  asm { dc.w 0x4AFC }     /* MC68000 illegal instruction   */

/* EOF */
