#include "extern.h"

/* -----------------------------
   | Initialize some variables |
   ----------------------------- */
void initialize(void)
{
OBJECT *x_adr;

rsrc_gaddr(R_TREE, SET_ENV, &x_adr);

smp_extension = x_adr[SMP_EXT].ob_spec.tedinfo->te_ptext;
avr_extension = x_adr[AVR_EXT].ob_spec.tedinfo->te_ptext;
pck_extension = x_adr[PCK_EXT].ob_spec.tedinfo->te_ptext;
}