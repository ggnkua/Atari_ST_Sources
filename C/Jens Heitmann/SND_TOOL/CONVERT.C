#include "extern.h"

/* -----------------
	 | Change volume |
	 ----------------- */
void set_loud(void)
{
OBJECT *loud_sel;

rsrc_gaddr(R_TREE, SET_VAL, &loud_sel);
if (dialog(loud_sel) == LOUD_OK)
	vol_calc(atoi(loud_sel[LOUD_VAL].ob_spec.tedinfo->te_ptext));
}
