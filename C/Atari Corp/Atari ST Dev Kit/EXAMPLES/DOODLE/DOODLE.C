/************************************************************************/
/*	DOODLE.C	An inferior drawing program.			*/
/************************************************************************/
/*									*/
/*			  +--------------------------+			*/
/*			  | PERPETRATED BY:	     |			*/
/*			  | Digital Research, Inc.   |			*/
/*			  | 60 Garden Court	     |			*/
/*			  | Monterey, CA.     93940  |			*/
/*			  +--------------------------+			*/
/*									*/
/*   The source code contained in this listing is a non-copyrighted	*/
/*   work which can be freely used (at the risk of your mental health).	*/
/*   In applications of this source code you are requested to		*/
/*   acknowledge Digital Research, Inc. as the originator of this code.	*/
/*   (In other words, don't blame Atari for this sorry mess...)		*/
/*									*/
/*   Author:	Tom Rolander, Tim Oren					*/
/*   PRODUCT:	GEM Sample Application					*/
/*   Module:	DOODLE,  Version 1.2					*/
/*   Version:	September 17, 1985					*/
/*									*/
/*   Revised: Mike Fulton, Atari Corp.  Nov. 1, 1991 (to fix problems	*/
/*		with revised compiler header files)			*/
/************************************************************************/


/*

Page*/
/*------------------------------*/
/*	includes		*/
/*------------------------------*/

#include "portab.h"				/* portable coding conv	*/
#include "machine.h"				/* machine depndnt conv	*/
#include "obdefs.h"				/* object definitions	*/
#include "treeaddr.h"				/* tree address macros	*/
#include "gemdefs.h"				/* gem binding structs	*/
#include "doodle.h"				/* doodle apl resource  */
#include "dos.h"				/* for local OS binding */



/*------------------------------*/
/*	defines			*/
/*------------------------------*/

#define FIS_SOLID	1
#define WA_UPPAGE	0
#define WA_DNPAGE	1
#define WA_UPLINE	2
#define WA_DNLINE	3
#define WA_LFPAGE	4
#define WA_RTPAGE	5
#define WA_LFLINE	6
#define WA_RTLINE	7

#define X_GETDRV 0x19
#define X_CREAT 0x3C
#define X_OPEN 0x3D
#define X_CLOSE 0x3E
#define X_READ 0x3F
#define X_WRITE 0x40
#define X_GETDIR 0x47
#define X_MALLOC 0x48
#define X_MFREE 0x49

#define	ARROW		0
#define	HOUR_GLASS	2

#define	DESK		0

#define END_UPDATE	0
#define	BEG_UPDATE	1

#define	PEN_INK		BLACK
#define	PEN_ERASER	WHITE

#define	PEN_FINE	1
#define	PEN_MEDIUM	5
#define	PEN_BROAD	9

#define X_FWD		0x0100		/* extended object types */
#define X_BAK		0x0200		/* used with scrolling	 */
#define X_SEL		0x0300		/* selectors		 */
#define N_COLORS	15L

#define	UMUL_DIV	umul_div
#define YSCALE(x) UMUL_DIV(x, scrn_xsize, scrn_ysize)

#define TE_TXTLEN(x) (x + 24)
#define BI_PDATA(x)	(x)
#define BI_WB(x)	(x + 4)
#define BI_HL(x)	(x + 6)

/*

Page*/
/************************************************************************/
/************************************************************************/
/****								     ****/
/****			    Data Structures			     ****/
/****								     ****/
/************************************************************************/
/************************************************************************/


/*------------------------------*/
/*	Extrnl Data Structures	*/
/*------------------------------*/

EXTERN	LONG	drawaddr;
EXTERN	LONG	gemdos();

/*------------------------------*/
/*	Global Data Structures	*/
/*------------------------------*/

GLOBAL UWORD	DOS_AX;	/* really a "DOS_RET"	*/
GLOBAL UWORD	DOS_ERR;

GLOBAL WORD	contrl[11];		/* control inputs		*/
GLOBAL WORD	intin[80];		/* max string length		*/
GLOBAL WORD	ptsin[256];		/* polygon fill points		*/
GLOBAL WORD	intout[45];		/* open workstation output	*/
GLOBAL WORD	ptsout[12];


/*------------------------------*/
/*	Local Data Structures	*/
/*------------------------------*/

WORD	gl_wchar;			/* character width		*/
WORD	gl_hchar;			/* character height		*/
WORD	gl_wbox;			/* box (cell) width		*/
WORD	gl_hbox;			/* box (cell) height		*/
WORD	gl_hspace;			/* height of space between lines*/
WORD	gem_handle;			/* GEM vdi handle		*/
WORD	vdi_handle;			/* doodle vdi handle		*/
WORD	work_out[57];			/* open virt workstation values	*/
GRECT	scrn_area;			/* whole screen area		*/
GRECT	work_area;			/* drawing area of main window  */
GRECT	undo_area;			/* area equal to work_area	*/
GRECT	save_area;			/* save area for full/unfulling */
WORD	gl_rmsg[8];			/* message buffer		*/
LONG	ad_rmsg;			/* LONG pointer to message bfr	*/
LONG	gl_menu;			/* menu tree address		*/
WORD	gl_apid;			/* application ID		*/
WORD	gl_xfull;			/* full window 'x'		*/
WORD	gl_yfull;			/* full window 'y'		*/
WORD	gl_wfull;			/* full window 'w'		*/
WORD	gl_hfull;			/* full window 'h'		*/
WORD	scrn_width;			/* screen width in pixels	*/
WORD	scrn_height;			/* screen height in pixels	*/
WORD	scrn_planes;			/* number of color planes	*/
WORD	scrn_xsize;			/* width of one pixel		*/
WORD	scrn_ysize;			/* height of one pixel		*/
UWORD	m_out = FALSE;			/* mouse in/out of window flag	*/
WORD	ev_which;			/* event multi return state(s)	*/
UWORD	mousex, mousey;			/* mouse x,y position		*/
UWORD	bstate, bclicks;		/* button state, & # of clicks	*/
UWORD	kstate, kreturn;		/* key state and keyboard char	*/
FDB	undo_mfdb;			/* undo buffer mmry frm def blk */
FDB	scrn_mfdb;			/* screen memory form defn blk	*/

LONG	buff_size;			/* buffer size req'd for screen */

LONG	buff_location;			/* screen buffer pointer	*/
WORD	dood_whndl;			/* doodle window handle		*/
WORD	dood_shade = PEN_INK;		/* doodle current pen shade	*/
WORD	pen_shade = PEN_INK;		/* saved pen shade		*/
WORD	dood_pen = 1;			/* doodle current pen width	*/
WORD	dood_height = 4;		/* doodle current char height	*/
WORD	char_fine;			/* character height for fine	*/
WORD	char_medium;			/* character height for medium	*/
WORD	char_broad;			/* character height for broad	*/
WORD	monumber = 5;			/* mouse form number		*/
LONG	mofaddr = 0x0L;			/* mouse form address		*/
WORD	file_handle;			/* file handle -> pict ld/sv	*/
BYTE	file_name[64] = "";		/* current pict file name	*/
BOOLEAN	key_input;			/* key inputting state		*/
WORD	key_xbeg;			/* x position for line beginning*/
WORD	key_ybeg;			/* y position for line beginning*/
WORD	key_xcurr;			/* current x position		*/
WORD	key_ycurr;			/* current y position		*/
					/* doodle window title		*/
BYTE	*wdw_title = " Doodle ";

WORD	usercolor[2] = {1, 0};
FDB	userbrush_mfdb;
USERBLK brushub[6];
LONG	color_sel[N_COLORS+1] = {	/* data for scrolling color selector */
	N_COLORS,
	0x31FF1071L,
	0x32FF1072L,
	0x33FF1073L,
	0x34FF1074L,
	0x35FF1075L,
	0x36FF1076L,
	0x37FF1077L,
	0x38FF1078L,
	0x39FF1079L,
	0x41FF107AL,
	0x42FF107BL,
	0x43FF107CL,
	0x44FF107DL,
	0x45FF107EL,
	0x46FF107FL};

/*

Page*/
/*------------------------------*/
/*	Mouse Data Structures	*/
/*------------------------------*/

