#include "hland.h"

/*
  legenda:
  0: air
  1: solid
  2: forced down right
  3: forced down left
*/
char y_info[]=
{
  SOLID,    /* 00 */
  SOLID,    /* 01 */
  SOLID,    /* 02 */
  SOLID,    /* 03 */
  SOLID,    /* 04 */
  SOLID,    /* 05 */ /* kan ook doorwaadbaar zand zijn */
  SOLID,    /* 06 */
  SOLID,    /* 07 */
  SOLID,    /* 08 */ /* steen */
  SOLID,    /* 09 */ /* steen */
  FD_LEFT,  /* 10 zandglijbaan naar links */
  FD_RIGHT, /* 11 glijbaan naar rechts */
  FD_LEFT,  /* 12 glijbaan naar links */
  FD_RIGHT, /* 13 zandglijbaan naar rechts */
  AIR, /* 14 */
  AIR, /* 15 leeg flesje */
  AIR, /* 16 doorwaadbaar zand */
  AIR, /* 17 */
  SOLID, /* 18 steen in zand */
  SOLID, /* 19 steen in zand */
  AIR, /* 20 */
  AIR, /* 21 */
  AIR, /* 22 */
  AIR, /* 23 nog meer lucht */
  AIR, /* 24 */
  AIR, /* 25 */
  AIR, /* 26 */
  AIR, /* 27 */
  AIR, /* 29 */
  AIR, /* 29 zand met een patchje gras, is niet zeker 0 */
  AIR, /* 30 pin */
  AIR, /* 31 plafond, niet zeker 0 */
  AIR, /* 32 */
  AIR, /* 33 benen mannetje */
  AIR, /* 34 */
  AIR, /* 35 */
  AIR, /* 36 */
  AIR, /* 37 */
  AIR, /* 38 start pinnen */
  AIR, /* 39 */
  AIR, /* 40 */
  AIR, /* 41 */
  AIR, /* 42 */
  AIR, /* 43 */
  AIR, /* 44 */
  AIR, /* 45 doos */
  AIR, /* 46 */
  AIR, /* 47 */
  AIR, /* 48 */
  AIR, /* 49 */
  AIR, /* 50 */
  AIR, /* 51 */
  AIR, /* 52 */
  AIR, /* 53 einde bloem */
  AIR, /* 54 zand met gat */
  AIR, /* 55 zand met gat */
  AIR, /* 56 zand met gat */
  AIR, /* 57 zand met gat */
  AIR, /* 58 zand met gat */
  AIR, /* 59 nog meer lucht, deze is voor pinnen */
  AIR, /* 60 */
  AIR, /* 61 */
  AIR, /* 62 */
  AIR, /* 63 */
  AIR, /* 64 */
  AIR, /* 65 */
  AIR, /* 66 */
  AIR, /* 67 */
  AIR, /* 68 */
  AIR, /* 69 */
  AIR, /* 70 start teleport */
  AIR, /* 72 */
  AIR, /* 73 */
  AIR, /* 74 */
  AIR, /* 75 */
  AIR, /* 76 start zand met bobbels */
  AIR, /* 77 */
  AIR, /* 78 */
  AIR, /* 79 */
  AIR, /* 80 */
  AIR, /* 81 */
  AIR, /* 82 */
  AIR, /* 83 */
  AIR, /* 84 */
  AIR, /* 85 slak */
  AIR, /* 86 */
  AIR, /* 87 */
  AIR, /* 88 */
  AIR, /* 89 */
  AIR, /* 90 */
  AIR, /* 91 */
  AIR, /* 92 */
  AIR, /* 93 */
  AIR, /* 94 */
  AIR, /* 95 */
  AIR, /* 96 teleport */
  AIR, /* 97 teleport */
  AIR, /* 98 teleport */
  AIR, /* 99 */
  AIR, /* 100 */
  AIR, /* 101 */
  AIR, /* 102 */
  AIR, /* 103 */
  AIR, /* 104 */
  AIR, /* 105 */
  AIR, /* 106 */
  AIR, /* 107 einde bloem*/
  AIR, /* 108 aas */
  AIR, /* 109 koning */
  AIR, /* 110 queen */
  AIR, /* 111 jack */
  AIR, /* 112 start flesjes */
  AIR, /* 113 flesje */
  AIR, /* 114 flesje */
  AIR, /* 115 flesje */
  AIR, /* 116 flesje */
  AIR, /* 117 flesje */
  AIR, /* 118 flesje */
  AIR, /* 119 flesje */
  AIR, /* 120 eerste muntje */
  AIR, /* 121 muntje */
  AIR, /* 122 muntje */
  AIR, /* 123 muntje */
  AIR, /* 124 muntje */
  AIR, /* 125 muntje */
  AIR, /* 126 muntje */
  AIR, /* 127 muntje */
};

