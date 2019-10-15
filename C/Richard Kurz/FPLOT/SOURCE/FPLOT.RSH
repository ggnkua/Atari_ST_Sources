#define T0OBJ 0
#define T1OBJ 26
#define T2OBJ 32
#define T3OBJ 43
#define FREEBB 0
#define FREEIMG 0
#define FREESTR 43

BYTE *rs_strings[] = {
"  ",
" Datei ",
" Funktion ",
"  Info...           ",
"--------------------",
"1",
"2",
"3",
"4",
"5",
"6",
"  Programm beenden    ",
"  Funktion laden...   ",
"  Funktion sichern... ",
"----------------------",
"  Funktion eingeben... ",
"  Plott starten        ",
"-----------------------",
"  Hilfe...             ",
"Formel eingeben",
"1234567890123456789012345678901234",
"__________________________________",
"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
"Abbrechen",
"Weiter",
"Start",
"Demonstration fÅr einen",
"schnellen Formel-Interpreter",
" Ω 1991 by Richard Kurz",
"Vogelherdbogen 62",
"7992 Tettnang",
"TOS-Magazin",
"ICP-Verlag GmbH & Co. KG",
"Funktions-Plotter",
"Okay",
"Funktionen",
"",
"",
"ABS ACOS ASIN ATAN COSH COS EXP",
"LOG10 LOG POW10 SINH SIN SQRT",
"SQR TANH TAN",
"+ - * / ^",
"Okay"};

LONG rs_frstr[] = {
0};

BITBLK rs_bitblk[] = {
0};

LONG rs_frimg[] = {
0};

ICONBLK rs_iconblk[] = {
0};

TEDINFO rs_tedinfo[] = {
20L, 21L, 22L, 3, 6, 0, 0x1180, 0x0, -1, 35,35,
35L, 36L, 37L, 3, 6, 2, 0x1180, 0x0, -1, 11,1};

