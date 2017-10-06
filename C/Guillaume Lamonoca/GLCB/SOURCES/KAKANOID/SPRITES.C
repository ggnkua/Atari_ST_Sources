#include "header.h"

#define DEC(c) (int)((c<'A')?(c-'0'):(  (c<'a')?(c-'A'+10):(  c-'a'+10  )  ))

typedef void *bloc;

unsigned int Jeupal[16]=
{
	0x0000,0x5F60,0x6FF0,0x30F0,0x5F4A,0x3F00,0x1C00,0x2777,
	0x4BBB,0x15BC,0x249C,0x338C,0x425C,0x513C,0x600C,0x8FFF
};

char *fond[]=
{
	"ccccceeaaaaaaccbbbbb",
	"ccceee9aaaaaabcccbbb",
	"ceeeee99aaaabbcccccb",
	"deeee999aaaabbbccccd",
	"ddeee9999aabbbbcccdd",
	"ddee99999bcbbbbbccdd",
	"ddde999bbbcccbbbcddd",
	"ddd99bbbbbcccccbbddd",
	"aaaccbbbbbccccceeaaa",
	"aaabcccbbbccceee9aaa",
	"aabbcccccbceeeee99aa",
	"aabbbccccddeeee999aa",
	"abbbbcccddddeee9999a",
	"cbbbbbccddddee99999b",
	"cccbbbcdddddde999bbb",
	"cccccbbdddddd99bbbbb",
	NULL,
};

char *fond2[]=
{
	"addddddddddddddddddd",
	"aeeeeeeeeeeFbeeeeeee",
	"aeeeeeeeeeecFeecceee",
	"aeeeeeeeeeecFcaaaFFF",
	"aeeeeeeeeecaFFFFFace",
	"aeeeeeeecFFFFFFaceee",
	"aeeecFFFFccaaaFceeee",
	"aFFFFceeeeecccFceeee",
	"aeeeeeeeeeeeeecFeeee",
	"aeeeeeeeeeeeeeeFeeee",
	"addddddddddddddddddd",
	"accccccccccccccccccc",
	"abbbbbbbbbbbbbbbbbbb",
	"aaaaaaaaaaaaaaaaaaaa",
	"abbbbbbbbbbbbbbbbbbb",
	"accccccccccccccccccc",
	NULL,
};
char *balle[]=  /* 8 en largeur */
{
	" ff ",
	"f99f",
	"f99f",
	" ff ",
        NULL
};

char *miniraq[]=
{
 " 55508888880555 ",
 " fff0ffffff0ff5 ",
 "f55508888880555f",
 " 555088888805550",
 " 555000000005550",
 "  00000000000000",
 "   00 000000 00 ",
 NULL
};

char *raqtir[]=  /* 32 en largeur */
{
	"    777 777777777777777777 777        ",
	"   79FF08888888888888888880FF97       ",
	"  F98880FFFFFFFFFFFFFFFFFF088898      ",
	" FF8888088888888888888888808888870    ",
	"FF885550555558888888855555055588770   ",
	"888557707777577777777577770885587700  ",
	" 855777077775777777775777707775570000 ",
	"   77770000050000000050000077770000000",
	"    0000000000000000000000000000000000",
	"      0000000000000000000000000000000 ",
	"        0000 00000000 0000000000000   ",
	NULL
};

char *raq_larg[]=  
{
	"         7777777777777777 5555        ",
	"         8888888888888888055555       ",
	"         ffffffffffffffff0ffff59      ",
	"         8888888888888888055555f900   ",
	"         ffffffffffffffff05555599000  ",
	"         7777777777777777055555900000 ",
	"         77777777777777770666660000000",
        "         00000000000000000666600000000",
	"         0000000000000000000000000000 ",
	"         000000000000000000000000000  ",
        "              0000000000000000 0000   ",
	NULL
};

char *raquette[]=  /* 32 en largeur */
{
	"   55555 7777777777777777 5555        ",
	"  55555508888888888888888055555       ",
	" 95fffff0ffffffffffffffff0ffff59      ",
	"9ff5555508888888888888888055555f900   ",
	"995555550ffffffffffffffff05555599000  ",
	" 955555507777777777777777055555900000 ",
	"  556666077777777777777770666660000000",
        "   66666000000000000000000666600000000",
	"       000000000000000000000000000000 ",
	"        0000000000000000000000000000  ",
        "         0000 0000000000000000 0000   ",
	NULL
};

char *tir[]=  /* 32 en largeur */
{
	"                                ",
	"       2                 2      ",
	"      2f2               2f2     ",
	"      2f2               2f2     ",
	"      2f2               2f2     ",
	"      2f2               2f2     ",
	"      2f2               2f2     ",
	"       2                 2      ",
	NULL
};

