/*
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation; either version 2, or (at your option) any
 * later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 */

#include <mint/osbind.h>
#include <mint/falcon.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ct60.h"
#include "rfb.h"
#define XK_LATIN1
#include "keysym.h"

#ifndef Vsetscreen
#ifdef VsetScreen
#define Vsetscreen VsetScreen
#else
#warning Bad falcon.h
#endif
#endif

#ifndef Vsetmode
#ifdef VsetMode
#define Vsetmode VsetMode
#else
#warning Bad falcon.h
#endif
#endif

#define VNC_PORT 5900
#define BLOCKLENGTH 32
#define TIME_INTERVAL 10000 // uS

#define MAX_VALUE_LOOKUP 0x90 
#define MAX_VALUE_ATARI  0x75

#define NUM_LOCK    0x53
#define CAPS_LOCK   0x39
#define SCROLL_LOCK 0x47

#define PF_EQ(x,y)                                                      \
        ((x.bitsPerPixel == y.bitsPerPixel) &&                          \
         (x.depth == y.depth) &&                                        \
         ((x.bigEndian == y.bigEndian) || (x.bitsPerPixel == 8)) &&     \
         (x.trueColour == y.trueColour) &&                              \
         (!x.trueColour || ((x.redMax == y.redMax) &&                   \
                            (x.greenMax == y.greenMax) &&               \
                            (x.blueMax == y.blueMax) &&                 \
                            (x.redShift == y.redShift) &&               \
                            (x.greenShift == y.greenShift) &&           \
                            (x.blueShift == y.blueShift))))

/* Modifier bits */
#define LEFT_CNTR		0
#define LEFT_SHIFT	1
#define LEFT_ALT		2
#define LEFT_GUI		3
#define RIGHT_CNTR	4
#define RIGHT_SHIFT	5
#define RIGHT_ALT		6
#define RIGHT_GUI		7

/* Language cookie */
#define USA 0 /* English */
#define FRG 1 /* German */
#define FRA 2 /* French */
#define UK  3 /* English */
#define SPA 4 /* Spanish */
#define ITA 5 /* Italian */
#define SWE 6 /* Swiss */
#define SWF 7 /* Swiss French */
#define SWG 8 /* Swiss German */

typedef struct
{
	long ident;
	union
	{
		long l;
		short i[2];
		char c[4];
	} v;
} COOKIE;

static unsigned char num_lock= 0;
static unsigned char caps_lock = 0;
static unsigned char scroll_lock = 0;
static unsigned char modifier = 0;
static unsigned char old_modifier = 0;
static union
{
	struct
	{
		unsigned reserved1:3;
		unsigned force_alt_shift:1;
		unsigned right_shift_host:1;
		unsigned left_shift_host:1;
		unsigned alt_host:1;
		unsigned ctrl_host:1;
		unsigned key_forced:1;
		unsigned reserved2:3;
		unsigned altgr_vnc:1;
		unsigned shift_vnc:1;
		unsigned altgr_vnc_break:1;
		unsigned shift_vnc_break:1;
	} b;
	unsigned short s;
} flags;

static void *scrbuf = NULL;
static void *vncbuf = NULL;
static void *cmpbuf = NULL;
static unsigned long *tab_65k_colors = NULL;
static rfbScreenInfoPtr vncscr;
static SCREENINFO scrinfo;
static int xmin, xmax;
static int ymin, ymax;
#ifdef COLDFIRE
void *linea000 = NULL;
#endif

void (**mousevec)(void *) = NULL;
_IOREC *iorec = NULL;
void (**ikbdvec)() = NULL;
unsigned char **keytbl;

static unsigned char vnc_kbd_to_atari_scancode[] =
{
//                         A(Q)  B     C     D
	0x00, 0x00, 0x00, 0x00, 0x1E, 0x30, 0x2E, 0x20,
// E     F     G     H     I     J     K     L
	0x12, 0x21, 0x22, 0x23, 0x17, 0x24, 0x25, 0x26,
// M(,)  N     O     P     Q(A)  R     S     T
	0x32, 0x31, 0x18, 0x19, 0x10, 0x13, 0x1F, 0x14,
// U     V     W(Z)  X     Y     Z(W)  1     2
	0x16, 0x2F, 0x11, 0x2D, 0x15, 0x2C, 0x02, 0x03,
// 3     4     5     6     7     8     9     0
	0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B,
// RET   ESC   BACK  TAB  SPACE  -())  =     [(^)
	0x1C, 0x01, 0x0E, 0x0F, 0x39, 0x0C, 0x0D, 0x1A,
// ]($)  \(*) EUR1   ;(M)  '     `     ,(;)  .(:)
	0x1B, 0x2B, 0x2B, 0x27, 0x28, 0x5B, 0x33, 0x34,
// /(!)  CAPS  F1    F2    F3    F4    F5    F6
	0x35, 0x3A, 0x3B, 0x3C, 0x3D, 0x3E, 0x3F, 0x40,
// F7    F8    F9    F10   F11   F12  PrtSc ScLoc
	0x41, 0x42, 0x43, 0x44, 0x62, 0x61, 0x49, 0x4C,
//PAUSE  INS  HOME  PgUp   DEL   END  PgDn   ->  
	0x4F, 0x52, 0x47, 0x45, 0x53, 0x55, 0x46, 0x4D,
// <-     DOWN  UP   NuLoc KP/   KP*   KP-   KP+
	0x4B, 0x50, 0x48, 0x54, 0x65, 0x66, 0x4A, 0x4E,
// ENT   KP1   KP2   KP3   KP4   KP5   KP6   KP7
	0x72, 0x6D, 0x6E, 0x6F, 0x6A, 0x6B, 0x6C, 0x67,
// KP8   KP9   KP0   KP.   ><    APP  POWER  KP=
	0x68, 0x69, 0x70, 0x71, 0x60, 0x00, 0x00, 0x00,
// F13,  F14,  F15   F16   F17   F18   F19   F20
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
// F21   F22   F23   F24  EXEC  HELP  MENU   SEL
	0x00, 0x00, 0x00, 0x00, 0x00, 0x62, 0x60, 0x00,
// STOP AGAIN  UNDO  CUT  COPY  PASTE FIND   MUTE
	0x00, 0x00, 0x61, 0x00, 0x00, 0x00, 0x00, 0x00,
//VolUp VolDn
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
//LCTRL LSHFT LALT  LGUI  RCTRL RSHFT  RALT  RGUI
	0x1D, 0x2A, 0x38, 0x56, 0x1D, 0x36, 0x38, 0x57 // virtual codes
};


static unsigned char vnc_kbd_to_atari_fr_modifier[] =
{
/* This table can change host SHIFT & ALT states for each scancode, values */
/* are in hexa : bit 7: 1 for a valid entry                                */
/*               bit 6: 1 for force CTRL                                   */
/*               bit 5: ALT, bit 4: SHIFT states for the AltGR table       */
/*               bit 3: ALT, bit 2: SHIFT states for the Shift table       */
/*               bit 1: ALT, bit 0: SHIFT states for the Unshift table     */  
//                         A(Q)  B     C     D
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
// E     F     G     H     I     J     K     L
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
// M(,)  N     O     P     Q(A)  R     S     T
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
// U     V     W(Z)  X     Y     Z(W)  1     2
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xB4,
// 3     4     5     6     7     8     9     0
	0x00, 0xB4, 0xA4, 0x94, 0x00, 0xA5, 0x84, 0xA4,
// RET   ESC   BACK  TAB  SPACE  -())  =     [(^)
	0x00, 0x00, 0x00, 0x00, 0x00, 0xA4, 0xB4, 0x00,
// ]($)  \(*)        ;(M)  '     `     ,(;)  .(:)
	0x00, 0x81, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
// /(!)  CAPS  F1    F2    F3    F4    F5    F6
	0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
// F7    F8    F9    F10   F11   F12  PrtSc ScLoc
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xAA, 0x00,
//PAUSE  INS  HOME  PgUp   DEL   END  PgDn   ->  
	0x00, 0x00, 0x00, 0x95, 0x00, 0x95, 0x95, 0x00,
// <-     DOWN  UP   NuLoc KP/   KP*   KP-   KP+
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
// ENT   KP1   KP2   KP3   KP4   KP5   KP6   KP7
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
// KP8   KP9   KP0   KP.   ><    APP  POWER  KP=
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
// F13,  F14,  F15   F16   F17   F18   F19   F20
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
// F21   F22   F23   F24  EXEC  HELP  MENU   SEL
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xBF, 0x00,
// STOP AGAIN  UNDO  CUT  COPY  PASTE FIND   MUTE
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
//VolUp VolDn
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
//LCTRL LSHFT LALT  LGUI  RCTRL RSHFT  RALT  RGUI
	0x00, 0x00, 0x00, 0xEA, 0x00, 0x00, 0x00, 0xEA
};

