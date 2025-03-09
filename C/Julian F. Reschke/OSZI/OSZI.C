/*
	@(#)oszi.c
	Copyright (c) 1995
	Julian F. Reschke /
	Maxon Computer
*/

#include <aes.h>
#include <stdio.h>
#include <string.h>
#include <tos.h>
#include <vdi.h>

#define PNAME	"DMA-Sound-Oszilloskop"

/* Erweiterungen fr PureC */

#define SMALLER         0x4000

#define WM_BUTTOMED     33
#define WM_ICONIFY      34
#define WM_UNICONIFY    35
#define WM_ALLICONIFY   36

#define WF_ICONIFY      26
#define WF_UNICONIFY    27
#define WF_UNICONIFYXYWH    28

/* appl_getinfo fr AES >= 0x0400 und „ltere
   Systeme mit entsprechender Erweiterung */

static int
appl_xgetinfo (int type, int *out1, int *out2,
    int *out3, int *out4)
{
    static short hasagi = -1;

    if (hasagi < 0)
        hasagi = _GemParBlk.global[0] >= 0x400 ||
            appl_find( "?AGI\0\0\0\0") == 0;

    return !hasagi ? 0 :
        appl_getinfo (type, out1, out2, out3, out4);
}

/* Mittels appl_getinfo wird abgefragt, ob Iconify
   m”glich ist */

static int
has_iconify (void)
{
    static int hasit = -1;

    if (hasit < 0)
    {
        int dum, val = 0;

        hasit = 0;

        appl_xgetinfo (11, &val, &dum, &dum, &dum);
        if (val & 128) hasit = 1;
    }

    return hasit;
}


/* wind_xset/xget: Varianten, die im Gegensatz zu
   denem in den Pure-C-Libraries auch mit unbekannten
   Opcodes richtig funktioniert */
   
static int    contrl[15];
static int    global[15];
static int    intin[132];
static int    intout[140];
static int    addrin[16];
static int    addrout[16];

static AESPB A = { contrl, global, intin,
	intout, addrin, addrout };

static int
wind_xget (int handle, int field, int *w1, int *w2,
	int *w3, int *w4)
{
	contrl[0] = 104;
	contrl[1] = 2;
	contrl[2] = 5;
	contrl[3] = contrl[4] = 0;
	intin[0] = handle;
	intin[1] = field;
	_crystal (&A);
	*w1 = intout[1];
	*w2 = intout[2];
	*w3 = intout[3];
	*w4 = intout[4];
	return intout[0];
}

static int
wind_xset (int handle, int field, int w1, int w2,
	int w3, int w4)
{
	contrl[0] = 105;
	contrl[1] = 6;
	contrl[2] = 1;
	contrl[3] = contrl[4] = 0;
	intin[0] = handle;
	intin[1] = field;
	intin[2] = w1;
	intin[3] = w2;
	intin[4] = w3;
	intin[5] = w4;
	_crystal (&A);
	return intout[0];
}


/* Erst hier geht es richtig los */

#define HEIGHT	80			/* Fensterh”he */
#define WIDTH	400			/* Fensterbreite */
#define BPL		WIDTH/8

static char wtitle[128] = " "PNAME" ";
static char oszimem[HEIGHT*BPL];
static int colors[] = {0, 1};

/* MFDB fr die Offscreen-Bitmap, in der alles
   passiert */

static MFDB oszimfdb = {
	oszimem,
	WIDTH, HEIGHT,
	BPL / 2,
	1, 1,
	0, 0, 0
};

/* MFDB fr den Bildschirm (auf 0
   initialisiert */

static MFDB screen;

static char *offs[256], *loffs[256], *roffs[256];

#define byte unsigned char

/* die DMA-Sound-Register */

short *soundctrl = (short *)0xffff8900L;

byte *fbhigh = (byte *)0xffff8903L;
byte *fbmid = (byte *)0xffff8905L;
byte *fblow = (byte *)0xffff8907L;

byte *fchigh = (byte *)0xffff8909L;
byte *fcmid = (byte *)0xffff890BL;
byte *fclow = (byte *)0xffff890DL;

byte *fehigh = (byte *)0xffff890fL;
byte *femid = (byte *)0xffff8911L;
byte *felow = (byte *)0xffff8913L;

short *soundmode = (short *)0xffff8920L;


/* Aktuelle Parameter der Soundhardware
   erfragen */

