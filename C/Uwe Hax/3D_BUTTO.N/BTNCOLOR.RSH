/***********************************************/
/* BTNCOLOR.RSH                                */
/*---------------------------------------------*/
/* Resource-Datei fÅr BTNCOLOR.C               */
/* Autor: Uwe Hax                              */
/* (C) 1993 by MAXON                           */
/***********************************************/

BYTE *rs_strings[] = 
{ "Hintergrund", "Verhalten von", "Farbe:",
  "Hellgrau ", "HineindrÅcken:", "Farbe Ñndern:",
  "Nein", "Nein", "(C)", "", "", "1993", "", "",
  "BY", "", "", "UWE HAX", "", "", "Test",
  "Vergrîûerung:", "(ALLE 3D-OBJEKTE)", "", "",
  "hor: 0", "vert: 0", "Sichern", "Ok","Abbruch",
  "Das Verhalten von", "3D-Buttons lÑût sich",
  "erst ab AES-Version", "3.40 einstellen.",
  "Ok", "Aktivator", "Indikator","Ok"
};

WORD IMAG0[] = 
{ 0x007F, 0xFE00, 0x00C0, 0x0300, 0x01BF, 0xFD80,
  0x037F, 0xFEC0, 0x06FF, 0xFF60, 0x0DFF, 0xFFB0,
  0x1BFF, 0xFFD8, 0x37FF, 0xFFEC, 0x6FFF, 0xFFF6,
  0xDFFF, 0xFFFB, 0xB181, 0x860D, 0xA081, 0x0205,
  0xA4E7, 0x3265, 0xA7E7, 0x3265, 0xA3E7, 0x3265,
  0xB1E7, 0x3205, 0xB8E7, 0x320D, 0xBCE7, 0x327D,
  0xA4E7, 0x327D, 0xA0E7, 0x027D, 0xB1E7, 0x867D,
  0xBFFF, 0xFFFD, 0xDFFF, 0xFFFB, 0x6FFF, 0xFFF6,
  0x37FF, 0xFFEC, 0x1BFF, 0xFFD8, 0x0DFF, 0xFFB0,
  0x06FF, 0xFF60, 0x037F, 0xFEC0, 0x01BF, 0xFD80,
  0x00C0, 0x0300, 0x007F, 0xFE00
};

LONG rs_frstr[] = 
{ 0 
};

BITBLK rs_bitblk[] = 
{ 0L, 4, 32, 0, 0, 1
};

LONG rs_frimg[] = 
{ 0
};

ICONBLK rs_iconblk[] = 
{ 0
};

TEDINFO rs_tedinfo[] = 
{ 8L, 9L, 10L, 5, 6, 0, 0x1180, 0x0, -1, 4,1,
  11L, 12L, 13L, 5, 6, 0, 0x1180, 0x0, -1, 5,1,
  14L, 15L, 16L, 5, 6, 0, 0x1180, 0x0, -1, 3,1,
  17L, 18L, 19L, 5, 6, 0, 0x1180, 0x0, -1, 8,1,
  22L, 23L, 24L, 5, 6, 0, 0x1180, 0x0, -1, 18,1
};

