#include "extern.h"

/* ---------------------- */
/* | Floskel bearbeiten | */
/* ---------------------- */
set_flosk()
{
register int eo, fk = 0, i;
char floskel[10][5][40];

rsrc_gaddr(ROOT, FLOSKEL, &form_adr);

memmove(floskel, mt_floskel, sizeof(floskel));

form_draw();
do
	{
	for (i = 0; i < 5; i++)
		{
		form_adr[FLSK_L1 + i].ob_spec.tedinfo->te_ptext = floskel[fk][i];
		objc_draw(form_adr, FLSK_L1 + i, MAX_DEPTH, fx, fy, fw, fh);
		}
		
	eo = form_do(form_adr, 0) & 0x7FFF;
	
	if (eo >= FLSK_F1 && eo <= FLSK_F10)
		fk = eo - FLSK_F1;
		
	if (eo == FLSK_LD)
		{ }
		
	if (eo == FLSK_SV)
		{ }
		
	}while(eo != FLSK_OK && eo != FLSK_CNC);

form_adr[eo].ob_state &= ~SELECTED;

if (eo == FLSK_OK)
	memmove(mt_floskel, floskel, sizeof(floskel));
	
form_end();
}

/* ------------------------------ */
/* | Funktionstasten bearbeiten | */
/* ------------------------------ */
set_funkt()
{
register int eo;

rsrc_gaddr(ROOT, FUNKTION, &form_adr);

eo = dialog(0);
}
