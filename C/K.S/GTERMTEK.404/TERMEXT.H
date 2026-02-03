/*********************************************************************/
/* EXTERNALS fÅr APTERM.C                                                        */
/*********************************************************************/

extern int      gl_apid;

/*********************************************************************/
/* GLOBAL VARIABLES fÅr APTERM.C                                                 */
/*********************************************************************/

extern int     gl_hchar;
extern int     gl_wchar;
extern int     gl_wbox;
extern int     gl_hbox;        /* system sizes */
extern long    gl_menu;

extern int     phys_handle;    /* physical workstation handle */
extern int     handle;         /* virtual workstation handle */
extern int     wi_handle;      /* window handle */
extern int     top_window;     /* handle of topped window */

extern int     xwork,ywork,hwork,wwork;        /* desktop and work areas */

extern int     msgbuff[8];     /* event message buffer */
extern int     keycode;        /* keycode returned by event-keyboard */
extern int     mx,my;          /* mouse x and y pos. */
extern int     butdown;        /* button state tested for, UP/DOWN */
extern int     ret;            /* dummy return variable */
extern int     m_out;
extern int     muflag;

extern int     hidden;         /* current state of cursor */

extern int     fulled;         /* current state of window */

extern int     contrl[12];
extern int     intin[128];
extern int     ptsin[128];
extern int     intout[128];
extern int     ptsout[128];    /* storage wasted for idiotic bindings */

extern int work_in[11];        /* Input to GSX parameter array */
extern int work_out[57];       /* Output from GSX parameter array */
extern int pxyarray[10];       /* input poextern int array */


