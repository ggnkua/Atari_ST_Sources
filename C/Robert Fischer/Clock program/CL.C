/* Clock program, in Hurs */
/* By Robert Fischer */
/* This program is in the public domain */
#include <gemdefs.h>
#include <nobdefs.h>
#include <e_osbind.h>
#include "mclock.h"
/* --------------------------------------------------------- */
long milli;		/* Current time */
LONG ft;			/* Next clock tick where we should change, * 5 */
LONG hz;			/* ft/5 */
int hour, minute, second;	/* Current time in old style */
LONG next_second;	/* Next clock tick that will be a second */
OBJECT *box;
BOOLEAN mtime = FALSE;	/* Should we display the new kind of time? */
BOOLEAN otime = TRUE;	/* Should we display the old kind of time? */
BOOLEAN h24 = TRUE;		/* Use 24 hour format? */
int changepos = 0;			/* Position to put cursor at when changing time */
/* --------------------------------------------------------- */
/* --------------------------------------------------------- */
dial_form(d, n)	/* Does a form_dial on box d, with mode n */
register OBJECT *d;
int n;
{
int border;
	border = d->ob_spec.boxchar.thickness;
	if (border > 128) border = 256-border;
	else border = 0;
	if (border < 4) border = 4;

	form_dial(n, d->ob_x + (d->ob_width >> 1), d->ob_y + (d->ob_height >> 1),
		0, 0, d->ob_x - border, d->ob_y - border,
		d->ob_width + (border << 1), d->ob_height + (border << 1));
}
/* --------------------------------------------------------- */
choose_timekind()		/* Decide what kind of time to use */
{
	/* Draw the box */
	dial_form(box, FMD_START);
	objc_draw(box, 0, 256, 0, 0, 0, 0);

	/* Let user play */
	box[form_do(box, 0)].ob_state = NORMAL;

	/* Undraw box */
	dial_form(box, FMD_FINISH);

	/* Blank the areas that were used */
	changepos = 80;
	if (mtime) changepos = 73;
	if (otime) {
		changepos -= 9;
		if (!h24) changepos -= 3;
	}
	if (changepos == 80) changepos = 0;

	/* Set up defaults */
	mtime = (box[MTIMEON].ob_state & SELECTED);
	otime = (box[OTIMEON].ob_state & SELECTED);
	h24 = (box[H24ON].ob_state & SELECTED);

}
/* --------------------------------------------------------- */
set_time()
{
long allsec;		/* Count of seconds in the day */
BIOS_DT_REC t;
long newtime;
long diff;
	t.l = Gettime();

	/* Convert to hurs, by converting to seconds & then to hurs */
	allsec = (long)t.dt.time.hour * 3600L +
		(long)t.dt.time.minute * 60L +
		(long)t.dt.time.second * 2;

	newtime = (allsec * 1000L) / 864;
	diff = milli - newtime;
	if (diff > 3 || diff < -3) {
		milli = newtime;
		hour = t.dt.time.hour;
		minute = t.dt.time.minute;
		second = t.dt.time.second * 2;
	}
}
/* --------------------------------------------------------- */
vblank_rout()	/* This is the routine that goes around all the time */
{
extern int curpos;		/* Current position of emulated cursor */
extern conout();		/* Put a char without BIOS or Line A */
register int i;

	/* Change cursor position if requested */
	if (changepos) {
		curpos = changepos;
		while (curpos < 80) conout(' ');
		changepos = 0;
	}

	if (HZ_200 > hz) {	/* Add 1 to milli and display */
		milli++;
		ft += 864;		/* Number of fivetimes in one millihur */
		hz = ft/5;

		if (mtime) {
			/* Output current time */
			curpos = 74;
			conout((int)(milli/10000) + '0');
			conout((int)((milli/1000) % 10) + '0');
			conout('.');
			conout((int)((milli/100) % 10) + '0');
			conout((int)((milli/10) % 10) + '0');
			conout((int)((milli % 10) + '0'));
		}
	}
	if (HZ_200 > next_second) {		/* Add 1 to the second count */
		next_second += 200;
		second++;
		if (second == 60) {
			minute ++;
			second = 0;
		}
		if (minute == 60) {
			hour ++;
			minute = 0;
		}

		if (otime) {
			curpos = 72;
			if (mtime) curpos -= 7;
			if (h24) {
				conout(hour / 10 + '0');
				conout((hour % 10) + '0');
			} else {
				curpos -= 3;
				i = hour % 12;
				if (i == 0) i = 12;
				conout(i / 10 + '0');
				conout((i % 10) + '0');
			}

			conout(':');
			conout(minute / 10 + '0');
			conout((minute % 10) + '0');
			conout(':');
			conout(second / 10 + '0');
			conout((second % 10) + '0');

			if (!h24) {
				conout(' ');
				conout((hour > 11 ? 'P' : 'A'));
				conout('M');
			}
		}
	}
}
/* --------------------------------------------------------- */
main()
{
LONG usp;
int i;
int acc_handle;		/* Desk accessory's handle in Desk menu */
int msg[8];
char c[3];			/* The info read from MCLOCK.INF */

	/* Load time defaults */
	i = Fopen("MCLOCK.INF", G_READ);
	if (i > 0) {
		mtime = h24 = otime = FALSE;
		c[0] = c[1] = c[2] = 0;
		Fread(i, 3L, c);
		Fclose(i);

		for (i = 0; i < 3; i++) {
			switch (c[i]) {
				case 'O' :
				case 'o' : otime = TRUE; break;
				case 'M' :
				case 'm' : mtime = TRUE; break;
				case '2' :
				case '4' : h24 = TRUE; break;
			}
		}
	}

	/* Set up clock part */
	milli = -5;
	set_time();

	usp = Super(0);
	ft = HZ_200 * 5 + 864;
	hz = ft/5;
	next_second = HZ_200 + 200;

	/* Install interrupt routine */
	init_vt();
	for (i=0; i<8; i++) {
		if (VBLQUEUE[i] == NULL) {
			VBLQUEUE[i]=&vblank_rout;	/* install scheduler in vblank queue */
			break;
		}
	}
	Super(usp);

	if (i == 8) {
		Cconws("Trouble installing VBLANK routine for MCLOCK!\n");
		exit(-1);
	}

	/* Set the clock when GEM lets us */
	i = appl_init();

	/* Check resolution */
	if (Getrez() != HIGH_RES) {
		otime = mtime = FALSE;
	} else {	/* Set up resource */
		if (rsrc_load("MCLOCK.RSC")) {
			acc_handle = menu_register(i, "  M-Clock");
			rsrc_gaddr(0, THETREE, &box);
			box[MTIMEON + (mtime ? 0 : 1)].ob_state = SELECTED;
			box[OTIMEON + (otime ? 0 : 1)].ob_state = SELECTED;
			box[H24ON + (h24 ? 0 : 1)].ob_state = SELECTED;
			form_center(box, &i, &i, &i, &i);
		}
	}

	while (TRUE) {
		if (MU_MESAG & evnt_multi(MU_TIMER | MU_MESAG,
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
			msg, 1000, 0,
			&i, &i, &i, &i, &i, &i)) {		/* Must be a message event */
			if (msg[0] == AC_OPEN) choose_timekind();
		}

		set_time();
	}
}
/* --------------------------------------------------------- */
