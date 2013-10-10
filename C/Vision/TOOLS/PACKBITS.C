/**************************************/
/* PACKBITS.C                         */
/* D‚compression de donn‚es Pack Bits */
/**************************************/
void *pbadr_in ;
void *pbadr_out ;
int  pbnb_ligne ;
int  pbnb_plan ;
int  pbnb_pixel ;
int  pbmot_larg ;
void pbits_dcmps(void) ;  /* D‚finie dans PACKBITS.S */
void pbits_idcmps(void) ; /* D‚finie dans PACKBITS.S */


void packbits_dcmps(void *in, void *out, int nbpixel, int nbline, int nbplan)
{
  pbadr_in   = in ;
  pbadr_out  = out ;
  pbnb_pixel = nbpixel ;
  pbnb_ligne = nbline ;
  pbnb_plan  = nbplan ;
  pbmot_larg = nbpixel >> 4 ;
  if (nbpixel % 16) pbmot_larg++ ;
  pbmot_larg  *= nbplan ;

  pbits_dcmps() ;
}

void packbits_idcmps(void *in, void *out, int nbpixel, int nbline, int nbplan)
{
  pbadr_in   = in ;
  pbadr_out  = out ;
  pbnb_pixel = nbpixel ;
  pbnb_ligne = nbline ;
  pbnb_plan  = nbplan ;
  pbmot_larg = nbpixel >> 4 ;
  if (nbpixel % 16) pbmot_larg++ ;
  pbmot_larg  *= nbplan ;

  pbits_idcmps() ;
}
