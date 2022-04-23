/* BubbleGEM 08-beta 1998-07-19 */

#ifndef BUBBLE_H
#define BUBBLE_H

#define BUBBLEGEM_REQUEST 0xbaba
#define BUBBLEGEM_SHOW    0xbabb
#define BUBBLEGEM_ACK     0xbabc
#define BUBBLEGEM_ASKFONT 0xbabd
#define BUBBLEGEM_FONT    0xbabe
#define BUBBLEGEM_HIDE    0xbabf

#define BGS7_USRHIDE      0x0001
#define BGS7_MFDB         0x0002
#define BGS7_MOUSE        0x0004
#define BGS7_2STRINGS     0x0008
#define BGS7_REQBYDEMON   0x0010
#define BGS7_ERROR        0x8000

#define BGC_FONTCHANGED   0x0001
#define BGC_NOWINSTYLE    0x0002
#define BGC_SENDKEY       0x0004
#define BGC_DEMONACTIVE   0x0008
#define BGC_TOPONLY       0x0010
#define BGC_AUTOSTYLE     0x0020


typedef struct
{
	long   magic;
	long   size;
	int    release;
	int    active;
	MFORM *mhelp;
	int    dtimer;
} BGEM;

#endif
