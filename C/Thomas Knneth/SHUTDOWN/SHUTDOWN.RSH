/* GEM Resource C Source */

#include <portab.h>
#include <aes.h>
#include "SHUTDOWN.H"

#if !defined(WHITEBAK)
#define WHITEBAK    0x0040
#endif
#if !defined(DRAW3D)
#define DRAW3D      0x0080
#endif

#define FLAGS9  0x0200
#define FLAGS10 0x0400
#define FLAGS11 0x0800
#define FLAGS12 0x1000
#define FLAGS13 0x2000
#define FLAGS14 0x4000
#define FLAGS15 0x8000
#define STATE8  0x0100
#define STATE9  0x0200
#define STATE10 0x0400
#define STATE11 0x0800
#define STATE12 0x1000
#define STATE13 0x2000
#define STATE14 0x4000
#define STATE15 0x8000

TEDINFO rs_tedinfo[] =
{ "Thomas K\201nneth",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1480, 0, 0, 15, 1,
  "Friedrich-Neuper-Str. 2b",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1480, 0, 0, 25, 1,
  "90552 R\224thenbach",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1480, 0, 0, 17, 1,
  "(c) 1995 MAXON",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x0180, 0, 0, 15, 1
};

WORD RSBB0DATA[] =
{ 0x001F, 0xFFFC, 0x0018, 0x000C, 
  0x0014, 0x0014, 0x0012, 0xAAA4, 
  0x0011, 0x5564, 0x0012, 0xAAA4, 
  0x0011, 0x5D64, 0x0012, 0xE6A4, 
  0x0011, 0x4364, 0x0012, 0xC2A4, 
  0x0011, 0x6564, 0x0012, 0xA6A4, 
  0x0011, 0x6564, 0x0012, 0xB2A4, 
  0x0011, 0x5364, 0x0013, 0xF3E4, 
  0x0014, 0x1214, 0x0018, 0x120C, 
  0x009F, 0xE7FC, 0x0761, 0x8400, 
  0x081E, 0x0800, 0x1040, 0x3000, 
  0x21B0, 0xC000, 0x460F, 0x0000
};

WORD RSBB1DATA[] =
{ 0x07FF, 0xFFE0, 0x07FF, 0xFFE0, 
  0x07FF, 0xFFE0, 0x0700, 0x00E0, 
  0x0768, 0x00E0, 0x0700, 0x00E0, 
  0x0700, 0x00E0, 0x076E, 0xE8E0, 
  0x0700, 0x00E0, 0x076A, 0x98E0, 
  0x0700, 0x00E0, 0x076C, 0xD8E0, 
  0x0700, 0x00E0, 0x0766, 0xA8E0, 
  0x0700, 0x00E0, 0x0768, 0x00E0, 
  0x0700, 0x00E0, 0x07FF, 0xFFE0, 
  0x07FF, 0xFFE0, 0x07FF, 0xFFE0, 
  0x003F, 0xFC00, 0x03FF, 0xFFC0, 
  0x03FF, 0xFFC0, 0x0000, 0x0000
};

WORD RSBB2DATA[] =
{ 0x007F, 0xFE00, 0x00C0, 0x0300, 
  0x01BF, 0xFD80, 0x037F, 0xFEC0, 
  0x06FF, 0xFF60, 0x0DFF, 0xFFB0, 
  0x1BFF, 0xFFD8, 0x37FF, 0xFFEC, 
  0x6FFF, 0xFFF6, 0xDFFF, 0xFFFB, 
  0xB181, 0x860D, 0xA081, 0x0205, 
  0xA4E7, 0x3265, 0xA7E7, 0x3265, 
  0xA3E7, 0x3265, 0xB1E7, 0x3205, 
  0xB8E7, 0x320D, 0xBCE7, 0x327D, 
  0xA4E7, 0x327D, 0xA0E7, 0x027D, 
  0xB1E7, 0x867D, 0xBFFF, 0xFFFD, 
  0xDFFF, 0xFFFB, 0x6FFF, 0xFFF6, 
  0x37FF, 0xFFEC, 0x1BFF, 0xFFD8, 
  0x0DFF, 0xFFB0, 0x06FF, 0xFF60, 
  0x037F, 0xFEC0, 0x01BF, 0xFD80, 
  0x00C0, 0x0300, 0x007F, 0xFE00
};

BITBLK rs_bitblk[] =
{ RSBB0DATA,   4,  24,   0,   0, 0x0001,
  RSBB1DATA,   4,  24,   0,   0, 0x0001,
  RSBB2DATA,   4,  32,   0,   0, 0x0002
};

