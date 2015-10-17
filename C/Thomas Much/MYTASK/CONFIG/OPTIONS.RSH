/* GEM Resource C Source */

#include <portab.h>
#include "OPTIONS.H"

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
{ "Untere Zeile",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1100, 0, -1, 13, 1,
  "Obere Zeile",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1100, 0, -1, 12, 1,
  "_______________",
  "_______________",
  "XXXXXXXXXXXXXXX",
  IBM  , 0, TE_CNTR , 0x1180, 0, 0, 16, 16,
  "_______________",
  "_______________",
  "XXXXXXXXXXXXXXX",
  IBM  , 0, TE_CNTR , 0x1180, 0, 0, 16, 16,
  "Name",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1100, 0, -1, 5, 1,
  "____________________",
  "____________________",
  "XXXXXXXXXXXXXXXXXXXX",
  IBM  , 0, TE_CNTR , 0x1180, 0, 0, 21, 21,
  "ms",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1100, 0, -1, 3, 1,
  "Zeit:",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1100, 0, -1, 6, 1,
  " 9999 ",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1100, 0, -1, 7, 1,
  "______________________________",
  "______________________________",
  "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
  IBM  , 0, TE_CNTR , 0x1180, 0, 0, 31, 31,
  "Application",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1100, 0, -1, 12, 1,
  "Accesory",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1100, 0, -1, 9, 1,
  "System",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1100, 0, -1, 7, 1,
  "Shell",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1100, 0, -1, 6, 1,
  "CAPS On",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1100, 0, -1, 8, 1,
  "CAPS Off",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1100, 0, -1, 9, 1,
  "Frezzy app",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1100, 0, -1, 11, 1,
  "Hidden app",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1100, 0, -1, 11, 1,
  "Einfach Rechts",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1100, 0, -1, 15, 1,
  "Einfach Links",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1100, 0, -1, 14, 1,
  "Alt+ Rechts",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1100, 0, -1, 12, 1,
  "Alt+ Links",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1100, 0, -1, 11, 1,
  "Ctrl+ Rechts",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1100, 0, -1, 13, 1,
  "Ctrl+ Links",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1100, 0, -1, 12, 1,
  "Shift+ Rechts",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1100, 0, -1, 14, 1,
  "Shift+ Links",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1100, 0, -1, 13, 1,
  "______________________________",
  "______________________________",
  "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
  IBM  , 0, TE_CNTR , 0x1180, 0, 0, 31, 31,
  "__",
  "__",
  "XX",
  IBM  , 0, TE_CNTR , 0x1180, 0, 0, 3, 3,
  "__",
  "__",
  "XX",
  IBM  , 0, TE_CNTR , 0x1180, 0, 0, 3, 3
};

