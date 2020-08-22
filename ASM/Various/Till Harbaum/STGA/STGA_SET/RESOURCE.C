/**************************************************/
/*** This file was created by RSC2C Version 1.0 ***/
/***          (c) 1992 by Guido Faber           ***/
/**************************************************/


TEDINFO tree0_ted[] =
  {
  "STGA-Boot-Konfiguration", "", "", 3, 6, 2, 4480, 0, -1, 24, 1,
  "V1.1   (c) 1997 by Till Harbaum", "", "", 5, 6, 2, 4992, 0, -1, 32, 1,
  "Aus", "", "", 3, 6, 2, 4480, 0, -1, 4, 1,
  "Color", "", "", 3, 6, 2, 4480, 0, -1, 6, 1,
  "Aus", "", "", 3, 6, 2, 4480, 0, -1, 4, 1
  }; /* tree0_ted */

OBJECT tree0_obj[] =
  {
  -1, 1, 16, G_BOX, NONE, NORMAL, 0x1141L, 0, 0, 32, 11,
  4, 2, 3, G_BOX, NONE, NORMAL, 0xFF1100L, 768, 768, 287, 2561,
  3, -1, -1, G_TEXT, NONE, NORMAL, &tree0_ted[0], 1027, 256, 280, 1,
  1, -1, -1, G_TEXT, NONE, NORMAL, &tree0_ted[1], 260, 513, 535, 1536,
  6, 5, 5, G_BOX, NONE, NORMAL, 0xFF1100L, 0, 265, 523, 3841,
  4, -1, -1, G_BUTTON, SELECTABLE|EXIT, NORMAL, "Reboot", 1025, 2048, 8, 1,
  9, 7, 8, G_BOX, NONE, NORMAL, 0xFF1100L, 779, 265, 1300, 3841,
  8, -1, -1, G_BUTTON, SELECTABLE|DEFAULT|EXIT, NORMAL, "OK", 769, 2048, 8, 1,
  6, -1, -1, G_BUTTON, SELECTABLE|EXIT, NORMAL, "Abbruch", 523, 2048, 8, 1,
  16, 10, 15, G_BOX, NONE, NORMAL, 0xFF1100L, 768, 258, 287, 1027,
  11, -1, -1, G_BOXTEXT, TOUCHEXIT, SHADOWED, &tree0_ted[2], 1045, 1536, 1032, 1,
  12, -1, -1, G_STRING, NONE, NORMAL, "STGA-Modul", 1, 1792, 1290, 1,
  13, -1, -1, G_BOXTEXT, TOUCHEXIT, SHADOWED, &tree0_ted[3], 1045, 3585, 1032, 1,
  14, -1, -1, G_STRING, NONE, NORMAL, "Grafikkarte:", 1, 3585, 12, 1,
  15, -1, -1, G_STRING, NONE, NORMAL, "keine", 14, 3585, 6, 1,
  9, -1, -1, G_STRING, NONE, NORMAL, "V0.0", 14, 1792, 6, 1,
  0, 17, 19, G_BOX, NONE, NORMAL, 0xFF1100L, 768, 2309, 287, 1027,
  18, -1, -1, G_BUTTON, TOUCHEXIT, SHADOWED, "123456789012345678901234", 257, 3585, 1820, 1,
  19, -1, -1, G_STRING, NONE, NORMAL, "STGA-VDI", 1, 1536, 17, 1,
  16, -1, -1, G_BOXTEXT, LASTOB|TOUCHEXIT, SHADOWED, &tree0_ted[4], 1045, 1536, 1032, 1
  }; /* tree0_obj */