OBJECT rs_object[] = 
{ -1, 1, 26, G_BOX, NONE, NORMAL, 0xFF1141L, 
  0,0, 288,11,
  4, 2, 3, G_BOX, NONE, NORMAL, 0xFF1101L, 
  768,768, 799,3841,
  3, -1, -1, G_BUTTON, TOUCHEXIT, SHADOWED, 0x0L,
  1295,1792, 14,1,
  1, -1, -1, G_STRING, NONE, NORMAL, 0x1L, 
  1,2048, 13,1,
  13, 5, 8, G_BOX, NONE, NORMAL, 0xFF1101L, 
  768,1538, 1304,1540,
  6, -1, -1, G_STRING, NONE, NORMAL, 0x2L, 
  1,1536, 6,1,
  7, -1, -1, G_BOX, NONE, SHADOWED, 0xFF1175L, 
  1035,768, 2,1,
  8, -1, -1, G_BUTTON, TOUCHEXIT, SHADOWED, 0x3L,
  1293,768, 10,1,
  4, 9, 12, G_BOX, NONE, NORMAL, 0x1101L, 
  512,2305, 24,3074,
  10, -1, -1, G_STRING, NONE, NORMAL, 0x4L, 
  1536,512, 14,1,
  11, -1, -1, G_STRING, NONE, NORMAL, 0x5L, 
  1536,2049, 13,1,
  12, -1, -1, G_BUTTON, TOUCHEXIT, SHADOWED,0x6L,
  783,2049, 8,1,
  8, -1, -1, G_BUTTON, TOUCHEXIT, SHADOWED, 0x7L,
  783,256, 8,1,
  18, 14, 17, G_BOX, NONE, NORMAL, 0xFF1101L, 
  1305,1538, 262,1538,
  15, -1, -1, G_TEXT, NONE, NORMAL, 0x0L, 
  2,512, 1794,3072,
  16, -1, -1, G_TEXT, NONE, NORMAL, 0x1L, 
  1025,2560, 3,3072,
  17, -1, -1, G_TEXT, NONE, NORMAL, 0x2L,
  770,769, 770,2560,
  13, -1, -1, G_TEXT, NONE, NORMAL, 0x3L, 
  768,2305, 517,3072,
  19, -1, -1, G_BUTTON, 0x605, NORMAL, 0x14L, 
  1561,2309, 1797,1,
  24, 20, 23, G_BOX, NONE, NORMAL, 0xFF1101L, 
  768,519, 799,3841,
  21, -1, -1, G_STRING, NONE, NORMAL, 0x15L, 
  1536,512, 13,1,
  22, -1, -1, G_TEXT, NONE, NORMAL, 0x4L, 
  1792,513, 1548,2816,
  23, -1, -1, G_STRING, NONE, NORMAL, 0x19L, 
  1039,1792, 6,1,
  19, -1, -1, G_STRING, NONE, NORMAL, 0x1AL, 
  791,1792, 7,1,
  26, 25, 25, G_BOX, NONE, NORMAL, 0xFF1101L, 
  0,1033, 11,3073,
  24, -1, -1, G_BUTTON, 0x605, NORMAL, 0x1BL, 
  257,1536, 1544,1,
  0, 27, 28, G_BOX, NONE, NORMAL, 0xFF1101L, 
  11,1033, 21,3073,
  28, -1, -1, G_BUTTON, 0x607, NORMAL, 0x1CL, 
  257,1536, 1544,1,
  26, -1, -1, G_BUTTON, 0x625, NORMAL, 0x1DL, 
  779,1536, 1544,1,
  -1, 1, 6, G_BOX, 0x400, OUTLINED, 0x21100L, 
  0,0, 1052,7,
  2, -1, -1, G_IMAGE, NONE, NORMAL, 0x0L, 
  1025,2048, 4,2,
  3, -1, -1, G_STRING, NONE, NORMAL, 0x1EL, 
  7,2048, 17,1,
  4, -1, -1, G_STRING, NONE, NORMAL, 0x1FL, 
  7,2049, 20,1,
  5, -1, -1, G_STRING, NONE, NORMAL, 0x20L, 
  7,2050, 19,1,
  6, -1, -1, G_STRING, NONE, NORMAL, 0x21L, 
  7,2051, 16,1,
  0, -1, -1, G_BUTTON, 0x627, NORMAL, 0x22L, 
  11,2053, 8,1,
  -1, 1, 3, G_BOX, 0x400, OUTLINED, 0x21100L, 
  0,0, 20,8,
  2, -1, -1, G_BUTTON, 0x601, NORMAL, 0x23L, 
  4,3, 12,1,
  3, -1, -1, G_BUTTON, 0x201, NORMAL, 0x24L, 
  4,1, 12,1,
  0, -1, -1, G_BUTTON, 0x27, NORMAL, 0x25L, 
  5,6, 10,1
};

LONG rs_trindex[] = 
{ 0L, 29L,36L
};

struct foobar 
{ WORD    dummy;
  WORD    *image;
} rs_imdope[] = { 0, &IMAG0[0] };

#define NUM_FRSTR 0
#define NUM_FRIMG 0
#define NUM_OBS 40
#define NUM_TREE 3


