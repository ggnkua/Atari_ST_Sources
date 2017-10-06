/*****************************************/
/* File : BOOT.RSH                       */
/* ------------------------------------- */
/* Module : BOOT.CPX       Versie 1.00   */
/* (C) 1990 MAXON Computer               */
/* Auteurs : Uwe Hax & Oliver Scholz     */
/* Van RCS uit resource-file aangemaakte */
/* Include-file                          */
/*****************************************/


#define	NUM_FRSTR	0
#define	NUM_FRIMG	0
#define	NUM_OBS	35
#define	NUM_TREE 2


BYTE *rs_strings[] =
{
  "Anzeige:","","","*.ACC"," Aktiv ","","",
  " Inaktiv ","","","________","","","________",
  "","","________","","","________","","",
  "________","","","________","","","________",
  "","","________","","","________","","",
  "________","","","ACC deaktivieren","","",
  "Ausgang",
  "(C) 1990 by Uwe Hax & Oliver Scholz",
  "","","Die maximale Anzahl der",
  "verwaltbaren Dateien","wurde uberschritten!",
  "Sie solten Ihre Festplatte",
  "mal wieder aufraumen!","Mist!"
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
  (char *)0L, (char *)1L, (char *)2L, 3, 6, 2,
  0x1180, 0x0, 255, 9,1,
  (char *)4L, (char *)5L, (char *)6L, 3, 6, 2,
  0x11A1, 0x0, 255, 8,1,
  (char *)7L, (char *)8L, (char *)9L, 3, 6, 2,
  0x11A1, 0x0, 255, 10,1,
  (char *)10L, (char *)11L, (char *)12L, 3, 6, 2,
  0x1180, 0x0, 255, 9,1,
  (char *)13L, (char *)14L, (char *)15L, 3, 6, 2,
  0x1180, 0x0, 255, 9,1,
  (char *)16L, (char *)17L, (char *)18L, 3, 6, 2,
  0x1180, 0x0, 255, 9,1,
  (char *)19L, (char *)20L, (char *)21L, 3, 6, 2,
  0x1180, 0x0, 255, 9,1,
  (char *)22L, (char *)23L, (char *)24L, 3, 6, 2,
  0x1180, 0x0, 255, 9,1,
  (char *)25L, (char *)26L, (char *)27L, 3, 6, 2,
  0x1180, 0x0, 255, 9,1,
  (char *)28L, (char *)29L, (char *)30L, 3, 6, 2,
  0x1180, 0x0, 255, 9,1,
  (char *)31L, (char *)32L, (char *)33L, 3, 6, 2,
  0x1180, 0x0, 255, 9,1,
  (char *)34L, (char *)35L, (char *)36L, 3, 6, 2,
  0x1180, 0x0, 255, 9,1,
  (char *)37L, (char *)38L, (char *)39L, 3, 6, 2,
  0x1180, 0x0, 255, 9,1,
  (char *)40L, (char *)41L, (char *)42L, 3, 6, 2,
  0x1180, 0x0, 254, 17,1,
  (char *)44L, (char *)45L, (char *)46L, 5, 6, 0,
  0x1180, 0x0, 255, 36,1,
};

OBJECT rs_object[] =
{
  -1,1, 27, G_BOX, NONE, NORMAL, 0xFF1141L,
  0,0, 32,11,
  2, -1, -1, G_BOXTEXT, NONE, NORMAL, 0x0L,
  2,768, 274,257,
  3, -1, -1, G_BUTTON, 0x41, SHADOWED, 0x3L,
  789,768, 8,1,
  4, -1, -1, G_BOXTEXT, NONE, NORMAL, 0x1L,
  2,2049, 525,257,
  5, -1, -1, G_BOXTEXT, NONE, NORMAL, 0x2L,
  1040,2049, 528,257,
  11, 6, 10, G_BOX, NONE, NORMAL, 0xFF1100L,
  2,2562, 1802,5,
  7, -1, -1, G_TEXT, 0x51, NORMAL, 0x3L,
  0,0, 1802,1,
  8, -1, -1, G_TEXT, 0x51, NORMAL, 0x4L,
  0,2, 1802,1,
  9, -1, -1, G_TEXT, 0x51, NORMAL, 0x5L,
  0,3, 1802,1,
  10, -1, -1 ,G_TEXT, 0x51, NORMAL, 0x6L,
  0,1, 1802,1,
  5, -1, -1, G_TEXT, 0x51, NORMAL, 0x7L,
  0,4, 1802,1,
  12, -1, -1, G_BOXCHAR, TOUCHEXIT, NORMAL,
  0x1FF1100L, 13,2562, 514,1,
  18, 13, 17, G_BOX, NONE, NORMAL, 0xFF1100L,
  1040,2562, 1802,5,
  14, -1, -1, G_TEXT, 0x51, NORMAL, 0x8L,
  0,0, 1802,1,
  15, -1, -1, G_TEXT, 0x51, NORMAL, 0x9L,
  0,1, 1802,1,
  16, -1, -1, G_TEXT, 0x51, NORMAL, 0xAL,
  0,2, 1802,1,
  17, -1, -1, G_TEXT, 0x51, NORMAL, 0xBL,
  0,3, 1802,1,
  12, -1, -1, G_TEXT, 0x51, NORMAL, 0xCL,
  0,4, 1802, 1,
  19, -1, -1, G_BOXCHAR, TOUCHEXIT, NORMAL,
  0x1FF1100L, 1051,2562, 514,1,
  21, 20, 20, G_BOX, TOUCHEXIT, NORMAL,
  0xFF1111L, 13,2819, 514,3586,
  19, -1, -1, G_BOX, TOUCHEXIT, NORMAL,
  0xFF1100L, 0,0, 514,258,
  23, 22, 22, G_BOX, TOUCHEXIT, NORMAL,
  0xFF1111L, 1051,2819, 514,3586,
  21, -1, -1, G_BOX, TOUCHEXIT, NORMAL,
  0xFF1100L, 0,0, 514,258,
  24, -1, -1, G_BOXCHAR, TOUCHEXIT, NORMAL,
  0x2FF1100L, 13,2566, 514,1,
  25, -1, -1, G_BOXCHAR, TOUCHEXIT, NORMAL,
  0x2FF1100L, 1051,2566, 514,1,
  26, -1, -1, G_BOXTEXT, 0x41, NORMAL, 0xDL,
  2,3591, 1563,1,
  27, -1, -1, G_BUTTON, 0x7, NORMAL, 0x2BL,
  778,1033, 1290,1,
  0, -1, -1, G_TEXT, LASTOB, NORMAL, 0xEL,
  1282,2314, 1306,1536,
  -1, 1, 6, G_BOX, NONE, OUTLINED, 0x21100L,
  0,0, 797,3848,
  2, -1, -1, G_STRING, NONE, NORMAL, 0x2FL,
  1538,3804, 23,1,
  3, -1, -1, G_STRING, NONE, NORMAL, 0x30L,
  516,3841, 21,1,
  4, -1, -1, G_STRING, NONE, NORMAL, 0x31L,
  1028, 3842, 20,1,
  5, -1, -1, G_STRING, NONE, NORMAL, 0x32L,
  257,2308, 27,1,
  6, -1, -1, G_STRING, NONE, NORMAL, 0x33L,
  771,2309, 21,1,
  0, -1, -1, G_BUTTON, 0x27, NORMAL, 0x34L,
  778,1031, 8,1,
};


LONG rs_trindex[] =
{
  0L,27L
};

struct foobar
{
  WORD	dummy;
  WORD	*image;
} rs_imdope[] = {
                  0
                };
                