/*
	This module implements the Text window
	Scrolling, Cursor and Keyboard handling.
*/
#include	<osbind.h>
#include	<gemdefs.h>
#include	<obdefs.h>

extern	int	txt_handle;		/* Text Window		handle	*/
extern	int	shandle;		/* virtual workstation	handle	*/
extern	GRECT	twork;			/* Text Window	area		*/
extern	int	sdevm;			/* Screen device mode		*/
extern	int	gl_wchar;		/* system text char width	*/
extern	int	gl_hchar;		/* system text char height	*/
extern	struct	{
	char	mrow, mcol;			/* window Maximn RowCol	*/
	char	row, col;			/* window cursor RowCol	*/
} current;
extern	int	TWhclip;			/* TWindow horiz. clip	*/

#define		SLOR		0	/* Low    Res	320  x 200 	*/
#define		SMDR		1	/* Medium Res	640  x 200 	*/
#define		SHIR		2	/* High   Res	640  x 400	*/

/*	..Key translations..	*/
/*	All cursor keys		*/
#define		rtch		0x0c0	/* Cursor Right	*/
#define		lfch		0x0c1	/* Cursor Left	*/
#define		upch		0x0c2	/* Cursor Up	*/
#define		dnch		0x0c3	/* Cursor Down	*/
#define		bolc		0x0c4	/* S Curs Left	*/
#define		eolc		0x0c5	/* S Curs Right	*/
#define		pgup		0x0c6	/* S Curs Up	*/
#define		pgdn		0x0c7	/* S Curs Down	*/
#define		bofc		0x0c8	/* C Curs Up	*/
#define		eofc		0x0c9	/* C Curs Down	*/
#define		Insc		0x0ca	/* Insert Key	*/
#define		Delc		0x0cb	/* Delete Key	*/
#define		NxtW		0x0cc	/* C Curs Right	*/
#define		PrvW		0x0cd	/* C Curs Left	*/
/*	Ctrl Fctn keys		*/
#define		CF1		0x000	/* Cntrl F. 1	*/
#define		CF2		0x000	/* Cntrl F. 2	*/
#define		CF3		0x000	/* Cntrl F. 3	*/
#define		CF4		0x000	/* Cntrl F. 4	*/
#define		CF5		0x000	/* Cntrl F. 5	*/
#define		CF6		0x000	/* Cntrl F. 6	*/
#define		CF7		0x000	/* Cntrl F. 7	*/
#define		CF8		0x000	/* Cntrl F. 8	*/
#define		CF9		0x000	/* Cntrl F. 9	*/
#define		CF10		0x000	/* Cntrl F. 10	*/
/*	Shift Fctn keys		*/
#define		SF1		0x000	/* Shift F. 1	*/
#define		SF2		0x000	/* Shift F. 2	*/
#define		SF3		0x000	/* Shift F. 3	*/
#define		SF4		0x000	/* Shift F. 4	*/
#define		SF5		0x000	/* Shift F. 5	*/
#define		SF6		0x000	/* Shift F. 6	*/
#define		SF7		0x000	/* Shift F. 7	*/
#define		SF8		0x000	/* Shift F. 8	*/
#define		SF9		0x000	/* Shift F. 9	*/
#define		SF10		0x000	/* Shift F. 10	*/
/*	Alt Fctn keys		*/
#define		AF1		0x000	/* Alt   F. 1	*/
#define		AF2		0x000	/* Alt   F. 2	*/
#define		AF3		0x000	/* Alt   F. 3	*/
#define		AF4		0x000	/* Alt   F. 4	*/
#define		AF5		0x000	/* Alt   F. 5	*/
#define		AF6		0x000	/* Alt   F. 6	*/
#define		AF7		0x000	/* Alt   F. 7	*/
#define		AF8		0x000	/* Alt   F. 8	*/
#define		AF9		0x000	/* Alt   F. 9	*/
#define		AF10		0x000	/* Alt   F. 10	*/
/*	Function keys		*/
#define		F1		0x007	/* Disc Hyphen	*/
#define		F2		0x0f0	/* EM	dash	*/
#define		F3		0x0f7	/* EN	dash	*/
#define		F4		0x00c	/* Region Feed	*/
#define		F5		0x0fe	/* EM	space	*/
#define		F6		0x01c	/* Quad Right	*/
#define		F7		0x0fd	/* EN	space	*/
#define		F8		0x01d	/* Quad Center	*/
#define		F9		0x0fc	/* THIN	space	*/
#define		F10		0x012	/* Quad Left	*/
/*	DSII Special Keys	*/
#define		ctlC		0x003	/* Control C	*/
#define		sHY		0x00b	/* soft Hyphen	*/
#define		srt		0x00f	/* soft Return	*/
#define		sDH		0x014	/* soft DHyphen	*/
#define		esc		0x01b	/* Escape Key	*/
#define		hrt		0x01f	/* Hard Return	*/
#define		QR		0x01c	/* Quad Right	*/
#define		QC		0x01d	/* Quad Center	*/
#define		QL		0x012	/* Quad Left	*/
#define		DH		0x007	/* Disc Hyphen	*/
#define		TSP		0x0fc	/* THIN	space	*/
#define		NSP		0x0fd	/* EN	space	*/
#define		MSP		0x0fe	/* EM	space	*/
/*	Alernate Commands	*/
#define		ATA		0x0d0	/* Again	*/
#define		ATB		0x0d1	/* Buffer	*/
#define		ATC		0x0d2	/* Copy		*/
#define		ATD		0x0d3	/* Delete	*/
#define		ATF		0x0d4	/* Forward Find	*/
#define		ATG		0x0d5	/* Get Text	*/
#define		ATJ		0x0d6	/* Jump Marker	*/
#define		ATM		0x0d7	/* Set	Marker	*/
#define		ATR		0x0d8	/* Replace	*/
#define		ATS		0x0d9	/* Select Art.	*/
#define		ATT		0x0da	/* Insert G.Tag	*/
#define		ATV		0x0db	/* Reverse Find	*/
#define		ATX		0x0dc	/* Delete Tag	*/
#define		ATL		0x0de	/* Insert L.Tag	*/
#define		ATP		0x0df	/* Insert PiTag	*/

