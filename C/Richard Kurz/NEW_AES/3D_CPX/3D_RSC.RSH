#define T0OBJ 0
#define FREEBB 0
#define FREEIMG 0
#define FREESTR 21

BYTE *rs_strings[] = {
"OK",
"Abbruch",
"Sichern",
"LK3DIND",
"LK3DACT",
"INDBUTCOL",
"ACTBUTCOL",
"BACKGRCOL",
"AD3DVALUE",
"123",
"",
"",
"I",
"123",
"",
"",
"II",
"Einstellung der 3D-Effekte",
"½ 1992 TOS-Magazin",
"",
""};

LONG rs_frstr[] = {
0};

BITBLK rs_bitblk[] = {
0};

LONG rs_frimg[] = {
0};

ICONBLK rs_iconblk[] = {
0};

TEDINFO rs_tedinfo[] = {
9L, 10L, 11L, 3, 0, 2, 0x1180, 0x0, -1, 4,1,
13L, 14L, 15L, 3, 0, 2, 0x1100, 0x0, -1, 4,1,
18L, 19L, 20L, 3, 0, 0, 0x1480, 0x0, 0, 19,1};

OBJECT rs_object[] = {
-1, 1, 24, G_BOX, NONE, NORMAL, 0xFF1100L, 0,0, 32,11,
6, 2, 4, G_BOX, NONE, NORMAL, 0xFF1100L, 0,9, 32,2,
3, -1, -1, G_BUTTON, 0x607, NORMAL, 0x0L, 1036,2048, 8,1,
4, -1, -1, G_BUTTON, 0x605, NORMAL, 0x1L, 22,2048, 9,1,
1, 5, 5, G_BOX, NONE, NORMAL, 0xFF1100L, 0,0, 11,2,
4, -1, -1, G_BUTTON, 0x605, NORMAL, 0x2L, 1,2048, 9,1,
13, 7, 12, G_BOX, 0x400, OUTLINED, 0x11100L, 1,2048, 21,5,
8, -1, -1, G_BUTTON, 0x215, 0x80, 0x3L, 1,2048, 9,1,
9, -1, -1, G_BUTTON, 0x215, 0x80, 0x4L, 11,2048, 9,1,
10, -1, -1, G_BUTTON, 0x215, NORMAL, 0x5L, 1,2, 9,1,
11, -1, -1, G_BUTTON, 0x215, NORMAL, 0x6L, 11,2, 9,1,
12, -1, -1, G_BUTTON, 0x215, NORMAL, 0x7L, 1,2051, 9,1,
6, -1, -1, G_BUTTON, 0x215, NORMAL, 0x8L, 11,2051, 9,1,
24, 14, 19, G_BOX, NONE, NORMAL, 0xFF1100L, 23,0, 9,3845,
19, 15, 18, G_IBOX, NONE, NORMAL, 0x1100L, 1024,2048, 4,1285,
16, -1, -1, G_BOXTEXT, 0x400, OUTLINED, 0x0L, 512,2, 3,1,
17, -1, -1, G_BOXCHAR, 0x605, NORMAL, 0x1FF1100L, 1024,4, 1,1,
18, -1, -1, G_BOXCHAR, 0x605, NORMAL, 0x2FF1100L, 2,4, 1,1,
14, -1, -1, G_BUTTON, NONE, OUTLINED, 0xCL, 256,0, 3,1,
13, 20, 23, G_IBOX, NONE, NORMAL, 0x1100L, 1284,2048, 4,1285,
21, -1, -1, G_BOXTEXT, 0x400, OUTLINED, 0x1L, 512,2, 3,1,
22, -1, -1, G_BOXCHAR, 0x605, NORMAL, 0x1FF1100L, 1024,4, 1,1,
23, -1, -1, G_BOXCHAR, 0x605, NORMAL, 0x2FF1100L, 2,4, 1,1,
19, -1, -1, G_BUTTON, NONE, OUTLINED, 0x10L, 256,0, 3,1,
0, 25, 26, G_BOX, NONE, NORMAL, 0xFF1100L, 0,6, 32,3,
26, -1, -1, G_STRING, NONE, NORMAL, 0x11L, 3,2048, 26,1,
24, -1, -1, G_TEXT, LASTOB, NORMAL, 0x2L, 7,2049, 18,1};

LONG rs_trindex[] = {
0L};

struct foobar {
	WORD	dummy;
	WORD	*image;
	} rs_imdope[] = {
0};

#define NUM_STRINGS 21
#define NUM_FRSTR 0
#define NUM_IMAGES 0
#define NUM_BB 0
#define NUM_FRIMG 0
#define NUM_IB 0
#define NUM_TI 3
#define NUM_OBS 27
#define NUM_TREE 1

BYTE pname[] = "3D_RSC.RSC";