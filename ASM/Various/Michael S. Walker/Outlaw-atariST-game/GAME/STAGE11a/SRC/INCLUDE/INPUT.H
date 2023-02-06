/*
 * Michael S. Walker <mwalk762@mtroyal.ca>
 *	    _    _
 *       | |  | |	OUTLAW. 
 *      -| |  | |- 
 *  _    | |- | |
 *-| |   | |  | |- 	
 * |.|  -| ||/  |
 * | |-  |  ___/ 
 *-|.|   | | |
 * |  \_|| |
 *  \____  |
 *   |   | |- 
 *       | |
 *      -| |
 *       |_| Copyleft !(c) 2020 All Rights Unreserved in all Federations, including Alpha Centauris.
 */

#ifndef INPUT_H
#define INPUT_D

#include <TYPES.H>

#ifndef ON
#define ON 1
#endif /* ON */

#ifndef OFF
#define OFF 0
#endif /* OFF */

#ifndef START
#define START 0
#endif /* START*/

#define DELTA_X_STATE 1
#define DELTA_Y_STATE 2
#define FIFO_SIZE 10

#define RIGHT_CLICK_SCAN_CODE 0xf9
#define LEFT_CLICK_SCAN_CODE 0xfa
#define BOTH_CLICK_SCAN_CODE 0xfb
#define MOUSE_MOVE_SCAN_CODE 0xf8

/* scan codes */

#define ALPHA_A 0x1E
#define ALPHA_B 0x30
#define ALPHA_C 0x2E
#define ALPHA_D 0x20
#define ALPHA_E 0x12
#define ALPHA_F 0x21
#define ALPHA_G 0x22
#define ALPHA_H 0x23
#define ALPHA_I 0x17
#define ALPHA_J 0x24
#define ALPHA_K 0x25
#define ALPHA_L 0x26
#define ALPHA_M 0x32
#define ALPHA_N 0x31
#define ALPHA_O 0x18
#define ALPHA_P 0x19
#define ALPHA_Q 0x10
#define ALPHA_R 0x13
#define ALPHA_S 0x1F
#define ALPHA_T 0x14
#define ALPHA_Y 0x16
#define ALPHA_V 0x2F
#define ALPHA_W 0x11
#define ALPHA_X 0x2D
#define ALPHA_Y 0x15
#define ALPHA_Z 0x2C
#define NUMERIC_1 0x02
#define NUMERIC_2 0x03
#define NUMERIC_3 0x04
#define NUMERIC_4 0x05
#define NUMERIC_5 0x06
#define NUMERIC_6 0x07
#define NUMERIC_7 0x08
#define NUMERIC_8 0x09
#define NUMERIC_9 0x0A
#define NUMERIC_0 0x0B
#define SPACE 0x39
#define ESC 0x01
#define BS 0x0E
#define DELETE 0x53
#define RETURN 0x1C
#define TAB 0x0F
#define HELP 0x62
#define UNDO 0x61
#define INSERT 0x52
#define CLR_HOME 0x47
#define UP_ARROW 0x48
#define DN_ARROW 0x50
#define LFT_ARROW 0x4B
#define RT_ARROW 0x4D
#define NUM_PAD_0 0x70
#define NUM_PAD_1 0x6D
#define NUM_PAD_2 0x6E
#define NUM_PAD_3 0x6F
#define NUM_PAD_4 0x6A
#define NUM_PAD_5 0x6B
#define NUM_PAD_6 0x6C
#define NUM_PAD_7 0x67
#define NUM_PAD_8 0x68
#define NUM_PAD_9 0x69
#define F1 0x3B
#define F2 0x3C
#define F3 0x3D
#define F4 0x3E
#define F5 0x3F
#define F6 0x40
#define F7 0x41
#define F8 0x42
#define F9 0x43
#define F10 0x44

extern int g_delta_x; /* in INPUT.C */
extern int g_delta_y; /* in INPUT.C */
extern int g_click;   /* in INPUT.C */

void do_IKBD_ISR(void);
int ReadCharNoEcho(void);
int CheckInputStatus(void);
SCANCODE ReadScancode(void);

void FifoInit(void);
SCANCODE FifoGet(void);
void FifoPut(SCANCODE data);

extern void FlushIKBD(void);
extern void MouseOff(void);
extern void MouseOn(void);

#endif