/*	Keyboard Tables		*/
static	unsigned char	uns_cap[32] = {		/* Unshift/CapLock keys	*/
	0x00, ' ' , 0x00, F1  , F2  , F3  , F4  , F5  ,	/* 0x38.. 0x3f	*/
	F6  , F7  , F8  , F9  , F10 , 0x00, 0x00, 0x00,	/* 0x40.. 0x47	*/
	upch, 0x00, '-' , lfch, 0x00, rtch, '+' , 0x00,	/* 0x48.. 0x4f	*/
	dnch, 0x00, Insc, Delc, 0x00, 0x00, 0x00, 0x00	/* 0x50.. 0x57	*/
};
static	unsigned char	shifted[24] = {		/* Shifted keys		*/
	pgup, 0x00, '-' , bolc, 0x00, eolc, '+' , 0x00,	/* 0x48.. 0x4f	*/
	pgdn, 0x00, Insc, Delc, SF1 , SF2 , SF3 , SF4 ,	/* 0x50.. 0x57	*/
	SF5 , SF6 , SF7 , SF8 , SF9 , SF10, 0x00, 0x00	/* 0x58.. 0x5f	*/
};
static	unsigned char	contrl[80] = {		/* Control keys		*/
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, ctlC, 0x00,	/* 0x28..0x2f	*/
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,	/* 0x30..0x37	*/
	0x00, 0x00, 0x00, CF1 , CF2 , CF3 , CF4 , CF5 ,	/* 0x38..0x3f	*/
	CF6 , CF7 , CF8 , 0x00, CF10, 0x00, 0x00, 0x00,	/* 0x40..0x47	*/
	bofc, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,	/* 0x48..0x4f	*/
	eofc, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,	/* 0x50..0x57	*/
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,	/* 0x58..0x5f	*/
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,	/* 0x60..0x67	*/
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,	/* 0x68..0x6f	*/
	0x00, 0x00, 0x00, PrvW, NxtW, 0x00, 0x00, 0x00	/* 0x70..0x77	*/
};
static	unsigned char	altern[56] = {		/* Alternate keys	*/
	0x00, 0x00, 0x00, ATR , ATT , 0x00, 0x00, 0x00,	/* 0x10..0x17	*/
	0x00, ATP , 0x00, 0x00, 0x00, 0x00, ATA , ATS ,	/* 0x18..0x1f	*/
	ATD , ATF , ATG , 0x00, ATJ , 0x00, ATL , 0x00,	/* 0x20..0x27	*/
	0x00, 0x00, 0x00, 0x00, 0x00, ATX , ATC , ATV ,	/* 0x28..0x2f	*/
	ATB , 0x00, ATM , 0x00, 0x00, 0x00, 0x00, 0x00,	/* 0x30..0x37	*/
	0x00, 0x00, 0x00, AF1 , AF2 , AF3 , AF4 , AF5 ,	/* 0x38..0x3f	*/
	AF6 , AF7 , AF8 , AF9 , AF10, 0x00, 0x00, 0x00	/* 0x40..0x47	*/
};

