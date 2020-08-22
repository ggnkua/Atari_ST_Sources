#include <aes.h>

static char string_0[] = "-RESOLUTIONS:";
static char string_1[] = "";
static char string_2[] = "";
static char string_3[] = "(c) 1993 Georg Acher & Michael Eberl";
static char string_4[] = "";
static char string_5[] = "";
static char string_6[] = "xxxx*yyyy";
static char string_7[] = "xxxx*yyyy";
static char string_8[] = "OFF";
static char string_9[] = "";
static char string_10[] = "2";
static char string_11[] = "";
static char string_12[] = "xxxx*yyyy";
static char string_13[] = "xxxx*yyyy";
static char string_14[] = "OFF";
static char string_15[] = "";
static char string_16[] = "4";
static char string_17[] = "";
static char string_18[] = "xxxx*yyyy";
static char string_19[] = "xxxx*yyyy";
static char string_20[] = "OFF";
static char string_21[] = "";
static char string_22[] = "16";
static char string_23[] = "";
static char string_24[] = "xxxx*yyyy";
static char string_25[] = "xxxx*yyyy";
static char string_26[] = "OFF";
static char string_27[] = "";
static char string_28[] = "256";
static char string_29[] = "";
static char string_30[] = "xxxx*yyyy";
static char string_31[] = "xxxx*yyyy";
static char string_32[] = "OFF";
static char string_33[] = "";
static char string_34[] = "TC";
static char string_35[] = "";
static char string_36[] = "SAVE";
static char string_37[] = "Saver";
static char string_38[] = "";
static char string_39[] = "";
static char string_40[] = "ON";
static char string_41[] = "";
static char string_42[] = "";
static char string_43[] = "[3][Can\'t save to your|bootdevice.][   OK   ]";


static int IMAGE0[] = {
0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 
0x0000, 0x0000, 0x0000, 0x0010, 0xE79C, 0x0000, 0x0000, 0x0000, 
0x01F8, 0xE79C, 0x0000, 0x0000, 0x0000, 0x03FC, 0xE79C, 0x0070, 
0x0000, 0x0001, 0x83FE, 0xE79C, 0x00F0, 0x0000, 0x0003, 0x87FE, 
0xE79C, 0x01F3, 0xC000, 0x0063, 0xEF0E, 0xE79C, 0x0275, 0xD800, 
0x03FB, 0xAE8E, 0xE79C, 0x0275, 0xDF00, 0x07FB, 0x9E8E, 0xE79C, 
0x0479, 0xDF80, 0x07FB, 0x8E4E, 0xE79C, 0x0879, 0xDFC0, 0x07BB, 
0x8E5E, 0xE79C, 0x0871, 0xDFC0, 0x0773, 0x8F3E, 0xFFFC, 0x3071, 
0xDCE0, 0x077B, 0x8FFC, 0xFFFC, 0x2071, 0xDCE0, 0x077B, 0xAFF8, 
0x7FF8, 0x4071, 0xDDE0, 0x077B, 0xE7F8, 0x7DF8, 0x807B, 0xDDE0, 
0x073B, 0xE1E4, 0x4108, 0x803F, 0xDDE0, 0x077B, 0xE0B2, 0x2111, 
0x003F, 0xDC80, 0x0771, 0xD04A, 0x2111, 0x014F, 0x9C00, 0x0770, 
0xEE35, 0x2112, 0x0281, 0x1C00, 0x077D, 0x190D, 0x1124, 0x0417, 
0x5C00, 0x0702, 0xA686, 0x9124, 0x283F, 0xFC00, 0x05E8, 0x59F3, 
0x5148, 0x53FF, 0xA000, 0x0017, 0xA75A, 0xC950, 0x87E8, 0x0000, 
0x0000, 0x5AFD, 0x6A51, 0x7E80, 0x0000, 0x0000, 0x05AF, 0xEAA6, 
0xF800, 0x0000, 0x0000, 0x007F, 0xFAEB, 0x8000, 0x0000, 0x0000, 
0x0007, 0xFEFE, 0x0000, 0x0000, 0x0000, 0x0001, 0xFFF8, 0x0000, 
0x0000, 0x0000, 0x0000, 0x7FE0, 0x0000, 0x0000, 0x0000, 0x0000, 
0x1F80, 0x0000, 0x0000, 0x0000, 0x0000, 0x0600, 0x0000, 0x0000};


