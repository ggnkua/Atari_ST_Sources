/*
 * Header file containing the objects for gemgs
 */

#include <vdibind.h>
#include <aesbind.h>

#define UL	(unsigned long)

/* buttons */
#define CEN_BUT		2
#define PRN_BUT		3
#define OTHER_OK	3
#define FILE_BUT	4
#define RUN_CANCEL	4

#define FIRSTBUT	2
#define LASTBUT		11
#define PAGE_DN		12
#define PAGE_UP		13
#define PAGE_CLEAR	15
#define PAGE_CANCEL	16
#define PAGE_OK		17


/* menus */
#define ABOUT		12

#define RUN		21
#define INPUT		22
#define OUTPUT		23
#define QUIT		24

#define CONFIRM		65
#define QUIET		66
#define NOPAUSE		67
#define AUTOQUIT	68
#define WINDOWS		69
#define GEOMETRY	70
#define CLIST		71
#define PAGE		72

/* important objects */
#define FIRSTDEV	27
#define LASTDEV		37
#define FIRSTRES	38
#define LASTRES		48
#define FIRSTSIZE	49
#define LASTSIZE	63
#define FIRSTOOL	74
#define LASTOOL		84

/* Menu bar object */

OBJECT menubar[] = {

/* 0 */  {-1,  1, 10, G_IBOX,  0, 0, 0L,                   0, 0, 80,  25},
/* 1 */  {10,  2,  2, G_BOX ,  0, 0, 0x1100L,              0, 0, 80, 513},

/* 2 */  { 1,  3,  9, G_IBOX,  0, 0, 0L,                   2, 0, 59, 769},
/* 3 */  { 4, -1, -1, G_TITLE, 0, 0, UL" Desk ",           0, 0,  6, 769},
/* 4 */  { 5, -1, -1, G_TITLE, 0, 0, UL" File ",           6, 0,  6, 769},
/* 5 */  { 6, -1, -1, G_TITLE, 0, 0, UL" Device ",        12, 0,  8, 769},
/* 6 */  { 7, -1, -1, G_TITLE, 0, 0, UL" Resolution ",    20, 0, 12, 769},
/* 7 */  { 8, -1, -1, G_TITLE, 0, 0, UL" PaperSize ",     32, 0, 11, 769},
/* 8 */  { 9, -1, -1, G_TITLE, 0, 0, UL" Options ",       43, 0,  9, 769},
/* 9 */  { 2, -1, -1, G_TITLE, 0, 0, UL" Tools ",         52, 0,  7, 769},

/* 10 */  { 0,  11, 74, G_IBOX,  0, 0, 0L,                 0, 769, 80, 19},

/* 11 */  { 20, 11, 19, G_BOX ,  0, 0, 0xff1100L,            2, 0, 20, 8},
/* 12 */  { 13, -1, -1, G_STRING ,  0, 0, UL"  About gemGS", 0, 0, 20, 1},
/* 13 */  { 14, -1, -1, G_STRING ,  0, 0x08, UL" ------------------ ",  0, 1, 20, 1},
/* 14 */  { 15, -1, -1, G_STRING ,  0, 0, UL"1",             0, 2, 20, 1},
/* 15 */  { 16, -1, -1, G_STRING ,  0, 0, UL"2",             0, 3, 20, 1},
/* 16 */  { 17, -1, -1, G_STRING ,  0, 0, UL"3",             0, 4, 20, 1},
/* 17 */  { 18, -1, -1, G_STRING ,  0, 0, UL"4",             0, 5, 20, 1},
/* 18 */  { 19, -1, -1, G_STRING ,  0, 0, UL"5",             0, 6, 20, 1},
/* 19 */  { 11, -1, -1, G_STRING ,  0, 0, UL"6",             0, 7, 20, 1},

/* 20 */  { 27, 21, 24, G_BOX ,  0, 0, 0xff1100L,            8, 0, 12, 4},
/* 21 */  { 22, -1, -1, G_STRING ,  0, 0, UL"  Run     r", 0, 0, 12, 1},
/* 22 */  { 23, -1, -1, G_STRING ,  0, 0, UL"  Input   i", 0, 1, 12, 1},
/* 23 */  { 24, -1, -1, G_STRING ,  0, 0, UL"  Output  o", 0, 2, 12, 1},
/* 24 */  { 20, -1, -1, G_STRING ,  0, 0, UL"  Quit    q", 0, 3, 12, 1},
/* 25 */  { 20, -1, -1, G_STRING ,  0, DISABLED, UL"",       0, 4, 12, 1},
/* 26 */  { 20, -1, -1, G_STRING ,  0, DISABLED, UL"",       0, 5, 12, 1},

/* 27 */  { 38, 28, 37, G_BOX ,  0, 0, 0xff1100L,           14, 0, 12, 2},
/* 28 */  { 37, -1, -1, G_STRING ,  0, CHECKED, UL"  stvdi", 0, 0, 12, 1},
/* 29 */  { 30, -1, -1, G_STRING ,  0, DISABLED, UL"",       0, 1, 12, 1},
/* 30 */  { 31, -1, -1, G_STRING ,  0, DISABLED, UL"",       0, 2, 12, 1},
/* 31 */  { 32, -1, -1, G_STRING ,  0, DISABLED, UL"",       0, 3, 12, 1},
/* 32 */  { 33, -1, -1, G_STRING ,  0, DISABLED, UL"",       0, 4, 12, 1},
/* 33 */  { 34, -1, -1, G_STRING ,  0, DISABLED, UL"",       0, 5, 12, 1},
/* 34 */  { 35, -1, -1, G_STRING ,  0, DISABLED, UL"",       0, 6, 12, 1},
/* 35 */  { 36, -1, -1, G_STRING ,  0, DISABLED, UL"",       0, 7, 12, 1},
/* 36 */  { 37, -1, -1, G_STRING ,  0, DISABLED, UL"",       0, 8, 12, 1},
/* 37 */  { 27, -1, -1, G_STRING ,  0, 0, UL"  Other",       0, 1, 12, 1},

/* 38 */  { 49, 39, 48, G_BOX ,  0, 0, 0xff1100L,           22, 0, 12, 2},
/* 39 */  { 48, -1, -1, G_STRING ,  0, CHECKED, UL"  Default", 0, 0, 12, 1},
/* 40 */  { 41, -1, -1, G_STRING ,  0, DISABLED, UL"",       0, 1, 12, 1},
/* 41 */  { 42, -1, -1, G_STRING ,  0, DISABLED, UL"",       0, 2, 12, 1},
/* 42 */  { 43, -1, -1, G_STRING ,  0, DISABLED, UL"",       0, 3, 12, 1},
/* 43 */  { 44, -1, -1, G_STRING ,  0, DISABLED, UL"",       0, 4, 12, 1},
/* 44 */  { 45, -1, -1, G_STRING ,  0, DISABLED, UL"",       0, 5, 12, 1},
/* 45 */  { 46, -1, -1, G_STRING ,  0, DISABLED, UL"",       0, 6, 12, 1},
/* 46 */  { 47, -1, -1, G_STRING ,  0, DISABLED, UL"",       0, 7, 12, 1},
/* 47 */  { 48, -1, -1, G_STRING ,  0, DISABLED, UL"",       0, 8, 12, 1},
/* 48 */  { 38, -1, -1, G_STRING ,  0, 0, UL"  Other",       0, 1, 12, 1},

/* 49 */  { 64, 50, 63, G_BOX ,  0, 0, 0xff1100L,           34, 0, 14, 14},
/* 50 */  { 51, -1, -1, G_STRING ,  0, CHECKED, UL"  Default", 0, 0, 14, 1},
/* 51 */  { 52, -1, -1, G_STRING ,  0, 0, UL"  letter",     0, 1, 14, 1},
/* 52 */  { 53, -1, -1, G_STRING ,  0, 0, UL"  halfletter", 0, 2, 14, 1},
/* 53 */  { 54, -1, -1, G_STRING ,  0, 0, UL"  legal",      0, 3, 14, 1},
/* 54 */  { 55, -1, -1, G_STRING ,  0, 0, UL"  ledger",     0, 4, 14, 1},
/* 55 */  { 56, -1, -1, G_STRING ,  0, 0, UL"  11x17",      0, 5, 14, 1},
/* 56 */  { 57, -1, -1, G_STRING ,  0, 0, UL"  note",       0, 6, 14, 1},
/* 57 */  { 58, -1, -1, G_STRING ,  0, 0, UL"  a3",         0, 7, 14, 1},
/* 58 */  { 59, -1, -1, G_STRING ,  0, 0, UL"  a4",         0, 8, 14, 1},
/* 59 */  { 60, -1, -1, G_STRING ,  0, 0, UL"  a5",         0, 9, 14, 1},
/* 60 */  { 61, -1, -1, G_STRING ,  0, 0, UL"  a6",         0, 10, 14, 1},
/* 61 */  { 62, -1, -1, G_STRING ,  0, 0, UL"  b4",         0, 11, 14, 1},
/* 62 */  { 63, -1, -1, G_STRING ,  0, 0, UL"  flsa",       0, 12, 14, 1},
/* 63 */  { 49, -1, -1, G_STRING ,  0, 0, UL"  flse",       0, 13, 14, 1},

/* 64 */  { 74, 65, 72, G_BOX ,  0, 0, 0xff1100L,           45, 0, 13, 8},
/* 65 */  { 66, -1, -1, G_STRING ,  0, 0, UL"  Confirm",     0, 0, 13, 1},
/* 66 */  { 67, -1, -1, G_STRING ,  0, 0, UL"  Quiet",       0, 1, 13, 1},
/* 67 */  { 68, -1, -1, G_STRING ,  0, 0, UL"  NoPause",     0, 2, 13, 1},
/* 68 */  { 69, -1, -1, G_STRING ,  0, 0, UL"  AutoQuit",    0, 3, 13, 1},
/* 69 */  { 70, -1, -1, G_STRING ,  0, 0, UL"  Windows",     0, 4, 13, 1},
/* 70 */  { 71, -1, -1, G_STRING ,  0, 0, UL"  Geometry g", 0, 5, 13, 1},
/* 71 */  { 72, -1, -1, G_STRING ,  0, 0, UL"  Clist    c", 0, 6, 13, 1},
/* 72 */  { 64, -1, -1, G_STRING ,  0, 0, UL"  Pages    p", 0, 7, 13, 1},
/* 73 */  { 64, -1, -1, G_STRING ,  0, DISABLED, UL"",        0, 8, 13, 1},

/* 74 */  { 10, 75, 75, G_BOX ,  0, 0, 0xff1100L,            54, 0, 20, 1},
/* 75 */  { 74, -1, -1, G_STRING ,  0, DISABLED, UL"  Empty", 0, 0, 20, 1},
/* 76 */  { 77, -1, -1, G_STRING ,  0, DISABLED, UL"",       0, 1, 20, 1},
/* 77 */  { 78, -1, -1, G_STRING ,  0, DISABLED, UL"",       0, 2, 20, 1},
/* 78 */  { 79, -1, -1, G_STRING ,  0, DISABLED, UL"",       0, 3, 20, 1},
/* 79 */  { 80, -1, -1, G_STRING ,  0, DISABLED, UL"",       0, 4, 20, 1},
/* 80 */  { 81, -1, -1, G_STRING ,  0, DISABLED, UL"",       0, 5, 20, 1},
/* 81 */  { 82, -1, -1, G_STRING ,  0, DISABLED, UL"",       0, 6, 20, 1},
/* 82 */  { 83, -1, -1, G_STRING ,  0, DISABLED, UL"",       0, 7, 20, 1},
/* 83 */  { 84, -1, -1, G_STRING ,  0, DISABLED, UL"",       0, 8, 20, 1},
/* 84 */  { 74, -1, -1, G_STRING ,  LASTOB, DISABLED, UL"",  0, 9, 20, 1}

};

