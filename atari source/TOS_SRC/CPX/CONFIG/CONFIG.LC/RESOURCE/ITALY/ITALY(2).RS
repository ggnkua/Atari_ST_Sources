#define T0OBJ 0
#define FREEBB 0
#define FREEIMG 2
#define FREESTR 21

BYTE *rs_strings[] = {
"01234567.123",
"0123456789012345",
"________________",
"XXXXXXXXXXXXXXXX",
"Opzioni CPX",
"",
"",
"Colore testo:",
"Colore icona:",
"00",
"",
"",
"00",
"",
"",
"Residente in RAM:",
"Si",
"No",
"Salva",
"OK",
"Annulla"};

WORD IMAG0[] = {
0x0, 0x0, 0xFFFF, 0xFFFF, 
0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF};

WORD IMAG1[] = {
0x0, 0x0, 0xFFFF, 0xFFFF, 
0x8000, 0x1, 0x8000, 0x1, 
0x8007, 0xF001, 0x800F, 0xF801, 
0x801F, 0xEC01, 0x8018, 0x401, 
0x8018, 0x401, 0x8010, 0x401, 
0x801E, 0x3C01, 0x8017, 0x5401, 
0x8011, 0x401, 0x800B, 0x2801, 
0x800D, 0xD801, 0x8006, 0x2801, 
0x8007, 0xD001, 0x802E, 0x1001, 
0x8039, 0xE001, 0x8038, 0x1, 
0x8000, 0x1, 0x8000, 0x1, 
0x8000, 0x1, 0xFFFF, 0xFFFF};

LONG rs_frstr[] = {
0};

BITBLK rs_bitblk[] = {
0};

LONG rs_frimg[] = {
0};

ICONBLK rs_iconblk[] = {
(short*)0L, (short*)1L, (char*)0L, 4096,21,18, 20,0,32,24, 0,24,72,8};

TEDINFO rs_tedinfo[] = {
(char*)1L, (char*)2L, (char*)3L, 3, 6, 0, 0x1180, 0x0, -1, 17,17,
(char*)4L, (char*)5L, (char*)6L, 3, 6, 2, 0x1180, 0x0, -1, 12,1,
(char*)9L, (char*)10L, (char*)11L, 3, 6, 2, 0x1180, 0x0, -1, 3,1,
(char*)12L, (char*)13L, (char*)14L, 3, 6, 2, 0x1180, 0x0, -1, 3,1};

OBJECT rs_object[] = {
-1, 1, 21, G_BOX, NONE, NORMAL, (void*)0x1121L, 12,1538, 32,11,
21, 2, 17, G_BOX, NONE, NORMAL, (void*)0xFF1141L, 256,0, 1567,1545,
5, 3, 4, G_BOX, NONE, NORMAL, (void*)0xFF1100L, 770,1024, 1818,514,
4, -1, -1, G_ICON, NONE, NORMAL, (void*)0x0L, 512,512, 9,2,
2, -1, -1, G_FTEXT, EDITABLE, NORMAL, (void*)0x0L, 522,2304, 16,1,
6, -1, -1, G_BOXCHAR, TOUCHEXIT, NORMAL, (void*)0x3FF1100L, 797,1024, 1281,514,
7, -1, -1, G_BOXCHAR, TOUCHEXIT, NORMAL, (void*)0x4FF1100L, 1280,1024, 1281,514,
8, -1, -1, G_BOXTEXT, NONE, NORMAL, (void*)0x1L, 1280,2818, 798,769,
17, 9, 16, G_BOX, NONE, NORMAL, (void*)0xFF1100L, 1280,516, 798,3586,
10, -1, -1, G_STRING, NONE, NORMAL, (void*)0x7L, 1,768, 13,1,
11, -1, -1, G_STRING, NONE, NORMAL, (void*)0x8L, 1,2305, 13,1,
12, -1, -1, G_BOXTEXT, NONE, NORMAL, (void*)0x2L, 788,1024, 1540,1,
13, -1, -1, G_BOXTEXT, NONE, NORMAL, (void*)0x3L, 788,2561, 1540,1,
14, -1, -1, G_BOXCHAR, TOUCHEXIT, NORMAL, (void*)0x3FF1100L, 537,1024, 514,1,
15, -1, -1, G_BOXCHAR, TOUCHEXIT, NORMAL, (void*)0x3FF1100L, 537,2561, 514,1,
16, -1, -1, G_BOXCHAR, TOUCHEXIT, NORMAL, (void*)0x4FF1100L, 18,1024, 514,1,
8, -1, -1, G_BOXCHAR, TOUCHEXIT, NORMAL, (void*)0x4FF1100L, 18,2561, 514,1,
1, 18, 20, G_BOX, NONE, NORMAL, (void*)0xFF1100L, 1280,1287, 798,2561,
19, -1, -1, G_STRING, NONE, NORMAL, (void*)0xFL, 1,1024, 17,1,
20, -1, -1, G_BUTTON, 0x11, NORMAL, (void*)0x10L, 275,1280, 1284,3840,
17, -1, -1, G_BUTTON, 0x11, NORMAL, (void*)0x11L, 281,1280, 772,3840,
0, 22, 25, G_BOX, NONE, NORMAL, (void*)0xFF1100L, 256,1545, 1567,2561,
24, 23, 23, G_BOX, NONE, NORMAL, (void*)0xFF1100L, 0,0, 11,2561,
22, -1, -1, G_BUTTON, 0x5, NORMAL, (void*)0x12L, 1025,1280, 8,1,
25, -1, -1, G_BUTTON, 0x7, NORMAL, (void*)0x13L, 1036,1280, 8,1,
21, -1, -1, G_BUTTON, 0x25, NORMAL, (void*)0x14L, 1046,1280, 8,1};

LONG rs_trindex[] = {
0L};

struct foobar {
	WORD	dummy;
	WORD	*image;
	} rs_imdope[] = {
0, &IMAG0[0],
0, &IMAG1[0]};

#define NUM_STRINGS 21
#define NUM_FRSTR 0
#define NUM_IMAGES 2
#define NUM_BB 0
#define NUM_FRIMG 0
#define NUM_IB 1
#define NUM_TI 4
#define NUM_OBS 26
#define NUM_TREE 1

BYTE pname[] = "ITALY.RSC";
