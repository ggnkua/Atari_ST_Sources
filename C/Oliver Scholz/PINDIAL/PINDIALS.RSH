/*
 * PINDIALS.RSH
 */

WORD Pin_Unpinned[] = {
    0x0,0x8,0x14,0x14,0x14,0x1ff4,0xff4,0x14,
    0x14,0x14,0x3008,0x4800,0x4800,0x3000,0x0,0x0
    };
    
WORD Pin_Pinned[] = {  
    0,0,0xf8,0x18c,0x202,0x603,0x401,0x401,0x401,
    0x401,0x603,0x202,0x78c,0xcf8,0x1800,0,0,0
    };
    
BITBLK rs_bitblk[] = {
(WORD *)Pin_Unpinned, 2, 16, 0, 0, 1,
(WORD *)Pin_Pinned, 2, 16, 0, 0, 1
};

TEDINFO rs_tedinfo[] = {
"Pica", "", "", 3, 6, 2, 0x1180, 0x0, -1, 5,1,
"Elite", "", "", 3, 6, 2, 0x1180, 0x0, -1, 6,1,
"Times", "", "", 3, 6, 2, 0x1180, 0x0, -1, 6,1,
"kursiv", "", "", 3, 6, 2, 0x1180, 0x0, -1, 7,1,
"unterstrichen", "", "",3,6,2,0x1180,0x0,-1,14,1,
"leicht", "", "", 3, 6, 2, 0x1180, 0x0, -1, 7,1,
"fett", "", "", 3, 6, 2, 0x1180, 0x0, -1, 5,1};

OBJECT rs_object[] = {
-1, 1, 6, G_IBOX, NONE, NORMAL,
  0x0L, 0,0, 90,25,
6, 2, 2, G_BOX, NONE, NORMAL,
  0x1100L, 0,0, 90,513,
1, 3, 5, G_IBOX, NONE, NORMAL,
  0x0L, 2,0, 19,769,
4, -1, -1, G_TITLE, NONE, NORMAL,
  (long)" Desk ", 0,0, 6,769,
5, -1, -1, G_TITLE, NONE, NORMAL,
  (long)" Datei ", 6,0, 7,769,
2, -1, -1, G_TITLE, NONE, NORMAL,
  (long)" Text ", 13,0, 6,769,
0, 7, 18, G_IBOX, NONE, NORMAL,
  0x0L, 0,769, 80,19,
16, 8, 15, G_BOX, NONE, NORMAL,
  0xFF1100L, 2,0, 20,8,
9, -1, -1, G_STRING, NONE, NORMAL,
  (long)"  šber PINDIALS...  ", 0,0, 20,1,
10, -1, -1, G_STRING, NONE, DISABLED,
  (long)"--------------------", 0,1, 20,1,
11, -1, -1, G_STRING, NONE, NORMAL,
  (long)"1", 0,2, 20,1,
12, -1, -1, G_STRING, NONE, NORMAL,
  (long)"2", 0,3, 20,1,
13, -1, -1, G_STRING, NONE, NORMAL,
  (long)"3", 0,4, 20,1,
14, -1, -1, G_STRING, NONE, NORMAL,
  (long)"4", 0,5, 20,1,
15, -1, -1, G_STRING, NONE, NORMAL,
  (long)"5", 0,6, 20,1,
7, -1, -1, G_STRING, NONE, NORMAL,
  (long)"6", 0,7, 20,1,
18, 17, 17, G_BOX, NONE, NORMAL,
  0xFF1100L, 8,0, 13,1,
16, -1, -1, G_STRING, NONE, NORMAL,
  (long)"  Ende", 0,0, 13,1,
6, 19, 20, G_BOX, NONE, NORMAL,
  0xFF1100L, 15,0, 15,2,
20, -1, -1, G_STRING, NONE, NORMAL,
  (long)"  Font...", 0,0, 15,1,
18, -1, -1, G_STRING, LASTOB, NORMAL,
  (long)"  Attribute...", 0,1, 15,1,
-1, 1, 9, G_BOX, NONE, NORMAL,
  0x1141L, 0,0, 1088,2319,
9, 2, 2, G_IBOX, NONE, NORMAL,
  0x11100L, 1,1, 1557,522,
1, 3, 8, G_BOX, NONE, OUTLINED,
  0x21100L, 1,1, 1043,1544,
4, -1, -1, G_BUTTON, 0x7, NORMAL,
  (long)"OK", 1797,1542, 8,1,
5, -1, -1, G_BOXTEXT, TOUCHEXIT, NORMAL,
  (long)&rs_tedinfo[0], 770,770, 15,1,
6, -1, -1, G_BOXTEXT, TOUCHEXIT, NORMAL,
  (long)&rs_tedinfo[1], 770,1795, 15,1,
7, -1, -1, G_BOXTEXT, TOUCHEXIT, NORMAL,
  (long)&rs_tedinfo[2], 770,2820, 15,1,
8, -1, -1, G_IMAGE, TOUCHEXIT, NORMAL,
  (long)&rs_bitblk[0], 1280,768, 1797,2817,
2, -1, -1, G_STRING, NONE, NORMAL,
  (long)"Font", 1287,3072, 6,1,
0, 10, 10, G_IBOX, NONE, NORMAL,
  0x11100L, 1561,3840, 1045,2314,
9, 11, 17, G_BOX, NONE, OUTLINED,
  0x21100L, 1536,2048, 1811,2825,
12, -1, -1, G_IMAGE, TOUCHEXIT, NORMAL,
  (long)&rs_bitblk[1], 1280,768, 1541,2561,
13, -1, -1, G_BOXTEXT, TOUCHEXIT, NORMAL,
  (long)&rs_tedinfo[3], 1026,2050, 15,1,
14, -1, -1, G_BOXTEXT, TOUCHEXIT, NORMAL,
  (long)&rs_tedinfo[4], 1026,2819, 15,1,
15, -1, -1, G_BOXTEXT, TOUCHEXIT, NORMAL,
  (long)&rs_tedinfo[5], 1026,3588, 15,1,
16, -1, -1, G_BOXTEXT, TOUCHEXIT, NORMAL,
  (long)&rs_tedinfo[6], 1026,262, 15,1,
17, -1, -1, G_BUTTON, 0x7, NORMAL,
  (long)"OK", 262,2823, 8,1,
10, -1, -1, G_STRING, LASTOB, NORMAL,
  (long)"Text", 1031,1, 6,1};

LONG rs_trindex[] = { 0L, 21L };

struct foobar {
 WORD dummy;
 WORD *image;
 } rs_imdope[2];

#define NUM_OBS 39