/*
	Routine to sound beeper.
*/
#define		CON	2
beep()
{
	Bconout(CON,7);
}

/*
	Routine to flush keyboard.
*/
flush_kbd()
{
/*	while (Bconstat(CON)) Bconin(CON);*/
     int tmp_buff[8];
     int event;
     int dummy;

           for(;;)	/* used to bleed off unwanted messages...*/
           {
		event = evnt_multi((MU_KEYBD|MU_TIMER),
				    0,0,0,
				    0,0,0,0,0,
				    0,0,0,0,0,
				    tmp_buff,
				    0,0,		/* timer == 0 */
				    &dummy,&dummy,
				    &dummy,&dummy,
				    &dummy,&dummy);

		if(event == MU_TIMER)
				break;
           }
}

/*
	Function to map in our keyboard codes.
	Used after an "event keyboard".
*/
unsigned char	mapkbd(kstat,kbret)
unsigned kstat, kbret;
{
	union {
		struct {
		  unsigned char scan;	/* Kbd Scan code	*/
		  unsigned char mchr;	/* mapped key code	*/
		}		kbyt;
		unsigned	kret;
	}	k;
	k.kret = kbret;
	kstat &= 15;
	if (kstat == 0) {		/* Unshift/Capslock	*/
		if (k.kbyt.scan >= 0x38 && k.kbyt.scan <= 0x57)
			k.kbyt.mchr	= uns_cap[k.kbyt.scan - 0x38];
	}
	else
	if (kstat >= 1 && kstat <= 3) {	/* All Shifted...	*/
		if (k.kbyt.scan >= 0x48 && k.kbyt.scan <= 0x5f)
			k.kbyt.mchr	= shifted[k.kbyt.scan - 0x48];
	}
	else
	if (kstat == 4) {		/* Control only...	*/
		if (k.kbyt.scan >= 0x28 && k.kbyt.scan <= 0x77)
			k.kbyt.mchr	= contrl[k.kbyt.scan - 0x28];
		else	k.kbyt.mchr	= 0;
	}
	else
	if (kstat == 8) {		/* Alternate only...	*/
		if (k.kbyt.scan >= 0x10 && k.kbyt.scan <= 0x47)
			k.kbyt.mchr	= altern[k.kbyt.scan - 0x10];
		else	k.kbyt.mchr	= 0;
	}
	else	k.kbyt.mchr	= 0;	/* other combo ignore	*/
	return(k.kbyt.mchr);
}

/*	Screen Definitions	*/
#define		wdw_cols	75		/* # columns fixed...	*/
extern	char	wdw_rows;			/* # rows set by screen	*/