/*
  leganda:
  00: air
  01: solid
  02: fles
  03: punt
  04: munt
  05: Aas
  06: Koning
  07: Queen
  08: Jack
  09: Teleport A
  10: teleport B
  11: teleport C
*/

char x_info[]=
{
  AIR, /* 00 */
  AIR, /* 01 */
  AIR, /* 02 */
  AIR, /* 03 */
  SOLID, /* 04 steen */
  SOLID, /* 05 */ /* kan ook doorwaadbaar zand zijn */
  AIR, /* 06 */
  AIR, /* 07 */
  AIR, /* 08 */ /* steen */
  AIR, /* 09 */ /* steen */
  AIR, /* 10 zandglijbaan naar links */
  AIR, /* 11 glijbaan naar rechts */
  AIR, /* 12 glijbaan naar links */
  AIR, /* 13 zandglijbaan naar rechts */
  AIR, /* 14 */
  AIR, /* 15 leeg flesje */
  AIR, /* 16 doorwaadbaar zand */
  AIR, /* 17 */
  AIR, /* 18 steen in zand */
  AIR, /* 19 steen in zand */
  AIR, /* 20 */
  AIR, /* 21 */
  AIR, /* 22 */
  AIR, /* 23 nog meer lucht */
  AIR, /* 24 */
  AIR, /* 25 */
  AIR, /* 26 */
  AIR, /* 27 */
  AIR, /* 29 */
  AIR, /* 29 zand met een patchje gras, is niet zeker 0 */
  PUNT, /* 30 pin */
  AIR, /* 31 plafond, niet zeker 0 */
  AIR, /* 32 */
  AIR, /* 33 benen mannetje */
  AIR, /* 34 */
  AIR, /* 35 */
  AIR, /* 36 */
  AIR, /* 37 */
  PUNT, /* 38 start pinnen */
  PUNT, /* 39 */
  PUNT, /* 40 */
  PUNT, /* 41 */
  PUNT, /* 42 */
  PUNT, /* 43 */
  PUNT, /* 44 */
  AIR, /* 45 doos */
  AIR, /* 46 */
  AIR, /* 47 */
  AIR, /* 48 */
  AIR, /* 49 */
  AIR, /* 50 */
  AIR, /* 51 */
  AIR, /* 52 */
  AIR, /* 53 einde bloem */
  AIR, /* 54 zand met gat */
  AIR, /* 55 zand met gat */
  AIR, /* 56 zand met gat */
  AIR, /* 57 zand met gat */
  AIR, /* 58 zand met gat */
  PUNT, /* 59 nog meer lucht, deze is voor pinnen */
  AIR, /* 60 */
  AIR, /* 61 */
  AIR, /* 62 */
  AIR, /* 63 */
  AIR, /* 64 */
  AIR, /* 65 */
  AIR, /* 66 */
  AIR, /* 67 */
  AIR, /* 68 */
  AIR, /* 69 */
  AIR, /* 70 start teleport */
  AIR, /* 71 */
  TPT_A, /* 72 teleport trigger A */
  AIR, /* 73 */
  AIR, /* 74 */
  TPT_B, /* 75 teleport trigger B */
  AIR, /* 76 start zand met bobbels */
  AIR, /* 77 */
  AIR, /* 78 */
  AIR, /* 79 */
  AIR, /* 80 */
  AIR, /* 81 */
  AIR, /* 82 */
  AIR, /* 83 */
  AIR, /* 84 */
  AIR, /* 85 slak */
  AIR, /* 86 */
  AIR, /* 87 */
  AIR, /* 88 */
  AIR, /* 89 */
  AIR, /* 90 */
  AIR, /* 91 */
  AIR, /* 92 */
  AIR, /* 93 */
  AIR, /* 94 */
  AIR, /* 95 */
  AIR, /* 96 teleport */
  AIR, /* 97 teleport */
  TPT_C, /* 98 teleport trigger C */
  AIR, /* 99 */
  AIR, /* 100 */
  AIR, /* 101 */
  AIR, /* 102 */
  AIR, /* 103 */
  AIR, /* 104 */
  AIR, /* 105 */
  AIR, /* 106 */
  AIR, /* 107 einde bloem*/
  AAS, /* 108 aas */
  KONING, /* 109 koning */
  QUEEN, /* 110 queen */
  JACK, /* 111 jack */
  FLES, /* 112 start flesjes */
  FLES, /* 113 flesje */
  FLES, /* 114 flesje */
  FLES, /* 115 flesje */
  FLES, /* 116 flesje */
  FLES, /* 117 flesje */
  FLES, /* 118 flesje */
  FLES, /* 119 flesje */
  MUNT, /* 120 eerste muntje */
  MUNT, /* 121 muntje */
  MUNT, /* 122 muntje */
  MUNT, /* 123 muntje */
  MUNT, /* 124 muntje */
  MUNT, /* 125 muntje */
  MUNT, /* 126 muntje */
  MUNT, /* 127 muntje */
};