static void
getsnddata (int *mode, int *ctrl,
	long *adr, long *end)
{
	long oldsp = Super (0L);
	char *d = (char *)adr;
	char *e = (char *)end;

	*mode = *soundmode;
	*ctrl = *soundctrl;
	*d++ = 0;
	*d++ = *fchigh;
	*d++ = *fcmid;
	*d = *fclow;
	*e++ = 0;
	*e++ = *fehigh;
	*e++ = *femid;
	*e = *felow;

	Super ((void *)oldsp);
}

/* Tabellen fr Bitmapausgabe
   vorberechnen */

static void
init_table (void)
{
	char **d = offs;
	char **r = roffs;
	char **l = loffs;
	int i;

	for (i = 0; i < 128; i++)
	{
		*d++ = oszimem + (HEIGHT/2 +
			(i * HEIGHT/2) / 128) * BPL;
		*l++ = oszimem + (HEIGHT/3 +
			(i * HEIGHT/3) / 128) * BPL;
		*r++ = oszimem + (HEIGHT*2/3 +
			(i * HEIGHT/3) / 128) * BPL;
	}
	for (i = -128; i < 0; i++)
	{
		*d++ = oszimem + (HEIGHT/2 +
			(i * HEIGHT/2) / 128) * BPL;
		*l++ = oszimem + (HEIGHT/3 +
			(i * HEIGHT/3) / 128) * BPL;
		*r++ = oszimem + (HEIGHT*2/3 +
			(i * HEIGHT/3) / 128) * BPL;
	}
}

/* Bitmap berechnen */

static int
disp (int *mode)
{
	static int bla = 0x01;
	int control;
	unsigned char *adr, *end;
	int i;

	getsnddata (mode, &control,
		(long *)&adr, (long *)&end);

	/* DMA-Sound aktiv? */
	if (control & 1)
	{
		int mask = 1 << (bla++ & 7);

		memset (oszimem, 0, sizeof (oszimem));

		/* Stereo oder Mono? */
		if (!(*mode & 0x80))
		{
			if ((long)end - (long)adr < WIDTH * 2)
				adr = end - WIDTH * 2;

			memset (loffs[0], mask, BPL);
			memset (roffs[0], mask, BPL);

			for (i = 0; i < BPL; i++)
			{
				loffs[*adr++][i] ^= 0x80;
				roffs[*adr++][i] ^= 0x80;
				loffs[*adr++][i] ^= 0x40;
				roffs[*adr++][i] ^= 0x40;
				loffs[*adr++][i] ^= 0x20;
				roffs[*adr++][i] ^= 0x20;
				loffs[*adr++][i] ^= 0x10;
				roffs[*adr++][i] ^= 0x10;
				loffs[*adr++][i] ^= 0x8;
				roffs[*adr++][i] ^= 0x8;
				loffs[*adr++][i] ^= 0x4;
				roffs[*adr++][i] ^= 0x4;
				loffs[*adr++][i] ^= 0x2;
				roffs[*adr++][i] ^= 0x2;
				loffs[*adr++][i] ^= 0x1;
				roffs[*adr++][i] ^= 0x1;
			}
		}
		else
		{
			if ((long)end - (long)adr < WIDTH)
				adr = end - WIDTH;

			memset (oszimem + BPL * HEIGHT/2,
				mask, BPL);

			for (i = 0; i < BPL; i++)
			{
				offs[*adr++][i] ^= 0x80;
				offs[*adr++][i] ^= 0x40;
				offs[*adr++][i] ^= 0x20;
				offs[*adr++][i] ^= 0x10;
				offs[*adr++][i] ^= 0x8;
				offs[*adr++][i] ^= 0x4;
				offs[*adr++][i] ^= 0x2;
				offs[*adr++][i] ^= 0x1;
			}
		}
	}

	return control;
}

#define MAX(a,b) ((a>b)?a:b)
#define MIN(a,b) ((a<b)?a:b)

static int
rect_inter (int x1, int y1, int w1,
	int h1, int x2, int y2, int w2,
	int h2, int *x3, int *y3, int *w3, int *h3)
{
	int t1,t2;

	*x3 = MAX(x1,x2);
	*y3 = MAX(y1,y2);
	t1 = x1+w1; t2 = x2+w2;
	*w3 = MIN(t1,t2) - *x3;
	t1 = y1+h1; t2 = y2+h2;
	*h3 = MIN(t1,t2) - *y3;
	return((*w3>0)&&(*h3>0));
}

