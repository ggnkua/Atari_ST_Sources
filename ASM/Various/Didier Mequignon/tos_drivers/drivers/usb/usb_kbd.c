/*
 * (C) Copyright 2001
 * Denis Peter, MPL AG Switzerland
 *
 * Part of this source has been derived from the Linux USB
 * project.
 *
 * See file CREDITS for list of people who contributed to this
 * project.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston,
 * MA 02111-1307 USA
 *
 */

#include "config.h"
#include "usb.h"

#undef USB_KBD_DEBUG

#undef USE_COUNTRYCODE

#if defined(CONFIG_USB_UHCI) || defined(CONFIG_USB_OHCI) || defined(CONFIG_USB_EHCI)
#ifdef CONFIG_USB_KEYBOARD

#ifdef	USB_KBD_DEBUG
#define	USB_KBD_PRINTF(fmt,args...)	board_printf(fmt ,##args)
#else
#define USB_KBD_PRINTF(fmt,args...)
#endif

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

extern void ltoa(char *buf, long n, unsigned long base);
extern void call_ikbdvec(unsigned char code, _IOREC *iorec, void (**ikbdvec)());
extern int asm_set_ipl(int level);
#ifdef USE_COUNTRYCODE
static int usb_kbd_get_hid_desc(struct usb_device *dev);
#endif

/* under TOS Repeat keys are build by timer C so infinite (0) or 1000 is a good value */
#define REPEAT_RATE 0 // 40 /* 40msec -> 25cps */

#define MAX_VALUE_LOOKUP 0x90 
#define MAX_VALUE_ATARI  0x75

#define NUM_LOCK    0x53
#define CAPS_LOCK   0x39
#define SCROLL_LOCK 0x47

/* Modifier bits */
#define LEFT_CNTR		0
#define LEFT_SHIFT	1
#define LEFT_ALT		2
#define LEFT_GUI		3
#define RIGHT_CNTR	4
#define RIGHT_SHIFT	5
#define RIGHT_ALT		6
#define RIGHT_GUI		7

/* HID bCountryCode */
#define CC_NOT 0
#define CC_ISO 13
#define CC_USA 33
#define CC_FRG 9
#define CC_FRA 8
#define CC_UK  32
#define CC_SPA 25
#define CC_ITA 14
#define CC_SWE 29
#define CC_SWF 27
#define CC_SWG 28

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

extern _IOREC *iorec;
extern void (**ikbdvec)();

static unsigned char *new;
static unsigned char old[8];
static unsigned char num_lock;
static unsigned char caps_lock;
static unsigned char scroll_lock;
static unsigned char old_modifier;
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
		unsigned altgr_usb:1;
		unsigned shift_usb:1;
		unsigned altgr_usb_break:1;
		unsigned shift_usb_break:1;
	} b;
	unsigned short s;		
} flags;

#ifdef USE_COUNTRYCODE
struct usb_hid_descriptor
{
	unsigned char  bLength;
	unsigned char  bDescriptorType; /* 0x21 for HID */
	unsigned short bcdHID; /* release number */
	unsigned char  bCountryCode;
	unsigned char  bNumDescriptors;
	unsigned char  bReportDescriptorType;
	unsigned short wDescriptorLength;
} __attribute__ ((packed));

static struct usb_hid_descriptor usb_kbd_hid_desc;
#endif

static unsigned char *leds;
static int kbd_installed;

static unsigned char usb_kbd_to_atari_scancode[] =
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
	0x1B, 0x2B, 0x00, 0x27, 0x28, 0x5B, 0x33, 0x34,
// /(!)  CAPS  F1    F2    F3    F4    F5    F6
	0x35, 0x3A, 0x3B, 0x3C, 0x3D, 0x3E, 0x3F, 0x40,
// F7    F8    F9    F10   F11   F12  PrtSc ScLoc
	0x41, 0x42, 0x43, 0x44, 0x62, 0x61, 0x49, 0x4C,
//PAUSE  INS  HOME  PgUp   DEL   END  PgDn   ->  
	0x4F, 0x52, 0x47, 0x45, 0x53, 0x55, 0x46, 0x4D,
// <-	   DOWN  UP   NuLoc KP/   KP*   KP-   KP+
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
	0x1D, 0x2A, 0x38, 0x56,	0x1D, 0x36, 0x38, 0x57 // virtual codes
};

