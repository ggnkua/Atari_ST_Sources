/* vdikeys.h
**
** GEM VDI standard key return codes
** Copyright 1990, Atari Corporation
**
** naming conventions:
** KA_name alt keys
** KC_name control keys
** KS_name shifted keys
** K_name  key name
** K_Nname numeric keypad
**
*/

#ifndef __VDIKEYS__
#define __VDIKEYS__

/* 
** ASCII code definitons, for convenience
*/
#define NUL	'\000'	/* ^@, Null					*/
#define CTL_AT		NUL
#define SOH '\001'	/* ^A, Start Of Header		*/
#define CTL_A		SOH
#define STX '\002'	/* ^B, Start Transmit?		*/
#define CTL_B		STX
#define ETX '\003'	/* ^C, End Transmit?		*/
#define CTL_C		ETX
#define EOT '\004'	/* ^D, End Of Transmission	*/
#define CTL_D		EOT
#define ENQ '\005'	/* ^E, Enquire				*/
#define	CTL_E		EOT
#define ACK '\006'	/* ^F, Acknowledge			*/
#define CTL_F		ACK
#define BEL '\007'	/* ^G, Bell					*/
#define CTL_G		BEL
#define BS	'\010'	/* ^H, BackSpace			*/
#define CTL_H		BS
#define HT	'\011'	/* ^I, Horizontal Tab		*/
#define CTL_I		HT
#define TAB			HT
#define LF	'\012'	/* ^J, LineFeed				*/
#define CTL_J		LF
#define VT	'\013'	/* ^K, Vertical Tab			*/
#define CTL_K		VT
#define FF	'\014'	/* ^L, FormFeed				*/
#define CTL_L		FF
#define CR	'\015'	/* ^M, Carriage Return		*/
#define CTL_M		CR
#define SO	'\016'	/* ^N, Shift Out			*/
#define CTL_N		SO
#define SI	'\017'	/* ^O, Shift In				*/
#define CTL_O		SI
#define DLE	'\020'	/* ^P, Data Link Enable		*/
#define CTL_P		DLE
#define DC1	'\021'	/* ^Q, Device Control 1		*/
#define CTL_Q		DC1
#define DC2	'\022'	/* ^R, Device Control 2		*/
#define CTL_R		DC2
#define DC3	'\023'	/* ^S, Device Control 3		*/
#define CTL_S		DC3
#define DC4	'\024'	/* ^T, Device Control 1		*/
#define CTL_T		DC4
#define NAK	'\025'	/* ^U, Negative Acknowledge */
#define CTL_U		NAK
#define SYN '\026'	/* ^V, Sync					*/
#define CTL_V		SYN
#define ETB	'\027'	/* ^W, End Transmit Block?	*/
#define CTL_W		ETB
#define CAN	'\030'	/* ^X, Cancel				*/
#define CTL_X		CAN
#define EM	'\031'	/* ^Y, ???					*/
#define CTL_Y		EM
#define SUB '\032'	/* ^Z, ???					*/
#define CTL_Z		SUB
#define ESC	'\033'	/* ^[, Escape				*/
#define FS	'\034'	/* ^\, File Separator		*/
#define CTL_BSLASH	FS
#define GS	'\035'	/* ^], Group Separator		*/
#define CTL_CBRACE	GS
#define RS	'\036'	/* ^^, Record Separator		*/
#define CTL_CARET	RS
#define US	'\037'	/* ^_, ??? Separator		*/
#define CTL__		US

/* Usually the low byte of the key code is the same as the ASCII
** value of the key struck. Exceptions are listed here:
**
**							ASCII equivalents
*/
#define KC_QUOTE	0x2807 /* ^G */
#define K_BACKSPACE	0x0e08 /* ^H */
#define K_TAB		0x0f09 /* ^I */
#define KC_RETURN	0x1c0a /* ^J */
#define KC_COMMA	0x330c /* ^L */
#define K_RETURN	0x1c0d /* ^M */
#define KC_PERIOD	0x340e /* ^N */
#define KC_SLASH	0x350f /* ^O */
#define KC_0		0x0b10 /* ^P */
#define KC_1		0x0211 /* ^Q */
/* KC_2 is ^@ instead of ^R */
#define KC_3		0x0413 /* ^S */
#define KC_4		0x0514 /* ^T */
#define KC_5		0x0615 /* ^U */
/* KC_6 is ^_ instead of ^V */
#define KC_7		0x0817 /* ^W */
#define KC_8		0x0918 /* ^X */
#define KC_9		0x0a19 /* ^Y */
#define K_ESC		0x011b /* ^[ */
#define KC_COLON	0x271b /* ^[ */
#define KC_EQUAL	0x0d1d /* ^] */
#define KC_DELETE	0x531f /* ^_ */
#define KS_INSERT	0x5230 /* 0  */
#define KS_DOWN		0x5032 /* 2  */
#define KS_LEFT		0x4b34 /* 4	 */
#define KS_RIGHT	0x4d36 /* 6  */
#define KS_HOME		0x4737 /* 7  */
#define KS_UP		0x4838 /* 8  */

