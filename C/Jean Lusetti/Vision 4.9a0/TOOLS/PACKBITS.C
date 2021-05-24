/**************************************/
/* PACKBITS.C                         */
/* D‚compression de donn‚es Pack Bits */
/**************************************/
#include "packbits.h"

void pbits_dcmps(PACKBITS_STR* packbits_str) ;  /* In PACKBITS.S */
void pbits_idcmps(PACKBITS_STR* packbits_str) ; /* In PACKBITS.S */


void init_packbits_str(PACKBITS_STR* packbits_str)
{
  packbits_str->pbmot_larg = packbits_str->pbnb_pixel >> 4 ;
  if ( packbits_str->pbnb_pixel % 16 ) packbits_str->pbmot_larg++ ;
  packbits_str->pbmot_larg  *= packbits_str->pbnb_plan ;
}

void packbits_dcmps(PACKBITS_STR* packbits_str)
{
  init_packbits_str( packbits_str ) ;
  pbits_dcmps( packbits_str ) ;
}

void packbits_idcmps(PACKBITS_STR* packbits_str)
{
  init_packbits_str( packbits_str ) ;
  pbits_idcmps( packbits_str ) ;
}