OBJECT rs_object[] = {
-1, 1, 6, G_IBOX, NONE, NORMAL, 0x0L, 0,0, 90,25,
6, 2, 2, G_BOX, NONE, NORMAL, 0x1100L, 0,0, 90,513,
1, 3, 5, G_IBOX, NONE, NORMAL, 0x0L, 2,0, 21,769,
4, -1, -1, G_TITLE, NONE, NORMAL, 0x0L, 0,0, 4,769,
5, -1, -1, G_TITLE, NONE, NORMAL, 0x1L, 4,0, 7,769,
2, -1, -1, G_TITLE, NONE, NORMAL, 0x2L, 11,0, 10,769,
0, 7, 21, G_IBOX, NONE, NORMAL, 0x0L, 0,769, 80,19,
16, 8, 15, G_BOX, NONE, NORMAL, 0xFF1100L, 2,0, 20,8,
9, -1, -1, G_STRING, NONE, NORMAL, 0x3L, 0,0, 20,1,
10, -1, -1, G_STRING, NONE, DISABLED, 0x4L, 0,1, 20,1,
11, -1, -1, G_STRING, NONE, NORMAL, 0x5L, 0,2, 20,1,
12, -1, -1, G_STRING, NONE, NORMAL, 0x6L, 0,3, 20,1,
13, -1, -1, G_STRING, NONE, NORMAL, 0x7L, 0,4, 20,1,
14, -1, -1, G_STRING, NONE, NORMAL, 0x8L, 0,5, 20,1,
15, -1, -1, G_STRING, NONE, NORMAL, 0x9L, 0,6, 20,1,
7, -1, -1, G_STRING, NONE, NORMAL, 0xAL, 0,7, 20,1,
21, 17, 20, G_BOX, NONE, NORMAL, 0xFF1100L, 6,0, 22,4,
18, -1, -1, G_STRING, NONE, NORMAL, 0xBL, 0,3, 22,1,
19, -1, -1, G_STRING, NONE, NORMAL, 0xCL, 0,0, 22,1,
20, -1, -1, G_STRING, NONE, NORMAL, 0xDL, 0,1, 22,1,
16, -1, -1, G_STRING, NONE, DISABLED, 0xEL, 0,2, 22,1,
6, 22, 25, G_BOX, NONE, NORMAL, 0xFF1100L, 13,0, 23,4,
23, -1, -1, G_STRING, NONE, NORMAL, 0xFL, 0,0, 23,1,
24, -1, -1, G_STRING, NONE, NORMAL, 0x10L, 0,3, 23,1,
25, -1, -1, G_STRING, NONE, DISABLED, 0x11L, 0,2, 23,1,
21, -1, -1, G_STRING, LASTOB, NORMAL, 0x12L, 0,1, 23,1,
-1, 1, 5, G_BOX, NONE, SHADOWED, 0x11100L, 0,0, 38,8,
2, -1, -1, G_BUTTON, NONE, NORMAL, 0x13L, 2,1, 34,2,
3, -1, -1, G_FTEXT, EDITABLE, NORMAL, 0x0L, 2,4, 34,1,
4, -1, -1, G_BUTTON, 0x5, NORMAL, 0x17L, 2,6, 11,1,
5, -1, -1, G_BUTTON, 0x5, NORMAL, 0x18L, 16,6, 9,1,
0, -1, -1, G_BUTTON, 0x27, NORMAL, 0x19L, 28,6, 8,1,
-1, 1, 9, G_BOX, NONE, OUTLINED, 0x21100L, 0,0, 34,16,
2, -1, -1, G_STRING, NONE, NORMAL, 0x1AL, 6,4, 23,1,
3, -1, -1, G_STRING, NONE, NORMAL, 0x1BL, 3,5, 28,1,
4, -1, -1, G_STRING, NONE, NORMAL, 0x1CL, 6,7, 23,1,
5, -1, -1, G_STRING, NONE, NORMAL, 0x1DL, 9,8, 17,1,
6, -1, -1, G_STRING, NONE, NORMAL, 0x1EL, 11,9, 13,1,
7, -1, -1, G_STRING, NONE, NORMAL, 0x1FL, 12,11, 11,1,
8, -1, -1, G_STRING, NONE, NORMAL, 0x20L, 5,12, 24,1,
9, -1, -1, G_BUTTON, SELECTABLE, NORMAL, 0x21L, 3,1, 28,2,
0, 10, 10, G_BOX, NONE, NORMAL, 0x1100L, 9,14, 14,1,
9, -1, -1, G_BUTTON, 0x27, NORMAL, 0x22L, 3,0, 8,1,
-1, 1, 6, G_BOX, NONE, SHADOWED, 0x11100L, 0,0, 37,11,
2, -1, -1, G_BOXTEXT, NONE, NORMAL, 0x1L, 3,1, 11,1,
3, -1, -1, G_STRING, NONE, NORMAL, 0x26L, 3,3, 31,1,
4, -1, -1, G_STRING, NONE, NORMAL, 0x27L, 3,4, 30,1,
5, -1, -1, G_STRING, NONE, NORMAL, 0x28L, 3,5, 12,1,
6, -1, -1, G_STRING, NONE, NORMAL, 0x29L, 3,7, 10,1,
0, -1, -1, G_BUTTON, 0x27, NORMAL, 0x2AL, 8,9, 20,1};

LONG rs_trindex[] = {
0L,
26L,
32L,
43L};

struct foobar {
	WORD	dummy;
	WORD	*image;
	} rs_imdope[] = {
0};

#define NUM_STRINGS 43
#define NUM_FRSTR 0
#define NUM_IMAGES 0
#define NUM_BB 0
#define NUM_FRIMG 0
#define NUM_IB 0
#define NUM_TI 2
#define NUM_OBS 50
#define NUM_TREE 4

BYTE pname[] = "FPLOT.RSC";