/*
** numeric keypad
*/
#define K_NOPAREN	0x6328
#define K_NCPAREN	0x6429
#define K_NSLASH	0x652f
#define K_NSTAR		0x662a
#define K_NMINUS	0x4a2d
#define K_NPLUS		0x4e2b
#define K_ENTER		0x720d
#define K_NPERIOD	0x712e
#define K_N0		0x7030
#define K_N1		0x6d31
#define K_N2		0x6e32
#define K_N3		0x6f33
#define K_N4		0x6a34
#define K_N5		0x6b35
#define K_N6		0x6c36
#define K_N7		0x6737
#define K_N8		0x6838
#define K_N9		0x6939
#define KC_NOPAREN	0x6308 /* ^H */
#define KC_NCPAREN	0x6409 /* ^I */
#define KC_NSLASH	0x650f /* ^O */
#define KC_NSTAR	0x660a /* ^J */
#define KC_NMINUS	0x4a1f /* ^_ */
#define KC_NPLUS	0x4e0b /* ^K */
#define KC_ENTER	0x720a /* ^J */
#define KC_NPERIOD	0x710e /* ^N */
#define KC_N0		0x7010 /* ^P */
#define KC_N1		0x6d11 /* ^Q */
#define KC_N2		0x6e00 /* ^@ */
#define KC_N3		0x6f13 /* ^S */
#define KC_N4		0x6a14 /* ^T */
#define KC_N5		0x6b15 /* ^U */
#define KC_N6		0x6c1e /* ^^ */
#define KC_N7		0x6717 /* ^W */
#define KC_N8		0x6818 /* ^X */
#define KC_N9		0x6919 /* ^Y */


/*
** Ascii 0-31 keycodes, listed here for convenience
*/
#define KC_2		0x0300
#define KC_A		0x1e01
#define KC_B		0x3002
#define KC_C		0x2e03
#define KC_D		0x2004
#define KC_E		0x1205
#define KC_F		0x2106
#define KC_G		0x2207
#define KC_H		0x2308
#define KC_I		0x1709
#define KC_J		0x240a
#define KC_K		0x250b
#define KC_L		0x260c
#define KC_M		0x320d
#define KC_N		0x310e
#define KC_O		0x180f
#define KC_P		0x1910
#define KC_Q		0x1011
#define KC_R		0x1312
#define KC_S		0x1f13
#define KC_T		0x1414
#define KC_U		0x1615
#define KC_V		0x2f16
#define KC_W		0x1117
#define KC_X		0x2d18
#define KC_Y		0x1519
#define KC_Z		0x2c1a
#define KC_OBRACE	0x1a1b
#define KC_BSLASH	0x2b1c
#define KC_CBRACE	0x1b1d
#define KC_6		0x071e
#define KC_MINUS	0x0c1f

/* null ascii codes */
#define K_ISO		0x3700	/*???*/
#define K_DEL		0x537f
#define K_BACKTAB	0x0f00	/*???*/
#define KC_TILDE	0x2900
#define KC_SPACE	0x3900

/* alt keys */
#define KA_A		0x1e00
#define KA_B		0x3000
#define KA_C		0x2e00
#define KA_D		0x1000
#define KA_E		0x1200
#define KA_F		0x2100
#define KA_G		0x2200
#define KA_H		0x2300
#define KA_I		0x1700
#define KA_J		0x2400
#define KA_K		0x2500
#define KA_L		0x2600
#define KA_M		0x3200
#define KA_N		0x3100
#define KA_O		0x1800
#define KA_P		0x1900
#define KA_Q		0x1000
#define KA_R		0x1300
#define KA_S		0x1f00
#define KA_T		0x1400
#define KA_U		0x1600
#define KA_V		0x2f00
#define KA_W		0x1100
#define KA_X		0x1d00
#define KA_Y		0x1500
#define KA_Z		0x2c00
#define KA_1		0x7800
#define KA_2		0x7900
#define KA_3		0x7a00
#define KA_4		0x7b00
#define KA_5		0x7c00
#define KA_6		0x7d00
#define KA_7		0x7e00
#define KA_8		0x7f00
#define KA_9		0x8000
#define KA_0		0x8100
#define KA_MINUS	0x8200
#define KA_EQUAL	0x8300

/* function keys */
#define K_F1		0x3b00
#define K_F2		0x3c00
#define K_F3		0x3d00
#define K_F4		0x3e00
#define K_F5		0x3f00
#define K_F6		0x4000
#define K_F7		0x4100
#define K_F8		0x4200
#define K_F9		0x4300
#define K_F10		0x4400
#define KS_F1		0x5400
#define KS_F2		0x5500
#define KS_F3		0x5600
#define KS_F4		0x5700
#define KS_F5		0x5800
#define KS_F6		0x5900
#define KS_F7		0x5a00
#define KS_F8		0x5b00
#define KS_F9		0x5c00
#define KS_F10		0x5d00

/* cursor cluster */
#define K_UNDO		0x6100
#define K_HELP		0x6200
#define K_INSERT	0x5200
#define K_HOME		0x4700
#define K_UP		0x4800
#define K_DOWN		0x5000
#define K_LEFT		0x4b00
#define K_RIGHT		0x4d00
#define KC_HOME		0x7700
#define KC_LEFT		0x7400
#define KC_RIGHT	0x7300
#define KS_INSERT	0x5230 /* 0  */
#define KS_HOME 	0x4737 /* 7  */
#define KS_UP		0x4838 /* 8  */
#define KS_DOWN 	0x5032 /* 2  */
#define KS_LEFT 	0x4b34 /* 4  */
#define KS_RIGHT 	0x4d36 /* 6  */

#endif
