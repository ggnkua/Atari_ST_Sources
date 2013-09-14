/* hdx.c */


#include "obdefs.h"
#include "gemdefs.h"
#include "osbind.h"
#include "mydefs.h"
#include "wind.h"
#include "addr.h"
#include "error.h"
#include "errno.h"
#include "stdio.h"
#include "stat.h"


#define APP_INFO ""
#define APP_NAME "Window Example"
#define MAX(X,Y)	( (X) > (Y) ? (X) : (Y) )
#define MIN(X,Y)	( (X) < (Y) ? (X) : (Y) )


/* AES (windows and messages) related variables */
int gl_hchar;		/* height of system font (pixels) */
int gl_wchar;		/* width of system font (pixels) */
int gl_wbox;		/* width of box able to hold system font */
int gl_hbox;		/* height of box able to hold system font */

int phys_handle;	/* physical workstation handle */
int handle;		/* virtual workstation handle */
int wi_handle;		/* window handle */

int formw, formh, sx, sy, lx, ly;	/* dialogue box dimensions */
int xdesk, ydesk, hdesk, wdesk;		/* window X, Y, width, height */
int xwork, ywork, hwork, wwork;		/* desktop and work areas */

char *sbuf[512];
int msgbuff[8];		/* event message buffer */
int keycode;		/* keycode returned by event-keyboard */
int mx, my;		/* mouse x and y pos. */
int butdown;		/* button state tested for, UP/DOWN */
int ret;		/* dummy return variable */
int hidden;		/* current state of cursor */
int contrl[12];
int intin[128];
int ptsin[128];
int intout[128];
int ptsout[128];	/* storage wasted for idiotic bindings */
int work_in[11];	/* Input to GSX parameter array */
int work_out[57];	/* Output from GSX parameter array */
int pxyarray[10];	/* input point array */
int msg[8];			/* message buffer */
int toptx;			/* the top line of text currently in the window */
int cellw, cellh, chspcw, chspch;	/* size of default character font */
char *dbuff;
long *list;
int nrow;
int running;

/*
 * Top level;
 * we get control from the desktop.
 */
main()
{


    appl_init();
    phys_handle=graf_handle(&gl_wchar, &gl_hchar, &gl_wbox, &gl_hbox);
    wind_get(0, WF_WORKXYWH, &xdesk, &ydesk, &wdesk, &hdesk);
    open_vwork();
	/*
    hw_handle=wind_create(0x0040&0x0080, xdesk, ydesk, wdesk, hdesk);
	*/

    if (!rsrc_load(RESOURCEFILE))	{
		errs("[2][|", RESOURCEFILE, "][ EXIT ]");
		goto doneit;
	}
    
    /* Get all addresses of dialogues from resource file */
    if (getalladdr() != OK) {
		errs("[2][|", RESOURCEFILE, "][ EXIT ]");
		goto doneit;
    }

    ARROW_MOUSE;
	menu_bar(menubar, 1);
	running = TRUE;
	while(running)	{
		domulti();
	}
	menu_bar(menubar, 0);

doneit:
	wind_delete(wi_handle);
	Mfree(dbuff);
	Mfree(list);
    v_clsvwk(handle);
    appl_exit();
}