static unsigned char vnc_kbd_to_atari_fr_unshift[] = 
{
//                         A(Q)  B     C     D
	0x00, 0x00, 0x00, 0x00, 0x1E, 0x30, 0x2E, 0x20,
// E     F     G     H     I     J     K     L
	0x12, 0x21, 0x22, 0x23, 0x17, 0x24, 0x25, 0x26,
// M(,)  N     O     P     Q(A)  R     S     T
	0x32, 0x31, 0x18, 0x19, 0x10, 0x13, 0x1F, 0x14,
// U     V     W(Z)  X     Y     Z(W)  1     2
	0x16, 0x2F, 0x11, 0x2D, 0x15, 0x2C, 0x02, 0x03,
// 3     4     5     6     7     8     9     0
	0x04, 0x05, 0x06, 0x0D, 0x08, 0x0D, 0x0A, 0x0B,
// RET   ESC   BACK  TAB  SPACE  -())  =     [(^)
	0x1C, 0x01, 0x0E, 0x0F, 0x39, 0x0C, 0x35, 0x1A,
// ]($)  \(*)        ;(M)  '     `     ,(;)  .(:)
	0x1B, 0x1B, 0x00, 0x27, 0x28, 0x00, 0x33, 0x34,
// /(!)  CAPS  F1    F2    F3    F4    F5    F6
	0x09, 0x3A, 0x3B, 0x3C, 0x3D, 0x3E, 0x3F, 0x40,
// F7    F8    F9    F10   F11   F12  PrtSc ScLoc
	0x41, 0x42, 0x43, 0x44, 0x62, 0x61, 0x62, 0x4C,
//PAUSE  INS  HOME  PgUp   DEL   END  PgDn   ->  
	0x4F, 0x52, 0x47, 0x45, 0x53, 0x47, 0x46, 0x4D,
// <-    DOWN  UP   NuLoc  KP/   KP*   KP-   KP+
	0x4B, 0x50, 0x48, 0x00, 0x65, 0x66, 0x4A, 0x4E,
// ENT   KP1   KP2   KP3   KP4   KP5   KP6   KP7
	0x72, 0x6D, 0x6E, 0x6F, 0x6A, 0x6B, 0x6C, 0x67,
// KP8   KP9   KP0   KP.   ><    APP         KP=
	0x68, 0x69, 0x70, 0x71, 0x60, 0x00, 0x00, 0x00,
// F13,  F14,  F15   F16   F17   F18   F19   F20
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
// F21   F22   F23   F24  EXEC  HELP  MENU   SEL
	0x00, 0x00, 0x00, 0x00, 0x00, 0x62, 0x60, 0x00,
// STOP AGAIN  UNDO  CUT  COPY  PASTE FIND   MUTE
	0x00, 0x00, 0x61, 0x00, 0x00, 0x00, 0x00, 0x00,
//VolUp VolDn
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
//LCTRL LSHFT LALT  LGUI  RCTRL RSHFT  RALT  RGUI
	0x1D, 0x2A, 0x38, 0x0F, 0x1D, 0x36, 0x00, 0x0F
};

static unsigned char vnc_kbd_to_atari_fr_shift[] = 
{
/* Hexa values, 00: unused => use the Unshift table     */
/*              FF: invalid => no scancode              */
//                         A(Q)  B     C     D
	0x00, 0x00, 0x00, 0x00, 0x1E, 0x30, 0x2E, 0x20,
// E     F     G     H     I     J     K     L
	0x12, 0x21, 0x22, 0x23, 0x17, 0x24, 0x25, 0x26,
// M(,)  N     O     P     Q(A)  R     S     T
	0x32, 0x31, 0x18, 0x19, 0x10, 0x13, 0x1F, 0x14,
// U     V     W(Z)  X     Y     Z(W)  1     2
	0x16, 0x2F, 0x11, 0x2D, 0x15, 0x2C, 0x02, 0x03,
// 3     4     5     6     7     8     9     0
	0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B,
// RET   ESC   BACK  TAB  SPACE  -())  =     [(^)
	0x1C, 0x01, 0x0E, 0x0F, 0x39, 0x0C, 0x35, 0x1A,
// ]($)  \(*)        ;(M)  '     `     ,(;)  .(:)
	0x29, 0xFF, 0x00, 0x27, 0x28, 0x00, 0x33, 0x34,
// /(!)  CAPS  F1    F2    F3    F4    F5    F6
	0x07, 0x3A, 0x54, 0x55, 0x56, 0x57, 0x58, 0x59,
// F7    F8    F9    F10   F11   F12  PrtSc ScLoc
	0x5A, 0x5B, 0x5C, 0x5D, 0x62, 0x61, 0x62, 0x4C,
//PAUSE  INS  HOME  PgUp   DEL   END  PgDn   ->
	0x4F, 0x52, 0x47, 0x48, 0x53, 0x47, 0x50, 0x4D,
// <-    DOWN  UP   NuLoc  KP/   KP*   KP-   KP+
	0x4B, 0x50, 0x48, 0x00, 0x65, 0x66, 0x4A, 0x4E,
// ENT   KP1   KP2   KP3   KP4   KP5   KP6   KP7
	0x72, 0x6D, 0x6E, 0x6F, 0x6A, 0x6B, 0x6C, 0x67,
// KP8   KP9   KP0   KP.   ><    APP         KP=
	0x68, 0x69, 0x70, 0x71, 0x60, 0x00, 0x00, 0x00,
// F13,  F14,  F15   F16   F17   F18   F19   F20
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
// F21   F22   F23   F24  EXEC  HELP  MENU   SEL
	0x00, 0x00, 0x00, 0x00, 0x00, 0x62, 0x60, 0x00,
// STOP AGAIN  UNDO  CUT  COPY  PASTE FIND   MUTE
	0x00, 0x00, 0x61, 0x00, 0x00, 0x00, 0x00, 0x00,
//VolUp VolDn
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
//LCTRL LSHFT LALT  LGUI  RCTRL RSHFT  RALT  RGUI
	0x1D, 0x2A, 0x38, 0x0F, 0x1D, 0x36, 0x00, 0x0F
};

