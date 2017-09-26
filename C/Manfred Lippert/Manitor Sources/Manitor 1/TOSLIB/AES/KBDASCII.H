/*----------------------------------------------------------------------------------------
	kbdascii.h, part of TOS Linker for CodeWarrior

	defines for ASCII-Codes (e.g. for evnt_keybd)
	
	10.11.1998 by Manfred Lippert

	last change: 17.11.1998

	Don't edit this file.

	If you have to make any changes on this file, please contact:
	mani@mani.de
----------------------------------------------------------------------------------------*/

#ifndef __KBD_ASCII_DEFINES__
#define __KBD_ASCII_DEFINES__

#define CTRL_A			1
#define CTRL_B			2
#define CTRL_C			3
#define CTRL_D			4
#define CTRL_E			5
#define CTRL_F			6
#define CTRL_G			7
#define CTRL_H			8
#define KBD_BACKSPACE	8	/* = CTRL_H */
#define CTRL_I			9
#define KBD_TAB			9	/* = CTRL_I */
#define CTRL_J			10
#define CTRL_K			11
#define CTRL_L			12
#define CTRL_M			13
#define KBD_RETURN		13	/* = CTRL_M */
#define CTRL_N			14
#define CTRL_O			15
#define CTRL_P			16
#define CTRL_Q			17
#define CTRL_R			18
#define CTRL_S			19
#define CTRL_T			20
#define CTRL_U			21
#define CTRL_V			22
#define CTRL_W			23
#define CTRL_X			24
#define CTRL_Y			25
#define CTRL_Z			26

#define KBD_ESC			27
#define KBD_SPACE		' '
#define KBD_DELETE		127
#define CTRL_DELETE		31	/* only if Scan-Code == 83! */

#endif
