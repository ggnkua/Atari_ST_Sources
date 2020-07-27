/*
 keynames.h of ue/Gulam			 01/18/86

 Copyright (c) 1986 pm@Case

 This file defines ST520 keynames; the values are the ascii codes returned
 by ST BIOS.  The 'key-to-ascii' mapping set up is given in file keymap.c
*/


#define CTRL    0x0100                  /* Control flag, or'ed in       */
#define META    0x0200                  /* Meta flag, or'ed in          */
#define CTLX    0x0400                  /* ^X flag, or'ed in            */

/*	The values below are chosen with certain patterns:
	to SHIFT	add 0040
	F1-10		0201 to 0212
	keypad 0-9	0260 to 0272 (subtract -0200 to get ascii digits)
	keypad()/ *-+.cr	add 0300 to the ascii ()/ *-+.cr

	Other choices may be better, I don't know.  However, I think
	it is unwise to use numbers in the range 0000 to 0177, because
	they are regular ascii codes.

*/
#define F1	0201
#define F2	0202
#define F3	0203
#define F4	0204
#define F5	0205
#define F6      0206
#define F7	0207
#define F8	0210
#define F9	0211
#define F10	0212

#define HELP    0213
#define UNDO	0214
#define INSERT	0215
#define HOME	0216

#define UPARRO	0273
#define DNARRO	0274
#define LTARRO	0275
#define RTARRO	0276

#define	KLP	0300
#define	KRP	0301
#define	KSTAR	0302
#define	KPLUS	0303
#define	KENTER	0304
#define	KMINUS	0305
#define	KDOT	0306
#define	KSLASH	0307

#define	K0	0260
#define	K1	0261
#define	K2	0262
#define	K3	0263
#define	K4	0264
#define	K5	0265
#define	K6	0266
#define	K7	0267
#define	K8	0270
#define	K9	0271


/*
	The above are the unshifted values.  Shifted, as well as 'capslocked'
	(for only these keys) values that I use are these +0040.
*/
#define SHIFTED 0040

/* -eof- */