static unsigned char vnc_kbd_to_atari_fr_altgr[] =
{
/* Hexa values, 00: unused => use the Unshift table     */
/*              FF: invalid => no scancode              */
//                         A(Q)  B     C     D
	0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
// E     F     G     H     I     J     K     L
	0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
// M(,)  N     O     P     Q(A)  R     S     T
	0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
// U     V     W(Z)  X     Y     Z(W)  1     2
	0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x2B,
// 3     4     5     6     7     8     9     0
	0x2B, 0x1A, 0x1A, 0x2B, 0x29, 0x28, 0x1A, 0x2B,
// RET   ESC   BACK  TAB  SPACE  -())  =     [(^)
	0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x1B, 0x1B, 0xFF,
// ]($)  \(*)        ;(M)  '     `     ,(;)  .(:)
	0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
// /(!)  CAPS  F1    F2    F3    F4    F5    F6
	0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
// F7    F8    F9    F10   F11   F12  PrtSc ScLoc
	0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
//PAUSE  INS  HOME  PgUp   DEL   END  PgDn   ->
	0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
// <-    DOWN  UP   NuLoc  KP/   KP*   KP-   KP+
	0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x4E,
// ENT   KP1   KP2   KP3   KP4   KP5   KP6   KP7
	0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
// KP8   KP9   KP0   KP.   ><    APP         KP=
	0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
// F13,  F14,  F15   F16   F17   F18   F19   F20
	0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
// F21   F22   F23   F24  EXEC  HELP  MENU   SEL
	0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x62, 0xFF, 0xFF,
// STOP AGAIN  UNDO  CUT  COPY  PASTE FIND   MUTE
	0xFF, 0xFF, 0x61, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
//VolUp VolDn
	0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
//LCTRL LSHFT LALT  LGUI  RCTRL RSHFT  RALT  RGUI
	0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0xFF
};

static unsigned char vnc_kbd_to_atari_de_modifier[] =
{
/* This table can change host SHIFT & ALT states for each scancode, values */
/* are in hexa : bit 7: 1 for a valid entry                                */
/*               bit 6: 1 for force CTRL                                   */
/*               bit 5: ALT, bit 4: SHIFT states for the AltGR table       */
/*               bit 3: ALT, bit 2: SHIFT states for the Shift table       */
/*               bit 1: ALT, bit 0: SHIFT states for the Unshift table     */  
//                         A(Q)  B     C     D
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
// E     F     G     H     I     J     K     L
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
// M(,)  N     O     P     Q(A)  R     S     T
	0x00, 0x00, 0x00, 0x00, 0xA4, 0x00, 0x00, 0x00,
// U     V     W(Z)  X     Y     Z(W)  1     2
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
// 3     4     5     6     7     8     9     0
	0x00, 0x00, 0x00, 0x00, 0xB4, 0xA4, 0xA4, 0xB4,
// RET   ESC   BACK  TAB  SPACE  -())  =     [(^)
	0x00, 0x00, 0x00, 0x00, 0x00, 0xB4, 0x00, 0x00,
// ]($)  \(*)        ;(M)  '     `     ,(;)  .(:)
	0x00, 0x80, 0x00, 0x00, 0x00, 0x91, 0x00, 0x00,
// /(!)  CAPS  F1    F2    F3    F4    F5    F6
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
// F7    F8    F9    F10   F11   F12  PrtSc ScLoc
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
//PAUSE  INS  HOME  PgUp   DEL   END  PgDn   ->  
	0x00, 0x00, 0x00, 0x81, 0x00, 0x95, 0x81, 0x00,
// <-     DOWN  UP   NuLoc KP/   KP*   KP-   KP+
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
// ENT   KP1   KP2   KP3   KP4   KP5   KP6   KP7
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
// KP8   KP9   KP0   KP.   ><    APP  POWER  KP=
	0x00, 0x00, 0x00, 0x00, 0x94, 0x00, 0x00, 0x00,
// F13,  F14,  F15   F16   F17   F18   F19   F20
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
// F21   F22   F23   F24  EXEC  HELP  MENU   SEL
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xBF, 0x00,
// STOP AGAIN  UNDO  CUT  COPY  PASTE FIND   MUTE
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
//VolUp VolDn
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
//LCTRL LSHFT LALT  LGUI  RCTRL RSHFT  RALT  RGUI
	0x00, 0x00, 0x00, 0xEA, 0x00, 0x00, 0x00, 0xEA
};

static unsigned char vnc_kbd_to_atari_de_unshift[] =
{
//                         A(Q)  B     C     D
	0x00, 0x00, 0x00, 0x00, 0x1E, 0x30, 0x2E, 0x20,
// E     F     G     H     I     J     K     L
	0x12, 0x21, 0x22, 0x23, 0x17, 0x24, 0x25, 0x26,
// M(,)  N     O     P     Q(A)  R     S     T
	0x32, 0x31, 0x18, 0x19, 0x10, 0x13, 0x1F, 0x14,
// U     V     W(Z)  X     Y     Z(W)  1     2
	0x16, 0x2F, 0x11, 0x2D, 0x15, 0x2C, 0x02, 0x03,
// 3     4     5     6     7     8     9     0
	0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B,
// RET   ESC   BACK  TAB  SPACE  -())  =     [(^)
	0x1C, 0x01, 0x0E, 0x0F, 0x39, 0x0C, 0x0D, 0x1A,
// ]($)  \(*)        ;(M)  '     `     ,(;)  .(:)
	0x1B, 0x29, 0x00, 0x27, 0x28, 0x29, 0x33, 0x34,
// /(!)  CAPS  F1    F2    F3    F4    F5    F6
	0x35, 0x3A, 0x3B, 0x3C, 0x3D, 0x3E, 0x3F, 0x40,
// F7    F8    F9    F10   F11   F12  PrtSc ScLoc
	0x41, 0x42, 0x43, 0x44, 0x63, 0x64, 0x62, 0x50,
//PAUSE  INS  HOME  PgUp   DEL   END  PgDn   ->  
	0x61, 0x52, 0x47, 0x48, 0x53, 0x47, 0x50, 0x4D,
// <-    DOWN  UP   NuLoc  KP/   KP*   KP-   KP+
	0x4B, 0x50, 0x48, 0x54, 0x65, 0x66, 0x4A, 0x4E,
// ENT   KP1   KP2   KP3   KP4   KP5   KP6   KP7
	0x72, 0x6D, 0x6E, 0x6F, 0x6A, 0x6B, 0x6C, 0x67,
// KP8   KP9   KP0   KP.   ><    APP         KP=
	0x68, 0x69, 0x70, 0x71, 0x60, 0x00, 0x00, 0x00,
// F13,  F14,  F15   F16   F17   F18   F19   F20
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
// F21   F22   F23   F24  EXEC  HELP  MENU   SEL
	0x00, 0x00, 0x00, 0x00, 0x00, 0x62, 0x60, 0x00,
// STOP AGAIN  UNDO  CUT  COPY  PASTE FIND   MUTE
	0x00, 0x00, 0x61, 0x00, 0x00, 0x00, 0x00, 0x00,
//VolUp VolDn
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
//LCTRL LSHFT LALT  LGUI  RCTRL RSHFT  RALT  RGUI
	0x1D, 0x2A, 0x38, 0x0F, 0x1D, 0x36, 0x00, 0x0F
};

