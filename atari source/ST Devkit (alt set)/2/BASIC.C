#define T0OBJ 0
#define T1OBJ 37
#define FREEBB 0
#define FREEIMG 0
#define FREESTR 33

BYTE *rs_strings[] = {
" Desk ",
" File ",
" Run ",
" Edit ",
" Debug ",
"  About Atari Basic",
"--------------------",
"  Desk Accessory 1  ",
"  Desk Accessory 2  ",
"  Desk Accessory 3  ",
"  Desk Accessory 4  ",
"  Desk Accessory 5  ",
"  Desk Accessory 6  ",
"  Load ",
"  Save As ",
"  Delete File ",
"  Merge ",
"  Quit       ",
"  Run ",
"  Stop ",
"  Step ",
"  Goto Line .. ",
"  Delete Lines ",
"  Start Edit ",
"  Tron ",
"  Troff ",
"  Trace ",
"  Untrace ",
"Atari  Basic",
"Atari Corp.",
"All Rights Reserved ",
"Copyright (c) 1985",
" OK "};

LONG rs_frstr[] = {
0};

BITBLK rs_bitblk[] = {
0};

LONG rs_frimg[] = {
0};

ICONBLK rs_iconblk[] = {
0};

TEDINFO rs_tedinfo[] = {
0};

OBJECT rs_object[] = {
-1, 1, 8, G_IBOX, NONE, NORMAL, 0x0L, 0,0, 80,25,
8, 2, 2, G_BOX, NONE, NORMAL, 0x1100L, 0,0, 80,513,
1, 3, 7, G_IBOX, NONE, NORMAL, 0x0L, 2,0, 30,769,
4, -1, -1, G_TITLE, NONE, NORMAL, 0x0L, 0,0, 6,769,
5, -1, -1, G_TITLE, NONE, NORMAL, 0x1L, 6,0, 6,769,
6, -1, -1, G_TITLE, NONE, NORMAL, 0x2L, 12,0, 5,769,
7, -1, -1, G_TITLE, NONE, NORMAL, 0x3L, 17,0, 6,769,
2, -1, -1, G_TITLE, NONE, NORMAL, 0x4L, 23,0, 7,769,
0, 9, 32, G_IBOX, NONE, NORMAL, 0x0L, 0,769, 80,19,
18, 10, 17, G_BOX, NONE, NORMAL, 0xFF1100L, 2,0, 20,8,
11, -1, -1, G_STRING, NONE, NORMAL, 0x5L, 0,0, 20,1,
12, -1, -1, G_STRING, NONE, DISABLED, 0x6L, 0,1, 20,1,
13, -1, -1, G_STRING, NONE, NORMAL, 0x7L, 0,2, 20,1,
14, -1, -1, G_STRING, NONE, NORMAL, 0x8L, 0,3, 20,1,
15, -1, -1, G_STRING, NONE, NORMAL, 0x9L, 0,4, 20,1,
16, -1, -1, G_STRING, NONE, NORMAL, 0xAL, 0,5, 20,1,
17, -1, -1, G_STRING, NONE, NORMAL, 0xBL, 0,6, 20,1,
9, -1, -1, G_STRING, NONE, NORMAL, 0xCL, 0,7, 20,1,
24, 19, 23, G_BOX, NONE, NORMAL, 0xFF1100L, 8,0, 14,5,
20, -1, -1, G_STRING, NONE, NORMAL, 0xDL, 0,0, 14,1,
21, -1, -1, G_STRING, NONE, NORMAL, 0xEL, 0,1, 14,1,
22, -1, -1, G_STRING, NONE, NORMAL, 0xFL, 0,2, 14,1,
23, -1, -1, G_STRING, NONE, NORMAL, 0x10L, 0,3, 14,1,
18, -1, -1, G_STRING, NONE, NORMAL, 0x11L, 0,4, 14,1,
28, 25, 27, G_BOX, NONE, NORMAL, 0xFF1100L, 14,0, 8,3,
26, -1, -1, G_STRING, NONE, NORMAL, 0x12L, 0,0, 8,1,
27, -1, -1, G_STRING, NONE, NORMAL, 0x13L, 0,1, 8,1,
24, -1, -1, G_STRING, NONE, NORMAL, 0x14L, 0,2, 8,1,
32, 29, 31, G_BOX, NONE, NORMAL, 0xFF1100L, 19,0, 15,3,
30, -1, -1, G_STRING, NONE, NORMAL, 0x15L, 0,0, 15,1,
31, -1, -1, G_STRING, NONE, NORMAL, 0x16L, 0,1, 15,1,
28, -1, -1, G_STRING, NONE, NORMAL, 0x17L, 0,2, 15,1,
8, 33, 36, G_BOX, NONE, NORMAL, 0xFF1100L, 25,0, 10,4,
34, -1, -1, G_STRING, NONE, NORMAL, 0x18L, 0,0, 10,1,
35, -1, -1, G_STRING, NONE, NORMAL, 0x19L, 0,1, 10,1,
36, -1, -1, G_STRING, NONE, NORMAL, 0x1AL, 0,2, 10,1,
32, -1, -1, G_STRING, LASTOB, NORMAL, 0x1BL, 0,3, 10,1,
-1, 1, 5, G_BOX, NONE, OUTLINED, 0x21100L, 0,0, 38,11,
2, -1, -1, G_STRING, NONE, NORMAL, 0x1CL, 13,2, 12,1,
3, -1, -1, G_STRING, NONE, NORMAL, 0x1DL, 14,5, 11,1,
4, -1, -1, G_STRING, NONE, NORMAL, 0x1EL, 9,7, 20,1,
5, -1, -1, G_STRING, NONE, NORMAL, 0x1FL, 10,3, 18,1,
0, -1, -1, G_BUTTON, 0x27, NORMAL, 0x20L, 14,9, 8,1};

LONG rs_trindex[] = {
0L,
37L};

struct foobar {
	WORD	dummy;
	WORD	*image;
	} rs_imdope[] = {
0};

#define NUM_STRINGS 33
#define NUM_FRSTR 0
#define NUM_IMAGES 0
#define NUM_BB 0
#define NUM_FRIMG 0
#define NUM_IB 0
#define NUM_TI 0
#define NUM_OBS 43
#define NUM_TREE 2

BYTE pname[] = "BASIC.RSC";