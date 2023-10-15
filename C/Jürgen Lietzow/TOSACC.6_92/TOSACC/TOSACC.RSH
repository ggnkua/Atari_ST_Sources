/* GEM Resource C Source */

#include <portab.h>
#include <aes.h>
#include "TOSACC.H"

#if !defined(WHITEBAK)
#define WHITEBAK    0x0080
#endif
#if !defined(DRAW3D)
#define DRAW3D      0x0040
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
{ "99",
  "0.__",
  "99",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 3, 5,
  "99",
  "0.__",
  "99",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 3, 5,
  "99",
  "0.__",
  "99",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 3, 5,
  "Dynamische",
  "",
  "",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 11, 1,
  "Maus",
  "",
  "",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 5, 1,
  "99",
  "__",
  "99",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 3, 3,
  "99",
  "__",
  "99",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 3, 3,
  "99",
  "__",
  "99",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 3, 3,
  "99",
  "__",
  "99",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 3, 3,
  "99",
  "__",
  "99",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 3, 3,
  "99",
  "__",
  "99",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 3, 3,
  "99",
  "__",
  "99",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 3, 3,
  "99",
  "__",
  "99",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 3, 3,
  "99",
  "__",
  "99",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 3, 3,
  "99",
  "__",
  "99",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 3, 3,
  "99",
  "__",
  "99",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 3, 3,
  "99",
  "__",
  "99",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 3, 3,
  "123456",
  "__.__.19__",
  "999999",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 7, 11,
  "123456",
  "__:__:__ Uhr",
  "999999",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 7, 13,
  "123456",
  "__.__.19__",
  "999999",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 7, 11,
  "123456",
  "__:__:__ Uhr",
  "999999",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 7, 13,
  "19200",
  "_____ Baud",
  "99999",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 6, 11,
  " Serielle Schnittstelle ",
  "",
  "",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 25, 1,
  "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
  "_________________________________",
  "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 34, 34,
  "Startparameter",
  "",
  "",
  SMALL, 0, TE_LEFT , 0x1180, 0, -1, 15, 1,
  "C",
  "_:",
  "A",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 2, 3,
  "LAUFWERK:",
  "",
  "",
  SMALL, 0, TE_LEFT , 0x1180, 0, -1, 10, 1,
  "12345678",
  "Zeichen im Spooler: ________",
  "99999999",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 9, 29,
  "50",
  "__%",
  "99",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 3, 4,
  "Anteil der Systemzeit f\201r Spooler",
  "",
  "",
  SMALL, 0, TE_LEFT , 0x1180, 0, -1, 34, 1,
  "999",
  "___ sec",
  "999",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 4, 8,
  "A",
  "_:",
  "X",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 2, 3,
  "5",
  "0._s",
  "9",
  SMALL, 0, TE_CNTR , 0x1180, 0, -1, 2, 5,
  "Schreib-Verz\224gerung",
  "",
  "",
  SMALL, 0, TE_LEFT , 0x1180, 0, -1, 20, 1,
  "physik.   :",
  "",
  "",
  SMALL, 0, TE_LEFT , 0x1180, 0, -1, 12, 1,
  "Sektoren  :    gelesen    geschrieben",
  "",
  "",
  SMALL, 0, TE_LEFT , 0x1180, 0, -1, 38, 1,
  "logisch   :",
  "",
  "",
  SMALL, 0, TE_LEFT , 0x1180, 0, -1, 12, 1,
  "Rate      :",
  "",
  "",
  SMALL, 0, TE_LEFT , 0x1180, 0, -1, 12, 1,
  "1234567",
  "",
  "",
  SMALL, 0, TE_RIGHT, 0x1180, 0, -1, 8, 1,
  "1234567",
  "",
  "",
  SMALL, 0, TE_RIGHT, 0x1180, 0, -1, 8, 1,
  "1234567",
  "",
  "",
  SMALL, 0, TE_RIGHT, 0x1180, 0, -1, 8, 1,
  "1234567",
  "",
  "",
  SMALL, 0, TE_RIGHT, 0x1180, 0, -1, 8, 1,
  "11239",
  "____._%",
  "99999",
  SMALL, 0, TE_RIGHT, 0x1180, 0, -1, 6, 8,
  "11239",
  "____._%",
  "99999",
  SMALL, 0, TE_RIGHT, 0x1180, 0, -1, 6, 8,
  "Reparierte Checksummenfehler :",
  "",
  "",
  SMALL, 0, TE_LEFT , 0x1180, 0, -1, 31, 1,
  "Fatale Fehler                :",
  "",
  "",
  SMALL, 0, TE_LEFT , 0x1180, 0, -1, 31, 1,
  "1234567",
  "",
  "",
  SMALL, 0, TE_RIGHT, 0x1180, 0, -1, 8, 1,
  "1234567",
  "",
  "",
  SMALL, 0, TE_RIGHT, 0x1180, 0, -1, 8, 1,
  "Bl\224cke f\201r Spooler           :",
  "",
  "",
  SMALL, 0, TE_LEFT , 0x1180, 0, -1, 31, 1,
  "Bl\224cke f\201r RAM-Disk          :",
  "",
  "",
  SMALL, 0, TE_LEFT , 0x1180, 0, -1, 31, 1,
  "Bl\224cke f\201r Cache             :",
  "",
  "",
  SMALL, 0, TE_LEFT , 0x1180, 0, -1, 31, 1,
  "Freie Bl\224cke                 :",
  "",
  "",
  SMALL, 0, TE_LEFT , 0x1180, 0, -1, 31, 1,
  "1234567",
  "",
  "",
  SMALL, 0, TE_RIGHT, 0x1180, 0, -1, 8, 1,
  "1234567",
  "",
  "",
  SMALL, 0, TE_RIGHT, 0x1180, 0, -1, 8, 1,
  "1234567",
  "",
  "",
  SMALL, 0, TE_RIGHT, 0x1180, 0, -1, 8, 1,
  "1234567",
  "",
  "",
  SMALL, 0, TE_RIGHT, 0x1180, 0, -1, 8, 1,
  "Zeichen an Drucker gesendet  :",
  "",
  "",
  SMALL, 0, TE_LEFT , 0x1180, 0, -1, 31, 1,
  "1234567",
  "",
  "",
  SMALL, 0, TE_RIGHT, 0x1180, 0, -1, 8, 1,
  "9999",
  "____ KB",
  "9999",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 5, 8,
  "Speichergr\224\236e:",
  "",
  "",
  SMALL, 0, TE_LEFT , 0x1180, 0, -1, 15, 1,
  "Kleinste Blockgr\224\236e:",
  "",
  "",
  SMALL, 0, TE_LEFT , 0x1180, 0, -1, 21, 1,
  "9999",
  "____ B",
  "9999",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 5, 7
};

RSBB0DATA[] =
{ 0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x052A, 0x5000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0214, 0x2000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x052A, 0x5000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0214, 0x2000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x052A, 0x5000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0214, 0x2000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x052A, 0x5000, 0x0000, 0x4000, 
  0x0FFF, 0xFFFE, 0x02FF, 0xA000, 
  0xFF80, 0xC000, 0x0FFF, 0xFFFE, 
  0x07FF, 0xF003, 0xFFFF, 0xC000, 
  0x0E03, 0xF80E, 0x1FFF, 0xFC07, 
  0xC07F, 0xC000, 0x0C03, 0xF806, 
  0x3FAA, 0xFE07, 0x8007, 0xC000, 
  0x0803, 0xF802, 0x7E14, 0x3F07, 
  0x8001, 0xC000, 0x0003, 0xF800, 
  0xFD2A, 0x5F87, 0x8000, 0xC000, 
  0x0003, 0xF801, 0xFA14, 0x2FC7, 
  0xC000, 0x4000, 0x0003, 0xF801, 
  0xFD2A, 0x5FC7, 0xFC00, 0x0000, 
  0x0003, 0xF803, 0xFA14, 0x2FE3, 
  0xFFF0, 0x0000, 0x0003, 0xF803, 
  0xFD2A, 0x5FE1, 0xFFFC, 0x0000, 
  0x0003, 0xF803, 0xFA14, 0x2FE0, 
  0x7FFF, 0x0000, 0x0003, 0xF803, 
  0xFD2A, 0x5FE0, 0x1FFF, 0x8000, 
  0x0003, 0xF801, 0xFA14, 0x2FC0, 
  0x007F, 0xC000, 0x0003, 0xF801, 
  0xFD2A, 0x5FC8, 0x0007, 0xC000, 
  0x0003, 0xF800, 0xFE14, 0x3F8C, 
  0x0003, 0xC000, 0x0003, 0xF800, 
  0x7E2A, 0x3F0E, 0x0003, 0xC000, 
  0x0003, 0xF800, 0x3F94, 0xFE0F, 
  0x8003, 0xC000, 0x0003, 0xF800, 
  0x1FFF, 0xFC0F, 0xF007, 0xC000, 
  0x0007, 0xFC00, 0x07FF, 0xF80F, 
  0xFFFF, 0x8000, 0x001F, 0xFF00, 
  0x05FF, 0xD00C, 0x0FFE, 0x0000, 
  0x0000, 0x0000, 0x0A2A, 0x2808, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x1414, 0x1400, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0A2A, 0x2800, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x1414, 0x1400, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x282A, 0x0A00, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x5414, 0x1500, 0x0000, 0x0000, 
  0x0000, 0x000A, 0xA82A, 0x0AA8, 
  0x0000, 0x0000, 0x0000, 0x0005, 
  0x5014, 0x0550, 0x0000, 0x0000, 
  0x0000, 0x000A, 0xA02A, 0x02A8, 
  0x0000, 0x0000, 0x0000, 0x0005, 
  0x4014, 0x0150, 0x0000, 0x0000, 
  0x0000, 0x0001, 0x0002, 0x0400, 
  0x0000, 0x0000, 0x0000, 0x0001, 
  0x0002, 0x0000, 0x4000, 0x0000, 
  0x1139, 0xE001, 0x0002, 0x0C38, 
  0xE3CE, 0x4400, 0x1145, 0x1001, 
  0x0002, 0x047C, 0x4091, 0x5400, 
  0x0A45, 0x1011, 0x1802, 0x0440, 
  0x4111, 0x5400, 0x0439, 0x100E, 
  0x1803, 0xCE38, 0x23CE, 0x6C00, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000
};

