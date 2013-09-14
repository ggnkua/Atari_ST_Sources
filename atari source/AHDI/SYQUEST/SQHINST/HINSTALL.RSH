#define T0OBJ 0
#define T1OBJ 20
#define T2OBJ 26
#define T3OBJ 38
#define T4OBJ 44
#define FREEBB 0
#define FREEIMG 0
#define FREESTR 46

BYTE *rs_strings[] = {
" Desk ",
" File ",
"  About HINSTALL ...  ",
"--------------------",
"  Desk Accessory 1  ",
"  Desk Accessory 2  ",
"  Desk Accessory 3  ",
"  Desk Accessory 4  ",
"  Desk Accessory 5  ",
"  Desk Accessory 6  ",
"  Quit     ",
"  Install  ",
"-------------",
"  Remove",
"  Atari Hard Disk Installation  ",
"Copyright 1986, 1987, 1988",
"OK",
"by Atari Corporation",
"2.0",
"Version ___",
"XXX",
"UNIT 0",
"UNIT 1",
"UNIT 2",
"UNIT 3",
"UNIT 4",
"UNIT 5",
"UNIT 6",
"UNIT 7",
"OK",
"CANCEL",
"Select the physical unit",
"About to install a bootable",
"OK",
"CANCEL",
"@",
"driver in physical unit _",
"9",
"  Install Hard Disk Driver ",
"About to remove the bootable",
"OK",
"CANCEL",
"@",
"driver in physical unit _",
"9",
"  Remove Hard Disk Driver  ",
"[3][Not enough system memory!|Cannot continue.][   OK   ]",
"[3][Cannot read Root Sector|from the disk!|Try backing up the disk|an\
d reformatting it.][   OK   ]",
"[3][Cannot write Root Sector|to the disk!|Try backing up the disk|and\
 reformatting it.][   OK   ]",
"[3][Cannot read Boot Sector|from the logical drive!|Try backing up th\
e disk|and reformatting it.][   OK   ]",
"[3][Cannot write Boot Sector|to the logical drive!|Try backing up the\
 disk|and reformatting it.][   OK   ]",
"[3][Too many logical devices!|You cannot have more than|14 logical dr\
ives.][   OK   ]",
"[3][Cannot write driver|file to destination!][   OK   ]",
"[3][Cannot create driver|file at destination!][   OK   ]",
"[3][Cannot open driver|source file!][   OK   ]",
"[3][Driver file does not|exist!][   OK   ]"};

LONG rs_frstr[] = {
46L,
47L,
48L,
49L,
50L,
51L,
52L,
53L,
54L,
55L};

BITBLK rs_bitblk[] = {
0};

LONG rs_frimg[] = {
0};

ICONBLK rs_iconblk[] = {
0};

TEDINFO rs_tedinfo[] = {
18L, 19L, 20L, 3, 6, 0, 0x1180, 0x0, -1, 4,12,
35L, 36L, 37L, 3, 6, 0, 0x1180, 0x0, -1, 2,26,
42L, 43L, 44L, 3, 6, 0, 0x1180, 0x0, -1, 2,26};

