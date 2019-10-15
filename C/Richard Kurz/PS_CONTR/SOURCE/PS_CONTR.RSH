/* GEM Resource C Source */

#include <portab.h>
#include <aes.h>
#include "PS_CONTR.H"

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
{ " 12345678 1234 1234 12 124567 12345678",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, 0, 39, 1,
  " 12345678 1234 1234 12 124567 12345678",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, 0, 39, 1,
  " 12345678 1234 1234 12 124567 12345678",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, 0, 39, 1,
  " 12345678 1234 1234 12 124567 12345678",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, 0, 39, 1,
  " 12345678 1234 1234 12 124567 12345678",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, 0, 39, 1,
  " 12345678 1234 1234 12 124567 12345678",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, 0, 39, 1,
  " 12345678 1234 1234 12 124567 12345678",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, 0, 39, 1,
  " 12345678 1234 1234 12 124567 12345678",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, 0, 39, 1,
  " 12345678 1234 1234 12 124567 12345678",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, 0, 39, 1,
  " 12345678 1234 1234 12 124567 12345678",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, 0, 39, 1,
  " 12345678 1234 1234 12 124567 12345678",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, 0, 39, 1,
  " 12345678 1234 1234 12 124567 12345678",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, 0, 39, 1,
  " 12345678 1234 1234 12 124567 12345678",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, 0, 39, 1,
  " 12345678 1234 1234 12 124567 12345678",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, 0, 39, 1,
  " 12345678 1234 1234 12 124567 12345678",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, 0, 39, 1,
  " 12345678 1234 1234 12 124567 12345678",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, 0, 39, 1,
  " 12345678 1234 1234 12 124567 12345678",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, 0, 39, 1,
  "Info",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 5, 1,
  "Hilfe",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 6, 1,
  "Alles",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 6, 1,
  "Nichts",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 7, 1,
  "Min",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 4, 1,
  "Max",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 4, 1,
  "0",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 2, 1,
  "Liste",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 6, 1,
  "Signal",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 7, 1,
  "STOP",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 5, 1,
  "TSTP",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 5, 1,
  "CONT",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 5, 1,
  "KILL",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 5, 1,
  "TERM",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 5, 1,
  "OK",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 3, 1,
  "L\224schen",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 8, 1,
  "Laden",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 6, 1,
  "OK",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 3, 1,
  "Sichern",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 8, 1,
  "Aufnehmen",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 10, 1
};