RSBB1DATA[] =
{ 0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0078, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x01C8, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x030C, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0604, 0xFC3F, 0x0FC3, 0xF8FE, 
  0x3F1F, 0xC7F8, 0x04CD, 0x8461, 
  0x1866, 0x0982, 0x6190, 0x64C8, 
  0x0CCB, 0x04C1, 0x302C, 0x0B02, 
  0xC0B0, 0x2CC8, 0x099A, 0x7C9F, 
  0x2669, 0xFA7E, 0x99A6, 0x6998, 
  0x1816, 0x4190, 0x6648, 0xC231, 
  0x9967, 0xD990, 0x1034, 0xC130, 
  0x40C8, 0x6219, 0x334C, 0x1330, 
  0x332C, 0x8320, 0xCF8E, 0x238B, 
  0x32C8, 0x3320, 0x2669, 0xF27C, 
  0x9F3E, 0x6F9A, 0x6698, 0x2060, 
  0x6648, 0x1204, 0x8160, 0x5812, 
  0x0590, 0x3040, 0x4CC8, 0x320C, 
  0x8341, 0xD072, 0x1D30, 0x7CC0, 
  0x7F8F, 0xE3F8, 0xFE7F, 0x1FC3, 
  0xF1E0, 0xC080, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x8380, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0xFE00, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0003, 0xF800, 
  0x0000, 0x01E0, 0x003E, 0x0000, 
  0x000E, 0x0800, 0x0000, 0x0320, 
  0x0062, 0x0000, 0x0008, 0x1800, 
  0x0000, 0x0260, 0x0046, 0x0000, 
  0x0019, 0xF7F0, 0xFC7F, 0x8FC3, 
  0xF064, 0x0000, 0x0013, 0x0419, 
  0x8640, 0x8882, 0x184C, 0x0000, 
  0x0011, 0x0C0B, 0x0240, 0x8882, 
  0x08C8, 0x0000, 0x0011, 0x899A, 
  0x6673, 0x8987, 0x9898, 0x0000, 
  0x0018, 0x9996, 0x6466, 0x191C, 
  0x1190, 0x0000, 0x0008, 0x9334, 
  0x0CCC, 0x1310, 0x3130, 0x0000, 
  0x000C, 0xB32C, 0xF998, 0x3233, 
  0x2320, 0x0000, 0x00F9, 0xA669, 
  0xF33C, 0x6626, 0x6660, 0x0000, 
  0x0181, 0x6048, 0x1604, 0xC220, 
  0x4C20, 0x0000, 0x0107, 0x41C8, 
  0x340C, 0x8620, 0xC860, 0x0000, 
  0x01FC, 0xCF0F, 0xE7F8, 0xFC3F, 
  0x8FC0, 0x0000, 0x0000, 0x9800, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0xF000, 0x0000, 0x0000, 
  0x0000, 0x0000
};

RSBB2DATA[] =
{ 0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x052A, 0x5000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0214, 0x2000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x052A, 0x5000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0214, 0x2000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x052A, 0x5000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0214, 0x2000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x052A, 0x5000, 0x0000, 0x4000, 
  0x0FFF, 0xFFFE, 0x02FF, 0xA000, 
  0xFF80, 0xC000, 0x0FFF, 0xFFFE, 
  0x07FF, 0xF003, 0xFFFF, 0xC000, 
  0x0E03, 0xF80E, 0x1FFF, 0xFC07, 
  0xC07F, 0xC000, 0x0C03, 0xF806, 
  0x3FAA, 0xFE07, 0x8007, 0xC000, 
  0x0803, 0xF802, 0x7E14, 0x3F07, 
  0x8001, 0xC000, 0x0003, 0xF800, 
  0xFD2A, 0x5F87, 0x8000, 0xC000, 
  0x0003, 0xF801, 0xFA14, 0x2FC7, 
  0xC000, 0x4000, 0x0003, 0xF801, 
  0xFD2A, 0x5FC7, 0xFC00, 0x0000, 
  0x0003, 0xF803, 0xFA14, 0x2FE3, 
  0xFFF0, 0x0000, 0x0003, 0xF803, 
  0xFD2A, 0x5FE1, 0xFFFC, 0x0000, 
  0x0003, 0xF803, 0xFA14, 0x2FE0, 
  0x7FFF, 0x0000, 0x0003, 0xF803, 
  0xFD2A, 0x5FE0, 0x1FFF, 0x8000, 
  0x0003, 0xF801, 0xFA14, 0x2FC0, 
  0x007F, 0xC000, 0x0003, 0xF801, 
  0xFD2A, 0x5FC8, 0x0007, 0xC000, 
  0x0003, 0xF800, 0xFE14, 0x3F8C, 
  0x0003, 0xC000, 0x0003, 0xF800, 
  0x7E2A, 0x3F0E, 0x0003, 0xC000, 
  0x0003, 0xF800, 0x3F94, 0xFE0F, 
  0x8003, 0xC000, 0x0003, 0xF800, 
  0x1FFF, 0xFC0F, 0xF007, 0xC000, 
  0x0007, 0xFC00, 0x07FF, 0xF80F, 
  0xFFFF, 0x8000, 0x001F, 0xFF00, 
  0x05FF, 0xD00C, 0x0FFE, 0x0000, 
  0x0000, 0x0000, 0x0A2A, 0x2808, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x1414, 0x1400, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0A2A, 0x2800, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x1414, 0x1400, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x282A, 0x0A00, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x5414, 0x1500, 0x0000, 0x0000, 
  0x0000, 0x000A, 0xA82A, 0x0AA8, 
  0x0000, 0x0000, 0x0000, 0x0005, 
  0x5014, 0x0550, 0x0000, 0x0000, 
  0x0000, 0x000A, 0xA02A, 0x02A8, 
  0x0000, 0x0000, 0x0000, 0x0005, 
  0x4014, 0x0150, 0x0000, 0x0000, 
  0x0000, 0x0001, 0x0002, 0x0400, 
  0x0000, 0x0000, 0x0000, 0x0001, 
  0x0002, 0x0000, 0x4000, 0x0000, 
  0x1139, 0xE001, 0x0002, 0x0C38, 
  0xE3CE, 0x4400, 0x1145, 0x1001, 
  0x0002, 0x047C, 0x4091, 0x5400, 
  0x0A45, 0x1011, 0x1802, 0x0440, 
  0x4111, 0x5400, 0x0439, 0x100E, 
  0x1803, 0xCE38, 0x23CE, 0x6C00, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000
};

BITBLK rs_bitblk[] =
{ RSBB0DATA,  12,  53,   0,   0, 0x0001,
  RSBB1DATA,  12,  39,   0,   0, 0x0001,
  RSBB2DATA,  12,  53,   0,   0, 0x0001
};