static unsigned char vnc_kbd_to_atari_de_shift[] = 
{
/* Hexa values, 00: unused => use the Unshift table     */
/*              FF: invalid => no scancode              */
//                         A(Q)  B     C     D
	0x00, 0x00, 0x00, 0x00, 0x1E, 0x30, 0x2E, 0x20,
// E     F     G     H     I     J     K     L
	0x12, 0x21, 0x22, 0x23, 0x17, 0x24, 0x25, 0x26,
// M(,)  N     O     P     Q(A)  R     S     T
	0x32, 0x31, 0x18, 0x19, 0x10, 0x13, 0x1F, 0x14,
// U     V     W(Z)  X     Y     Z(W)  1     2
	0x16, 0x2F, 0x11, 0x2D, 0x15, 0x2C, 0x02, 0x03,
// 3     4     5     6     7     8     9     0
	0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B,
// RET   ESC   BACK  TAB  SPACE  -())  =     [(^)
	0x1C, 0x01, 0x0E, 0x0F, 0x39, 0x0C, 0x0D, 0x1A,
// ]($)  \(*)        ;(M)  '     `     ,(;)  .(:)
	0x1B, 0x0D, 0x00, 0x27, 0x28, 0x34, 0x33, 0x34,
// /(!)  CAPS  F1    F2    F3    F4    F5    F6
	0x35, 0x3A, 0x54, 0x55, 0x56, 0x57, 0x58, 0x59,
// F7    F8    F9    F10   F11   F12  PrtSc ScLoc
	0x5A, 0x5B, 0x5C, 0x5D, 0x63, 0x64, 0x62, 0x50,
//PAUSE  INS  HOME  PgUp   DEL   END  PgDn   ->  
	0x61, 0x52, 0x47, 0x48, 0x53, 0x47, 0x50, 0x4D,
// <-    DOWN  UP   NuLoc  KP/   KP*   KP-   KP+
	0x4B, 0x50, 0x48, 0x54, 0x65, 0x66, 0x4A, 0x4E,
// ENT   KP1   KP2   KP3   KP4   KP5   KP6   KP7
	0x72, 0x6D, 0x6E, 0x6F, 0x6A, 0x6B, 0x6C, 0x67,
// KP8   KP9   KP0   KP.   ><    APP         KP=
	0x68, 0x69, 0x70, 0x71, 0x60, 0x00, 0x00, 0x00,
// F13,  F14,  F15   F16   F17   F18   F19   F20
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
// F21   F22   F23   F24  EXEC  HELP  MENU   SEL
	0x00, 0x00, 0x00, 0x00, 0x00, 0x62, 0x60, 0x00,
// STOP AGAIN  UNDO  CUT  COPY  PASTE FIND   MUTE
	0x00, 0x00, 0x61, 0x00, 0x00, 0x00, 0x00, 0x00,
//VolUp VolDn
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
//LCTRL LSHFT LALT  LGUI  RCTRL RSHFT  RALT  RGUI
	0x1D, 0x2A, 0x38, 0x0F, 0x1D, 0x36, 0x00, 0x0F
};

static unsigned char vnc_kbd_to_atari_de_altgr[] =
{
/* Hexa values, 00: unused => use the Unshift table     */
/*              FF: invalid => no scancode              */
//                         A(Q)  B     C     D
	0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
// E     F     G     H     I     J     K     L
	0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
// M(,)  N     O     P     Q(A)  R     S     T
	0xFF, 0xFF, 0xFF, 0xFF, 0x1A, 0xFF, 0xFF, 0xFF,
// U     V     W(Z)  X     Y     Z(W)  1     2
	0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
// 3     4     5     6     7     8     9     0
	0xFF, 0xFF, 0xFF, 0xFF, 0x27, 0x27, 0x28, 0x28,
// RET   ESC   BACK  TAB  SPACE  -())  =     [(^)
	0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x1A, 0x2B, 0xFF,
// ]($)  \(*)        ;(M)  '     `     ,(;)  .(:)
	0x2B, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
// /(!)  CAPS  F1    F2    F3    F4    F5    F6
	0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
// F7    F8    F9    F10   F11   F12  PrtSc ScLoc
	0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
//PAUSE  INS  HOME  PgUp   DEL   END  PgDn   ->
	0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
// <-    DOWN  UP   NuLoc  KP/   KP*   KP-   KP+
	0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x4E,
// ENT   KP1   KP2   KP3   KP4   KP5   KP6   KP7
	0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
// KP8   KP9   KP0   KP.   ><    APP         KP=
	0xFF, 0xFF, 0xFF, 0xFF, 0x2B, 0xFF, 0xFF, 0xFF,
// F13,  F14,  F15   F16   F17   F18   F19   F20
	0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
// F21   F22   F23   F24  EXEC  HELP  MENU   SEL
	0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x62, 0xFF, 0xFF,
// STOP AGAIN  UNDO  CUT  COPY  PASTE FIND   MUTE
	0xFF, 0xFF, 0x61, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
//VolUp VolDn
	0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
//LCTRL LSHFT LALT  LGUI  RCTRL RSHFT  RALT  RGUI
	0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0xFF
};

extern unsigned long mousexy(void);
extern void call_mousevec(unsigned char *data, void (**mousevec)(void *));
extern void call_ikbdvec(unsigned char code, _IOREC *iorec, void (**ikbdvec)());
extern int compare_block(void *frame_buffer, void *cmp_buffer, int bpp, int block_length_w, int block_length_h, int line_width);
extern void copy_block(void *vnc_buffer, void *frame_buffer, int bpp, int block_length_w, int block_length_h, int vnc_width, int line_width, unsigned long *tab_65k_colors);
extern int asm_set_ipl(int level);

COOKIE *fcookie(void)
{
	COOKIE *p;
	long stack;
	stack=Super(0L);
	p=*(COOKIE **)0x5a0;
	Super((void *)stack);
	if(!p)
		return((COOKIE *)0);
	return(p);
}

COOKIE *ncookie(COOKIE *p)
{
	if(!p->ident)
		return(0);
	return(++p);
}

COOKIE *get_cookie(long id)
{
	COOKIE *p;
	p=fcookie();
	while(p)
	{
		if(p->ident==id)
			return p;
		p=ncookie(p);
	}
	return((COOKIE *)0);
}

static long read_hz_200(void)
{
	return(*(long *)0x4ba);
}

static void vnc_kbd_send_code(unsigned char code)
{
	if((iorec != NULL) && (ikbdvec != NULL))
		call_ikbdvec(code, iorec, ikbdvec);
}

static void vnc_kbd_send_atari_scancodes(unsigned char atari_scancode, unsigned char atari_modifier, int pressed)
{
	int level;
	void *ssp = NULL;
	unsigned char **header;
	unsigned char sshift;
#define STATE_RIGHT_SHIFT 0x01
#define STATE_LEFT_SHIFT  0x02
#define STATE_CTRL        0x04
#define STATE_ALT         0x08
#define STATE_CAPSLOCK    0x10
#define _sysbase          0x4F2 // header ROM
	if(!Super(1L))
		ssp = (void *)Super(0L);
	header = (unsigned char **)*(long *)_sysbase;
	sshift = *header[9];
//	printf("atari_scancode:0x%02x, modifier:0x%02x, sshift:0x%02x, pressed:%d\r\n", atari_scancode, atari_modifier, sshift, pressed);
	level = asm_set_ipl(7); /* mask interrupts for use call_ikbdvec() */
	if(sshift & STATE_CAPSLOCK)
		vnc_kbd_send_code(0xBA);
	if(pressed && (flags.b.force_alt_shift))
	{
		flags.b.key_forced = 1;
		if(((atari_modifier & (1 << 6)) != 0) && flags.b.ctrl_host)
			vnc_kbd_send_code(0x1D); /* CTRL */
		if((atari_modifier & (1 << 0)) == 0)
		{
			if(flags.b.left_shift_host)
				vnc_kbd_send_code(0xAA); /* !LSHIFT */
			if(flags.b.right_shift_host)
				vnc_kbd_send_code(0xB6); /* !RSHIFT */
		}
		else
		{
			if(!flags.b.left_shift_host)
				vnc_kbd_send_code(0x2A); /* LSHIFT */
			if(!flags.b.right_shift_host && (atari_scancode != 0x60)) /* < */
				vnc_kbd_send_code(0x36); /* RSHIFT */
		}
		if((atari_modifier & (1 << 1)) == 0)
		{
			if(flags.b.alt_host)
				vnc_kbd_send_code(0xB8); /* !ALT */
		}
		else
		{
			if(!flags.b.alt_host)
				vnc_kbd_send_code(0x38); /* ALT */
		}
	}
	if((atari_scancode != 0) && (atari_scancode <= MAX_VALUE_ATARI))
	{
		if(pressed >= 0)
			vnc_kbd_send_code(pressed ? atari_scancode : atari_scancode | 0x80);
		else /* toggle */
		{
			vnc_kbd_send_code(atari_scancode);
			vnc_kbd_send_code(atari_scancode | 0x80);
		}
	}
	if((pressed >= 0) && (flags.b.force_alt_shift))
	{
		flags.b.key_forced = 0;
		if(((atari_modifier & (1 << 6)) != 0) && flags.b.ctrl_host)
			vnc_kbd_send_code(0x9D); /* !CTRL */
		if((atari_modifier & (1 << 0)) == 0)
		{
			if(flags.b.left_shift_host)
				vnc_kbd_send_code(0x2A); /* LSHIFT */
			if(flags.b.right_shift_host)
				vnc_kbd_send_code(0x36); /* RSHIFT */
		}
		else
		{
			if(!flags.b.left_shift_host)
				vnc_kbd_send_code(0xAA); /* !LSHIFT */
			if(!flags.b.right_shift_host)
				vnc_kbd_send_code(0xB6); /* !RSHIFT */
		}
		if((atari_modifier & (1 << 1)) == 0)
		{
			if(flags.b.alt_host)
				vnc_kbd_send_code(0x38); /* ALT */
		}
		else
		{
			if(!flags.b.alt_host)
				vnc_kbd_send_code(0xB8); /* !ALT */
		}
	}
	if(sshift & STATE_CAPSLOCK)
		vnc_kbd_send_code(0x3A);
	asm_set_ipl(level);
	if(ssp != NULL)
		Super(ssp);
}