WORD	erase_broad[37] =		/* mouse form for broad eraser	*/
{
	7, 7, 1, 0, 1,
	0x0000, 0x0000, 0x0000, 0x0000,	/* mask */
	0x0000, 0x1ff0, 0x1ff0, 0x1ff0,
	0x1ff0, 0x1ff0, 0x0000, 0x0000,
	0x0000, 0x0000, 0x0000, 0x0000,
	0x0000, 0x0000, 0x0000, 0x0000,	/* data */
	0x7ffc, 0x600c, 0x600c, 0x600c,
	0x600c, 0x600c, 0x7ffc, 0x0000,
	0x0000, 0x0000, 0x0000, 0x0000
};
WORD	erase_medium[37] =		/* mouse form for medium eraser	*/
{
	7, 7, 1, 0, 1,
	0x0000, 0x0000, 0x0000, 0x0000,	/* mask */
	0x0000, 0x0000, 0x07c0, 0x07c0,
	0x07c0, 0x0000, 0x0000, 0x0000,
	0x0000, 0x0000, 0x0000, 0x0000,
	0x0000, 0x0000, 0x0000, 0x0000,	/* data */
	0x0000, 0x1ff0, 0x1830, 0x1830,
	0x1830, 0x1ff0, 0x0000, 0x0000,
	0x0000, 0x0000, 0x0000, 0x0000
};
WORD	erase_fine[37] =		/* mouse form for fine eraser	*/
{
	7, 7, 1, 0, 1,
	0x0000, 0x0000, 0x0000, 0x0000,	/* mask */
	0x0000, 0x0000, 0x0000, 0x0100,
	0x0000, 0x0000, 0x0000, 0x0000,
	0x0000, 0x0000, 0x0000, 0x0000,
	0x0000, 0x0000, 0x0000, 0x0000,	/* data */
	0x0000, 0x0000, 0x07c0, 0x06c0,
	0x07c0, 0x0000, 0x0000, 0x0000,
	0x0000, 0x0000, 0x0000, 0x0000
};



/*

Page*/
/************************************************************************/
/************************************************************************/
/****								     ****/
/****			    Local Procedures			     ****/
/****								     ****/
/************************************************************************/
/************************************************************************/
	VOID
dos_func(function, parm)
	UWORD		function;
	LONG		parm;
{
	return( gemdos(function,parm) );
}

	WORD
dos_gdrv()
{
	return( gemdos(X_GETDRV) );
}

	WORD
dos_open(pname, access)
	BYTE		*pname;
	WORD		access;
{
	LONG		ret;

	ret = gemdos(X_OPEN,pname,access);
	if (DOS_ERR)
	  return(FALSE);
	else
	  return((UWORD)ret);
}

	WORD
dos_close(handle)
	WORD		handle;
{
	return( gemdos(X_CLOSE,handle) );
}

	UWORD
dos_read(handle, cnt, pbuffer)
	WORD		handle;
	LONG		cnt;
	LONG		pbuffer;
{
	return(gemdos(X_READ,handle,(ULONG)cnt,pbuffer));
}

	UWORD
dos_write(handle, cnt, pbuffer)
	WORD		handle;
	LONG		cnt;
	LONG		pbuffer;
{
	return(gemdos(X_WRITE,handle,(ULONG)cnt,pbuffer));
}

	WORD
dos_gdir(drive, pdrvpath)
	WORD		drive;
	REG BYTE *	pdrvpath;
{
	REG WORD ret;

	ret = gemdos(X_GETDIR,pdrvpath,drive);
	if (pdrvpath[0] == '\\')
	  strcpy(pdrvpath,&pdrvpath[1]);	/* remove leading '\' */
	return(ret);
}

	LONG
dos_create(name, attr)
	BYTE	*name;
	WORD	attr;
{
	return(gemdos(X_CREAT,name,attr));
}

	LONG
dos_alloc(nbytes)
	LONG		nbytes;
{
	REG LONG ret;

	ret = gemdos(X_MALLOC,nbytes);
	if (ret == 0)
	  DOS_ERR = TRUE;		/* gemdos() sets it to FALSE	*/
	return(ret);
}

	WORD
dos_free(maddr)
	LONG		maddr;
{
	return( gemdos(X_MFREE,maddr) );
}

/*------------------------------*/
/*	strlen			*/
/*------------------------------*/
WORD
strlen(p1)
BYTE		*p1;
{
	WORD		len;

	len = 0;
	while( *p1++ )
		len++;

	return(len);
}

/*------------------------------*/
/*	strcpy			*/
/*------------------------------*/
BYTE
*strcpy(pd, ps)
BYTE		*pd, *ps;
{
	while(*pd++ = *ps++)
		;
	return(pd);
}

/*------------------------------*/
/*	strcat			*/
/*------------------------------*/
BYTE
*strcat(pd, ps)
BYTE		*pd, *ps;
{
	while(*pd)
		pd++;
	while(*pd++ = *ps++)
		;
	return(pd);
}


/*------------------------------*/
/*	min			*/
/*------------------------------*/
WORD
min(a, b)			/* return min of two values */
WORD		a, b;
{
	return( (a < b) ? a : b );
}


/*------------------------------*/
/*	max			*/
/*------------------------------*/
WORD
max(a, b)			/* return max of two values */
WORD		a, b;
{
	return( (a > b) ? a : b );
}


/*------------------------------*/
/*	string_addr		*/
/*------------------------------*/
LONG
string_addr(which)		/* returns a tedinfo LONG string addr	*/
WORD	which;
{
	LONG	where;

	rsrc_gaddr(R_STRING, which, &where);
	return (where);
} 


/*------------------------------*/
/*	rc_equal		*/
/*------------------------------*/
WORD
rc_equal(p1, p2)		/* tests for two rectangles equal	*/
GRECT		*p1, *p2;
{
	if ((p1->g_x != p2->g_x) ||
	    (p1->g_y != p2->g_y) ||
	    (p1->g_w != p2->g_w) ||
	    (p1->g_h != p2->g_h))
		return(FALSE);
	return(TRUE);
}



/*------------------------------*/
/*	rc_copy			*/
/*------------------------------*/
VOID
rc_copy(psbox, pdbox)		/* copy source to destination rectangle	*/
GRECT	*psbox;
GRECT	*pdbox;
{
	pdbox->g_x = psbox->g_x;
	pdbox->g_y = psbox->g_y;
	pdbox->g_w = psbox->g_w;
	pdbox->g_h = psbox->g_h;
}


/*------------------------------*/
/*	rc_intersect		*/
/*------------------------------*/
WORD
rc_intersect(p1, p2)		/* compute intersect of two rectangles	*/
GRECT		*p1, *p2;
{
	WORD		tx, ty, tw, th;

	tw = min(p2->g_x + p2->g_w, p1->g_x + p1->g_w);
	th = min(p2->g_y + p2->g_h, p1->g_y + p1->g_h);
	tx = max(p2->g_x, p1->g_x);
	ty = max(p2->g_y, p1->g_y);
	p2->g_x = tx;
	p2->g_y = ty;
	p2->g_w = tw - tx;
	p2->g_h = th - ty;
	return( (tw > tx) && (th > ty) );
}


/*------------------------------*/
/*	inside			*/
/*------------------------------*/
UWORD
inside(x, y, pt)		/* determine if x,y is in rectangle	*/
UWORD		x, y;
GRECT		*pt;
{
	if ( (x >= pt->g_x) && (y >= pt->g_y) &&
	    (x < pt->g_x + pt->g_w) && (y < pt->g_y + pt->g_h) )
		return(TRUE);
	else
		return(FALSE);
} /* inside */


/*------------------------------*/
/*	grect_to_array		*/
/*------------------------------*/
VOID
grect_to_array(area, array)	/* convert x,y,w,h to upr lt x,y and	*/
GRECT	*area;			/*		      lwr rt x,y	*/
WORD	*array;
{
	*array++ = area->g_x;
	*array++ = area->g_y;
	*array++ = area->g_x + area->g_w - 1;
	*array = area->g_y + area->g_h - 1;
}


/*------------------------------*/
/*	rast_op			*/
/*------------------------------*/
VOID
rast_op(mode, s_area, s_mfdb, d_area, d_mfdb)	/* bit block level trns	*/
WORD	mode;
GRECT	*s_area, *d_area;
FDB	*s_mfdb, *d_mfdb;
{
	WORD	pxy[8];

	grect_to_array(s_area, pxy);
	grect_to_array(d_area, &pxy[4]);
	vro_cpyfm(vdi_handle, mode, pxy, s_mfdb, d_mfdb);
}

/*------------------------------*/
/*	vdi_fix			*/
/*------------------------------*/
VOID
vdi_fix(pfd, theaddr, wb, h)
	FDB		*pfd;
	LONG		theaddr;
	WORD		wb, h;
{
	pfd->fd_wdwidth = wb >> 1;
	pfd->fd_w = wb << 3;
	pfd->fd_h = h;
	pfd->fd_nplanes = 1;
	pfd->fd_addr = theaddr;
}

