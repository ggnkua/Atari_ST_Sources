/***********************************************/
/* Datei: DIPS.RSH            Version 1.00     */
/* ------------------------------------------- */
/* (C) 1991 by MAXON Computer                  */
/* Autoren: Oliver Scholz & Uwe Hax            */
/***********************************************/

#define T0OBJ 0
#define T1OBJ 32
#define FREEBB 0
#define FREEIMG 0
#define FREESTR 27

BYTE *rs_strings[] = {
  "(C) 1991 by Oliver Scholz & Uwe Hax", "", "",
  "DIP 1", "1", "DIP 2", "2", "DIP 3", "3",
  "DIP 4", "4", "DIP 5", "5", "DIP 6", "6",
  "DIP 7", "7", "DIP 8", "8", "Lesen", "Ok",
  "Abbruch", "Sichern", "OK", "Es ist leider",
  "kein _SWI Cookie", "vorhanden !"};

LONG rs_frstr[] = { 0 };

BITBLK rs_bitblk[] = { 0 };

LONG rs_frimg[] = { 0 };

ICONBLK rs_iconblk[] = { 0 };

TEDINFO rs_tedinfo[] = {
  (char *)0L, (char *)1L,(char *)2L,
  5, 6, 0, 0x1180, 0x0, 255, 36,1
  };

OBJECT rs_object[] = {
  -1, 1, 27, G_BOX, NONE, NORMAL, 0xFF1141L,
  0,0, 32,11,
  2, -1, -1, G_TEXT, NONE, NORMAL, 0x0L,
  1282,512, 1306,2560,
  5, 3, 4, G_BOX, NONE, NORMAL, 0xFF1100L,
  0,1, 1799,1027,
  4, -1, -1, G_STRING, NONE, NORMAL, 0x3L,
  257,1280, 1029,257,
  2, -1, -1, G_BUTTON, 0x41, SHADOWED, 0x4L,
  1024,3329, 1542,1,
  8, 6, 7, G_BOX, NONE, NORMAL, 0xFF1100L,
  8,1, 8,1027,
  7, -1, -1, G_STRING, NONE, NORMAL, 0x5L,
  257,1280, 1029,257,
  5, -1, -1, G_BUTTON, 0x41, SHADOWED, 0x6L,
  1024,3329, 1542,1,
  11, 9, 10, G_BOX, NONE, NORMAL, 0xFF1100L,
  272,1, 1799,1027,
  10, -1, -1, G_STRING, NONE, NORMAL, 0x7L,
  257,1280, 1029,257,
  8, -1, -1, G_BUTTON, 0x41, SHADOWED, 0x8L,
  1024,3329, 1542,1,
  14, 12, 13, G_BOX, NONE, NORMAL, 0xFF1100L,
  280,1, 1799,1027,
  13, -1, -1, G_STRING, NONE, NORMAL, 0x9L,
  257,1280, 1029,257,
  11, -1, -1, G_BUTTON, 0x41, SHADOWED, 0xAL,
  1024,3329, 1542,1,
  17, 15, 16, G_BOX, NONE, NORMAL, 0xFF1100L,
  0,1284, 1799,1027,
  16, -1, -1, G_STRING, NONE, NORMAL, 0xBL,
  257,1280, 1029,257,
  14, -1, -1, G_BUTTON, 0x41, SHADOWED, 0xCL,
  1024,3329, 1542,1,
  20, 18, 19, G_BOX, NONE, NORMAL, 0xFF1100L,
  8,1284, 520,1027,
  19, -1, -1, G_STRING, NONE, NORMAL, 0xDL,
  257,1280, 1029,257,
  17, -1, -1, G_BUTTON, 0x41, SHADOWED, 0xEL,
  1024,3329, 1542,1,
  23, 21, 22, G_BOX, NONE, NORMAL, 0xFF1100L,
  272,1284, 1799,1027,
  22, -1, -1, G_STRING, NONE, NORMAL, 0xFL,
  257,1280, 1029,257,
  20, -1, -1, G_BUTTON, 0x41, SHADOWED, 0x10L,
  1024,3329, 1542,1,
  26, 24, 25, G_BOX, NONE, NORMAL, 0xFF1100L,
  280,1284, 1799,1027,
  25, -1, -1, G_STRING, NONE, NORMAL, 0x11L,
  257,1280, 1029,257,
  23, -1, -1, G_BUTTON, 0x41, SHADOWED, 0x12L,
  1024,3329, 1542,1,
  27, -1, -1, G_BUTTON, 0x5, NORMAL, 0x13L,
  1281,3591, 8,1,
  0, 28, 30, G_BOX, NONE, NORMAL, 0xFF1100L,
  0,777,32,3329,
  29, -1, -1, G_BUTTON, 0x7, NORMAL, 0x14L,
  1548,1792, 8,1,
  30, -1, -1, G_BUTTON, 0x5, NORMAL, 0x15L,
  1046,1792, 8,1,
  27, 31, 31, G_BOX, NONE, NORMAL, 0xFF1100L,
  0,0, 523,3329,
  30, -1, -1, G_BUTTON, 0x25, NORMAL, 0x16L,
  769,1536, 1032,513,
  -1, 1, 4, G_BOX, NONE, OUTLINED, 0x21100L,
  0,0, 22,7,
  2, -1, -1, G_BUTTON, 0x7, NORMAL, 0x17L,
  7,5, 8,1,
  3, -1, -1, G_STRING, NONE, NORMAL, 0x18L,
  5,1, 13,1,
  4, -1, -1, G_STRING, NONE, NORMAL, 0x19L,
  3,2, 16,1,
  0, -1, -1, G_STRING, LASTOB, NORMAL, 0x1AL,
  6,3, 11,1
};

LONG rs_trindex[] = { 0L,32L };

struct foobar {
    WORD    dummy;
    WORD    *image;
    } rs_imdope[] = { 0 };

#define NUM_STRINGS 27
#define NUM_FRSTR 0
#define NUM_IMAGES 0
#define NUM_BB 0
#define NUM_FRIMG 0
#define NUM_IB 0
#define NUM_TI 1
#define NUM_OBS 37
#define NUM_TREE 2


