/*
 * DFREE.RSH
 *
 * von Oliver Scholz, Januar 1992
 *
 */

#define T0OBJ 0
#define FREEBB 0
#define FREEIMG 0
#define FREESTR 37

BYTE *rs_strings[] = 
{
  "STRING", "C:", "D:", "E:", "G:", "F:", 
  "H:", "I:", "J:",
  "999.99", "999.99", "999.99", "999.99",
  "999.99", "999.99", "999.99", "999.99",
  "999.99", "999.99", "999.99", "999.99",
  "999.99", "999.99", "999.99", "999.99",
  " Hard Disk Usage Information ", "", "",
  "Drive", "", "", 
  "Usage", "", "", 
  "Free MBs", "", ""
};

LONG rs_frstr[] = { 0 };

BITBLK rs_bitblk[] = { 0 };

LONG rs_frimg[] = { 0 };

ICONBLK rs_iconblk[] = { 0 };

TEDINFO rs_tedinfo[] = 
{
  25L, 26L, 27L, 3, 6, 2, 0x11C1, 0x0, 255, 30,1,
  28L, 29L, 30L, 3, 6, 0, 0x1180, 0x0, 255, 6,1,
  31L, 32L, 33L, 3, 6, 0, 0x1180, 0x0, 255, 6,1,
  34L, 35L, 36L, 3, 6, 0, 0x1180, 0x0, -1, 9,1
};

OBJECT rs_object[] = 
{
  -1, 1, 47, G_BOX, NONE, OUTLINED, 0x21101L, 
  0,0, 570,15,
  2, -1, -1, G_BOXCHAR, 0x5, NORMAL, 0x5FF1100L, 
  0,0, 770,1,
  44, 3, 43, G_BOX, NONE, NORMAL, 0xFF1101L, 
  513,2, 1079,2060,
  4, -1, -1, G_STRING, HIDETREE, NORMAL, 0x0L, 
  1025,3585, 6,1,
  5, -1, -1, G_STRING, NONE, NORMAL, 0x1L,
  2,257, 3,1,
  6, -1, -1, G_STRING, NONE, NORMAL, 0x2L, 
  2,1538, 3,1,
  7, -1, -1, G_STRING, NONE, NORMAL, 0x3L,
  2,2819, 3,1,
  8, -1, -1, G_STRING, NONE, NORMAL, 0x4L,
  2,1286, 3,1,
  9, -1, -1, G_STRING, NONE, NORMAL, 0x5L,
  2,5, 3,1,
  11, 10, 10, G_BOX, NONE, NORMAL, 0xFF1141L, 
  525,513, 546,3840,
  9, -1, -1, G_BOX, NONE, NORMAL, 0xFF1111L, 
  0,0, 1793,3840,
  13, 12, 12, G_BOX, NONE, NORMAL, 0xFF1141L, 
  525,1794, 546,3840,
  11, -1, -1, G_BOX, NONE, NORMAL, 0xFF1111L,
  0,0, 1793,3840,
  15, 14, 14, G_BOX, NONE, NORMAL, 0xFF1141L, 
  525,3075, 546,3840,
  13, -1, -1, G_BOX, NONE, NORMAL, 0xFF1111L, 
  0,0, 1793,3840,
  17, 16, 16, G_BOX, NONE, NORMAL, 0xFF1141L, 
  525,261, 546,3840,
  15, -1, -1, G_BOX, NONE, NORMAL, 0xFF1111L, 
  0,0, 1793,3840,
  19, 18, 18, G_BOX, NONE, NORMAL, 0xFF1141L, 
  525,1542, 546,3840,
  17, -1, -1, G_BOX, NONE, NORMAL, 0xFF1111L, 
  0,0, 1793,3840,
  21, 20, 20, G_BOX, NONE, NORMAL, 0xFF1141L, 
  525,2823, 546,3840,
  19, -1, -1, G_BOX, NONE, NORMAL, 0xFF1111L, 
  0,0, 1793,3840,
  22, -1, -1, G_STRING, NONE, NORMAL, 0x6L, 
  2,2567, 3,1,
  24, 23, 23, G_BOX, NONE, NORMAL, 0xFF1141L, 
  525,9, 546,3840,
  22, -1, -1, G_BOX, NONE, NORMAL, 0xFF1111L, 
  0,0, 1793,3840,
  26, 25, 25, G_BOX, NONE, NORMAL, 0xFF1141L, 
  525,1290, 546,3840,
  24, -1, -1, G_BOX, NONE, NORMAL, 0xFF1111L, 
  0,0, 1793,3840,
  27, -1, -1, G_STRING, NONE, NORMAL, 0x7L, 
  2,3848, 3,1,
  28, -1, -1, G_STRING, NONE, NORMAL, 0x8L, 
  2,1034, 3,1,
  29, -1, -1, G_STRING, NONE, NORMAL, 0x9L,
  1328,257, 6,1,
  30, -1, -1, G_STRING, NONE, NORMAL, 0xAL, 
  1328,1538, 6,1,
  31, -1, -1, G_STRING, NONE, NORMAL, 0xBL, 
  1328,2819, 6,1,
  32, -1, -1, G_STRING, NONE, NORMAL, 0xCL, 
  1328,5, 6,1,
  33, -1, -1, G_STRING, NONE, NORMAL, 0xDL, 
  1328,1286, 6,1,
  34, -1, -1, G_STRING, NONE, NORMAL, 0xEL, 
  1328,2567, 6,1,
  35, -1, -1, G_STRING, NONE, NORMAL, 0xFL,
  1328,3848, 6,1,
  36, -1, -1, G_STRING, NONE, NORMAL, 0x10L, 
  1328,1034, 6,1,
  37, -1, -1, G_STRING, NONE, NORMAL, 0x11L, 
  1285,257, 6,1,
  38, -1, -1, G_STRING, NONE, NORMAL, 0x12L, 
  1285,1538, 6,1,
  39, -1, -1, G_STRING, NONE, NORMAL, 0x13L, 
  1285,2819, 6,1,
  40, -1, -1, G_STRING, NONE, NORMAL, 0x14L, 
  1285,5, 6,1,
  41, -1, -1, G_STRING, NONE, NORMAL, 0x15L, 
  1285,1286, 6,1,
  42, -1, -1, G_STRING, NONE, NORMAL, 0x16L, 
  1285,2567, 6,1,
  43, -1, -1, G_STRING, NONE, NORMAL, 0x17L, 
  1285,3848, 6,1,
  2, -1, -1, G_STRING, NONE, NORMAL, 0x18L, 
  1285,1034, 6,1,
  45, -1, -1, G_BOXTEXT, NONE, NORMAL, 0x0L, 
  770,0, 1847,1,
  46, -1, -1, G_TEXT, NONE, NORMAL, 0x1L, 
  3,1793, 1800,1,
  47, -1, -1, G_TEXT, NONE, NORMAL, 0x2L, 
  280,1793, 782,1,
  0, -1, -1, G_TEXT, LASTOB, NORMAL, 0x3L, 
  816,1537, 8,1};

LONG rs_trindex[] = { 0L };

struct foobar 
{
  WORD    dummy;
  WORD    *image;
} rs_imdope[] = { 0 };

#define NUM_STRINGS 37
#define NUM_FRSTR 0
#define NUM_IMAGES 0
#define NUM_BB 0
#define NUM_FRIMG 0
#define NUM_IB 0
#define NUM_TI 4
#define NUM_OBS 48
#define NUM_TREE 1