/* About gemGS dialog object. */

OBJECT about[] = {
/* 0 */  {-1,  1,  8,    G_BOX, 0, 16, 0x00021100L,              0, 0, 29, 13},
/* 1 */  { 2, -1, -1, G_STRING, 0, 0, UL"gemGS 1.3",            10, 1,  9,  1},
/* 2 */  { 3, -1, -1, G_STRING, 0, 0, UL"Gem Shell for Ghostscript", 2, 2, 25, 1},
/* 3 */  { 4, -1, -1, G_STRING, 0, 0, UL"(c) 1992, Tim Gallivan", 3, 3, 23, 1},
/* 4 */  { 5, -1, -1, G_STRING, 0, 0, UL"gemGS is JobWare",       6, 6, 16, 1},
/* 5 */  { 6, -1, -1, G_STRING, 0, 0, UL"Regular Users Must",     5, 7, 18, 1},
/* 6 */  { 7, -1, -1, G_STRING, 0, 0, UL"Offer the Author",       6, 8, 16, 1},
/* 7 */  { 8, -1, -1, G_STRING, 0, 0, UL"Gainful Employment",     5, 9, 18, 1},
/* 8 */  { 0, -1, -1, G_BUTTON, 0x62,  0, UL" OK ",              10, 11, 8, 1}
};

