#define T0OBJ 0
#define FREEBB 0
#define FREEIMG 0
#define FREESTR 45

BYTE *rs_strings[] = {
"This port is in use,",
"and therefore cannot be",
"configured !",
"Unknown",
"   8   ",
"  Odd  ",
"   2   ",
"bps",
"Bits",
"Parity",
"Stop Bits",
"FlowCTRL :",
"Xon/Xoff",
"RSVF",
"",
"",
"supported",
"",
"",
"Buffer sizes :",
"",
"",
"_____",
"Receive : _____",
"99999",
"",
"Use LAN Port",
"_____",
"Send : _____",
"99999",
"DTR",
"Flush",
"Break",
"  Serial 2  ",
"Parameter",
"Serial Setter",
"(c)  1997  by",
"",
"",
"Peter Rottengatter",
"",
"",
"Save",
"Ok",
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
13L, 14L, 15L, 5, 6, 0, 0x1180, 0x0, -1, 5,1,
16L, 17L, 18L, 5, 6, 0, 0x1180, 0x0, -1, 10,1,
19L, 20L, 21L, 5, 6, 0, 0x1180, 0x0, -1, 15,1,
22L, 23L, 24L, 3, 6, 0, 0x1180, 0x0, -1, 6,16,
27L, 28L, 29L, 3, 6, 0, 0x1180, 0x0, -1, 6,13,
36L, 37L, 38L, 5, 6, 0, 0x1180, 0x0, -1, 14,1,
39L, 40L, 41L, 5, 6, 0, 0x1180, 0x0, -1, 19,1};

OBJECT rs_object[] = {
-1, 1, 39, G_BOX, NONE, NORMAL, 0x1101L, 0,0, 32,11,
37, 2, 33, G_BOX, NONE, NORMAL, 0xFF1100L, 0,0, 32,777,
7, 3, 3, G_BOX, NONE, NORMAL, 0x1100L, 0,2819, 32,2053,
2, 4, 6, G_BOX, NONE, NORMAL, 0xFF1100L, 2,2304, 28,4,
5, -1, -1, G_STRING, NONE, NORMAL, 0x0L, 4,1536, 20,1,
6, -1, -1, G_STRING, NONE, NORMAL, 0x1L, 1026,2049, 23,1,
3, -1, -1, G_STRING, NONE, NORMAL, 0x2L, 8,2562, 12,1,
21, 8, 18, G_BOX, NONE, NORMAL, 0xFF1101L, 0,3075, 32,1797,
9, -1, -1, G_BUTTON, 0x41, SHADOWED, 0x3L, 2,1024, 8,1,
10, -1, -1, G_BUTTON, 0x41, SHADOWED, 0x4L, 2,2049, 8,1,
11, -1, -1, G_BUTTON, 0x41, SHADOWED, 0x5L, 2,3074, 8,1,
12, -1, -1, G_BUTTON, 0x41, SHADOWED, 0x6L, 2,4, 8,1,
13, -1, -1, G_STRING, NONE, NORMAL, 0x7L, 11,1024, 3,1,
14, -1, -1, G_STRING, NONE, NORMAL, 0x8L, 11,2049, 4,1,
15, -1, -1, G_STRING, NONE, NORMAL, 0x9L, 11,3074, 6,1,
16, -1, -1, G_STRING, NONE, NORMAL, 0xAL, 11,4, 9,1,
17, -1, -1, G_STRING, NONE, NORMAL, 0xBL, 20,2560, 10,1,
18, -1, -1, G_BUTTON, 0x41, SHADOWED, 0xCL, 20,3585, 10,1,
7, 19, 20, G_BOX, NONE, NORMAL, 0x1100L, 1302,3075, 263,1,
20, -1, -1, G_TEXT, NONE, NORMAL, 0x0L, 258,256, 3,1536,
18, -1, -1, G_TEXT, NONE, NORMAL, 0x1L, 256,2304, 1542,1536,
31, 22, 30, G_BOX, NONE, NORMAL, 0xFF1100L, 0,3075, 32,1797,
23, -1, -1, G_TEXT, NONE, NORMAL, 0x2L, 2,2048, 1290,3072,
24, -1, -1, G_FTEXT, EDITABLE, NORMAL, 0x3L, 3,1026, 15,1,
27, 25, 26, G_IBOX, NONE, NORMAL, 0x1100L, 3,4, 15,1,
26, -1, -1, 0x11A, SELECTABLE, 0x6, 0xECL, 0,0, 2,1,
24, -1, -1, G_STRING, NONE, NORMAL, 0x1AL, 3,0, 12,1,
28, -1, -1, G_FTEXT, EDITABLE, NORMAL, 0x4L, 6,1025, 12,1,
29, -1, -1, G_BUTTON, SELECTABLE, NORMAL, 0x1EL, 22,1, 7,1,
30, -1, -1, G_BUTTON, 0x41, NORMAL, 0x1FL, 22,2050, 7,1,
21, -1, -1, G_BUTTON, 0x41, NORMAL, 0x20L, 22,4, 7,1,
32, -1, -1, G_BUTTON, 0x41, SHADOWED, 0x21L, 2,2048, 12,1,
33, -1, -1, G_BUTTON, 0x41, SHADOWED, 0x22L, 2,514, 12,1,
1, 34, 36, G_BOX, NONE, NORMAL, 0x1100L, 1552,1024, 14,3330,
35, -1, -1, G_STRING, NONE, NORMAL, 0x23L, 1024,1536, 13,1,
36, -1, -1, G_TEXT, NONE, NORMAL, 0x5L, 2,1537, 10,3328,
33, -1, -1, G_TEXT, NONE, NORMAL, 0x6L, 512,3841, 1293,3328,
39, 38, 38, G_BOX, NONE, NORMAL, 0xFF1100L, 0,1033, 1803,3073,
37, -1, -1, G_BUTTON, 0x5, NORMAL, 0x2AL, 1793,1536, 8,1,
0, 40, 41, G_BOX, NONE, NORMAL, 0xFF1100L, 12,1033, 20,3073,
41, -1, -1, G_BUTTON, 0x7, NORMAL, 0x2BL, 514,1536, 5,1,
39, -1, -1, G_BUTTON, 0x25, NORMAL, 0x2CL, 9,1536, 9,1};

LONG rs_trindex[] = {
0L};

struct foobar {
	WORD	dummy;
	WORD	*image;
	} rs_imdope[] = {
0};

#define NUM_STRINGS 45
#define NUM_FRSTR 0
#define NUM_IMAGES 0
#define NUM_BB 0
#define NUM_FRIMG 0
#define NUM_IB 0
#define NUM_TI 7
#define NUM_OBS 42
#define NUM_TREE 1

BYTE pname[] = "SERIAL.RSC";