doopenwd()
{

	int done = FALSE;
	long slidsiz;
	DMABUFFER dma;
	int status, i, tmpy, tmpx, fp;
	char *sbuff, *tem;
	int attrib[4];
	long *tmp;
	int deskx, desky, deskw, deskh;


    wi_handle=wind_create(0xFFFF, xdesk, ydesk, wdesk, hdesk);
	wind_set(wi_handle, WF_INFO, APP_INFO, 0, 0);
	wind_set(wi_handle, WF_NAME, APP_NAME, 0, 0);
	wind_open(wi_handle, xdesk+30, ydesk+30, wdesk/2, hdesk/2);
    wind_get(wi_handle, WF_WORKXYWH, &xwork, &ywork, &wwork, &hwork);

	toptx = 0;		/* start top line of text */

/*
	vst_alignment(handle, 0, 5, &done, &done);	 set text alignment
	wind_calc(0, 0xFFFF,
				gl_wchar*5, gl_hchar*5, gl_wchar*TCOLS+4, hwork*SROWS+4,
    			&xwork, &ywork, &wwork, &hwork);
*/
	/* set the window to that size */
/*
	wind_set(wi_handle, WF_CURRXYWH, 
						xwork, ywork, wwork, hwork);
*/

	/* find slider size and set it */
	slidsiz = (1000*(hwork-5)/gl_hchar) / nrow; 
	/*
	wind_set(wi_handle, WF_VSLSIZE, (int)slidsiz, 0, 0, 0);
	*/

/*
	find the work area

    wind_get(wi_handle, WF_WORKXYWH, &xwork, &ywork, &wwork, &hwork);
*/


	/* read the file into buffer */

	Fsetdta(&dma);
	if ((status = Fsfirst("c:\\fmt.c", 0xF7)) != 0)
		fatal(status, "fmt.c");
	if ((sbuff = Malloc(dma.d_fsize + 1)) == NULL)
		exit(1);
	if ((dbuff = Malloc(dma.d_fsize + 1000)) == NULL)
		exit(1);
	if ((fp = Fopen("c:\\fmt.c", "rb")) < 0)	{
		Mfree(sbuff);
		Mfree(dbuff);
		fatal(fp, "cannot open input file");
	}
	if ((status=Fread(fp, (long)dma.d_fsize, sbuff)) < 0)	{
		Mfree(sbuff);
		Mfree(dbuff);
		fatal(status, "fmt.c");
	}
	nrow = findsiz(sbuff);
	list = Malloc((long )nrow);
	converstr(list, sbuff, dbuff);
	vqm_attributes(wi_handle, attrib);
	do_redraw(xwork, ywork, wwork, hwork);
	/*
	wind_update(1);
	tmpy = ywork+3;
	toptx = 0;
	while (tmpy < hwork+3)	{
		tmpy += 4*attrib[3]/5;
		v_gtext(wi_handle, xwork, tmpy, *list++);
		toptx++;
	}
	wind_update(0);
    ARROW_MOUSE;
	*/
	/*

	do
	{
		evnt_mesage(msg);	 get message 
		done = deal_msg();	 and handle them
	} while(!done);

    wind_delete(wi_handle);
	Mfree(sbuff);
	Mfree(dbuff);
	Mfree(list);
	*/
	Mfree(sbuff);

}

deal_msg()
{
	int done = FALSE;
	long tmp;
	GRECT box;

	box.g_x = xwork;
	box.g_y = ywork;
	box.g_h = hwork;
	box.g_w = wwork;

	switch(msg[0])	{

		case  WM_REDRAW:		/* do the redraw by call redraw routine */
			redraw(msg[3], (GRECT *)&msg[4]);
			break;

		case  WM_TOPPED:		/* if topped, send to top */
			wind_set(msg[3], WF_TOP, 0, 0, 0, 0);
			break;

		case  WM_SIZED:			/* if sized, check for min size, then resize */
			msg[6] = MAX(msg[6], gl_wchar*8);
			msg[7] = MAX(msg[7], gl_hchar*4);
			wind_set(msg[3], WF_CURRXYWH, msg[4], msg[5], msg[6], msg[7]);
			redraw(msg[3], (GRECT *)&msg[4]);
			break;

		case  WM_MOVED:			/* if moved, make sure the window stays on the
								   desktop */
			if (msg[4] + msg[6] > xdesk + wdesk)	{
				msg[4] = xdesk + wdesk - msg[6];
			} 
			if (msg[5] + msg[7] > ydesk + hdesk)	{
				msg[5] = ydesk + hdesk - msg[7];
			}
			wind_set(msg[3], WF_CURRXYWH, msg[4], msg[5], msg[6], msg[7]);
			break;

		case  WM_FULLED:		/* if fulled, do toggle routine */
			toggle(msg[3]);
			break;

		case  WM_CLOSED:		/* if closed, set flag */
			wind_close(msg[3]);
			done = TRUE;
			break;

		case  WM_VSLID:			/* slide bar was dragged */
			tmp = msg[4] * (nrow-hwork/gl_hchar) / 1000;	/* calc toptx */
			toptx = tmp;
			redraw(wi_handle, &box);	/* redraw window */
			mvslide();
			break;
		case  WM_HSLID:			/* slide bar was dragged */
			break;

		case  WM_ARROWED:
			switch (msg[4])	{
				case 0:	/* page up */
					toptx = MAX(0, toptx-hwork/gl_hchar);
					break;

				case 1:	/* page down */
					toptx = MIN(nrow-hwork/gl_hchar, toptx+hwork/gl_hchar);
					break;

				case 2:	/* row up */
					toptx = MAX(0, toptx-1);
					break;

				case 3:	/* row down */
					toptx = MIN(nrow-hwork/gl_hchar, toptx+1);
					break;

				default:
					break;
			}
			redraw(wi_handle, &box);	/* redraw window */
			mvslide();
			break;

		default:
			break;
	}

	return(done);
}

