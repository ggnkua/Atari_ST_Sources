OBJECT rs_object[] = {
-1, 1, 13, G_BOX, NONE, OUTLINED,
    0x21100L, 0,0, 34,12,
2, -1, -1, G_BUTTON, 0x5, NORMAL,
    (long)"POWER", 2,1, 8,1,
3, -1, -1, G_STRING, NONE, NORMAL,
    (long)"SIRCS-Fernbedienung", 13,1, 19,1,
4, -1, -1, G_BUTTON, 0x5, NORMAL,
    (long)"PAUSE", 3,4, 8,1,
5, -1, -1, G_BUTTON, 0x5, NORMAL,
    (long)"PLAY", 13,4, 8,1,
6, -1, -1, G_BUTTON, 0x5, NORMAL,
    (long)"REC", 23,4, 8,1,
7, -1, -1, G_BUTTON, TOUCHEXIT, NORMAL,
    (long)"REW", 3,6, 8,1,
8, -1, -1, G_BUTTON, 0x5, NORMAL,
    (long)"STOP", 13,6, 8,1,
9, -1, -1, G_BUTTON, TOUCHEXIT, NORMAL,
    (long)"FF", 23,6, 8,1,
10, -1, -1, G_BUTTON, 0x5, NORMAL,
    (long)"EJECT", 3,8, 8,1,
11, -1, -1, G_BUTTON, 0x7, NORMAL,
    (long)"FERTIG", 13,10, 8,1,
12, -1, -1, G_BUTTON, TOUCHEXIT, NORMAL,
    (long)"+", 29,8, 2,1,
13, -1, -1, G_BUTTON, TOUCHEXIT, NORMAL,
    (long)"-", 29,10, 2,1,
0, -1, -1, G_STRING, LASTOB, NORMAL,
    (long)"Programm:", 19,8, 9,1};

LONG rs_trindex[] = {
0L};

struct foobar {
 WORD dummy;
 WORD *image;
 } rs_imdope[] = {
0};

#define NUM_OBS 14
#define NUM_TREE 1

