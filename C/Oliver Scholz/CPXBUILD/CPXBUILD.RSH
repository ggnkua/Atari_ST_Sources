/********************************************/
/* File : CPXBUILD.RSH                      */
/* ---------------------------------------- */
/* Programm: CPXBUILD.PRG      Versie 1.00  */
/* (C) 1991 by MAXON Computer               */
/* Auteurs : Uwe Hax & Oliver Scholz        */
/* Van RCS vervaardigde (en gemodificeerde) */
/* Include file                             */
/********************************************/


WORD image[48];

BITBLK bitblk[] = 
{
  image, 6, 24, 0, 0, 1
};


TEDINFO tedinfo[] =
{
  /* Tedinfo 0 */
  "(c) 1991 by Oliver Scholz & Uwe Hax", "", "",
  5,6, 0, 0x1180, 0x0, -1, 36,1,
  /* Tedinfo 1 */
  "________________",
  "CPX-Naam: ________________",
  "XXXXXXXXXXXXXXXX",3, 6, 0, 0x1180, 0x0, -1,
  17,27,
  /* Tedinfo 2 */
  "____", "ID: ____", "XXXX", 3, 6, 2, 0x1180,
  0x0,-1, 5,9,
  /* Tedinfo 3*/
  "____________", "Naam: ____________",
  "XXXXXXXXXXXX", 3, 6, 0, 0x1180, 0x0, -1,13,
  19,
  /* Tedinfo 4 */
  "____", "Version: __.__","9999", 3, 6, 2,
  0x1180, 0x0, -1, 5,15
};


OBJECT object[] =
{
  -1,1, 26, G_BOX, NONE, OUTLINED, 0x1101L, 12,
  1538, 39,20,
  2, -1, -1, G_STRING, NONE, NORMAL,
  (LONG)"CPX-Building-Tool", 11,1, 17,1,
  3, -1, -1, G_TEXT, NONE, NORMAL,
  (LONG)&tedinfo[0], 774,770, 538,1536,
  4, -1, -1, G_FTEXT, EDITABLE, NORMAL,
  (LONG)&tedinfo[1], 6,260, 27,1,
  5, -1, -1, G_STRING, NONE, NORMAL,
  (LONG)"Textkleur:", 6,773, 10,1,
  6, -1, -1, G_BOXCHAR, TOUCHEXIT, NORMAL,
  0x4FF1100L, 20,773, 2,1,
  7, -1, -1, G_BOXCHAR, NONE, NORMAL,
  0x31FF1100L, 278,773, 3,1,
  8, -1, -1, G_BOXCHAR, TOUCHEXIT, NORMAL,
  0x3FF1100L, 537,773, 2,1,
  9, -1, -1, G_FBOXTEXT, EDITABLE, NORMAL,
  (LONG)&tedinfo[2], 24,7, 1806,1,
  10, -1, -1, G_FBOXTEXT, EDITABLE, NORMAL,
  (LONG)&tedinfo[4], 1815,1288, 1806,257,
  20, 11, 19, G_BOX, NONE, OUTLINED, 0xFF1101L,
  1,263, 1813, 1289,
  13, 12, 12, G_BOX, NONE, NORMAL, 0x1100L, 14,1,
  262,515,
  11, -1, -1, G_IMAGE, NONE, NORMAL, (LONG)bitblk,
  0,0, 6,2,
  14, -1, -1, G_STRING, NONE, NORMAL,
  (LONG)"Kleur:", 15,1540, 6,1,
  15, -1, -1, G_BOXCHAR, TOUCHEXIT, NORMAL,
  0x4FF1100L, 14,6, 2,1,
  16, -1, -1, G_BOXCHAR, NONE, NORMAL,
  0x31FF1100L, 16,6, 3,1,
  17, -1, -1, G_BOXCHAR, TOUCHEXIT, NORMAL,
  0x3FF1100L, 19,6, 2,1,
  18, -1, -1, G_FTEXT, EDITABLE, NORMAL,
  (LONG)&tedinfo[3], 2,1032, 18,1,
  19, -1, -1, G_BUTTON, 0x41, NORMAL,
  (LONG)"Invers", 1793,263, 9,1,
  10, -1, -1, G_BOX, TOUCHEXIT, OUTLINED,
  0xFF1100L, 1536,512, 12,518,
  21, -1, -1, G_STRING, NONE, NORMAL,
  (LONG)"Flags", 24,11, 6,1,
  22, -1, -1, G_BUTTON, SELECTABLE, NORMAL,
  (LONG)"Set-Only", 25,1548, 9,1,
  23, -1, -1, G_BUTTON, SELECTABLE, NORMAL,
  (LONG)"Bootinit", 1816,782, 9,1,
  24, -1, -1, G_BUTTON, SELECTABLE, NORMAL,
  (LONG)"Resident", 1560,16, 9,1,
  25, -1, -1, G_BUTTON, 0x5, NORMAL,
  (LONG)"Load", 1,18, 8,1,
  26, -1, -1, G_BUTTON, 0x7, NORMAL,
  (LONG)"Build", 19,18, 8,1,
  0, -1, -1, G_BUTTON, 0x25, NORMAL,
  (LONG)"Stoppen", 29,18, 8,1,
};


struct foobar
{
  WORD dummy;
  WORD *image;
} imdope[]={
			 0, image
			};


#define NUM_OBS 27