static unsigned char usb_kbd_to_atari_fr_modifier[] =
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
// <-	   DOWN  UP   NuLoc KP/   KP*   KP-   KP+
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

static unsigned char usb_kbd_to_atari_fr_unshift[] = 
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
// <-	   DOWN  UP   NuLoc  KP/   KP*   KP-   KP+
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
	0x1D, 0x2A, 0x38, 0x0F,	0x1D, 0x36, 0x00, 0x0F
};

static unsigned char usb_kbd_to_atari_fr_shift[] = 
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
// <-	   DOWN  UP   NuLoc  KP/   KP*   KP-   KP+
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
	0x1D, 0x2A, 0x38, 0x0F,	0x1D, 0x36, 0x00, 0x0F
};

static unsigned char usb_kbd_to_atari_fr_altgr[] =
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
// <-	   DOWN  UP   NuLoc  KP/   KP*   KP-   KP+
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
	0x00, 0x00, 0x00, 0xFF,	0x00, 0x00, 0x00, 0xFF
};

static unsigned char usb_kbd_to_atari_de_modifier[] =
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
// <-	   DOWN  UP   NuLoc KP/   KP*   KP-   KP+
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

static unsigned char usb_kbd_to_atari_de_unshift[] =
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
// <-	   DOWN  UP   NuLoc  KP/   KP*   KP-   KP+
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
	0x1D, 0x2A, 0x38, 0x0F,	0x1D, 0x36, 0x00, 0x0F
};

static unsigned char usb_kbd_to_atari_de_shift[] = 
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
// <-	   DOWN  UP   NuLoc  KP/   KP*   KP-   KP+
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
	0x1D, 0x2A, 0x38, 0x0F,	0x1D, 0x36, 0x00, 0x0F
};

static unsigned char usb_kbd_to_atari_de_altgr[] =
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
// <-	   DOWN  UP   NuLoc  KP/   KP*   KP-   KP+
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
	0x00, 0x00, 0x00, 0xFF,	0x00, 0x00, 0x00, 0xFF
};

static COOKIE *get_cookie(long id)
{
	COOKIE *p= *(COOKIE **)0x5a0;
	while(p)
	{
		if(p->ident == id)
			return(p);
		if(!p->ident)
			return((COOKIE *)0);
		p++;
	}
	return((COOKIE *)0);
}

static void *memscan(void *addr, int c, int size)
{
	unsigned char *p = (unsigned char *)addr;
	while(size)
	{
		if(*p == (char)c)
			return(void *)p;
		p++;
		size--;
	}
	return(void *)p;
}

/* forward declaration */
static int usb_kbd_probe(struct usb_device *dev, unsigned int ifnum);

/* deregistering the keyboard */
int usb_kbd_deregister(struct usb_device *dev)
{
	dev->irq_handle = NULL;
	if(new != NULL)
	{
		usb_free(new);
		new = NULL;
	}
	if(leds != NULL)
	{
		usb_free(leds);
		leds = NULL;
	}
	kbd_installed = 0;
	USB_KBD_PRINTF("USB KBD deregister\r\n");
	return 1;
}

/* registering the keyboard */
int usb_kbd_register(struct usb_device *dev)
{
	if(!kbd_installed && (dev->devnum != -1) && (usb_kbd_probe(dev, 0) == 1))
	{ /* Ok, we found a keyboard */
		USB_KBD_PRINTF("USB KBD found (iorec: 0x%x, USB: %d, devnum: %d)\r\n", iorec, dev->usbnum, dev->devnum);
		num_lock = caps_lock = scroll_lock = old_modifier = 0;
		flags.s = 0;
		kbd_installed = 1;
		dev->deregister = usb_kbd_deregister;
		return 1;
	}
	/* no USB Keyboard found */
	return -1;
}

/* search for keyboard and register it if found */
int drv_usb_kbd_init(void)
{
	int i, j;
	if(kbd_installed)
		return -1;
	/* scan all USB Devices */
	for(j = 0; j < USB_MAX_BUS; j++)
	{
		for(i = 0; i < USB_MAX_DEVICE; i++)
		{
			struct usb_device *dev = usb_get_dev_index(i, j); /* get device */
			if(dev == NULL)
				break;
			if(usb_kbd_register(dev) > 0)
				return 1;
		}
	}
	/* no USB Keyboard found */
	return -1;
}