/*	Cursor Tables		*/
static	unsigned tcurMR[10] = {			/* thin cursor MED RES	*/
0x8000,0x8000,0x8000,0x8000,0x8000,0x8000,0x8000,0x8000,/* 0x00.. 0x07	*/
0x8000,0x8000						/* 0x08.. 0x09	*/
};
static	unsigned tcurHR[18] = {			/* thin cursor HI RES	*/
0x8000,0x8000,0x8000,0x8000,0x8000,0x8000,0x8000,0x8000,/* 0x00.. 0x07	*/
0x8000,0x8000,0x8000,0x8000,0x8000,0x8000,0x8000,0x8000,/* 0x08.. 0x0f	*/
0x8000,0x8000						/* 0x10.. 0x11	*/
};
static	unsigned bcurMR[10] = {			/* box cursor  MED RES	*/
0xff00,0x8100,0x8100,0x8100,0x8100,0x8100,0x8100,0x8100,/* 0x00.. 0x07	*/
0x8100,0xff00						/* 0x08.. 0x09	*/
};
static	unsigned bcurHR[18] = {			/* box cursor  HI RES	*/
0xff00,0x8100,0x8100,0x8100,0x8100,0x8100,0x8100,0x8100,/* 0x00.. 0x07	*/
0x8100,0x8100,0x8100,0x8100,0x8100,0x8100,0x8100,0x8100,/* 0x08.. 0x0f	*/
0x8100,0xff00						/* 0x08.. 0x09	*/
};

/*	Cursor variables	*/
static	unsigned *tcurs[3]= { tcurHR, tcurMR, tcurHR };
static	unsigned *bcurs[3]= { bcurHR, bcurMR, bcurHR };
static	unsigned crsxy[8] = { 0,0,7,0,0,0,0,0 };/* pxy table of cursor	*/
static	int	vrtcoi[2] = {BLACK,WHITE};	/* vrt_cpyfm colorIndex	*/
static	FDB	curs_MFDB;			/* cursor MFDB		*/
static	char	cursor_clr = 1;			/* cleared state	*/

/*
	Function to scroll up or down 1 line the window.
*/
wdw_scroll(up)
int	up;
{
	GRECT	s, d;
	long	scrmfdb = 0L;			/* screen MFDB address	*/

	s.g_y	= d.g_y	= twork.g_y;
	if (up)
		s.g_y	+= gl_hchar;
	else	d.g_y	+= gl_hchar;
	s.g_x	= d.g_x	= twork.g_x;
	s.g_w	= d.g_w	= twork.g_w;
	s.g_h	= d.g_h	= (current.mrow - 1) * gl_hchar;
	rast_op(3,&s,&scrmfdb,&d,&scrmfdb);
	if (up)					/* adjust old cursor Y	*/
		crsxy[5] -= gl_hchar;
	else	crsxy[5] += gl_hchar;
}

/*
	Function to clear Text Window area
*/
clrTW(area)
GRECT	 *area;
{
	long	scrmfdb = 0L;			/* screen MFDB address	*/

	rast_op(0,area,&scrmfdb,area,&scrmfdb);
}

/*
	Function to set maximum number of Row and Column
	from current work area of Text Window.
*/
setMrowcol()
{
	int	newmcol;

	current.mrow = twork.g_h / gl_hchar;
	if (current.mrow > wdw_rows)
		current.mrow = wdw_rows;
	newmcol = (twork.g_w / gl_wchar) - 2;
	if (newmcol == current.mcol)
		return;
	if (newmcol >= wdw_cols) {
		newmcol = wdw_cols;
		TWhclip = 0;
	}
	else
	if (newmcol > current.mcol && TWhclip)
		TWhclip -= (TWhclip <= (newmcol - current.mcol))
				? TWhclip:newmcol - current.mcol;
	current.mcol = newmcol;
}