OBJECT rs_object[] =
{ 
  /******** Tree 0 G_MAIN ****************************************************/
        -1, OPT_OK          , OPT_BACK_SKINS  , G_BOX             ,   /* Object 0  */
  FLAGS10, NORMAL, (LONG)0x00001100L,
  0x0000, 0x0000, 0x0336, 0x0515,
  OPT_BACK_ALLGEM ,       -1,       -1, G_BUTTON          ,   /* Object 1 OPT_OK */
  SELECTABLE|DEFAULT|EXIT|FLAGS9, DRAW3D, (LONG)"OK",
  0x072B, 0x0711, 0x0008, 0x0001,
  OPT_BACK_STIC   ,        3, OPT_HTML_SEPARAT, G_BUTTON          |0x1400,   /* Object 2 OPT_BACK_ALLGEM */
  NONE, NORMAL, (LONG)" Allgemein ",
  0x0601, 0x0A02, 0x0428, 0x0811,
         4,       -1,       -1, G_TEXT            ,   /* Object 3  */
  FLAGS10, NORMAL, (LONG)&rs_tedinfo[0],
  0x0007, 0x0F0A, 0x000C, 0x0001,
  OPT_TIME2_BACK  ,       -1,       -1, G_TEXT            ,   /* Object 4  */
  FLAGS10, NORMAL, (LONG)&rs_tedinfo[1],
  0x0008, 0x0009, 0x000B, 0x0001,
  OPT_TIME1_BACK  , OPT_FORMAT_TIME2, OPT_FORMAT_TIME2, G_BUTTON          |0x1F00,   /* Object 5 OPT_TIME2_BACK */
  NONE, NORMAL, (LONG)"\0",
  0x0014, 0x0D0A, 0x000F, 0x0001,
  OPT_TIME2_BACK  ,       -1,       -1, G_FTEXT           ,   /* Object 6 OPT_FORMAT_TIME2 */
  NONE, NORMAL, (LONG)&rs_tedinfo[2],
  0x0000, 0x0000, 0x000F, 0x0001,
  OPT_VAPROTOSTAT , OPT_FORMAT_TIME1, OPT_FORMAT_TIME1, G_BUTTON          |0x1F00,   /* Object 7 OPT_TIME1_BACK */
  NONE, NORMAL, (LONG)"\0",
  0x0014, 0x0D08, 0x000F, 0x0001,
  OPT_TIME1_BACK  ,       -1,       -1, G_FTEXT           ,   /* Object 8 OPT_FORMAT_TIME1 */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[3],
  0x0000, 0x0000, 0x000F, 0x0001,
  OPT_AVNOTOS     ,       -1,       -1, G_BUTTON          |0x1200,   /* Object 9 OPT_VAPROTOSTAT */
  SELECTABLE, NORMAL, (LONG)"VA protocol status",
  0x0601, 0x0805, 0x0012, 0x0001,
  OPT_AVIGNORE    ,       -1,       -1, G_BUTTON          |0x1200,   /* Object 10 OPT_AVNOTOS */
  SELECTABLE, NORMAL, (LONG)"AV no TOS",
  0x0716, 0x0705, 0x0009, 0x0001,
  OPT_MAGXFADEOUT ,       -1,       -1, G_BUTTON          |0x1200,   /* Object 11 OPT_AVIGNORE */
  SELECTABLE, NORMAL, (LONG)"AV ignore",
  0x0716, 0x0304, 0x0009, 0x0001,
  OPT_TOSMULTISTAR,       -1,       -1, G_BUTTON          |0x1200,   /* Object 12 OPT_MAGXFADEOUT */
  SELECTABLE, NORMAL, (LONG)"MagiC fadeout",
  0x0716, 0x0F02, 0x000D, 0x0001,
  OPT_AVNOACC     ,       -1,       -1, G_BUTTON          |0x1200,   /* Object 13 OPT_TOSMULTISTAR */
  SELECTABLE, NORMAL, (LONG)"TOS multistart",
  0x0716, 0x0B01, 0x000E, 0x0001,
  OPT_DHSTCOOKIE  ,       -1,       -1, G_BUTTON          |0x1200,   /* Object 14 OPT_AVNOACC */
  SELECTABLE, NORMAL, (LONG)"AV no ACC",
  0x0601, 0x0F02, 0x0009, 0x0001,
  OPT_SAVELINKS   ,       -1,       -1, G_BUTTON          |0x1200,   /* Object 15 OPT_DHSTCOOKIE */
  SELECTABLE, NORMAL, (LONG)"DHST als Cookie",
  0x0601, 0x0304, 0x000F, 0x0001,
        17,       -1,       -1, G_BUTTON          |0x1200,   /* Object 16 OPT_SAVELINKS */
  SELECTABLE, NORMAL, (LONG)"Links speichern",
  0x0601, 0x0B01, 0x000F, 0x0001,
        18,       -1,       -1, G_TEXT            ,   /* Object 17  */
  FLAGS10, NORMAL, (LONG)&rs_tedinfo[4],
  0x040A, 0x020D, 0x0004, 0x0001,
        20, OPT_NAME        , OPT_NAME        , G_BUTTON          |0x1F00,   /* Object 18  */
  NONE, NORMAL, (LONG)"\0",
  0x010F, 0x000D, 0x0014, 0x0101,
        18,       -1,       -1, G_FTEXT           ,   /* Object 19 OPT_NAME */
  SELECTABLE|EXIT, NORMAL, (LONG)&rs_tedinfo[5],
  0x0000, 0x0000, 0x0014, 0x0101,
        21,       -1,       -1, G_TEXT            ,   /* Object 20  */
  FLAGS10, NORMAL, (LONG)&rs_tedinfo[6],
  0x021A, 0x090E, 0x0002, 0x0001,
  OPT_SCHRITT     ,       -1,       -1, G_TEXT            ,   /* Object 21  */
  FLAGS10, NORMAL, (LONG)&rs_tedinfo[7],
  0x0401, 0x0A0E, 0x0005, 0x0001,
  OPT_SCHRITT_BAR ,       -1,       -1, G_TEXT            ,   /* Object 22 OPT_SCHRITT */
  FLAGS10, NORMAL, (LONG)&rs_tedinfo[8],
  0x0314, 0x090E, 0x0006, 0x0001,
  OPT_FENSTERNUMME, OPT_SCHRITT_CUR , OPT_SCHRITT_CUR , G_BUTTON          |0x1700,   /* Object 23 OPT_SCHRITT_BAR */
  TOUCHEXIT, SELECTED|CHECKED, (LONG)" ",
  0x0507, 0x0A0E, 0x020C, 0x0001,
  OPT_SCHRITT_BAR ,       -1,       -1, G_BUTTON          |0x1700,   /* Object 24 OPT_SCHRITT_CUR */
  TOUCHEXIT, CROSSED|CHECKED, (LONG)"\0",
  0x0002, 0x0000, 0x0002, 0x0001,
  OPT_ACCSYSTRAY  ,       -1,       -1, G_BUTTON          |0x1200,   /* Object 25 OPT_FENSTERNUMME */
  SELECTABLE, NORMAL, (LONG)"Zeige Fenster-Nummer",
  0x0601, 0x0110, 0x0014, 0x0001,
  OPT_HTML_SEPARAT,       -1,       -1, G_BUTTON          |0x1200,   /* Object 26 OPT_ACCSYSTRAY */
  SELECTABLE, NORMAL, (LONG)"Zeige ACC in SystemTray",
  0x0601, 0x0D06, 0x0017, 0x0001,
  OPT_BACK_ALLGEM ,       -1,       -1, G_BUTTON          |0x1200,   /* Object 27 OPT_HTML_SEPARAT */
  SELECTABLE, NORMAL, (LONG)"HTML Separat",
  0x0716, 0x0D06, 0x000C, 0x0001,
  OPT_BACK_BEDINUN, OPT_STIC_POPUP  ,       31, G_BUTTON          |0x1400,   /* Object 28 OPT_BACK_STIC */
  NONE, NORMAL, (LONG)" StIc ",
  0x0601, 0x0A02, 0x0428, 0x0811,
  OPT_STIC_APPTRAY,       -1,       -1, G_BUTTON          |0x1200,   /* Object 29 OPT_STIC_POPUP */
  SELECTABLE, NORMAL, (LONG)"Verwende StIc in Popup",
  0x0303, 0x0103, 0x0016, 0x0001,
        31,       -1,       -1, G_BUTTON          |0x1200,   /* Object 30 OPT_STIC_APPTRAY */
  SELECTABLE, NORMAL, (LONG)"Verwende StIc in App-Tray",
  0x0303, 0x0B01, 0x0019, 0x0001,
  OPT_BACK_STIC   , OPT_STIC_TXTBUTT, OPT_TEXT_BUTT   , G_BUTTON          |0x1400,   /* Object 31  */
  SELECTABLE, NORMAL, (LONG)"StIc und Task-Buttons",
  0x0103, 0x0405, 0x061D, 0x0904,
  OPT_STIC_BUTT   ,       -1,       -1, G_BUTTON          |0x1200,   /* Object 32 OPT_STIC_TXTBUTT */
  SELECTABLE|RBUTTON, SELECTED|CROSSED, (LONG)"Icons und Text auf App-Tasten",
  0x0600, 0x0701, 0x001D, 0x0001,
  OPT_TEXT_BUTT   ,       -1,       -1, G_BUTTON          |0x1200,   /* Object 33 OPT_STIC_BUTT */
  SELECTABLE|RBUTTON, CROSSED, (LONG)"Nur Icons auf App-Tasten",
  0x0600, 0x0802, 0x0018, 0x0001,
        31,       -1,       -1, G_BUTTON          |0x1200,   /* Object 34 OPT_TEXT_BUTT */
  SELECTABLE|RBUTTON, CROSSED, (LONG)"Nur Text auf App-Tasten",
  0x0600, 0x0903, 0x0017, 0x0001,
  OPT_BACK_COLORS , OPT_NOQUITALERT , OPT_DOPPEL_BACK , G_BUTTON          |0x1400,   /* Object 35 OPT_BACK_BEDINUN */
  NONE, NORMAL, (LONG)" Bedienung ",
  0x0601, 0x0A02, 0x0428, 0x0811,
  OPT_DOCUMENTS   ,       -1,       -1, G_BUTTON          |0x1200,   /* Object 36 OPT_NOQUITALERT */
  SELECTABLE, NORMAL, (LONG)"Ohne Exit-Alert",
  0x0312, 0x0C03, 0x000F, 0x0001,
  OPT_DRIVES      ,       -1,       -1, G_BUTTON          |0x1200,   /* Object 37 OPT_DOCUMENTS */
  SELECTABLE, NORMAL, (LONG)"Zeige Dokumente (DHST)",
  0x0312, 0x0806, 0x0016, 0x0001,
  OPT_AUTOHIDE    ,       -1,       -1, G_BUTTON          |0x1200,   /* Object 38 OPT_DRIVES */
  SELECTABLE, NORMAL, (LONG)"Zeige Laufwerke",
  0x0312, 0x0205, 0x000F, 0x0001,
  OPT_LANGUAGE_BUT,       -1,       -1, G_BUTTON          |0x1200,   /* Object 39 OPT_AUTOHIDE */
  SELECTABLE, NORMAL, (LONG)"Autoverstecken",
  0x0601, 0x0C03, 0x000E, 0x0001,
  OPT_LANGUAGE_CYC,       -1,       -1, G_BUTTON          |0x1500,   /* Object 40 OPT_LANGUAGE_BUT */
  SELECTABLE|EXIT|FLAGS11, NORMAL, (LONG)" Language         ",
  0x0601, 0x0F01, 0x0012, 0x0001,
  OPT_AUTOTOP_BACK,       -1,       -1, G_BUTTON          |0x1600,   /* Object 41 OPT_LANGUAGE_CYC */
  SELECTABLE|EXIT|FLAGS11, NORMAL, (LONG)" ",
  0x0613, 0x0F01, 0x0701, 0x0001,
  OPT_AUTOTOP     , OPT_AUTOTOPSMART, OPT_AUTOTOPNORMA, G_BUTTON          |0x1400,   /* Object 42 OPT_AUTOTOP_BACK */
  NONE, NORMAL, (LONG)"\0",
  0x0504, 0x0406, 0x0508, 0x0D02,
  OPT_AUTOTOPNORMA,       -1,       -1, G_BUTTON          |0x1200,   /* Object 43 OPT_AUTOTOPSMART */
  SELECTABLE|RBUTTON, CROSSED, (LONG)"schlau",
  0x0001, 0x0B00, 0x0007, 0x0001,
  OPT_AUTOTOP_BACK,       -1,       -1, G_BUTTON          |0x1200,   /* Object 44 OPT_AUTOTOPNORMA */
  SELECTABLE|RBUTTON, SELECTED|CROSSED, (LONG)"normal",
  0x0001, 0x0C01, 0x0007, 0x0001,
  OPT_DOPPEL_TIME ,       -1,       -1, G_BUTTON          |0x1200,   /* Object 45 OPT_AUTOTOP */
  SELECTABLE, NORMAL, (LONG)"Autotop",
  0x0601, 0x0205, 0x0007, 0x0001,
  OPT_DOPPEL_BACK ,       -1,       -1, G_BUTTON          |0x1200,   /* Object 46 OPT_DOPPEL_TIME */
  SELECTABLE, NORMAL, (LONG)"Doppelklick auf die Uhr startet",
  0x0601, 0x0D09, 0x001F, 0x0001,
  OPT_BACK_BEDINUN, OPT_DOPPEL_TXT  , OPT_DOPPEL_TXT  , G_BUTTON          |0x1F00,   /* Object 47 OPT_DOPPEL_BACK */
  NONE, NORMAL, (LONG)"\0",
  0x0102, 0x040B, 0x001E, 0x0201,
  OPT_DOPPEL_BACK ,       -1,       -1, G_FTEXT           ,   /* Object 48 OPT_DOPPEL_TXT */
  SELECTABLE|EXIT, NORMAL, (LONG)&rs_tedinfo[9],
  0x0000, 0x0000, 0x001E, 0x0101,
  OPT_KAT_BUT     ,       50, OPT_TEX_HIDD_CYC, G_BUTTON          |0x1400,   /* Object 49 OPT_BACK_COLORS */
  HIDETREE, NORMAL, (LONG)"Farben",
  0x0601, 0x0A02, 0x0428, 0x0811,
        51,       -1,       -1, G_TEXT            ,   /* Object 50  */
  FLAGS10, NORMAL, (LONG)&rs_tedinfo[10],
  0x0201, 0x0004, 0x0208, 0x0B00,
        52,       -1,       -1, G_TEXT            ,   /* Object 51  */
  FLAGS10, NORMAL, (LONG)&rs_tedinfo[11],
  0x0301, 0x0805, 0x0106, 0x0E00,
        53,       -1,       -1, G_TEXT            ,   /* Object 52  */
  FLAGS10, NORMAL, (LONG)&rs_tedinfo[12],
  0x0301, 0x0107, 0x0404, 0x0F00,
  OPT_COL_APP_TXT ,       -1,       -1, G_TEXT            ,   /* Object 53  */
  FLAGS10, NORMAL, (LONG)&rs_tedinfo[13],
  0x0401, 0x0808, 0x0603, 0x0101,
  OPT_COL_ACC_TXT , OPT_COL_APP_COL , OPT_COL_APP_COL , G_BUTTON          |0x1500,   /* Object 54 OPT_COL_APP_TXT */
  SELECTABLE|EXIT|FLAGS11, NORMAL, (LONG)"  Language3      ",
  0x010A, 0x0E03, 0x0011, 0x0001,
  OPT_COL_APP_TXT ,       -1,       -1, G_BOX             ,   /* Object 55 OPT_COL_APP_COL */
  NONE, DRAW3D|WHITEBAK, (LONG)0x000111F0L,
  0x0000, 0x0000, 0x0001, 0x0001,
  OPT_COL_SYS_TXT , OPT_COL_ACC_COL , OPT_COL_ACC_COL , G_BUTTON          |0x1500,   /* Object 56 OPT_COL_ACC_TXT */
  SELECTABLE|EXIT, NORMAL, (LONG)"  Language4      ",
  0x010A, 0x0705, 0x0011, 0x0001,
  OPT_COL_ACC_TXT ,       -1,       -1, G_BOX             ,   /* Object 57 OPT_COL_ACC_COL */
  NONE, DRAW3D|WHITEBAK, (LONG)0x000111F0L,
  0x0000, 0x0000, 0x0001, 0x0001,
  OPT_COL_SHE_TXT , OPT_COL_SYS_COL , OPT_COL_SYS_COL , G_BUTTON          |0x1500,   /* Object 58 OPT_COL_SYS_TXT */
  SELECTABLE|EXIT, NORMAL, (LONG)"  Language5      ",
  0x010A, 0x0107, 0x0011, 0x0001,
  OPT_COL_SYS_TXT ,       -1,       -1, G_BOX             ,   /* Object 59 OPT_COL_SYS_COL */
  NONE, DRAW3D|WHITEBAK, (LONG)0x000111F0L,
  0x0000, 0x0000, 0x0001, 0x0001,
  OPT_COL_APP_CYC , OPT_COL_SHE_COL , OPT_COL_SHE_COL , G_BUTTON          |0x1500,   /* Object 60 OPT_COL_SHE_TXT */
  SELECTABLE|EXIT, NORMAL, (LONG)"  Language3      ",
  0x010A, 0x0908, 0x0011, 0x0001,
  OPT_COL_SHE_TXT ,       -1,       -1, G_BOX             ,   /* Object 61 OPT_COL_SHE_COL */
  NONE, DRAW3D|WHITEBAK, (LONG)0x000111F0L,
  0x0000, 0x0000, 0x0001, 0x0001,
  OPT_COL_ACC_CYC ,       -1,       -1, G_BUTTON          |0x1600,   /* Object 62 OPT_COL_APP_CYC */
  SELECTABLE|EXIT|FLAGS11, NORMAL, (LONG)" ",
  0x011B, 0x0E03, 0x0701, 0x0001,
  OPT_COL_SYS_CYC ,       -1,       -1, G_BUTTON          |0x1600,   /* Object 63 OPT_COL_ACC_CYC */
  SELECTABLE|EXIT|FLAGS11, NORMAL, (LONG)" ",
  0x011B, 0x0705, 0x0701, 0x0001,
  OPT_COL_SHE_CYC ,       -1,       -1, G_BUTTON          |0x1600,   /* Object 64 OPT_COL_SYS_CYC */
  SELECTABLE|EXIT|FLAGS11, NORMAL, (LONG)" ",
  0x011B, 0x0107, 0x0701, 0x0001,
        66,       -1,       -1, G_BUTTON          |0x1600,   /* Object 65 OPT_COL_SHE_CYC */
  SELECTABLE|EXIT|FLAGS11, NORMAL, (LONG)" ",
  0x011B, 0x0908, 0x0701, 0x0001,
  OPT_COL_CAPSONBU,       -1,       -1, G_TEXT            ,   /* Object 66  */
  FLAGS10, NORMAL, (LONG)&rs_tedinfo[14],
  0x0401, 0x070A, 0x0205, 0x0101,
  OPT_COL_CAPSONCY, OPT_COL_CAPSONCO, OPT_COL_CAPSONCO, G_BUTTON          |0x1500,   /* Object 67 OPT_COL_CAPSONBU */
  SELECTABLE|EXIT, NORMAL, (LONG)"  Language3      ",
  0x010A, 0x080A, 0x0011, 0x0001,
  OPT_COL_CAPSONBU,       -1,       -1, G_BOX             ,   /* Object 68 OPT_COL_CAPSONCO */
  NONE, DRAW3D|WHITEBAK, (LONG)0x000111F0L,
  0x0000, 0x0000, 0x0001, 0x0001,
        70,       -1,       -1, G_BUTTON          |0x1600,   /* Object 69 OPT_COL_CAPSONCY */
  SELECTABLE|EXIT|FLAGS11, NORMAL, (LONG)" ",
  0x011B, 0x080A, 0x0701, 0x0001,
  OPT_COL_CAPSOFBU,       -1,       -1, G_TEXT            ,   /* Object 70  */
  FLAGS10, NORMAL, (LONG)&rs_tedinfo[15],
  0x0401, 0x020C, 0x0006, 0x0101,
  OPT_COL_CAPSOFCY, OPT_COL_CAPSOFCO, OPT_COL_CAPSOFCO, G_BUTTON          |0x1500,   /* Object 71 OPT_COL_CAPSOFBU */
  SELECTABLE|EXIT, NORMAL, (LONG)"  Language3      ",
  0x010A, 0x030C, 0x0011, 0x0001,
  OPT_COL_CAPSOFBU,       -1,       -1, G_BOX             ,   /* Object 72 OPT_COL_CAPSOFCO */
  NONE, DRAW3D|WHITEBAK, (LONG)0x000111F0L,
  0x0000, 0x0000, 0x0001, 0x0001,
  OPT_TEX_APP_BACK,       -1,       -1, G_BUTTON          |0x1600,   /* Object 73 OPT_COL_CAPSOFCY */
  SELECTABLE|EXIT|FLAGS11, NORMAL, (LONG)" ",
  0x011B, 0x030C, 0x0701, 0x0001,
  OPT_TEX_APP_CYC , OPT_TEX_APP_COL , OPT_TEX_APP_COL , G_BUTTON          |0x1500,   /* Object 74 OPT_TEX_APP_BACK */
  SELECTABLE|EXIT, NORMAL, (LONG)"   ",
  0x071D, 0x0E03, 0x0006, 0x0001,
  OPT_TEX_APP_BACK,       -1,       -1, G_BOX             ,   /* Object 75 OPT_TEX_APP_COL */
  SELECTABLE|EXIT, DRAW3D|WHITEBAK, (LONG)0x000111F0L,
  0x0000, 0x0000, 0x0305, 0x0001,
  OPT_TEX_ACC_BACK,       -1,       -1, G_BUTTON          |0x1600,   /* Object 76 OPT_TEX_APP_CYC */
  SELECTABLE|EXIT|FLAGS11, NORMAL, (LONG)" ",
  0x0723, 0x0E03, 0x0701, 0x0001,
  OPT_TEX_ACC_CYC , OPT_TEX_ACC_COL , OPT_TEX_ACC_COL , G_BUTTON          |0x1500,   /* Object 77 OPT_TEX_ACC_BACK */
  SELECTABLE|EXIT, NORMAL, (LONG)"   ",
  0x071D, 0x0705, 0x0006, 0x0001,
  OPT_TEX_ACC_BACK,       -1,       -1, G_BOX             ,   /* Object 78 OPT_TEX_ACC_COL */
  SELECTABLE|EXIT, DRAW3D|WHITEBAK, (LONG)0x000111F0L,
  0x0000, 0x0000, 0x0305, 0x0001,
  OPT_TEX_SYS_BACK,       -1,       -1, G_BUTTON          |0x1600,   /* Object 79 OPT_TEX_ACC_CYC */
  SELECTABLE|EXIT|FLAGS11, NORMAL, (LONG)" ",
  0x0723, 0x0705, 0x0701, 0x0001,
  OPT_TEX_SYS_CYC , OPT_TEX_SYS_COL , OPT_TEX_SYS_COL , G_BUTTON          |0x1500,   /* Object 80 OPT_TEX_SYS_BACK */
  SELECTABLE|EXIT, NORMAL, (LONG)"   ",
  0x071D, 0x0107, 0x0006, 0x0001,
  OPT_TEX_SYS_BACK,       -1,       -1, G_BOX             ,   /* Object 81 OPT_TEX_SYS_COL */
  SELECTABLE|EXIT, DRAW3D|WHITEBAK, (LONG)0x000111F0L,
  0x0000, 0x0000, 0x0305, 0x0001,
  OPT_TEX_SHE_BACK,       -1,       -1, G_BUTTON          |0x1600,   /* Object 82 OPT_TEX_SYS_CYC */
  SELECTABLE|EXIT|FLAGS11, NORMAL, (LONG)" ",
  0x0723, 0x0107, 0x0701, 0x0001,
  OPT_TEX_SHE_CYC , OPT_TEX_SHE_COL , OPT_TEX_SHE_COL , G_BUTTON          |0x1500,   /* Object 83 OPT_TEX_SHE_BACK */
  SELECTABLE|EXIT, NORMAL, (LONG)"   ",
  0x071D, 0x0A08, 0x0006, 0x0001,
  OPT_TEX_SHE_BACK,       -1,       -1, G_BOX             ,   /* Object 84 OPT_TEX_SHE_COL */
  SELECTABLE|EXIT, DRAW3D|WHITEBAK, (LONG)0x000111F0L,
  0x0000, 0x0000, 0x0305, 0x0001,
  OPT_TEX_CON_BACK,       -1,       -1, G_BUTTON          |0x1600,   /* Object 85 OPT_TEX_SHE_CYC */
  SELECTABLE|EXIT|FLAGS11, NORMAL, (LONG)" ",
  0x0723, 0x0A08, 0x0701, 0x0001,
  OPT_TEX_CON_CYC , OPT_TEX_CON_COL , OPT_TEX_CON_COL , G_BUTTON          |0x1500,   /* Object 86 OPT_TEX_CON_BACK */
  SELECTABLE|EXIT, NORMAL, (LONG)"   ",
  0x071D, 0x090A, 0x0006, 0x0001,
  OPT_TEX_CON_BACK,       -1,       -1, G_BOX             ,   /* Object 87 OPT_TEX_CON_COL */
  SELECTABLE|EXIT, DRAW3D|WHITEBAK, (LONG)0x000111F0L,
  0x0000, 0x0000, 0x0305, 0x0001,
  OPT_TEX_COFF_BAC,       -1,       -1, G_BUTTON          |0x1600,   /* Object 88 OPT_TEX_CON_CYC */
  SELECTABLE|EXIT|FLAGS11, NORMAL, (LONG)" ",
  0x0723, 0x090A, 0x0701, 0x0001,
  OPT_TEX_COFF_CYC, OPT_TEX_COFF_COL, OPT_TEX_COFF_COL, G_BUTTON          |0x1500,   /* Object 89 OPT_TEX_COFF_BAC */
  SELECTABLE|EXIT, NORMAL, (LONG)"   ",
  0x071D, 0x020C, 0x0006, 0x0001,
  OPT_TEX_COFF_BAC,       -1,       -1, G_BOX             ,   /* Object 90 OPT_TEX_COFF_COL */
  SELECTABLE|EXIT, DRAW3D|WHITEBAK, (LONG)0x000111F0L,
  0x0000, 0x0000, 0x0305, 0x0001,
  OPT_COL_BACK    ,       -1,       -1, G_BUTTON          |0x1600,   /* Object 91 OPT_TEX_COFF_CYC */
  SELECTABLE|EXIT|FLAGS11, NORMAL, (LONG)" ",
  0x0723, 0x020C, 0x0701, 0x0001,
  OPT_COL_TEXT    ,       -1,       -1, G_BUTTON          |0x1200,   /* Object 92 OPT_COL_BACK */
  SELECTABLE|RBUTTON, CROSSED, (LONG)"Hintergrund",
  0x010A, 0x0602, 0x000B, 0x0001,
        94,       -1,       -1, G_BUTTON          |0x1200,   /* Object 93 OPT_COL_TEXT */
  SELECTABLE|RBUTTON, SELECTED|CROSSED, (LONG)"Text",
  0x010A, 0x0501, 0x0007, 0x0001,
  OPT_COL_FREEZYBU,       -1,       -1, G_TEXT            ,   /* Object 94  */
  FLAGS10, NORMAL, (LONG)&rs_tedinfo[16],
  0x0401, 0x0E0D, 0x0407, 0x0101,
  OPT_COL_FREEZYCY, OPT_COL_FREEZYCO, OPT_COL_FREEZYCO, G_BUTTON          |0x1500,   /* Object 95 OPT_COL_FREEZYBU */
  SELECTABLE|EXIT, NORMAL, (LONG)"  Language3      ",
  0x010A, 0x0F0D, 0x0011, 0x0001,
  OPT_COL_FREEZYBU,       -1,       -1, G_BOX             ,   /* Object 96 OPT_COL_FREEZYCO */
  NONE, DRAW3D|WHITEBAK, (LONG)0x000111F0L,
  0x0000, 0x0000, 0x0001, 0x0001,
  OPT_TEX_FREE_BAC,       -1,       -1, G_BUTTON          |0x1600,   /* Object 97 OPT_COL_FREEZYCY */
  SELECTABLE|EXIT|FLAGS11, NORMAL, (LONG)" ",
  0x011B, 0x0F0D, 0x0701, 0x0001,
  OPT_TEX_FREE_CYC, OPT_TEX_FREE_COL, OPT_TEX_FREE_COL, G_BUTTON          |0x1500,   /* Object 98 OPT_TEX_FREE_BAC */
  SELECTABLE|EXIT, NORMAL, (LONG)"   ",
  0x071D, 0x0F0D, 0x0006, 0x0001,
  OPT_TEX_FREE_BAC,       -1,       -1, G_BOX             ,   /* Object 99 OPT_TEX_FREE_COL */
  SELECTABLE|EXIT, DRAW3D|WHITEBAK, (LONG)0x000111F0L,
  0x0000, 0x0000, 0x0305, 0x0001,
       101,       -1,       -1, G_BUTTON          |0x1600,   /* Object 100 OPT_TEX_FREE_CYC */
  SELECTABLE|EXIT|FLAGS11, NORMAL, (LONG)" ",
  0x0723, 0x0F0D, 0x0701, 0x0001,
  OPT_COL_HIDDENBU,       -1,       -1, G_TEXT            ,   /* Object 101  */
  FLAGS10, NORMAL, (LONG)&rs_tedinfo[17],
  0x0401, 0x060F, 0x0407, 0x0101,
  OPT_COL_HIDDENCY, OPT_COL_HIDDENCO, OPT_COL_HIDDENCO, G_BUTTON          |0x1500,   /* Object 102 OPT_COL_HIDDENBU */
  SELECTABLE|EXIT, NORMAL, (LONG)"  Language3      ",
  0x010A, 0x070F, 0x0011, 0x0001,
  OPT_COL_HIDDENBU,       -1,       -1, G_BOX             ,   /* Object 103 OPT_COL_HIDDENCO */
  NONE, DRAW3D|WHITEBAK, (LONG)0x000111F0L,
  0x0000, 0x0000, 0x0001, 0x0001,
  OPT_TEX_HIDD_BAC,       -1,       -1, G_BUTTON          |0x1600,   /* Object 104 OPT_COL_HIDDENCY */
  SELECTABLE|EXIT|FLAGS11, NORMAL, (LONG)" ",
  0x011B, 0x070F, 0x0701, 0x0001,
  OPT_TEX_HIDD_CYC, OPT_TEX_HIDD_COL, OPT_TEX_HIDD_COL, G_BUTTON          |0x1500,   /* Object 105 OPT_TEX_HIDD_BAC */
  SELECTABLE|EXIT, NORMAL, (LONG)"   ",
  0x071D, 0x070F, 0x0006, 0x0001,
  OPT_TEX_HIDD_BAC,       -1,       -1, G_BOX             ,   /* Object 106 OPT_TEX_HIDD_COL */
  SELECTABLE|EXIT, DRAW3D|WHITEBAK, (LONG)0x000111F0L,
  0x0000, 0x0000, 0x0305, 0x0001,
  OPT_BACK_COLORS ,       -1,       -1, G_BUTTON          |0x1600,   /* Object 107 OPT_TEX_HIDD_CYC */
  SELECTABLE|EXIT|FLAGS11, NORMAL, (LONG)" ",
  0x0723, 0x070F, 0x0701, 0x0001,
  OPT_KAT_CYC     ,       -1,       -1, G_BUTTON          |0x1500,   /* Object 108 OPT_KAT_BUT */
  SELECTABLE|EXIT|FLAGS11, NORMAL, (LONG)" Farben         ",
  0x0701, 0x0800, 0x0010, 0x0001,
  OPT_SETZE       ,       -1,       -1, G_BUTTON          |0x1600,   /* Object 109 OPT_KAT_CYC */
  SELECTABLE|EXIT|FLAGS11, NORMAL, (LONG)" ",
  0x0711, 0x0800, 0x0701, 0x0001,
  OPT_BACK_DONOTSH,       -1,       -1, G_BUTTON          ,   /* Object 110 OPT_SETZE */
  SELECTABLE|EXIT|FLAGS9, DRAW3D, (LONG)"Setze",
  0x072B, 0x0213, 0x0008, 0x0001,
  OPT_BACK_MAUS   , OPT_APP_BACK_1  , OPT_APP_BACK_2  , G_BUTTON          |0x1400,   /* Object 111 OPT_BACK_DONOTSH */
  HIDETREE, NORMAL, (LONG)" Applikationen ",
  0x0601, 0x0A02, 0x0428, 0x0811,
  OPT_NOTSHOW_UP  , OPT_NOTSHOW_TXT1, OPT_NOTSHOW_TXT8, G_BUTTON          |0x1700,   /* Object 112 OPT_APP_BACK_1 */
  NONE, NORMAL, (LONG)"\0",
  0x0003, 0x0004, 0x040A, 0x0008,
  OPT_NOTSHOW_TXT2,       -1,       -1, G_BUTTON          |0x1700,   /* Object 113 OPT_NOTSHOW_TXT1 */
  SELECTABLE|EXIT|RBUTTON, NORMAL, (LONG)"Ligne 0000",
  0x0000, 0x0000, 0x000A, 0x0001,
  OPT_NOTSHOW_TXT3,       -1,       -1, G_BUTTON          |0x1700,   /* Object 114 OPT_NOTSHOW_TXT2 */
  SELECTABLE|EXIT|RBUTTON, NORMAL, (LONG)"Ligne 0000",
  0x0000, 0x0001, 0x000A, 0x0001,
  OPT_NOTSHOW_TXT4,       -1,       -1, G_BUTTON          |0x1700,   /* Object 115 OPT_NOTSHOW_TXT3 */
  SELECTABLE|EXIT|RBUTTON, NORMAL, (LONG)"Ligne 0000",
  0x0000, 0x0002, 0x000A, 0x0001,
  OPT_NOTSHOW_TXT5,       -1,       -1, G_BUTTON          |0x1700,   /* Object 116 OPT_NOTSHOW_TXT4 */
  SELECTABLE|EXIT|RBUTTON, NORMAL, (LONG)"Ligne 0000",
  0x0000, 0x0003, 0x000A, 0x0001,
  OPT_NOTSHOW_TXT6,       -1,       -1, G_BUTTON          |0x1700,   /* Object 117 OPT_NOTSHOW_TXT5 */
  SELECTABLE|EXIT|RBUTTON, NORMAL, (LONG)"Ligne 0000",
  0x0000, 0x0004, 0x000A, 0x0001,
  OPT_NOTSHOW_TXT7,       -1,       -1, G_BUTTON          |0x1700,   /* Object 118 OPT_NOTSHOW_TXT6 */
  SELECTABLE|EXIT|RBUTTON, NORMAL, (LONG)"Ligne 0000",
  0x0000, 0x0005, 0x000A, 0x0001,
  OPT_NOTSHOW_TXT8,       -1,       -1, G_BUTTON          |0x1700,   /* Object 119 OPT_NOTSHOW_TXT7 */
  SELECTABLE|EXIT|RBUTTON, NORMAL, (LONG)"Ligne 0000",
  0x0000, 0x0006, 0x000A, 0x0001,
  OPT_APP_BACK_1  ,       -1,       -1, G_BUTTON          |0x1700,   /* Object 120 OPT_NOTSHOW_TXT8 */
  SELECTABLE|EXIT|RBUTTON, NORMAL, (LONG)"Ligne 0000",
  0x0000, 0x0007, 0x000A, 0x0001,
  OPT_NOTSHOW_BAR ,       -1,       -1, G_BUTTON          |0x1700,   /* Object 121 OPT_NOTSHOW_UP */
  TOUCHEXIT, NORMAL, (LONG)"\001",
  0x0218, 0x0004, 0x0002, 0x0001,
  OPT_NOTSHOW_DOWN, OPT_NOTSHOW_SLID, OPT_NOTSHOW_SLID, G_BUTTON          |0x1700,   /* Object 122 OPT_NOTSHOW_BAR */
  TOUCHEXIT, SELECTED, (LONG)" ",
  0x0218, 0x0005, 0x0002, 0x0006,
  OPT_NOTSHOW_BAR ,       -1,       -1, G_BUTTON          |0x1700,   /* Object 123 OPT_NOTSHOW_SLID */
  TOUCHEXIT, NORMAL, (LONG)"\0",
  0x0000, 0x0001, 0x0002, 0x0001,
  OPT_KAT_APP_BUT ,       -1,       -1, G_BUTTON          |0x1700,   /* Object 124 OPT_NOTSHOW_DOWN */
  TOUCHEXIT, NORMAL, (LONG)"\002",
  0x0218, 0x000B, 0x0002, 0x0001,
  OPT_KAT_APP_CYC ,       -1,       -1, G_BUTTON          |0x1500,   /* Object 125 OPT_KAT_APP_BUT */
  SELECTABLE|EXIT|FLAGS11, NORMAL, (LONG)" Versteckte   ",
  0x0003, 0x0B01, 0x000E, 0x0001,
  OPT_VER_DELETE  ,       -1,       -1, G_BUTTON          |0x1600,   /* Object 126 OPT_KAT_APP_CYC */
  SELECTABLE|EXIT|FLAGS11, NORMAL, (LONG)" ",
  0x0111, 0x0B01, 0x0701, 0x0001,
  OPT_VER_ADD     ,       -1,       -1, G_BUTTON          ,   /* Object 127 OPT_VER_DELETE */
  SELECTABLE|EXIT|FLAGS9, DRAW3D, (LONG)" L\224sche alles ",
  0x0003, 0x0C0C, 0x000E, 0x0001,
  OPT_VER_SORT    ,       -1,       -1, G_BUTTON          ,   /* Object 128 OPT_VER_ADD */
  SELECTABLE|EXIT|FLAGS9, DRAW3D, (LONG)" Hinzuf\201gen ",
  0x0003, 0x040E, 0x000E, 0x0001,
  OPT_APP_BACK_2  ,       -1,       -1, G_BUTTON          ,   /* Object 129 OPT_VER_SORT */
  SELECTABLE|EXIT|FLAGS9, DRAW3D, (LONG)" Sortieren ",
  0x0003, 0x0B0F, 0x000E, 0x0001,
  OPT_BACK_DONOTSH, OPT_NOTSHOW_ALI1, OPT_NOTSHOW_ALI8, G_BUTTON          |0x1700,   /* Object 130 OPT_APP_BACK_2 */
  NONE, NORMAL, (LONG)"\0",
  0x050D, 0x0004, 0x040A, 0x0008,
  OPT_NOTSHOW_ALI2,       -1,       -1, G_BUTTON          |0x1700,   /* Object 131 OPT_NOTSHOW_ALI1 */
  SELECTABLE|EXIT|RBUTTON, NORMAL, (LONG)"Ligne 0000",
  0x0000, 0x0000, 0x000A, 0x0001,
  OPT_NOTSHOW_ALI3,       -1,       -1, G_BUTTON          |0x1700,   /* Object 132 OPT_NOTSHOW_ALI2 */
  SELECTABLE|EXIT|RBUTTON, NORMAL, (LONG)"Ligne 0000",
  0x0000, 0x0001, 0x000A, 0x0001,
  OPT_NOTSHOW_ALI4,       -1,       -1, G_BUTTON          |0x1700,   /* Object 133 OPT_NOTSHOW_ALI3 */
  SELECTABLE|EXIT|RBUTTON, NORMAL, (LONG)"Ligne 0000",
  0x0000, 0x0002, 0x000A, 0x0001,
  OPT_NOTSHOW_ALI5,       -1,       -1, G_BUTTON          |0x1700,   /* Object 134 OPT_NOTSHOW_ALI4 */
  SELECTABLE|EXIT|RBUTTON, NORMAL, (LONG)"Ligne 0000",
  0x0000, 0x0003, 0x000A, 0x0001,
  OPT_NOTSHOW_ALI6,       -1,       -1, G_BUTTON          |0x1700,   /* Object 135 OPT_NOTSHOW_ALI5 */
  SELECTABLE|EXIT|RBUTTON, NORMAL, (LONG)"Ligne 0000",
  0x0000, 0x0004, 0x000A, 0x0001,
  OPT_NOTSHOW_ALI7,       -1,       -1, G_BUTTON          |0x1700,   /* Object 136 OPT_NOTSHOW_ALI6 */
  SELECTABLE|EXIT|RBUTTON, NORMAL, (LONG)"Ligne 0000",
  0x0000, 0x0005, 0x000A, 0x0001,
  OPT_NOTSHOW_ALI8,       -1,       -1, G_BUTTON          |0x1700,   /* Object 137 OPT_NOTSHOW_ALI7 */
  SELECTABLE|EXIT|RBUTTON, NORMAL, (LONG)"Ligne 0000",
  0x0000, 0x0006, 0x000A, 0x0001,
  OPT_APP_BACK_2  ,       -1,       -1, G_BUTTON          |0x1700,   /* Object 138 OPT_NOTSHOW_ALI8 */
  SELECTABLE|EXIT|RBUTTON, NORMAL, (LONG)"Ligne 0000",
  0x0000, 0x0007, 0x000A, 0x0001,
  OPT_BACK_KONTEXT,      140, OPT_DOPPELKLICK , G_BUTTON          |0x1400,   /* Object 139 OPT_BACK_MAUS */
  HIDETREE, NORMAL, (LONG)" Mausklicks ",
  0x0601, 0x0A02, 0x0428, 0x0811,
       141,       -1,       -1, G_TEXT            ,   /* Object 140  */
  FLAGS10, NORMAL, (LONG)&rs_tedinfo[18],
  0x0002, 0x0603, 0x000E, 0x0001,
  OPT_E_R_B       ,       -1,       -1, G_TEXT            ,   /* Object 141  */
  FLAGS10, NORMAL, (LONG)&rs_tedinfo[19],
  0x0002, 0x0205, 0x000D, 0x0001,
  OPT_E_R_C       ,       -1,       -1, G_BUTTON          |0x1500,   /* Object 142 OPT_E_R_B */
  SELECTABLE|EXIT|FLAGS11, NORMAL, (LONG)" Kontextmenu1      ",
  0x0311, 0x0603, 0x0013, 0x0001,
  OPT_E_L_B       ,       -1,       -1, G_BUTTON          |0x1600,   /* Object 143 OPT_E_R_C */
  SELECTABLE|EXIT|FLAGS11, NORMAL, (LONG)" ",
  0x0324, 0x0603, 0x0701, 0x0001,
  OPT_E_L_C       ,       -1,       -1, G_BUTTON          |0x1500,   /* Object 144 OPT_E_L_B */
  SELECTABLE|EXIT|FLAGS11, NORMAL, (LONG)" Kontextmenu2      ",
  0x0311, 0x0005, 0x0013, 0x0001,
       146,       -1,       -1, G_BUTTON          |0x1600,   /* Object 145 OPT_E_L_C */
  SELECTABLE|EXIT|FLAGS11, NORMAL, (LONG)" ",
  0x0324, 0x0005, 0x0701, 0x0001,
       147,       -1,       -1, G_TEXT            ,   /* Object 146  */
  FLAGS10, NORMAL, (LONG)&rs_tedinfo[20],
  0x0002, 0x0F06, 0x000B, 0x0001,
       148,       -1,       -1, G_TEXT            ,   /* Object 147  */
  FLAGS10, NORMAL, (LONG)&rs_tedinfo[21],
  0x0002, 0x0B08, 0x000A, 0x0001,
       149,       -1,       -1, G_TEXT            ,   /* Object 148  */
  FLAGS10, NORMAL, (LONG)&rs_tedinfo[22],
  0x0002, 0x0B0A, 0x000C, 0x0001,
       150,       -1,       -1, G_TEXT            ,   /* Object 149  */
  FLAGS10, NORMAL, (LONG)&rs_tedinfo[23],
  0x0002, 0x070C, 0x000B, 0x0001,
       151,       -1,       -1, G_TEXT            ,   /* Object 150  */
  FLAGS10, NORMAL, (LONG)&rs_tedinfo[24],
  0x0002, 0x010E, 0x000D, 0x0001,
  OPT_A_R_B       ,       -1,       -1, G_TEXT            ,   /* Object 151  */
  FLAGS10, NORMAL, (LONG)&rs_tedinfo[25],
  0x0002, 0x0D0F, 0x000C, 0x0001,
  OPT_A_R_C       ,       -1,       -1, G_BUTTON          |0x1500,   /* Object 152 OPT_A_R_B */
  SELECTABLE|EXIT|FLAGS11, NORMAL, (LONG)" Kontextmenu1      ",
  0x0311, 0x0F06, 0x0013, 0x0001,
  OPT_A_L_B       ,       -1,       -1, G_BUTTON          |0x1600,   /* Object 153 OPT_A_R_C */
  SELECTABLE|EXIT|FLAGS11, NORMAL, (LONG)" ",
  0x0324, 0x0F06, 0x0701, 0x0001,
  OPT_A_L_C       ,       -1,       -1, G_BUTTON          |0x1500,   /* Object 154 OPT_A_L_B */
  SELECTABLE|EXIT|FLAGS11, NORMAL, (LONG)" Kontextmenu2      ",
  0x0311, 0x0908, 0x0013, 0x0001,
  OPT_C_R_B       ,       -1,       -1, G_BUTTON          |0x1600,   /* Object 155 OPT_A_L_C */
  SELECTABLE|EXIT|FLAGS11, NORMAL, (LONG)" ",
  0x0324, 0x0908, 0x0701, 0x0001,
  OPT_C_R_C       ,       -1,       -1, G_BUTTON          |0x1500,   /* Object 156 OPT_C_R_B */
  SELECTABLE|EXIT|FLAGS11, NORMAL, (LONG)" Kontextmenu1      ",
  0x0311, 0x0A0A, 0x0013, 0x0001,
  OPT_C_L_B       ,       -1,       -1, G_BUTTON          |0x1600,   /* Object 157 OPT_C_R_C */
  SELECTABLE|EXIT|FLAGS11, NORMAL, (LONG)" ",
  0x0324, 0x0A0A, 0x0701, 0x0001,
  OPT_C_L_C       ,       -1,       -1, G_BUTTON          |0x1500,   /* Object 158 OPT_C_L_B */
  SELECTABLE|EXIT|FLAGS11, NORMAL, (LONG)" Kontextmenu2      ",
  0x0311, 0x040C, 0x0013, 0x0001,
  OPT_S_R_B       ,       -1,       -1, G_BUTTON          |0x1600,   /* Object 159 OPT_C_L_C */
  SELECTABLE|EXIT|FLAGS11, NORMAL, (LONG)" ",
  0x0324, 0x040C, 0x0701, 0x0001,
  OPT_S_R_C       ,       -1,       -1, G_BUTTON          |0x1500,   /* Object 160 OPT_S_R_B */
  SELECTABLE|EXIT|FLAGS11, NORMAL, (LONG)" Kontextmenu1      ",
  0x0311, 0x030E, 0x0013, 0x0001,
  OPT_S_L_B       ,       -1,       -1, G_BUTTON          |0x1600,   /* Object 161 OPT_S_R_C */
  SELECTABLE|EXIT|FLAGS11, NORMAL, (LONG)" ",
  0x0324, 0x030E, 0x0701, 0x0001,
  OPT_S_L_C       ,       -1,       -1, G_BUTTON          |0x1500,   /* Object 162 OPT_S_L_B */
  SELECTABLE|EXIT|FLAGS11, NORMAL, (LONG)" Kontextmenu2      ",
  0x0311, 0x0D0F, 0x0013, 0x0001,
  OPT_KLICK       ,       -1,       -1, G_BUTTON          |0x1600,   /* Object 163 OPT_S_L_C */
  SELECTABLE|EXIT|FLAGS11, NORMAL, (LONG)" ",
  0x0324, 0x0D0F, 0x0701, 0x0001,
  OPT_DOPPELKLICK ,       -1,       -1, G_BUTTON          |0x1200,   /* Object 164 OPT_KLICK */
  SELECTABLE|RBUTTON, SELECTED|CROSSED, (LONG)"Einfaches Klick",
  0x0111, 0x0101, 0x000F, 0x0001,
  OPT_BACK_MAUS   ,       -1,       -1, G_BUTTON          |0x1200,   /* Object 165 OPT_DOPPELKLICK */
  SELECTABLE|RBUTTON, CROSSED, (LONG)"Doppelklick",
  0x0111, 0x0202, 0x000B, 0x0001,
  OPT_BACK_SKINS  , OPT_KONT_BACK   , OPT_KONT_BACK   , G_BUTTON          |0x1400,   /* Object 166 OPT_BACK_KONTEXT */
  HIDETREE, NORMAL, (LONG)" Kontextmenue ",
  0x0601, 0x0A02, 0x0428, 0x0811,
  OPT_BACK_KONTEXT, OPT_KONT_LAST   , OPT_KONT_L1     , G_BUTTON          |0x1700,   /* Object 167 OPT_KONT_BACK */
  NONE, NORMAL, (LONG)"\0",
  0x0303, 0x0301, 0x011D, 0x0010,
       169,       -1,       -1, G_BUTTON          |0x1700,   /* Object 168 OPT_KONT_LAST */
  SELECTABLE|EXIT|RBUTTON, NORMAL, (LONG)"0123456789012345678901234567",
  0x0100, 0x000F, 0x001C, 0x0001,
       170,       -1,       -1, G_BUTTON          |0x1700,   /* Object 169  */
  SELECTABLE|EXIT|RBUTTON, NORMAL, (LONG)"01234567890123456789012345678",
  0x0100, 0x000E, 0x001D, 0x0001,
       171,       -1,       -1, G_BUTTON          |0x1700,   /* Object 170  */
  SELECTABLE|EXIT|RBUTTON, NORMAL, (LONG)"01234567890123456789012345678",
  0x0100, 0x000D, 0x001D, 0x0001,
       172,       -1,       -1, G_BUTTON          |0x1700,   /* Object 171  */
  SELECTABLE|EXIT|RBUTTON, NORMAL, (LONG)"01234567890123456789012345678",
  0x0100, 0x000C, 0x001D, 0x0001,
       173,       -1,       -1, G_BUTTON          |0x1700,   /* Object 172  */
  SELECTABLE|EXIT|RBUTTON, NORMAL, (LONG)"01234567890123456789012345678",
  0x0100, 0x000B, 0x001D, 0x0001,
       174,       -1,       -1, G_BUTTON          |0x1700,   /* Object 173  */
  SELECTABLE|EXIT|RBUTTON, NORMAL, (LONG)"01234567890123456789012345678",
  0x0100, 0x000A, 0x001D, 0x0001,
       175,       -1,       -1, G_BUTTON          |0x1700,   /* Object 174  */
  SELECTABLE|EXIT|RBUTTON, NORMAL, (LONG)"01234567890123456789012345678",
  0x0100, 0x0009, 0x001D, 0x0001,
       176,       -1,       -1, G_BUTTON          |0x1700,   /* Object 175  */
  SELECTABLE|EXIT|RBUTTON, NORMAL, (LONG)"01234567890123456789012345678",
  0x0100, 0x0008, 0x001D, 0x0001,
       177,       -1,       -1, G_BUTTON          |0x1700,   /* Object 176  */
  SELECTABLE|EXIT|RBUTTON, NORMAL, (LONG)"01234567890123456789012345678",
  0x0100, 0x0007, 0x001D, 0x0001,
       178,       -1,       -1, G_BUTTON          |0x1700,   /* Object 177  */
  SELECTABLE|EXIT|RBUTTON, NORMAL, (LONG)"01234567890123456789012345678",
  0x0100, 0x0006, 0x001D, 0x0001,
       179,       -1,       -1, G_BUTTON          |0x1700,   /* Object 178  */
  SELECTABLE|EXIT|RBUTTON, NORMAL, (LONG)"01234567890123456789012345678",
  0x0100, 0x0005, 0x001D, 0x0001,
       180,       -1,       -1, G_BUTTON          |0x1700,   /* Object 179  */
  SELECTABLE|EXIT|RBUTTON, NORMAL, (LONG)"01234567890123456789012345678",
  0x0100, 0x0004, 0x001D, 0x0001,
       181,       -1,       -1, G_BUTTON          |0x1700,   /* Object 180  */
  SELECTABLE|EXIT|RBUTTON, NORMAL, (LONG)"01234567890123456789012345678",
  0x0100, 0x0003, 0x001D, 0x0001,
       182,       -1,       -1, G_BUTTON          |0x1700,   /* Object 181  */
  SELECTABLE|EXIT|RBUTTON, NORMAL, (LONG)"01234567890123456789012345678",
  0x0100, 0x0002, 0x001D, 0x0001,
  OPT_KONT_L1     ,       -1,       -1, G_BUTTON          |0x1700,   /* Object 182  */
  SELECTABLE|EXIT|RBUTTON, NORMAL, (LONG)"01234567890123456789012345678",
  0x0100, 0x0001, 0x001D, 0x0001,
  OPT_KONT_BACK   ,       -1,       -1, G_BUTTON          |0x1700,   /* Object 183 OPT_KONT_L1 */
  SELECTABLE|EXIT|RBUTTON, NORMAL, (LONG)"01234567890123456789012345678",
  0x0100, 0x0000, 0x001D, 0x0001,
         0, OPT_BACK_RSC    ,      193, G_BUTTON          |0x1400,   /* Object 184 OPT_BACK_SKINS */
  NONE, NORMAL, (LONG)" Skins ",
  0x0601, 0x0A02, 0x0428, 0x0811,
  OPT_EXT_RSC_BUTT, OPT_EXT_RSC     , OPT_EXT_RSC     , G_BUTTON          |0x1F00,   /* Object 185 OPT_BACK_RSC */
  NONE, NORMAL, (LONG)"\0",
  0x0502, 0x0203, 0x001E, 0x0101,
  OPT_BACK_RSC    ,       -1,       -1, G_FTEXT           ,   /* Object 186 OPT_EXT_RSC */
  SELECTABLE|EXIT, NORMAL, (LONG)&rs_tedinfo[26],
  0x0000, 0x0000, 0x001E, 0x0101,
       188,       -1,       -1, G_BUTTON          |0x1200,   /* Object 187 OPT_EXT_RSC_BUTT */
  SELECTABLE, NORMAL, (LONG)"Externe RSC-Datei",
  0x0402, 0x0B01, 0x0011, 0x0001,
       193,      189, OPT_ICONTEXT_ST , G_BUTTON          |0x1400,   /* Object 188  */
  NONE, NORMAL, (LONG)"START Button",
  0x0602, 0x0505, 0x0715, 0x0403,
  OPT_BACK_RSC_NR ,       -1,       -1, G_STRING          ,   /* Object 189  */
  SELECTABLE, NORMAL, (LONG)"Nr.:",
  0x0300, 0x0601, 0x0004, 0x0001,
  OPT_ICONTEXT_ST , OPT_EXT_RSC_NR  , OPT_EXT_RSC_NR  , G_BUTTON          |0x1F00,   /* Object 190 OPT_BACK_RSC_NR */
  NONE, NORMAL, (LONG)"\0",
  0x0704, 0x0401, 0x0603, 0x0101,
  OPT_BACK_RSC_NR ,       -1,       -1, G_FTEXT           ,   /* Object 191 OPT_EXT_RSC_NR */
  SELECTABLE|EXIT, NORMAL, (LONG)&rs_tedinfo[27],
  0x0000, 0x0000, 0x0002, 0x0001,
       188,       -1,       -1, G_BUTTON          |0x1200,   /* Object 192 OPT_ICONTEXT_ST */
  SELECTABLE, NORMAL, (LONG)"Ikontext",
  0x020B, 0x0401, 0x0008, 0x0001,
  OPT_BACK_SKINS  ,      194, OPT_ICONTEXT_APP, G_BUTTON          |0x1400,   /* Object 193  */
  NONE, NORMAL, (LONG)"App Button",
  0x0602, 0x0609, 0x0715, 0x0403,
  OPT_BACK_RSC_NRA,       -1,       -1, G_STRING          ,   /* Object 194  */
  SELECTABLE, NORMAL, (LONG)"Nr.:",
  0x0300, 0x0701, 0x0004, 0x0001,
  OPT_ICONTEXT_APP, OPT_EXT_RSC_NRAP, OPT_EXT_RSC_NRAP, G_BUTTON          |0x1F00,   /* Object 195 OPT_BACK_RSC_NRA */
  NONE, NORMAL, (LONG)"\0",
  0x0704, 0x0501, 0x0603, 0x0101,
  OPT_BACK_RSC_NRA,       -1,       -1, G_FTEXT           ,   /* Object 196 OPT_EXT_RSC_NRAP */
  SELECTABLE|EXIT, NORMAL, (LONG)&rs_tedinfo[28],
  0x0000, 0x0000, 0x0002, 0x0001,
       193,       -1,       -1, G_BUTTON          |0x1200,   /* Object 197 OPT_ICONTEXT_APP */
  SELECTABLE|LASTOB, NORMAL, (LONG)"Ikontext",
  0x000B, 0x0501, 0x0008, 0x0001,
  
  /******** Tree 1 G_POPUP_KAT ****************************************************/
        -1,        1,        8, G_BUTTON          |0x1700,   /* Object 0  */
  NONE, SHADOWED, (LONG)"\0",
  0x0000, 0x0000, 0x0010, 0x0108,
         2,       -1,       -1, G_STRING          ,   /* Object 1  */
  SELECTABLE|EXIT, NORMAL, (LONG)" Allgemein     ",
  0x0001, 0x0000, 0x000F, 0x0001,
         3,       -1,       -1, G_STRING          ,   /* Object 2  */
  SELECTABLE|EXIT, NORMAL, (LONG)" Bedienung     ",
  0x0001, 0x0001, 0x000F, 0x0001,
         4,       -1,       -1, G_STRING          ,   /* Object 3  */
  SELECTABLE|EXIT, NORMAL, (LONG)" Mausklicks    ",
  0x0001, 0x0002, 0x000F, 0x0001,
         5,       -1,       -1, G_STRING          ,   /* Object 4  */
  SELECTABLE|EXIT, NORMAL, (LONG)" Farben        ",
  0x0001, 0x0003, 0x000F, 0x0001,
         6,       -1,       -1, G_STRING          ,   /* Object 5  */
  SELECTABLE|EXIT, NORMAL, (LONG)" StIc          ",
  0x0001, 0x0004, 0x000F, 0x0001,
         7,       -1,       -1, G_STRING          ,   /* Object 6  */
  SELECTABLE|EXIT, NORMAL, (LONG)" Applikationen ",
  0x0001, 0x0E04, 0x000F, 0x0001,
         8,       -1,       -1, G_STRING          ,   /* Object 7  */
  SELECTABLE|EXIT, NORMAL, (LONG)" Kontextmenue ",
  0x0001, 0x0E05, 0x000E, 0x0001,
         0,       -1,       -1, G_STRING          ,   /* Object 8  */
  SELECTABLE|EXIT|LASTOB, NORMAL, (LONG)" Skins        ",
  0x0001, 0x0E06, 0x000E, 0x0001,
  
  /******** Tree 2 G_POPUP_MOUSE ****************************************************/
        -1,        1,        8, G_BUTTON          |0x1700,   /* Object 0  */
  NONE, SHADOWED, (LONG)"\0",
  0x0000, 0x0000, 0x0014, 0x0F07,
         2,       -1,       -1, G_STRING          ,   /* Object 1  */
  SELECTABLE|EXIT, NORMAL, (LONG)" Kontextmenue      ",
  0x0001, 0x0000, 0x0013, 0x0001,
         3,       -1,       -1, G_STRING          ,   /* Object 2  */
  SELECTABLE|EXIT, NORMAL, (LONG)" Nach vorne        ",
  0x0001, 0x0001, 0x0013, 0x0001,
         4,       -1,       -1, G_STRING          ,   /* Object 3  */
  SELECTABLE|EXIT, NORMAL, (LONG)" Ikonifizieren     ",
  0x0001, 0x0002, 0x0013, 0x0001,
         5,       -1,       -1, G_STRING          ,   /* Object 4  */
  SELECTABLE|EXIT, NORMAL, (LONG)" Ikonifizieren alle",
  0x0001, 0x0F02, 0x0013, 0x0001,
         6,       -1,       -1, G_STRING          ,   /* Object 5  */
  SELECTABLE|EXIT, NORMAL, (LONG)" De-Ikonifizieren  ",
  0x0001, 0x0E03, 0x0013, 0x0001,
         7,       -1,       -1, G_STRING          ,   /* Object 6  */
  SELECTABLE|EXIT, NORMAL, (LONG)" Ausblenden        ",
  0x0001, 0x0E04, 0x0013, 0x0001,
         8,       -1,       -1, G_STRING          ,   /* Object 7  */
  SELECTABLE|EXIT, NORMAL, (LONG)" Terminate         ",
  0x0001, 0x0C05, 0x0013, 0x0001,
         0,       -1,       -1, G_STRING          ,   /* Object 8  */
  SELECTABLE|EXIT|LASTOB, NORMAL, (LONG)" Nichts            ",
  0x0001, 0x0B06, 0x0013, 0x0001,
  
  /******** Tree 3 G_POPUP_LANGUAGE ****************************************************/
        -1,        1,        6, G_BUTTON          |0x1700,   /* Object 0  */
  NONE, SHADOWED, (LONG)"\0",
  0x0000, 0x0000, 0x0014, 0x0D05,
         2,       -1,       -1, G_STRING          ,   /* Object 1  */
  SELECTABLE|EXIT, NORMAL, (LONG)"  Polnisch        ",
  0x0000, 0x0000, 0x0012, 0x0001,
         3,       -1,       -1, G_STRING          ,   /* Object 2  */
  SELECTABLE|EXIT, NORMAL, (LONG)"  Deutsch         ",
  0x0000, 0x0F00, 0x0012, 0x0001,
         4,       -1,       -1, G_STRING          ,   /* Object 3  */
  SELECTABLE|EXIT, NORMAL, (LONG)"  Englisch        ",
  0x0000, 0x0F01, 0x0012, 0x0001,
         5,       -1,       -1, G_STRING          ,   /* Object 4  */
  SELECTABLE|EXIT, NORMAL, (LONG)"  Franzosisch     ",
  0x0000, 0x0E02, 0x0012, 0x0001,
         6,       -1,       -1, G_STRING          ,   /* Object 5  */
  SELECTABLE|EXIT, NORMAL, (LONG)"  Schwedisch      ",
  0x0000, 0x0D03, 0x0012, 0x0001,
         0,       -1,       -1, G_STRING          ,   /* Object 6  */
  SELECTABLE|EXIT|LASTOB, NORMAL, (LONG)"  Norwegisch      ",
  0x0000, 0x0D04, 0x0012, 0x0001,
  
  /******** Tree 4 G_POPUP_FARBEN ****************************************************/
        -1,        1, CODMAGEN        , G_BUTTON          |0x1700,   /* Object 0  */
  NONE, SHADOWED, (LONG)"\0",
  0x0000, 0x0000, 0x0110, 0x0310,
         2,       -1,       -1, G_BOX             ,   /* Object 1  */
  NONE, DRAW3D|WHITEBAK, (LONG)0x000111F0L,
  0x0100, 0x0100, 0x0001, 0x0001,
         3,       -1,       -1, G_BOX             ,   /* Object 2  */
  NONE, DRAW3D, (LONG)0x000111F1L,
  0x0100, 0x0101, 0x0001, 0x0001,
         4,       -1,       -1, G_BOX             ,   /* Object 3  */
  NONE, DRAW3D, (LONG)0x000111F2L,
  0x0100, 0x0102, 0x0001, 0x0001,
         5,       -1,       -1, G_BOX             ,   /* Object 4  */
  NONE, DRAW3D, (LONG)0x000111F3L,
  0x0100, 0x0103, 0x0001, 0x0001,
         6,       -1,       -1, G_BOX             ,   /* Object 5  */
  NONE, DRAW3D, (LONG)0x000111F4L,
  0x0100, 0x0104, 0x0001, 0x0001,
         7,       -1,       -1, G_BOX             ,   /* Object 6  */
  NONE, DRAW3D, (LONG)0x000111F5L,
  0x0100, 0x0105, 0x0001, 0x0001,
         8,       -1,       -1, G_BOX             ,   /* Object 7  */
  NONE, DRAW3D, (LONG)0x000111F6L,
  0x0100, 0x0106, 0x0001, 0x0001,
         9,       -1,       -1, G_BOX             ,   /* Object 8  */
  NONE, DRAW3D, (LONG)0x000111F7L,
  0x0100, 0x0107, 0x0001, 0x0001,
        10,       -1,       -1, G_BOX             ,   /* Object 9  */
  NONE, DRAW3D, (LONG)0x000111F8L,
  0x0100, 0x0108, 0x0001, 0x0001,
        11,       -1,       -1, G_BOX             ,   /* Object 10  */
  NONE, DRAW3D, (LONG)0x000111F9L,
  0x0100, 0x0109, 0x0001, 0x0001,
        12,       -1,       -1, G_BOX             ,   /* Object 11  */
  NONE, DRAW3D, (LONG)0x000111FAL,
  0x0100, 0x010A, 0x0001, 0x0001,
        13,       -1,       -1, G_BOX             ,   /* Object 12  */
  NONE, DRAW3D, (LONG)0x000111FBL,
  0x0100, 0x010B, 0x0001, 0x0001,
        14,       -1,       -1, G_BOX             ,   /* Object 13  */
  NONE, DRAW3D, (LONG)0x000111FCL,
  0x0100, 0x010C, 0x0001, 0x0001,
        15,       -1,       -1, G_BOX             ,   /* Object 14  */
  NONE, DRAW3D, (LONG)0x000111FDL,
  0x0100, 0x010D, 0x0001, 0x0001,
        16,       -1,       -1, G_BOX             ,   /* Object 15  */
  NONE, DRAW3D, (LONG)0x000111FEL,
  0x0100, 0x010E, 0x0001, 0x0001,
  COWHITE         ,       -1,       -1, G_BOX             ,   /* Object 16  */
  NONE, DRAW3D, (LONG)0x000111FFL,
  0x0100, 0x010F, 0x0001, 0x0001,
  COBLACK         ,       -1,       -1, G_STRING          ,   /* Object 17 COWHITE */
  SELECTABLE|EXIT, DRAW3D, (LONG)" Wei\236        0",
  0x0101, 0x0100, 0x000F, 0x0001,
  CORED           ,       -1,       -1, G_STRING          ,   /* Object 18 COBLACK */
  SELECTABLE|EXIT, NORMAL, (LONG)" Schwarz     1",
  0x0101, 0x0101, 0x000F, 0x0001,
  COGREEN         ,       -1,       -1, G_STRING          ,   /* Object 19 CORED */
  SELECTABLE|EXIT, NORMAL, (LONG)" Rot         2",
  0x0101, 0x0102, 0x000F, 0x0001,
        21,       -1,       -1, G_STRING          ,   /* Object 20 COGREEN */
  SELECTABLE|EXIT, NORMAL, (LONG)" Gr\201n        3",
  0x0101, 0x0103, 0x000F, 0x0001,
  COCYAN          ,       -1,       -1, G_STRING          ,   /* Object 21  */
  SELECTABLE|EXIT, NORMAL, (LONG)" Blau        4",
  0x0101, 0x0104, 0x000F, 0x0001,
  COYELLOW        ,       -1,       -1, G_STRING          ,   /* Object 22 COCYAN */
  SELECTABLE|EXIT, NORMAL, (LONG)" Zyan        5",
  0x0101, 0x0105, 0x000F, 0x0001,
  COMAGENT        ,       -1,       -1, G_STRING          ,   /* Object 23 COYELLOW */
  SELECTABLE|EXIT, NORMAL, (LONG)" Gelb        6",
  0x0101, 0x0106, 0x000F, 0x0001,
  COLGREY         ,       -1,       -1, G_STRING          ,   /* Object 24 COMAGENT */
  SELECTABLE|EXIT, NORMAL, (LONG)" Magenta     7",
  0x0101, 0x0107, 0x000F, 0x0001,
  CODGREY         ,       -1,       -1, G_STRING          ,   /* Object 25 COLGREY */
  SELECTABLE|EXIT, NORMAL, (LONG)" Hellgrau    8",
  0x0101, 0x0108, 0x000F, 0x0001,
  CODRED          ,       -1,       -1, G_STRING          ,   /* Object 26 CODGREY */
  SELECTABLE|EXIT, NORMAL, (LONG)" Dunkelgrau  9",
  0x0101, 0x0109, 0x000F, 0x0001,
  CODGREEN        ,       -1,       -1, G_STRING          ,   /* Object 27 CODRED */
  SELECTABLE|EXIT, NORMAL, (LONG)" Dunkelrot   A",
  0x0101, 0x010A, 0x000F, 0x0001,
        29,       -1,       -1, G_STRING          ,   /* Object 28 CODGREEN */
  SELECTABLE|EXIT, NORMAL, (LONG)" Dunkelgr\201n  B",
  0x0101, 0x010B, 0x000F, 0x0001,
        30,       -1,       -1, G_STRING          ,   /* Object 29  */
  SELECTABLE|EXIT, NORMAL, (LONG)" Dunkelblau  C",
  0x0101, 0x010C, 0x000F, 0x0001,
  CODYELLO        ,       -1,       -1, G_STRING          ,   /* Object 30  */
  SELECTABLE|EXIT, NORMAL, (LONG)" Dunkelzyan  D",
  0x0101, 0x010D, 0x000F, 0x0001,
  CODMAGEN        ,       -1,       -1, G_STRING          ,   /* Object 31 CODYELLO */
  SELECTABLE|EXIT, NORMAL, (LONG)" Dunkelgelb  E",
  0x0101, 0x010E, 0x000F, 0x0001,
         0,       -1,       -1, G_STRING          ,   /* Object 32 CODMAGEN */
  SELECTABLE|EXIT|LASTOB, NORMAL, (LONG)" Dnklmagenta F",
  0x0101, 0x010F, 0x000F, 0x0001,
  
  /******** Tree 5 G_POPUP_APPL ****************************************************/
        -1, APP_VERSTECKTE  , APP_IKONS       , G_BUTTON          |0x1700,   /* Object 0  */
  NONE, SHADOWED, (LONG)"\0",
  0x0000, 0x0000, 0x0010, 0x0003,
  APP_ALIASES     ,       -1,       -1, G_STRING          ,   /* Object 1 APP_VERSTECKTE */
  SELECTABLE|EXIT, NORMAL, (LONG)" Versteckte    ",
  0x0001, 0x0000, 0x000F, 0x0001,
  APP_IKONS       ,       -1,       -1, G_STRING          ,   /* Object 2 APP_ALIASES */
  SELECTABLE|EXIT, NORMAL, (LONG)" Aliases       ",
  0x0001, 0x0001, 0x000F, 0x0001,
         0,       -1,       -1, G_STRING          ,   /* Object 3 APP_IKONS */
  SELECTABLE|EXIT|LASTOB, NORMAL, (LONG)" Ikons         ",
  0x0001, 0x0002, 0x000F, 0x0001,
  
  /******** Tree 6 G_POPUP_APPL_VER ****************************************************/
        -1,        1,        2, G_BUTTON          |0x1700,   /* Object 0  */
  NONE, SHADOWED, (LONG)"\0",
  0x0000, 0x0000, 0x0010, 0x0002,
         2,       -1,       -1, G_STRING          ,   /* Object 1  */
  SELECTABLE|EXIT, NORMAL, (LONG)" Zeige immer ",
  0x0001, 0x0000, 0x000D, 0x0001,
         0,       -1,       -1, G_STRING          ,   /* Object 2  */
  SELECTABLE|EXIT|LASTOB, NORMAL, (LONG)" Zeige jetzt   ",
  0x0001, 0x0001, 0x000F, 0x0001,
  
  /******** Tree 7 G_POPUP_TEXTU ****************************************************/
        -1, FI0             , FI7             , G_BUTTON          |0x1700,   /* Object 0  */
  NONE, SHADOWED, (LONG)"\0",
  0x0000, 0x0000, 0x0110, 0x0108,
  FI1             ,       -1,       -1, G_BOX             ,   /* Object 1 FI0 */
  SELECTABLE, NORMAL, (LONG)0x00FF1101L,
  0x0100, 0x0100, 0x0010, 0x0001,
  FI2             ,       -1,       -1, G_BOX             ,   /* Object 2 FI1 */
  SELECTABLE, NORMAL, (LONG)0x00FF1111L,
  0x0100, 0x0101, 0x0010, 0x0001,
  FI3             ,       -1,       -1, G_BOX             ,   /* Object 3 FI2 */
  SELECTABLE, NORMAL, (LONG)0x00FF1121L,
  0x0100, 0x0102, 0x0010, 0x0001,
  FI4             ,       -1,       -1, G_BOX             ,   /* Object 4 FI3 */
  SELECTABLE, NORMAL, (LONG)0x00FF1131L,
  0x0100, 0x0103, 0x0010, 0x0001,
  FI5             ,       -1,       -1, G_BOX             ,   /* Object 5 FI4 */
  SELECTABLE, NORMAL, (LONG)0x00FF1141L,
  0x0100, 0x0104, 0x0010, 0x0001,
  FI6             ,       -1,       -1, G_BOX             ,   /* Object 6 FI5 */
  SELECTABLE, NORMAL, (LONG)0x00FF1151L,
  0x0100, 0x0105, 0x0010, 0x0001,
  FI7             ,       -1,       -1, G_BOX             ,   /* Object 7 FI6 */
  SELECTABLE, NORMAL, (LONG)0x00FF1161L,
  0x0100, 0x0106, 0x0010, 0x0001,
         0,       -1,       -1, G_BOX             ,   /* Object 8 FI7 */
  SELECTABLE|LASTOB, NORMAL, (LONG)0x00FF1171L,
  0x0100, 0x0107, 0x0010, 0x0001,
  
  /******** Tree 8 G_POPUP_KONTEXT ****************************************************/
        -1,        1,       19, G_BUTTON          |0x1700,   /* Object 0  */
  NONE, SHADOWED, (LONG)"\0",
  0x0000, 0x0000, 0x001E, 0x0912,
         2,       -1,       -1, G_STRING          ,   /* Object 1  */
  SELECTABLE|EXIT|FLAGS10, NORMAL, (LONG)" Name                        ",
  0x0001, 0x0000, 0x001D, 0x0001,
         3,       -1,       -1, G_STRING          ,   /* Object 2  */
  SELECTABLE|EXIT, NORMAL, (LONG)" Speicher                    ",
  0x0001, 0x0001, 0x001D, 0x0001,
         4,       -1,       -1, G_STRING          ,   /* Object 3  */
  SELECTABLE|EXIT, NORMAL, (LONG)" Fenster                     ",
  0x0001, 0x0F01, 0x001D, 0x0001,
         5,       -1,       -1, G_STRING          ,   /* Object 4  */
  SELECTABLE|EXIT, NORMAL, (LONG)" Separator                   ",
  0x0001, 0x0E02, 0x001D, 0x0001,
         6,       -1,       -1, G_STRING          ,   /* Object 5  */
  SELECTABLE|EXIT, NORMAL, (LONG)" Zeigen                      ",
  0x0001, 0x0E03, 0x001D, 0x0001,
         7,       -1,       -1, G_STRING          ,   /* Object 6  */
  SELECTABLE|EXIT, NORMAL, (LONG)" Zeigen alle                 ",
  0x0001, 0x0C04, 0x001D, 0x0001,
         8,       -1,       -1, G_STRING          ,   /* Object 7  */
  SELECTABLE|EXIT, NORMAL, (LONG)" Ikonifiziern                ",
  0x0001, 0x0B05, 0x001D, 0x0001,
         9,       -1,       -1, G_STRING          ,   /* Object 8  */
  SELECTABLE|EXIT, NORMAL, (LONG)" Ikonifizieren alle          ",
  0x0001, 0x0A06, 0x001D, 0x0001,
        10,       -1,       -1, G_STRING          ,   /* Object 9  */
  SELECTABLE|EXIT, NORMAL, (LONG)" Unikonifizieren             ",
  0x0001, 0x0A07, 0x001D, 0x0001,
        11,       -1,       -1, G_STRING          ,   /* Object 10  */
  SELECTABLE|EXIT, NORMAL, (LONG)" Verstecken                  ",
  0x0001, 0x0B08, 0x001D, 0x0001,
        12,       -1,       -1, G_STRING          ,   /* Object 11  */
  SELECTABLE|EXIT, NORMAL, (LONG)" Verstecken alle             ",
  0x0001, 0x0B09, 0x001D, 0x0001,
        13,       -1,       -1, G_STRING          ,   /* Object 12  */
  SELECTABLE|EXIT, NORMAL, (LONG)" Nach vorne                  ",
  0x0001, 0x0C0A, 0x001D, 0x0001,
        14,       -1,       -1, G_STRING          ,   /* Object 13  */
  SELECTABLE|EXIT, NORMAL, (LONG)" Vor\201bergehend verstecken    ",
  0x0001, 0x0C0B, 0x001D, 0x0001,
        15,       -1,       -1, G_STRING          ,   /* Object 14  */
  SELECTABLE|EXIT, NORMAL, (LONG)" Dauerhaft verstecken        ",
  0x0001, 0x0A0C, 0x001D, 0x0001,
        16,       -1,       -1, G_STRING          ,   /* Object 15  */
  SELECTABLE|EXIT, NORMAL, (LONG)" Priorit\204t                   ",
  0x0001, 0x0A0D, 0x001D, 0x0001,
        17,       -1,       -1, G_STRING          ,   /* Object 16  */
  SELECTABLE|EXIT, NORMAL, (LONG)" Frezzy                      ",
  0x0001, 0x0A0E, 0x001D, 0x0001,
        18,       -1,       -1, G_STRING          ,   /* Object 17  */
  SELECTABLE|EXIT, NORMAL, (LONG)" Unfrezzy                    ",
  0x0001, 0x0A0F, 0x001D, 0x0001,
        19,       -1,       -1, G_STRING          ,   /* Object 18  */
  SELECTABLE|EXIT, NORMAL, (LONG)" Terminate                   ",
  0x0001, 0x0A10, 0x001D, 0x0001,
         0,       -1,       -1, G_STRING          ,   /* Object 19  */
  SELECTABLE|EXIT|LASTOB, NORMAL, (LONG)" Ende                        ",
  0x0001, 0x0911, 0x001D, 0x0001
};

OBJECT *rs_trindex[] =
{ &rs_object[0],   /* Tree  0 G_MAIN           */
  &rs_object[198],   /* Tree  1 G_POPUP_KAT      */
  &rs_object[207],   /* Tree  2 G_POPUP_MOUSE    */
  &rs_object[216],   /* Tree  3 G_POPUP_LANGUAGE */
  &rs_object[223],   /* Tree  4 G_POPUP_FARBEN   */
  &rs_object[256],   /* Tree  5 G_POPUP_APPL     */
  &rs_object[260],   /* Tree  6 G_POPUP_APPL_VER */
  &rs_object[263],   /* Tree  7 G_POPUP_TEXTU    */
  &rs_object[272]    /* Tree  8 G_POPUP_KONTEXT  */
};
