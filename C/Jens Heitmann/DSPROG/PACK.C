#include "extern.h"

extern DIALOG packopt_dia, mboard_dia;

/* -------------------------------
   | Count correction value down |
   ------------------------------- */
int pkor_dwn(void)
{
if (korr_val > 4)
	{
	korr_val--;
	if (!packopt_dia.tree)
		rsrc_gaddr(R_TREE, PACKOPT, &packopt_dia.tree);
	if (!mboard_dia.tree)
		rsrc_gaddr(R_TREE, ALLINONE, &mboard_dia.tree);
		
	itoa(korr_val, packopt_dia.tree[CVAL].ob_spec.tedinfo->te_ptmplt, 10);
	itoa(korr_val, mboard_dia.tree[MB_CVAL].ob_spec.tedinfo->te_ptmplt, 10);
	
	if (packopt_dia.w_handle)
		force_oredraw(packopt_dia.w_handle, CVAL);
	if (mboard_dia.w_handle)
		force_oredraw(mboard_dia.w_handle, MB_CVAL);
	}
return 0;
}

/* -----------------------------
   | Count correction value up |
   ----------------------------- */
int pkor_up(void)
{
if (korr_val < 256)
	{
	korr_val++;
	if (!packopt_dia.tree)
		rsrc_gaddr(R_TREE, PACKOPT, &packopt_dia.tree);
	if (!mboard_dia.tree)
		rsrc_gaddr(R_TREE, ALLINONE, &mboard_dia.tree);

	itoa(korr_val, packopt_dia.tree[CVAL].ob_spec.tedinfo->te_ptmplt, 10);
	itoa(korr_val, mboard_dia.tree[MB_CVAL].ob_spec.tedinfo->te_ptmplt, 10);
	
	if (packopt_dia.w_handle)
		force_oredraw(packopt_dia.w_handle, CVAL);
	if (mboard_dia.w_handle)
		force_oredraw(mboard_dia.w_handle, MB_CVAL);
	}
return 0;
}