char *logo[]=  
{
 "   ffff8                8ffff8                8f        ffff8      ffff      ffff8       f    ",
 "   f5558               f8f5558               f8ff       f5558    ff5555ff    f5558      f58   ",
 "   f5558  f           f58f5558  f           f58f5f      f5558   f55555555f   f5558     f5558  ",
 "   f5558 f5f         f558f5558 f5f         f558f55f     f5558  f55555555558  f5558ffff8555558 ",
 "   f5558f555f       f5558f5558f555f       f5558f555f    f5558 f5555588555558 f5558f558 8555558",
 "   f5558555558     f55558f5558555558     f55558f5555f   f5558 f55588  885558 f5558f558  f5558 ",
 "   f555555558     f555558f555555558     f555558f55555f  f5558f55558    f55558f5558f558 f5558  ",
 "   f55555558     f555f558f55555558     f555f558f555555f f5558f5558      f5558f5558f558f5558   ",
 "   f5555558     f5558f558f5555558     f5558f558f5555555ff5558f5558      f5558f5558f5585558    ",
 "   f555558     f5558 f558f555558     f5558 f558f55555555f5558f55558    f55558f5558f555558     ",
 "   f5555558   f5558  f558f5555558   f5558  f558f5558555555558 f5558f  ff5558 f5558f55558      ",
 "   f55555558 f55555f f558f55555558 f55555f f558f5558855555558 f55555ff555558 f5558f5558       ",
 "   f558555558 f555558fff8f558555558 f555558fff8f8888 8555558   f55555555558  f558 f558        ",
 "   f58 85558   f5558     f58 85558   f5558            85558     8555555558   f58  f58         ",
 "   f8   858     f58      f8   858     f58              858       88555588    f8   f8          ",
 "   f     8       8       f     8       8                8          8888      f    f           ",
 NULL
};



char *bidule[]=  /* 8  en largeur */
{
	" 000000 ",
	" FF8777 ",
	"FF88777F",
	"FF88777F",
	"FF88777F",
	"FF88777F",
	"FF88777F",
	"FF88777F",
	" 770007 ",
	"FF88777F",
	" 770007 ",
	"FF88777F",
	" 770007 ",
	"FF88777F",
	" 770007 ",
	"FF88777F",
	"FF88777F",
	"FF88777F",
	"FF88777F",
	"FF88777F",
	"FF88777F",
	" 888777 ",
	" 000000 ",
	NULL
};

char *prime_raq[]=  /* 18  en largeur */
{
	" 88888888888888   ",
	"87FFFFFFFFFFFFF8  ",
	"8F777777777777780 ",
	"877777777777777800",
	"877777777777777800",
	"877777777777777800",
	"877777777777777800",
	" 88888888888888000",
	"  0000000000000000",
	"   000000000000000 ",
	NULL
};

char *prime_tir[]=  /* 18  en largeur */
{
	" 66666666666666   ",
	"65FFFFFFFFFFFFF6  ",
	"6F555555555555560 ",
	"655555555555555600",
	"655555555555555600",
	"655555555555555600",
	"655555555555555600",
	" 66666666666666000",
	"  0000000000000000",
	"   00000000000000 ",
	NULL
};

char *prime_colle[]=  /* 18  en largeur */
{
	" 77777777777777   ",
	"73FFFFFFFFFFFFF7  ",
	"7F333333333333370 ",
	"733333333333333700",
	"733333333333333700",
	"733333333333333700",
	"733333333333333700",
	" 77777777777777000",
	"  0000000000000000",
	"   00000000000000 ",
	NULL
};

char *prime_large[]=  /* 18  en largeur */
{
	" EEEEEEEEEEEEEE   ",
	"EDFFFFFFFFFFFFFE  ",
	"EFDDDDDDDDDDDDDE0 ",
	"EDDDDDDDDDDDDDDE00",
	"EDDDDDDDDDDDDDDE00",
	"EDDDDDDDDDDDDDDE00",
	"EDDDDDDDDDDDDDDE00",
	" EEEEEEEEEEEEEE000",
	"  0000000000000000",
	"   00000000000000 ",
	NULL
};

char *prime_lent[]=  /* 18  en largeur */
{
	" 66666666666666   ",
	"61FFFFFFFFFFFFF6  ",
	"6F111111111111160 ",
	"611111111111111600",
	"611111111111111600",
	"611111111111111600",
	"611111111111111600",
	" 66666666666666000",
	"  0000000000000000",
	"   00000000000000 ",
	NULL
};

