/* julia:	Buttonless drawing program for children
 * phil comeau 19-sep-87
 * last edited 23-feb-89
 * Copyright 1989 Antic Publishing
 */

#include <stdio.h>
#include <portab.h>
#include <gemdefs.h>
#include <osbind.h>

#define MAXPITCH 4095			/* highest pitch value used */
#define COLORCYCLE 1000			/* controls rate that we cycle
					 * through palette
					 */
#define LOW8(w) ((w) & 0xff)		/* extract low/hi 8 bits from word */
#define HI8(w) (((w) >> 8) & 0xff)
#define CH_A_PITCH_LOW 1		/* indexes of ch A pitch values in */
#define CH_A_PITCH_HI 3			/* sound program
					 */
#define EXITKEY '\003'			/* <ctrl/C> */
#define ERASEKEY '\005'			/* <ctrl/e> */
#define PARENTKEY '\020'		/* <ctrl/p> */
#define HIDECURSOR 0			/* cursconf() function */
#define MAXCHAR ('~' - ' ')		/* # of character values */
#define CPITCH 120			/* natural note pitches */
#define DPITCH 107
#define EPITCH 95
#define FPITCH 90
#define GPITCH 80
#define APITCH 71
#define BPITCH 64

/* Globals used by VDI */
int work_in[11];
int work_out[57];
int contrl[12];
int intin[128];
int ptsin[128];
int intout[128];
int ptsout[128];

struct keyPitch {
	char c;				/* keyboard character */
	int pitch;			/* corresponding pitch */
};

/* Table of pitches corresponding to notes in the C-major scale. Rows
 * of the keyboard are mapped onto "white piano keys."
 */
struct keyPitch keyTbl[] = {
	{'z', CPITCH * 8},
	{'x', DPITCH * 8},
	{'c', EPITCH * 8},
	{'v', FPITCH * 8},
	{'b', GPITCH * 8},
	{'n', APITCH * 8},
	{'m', BPITCH * 8},
	{',', CPITCH * 4},
	{'.', DPITCH * 4},
	{'/', EPITCH * 4},
	{'a', CPITCH * 4},
	{'s', DPITCH * 4},
	{'d', EPITCH * 4},
	{'f', FPITCH * 4},
	{'g', GPITCH * 4},
	{'h', APITCH * 4},
	{'j', BPITCH * 4},
	{'k', CPITCH * 2},
	{'l', DPITCH * 2},
	{';', EPITCH * 2},
	{'\'', FPITCH * 2},
	{'q', CPITCH * 2},
	{'w', DPITCH * 2},
	{'e', EPITCH * 2},
	{'r', FPITCH * 2},
	{'t', GPITCH * 2},
	{'y', APITCH * 2},
	{'u', BPITCH * 2},
	{'i', CPITCH * 1},
	{'o', DPITCH * 1},
	{'p', EPITCH * 1},
	{'[', FPITCH * 1},
	{']', GPITCH * 1},
	{'\033', CPITCH * 1},
	{'1', DPITCH * 1},
	{'2', EPITCH * 1},
	{'3', FPITCH * 1},
	{'4', GPITCH * 1},
	{'5', APITCH * 1},
	{'6', BPITCH * 1},
	{'7', CPITCH / 2},
	{'8', DPITCH / 2},
	{'9', EPITCH / 2},
	{'0', FPITCH / 2},
	{'-', GPITCH / 2},
	{'=', APITCH / 2},
	{'`', BPITCH / 2},
	{'\b', CPITCH / 4}
};