/*------------------------------*/
/*	vdi_trans		*/
/*------------------------------*/
WORD
vdi_trans(saddr, swb, daddr, dwb, h) 
	LONG		saddr;
	WORD		swb;
	LONG		daddr;
	WORD		dwb;
	WORD		h;
{
	FDB		src, dst;

	vdi_fix(&src, saddr, swb, h);
	src.fd_stand = TRUE;

	vdi_fix(&dst, daddr, dwb, h);
	dst.fd_stand = FALSE;
	vr_trnfm(vdi_handle, &src, &dst );
}

/*------------------------------*/
/*	trans_gimage		*/
/*------------------------------*/
VOID
trans_gimage(tree, obj)
	LONG	tree;
	WORD	obj;
{
	LONG	taddr, obspec;
	WORD	wb, hl;

	obspec = LLGET(OB_SPEC(obj));
	taddr = LLGET(BI_PDATA(obspec));
	wb = LWGET(BI_WB(obspec));
	hl = LWGET(BI_HL(obspec));
	vdi_trans(taddr, wb, taddr, wb, hl);
}

/*------------------------------*/
/*	do_open			*/
/*------------------------------*/
VOID
do_open(wh, org_x, org_y, x, y, w, h)	/* grow and open specified wdw	*/
WORD	wh;
WORD	org_x, org_y;
WORD	x, y, w, h;
{
	graf_growbox(org_x, org_y, 21, 21, x, y, w, h);
	wind_open(wh, x, y, w, h);
}


/*------------------------------*/
/*	do_close		*/
/*------------------------------*/
VOID
do_close(wh, org_x, org_y)	/* close and shrink specified window	*/
WORD	wh;
WORD	org_x, org_y;
{
	WORD	x, y, w, h;

	wind_get(wh, WF_CURRXYWH, &x, &y, &w, &h);
	wind_close(wh);
	graf_shrinkbox(org_x, org_y, 21, 21, x, y, w, h);
}

/*------------------------------*/
/*	set_clip		*/
/*------------------------------*/
VOID
set_clip(clip_flag, s_area)	/* set clip to specified area	*/
WORD	clip_flag;
GRECT	*s_area;
{
	WORD	pxy[4];

	grect_to_array(s_area, pxy);
	vs_clip(vdi_handle, clip_flag, pxy);
}

/*------------------------------*/
/*	draw_rect		*/
/*------------------------------*/
VOID
draw_rect(area)
GRECT	*area;
{
    	WORD	pxy[10];

    	pxy[0] = area->g_x;
    	pxy[1] = area->g_y;
    	pxy[2] = area->g_x + area->g_w - 1;
    	pxy[3] = area->g_y + area->g_h - 1;
    	pxy[4] = pxy[2];
    	pxy[5] = pxy[3];
    	pxy[3] = pxy[1];
    	pxy[6] = pxy[0];
    	pxy[7] = pxy[5];
    	pxy[8] = pxy[0];
    	pxy[9] = pxy[1];
    	v_pline(vdi_handle, 5, pxy);
}


/*------------------------------*/
/*	align_x			*/
/*------------------------------*/
WORD
align_x(x)		/* forces word alignment for column position	*/
WORD	x;		/*   rounding to nearest word			*/
{
	return((x & 0xfff0) + ((x & 0x000c) ? 0x0010 : 0));
}	


/*

Page*/
/************************************************************************/
/************************************************************************/
/****								     ****/
/****			Advanced Dialog Handling		     ****/
/****								     ****/
/************************************************************************/
/************************************************************************/


/*------------------------------*/
/*	set_select		*/
/*------------------------------*/
VOID
set_select(tree, obj, init_no, bind, arry)
LONG	tree, bind[], arry[];
WORD	obj, init_no;
{
	WORD	n, nobj, cobj, count;

	indir_obj(tree, obj);
	bind[0] = LLGET(OB_SPEC(obj));
	LLSET(OB_SPEC(obj), ADDR(bind));
	bind[1] = ADDR(arry);

	n = (WORD) arry[0];
	count = 0;
	for (cobj = LWGET(OB_HEAD(obj)); cobj != obj; 
	cobj = LWGET(OB_NEXT(cobj)))
	{
		indir_obj(tree, cobj);
		LLSET(OB_SPEC(cobj), ADDR( &arry[count + 1] ));
		count = (count + 1) % n;
	}

	nobj = LWGET(OB_NEXT(obj));
	indir_obj(tree, nobj);
	LLSET(OB_SPEC(nobj), ADDR( &arry[1 + init_no % n] ));
}

/*------------------------------*/
/*	get_select		*/
/*------------------------------*/
WORD
get_select(tree, obj)
LONG	tree;
WORD	obj;
{
	WORD	nobj, cobj;
	LONG	bind, arry, temp;

	bind = LLGET(OB_SPEC(obj));
	dir_obj(tree, obj);
	LLSET(OB_SPEC(obj), LLGET(bind));
	arry = LLGET(bind + sizeof(LONG) );

	for (cobj = LWGET(OB_HEAD(obj)); cobj != obj;
	cobj = LWGET(OB_NEXT(cobj)))
	{
		dir_obj(tree, cobj);
		LLSET(OB_SPEC(cobj), LLGET(LLGET(OB_SPEC(cobj))));
	}

	nobj = LWGET(OB_NEXT(obj));
	dir_obj(tree, nobj);
	temp = LLGET(OB_SPEC(nobj));
	LLSET(OB_SPEC(nobj), LLGET(temp));
	return (WORD) (temp - arry) / sizeof(LONG) - 1;
}

/*------------------------------*/
/*	move_do			*/
/*------------------------------*/
VOID
move_do(tree, obj, inc)
LONG	tree;
WORD	obj, inc;
{
	WORD	cobj; 
	LONG	n, bind, arry, limit, obspec;

	obj = get_parent(tree, obj);
	obj = LWGET(OB_NEXT(obj));
	bind = LLGET(OB_SPEC(obj));
	arry = LLGET(bind + sizeof(LONG));
	n = LLGET(arry) * sizeof(LONG);
	limit = arry + n;

	for (cobj = LWGET(OB_HEAD(obj)); cobj != obj;
	cobj = LWGET(OB_NEXT(cobj)))
	{
		obspec = LLGET(OB_SPEC(cobj));
		obspec += inc * sizeof(LONG);
		while (obspec <= arry || obspec > limit)
			obspec += n * ((obspec > limit)? -1: 1);
		LLSET(OB_SPEC(cobj), obspec);
	}

	redraw_do(tree, obj);
}

/*------------------------------*/
/*	redraw_do		*/
/*------------------------------*/
VOID
redraw_do(tree, obj)
LONG	tree;
WORD	obj;
{
	GRECT	o;

	objc_xywh(tree, obj, &o);
	o.g_x -= 3; o.g_y -= 3; o.g_w += 6; o.g_h += 6;
	objc_draw(tree, ROOT, MAX_DEPTH, o.g_x, o.g_y, o.g_w, o.g_h);
}

/*------------------------------*/
/*	xtend_do		*/
/*------------------------------*/
WORD
xtend_do(tree, obj, xtype)
LONG	tree;
WORD	obj, xtype;
{
	LONG	obspec;

	switch (xtype) {
		case X_SEL:
			obspec = LLGET(OB_SPEC(obj));
			obj = get_parent(tree, obj);
			obj = LWGET(OB_NEXT(obj));
			LLSET(OB_SPEC(obj), obspec);
			redraw_do(tree, obj);
			break;
		case X_FWD:
			move_do(tree, obj, 1);
			redraw_do(tree, obj);
			break;
		case X_BAK:
			move_do(tree, obj, -1);
			redraw_do(tree, obj);
			break;
		default:
			break;
	}
	return(FALSE);
}

/*------------------------------*/
/*	hndl_dial		*/
/*------------------------------*/
WORD
hndl_dial(tree, def, x, y, w, h)
LONG	tree;
WORD	def;
WORD	x, y, w, h;
{
	WORD	xdial, ydial, wdial, hdial, exitobj;
	WORD	xtype;

	form_center(tree, &xdial, &ydial, &wdial, &hdial);
	form_dial(0, x, y, w, h, xdial, ydial, wdial, hdial);
	form_dial(1, x, y, w, h, xdial, ydial, wdial, hdial);
	objc_draw(tree, ROOT, MAX_DEPTH, xdial, ydial, wdial, hdial);

	FOREVER
	{
		exitobj = form_do(tree, def) & 0x7FFF;
		xtype = LWGET(OB_TYPE(exitobj)) & 0xFF00;
		if (!xtype)
			break;
		if (xtend_do(tree, exitobj, xtype))
			break;
	}

	form_dial(2, x, y, w, h, xdial, ydial, wdial, hdial);
	form_dial(3, x, y, w, h, xdial, ydial, wdial, hdial);
	return (exitobj);
}