/* this function do the WM_FULLED message */

toggle(msg)		
int msg;
{

	GRECT prv, cur, full;

	/* get the previous, current, and the full size of windows */
	wind_get(msg, WF_PREVXYWH, &prv.g_x, &prv.g_y, &prv.g_w, &prv.g_h);
	wind_get(msg, WF_CURRXYWH, &cur.g_x, &cur.g_y, &cur.g_w, &cur.g_h);
	wind_get(msg, WF_FULLXYWH, &full.g_x, &full.g_y, &full.g_w, &full.g_h);

	/* if it is full size, change it to previous unless that was full also */

	if (((cur.g_x == full.g_x) &&
		 (cur.g_y == full.g_y) &&
		 (cur.g_w == full.g_w) &&
		 (cur.g_h == full.g_h)) &&
		 	((prv.g_x != full.g_x) ||
		 	 (prv.g_y != full.g_y) ||
		 	 (prv.g_w != full.g_w) ||
		 	 (prv.g_h != full.g_h))) 	{
		wind_set(msg, WF_CURRXYWH, prv.g_x, prv.g_y, prv.g_w, prv.g_h);
		redraw(msg, &prv);		
		xwork = prv.g_x;
		ywork = prv.g_y;
		hwork = prv.g_h;
		wwork = prv.g_w;
	} else {
		wind_set(msg, WF_CURRXYWH, full.g_x, full.g_y, full.g_w, full.g_h);
		xwork = full.g_x;
		ywork = full.g_y;
		hwork = full.g_h;
		wwork = full.g_w;
	}
}


/* redraw the window */

redraw(wh, dbox)	

int wh;		/* window handle from msg[3] */
GRECT *dbox;	/* pointer to the redraw rectangle */

{  

	GRECT wdrct;	/* the current window rectangle in rect list */ 

	hide_mouse();		/* turn off mouse */
	wind_update(BEG_UPDATE);	/* lock screen */
	wind_get
		(wh, WF_FIRSTXYWH, &wdrct.g_x, &wdrct.g_y, &wdrct.g_w, &wdrct.g_h);
	while (wdrct.g_w && wdrct.g_h)	{	/* while it is not the last one */
		if (overlap(dbox, &wdrct))	{ /*check to see if this one is damaged*/ 
			setclip(&wdrct, msg);		  /*if it is, set clip rectangle*/
			writewd(wh);				/* redraw the window */
			vs_clip(wh, FALSE, (int *)&wdrct);
		}
		wind_get
		  (wh, WF_NEXTXYWH, &wdrct.g_x, &wdrct.g_y, &wdrct.g_w, &wdrct.g_h);
	}
	wind_update(END_UPDATE);	/* unlock screen */
	show_mouse();		/* turn on mouse */

}

/* draw and display the window */

writewd(wh)
int wh;
{
	int i;
	int temp[4];

	temp[0] = xwork;
	temp[1] = ywork;
	temp[2] = xwork + wwork - 1;
	temp[3] = ywork + hwork - 1;
	v_bar(wh, temp);
	for (i=0; i < (hwork-4)/gl_hchar; i++)	{
		v_gtext(wh, xwork+2, gl_hchar*i + ywork+5, *(list+toptx+i));
	}
	toptx += i;

}


