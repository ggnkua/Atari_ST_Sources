/*
 *	GEM calculator
 *	resource-independent driver, patterned after DRI doodle
 *	Copyright 1985 Axel T. Schreiner, Ulm, W-Germany
 */

#include <obdefs.h>
#include <gemdefs.h>

/*
 *	tunable
 */

#define	NORESOURCE	form_alert(1, "[3][Cannot find resource file][ Quit ]")
#define	NOWINDOW	form_alert(1, "[3][Cannot open window][ Quit ]")
#define	NOALERT		form_alert(1, "[3][Cannot find error message][ Ok ]")

/*
 *	definitions
 */

#define	DESK	0			/* desktop window */
#define	WINDOW	(NAME|CLOSER|MOVER)	/* window options */

/*
 *	macros
 */

#define	Grect(p)	(p)->g_x, (p)->g_y, (p)->g_w, (p)->g_h
#define	aGrect(p)	&(p)->g_x, &(p)->g_y, &(p)->g_w, &(p)->g_h

/*
 *	global variables for VDI
 */

int contrl[12], intin[128], intout[128], ptsin[128], ptsout[128];

/*
 *	locally needed variables for VDI and AES
 */

extern OBJECT * Resource;		/* main tree of resource */
extern char Name[];			/* main tree window name */
static GRECT shrink;			/* shrunken rectangle */

/*
 *	alert utilities
 */

int Alert(name)				/* show an alert */
	int name;			/* #define'd number of alert */
{	char * addr;

	if (rsrc_gaddr(R_STRING, name, &addr))
		return form_alert(1, addr);
	return NOALERT;
}

#ifdef	DEBUG				/* debugging printer */

	static Debug(fmt, v1, v2, v3, v4)
		char * fmt;
	{	char buf1[80], buf2[80];

		sprintf(buf1, fmt, v1, v2, v3, v4);
		sprintf(buf2, "[0][%s][ Ok ]", buf1);
		form_alert(1, buf2);
	}

#endif

/*
 *	initialization
 */

static int init(vp, wp)
	int * vp;			/* return virtual workstation handle */
	int * wp;			/* return window handle */
{	int work_in[11], work_out[57];
	GRECT curr, work;
	int i;

	if (appl_init() == -1)
		return 4;
	wind_update(BEG_UPDATE);
	graf_mouse(HOURGLASS, 0L);

	/*
	 *	open workstation
	 */

	for (i = 0; i < 10; work_in[i++] = 1)
		;
	work_in[i] = 2;			/* raster coordinates */
	*vp = graf_handle(&i, &i, &i, &i);
	v_opnvwk(work_in, vp, work_out);
	if (! *vp)
		return 1;		/* no workstation */

	/*
	 *	get resource
	 */

	if (! Load())
	{	graf_mouse(ARROW, 0L);
		NORESOURCE;
		return 1;		/* no resource file */
	}

	/*
	 *	establish window and center main tree
	 */

	wind_get(DESK, WF_WORKXYWH, aGrect(&curr));
	shrink.g_x = curr.g_w/2;
	shrink.g_y = curr.g_h/2;
	shrink.g_w = 1;
	shrink.g_h = 1;

	work.g_w = Resource->ob_width;
	work.g_h = Resource->ob_height;
	Resource->ob_x = work.g_x = (curr.g_w - work.g_w) / 2;
	Resource->ob_y = work.g_y = (curr.g_h - work.g_h) / 2;
	wind_calc(WC_BORDER, WINDOW, Grect(&work), aGrect(&curr));

	if ((*wp = wind_create(WINDOW, Grect(&curr))) == -1)
	{	NOWINDOW;
		return 3;		/* no window */
	}
	wind_set(*wp, WF_NAME, Name, 0, 0);
	graf_growbox(Grect(& shrink), Grect(& curr));
	wind_open(*wp, Grect(& curr));

	graf_mouse(ARROW, 0L);
	wind_update(END_UPDATE);
	return 0;
}

/*
 *	termination
 */

static term(code, vh, wh)
	int code;			/* amount to clean up */
	int vh;				/* virtual workstation handle */
	int wh;				/* window handle */
{	GRECT curr;

	switch (code) {
	case 0:				/* normal termination */
		wind_get(wh, WF_CURRXYWH, aGrect(& curr));
		wind_close(wh);
		graf_shrinkbox(Grect(& shrink), Grect(& curr));
		wind_delete(wh);
	case 3:				/* no window */
	case 2:				/* no menu */
		v_clsvwk(vh);
	case 1:				/* no workstation */
		if (code)
			wind_update(END_UPDATE);
		appl_exit();
	case 4:				/* nothing at all */
		break;
	}
}

/*
 *	main program
 */

main()
{	int code, vh, wh;		/* init/term information */
	int event, done, i, m[8], x, y, key;
	OBJECT * op;

	if (! (code = init(&vh, &wh)))

	do
	{	event = evnt_multi(MU_KEYBD|MU_BUTTON|MU_MESAG,
			1, 1, 1,	/* 1 click on left button */
			0, 0, 0, 0, 0,	/* no area */
			0, 0, 0, 0, 0,	/* no second area */
			m,		/* message buffer */
			0, 0,		/* no timer */
			&x, &y,		/* result coordinates */
			&i, &i,		/* must be left button */
			&key,		/* keypress */
			&i);		/* must be one click */

		wind_update(BEG_UPDATE);

		done = 0;

		if (event & MU_KEYBD)
			done |= Keyboard(key);

		if ((event & MU_BUTTON)
		    && (i = objc_find(Resource, ROOT, MAX_DEPTH, x, y)) >= 0)
			done |= Button(i);

		if (event & MU_MESAG) switch (m[0]) {

		case WM_REDRAW:		/* need to redraw */
			objc_draw(Resource, ROOT, MAX_DEPTH,
				m[4], m[5], m[6], m[7]);
			break;

		case WM_TOPPED:		/* something got topped */
		case WM_NEWTOP:		/* we got topped */
			wind_set(m[3], WF_TOP, 0, 0, 0, 0);
			break;

		case WM_CLOSED:		/* time to quit */
			done = 1;
			break;

		case WM_MOVED:		/* we got moved */
			wind_set(m[3], WF_CURRXYWH, m[4], m[5], m[6], m[7]);
			wind_get(m[3], WF_WORKXYWH, m+4, m+5, m+6, m+7);
			Resource->ob_x = m[4];
			Resource->ob_y = m[5];
			break;
		}

		wind_update(END_UPDATE);

	} while (! done);

	term(code, vh, wh);
}
