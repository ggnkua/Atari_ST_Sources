#ifndef __PACKBITS_H
#define __PACKBITS_H

typedef struct _PACKBITS_STR
{
  void* pbadr_in ;
  void* pbadr_out ;
  int   pbnb_ligne ;
  int   pbnb_plan ;
  int   pbnb_pixel ;
  int   pbmot_larg ; /* Don't fill it */
}
PACKBITS_STR, *PPACKBITS_STR ;

void packbits_dcmps(PACKBITS_STR* packbits_str) ;
void packbits_idcmps(PACKBITS_STR* packbits_str) ;

#endif