/* Translate the scancode */
static int vnc_kbd_translate(unsigned char scancode, unsigned char modifier, int pressed)
{
	unsigned char keycode = 0, atari_modifier = 0;
	int type = USA;
//	printf("KBD scancode: 0x%02x, modifier:0x%02x, pressed: %d\r\n", scancode, modifier, pressed);
	flags.b.force_alt_shift = 0;
	if(scancode > MAX_VALUE_LOOKUP)
		keycode = 0;
	else
	{
		if(scancode == 0x8A) /* LEFT ALT */
			keycode = 0x38; /* Alt Atari */
		else
		{
			unsigned char *unshift_table = NULL;
			unsigned char *shift_table = NULL;
			unsigned char *altgr_table = NULL;
			unsigned char *modifier_table = NULL;
			unsigned long lang = USA;
			COOKIE *p = get_cookie('_AKP');
			if(p != NULL)
				lang = (p->v.l >> 8) & 0xFF;
			switch(lang)
			{
				case FRA:
				case SWF:
					unshift_table = vnc_kbd_to_atari_fr_unshift;
					shift_table = vnc_kbd_to_atari_fr_shift;
					altgr_table = vnc_kbd_to_atari_fr_altgr;
					modifier_table = vnc_kbd_to_atari_fr_modifier;
					type = FRA;
	 				break;
				case FRG:
				case SWG:
					unshift_table = vnc_kbd_to_atari_de_unshift;
					shift_table = vnc_kbd_to_atari_de_shift;
					altgr_table = vnc_kbd_to_atari_de_altgr;
					modifier_table = vnc_kbd_to_atari_de_modifier;
					type = FRG;
					break;
				default:
					unshift_table = vnc_kbd_to_atari_scancode;
					break;		
			}
			if(modifier != old_modifier)
			{
				if(((modifier & (1 << LEFT_SHIFT)) != 0) || ((modifier & (1 << RIGHT_SHIFT)) != 0))
				{
					if(!flags.b.shift_vnc)
					{
						flags.b.shift_vnc = 1;
						flags.b.shift_vnc_break = 1;
					}
				}
				else
					flags.b.shift_vnc = 0;
				if((modifier & (1 << RIGHT_ALT)) != 0)
				{
					if(!flags.b.altgr_vnc)
					{
						flags.b.altgr_vnc = 1;
						flags.b.altgr_vnc_break = 1;
					}
				}
				else
					flags.b.altgr_vnc = 0;
				old_modifier = modifier;
			}
			else if(pressed)
			{
				if(!flags.b.altgr_vnc)
					flags.b.altgr_vnc_break = 0;
				if(!flags.b.shift_vnc)
					flags.b.shift_vnc_break = 0;
			}
			keycode = unshift_table[scancode];
			if((modifier & (1 << LEFT_ALT)) == 0)
			{
				/* This modifier table can change host SHIFT & ALT states for each scancode, values
				   are in hexa : bit 7: 1 for a valid entry
				                 bit 6: 1 for force CTRL
				                 bit 5: ALT, bit 4: SHIFT states for the AltGR table
				                 bit 3: ALT, bit 2: SHIFT states for the Shift table
				                 bit 1: ALT, bit 0: SHIFT states for the Unshift table
				 */  
				if(modifier_table != NULL)
					atari_modifier = modifier_table[scancode];
				else
					atari_modifier = 0;
				if((atari_modifier & (1 << 7)) != 0)
					flags.b.force_alt_shift = 1;
				else
					atari_modifier = 0;
				if(flags.b.altgr_vnc_break)
				{
					if(altgr_table[scancode])
					{
						keycode = altgr_table[scancode];
						if((atari_modifier & (1 << 6)) != 0)
							atari_modifier = (atari_modifier >> 4) | (atari_modifier & (1 << 6));
						else
							atari_modifier >>= 4;
					}
				}
			  else if(flags.b.shift_vnc_break)
			  {
					if(shift_table[scancode])
					{
						keycode = shift_table[scancode];
						if((atari_modifier & (1 << 6)) != 0)
							atari_modifier = (atari_modifier >> 2) | (atari_modifier & (1 << 6));
						else
							atari_modifier >>= 2;
					}	
				}
			}
		}
	}
//	printf("KBD atari-%s keycode:0x%02x, modifier:0x%02x, flags:0x%04x\r\n", (type == FRA) ? "fr" : (type == FRG) ? "de" : "us", keycode, atari_modifier, flags.s);
	if(keycode == 0x1D) /* CTRL */
	{
		if(pressed)
			flags.b.ctrl_host = 1;
		else
			flags.b.ctrl_host = 0;
	}
	if(keycode == 0x36) /* RSHIFT */
	{
		if(pressed)
			flags.b.right_shift_host = 1;
		else
			flags.b.right_shift_host = 0;
	}
	if(keycode == 0x2A) /* LSHIFT */
	{
		if(pressed)
			flags.b.left_shift_host = 1;
		else
			flags.b.left_shift_host = 0;
	}
	vnc_kbd_send_atari_scancodes(keycode, atari_modifier, pressed);
	if(pressed == 1)
	{
		if(scancode == NUM_LOCK)
		{
			num_lock = ~num_lock;
			return 1;
		}
		if(scancode == CAPS_LOCK)
		{
			caps_lock = ~caps_lock;
			return 1;
		}
		if(scancode == SCROLL_LOCK)
		{
			scroll_lock = ~scroll_lock;
			return 1;
		}
	}
	return 0;
}

