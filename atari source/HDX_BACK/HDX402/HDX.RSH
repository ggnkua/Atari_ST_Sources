#define T0OBJ 0
#define T1OBJ 7
#define T2OBJ 32
#define T3OBJ 39
#define FREEBB 0
#define FREEIMG 0
#define FREESTR 68

BYTE *rs_strings[] = {
"  SELECT PREFERENCE  ",
"MEGA or ST",
"MS-DOS 3.X",
"OK",
"CANCEL",
"999Mb",
"OK",
"CANCEL",
"999Mb",
"999Mb",
" Menu",
"Undo",
"999Mb",
"Edit partition scheme of the unit",
"@23456",
"Left: ______",
"nnnnnn",
"EXT.PARTITION",
"",
"________.",
"",
"",
"________.",
"",
"",
"________.",
"",
"",
"________.",
"",
"",
"Total: ________",
"",
"partition",
"CANCEL",
"     ST doesn't read more than",
"     maximum number of fourteen",
"   logical drives !",
"            WARNING   ",
"999Mb",
"999Mb",
"999Mb",
"999Mb",
"",
"________.",
"",
"",
"________.",
"",
"",
"________.",
"",
"",
"EXTENDED PARTITION",
"",
"PRIMARY OK",
"OK",
"UNDO",
"CANCEL",
"",
"________.",
"",
"",
"Total: ________",
"",
"@23456",
"Left: ______",
"nnnnnn",
"[3][You must reboot the system if|you want to directly zero or|markba\
d the hard disk right |after formatting or partitioning][   OK   ]"};

LONG rs_frstr[] = {
68L};

BITBLK rs_bitblk[] = {
0};

LONG rs_frimg[] = {
0};

ICONBLK rs_iconblk[] = {
0};

TEDINFO rs_tedinfo[] = {
14L, 15L, 16L, 3, 6, 0, 0x1180, 0x0, -1, 7,13,
18L, 19L, 20L, 3, 6, 0, 0x1180, 0x0, -1, 1,10,
21L, 22L, 23L, 3, 6, 0, 0x1180, 0x0, -1, 1,10,
24L, 25L, 26L, 3, 6, 0, 0x1180, 0x0, -1, 1,10,
27L, 28L, 29L, 3, 6, 0, 0x1180, 0x0, -1, 1,10,
30L, 31L, 32L, 3, 6, 0, 0x1180, 0x0, -1, 1,16,
43L, 44L, 45L, 3, 6, 0, 0x1180, 0x0, -1, 1,10,
46L, 47L, 48L, 3, 6, 0, 0x1180, 0x0, -1, 1,10,
49L, 50L, 51L, 3, 6, 0, 0x1180, 0x0, -1, 1,10,
52L, 53L, 54L, 3, 6, 2, 0x1180, 0x0, -1, 1,19,
59L, 60L, 61L, 3, 6, 0, 0x1180, 0x0, -1, 1,10,
62L, 63L, 64L, 3, 6, 0, 0x1180, 0x0, -1, 1,16,
65L, 66L, 67L, 3, 6, 0, 0x1180, 0x0, -1, 7,13};