main()
{
	int handle, x, y, lastX, lastY, junk, pxy[4], maxX, midX,
	    kbRate, i, cycle, color, openVWk(), ncolors;
	BOOLEAN done, found, parentMode;
	char c;

	appl_init();
	handle = openVWk(graf_handle(&junk, &junk, &junk, &junk));

	/* Hide the text cursor. */
	Cursconf(HIDECURSOR, 0);

	vq_mouse(handle, &junk, &lastX, &lastY);
	srand((long)(lastX * lastY));

	/* Determine screen dimensions. */
	switch (Getrez()) {
	case 0:
		maxX = 320;
		ncolors = 16;
		break;
	case 1:
		maxX = 640;
		ncolors = 4;
		break;
	case 2:
		maxX = 640;
		ncolors = 2;
		break;
	}
	midX = maxX / 2;

	/* Change the keyboard repeat characteristics so keys repeat
	 * as slowly as possible.
	 */
	kbRate = Kbrate(0xff, 0xff);

	done = parentMode = FALSE;
	cycle = 0;
	color = 1;
	while (!done) {

		/* Obtain the current mouse position. */
		vq_mouse(handle, &junk, &x, &y);

		if (x != lastX || y != lastY) {

			/* The mouse moved. Draw a line from its last
			 * location to the current location.
			 */
			v_hide_c(handle);
			pxy[0] = lastX;
			pxy[1] = lastY;
			pxy[2] = x;
			pxy[3] = y;
			v_pline(handle, 2, pxy);
			v_show_c(handle, 0);
			lastX = x;
			lastY = y;

			/* Make a sound with frequency related to x
			 * position. Note that the pitch value varies
			 * proportionally with frequency.
			 */
			makeSound((int)(MAXPITCH * (long)abs(midX - x) /
			    midX));
		}

		/* Check for character presses. */
		if (Cconis()) {
			c = Cnecin();
			if (c == EXITKEY) {
				done = TRUE;
			}
			else if (c == ERASEKEY) {
				v_clrwk(handle);
			}
			else if (c == PARENTKEY && parentMode == FALSE) {
				parentMode = TRUE;
			}
			else if (c == PARENTKEY && parentMode == TRUE) {
				parentMode = FALSE;
			}
			else if (c == ' ' && parentMode) {
				v_clrwk(handle);
			}
			else {
				/* See if the key exists in the keyboard
				 * pitch table.
				 */
				found = FALSE;
				for (i = 0; i < sizeof(keyTbl) /
				    sizeof(struct keyPitch) && !found; ++i) {
					if (keyTbl[i].c == c) {
						makeSound(keyTbl[i].pitch);
						found = TRUE;
					}
				}
				if (!found) {
					makeSound(abs(rand()) % MAXPITCH);
				}
			}
		}

		/* See if it's time to change colors. */
		if (++cycle == COLORCYCLE) {

			/* Select the next color from the palette. We'll
			 * skip color 0 because it's usually white and
			 * therefore invisible.
			 */
			color = color % (ncolors - 1) + 1;
			vsl_color(handle, color);
			cycle = 0;
		}
	}


	/* Restore the keyboard repeat rate. */
	Kbrate(HI8(kbRate), LOW8(kbRate));

	clsVWk(handle);
	appl_exit();
	exit(0);
}

/* makeSound:	Make a sound with a specified pitch. */

makeSound(pitch)
int pitch;
{
	static unsigned char sound[] = {
	    0x00, 0x00,		/* ch A pitch low */
	    0x01, 0x00,		/* ch A pitch high */
	    0x02, 0x00,		/* ch B pitch low */
	    0x03, 0x00,		/* ch B pitch high */
	    0x04, 0x00,		/* ch C pitch low */
	    0x05, 0x00,		/* ch C pitch high */
	    0x06, 0x00,		/* noise pitch */
	    0x07, 0xfe,		/* mixer: only ch A enabled */
	    0x08, 0x10,		/* ch A volume: use envelope */
	    0x09, 0x00,		/* ch B volume */
	    0x0a, 0x00,		/* ch C volume */
	    0x0b, 0x10,		/* sustain low: 10000 (base 10) */
	    0x0c, 0x27,		/* sustain high */
	    0x0d, 0x09,		/* envelope: decay and hold */
	    0xff, 0x00		/* end of sound program */
	};

	/* Write the pitch into the tone pitch registers. */
	sound[CH_A_PITCH_LOW] = LOW8(pitch);
	sound[CH_A_PITCH_HI] = HI8(pitch);
	
	/* Play the sound */

	Dosound(sound);
}

/* openVWk:	Open a virtual workstation */
int openVWk(physHandle)
int physHandle;
{
	register int i;
	int handle;

	for (i = 0; i < 10; ++i) {
		work_in[i] = 1;
	}
	work_in[i] = 2;
	handle = physHandle;
	v_opnvwk(work_in, &handle, work_out);

	return (handle);
}

/* clsVWk:	Close a virtual workstation */
clsVWk(handle)
int handle;
{
	v_clsvwk(handle);
}