static void keyevent(rfbBool down, rfbKeySym key, rfbClientPtr cl)
{
	int scancode = 0;
//	printf("Key event: %04x (down=%d)\n", (unsigned int)key, (int)down);
	if((key >= XK_space) && (key <= XK_ydiaeresis) && down)
	{	/* ASCII code */
		unsigned char *table_unshift = keytbl[0];
		unsigned char *table_shift = keytbl[1];
		int i, shift = 0;
		switch(key) /* ISO Latin 1 to Atari ASCII to Atari scancode */
		{
			case XK_Agrave: key = 0xB6; break;
			case XK_Aacute: key = XK_A; break;
			case XK_Acircumflex: key = XK_A; break;
			case XK_Atilde: key = 0xB7; break;
			case XK_Adiaeresis: key = 0x8E; break;
			case XK_Aring: key = 0x90; break;
			case XK_AE: key = 0x92; break;
			case XK_Ccedilla: key = 0x80; break;
			case XK_Egrave: key = XK_E; break;
			case XK_Eacute: key = 0x90; break;
			case XK_Ecircumflex: key = XK_E; break;
			case XK_Ediaeresis: key = XK_E; break;
			case XK_Igrave: key = XK_I; break;
			case XK_Iacute: key = XK_I; break;
			case XK_Icircumflex: key = XK_I; break;
			case XK_Idiaeresis: key = XK_I; break;
			case XK_ETH: key = 0; break;
			case XK_Ntilde: key = 0xA5; break;
			case XK_Ograve: key = XK_O; break;
			case XK_Oacute: key = XK_O; break;
			case XK_Ocircumflex: key = XK_O; break;
			case XK_Otilde: key = 0xB8; break;
			case XK_Odiaeresis: key = 0x99; break;
			case XK_multiply: key = 0; break;
			case XK_Ooblique: key = 0xB2; break;
			case XK_Ugrave: key = XK_U; break;
			case XK_Uacute: key = XK_U; break;
			case XK_Ucircumflex: key = XK_U; break;
			case XK_Udiaeresis: key = 0x9A; break;
			case XK_Yacute: key = 0; break;
			case XK_THORN: key = 0; break;
			case XK_ssharp: key = 0x9E; break;
			case XK_agrave: key = 0x85; break;
			case XK_aacute: key = 0xA0; break;
			case XK_acircumflex: key = 0x83; break;
			case XK_atilde: key = 0xB0; break;
			case XK_adiaeresis: key = 0x84; break;
			case XK_aring: key = 0x86; break;
			case XK_ae: key = 0x91; break;
			case XK_ccedilla: key = 0x87; break;
			case XK_egrave: key = 0x8A; break;
			case XK_eacute: key = 0x82; break;
			case XK_ecircumflex: key = 0x88; break;
			case XK_ediaeresis: key = 0x89; break;
			case XK_igrave: key = 0x8D; break;
			case XK_iacute: key = 0xA1; break;
			case XK_icircumflex: key = 0x8C; break;
			case XK_idiaeresis: key = 0x8B; break;
			case XK_eth: key = 0; break;
			case XK_ntilde: key = 0xA4; break;
			case XK_ograve: key = 0x95; break;
			case XK_oacute: key = XK_o; break;
			case XK_ocircumflex: key = 0x93; break;
			case XK_otilde: key = 0xB1; break;
			case XK_odiaeresis: key = 0x94; break;
			case XK_division: key = 0; break;
			case XK_oslash: key = 0xB3; break;
			case XK_ugrave: key = 0x97; break;
			case XK_uacute: key = 0xA3; break;
			case XK_ucircumflex: key = 0x96; break;
			case XK_udiaeresis: key = 0x81; break;
			case XK_yacute: key = XK_y; break;
			case XK_thorn: key = 0; break;
			case XK_ydiaeresis: key = 0x98; break;
		}
		for(i = 0; i < 128; i++)
		{
			if(table_unshift[i] == (unsigned char)key)
			{
				scancode = i; 
				break;
			}
		}
		if(!scancode)
		{
			for(i = 0; i < 128; i++)
			{
				if(table_shift[i] == (unsigned char)key)
				{
					scancode = i;
					shift = 1; 
					break;
				}
			}
		}
		if(scancode)
			vnc_kbd_send_atari_scancodes(scancode, (unsigned char)shift, -1);
	}
	else /* VNC scancodes to HID scancodes to Atari scancodes */
	{
		switch(key)
		{
			case XK_Return: scancode = 0x28; break;
			case XK_Escape: scancode = 0x29; break;
			case XK_BackSpace: scancode = 0x2A; break;
			case XK_Tab: scancode = 0x2B; break;
			case XK_F1: scancode = 0x3A; break;
			case XK_F2: scancode = 0x3B; break;
			case XK_F3: scancode = 0x3C; break;
			case XK_F4: scancode = 0x3D; break;
			case XK_F5: scancode = 0x3E; break;
			case XK_F6: scancode = 0x3F; break;
			case XK_F7: scancode = 0x40; break;
			case XK_F8: scancode = 0x41; break;
			case XK_F9: scancode = 0x42; break;
			case XK_F10: scancode = 0x43; break;
			case XK_F11: scancode = 0x44; break; // was rfbShutdownServer(cl->screen,TRUE);  
			case XK_F12: scancode = 0x45; break;
			/* Cursor control & motion */
			case XK_Home: scancode = 0x4A; break;
			case XK_Left: scancode = 0x50; break;
			case XK_Up: scancode = 0x52; break;
			case XK_Right: scancode = 0x4F; break;
			case XK_Page_Up: scancode = 0x4B; break;
			case XK_Page_Down: scancode = 0x4E; break;
			case XK_End: scancode = 0x59; break;     
			/* Misc Functions */
			case XK_Select: scancode = 0x77; break;
			case XK_Print: scancode = 0x46; break;
			case XK_Execute: scancode = 0x74; break;
			case XK_Insert: scancode = 0x49; break;
			case XK_Undo: scancode = 0x7A; break;
			case XK_Menu: scancode = 0x76; break;
			case XK_Find: scancode = 0x7E; break;
			case XK_Cancel: scancode = 0x9B; break;
			case XK_Help: scancode = 0x75; break;
			case XK_Break: scancode = 0x48; break;
			case XK_Num_Lock: scancode = 0x53; break;
			/* Keypad Functions, keypad numbers cleverly chosen to map to ascii */
			case XK_KP_Space: scancode = 0x2C; break;
			case XK_KP_Tab: scancode = 0x2B; break;
			case XK_KP_Enter: scancode = 0x58; break;
			case XK_KP_Home: scancode = 0x4A; break;
			case XK_KP_Left: scancode = 0x50; break;
			case XK_KP_Up: scancode = 0x52; break;
			case XK_KP_Right: scancode = 0x4F; break;
			case XK_KP_Page_Up: scancode =0x4B; break;
			case XK_KP_Page_Down: scancode = 0x4E; break;
			case XK_KP_End: scancode = 0x59; break;
			case XK_KP_Insert: scancode = 0x49; break;
			case XK_KP_Delete: scancode = 0x63; break; /* . */
			case XK_KP_Equal: scancode = 0x67; break;
			case XK_KP_Multiply: scancode = 0x55; break;
			case XK_KP_Add: scancode = 0x57; break;
			case XK_KP_Subtract: scancode = 0x56; break;
			case XK_KP_Divide: scancode = 0x54; break;
			case XK_KP_0: scancode = 0x62; break;
			case XK_KP_1: scancode = 0x59; break;
			case XK_KP_2: scancode = 0x5A; break;
			case XK_KP_3: scancode = 0x5B; break;
			case XK_KP_4: scancode = 0x5C; break;
			case XK_KP_5: scancode = 0x5D; break;
			case XK_KP_6: scancode = 0x5E; break;
			case XK_KP_7: scancode = 0x5F; break;
			case XK_KP_8: scancode = 0x60; break;
			case XK_KP_9: scancode = 0x61; break;
			/* Modifiers */
			case XK_Shift_L:
				if(down)
					modifier |= (1 << LEFT_SHIFT);
				else
					modifier &= ~(1 << LEFT_SHIFT);
				vnc_kbd_translate(0x89, modifier, (int)down);
				return;
			case XK_Shift_R:
				if(down)
					modifier |= (1 << RIGHT_SHIFT);
				else 
					modifier &= ~(1 << RIGHT_SHIFT);
				vnc_kbd_translate(0x8D, modifier, (int)down);
				return;
			case XK_Control_L:
				if(down)
					modifier |= (1 << LEFT_CNTR);
				else 
					modifier &= ~(1 << LEFT_CNTR);
				vnc_kbd_translate(0x88, modifier, (int)down);
				return;
			case XK_Control_R:
				if(down)
					modifier |= (1 << RIGHT_CNTR);
				else
					modifier &= ~(1 << RIGHT_CNTR);
				vnc_kbd_translate(0x8C, modifier, (int)down);
				return;
			case XK_Alt_L:
				if(down)
					modifier |= (1 << LEFT_ALT);
				else
					modifier &= ~(1 << LEFT_ALT);
				vnc_kbd_translate(0x8A, modifier, (int)down);
				return;
			case XK_Alt_R:
				if(down)
					modifier |= (1 << RIGHT_ALT);
				else
					modifier &= ~(1 << RIGHT_ALT);
				vnc_kbd_translate(0x8E, modifier, (int)down);
				return;
			case XK_Meta_L:
				if(down)
					modifier |= (1 << LEFT_GUI);
				else
					modifier &= ~(1 << LEFT_GUI);
				vnc_kbd_translate(0x8B, modifier, (int)down);
				return;
			case XK_Meta_R:
				if(down)
					modifier |= (1 << RIGHT_GUI); 
				else
					modifier &= ~(1 << RIGHT_GUI);
				vnc_kbd_translate(0x8F, modifier, (int)down);
				return;
			case XK_Caps_Lock: scancode = 0x39; break;
			case XK_Shift_Lock: scancode = 0x39; break;
		}
		if(scancode && down)
			vnc_kbd_translate(scancode, modifier, -1);
	}
}

