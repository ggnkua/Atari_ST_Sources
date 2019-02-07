#define T0OBJ 0
#define FREEBB 0
#define FREEIMG 0
#define FREESTR 9

BYTE *rs_strings[] = {
"Floppy Speed Tester",
"Your drive should be spinning at 300 RPM.",
"message here",
"RPM =",
"123",
"Drive A",
"Quit",
"Drive B",
"version 1.3"};

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
-1, 1, 9, G_BOX, NONE, OUTLINED, 0x21100L, 0,0, 46,21,
2, -1, -1, G_STRING, NONE, NORMAL, 0x0L, 14,2, 19,1,
3, -1, -1, G_STRING, NONE, NORMAL, 0x1L, 3,7, 41,1,
4, -1, -1, G_STRING, NONE, NORMAL, 0x2L, 11,10, 12,1,
5, -1, -1, G_STRING, NONE, NORMAL, 0x3L, 17,13, 6,1,
6, -1, -1, G_STRING, NONE, NORMAL, 0x4L, 24,13, 4,1,
7, -1, -1, G_BUTTON, 0x5, NORMAL, 0x5L, 5,18, 8,1,
8, -1, -1, G_BUTTON, 0x5, NORMAL, 0x6L, 19,18, 8,1,
9, -1, -1, G_BUTTON, 0x5, NORMAL, 0x7L, 33,18, 8,1,
0, -1, -1, G_STRING, LASTOB, NORMAL, 0x8L, 18,3, 11,1};

LONG rs_trindex[] = {
0L};

struct foobar {
	WORD	dummy;
	WORD	*image;
	} rs_imdope[] = {
0};

#define NUM_STRINGS 9
#define NUM_FRSTR 0
#define NUM_IMAGES 0
#define NUM_BB 0
#define NUM_FRIMG 0
#define NUM_IB 0
#define NUM_TI 0
#define NUM_OBS 10
#define NUM_TREE 1

BYTE pname[] = "SPEED.RSC";