OBJECT rs_object[] =
{ 
  /******** Tree 0 TOSACC ****************************************************/
        -1, TOOLS   , ICACC   , G_BOX     ,   /* Object 0  */
  NONE, OUTLINED, (LONG)0x00001100L,
  0x0000, 0x0000, 0x0025, 0x0014,
  SAVE    ,       -1,       -1, G_IBOX    ,   /* Object 1 TOOLS */
  NONE, NORMAL, (LONG)0x00001100L,
  0x0000, 0x0004, 0x0025, 0x0010,
  ICTOS   ,       -1,       -1, G_BUTTON  ,   /* Object 2 SAVE */
  SELECTABLE|EXIT, NORMAL, (LONG)"Sichern",
  0x001A, 0x0002, 0x0009, 0x0001,
  ICACC   ,       -1,       -1, G_IMAGE   ,   /* Object 3 ICTOS */
  NONE, NORMAL, (LONG)&rs_bitblk[0],
  0x0001, 0x0000, 0x000C, 0x0503,
         0,       -1,       -1, G_IMAGE   ,   /* Object 4 ICACC */
  LASTOB, NORMAL, (LONG)&rs_bitblk[1],
  0x000D, 0x0001, 0x000C, 0x0702,
  
  /******** Tree 1 XDIAL ****************************************************/
        -1,        1,        6, G_BOX     ,   /* Object 0  */
  NONE, OUTLINED, (LONG)0x00021100L,
  0x0000, 0x0000, 0x0025, 0x0010,
         6, XDON    , XSHGRON , G_BUTTON  ,   /* Object 1  */
  NONE, NORMAL, (LONG)"{ GEM-Funktionen ",
  0x0002, 0x0001, 0x0021, 0x0007,
  XEDON   ,       -1,       -1, G_BUTTON  ,   /* Object 2 XDON */
  SELECTABLE|EXIT|TOUCHEXIT, NORMAL, (LONG)"] form_[do()",
  0x0001, 0x0002, 0x000C, 0x0001,
  XDRAWON ,       -1,       -1, G_BUTTON  ,   /* Object 3 XEDON */
  SELECTABLE|EXIT|TOUCHEXIT, NORMAL, (LONG)"] objc_[edit()",
  0x0001, 0x0003, 0x000E, 0x0001,
  XSHGRON ,       -1,       -1, G_BUTTON  ,   /* Object 4 XDRAWON */
  SELECTABLE|EXIT|TOUCHEXIT, NORMAL, (LONG)"] objc_[draw()",
  0x0001, 0x0004, 0x000E, 0x0001,
         1,       -1,       -1, G_BUTTON  ,   /* Object 5 XSHGRON */
  SELECTABLE|EXIT|TOUCHEXIT, NORMAL, (LONG)"] [Grow/Shrink-Boxen",
  0x0001, 0x0005, 0x0014, 0x0001,
         0, ALDEFPOS, ALON    , G_BUTTON  ,   /* Object 6  */
  NONE, NORMAL, (LONG)"{ Erweiterte Alerts ",
  0x0002, 0x0009, 0x0021, 0x0006,
  ALERTDEL,       -1,       -1, G_BUTTON  ,   /* Object 7 ALDEFPOS */
  SELECTABLE|EXIT|TOUCHEXIT, NORMAL, (LONG)"] Default-Button [Position",
  0x0001, 0x0005, 0x001A, 0x0001,
  ALON    ,       -1,       -1, G_BUTTON  ,   /* Object 8 ALERTDEL */
  SELECTABLE|EXIT, NORMAL, (LONG)"[L\224sche Alerts",
  0x0009, 0x0002, 0x0010, 0x0001,
         6,       -1,       -1, G_BUTTON  ,   /* Object 9 ALON */
  SELECTABLE|EXIT|LASTOB|TOUCHEXIT, NORMAL, (LONG)"] form_[alert()",
  0x0001, 0x0004, 0x000F, 0x0001,
  
  /******** Tree 2 KEYBOARD ****************************************************/
        -1,        1,       14, G_BOX     ,   /* Object 0  */
  NONE, OUTLINED, (LONG)0x00021100L,
  0x0000, 0x0000, 0x0025, 0x0010,
        14, RPSLIDER,       13, G_BUTTON  ,   /* Object 1  */
  NONE, NORMAL, (LONG)"{ Tastatur ",
  0x0002, 0x0002, 0x0021, 0x0008,
  KBSLIDER,        3,        6, G_IBOX    ,   /* Object 2 RPSLIDER */
  NONE, NORMAL, (LONG)0x00001100L,
  0x0002, 0x0003, 0x0016, 0x0001,
         4,       -1,       -1, G_BOXCHAR ,   /* Object 3  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)0x04FF1100L,
  0x0000, 0x0000, 0x0002, 0x0001,
         6,        5,        5, G_BOX     ,   /* Object 4  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)0x00FF1111L,
  0x0002, 0x0000, 0x0012, 0x0001,
         4,       -1,       -1, G_FBOXTEXT,   /* Object 5  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)&rs_tedinfo[0],
  0x0002, 0x0000, 0x0007, 0x0001,
  RPSLIDER,       -1,       -1, G_BOXCHAR ,   /* Object 6  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)0x03FF1100L,
  0x0014, 0x0000, 0x0002, 0x0001,
        12,        8,       11, G_IBOX    ,   /* Object 7 KBSLIDER */
  NONE, NORMAL, (LONG)0x00001100L,
  0x0002, 0x0006, 0x0016, 0x0001,
         9,       -1,       -1, G_BOXCHAR ,   /* Object 8  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)0x04FF1100L,
  0x0000, 0x0000, 0x0002, 0x0001,
        11,       10,       10, G_BOX     ,   /* Object 9  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)0x00FF1111L,
  0x0002, 0x0000, 0x0012, 0x0001,
         9,       -1,       -1, G_FBOXTEXT,   /* Object 10  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)&rs_tedinfo[1],
  0x0002, 0x0000, 0x0007, 0x0001,
  KBSLIDER,       -1,       -1, G_BOXCHAR ,   /* Object 11  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)0x03FF1100L,
  0x0014, 0x0000, 0x0002, 0x0001,
        13,       -1,       -1, G_STRING  ,   /* Object 12  */
  NONE, NORMAL, (LONG)"Wiederholung:",
  0x0002, 0x0001, 0x000D, 0x0002,
         1,       -1,       -1, G_STRING  ,   /* Object 13  */
  NONE, NORMAL, (LONG)"Ansprechzeit:",
  0x0002, 0x0004, 0x000D, 0x0002,
         0, DKSLIDER, DKTEST  , G_BUTTON  ,   /* Object 14  */
  NONE, NORMAL, (LONG)"{ Maus ",
  0x0002, 0x000B, 0x0021, 0x0004,
  DKTEST  ,       16,       19, G_IBOX    ,   /* Object 15 DKSLIDER */
  NONE, NORMAL, (LONG)0x00001100L,
  0x0010, 0x0002, 0x000F, 0x0001,
        17,       -1,       -1, G_BOXCHAR ,   /* Object 16  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)0x04FF1100L,
  0x0000, 0x0000, 0x0002, 0x0001,
        19,       18,       18, G_BOX     ,   /* Object 17  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)0x00FF1111L,
  0x0002, 0x0000, 0x000B, 0x0001,
        17,       -1,       -1, G_FBOXTEXT,   /* Object 18  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)&rs_tedinfo[2],
  0x0002, 0x0000, 0x0006, 0x0001,
  DKSLIDER,       -1,       -1, G_BOXCHAR ,   /* Object 19  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)0x03FF1100L,
  0x000D, 0x0000, 0x0002, 0x0001,
        14,       -1,       -1, G_BUTTON  ,   /* Object 20 DKTEST */
  EXIT|LASTOB|TOUCHEXIT, NORMAL, (LONG)"Doppelklick",
  0x0002, 0x0002, 0x000C, 0x0001,
  
  /******** Tree 3 SETMOUSE ****************************************************/
        -1,        1, SMSLIDER, G_BOX     ,   /* Object 0  */
  NONE, OUTLINED, (LONG)0x00021100L,
  0x0000, 0x0000, 0x0025, 0x0010,
  SMON    ,       -1,       -1, G_TEXT    ,   /* Object 1  */
  NONE, NORMAL, (LONG)&rs_tedinfo[3],
  0x0002, 0x0001, 0x000A, 0x0001,
  SMDIREC ,       -1,       -1, G_BUTTON  ,   /* Object 2 SMON */
  SELECTABLE|EXIT|RBUTTON, NORMAL, (LONG)"] [an",
  0x000E, 0x0001, 0x0005, 0x0001,
         4,       -1,       -1, G_BUTTON  ,   /* Object 3 SMDIREC */
  SELECTABLE|EXIT|TOUCHEXIT, NORMAL, (LONG)"] [bevorzuge Richtung",
  0x000E, 0x0002, 0x0015, 0x0002,
  SMOFF   ,       -1,       -1, G_TEXT    ,   /* Object 4  */
  NONE, NORMAL, (LONG)&rs_tedinfo[4],
  0x0002, 0x0002, 0x0004, 0x0001,
         6,       -1,       -1, G_BUTTON  ,   /* Object 5 SMOFF */
  SELECTABLE|EXIT|RBUTTON, NORMAL, (LONG)"] a[us",
  0x0016, 0x0001, 0x0006, 0x0001,
         7,       -1,       -1, G_STRING  ,   /* Object 6  */
  NONE, NORMAL, (LONG)"\177y",
  0x0004, 0x0006, 0x0002, 0x0001,
  SMSLIDER,       -1,       -1, G_STRING  ,   /* Object 7  */
  NONE, NORMAL, (LONG)"\177x",
  0x001F, 0x0006, 0x0002, 0x0001,
         0,        9,       64, G_IBOX    ,   /* Object 8 SMSLIDER */
  NONE, NORMAL, (LONG)0x00001101L,
  0x0002, 0x0004, 0x0021, 0x000B,
        14,       10,       13, G_IBOX    ,   /* Object 9  */
  NONE, NORMAL, (LONG)0x00001100L,
  0x0007, 0x0000, 0x0009, 0x0001,
        11,       -1,       -1, G_BOXCHAR ,   /* Object 10  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)0x04FF1100L,
  0x0000, 0x0000, 0x0002, 0x0001,
        13,       12,       12, G_BOX     ,   /* Object 11  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)0x00FF1111L,
  0x0002, 0x0000, 0x0005, 0x0001,
        11,       -1,       -1, G_FBOXTEXT,   /* Object 12  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)&rs_tedinfo[5],
  0x0001, 0x0000, 0x0003, 0x0001,
         9,       -1,       -1, G_BOXCHAR ,   /* Object 13  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)0x03FF1100L,
  0x0007, 0x0000, 0x0002, 0x0001,
        19,       15,       18, G_IBOX    ,   /* Object 14  */
  NONE, NORMAL, (LONG)0x00001100L,
  0x0011, 0x0000, 0x0009, 0x0001,
        16,       -1,       -1, G_BOXCHAR ,   /* Object 15  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)0x04FF1100L,
  0x0000, 0x0000, 0x0002, 0x0001,
        18,       17,       17, G_BOX     ,   /* Object 16  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)0x00FF1111L,
  0x0002, 0x0000, 0x0005, 0x0001,
        16,       -1,       -1, G_FBOXTEXT,   /* Object 17  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)&rs_tedinfo[6],
  0x0001, 0x0000, 0x0003, 0x0001,
        14,       -1,       -1, G_BOXCHAR ,   /* Object 18  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)0x03FF1100L,
  0x0007, 0x0000, 0x0002, 0x0001,
        24,       20,       23, G_IBOX    ,   /* Object 19  */
  NONE, NORMAL, (LONG)0x00001100L,
  0x0006, 0x0002, 0x000A, 0x0001,
        21,       -1,       -1, G_BOXCHAR ,   /* Object 20  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)0x04FF1100L,
  0x0000, 0x0000, 0x0002, 0x0001,
        23,       22,       22, G_BOX     ,   /* Object 21  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)0x00FF1111L,
  0x0002, 0x0000, 0x0006, 0x0001,
        21,       -1,       -1, G_FBOXTEXT,   /* Object 22  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)&rs_tedinfo[7],
  0x0001, 0x0000, 0x0003, 0x0001,
        19,       -1,       -1, G_BOXCHAR ,   /* Object 23  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)0x03FF1100L,
  0x0008, 0x0000, 0x0002, 0x0001,
        29,       25,       28, G_IBOX    ,   /* Object 24  */
  NONE, NORMAL, (LONG)0x00001100L,
  0x0011, 0x0002, 0x000A, 0x0001,
        26,       -1,       -1, G_BOXCHAR ,   /* Object 25  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)0x04FF1100L,
  0x0000, 0x0000, 0x0002, 0x0001,
        28,       27,       27, G_BOX     ,   /* Object 26  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)0x00FF1111L,
  0x0002, 0x0000, 0x0006, 0x0001,
        26,       -1,       -1, G_FBOXTEXT,   /* Object 27  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)&rs_tedinfo[8],
  0x0002, 0x0000, 0x0003, 0x0001,
        24,       -1,       -1, G_BOXCHAR ,   /* Object 28  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)0x03FF1100L,
  0x0008, 0x0000, 0x0002, 0x0001,
        34,       30,       33, G_IBOX    ,   /* Object 29  */
  NONE, NORMAL, (LONG)0x00001100L,
  0x0005, 0x0004, 0x000B, 0x0001,
        31,       -1,       -1, G_BOXCHAR ,   /* Object 30  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)0x04FF1100L,
  0x0000, 0x0000, 0x0002, 0x0001,
        33,       32,       32, G_BOX     ,   /* Object 31  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)0x00FF1111L,
  0x0002, 0x0000, 0x0007, 0x0001,
        31,       -1,       -1, G_FBOXTEXT,   /* Object 32  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)&rs_tedinfo[9],
  0x0001, 0x0000, 0x0003, 0x0001,
        29,       -1,       -1, G_BOXCHAR ,   /* Object 33  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)0x03FF1100L,
  0x0009, 0x0000, 0x0002, 0x0001,
        39,       35,       38, G_IBOX    ,   /* Object 34  */
  NONE, NORMAL, (LONG)0x00001100L,
  0x0011, 0x0004, 0x000B, 0x0001,
        36,       -1,       -1, G_BOXCHAR ,   /* Object 35  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)0x04FF1100L,
  0x0000, 0x0000, 0x0002, 0x0001,
        38,       37,       37, G_BOX     ,   /* Object 36  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)0x00FF1111L,
  0x0002, 0x0000, 0x0007, 0x0001,
        36,       -1,       -1, G_FBOXTEXT,   /* Object 37  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)&rs_tedinfo[10],
  0x0003, 0x0000, 0x0003, 0x0001,
        34,       -1,       -1, G_BOXCHAR ,   /* Object 38  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)0x03FF1100L,
  0x0009, 0x0000, 0x0002, 0x0001,
        44,       40,       43, G_IBOX    ,   /* Object 39  */
  NONE, NORMAL, (LONG)0x00001100L,
  0x0003, 0x0006, 0x000D, 0x0001,
        41,       -1,       -1, G_BOXCHAR ,   /* Object 40  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)0x04FF1100L,
  0x0000, 0x0000, 0x0002, 0x0001,
        43,       42,       42, G_BOX     ,   /* Object 41  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)0x00FF1111L,
  0x0002, 0x0000, 0x0009, 0x0001,
        41,       -1,       -1, G_FBOXTEXT,   /* Object 42  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)&rs_tedinfo[11],
  0x0001, 0x0000, 0x0003, 0x0001,
        39,       -1,       -1, G_BOXCHAR ,   /* Object 43  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)0x03FF1100L,
  0x000B, 0x0000, 0x0002, 0x0001,
        49,       45,       48, G_IBOX    ,   /* Object 44  */
  NONE, NORMAL, (LONG)0x00001100L,
  0x0011, 0x0006, 0x000D, 0x0001,
        46,       -1,       -1, G_BOXCHAR ,   /* Object 45  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)0x04FF1100L,
  0x0000, 0x0000, 0x0002, 0x0001,
        48,       47,       47, G_BOX     ,   /* Object 46  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)0x00FF1111L,
  0x0002, 0x0000, 0x0009, 0x0001,
        46,       -1,       -1, G_FBOXTEXT,   /* Object 47  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)&rs_tedinfo[12],
  0x0005, 0x0000, 0x0003, 0x0001,
        44,       -1,       -1, G_BOXCHAR ,   /* Object 48  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)0x03FF1100L,
  0x000B, 0x0000, 0x0002, 0x0001,
        54,       50,       53, G_IBOX    ,   /* Object 49  */
  NONE, NORMAL, (LONG)0x00001100L,
  0x0001, 0x0008, 0x000F, 0x0001,
        51,       -1,       -1, G_BOXCHAR ,   /* Object 50  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)0x04FF1100L,
  0x0000, 0x0000, 0x0002, 0x0001,
        53,       52,       52, G_BOX     ,   /* Object 51  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)0x00FF1111L,
  0x0002, 0x0000, 0x000B, 0x0001,
        51,       -1,       -1, G_FBOXTEXT,   /* Object 52  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)&rs_tedinfo[13],
  0x0001, 0x0000, 0x0003, 0x0001,
        49,       -1,       -1, G_BOXCHAR ,   /* Object 53  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)0x03FF1100L,
  0x000D, 0x0000, 0x0002, 0x0001,
        59,       55,       58, G_IBOX    ,   /* Object 54  */
  NONE, NORMAL, (LONG)0x00001100L,
  0x0011, 0x0008, 0x000F, 0x0001,
        56,       -1,       -1, G_BOXCHAR ,   /* Object 55  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)0x04FF1100L,
  0x0000, 0x0000, 0x0002, 0x0001,
        58,       57,       57, G_BOX     ,   /* Object 56  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)0x00FF1111L,
  0x0002, 0x0000, 0x000B, 0x0001,
        56,       -1,       -1, G_FBOXTEXT,   /* Object 57  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)&rs_tedinfo[14],
  0x0007, 0x0000, 0x0003, 0x0001,
        54,       -1,       -1, G_BOXCHAR ,   /* Object 58  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)0x03FF1100L,
  0x000D, 0x0000, 0x0002, 0x0001,
        64,       60,       63, G_IBOX    ,   /* Object 59  */
  NONE, NORMAL, (LONG)0x00001100L,
  0x0000, 0x000A, 0x0010, 0x0001,
        61,       -1,       -1, G_BOXCHAR ,   /* Object 60  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)0x04FF1100L,
  0x0000, 0x0000, 0x0002, 0x0001,
        63,       62,       62, G_BOX     ,   /* Object 61  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)0x00FF1111L,
  0x0002, 0x0000, 0x000C, 0x0001,
        61,       -1,       -1, G_FBOXTEXT,   /* Object 62  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)&rs_tedinfo[15],
  0x0001, 0x0000, 0x0003, 0x0001,
        59,       -1,       -1, G_BOXCHAR ,   /* Object 63  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)0x03FF1100L,
  0x000E, 0x0000, 0x0002, 0x0001,
  SMSLIDER,       65,       68, G_IBOX    ,   /* Object 64  */
  NONE, NORMAL, (LONG)0x00001100L,
  0x0011, 0x000A, 0x0010, 0x0001,
        66,       -1,       -1, G_BOXCHAR ,   /* Object 65  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)0x04FF1100L,
  0x0000, 0x0000, 0x0002, 0x0001,
        68,       67,       67, G_BOX     ,   /* Object 66  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)0x00FF1111L,
  0x0002, 0x0000, 0x000C, 0x0001,
        66,       -1,       -1, G_FBOXTEXT,   /* Object 67  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)&rs_tedinfo[16],
  0x0008, 0x0000, 0x0003, 0x0001,
        64,       -1,       -1, G_BOXCHAR ,   /* Object 68  */
  EXIT|LASTOB|TOUCHEXIT, NORMAL, (LONG)0x03FF1100L,
  0x000E, 0x0000, 0x0002, 0x0001,
  
  /******** Tree 4 MESSAGE ****************************************************/
        -1,        1,       11, G_BOX     ,   /* Object 0  */
  NONE, OUTLINED, (LONG)0x00021101L,
  0x0000, 0x0000, 0x0025, 0x0010,
         2,       -1,       -1, G_IMAGE   ,   /* Object 1  */
  NONE, NORMAL, (LONG)&rs_bitblk[2],
  0x0018, 0x0006, 0x000C, 0x0503,
         3,       -1,       -1, G_STRING  ,   /* Object 2  */
  NONE, NORMAL, (LONG)"TOS MAGAZIN PLUS SOFTWARE !",
  0x0002, 0x0002, 0x001B, 0x0001,
         4,       -1,       -1, G_STRING  ,   /* Object 3  */
  NONE, NORMAL, (LONG)"ICP-Innovativ Computer-Presse",
  0x0002, 0x0005, 0x001D, 0x0001,
         5,       -1,       -1, G_STRING  ,   /* Object 4  */
  NONE, NORMAL, (LONG)"Verlag GmbH & Co. KG",
  0x0002, 0x0006, 0x0014, 0x0001,
         6,       -1,       -1, G_STRING  ,   /* Object 5  */
  NONE, NORMAL, (LONG)"Wendelsteinstra\236e 3",
  0x0002, 0x0008, 0x0013, 0x0001,
         7,       -1,       -1, G_STRING  ,   /* Object 6  */
  NONE, NORMAL, (LONG)"8011 Vaterstetten",
  0x0002, 0x0009, 0x0011, 0x0001,
         8,       -1,       -1, G_STRING  ,   /* Object 7  */
  NONE, NORMAL, (LONG)"Telefon (08106) 3 39 54",
  0x0002, 0x000A, 0x0017, 0x0001,
         9,       -1,       -1, G_STRING  ,   /* Object 8  */
  NONE, NORMAL, (LONG)"Projekt mit Quelltext: J. Lietzow",
  0x0002, 0x000C, 0x0021, 0x0001,
        10,       -1,       -1, G_STRING  ,   /* Object 9  */
  NONE, NORMAL, (LONG)"Ausgaben: 12/91, 1/92, 2/92, 3/92",
  0x0002, 0x000D, 0x0021, 0x0002,
        11,       -1,       -1, G_STRING  ,   /* Object 10  */
  NONE, NORMAL, (LONG)"===========================",
  0x0002, 0x0003, 0x001C, 0x0001,
         0,       -1,       -1, G_STRING  ,   /* Object 11  */
  LASTOB, NORMAL, (LONG)"4/92, 6/92",
  0x000C, 0x000E, 0x000A, 0x0002,
  
  /******** Tree 5 SETTIME ****************************************************/
        -1,        1,        6, G_BOX     ,   /* Object 0  */
  NONE, OUTLINED, (LONG)0x00021100L,
  0x0000, 0x0000, 0x0025, 0x0010,
         6, CDATE   ,        5, G_BUTTON  ,   /* Object 1  */
  NONE, NORMAL, (LONG)"{ Uhrzeit ",
  0x0002, 0x0001, 0x0021, 0x0006,
  CTIME   ,       -1,       -1, G_FTEXT   ,   /* Object 2 CDATE */
  EXIT|TOUCHEXIT, NORMAL, (LONG)&rs_tedinfo[17],
  0x000C, 0x0001, 0x000A, 0x0002,
         4,       -1,       -1, G_FTEXT   ,   /* Object 3 CTIME */
  EXIT|TOUCHEXIT, NORMAL, (LONG)&rs_tedinfo[18],
  0x000C, 0x0003, 0x000C, 0x0001,
         5,       -1,       -1, G_STRING  ,   /* Object 4  */
  NONE, NORMAL, (LONG)"Datum :",
  0x0003, 0x0001, 0x0007, 0x0002,
         1,       -1,       -1, G_STRING  ,   /* Object 5  */
  NONE, NORMAL, (LONG)"Zeit  :",
  0x0003, 0x0003, 0x0007, 0x0001,
         0, TIMEON  ,       11, G_BUTTON  ,   /* Object 6  */
  NONE, NORMAL, (LONG)"{ Wecker ",
  0x0002, 0x0008, 0x0021, 0x0007,
  TDATE   ,       -1,       -1, G_BUTTON  ,   /* Object 7 TIMEON */
  SELECTABLE|EXIT|TOUCHEXIT, NORMAL, (LONG)"[Ein",
  0x000B, 0x0005, 0x0007, 0x0001,
  TTIME   ,       -1,       -1, G_FTEXT   ,   /* Object 8 TDATE */
  EXIT|TOUCHEXIT, NORMAL, (LONG)&rs_tedinfo[19],
  0x000C, 0x0001, 0x000A, 0x0002,
        10,       -1,       -1, G_FTEXT   ,   /* Object 9 TTIME */
  EXIT|TOUCHEXIT, NORMAL, (LONG)&rs_tedinfo[20],
  0x000C, 0x0003, 0x000C, 0x0001,
        11,       -1,       -1, G_STRING  ,   /* Object 10  */
  NONE, NORMAL, (LONG)"Datum :",
  0x0003, 0x0001, 0x0007, 0x0002,
         6,       -1,       -1, G_STRING  ,   /* Object 11  */
  LASTOB, NORMAL, (LONG)"Zeit  :",
  0x0003, 0x0003, 0x0007, 0x0001,
  
  /******** Tree 6 RS232 ****************************************************/
        -1,        1,       24, G_BOX     ,   /* Object 0  */
  NONE, OUTLINED, (LONG)0x00011100L,
  0x0000, 0x0000, 0x0025, 0x0010,
        24, SLBAUD  ,       19, G_BOX     ,   /* Object 1  */
  NONE, NORMAL, (LONG)0x00011100L,
  0x0000, 0x0001, 0x0025, 0x000F,
         7,        3,        6, G_IBOX    ,   /* Object 2 SLBAUD */
  NONE, NORMAL, (LONG)0x00001100L,
  0x0005, 0x0001, 0x001B, 0x0001,
         4,       -1,       -1, G_BOXCHAR ,   /* Object 3  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)0x04FF1100L,
  0x0000, 0x0000, 0x0002, 0x0001,
         6,        5,        5, G_BOX     ,   /* Object 4  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)0x00FF1111L,
  0x0002, 0x0000, 0x0017, 0x0001,
         4,       -1,       -1, G_FBOXTEXT,   /* Object 5  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)&rs_tedinfo[21],
  0x0001, 0x0000, 0x000C, 0x0001,
  SLBAUD  ,       -1,       -1, G_BOXCHAR ,   /* Object 6  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)0x03FF1100L,
  0x0019, 0x0000, 0x0002, 0x0001,
        10, SHAKEXON, SHAKERTS, G_BUTTON  ,   /* Object 7  */
  NONE, NORMAL, (LONG)"} Kom. Parameter ",
  0x0002, 0x0003, 0x0021, 0x0002,
  SHAKERTS,       -1,       -1, G_BUTTON  ,   /* Object 8 SHAKEXON */
  SELECTABLE|EXIT|TOUCHEXIT, NORMAL, (LONG)"] [Xon/Xoff",
  0x0001, 0x0001, 0x000B, 0x0001,
         7,       -1,       -1, G_BUTTON  ,   /* Object 9 SHAKERTS */
  SELECTABLE|EXIT|TOUCHEXIT, NORMAL, (LONG)"] [Rts/Cts",
  0x0015, 0x0001, 0x000A, 0x0001,
        14, PARINO  , PARIEVEN, G_BUTTON  ,   /* Object 10  */
  NONE, NORMAL, (LONG)"} Parit\204t ",
  0x0002, 0x0006, 0x0021, 0x0002,
  PARIODD ,       -1,       -1, G_BUTTON  ,   /* Object 11 PARINO */
  SELECTABLE|EXIT|RBUTTON, NORMAL, (LONG)"] [Keine",
  0x0001, 0x0001, 0x0008, 0x0001,
  PARIEVEN,       -1,       -1, G_BUTTON  ,   /* Object 12 PARIODD */
  SELECTABLE|EXIT|RBUTTON, NORMAL, (LONG)"] [Ungerade",
  0x0015, 0x0001, 0x000B, 0x0001,
        10,       -1,       -1, G_BUTTON  ,   /* Object 13 PARIEVEN */
  SELECTABLE|EXIT|RBUTTON, NORMAL, (LONG)"] [Gerade",
  0x000B, 0x0001, 0x0009, 0x0001,
        19, SGN8    , SGN5    , G_BUTTON  ,   /* Object 14  */
  NONE, NORMAL, (LONG)"} Bits/Zeichen ",
  0x0002, 0x0009, 0x0021, 0x0002,
  SGN6    ,       -1,       -1, G_BUTTON  ,   /* Object 15 SGN8 */
  SELECTABLE|EXIT|RBUTTON, NORMAL, (LONG)"] [8",
  0x0001, 0x0001, 0x0004, 0x0001,
  SGN7    ,       -1,       -1, G_BUTTON  ,   /* Object 16 SGN6 */
  SELECTABLE|EXIT|RBUTTON, NORMAL, (LONG)"] [6",
  0x0012, 0x0001, 0x0004, 0x0001,
  SGN5    ,       -1,       -1, G_BUTTON  ,   /* Object 17 SGN7 */
  SELECTABLE|EXIT|RBUTTON, NORMAL, (LONG)"] [7",
  0x0009, 0x0001, 0x0004, 0x0001,
        14,       -1,       -1, G_BUTTON  ,   /* Object 18 SGN5 */
  SELECTABLE|EXIT|RBUTTON, NORMAL, (LONG)"] [5",
  0x001A, 0x0001, 0x0004, 0x0001,
         1, STOP00  , STOP20  , G_BUTTON  ,   /* Object 19  */
  NONE, NORMAL, (LONG)"} Stop-Bits ",
  0x0002, 0x000C, 0x0021, 0x0002,
  STOP15  ,       -1,       -1, G_BUTTON  ,   /* Object 20 STOP00 */
  SELECTABLE|EXIT|RBUTTON, DISABLED, (LONG)"] [0",
  0x0001, 0x0001, 0x0004, 0x0001,
  STOP10  ,       -1,       -1, G_BUTTON  ,   /* Object 21 STOP15 */
  SELECTABLE|EXIT|RBUTTON, NORMAL, (LONG)"] 1[.5",
  0x0009, 0x0001, 0x0006, 0x0001,
  STOP20  ,       -1,       -1, G_BUTTON  ,   /* Object 22 STOP10 */
  SELECTABLE|EXIT|RBUTTON, NORMAL, (LONG)"] [1",
  0x0012, 0x0001, 0x0004, 0x0001,
        19,       -1,       -1, G_BUTTON  ,   /* Object 23 STOP20 */
  SELECTABLE|EXIT|RBUTTON, NORMAL, (LONG)"] [2",
  0x001A, 0x0001, 0x0004, 0x0001,
         0,       -1,       -1, G_TEXT    ,   /* Object 24  */
  LASTOB, NORMAL, (LONG)&rs_tedinfo[22],
  0x0004, 0x0000, 0x0018, 0x0002,
  
  /******** Tree 7 CETRONIC ****************************************************/
        -1,        1,        1, G_BOX     ,   /* Object 0  */
  NONE, OUTLINED, (LONG)0x00021100L,
  0x0000, 0x0000, 0x0025, 0x0010,
         0,        2,       17, G_BUTTON  ,   /* Object 1  */
  NONE, NORMAL, (LONG)"{ Drucker ",
  0x0002, 0x0001, 0x0021, 0x000E,
         5, PRUNLIM , PRSINGL , G_BUTTON  ,   /* Object 2  */
  NONE, NORMAL, (LONG)"} Papier ",
  0x0014, 0x0006, 0x000B, 0x0003,
  PRSINGL ,       -1,       -1, G_BUTTON  ,   /* Object 3 PRUNLIM */
  SELECTABLE|EXIT|RBUTTON, NORMAL, (LONG)"] Endl[os",
  0x0001, 0x0001, 0x0009, 0x0001,
         2,       -1,       -1, G_BUTTON  ,   /* Object 4 PRSINGL */
  SELECTABLE|EXIT|RBUTTON, NORMAL, (LONG)"] Ein[zel",
  0x0001, 0x0002, 0x0009, 0x0001,
         8, PRATARI , PREPSON , G_BUTTON  ,   /* Object 5  */
  NONE, NORMAL, (LONG)"} Emulation ",
  0x0002, 0x0006, 0x0010, 0x0003,
  PREPSON ,       -1,       -1, G_BUTTON  ,   /* Object 6 PRATARI */
  SELECTABLE|EXIT|RBUTTON, NORMAL, (LONG)"] [ATARI",
  0x0001, 0x0001, 0x0008, 0x0001,
         5,       -1,       -1, G_BUTTON  ,   /* Object 7 PREPSON */
  SELECTABLE|EXIT|RBUTTON, NORMAL, (LONG)"] [EPSON",
  0x0001, 0x0002, 0x0008, 0x0001,
        11, PRSER   , PRCETRON, G_BUTTON  ,   /* Object 8  */
  NONE, NORMAL, (LONG)"} Schnittstelle ",
  0x0002, 0x0002, 0x0010, 0x0003,
  PRCETRON,       -1,       -1, G_BUTTON  ,   /* Object 9 PRSER */
  SELECTABLE|EXIT|RBUTTON, NORMAL, (LONG)"] [RS-232",
  0x0001, 0x0001, 0x0009, 0x0001,
         8,       -1,       -1, G_BUTTON  ,   /* Object 10 PRCETRON */
  SELECTABLE|EXIT|RBUTTON, NORMAL, (LONG)"] [Cetronics",
  0x0001, 0x0002, 0x000C, 0x0001,
        14, PRMONO  , PRCOLOR , G_BUTTON  ,   /* Object 11  */
  NONE, NORMAL, (LONG)"} Farbe ",
  0x0014, 0x0002, 0x000B, 0x0003,
  PRCOLOR ,       -1,       -1, G_BUTTON  ,   /* Object 12 PRMONO */
  SELECTABLE|EXIT|RBUTTON, NORMAL, (LONG)"] [S/W",
  0x0001, 0x0001, 0x0006, 0x0001,
        11,       -1,       -1, G_BUTTON  ,   /* Object 13 PRCOLOR */
  SELECTABLE|EXIT|RBUTTON, NORMAL, (LONG)"] [Farbe",
  0x0001, 0x0002, 0x0008, 0x0001,
        17, PRMATRI , PRTYP   , G_BUTTON  ,   /* Object 14  */
  NONE, NORMAL, (LONG)"} Typ ",
  0x0002, 0x000A, 0x0010, 0x0003,
  PRTYP   ,       -1,       -1, G_BUTTON  ,   /* Object 15 PRMATRI */
  SELECTABLE|EXIT|RBUTTON, NORMAL, (LONG)"] [Matrix",
  0x0001, 0x0001, 0x0009, 0x0001,
        14,       -1,       -1, G_BUTTON  ,   /* Object 16 PRTYP */
  SELECTABLE|EXIT|RBUTTON, NORMAL, (LONG)"] [Typenrad",
  0x0001, 0x0002, 0x000B, 0x0001,
         1, PRNLQ   , PRDRAFT , G_BUTTON  ,   /* Object 17  */
  NONE, NORMAL, (LONG)"} Qualit\204t ",
  0x0014, 0x000A, 0x000B, 0x0003,
  PRDRAFT ,       -1,       -1, G_BUTTON  ,   /* Object 18 PRNLQ */
  SELECTABLE|EXIT|RBUTTON, NORMAL, (LONG)"] [NLQ",
  0x0001, 0x0001, 0x0006, 0x0001,
        17,       -1,       -1, G_BUTTON  ,   /* Object 19 PRDRAFT */
  SELECTABLE|EXIT|RBUTTON|LASTOB, NORMAL, (LONG)"] [Draft",
  0x0001, 0x0002, 0x0008, 0x0001,
  
  /******** Tree 8 RAMDISK ****************************************************/
        -1,        1,        1, G_BOX     ,   /* Object 0  */
  NONE, OUTLINED, (LONG)0x00021100L,
  0x0000, 0x0000, 0x0025, 0x0010,
         0,        2, RDOFF   , G_BUTTON  ,   /* Object 1  */
  NONE, NORMAL, (LONG)"{ RAM-Disk ",
  0x0001, 0x0001, 0x0023, 0x000E,
  RDDRIVE , RDPARAM , RDRESET , G_BUTTON  ,   /* Object 2  */
  NONE, NORMAL, (LONG)"} Startprogramm ",
  0x0000, 0x0005, 0x0023, 0x0009,
  RDPRG   ,       -1,       -1, G_FTEXT   ,   /* Object 3 RDPARAM */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[23],
  0x0001, 0x0004, 0x0021, 0x0001,
         5,       -1,       -1, G_STRING  ,   /* Object 4 RDPRG */
  SELECTABLE|EXIT, OUTLINED, (LONG)"A:\134AAAAAAAA.AAA\134AAAAAAAA.AAA\134AAAA",
  0x0001, 0x0001, 0x0021, 0x0001,
  RDONLY  ,       -1,       -1, G_TEXT    ,   /* Object 5  */
  NONE, NORMAL, (LONG)&rs_tedinfo[24],
  0x0001, 0x0003, 0x000B, 0x0001,
  RDRESET ,       -1,       -1, G_BUTTON  ,   /* Object 6 RDONLY */
  SELECTABLE|EXIT|RBUTTON, NORMAL, (LONG)"] [nur bei Installation",
  0x0001, 0x0007, 0x0017, 0x0001,
         2,       -1,       -1, G_BUTTON  ,   /* Object 7 RDRESET */
  SELECTABLE|EXIT|RBUTTON, NORMAL, (LONG)"] nach jedem [Reset",
  0x0001, 0x0006, 0x0017, 0x0001,
        13,        9,       12, G_IBOX    ,   /* Object 8 RDDRIVE */
  NONE, NORMAL, (LONG)0x00001100L,
  0x0011, 0x0003, 0x000E, 0x0001,
        10,       -1,       -1, G_BOXCHAR ,   /* Object 9  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)0x04FF1100L,
  0x0000, 0x0000, 0x0002, 0x0001,
        12,       11,       11, G_BOX     ,   /* Object 10  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)0x00FF1111L,
  0x0002, 0x0000, 0x000A, 0x0001,
        10,       -1,       -1, G_FBOXTEXT,   /* Object 11  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)&rs_tedinfo[25],
  0x0001, 0x0000, 0x0003, 0x0001,
  RDDRIVE ,       -1,       -1, G_BOXCHAR ,   /* Object 12  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)0x03FF1100L,
  0x000C, 0x0000, 0x0002, 0x0001,
  RDON    ,       -1,       -1, G_TEXT    ,   /* Object 13  */
  NONE, NORMAL, (LONG)&rs_tedinfo[26],
  0x0011, 0x0002, 0x0606, 0x0001,
  RDOFF   ,       -1,       -1, G_BUTTON  ,   /* Object 14 RDON */
  SELECTABLE|EXIT|RBUTTON, NORMAL, (LONG)"] [an",
  0x0002, 0x0002, 0x0005, 0x0001,
         1,       -1,       -1, G_BUTTON  ,   /* Object 15 RDOFF */
  SELECTABLE|EXIT|RBUTTON|LASTOB, NORMAL, (LONG)"] a[us",
  0x0002, 0x0003, 0x0006, 0x0001,
  
  /******** Tree 9 SPOOLER ****************************************************/
        -1,        1,        1, G_BOX     ,   /* Object 0  */
  NONE, OUTLINED, (LONG)0x00021100L,
  0x0000, 0x0000, 0x0025, 0x0010,
         0, SPON    ,       12, G_BUTTON  ,   /* Object 1  */
  NONE, NORMAL, (LONG)"{ Drucker-Spooler ",
  0x0002, 0x0001, 0x0021, 0x000E,
  SPOFF   ,       -1,       -1, G_BUTTON  ,   /* Object 2 SPON */
  SELECTABLE|EXIT|RBUTTON, NORMAL, (LONG)"] [an",
  0x0002, 0x0002, 0x0005, 0x0001,
  SPRESET ,       -1,       -1, G_BUTTON  ,   /* Object 3 SPOFF */
  SELECTABLE|EXIT|RBUTTON, NORMAL, (LONG)"] a[us",
  0x0002, 0x0003, 0x0006, 0x0001,
  SPCHARS ,       -1,       -1, G_BUTTON  ,   /* Object 4 SPRESET */
  SELECTABLE|EXIT, NORMAL, (LONG)"Spooler-[Reset",
  0x000D, 0x0003, 0x000E, 0x0001,
  SPQUICK ,       -1,       -1, G_FTEXT   ,   /* Object 5 SPCHARS */
  NONE, NORMAL, (LONG)&rs_tedinfo[27],
  0x0002, 0x0007, 0x001C, 0x0002,
  SPRATE  ,       -1,       -1, G_BUTTON  ,   /* Object 6 SPQUICK */
  SELECTABLE|EXIT|TOUCHEXIT, NORMAL, (LONG)"] [Schnelle Cetronic-Ausgabe",
  0x0002, 0x0005, 0x001C, 0x0002,
        12,        8,       11, G_IBOX    ,   /* Object 7 SPRATE */
  NONE, NORMAL, (LONG)0x00001100L,
  0x0004, 0x000B, 0x0018, 0x0001,
         9,       -1,       -1, G_BOXCHAR ,   /* Object 8  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)0x04FF1100L,
  0x0000, 0x0000, 0x0002, 0x0001,
        11,       10,       10, G_BOX     ,   /* Object 9  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)0x00FF1111L,
  0x0002, 0x0000, 0x0014, 0x0001,
         9,       -1,       -1, G_FBOXTEXT,   /* Object 10  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)&rs_tedinfo[28],
  0x0001, 0x0000, 0x0005, 0x0001,
  SPRATE  ,       -1,       -1, G_BOXCHAR ,   /* Object 11  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)0x03FF1100L,
  0x0016, 0x0000, 0x0002, 0x0001,
         1,       -1,       -1, G_TEXT    ,   /* Object 12  */
  LASTOB, NORMAL, (LONG)&rs_tedinfo[29],
  0x0004, 0x000A, 0x0618, 0x0001,
  
  /******** Tree 10 SCSAVER ****************************************************/
        -1,        1,        1, G_BOX     ,   /* Object 0  */
  NONE, OUTLINED, (LONG)0x00021100L,
  0x0000, 0x0000, 0x0025, 0x0010,
         0, SCON    , SCINVERT, G_BUTTON  ,   /* Object 1  */
  NONE, NORMAL, (LONG)"{ Bildschirmschoner ",
  0x0002, 0x0002, 0x0021, 0x000C,
  SCOFF   ,       -1,       -1, G_BUTTON  ,   /* Object 2 SCON */
  SELECTABLE|EXIT|RBUTTON, NORMAL, (LONG)"] [ein",
  0x0003, 0x0002, 0x0006, 0x0002,
         4,       -1,       -1, G_BUTTON  ,   /* Object 3 SCOFF */
  SELECTABLE|EXIT|RBUTTON, NORMAL, (LONG)"] [aus",
  0x0003, 0x0004, 0x0006, 0x0001,
  SCSLIDER,       -1,       -1, G_STRING  ,   /* Object 4  */
  NONE, NORMAL, (LONG)"Abschaltzeit:",
  0x0002, 0x0006, 0x000D, 0x0001,
  SCINVERT,        6,        9, G_IBOX    ,   /* Object 5 SCSLIDER */
  NONE, NORMAL, (LONG)0x00001100L,
  0x0002, 0x0008, 0x001D, 0x0001,
         7,       -1,       -1, G_BOXCHAR ,   /* Object 6  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)0x04FF1100L,
  0x0000, 0x0000, 0x0002, 0x0001,
         9,        8,        8, G_BOX     ,   /* Object 7  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)0x00FF1111L,
  0x0002, 0x0000, 0x0019, 0x0001,
         7,       -1,       -1, G_FBOXTEXT,   /* Object 8  */
  NONE, NORMAL, (LONG)&rs_tedinfo[30],
  0x0004, 0x0000, 0x0008, 0x0001,
  SCSLIDER,       -1,       -1, G_BOXCHAR ,   /* Object 9  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)0x03FF1100L,
  0x001B, 0x0000, 0x0002, 0x0001,
         1,       -1,       -1, G_BUTTON  ,   /* Object 10 SCINVERT */
  SELECTABLE|EXIT|LASTOB|TOUCHEXIT, NORMAL, (LONG)"] Bildschirm [invertieren",
  0x0003, 0x000A, 0x0019, 0x0001,
  
  /******** Tree 11 CACHE ****************************************************/
        -1,        1,        1, G_BOX     ,   /* Object 0  */
  NONE, OUTLINED, (LONG)0x00021100L,
  0x0003, 0x0005, 0x0025, 0x0010,
         0, DCON    ,       21, G_BUTTON  ,   /* Object 1  */
  NONE, NORMAL, (LONG)"{ Disk-Cache ",
  0x0002, 0x0001, 0x0021, 0x000E,
  DCOFF   ,       -1,       -1, G_BUTTON  ,   /* Object 2 DCON */
  SELECTABLE|EXIT|RBUTTON, NORMAL, (LONG)"] [ein",
  0x0002, 0x0002, 0x0006, 0x0001,
         4,       -1,       -1, G_BUTTON  ,   /* Object 3 DCOFF */
  SELECTABLE|EXIT|RBUTTON, NORMAL, (LONG)"] [aus",
  0x0002, 0x0003, 0x0006, 0x0001,
  DCRESET , DCDRIVE ,       14, G_BUTTON  ,   /* Object 4  */
  NONE, NORMAL, (LONG)"{ Laufwerk ",
  0x0000, 0x0007, 0x0021, 0x0007,
  DCDREAD ,        6,        9, G_IBOX    ,   /* Object 5 DCDRIVE */
  NONE, NORMAL, (LONG)0x00001100L,
  0x0002, 0x0002, 0x000F, 0x0001,
         7,       -1,       -1, G_BOXCHAR ,   /* Object 6  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)0x04FF1100L,
  0x0000, 0x0000, 0x0002, 0x0001,
         9,        8,        8, G_BOX     ,   /* Object 7  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)0x00FF1111L,
  0x0002, 0x0000, 0x000B, 0x0001,
         7,       -1,       -1, G_FBOXTEXT,   /* Object 8  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)&rs_tedinfo[31],
  0x0003, 0x0000, 0x0003, 0x0001,
  DCDRIVE ,       -1,       -1, G_BOXCHAR ,   /* Object 9  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)0x03FF1100L,
  0x000D, 0x0000, 0x0002, 0x0001,
  DCDWRITE,       -1,       -1, G_BUTTON  ,   /* Object 10 DCDREAD */
  SELECTABLE|EXIT|RBUTTON, NORMAL, (LONG)"] [lesen",
  0x0014, 0x0004, 0x0008, 0x0001,
  DCDLOCK ,       -1,       -1, G_BUTTON  ,   /* Object 11 DCDWRITE */
  SELECTABLE|EXIT|RBUTTON, NORMAL, (LONG)"] [scheiben",
  0x0014, 0x0005, 0x000B, 0x0001,
  DCDOFF  ,       -1,       -1, G_BUTTON  ,   /* Object 12 DCDLOCK */
  SELECTABLE|EXIT|TOUCHEXIT, NORMAL, (LONG)"] Schei[bschutz",
  0x0002, 0x0004, 0x000F, 0x0002,
        14,       -1,       -1, G_BUTTON  ,   /* Object 13 DCDOFF */
  SELECTABLE|EXIT|RBUTTON, NORMAL, (LONG)"] a[us",
  0x0014, 0x0003, 0x0006, 0x0001,
         4,       -1,       -1, G_STRING  ,   /* Object 14  */
  NONE, NORMAL, (LONG)"Cache-Typ",
  0x0014, 0x0001, 0x0009, 0x0002,
  DCDELAY ,       -1,       -1, G_BUTTON  ,   /* Object 15 DCRESET */
  SELECTABLE|EXIT, NORMAL, (LONG)"Cache-Speicher [Reset",
  0x0006, 0x0005, 0x0015, 0x0001,
        21,       17,       20, G_IBOX    ,   /* Object 16 DCDELAY */
  NONE, NORMAL, (LONG)0x00001100L,
  0x000F, 0x0002, 0x000F, 0x0001,
        18,       -1,       -1, G_BOXCHAR ,   /* Object 17  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)0x04FF1100L,
  0x0000, 0x0000, 0x0002, 0x0001,
        20,       19,       19, G_BOX     ,   /* Object 18  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)0x00FF1111L,
  0x0002, 0x0000, 0x000B, 0x0001,
        18,       -1,       -1, G_FBOXTEXT,   /* Object 19  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)&rs_tedinfo[32],
  0x0002, 0x0000, 0x0004, 0x0001,
  DCDELAY ,       -1,       -1, G_BOXCHAR ,   /* Object 20  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)0x03FF1100L,
  0x000D, 0x0000, 0x0002, 0x0001,
         1,       -1,       -1, G_TEXT    ,   /* Object 21  */
  LASTOB, NORMAL, (LONG)&rs_tedinfo[33],
  0x000F, 0x0001, 0x020E, 0x0001,
  
  /******** Tree 12 STATIST ****************************************************/
        -1,        1,       16, G_BOX     ,   /* Object 0  */
  NONE, OUTLINED, (LONG)0x00021100L,
  0x0000, 0x0000, 0x0025, 0x0010,
        16,        2, CIFATERR, G_BUTTON  ,   /* Object 1  */
  NONE, NORMAL, (LONG)"} Cache-Statistik ",
  0x0002, 0x0001, 0x0021, 0x0007,
         3,       -1,       -1, G_TEXT    ,   /* Object 2  */
  NONE, NORMAL, (LONG)&rs_tedinfo[34],
  0x0001, 0x0002, 0x0208, 0x0001,
         4,       -1,       -1, G_TEXT    ,   /* Object 3  */
  NONE, NORMAL, (LONG)&rs_tedinfo[35],
  0x0001, 0x0001, 0x061B, 0x0001,
         5,       -1,       -1, G_TEXT    ,   /* Object 4  */
  NONE, NORMAL, (LONG)&rs_tedinfo[36],
  0x0001, 0x0003, 0x0208, 0x0001,
  CIPHRD  ,       -1,       -1, G_TEXT    ,   /* Object 5  */
  NONE, NORMAL, (LONG)&rs_tedinfo[37],
  0x0001, 0x0004, 0x0208, 0x0001,
  CILOGRD ,       -1,       -1, G_TEXT    ,   /* Object 6 CIPHRD */
  NONE, NORMAL, (LONG)&rs_tedinfo[38],
  0x000C, 0x0002, 0x0205, 0x0001,
  CILOGWRT,       -1,       -1, G_TEXT    ,   /* Object 7 CILOGRD */
  NONE, NORMAL, (LONG)&rs_tedinfo[39],
  0x000C, 0x0003, 0x0205, 0x0001,
  CIPHWRT ,       -1,       -1, G_TEXT    ,   /* Object 8 CILOGWRT */
  NONE, NORMAL, (LONG)&rs_tedinfo[40],
  0x0017, 0x0003, 0x0205, 0x0001,
  CIRATRD ,       -1,       -1, G_TEXT    ,   /* Object 9 CIPHWRT */
  NONE, NORMAL, (LONG)&rs_tedinfo[41],
  0x0017, 0x0002, 0x0205, 0x0001,
  CIRATWRT,       -1,       -1, G_FTEXT   ,   /* Object 10 CIRATRD */
  NONE, NORMAL, (LONG)&rs_tedinfo[42],
  0x000C, 0x0004, 0x0205, 0x0001,
        12,       -1,       -1, G_FTEXT   ,   /* Object 11 CIRATWRT */
  NONE, NORMAL, (LONG)&rs_tedinfo[43],
  0x0017, 0x0004, 0x0205, 0x0001,
        13,       -1,       -1, G_TEXT    ,   /* Object 12  */
  NONE, NORMAL, (LONG)&rs_tedinfo[44],
  0x0001, 0x0005, 0x0416, 0x0001,
  CICHKERR,       -1,       -1, G_TEXT    ,   /* Object 13  */
  NONE, NORMAL, (LONG)&rs_tedinfo[45],
  0x0001, 0x0006, 0x0416, 0x0001,
  CIFATERR,       -1,       -1, G_TEXT    ,   /* Object 14 CICHKERR */
  NONE, NORMAL, (LONG)&rs_tedinfo[46],
  0x0018, 0x0005, 0x0205, 0x0001,
         1,       -1,       -1, G_TEXT    ,   /* Object 15 CIFATERR */
  NONE, NORMAL, (LONG)&rs_tedinfo[47],
  0x0018, 0x0006, 0x0205, 0x0001,
         0,       17, SENDCHAR, G_BUTTON  ,   /* Object 16  */
  NONE, NORMAL, (LONG)"} Speicher-Statistik ",
  0x0002, 0x0009, 0x0021, 0x0006,
        18,       -1,       -1, G_TEXT    ,   /* Object 17  */
  NONE, NORMAL, (LONG)&rs_tedinfo[48],
  0x0001, 0x0001, 0x0416, 0x0001,
        19,       -1,       -1, G_TEXT    ,   /* Object 18  */
  NONE, NORMAL, (LONG)&rs_tedinfo[49],
  0x0001, 0x0002, 0x0416, 0x0001,
        20,       -1,       -1, G_TEXT    ,   /* Object 19  */
  NONE, NORMAL, (LONG)&rs_tedinfo[50],
  0x0001, 0x0003, 0x0416, 0x0001,
  SPBLK   ,       -1,       -1, G_TEXT    ,   /* Object 20  */
  NONE, NORMAL, (LONG)&rs_tedinfo[51],
  0x0001, 0x0004, 0x0416, 0x0001,
  RDBLK   ,       -1,       -1, G_TEXT    ,   /* Object 21 SPBLK */
  NONE, NORMAL, (LONG)&rs_tedinfo[52],
  0x0018, 0x0001, 0x0205, 0x0001,
  CIBLK   ,       -1,       -1, G_TEXT    ,   /* Object 22 RDBLK */
  NONE, NORMAL, (LONG)&rs_tedinfo[53],
  0x0018, 0x0002, 0x0205, 0x0001,
  FREEBLK ,       -1,       -1, G_TEXT    ,   /* Object 23 CIBLK */
  NONE, NORMAL, (LONG)&rs_tedinfo[54],
  0x0018, 0x0003, 0x0205, 0x0001,
        25,       -1,       -1, G_TEXT    ,   /* Object 24 FREEBLK */
  NONE, NORMAL, (LONG)&rs_tedinfo[55],
  0x0018, 0x0004, 0x0205, 0x0001,
  SENDCHAR,       -1,       -1, G_TEXT    ,   /* Object 25  */
  NONE, NORMAL, (LONG)&rs_tedinfo[56],
  0x0001, 0x0005, 0x0416, 0x0001,
        16,       -1,       -1, G_TEXT    ,   /* Object 26 SENDCHAR */
  LASTOB, NORMAL, (LONG)&rs_tedinfo[57],
  0x0018, 0x0005, 0x0205, 0x0001,
  
  /******** Tree 13 MEMORY ****************************************************/
        -1,        1,        1, G_BOX     ,   /* Object 0  */
  NONE, OUTLINED, (LONG)0x00021100L,
  0x0000, 0x0000, 0x0025, 0x0010,
         0, MEMINST ,       24, G_BUTTON  ,   /* Object 1  */
  NONE, NORMAL, (LONG)"{ Residenter Speicher ",
  0x0002, 0x0001, 0x0021, 0x000E,
  NXTMEM  ,       -1,       -1, G_BUTTON  ,   /* Object 2 MEMINST */
  SELECTABLE|EXIT, NORMAL, (LONG)"[Installieren",
  0x0012, 0x0002, 0x000D, 0x0001,
         8,        4,        7, G_IBOX    ,   /* Object 3 NXTMEM */
  NONE, NORMAL, (LONG)0x00001100L,
  0x0002, 0x000C, 0x001C, 0x0001,
         5,       -1,       -1, G_BOXCHAR ,   /* Object 4  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)0x04FF1100L,
  0x0000, 0x0000, 0x0002, 0x0001,
         7,        6,        6, G_BOX     ,   /* Object 5  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)0x00FF1111L,
  0x0002, 0x0000, 0x0018, 0x0001,
         5,       -1,       -1, G_FBOXTEXT,   /* Object 6  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)&rs_tedinfo[58],
  0x0002, 0x0000, 0x0008, 0x0001,
  NXTMEM  ,       -1,       -1, G_BOXCHAR ,   /* Object 7  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)0x03FF1100L,
  0x001A, 0x0000, 0x0002, 0x0001,
         9,       -1,       -1, G_TEXT    ,   /* Object 8  */
  NONE, NORMAL, (LONG)&rs_tedinfo[59],
  0x0002, 0x000B, 0x040A, 0x0001,
        10,       -1,       -1, G_STRING  ,   /* Object 9  */
  NONE, NORMAL, (LONG)"Aktuell",
  0x0001, 0x0002, 0x0007, 0x0001,
        11,       -1,       -1, G_STRING  ,   /* Object 10  */
  NONE, NORMAL, (LONG)"Speichergr\224\236e :",
  0x0002, 0x0003, 0x000F, 0x0002,
        12,       -1,       -1, G_STRING  ,   /* Object 11  */
  NONE, NORMAL, (LONG)"Blockgr\224\236e    :",
  0x0002, 0x0004, 0x000F, 0x0002,
  CURMEM  ,       -1,       -1, G_STRING  ,   /* Object 12  */
  NONE, NORMAL, (LONG)"Zuk\201nftig",
  0x0001, 0x0009, 0x0009, 0x0001,
  CURBLK  ,       -1,       -1, G_STRING  ,   /* Object 13 CURMEM */
  NONE, NORMAL, (LONG)"9999",
  0x0012, 0x0003, 0x0004, 0x0002,
  AHDIFLAG,       -1,       -1, G_STRING  ,   /* Object 14 CURBLK */
  NONE, NORMAL, (LONG)"9999",
  0x0012, 0x0004, 0x0004, 0x0002,
        16,       -1,       -1, G_STRING  ,   /* Object 15 AHDIFLAG */
  NONE, NORMAL, (LONG)"Kein AHDI 3.0 kompatibler",
  0x0003, 0x0006, 0x0019, 0x0002,
        17,       -1,       -1, G_STRING  ,   /* Object 16  */
  NONE, NORMAL, (LONG)"Treiber installiert!",
  0x0006, 0x0007, 0x0014, 0x0002,
  NXTBLK  ,       -1,       -1, G_TEXT    ,   /* Object 17  */
  NONE, NORMAL, (LONG)&rs_tedinfo[60],
  0x000F, 0x0009, 0x000F, 0x0001,
        23,       19,       22, G_IBOX    ,   /* Object 18 NXTBLK */
  NONE, NORMAL, (LONG)0x00001100L,
  0x000F, 0x000A, 0x000F, 0x0001,
        20,       -1,       -1, G_BOXCHAR ,   /* Object 19  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)0x04FF1100L,
  0x0000, 0x0000, 0x0002, 0x0001,
        22,       21,       21, G_BOX     ,   /* Object 20  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)0x00FF1111L,
  0x0002, 0x0000, 0x000B, 0x0001,
        20,       -1,       -1, G_FBOXTEXT,   /* Object 21  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)&rs_tedinfo[61],
  0x0001, 0x0000, 0x0007, 0x0001,
  NXTBLK  ,       -1,       -1, G_BOXCHAR ,   /* Object 22  */
  EXIT|TOUCHEXIT, NORMAL, (LONG)0x03FF1100L,
  0x000D, 0x0000, 0x0002, 0x0001,
        24,       -1,       -1, G_STRING  ,   /* Object 23  */
  NONE, NORMAL, (LONG)"KBytes",
  0x0017, 0x0003, 0x0006, 0x0002,
         1,       -1,       -1, G_STRING  ,   /* Object 24  */
  LASTOB, NORMAL, (LONG)"Bytes",
  0x0017, 0x0004, 0x0005, 0x0002
};

OBJECT *rs_trindex[] =
{ &rs_object[0],   /* Tree 0 TOSACC */
  &rs_object[5],   /* Tree 1 XDIAL */
  &rs_object[15],   /* Tree 2 KEYBOARD */
  &rs_object[36],   /* Tree 3 SETMOUSE */
  &rs_object[105],   /* Tree 4 MESSAGE */
  &rs_object[117],   /* Tree 5 SETTIME */
  &rs_object[129],   /* Tree 6 RS232 */
  &rs_object[154],   /* Tree 7 CETRONIC */
  &rs_object[174],   /* Tree 8 RAMDISK */
  &rs_object[190],   /* Tree 9 SPOOLER */
  &rs_object[203],   /* Tree 10 SCSAVER */
  &rs_object[214],   /* Tree 11 CACHE */
  &rs_object[236],   /* Tree 12 STATIST */
  &rs_object[263],   /* Tree 13 MEMORY */
};
