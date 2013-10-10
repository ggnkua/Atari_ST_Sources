#ifndef DESKACT_H

#define DESKACT_H

EXTERN	WORD gr_obfind(LONG tree, WORD root, WORD mx, WORD my);
EXTERN	WORD gr_isdown(WORD out, WORD x, WORD y, WORD w, WORD h,
	WORD *pmx, WORD *pmy, WORD *pbutton, WORD *pkstate);
EXTERN	VOID gr_accobs(LONG tree, WORD root, WORD *pnum, WORD *pxypts);
EXTERN	VOID gr_extent(WORD numpts, WORD *xylnpts, GRECT *pt);
EXTERN	VOID gr_plns(WORD x, WORD y, WORD numpts, WORD *xylnpts,
	WORD numobs, WORD *xyobpts);
EXTERN	WORD gr_bwait(GRECT *po, WORD mx, WORD my, WORD numpts,
	WORD *xylnpts, WORD numobs, WORD *xyobpts);
EXTERN	VOID gr_drgplns(WORD in_mx, WORD in_my, GRECT *pc,
	WORD *pdulx, WORD *pduly, WORD *pdwh, WORD *pdobj);
EXTERN	WORD bit_on(WORD x, WORD y, LONG praster, WORD bwidth);
EXTERN	WORD act_chkobj(LONG tree, WORD root, WORD obj,
	WORD mx, WORD my, WORD w, WORD h);
EXTERN	WORD act_chg(WORD wh, LONG tree, WORD root, WORD obj, GRECT *pc,
	UWORD chgvalue, WORD dochg, WORD dodraw, WORD chkdisabled);
EXTERN	VOID act_allchg(WORD wh, LONG tree, WORD root, WORD ex_obj,
	GRECT *pt, GRECT *pc, WORD chgvalue, WORD dochg, WORD dodraw);
EXTERN	VOID act_bsclick(WORD wh, LONG tree, WORD root, WORD mx, WORD my,
	WORD keystate, GRECT *pc, WORD dclick);
EXTERN	WORD act_bdown(WORD wh, LONG tree, WORD root, WORD *in_mx, WORD *in_my,
	WORD keystate, GRECT *pc, WORD *pdobj);

#endif
