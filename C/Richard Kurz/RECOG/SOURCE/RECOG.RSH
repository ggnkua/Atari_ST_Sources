#define T0OBJ 0
#define T1OBJ 50
#define T2OBJ 54
#define T3OBJ 60
#define T4OBJ 72
#define FREEBB 0
#define FREEIMG 0
#define FREESTR 96

BYTE *rs_strings[] = {
"R e c o g",
"",
"",
" Optionen...",
"",
"",
"  VDI           ",
"",
"",
"  LINEA         ",
"",
"",
"  MÅll lîschen  ",
"",
"",
"  Kontakt OK    ",
"",
"",
"----------------",
"  Text mischen  ",
"",
"",
"  links bÅndig  ",
"",
"",
"----------------",
"  Text sehen... ",
"",
"",
"  Bild laden... ",
"",
"",
"ASCII",
"",
"",
"Font",
"",
"",
"6*6",
"8*8",
"8*16",
"von",
"",
"",
"bis",
"",
"",
"Fett",
"Hell",
"Kurs",
"Hohl",
"Style",
"",
"",
"  Font lernen  ",
"     Start     ",
"Info...",
"",
"",
"Hilfe...",
"",
"",
"Ende",
"",
"",
"Bitte warten",
"Lernen!",
"Was machen wir nun",
"mit dem Text ?",
" Sichern ",
" Lîschen ",
" Aufheben",
"Okay",
"Nach dem ersten Start von RECOG, ",
"muû zunÑchst ein Zeichensatz ge-",
"lernt werden. Voreingestellt ist ",
"der aktuelle Systemzeichensatz.",
"Mit Hilfe von Style und Font kann",
"ein anderer Zeichensatz gesetzt",
"werden.",
"Mit den Pfeilen in der Box ASCII",
"bestimmt man die gewÅnschten Zei-",
"chen.",
"R e c o g",
"",
"",
"Ω 1992 by",
"Richard Kurz",
"Vogelherdbogen 62",
"7992 Tettnang",
"Tel. 07542/52908",
"Version 2.2",
"erstellt mit Pure C V1.0",
"TOS Magazin",
"Okay",
"ICP-Verlag GmbH & Co. KG"};

LONG rs_frstr[] = {
0};

BITBLK rs_bitblk[] = {
0};

LONG rs_frimg[] = {
0};

ICONBLK rs_iconblk[] = {
0};

TEDINFO rs_tedinfo[] = {
0L, 1L, 2L, 3, 6, 2, 0x1180, 0x0, 3, 10,1,
3L, 4L, 5L, 3, 6, 2, 0x1180, 0x0, -1, 13,1,
6L, 7L, 8L, 3, 6, 0, 0x1180, 0x0, -1, 17,1,
9L, 10L, 11L, 3, 6, 0, 0x1180, 0x0, -1, 17,1,
12L, 13L, 14L, 3, 6, 0, 0x1180, 0x0, -1, 17,1,
15L, 16L, 17L, 3, 6, 0, 0x1180, 0x0, -1, 17,1,
19L, 20L, 21L, 3, 6, 0, 0x1180, 0x0, -1, 17,1,
22L, 23L, 24L, 3, 6, 0, 0x1180, 0x0, -1, 17,1,
26L, 27L, 28L, 3, 6, 0, 0x1180, 0x0, -1, 17,1,
29L, 30L, 31L, 3, 6, 0, 0x1180, 0x0, -1, 17,1,
32L, 33L, 34L, 3, 6, 0, 0x1180, 0x0, -1, 6,1,
35L, 36L, 37L, 3, 6, 0, 0x1180, 0x0, -1, 5,1,
41L, 42L, 43L, 5, 6, 0, 0x1180, 0x0, -1, 4,1,
44L, 45L, 46L, 5, 6, 0, 0x1180, 0x0, -1, 4,1,
51L, 52L, 53L, 3, 6, 0, 0x1180, 0x0, -1, 6,1,
56L, 57L, 58L, 3, 6, 2, 0x1180, 0x0, -2, 8,1,
59L, 60L, 61L, 3, 6, 2, 0x1180, 0x0, -2, 9,1,
62L, 63L, 64L, 3, 6, 2, 0x1180, 0x0, -3, 5,1,
83L, 84L, 85L, 3, 6, 2, 0x1180, 0x0, 3, 10,1};