/*------------------------------*/
/*	dr_code			*/
/*------------------------------*/
WORD
dr_code(pparms)
LONG	pparms;
{
	PARMBLK		pb;
    	WORD		pxy[10], hl, wb;
	LONG		taddr;

	LBCOPY(ADDR(&pb), pparms, sizeof(PARMBLK));
    	set_clip(TRUE, (GRECT *) &pb.pb_xc);

	taddr = pb.pb_parm;
	userbrush_mfdb.fd_addr = LLGET(BI_PDATA(taddr));
	hl = LWGET(BI_HL(taddr));
	wb = LWGET(BI_WB(taddr));
	userbrush_mfdb.fd_w = wb << 3;
	userbrush_mfdb.fd_wdwidth = wb >> 1;
	userbrush_mfdb.fd_h = hl;
	userbrush_mfdb.fd_nplanes = 1;
	userbrush_mfdb.fd_stand = 0;

	pxy[0] = pxy[1] = 0;
	pxy[2] = (wb << 3) - 1;
	pxy[3] = hl - 1;
	pxy[4] = pb.pb_x; 
	pxy[5] = pb.pb_y;
	pxy[6] = pxy[4] + pb.pb_w - 1;
	pxy[7] = pxy[5] + pb.pb_h - 1;

	vrt_cpyfm(vdi_handle, 2, pxy, &userbrush_mfdb, &scrn_mfdb, usercolor);

	if((pb.pb_currstate!=pb.pb_prevstate)||(pb.pb_currstate&SELECTED))
	{
	        if (pb.pb_currstate & SELECTED)
		  	vsl_color(vdi_handle,1);
		else
		  	vsl_color(vdi_handle,0);
		vsl_width(vdi_handle, 1);
		vsl_type(vdi_handle, FIS_SOLID);

		pb.pb_x--;
		pb.pb_y--;
		pb.pb_w++;
		pb.pb_h++;
		draw_rect((GRECT *) &pb.pb_x);
	 }
	set_clip(TRUE, &work_area);
	return (0);
}

/*

Page*/
/************************************************************************/
/************************************************************************/
/****								     ****/
/****			    Work Area Management		     ****/
/****								     ****/
/************************************************************************/
/************************************************************************/


/*------------------------------*/
/*	set_work		*/
/*------------------------------*/
VOID
set_work(slider_update)		/* update undo area, clamping to page	*/
BOOLEAN	slider_update;		/*   edges, and updt sliders if req'd	*/
{
	WORD	i;

	wind_get(dood_whndl, WF_WORKXYWH,
	&work_area.g_x, &work_area.g_y,
	&work_area.g_w, &work_area.g_h);

	undo_area.g_w = work_area.g_w;
	undo_area.g_h = work_area.g_h;
	/**/					/* clamp work area to page edges */
	undo_area.g_x = align_x(undo_area.g_x);
	if ((i = undo_mfdb.fd_w - (undo_area.g_x + undo_area.g_w)) < 0)
		undo_area.g_x += i;
	if ((i = undo_mfdb.fd_h - (undo_area.g_y + undo_area.g_h)) < 0)
		undo_area.g_y += i;

	if (slider_update)
	{
		wind_set(dood_whndl, WF_HSLIDE, UMUL_DIV(undo_area.g_x, 1000,
			undo_mfdb.fd_w - undo_area.g_w), 0, 0, 0);
		wind_set(dood_whndl, WF_VSLIDE, UMUL_DIV(undo_area.g_y, 1000,
			undo_mfdb.fd_h - undo_area.g_h), 0, 0, 0);
		wind_set(dood_whndl, WF_HSLSIZ, UMUL_DIV(work_area.g_w, 1000,
			undo_mfdb.fd_w), 0, 0, 0);
		wind_set(dood_whndl, WF_VSLSIZ, UMUL_DIV(work_area.g_h, 1000,
			undo_mfdb.fd_h), 0, 0, 0);
	}

	/* only use portion of work_area on screen	*/
	rc_intersect(&scrn_area, &work_area);
	undo_area.g_w = work_area.g_w;
	undo_area.g_h = work_area.g_h;
}


/*------------------------------*/
/*	save_work		*/
/*------------------------------*/
VOID
save_work()			/* copy work_area to undo_area buffer	*/
{
	GRECT	tmp_area;

	rc_copy(&work_area,&tmp_area);
	rc_intersect(&scrn_area,&tmp_area);
	graf_mouse(M_OFF, 0x0L);
	rast_op(3, &tmp_area, &scrn_mfdb, &undo_area, &undo_mfdb);
	graf_mouse(M_ON, 0x0L);
}


/*------------------------------*/
/*	restore_work		*/
/*------------------------------*/
VOID
restore_work()			/* restore work_area from undo_area	*/
{
	GRECT	tmp_area;

	rc_copy(&work_area,&tmp_area);
	rc_intersect(&scrn_area,&tmp_area);
	graf_mouse(M_OFF, 0x0L);
	rast_op(3, &undo_area, &undo_mfdb, &tmp_area, &scrn_mfdb);
	graf_mouse(M_ON, 0x0L);
}


/*

Page*/
/************************************************************************/
/************************************************************************/
/****								     ****/
/****			    Object Tree Manipulation		     ****/
/****								     ****/
/************************************************************************/
/************************************************************************/


/*------------------------------*/
/*	do_obj			*/
/*------------------------------*/
VOID
do_obj(tree, which, bit)	/* set specified bit in object state	*/
LONG	tree;
WORD	which, bit;
{
	WORD	state;

	state = LWGET(OB_STATE(which));
	LWSET(OB_STATE(which), state | bit);
}


/*------------------------------*/
/*	undo_obj		*/
/*------------------------------*/
VOID
undo_obj(tree, which, bit)	/* clear specified bit in object state	*/
LONG	tree;
WORD	which, bit;
{
	WORD	state;

	state = LWGET(OB_STATE(which));
	LWSET(OB_STATE(which), state & ~bit);
}

/*------------------------------*/
/*	sel_obj			*/
/*------------------------------*/
VOID
sel_obj(tree, which)		/* turn on selected bit of spcfd object	*/
LONG	tree;
WORD	which;
{
	do_obj(tree, which, SELECTED);
}

/*------------------------------*/
/*	desel_obj		*/
/*------------------------------*/
VOID
desel_obj(tree, which)		/* turn off selected bit of spcfd object*/
LONG	tree;
WORD	which;
{
	undo_obj(tree, which, SELECTED);
}

/*------------------------------*/
/*	enab_menu		*/
/*------------------------------*/
VOID
enab_menu(which)		/* enable specified menu item	*/
WORD	which;
{
	undo_obj(gl_menu, which, DISABLED);
}

/*------------------------------*/
/*	unflag_obj		*/
/*------------------------------*/
VOID
unflag_obj(tree, which, bit)
LONG	tree;
WORD	which, bit;
{
	WORD	flags;

	flags = LWGET(OB_FLAGS(which));
	LWSET(OB_FLAGS(which), flags & ~bit);
}

/*------------------------------*/
/*	flag_obj		*/
/*------------------------------*/
VOID
flag_obj(tree, which, bit)
LONG	tree;
WORD	which, bit;
{
	WORD	flags;

	flags = LWGET(OB_FLAGS(which));
	LWSET(OB_FLAGS(which), flags | bit);
}

/*------------------------------*/
/*	indir_obj		*/
/*------------------------------*/
VOID
indir_obj(tree, which)
LONG	tree;
WORD	which;
{
	flag_obj(tree, which, INDIRECT);
}

/*------------------------------*/
/*	dir_obj			*/
/*------------------------------*/
VOID
dir_obj(tree, which)
LONG	tree;
WORD	which;
{
	unflag_obj(tree, which, INDIRECT);
}