/* Command line parameters dialog object and the associated tedinfo. */

TEDINFO commtedinf = {
  "",
  "__________________________________________________________________________",
  "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
  3, 6, 0, 0x1180, 0, -1, 75, 75};

OBJECT commline[] = {
/* 0 */  {-1,  1,  4,  G_BOX, 0, 16, 0x00021100L,         0, 0, 78, 7},
/* 1 */  { 2, -1, -1, G_STRING, 0,  0, UL"",             27, 1, 24, 1},
/* 2 */  { 3, -1, -1, G_FTEXT, 0x08,  0, UL&commtedinf,   2, 3, 74, 1},
/* 3 */  { 4, -1, -1, G_BUTTON, 0x42,  0, UL" Run ",     31, 5,  5, 1},
/* 4 */  { 0, -1, -1, G_BUTTON, 0x60,  0, UL" Cancel ",  39, 5,  8, 1}
};

/* Object for output selection dialog. */

OBJECT output[] = {
/* 0 */  {-1,  1,  4,  G_BOX, 0, 16, 0x00021100L,           0, 0, 26, 5},
/* 1 */  { 2, -1, -1, G_STRING, 0,  0, UL"Send Output To:", 5, 1, 15, 1},
/* 2 */  { 3, -1, -1, G_BUTTON, 0x42,  0, UL" CEN: ",        2, 3, 6, 1},
/* 3 */  { 4, -1, -1, G_BUTTON, 0x40,  0, UL" PRN: ",       10, 3, 6, 1},
/* 4 */  { 0, -1, -1, G_BUTTON, 0x60,  0, UL" File ",       18, 3, 6, 1}
};

