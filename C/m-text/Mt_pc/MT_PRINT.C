#include "extern.h"

/* ---------------- */
/* | Text drucken | */
/* ---------------- */
void print_txt(void)
{
register int eo;

rsrc_gaddr(ROOT, PRT_MENU, &form_adr);

eo = dialog(0) & 0x7FFF;
if (eo == DO_PRT)
	form_alert(1, "[3][Drucken noch nicht |m”glich!][ OK ]");
}
