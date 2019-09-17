#define T0OBJ 0
#define T1OBJ 5
#define FREEBB 0
#define FREEIMG 0
#define FREESTR 7

BYTE *rs_strings[] = {
"Sample Progress Box",
"Variable Text Line",
"",
"",
"Progress Event One",
"Progress Event Two",
"Progress Event N"};

LONG rs_frstr[] = {
0};

BITBLK rs_bitblk[] = {
0};

LONG rs_frimg[] = {
0};

ICONBLK rs_iconblk[] = {
0};

TEDINFO rs_tedinfo[] = {
1L, 2L, 3L, 3, 6, 2, 0x1380, 0x0, -1, 19,1};

OBJECT rs_object[] = {
-1, 1, 3, G_BOX, NONE, OUTLINED, 0x21100L, 0,0, 41,8,
2, -1, -1, G_STRING, NONE, NORMAL, 0x0L, 11,1, 19,1,
3, -1, -1, G_TEXT, NONE, NORMAL, 0x0L, 0,3, 41,1,
0, 4, 4, G_BOX, NONE, NORMAL, 0xFF1170L, 3,5, 34,1,
3, -1, -1, G_BOX, LASTOB, NORMAL, 0xFF1172L, 0,0, 6,1,
-1, 1, 3, G_BOX, NONE, OUTLINED, 0x21100L, 0,0, 27,7,
2, -1, -1, G_STRING, NONE, NORMAL, 0x4L, 2,1, 18,1,
3, -1, -1, G_STRING, NONE, NORMAL, 0x5L, 2,3, 18,1,
0, -1, -1, G_STRING, LASTOB, NORMAL, 0x6L, 2,5, 18,1};

LONG rs_trindex[] = {
0L,
5L};

struct foobar {
	WORD	dummy;
	WORD	*image;
	} rs_imdope[] = {
0};

#define NUM_STRINGS 7
#define NUM_FRSTR 0
#define NUM_IMAGES 0
#define NUM_BB 0
#define NUM_FRIMG 0
#define NUM_IB 0
#define NUM_TI 1
#define NUM_OBS 9
#define NUM_TREE 2

BYTE pname[] = "GMCL16.RSC";