char *prime_multi[]=  /* 18  en largeur */
{
	" BBBBBBBBBBBBBB   ",
	"B9FFFFFFFFFFFFFB  ",
	"BF9999999999999B0 ",
	"B99999999999999B00",
	"B99999999999999B00",
	"B99999999999999B00",
	"B99999999999999B00",
	" BBBBBBBBBBBBBB000",
	"  0000000000000000",
	"   00000000000000 ",
	NULL
};

char *prime_sortie[]=  /* 18  en largeur */
{
	" 55555555555555   ",
	"54FFFFFFFFFFFFF5  ",
	"5F444444444444450 ",
	"544444444444444500",
	"544444444444444500",
	"544444444444444500",
	"544444444444444500",
	" 55555555555555000",
	"  0000000000000000",
	"   00000000000000 ",
	NULL
};


/* Forme des primes pour monochrome */

char *prime_raq_m[]=  /* 18  en largeur */
{
	" 88888888888888   ",
	"80FFFFFFFFFFFFF8  ",
	"8F000000000000080 ",
	"80000FFFF000000800",
	"80000F000F00000800",
	"80000FFFF000000800",
	"80000F000F00000800",
	" 8888F888F88888000",
	"  0000000000000000",
	"   000000000000000 ",
	NULL
};

char *prime_tir_m[]=  /* 18  en largeur */
{
	" 66666666666666   ",
	"60FFFFFFFFFFFFF6  ",
	"6F000000000000060 ",
	"60000FFFFF00000600",
	"6000000F0000000600",
	"6000000F0000000600",
	"6000000F0000000600",
	" 666666F6666666000",
	"  0000000000000000",
	"   00000000000000 ",
	NULL
};

char *prime_colle_m[]=  /* 18  en largeur */
{
	" 77777777777777   ",
	"70FFFFFFFFFFFFF7  ",
	"7F000000000000070 ",
	"700000FF0000000700",
	"70000F00F000000700",
	"70000F000000000700",
	"70000F00F000000700",
	" 77777FF7777777000",
	"  0000000000000000",
	"   00000000000000 ",
	NULL
};

char *prime_large_m[]=  /* 18  en largeur */
{
	" 77777777777777   ",
	"70FFFFFFFFFFFFF7  ",
	"7F000000000000070 ",
	"70000F000000000700",
	"70000F000000000700",
	"70000F000000000700",
	"70000F000000000700",
	" 7777FFFF777777000",
	"  0000000000000000",
	"   00000000000000 ",
	NULL
};

char *prime_lent_m[]=  /* 18  en largeur */
{
	" 66666666666666   ",
	"60FFFFFFFFFFFFF6  ",
	"6F000000000000060 ",
	"600000000000000600",
	"600000000000000600",
	"600000000000000600",
	"600000000000000600",
	" 66666666666666000",
	"  0000000000000000",
	"   00000000000000 ",
	NULL
};

char *prime_multi_m[]=  /* 18  en largeur */
{
	" BBBBBBBBBBBBBB   ",
	"B0FFFFFFFFFFFFFB  ",
	"BF0000000000000B0 ",
	"B0000F000F00000B00",
	"B0000FF0FF00000B00",
	"B0000F0F0F00000B00",
	"B0000F000F00000B00",
	" BBBBFBBBFBBBBB000",
	"  0000000000000000",
	"   00000000000000 ",
	NULL
};

char *prime_sortie_m[]=  /* 18  en largeur */
{
	" 55555555555555   ",
	"50FFFFFFFFFFFFF5  ",
	"5F000000000000050 ",
	"500000FFF000000500",
	"50000F000000000500",
	"500000FF0000000500",
	"50000000F000000500",
	" 5555FFF5555555000",
	"  0000000000000000",
	"   00000000000000 ",
	NULL
};


bloc S_Balle,S_Raquette,S_RaqTir,S_Tir,S_Logo,S_Bidule,S_MiniRaq,S_Fond,S_Fond2;
bloc S_RaqLarg;

void GetSpriteFromChar( char *data[], bloc *Sprite )
{
 int  haut,larg,c;

 pbox( 0,0,320,200, FOND );

 initbloc( Sprite );

 haut = 0;
 while( data[haut] != NULL )
 {
  larg = 0;
  while( data[haut][larg] != '\0' )
  {
   c=data[haut][larg];

   if( c != ' ' )
   {
    plot(larg,haut, DEC( c ) );
    plot(160+larg,haut, MASK );
   }
   larg++;
  }
  haut++;
 }
 
 larg = 16*((larg+15)/16);
 refresh();
 getbloc(Sprite,0,0,larg,haut);
 getmask(Sprite,160,0);
}