/**************************************************************************
 * Low Level drivers
 */

/* set the LEDs. Since this is used in the irq routine, the control job
   is issued with a timeout of 0. This means, that the job is queued without
   waiting for job completion */

static void usb_kbd_setled(struct usb_device *dev)
{
	struct usb_interface_descriptor *iface = &dev->config.if_desc[0];
	unsigned char *pleds = (unsigned char *)(((unsigned long)leds + 3) & ~3);
	if(scroll_lock != 0)
		*pleds = 4;
	else
		*pleds = 0;
	if(caps_lock != 0)
		*pleds |= 2;
	if(num_lock != 0)
		*pleds |= 1;
	usb_control_msg(dev, usb_sndctrlpipe(dev, 0),
	 USB_REQ_SET_REPORT, USB_TYPE_CLASS | USB_RECIP_INTERFACE, 0x200, iface->bInterfaceNumber, pleds, 1, 0);
}

static void usb_kbd_send_code(unsigned char code)
{
	if((iorec != NULL) && (ikbdvec != NULL))
		call_ikbdvec(code, iorec, ikbdvec);
}

/* Translate the scancode */
static int usb_kbd_translate(unsigned char scancode, unsigned char modifier, int pressed)
{
	unsigned char keycode = 0, atari_modifier = 0;
#ifdef CONFIG_USB_INTERRUPT_POLLING
	int level;
#endif
	int type = USA;
	USB_KBD_PRINTF("USB KBD scancode: 0x%02x, modifier:0x%02x, pressed: %d\r\n", scancode, modifier, pressed);
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
#ifdef USE_COUNTRYCODE
			switch(usb_kbd_hid_desc.bCountryCode)
			{
				case CC_USA: lang = USA; break;
				case CC_FRG: lang = FRG; break;
				case CC_FRA: lang = FRA; break;
				case CC_UK: lang = UK; break;
				case CC_SPA: lang = SPA; break;
				case CC_ITA: lang = ITA; break;
				case CC_SWE: lang = SWE; break;
				case CC_SWF: lang = SWF; break;
				case CC_SWG: lang = SWG; break;		
			} 
#endif
	  	switch(lang)
			{
				case FRA:
				case SWF:
					unshift_table = usb_kbd_to_atari_fr_unshift;
					shift_table = usb_kbd_to_atari_fr_shift;
					altgr_table = usb_kbd_to_atari_fr_altgr;
					modifier_table = usb_kbd_to_atari_fr_modifier;
					type = FRA;
	 	 			break;
				case FRG:
				case SWG:
					unshift_table = usb_kbd_to_atari_de_unshift;
					shift_table = usb_kbd_to_atari_de_shift;
					altgr_table = usb_kbd_to_atari_de_altgr;
					modifier_table = usb_kbd_to_atari_de_modifier;
					type = FRG;
					break;
				default:
					unshift_table = usb_kbd_to_atari_scancode;
					break;		
			}
			if(modifier != old_modifier)
			{
				if(((modifier & (1 << LEFT_SHIFT)) != 0) || ((modifier & (1 << RIGHT_SHIFT)) != 0))
				{
					if(!flags.b.shift_usb)
					{
						flags.b.shift_usb = 1;
						flags.b.shift_usb_break = 1;
					}
				}
				else
					flags.b.shift_usb = 0;
				if((modifier & (1 << RIGHT_ALT)) != 0)
				{
					if(!flags.b.altgr_usb)
					{
						flags.b.altgr_usb = 1;
						flags.b.altgr_usb_break = 1;
					}
				}
				else
					flags.b.altgr_usb = 0;
				old_modifier = modifier;
			}
			else if(pressed)
			{
				if(!flags.b.altgr_usb)
					flags.b.altgr_usb_break = 0;
				if(!flags.b.shift_usb)
					flags.b.shift_usb_break = 0;
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
				if(flags.b.altgr_usb_break)
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
			  else if(flags.b.shift_usb_break)
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
	USB_KBD_PRINTF("USB KBD atari-%s keycode:0x%02x, modifier:0x%02x, flags:0x%04x\r\n", (type == FRA) ? "fr" : (type == FRG) ? "de" : "us", keycode, atari_modifier, flags.s);
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
#ifdef CONFIG_USB_INTERRUPT_POLLING
	level = asm_set_ipl(7); /* mask interrupts for use call_ikbdvec() */
#endif
	if(pressed && (flags.b.force_alt_shift))
	{
		flags.b.key_forced = 1;
		if(((atari_modifier & (1 << 6)) != 0) && flags.b.ctrl_host)
			usb_kbd_send_code(0x1D); /* CTRL */
		if((atari_modifier & (1 << 0)) == 0)
		{
			if(flags.b.left_shift_host)
				usb_kbd_send_code(0xAA); /* !LSHIFT */
			if(flags.b.right_shift_host)
				usb_kbd_send_code(0xB6); /* !RSHIFT */
		}
		else
		{
			if(!flags.b.left_shift_host)
				usb_kbd_send_code(0x2A); /* LSHIFT */
			if(!flags.b.right_shift_host && (keycode != 0x60)) /* < */
				usb_kbd_send_code(0x36); /* RSHIFT */
		}
		if((atari_modifier & (1 << 1)) == 0)
		{
			if(flags.b.alt_host)
				usb_kbd_send_code(0xB8); /* !ALT */
		}
		else
		{
			if(!flags.b.alt_host)
				usb_kbd_send_code(0x38); /* ALT */
		}
	}
	if((keycode !=0) && (keycode <= MAX_VALUE_ATARI))
		usb_kbd_send_code(pressed ? keycode : keycode | 0x80);
	if(!pressed && (flags.b.force_alt_shift))
	{
		flags.b.key_forced = 0;
		if(((atari_modifier & (1 << 6)) != 0) && flags.b.ctrl_host)
			usb_kbd_send_code(0x9D); /* !CTRL */
		if((atari_modifier & (1 << 0)) == 0)
		{
			if(flags.b.left_shift_host)
				usb_kbd_send_code(0x2A); /* LSHIFT */
			if(flags.b.right_shift_host)
				usb_kbd_send_code(0x36); /* RSHIFT */
		}
		else
		{
			if(!flags.b.left_shift_host)
				usb_kbd_send_code(0xAA); /* !LSHIFT */
			if(!flags.b.right_shift_host)
				usb_kbd_send_code(0xB6); /* !RSHIFT */
		}
		if((atari_modifier & (1 << 1)) == 0)
		{
			if(flags.b.alt_host)
				usb_kbd_send_code(0x38); /* ALT */
		}
		else
		{
			if(!flags.b.alt_host)
				usb_kbd_send_code(0xB8); /* !ALT */
		}
	}
#ifdef CONFIG_USB_INTERRUPT_POLLING
	asm_set_ipl(level);
#endif
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

/* Interrupt service routine */
static int usb_kbd_irq(struct usb_device *dev)
{
	int i,res;
	if((dev->irq_status != 0) || (dev->irq_act_len != 8))
	{
		USB_KBD_PRINTF("USB KBD error %lX, len %d\r\n",dev->irq_status,dev->irq_act_len);
		return 1;
	}
	res = 0;
	for(i = 2; i < 8; i++)
	{
		if(old[i] > 3 && memscan(&new[2], old[i], 6) == &new[8])
		{
			res |= usb_kbd_translate(old[i], new[0], 0);
			old[0] = new[0];
		}
		if(new[i] > 3 && memscan(&old[2], new[i], 6) == &old[8])
		{
			res |= usb_kbd_translate(new[i], new[0], 1);
			old[0] = new[0];
		}
	}
	if(new[0] != old[0]) /* modifier change */
	{
		unsigned char modifier_change = new[0] ^ old[0];
		if(modifier_change & (1 << LEFT_CNTR))
			res |= usb_kbd_translate(0x88, new[0], (new[0] & (1 << LEFT_CNTR)) ? 1 : 0);
		if(modifier_change & (1 << LEFT_SHIFT))
			res |= usb_kbd_translate(0x89, new[0], (new[0] & (1 << LEFT_SHIFT)) ? 1 : 0);
 		if(modifier_change & (1 << LEFT_ALT))
			res |= usb_kbd_translate(0x8A, new[0], (new[0] & (1 << LEFT_ALT)) ? 1 : 0);
		if(modifier_change & (1 << LEFT_GUI))
			res |= usb_kbd_translate(0x8B, new[0], (new[0] & (1 << LEFT_GUI)) ? 1 : 0);
		if(modifier_change & (1 << RIGHT_CNTR))
			res |= usb_kbd_translate(0x8C, new[0], (new[0] & (1 << RIGHT_CNTR)) ? 1 : 0);
		if(modifier_change & (1 << RIGHT_SHIFT))
			res |= usb_kbd_translate(0x8D, new[0], (new[0] & (1 << RIGHT_SHIFT)) ? 1 : 0);
		if(modifier_change & (1 << RIGHT_ALT))
			res |= usb_kbd_translate(0x8E, new[0], (new[0] & (1 << RIGHT_ALT)) ? 1 : 0);
		if(modifier_change & (1 << RIGHT_GUI))
			res |= usb_kbd_translate(0x8F, new[0], (new[0] & (1 << RIGHT_GUI)) ? 1 : 0);
	}
	if(res == 1)
		usb_kbd_setled(dev);
	memcpy(&old[0], &new[0], 8);
	return 1; /* install IRQ Handler again */
}

/* probes the USB device dev for keyboard type */
static int usb_kbd_probe(struct usb_device *dev, unsigned int ifnum)
{
	struct usb_interface_descriptor *iface;
	struct usb_endpoint_descriptor *ep;
	int pipe,maxp;
	if(dev->descriptor.bNumConfigurations != 1)
		return 0;
	iface = &dev->config.if_desc[ifnum];
	if(iface->bInterfaceClass != 3)
		return 0;
	if(iface->bInterfaceSubClass != 1)
		return 0;
	if(iface->bInterfaceProtocol != 1)
		return 0;
	if(iface->bNumEndpoints != 1)
		return 0;
	ep = &iface->ep_desc[0];
	if(!(ep->bEndpointAddress & 0x80))
		return 0;
	if((ep->bmAttributes & 3) != 3)
		return 0;
	leds = (unsigned char *)usb_malloc(8);
	if(leds == NULL)
		return 0;
	new = (unsigned char *)usb_malloc(8);
	if(new == NULL)
	{
		usb_free(leds);
		new = NULL;
		return 0;
	}
	USB_KBD_PRINTF("USB KBD found set protocol...\r\n");
	/* ok, we found a USB Keyboard, install it */
#ifdef USE_COUNTRYCODE 
	if(usb_kbd_get_hid_desc(dev) < 0)
		usb_kbd_hid_desc.bCountryCode = CC_NOT;
#endif
	usb_set_protocol(dev, iface->bInterfaceNumber, 0);
	USB_KBD_PRINTF("USB KBD found set idle...\r\n");
	usb_set_idle(dev, iface->bInterfaceNumber, REPEAT_RATE, 0);
	memset(&new[0], 0, 8);
	memset(&old[0], 0, 8);
	pipe = usb_rcvintpipe(dev, ep->bEndpointAddress);
	maxp = usb_maxpacket(dev, pipe);
	dev->irq_handle = usb_kbd_irq;
	USB_KBD_PRINTF("USB KBD enable interrupt pipe (maxp: %d)...\r\n", maxp);
	usb_submit_int_msg(dev, pipe, &new[0], maxp > 8 ? 8 : maxp, ep->bInterval);
	return 1;
}

#ifdef USE_COUNTRYCODE

/*
 * We parse each description item into this structure. Short items data
 * values are expanded to 32-bit signed int, long items contain a pointer
 * into the data area.
 */

struct hid_item {
	unsigned char format;
	unsigned char size;
	unsigned char type;
	unsigned char tag;
	union {
	    unsigned char   u_8;
	    char            s_8;
	    unsigned short  u_16;
	    short           s_16;
	    unsigned long   u_32;
	    long            s_32;
	    unsigned char  *longdata;
	} data;
};

/* HID report item format */
#define HID_ITEM_FORMAT_SHORT	0
#define HID_ITEM_FORMAT_LONG	1

/* Special tag indicating long items */
#define HID_ITEM_TAG_LONG	15

#ifdef USB_KBD_DEBUG

void usb_kbd_display_hid(struct usb_hid_descriptor *hid)
{
	board_printf("USB_HID_DESC:\r\n");
	board_printf("  bLenght               0x%x\r\n",hid->bLength);
	board_printf("  bcdHID                0x%x\r\n",hid->bcdHID);
	board_printf("  bCountryCode          %d\r\n",hid->bCountryCode);
	board_printf("  bNumDescriptors       0x%x\r\n",hid->bNumDescriptors);
	board_printf("  bReportDescriptorType 0x%x\r\n",hid->bReportDescriptorType);
	board_printf("  wDescriptorLength     0x%x\r\n",hid->wDescriptorLength);
}

/*
 * Fetch a report description item from the data stream. We support long
 * items, though they are not used yet.
 */

static int fetch_item(unsigned char *start, unsigned char *end, struct hid_item *item)
{
	if((end - start) > 0)
	{
		unsigned char b = *start++;
		item->type = (b >> 2) & 3;
		item->tag  = (b >> 4) & 15;
		if(item->tag == HID_ITEM_TAG_LONG)
		{
			item->format = HID_ITEM_FORMAT_LONG;
			if((end - start) >= 2)
			{
				item->size = *start++;
				item->tag  = *start++;
				if((end - start) >= item->size)
				{
					item->data.longdata = start;
					start += item->size;
					return item->size;
				}
			}
		}
		else
		{
			item->format = HID_ITEM_FORMAT_SHORT;
			item->size = b & 3;
			switch(item->size)
			{
				case 0:
					return item->size;
				case 1:
					if((end - start) >= 1)
					{
						item->data.u_8 = *start++;
						return item->size;
					}
					break;
				case 2:
					if((end - start) >= 2)
					{
						item->data.u_16 = le16_to_cpu(*(unsigned short *)start);
						start+=2;
						return item->size;
					}
				case 3:
					item->size++;
					if((end - start) >= 4)
					{
						item->data.u_32 = le32_to_cpu(*(unsigned long *)start);
						start+=4;
						return item->size;
					}
			}
		}
	}
	return -1;
}

#endif /* USB_KBD_DEBUG */

/*
 * HID report descriptor item type (prefix bit 2,3)
 */

#define HID_ITEM_TYPE_MAIN		0
#define HID_ITEM_TYPE_GLOBAL		1
#define HID_ITEM_TYPE_LOCAL		2
#define HID_ITEM_TYPE_RESERVED		3
/*
 * HID report descriptor main item tags
 */

#define HID_MAIN_ITEM_TAG_INPUT			8
#define HID_MAIN_ITEM_TAG_OUTPUT		9
#define HID_MAIN_ITEM_TAG_FEATURE		11
#define HID_MAIN_ITEM_TAG_BEGIN_COLLECTION	10
#define HID_MAIN_ITEM_TAG_END_COLLECTION	12
/*
 * HID report descriptor main item contents
 */

#define HID_MAIN_ITEM_CONSTANT		0x001
#define HID_MAIN_ITEM_VARIABLE		0x002
#define HID_MAIN_ITEM_RELATIVE		0x004
#define HID_MAIN_ITEM_WRAP		0x008
#define HID_MAIN_ITEM_NONLINEAR		0x010
#define HID_MAIN_ITEM_NO_PREFERRED	0x020
#define HID_MAIN_ITEM_NULL_STATE	0x040
#define HID_MAIN_ITEM_VOLATILE		0x080
#define HID_MAIN_ITEM_BUFFERED_BYTE	0x100

/*
 * HID report descriptor collection item types
 */

#define HID_COLLECTION_PHYSICAL		0
#define HID_COLLECTION_APPLICATION	1
#define HID_COLLECTION_LOGICAL		2
/*
 * HID report descriptor global item tags
 */

#define HID_GLOBAL_ITEM_TAG_USAGE_PAGE		0
#define HID_GLOBAL_ITEM_TAG_LOGICAL_MINIMUM	1
#define HID_GLOBAL_ITEM_TAG_LOGICAL_MAXIMUM	2
#define HID_GLOBAL_ITEM_TAG_PHYSICAL_MINIMUM	3
#define HID_GLOBAL_ITEM_TAG_PHYSICAL_MAXIMUM	4
#define HID_GLOBAL_ITEM_TAG_UNIT_EXPONENT	5
#define HID_GLOBAL_ITEM_TAG_UNIT		6
#define HID_GLOBAL_ITEM_TAG_REPORT_SIZE		7
#define HID_GLOBAL_ITEM_TAG_REPORT_ID		8
#define HID_GLOBAL_ITEM_TAG_REPORT_COUNT	9
#define HID_GLOBAL_ITEM_TAG_PUSH		10
#define HID_GLOBAL_ITEM_TAG_POP			11

/*
 * HID report descriptor local item tags
 */

#define HID_LOCAL_ITEM_TAG_USAGE		0
#define HID_LOCAL_ITEM_TAG_USAGE_MINIMUM	1
#define HID_LOCAL_ITEM_TAG_USAGE_MAXIMUM	2
#define HID_LOCAL_ITEM_TAG_DESIGNATOR_INDEX	3
#define HID_LOCAL_ITEM_TAG_DESIGNATOR_MINIMUM	4
#define HID_LOCAL_ITEM_TAG_DESIGNATOR_MAXIMUM	5
#define HID_LOCAL_ITEM_TAG_STRING_INDEX		7
#define HID_LOCAL_ITEM_TAG_STRING_MINIMUM	8
#define HID_LOCAL_ITEM_TAG_STRING_MAXIMUM	9
#define HID_LOCAL_ITEM_TAG_DELIMITER		10

#ifdef USB_KBD_DEBUG
static void usb_kbd_show_item(struct hid_item *item)
{
	switch(item->type)
	{
		case HID_ITEM_TYPE_MAIN:
			switch(item->tag)
			{
				case HID_MAIN_ITEM_TAG_INPUT: board_printf("Main Input"); break;
				case HID_MAIN_ITEM_TAG_OUTPUT: board_printf("Main Output"); break;
				case HID_MAIN_ITEM_TAG_FEATURE: board_printf("Main Feature"); break;
				case HID_MAIN_ITEM_TAG_BEGIN_COLLECTION: board_printf("Main Begin Collection"); break;
				case HID_MAIN_ITEM_TAG_END_COLLECTION: board_printf("Main End Collection"); break;
				default: board_printf("Main reserved %d",item->tag); break;
			}
			break;
		case HID_ITEM_TYPE_GLOBAL:
			switch(item->tag)
			{
				case HID_GLOBAL_ITEM_TAG_USAGE_PAGE: board_printf("- Global Usage Page"); break;
				case HID_GLOBAL_ITEM_TAG_LOGICAL_MINIMUM: board_printf("- Global Logical Minimum"); break;
				case HID_GLOBAL_ITEM_TAG_LOGICAL_MAXIMUM: board_printf("- Global Logical Maximum"); break;
				case HID_GLOBAL_ITEM_TAG_PHYSICAL_MINIMUM: board_printf("- Global physical Minimum"); break;
				case HID_GLOBAL_ITEM_TAG_PHYSICAL_MAXIMUM: board_printf("- Global physical Maximum"); break;
				case HID_GLOBAL_ITEM_TAG_UNIT_EXPONENT: board_printf("- Global Unit Exponent"); break;
				case HID_GLOBAL_ITEM_TAG_UNIT: board_printf("- Global Unit"); break;
				case HID_GLOBAL_ITEM_TAG_REPORT_SIZE: board_printf("- Global Report Size"); break;
				case HID_GLOBAL_ITEM_TAG_REPORT_ID: board_printf("- Global Report ID"); break;
				case HID_GLOBAL_ITEM_TAG_REPORT_COUNT: board_printf("- Global Report Count"); break;
				case HID_GLOBAL_ITEM_TAG_PUSH: board_printf("- Global Push"); break;
				case HID_GLOBAL_ITEM_TAG_POP: board_printf("- Global Pop"); break;
				default: board_printf("- Global reserved %d",item->tag); break;
			}
			break;
		case HID_ITEM_TYPE_LOCAL:
			switch(item->tag)
			{
				case HID_LOCAL_ITEM_TAG_USAGE: board_printf("-- Local Usage"); break;
				case HID_LOCAL_ITEM_TAG_USAGE_MINIMUM: board_printf("-- Local Usage Minimum"); break;
				case HID_LOCAL_ITEM_TAG_USAGE_MAXIMUM: board_printf("-- Local Usage Maximum"); break;
				case HID_LOCAL_ITEM_TAG_DESIGNATOR_INDEX: board_printf("-- Local Designator Index"); break;
				case HID_LOCAL_ITEM_TAG_DESIGNATOR_MINIMUM: board_printf("-- Local Designator Minimum"); break;
				case HID_LOCAL_ITEM_TAG_DESIGNATOR_MAXIMUM: board_printf("-- Local Designator Maximum"); break;
				case HID_LOCAL_ITEM_TAG_STRING_INDEX: board_printf("-- Local String Index"); break;
				case HID_LOCAL_ITEM_TAG_STRING_MINIMUM: board_printf("-- Local String Minimum"); break;
				case HID_LOCAL_ITEM_TAG_STRING_MAXIMUM: board_printf("-- Local String Maximum"); break;
				case HID_LOCAL_ITEM_TAG_DELIMITER: board_printf("-- Local Delimiter"); break;
				default: board_printf("-- Local reserved %d",item->tag); break;
			}
			break;
		default:
			board_printf("--- reserved %d",item->type);
			break;
	}
	board_printf("  ");
	switch(item->size)
	{
		case 1: board_printf("%d",item->data.u_8); break;
		case 2: board_printf("%d",item->data.u_16); break;
		case 4: board_printf("%ld",item->data.u_32); break;
	}
	board_printf("\r\n");
}
#endif /* USB_KBD_DEBUG */

static int usb_kbd_get_hid_desc(struct usb_device *dev)
{
	unsigned char *buffer = (unsigned char *)usb_malloc(256);
	struct usb_descriptor_header *head;
	struct usb_config_descriptor *config;
	int index, len;
#ifdef USB_KBD_DEBUG
	int i;
	unsigned char *start, *end;
	struct hid_item item;
#endif
	if(buffer == NULL)
		return -1;
	if(usb_get_configuration_no(dev, &buffer[0], 0) == -1)
	{
		usb_free(buffer);
		return -1;
	}
	head = (struct usb_descriptor_header *)&buffer[0];
	if(head->bDescriptorType!=USB_DT_CONFIG)
	{
		USB_KBD_PRINTF(" ERROR: NOT USB_CONFIG_DESC %x\r\n",head->bDescriptorType);
		usb_free(buffer);
		return -1;
	}
	index = head->bLength;
	config = (struct usb_config_descriptor *)&buffer[0];
	len = le16_to_cpu(config->wTotalLength);
	/* Ok the first entry must be a configuration entry, now process the others */
	head = (struct usb_descriptor_header *)&buffer[index];
	while(index+1 < len)
	{
		if(head->bDescriptorType == USB_DT_HID)
		{
			USB_KBD_PRINTF("HID desc found\r\n");
			memcpy(&usb_kbd_hid_desc, &buffer[index],buffer[index]);
			le16_to_cpus(&usb_kbd_hid_desc.bcdHID);
			le16_to_cpus(&usb_kbd_hid_desc.wDescriptorLength);
#ifdef USB_KBD_DEBUG
			usb_kbd_display_hid(&usb_kbd_hid_desc);
#endif
			len = 0;
			break;
		}
		index += head->bLength;
		head = (struct usb_descriptor_header *)&buffer[index];
	}
	if(len > 0)
	{
		usb_free(buffer);
		return -1;
	}
#ifdef USB_KBD_DEBUG
	len = usb_kbd_hid_desc.wDescriptorLength;
	if((index = usb_get_class_descriptor(dev, 0, USB_DT_REPORT, 0, &buffer[0], len)) < 0)
	{
		USB_KBD_PRINTF("reading report descriptor failed\r\n");
		usb_free(buffer);
		return -1;
	}
	USB_KBD_PRINTF(" report descriptor (size %u, read %d)\r\n", len, index);
	start = &buffer[0];
	end = &buffer[len];
	i = 0;
	do
	{
		index = fetch_item(start, end, &item);
		i += index;
		i++;
		if(index >= 0)
			usb_kbd_show_item(&item);
		start += index;
		start++;
	}
	while(index >= 0);
#endif /* USB_KBD_DEBUG */
	usb_free(buffer);
	return 0;
}

#endif /* USE_COUNTRYCODE */

/*
	usb_get_report(dev, 0, 0, 1, &new[0], 8);
*/

#endif /* CONFIG_USB_KEYBOARD */
#endif /* CONFIG_USB_UHCI || CONFIG_USB_OHCI || CONFIG_USB_EHCI */