char *rs_frstr[] = {
	string_43,
};


static BITBLK rs_bitblk[] = {
	{ IMAGE0, 10, 32, 0, 0, 1 },
};


BITBLK *rs_frimg[] = {
0
};


static TEDINFO rs_tedinfo[] = {
	{ string_0, string_1, string_2, 3, 6, 0, 0x1100, 0x0, -1, 14,1 },
	{ string_3, string_4, string_5, 5, 6, 2, 0x1100, 0x0, -1, 37,1 },
	{ string_9, string_10, string_11, 5, 6, 0, 0x1100, 0x0, 0, 1,2 },
	{ string_15, string_16, string_17, 5, 6, 0, 0x1100, 0x0, 0, 1,2 },
	{ string_21, string_22, string_23, 5, 6, 0, 0x1100, 0x0, 0, 1,3 },
	{ string_27, string_28, string_29, 5, 6, 0, 0x1100, 0x0, 0, 1,4 },
	{ string_33, string_34, string_35, 5, 6, 0, 0x1100, 0x0, 0, 1,3 },
	{ string_37, string_38, string_39, 5, 6, 0, 0x1100, 0x0, -1, 6,1 },
	{ string_40, string_41, string_42, 3, 6, 2, 0x1180, 0x0, -1, 3,1 },
};


