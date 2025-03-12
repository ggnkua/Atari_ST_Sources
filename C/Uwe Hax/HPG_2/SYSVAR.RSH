/*
 * SYSVAR.RSH
 *
 * Uwe Hax, M„rz 1992
 * (c) MAXON Computer
 */

#define T0OBJ 0
#define FREEBB 0
#define FREEIMG 0
#define FREESTR 25

BYTE *rs_strings[] = 
{
  " System Vectors and Variables ", "", "",
  " ADDRESS ", "", "", " MEANING ", "", "",
  " VALUE ", "", "", "STRING",
  "Hardware Vectors", "Unused Exceptions", 
  "Interrupts", "MFP Vectors", "Traps",
  "System Variables", "System Variables",
  "", "", "Select Item", "",""
};

LONG rs_frstr[] = 
{
  0
};

BITBLK rs_bitblk[] = 
{
  0
};

LONG rs_frimg[] = 
{
  0
};

ICONBLK rs_iconblk[] = 
{
  0
};

TEDINFO rs_tedinfo[] = 
{
  0L, 1L, 2L, 3, 6, 2, 0x11C1, 0x0, 255, 31,1,
  3L, 4L, 5L, 5, 6, 2, 0x11C1, 0x0, 255, 10,1,
  6L, 7L, 8L, 5, 6, 2, 0x11C1, 0x0, 255, 10,1,
  9L, 10L, 11L, 5, 6, 2, 0x11C1, 0x0, 255, 8,1,
  19L, 20L, 21L, 3, 6, 0, 0x1180, 0x0, 255, 17,1,
  22L, 23L, 24L, 3, 6, 0, 0x1180, 0x0, 255, 12,1
};

OBJECT rs_object[] = 
{
  -1, 1, 26, G_BOX, NONE, OUTLINED, 0x21100L,
  0,0, 52,22,
  2, -1, -1, G_BOXCHAR, 0x41, NORMAL, 0x5FF1100L,
  0,0, 514,1,
  3, -1, -1, G_BOXTEXT, NONE, NORMAL, 0x0L, 
  770,0, 1329,1,
  12, 4, 11, G_BOX, NONE, NORMAL, 0xFF1100L, 
  1025,514, 1840,1804,
  5, -1, -1, G_BOXTEXT, NONE, NORMAL, 0x1L, 
  1281,3584, 9,2560,
  6, -1, -1, G_BOXTEXT, NONE, NORMAL, 0x2L, 
  1292,3584, 1811,2560,
  7, -1, -1, G_BOXTEXT, NONE, NORMAL, 0x3L, 
  1570,3584, 1800,2560,
  9, 8, 8, G_BOX, TOUCHEXIT, NORMAL, 0xFF1111L, 
  1069,3586, 2,8,
  7, -1, -1, G_BOX, TOUCHEXIT, NORMAL, 0xFF1100L,
  0,514, 2,3840,
  10, -1, -1, G_STRING, HIDETREE, NORMAL, 0xCL, 
  1025,3585, 6,1,
  11, -1, -1, G_BOXCHAR, TOUCHEXIT, NORMAL, 
  0x1FF1100L, 1069,3585, 2,1,
  3, -1, -1, G_BOXCHAR, TOUCHEXIT, NORMAL, 
  0x2FF1100L, 1069,3594, 2,1,
  25, 13, 24, G_BOX, NONE, NORMAL, 0xFF1100L, 
  1025,16, 1840,3844,
  14, -1, -1, G_BOXCHAR, 0x51, NORMAL,
  0x6FFF1100L, 1793,1, 258,1,
  15, -1, -1, G_STRING, NONE, NORMAL, 0xDL, 
  1540,1, 16,1,
  16, -1, -1, G_BOXCHAR, 0x51, NORMAL,
  0x6FFF1100L, 538,1, 258,1,
  17, -1, -1, G_STRING, NONE, NORMAL, 0xEL, 
  797,1, 17,1,
  18, -1, -1, G_BOXCHAR, 0x51, NORMAL,
  0x6FFF1100L, 1793,1026, 258,1,
  19, -1, -1, G_STRING, NONE, NORMAL, 0xFL, 
  1540,1026, 778,1,
  20, -1, -1, G_BOXCHAR, 0x51, NORMAL, 
  0x6FFF1100L, 538,1026, 258,257,
  21, -1, -1, G_STRING, NONE, NORMAL, 0x10L, 
  1053,1026, 524,257,
  22, -1, -1, G_BOXCHAR, 0x51, NORMAL, 
  0x6FFF1100L, 1793,2051, 258,1,
  23, -1, -1, G_STRING, NONE, NORMAL, 0x11L, 
  1284,2051, 517,257,
  24, -1, -1, G_STRING, NONE, NORMAL, 0x12L, 
  541,2051, 16,1,
  12, -1, -1, G_BOXCHAR, 0x51, SELECTED, 
  0x6FFF1100L, 538,2307, 258,1,
  26, -1, -1, G_TEXT, NONE, NORMAL, 0x4L,
  3,2305, 786,1,
  0, -1, -1, G_TEXT, LASTOB, NORMAL, 0x5L,
  515,2063, 11,1
};

LONG rs_trindex[] = 
{
  0L
};

struct foobar 
{
  WORD    dummy;
  WORD    *image;
} rs_imdope[] = { 0 };

#define NUM_STRINGS 25
#define NUM_FRSTR 0
#define NUM_IMAGES 0
#define NUM_BB 0
#define NUM_FRIMG 0
#define NUM_IB 0
#define NUM_TI 6
#define NUM_OBS 27
#define NUM_TREE 1


