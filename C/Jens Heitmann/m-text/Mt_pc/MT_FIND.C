#include "extern.h"

/* ------------------- */
/* | Suchen/Ersetzen | */
/* ------------------- */
void do_search(void)
{
register int eo;

rsrc_gaddr(ROOT, FIND_REP, &form_adr);

form_draw();
do
	{
	eo = form_do(form_adr, FIND_STR);
	
	switch(eo)
		{
		case SR_BEGIN | 0x8000:
		case SR_BEGIN:
		case SR_END | 0x8000:
		case SR_END:
			form_adr[SR_CRDWN].ob_state |= DISABLED;
			form_adr[SR_CRUP].ob_state |= DISABLED;
			objc_draw(form_adr, SR_CRDWN, MAX_DEPTH, fx, fy, fw, fh);
			objc_draw(form_adr, SR_CRUP, MAX_DEPTH, fx, fy, fw, fh);
			break;

		case SR_CURSR:
		case SR_CURSR | 0x8000:
			form_adr[SR_CRDWN].ob_state &= ~DISABLED;
			form_adr[SR_CRUP].ob_state &= ~DISABLED;
			objc_draw(form_adr, SR_CRDWN, MAX_DEPTH, fx, fy, fw, fh);
			objc_draw(form_adr, SR_CRUP, MAX_DEPTH, fx, fy, fw, fh);
			break;
		}
	}while((eo & 0x7FFF) != SR_CANC);

form_end();	
}

