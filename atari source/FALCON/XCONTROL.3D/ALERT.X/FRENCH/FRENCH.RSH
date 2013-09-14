#define T0OBJ 0
#define FREEBB 1
#define FREEIMG 1
#define FREESTR 6

BYTE *as_strings[] = {
"CONFIRME",
"CONFIRME",
"Annule",
"012345678901234567",
"012345678901234567",
"012345678901234567"};

WORD AIMAG0[] = {
0x3, 0xC000, 0x6, 0x6000, 
0xD, 0xB000, 0x1B, 0xD800, 
0x37, 0xEC00, 0x6F, 0xF600, 
0xDC, 0x3B00, 0x1BC, 0x3D80, 
0x37C, 0x3EC0, 0x6FC, 0x3F60, 
0xDFC, 0x3FB0, 0x1BFC, 0x3FD8, 
0x37FC, 0x3FEC, 0x6FFC, 0x3FF6, 
0xDFFC, 0x3FFB, 0xBFFC, 0x3FFD, 
0xBFFC, 0x3FFD, 0xDFFC, 0x3FFB, 
0x6FFC, 0x3FF6, 0x37FC, 0x3FEC, 
0x1BFF, 0xFFD8, 0xDFF, 0xFFB0, 
0x6FC, 0x3F60, 0x37C, 0x3EC0, 
0x1BC, 0x3D80, 0xDC, 0x3B00, 
0x6F, 0xF600, 0x37, 0xEC00, 
0x1B, 0xD800, 0xD, 0xB000, 
0x6, 0x6000, 0x3, 0xC000};

LONG as_frstr[] = {
0};

BITBLK as_bitblk[] = {
0L, 4, 32, 0, 0, 1};

LONG as_frimg[] = {
0};

ICONBLK as_iconblk[] = {
0};

TEDINFO as_tedinfo[] = {
0};

OBJECT as_object[] = {
-1, 1, 7, G_BOX, NONE, OUTLINED, 0x11100L, 0,0, 24,8,
2, -1, -1, G_IMAGE, NONE, NORMAL, 0x0L, 1,1, 4,2,
3, -1, -1, G_BUTTON, 0x7, NORMAL, 0x0L, 2,6, 9,1,
4, -1, -1, G_BUTTON, 0x7, NORMAL, 0x1L, 7,6, 10,1,
5, -1, -1, G_BUTTON, 0x5, NORMAL, 0x2L, 13,6, 9,1,
6, -1, -1, G_STRING, NONE, NORMAL, 0x3L, 6,1, 18,1,
7, -1, -1, G_STRING, NONE, NORMAL, 0x4L, 6,2, 18,1,
0, -1, -1, G_STRING, LASTOB, NORMAL, 0x5L, 6,3, 18,1};

LONG as_trindex[] = {
0L};

struct foobar {
	WORD	dummy;
	WORD	*image;
	} as_imdope[] = {
0, &AIMAG0[0]};

#define NUM_STRINGS 6
#define NUM_FRSTR 0
#define NUM_IMAGES 1
#define NUM_BB 1
#define NUM_FRIMG 0
#define NUM_IB 0
#define NUM_TI 0
#define NUM_OBS 8
#define NUM_TREE 1

BYTE apname[] = "FRENCH.RSC";