static void SetXCursor(rfbScreenInfoPtr rfbScreen)
{
	int width = 16, height = 19;
	static char cursor[] =
        "                "
        " x              "
        " xx             "
        " xxx            "
        " xxxx           "
        " xxxxx          "
        " xxxxxx         "
        " xxxxxxx        "
        " xxxxxxxx       "
        " xxxxxxxxx      "
        " xxxxxxxxxx     "
        " xxxxx          "
        " xx xxx         "
        " x  xxx         "
        "     xxx        "
        "     xxx        "
        "      xxx       "
        "      xxx       "
        "                ";
	static char mask[] =
        "xx              "
        "xxx             "
        "xxxx            "
        "xxxxx           "
        "xxxxxx          "
        "xxxxxxx         "
        "xxxxxxxx        "
        "xxxxxxxxx       "
        "xxxxxxxxxx      "
        "xxxxxxxxxxx     "
        "xxxxxxxxxxxx    "
        "xxxxxxxxxx      "
        "xxxxxxxx        "
        "xxxxxxxx        "
        "xx  xxxxx       "
        "    xxxxx       "
        "     xxxxx      "
        "     xxxxx      "
        "      xxx       ";
	rfbCursorPtr c;
	c=rfbMakeXCursor(width, height, cursor, mask);
	c->xhot = c->yhot = 1;
	rfbSetCursor(rfbScreen, c);
}

static void ptrevent(int buttonMask, int x, int y, rfbClientPtr cl)
{
	static int old_buttons = 0, old_x, old_y;
	/* Indicates either pointer movement or a pointer button press or release. The pointer is
now at (x-position, y-position), and the current state of buttons 1 to 8 are represented
by bits 0 to 7 of button-mask respectively, 0 meaning up, 1 meaning down (pressed).
On a conventional mouse, buttons 1, 2 and 3 correspond to the left, middle and right
buttons on the mouse. On a wheel mouse, each step of the wheel upwards is represented
by a press and release of button 4, and each step downwards is represented by
a press and release of button 5. 
  From: http://www.vislab.usyd.edu.au/blogs/index.php/2009/05/22/an-headerless-indexed-protocol-for-input-1?blog=61 */
	if((x != old_x) || (y != old_y) || (buttonMask != old_buttons))
	{
		int level, i = 0;
		int delta_x, delta_y;
		void *ssp = NULL;
//		printf("Mouse event x: %d, y: %d, buttonMask: 0x%02x\r\n", x, y, buttonMask);
		if(!Super(1L))
			ssp = (void *)Super(0L);
		do
		{
			int old_x = (int)(mousexy() >> 16);
			int old_y = (int)(mousexy() & 0xffff);
			delta_x = x - old_x;
			delta_y = y - old_y;
			if(delta_x < -128)
				delta_x = -128;
			else if(delta_x > 127)
				delta_x = 127;
			if(delta_y < -128)
				delta_y = -128;
			else if(delta_y > 127)
				delta_y = 127;
			if(delta_x || delta_y)
			{
				static unsigned char frame[4];
				level = asm_set_ipl(7); /* mask interrupts */
				/* IKBD: B1: left, B0: right */
				frame[0] = ((old_buttons & 1) << 1) + ((old_buttons & 4) >> 2) + 0xF8;
				frame[1] = (unsigned char)delta_x;
				frame[2] = (unsigned char)delta_y;
				if(mousevec != NULL)
					call_mousevec(frame, mousevec);
				asm_set_ipl(level);
			}
			else
				break;
			i++;
		}
		while(i < 32);
		if((buttonMask ^ old_buttons) & 7)
		{
			static unsigned char frame[4];
			level = asm_set_ipl(7); /* mask interrupts */
			/* IKBD: B1: left, B0: right */
			frame[0] = ((buttonMask & 1) << 1) + ((buttonMask & 4) >> 2) + 0xF8;
			frame[1] = frame[2] = 0;
			if(mousevec != NULL)
				call_mousevec(frame, mousevec);
			asm_set_ipl(level);
		}
		if((buttonMask ^ old_buttons) & 2) /* 3rd button: middle */
		{
			if(buttonMask & 2)
			{
				level = asm_set_ipl(7); /* mask interrupts */
				vnc_kbd_send_code(0x72); /* ENTER */
				vnc_kbd_send_code(0xF2);
				asm_set_ipl(level);
			}
		}
		old_buttons = buttonMask;
		if(ssp != NULL)
			Super(ssp);
		rfbDefaultPtrAddEvent(buttonMask, x, y, cl);
	}
}

