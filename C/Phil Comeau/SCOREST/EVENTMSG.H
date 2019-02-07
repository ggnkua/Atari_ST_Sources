/* eventMsg: Event manager message buffer offsets
 * phil comeau 02-sep-87
 * last edited 02-sep-87
 *
 * Copyright 1990 Antic Publishing Inc.
 */

#define MSGBFRSZ 8	/* number of words in message buffer */

/* Offsets common to all messages */

#define MSGTYPE 0	/* message type code */
#define MSGORGAPID 1	/* message originator's ap_id */
#define MSGEXTRASZ 2	/* size of message > 16 bytes */

/* Offsets specific to MN_SELECTED messages */

#define MNTTLX 3	/* index of menu title selected */
#define MNITMX 4	/* index of menu item selected */

/* Offsets specific to Window Manager messages */

#define WHANDLE 3	/* window handle */

/* Offsets specific to WM_REDRAW messages */

#define WRDWX 4		/* x-coordinate of area to redraw */
#define WRDWY 5		/* y-coordinate of area to redraw */
#define WRDWWID 6	/* width of area to redraw */
#define WRDWHT 7	/* height of area to redraw */

/* Offsets specific to WM_ARROWED messages */

#define WARWACTION 4	/* arrow action (page up, etc) */

/* Offsets specific to WM_HSLID messages */

#define WHSLIDEPOS 4	/* horizontal slider position in .1% */

/* Offsets specific to WM_VSLID messages */

#define WVSLIDEPOS 4	/* vertical slider position in .1% */

/* Offsets specific to WM_SIZED messages */

#define WSZX 4		/* current x origin */
#define WSZY 5		/* current y origin */
#define WSZWID 6	/* new window width */
#define WSZHT 7		/* new window height */

/* Offsets specific to WM_MOVED messages */

#define WMVX 4		/* new x origin */
#define WMVY 5		/* new y origin */
#define WMVWID 6	/* current width */
#define WMVHT 7		/* current height */

/* Offsets specific to AC_OPEN messages */

#define ACOPMENUID 3	/* accessory menu item id */

/* Offsets specific to AC_CLOSE messages */

#define ACLSMENUID 3	/* accessory menu item id */
