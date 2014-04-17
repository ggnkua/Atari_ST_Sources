#define T0OBJ 0
#define T1OBJ 55
#define T2OBJ 58
#define FREEBB 0
#define FREEIMG 0
#define FREESTR 59

BYTE *rs_strings[] = {
"Couleur",
"",
"",
"",
"",
"",
"000",
"",
"",
"",
"",
"",
"",
"",
"",
"",
"",
"",
"",
"",
"",
"0000",
"",
"",
"0000",
"",
"",
"0000",
"",
"",
"",
"",
"",
"",
"",
"",
"",
"",
"",
"R‚init.",
"",
"",
"Sauve",
"",
"",
"Confirmer",
"",
"",
"Annuler",
"",
"",
"000",
"___",
"999",
"",
"0000",
"____",
"9999",
""};

LONG rs_frstr[] = {
0};

BITBLK rs_bitblk[] = {
0};

LONG rs_frimg[] = {
0};

ICONBLK rs_iconblk[] = {
0};

TEDINFO rs_tedinfo[] = {
(char*)0L, (char*)1L, (char*)2L, 3, 6, 2, 0x1180, 0x0, -1, 8,1,
(char*)3L, (char*)4L, (char*)5L, 3, 6, 2, 0x1180, 0x0, -1, 2,1,
(char*)6L, (char*)7L, (char*)8L, 3, 6, 2, 0x1180, 0x0, -1, 4,1,
(char*)9L, (char*)10L, (char*)11L, 3, 6, 2, 0x1180, 0x0, -1, 2,1,
(char*)12L, (char*)13L, (char*)14L, 3, 6, 2, 0x1180, 0x0, -1, 2,1,
(char*)15L, (char*)16L, (char*)17L, 3, 6, 2, 0x1180, 0x0, -1, 2,1,
(char*)18L, (char*)19L, (char*)20L, 3, 6, 2, 0x1180, 0x0, -1, 2,1,
(char*)21L, (char*)22L, (char*)23L, 3, 6, 2, 0x1180, 0x0, -1, 5,1,
(char*)24L, (char*)25L, (char*)26L, 3, 6, 2, 0x1180, 0x0, -1, 5,1,
(char*)27L, (char*)28L, (char*)29L, 3, 6, 2, 0x1180, 0x0, -1, 5,1,
(char*)30L, (char*)31L, (char*)32L, 3, 6, 2, 0x1180, 0x0, -1, 2,1,
(char*)33L, (char*)34L, (char*)35L, 3, 6, 2, 0x1180, 0x0, -1, 2,1,
(char*)36L, (char*)37L, (char*)38L, 3, 6, 2, 0x1180, 0x0, -1, 2,1,
(char*)39L, (char*)40L, (char*)41L, 3, 6, 2, 0x1180, 0x0, -1, 8,1,
(char*)42L, (char*)43L, (char*)44L, 3, 6, 2, 0x1180, 0x0, -1, 6,1,
(char*)45L, (char*)46L, (char*)47L, 3, 6, 2, 0x1180, 0x0, -2, 10,1,
(char*)48L, (char*)49L, (char*)50L, 3, 6, 2, 0x1180, 0x0, -1, 8,1,
(char*)51L, (char*)52L, (char*)53L, 3, 6, 2, 0x1180, 0x0, -1, 4,4,
(char*)55L, (char*)56L, (char*)57L, 3, 6, 2, 0x1180, 0x0, -1, 5,5};

