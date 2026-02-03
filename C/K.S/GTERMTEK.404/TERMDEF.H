/*********************************************************************/
/* DEFINES fuer APTERM.c                                             */
/*********************************************************************/

/*#define WI_KIND         (SIZER|MOVER|FULLER|CLOSER|NAME)*/
#define WI_KIND     0

#define NO_WINDOW (-1)

#define MIN_WIDTH  (2*gl_wbox)
#define MIN_HEIGHT (3*gl_hbox)

#define X_FWD           0x0100          /* extended object types */
#define X_BAK           0x0200          /* used with scrolling   */
#define X_SEL           0x0300          /* selectors             */
#define N_COLORS        15L


