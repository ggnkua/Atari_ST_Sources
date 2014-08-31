#define T0OBJ 0
#define FREEBB 0
#define FREEIMG 0
#define FREESTR 49

BYTE *rs_strings[] = {
"STinG V00.01",
"TCP.......",
"",
"Address Mask Control",
"",
"___",
"Router Advert. :  ___ min",
"999",
"____",
"Lag behind GMT : ____ min",
"XXXX",
"_____",
"Max. Segment Size : _____",
"99999",
"_____",
"Receive Window : _____",
"99999",
"_____",
"First local port : _____",
"99999",
"___",
"Default TTL : ___",
"XXX",
"_____",
"Initial RTT : __.___ sec",
"99999",
"",
"Evaluate ICMP messages",
"_____",
"First local port : _____",
"99999",
"",
"Evaluate ICMP messages",
"Name Server :",
"123456789357",
"___.___.___.___",
"999999999999",
"Domain :",
"____________________________",
"____________________________",
"XXXXXXXXXXXXXXXXXXXXXXXXXXXX",
"____",
"Cache :  ____ RRs",
"XXXX",
"",
"Save",
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
5L, 6L, 7L, 3, 6, 0, 0x1180, 0x0, -1, 4,26,
8L, 9L, 10L, 3, 6, 0, 0x1180, 0x0, -1, 5,26,
11L, 12L, 13L, 3, 6, 0, 0x1180, 0x0, -1, 6,26,
14L, 15L, 16L, 3, 6, 0, 0x1180, 0x0, -1, 6,23,
17L, 18L, 19L, 3, 6, 0, 0x1180, 0x0, -1, 6,25,
20L, 21L, 22L, 3, 6, 0, 0x1180, 0x0, -1, 4,18,
23L, 24L, 25L, 3, 6, 0, 0x1180, 0x0, -1, 6,25,
28L, 29L, 30L, 3, 6, 0, 0x1180, 0x0, -1, 6,25,
34L, 35L, 36L, 3, 6, 0, 0x1180, 0x0, -1, 13,16,
38L, 39L, 40L, 3, 6, 0, 0x1180, 0x0, -1, 29,29,
41L, 42L, 43L, 3, 6, 0, 0x1180, 0x0, -1, 5,18};

OBJECT rs_object[] = {
-1, 1, 41, G_BOX, NONE, NORMAL, 0x1101L, 0,0, 32,11,
39, 2, 27, G_BOX, NONE, NORMAL, 0xFF1100L, 0,0, 32,777,
4, 3, 3, G_BOX, NONE, NORMAL, 0xFF1100L, 18,0, 14,2561,
2, -1, -1, G_STRING, NONE, NORMAL, 0x0L, 1,1536, 12,1,
5, -1, -1, G_BUTTON, 0x41, SHADOWED, 0x1L, 2,1536, 14,1,
13, 6, 12, G_BOX, NONE, NORMAL, 0x1100L, 0,2, 32,775,
9, 7, 8, G_BOX, NONE, NORMAL, 0x1100L, 2,2, 23,1,
8, -1, -1, 0x11A, SELECTABLE, 0x6, 0x3CL, 0,0, 2,1,
6, -1, -1, G_STRING, NONE, NORMAL, 0x3L, 3,0, 20,1,
12, 10, 11, G_BOX, NONE, NORMAL, 0x1100L, 2,2051, 28,1,
11, -1, -1, 0x11A, SELECTABLE, 0x6, 0x52L, 0,0, 2,1,
9, -1, -1, G_FTEXT, EDITABLE, NORMAL, 0x0L, 3,0, 25,1,
5, -1, -1, G_FTEXT, EDITABLE, NORMAL, 0x1L, 5,5, 26,1,
22, 14, 19, G_BOX, NONE, NORMAL, 0x1100L, 0,2, 32,775,
15, -1, -1, G_FTEXT, EDITABLE, NORMAL, 0x2L, 3,512, 25,1,
16, -1, -1, G_FTEXT, EDITABLE, NORMAL, 0x3L, 6,513, 22,1,
17, -1, -1, G_FTEXT, EDITABLE, NORMAL, 0x4L, 4,514, 24,1,
18, -1, -1, G_FTEXT, EDITABLE, NORMAL, 0x5L, 9,515, 17,1,
19, -1, -1, G_FTEXT, EDITABLE, NORMAL, 0x6L, 5,1796, 24,1,
13, 20, 21, G_BOX, NONE, NORMAL, 0x1100L, 4,3077, 25,1,
21, -1, -1, 0x11A, SELECTABLE, 0x6, 0x146L, 0,0, 2,1,
19, -1, -1, G_STRING, NONE, NORMAL, 0x1BL, 3,0, 22,1,
27, 23, 24, G_BOX, NONE, NORMAL, 0x1100L, 0,2, 32,775,
24, -1, -1, G_FTEXT, EDITABLE, NORMAL, 0x7L, 4,2, 24,1,
22, 25, 26, G_BOX, NONE, NORMAL, 0x1100L, 4,4, 25,1,
26, -1, -1, 0x11A, SELECTABLE, 0x6, 0x183L, 0,0, 2,1,
24, -1, -1, G_STRING, NONE, NORMAL, 0x20L, 3,0, 22,1,
1, 28, 35, G_BOX, NONE, NORMAL, 0x1100L, 0,2, 32,775,
29, -1, -1, G_STRING, NONE, NORMAL, 0x21L, 3,1024, 13,1,
33, 30, 32, G_BOX, NONE, NORMAL, 0x1100L, 2,2049, 21,1,
31, -1, -1, G_BOXCHAR, 0x41, NORMAL, 0x4FF1100L, 0,0, 2,1,
32, -1, -1, G_FTEXT, EDITABLE, NORMAL, 0x8L, 3,0, 15,1,
29, -1, -1, G_BOXCHAR, 0x41, NORMAL, 0x3FF1100L, 19,0, 2,1,
34, -1, -1, G_STRING, NONE, NORMAL, 0x25L, 3,3586, 8,1,
35, -1, -1, G_FTEXT, EDITABLE, NORMAL, 0x9L, 2,516, 28,1,
27, 36, 38, G_BOX, NONE, NORMAL, 0x1100L, 2,2053, 28,1,
37, -1, -1, G_FTEXT, EDITABLE, NORMAL, 0xAL, 1,0, 17,1,
38, -1, -1, 0x11A, SELECTABLE, 0x6, 0x24FL, 21,0, 2,1,
35, -1, -1, G_STRING, NONE, NORMAL, 0x2DL, 24,0, 4,1,
41, 40, 40, G_BOX, NONE, NORMAL, 0xFF1100L, 0,1033, 1803,3073,
39, -1, -1, G_BUTTON, 0x5, NORMAL, 0x2EL, 1793,1536, 8,1,
0, 42, 43, G_BOX, NONE, NORMAL, 0xFF1100L, 12,1033, 20,3073,
43, -1, -1, G_BUTTON, 0x7, NORMAL, 0x2FL, 514,1536, 5,1,
41, -1, -1, G_BUTTON, 0x25, NORMAL, 0x30L, 9,1536, 9,1};

LONG rs_trindex[] = {
0L};

struct foobar {
	WORD	dummy;
	WORD	*image;
	} rs_imdope[] = {
0};

#define NUM_STRINGS 49
#define NUM_FRSTR 0
#define NUM_IMAGES 0
#define NUM_BB 0
#define NUM_FRIMG 0
#define NUM_IB 0
#define NUM_TI 11
#define NUM_OBS 44
#define NUM_TREE 1

BYTE pname[] = "STING.RSC";