/*------------------------------*/
/*	get_parent		*/
/*------------------------------*/
/*
*	Routine that will find the parent of a given object.  The
*	idea is to walk to the end of our siblings and return
*	our parent.  If object is the root then return NULL as parent.
*/
WORD
get_parent(tree, obj)
LONG		tree;
WORD		obj;
{
	WORD		pobj;

	if (obj == NULL)
		return (NULL);
	pobj = LWGET(OB_NEXT(obj));
	if (pobj != NULL)
	{
	  	while( LWGET(OB_TAIL(pobj)) != obj ) 
	  	{
	    		obj = pobj;
	    		pobj = LWGET(OB_NEXT(obj));
	  	}
	}
	return(pobj);
} 

/*------------------------------*/
/*	objc_xywh		*/
/*------------------------------*/
VOID
objc_xywh(tree, obj, p)		/* get x,y,w,h for specified object	*/
LONG	tree;
WORD	obj;
GRECT	*p;
{
	objc_offset(tree, obj, &p->g_x, &p->g_y);
	p->g_w = LWGET(OB_WIDTH(obj));
	p->g_h = LWGET(OB_HEIGHT(obj));
}


/*

Page*/
/************************************************************************/
/************************************************************************/
/****								     ****/
/****			    File Path Name Functions		     ****/
/****								     ****/
/************************************************************************/
/************************************************************************/


/*------------------------------*/
/*	dial_name		*/
/*------------------------------*/
WORD
dial_name ( name )		/* dialogue box input filename	*/
BYTE	*name;
{		    
	LONG	tree ;
	LONG	ted_addr ;
	BYTE	c ;	
	WORD	i, j;
	GRECT	box;


	objc_xywh(gl_menu, DOODFILE, &box);
	rsrc_gaddr( R_TREE, DOODSVAD, &tree) ;
	ted_addr = LLGET(OB_SPEC(DOODNAME));
	LLSET( ted_addr, ADDR(name) ) ;
	LWSET( TE_TXTLEN(ted_addr),9);
	name[0] = '\0';
	if (hndl_dial(tree, DOODNAME, box.g_x, box.g_y, box.g_w, box.g_h) == DOODSOK)
	{
		i =
		    j =  0;
		while (TRUE)
		{
			c = name[i++];
			if (!c) 
				break ;
			if ( (c != ' ') && (c != '_') )
				name[j++] = c ;
		}
		if ( *name )
			strcpy( &name[j], ".DOO" ) ;
		desel_obj(tree, DOODSOK);
		return (TRUE);
	}
	else
	{
		desel_obj(tree, DOODSCNL);
		return (FALSE);
	}
}


/*------------------------------*/
/*	get_path		*/
/*------------------------------*/
VOID
get_path(tmp_path, spec)	/* get directory path name	*/
BYTE	*tmp_path, *spec;
{
	WORD	cur_drv;

	cur_drv = dos_gdrv();
	tmp_path[0] = cur_drv + 'A';
	tmp_path[1] = ':';
	tmp_path[2] = '\\';
	dos_gdir(cur_drv+1, ADDR(&tmp_path[3]));
	if (strlen(tmp_path) > 3)
		strcat(tmp_path, "\\");
	else
		tmp_path[2] = '\0';
	strcat(tmp_path, spec);
}


/*------------------------------*/
/*	add_file_name		*/
/*------------------------------*/
VOID
add_file_name(dname, fname)	/* replace name at end of input file spec*/
BYTE	*dname, *fname;
{
	BYTE	c;
	WORD	ii;


	ii = strlen(dname);
	while (ii && (((c = dname[ii-1])  != '\\') && (c != ':')))
		ii--;
	dname[ii] = '\0';
	strcat(dname, fname);
}


/*------------------------------*/
/*	get_file		*/
/*------------------------------*/
WORD
get_file(loop)			/* use file selector to get input file	*/
BOOLEAN	loop;
{
	WORD	fs_iexbutton;
	BYTE	fs_iinsel[13];

	while (TRUE)
	{
		get_path(file_name, "*.DOO");
		fs_iinsel[0] = '\0';

		fsel_input(ADDR(file_name), ADDR(fs_iinsel), &fs_iexbutton);
		if (fs_iexbutton)
		{
			add_file_name(file_name, fs_iinsel);
			file_handle = dos_open(ADDR(file_name),2);
			if (!loop || (loop && !DOS_ERR))
				return(1);
		}
		else
			return (0);
	}
} /* get_file */


/*

Page*/
/************************************************************************/
/************************************************************************/
/****								     ****/
/****			    Soft Cursor Support			     ****/
/****								     ****/
/************************************************************************/
/************************************************************************/


/*------------------------------*/
/*	cursor			*/
/*------------------------------*/
VOID
cursor(color)			/* turn cursor on,  color = BLACK	*/
WORD	color;			/*   or cursor off, color = WHITE	*/
{
	WORD	pxy[4];

	pxy[0] = key_xcurr + 1;
	pxy[1] = key_ycurr + gl_hspace;
	pxy[2] = key_xcurr + 1;
	pxy[3] = key_ycurr - gl_hbox;

	vsl_color(vdi_handle,color);
	vswr_mode(vdi_handle,MD_REPLACE);
	vsl_type (vdi_handle,FIS_SOLID);
	vsl_width (vdi_handle,PEN_FINE);
	graf_mouse(M_OFF, 0x0L);
	set_clip(TRUE, &work_area);
	v_pline(vdi_handle, 2, pxy);
	set_clip(FALSE, &work_area);
	graf_mouse(M_ON, 0x0L);
}


/*------------------------------*/
/*	curs_on			*/
/*------------------------------*/
VOID
curs_on()			/* turn 'soft' cursor 'on'	*/
{
	cursor(pen_shade);
}

/*------------------------------*/
/*	curs_off		*/
/*------------------------------*/
VOID
curs_off()			/* turn 'soft' cursor 'off'	*/
{
	cursor(PEN_ERASER);
}


/*

Page*/
/************************************************************************/
/************************************************************************/
/****								     ****/
/****			    Menu Handling			     ****/
/****								     ****/
/************************************************************************/
/************************************************************************/


/*------------------------------*/
/*	hndl_menu		*/
/*------------------------------*/
WORD
hndl_menu(title, item)
WORD 	title, item;
{
	WORD	done;

	graf_mouse(ARROW, 0x0L);
	done = FALSE;
	switch (title) {
	case DOODDESK:
		if (item == DOODINFO)
			do_about();
		break;

	case DOODFILE:
		switch (item)
		{
		case DOODLOAD:
			do_load(TRUE);
			break;
		case DOODSAVE:
			do_save();
			break;
		case DOODSVAS:
			do_svas();
			break;
		case DOODABAN:
			file_handle = dos_open(ADDR(file_name),2);
			do_load(FALSE);
			break;
		case DOODQUIT:
			done = TRUE;
			break;
		}

	case DOODOPTS:
		switch (item)
		{
		case DOODPENS:
			do_penselect();
			break;
		case DOODERAP:
			do_erase();
			break;
		}
	}
	menu_tnormal(gl_menu,title,TRUE);
	graf_mouse(monumber, mofaddr);
	return (done);
}


/*------------------------------*/
/*	do_about		*/
/*------------------------------*/
VOID
do_about()			/* display Doodle Info... 	*/
{
	LONG	tree;
	GRECT	box;

	objc_xywh(gl_menu, DOODDESK, &box);
	rsrc_gaddr(R_TREE, DOODINFD, &tree);
	hndl_dial(tree, 0, box.g_x, box.g_y, box.g_w, box.g_h);
	desel_obj(tree, DOODOK);
}


/*------------------------------*/
/*	do_load			*/
/*------------------------------*/
VOID
do_load(need_name)		/* load doodle picture file	*/
BOOLEAN	need_name;
{
	if (!need_name || get_file(TRUE))
	{
		if (!DOS_ERR)
		{
			dos_read(file_handle, buff_size, buff_location);
			dos_close(file_handle);
			enab_menu(DOODSAVE);
			enab_menu(DOODABAN);
			restore_work();
		}
	}
}


/*------------------------------*/
/*	do_save			*/
/*------------------------------*/
VOID
do_save()			/* save current named doodle picture	*/
{
	if (*file_name)
	{
		file_handle = dos_open(ADDR(file_name),2);
		if (DOS_ERR)
			file_handle = dos_create(ADDR(file_name),0);
		else
		{
			if (form_alert(1, string_addr(DOODOVWR)) == 2)
				return;
		}
		dos_write(file_handle, buff_size, buff_location);
		enab_menu(DOODSAVE);
		enab_menu(DOODABAN);
		dos_close(file_handle);
	}
}