/*
	Function to get R.C. X value of cursor from column.
*/
xcrs(col)
int	col;
{
	return(twork.g_x + ((col+1) * gl_wchar));
}

/*
	Function to get R.C. Y value of cursor from row.
*/
ycrs(row)
int	row;
{
	return(twork.g_y + (row * gl_hchar));
}

/*
	Function to check if point (x,y) are in Text Window area
*/
xyinTW(x,y)
int	x, y;
{
	return(	x >= twork.g_x && x < (twork.g_x + twork.g_w)
		&&
		y >= twork.g_y && y < (twork.g_y + twork.g_h) );
}

/*
	Function to set cursor on screen at R.C. x and y.
*/
static	gcursor(y,x,mod)
unsigned y, x, mod;
{
	GRECT	t1, s;
	long	scrmfdb = 0L;		/* screen MFDB address	*/

	if (!xyinTW(x,y))
		return;
	crsxy[4] = s.g_x = x;
	crsxy[5] = s.g_y = y;
	crsxy[6] = x + 7;
	crsxy[7] = y + crsxy[3];
	s.g_w	 = 8;
	s.g_h	 = crsxy[3] + 1;
	wind_get(txt_handle,WF_FIRSTXYWH,&t1.g_x,&t1.g_y,&t1.g_w,&t1.g_h);
	while (t1.g_w && t1.g_h) {
	  if (rc_intersect(&s,&t1)) {
		set_clip(1,&t1);
		vrt_cpyfm(shandle,3,crsxy,&curs_MFDB,&scrmfdb,vrtcoi);
		set_clip(0,&t1);
		break;
	  }
	  wind_get(txt_handle,WF_NEXTXYWH,&t1.g_x,&t1.g_y,&t1.g_w,&t1.g_h);
	}
	cursor_clr = mod;		/* set cursor state	*/
}

/*
	Function to setup the cursor variables.
*/
setupcurs()
{
	curs_MFDB.fd_w		= 16;
	curs_MFDB.fd_h		= sdevm == SMDR ? 10:18;
	curs_MFDB.fd_wdwidth	= 1;
	curs_MFDB.fd_stand	= 0;
	curs_MFDB.fd_nplanes	= 1;
	curs_MFDB.fd_addr	= (long)tcurs[sdevm];
	crsxy[3]		= curs_MFDB.fd_h - 1;
}

/*
	Function to turn thin line cursor on. (System/Insert modes)
*/
wdw_crsnm()
{
	setcursor(1);
}

/*
	Function to turn box type cursor on. (Overwrite mode)
*/
wdw_crsbx()
{
	setcursor(2);
}

/*
	Function to set the cursor at current internal row and column.
	"mode" if true change the cursor type :
		1 --	thin line	cursor
		2 --	box type	cursor
*/
setcursor(mode)
int	mode;
{
	clrcursor();					/* delete old	*/
	if (mode == 1)
		curs_MFDB.fd_addr = (long)tcurs[sdevm];
	else
	if (mode == 2)
		curs_MFDB.fd_addr = (long)bcurs[sdevm];
	gcursor(ycrs(current.row),xcrs(current.col),0);	/* display new	*/
}

/*
	Function to clear old cursor if not cleared.
*/
clrcursor()
{
	if (!cursor_clr) gcursor(crsxy[5],crsxy[4],1);
}

/*
	Function to convert if needed passed char to video one.
	Returns new/old video character.
*/
unsigned char	ctvdc(c)
unsigned char	c;
{
	if (c == sHY ||
	    c == sDH)	c = '-';
	else
	if (c ==  DH)	c = 0x0fa;
	else
	if (c == srt)	c = 0x00d;
	else
	if (c == hrt)	c = 0x002;
	else
	if (c == QL)	c = 0x004;
	else
	if (c == QR)	c = 0x003;
	else
	if (c == QC)	c = 0x005;
	else
	if (c == ATP)	c = 0x0e3;
	else
	if (c == 0 ||
	    c == 255)	c = 0x07f;
	return(c);
}
