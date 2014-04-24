/* EZ-Score Plus 1.1
 * Score printout controller
 * Printer configuration file definitions (prtcnf.h)
 *
 * by Craig Dickson
 * for Hybrid Arts, Inc.
 * Copyright 1988 Hybrid Arts, Inc.
 * All Rights Reserved
 *
 * File opened:   24 February 1988
 * Last modified: 09 March 1988
 */

typedef struct {
   int   pins;                /* number of pins on print head: 9 or 24     */
   int   lines_inch;          /* vertical dpi in final mode                */
   int   bytes_line;          /* horizontal dots per line divided by 8     */
   int   full_linefeed;       /* number of lines the print head moves down */
                              /* for a linefeed in draft or rough modes    */
   int   intrlv_linefeed;     /* number of lines the print head moves down */
                              /* when interleaving (irrelevant for 24-pin) */
   int   i_nxln_linefeed;     /* number of lines the print head moves down */
                              /* after interleaving, to get to next set    */
   int   top_margin;          /* top of first system or title              */
   int   bottom_margin;       /* bottom of last system                     */
   int   left_margin;         /* left edge of staff lines                  */
   int   right_margin;        /* right edge of staff lines                 */
   int   vertical_limit;      /* bottom of everything; do a formfeed here  */
   int   pagenum_top;         /* vertical pos. of page # if at the top     */
   int   pagenum_bottom;      /* vertical pos. of page # if at the bottom  */
   int   pagenum_left;        /* horizontal pos. of page # if at left      */
   int   pagenum_right;       /* horizontal pos. of page # if at right     */
} PRINTER;

/* offset in printer config file to start of strings  */
#define  STRBASE  32

/* EOF */