/*------------------------------*/
/*	do_save_as		*/
/*------------------------------*/
VOID
do_svas()			/* save doodle picture as named	*/
{
	BYTE	name[13];

	if (dial_name(&name[0]))
	{
		add_file_name(file_name, name);
		do_save();
	}
}

/*------------------------------*/
/*	set_pen			*/
/*------------------------------*/
VOID
set_pen(pen, height)
WORD	pen, height;
{
	dood_pen = pen;
	dood_height = height;
	monumber = 5;
	mofaddr = 0x0L;
}

/*------------------------------*/
/*	set_eraser		*/
/*------------------------------*/
VOID
set_eraser(pen, height, eraser)
WORD	pen, height;
BYTE	*eraser;
{
	dood_pen = pen;
	dood_height = height;
	dood_shade = PEN_ERASER;
	monumber = 255;
	mofaddr = ADDR(eraser);
}		

/*------------------------------*/
/*	set_color		*/
/*------------------------------*/
VOID
set_color(tree, obj, color_num, bind)
LONG	tree, *bind;
WORD	obj, color_num;
{
	set_select(tree, obj, color_num - 1, bind, color_sel);
}

/*------------------------------*/
/*	get_color		*/
/*------------------------------*/
WORD
get_color(tree, obj)
LONG	tree;
WORD	obj;
{
	return get_select(tree, obj) + 1;
}

/*------------------------------*/
/*	do_penselect		*/
/*------------------------------*/
VOID
do_penselect()			/* use dialogue box to input selection	*/
{				/*   of specified pen/eraser		*/
	WORD	exit_obj, psel_obj, color;
	LONG	tree, bind[2];
	GRECT	box;

	objc_xywh(gl_menu, DOODPENS, &box);
	rsrc_gaddr(R_TREE, DOODPEND, &tree);
	/**/			/* first setup current selection state	*/
	switch (dood_pen) {
		case PEN_FINE:
			sel_obj(tree, (dood_shade != PEN_ERASER)?
				DOODPFIN: DOODEFIN);
			break;
		case PEN_MEDIUM:
			sel_obj(tree, (dood_shade != PEN_ERASER)?
				DOODPMED: DOODEMED);
			break;
		case PEN_BROAD:
			sel_obj(tree, (dood_shade != PEN_ERASER)?
				DOODPBRD: DOODEBRD);
			break;
	}
	set_color(tree, DOODPCLR, pen_shade, bind);

	/**/				/* get dialogue box input	*/
	exit_obj = hndl_dial(tree, 0, box.g_x, box.g_y, box.g_w, box.g_h);
	for (psel_obj = DOODPFIN; psel_obj <= DOODEBRD; psel_obj++)
		if (LWGET(OB_STATE(psel_obj)) & SELECTED)
		{
			desel_obj(tree, psel_obj);
			break;
		}
	color = get_color(tree, DOODPCLR);

	if (exit_obj == DOODPSOK)
	{
		switch (psel_obj) {
			case DOODPFIN:
				set_pen(PEN_FINE, char_fine);
				dood_shade = color;
				break;
			case DOODPMED:
				set_pen(PEN_MEDIUM, char_medium);
				dood_shade = color;
				break;
			case DOODPBRD:
				set_pen(PEN_BROAD, char_broad);
				dood_shade = color;
				break;
			case DOODEFIN:
				set_eraser(PEN_FINE, char_fine, 
					(BYTE *) erase_fine);
				break;
			case DOODEMED:
				set_eraser(PEN_MEDIUM, char_medium,
					(BYTE *) erase_medium);
				break;
			case DOODEBRD:
				set_eraser(PEN_BROAD, char_broad,
					(BYTE *) erase_broad);
				break;
		}
		pen_shade = color;
		desel_obj(tree, DOODPSOK);
	}
	else
		desel_obj(tree, DOODCNCL);
}


/*------------------------------*/
/*	do_erase		*/
/*------------------------------*/
VOID
do_erase()			/* clear the screen and the undo buffer	*/
{
	rast_op(0, &scrn_area, &scrn_mfdb, &scrn_area, &undo_mfdb);
	restore_work();
}
/*

Page*/
/************************************************************************/
/************************************************************************/
/****								     ****/
/****			    Keyboard Handling			     ****/
/****								     ****/
/************************************************************************/
/************************************************************************/


/*------------------------------*/
/*	hndl_keyboard		*/
/*------------------------------*/
WORD
hndl_keyboard()
{
	WORD	i;
	BYTE	str[2];
	GRECT	lttr, test;

	if ((str[0] = kreturn) == 0x03)
		return(TRUE);
	graf_mouse(M_OFF, 0x0L);
	if (!key_input)
	{
		vswr_mode(vdi_handle, MD_REPLACE);
		vst_color(vdi_handle, pen_shade);
		vst_height(vdi_handle, dood_height,
			&gl_wchar,&gl_hchar,&gl_wbox,&gl_hbox);
		gl_hspace = gl_hbox - gl_hchar;
		vst_alignment(vdi_handle, 0, 3, &i, &i);
		graf_mkstate(&key_xbeg, &key_ybeg, &i, &i);
		key_xcurr = ++key_xbeg;
		key_ycurr = --key_ybeg;
	}
	else
		curs_off();
	str[1] = '\0';
	if (str[0] == 0x1A)
	{
		save_work();
		graf_mouse(M_ON, 0x0L);
		return(key_input = FALSE);
	}
	else
		if (str[0] == 0x0D)
		{
			key_ycurr += gl_hbox + gl_hspace;
			key_xcurr = key_xbeg;
		}
		else
			if (str[0] == 0x08)
			{
				if (key_input && (key_xcurr != key_xbeg))
				{
					for (i = 0; i < gl_wbox; i++)
					{
						key_xcurr--;
						curs_off();
					}
				}
			}
			else
				if ((str[0] >= ' ') && (str[0] <= 'z'))
				{
					lttr.g_x = key_xcurr;
					lttr.g_y = key_ycurr - gl_hbox;
					lttr.g_w = gl_wbox;
					lttr.g_h = gl_hbox;
					rc_copy(&lttr, &test);
					rc_intersect(&work_area, &test);
					if (!rc_equal(&lttr, &test))
						{
						graf_mouse(M_ON, 0x0L);
						return (FALSE);
						}
					set_clip(TRUE, &work_area);
					v_gtext(vdi_handle, key_xcurr,
						key_ycurr, str);
					set_clip(FALSE, &work_area);
					key_xcurr += gl_wbox;
				}
	if (!key_input)
	{
		key_input = TRUE;
	}
	curs_on();
	graf_mouse(M_ON, 0x0L);
	return(FALSE);
}



/*

Page*/
/************************************************************************/
/************************************************************************/
/****								     ****/
/****			    Message Handling			     ****/
/****								     ****/
/************************************************************************/
/************************************************************************/


/*------------------------------*/
/*	hndl_msg		*/
/*------------------------------*/
/*MLOCAL*/	BOOLEAN	hndl_msg()
{
	BOOLEAN	done; 
	WORD	wdw_hndl;
	GRECT	work;

	done = FALSE;
	wdw_hndl = gl_rmsg[3];
	switch( gl_rmsg[0] )
	{
	case MN_SELECTED:
		done = hndl_menu(wdw_hndl, gl_rmsg[4]);
		break;

	case WM_REDRAW:
		do_redraw(wdw_hndl, (GRECT *) &gl_rmsg[4]);
		break;

	case WM_TOPPED:
		wind_set(wdw_hndl, WF_TOP, 0, 0, 0, 0);
		break;
	case WM_CLOSED:
		done = TRUE;
		break;
	case WM_FULLED:
		do_full(wdw_hndl);
		break;
	case WM_ARROWED:
		switch(gl_rmsg[4])
		{
		case WA_UPPAGE:
			undo_area.g_y = max(undo_area.g_y - undo_area.g_h, 0);
			break;
		case WA_DNPAGE:
			undo_area.g_y += undo_area.g_h;
			break;
		case WA_UPLINE:
			undo_area.g_y = max(undo_area.g_y - YSCALE(16), 0);
			break;
		case WA_DNLINE:
			undo_area.g_y += YSCALE(16);
			break;
		case WA_LFPAGE:
			undo_area.g_x = max(undo_area.g_x-undo_area.g_w, 0);
			break;
		case WA_RTPAGE:
			undo_area.g_x += undo_area.g_w;
			break;
		case WA_LFLINE:
			undo_area.g_x = max(undo_area.g_x - 16, 0);
			break;
		case WA_RTLINE:
			undo_area.g_x += 16;
			break;
		}
		set_work(TRUE);
		restore_work();
		break;
	case WM_HSLID:
		undo_area.g_x = align_x(UMUL_DIV(undo_mfdb.fd_w - undo_area.g_w,
		gl_rmsg[4], 1000));
		set_work(TRUE);
		restore_work();
		break;
	case WM_VSLID:
		undo_area.g_y = UMUL_DIV(undo_mfdb.fd_h - undo_area.g_h,
		gl_rmsg[4],1000);
		set_work(TRUE);
		restore_work();
		break;
	case WM_SIZED:
		wind_calc(1, 0x0fef, gl_rmsg[4], gl_rmsg[5], gl_rmsg[6],
			gl_rmsg[7], &work.g_x, &work.g_y, &work.g_w,
			&work.g_h);
		work.g_x = align_x(work.g_x);
		work.g_w = align_x(work.g_w);
		wind_calc(0, 0x0fef, work.g_x, work.g_y, work.g_w, work.g_h,
			&gl_rmsg[4], &gl_rmsg[5], &gl_rmsg[6], &gl_rmsg[7]); 
		wind_set(wdw_hndl, WF_CURRXYWH, gl_rmsg[4],
			gl_rmsg[5], gl_rmsg[6], gl_rmsg[7]);
		set_work(TRUE);
		break;
	case WM_MOVED:
		gl_rmsg[4] = align_x(gl_rmsg[4]);
		wind_set(wdw_hndl, WF_CURRXYWH, align_x(gl_rmsg[4]) - 1,
		gl_rmsg[5], gl_rmsg[6], gl_rmsg[7]);
		set_work(FALSE);
		break;
	} /* switch */
	return(done);
} /* hndl_msg */

