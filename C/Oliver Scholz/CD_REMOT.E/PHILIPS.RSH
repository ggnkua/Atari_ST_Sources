OBJECT rs_object[] = {
-1, 1, 10, G_BOX, NONE, OUTLINED, 0x21100L, 0,0, 34,12,
2, -1, -1, G_BUTTON, 0x5, NORMAL, (long)"POWER", 2,1, 8,1,
3, -1, -1, G_STRING, NONE, NORMAL, (long)"RC-5 Fernbedienung", 13,1, 19,1,
4, -1, -1, G_BUTTON, 0x5, NORMAL, (long)"PAUSE", 3,4, 8,1,
5, -1, -1, G_BUTTON, 0x5, NORMAL, (long)"STOP", 13,4, 8,1,
6, -1, -1, G_BUTTON, 0x5, NORMAL, (long)"PLAY", 23,4, 8,1,
7, -1, -1, G_BUTTON, 0x5, NORMAL, (long)"< SKIP", 3,6, 8,1,
8, -1, -1, G_BUTTON, 0x5, NORMAL, (long)"DISPLAY", 8,8, 8,1,
9, -1, -1, G_BUTTON, 0x5, NORMAL, (long)"SKIP >", 23,6, 8,1,
10, -1, -1, G_BUTTON, 0x5, NORMAL, (long)"OPEN/CLOSE", 18,8, 10,1,
0, -1, -1, G_BUTTON, 0x27, NORMAL, (long)"FERTIG", 13,10, 8,1};

LONG rs_trindex[] = {
0L};

struct foobar {
    WORD    dummy;
    WORD    *image;
    } rs_imdope[] = {
0};

#define NUM_OBS 11
#define NUM_TREE 1