/* move the slider to match top text */

mvslide(wh)
int wh;
{
	int cslide, nslide;
	int tmp;

	wind_get(wh, WF_VSLIDE, &cslide, &nslide, &nslide, &nslide);
	tmp = 1000*toptx/(nrow-(hwork-5)/gl_hchar);
	if ((nslide=tmp) != cslide)	{
		wind_set(wh, WF_VSLIDE, nslide, 0, 0, 0);
	}
}

/* set clip to specified rectangle */
setclip(p, wh)	
GRECT *p;
int wh;

{
	int ptr[4];

	grect_conv(p, ptr);
	vs_clip(wh, TRUE, ptr);
}


grect_conv(r, ar)
GRECT *r;
int *ar;
{
	*ar++ = r->g_x;
	*ar++ = r->g_y;
	*ar++ = r->g_x + r->g_w - 1;
	*ar   = r->g_y + r->g_h - 1;
}

/* compute overlap of two rectangles */

overlap(r1, r2)
GRECT *r1, *r2;
{
	int x, y, x1, y1;

	x = MAX(r2->g_x, r1->g_x);
	y = MAX(r2->g_y, r1->g_y);
	r2->g_w = MIN(r2->g_x + r2->g_w, r1->g_x + r1->g_w) - x;
	r2->g_h = MIN(r2->g_y + r2->g_h, r1->g_y + r1->g_h) - y;
	r2->g_x = x;
	r2->g_y = y;
	return((r2->g_w > 0) && (r2->g_h > 0));
}


fatal(error, msg)
int error; char *msg;
{
	errno = -error;
	perror(msg);
	exit(1);
}


findsiz(buf)
char *buf;
{
	int n=0;

	while (*buf)	{
		while (*buf != 0x0D)	{
			buf++;
		}
		n++;
		buf += 2;
	}
	return (n);
}

converstr(list, sbuff, dbuff)
long *list;
char *sbuff;
char *dbuff;
{

	long *tmp;
	char *sptr, *dptr;
	int i=0;

	tmp = list;
	*tmp++ = dbuff;
	sptr = sbuff;
	dptr = dbuff;
	if (*sptr == 0x0D)	{ /* the first line is the blank line */
		*dptr++ = 0x20;
		*dptr++ = 0x00;
		sptr += 2;
		*tmp++ = dptr;
	} 
	while (*sptr)	{
		while ((*sptr != 0x09) && ((*dptr++ = *sptr) != 0x0D))	{
			i++;
			sptr++;
		}
		switch(*sptr)	{
			case 0x09:		/* it is a tab char */
				sptr++;
				i = 4 - i%4;	/* calculate how many space should be */
				switch(i)	{
					case 4:
						*dptr++ = 0x20;
						*dptr++ = 0x20;
						*dptr++ = 0x20;
						*dptr++ = 0x20;
						break;
					case 3:
						*dptr++ = 0x20;
						*dptr++ = 0x20;
						*dptr++ = 0x20;
						break;
					case 2:
						*dptr++ = 0x20;
						*dptr++ = 0x20;
						break;
					case 1:
						*dptr++ = 0x20;
						break;
					default:
						break;
				}
				break;
			case 0x0D:		/* it is a carriage return char */
				sptr++;
				if (*(sptr-2) == 0x0A) {/* it is a blank line */
					*(dptr-1) = 0x20;
					*dptr++ = 0x00;
				} else {
					*(dptr-1) = 0x00;
				}
				*tmp++ = dptr;
				sptr++;
				break;
			default:
				break;
		}
		i = 0;
	}
}
/*

converstr(list, buff)
long *list;
char *buff;
{

	long *tmp;
	char *ptr;

	*list = buff;
	tmp = list;
	ptr = buff;
	if (*ptr == 0x0D)	{  the first line is the blank line
		*ptr++ = 0x20;
		*ptr++ = 0x00;
		*tmp++ = ptr;
	} else 	{
		tmp++;
	}
	while (*ptr)	{
		while (*ptr != 0x0D)	{
			ptr++;
		}
		if ((*(ptr-1) == 0x00) || (*(ptr-1) == 0x0A)) { it is a blank line
			*ptr++ = 0x20;
			*ptr++ = 0x00;
			*tmp++ = ptr;
			continue;
		}
		*ptr = 0x00;
		ptr += 2;
		*tmp++ = ptr;
	}
}

*/

