
char *rs_strings[]={
"Thanks a lot",
"**********",
"OK",
"",
"Name: __________",
"XXXXXXXXXX",
"OK",
"Please type in your name.",
""
};

OBJECT rs_object[]={
-1,1,3,G_BOX,0x0,0x10,135424L,0x0,0x0,0x2D,0x5,
2,-1,-1,G_STRING,0x0,0x0,0L,0x4,0x2,0xC,0x1,
3,-1,-1,G_STRING,0x0,0x0,1L,0x11,0x2,0xA,0x1,
0,-1,-1,G_BUTTON,0x27,0x0,2L,0x20,0x2,0x8,0x1,
-1,1,3,G_BOX,0x0,0x10,135424L,0x0,0x0,0x39,0x7,
2,-1,-1,G_FTEXT,0x8,0x0,0L,0x9,0x4,0x10,0x1,
3,-1,-1,G_BUTTON,0x7,0x0,6L,0x26,0x4,0x8,0x1,
0,-1,-1,G_STRING,0x20,0x0,7L,0xF,0x2,0x19,0x1
};

BITBLK rs_bitblk[] ;

ICONBLK rs_iconblk[] ;

TEDINFO rs_tedinfo[]={
3L,4L,5L,3,6,0,4480,0,255,1,17
};
long rs_trindex[]={
4L,
0L
};
rs_frstr[] ;
long rs_frimg[] ;
struct foobar {
        int dummy;
        int *image;
        } rs_imdope[] ;
#define NUM_TI 1
#define NUM_BB 0
#define NUM_OBS 8
#define NUM_IB 0
#define NUM_FRSTR 0
#define NUM_FRIMG 0
#define NUM_TREE 2
#define NUM_STRINGS 9
#define NUM_IMAGES  0
