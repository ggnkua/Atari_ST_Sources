/*****************************************************************************
Author     : Peter Persson (IKBD routines by Patrice Mandin)
Description: Atari Falcon-specific keyboard stuff
Version    : 0.0.1 (2006-01-07)
******************************************************************************/

#include "config.h"
#include "options.h"
#include "types.h"
#include "address.h"
#include "vmachine.h"
#include "macro.h"
#include "extern.h"
#include "memory.h"
#include "realjoy.h"
#include "display.h"
#include "kmap.h"
#include "mint/falcon.h"
#include "ikbd.h"

enum control {STICK, PADDLE, KEYPAD};
extern int keymap[103];

/* Update the current keyboard state. */
void keybdrv_update (void)
{
}

/* Is this key presssed? */
int keybdrv_pressed(int key)
{
	return Ikbd_keyboard[keymap[key]];
}

/* Defines the keyboard mappings */
void keybdrv_setmap(void)
{
  keymap[  kmapSYSREQ              ]=0;
  keymap[  kmapCAPSLOCK            ]=58;
  keymap[  kmapNUMLOCK             ]=99;
  keymap[  kmapSCROLLLOCK          ]=100;
  keymap[  kmapLEFTCTRL            ]=29;
  keymap[  kmapLEFTALT             ]=56;
  keymap[  kmapLEFTSHIFT           ]=42;
  keymap[  kmapRIGHTCTRL           ]=29;
  keymap[  kmapRIGHTALT            ]=56;
  keymap[  kmapRIGHTSHIFT          ]=54;
  keymap[  kmapESC                 ]=1;
  keymap[  kmapBACKSPACE           ]=14;
  keymap[  kmapENTER               ]=28;
  keymap[  kmapSPACE               ]=57;
  keymap[  kmapTAB                 ]=15;
  keymap[  kmapF1                  ]=59;
  keymap[  kmapF2                  ]=60;
  keymap[  kmapF3                  ]=61;
  keymap[  kmapF4                  ]=62;
  keymap[  kmapF5                  ]=63;
  keymap[  kmapF6                  ]=64;
  keymap[  kmapF7                  ]=65;
  keymap[  kmapF8                  ]=66;
  keymap[  kmapF9                  ]=67;
  keymap[  kmapF10                 ]=68;
  keymap[  kmapF11                 ]=84;
  keymap[  kmapF12                 ]=85;
  keymap[  kmapA                   ]=30;
  keymap[  kmapB                   ]=48;
  keymap[  kmapC                   ]=46;
  keymap[  kmapD                   ]=32;
  keymap[  kmapE                   ]=18;
  keymap[  kmapF                   ]=33;
  keymap[  kmapG                   ]=34;
  keymap[  kmapH                   ]=35;
  keymap[  kmapI                   ]=23;
  keymap[  kmapJ                   ]=36;
  keymap[  kmapK                   ]=37;
  keymap[  kmapL                   ]=38;
  keymap[  kmapM                   ]=50;
  keymap[  kmapN                   ]=49;
  keymap[  kmapO                   ]=24;
  keymap[  kmapP                   ]=25;
  keymap[  kmapQ                   ]=16;
  keymap[  kmapR                   ]=19;
  keymap[  kmapS                   ]=31;
  keymap[  kmapT                   ]=20;
  keymap[  kmapU                   ]=22;
  keymap[  kmapV                   ]=47;
  keymap[  kmapW                   ]=17;
  keymap[  kmapX                   ]=45;
  keymap[  kmapY                   ]=21;
  keymap[  kmapZ                   ]=44;
  keymap[  kmap1                   ]=2;
  keymap[  kmap2                   ]=3;
  keymap[  kmap3                   ]=4;
  keymap[  kmap4                   ]=5;
  keymap[  kmap5                   ]=6;
  keymap[  kmap6                   ]=7;
  keymap[  kmap7                   ]=8;
  keymap[  kmap8                   ]=9;
  keymap[  kmap9                   ]=10;
  keymap[  kmap0                   ]=11;
  keymap[  kmapMINUS               ]=0;
  keymap[  kmapEQUAL               ]=0;
  keymap[  kmapLBRACKET            ]=0;
  keymap[  kmapRBRACKET            ]=0;
  keymap[  kmapSEMICOLON           ]=0;
  keymap[  kmapTICK                ]=0;
  keymap[  kmapAPOSTROPHE          ]=0;
  keymap[  kmapBACKSLASH           ]=14;
  keymap[  kmapCOMMA               ]=0;
  keymap[  kmapPERIOD              ]=0;
  keymap[  kmapSLASH               ]=0;
  keymap[  kmapINS                 ]=82;
  keymap[  kmapDEL                 ]=83;
  keymap[  kmapHOME                ]=71;
  keymap[  kmapEND                 ]=0;
  keymap[  kmapPGUP                ]=0;
  keymap[  kmapPGDN                ]=0;
  keymap[  kmapLARROW              ]=75;
  keymap[  kmapRARROW              ]=77;
  keymap[  kmapUARROW              ]=72;
  keymap[  kmapDARROW              ]=80;
  keymap[  kmapKEYPAD0             ]=112;
  keymap[  kmapKEYPAD1             ]=109;
  keymap[  kmapKEYPAD2             ]=110;
  keymap[  kmapKEYPAD3             ]=111;
  keymap[  kmapKEYPAD4             ]=106;
  keymap[  kmapKEYPAD5             ]=107;
  keymap[  kmapKEYPAD6             ]=108;
  keymap[  kmapKEYPAD7             ]=103;
  keymap[  kmapKEYPAD8             ]=104;
  keymap[  kmapKEYPAD9             ]=105;
  keymap[  kmapKEYPADDEL           ]=0;
  keymap[  kmapKEYPADSTAR          ]=102;
  keymap[  kmapKEYPADMINUS         ]=74;
  keymap[  kmapKEYPADPLUS          ]=78;
  keymap[  kmapKEYPADENTER         ]=114;
  keymap[  kmapCTRLPRTSC           ]=0;
  keymap[  kmapSHIFTPRTSC          ]=0;
  keymap[  kmapKEYPADSLASH         ]=101;

}

/* Zeros the keyboard array, and installs event handlers. */
int keybdrv_init (void)
{
	/* Setup IKBD handling */

	memset(Ikbd_keyboard, 0, 128);
	Ikbd_mousex = Ikbd_mousey = Ikbd_mouseb = Ikbd_joystick = 0;

	Supexec(IkbdInstall);
	
	printf("Kb open...\n");
	
	return 0;
}

/* Close the keyboard and tidy up */
void keybdrv_close (void)
{
	/* Restore IKBD stuff */

	Supexec(IkbdUninstall);

	printf("Kb close...\n");

}