/*
 * Get a single event, process it, and return.
 *
 */
domulti(){
    int event;
	long tmp;
	GRECT box;

	box.g_x = xwork;
	box.g_y = ywork;
	box.g_h = hwork;
	box.g_w = wwork;
    
    event = evnt_multi(MU_MESAG,
			1,1,butdown,
			0,0,0,0,0,
			0,0,0,0,0,
			msg,0,0,&mx,&my,&ret,&ret,&keycode,&ret);

    if (event & MU_MESAG) {
    	wind_update(TRUE);
	switch (msg[0]) {
		case  WM_REDRAW:		/* do the redraw by call redraw routine */
			redraw(msg[3], (GRECT *)&msg[4]);
			break;

		case  WM_TOPPED:		/* if topped, send to top */
			wind_set(msg[3], WF_TOP, 0, 0, 0, 0);
			break;

		case  WM_SIZED:			/* if sized, check for min size, then resize */
			msg[6] = MAX(msg[6], gl_wchar*8);
			msg[7] = MAX(msg[7], gl_hchar*4);
			wind_set(msg[3], WF_CURRXYWH, msg[4], msg[5], msg[6], msg[7]);
			wwork = msg[6];
			hwork = msg[7];
			box.g_w = msg[6];
			box.g_h = msg[7];
			redraw(msg[3], (GRECT *)&msg[4]);
			break;

		case  WM_MOVED:			/* if moved, make sure the window stays on the
								   desktop */
			if (msg[4] + msg[6] > xdesk + wdesk)	{
				msg[4] = xdesk + wdesk - msg[6];
			} 
			if (msg[5] + msg[7] > ydesk + hdesk)	{
				msg[5] = ydesk + hdesk - msg[7];
			}
			wind_set(msg[3], WF_CURRXYWH, msg[4], msg[5], msg[6], msg[7]);
			xwork = msg[4];
			ywork = msg[5];
			box.g_x = msg[4];
			box.g_y = msg[5];
			break;

		case  WM_FULLED:		/* if fulled, do toggle routine */
			toggle(msg[3]);
			break;

		case  WM_CLOSED:		/* if closed, set flag */
			wind_close(msg[3]);
			break;

		case  WM_VSLID:			/* slide bar was dragged */
			tmp = msg[4] * (nrow-(hwork-5)/gl_hchar) / 1000;	/* calc toptx */
			toptx = tmp;
			redraw(msg[3], &box);	/* redraw window */
			mvslide(msg[3]);
			break;

		case  WM_HSLID:			/* slide bar was dragged */
			break;

		case  WM_ARROWED:
			switch (msg[4])	{
				case 0:	/* page up */
					toptx = MAX(0, toptx-(hwork-5)/gl_hchar);
					break;

				case 1:	/* page down */
					toptx = MIN(nrow-(hwork-5)/gl_hchar, 
											toptx+(hwork-5)/gl_hchar);
					break;

				case 2:	/* row up */
					toptx = MAX(0, toptx-1);
					break;

				case 3:	/* row down */
					toptx = MIN(nrow-(hwork-5)/gl_hchar, toptx+1);
					break;

				default:
					break;
			}
			redraw(msg[3], &box);	/* redraw window */
			mvslide(msg[3]);
			break;

	    case MN_SELECTED:
	        BEE_MOUSE;
		switch(msg[3]) {
		    case WINDOW:
				switch (msg[4]) {
				    case OPENWD:
						doopenwd();
						break;
				    case RDFILE:
						dordfile();
				        break;
				    default:	    
						break;
				}
				break;

		    case MNFILE:
				switch (msg[4]) {
				    case FIQUIT:
					running = 0;
					break;

			   	 	default:
						break;
				}
				break;
			
		    case MNDESK:
			/*
			if(msg[4] == DABOUT) {
			    strcpy(abtdial[ABVERSN].ob_spec, "Version 5.00");
		 	    abtdial[ABOK].ob_state = NORMAL;
			    execform(abtdial);
			}
			*/
			break;		/* "cannot happen" */
		}

		menu_tnormal(menubar, msg[3], 1);	/* back to normal */
        ARROW_MOUSE;
		break;
		
	    case WM_NEWTOP:
			wind_set(wi_handle, WF_TOP, 0, 0, 0, 0);
			break;


	    default:
		break;
	}
	wind_update(FALSE);
    }
}

