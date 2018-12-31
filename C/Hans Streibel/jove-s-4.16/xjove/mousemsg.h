/***************************************************************************
 * This program is Copyright (C) 1991-1996 by C.H.Lindsey, University of   *
 * Manchester.  (X)JOVETOOL is provided to you without charge, and with no *
 * warranty.  You may give away copies of (X)JOVETOOL, including sources,  *
 * provided that this notice is included in all the files, except insofar  *
 * as a more specific copyright notices attaches to the file (x)jovetool.c *
 ***************************************************************************/

/* JoveTool/XJove Mouse Message Format
 *
 * Mouse button events become:
 *	^XmC(button-state x-col y-line font-width)
 * or (if the mouse has not moved):
 *	^XmC(button-state)
 *
 * - C is an eventcode, a single character describing what has just
 *   happened to the mouse.
 * - button-state is a decimal numeral (mostly) describing the current
 *   state of the buttons and shifts.
 * - x-col is a decimal numeral reporting the horizontal PIXEL column
 *   containing the mouse pointer.  The leftmost column is numbered 0.
 * - y-col is a decimal numeral reporting the vertical CHARACTER row
 *   containing the mouse pointer.  The top row is numbered 1.
 * - font-width is a decimal numeral reporting the width of each character
 *   in pixels (the font must be fixed pitch).  This allows the conversion
 *   of x-col to characters.
 */

/* Event Code
 *
 * Code for the current event in mouse_code (left/middle/right).
 * It is encoded as a single decimal digit, in ASCII.
 * Note: right-button events won't get passed to child, so there
 * is no need to encode the digits 10 to 14.
 * This code is intended to be used to select the desired JOVE command,
 * via the key-binding mechanism.
 *
 * 0/5/10 down
 * 1/6/11 double-click down
 * 2/7/12 triple-click down
 * 3/8/13 release
 * 4/9/14 drag with button down
 */

#define	JTEC_LEFT	0
#define	JTEC_MIDDLE	5
#define	JTEC_RIGHT	10

#define	JTEC_DOWN	0
#define	JTEC_CLICK2	1
#define	JTEC_CLICK3	2
#define	JTEC_UP		3
#define	JTEC_DRAG	4

/* Button State
 *
 * The JT_LEFT, JT_MIDDLE, and JT_RIGHT are mutually exclusive,
 * and indicate the last button that changed state.  Note that JT_RIGHT
 * will not be seen by a client program since the right button is
 * used internally for menu selection.
 *
 * JT_SHIFT and JT_CONTROL indicate the state of these shift keys
 * at the time of the event.
 *
 * JT_CLICK2 and JT_CLICK3 indicate whether a button up or button down
 * is part of a double or triple click.  Note that a multiclick down
 * might be followed by a non-multiclick up (if the release is slow).
 *
 * JT_UPEVENT and JT_DRAGEVENT together indicate what kind of event
 * just occurred: button down (neither on), button up, or a mouse
 * movement while a button was depressed.
 *
 * JT_PASTE and JT_CUT indicate whether these keys were down
 * at the time of the event.
 */

#define JT_LEFT		00001
#define JT_MIDDLE	00002
#define JT_RIGHT	00004
#define	JT_BUTMASK	(JT_LEFT | JT_MIDDLE | JT_RIGHT)

#define JT_SHIFT	00010
#define JT_CONTROL	00020
#define JT_CSMASK	(JT_SHIFT | JT_CONTROL)

#define JT_CLICK2	00040
#define JT_CLICK3	00100
#define	JT_CLICKMASK	(JT_CLICK2 | JT_CLICK3)

#define	JT_DOWNEVENT	00000
#define JT_UPEVENT	00200
#define JT_DRAGEVENT	00400
#define	JT_EVENTMASK	(JT_UPEVENT | JT_DRAGEVENT)

#define JT_PASTE	01000
#define JT_CUT		02000
#define JT_PASTEMASK	(JT_PASTE | JT_CUT)