static int
redraw (int whandle, int vdihandle,
	int lastmode, int orgx, int orgy, int cx, int cy,
	int cw, int ch, int force)
{
	int dx, dy, dw, dh;
	int newmode;
	int ctl = disp (&newmode);

	/* hat sich der Soundmode ge„ndert? */
	if (newmode != lastmode)
	{
		int rate = newmode & 3;
		char *str[] = {"6.25", "12.5", "25", "50"};
		char *s = wtitle;

		s += sprintf (s, " "PNAME" ");
		if (ctl & 1)
			sprintf (s, "[%s KHz] ", str[rate]);

		wind_set (whandle, WF_NAME, wtitle);
	}

	if (!force && !(ctl & 1)) return newmode;

	wind_update (BEG_UPDATE);
	wind_get (whandle, WF_FIRSTXYWH,
		&dx, &dy, &dw, &dh);

	graf_mouse (M_OFF, 0);
	while (dw && dh)
	{
		int x1, y1, w1, h1;

		if (rect_inter (cx, cy, cw, ch,
			dx, dy, dw, dh, &x1, &y1, &w1, &h1))
		{
			int pxy[8];

			pxy[0] = x1 - orgx;
			pxy[1] = y1 - orgy;
			pxy[2] = pxy[0] + w1 - 1;
			pxy[3] = pxy[1] + h1 - 1;
			pxy[4] = x1; pxy[5] = y1;
			pxy[6] = x1 + w1 - 1;
			pxy[7] = y1 + h1 - 1;

			vrt_cpyfm (vdihandle, MD_REPLACE, pxy,
				&oszimfdb, &screen, colors);
		}

		wind_get (whandle, WF_NEXTXYWH,
			&dx, &dy, &dw, &dh);
	}

	wind_update (END_UPDATE);
	graf_mouse (M_ON, 0);
	return newmode;
}

/* Fenster ”ffnen bzw schliežen */

static int
open_window (int *x, int *y, int *w, int *h)
{
	int handle;
	int wx, wy, ww, wh;

	wind_calc (WC_BORDER, NAME|CLOSER|MOVER|SMALLER,
		96, 100, WIDTH, HEIGHT, &wx, &wy, &ww, &wh);
	handle = wind_create (NAME|CLOSER|MOVER|SMALLER,
		wx, wy, ww, wh);

	if (handle >= 0) {
		wind_set (handle, WF_NAME, wtitle);
		wind_open (handle, wx, wy, ww, wh);
		wind_get (handle, WF_WORKXYWH, x, y, w, h);
	}
	else
		form_alert (1, "[1][ Konnte Fenster|"
			"nicht ”ffnen!][ OK ]");
	
	return handle;
}

static void
close_window (int handle)
{
	wind_close (handle);
	wind_delete (handle);
}


/* Eventschleife */