static void update_screen(void)
{

	static int old_y = 0;
	int x, y = 0;
	int blocks_updated = 0;
	int total_blocks = 0;
	int w = scrinfo.virtWidth;
	int h = scrinfo.virtHeight;
	int inc_vnc = scrinfo.virtWidth * (BLOCKLENGTH - 1);
	int bpp = scrinfo.scrPlanes / 8;
	int line_width = scrinfo.lineWrap / bpp;
	int inc_fb = line_width * (BLOCKLENGTH - 1);
	long timer = Supexec(read_hz_200);
	switch(scrinfo.scrPlanes)
	{
		case 16:
			{
				unsigned short *f = (unsigned short *)scrbuf; /* -> framebuffer         */
				unsigned short *c = (unsigned short *)cmpbuf; /* -> compare framebuffer */
				unsigned long *r = (unsigned long *)vncbuf; /* -> remote framebuffer  */
				f += (line_width * old_y);
				c += (line_width * old_y);
				r += (scrinfo.virtWidth * old_y);
				for(y = old_y; y < h; y += BLOCKLENGTH)
				{
					int y2 = y + BLOCKLENGTH;
					int block_length = BLOCKLENGTH;
					if(y2 >= h)
					{
						y2 = h;
						block_length = y2 - y;
					}
					for(x = 0; x < w; x += BLOCKLENGTH)
					{
						if(!compare_block(c, f, bpp, BLOCKLENGTH, block_length, line_width))
						{
							int x2 = x + BLOCKLENGTH;
							if(x2 >= w)
								x2 = w;
							copy_block(r, f, bpp, BLOCKLENGTH, block_length, w, line_width, tab_65k_colors);
							rfbMarkRectAsModified(vncscr, x, y, x2, y2);
							blocks_updated++;
						}
						total_blocks++;
						f += BLOCKLENGTH;
						c += BLOCKLENGTH;
						r += BLOCKLENGTH;
					}
					f += inc_fb;
					c += inc_fb;
					r += inc_vnc;
					if((blocks_updated < total_blocks) && ((Supexec(read_hz_200) - timer) >= (TIME_INTERVAL / 5000)))
					{
						y += BLOCKLENGTH;
						break;
					}
				}
			}
			break;
		case 32:
			{
				unsigned long *f = (unsigned long *)scrbuf; /* -> framebuffer         */
				unsigned long *c = (unsigned long *)cmpbuf; /* -> compare framebuffer */
				unsigned long *r = (unsigned long *)vncbuf; /* -> remote framebuffer  */
				f += (line_width * old_y);
				c += (line_width * old_y);	
				r += (scrinfo.virtWidth * old_y);
				for(y = old_y; y < h; y += BLOCKLENGTH)
				{
					int y2 = y + BLOCKLENGTH;
					int block_length = BLOCKLENGTH;
					if(y2 >= h)
					{
						y2 = h;
						block_length = y2 - y;
					}
					for(x = 0; x < w; x += BLOCKLENGTH)
					{
						if(!compare_block(c, f, bpp, BLOCKLENGTH, block_length, line_width))
						{
							int x2 = x + BLOCKLENGTH;
							if(x2 >= w)
								x2 = w;
							copy_block(r, f, bpp, BLOCKLENGTH, block_length, w, line_width, NULL);
							rfbMarkRectAsModified(vncscr, x, y, x2, y2);
							blocks_updated++;
						}
						total_blocks++;
						f += BLOCKLENGTH;
						c += BLOCKLENGTH;
						r += BLOCKLENGTH;
					}
					f += inc_fb;
					c += inc_fb;
					r += inc_vnc;
					if((blocks_updated < total_blocks) && ((Supexec(read_hz_200) - timer) >= (TIME_INTERVAL / 5000)))
					{
						y += BLOCKLENGTH;
						break;
					}
				}
			}
			break;
	}
	if(y >= h)
		y = 0;
	old_y = y;
//	if(blocks_updated)
//		printf("update_screen at %d%% in %ld mS\r\n", (blocks_updated * 100) / total_blocks, (Supexec(read_hz_200) - timer) * 5);
}

int main(int argc, char **argv)
{
	_KBDVECS *kbdvecs = (_KBDVECS *)Kbdvbase();
	void **kbdvecs2 = (void **)kbdvecs;
	COOKIE *p = get_cookie('_VDO');
	if(p->v.l < 0x30000)
	{
		printf("This program need a Falcon or better!\r\n");
		return;
	}
#ifdef COLDFIRE
	p = get_cookie('A000');
	if(p->v.l)
		linea000 = (void *)p->v.l;
#endif
	scrinfo.size = sizeof(SCREENINFO); /* Structure size has to be set */
	scrinfo.devID = Vsetmode(-1) & 0xFFFF;
	scrinfo.scrFlags = 0; /* status of the operation */
	Vsetscreen(-1, &scrinfo, 0x564E, CMD_GETINFO); /* Vsetscreen New */
	if(!(scrinfo.scrFlags & SCRINFO_OK))
	{
		scrinfo.size = sizeof(SCREENINFO) - 8; /* refresh & pixclock not exist on Milan */
		scrinfo.scrFlags = 0; /* status of the operation */
		Vsetscreen(-1, &scrinfo, 0x4D49, CMD_GETINFO); /* MI_MAGIC */
		if(!(scrinfo.scrFlags & SCRINFO_OK))
		{
			printf("This program can't found screen infos from Vsetscreen!\r\n");
			return;
		}
	}
	if((scrinfo.scrPlanes != 16) && (scrinfo.scrPlanes != 32))
	{
		printf("This program need 65K colors or more!\r\n");
		return;
	}
	mousevec = &kbdvecs->mousevec; 
	ikbdvec = (void (**)())&kbdvecs2[-1]; /* undocumented */
	iorec = (_IOREC *)Iorec(1);
	keytbl = (unsigned char **)Keytbl(-1, -1, -1);
	flags.s = 0;
	/* Allocate the VNC server buffer to be managed (not manipulated) by  libvncserver. */
	scrbuf = (void *)Logbase();
	/* Allocate the VNC server buffer to be managed (not manipulated) by  libvncserver. */
	vncbuf = malloc(scrinfo.virtWidth * ((scrinfo.virtHeight + (BLOCKLENGTH - 1)) & ~(BLOCKLENGTH - 1)) * sizeof(unsigned long));
	/* Allocate the comparison buffer for detecting drawing updates from frame to frame. */
	cmpbuf = malloc(scrinfo.lineWrap * ((scrinfo.virtHeight + (BLOCKLENGTH - 1)) & ~(BLOCKLENGTH - 1)));
	tab_65k_colors = malloc(65536 * sizeof(unsigned long));
	if((vncbuf != NULL) && (cmpbuf != NULL))
	{
		unsigned long *src = (unsigned long *)scrbuf;
		unsigned long *dst = (unsigned long *)cmpbuf;
		int i;
		memset(vncbuf, 0, scrinfo.virtHeight * scrinfo.virtHeight * sizeof(unsigned long));
		for(i = (scrinfo.lineWrap * scrinfo.virtHeight) / sizeof(unsigned long); i; *dst++ = ~*src++, i--);
		if(tab_65k_colors != NULL) /* faster 65k to 16M colors table */
		{
			unsigned long color = 0;
			unsigned long *p = tab_65k_colors;
			int r, g, b;
			for(r = 32; r; r--)
			{
				for(g = 64; g; g--)
				{
					for(b = 32; b; b--)
					{
						color &= 0xF8FCF8;
						*p++ = color;
						color += 0x000008;
					}
					color += 0x000400;
				}
				color += 0x080000;
			}
		}
		vncscr = rfbGetScreen(&argc, argv, scrinfo.virtWidth, scrinfo.virtHeight, 8, 3, 4);
		if(vncscr != NULL)
		{
			vncscr->desktopName = "Atari";
			vncscr->frameBuffer = (char *)vncbuf;
			vncscr->alwaysShared = TRUE;
			vncscr->httpDir = NULL;
			vncscr->port = VNC_PORT;
			vncscr->kbdAddEvent = keyevent;
			vncscr->ptrAddEvent = ptrevent;
			vncscr->serverFormat.redShift = 16;
			vncscr->serverFormat.greenShift = 8;
			vncscr->serverFormat.blueShift = 0;
			rfbLog("Initializing VNC server in %dx%dx%d, port %d\r\n", (int)scrinfo.virtWidth, (int)scrinfo.virtHeight,  (int)scrinfo.scrPlanes, (int)VNC_PORT);
			/* TO FIX better test for hardware cursor */
			if((unsigned long)scrbuf >= 0x1000000)
				SetXCursor(vncscr);
			rfbInitServer(vncscr);
			/* Mark as dirty since we haven't sent any updates at all yet. */
			rfbMarkRectAsModified(vncscr, 0, 0, scrinfo.virtWidth, scrinfo.virtHeight);
			/* Implement our own event loop to detect changes in the framebuffer. */
			while(1)
			{
				while(vncscr->clientHead == NULL)
					rfbProcessEvents(vncscr, TIME_INTERVAL);
				rfbProcessEvents(vncscr, TIME_INTERVAL);
				update_screen();
			}
		}
	}
	else
		printf("Out of memory!\r\n");
	if(tab_65k_colors != NULL)
		free(tab_65k_colors);
	if(vncbuf != NULL)
		free(vncbuf);
	if(cmpbuf != NULL)
		free(cmpbuf);
}
