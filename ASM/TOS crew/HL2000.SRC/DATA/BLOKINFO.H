typedef unsigned int word;
typedef unsigned char byte;

/*
  animaties voor animatie lengte 16

  00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15
M 78 79 7a 7b 7b 7a 79 78 78 79 7a 7b 7b 7a 79 78
F 70 71 72 71 70 77 76 77 70 71 72 71 70 77 76 77
S 1e 26 27 28 29 2a 2b 2c 3b 2c 2b 2a 29 28 27 26

*/

byte munt_ani[]=
{
  0x78,
  0x79,
  0x7a,
  0x7b,
  0x7b,
  0x7a,
  0x79,
  0x78,
  0x78,
  0x79,
  0x7a,
  0x7b,
  0x7b,
  0x7a,
  0x79,
  0x78,
};

char fles_ani[]=
{
  0x70,
  0x71,
  0x72,
  0x71,
  0x70,
  0x77,
  0x76,
  0x77,
  0x70,
  0x71,
  0x72,
  0x71,
  0x70,
  0x77,
  0x76,
  0x77,
};

char punt_ani[]=
{
  0x1e,
  0x26,
  0x27,
  0x28,
  0x29,
  0x2a,
  0x2b,
  0x2c,
  0x3b,
  0x2c,
  0x2b,
  0x2a,
  0x29,
  0x28,
  0x27,
  0x26,
};


/* game defines */

#define AIR 0
#define SOLID 1
#define FD_RIGHT 2
#define FD_LEFT 3
#define FLES 2
#define PUNT 3
#define MUNT 4
#define AAS 5
#define KONING 6
#define QUEEN 7
#define JACK 8
#define TPT_A 9
#define TPT_B 10
#define TPT_C 11

#define C_LUCHT   1 /* lucht */
#define C_GROND   2 /* grond */
#define C_FLONDER 3 /* houten flonder */
#define C_GRAS    4 /* gras */
#define C_STEEN   5 /* steen */
#define C_MUNT    6 /* munt */
#define C_DEUR    7 /* deur */
#define C_FLES    2 /* fles (vol of leeg) */

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

word gamecolors[]=
{
  0x000,
  0xfff,
  0xca9,
  0xdba,
  0xe00,
  0x8b8,
  0x0d8,
  0x8f8,
  0xff8,
  0xdde,
  0xc3c,
  0xbab,
  0x21a,
  0x88b,
  0x318,
  0xfff,
};

word mapcolors[]=
{
  0x000,  /* achtergrond kleur */
  0x002,  /* lucht kleur */
  0xba9,  /* grond kleur, fles kleur */
  0xcc8,  /* flonder kleur */
  0x8f8,  /* gras kleur */
  0xccc,  /* steen kleur */
  0xff8,  /* munt kleur */
  0xf8f,  /* deur kleur */
  0xff8,  /* not used */
  0xdde,
  0xcbc,
  0xbab,
  0xa9a,
  0x88b,
  0x318,
  0xfff,
};

word menucolors[]=
{
  0x888,
  0xfff,
  0xc21,
  0xd3a,
  0xe00,
  0x030,
  0x0d8,
  0x0f8,
  0xff8,
  0xdde,
  0xc3c,
  0x323,
  0x21a,
  0x003,
  0x318,
  0xfff,
};