OBJECT rs_object[] = {
-1, 1, 49, G_BOX, NONE, NORMAL, (void*)0x1121L, 12,1538, 32,11,
49, 2, 33, G_BOX, NONE, NORMAL, (void*)0xFF1101L, 256,0, 1567,1545,
33, 3, 28, G_BOX, NONE, NORMAL, (void*)0xFF1100L, 0,256, 1553,1289,
4, -1, -1, G_BOXTEXT, NONE, NORMAL, (void*)0x0L, 0,0, 1553,1,
21, 5, 20, G_BOX, HIDETREE, NORMAL, (void*)0xFF1100L, 1027,257, 14,1032,
6, -1, -1, G_BOX, TOUCHEXIT, NORMAL, (void*)0xFF1170L, 1280,1792, 1026,2049,
7, -1, -1, G_BOX, TOUCHEXIT, NORMAL, (void*)0xFF1171L, 4,1792, 1026,2049,
8, -1, -1, G_BOX, TOUCHEXIT, NORMAL, (void*)0xFF1172L, 775,1792, 1026,2049,
9, -1, -1, G_BOX, TOUCHEXIT, NORMAL, (void*)0xFF1173L, 1546,1792, 1026,2049,
10, -1, -1, G_BOX, TOUCHEXIT, NORMAL, (void*)0xFF1174L, 1280,1538, 1026,2049,
11, -1, -1, G_BOX, TOUCHEXIT, NORMAL, (void*)0xFF1175L, 4,1538, 1026,2049,
12, -1, -1, G_BOX, TOUCHEXIT, NORMAL, (void*)0xFF1176L, 775,1538, 1026,2049,
13, -1, -1, G_BOX, TOUCHEXIT, NORMAL, (void*)0xFF1177L, 1546,1538, 1026,2049,
14, -1, -1, G_BOX, TOUCHEXIT, NORMAL, (void*)0xFF1178L, 1280,1284, 1026,2049,
15, -1, -1, G_BOX, TOUCHEXIT, NORMAL, (void*)0xFF1179L, 4,1284, 1026,2049,
16, -1, -1, G_BOX, TOUCHEXIT, NORMAL, (void*)0xFF117AL, 775,1284, 1026,2049,
17, -1, -1, G_BOX, TOUCHEXIT, NORMAL, (void*)0xFF117BL, 1546,1284, 1026,2049,
18, -1, -1, G_BOX, TOUCHEXIT, NORMAL, (void*)0xFF117CL, 1280,1030, 1026,2049,
19, -1, -1, G_BOX, TOUCHEXIT, NORMAL, (void*)0xFF117DL, 4,1030, 1026,2049,
20, -1, -1, G_BOX, TOUCHEXIT, NORMAL, (void*)0xFF117EL, 775,1030, 1026,2049,
4, -1, -1, G_BOX, TOUCHEXIT, NORMAL, (void*)0xFF117FL, 1546,1030, 1026,2049,
22, -1, -1, G_BOXTEXT, TOUCHEXIT, NORMAL, (void*)0x1L, 0,257, 771,257,
24, 23, 23, G_BOX, TOUCHEXIT, NORMAL, (void*)0xFF1111L, 0,514, 771,262,
22, -1, -1, G_BOXTEXT, TOUCHEXIT, NORMAL, (void*)0x2L, 0,0, 771,1,
25, -1, -1, G_BOXTEXT, TOUCHEXIT, NORMAL, (void*)0x3L, 0,1032, 771,1,
28, 26, 27, G_BOX, HIDETREE, NORMAL, (void*)0xFF1100L, 1027,257, 526,1032,
27, -1, -1, G_BOX, TOUCHEXIT, NORMAL, (void*)0xFF1170L, 1,1538, 261,1795,
25, -1, -1, G_BOX, TOUCHEXIT, NORMAL, (void*)0xFF1171L, 1543,1538, 261,1795,
2, 29, 32, G_BOX, HIDETREE, NORMAL, (void*)0xFF1100L, 1027,257, 526,1032,
30, -1, -1, G_BOX, TOUCHEXIT, NORMAL, (void*)0xFF1170L, 769,1537, 5,1026,
31, -1, -1, G_BOX, TOUCHEXIT, NORMAL, (void*)0xFF1171L, 1799,1537, 5,1026,
32, -1, -1, G_BOX, TOUCHEXIT, NORMAL, (void*)0xFF1172L, 769,2564, 5,1026,
28, -1, -1, G_BOX, TOUCHEXIT, NORMAL, (void*)0xFF1173L, 1799,2564, 5,1026,
1, 34, 48, G_BOX, NONE, NORMAL, (void*)0xFF1100L, 1297,256, 270,1289,
35, -1, -1, G_BOXCHAR, NONE, NORMAL, (void*)0x52FF1100L, 256,0, 1028,1,
36, -1, -1, G_BOXCHAR, NONE, NORMAL, (void*)0x56FF1100L, 1796,0, 1028,1,
37, -1, -1, G_BOXCHAR, NONE, NORMAL, (void*)0x42FF1100L, 1289,0, 1028,1,
38, -1, -1, G_BOXTEXT, TOUCHEXIT, NORMAL, (void*)0x4L, 256,257, 1028,1,
39, -1, -1, G_BOXTEXT, TOUCHEXIT, NORMAL, (void*)0x5L, 1796,257, 1028,1,
40, -1, -1, G_BOXTEXT, TOUCHEXIT, NORMAL, (void*)0x6L, 1289,257, 1028,1,
42, 41, 41, G_BOX, TOUCHEXIT, NORMAL, (void*)0xFF1111L, 256,514, 1028,518,
40, -1, -1, G_BOXTEXT, TOUCHEXIT, NORMAL, (void*)0x7L, 0,0, 1028,1,
44, 43, 43, G_BOX, TOUCHEXIT, NORMAL, (void*)0xFF1111L, 1796,514, 1028,518,
42, -1, -1, G_BOXTEXT, TOUCHEXIT, NORMAL, (void*)0x8L, 0,0, 1028,1,
46, 45, 45, G_BOX, TOUCHEXIT, NORMAL, (void*)0xFF1111L, 1289,514, 1028,518,
44, -1, -1, G_BOXTEXT, TOUCHEXIT, NORMAL, (void*)0x9L, 0,0, 1028,1,
47, -1, -1, G_BOXTEXT, TOUCHEXIT, NORMAL, (void*)0xAL, 256,1032, 1028,1,
48, -1, -1, G_BOXTEXT, TOUCHEXIT, NORMAL, (void*)0xBL, 1796,1032, 1028,1,
33, -1, -1, G_BOXTEXT, TOUCHEXIT, NORMAL, (void*)0xCL, 1289,1032, 1028,1,
0, 50, 54, G_BOX, NONE, NORMAL, (void*)0xFF1100L, 256,1545, 1567,2561,
52, 51, 51, G_BOX, NONE, NORMAL, (void*)0xFF1100L, 536,0, 1031,2561,
50, -1, -1, G_BOXTEXT, 0x5, NORMAL, (void*)0xDL, 512,1280, 7,1,
53, -1, -1, G_BOXTEXT, 0x5, NORMAL, (void*)0xEL, 512,1280, 1541,1,
54, -1, -1, G_BOXTEXT, 0x7, NORMAL, (void*)0xFL, 1542,1280, 9,1,
49, -1, -1, G_BOXTEXT, 0x25, NORMAL, (void*)0x10L, 784,1280, 775,1,
-1, 1, 2, G_BOX, NONE, NORMAL, (void*)0x11100L, 0,0, 265,2563,
2, -1, -1, G_FBOXTEXT, 0x48, NORMAL, (void*)0x11L, 1796,2048, 771,1,
0, -1, -1, G_BUTTON, 0x27, NORMAL, (void*)0x36L, 515,2562, 257,2048,
-1, 1, 2, G_BOX, NONE, NORMAL, (void*)0x11100L, 0,0, 527,517,
2, -1, -1, G_FBOXTEXT, 0x48, NORMAL, (void*)0x12L, 5,1, 1028,1,
0, -1, -1, G_BUTTON, 0x27, NORMAL, (void*)0x3AL, 3,1539, 1025,2304};

LONG rs_trindex[] = {
0L,
55L,
58L};

struct foobar {
	WORD	dummy;
	WORD	*image;
	} rs_imdope[] = {
0};

#define NUM_STRINGS 59
#define NUM_FRSTR 0
#define NUM_IMAGES 0
#define NUM_BB 0
#define NUM_FRIMG 0
#define NUM_IB 0
#define NUM_TI 19
#define NUM_OBS 61
#define NUM_TREE 3

BYTE pname[] = "FRANCE.RSC";