OBJECT rs_object[] =
{ 
  /******** Tree 0 MAIN_PAGE ****************************************************/
        -1,        1,        9, G_BOX             ,   /* Object 0  */
  NONE, NORMAL, (LONG)0x00FF1000L,
  0x0000, 0x0000, 0x0020, 0x000B,
  BT_MP_SHUTDOWN  ,       -1,       -1, G_IMAGE           ,   /* Object 1  */
  NONE, NORMAL, (LONG)&rs_bitblk[0],
  0x0401, 0x0001, 0x0004, 0x0801,
         3,       -1,       -1, G_BUTTON          ,   /* Object 2 BT_MP_SHUTDOWN */
  SELECTABLE|EXIT|FLAGS9|FLAGS10, NORMAL, (LONG)"Ausschalten",
  0x0408, 0x0801, 0x0011, 0x0001,
  PU_MP_SELRES    ,       -1,       -1, G_IMAGE           ,   /* Object 3  */
  NONE, NORMAL, (LONG)&rs_bitblk[1],
  0x0002, 0x0004, 0x0004, 0x0801,
         5,       -1,       -1, G_BUTTON          ,   /* Object 4 PU_MP_SELRES */
  TOUCHEXIT, SHADOWED, (LONG)"Aufl\224sungswechsel",
  0x0408, 0x0804, 0x0011, 0x0001,
         6,       -1,       -1, G_TEXT            ,   /* Object 5  */
  NONE, NORMAL, (LONG)&rs_tedinfo[0],
  0x000B, 0x0806, 0x040A, 0x0800,
         7,       -1,       -1, G_TEXT            ,   /* Object 6  */
  NONE, NORMAL, (LONG)&rs_tedinfo[1],
  0x0007, 0x0007, 0x0012, 0x0800,
         8,       -1,       -1, G_TEXT            ,   /* Object 7  */
  NONE, NORMAL, (LONG)&rs_tedinfo[2],
  0x000A, 0x0807, 0x000C, 0x0800,
         9,       -1,       -1, G_TEXT            ,   /* Object 8  */
  NONE, NORMAL, (LONG)&rs_tedinfo[3],
  0x000B, 0x0808, 0x040A, 0x0800,
         0, BT_MP_CANCEL    , BT_MP_CANCEL    , G_BOX             ,   /* Object 9  */
  NONE, NORMAL, (LONG)0x00FF1000L,
  0x0000, 0x0009, 0x0020, 0x0002,
         9,       -1,       -1, G_BUTTON          ,   /* Object 10 BT_MP_CANCEL */
  SELECTABLE|DEFAULT|EXIT|LASTOB|FLAGS9|FLAGS10, NORMAL, (LONG)"Abbruch",
  0x0017, 0x0800, 0x0407, 0x0001,
  
  /******** Tree 1 SHUT_ERROR ****************************************************/
        -1,        1,        1, G_BOX             ,   /* Object 0  */
  NONE, NORMAL, (LONG)0x00FF1000L,
  0x0000, 0x0000, 0x0020, 0x000B,
         0,        2, BT_ED_OK        , G_BOX             ,   /* Object 1  */
  NONE, OUTLINED, (LONG)0x00021000L,
  0x0002, 0x0800, 0x001C, 0x000A,
         3,       -1,       -1, G_STRING          ,   /* Object 2  */
  NONE, NORMAL, (LONG)"Der Shutdown bzw.",
  0x0407, 0x0001, 0x0011, 0x0001,
         4,       -1,       -1, G_IMAGE           ,   /* Object 3  */
  NONE, NORMAL, (LONG)&rs_bitblk[2],
  0x0002, 0x0801, 0x0004, 0x0002,
         5,       -1,       -1, G_STRING          ,   /* Object 4  */
  NONE, NORMAL, (LONG)"Aufl\224sungswechsel",
  0x0407, 0x0002, 0x0011, 0x0001,
         6,       -1,       -1, G_STRING          ,   /* Object 5  */
  NONE, NORMAL, (LONG)"kann leider nicht",
  0x0407, 0x0003, 0x0011, 0x0001,
         7,       -1,       -1, G_STRING          ,   /* Object 6  */
  NONE, NORMAL, (LONG)"durchgef\201hrt werden. Bitte",
  0x0001, 0x0004, 0x001A, 0x0001,
         8,       -1,       -1, G_STRING          ,   /* Object 7  */
  NONE, NORMAL, (LONG)"beenden Sie zun\204chst alle",
  0x0001, 0x0005, 0x0019, 0x0001,
  BT_ED_KILL      ,       -1,       -1, G_STRING          ,   /* Object 8  */
  NONE, NORMAL, (LONG)"laufenden Anwendungen.",
  0x0001, 0x0006, 0x0016, 0x0001,
  BT_ED_OK        ,       -1,       -1, G_BUTTON          ,   /* Object 9 BT_ED_KILL */
  SELECTABLE|EXIT|FLAGS9|FLAGS10, NORMAL, (LONG)"Kill",
  0x0401, 0x0008, 0x0007, 0x0001,
         1,       -1,       -1, G_BUTTON          ,   /* Object 10 BT_ED_OK */
  SELECTABLE|DEFAULT|EXIT|LASTOB|FLAGS9|FLAGS10, NORMAL, (LONG)"OK",
  0x0013, 0x0008, 0x0007, 0x0001,
  
  /******** Tree 2 SHUT_DO ****************************************************/
        -1,        1,        1, G_BOX             ,   /* Object 0  */
  NONE, NORMAL, (LONG)0x00FF1000L,
  0x0000, 0x0000, 0x0020, 0x000B,
         0,        2, BT_DOSHUT_CAN   , G_BOX             ,   /* Object 1  */
  NONE, OUTLINED, (LONG)0x00021000L,
  0x0002, 0x0800, 0x001C, 0x000A,
         3,       -1,       -1, G_STRING          ,   /* Object 2  */
  NONE, NORMAL, (LONG)"Bitte best\204tigen Sie mit",
  0x0401, 0x0001, 0x0018, 0x0001,
         4,       -1,       -1, G_STRING          ,   /* Object 3  */
  NONE, NORMAL, (LONG)"OK, da\236 der Shutdown bzw.",
  0x0401, 0x0002, 0x0019, 0x0001,
         5,       -1,       -1, G_STRING          ,   /* Object 4  */
  NONE, NORMAL, (LONG)"Aufl\224sungswechsel begon-",
  0x0401, 0x0003, 0x0018, 0x0001,
         6,       -1,       -1, G_STRING          ,   /* Object 5  */
  NONE, NORMAL, (LONG)"nen werden kann oder",
  0x0401, 0x0004, 0x0014, 0x0001,
         7,       -1,       -1, G_STRING          ,   /* Object 6  */
  NONE, NORMAL, (LONG)"klicken Sie auf Abbruch,",
  0x0002, 0x0005, 0x0018, 0x0001,
  BT_DOSHUT_OK    ,       -1,       -1, G_STRING          ,   /* Object 7  */
  NONE, NORMAL, (LONG)"um die Aktion abzubrechen",
  0x0002, 0x0006, 0x0019, 0x0001,
  BT_DOSHUT_CAN   ,       -1,       -1, G_BUTTON          ,   /* Object 8 BT_DOSHUT_OK */
  SELECTABLE|EXIT|FLAGS9|FLAGS10, NORMAL, (LONG)"OK",
  0x040A, 0x0008, 0x0007, 0x0001,
         1,       -1,       -1, G_BUTTON          ,   /* Object 9 BT_DOSHUT_CAN */
  SELECTABLE|DEFAULT|EXIT|LASTOB|FLAGS9|FLAGS10, NORMAL, (LONG)"Abbruch",
  0x0413, 0x0008, 0x0007, 0x0001,
  
  /******** Tree 3 SHUT_DONE ****************************************************/
        -1,        1,        1, G_BOX             ,   /* Object 0  */
  NONE, NORMAL, (LONG)0x00FF1000L,
  0x0000, 0x0000, 0x0020, 0x000B,
         0,        2,        3, G_BOX             ,   /* Object 1  */
  NONE, OUTLINED, (LONG)0x00021000L,
  0x0002, 0x0800, 0x001C, 0x000A,
         3,       -1,       -1, G_STRING          ,   /* Object 2  */
  NONE, NORMAL, (LONG)"Bitte schalten Sie jetzt",
  0x0402, 0x0004, 0x0018, 0x0001,
         1,       -1,       -1, G_STRING          ,   /* Object 3  */
  LASTOB, NORMAL, (LONG)"Ihren Rechner aus...",
  0x0402, 0x0005, 0x0014, 0x0001
};

OBJECT *rs_trindex[] =
{ &rs_object[0],   /* Tree  0 MAIN_PAGE        */
  &rs_object[11],   /* Tree  1 SHUT_ERROR       */
  &rs_object[22],   /* Tree  2 SHUT_DO          */
  &rs_object[32]    /* Tree  3 SHUT_DONE        */
};
