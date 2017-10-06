#define T0OBJ 0
#define T1OBJ 18
#define FREEBB 1
#define FREEIMG 1
#define FREESTR 22

char *rs_strings[] = {
"New",
"",
"",
"Load",
"Switchs",
"",
"",
"123",
"",
"",
"Blocksize",
"",
"",
"12",
"",
"",
"Help",
"",
"",
"PlayIt!",
"",
""};

USERBLK rs_userblks[] = {
0};


int  IMAG0[] = {
0x0, 0x0, 0x3E0, 0x0, 
0x417, 0x8000, 0x9C8, 0x6400, 
0xBE0, 0x1B00, 0xBCF, 0x6500, 
0x590, 0x9D00, 0x206, 0xD00, 
0x106, 0x6200, 0x100, 0x6400, 
0x101, 0xC00, 0x8D, 0x8800, 
0x144, 0x2800, 0x227, 0xD000, 
0x410, 0x2C00, 0x80F, 0xC200, 
0xC00, 0x200, 0x1200, 0x1200, 
0x1200, 0x1200, 0x1200, 0x1200, 
0x1200, 0x1200, 0x1200, 0x1200, 
0x1300, 0x1200, 0x1280, 0x2C00, 
0x1260, 0x4300, 0x12F7, 0xC780, 
0x13F8, 0x4F80, 0xDF8, 0x4F80, 
0x1F8, 0x2F80, 0x1F0, 0x1F00, 
0x1F0, 0x600, 0xF0, 0x0};

LONG rs_frstr[] = {
0};

BITBLK rs_bitblk[] = {
(WORD *)0L, 4, 32, 0, 0, 1};

LONG rs_frimg[] = {
0};

ICONBLK rs_iconblk[] = {
0};

CICONBLK rs_ciconblk[] = {
0};

TEDINFO rs_tedinfo[] = {
(char *)0L, (char *)1L, (char *)2L, 3, 0, 2, 0x1180, 0x0, -2, 4,1,
(char *)4L, (char *)5L, (char *)6L, 5, 0, 2, 0x1100, 0x0, -1, 8,1,
(char *)7L, (char *)8L, (char *)9L, 3, 0, 2, 0x1180, 0x0, 0, 4,1,
(char *)10L, (char *)11L, (char *)12L, 5, 0, 2, 0x1100, 0x0, -1, 10,1,
(char *)13L, (char *)14L, (char *)15L, 3, 0, 2, 0x1180, 0x0, 0, 3,1,
(char *)16L, (char *)17L, (char *)18L, 5, 0, 2, 0x1180, 0x0, -1, 5,1,
(char *)19L, (char *)20L, (char *)21L, 5, 0, 2, 0x1100, 0x0, -1, 8,1};

OBJECT rs_object[] = {
-1, 1, 17, G_BOX, NONE, OUTLINED, 0x21100L, 0,0, 51,20,
17, 2, 16, G_BOX, 0x400, NORMAL, 0x21101L, 0,0, 11,20,
4, 3, 3, G_BOXTEXT, 0x641, DISABLED, 0x0L, 2,1, 7,1,
2, -1, -1, (0x5<<8)+G_IBOX, NONE, NORMAL, 0x4E011100L, 2,0, 1,1,
6, 5, 5, G_BUTTON, 0x605, NORMAL, 0x3L, 2,3, 7,1,
4, -1, -1, (0x5<<8)+G_IBOX, NONE, NORMAL, 0x4C011100L, 2,0, 1,1,
7, -1, -1, G_TEXT, NONE, NORMAL, 0x1L, 1,5, 9,1,
8, -1, -1, G_BOXCHAR, NONE, NORMAL, 0x4FF1100L, 1,6, 2,1,
10, 9, 9, G_BOX, NONE, NORMAL, 0xFF1100L, 4,6, 3,1,
8, -1, -1, G_BOXTEXT, NONE, NORMAL, 0x2L, 0,0, 3,1,
11, -1, -1, G_BOXCHAR, NONE, NORMAL, 0x3FF1100L, 8,6, 2,1,
12, -1, -1, G_TEXT, NONE, NORMAL, 0x3L, 1,8, 9,1,
13, -1, -1, G_BOXCHAR, NONE, NORMAL, 0x2DFF1100L, 1,9, 2,1,
15, 14, 14, G_BOX, NONE, NORMAL, 0xFF1100L, 4,9, 3,1,
13, -1, -1, G_BOXTEXT, NONE, NORMAL, 0x4L, 0,0, 3,1,
16, -1, -1, G_BOXCHAR, NONE, NORMAL, 0x2BFF1100L, 8,9, 2,1,
1, -1, -1, (0xC<<8)+G_BOXTEXT, 0x5, 0x30, 0x5L, 3,18, 5,1,
0, -1, -1, G_IBOX, 0x60, NORMAL, 0x11100L, 11,0, 40,20,
-1, 1, 2, G_BOX, NONE, NORMAL, 0x1100L, 0,0, 8,5,
2, -1, -1, G_IMAGE, NONE, NORMAL, 0x0L, 2,1, 8192,8192,
0, -1, -1, G_TEXT, LASTOB, NORMAL, 0x6L, 0,3, 8,1};

LONG rs_trindex[] = {
0L,
18L};

struct foobar {
	WORD 	dummy;
	WORD 	*image;
	} rs_imdope[] = {
0, &IMAG0[0]};

#define NUM_STRINGS 22
#define NUM_USERDEFS 0
#define NUM_FRSTR 0
#define NUM_IMAGES 1
#define NUM_BB 1
#define NUM_FRIMG 0
#define NUM_IB 0
#define NUM_CIB 0
#define NUM_TI 7
#define NUM_OBS 21
#define NUM_TREE 2

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

char pname[] = "PLAY_RSC.RSC";

int _rsc_format = 1;
