
/* written by Ian Lepore
** Copyright 1990 by Antic Publishing, Inc.
*/

/**************************************************************************
 *
 * Fastplot header file for C.
 *
 *************************************************************************/

#ifndef FASTPLOT_H

#define FASTPLOT_H       1         /* prevent multiple inclusions.       */

                                   /* values returned by fpl_inrect()... */

#define FPL_ISINRECT     0         /* point is inside rectangle          */
#define FPL_NOTINRECT    1         /* point is not in rectangle          */

#define FPL_NOCLIP       0L        /* for fpl_sclip()...disable clipping */

#define FPL_VDIXLATE    -1L        /* for fpl_sxlate()...set color       */
#define FPL_TOSXLATE     0L        /* translation to VDI or TOS mode.    */

extern    int       fplot();
extern    void      fpl_init();
extern    void      fpl_sclip();
extern    void      fpl_dclip();
extern    void      fpl_sxlate();
extern    void      fpl_clrscrn();
extern    int       fpl_inrect();


/* FYI department...
 *  VDI to TOS color translation is as follows:
 *
 *      VDI ->  TOS             VDI ->  TOS
 *      00      00              08      09
 *      01      02              09      10
 *      02      03              10      11
 *      03      06              11      14
 *      04      04              12      12
 *      05      07              13      15
 *      06      05              14      13
 *      07      08              15      01
 *
 *      TOS ->  VDI             TOS ->  VDI
 *      00      00              08      07
 *      01      15              09      08
 *      02      01              10      09
 *      03      02              11      10
 *      04      04              12      10
 *      05      06              13      14
 *      06      03              14      11
 *      07      05              15      01
 */
 
#endif

