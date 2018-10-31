/* 
 * This contains the key scancode => joystick flag mappings.
 * Codes below $3B are for player 0, rest (function, cursor and keypad keys)
 * are for player 1.
 * 
 * Joystick flags are jUP, jDOWN, jLEFT, jRIGHT, jBUTTON.
 * jEXIT code has to be in some key so that program can be quit!!!
 *
 * PUNSSi (C) 1995, 1997 by Eero Tamminen
 */

#include "device.h"		/* joystick flags */

volatile unsigned char InputMapping[128] = {
  0,		/* code, key on keyboard */
  /* player-0 */
  jEXIT,	/* 01, ESC */
  0,		/* 02, 1 */
  0,		/* 03, 2 */
  0,		/* 04, 3 */
  0,		/* 05, 4 */
  0,		/* 06, 5 */
  0,		/* 07, 6 */
  0,		/* 08, 7 */
  0,		/* 09, 8 */
  0,		/* 0a, 9 */
  0,		/* 0b, 0 */
  0,		/* 0c, . */
  0,		/* 0d, . */
  0,		/* 0e, BS */
  0,		/* 0f, TAB */
  jUP,		/* 10, q */
  jUP,		/* 11, w */
  jUP,		/* 12, e */
  0,		/* 13, r */
  0,		/* 14, t */
  0,		/* 15, y */
  0,		/* 16, u */
  0,		/* 17, i */
  0,		/* 18, o */
  0,		/* 19, p */
  0,		/* 1a, . */
  0,		/* 1b, . */
  0,		/* 1c, ENTER */
  0,		/* 1d, CONTROL */
  jLEFT,	/* 1e, a */
  jBUTTON,	/* 1f, s */
  jRIGHT,	/* 20, d */
  0,		/* 21, f */
  0,		/* 22, g */
  0,		/* 23, h */
  0,		/* 24, j */
  0,		/* 25, k */
  0,		/* 26, l */
  0,		/* 27, . */
  0,		/* 28, . */
  0,		/* 29, . */
  0,		/* 2a, left SHIFT */
  0,		/* 2b, . */
  jDOWN,	/* 2c, z */
  jDOWN,	/* 2d, x */
  jDOWN,	/* 2e, c */
  0,		/* 2f, v */
  0,		/* 30, b */
  0,		/* 31, n */
  0,		/* 32, m */
  0,		/* 33, . */
  0,		/* 34, . */
  0,		/* 35, . */
  0,		/* 36, right SHIFT */
  0,		/* 37, . */
  0,		/* 38, ALTERNATE */
  0,		/* 39, SPACE */
  0,		/* 3a, CAPSLOCK */
  /* player-1 */
  0,		/* 3b, F1 */
  0,		/* 3c, F2 */
  0,		/* 3d, F3 */
  0,		/* 3e, F4 */
  0,		/* 3f, F5 */
  0,		/* 40, F6 */
  0,		/* 41, F7 */
  0,		/* 42, F8 */
  0,		/* 43, F9 */
  0,		/* 44, F10 */
  0,		/* 45, . */
  0,		/* 46, . */
  0,		/* 47, CLR HOME */
  0,		/* 48, CURSOR UP */
  0,		/* 49, . */
  0,		/* 4a, KPAD - */
  0,		/* 4b, CURSOR LEFT */
  0,		/* 4c, . */
  0,		/* 4d, CURSOR RIGHT */
  0,		/* 4e, KPAD + */
  0,		/* 4f, . */
  0,		/* 50, CURSOR DOWN */
  0,		/* 51, . */
  0,		/* 52, INSERT */
  0,		/* 53, DELETE */
  0,		/* 54, . */
  0,		/* 55, . */
  0,		/* 56, . */
  0,		/* 57, . */
  0,		/* 58, . */
  0,		/* 59, . */
  0,		/* 5a, . */
  0,		/* 5b, . */
  0,		/* 5c, . */
  0,		/* 5d, . */
  0,		/* 5e, . */
  0,		/* 5f, . */
  0,		/* 60, (key next to left SHIFT) */
  jEXIT,	/* 61, UNDO */
  0,		/* 62, HELP */
  0,		/* 63, KPAD ( */
  0,		/* 64, KPAD ) */
  0,		/* 65, KPAD / */
  0,		/* 66, KPAD * */
  jUP,		/* 67, KPAD 7 */
  jUP,		/* 68, KPAD 8 */
  jUP,		/* 69, KPAD 9 */
  jLEFT,	/* 6a, KPAD 4 */
  jBUTTON,	/* 6b, KPAD 5 */
  jRIGHT,	/* 6c, KPAD 6 */
  jDOWN,	/* 6d, KPAD 1 */
  jDOWN,	/* 6e, KPAD 2 */
  jDOWN,	/* 6f, KPAD 3 */
  0,		/* 70, KPAD 0 */
  0,		/* 71, KPAD . */
  0,		/* 72, KPAD ENTER */
  0,		/* 73, . */
  0,		/* 74, . */
  0,		/* 75, . */
};

/* Above codes with 8th bit set signify key release.  Codes $76-$7f/f6-ff
 * are reserved packed headers.
 */