OBJECT rs_object[] =
{ 
  /******** Tree 0 DIALOG ****************************************************/
        -1,        1, D_FILE  , G_BOX     ,   /* Object 0  */
  NONE, NORMAL, (LONG)0x00FF1100L,
  0x0000, 0x0000, 0x0027, 0x0815,
         2,       -1,       -1, G_STRING  ,   /* Object 1  */
  NONE, NORMAL, (LONG)"Name",
  0x0001, 0x0000, 0x0004, 0x0001,
         3,       -1,       -1, G_STRING  ,   /* Object 2  */
  NONE, NORMAL, (LONG)"Id",
  0x000B, 0x0000, 0x0002, 0x0001,
         4,       -1,       -1, G_STRING  ,   /* Object 3  */
  NONE, NORMAL, (LONG)"Pri",
  0x000F, 0x0000, 0x0003, 0x0001,
         5,       -1,       -1, G_STRING  ,   /* Object 4  */
  NONE, NORMAL, (LONG)"Fl",
  0x0013, 0x0000, 0x0002, 0x0001,
         6,       -1,       -1, G_STRING  ,   /* Object 5  */
  NONE, NORMAL, (LONG)"CPU",
  0x001A, 0x0000, 0x0003, 0x0001,
  DISPLAY ,       -1,       -1, G_STRING  ,   /* Object 6  */
  NONE, NORMAL, (LONG)"Byte",
  0x0022, 0x0000, 0x0004, 0x0001,
        25, ZEILE1  , ZEILE17 , G_BOX     ,   /* Object 7 DISPLAY */
  NONE, NORMAL, (LONG)0x00FF1101L,
  0x0000, 0x0001, 0x0027, 0x0011,
         9,       -1,       -1, G_TEXT    ,   /* Object 8 ZEILE1 */
  TOUCHEXIT, NORMAL, (LONG)&rs_tedinfo[0],
  0x0000, 0x0000, 0x0027, 0x0001,
        10,       -1,       -1, G_TEXT    ,   /* Object 9  */
  TOUCHEXIT, NORMAL, (LONG)&rs_tedinfo[1],
  0x0000, 0x0001, 0x0027, 0x0001,
        11,       -1,       -1, G_TEXT    ,   /* Object 10  */
  TOUCHEXIT, NORMAL, (LONG)&rs_tedinfo[2],
  0x0000, 0x0002, 0x0027, 0x0001,
        12,       -1,       -1, G_TEXT    ,   /* Object 11  */
  TOUCHEXIT, NORMAL, (LONG)&rs_tedinfo[3],
  0x0000, 0x0003, 0x0027, 0x0001,
        13,       -1,       -1, G_TEXT    ,   /* Object 12  */
  TOUCHEXIT, NORMAL, (LONG)&rs_tedinfo[4],
  0x0000, 0x0004, 0x0027, 0x0001,
        14,       -1,       -1, G_TEXT    ,   /* Object 13  */
  TOUCHEXIT, NORMAL, (LONG)&rs_tedinfo[5],
  0x0000, 0x0005, 0x0027, 0x0001,
        15,       -1,       -1, G_TEXT    ,   /* Object 14  */
  TOUCHEXIT, NORMAL, (LONG)&rs_tedinfo[6],
  0x0000, 0x0006, 0x0027, 0x0001,
        16,       -1,       -1, G_TEXT    ,   /* Object 15  */
  TOUCHEXIT, NORMAL, (LONG)&rs_tedinfo[7],
  0x0000, 0x0007, 0x0027, 0x0001,
        17,       -1,       -1, G_TEXT    ,   /* Object 16  */
  TOUCHEXIT, NORMAL, (LONG)&rs_tedinfo[8],
  0x0000, 0x0008, 0x0027, 0x0001,
        18,       -1,       -1, G_TEXT    ,   /* Object 17  */
  TOUCHEXIT, NORMAL, (LONG)&rs_tedinfo[9],
  0x0000, 0x0009, 0x0027, 0x0001,
        19,       -1,       -1, G_TEXT    ,   /* Object 18  */
  TOUCHEXIT, NORMAL, (LONG)&rs_tedinfo[10],
  0x0000, 0x000A, 0x0027, 0x0001,
        20,       -1,       -1, G_TEXT    ,   /* Object 19  */
  TOUCHEXIT, NORMAL, (LONG)&rs_tedinfo[11],
  0x0000, 0x000B, 0x0027, 0x0001,
        21,       -1,       -1, G_TEXT    ,   /* Object 20  */
  TOUCHEXIT, NORMAL, (LONG)&rs_tedinfo[12],
  0x0000, 0x000C, 0x0027, 0x0001,
        22,       -1,       -1, G_TEXT    ,   /* Object 21  */
  TOUCHEXIT, NORMAL, (LONG)&rs_tedinfo[13],
  0x0000, 0x000D, 0x0027, 0x0001,
        23,       -1,       -1, G_TEXT    ,   /* Object 22  */
  TOUCHEXIT, NORMAL, (LONG)&rs_tedinfo[14],
  0x0000, 0x000E, 0x0027, 0x0001,
  ZEILE17 ,       -1,       -1, G_TEXT    ,   /* Object 23  */
  TOUCHEXIT, NORMAL, (LONG)&rs_tedinfo[15],
  0x0000, 0x000F, 0x0027, 0x0001,
  DISPLAY ,       -1,       -1, G_TEXT    ,   /* Object 24 ZEILE17 */
  TOUCHEXIT, NORMAL, (LONG)&rs_tedinfo[16],
  0x0000, 0x0010, 0x0027, 0x0001,
        28, BYRK    , HILFE   , G_BOX     ,   /* Object 25  */
  NONE, NORMAL, (LONG)0x00011141L,
  0x0000, 0x0012, 0x0008, 0x0803,
  HILFE   ,       -1,       -1, G_BOXTEXT ,   /* Object 26 BYRK */
  SELECTABLE|EXIT, SHADOWED, (LONG)&rs_tedinfo[17],
  0x0001, 0x0800, 0x0006, 0x0001,
        25,       -1,       -1, G_BOXTEXT ,   /* Object 27 HILFE */
  SELECTABLE|EXIT, SHADOWED, (LONG)&rs_tedinfo[18],
  0x0001, 0x0002, 0x0006, 0x0001,
  D_PRIO  , ALLE    , NIX     , G_BOX     ,   /* Object 28  */
  NONE, NORMAL, (LONG)0x00011131L,
  0x0008, 0x0012, 0x0009, 0x0803,
  NIX     ,       -1,       -1, G_BOXTEXT ,   /* Object 29 ALLE */
  SELECTABLE|EXIT, NORMAL, (LONG)&rs_tedinfo[19],
  0x0001, 0x0800, 0x0007, 0x0001,
        28,       -1,       -1, G_BOXTEXT ,   /* Object 30 NIX */
  SELECTABLE|EXIT, NORMAL, (LONG)&rs_tedinfo[20],
  0x0001, 0x0002, 0x0007, 0x0001,
  D_SIGN  , PLUS    , SIGNAL  , G_BOX     ,   /* Object 31 D_PRIO */
  NONE, NORMAL, (LONG)0x00011111L,
  0x0011, 0x0012, 0x0016, 0x0803,
  MINUS   ,       -1,       -1, G_BOXCHAR ,   /* Object 32 PLUS */
  TOUCHEXIT, NORMAL, (LONG) ((LONG)'+' << 24)|0x00FF1100L,
  0x0001, 0x0800, 0x0003, 0x0001,
  MIN     ,       -1,       -1, G_BOXCHAR ,   /* Object 33 MINUS */
  TOUCHEXIT, NORMAL, (LONG) ((LONG)'-' << 24)|0x00FF1100L,
  0x0001, 0x0002, 0x0003, 0x0001,
  MAX     ,       -1,       -1, G_BOXTEXT ,   /* Object 34 MIN */
  SELECTABLE|EXIT, NORMAL, (LONG)&rs_tedinfo[21],
  0x0005, 0x0002, 0x0004, 0x0001,
  NORM    ,       -1,       -1, G_BOXTEXT ,   /* Object 35 MAX */
  SELECTABLE|EXIT, NORMAL, (LONG)&rs_tedinfo[22],
  0x0005, 0x0800, 0x0004, 0x0001,
  LOADSAVE,       -1,       -1, G_BOXTEXT ,   /* Object 36 NORM */
  SELECTABLE|EXIT, NORMAL, (LONG)&rs_tedinfo[23],
  0x000A, 0x0800, 0x0002, 0x0802,
  SIGNAL  ,       -1,       -1, G_BOXTEXT ,   /* Object 37 LOADSAVE */
  SELECTABLE|EXIT, SHADOWED, (LONG)&rs_tedinfo[24],
  0x000D, 0x0800, 0x0008, 0x0001,
  D_PRIO  ,       -1,       -1, G_BOXTEXT ,   /* Object 38 SIGNAL */
  SELECTABLE|EXIT, SHADOWED, (LONG)&rs_tedinfo[25],
  0x000D, 0x0002, 0x0008, 0x0001,
  D_FILE  , S_STOP  , ZURUECK , G_BOX     ,   /* Object 39 D_SIGN */
  NONE, NORMAL, (LONG)0x00011111L,
  0x000E, 0x0012, 0x0016, 0x0803,
  S_TSTP  ,       -1,       -1, G_BOXTEXT ,   /* Object 40 S_STOP */
  SELECTABLE|EXIT, NORMAL, (LONG)&rs_tedinfo[26],
  0x0001, 0x0800, 0x0006, 0x0001,
  S_CONT  ,       -1,       -1, G_BOXTEXT ,   /* Object 41 S_TSTP */
  SELECTABLE|EXIT, NORMAL, (LONG)&rs_tedinfo[27],
  0x0008, 0x0800, 0x0006, 0x0001,
  S_KILL  ,       -1,       -1, G_BOXTEXT ,   /* Object 42 S_CONT */
  SELECTABLE|EXIT, NORMAL, (LONG)&rs_tedinfo[28],
  0x000F, 0x0800, 0x0006, 0x0001,
  S_TERM  ,       -1,       -1, G_BOXTEXT ,   /* Object 43 S_KILL */
  SELECTABLE|EXIT, NORMAL, (LONG)&rs_tedinfo[29],
  0x0001, 0x0002, 0x0006, 0x0001,
  ZURUECK ,       -1,       -1, G_BOXTEXT ,   /* Object 44 S_TERM */
  SELECTABLE|EXIT, NORMAL, (LONG)&rs_tedinfo[30],
  0x0008, 0x0002, 0x0006, 0x0001,
  D_SIGN  ,       -1,       -1, G_BOXTEXT ,   /* Object 45 ZURUECK */
  SELECTABLE|EXIT, SHADOWED, (LONG)&rs_tedinfo[31],
  0x000F, 0x0002, 0x0006, 0x0001,
         0, LOESCHEN, ADDI    , G_BOX     ,   /* Object 46 D_FILE */
  HIDETREE, NORMAL, (LONG)0x00011111L,
  0x000B, 0x0012, 0x0016, 0x0803,
  LOADI   ,       -1,       -1, G_BOXTEXT ,   /* Object 47 LOESCHEN */
  SELECTABLE|EXIT, NORMAL, (LONG)&rs_tedinfo[32],
  0x000C, 0x0800, 0x0009, 0x0001,
  ZURUECK2,       -1,       -1, G_BOXTEXT ,   /* Object 48 LOADI */
  SELECTABLE|EXIT, SHADOWED, (LONG)&rs_tedinfo[33],
  0x0001, 0x0002, 0x0006, 0x0001,
  SAVEI   ,       -1,       -1, G_BOXTEXT ,   /* Object 49 ZURUECK2 */
  SELECTABLE|EXIT, SHADOWED, (LONG)&rs_tedinfo[34],
  0x0011, 0x0002, 0x0004, 0x0001,
  ADDI    ,       -1,       -1, G_BOXTEXT ,   /* Object 50 SAVEI */
  SELECTABLE|EXIT, SHADOWED, (LONG)&rs_tedinfo[35],
  0x0008, 0x0002, 0x0008, 0x0001,
  D_FILE  ,       -1,       -1, G_BOXTEXT ,   /* Object 51 ADDI */
  SELECTABLE|EXIT|LASTOB, NORMAL, (LONG)&rs_tedinfo[36],
  0x0001, 0x0800, 0x000A, 0x0001,
  
  /******** Tree 1 HELP ****************************************************/
        -1,        1,       16, G_BOX     ,   /* Object 0  */
  NONE, OUTLINED, (LONG)0x00FF1100L,
  0x0000, 0x0000, 0x0025, 0x0013,
         2,       -1,       -1, G_STRING  ,   /* Object 1  */
  NONE, NORMAL, (LONG)"Durch Anklicken wird ein Prozess",
  0x0001, 0x0001, 0x0020, 0x0001,
         3,       -1,       -1, G_STRING  ,   /* Object 2  */
  NONE, NORMAL, (LONG)"markiert. Bei gedr\201ckter Shift-",
  0x0001, 0x0002, 0x001F, 0x0001,
         4,       -1,       -1, G_STRING  ,   /* Object 3  */
  NONE, NORMAL, (LONG)"Mit + und - kann die Priorit\204t",
  0x0001, 0x0006, 0x001E, 0x0001,
         5,       -1,       -1, G_STRING  ,   /* Object 4  */
  NONE, NORMAL, (LONG)"eines Prozesses erh\224ht bzw. ver-",
  0x0001, 0x0007, 0x0020, 0x0001,
         6,       -1,       -1, G_STRING  ,   /* Object 5  */
  NONE, NORMAL, (LONG)"mindert werden, Min / Max setzen",
  0x0001, 0x0008, 0x0020, 0x0001,
         7,       -1,       -1, G_STRING  ,   /* Object 6  */
  NONE, NORMAL, (LONG)"sie auf -20 / +20. Diese Vorgaben",
  0x0001, 0x0009, 0x0021, 0x0001,
         8,       -1,       -1, G_STRING  ,   /* Object 7  */
  NONE, NORMAL, (LONG)"k\224nnen mit \042Liste\042 dauerhaft ge-",
  0x0001, 0x000A, 0x0020, 0x0001,
         9,       -1,       -1, G_STRING  ,   /* Object 8  */
  NONE, NORMAL, (LONG)"sichert werden. Einmal pro Sekunde",
  0x0001, 0x000B, 0x0022, 0x0001,
        10,       -1,       -1, G_STRING  ,   /* Object 9  */
  NONE, NORMAL, (LONG)"werden die Werte aus der Liste bei",
  0x0001, 0x000C, 0x0022, 0x0001,
        11,       -1,       -1, G_STRING  ,   /* Object 10  */
  NONE, NORMAL, (LONG)"Bedarf aktuallisiert.",
  0x0001, 0x000D, 0x0015, 0x0001,
        12,       -1,       -1, G_STRING  ,   /* Object 11  */
  NONE, NORMAL, (LONG)"Im Menu Signal, k\224nnen Signale an",
  0x0001, 0x000E, 0x0021, 0x0001,
  HFEXIT  ,       -1,       -1, G_STRING  ,   /* Object 12  */
  NONE, NORMAL, (LONG)"aktive Prozesse gesendet werden.",
  0x0001, 0x000F, 0x0020, 0x0001,
        14,       -1,       -1, G_BUTTON  ,   /* Object 13 HFEXIT */
  SELECTABLE|DEFAULT|EXIT, NORMAL, (LONG)"OK",
  0x0019, 0x0011, 0x000A, 0x0001,
        15,       -1,       -1, G_STRING  ,   /* Object 14  */
  NONE, NORMAL, (LONG)"\224ffnet ein Informations-Fenster.",
  0x0001, 0x0005, 0x0020, 0x0001,
        16,       -1,       -1, G_STRING  ,   /* Object 15  */
  NONE, NORMAL, (LONG)"Taste k\224nnen mehrere Prozesse an-",
  0x0001, 0x0003, 0x0021, 0x0001,
         0,       -1,       -1, G_STRING  ,   /* Object 16  */
  LASTOB, NORMAL, (LONG)"gew\204hlt werden. Ein Doppelklick",
  0x0001, 0x0004, 0x001F, 0x0001,
  
  /******** Tree 2 PSINFO1 ****************************************************/
        -1,        1, ICUSR   , G_BOX     ,   /* Object 0  */
  NONE, NORMAL, (LONG)0x00FF1100L,
  0x0000, 0x0000, 0x0023, 0x000A,
  IPID    ,       -1,       -1, G_STRING  ,   /* Object 1  */
  NONE, NORMAL, (LONG)"pid   :",
  0x0001, 0x0001, 0x0007, 0x0001,
         3,       -1,       -1, G_STRING  ,   /* Object 2 IPID */
  NONE, NORMAL, (LONG)"123456",
  0x0009, 0x0001, 0x0006, 0x0001,
  IPPID   ,       -1,       -1, G_STRING  ,   /* Object 3  */
  NONE, NORMAL, (LONG)"ppid  :",
  0x0015, 0x0001, 0x0007, 0x0001,
         5,       -1,       -1, G_STRING  ,   /* Object 4 IPPID */
  NONE, NORMAL, (LONG)"123456",
  0x001D, 0x0001, 0x0006, 0x0001,
  ISTATUS ,       -1,       -1, G_STRING  ,   /* Object 5  */
  NONE, NORMAL, (LONG)"status:",
  0x0001, 0x0002, 0x0007, 0x0001,
  ITSTATUS,       -1,       -1, G_STRING  ,   /* Object 6 ISTATUS */
  NONE, NORMAL, (LONG)"123456",
  0x0009, 0x0002, 0x0006, 0x0001,
         8,       -1,       -1, G_STRING  ,   /* Object 7 ITSTATUS */
  NONE, NORMAL, (LONG)"123456789012",
  0x0015, 0x0002, 0x000C, 0x0001,
  IPRI    ,       -1,       -1, G_STRING  ,   /* Object 8  */
  NONE, NORMAL, (LONG)"pri   :",
  0x0001, 0x0003, 0x0007, 0x0001,
        10,       -1,       -1, G_STRING  ,   /* Object 9 IPRI */
  NONE, NORMAL, (LONG)"123456",
  0x0009, 0x0003, 0x0006, 0x0001,
  ICURPRI ,       -1,       -1, G_STRING  ,   /* Object 10  */
  NONE, NORMAL, (LONG)"curpri:",
  0x0015, 0x0003, 0x0007, 0x0001,
        12,       -1,       -1, G_STRING  ,   /* Object 11 ICURPRI */
  NONE, NORMAL, (LONG)"123456",
  0x001D, 0x0003, 0x0006, 0x0001,
  ISIZE   ,       -1,       -1, G_STRING  ,   /* Object 12  */
  NONE, NORMAL, (LONG)"byte  :",
  0x0001, 0x0004, 0x0007, 0x0001,
        14,       -1,       -1, G_STRING  ,   /* Object 13 ISIZE */
  NONE, NORMAL, (LONG)"12345678901234567890",
  0x0009, 0x0004, 0x0014, 0x0001,
        15,       -1,       -1, G_STRING  ,   /* Object 14  */
  NONE, NORMAL, (LONG)"systime",
  0x000B, 0x0006, 0x0007, 0x0001,
        16,       -1,       -1, G_STRING  ,   /* Object 15  */
  NONE, NORMAL, (LONG)"usrtime",
  0x0017, 0x0006, 0x0007, 0x0001,
  IPSYS   ,       -1,       -1, G_STRING  ,   /* Object 16  */
  NONE, NORMAL, (LONG)"prozess :",
  0x0001, 0x0007, 0x0009, 0x0001,
  IPUSR   ,       -1,       -1, G_STRING  ,   /* Object 17 IPSYS */
  NONE, NORMAL, (LONG)"1234567890",
  0x000B, 0x0007, 0x000A, 0x0001,
        19,       -1,       -1, G_STRING  ,   /* Object 18 IPUSR */
  NONE, NORMAL, (LONG)"1234567890",
  0x0017, 0x0007, 0x000A, 0x0001,
  ICSYS   ,       -1,       -1, G_STRING  ,   /* Object 19  */
  NONE, NORMAL, (LONG)"children:",
  0x0001, 0x0008, 0x0009, 0x0001,
  ICUSR   ,       -1,       -1, G_STRING  ,   /* Object 20 ICSYS */
  NONE, NORMAL, (LONG)"1234567890",
  0x000B, 0x0008, 0x000A, 0x0001,
         0,       -1,       -1, G_STRING  ,   /* Object 21 ICUSR */
  LASTOB, NORMAL, (LONG)"1234567890",
  0x0017, 0x0008, 0x000A, 0x0001,
  
  /******** Tree 3 PSINFO2 ****************************************************/
        -1,        1,       21, G_BOX     ,   /* Object 0  */
  NONE, NORMAL, (LONG)0x00FF1100L,
  0x0000, 0x0000, 0x0023, 0x000A,
         2,       -1,       -1, G_STRING  ,   /* Object 1  */
  NONE, NORMAL, (LONG)"pid   :",
  0x0001, 0x0001, 0x0007, 0x0001,
         3,       -1,       -1, G_STRING  ,   /* Object 2  */
  NONE, NORMAL, (LONG)"123456",
  0x0009, 0x0001, 0x0006, 0x0001,
         4,       -1,       -1, G_STRING  ,   /* Object 3  */
  NONE, NORMAL, (LONG)"ppid  :",
  0x0015, 0x0001, 0x0007, 0x0001,
         5,       -1,       -1, G_STRING  ,   /* Object 4  */
  NONE, NORMAL, (LONG)"123456",
  0x001D, 0x0001, 0x0006, 0x0001,
         6,       -1,       -1, G_STRING  ,   /* Object 5  */
  NONE, NORMAL, (LONG)"status:",
  0x0001, 0x0002, 0x0007, 0x0001,
         7,       -1,       -1, G_STRING  ,   /* Object 6  */
  NONE, NORMAL, (LONG)"123456",
  0x0009, 0x0002, 0x0006, 0x0001,
         8,       -1,       -1, G_STRING  ,   /* Object 7  */
  NONE, NORMAL, (LONG)"123456789012",
  0x0015, 0x0002, 0x000C, 0x0001,
         9,       -1,       -1, G_STRING  ,   /* Object 8  */
  NONE, NORMAL, (LONG)"pri   :",
  0x0001, 0x0003, 0x0007, 0x0001,
        10,       -1,       -1, G_STRING  ,   /* Object 9  */
  NONE, NORMAL, (LONG)"123456",
  0x0009, 0x0003, 0x0006, 0x0001,
        11,       -1,       -1, G_STRING  ,   /* Object 10  */
  NONE, NORMAL, (LONG)"curpri:",
  0x0015, 0x0003, 0x0007, 0x0001,
        12,       -1,       -1, G_STRING  ,   /* Object 11  */
  NONE, NORMAL, (LONG)"123456",
  0x001D, 0x0003, 0x0006, 0x0001,
        13,       -1,       -1, G_STRING  ,   /* Object 12  */
  NONE, NORMAL, (LONG)"byte  :",
  0x0001, 0x0004, 0x0007, 0x0001,
        14,       -1,       -1, G_STRING  ,   /* Object 13  */
  NONE, NORMAL, (LONG)"12345678901234567890",
  0x0009, 0x0004, 0x0014, 0x0001,
        15,       -1,       -1, G_STRING  ,   /* Object 14  */
  NONE, NORMAL, (LONG)"systime",
  0x000B, 0x0006, 0x0007, 0x0001,
        16,       -1,       -1, G_STRING  ,   /* Object 15  */
  NONE, NORMAL, (LONG)"usrtime",
  0x0017, 0x0006, 0x0007, 0x0001,
        17,       -1,       -1, G_STRING  ,   /* Object 16  */
  NONE, NORMAL, (LONG)"prozess :",
  0x0001, 0x0007, 0x0009, 0x0001,
        18,       -1,       -1, G_STRING  ,   /* Object 17  */
  NONE, NORMAL, (LONG)"1234567890",
  0x000B, 0x0007, 0x000A, 0x0001,
        19,       -1,       -1, G_STRING  ,   /* Object 18  */
  NONE, NORMAL, (LONG)"1234567890",
  0x0017, 0x0007, 0x000A, 0x0001,
        20,       -1,       -1, G_STRING  ,   /* Object 19  */
  NONE, NORMAL, (LONG)"children:",
  0x0001, 0x0008, 0x0009, 0x0001,
        21,       -1,       -1, G_STRING  ,   /* Object 20  */
  NONE, NORMAL, (LONG)"1234567890",
  0x000B, 0x0008, 0x000A, 0x0001,
         0,       -1,       -1, G_STRING  ,   /* Object 21  */
  LASTOB, NORMAL, (LONG)"1234567890",
  0x0017, 0x0008, 0x000A, 0x0001,
  
  /******** Tree 4 PSINFO3 ****************************************************/
        -1,        1,       21, G_BOX     ,   /* Object 0  */
  NONE, NORMAL, (LONG)0x00FF1100L,
  0x0000, 0x0000, 0x0023, 0x000A,
         2,       -1,       -1, G_STRING  ,   /* Object 1  */
  NONE, NORMAL, (LONG)"pid   :",
  0x0001, 0x0001, 0x0007, 0x0001,
         3,       -1,       -1, G_STRING  ,   /* Object 2  */
  NONE, NORMAL, (LONG)"123456",
  0x0009, 0x0001, 0x0006, 0x0001,
         4,       -1,       -1, G_STRING  ,   /* Object 3  */
  NONE, NORMAL, (LONG)"ppid  :",
  0x0015, 0x0001, 0x0007, 0x0001,
         5,       -1,       -1, G_STRING  ,   /* Object 4  */
  NONE, NORMAL, (LONG)"123456",
  0x001D, 0x0001, 0x0006, 0x0001,
         6,       -1,       -1, G_STRING  ,   /* Object 5  */
  NONE, NORMAL, (LONG)"status:",
  0x0001, 0x0002, 0x0007, 0x0001,
         7,       -1,       -1, G_STRING  ,   /* Object 6  */
  NONE, NORMAL, (LONG)"123456",
  0x0009, 0x0002, 0x0006, 0x0001,
         8,       -1,       -1, G_STRING  ,   /* Object 7  */
  NONE, NORMAL, (LONG)"123456789012",
  0x0015, 0x0002, 0x000C, 0x0001,
         9,       -1,       -1, G_STRING  ,   /* Object 8  */
  NONE, NORMAL, (LONG)"pri   :",
  0x0001, 0x0003, 0x0007, 0x0001,
        10,       -1,       -1, G_STRING  ,   /* Object 9  */
  NONE, NORMAL, (LONG)"123456",
  0x0009, 0x0003, 0x0006, 0x0001,
        11,       -1,       -1, G_STRING  ,   /* Object 10  */
  NONE, NORMAL, (LONG)"curpri:",
  0x0015, 0x0003, 0x0007, 0x0001,
        12,       -1,       -1, G_STRING  ,   /* Object 11  */
  NONE, NORMAL, (LONG)"123456",
  0x001D, 0x0003, 0x0006, 0x0001,
        13,       -1,       -1, G_STRING  ,   /* Object 12  */
  NONE, NORMAL, (LONG)"byte  :",
  0x0001, 0x0004, 0x0007, 0x0001,
        14,       -1,       -1, G_STRING  ,   /* Object 13  */
  NONE, NORMAL, (LONG)"12345678901234567890",
  0x0009, 0x0004, 0x0014, 0x0001,
        15,       -1,       -1, G_STRING  ,   /* Object 14  */
  NONE, NORMAL, (LONG)"systime",
  0x000B, 0x0006, 0x0007, 0x0001,
        16,       -1,       -1, G_STRING  ,   /* Object 15  */
  NONE, NORMAL, (LONG)"usrtime",
  0x0017, 0x0006, 0x0007, 0x0001,
        17,       -1,       -1, G_STRING  ,   /* Object 16  */
  NONE, NORMAL, (LONG)"prozess :",
  0x0001, 0x0007, 0x0009, 0x0001,
        18,       -1,       -1, G_STRING  ,   /* Object 17  */
  NONE, NORMAL, (LONG)"1234567890",
  0x000B, 0x0007, 0x000A, 0x0001,
        19,       -1,       -1, G_STRING  ,   /* Object 18  */
  NONE, NORMAL, (LONG)"1234567890",
  0x0017, 0x0007, 0x000A, 0x0001,
        20,       -1,       -1, G_STRING  ,   /* Object 19  */
  NONE, NORMAL, (LONG)"children:",
  0x0001, 0x0008, 0x0009, 0x0001,
        21,       -1,       -1, G_STRING  ,   /* Object 20  */
  NONE, NORMAL, (LONG)"1234567890",
  0x000B, 0x0008, 0x000A, 0x0001,
         0,       -1,       -1, G_STRING  ,   /* Object 21  */
  LASTOB, NORMAL, (LONG)"1234567890",
  0x0017, 0x0008, 0x000A, 0x0001,
  
  /******** Tree 5 PSINFO4 ****************************************************/
        -1,        1,       21, G_BOX     ,   /* Object 0  */
  NONE, NORMAL, (LONG)0x00FF1100L,
  0x0000, 0x0000, 0x0023, 0x000A,
         2,       -1,       -1, G_STRING  ,   /* Object 1  */
  NONE, NORMAL, (LONG)"pid   :",
  0x0001, 0x0001, 0x0007, 0x0001,
         3,       -1,       -1, G_STRING  ,   /* Object 2  */
  NONE, NORMAL, (LONG)"123456",
  0x0009, 0x0001, 0x0006, 0x0001,
         4,       -1,       -1, G_STRING  ,   /* Object 3  */
  NONE, NORMAL, (LONG)"ppid  :",
  0x0015, 0x0001, 0x0007, 0x0001,
         5,       -1,       -1, G_STRING  ,   /* Object 4  */
  NONE, NORMAL, (LONG)"123456",
  0x001D, 0x0001, 0x0006, 0x0001,
         6,       -1,       -1, G_STRING  ,   /* Object 5  */
  NONE, NORMAL, (LONG)"status:",
  0x0001, 0x0002, 0x0007, 0x0001,
         7,       -1,       -1, G_STRING  ,   /* Object 6  */
  NONE, NORMAL, (LONG)"123456",
  0x0009, 0x0002, 0x0006, 0x0001,
         8,       -1,       -1, G_STRING  ,   /* Object 7  */
  NONE, NORMAL, (LONG)"123456789012",
  0x0015, 0x0002, 0x000C, 0x0001,
         9,       -1,       -1, G_STRING  ,   /* Object 8  */
  NONE, NORMAL, (LONG)"pri   :",
  0x0001, 0x0003, 0x0007, 0x0001,
        10,       -1,       -1, G_STRING  ,   /* Object 9  */
  NONE, NORMAL, (LONG)"123456",
  0x0009, 0x0003, 0x0006, 0x0001,
        11,       -1,       -1, G_STRING  ,   /* Object 10  */
  NONE, NORMAL, (LONG)"curpri:",
  0x0015, 0x0003, 0x0007, 0x0001,
        12,       -1,       -1, G_STRING  ,   /* Object 11  */
  NONE, NORMAL, (LONG)"123456",
  0x001D, 0x0003, 0x0006, 0x0001,
        13,       -1,       -1, G_STRING  ,   /* Object 12  */
  NONE, NORMAL, (LONG)"byte  :",
  0x0001, 0x0004, 0x0007, 0x0001,
        14,       -1,       -1, G_STRING  ,   /* Object 13  */
  NONE, NORMAL, (LONG)"12345678901234567890",
  0x0009, 0x0004, 0x0014, 0x0001,
        15,       -1,       -1, G_STRING  ,   /* Object 14  */
  NONE, NORMAL, (LONG)"systime",
  0x000B, 0x0006, 0x0007, 0x0001,
        16,       -1,       -1, G_STRING  ,   /* Object 15  */
  NONE, NORMAL, (LONG)"usrtime",
  0x0017, 0x0006, 0x0007, 0x0001,
        17,       -1,       -1, G_STRING  ,   /* Object 16  */
  NONE, NORMAL, (LONG)"prozess :",
  0x0001, 0x0007, 0x0009, 0x0001,
        18,       -1,       -1, G_STRING  ,   /* Object 17  */
  NONE, NORMAL, (LONG)"1234567890",
  0x000B, 0x0007, 0x000A, 0x0001,
        19,       -1,       -1, G_STRING  ,   /* Object 18  */
  NONE, NORMAL, (LONG)"1234567890",
  0x0017, 0x0007, 0x000A, 0x0001,
        20,       -1,       -1, G_STRING  ,   /* Object 19  */
  NONE, NORMAL, (LONG)"children:",
  0x0001, 0x0008, 0x0009, 0x0001,
        21,       -1,       -1, G_STRING  ,   /* Object 20  */
  NONE, NORMAL, (LONG)"1234567890",
  0x000B, 0x0008, 0x000A, 0x0001,
         0,       -1,       -1, G_STRING  ,   /* Object 21  */
  LASTOB, NORMAL, (LONG)"1234567890",
  0x0017, 0x0008, 0x000A, 0x0001,
  
  /******** Tree 6 EINFO ****************************************************/
        -1,        1,       10, G_BOX     ,   /* Object 0  */
  NONE, NORMAL, (LONG)0x00FF1100L,
  0x0000, 0x0000, 0x0022, 0x0011,
         2,       -1,       -1, G_STRING  ,   /* Object 1  */
  NONE, NORMAL, (LONG)"Demonstration f\201r die",
  0x0007, 0x0004, 0x0015, 0x0001,
         3,       -1,       -1, G_STRING  ,   /* Object 2  */
  NONE, NORMAL, (LONG)"Programmierung unter MiNT",
  0x0005, 0x0005, 0x0019, 0x0001,
         4,       -1,       -1, G_STRING  ,   /* Object 3  */
  NONE, NORMAL, (LONG)" \275 1992 by Richard Kurz",
  0x0006, 0x0007, 0x0017, 0x0001,
         5,       -1,       -1, G_STRING  ,   /* Object 4  */
  NONE, NORMAL, (LONG)"Vogelherdbogen 62",
  0x0009, 0x0008, 0x0011, 0x0001,
         6,       -1,       -1, G_STRING  ,   /* Object 5  */
  NONE, NORMAL, (LONG)"7992 Tettnang",
  0x000B, 0x0009, 0x000D, 0x0001,
         7,       -1,       -1, G_STRING  ,   /* Object 6  */
  NONE, NORMAL, (LONG)"TOS-Magazin",
  0x000C, 0x000C, 0x000B, 0x0001,
         8,       -1,       -1, G_STRING  ,   /* Object 7  */
  NONE, NORMAL, (LONG)"ICP-Verlag GmbH & Co. KG",
  0x0005, 0x000D, 0x0018, 0x0001,
         9,       -1,       -1, G_BUTTON  ,   /* Object 8  */
  NONE, SHADOWED, (LONG)"PS-Control V1.5",
  0x0003, 0x0001, 0x001C, 0x0002,
        10,       -1,       -1, G_BUTTON  ,   /* Object 9  */
  SELECTABLE|DEFAULT|EXIT, NORMAL, (LONG)"Okay",
  0x000D, 0x000F, 0x0008, 0x0001,
         0,       -1,       -1, G_STRING  ,   /* Object 10  */
  LASTOB, NORMAL, (LONG)"Fido: 2:241/7232.5",
  0x0008, 0x000A, 0x0012, 0x0001
};

OBJECT *rs_trindex[] =
{ &rs_object[0],   /* Tree  0 DIALOG   */
  &rs_object[52],   /* Tree  1 HELP     */
  &rs_object[69],   /* Tree  2 PSINFO1  */
  &rs_object[91],   /* Tree  3 PSINFO2  */
  &rs_object[113],   /* Tree  4 PSINFO3  */
  &rs_object[135],   /* Tree  5 PSINFO4  */
  &rs_object[157]    /* Tree  6 EINFO    */
};