static int
do_events (int vdihandle)
{
	int winx, winy, winw, winh;
	int lastmode = -1;
	int done = 0, iconified = 0;
	int top = 1;
	int whandle = -1;

	if (_app)
	{
		whandle = open_window (&winx, &winy,
			&winw, &winh);
		if (whandle < 0) return 1;
	}

	while (!done)
	{
		int mbuf[8];
		int dummy;
		int shiftstate, key;

		int which =	evnt_multi 
			(
			whandle < 0 ? MU_MESAG :
				MU_KEYBD|MU_MESAG|MU_TIMER,
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
			mbuf,
			top ? 20 : 100,
			0, &dummy, &dummy,
			&dummy, &shiftstate, &key, &dummy);

        if (which & MU_KEYBD)
        {
            /* ^Q und ^U beenden */
            if ((key & 0xff) == 17) done = 1;
            if ((key & 0xff) == 21) done = 1;

            /* Vorschlag: Alt-Ctrl-Blank minimiert,
               mit zus„tzlicher Shift-Taste
               entspricht es WM_ALLICONIFY */
               
            if ((key & 0xff00) == 0x3900 &&
                (shiftstate & 12) == 12 &&
                has_iconify ())
            {
                which &= ~MU_KEYBD;
                which |= MU_MESAG;
                mbuf[0] = WM_ICONIFY;
                mbuf[3] = whandle;
            }
            
            if ((key & 0xff00) == 0x6200)
            	form_alert (1, "[1]"
            		"[DMA-Sound-Oszilloskop| "
            		"|Copyright (c) 1995"
            		"|Julian Reschke"
            		"|Maxon Computer GmbH][ OK ]");
        }

		if (which & MU_TIMER)
			lastmode = redraw (whandle, vdihandle,
				lastmode, winx, winy, winx, winy,
				winw, winh, 0);

		if (which & MU_MESAG)
		{
			switch (mbuf[0])
			{
				case AC_OPEN:
					whandle = open_window (&winx, &winy,
						&winw, &winh);
					break;
			
				case AC_CLOSE:
					whandle = -1;
					break;

				case AP_TERM:
				case WM_CLOSED:
					close_window (whandle);
					whandle = -1;
					done = 1;
					break;

				case WM_MOVED:
					if (mbuf[3] == whandle)
					{
						wind_set (whandle, WF_CURRXYWH,
							mbuf[4], mbuf[5], mbuf[6],
							mbuf[7]);
						wind_get (whandle, WF_WORKXYWH,
							&winx, &winy, &winw, &winh);
					}
					break;

				case WM_UNTOPPED:
				case WM_ONTOP:
					top = mbuf[0] == WM_ONTOP;
					break;

 				case WM_NEWTOP:
				case WM_TOPPED:
					if (mbuf[3] == whandle)
					{
						wind_set (whandle, WF_TOP);
						top = 1;
					}
					break;

				case WM_BUTTOMED:
					wind_set (mbuf[3], WF_BOTTOM);
					break;

				case WM_REDRAW:
					if (mbuf[3] == whandle)
						lastmode = redraw (whandle,
							vdihandle, lastmode, winx,
							winy, mbuf[4], mbuf[5],
							mbuf[6], mbuf[7], 1);
					break;

                case WM_ICONIFY:
                case WM_ALLICONIFY:
                case WM_UNICONIFY:
                    if (!iconified)
                    {
						int ox, oy, ow, oh;
						
						iconified = 1;
						wind_get (whandle, WF_CURRXYWH,
							&ox, &oy, &ow, &oh);
						wind_close (whandle);
						wind_set (whandle, WF_ICONIFY,
							-1, -1, -1, -1);
						wind_xset (whandle, WF_UNICONIFYXYWH,
							ox, oy, ow, oh);
						wind_open (whandle, -1, -1,
							-1, -1);
					}
                    else
                    {
                        iconified = 0;
                        wind_xget (whandle, WF_UNICONIFY,
                        	&mbuf[4], &mbuf[5],
                        	&mbuf[6], &mbuf[7]);
                        wind_set (whandle, WF_UNICONIFY,
                        	mbuf[4], mbuf[5],
                        	mbuf[6], mbuf[7]);
                    }

					wind_get (whandle, WF_WORKXYWH,
						&winx, &winy, &winw, &winh);
                    break;
			}
		}
	}

	return 0;
}



/* beim AES anmelden */

static void
register_aes (void)
{
	int dum, event = 0;

	/* AP_TERM nur dann, wenn nicht ACC */
	appl_xgetinfo (10, &event, &dum, &dum, &dum);
	if ((event & 0xff) >= 9 && _app)
		shel_write (9, 1, 0, NULL, NULL);
	
	/* Meneintrag bei AES 4.00 oder ACC */
	if (_GemParBlk.global[0] >= 0x400 || !_app)
		menu_register (_GemParBlk.global[2],
			"  Oszilloskop");
}

static long cookieptr (void)
{ return *((long *)0x5a0); }

static int
get_cookie (long cookie, long *p_value)
{
	long *cookiejar = (long *)Supexec (cookieptr);
	if (!cookiejar) return 0;

	do {
		if (cookiejar[0] == cookie) {
			if (p_value) *p_value = cookiejar[1];
			return 1;
		}
		cookiejar += 2;
	} while (cookiejar[-2]);

	return 0;
}


int
main (void)
{
	int workin[] = {1,1,1,1,1,1,1,1,1,1,2};
	int workout[57];
	int vdihandle;
	long sndcookie;

	appl_init ();

	register_aes ();

	if (!get_cookie ('_SND', &sndcookie) ||
		!(sndcookie & 2))
	{
		form_alert (1, "[1][Kein DMA-Sound!][ OK ]");
		appl_exit ();
		return 1;
	}

	vdihandle = graf_handle (workout, workout,
		workout, workout);
	v_opnvwk (workin, &vdihandle, workout);

	if (!vdihandle) {
		form_alert (1, "[1][ Konnte Workstation|"
			"nicht ”ffnen!][ OK ]");
		appl_exit ();
		return 1;
	}

	/* Wenn es 'grn' gibt, wird es auch benutzt */
	if (workout[13] >= GREEN) colors[0] = GREEN;

	init_table ();

	if (_app)
	{
		int ret;
				
		ret = do_events (vdihandle);

		v_clsvwk (vdihandle);
		appl_exit ();
		return ret;
	}
	else
	{
		while (1)
			do_events (vdihandle);
	}
}
