/* EZ-Score Plus
 * Score header data structure definitions
 *
 * by Craig Dickson
 * for Hybrid Arts, Inc.
 * Copyright 1987 Hybrid Arts, Inc.
 * All Rights Reserved
 *
 * File opened:   10 July 1987
 * Last updated:  06 March 1988
 */

/* offsets within ENVIRINFO
 *
 * these can be treated as:
 *    char  *WIND_INFO;
 *    char  SCO_VERSION;
 */
#define  WIND_INFO   (&envirptr[8])
#define  SCO_VERSION (envirptr[50])

/* offsets within STAFFINFO
 *
 * these can be treated as:
 *    char  N_STAVES;
 *    char  *N_LEDGERS;
 *    char  *ST_CONNECT;
 *    char  *ST_VISIBLE;
 *    char  *ST_ORDER;
 */
#define  N_STAVES    (*staffptr)
#define  N_LEDGERS   (&staffptr[1])
#define  ST_CONNECT  (&staffptr[121])
#define  ST_VISIBLE  (&staffptr[181])
#define  ST_ORDER    (&staffptr[241])

#define  UPBRACE  0x10              /* & masks for staff edge connections  */
#define  DNBRACE  0x20
#define  UPBRACK  0x40
#define  DNBRACK  0x80

   /* get number of ledger lines above or below a staff
    * a = staff number
    */
#define  leg_above(a)   ((int)(N_LEDGERS[(a)+(a)]))
#define  leg_below(a)   ((int)(N_LEDGERS[(a)+(a)+1]))

   /* get edge connection byte for a staff
    * a = staff number
    */
#define  edge_conn(a)   ((int)(ST_CONNECT[a]))

   /* get visibility status for a staff
    * a = staff number                   
    */
#define  invisible(a)   ((int)(ST_VISIBLE[a]))

/* definitions for PAGE_INFO
 *
 * these can be treated as
 *    long  PMAGICV;
 *    all others are indexes into pageptr (declared as char*);
 *    but (NB!) HMNOFF, and HPNOFF must always be referred to as follows:
 *    ((int*)pageptr)NAME.
 */
#define  PMAGICV  0x19754001L       /* magic number found at *pageptr   */
#define  PGLINE1  4                 /* offsets to start of each line    */
#define  PGLINE2  65
#define  PGLINE3  126
#define  PGLINE4  187
#define  PGLINE5  248
#define  PGLINE6  309
#define  PGLINE7  370
#define  PGTLRG   431               /* "L" button ob_state, each line   */
#define  PGTCNT   438               /* "C" button ob_states             */
#define  PSYSUSR  446               /* user's choice # systems per page */
#define  PSVIS    447               /* # of visible staves per system   */
#define  HPNPTOP  448               /* page number position ob_states   */
#define  HPNPBOT  449
#define  HPNPALT  450
#define  HPNPLEFT 451
#define  HPNPCENT 452
#define  HPNPRIGT 453
#define  HPNOFF   227               /* page number offset (int)         */
#define  HMNOFF   228               /* measure number offset (int)      */
#define  HROUGH   599               /* option dialog radio ob_states    */
#define  HDRAFT   598
#define  HFINAL   597
#define  HDSTRKON 596
#define  HDSTRKOF 595
#define  HSINGLE  594
#define  HFEED    593
#define  HTIHID   592
#define  HTISHOWN 591
#define  HPNHID   590
#define  HPNSHOWN 589
#define  HMNHID   588
#define  HMNSHOWN 587
#define  HRMHID   586
#define  HRMSHOWN 585
#define  HINDFSN  584
#define  HINDFSY  583

   /* check or set magic number
    */
#define  is_magic()  ((*((long*)pageptr) == PMAGICV)? TRUE: FALSE)
#define  set_magic() (*((long*)pageptr) = PMAGICV)

/* EOF */