OBJECT rs_object[] = {
-1, 1, 5, G_IBOX, NONE, NORMAL, 0x0L, 0,0, 80,25,
5, 2, 2, G_BOX, NONE, NORMAL, 0x1100L, 0,0, 80,513,
1, 3, 4, G_IBOX, NONE, NORMAL, 0x0L, 2,0, 12,769,
4, -1, -1, G_TITLE, NONE, NORMAL, 0x0L, 0,0, 6,769,
2, -1, -1, G_TITLE, NONE, NORMAL, 0x1L, 6,0, 6,769,
0, 6, 15, G_IBOX, NONE, NORMAL, 0x0L, 0,769, 80,19,
15, 7, 14, G_BOX, NONE, NORMAL, 0xFF1100L, 2,0, 20,8,
8, -1, -1, G_STRING, NONE, NORMAL, 0x2L, 0,0, 20,1,
9, -1, -1, G_STRING, NONE, DISABLED, 0x3L, 0,1, 20,1,
10, -1, -1, G_STRING, NONE, NORMAL, 0x4L, 0,2, 20,1,
11, -1, -1, G_STRING, NONE, NORMAL, 0x5L, 0,3, 20,1,
12, -1, -1, G_STRING, NONE, NORMAL, 0x6L, 0,4, 20,1,
13, -1, -1, G_STRING, NONE, NORMAL, 0x7L, 0,5, 20,1,
14, -1, -1, G_STRING, NONE, NORMAL, 0x8L, 0,6, 20,1,
6, -1, -1, G_STRING, NONE, NORMAL, 0x9L, 0,7, 20,1,
5, 16, 19, G_BOX, NONE, NORMAL, 0xFF1100L, 8,0, 13,4,
17, -1, -1, G_STRING, NONE, NORMAL, 0xAL, 0,3, 13,1,
18, -1, -1, G_STRING, NONE, NORMAL, 0xBL, 0,0, 13,1,
19, -1, -1, G_STRING, NONE, DISABLED, 0xCL, 0,2, 13,1,
15, -1, -1, G_STRING, LASTOB, NORMAL, 0xDL, 0,1, 13,1,
-1, 1, 5, G_BOX, NONE, OUTLINED, 0x21100L, 0,0, 40,12,
2, -1, -1, G_STRING, NONE, NORMAL, 0xEL, 2,2, 36,1,
3, -1, -1, G_STRING, NONE, NORMAL, 0xFL, 7,5, 26,1,
4, -1, -1, G_BUTTON, 0x7, NORMAL, 0x10L, 16,9, 8,1,
5, -1, -1, G_STRING, NONE, NORMAL, 0x11L, 10,6, 20,1,
0, -1, -1, G_FTEXT, LASTOB, NORMAL, 0x0L, 15,3, 11,1,
-1, 1, 11, G_BOX, NONE, OUTLINED, 0x21100L, 0,0, 37,12,
2, -1, -1, G_BUTTON, 0x11, DISABLED, 0x15L, 1,4, 8,1,
3, -1, -1, G_BUTTON, 0x11, DISABLED, 0x16L, 10,4, 8,1,
4, -1, -1, G_BUTTON, 0x11, DISABLED, 0x17L, 19,4, 8,1,
5, -1, -1, G_BUTTON, 0x11, DISABLED, 0x18L, 28,4, 8,1,
6, -1, -1, G_BUTTON, 0x11, DISABLED, 0x19L, 1,6, 8,1,
7, -1, -1, G_BUTTON, 0x11, DISABLED, 0x1AL, 10,6, 8,1,
8, -1, -1, G_BUTTON, 0x11, DISABLED, 0x1BL, 19,6, 8,1,
9, -1, -1, G_BUTTON, 0x11, DISABLED, 0x1CL, 28,6, 8,1,
10, -1, -1, G_BUTTON, 0x41, NORMAL, 0x1DL, 7,9, 8,1,
11, -1, -1, G_BUTTON, 0x43, NORMAL, 0x1EL, 23,9, 8,1,
0, -1, -1, G_STRING, LASTOB, NORMAL, 0x1FL, 7,2, 24,1,
-1, 1, 5, G_BOX, NONE, OUTLINED, 0x21100L, 0,0, 37,12,
2, -1, -1, G_STRING, NONE, NORMAL, 0x20L, 5,5, 27,1,
3, -1, -1, G_BUTTON, 0x5, NORMAL, 0x21L, 5,9, 8,1,
4, -1, -1, G_BUTTON, 0x7, NORMAL, 0x22L, 24,9, 8,1,
5, -1, -1, G_FTEXT, NONE, NORMAL, 0x1L, 6,6, 25,1,
0, -1, -1, G_STRING, LASTOB, NORMAL, 0x26L, 3,2, 31,1,
-1, 1, 5, G_BOX, NONE, OUTLINED, 0x21100L, 0,0, 38,12,
2, -1, -1, G_STRING, NONE, NORMAL, 0x27L, 5,5, 28,1,
3, -1, -1, G_BUTTON, 0x5, NORMAL, 0x28L, 5,9, 8,1,
4, -1, -1, G_BUTTON, 0x7, NORMAL, 0x29L, 25,9, 8,1,
5, -1, -1, G_FTEXT, NONE, NORMAL, 0x2L, 7,6, 25,1,
0, -1, -1, G_STRING, LASTOB, NORMAL, 0x2DL, 4,2, 31,1};

LONG rs_trindex[] = {
0L,
20L,
26L,
38L,
44L};

struct foobar {
	WORD	dummy;
	WORD	*image;
	} rs_imdope[] = {
0};

#define NUM_STRINGS 56
#define NUM_FRSTR 10
#define NUM_IMAGES 0
#define NUM_BB 0
#define NUM_FRIMG 0
#define NUM_IB 0
#define NUM_TI 3
#define NUM_OBS 50
#define NUM_TREE 5

BYTE pname[] = "HINSTALL.RSC";