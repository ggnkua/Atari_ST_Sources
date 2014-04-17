#define T0OBJ 0
#define T1OBJ 20
#define FREEBB 0
#define FREEIMG 0
#define FREESTR 36

BYTE *rs_strings[] = {
"012345678901234567890123456",
"",
"",
"012345678901234567890123456",
"",
"",
"012345678901234567890123456",
"",
"",
"012345678901234567890123456",
"",
"",
"012345678901234567890123456",
"",
"",
"012345678901234567890123456",
"",
"",
"012345678901234567890123456",
"",
"",
"Add",
"Delete",
"Save",
"Exit",
"Environment String(s)",
"",
"",
"Modify Environment String",
"",
"",
"0123456789012345678901234567890123456789",
"STRING: ________________________________________",
"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
"OK",
"Cancel"};

LONG rs_frstr[] = {
0};

BITBLK rs_bitblk[] = {
0};

LONG rs_frimg[] = {
0};

ICONBLK rs_iconblk[] = {
0};

TEDINFO rs_tedinfo[] = {
(char*)0L, (char*)1L, (char*)2L, 3, 6, 0, 0x1180, 0x0, -1, 28,1,
(char*)3L, (char*)4L, (char*)5L, 3, 6, 0, 0x1180, 0x0, -1, 28,1,
(char*)6L, (char*)7L, (char*)8L, 3, 6, 0, 0x1180, 0x0, -1, 28,1,
(char*)9L, (char*)10L, (char*)11L, 3, 6, 0, 0x1180, 0x0, -1, 28,1,
(char*)12L, (char*)13L, (char*)14L, 3, 6, 0, 0x1180, 0x0, -1, 28,1,
(char*)15L, (char*)16L, (char*)17L, 3, 6, 0, 0x1180, 0x0, -1, 28,1,
(char*)18L, (char*)19L, (char*)20L, 3, 6, 0, 0x1180, 0x0, -1, 28,1,
(char*)25L, (char*)26L, (char*)27L, 3, 6, 2, 0x1180, 0x0, -1, 22,1,
(char*)28L, (char*)29L, (char*)30L, 3, 6, 2, 0x1180, 0x0, -1, 26,1,
(char*)31L, (char*)32L, (char*)33L, 3, 6, 2, 0x1180, 0x0, -1, 41,49};

OBJECT rs_object[] = {
-1, 1, 19, G_BOX, TOUCHEXIT, NORMAL, (void*)0x1141L, 12,1538, 32,11,
14, 2, 13, G_BOX, NONE, NORMAL, (void*)0xFF1100L, 257,2561, 1565,7,
10, 3, 9, G_BOX, NONE, NORMAL, (void*)0xFF1100L, 0,0, 27,7,
4, -1, -1, G_TEXT, TOUCHEXIT, NORMAL, (void*)0x0L, 0,0, 27,1,
5, -1, -1, G_TEXT, TOUCHEXIT, NORMAL, (void*)0x1L, 0,1, 27,1,
6, -1, -1, G_TEXT, TOUCHEXIT, NORMAL, (void*)0x2L, 0,2, 27,1,
7, -1, -1, G_TEXT, TOUCHEXIT, NORMAL, (void*)0x3L, 0,3, 27,1,
8, -1, -1, G_TEXT, TOUCHEXIT, NORMAL, (void*)0x4L, 0,4, 27,1,
9, -1, -1, G_TEXT, TOUCHEXIT, NORMAL, (void*)0x5L, 0,5, 27,1,
2, -1, -1, G_TEXT, TOUCHEXIT, NORMAL, (void*)0x6L, 0,6, 27,1,
12, 11, 11, G_BOX, TOUCHEXIT, NORMAL, (void*)0xFF1111L, 283,257, 1282,3588,
10, -1, -1, G_BOX, TOUCHEXIT, NORMAL, (void*)0xFF1100L, 0,514, 1282,3328,
13, -1, -1, G_BOXCHAR, TOUCHEXIT, NORMAL, (void*)0x1FF1100L, 283,0, 1282,1,
1, -1, -1, G_BOXCHAR, TOUCHEXIT, NORMAL, (void*)0x2FF1100L, 283,6, 1282,1,
19, 15, 18, G_BOX, TOUCHEXIT, NORMAL, (void*)0xFF1100L, 257,3848, 1565,2817,
16, -1, -1, G_BUTTON, 0x5, NORMAL, (void*)0x15L, 1280,1536, 6,1,
17, -1, -1, G_BUTTON, 0x5, NORMAL, (void*)0x16L, 1287,1536, 775,1,
18, -1, -1, G_BUTTON, 0x5, NORMAL, (void*)0x17L, 16,1536, 6,1,
14, -1, -1, G_BUTTON, 0x7, NORMAL, (void*)0x18L, 279,1536, 6,1,
0, -1, -1, G_BOXTEXT, 0x60, NORMAL, (void*)0x7L, 257,1024, 1565,513,
-1, 1, 4, G_BOX, NONE, OUTLINED, (void*)0x21100L, 0,0, 54,2566,
2, -1, -1, G_BOXTEXT, NONE, SHADOWED, (void*)0x8L, 12,3072, 30,1,
3, -1, -1, G_FBOXTEXT, EDITABLE, NORMAL, (void*)0x9L, 2,2050, 50,1,
4, -1, -1, G_BUTTON, 0x7, NORMAL, (void*)0x22L, 1036,2052, 11,1,
0, -1, -1, G_BUTTON, 0x25, NORMAL, (void*)0x23L, 1055,2052, 11,1};

LONG rs_trindex[] = {
0L,
20L};

struct foobar {
	WORD	dummy;
	WORD	*image;
	} rs_imdope[] = {
0};

#define NUM_STRINGS 36
#define NUM_FRSTR 0
#define NUM_IMAGES 0
#define NUM_BB 0
#define NUM_FRIMG 0
#define NUM_IB 0
#define NUM_TI 10
#define NUM_OBS 25
#define NUM_TREE 2

BYTE pname[] = "USA.RSC";
