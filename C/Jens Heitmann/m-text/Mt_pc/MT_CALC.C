#include "extern.h"

/* ---------------- */
/* | Text rechnen | */
/* ---------------- */
void do_calc(void)
{
register int eo;

rsrc_gaddr(ROOT, CALC, &form_adr);

eo = dialog(0);
form_alert(1, "[1][Rechnen noch nicht |m”glich!][ OK ]");
}

