#define T0OBJ 0
#define FREEBB 0
#define FREEIMG 0
#define FREESTR 37

char *rs_strings[] = {
" 1. Titel 12345678",
"",
"",
"1. BUTO",
"",
"",
"123456789112345678",
"",
"",
"2. BUTO",
"",
"",
"123456789012345678",
"",
"",
"3. BUTO",
"",
"",
"123456789012345678",
"",
"",
"4. BUTO",
"",
"",
"OK",
" Abbruch ",
"",
"",
"Sichern",
"",
"",
"NEC Power (NEC P20/30)",
"",
"",
"\xbd" " Copyright 1993 by Maxon GmbH",
"",
""};

long rs_frstr[] = {
0};

BITBLK rs_bitblk[] = {
0};

long rs_frimg[] = {
0};

ICONBLK rs_iconblk[] = {
0};

TEDINFO rs_tedinfo[] = {
(char *)0L, (char *)1L, (char *)2L, 3, 6, 0, 0x1180, 0x0, -1, 19,1,
(char *)3L, (char *)4L, (char *)5L, 3, 6, 2, 0x1180, 0x0, -1, 8,1,
(char *)6L, (char *)7L, (char *)8L, 3, 6, 0, 0x1180, 0x0, -1, 19,1,
(char *)9L, (char *)10L, (char *)11L, 3, 6, 2, 0x1180, 0x0, -1, 8,1,
(char *)12L, (char *)13L, (char *)14L, 3, 6, 0, 0x1180, 0x0, -1, 19,1,
(char *)15L, (char *)16L, (char *)17L, 3, 6, 2, 0x1180, 0x0, -1, 8,1,
(char *)18L, (char *)19L, (char *)20L, 3, 6, 0, 0x1180, 0x0, -1, 19,1,
(char *)21L, (char *)22L, (char *)23L, 3, 6, 2, 0x1180, 0x0, -1, 8,1,
(char *)25L, (char *)26L, (char *)27L, 3, 6, 2, 0x1180, 0x0, -2, 10,1,
(char *)28L, (char *)29L, (char *)30L, 3, 6, 2, 0x1180, 0x0, -2, 8,1,
(char *)31L, (char *)32L, (char *)33L, 3, 6, 2, 0x1180, 0x0, -1, 23,1,
(char *)34L, (char *)35L, (char *)36L, 5, 6, 2, 0x1180, 0x0, -1, 31,1};

OBJECT rs_object[] = {
-1, 1, 21, G_BOX, NONE, NORMAL, 0x1181L, 0,0, 288,267,
15, 2, 14, G_BOX, NONE, NORMAL, 0xFF1141L, 0,3585, 32,1543,
3, -1, -1, G_BOXCHAR, TOUCHEXIT, NORMAL, 0x1011101L, 541,1280, 514,513,
12, 4, 10, G_BOX, NONE, NORMAL, 0xFF1101L, 1280,1536, 1819,2822,
6, 5, 5, G_BOXTEXT, TOUCHEXIT, NORMAL, 0x0L, 0,0, 1819,2561,
4, -1, -1, G_BOXTEXT, TOUCHEXIT, SHADOWED, 0x1L, 1554,768, 1544,513,
8, 7, 7, G_BOXTEXT, TOUCHEXIT, NORMAL, 0x2L, 0,2817, 1819,2561,
6, -1, -1, G_BOXTEXT, TOUCHEXIT, SHADOWED, 0x3L, 1554,768, 1544,513,
10, 9, 9, G_BOXTEXT, TOUCHEXIT, NORMAL, 0x4L, 0,1539, 1819,2561,
8, -1, -1, G_BOXTEXT, TOUCHEXIT, SHADOWED, 0x5L, 1554,768, 1544,513,
3, 11, 11, G_BOXTEXT, TOUCHEXIT, NORMAL, 0x6L, 0,261, 1819,2561,
10, -1, -1, G_BOXTEXT, TOUCHEXIT, SHADOWED, 0x7L, 1810,768, 1544,513,
14, 13, 13, G_BOX, TOUCHEXIT, NORMAL, 0xFF1111L, 797,1793, 2,2308,
12, -1, -1, G_BOX, TOUCHEXIT, NORMAL, 0xFF1101L, 0,0, 2,1,
1, -1, -1, G_BOXCHAR, TOUCHEXIT, NORMAL, 0x2011101L, 541,6, 514,513,
18, 16, 17, G_IBOX, NONE, NORMAL, 0x11100L, 1290,1033, 1045,3329,
17, -1, -1, G_BUTTON, 0x7, NORMAL, 0x18L, 1025,1536, 8,1,
15, -1, -1, G_BOXTEXT, 0x5, NORMAL, 0x8L, 523,1536, 9,1,
20, 19, 19, G_BOX, NONE, NORMAL, 0xFF1101L, 0,1289, 1290,2817,
18, -1, -1, G_BOXTEXT, 0x5, NORMAL, 0x9L, 769,1280, 8,1,
21, -1, -1, G_TEXT, NONE, NORMAL, 0xAL, 0,768, 32,1,
0, -1, -1, G_TEXT, LASTOB, NORMAL, 0xBL, 0,1025, 32,2048};

long rs_trindex[] = {
0L};

struct foobar {
	int 	dummy;
	int 	*image;
	} rs_imdope[] = {
0};

#define NUM_STRINGS 37
#define NUM_FRSTR 0
#define NUM_IMAGES 0
#define NUM_BB 0
#define NUM_FRIMG 0
#define NUM_IB 0
#define NUM_TI 12
#define NUM_OBS 22
#define NUM_TREE 1

char pname[] = "NEC_RSCM.RSC";
