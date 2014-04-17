#define T0OBJ 0
#define FREEBB 0
#define FREEIMG 0
#define FREESTR 34

BYTE *rs_strings[] = {
"0.00",
"",
"",
"00",
"",
"",
"0.00",
"",
"",
" Response Delay ",
"",
"",
" Drag Delay ",
"",
"",
" Display Delay ",
"",
"",
"0.00",
"",
"",
" Scroll Delay ",
"",
"",
"000",
"___",
"999",
" Height ",
"",
"",
"Reload",
"Save",
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
(char*)0L, (char*)1L, (char*)2L, 3, 6, 2, 0x1180, 0x0, -1, 5,1,
(char*)3L, (char*)4L, (char*)5L, 3, 6, 2, 0x1180, 0x0, -1, 3,1,
(char*)6L, (char*)7L, (char*)8L, 3, 6, 2, 0x1180, 0x0, -1, 5,1,
(char*)9L, (char*)10L, (char*)11L, 3, 6, 0, 0x1180, 0x0, -1, 17,1,
(char*)12L, (char*)13L, (char*)14L, 3, 6, 0, 0x1180, 0x0, -1, 13,1,
(char*)15L, (char*)16L, (char*)17L, 3, 6, 0, 0x1180, 0x0, -1, 16,1,
(char*)18L, (char*)19L, (char*)20L, 3, 6, 2, 0x1180, 0x0, -1, 5,1,
(char*)21L, (char*)22L, (char*)23L, 3, 6, 0, 0x1180, 0x0, -1, 15,1,
(char*)24L, (char*)25L, (char*)26L, 3, 6, 2, 0x1180, 0x0, -1, 4,4,
(char*)27L, (char*)28L, (char*)29L, 3, 6, 0, 0x1180, 0x0, -1, 9,1};

OBJECT rs_object[] = {
-1, 1, 32, G_BOX, TOUCHEXIT, NORMAL, (void*)0x1100L, 12,1538, 32,11,
26, 2, 25, G_BOX, NONE, NORMAL, (void*)0xFF1100L, 0,0, 1556,11,
7, 3, 6, G_BOX, NONE, NORMAL, (void*)0xFF1100L, 1280,2560, 787,3329,
4, -1, -1, G_BOXCHAR, TOUCHEXIT, NORMAL, (void*)0x4FF1100L, 1793,2304, 770,1,
6, 5, 5, G_BOX, TOUCHEXIT, NORMAL, (void*)0xFF1111L, 772,2304, 1034,1,
4, -1, -1, G_BOXTEXT, TOUCHEXIT, NORMAL, (void*)0x0L, 1794,0, 1796,1,
2, -1, -1, G_BOXCHAR, TOUCHEXIT, NORMAL, (void*)0x3FF1100L, 15,2304, 770,1,
12, 8, 11, G_BOX, NONE, NORMAL, (void*)0xFF1100L, 1280,1283, 787,3329,
9, -1, -1, G_BOXCHAR, TOUCHEXIT, NORMAL, (void*)0x4FF1100L, 1793,2304, 770,1,
11, 10, 10, G_BOX, TOUCHEXIT, NORMAL, (void*)0xFF1111L, 772,2304, 1034,1,
9, -1, -1, G_BOXTEXT, TOUCHEXIT, NORMAL, (void*)0x1L, 1283,0, 771,1,
7, -1, -1, G_BOXCHAR, TOUCHEXIT, NORMAL, (void*)0x3FF1100L, 15,2304, 770,1,
17, 13, 16, G_BOX, NONE, NORMAL, (void*)0xFF1100L, 1280,518, 787,3329,
14, -1, -1, G_BOXCHAR, TOUCHEXIT, NORMAL, (void*)0x4FF1100L, 1793,2304, 770,1,
16, 15, 15, G_BOX, TOUCHEXIT, NORMAL, (void*)0xFF1111L, 772,2304, 1034,1,
14, -1, -1, G_BOXTEXT, TOUCHEXIT, NORMAL, (void*)0x2L, 1794,0, 1796,1,
12, -1, -1, G_BOXCHAR, TOUCHEXIT, NORMAL, (void*)0x3FF1100L, 15,2304, 770,1,
18, -1, -1, G_TEXT, TOUCHEXIT, NORMAL, (void*)0x3L, 2,2309, 16,1,
19, -1, -1, G_TEXT, TOUCHEXIT, NORMAL, (void*)0x4L, 2,3074, 12,1,
20, -1, -1, G_TEXT, TOUCHEXIT, NORMAL, (void*)0x5L, 2,256, 15,1,
25, 21, 24, G_BOX, NONE, NORMAL, (void*)0xFF1100L, 1280,3848, 787,3329,
22, -1, -1, G_BOXCHAR, TOUCHEXIT, NORMAL, (void*)0x4FF1100L, 1793,2304, 770,1,
24, 23, 23, G_BOX, TOUCHEXIT, NORMAL, (void*)0xFF1111L, 772,2304, 1034,1,
22, -1, -1, G_BOXTEXT, TOUCHEXIT, NORMAL, (void*)0x6L, 1794,0, 1796,1,
20, -1, -1, G_BOXCHAR, TOUCHEXIT, NORMAL, (void*)0x3FF1100L, 15,2304, 770,1,
1, -1, -1, G_TEXT, TOUCHEXIT, NORMAL, (void*)0x7L, 2,1544, 14,1,
32, 27, 31, G_BOX, NONE, NORMAL, (void*)0xFF1100L, 1812,0, 267,1027,
31, 28, 30, G_BOX, NONE, NORMAL, (void*)0xFF1100L, 1024,2560, 266,3329,
29, -1, -1, G_BOXCHAR, TOUCHEXIT, NORMAL, (void*)0x1FF1100L, 257,2304, 1025,1,
30, -1, -1, G_BOXCHAR, TOUCHEXIT, NORMAL, (void*)0x2FF1100L, 1031,2304, 1025,1,
27, -1, -1, G_FBOXTEXT, NONE, NORMAL, (void*)0x8L, 1538,2304, 1284,1,
26, -1, -1, G_TEXT, TOUCHEXIT, NORMAL, (void*)0x9L, 1025,256, 8,1,
0, 33, 38, G_BOX, NONE, NORMAL, (void*)0xFF1100L, 1812,1283, 267,2823,
35, 34, 34, G_BOX, NONE, NORMAL, (void*)0xFF1100L, 0,0, 267,3841,
33, -1, -1, G_BUTTON, 0x5, NORMAL, (void*)0x1EL, 1793,1536, 519,257,
37, 36, 36, G_BOX, NONE, NORMAL, (void*)0xFF1100L, 0,2, 267,3329,
35, -1, -1, G_BUTTON, 0x5, NORMAL, (void*)0x1FL, 1793,1536, 519,257,
38, -1, -1, G_BUTTON, 0x7, NORMAL, (void*)0x20L, 1793,1796, 519,257,
32, -1, -1, G_BUTTON, 0x25, NORMAL, (void*)0x21L, 1793,1286, 519,257};

LONG rs_trindex[] = {
0L};

struct foobar {
	WORD	dummy;
	WORD	*image;
	} rs_imdope[] = {
0};

#define NUM_STRINGS 34
#define NUM_FRSTR 0
#define NUM_IMAGES 0
#define NUM_BB 0
#define NUM_FRIMG 0
#define NUM_IB 0
#define NUM_TI 10
#define NUM_OBS 39
#define NUM_TREE 1

BYTE pname[] = "USA.RSC";