/*------------------------------*/
/*	do_redraw		*/
/*------------------------------*/
VOID
do_redraw(wh, area)		/* redraw specified area from undo bfr	*/
WORD	wh;
GRECT	*area;
{
	GRECT	box;
	GRECT	dirty_source, dirty_dest;

	graf_mouse(M_OFF, 0x0L);

	wind_get(wh, WF_FIRSTXYWH, &box.g_x, &box.g_y, &box.g_w, &box.g_h);
	while ( box.g_w && box.g_h )
	{
		if (rc_intersect(area, &box))
		{
			if (wh == dood_whndl)
			{
				rc_copy(&box, &dirty_dest);
				if (rc_intersect(&work_area, &dirty_dest))
				{
					dirty_source.g_x = (dirty_dest.g_x - work_area.g_x)
						+ undo_area.g_x;
					dirty_source.g_y = (dirty_dest.g_y - work_area.g_y)
						+ undo_area.g_y;
					dirty_source.g_w = dirty_dest.g_w;
					dirty_source.g_h = dirty_dest.g_h;
					rast_op(3, &dirty_source, &undo_mfdb,
					&dirty_dest, &scrn_mfdb);
				}
			}
		}
		wind_get(wh, WF_NEXTXYWH, &box.g_x, &box.g_y, &box.g_w, &box.g_h);
	}
	graf_mouse(M_ON, 0x0L);
}

/*------------------------------*/
/*	do_full			*/
/*------------------------------*/
VOID
do_full(wh)	/* depending on current window state, either make window*/
WORD	wh;	/*   full size -or- return to previous shrunken size	*/
{
	GRECT	prev;
	GRECT	curr;
	GRECT	full;

	graf_mouse(M_OFF,0x0L);
	wind_get(wh, WF_CURRXYWH, &curr.g_x, &curr.g_y, &curr.g_w, &curr.g_h);
	wind_get(wh, WF_PREVXYWH, &prev.g_x, &prev.g_y, &prev.g_w, &prev.g_h);
	wind_get(wh, WF_FULLXYWH, &full.g_x, &full.g_y, &full.g_w, &full.g_h);
	if ( rc_equal(&curr, &full) )
	{					/* is full now so change*/
		/**/					/*   to previous	*/
		graf_shrinkbox(prev.g_x, prev.g_y, prev.g_w, prev.g_h,
			full.g_x, full.g_y, full.g_w, full.g_h);
		wind_set(wh, WF_CURRXYWH, prev.g_x, prev.g_y, prev.g_w, prev.g_h);
		rc_copy(&save_area, &undo_area);
		set_work(TRUE);
		if ((prev.g_x == full.g_x) && (prev.g_y == full.g_y))
			do_redraw(wh, &work_area);
	}
	else
	{					/* is not full so make	*/
		/**/					/*   it full		*/
		rc_copy(&undo_area, &save_area);
		graf_growbox(curr.g_x, curr.g_y, curr.g_w, curr.g_h,
			full.g_x, full.g_y, full.g_w, full.g_h);
		wind_set(wh, WF_CURRXYWH, full.g_x, full.g_y, full.g_w, full.g_h);
		set_work(TRUE);
	}
	graf_mouse(M_ON,0x0L);
}
/*

Page*/
/************************************************************************/
/************************************************************************/
/****								     ****/
/****			    Mouse Handling			     ****/
/****								     ****/
/************************************************************************/
/************************************************************************/


/*------------------------------*/
/*	hndl_mouse		*/
/*------------------------------*/
WORD
hndl_mouse()
{
	BOOLEAN	done;

	if (m_out)
		graf_mouse(ARROW, 0x0L);
	else
		graf_mouse(monumber, mofaddr);

	m_out = !m_out;
	done = FALSE;
	return(done);
}


/*

Page*/
/************************************************************************/
/************************************************************************/
/****								     ****/
/****			    Button Handling			     ****/
/****								     ****/
/************************************************************************/
/************************************************************************/


/*------------------------------*/
/*	hndl_button		*/
/*------------------------------*/
WORD
hndl_button()
{
	WORD	done;

	done = FALSE;
	if (inside(mousex, mousey, &work_area))
		draw_pencil(mousex, mousey);
	return(done);
}


/*------------------------------*/
/*	draw_pencil		*/
/*------------------------------*/
WORD
draw_pencil(x, y)
UWORD	x, y;
{
	UWORD	pxy[4];
	WORD	done;
	UWORD	mflags;
	UWORD	locount, hicount;
	UWORD	ev_which, bbutton, kstate, kreturn, breturn;

	set_clip(TRUE, &work_area);
	pxy[0] = x;
	pxy[1] = y;

	vsl_color(vdi_handle,dood_shade);
	vswr_mode(vdi_handle,MD_REPLACE);
	vsl_type (vdi_handle,FIS_SOLID);

	if (dood_shade != PEN_ERASER)
	{
		vsl_width (vdi_handle,dood_pen);
		vsl_ends(vdi_handle, 2, 2);
		hicount = 0;
		locount = 125;
		mflags = MU_BUTTON | MU_M1 | MU_TIMER;
		graf_mouse(M_OFF, 0x0L);
	}
	else
	{
		vsf_interior(vdi_handle, 1);
		vsf_color(vdi_handle, WHITE);
		mflags = MU_BUTTON | MU_M1;
	}

	done = FALSE;
	while (!done)
	{
		ev_which = evnt_multi(mflags,
		0x01, 0x01, 0x00, 
		1, pxy[0], pxy[1], 1, 1,
		0, 0, 0, 0, 0,
		ad_rmsg, locount, hicount,
		&pxy[2], &pxy[3], &bbutton, &kstate,
		&kreturn, &breturn);

		if (ev_which & MU_BUTTON)
		{
			if (!(mflags & MU_TIMER))
				graf_mouse(M_OFF, 0x0L);
			if (dood_shade != PEN_ERASER)
				v_pline(vdi_handle, 2, (WORD *) pxy);
			else
				eraser((WORD) pxy[2], (WORD) pxy[3]);
			graf_mouse(M_ON, 0x0L);
			done = TRUE;
		}
		else
			if (ev_which & MU_TIMER)
			{
				graf_mouse(M_ON, 0x0L);
				mflags = MU_BUTTON | MU_M1;
			}
			else
			{
				if (!(mflags & MU_TIMER))
					graf_mouse(M_OFF, 0x0L);
				if (dood_shade != PEN_ERASER)
				{
					v_pline(vdi_handle, 2, (WORD *) pxy);
					mflags = MU_BUTTON | MU_M1 | MU_TIMER;
				}
				else
				{
					eraser((WORD) pxy[2], (WORD) pxy[3]);
					graf_mouse(M_ON,0x0L);
				}
				pxy[0] = pxy[2];
				pxy[1] = pxy[3];
			}
	} /* while */

	set_clip(FALSE, &work_area);
	save_work();
}


