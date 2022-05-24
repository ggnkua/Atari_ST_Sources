#define T0OBJ 0
#define FREEBB 0
#define FREEIMG 0
#define FREESTR 23

char *rs_strings[] = {
"Resource-Previewer...",
"(c) 1994 Christian Grunenberg",
"",
"",
"Settings",
"",
"",
"Window-Dialogs",
"Flying Dialogs",
"EnhancedGEM-Resource",
"@@@@@@@@@@@@@@@@@@",
"Resource : __________________",
"P",
"Tree:",
"000",
"",
"",
"Test",
"@@@",
"Max: ___",
"9",
"Load resource...",
"Exit"};

USERBLK rs_userblks[] = {
0};


LONG rs_frstr[] = {
0};

BITBLK rs_bitblk[] = {
0};

LONG rs_frimg[] = {
0};

ICONBLK rs_iconblk[] = {
0};

CICONBLK rs_ciconblk[] = {
0};

TEDINFO rs_tedinfo[] = {
(char *)1L, (char *)2L, (char *)3L, 5, 0, 0, 0x1100, 0x0, -1, 30,1,
(char *)4L, (char *)5L, (char *)6L, 3, 0, 2, 0x1180, 0x0, -1, 9,1,
(char *)10L, (char *)11L, (char *)12L, 3, 0, 2, 0x1180, 0x0, -2, 19,30,
(char *)14L, (char *)15L, (char *)16L, 3, 0, 2, 0x1180, 0x0, -1, 4,1,
(char *)18L, (char *)19L, (char *)20L, 5, 0, 0, 0x1180, 0x0, -1, 4,9};

OBJECT rs_object[] = {
-1, 1, 26, G_BOX, NONE, OUTLINED, 0x21101L, 0,0, 35,18,
2, -1, -1, (0x9<<8)+G_IBOX, SELECTABLE, NORMAL, 0x57011180L, 33,0, 2,1,
3, -1, -1, G_STRING, NONE, NORMAL, 0x0L, 2,1, 21,1,
5, 4, 4, (0x4<<8)+G_BOX, NONE, NORMAL, 0x11100L, 1,2, 33,1,
3, -1, -1, (0xD<<8)+G_TEXT, NONE, NORMAL, 0x0L, 1,0, 1557,1,
16, 6, 14, G_BOX, NONE, NORMAL, 0x11101L, 2,4, 31,6,
7, -1, -1, (0x2<<8)+G_BOXTEXT, NONE, NORMAL, 0x1L, 1,0, 10,1,
8, -1, -1, (0x7<<8)+G_IBOX, 0x11, SELECTED, 0x57011100L, 2,1, 2,1,
10, 9, 9, G_STRING, NONE, NORMAL, 0x7L, 6,1, 14,1,
8, -1, -1, (0x8<<8)+G_IBOX, NONE, NORMAL, 0x57011100L, 0,0, 1,1,
11, -1, -1, (0x7<<8)+G_IBOX, 0x11, NORMAL, 0x57011100L, 2,2, 2,1,
13, 12, 12, G_STRING, NONE, NORMAL, 0x8L, 6,2, 14,1,
11, -1, -1, (0x8<<8)+G_IBOX, NONE, NORMAL, 0x46011100L, 0,0, 1,1,
14, -1, -1, (0x6<<8)+G_IBOX, SELECTABLE, SELECTED, 0x57011100L, 2,4, 2,1,
5, 15, 15, G_STRING, NONE, NORMAL, 0x9L, 6,4, 20,1,
14, -1, -1, (0x8<<8)+G_IBOX, NONE, NORMAL, 0x45011100L, 0,0, 1,1,
17, -1, -1, G_FBOXTEXT, NONE, NORMAL, 0x2L, 2,11, 31,1,
18, -1, -1, G_STRING, NONE, NORMAL, 0xDL, 2,13, 5,1,
19, -1, -1, G_BOXCHAR, 0x41, NORMAL, 0x2DFF1100L, 8,13, 2,1,
20, -1, -1, G_BOXTEXT, NONE, NORMAL, 0x3L, 11,13, 6,1,
21, -1, -1, G_BOXCHAR, 0x41, NORMAL, 0x2BFF1100L, 18,13, 2,1,
23, 22, 22, G_BUTTON, 0x605, DISABLED, 0x11L, 24,13, 9,1,
21, -1, -1, (0x5<<8)+G_IBOX, NONE, NORMAL, 0x54011100L, 1026,0, 1,1,
24, -1, -1, G_FTEXT, NONE, NORMAL, 0x4L, 11,14, 6,1,
26, 25, 25, G_BUTTON, 0x605, NORMAL, 0x15L, 2,16, 18,1,
24, -1, -1, (0x5<<8)+G_IBOX, NONE, NORMAL, 0x4C011100L, 1,0, 1,1,
0, 27, 27, (0x13<<8)+G_BUTTON, 0x607, NORMAL, 0x16L, 24,16, 9,1,
26, -1, -1, (0x5<<8)+G_IBOX, LASTOB, NORMAL, 0x78011100L, 1027,0, 1,1};

LONG rs_trindex[] = {
0L};

struct foobar {
	WORD 	dummy;
	WORD 	*image;
	} rs_imdope[] = {
0};

#define NUM_STRINGS 23
#define NUM_USERDEFS 0
#define NUM_FRSTR 0
#define NUM_IMAGES 0
#define NUM_BB 0
#define NUM_FRIMG 0
#define NUM_IB 0
#define NUM_CIB 0
#define NUM_TI 5
#define NUM_OBS 28
#define NUM_TREE 1

int rs_numstrings = NUM_STRINGS;
int rs_nuser = NUM_USERDEFS;
int rs_numfrstr = NUM_FRSTR;
int rs_numimages = NUM_IMAGES;
int rs_numbb = NUM_BB;
int rs_numfrimg = NUM_FRIMG;
int rs_numib = NUM_IB;
int rs_numcib = NUM_CIB;
int rs_numti = NUM_TI;
int rs_numobs = NUM_OBS;
int rs_numtree = NUM_TREE;

char pname[] = "PREV_RSC.RSC";

int _rsc_format = 1;