/* Device and resolution dialog objects and the associated tedinfos. */

TEDINFO othertedinf = {
  "",
  "__________",
  "XXXXXXXXXX",
  3, 6, 0, 0x1180, 0, -1, 11, 11};

OBJECT other[] = {
/* 0 */  {-1,  1,  4,  G_BOX, 0, 16, 0x00021100L,        0, 0, 18, 7},
/* 1 */  { 2, -1, -1, G_STRING, 0,  0, UL"  Device:  ",  4, 1, 11, 1},
/* 2 */  { 3, -1, -1, G_FTEXT, 0x08,  0, UL&othertedinf, 4, 3, 10, 1},
/* 3 */  { 4, -1, -1, G_BUTTON, 0x42,  0, UL" OK ",      2, 5,  4, 1},
/* 4 */  { 0, -1, -1, G_BUTTON, 0x60,  0, UL" Cancel ",  8, 5,  8, 1}
};

/* Page dialog object and the associated tedinfo. */

TEDINFO pagetedinf = {
  "",
  "Pages: ______________________",
  "XXXXXXXXXXXXXXXXXXXXXX",
  3, 6, 0, 0x1180, 0, -1, 23, 23};

OBJECT pagedial[] = {
/* 0 */  {-1,  1, 17,  G_BOX, 0, 16, 0x00021100L,                0, 0, 33, 11},
/* 1 */  { 2, -1, -1, G_STRING, 0,  0, UL"There are 2 pages.  ", 7, 1, 20, 1},

/* 2 */  { 3, -1, -1, G_BUTTON, 0, DISABLED, UL"  1 ",           2, 3, 4, 1},
/* 3 */  { 4, -1, -1, G_BUTTON, 0, DISABLED, UL"  2 ",           7, 3, 4, 1},
/* 4 */  { 5, -1, -1, G_BUTTON, 0, DISABLED, UL"  3 ",          12, 3, 4, 1},
/* 5 */  { 6, -1, -1, G_BUTTON, 0, DISABLED, UL"  4 ",          17, 3, 4, 1},
/* 6 */  { 7, -1, -1, G_BUTTON, 0, DISABLED, UL"  5 ",          22, 3, 4, 1},

/* 7 */  { 8, -1, -1, G_BUTTON, 0, DISABLED, UL"  6 ",           2, 5, 4, 1},
/* 8 */  { 9, -1, -1, G_BUTTON, 0, DISABLED, UL"  7 ",           7, 5, 4, 1},
/* 9 */  { 10, -1, -1, G_BUTTON, 0, DISABLED, UL"  8 ",         12, 5, 4, 1},
/* 10 */  { 11, -1, -1, G_BUTTON, 0, DISABLED, UL"  9 ",        17, 5, 4, 1},
/* 11 */  { 12, -1, -1, G_BUTTON, 0, DISABLED, UL" 10 ",        22, 5, 4, 1},

/* 12 */  { 13, -1, -1, G_BUTTON, 0, DISABLED, UL" \001 ",      28, 3, 3, 1},
/* 13 */  { 14, -1, -1, G_BUTTON, 0x41, 0, UL" \002 ",          28, 5, 3, 1},

/* 14 */  { 15, -1, -1, G_FTEXT, 0x08,  0, UL&pagetedinf,       2, 7, 29, 1},

/* 15 */  { 16, -1, -1, G_BUTTON, 0x41,  0, UL"  Clear  ",      2, 9, 10, 1},
/* 16 */  { 17, -1, -1, G_BUTTON, 0x41,  0, UL" Cancel ",      13, 9,  9, 1},
/* 17 */  {  0, -1, -1, G_BUTTON, 0x62,  0, UL" OK ",           23, 9,  8, 1}
};