OBJECT rs_object[] = {
-1, 1, 6, G_BOX, NONE, OUTLINED, 0x21100L, 0,0, 42,13,
2, -1, -1, G_STRING, NONE, NORMAL, 0x0L, 9,3, 25,1,
5, 3, 4, G_IBOX, NONE, NORMAL, 0x1100L, 5,5, 32,5,
4, -1, -1, G_BUTTON, 0x11, SHADOWED, 0x1L, 9,1, 14,1,
2, -1, -1, G_BUTTON, 0x11, SHADOWED, 0x2L, 9,3, 14,1,
6, -1, -1, G_BUTTON, 0x7, NORMAL, 0x3L, 7,10, 8,1,
0, -1, -1, G_BUTTON, 0x25, NORMAL, 0x4L, 27,10, 8,1,
-1, 1, 24, G_BOX, NONE, OUTLINED, 0x21100L, 0,0, 39,15,
2, -1, -1, G_BUTTON, 0x41, NORMAL, 0x5L, 12,5, 7,1,
3, -1, -1, G_BOXCHAR, TOUCHEXIT, NORMAL, 0x2FF1100L, 20,5, 3,1,
4, -1, -1, G_BOXCHAR, TOUCHEXIT, NORMAL, 0x1FF1100L, 23,5, 3,1,
5, -1, -1, G_BOXCHAR, TOUCHEXIT, NORMAL, 0x2FF1100L, 20,7, 3,1,
6, -1, -1, G_BOXCHAR, TOUCHEXIT, NORMAL, 0x2FF1100L, 20,9, 3,1,
7, -1, -1, G_BOXCHAR, TOUCHEXIT, NORMAL, 0x2FF1100L, 20,11, 3,1,
8, -1, -1, G_BOXCHAR, TOUCHEXIT, NORMAL, 0x1FF1100L, 23,7, 3,1,
9, -1, -1, G_BOXCHAR, TOUCHEXIT, NORMAL, 0x1FF1100L, 23,9, 3,1,
10, -1, -1, G_BOXCHAR, TOUCHEXIT, NORMAL, 0x1FF1100L, 23,11, 3,1,
11, -1, -1, G_BUTTON, 0x5, NORMAL, 0x6L, 28,9, 8,1,
12, -1, -1, G_BUTTON, 0x7, NORMAL, 0x7L, 28,11, 8,1,
13, -1, -1, G_BUTTON, 0x41, NORMAL, 0x8L, 12,7, 7,1,
14, -1, -1, G_BUTTON, 0x41, NORMAL, 0x9L, 12,9, 7,1,
15, -1, -1, G_BUTTON, 0x41, NORMAL, 0xAL, 2,13, 8,1,
16, -1, -1, G_BUTTON, 0x41, NORMAL, 0xBL, 12,13, 8,1,
17, -1, -1, G_BUTTON, 0x41, NORMAL, 0xCL, 12,11, 7,1,
18, -1, -1, G_STRING, NONE, NORMAL, 0xDL, 3,1, 33,1,
19, -1, -1, G_FTEXT, NONE, NORMAL, 0x0L, 21,3, 13,1,
20, -1, -1, G_BUTTON, 0x41, NORMAL, 0x11L, 22,13, 13,1,
21, -1, -1, G_FTEXT, NONE, NORMAL, 0x1L, 2,5, 9,1,
22, -1, -1, G_FTEXT, NONE, NORMAL, 0x2L, 2,7, 9,1,
23, -1, -1, G_FTEXT, NONE, NORMAL, 0x3L, 2,9, 9,1,
24, -1, -1, G_FTEXT, NONE, NORMAL, 0x4L, 2,11, 9,1,
0, -1, -1, G_FTEXT, LASTOB, NORMAL, 0x5L, 3,3, 15,1,
-1, 1, 6, G_BOX, NONE, OUTLINED, 0x21100L, 0,0, 39,15,
2, -1, -1, G_BUTTON, 0x5, NORMAL, 0x21L, 9,11, 9,1,
3, -1, -1, G_BUTTON, 0x7, NORMAL, 0x22L, 23,11, 8,1,
4, -1, -1, G_STRING, NONE, NORMAL, 0x23L, 2,4, 35,1,
5, -1, -1, G_STRING, NONE, NORMAL, 0x24L, 2,6, 35,1,
6, -1, -1, G_STRING, NONE, NORMAL, 0x25L, 4,8, 35,1,
0, -1, -1, G_STRING, LASTOB, NORMAL, 0x26L, 2,2, 35,1,
-1, 1, 30, G_BOX, NONE, NORMAL, 0x21100L, 12,1538, 296,1295,
2, -1, -1, G_BUTTON, TOUCHEXIT, NORMAL, 0x27L, 16,4, 7,1,
3, -1, -1, G_BOXCHAR, TOUCHEXIT, NORMAL, 0x2FF1100L, 26,4, 3,1,
4, -1, -1, G_BOXCHAR, TOUCHEXIT, NORMAL, 0x1FF1100L, 29,4, 3,1,
5, -1, -1, G_BOXCHAR, TOUCHEXIT, NORMAL, 0x2FF1100L, 26,6, 3,1,
6, -1, -1, G_BOXCHAR, TOUCHEXIT, NORMAL, 0x2FF1100L, 26,8, 3,1,
7, -1, -1, G_BOXCHAR, TOUCHEXIT, NORMAL, 0x2FF1100L, 26,10, 3,1,
8, -1, -1, G_BOXCHAR, TOUCHEXIT, NORMAL, 0x1FF1100L, 29,6, 3,1,
9, -1, -1, G_BOXCHAR, TOUCHEXIT, NORMAL, 0x1FF1100L, 29,8, 3,1,
10, -1, -1, G_BOXCHAR, TOUCHEXIT, NORMAL, 0x1FF1100L, 29,10, 3,1,
11, -1, -1, G_BUTTON, TOUCHEXIT, NORMAL, 0x28L, 16,6, 7,1,
12, -1, -1, G_BUTTON, TOUCHEXIT, NORMAL, 0x29L, 16,8, 7,1,
13, -1, -1, G_BUTTON, TOUCHEXIT, NORMAL, 0x2AL, 16,10, 7,1,
14, -1, -1, G_FTEXT, NONE, NORMAL, 0x6L, 5,4, 9,1,
15, -1, -1, G_FTEXT, NONE, NORMAL, 0x7L, 5,6, 9,1,
16, -1, -1, G_FTEXT, NONE, NORMAL, 0x8L, 5,8, 10,1,
18, 17, 17, G_BOX, TOUCHEXIT, NORMAL, 0xFF1111L, 38,1284, 2,1798,
16, -1, -1, G_BOX, TOUCHEXIT, NORMAL, 0xFF1100L, 0,256, 2,257,
20, 19, 19, G_BOX, NONE, NORMAL, 0xFF1100L, 38,771, 2,513,
18, -1, -1, G_BOXCHAR, TOUCHEXIT, NORMAL, 0x1FF1100L, 0,256, 2,257,
21, -1, -1, G_BOX, NONE, NORMAL, 0xFF1100L, 38,3082, 2,1,
23, 22, 22, G_BOX, NONE, NORMAL, 0xFF1121L, 512,0, 1575,1,
21, -1, -1, G_FBOXTEXT, EDITABLE, NORMAL, 0x9L, 778,0, 19,1,
28, 24, 27, G_BOX, NONE, NORMAL, 0xFF1100L, 512,3595, 1575,1283,
25, -1, -1, G_BUTTON, 0x41, NORMAL, 0x37L, 1,513, 10,1,
26, -1, -1, G_BUTTON, 0x5, NORMAL, 0x38L, 1053,769, 775,3584,
27, -1, -1, G_BUTTON, TOUCHEXIT, NORMAL, 0x39L, 12,513, 7,1,
23, -1, -1, G_BUTTON, 0x7, NORMAL, 0x3AL, 532,513, 1543,1,
29, -1, -1, G_BOXCHAR, TOUCHEXIT, NORMAL, 0x2FF1180L, 38,3082, 2,257,
30, -1, -1, G_FTEXT, NONE, NORMAL, 0xAL, 5,10, 10,1,
0, 31, 32, G_BOX, NONE, NORMAL, 0xFF1100L, 512,257, 1575,514,
32, -1, -1, G_FTEXT, NONE, NORMAL, 0xBL, 1027,2048, 15,1,
30, -1, -1, G_FTEXT, LASTOB, NORMAL, 0xCL, 1301,2048, 13,1};

LONG rs_trindex[] = {
0L,
7L,
32L,
39L};

struct foobar {
	WORD	dummy;
	WORD	*image;
	} rs_imdope[] = {
0};

#define NUM_STRINGS 69
#define NUM_FRSTR 1
#define NUM_IMAGES 0
#define NUM_BB 0
#define NUM_FRIMG 0
#define NUM_IB 0
#define NUM_TI 13
#define NUM_OBS 72
#define NUM_TREE 4

BYTE pname[] = "IBM.RSC";