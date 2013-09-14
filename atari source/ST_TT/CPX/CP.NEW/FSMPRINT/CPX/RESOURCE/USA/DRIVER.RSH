#define T0OBJX 0
#define T1OBJX 18
#define FREEBBX 0
#define FREEIMGX 0
#define FREESTRX 31

BYTE *rx_strings[] = {
"012345678901234567890123456789",
"",
"",
"Print Quality:",
"Final",
"Letter",
"Page Size:",
"Colors:",
"B/W",
"Port:",
"Printer",
"Tray:",
"Tractor",
"Horizontal DPI Size:",
"0123",
"Vertical DPI Size:",
"0123",
"SAVE",
"Exit",
"PRINTER RESOLUTION",
"UNITS: INCHES",
"",
"",
"01234",
"   WIDTH:  _____",
"XXXXX",
"01234",
"  HEIGHT:  _____",
"XXXXX",
"OK",
"Cancel"};

LONG rx_frstr[] = {
0};

BITBLK rx_bitblk[] = {
0};

LONG rx_frimg[] = {
0};

ICONBLK rx_iconblk[] = {
0};

TEDINFO rx_tedinfo[] = {
0L, 1L, 2L, 3, 6, 2, 0x1180, 0x0, -1, 31,1,
20L, 21L, 22L, 3, 6, 2, 0x1180, 0x0, -1, 14,1,
23L, 24L, 25L, 3, 6, 0, 0x1180, 0x0, -1, 6,17,
26L, 27L, 28L, 3, 6, 0, 0x1180, 0x0, -1, 6,17};

OBJECT rx_object[] = {
-1, 1, 17, G_BOX, NONE, OUTLINED, 0x21100L, 12,1538, 34,19,
2, -1, -1, G_TEXT, NONE, NORMAL, 0x0L, 2,1, 30,1,
3, -1, -1, G_STRING, NONE, NORMAL, 0x3L, 2,3, 14,1,
4, -1, -1, G_BUTTON, TOUCHEXIT, SHADOWED, 0x4L, 20,3, 12,1,
5, -1, -1, G_BUTTON, TOUCHEXIT, SHADOWED, 0x5L, 20,5, 12,1,
6, -1, -1, G_STRING, NONE, NORMAL, 0x6L, 2,5, 10,1,
7, -1, -1, G_STRING, NONE, NORMAL, 0x7L, 2,7, 7,1,
8, -1, -1, G_BUTTON, TOUCHEXIT, SHADOWED, 0x8L, 20,7, 12,1,
9, -1, -1, G_STRING, NONE, NORMAL, 0x9L, 2,9, 5,1,
10, -1, -1, G_BUTTON, TOUCHEXIT, SHADOWED, 0xAL, 20,9, 12,1,
11, -1, -1, G_STRING, NONE, NORMAL, 0xBL, 2,11, 5,1,
12, -1, -1, G_BUTTON, TOUCHEXIT, SHADOWED, 0xCL, 20,11, 12,1,
13, -1, -1, G_STRING, NONE, NORMAL, 0xDL, 2,13, 20,1,
14, -1, -1, G_BUTTON, NONE, NORMAL, 0xEL, 25,13, 7,1,
15, -1, -1, G_STRING, NONE, NORMAL, 0xFL, 2,15, 18,1,
16, -1, -1, G_BUTTON, NONE, NORMAL, 0x10L, 25,15, 7,1,
17, -1, -1, G_BUTTON, 0x7, NORMAL, 0x11L, 6,17, 8,1,
0, -1, -1, G_BUTTON, 0x25, NORMAL, 0x12L, 20,17, 8,1,
-1, 1, 7, G_BOX, NONE, OUTLINED, 0x21100L, 0,0, 27,12,
2, -1, -1, G_STRING, NONE, NORMAL, 0x13L, 4,1, 19,1,
3, -1, -1, G_TEXT, NONE, NORMAL, 0x1L, 0,2, 27,1,
6, 4, 5, G_IBOX, NONE, NORMAL, 0x11100L, 2,4, 23,5,
5, -1, -1, G_FBOXTEXT, EDITABLE, NORMAL, 0x2L, 2,1, 19,1,
3, -1, -1, G_FBOXTEXT, EDITABLE, NORMAL, 0x3L, 2,3, 19,1,
7, -1, -1, G_BUTTON, 0x7, NORMAL, 0x1DL, 4,10, 8,1,
0, -1, -1, G_BUTTON, 0x25, NORMAL, 0x1EL, 15,10, 8,1};

LONG rx_trindex[] = {
0L,
18L};

struct foobarx {
	WORD	dummy;
	WORD	*image;
	} rx_imdope[] = {
0};

#define NUMX_STRINGS 31
#define NUMX_FRSTR 0
#define NUMX_IMAGES 0
#define NUMX_BB 0
#define NUMX_FRIMG 0
#define NUMX_IB 0
#define NUMX_TI 4
#define NUMX_OBS 26
#define NUMX_TREE 2

BYTE pxname[] = "DRIVER.RSC";