char block_2_block[]=
{ /* conversie info, welke blokken zijn aan elkaar gelijk */
  0x00,    /* 00 */
  0x01,    /* 01 */
  0x02,    /* 02 */
  0x03,    /* 03 */
  0x04,    /* 04 */
  0x05,    /* 05 */ /* kan ook doorwaadbaar zand zijn */
  0x06,    /* 06 */
  0x07,    /* 07 */
  0x08,    /* 08 */ /* steen */
  0x09,    /* 09 */ /* steen */
  0x0a,    /* 10 zandglijbaan naar links */
  0x0b,    /* 11 glijbaan naar rechts */
  0x0c,    /* 12 glijbaan naar links */
  0x0d,    /* 13 zandglijbaan naar rechts */
  0x0e, /* 14 */
  0x0f, /* 15 leeg flesje */
  0x05, /* 16 doorwaadbaar zand */
  0x11, /* 17 */
  0x12, /* 18 steen in zand */
  0x13, /* 19 steen in zand */
  0x14, /* 20 */
  0x15, /* 21 */
  0x16, /* 22 */
  0x0e, /* 23 nog meer lucht */
  0x18, /* 24 */
  0x19, /* 25 */
  0x1a, /* 26 */
  0x1b, /* 27 */
  0x1c, /* 29 */
  0x1d, /* 29 zand met een patchje gras, is niet zeker 0 */
  0x1e, /* 30 pin */
  0x1f, /* 31 plafond, niet zeker 0 */
  0x20, /* 32 */
  0x21, /* 33 benen mannetje */
  0x22, /* 34 */
  0x23, /* 35 */
  0x24, /* 36 */
  0x25, /* 37 */
  0x26, /* 38 start pinnen */
  0x27, /* 39 */
  0x28, /* 40 */
  0x29, /* 41 */
  0x2a, /* 42 */
  0x2b, /* 43 */
  0x2c, /* 44 */
  0x2d, /* 45 doos */
  0x2e, /* 46 */
  0x2f, /* 47 */
  0x30, /* 48 */
  0x31, /* 49 */
  0x32, /* 50 */
  0x33, /* 51 */
  0x34, /* 52 */
  0x35, /* 53 einde bloem */
  0x36, /* 54 zand met gat */
  0x37, /* 55 zand met gat */
  0x38, /* 56 zand met gat */
  0x39, /* 57 zand met gat */
  0x05, /* 58 zand met gat */
  0x0e, /* 59 nog meer lucht, deze is voor pinnen */
  0x3c, /* 60 */
  0x3d, /* 61 */
  0x3e, /* 62 */
  0x3f, /* 63 */
  0x40, /* 64 */
  0x41, /* 65 */
  0x42, /* 66 */
  0x43, /* 67 */
  0x44, /* 68 */
  0x45, /* 69 */
  0x46, /* 70 start teleport */
  0x47, /* 71 */
  0x48, /* 72 */
  0x49, /* 73 */
  0x4a, /* 74 */
  0x4b, /* 75 start zand met bobbels */
  0x4c, /* 76 */
  0x4d, /* 77 */
  0x4e, /* 78 */
  0x4f, /* 79 */
  0x50, /* 80 */
  0x51, /* 81 */
  0x52, /* 82 */
  0x53, /* 83 */
  0x54, /* 84 slak */
  0x55, /* 85 */
  0x56, /* 86 */
  0x57, /* 87 */
  0x58, /* 88 */
  0x59, /* 89 */
  0x5a, /* 90 */
  0x5b, /* 91 */
  0x5c, /* 92 */
  0x5d, /* 93 */
  0x5e, /* 94 */
  0x5f, /* 95 teleport */
  0x60, /* 96 teleport */
  0x61, /* 97 teleport */
  0x62, /* 98 */
  0x63, /* 99 */
  0x64, /* 100 */
  0x65, /* 101 */
  0x66, /* 102 */
  0x67, /* 103 */
  0x68, /* 104 */
  0x69, /* 105 */
  0x6a, /* 106 */
  0x6b, /* 107 einde bloem*/
  0x6c, /* 108 aas */
  0x6d, /* 109 koning */
  0x6e, /* 110 queen */
  0x6f, /* 111 jack */
  0x70, /* 112 start flesjes */
  0x71, /* 113 flesje */
  0x72, /* 114 flesje */
  0x73, /* 115 flesje */
  0x74, /* 116 flesje */
  0x75, /* 117 flesje */
  0x76, /* 118 flesje */
  0x77, /* 119 flesje */
  0x78, /* 120 eerste muntje */
  0x79, /* 121 muntje */
  0x7a, /* 122 muntje */
  0x7b, /* 123 muntje */
  0x7c, /* 124 muntje */
  0x7d, /* 125 muntje */
  0x7e, /* 126 muntje */
  0x7f, /* 127 muntje */
};
