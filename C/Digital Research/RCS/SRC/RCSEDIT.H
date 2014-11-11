   /* external function declarations for rcsedit.c */
/*************************************************************
 * Copyright 1999 by Caldera Thin Clients, Inc.              *
 * This software is licensed under the GNU Public License.   *
 * Please see LICENSE.TXT for further information.           *
 *************************************************************/
#ifndef RCSEDIT_H

#define RCSEDIT_H

EXTERN	VOID	set_text(LONG tree, WORD obj, LONG addr, WORD len);
EXTERN	VOID	ted_set(LONG taddr, BYTE *tmplt, BYTE *valid, BYTE *text);
EXTERN	VOID	ted_get(LONG taddr, BYTE *tmplt, BYTE *valid, BYTE *text);
EXTERN	VOID	icon_set(LONG taddr, BYTE *text, BYTE *chr);
EXTERN	VOID	icon_get(LONG taddr, BYTE *text, BYTE *chr);
EXTERN	WORD	icon_cwhich(WORD xy, WORD wh, WORD iwh);
EXTERN	WORD	icon_twhich(WORD xy, WORD iwh);
EXTERN	WORD	icon_tapply(WORD rule, WORD wh, WORD iwh);
EXTERN	WORD	icon_capply(WORD rule, WORD wh, WORD iwh);
EXTERN	VOID	get_obf(LONG tree, WORD obj, WORD *type, LONG *obspec);
EXTERN	VOID	get_fields(LONG tree, WORD sobj, WORD *type, LONG *obspec, GRECT *p);
EXTERN	VOID	edit_str(LONG tree, WORD sobj);
EXTERN	VOID	edit_box(LONG tree, WORD sobj);
EXTERN	VOID	edit_text(LONG tree, WORD sobj);
EXTERN	VOID	edit_bit(LONG tree, WORD sobj);
EXTERN	VOID	edit_icon(LONG tree, WORD sobj);
EXTERN	VOID	open_obj(WORD sobj);
EXTERN	VOID	do_bdcol(LONG tree, WORD obj, WORD item);
EXTERN	VOID	do_bgcol(LONG tree, WORD obj, WORD item);
EXTERN	VOID	do_fgcol(LONG tree, WORD obj, WORD item);
EXTERN	VOID	do_patrn(LONG tree, WORD obj, WORD item);
EXTERN	VOID	do_thick(LONG tree, WORD obj, WORD item);
EXTERN	VOID	do_rule(LONG tree, WORD obj, WORD item);
EXTERN	VOID	do_posn(LONG tree, WORD obj, WORD item);
EXTERN	VOID	do_swtch(LONG tree, WORD obj, WORD item);

#endif