OBJECT rs_object[] = {
/* TREE1 */

	{ -1, 1, 32, G_BOX, 0x200, OUTLINED, (long)(0x1180L), 0,0, 1820,11 },
	{ 2, -1, -1, G_IMAGE, NONE, NORMAL, (long)(&rs_bitblk[0]), 0,0, 20480,8192 },
	{ 3, -1, -1, G_TEXT, NONE, NORMAL, (long)(&rs_tedinfo[0]), 10,1792, 13,1 },
	{ 4, -1, -1, G_TEXT, NONE, NORMAL, (long)(&rs_tedinfo[1]), 1536,2, 27,2304 },
	{ 30, 5, 29, G_BOX, NONE, NORMAL, (long)(0xFF1101L), 1,2306, 539,7 },
	{ 9, 6, 8, G_IBOX, NONE, NORMAL, (long)(0x11100L), 515,768, 535,513 },
	{ 7, -1, -1, G_BUTTON, SELECTABLE|RBUTTON|TOUCHEXIT|0x200, NORMAL, (long)(string_6), 0,256, 1289,1 },
	{ 8, -1, -1, G_BUTTON, SELECTABLE|RBUTTON|TOUCHEXIT|0x200, NORMAL, (long)(string_7), 1545,256, 1033,1 },
	{ 5, -1, -1, G_BUTTON, SELECTABLE|RBUTTON|TOUCHEXIT|0x200, SELECTED, (long)(string_8), 787,256, 1539,1 },
	{ 10, -1, -1, G_FBOXTEXT, NONE, NORMAL, (long)(&rs_tedinfo[2]), 1536,2560, 769,3328 },
	{ 14, 11, 13, G_IBOX, NONE, NORMAL, (long)(0x11100L), 515,2305, 535,513 },
	{ 12, -1, -1, G_BUTTON, SELECTABLE|RBUTTON|TOUCHEXIT|0x200, NORMAL, (long)(string_12), 0,256, 1289,1 },
	{ 13, -1, -1, G_BUTTON, SELECTABLE|RBUTTON|TOUCHEXIT|0x200, NORMAL, (long)(string_13), 1545,256, 1033,1 },
	{ 10, -1, -1, G_BUTTON, SELECTABLE|RBUTTON|TOUCHEXIT|0x200, SELECTED, (long)(string_14), 787,256, 1539,1 },
	{ 15, -1, -1, G_FBOXTEXT, NONE, NORMAL, (long)(&rs_tedinfo[3]), 1536,3329, 1536,1 },
	{ 19, 16, 18, G_IBOX, NONE, NORMAL, (long)(0x11100L), 515,3842, 535,513 },
	{ 17, -1, -1, G_BUTTON, SELECTABLE|RBUTTON|TOUCHEXIT|0x200, NORMAL, (long)(string_18), 0,256, 1289,1 },
	{ 18, -1, -1, G_BUTTON, SELECTABLE|RBUTTON|TOUCHEXIT|0x200, NORMAL, (long)(string_19), 1545,256, 1033,1 },
	{ 15, -1, -1, G_BUTTON, SELECTABLE|RBUTTON|TOUCHEXIT|0x200, SELECTED, (long)(string_20), 787,256, 1539,1 },
	{ 20, -1, -1, G_FBOXTEXT, NONE, NORMAL, (long)(&rs_tedinfo[4]), 768,515, 2,3840 },
	{ 24, 21, 23, G_IBOX, NONE, NORMAL, (long)(0x11100L), 515,1284, 535,513 },
	{ 22, -1, -1, G_BUTTON, SELECTABLE|RBUTTON|TOUCHEXIT|0x200, NORMAL, (long)(string_24), 0,256, 1289,1 },
	{ 23, -1, -1, G_BUTTON, SELECTABLE|RBUTTON|TOUCHEXIT|0x200, NORMAL, (long)(string_25), 1545,256, 1033,1 },
	{ 20, -1, -1, G_BUTTON, SELECTABLE|RBUTTON|TOUCHEXIT|0x200, SELECTED, (long)(string_26), 787,256, 1539,1 },
	{ 25, -1, -1, G_FBOXTEXT, NONE, NORMAL, (long)(&rs_tedinfo[5]), 1024,1796, 514,3072 },
	{ 29, 26, 28, G_IBOX, NONE, NORMAL, (long)(0x11100L), 515,2821, 535,513 },
	{ 27, -1, -1, G_BUTTON, SELECTABLE|RBUTTON|TOUCHEXIT|0x200, NORMAL, (long)(string_30), 0,256, 1289,1 },
	{ 28, -1, -1, G_BUTTON, SELECTABLE|RBUTTON|TOUCHEXIT|0x200, NORMAL, (long)(string_31), 1545,256, 1033,1 },
	{ 25, -1, -1, G_BUTTON, SELECTABLE|RBUTTON|TOUCHEXIT|0x200, SELECTED, (long)(string_32), 787,256, 1539,1 },
	{ 4, -1, -1, G_FBOXTEXT, NONE, NORMAL, (long)(&rs_tedinfo[6]), 1280,2821, 2,257 },
	{ 31, -1, -1, G_BUTTON, SELECTABLE|0x200, NORMAL, (long)(string_36), 1,3593, 264,1 },
	{ 32, -1, -1, G_TEXT, NONE, NORMAL, (long)(&rs_tedinfo[7]), 789,10, 1539,3328 },
	{ 0, -1, -1, G_BOXTEXT, SELECTABLE|LASTOB, NORMAL, (long)(&rs_tedinfo[8]), 1561,3593, 2,1 },
};


OBJECT *rs_trindex[] = {
	&rs_object[0],
};


int rs_numstrings = 44;
int rs_nuser = 0;
int rs_numfrstr = 1;
int rs_numimages = 1;
int rs_numbb = 1;
int rs_numfrimg = 0;
int rs_numib = 0;
int rs_numti = 9;
int rs_numobs = 33;
int rs_numtree = 1;

char rs_name[] = "BLOWACC.RSC";
