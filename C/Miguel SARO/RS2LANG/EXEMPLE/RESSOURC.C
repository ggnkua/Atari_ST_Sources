#define Num_lang  3
int  lang ;

char str0[] = "" ;
char str2[] = "0001" ;
char str4[] = "9999" ;
char str5[] = "0123" ;

/* phrase 1 : Fran‡ais , 2 : Anglais , 3 : Allemand */
      
char str1[][33] = {"   Cette phrase doit changer.   ",    
                   "   This sentence must change.   ",
                   "Dieser Satz muá ver„ndert werden"};
char str3[][29] = {"  Entrez un chiffre   : ____",
                   "    Input a number    : ____",
                   "  Eingabe einer Zahl  : ____" } ;
char str6[][10] = { " English ",
                    " Deutsch ",
                    "Fran‡ais " } ;
char str7[][10] = { " Termin‚ ",
                    "   End ! ",
                    "  Ende ! " } ;
char str8[][19] = { "   cliquer pour   ",
                    "    click  for    ",
                    "     Klick zur    " } ;
char str11[][24] = {"   changer de langue   ",
                    "   language change     ",
                    "  Žnderung der Spreche " } ;

WORD IMAG0[] = {
0x0005,0x0800,0x0012,0x5000,0x0533,0x5800,0x061d,0xf100,
0x14da,0x4200,0x0c70,0xca00,0x06b1,0xc980,0x0235,0xcf00,
0x0ffb,0xff20,0x399e,0x99a0,0x232b,0xb8c8,0x0203,0xec60,
0x0003,0xc638,0x0003,0xc210,0x0003,0xc008,0x0003,0xc000,
0x0003,0xc000,0x0003,0xe000,0x0007,0xf000,0x0c4c,0xdae0,
0x55b0,0x0515,0x0024,0x8000,0x0000,0x1204,0x0b08,0x0080,
0x0101,0x0000,0x0010,0x1040,0x0004,0x0000,0x1000,0x0004 } ;

WORD IMAG1[] = {
0x0005,0x0800,0x0012,0x5000,0x0533,0x5800,0x061d,0xf100,
0x14da,0x4200,0x0c70,0xca00,0x06b1,0xc980,0x0235,0xcf00,
0x0ffb,0xff20,0x399e,0x99a0,0x232b,0xb8c8,0x0203,0xec60,
0x0003,0xc638,0x0003,0xc210,0x0003,0xc008,0x0003,0xc000,
0x0003,0xc000,0x0003,0xe000,0x0007,0xf000,0x0c4c,0xdae0,
0x55b0,0x0515,0x0024,0x8000,0x0000,0x1204,0x0b08,0x0080,
0x0101,0x0000,0x0010,0x1040,0x0004,0x0000,0x1000,0x0004 } ;


BITBLK rs_bbl[] = {
0 } ;


ICONBLK rs_ibl[] = {
(int*)IMAG0,(int*)IMAG1, str5   , 4096,0,0, 0,0,32,28, 4,28,24,6  } ;

TEDINFO rs_tdi[] = {
str2   , str3[0], str4   , 3, 6, 0, 0x1180, 0x0, -1, 5, 29,
str8[0], str0   , str0   , 5, 6, 0, 0x1180, 0x0, -1, 19, 1,
str11[0], str0   , str0   , 5, 6, 0, 0x1180, 0x0, -1, 24, 1 } ;

OBJECT rs_ob[] = {
-1, 1, 7, G_BOX, 0, 16, 0x21100L, 1, 1, 49, 2059,
2, -1, -1, G_STRING, 0, 0, (long)str1[0], 2, 2, 32, 1,
3, -1, -1, G_FTEXT, 8, 0, (long)&rs_tdi[0], 3, 5, 28, 1,
4, -1, -1, G_ICON, 1029, 0, (long)&rs_ibl[0], 39, 3, 4, 514,
5, -1, -1, G_BUTTON, 5, 0, (long)str6[0], 11, 8, 10, 1,
6, -1, -1, G_BUTTON, 7, 0, (long)str7[0], 26, 8, 10, 1,
7, -1, -1, G_TEXT, 5, 0, (long)&rs_tdi[1], 9, 9, 13, 1,
0, -1, -1, G_TEXT, 37, 0, (long)&rs_tdi[2], 7, 10, 529, 1536 } ;

OBJECT *rs_tx[] = {
&rs_ob[0] } ;

#define NUM_OBS     8
 
void met_rsc()
{
  int i ;
  for(i=0; i<NUM_OBS; rsrc_obfix(rs_ob, i++) ) ;
}

void met_lg()
{
  rs_ob[1].ob_spec = (long)str1[lang] ;
  rs_tdi[0].te_ptmplt = str3[lang] ;
  rs_ob[4].ob_spec = (long)str6[lang] ;
  rs_ob[5].ob_spec = (long)str7[lang] ;
  rs_tdi[1].te_ptext  = str8[lang] ;
  rs_tdi[2].te_ptext  = str11[lang] ;
 } ;

void nxt_lg()
{
  lang = (lang+1) % Num_lang ;
  met_lg() ;
}