dordfile()
{
;
}


/*
 * Open virtual workstation.
 *
 */
open_vwork()
{
    int i;

    for (i = 0; i < 10;)
	work_in[i++] = 1;
    work_in[10] = 2;
    handle = phys_handle;
    v_opnvwk(work_in, &handle, work_out);
}


/*
 * Find and redraw all clipping rectangles
 *
 */
do_redraw(xc, yc, wc, hc)
int xc, yc, wc, hc;
{
    GRECT t1, t2;
    int temp[4];

    hide_mouse();
    t2.g_x=xc;
    t2.g_y=yc;
    t2.g_w=wc;
    t2.g_h=hc;
    vsf_interior(handle, 1);
    vsf_color(handle, 0);
    wind_get(wi_handle, WF_FIRSTXYWH, &t1.g_x, &t1.g_y, &t1.g_w, &t1.g_h);
    while (t1.g_w && t1.g_h) {
	if (rc_intersect(&t2, &t1)) {
	    set_clip(t1.g_x, t1.g_y, t1.g_w, t1.g_h);
	    temp[0] = xwork;
	    temp[1] = ywork;
	    temp[2] = xwork + wwork - 1;
	    temp[3] = ywork + hwork - 1;
	    v_bar(handle, temp);
	}
	wind_get(wi_handle, WF_NEXTXYWH, &t1.g_x, &t1.g_y, &t1.g_w, &t1.g_h);
    }

    show_mouse();
}


/*
 * Hide the mouse.
 *
 */
hide_mouse()
{
    if (!hidden) {
	graf_mouse(M_OFF, 0L);
	hidden = TRUE;
    }
}


/*
 * Show the mouse.
 *
 */
show_mouse() 
{
    if (hidden) {
	graf_mouse(M_ON, 0L);
	hidden = FALSE;
    }
}


/*
 * Set clipping rectangle.
 *
 */
set_clip(x, y, w, h)
int x, y, w, h;
{
    int clip[4];

    clip[0] = x;
    clip[1] = y;
    clip[2] = x + w;
    clip[3] = y + h;
    vs_clip(handle, 1, clip);
}


/*
 * "Execute" form,
 * return thingy that caused the exit.
 *
 */
execform(tree)
OBJECT tree[];
{
    int thingy;

    ARROW_MOUSE;
    dsplymsg(tree);
    thingy = form_do(tree, 0);
    erasemsg();
    BEE_MOUSE;
    return thingy;
}


/*
 *  Display a dialogue box on the screen.
 *	Input:
 *		tree - object tree for dialogue box to be displayed.
 *	Output:
 *		formw, formh, sx, sy, lx, ly - dimensions of box.
 */
dsplymsg(tree)
OBJECT *tree;
{
    form_center(tree,&lx, &ly, &formw, &formh);

	/*
    sx = lx + formw / 2;
    sy = ly + formh / 2;
	*/
    
    form_dial(1, 0, 0, 0, 0, lx, ly, formw, formh);
    objc_draw(tree, 0, MAX_DEPTH, 0, 0, wdesk, hdesk);
}


/*
 *  Erase a dialogue box from the screen.
 *	Input:
 *		formw, formh, sx, sy, lx, ly - dimensions of box.
 */
erasemsg()
{
    form_dial(3, 0, 0, 0, 0, lx, ly, formw, formh);
}



/*
 *  Make a long (4-byte) random.
 */ 
long
longrandom()
{
    long pattern;
    
    pattern = Random();
    pattern <<= 16;
    pattern ^= Random();
    
    return (pattern);
}

