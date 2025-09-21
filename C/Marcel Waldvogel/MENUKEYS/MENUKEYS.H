/***********************************************************************\
* Headerdatei fÅr MENUKEYS.C						*
*									*
* EnthÑlt die globalen Definitionen, soll also auch vom Hauptprogramm	*
* #included werden.							*
\***********************************************************************/

/*
** Die Prototypen
*/
void key_text(int mode, int keycode, char *buf);
int key_decode(unsigned int scanascii);

/*
** Die Modi bei key_text(), in Klammern steht die MindestbufferlÑnge.
*/
#define KT_SYMBOL	0	/* Mit Symbolen (8) */
#define KT_SHORT	1	/* Mit einbuchstabigen AbkÅrzungen (10) */
#define KT_LONG		2	/* Mit "lesbaren" AbkÅrzungen (17) */

/*
** Einige wichtige Scancodes
**
** Nettes Detail: Bei INSERT und AUF (nicht jedoch bei AB) gibt es
** zusÑtzlich zu SHIFT auch noch SHIFT-CONTROL, nicht jedoch CONTROL.
*/
#define ESC		0x01
#define BACKSPACE	0x0e
#define TAB		0x0f
#define RETURN		0x1c	/* ASCII != 13	-> mit CTRL	*/
#define CLRHOME		0x47	/* ASCII != 0	-> CLR		*/
#define AUF		0x48	/* ASCII != 0	-> mit SHIFT	*/
				/* ASCII < ' '	-> auch mit CTRL*/
#define LINKS		0x4b	/* ASCII != 0	-> mit SHIFT	*/
#define RECHTS		0x4d	/* ASCII != 0	-> mit SHIFT	*/
#define AB		0x50	/* ASCII != 0	-> mit SHIFT	*/
#define INSERT		0x52	/* ASCII != 0	-> mit SHIFT	*/
				/* ASCII < ' '	-> auch mit CTRL*/
#define DELETE		0x53	/* ASCII != 127	-> mit CTRL	*/
#define UNDO		0x61
#define HELP		0x62
#define ENTER		0x72	/* ASCII != 13	-> mit CTRL	*/
#define CTRLLINKS	0x73
#define CTRLRECHTS	0x74
#define CTRLHOME	0x77	/* ASCII != 0	-> mit SHIFT	*/

#define F1		0x3b
#define F2		0x3c
#define F3		0x3d
#define F4		0x3e
#define F5		0x3f
#define F6		0x40
#define F7		0x41
#define F8		0x42
#define F9		0x43
#define F10		0x44

/*
** Einige hinzugeoderte Bits
*/
#define KEY_NUM		0x0100	/* Aus dem numerischen Ziffernblock */
#define KEY_NOSCAN	0x0200	/* Taste hatte keinen Scancode */
#define KEY_SHIFT	0x0400	/* Zusammen mit Shift */
#define KEY_CTRL	0x0800	/* Zusammen mit Ctrl */
#define KEY_ALT		0x1000	/* Zusammen mit Alt */
#define KEY_SCAN	0x2000	/* Im niedrigen Byte befindet sich nicht */
/* der ASCII-Code der Taste, sondern (da die Taste keinen vernÅnftigen   */
/* ASCII-Code liefert), der Scancode bzw. ein von mir vergebener Code.   */

