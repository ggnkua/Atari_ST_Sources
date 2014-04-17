#define T0OBJX 0
#define FREEBBX 0
#define FREEIMGX 0
#define FREESTRX 7

BYTE *ws_strings[] = {
"This is a string test",
"This is a text test",
"",
"",
"This is a text test",
"",
""};

LONG ws_frstr[] = {
0};

BITBLK ws_bitblk[] = {
0};

LONG ws_frimg[] = {
0};

ICONBLK ws_iconblk[] = {
0};

TEDINFO ws_tedinfo[] = {
( char *)1L, ( char *)2L, ( char *)3L, 3, 6, 0, 0x1180, 0x0, -1, 20,1,
( char *)4L, ( char *)5L, ( char *)6L, 5, 6, 0, 0x1180, 0x0, -1, 20,1};

OBJECT ws_object[] = {
-1, 1, 3, G_BOX, LASTOB, OUTLINED, ( void *)0xFF1100L, 0,0, 34,15,
2, -1, -1, G_STRING, NONE, NORMAL, ( void *)0x0L, 1,1, 21,1,
3, -1, -1, G_TEXT, NONE, NORMAL, ( void *)0x0L, 1,2, 19,1,
0, -1, -1, G_TEXT, LASTOB, NORMAL, ( void *)0x1L, 1,3, 19,1};

LONG ws_trindex[] = {
0L};

struct foobarx {
	WORD	dummy;
	WORD	*image;
	} ws_imdope[] = {
0};

#define NUMX_STRINGS 7
#define NUMX_FRSTR 0
#define NUMX_IMAGES 0
#define NUMX_BB 0
#define NUMX_FRIMG 0
#define NUMX_IB 0
#define NUMX_TI 2
#define NUMX_OBS 4
#define NUMX_TREE 1

BYTE pxname[] = "OTHER.RSC";