/*
  Map colors:
  legenda:
  C_LUCHT:   lucht
  C_GROND:   grond
  C_FLONDER: houten flonder
  C_GRAS:    gras
  C_STEEN:   steen
  C_MUNT:    munt
  C_DEUR:    deur
  C_FLES:    fles (vol of leeg)
*/
  
char color_info[]=
{
  C_FLONDER, /* 00 */
  C_FLONDER, /* 01 */
  C_GRAS, /* 02 */
  C_GRAS, /* 03 */
  C_STEEN, /* 04 steen */
  C_GROND, /* 05 */ /* kan ook doorwaadbaar zand zijn */
  C_GRAS, /* 06 */
  C_GRAS, /* 07 */
  C_STEEN, /* 08 */ /* steen */
  C_STEEN, /* 09 */ /* steen */
  C_GRAS, /* 10 zandglijbaan naar links */
  C_GRAS, /* 11 glijbaan naar rechts */
  C_GRAS, /* 12 glijbaan naar links */
  C_GRAS, /* 13 zandglijbaan naar rechts */
  C_LUCHT, /* 14 */
  C_FLES, /* 15 leeg flesje */
  C_GROND, /* 16 doorwaadbaar zand */
  C_GROND, /* 17 */
  C_STEEN, /* 18 steen in zand */
  C_STEEN, /* 19 steen in zand */
  C_LUCHT, /* 20 */
  C_LUCHT, /* 21 */
  C_GROND, /* 22 */
  C_LUCHT, /* 23 nog meer lucht */
  C_LUCHT, /* 24 */
  C_LUCHT, /* 25 */
  C_LUCHT, /* 26 */
  C_LUCHT, /* 27 */
  C_LUCHT, /* 29 */
  C_GROND, /* 29 zand met een patchje gras, is niet zeker 0 */
  C_LUCHT, /* 30 pin */
  C_GROND, /* 31 plafond, niet zeker 0 */
  C_LUCHT, /* 32 */
  C_LUCHT, /* 33 benen mannetje */
  C_GROND, /* 34 */
  C_GROND, /* 35 */
  C_GROND, /* 36 */
  C_GROND, /* 37 */
  C_LUCHT, /* 38 start pinnen */
  C_LUCHT, /* 39 */
  C_LUCHT, /* 40 */
  C_LUCHT, /* 41 */
  C_LUCHT, /* 42 */
  C_LUCHT, /* 43 */
  C_LUCHT, /* 44 */
  C_LUCHT, /* 45 doos */
  C_LUCHT, /* 46 */
  C_LUCHT, /* 47 */
  C_LUCHT, /* 48 */
  C_LUCHT, /* 49 */
  C_LUCHT, /* 50 */
  C_LUCHT, /* 51 */
  C_LUCHT, /* 52 */
  C_LUCHT, /* 53 einde bloem */
  C_GROND, /* 54 zand met gat */
  C_GROND, /* 55 zand met gat */
  C_GROND, /* 56 zand met gat */
  C_GROND, /* 57 zand met gat */
  C_GROND, /* 58 zand met gat */
  C_LUCHT, /* 59 nog meer lucht, deze is voor pinnen */
  C_LUCHT, /* 60 */
  C_LUCHT, /* 61 */
  C_LUCHT, /* 62 */
  C_LUCHT, /* 63 */
  C_LUCHT, /* 64 */
  C_LUCHT, /* 65 */
  C_LUCHT, /* 66 */
  C_LUCHT, /* 67 */
  C_LUCHT, /* 68 */
  C_LUCHT, /* 69 */
  C_DEUR, /* 70 start teleport */
  C_DEUR, /* 71 */
  C_DEUR, /* 72 teleport trigger A */
  C_DEUR, /* 73 */
  C_DEUR, /* 74 */
  C_DEUR, /* 75 teleport trigger B */
  C_GROND, /* 76 start zand met bobbels */
  C_GROND, /* 77 */
  C_GROND, /* 78 */
  C_GROND, /* 79 */
  C_GROND, /* 80 */
  C_GROND, /* 81 */
  C_GROND, /* 82 */
  C_GROND, /* 83 */
  C_GROND, /* 84 */
  C_LUCHT, /* 85 slak */
  C_LUCHT, /* 86 */
  C_LUCHT, /* 87 */
  C_LUCHT, /* 88 */
  C_LUCHT, /* 89 */
  C_LUCHT, /* 90 */
  C_LUCHT, /* 91 */
  C_LUCHT, /* 92 */
  C_LUCHT, /* 93 */
  C_LUCHT, /* 94 */
  C_LUCHT, /* 95 */
  C_DEUR, /* 96 teleport */
  C_DEUR, /* 97 teleport */
  C_DEUR, /* 98 teleport trigger C */
  C_GROND, /* 99 */
  C_GROND, /* 100 */
  C_GROND, /* 101 */
  C_GROND, /* 102 */
  C_GROND, /* 103 */
  C_GROND, /* 104 */
  C_GROND, /* 105 */
  C_GROND, /* 106 */
  C_GROND, /* 107 einde bloem*/
  C_GROND, /* 108 aas */
  C_GROND, /* 109 koning */
  C_GROND, /* 110 queen */
  C_GROND, /* 111 jack */
  C_FLES, /* 112 start flesjes */
  C_FLES, /* 113 flesje */
  C_FLES, /* 114 flesje */
  C_FLES, /* 115 flesje */
  C_FLES, /* 116 flesje */
  C_FLES, /* 117 flesje */
  C_FLES, /* 118 flesje */
  C_FLES, /* 119 flesje */
  C_MUNT, /* 120 eerste muntje */
  C_MUNT, /* 121 muntje */
  C_MUNT, /* 122 muntje */
  C_MUNT, /* 123 muntje */
  C_MUNT, /* 124 muntje */
  C_MUNT, /* 125 muntje */
  C_MUNT, /* 126 muntje */
  C_MUNT, /* 127 muntje */
};


/* teleport tabel, (x,y) waarden */
int teleport[]=
{
  102,28,
  178,12,
  429,50,
  327,24,
  89,80,
  372,43,
  216,69,
  418,2,
  316,78
};
