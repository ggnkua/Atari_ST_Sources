#define T0OBJ 0
#define T1OBJ 25
#define FREEBB 1
#define FREEIMG 1
#define FREESTR 18

char *rs_strings[] = {
"Settings",
"WinDials",
"Frame",
"FlyDials",
"EnhancedGEM-Resource",
"@@@@@@@@@@@@@@@",
"Resource : _______________",
"P",
"Tree",
"",
"",
"-----",
"",
"",
"Test",
"Help",
"",
""};

USERBLK rs_userblks[] = {
0};


int  IMAG0[] = {
0x0, 0x0, 0x0, 0x0, 
0x0, 0x0, 0x0, 0x0, 
0x0, 0x0, 0xFFFF, 0xFFFE, 
0x8000, 0x3, 0x9EFD, 0xE7C3, 
0x8084, 0x3, 0xBFFF, 0xFFFB, 
0xAB00, 0x6AB, 0x9F7C, 0x553, 
0xB3FF, 0xFEAB, 0x9382, 0x1D13, 
0xBFFF, 0xFE4B, 0xA1AA, 0xAD63, 
0xBF00, 0x673, 0x957B, 0xC523, 
0xAB00, 0x6AB, 0x9F7C, 0x543, 
0xB300, 0x6AB, 0x937D, 0xF553, 
0xBF00, 0x6AB, 0xA1AA, 0xAD53, 
0xBF00, 0x6FF, 0x9555, 0x4547, 
0xAB00, 0x6CE, 0x95FF, 0xFD5C, 
0x8000, 0x78, 0xFFFF, 0xFFF0, 
0x7FFF, 0xFFE0, 0x0, 0x0};

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
(char *)5L, (char *)6L, (char *)7L, 3, 0, 2, 0x1180, 0x0, -2, 16,27,
(char *)8L, (char *)9L, (char *)10L, 5, 0, 2, 0x1100, 0x0, -1, 5,1,
(char *)11L, (char *)12L, (char *)13L, 3, 0, 2, 0x1180, 0x0, -1, 6,1,
(char *)15L, (char *)16L, (char *)17L, 5, 0, 2, 0x1180, 0x0, -1, 5,1};

OBJECT rs_object[] = {
-1, 1, 24, G_BOX, NONE, OUTLINED, 0x21101L, 0,0, 32,15,
15, 2, 13, G_BOX, NONE, DRAW3D, 0xFF1101L, 2,4, 28,6,
3, -1, -1, (0x2<<8)+G_BUTTON, NONE, DRAW3D, 0x0L, 1,0, 10,1,
4, -1, -1, (0x7<<8)+G_IBOX, 0x11, SELECTED, 0x57011100L, 2,1, 2,1,
6, 5, 5, G_STRING, NONE, NORMAL, 0x1L, 6,1, 8,1,
4, -1, -1, (0x8<<8)+G_IBOX, NONE, NORMAL, 0x57011100L, 0,0, 1,1,
7, -1, -1, (0x6<<8)+G_IBOX, SELECTABLE, NORMAL, 0x57011100L, 17,1, 2,1,
9, 8, 8, G_STRING, NONE, NORMAL, 0x2L, 21,1, 5,1,
7, -1, -1, (0x8<<8)+G_IBOX, NONE, NORMAL, 0x61011100L, 2,0, 1,1,
10, -1, -1, (0x7<<8)+G_IBOX, 0x11, NORMAL, 0x57011100L, 2,2, 2,1,
12, 11, 11, G_STRING, NONE, NORMAL, 0x3L, 6,2, 8,1,
10, -1, -1, (0x8<<8)+G_IBOX, NONE, NORMAL, 0x46011100L, 0,0, 1,1,
13, -1, -1, (0x6<<8)+G_IBOX, SELECTABLE, SELECTED, 0x57011100L, 2,4, 2,1,
1, 14, 14, G_STRING, NONE, NORMAL, 0x4L, 6,4, 20,1,
13, -1, -1, (0x8<<8)+G_IBOX, NONE, NORMAL, 0x45011100L, 0,0, 1,1,
17, 16, 16, G_FBOXTEXT, 0x205, NORMAL, 0x0L, 2,1, 28,1,
15, -1, -1, (0x5<<8)+G_IBOX, NONE, NORMAL, 0x52011100L, 1,0, 1,1,
18, -1, -1, G_TEXT, NONE, NORMAL, 0x1L, 5,10, 22,1,
19, -1, -1, G_BOXCHAR, TOUCHEXIT, NORMAL, 0x4FF1100L, 2,11, 2,1,
21, 20, 20, G_BOX, TOUCHEXIT, NORMAL, 0xFF1111L, 5,11, 22,1,
19, -1, -1, G_BOXTEXT, TOUCHEXIT, NORMAL, 0x2L, 10,0, 5,1,
22, -1, -1, G_BOXCHAR, TOUCHEXIT, NORMAL, 0x3FF1100L, 28,11, 2,1,
24, 23, 23, G_BUTTON, 0x607, DISABLED, 0xEL, 21,13, 9,1,
22, -1, -1, (0x5<<8)+G_IBOX, NONE, NORMAL, 0x54011100L, 1026,0, 1,1,
0, -1, -1, (0xC<<8)+G_BOXTEXT, 0x25, 0x30, 0x3L, 2,13, 8,1,
-1, 1, 1, G_BOX, NONE, NORMAL, 0x1100L, 0,0, 8,2,
0, -1, -1, G_IMAGE, LASTOB, NORMAL, 0x0L, 2,0, 8192,8192};

LONG rs_trindex[] = {
0L,
25L};

struct foobar {
	WORD 	dummy;
	WORD 	*image;
	} rs_imdope[] = {
0, &IMAG0[0]};

#define NUM_STRINGS 18
#define NUM_USERDEFS 0
#define NUM_FRSTR 0
#define NUM_IMAGES 1
#define NUM_BB 1
#define NUM_FRIMG 0
#define NUM_IB 0
#define NUM_CIB 0
#define NUM_TI 4
#define NUM_OBS 27
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

char pname[] = "PREV_RSC.RSC";

int _rsc_format = 1;
