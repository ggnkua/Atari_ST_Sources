   /* external function declarations for rcsalert.c */
/*************************************************************
 * Copyright 1999 by Caldera Thin Clients, Inc.              *
 * This software is licensed under the GNU Public License.   *
 * Please see LICENSE.TXT for further information.           *
 *************************************************************/
#ifndef RCSALERT_H

#define RCSALERT_H

EXTERN	VOID	pt_parse(LONG tree, WORD obj0, WORD nobj, LONG where, WORD *here);
EXTERN	VOID	parse_alert(LONG tree, LONG where);
EXTERN	WORD	is_alert(LONG where);
EXTERN	VOID	comp_alerts(LONG hdr);
EXTERN	VOID	pt_unparse(LONG tree, WORD obj0, WORD nobj, LONG where, WORD *here);
EXTERN	VOID	unparse_alert(LONG tree, LONG where);
EXTERN	VOID	dcomp_alerts(VOID);
EXTERN	WORD	pt_roomp(LONG tree, WORD obj0, WORD nobj);
EXTERN	VOID	pt_count(LONG tree, WORD obj0, WORD nobj, WORD *n, WORD *mxl);
EXTERN	VOID	al_count(LONG tree, WORD *pic, WORD *nmsg, WORD *mxlmsg, WORD *nbut, WORD *mxlbut);
EXTERN	VOID	al_space(LONG tree, WORD haveicon, WORD nummsg, WORD mlenmsg, WORD numbut, WORD mlenbut);
EXTERN	VOID	fix_alert(LONG tree);

#endif