OBJECT rs_object[] = {
-1, 1, 49, G_BOX, NONE, OUTLINED, 0x21101L, 12,1538, 38,14,
2, -1, -1, G_BOX, TOUCHEXIT, CROSSED, 0x11100L, 36,0, 2,1,
3, -1, -1, G_BOXTEXT, NONE, OUTLINED, 0x0L, 2,1, 17,2,
4, -1, -1, G_BOXTEXT, TOUCHEXIT, SHADOWED, 0x1L, 21,2, 15,1,
15, 5, 14, G_BOX, NONE, SHADOWED, 0xFF1100L, 21,3, 16,10,
6, -1, -1, G_TEXT, NONE, NORMAL, 0x2L, 0,0, 16,1,
7, -1, -1, G_TEXT, NONE, CHECKED, 0x3L, 0,1, 16,1,
8, -1, -1, G_TEXT, NONE, CHECKED, 0x4L, 0,2, 16,1,
9, -1, -1, G_TEXT, NONE, NORMAL, 0x5L, 0,3, 16,1,
10, -1, -1, G_STRING, NONE, DISABLED, 0x12L, 0,4, 16,1,
11, -1, -1, G_TEXT, NONE, NORMAL, 0x6L, 0,5, 16,1,
12, -1, -1, G_TEXT, NONE, NORMAL, 0x7L, 0,6, 16,1,
13, -1, -1, G_STRING, NONE, DISABLED, 0x19L, 0,7, 16,1,
14, -1, -1, G_TEXT, NONE, NORMAL, 0x8L, 0,8, 16,1,
4, -1, -1, G_TEXT, NONE, NORMAL, 0x9L, 0,9, 16,1,
33, 16, 32, G_BOX, NONE, NORMAL, 0xFF1100L, 2,4, 34,5,
17, -1, -1, G_TEXT, NONE, NORMAL, 0xAL, 2,0, 5,1,
18, -1, -1, G_TEXT, NONE, NORMAL, 0xBL, 28,0, 4,1,
19, -1, -1, G_BOXCHAR, TOUCHEXIT, NORMAL, 0x4FF1100L, 1,1, 2,1,
20, -1, -1, G_BOXCHAR, NONE, NORMAL, 0x21FF1100L, 3,1, 3,1,
21, -1, -1, G_BOXCHAR, TOUCHEXIT, NORMAL, 0x3FF1100L, 6,1, 2,1,
25, 22, 24, G_IBOX, NONE, NORMAL, 0x1100L, 26,1, 3,3,
23, -1, -1, G_BOX, 0x51, OUTLINED, 0x11100L, 1,0, 1,1,
24, -1, -1, G_BOX, 0x51, OUTLINED, 0x11100L, 1,1, 1,1,
21, -1, -1, G_BOX, 0x51, 0x11, 0x11100L, 1,2, 1,1,
26, -1, -1, G_STRING, NONE, NORMAL, 0x26L, 29,1, 4,1,
27, -1, -1, G_STRING, NONE, NORMAL, 0x27L, 29,2, 4,1,
28, -1, -1, G_BOXCHAR, TOUCHEXIT, NORMAL, 0x4FF1100L, 1,3, 2,1,
29, -1, -1, G_BOXCHAR, NONE, NORMAL, 0x7AFF1100L, 3,3, 3,1,
30, -1, -1, G_BOXCHAR, TOUCHEXIT, NORMAL, 0x3FF1100L, 6,3, 2,1,
31, -1, -1, G_STRING, NONE, NORMAL, 0x28L, 29,3, 5,1,
32, -1, -1, G_TEXT, NONE, NORMAL, 0xCL, 3,2, 3,1,
15, -1, -1, G_TEXT, NONE, NORMAL, 0xDL, 3,4, 3,1,
42, 34, 41, G_BOX, NONE, NORMAL, 0xFF1100L, 11,4, 17,5,
35, -1, -1, G_BOXCHAR, TOUCHEXIT, SELECTED, 0x11171L, 1,1, 2,1,
36, -1, -1, G_STRING, NONE, NORMAL, 0x2FL, 4,1, 4,1,
37, -1, -1, G_BOXCHAR, TOUCHEXIT, SELECTED, 0x11171L, 9,1, 2,1,
38, -1, -1, G_STRING, NONE, NORMAL, 0x30L, 12,1, 4,1,
39, -1, -1, G_BOXCHAR, TOUCHEXIT, SELECTED, 0x11171L, 1,3, 2,1,
40, -1, -1, G_STRING, NONE, NORMAL, 0x31L, 4,3, 4,1,
41, -1, -1, G_BOXCHAR, TOUCHEXIT, SELECTED, 0x11171L, 9,3, 2,1,
33, -1, -1, G_STRING, NONE, NORMAL, 0x32L, 12,3, 4,1,
43, -1, -1, G_TEXT, NONE, NORMAL, 0xEL, 17,4, 5,1,
45, 44, 44, G_IBOX, NONE, 0x30, 0x11100L, 2,10, 15,1,
43, -1, -1, G_STRING, TOUCHEXIT, NORMAL, 0x36L, 0,0, 15,1,
47, 46, 46, G_IBOX, NONE, 0x30, 0x11100L, 21,10, 15,1,
45, -1, -1, G_STRING, TOUCHEXIT, DISABLED, 0x37L, 0,0, 15,1,
48, -1, -1, G_BOXTEXT, 0x5, NORMAL, 0xFL, 2,12, 9,1,
49, -1, -1, G_BOXTEXT, 0x5, NORMAL, 0x10L, 14,12, 10,1,
0, -1, -1, G_BOXTEXT, 0x27, NORMAL, 0x11L, 27,12, 9,1,
-1, 1, 3, G_BOX, NONE, SHADOWED, 0x11100L, 0,0, 24,7,
2, -1, -1, G_STRING, NONE, NORMAL, 0x41L, 6,5, 12,1,
3, -1, -1, G_BOXCHAR, NONE, NORMAL, 0x20001100L, 13,3, 2,1,
0, -1, -1, G_STRING, LASTOB, NORMAL, 0x42L, 9,4, 7,1,
-1, 1, 5, G_BOX, NONE, OUTLINED, 0x21100L, 0,0, 22,10,
2, -1, -1, G_STRING, NONE, NORMAL, 0x43L, 2,1, 18,1,
3, -1, -1, G_STRING, NONE, NORMAL, 0x44L, 4,2, 14,1,
4, -1, -1, G_BUTTON, 0x5, NORMAL, 0x45L, 2,4, 18,1,
5, -1, -1, G_BUTTON, 0x5, NORMAL, 0x46L, 2,6, 18,1,
0, -1, -1, G_BUTTON, 0x27, NORMAL, 0x47L, 2,8, 18,1,
-1, 1, 11, G_BOX, NONE, OUTLINED, 0x21100L, 0,0, 38,14,
2, -1, -1, G_BUTTON, 0x7, NORMAL, 0x48L, 2,12, 34,1,
3, -1, -1, G_STRING, NONE, NORMAL, 0x49L, 2,1, 34,1,
4, -1, -1, G_STRING, NONE, NORMAL, 0x4AL, 2,2, 32,1,
5, -1, -1, G_STRING, NONE, NORMAL, 0x4BL, 2,3, 33,1,
6, -1, -1, G_STRING, NONE, NORMAL, 0x4CL, 2,4, 31,1,
7, -1, -1, G_STRING, NONE, NORMAL, 0x4DL, 2,5, 33,1,
8, -1, -1, G_STRING, NONE, NORMAL, 0x4EL, 2,6, 34,1,
9, -1, -1, G_STRING, NONE, NORMAL, 0x4FL, 2,7, 7,1,
10, -1, -1, G_STRING, NONE, NORMAL, 0x50L, 2,8, 32,1,
11, -1, -1, G_STRING, NONE, NORMAL, 0x51L, 2,9, 33,1,
0, -1, -1, G_STRING, LASTOB, NORMAL, 0x52L, 2,10, 6,1,
-1, 1, 11, G_BOX, NONE, OUTLINED, 0x21100L, 0,0, 38,14,
2, -1, -1, G_BOXTEXT, NONE, OUTLINED, 0x12L, 2,1, 16,2,
3, -1, -1, G_STRING, NONE, NORMAL, 0x56L, 20,1, 9,1,
4, -1, -1, G_STRING, NONE, NORMAL, 0x57L, 20,2, 12,1,
5, -1, -1, G_STRING, NONE, NORMAL, 0x58L, 20,3, 17,1,
6, -1, -1, G_STRING, NONE, NORMAL, 0x59L, 20,4, 13,1,
7, -1, -1, G_STRING, NONE, NORMAL, 0x5AL, 2,4, 16,1,
8, -1, -1, G_STRING, NONE, NORMAL, 0x5BL, 14,6, 11,1,
9, -1, -1, G_STRING, NONE, NORMAL, 0x5CL, 7,7, 24,1,
10, -1, -1, G_STRING, NONE, NORMAL, 0x5DL, 14,9, 11,1,
11, -1, -1, G_BUTTON, 0x7, NORMAL, 0x5EL, 2,12, 34,1,
0, -1, -1, G_STRING, LASTOB, NORMAL, 0x5FL, 7,10, 24,1};

LONG rs_trindex[] = {
0L,
50L,
54L,
60L,
72L};

struct foobar {
	WORD	dummy;
	WORD	*image;
	} rs_imdope[] = {
0};

#define NUM_STRINGS 96
#define NUM_FRSTR 0
#define NUM_IMAGES 0
#define NUM_BB 0
#define NUM_FRIMG 0
#define NUM_IB 0
#define NUM_TI 19
#define NUM_OBS 84
#define NUM_TREE 5

BYTE pname[] = "RECOG.RSC";