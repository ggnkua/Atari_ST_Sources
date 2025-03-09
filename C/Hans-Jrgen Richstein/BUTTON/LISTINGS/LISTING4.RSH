/*----------------------------------------------
|    BUT_DSGN.RSH        Resource-File         |
|                                              |
| Dieses File wurde mit RSC2CSRC von Erik Dick | 
| erzeugt und zum Abdruck von Hand nachbe-     |
| arbeitet.                                    |
|                                              |
-----------------------------------------------*/

#include <aes.h>
#include <vdi.h>

#define NUM_OBS 28

void    objc_init( void );
extern  OBJECT *TREE[],rs_object[];
/*---------------------------------------------*/

void objc_init( void )
{   int i;

    for(i = 0; i < NUM_OBS; 
                rsrc_obfix(rs_object,i++));
}
/*------------- TEDINFO-Strings ---------------*/

char    TED0_s[15] = " Button Design";
#define TED0_t ""
#define TED0_v ""
char    TED1_s[26] = "von Hans-Jrgen Richstein";
#define TED1_t ""
#define TED1_v ""
char    TED2_s[15] = "";
#define TED2_t "______________"
#define TED2_v "XXXXXXXXXXXXXX"
char    TED3_s[20] = "(c) Maxon GmbH 1990";
#define TED3_t ""
#define TED3_v ""
#define FSTR0 "Aus"
#define FSTR1 "Ein"
#define FSTR2 "Test"
#define FSTR3 "Schaltername"
#define FSTR4 "Neuer C-Code"
#define FSTR5 "C-Code anfgen"
#define FSTR6 "Bitmap speichern"
#define FSTR7 "Bitmap laden"
#define FSTR8 "Ende"
#define FSTR9 "Raster +'Ein'"
#define FSTR10 "L”schen"

/*---------------- Bitblocks ------------------*/

int IMAGE0[16] = {0};
int IMAGE1[16] = {0};
int IMAGE2[16] = {0};

/*------------- BITBLK-structures -------------*/

BITBLK rs_bitblk[] =
{   IMAGE0,0x2 ,0x10,0x0 ,0x0 ,0x1 ,
    IMAGE1,0x2 ,0x10,0x0 ,0x0 ,0x1 ,
    IMAGE2,0x2 ,0x10,0x0 ,0x0 ,0x1   
};

/*------------ TEDINFO-structures -------------*/

TEDINFO rs_tedinfo[] =
{   TED0_s,TED0_t,TED0_v,IBM ,0x6 ,TE_LEFT,
                    0x1071,0x0 ,0x1 ,0xf ,0x1 ,
    TED1_s,TED1_t,TED1_v,SMALL ,0x6 ,TE_LEFT,
                    0x1000,0x0 ,0xffff,0x1a,0x1 ,
    TED2_s,TED2_t,TED2_v,IBM ,0x6 ,TE_LEFT,
                    0x1180,0x0 ,0xffff,0xf ,0xf ,
    TED3_s,TED3_t,TED3_v,SMALL ,0x6 ,TE_CNTR,
                    0x1180,0x0 ,0xffff,0x14,0x1
};

/*------------- Object-structures -------------*/

OBJECT rs_object[] =
{       -1, 1,27,G_BOX   ,NONE    ,OUTLINED,
                    0X21111L,1030,3584,42,2067,
         3, 2, 2,G_BOXTEXT,NONE   ,OUTLINED,
        (long) &rs_tedinfo[0],514,2560,1061,1793,
         1,-1,-1,G_TEXT  ,NONE    ,NORMAL,
       (long) &rs_tedinfo[1],1297,2560,1554,2560,
        19, 4,18,G_BOX   ,NONE    ,NORMAL,
                    0XFF1141L,2,2306,21,16,
        11, 5,10,G_BOX   ,NONE    ,NORMAL,
                    0XFF1101L,1,2304,19,5,
         6,-1,-1,G_IMAGE ,TOUCHEXIT ,OUTLINED,
              (long) &rs_bitblk[0],2,1,4096,4096,
         7,-1,-1,G_IMAGE ,TOUCHEXIT ,OUTLINED,
              (long) &rs_bitblk[1],2,3,4096,4096,
         8,-1,-1,G_STRING,NONE    ,NORMAL,
                            (long) FSTR0,5,1,3,1,
         9,-1,-1,G_STRING,NONE    ,NORMAL,
                            (long) FSTR1,5,3,3,1,
        10,-1,-1,G_IMAGE ,NONE    ,NORMAL,
             (long) &rs_bitblk[2],11,2,4096,4096,
         4,-1,-1,G_STRING,TOUCHEXIT ,OUTLINED,
                           (long) FSTR2,14,2,4,1,
        14,12,13,G_BOX   ,NONE    ,NORMAL,
                       0XFF1101L, 1, 6,19,  2050,
        13,-1,-1,G_STRING,NONE    ,NORMAL,
                       (long) FSTR3,515,512,12,1,
        11,-1,-1,G_FTEXT ,EDITABLE,NORMAL,
             (long) &rs_tedinfo[2],514,769,14, 1,
        15,-1,-1,G_BUTTON,TOUCHEXIT ,NORMAL,
                         (long) FSTR4,1,521,19,1,
        16,-1,-1,G_BUTTON,TOUCHEXIT ,NORMAL,
                        (long) FSTR5,1,1802,19,1,
        17,-1,-1,G_BUTTON,TOUCHEXIT ,NORMAL,
                       (long) FSTR6,1,3083,19, 1,
        18,-1,-1,G_BUTTON,TOUCHEXIT ,NORMAL,
                         (long) FSTR7,1,269,19,1,
         3,-1,-1,G_BUTTON,TOUCHEXIT ,NORMAL,
                        (long) FSTR8,1,2574,19,1,
        20,-1,-1,G_BOX   ,TOUCHEXIT ,NORMAL,
                    0XFF1181L,280,2306,1807,3847,
        27,21,26,G_BOX   ,NONE    ,NORMAL,
                         0XFF1141L,280,11,1807,6,
        22,-1,-1,G_BUTTON,TOUCHEXIT ,NORMAL,
                           (long) FSTR9,1,2,14,1,
        23,-1,-1,G_BOXCHAR ,TOUCHEXIT ,NORMAL,
                  (long) 0X1FF1100L,520,4,3,2049,
        24,-1,-1,G_BOXCHAR ,TOUCHEXIT ,NORMAL,
                 (long) 0X2FF1100L,1284,4,3,2049,
        25,-1,-1,G_BOXCHAR ,TOUCHEXIT ,NORMAL,
                    (long) 0X4FF1100L,1,4,3,2049,
        26,-1,-1,G_BOXCHAR ,TOUCHEXIT ,NORMAL,
                 (long) 0X3FF1100L,1803,4,3,2049,
        20,-1,-1,G_BUTTON,TOUCHEXIT ,NORMAL,
                    (long) FSTR10,1792,2048,14,1,
         0,-1,-1,G_BOXTEXT ,LASTOB  ,NORMAL,
            (long) &rs_tedinfo[3],280,2321,1807,1
};
/*------------ TREE-Index ---------------------*/

OBJECT *TREE[] =
{   (OBJECT *) &rs_object[0]
};