/*------------------------------*/
/*	eraser			*/
/*------------------------------*/
VOID
eraser(x, y)			/* erase rectangle of eraser size at x,y */
WORD	x, y;
{
	WORD	erase_xy[4];

	if (dood_pen == PEN_FINE)
	{
		erase_xy[0] = x - 2;
		erase_xy[1] = y - 1;
		erase_xy[2] = x + 2;
		erase_xy[3] = y + 1;
	}
	else
		if (dood_pen == PEN_MEDIUM)
		{
			erase_xy[0] = x - 4;
			erase_xy[1] = y - 2;
			erase_xy[2] = x + 4;
			erase_xy[3] = y + 2;
		}
		else
		{
			erase_xy[0] = x - 6;
			erase_xy[1] = y - 3;
			erase_xy[2] = x + 6;
			erase_xy[3] = y + 3;
		}
	vr_recfl(vdi_handle, erase_xy);
}


/*

Page*/
/************************************************************************/
/************************************************************************/
/****								     ****/
/****			    Doodle Event Handler		     ****/
/****								     ****/
/************************************************************************/
/************************************************************************/

/*------------------------------*/
/*	doodle			*/
/*------------------------------*/
doodle()
{
	BOOLEAN	done;

	key_input = FALSE;
	done = FALSE;
	FOREVER
	{
		ev_which = evnt_multi(MU_BUTTON | MU_MESAG | MU_M1 | MU_KEYBD,
		0x02, 0x01, 0x01, 
		m_out,
		(UWORD) work_area.g_x, (UWORD) work_area.g_y,
		(UWORD) work_area.g_w, (UWORD) work_area.g_h,
		0, 0, 0, 0, 0,
		ad_rmsg, 0, 0, 
		&mousex, &mousey, &bstate, &kstate,
		&kreturn, &bclicks);

		wind_update(BEG_UPDATE);

		if (!(ev_which & MU_KEYBD))
		{
			if (key_input)
			{
				curs_off();
				key_input = FALSE;
				save_work();
			}
		}

		if (ev_which & MU_MESAG)
		if (hndl_msg())
			break;

		if (ev_which & MU_BUTTON)
		if (hndl_button())
			break;

		if (ev_which & MU_M1)
		if (hndl_mouse())
			break;

		if (ev_which & MU_KEYBD)
		if (hndl_keyboard())
			break;

		wind_update(END_UPDATE);
	}
}
/*

Page*/
/************************************************************************/
/************************************************************************/
/****								     ****/
/****			    Termination				     ****/
/****								     ****/
/************************************************************************/
/************************************************************************/


/*------------------------------*/
/*	dood_term		*/
/*------------------------------*/
dood_term(term_type)
WORD	term_type;
{
	switch (term_type)	/* NOTE: all cases fall through		*/
	{
		case (0 /* normal termination */):
			do_close(dood_whndl, gl_wfull/2, gl_hfull/2);
			wind_delete(dood_whndl);
		case (3):
			menu_bar(0x0L, FALSE);
			dos_free(undo_mfdb.fd_addr);
		case (2):
			v_clsvwk( vdi_handle );
		case (1):
			wind_update(END_UPDATE);
			appl_exit();
		case (4):
			break;
	}
}

/*

Page*/
/************************************************************************/
/************************************************************************/
/****								     ****/
/****			    Initialization			     ****/
/****								     ****/
/************************************************************************/
/************************************************************************/
/*------------------------------*/
/*	pict_init		*/
/*------------------------------*/
VOID 
pict_init()
{
	LONG	tree;
	WORD	tr_obj, nobj;

	rsrc_gaddr(R_TREE, DOODINFD, &tree);
	trans_gimage(tree, DOODIMG);
	rsrc_gaddr(R_TREE, DOODPEND, &tree);
	for (tr_obj = DOODPFIN; tr_obj <= DOODEBRD; tr_obj++)
	{
		trans_gimage(tree, tr_obj);
		LWSET(OB_TYPE(tr_obj), G_USERDEF);
		nobj = tr_obj - DOODPFIN;
		brushub[nobj].ub_code = drawaddr;
		brushub[nobj].ub_parm = LLGET(OB_SPEC(tr_obj));
		LLSET(OB_SPEC(tr_obj), ADDR(&brushub[nobj]));	
	}
}

/*------------------------------*/
/*	dood_init		*/
/*------------------------------*/
WORD
dood_init()
{
	WORD	work_in[11];
	WORD	i;

	gl_apid = appl_init();			/* initialize libraries	*/
	if (gl_apid == -1)
		return(4);
	wind_update(BEG_UPDATE);
	graf_mouse(HOUR_GLASS, 0x0L);
	if (!rsrc_load( ADDR("DOODLE.RSC") ))
	{
		graf_mouse(ARROW, 0x0L);
		form_alert(1,
		ADDR("[3][Fatal Error !|DOODLE.RSC|File Not Found][ Abort ]"));
		return(1);
	}
	/* open virtual workstation */
	/* allocate undo buffer	*/
	for (i=0; i<10; i++)
	{
		work_in[i]=1;
	}
	work_in[10]=2;

	gem_handle = graf_handle(&gl_wchar,&gl_hchar,&gl_wbox,&gl_hbox);
	vdi_handle = gem_handle;
	v_opnvwk(work_in,&vdi_handle,work_out);

	if (vdi_handle == 0)
		return(1);

	scrn_width = work_out[0] + 1;
	scrn_height = work_out[1] + 1;
	scrn_xsize = work_out[3];
	scrn_ysize = work_out[4];

	char_fine = work_out[46];
	char_medium = work_out[48];
	char_broad = char_medium * 2;

	vq_extnd(vdi_handle, 1, work_out);
	scrn_planes = work_out[4];

	undo_mfdb.fd_w = scrn_width;
	undo_mfdb.fd_wdwidth = undo_mfdb.fd_w>>4;
	undo_mfdb.fd_h = scrn_height;
	undo_mfdb.fd_nplanes = scrn_planes;
	undo_mfdb.fd_stand = 0;

	buff_size = (LONG)(undo_mfdb.fd_w>>3) *
	    (LONG)undo_mfdb.fd_h *
	    (LONG)undo_mfdb.fd_nplanes;
	buff_location =
	    undo_mfdb.fd_addr  = dos_alloc(buff_size);

	if (undo_mfdb.fd_addr == 0)
		return(2);
	scrn_area.g_x = 0;
	scrn_area.g_y = 0;
	scrn_area.g_w = scrn_width;
	scrn_area.g_h = scrn_height;
	scrn_mfdb.fd_addr = 0x0L;

	rc_copy(&scrn_area, &undo_area);
	rast_op(0, &undo_area, &scrn_mfdb, &undo_area, &undo_mfdb);

	pict_init();	/* transforms & user defined objects */

	ad_rmsg = ADDR((BYTE *) &gl_rmsg[0]);

	wind_get(DESK, WF_WORKXYWH, &gl_xfull, &gl_yfull, &gl_wfull, &gl_hfull);
	/* initialize menu	*/
	rsrc_gaddr(R_TREE, DOODMENU, &gl_menu);
	/* show menu		*/
	menu_bar(gl_menu, TRUE);	

	dood_whndl = wind_create(0x0fef, gl_xfull - 1, gl_yfull,
	gl_wfull, gl_hfull);
	if (dood_whndl == -1)
	{
		form_alert(1, string_addr(DOODNWDW));
		return(3);
	}

	graf_mouse(HOUR_GLASS, 0x0L);
	wind_set(dood_whndl, WF_NAME, ADDR(wdw_title), 0, 0);
	gl_xfull = align_x(gl_xfull);
	do_open(dood_whndl, gl_wfull/2, gl_hfull/2, align_x(gl_xfull)-1,
		gl_yfull, gl_wfull, gl_hfull);
	wind_get(dood_whndl, WF_WORKXYWH,
	&work_area.g_x, &work_area.g_y,
	&work_area.g_w, &work_area.g_h);

	set_work(TRUE);
	rc_copy (&undo_area, &save_area);

	graf_mouse(ARROW,0x0L);
	wind_update(END_UPDATE);
	return(0);
}
/*

Page*/
/************************************************************************/
/************************************************************************/
/****								     ****/
/****			    Main Program			     ****/
/****								     ****/
/************************************************************************/
/************************************************************************/


/*------------------------------*/
/*	GEMAIN			*/
/*------------------------------*/
#if I8086
GEMAIN()
#endif
#if MC68K
main()
#endif
{
	WORD	term_type;

	if (!(term_type = dood_init()))
		doodle();
	dood_term(term_type);
}

