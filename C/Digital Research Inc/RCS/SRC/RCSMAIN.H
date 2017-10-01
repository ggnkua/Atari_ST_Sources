  /* external function declarations for rcsmain */
/*************************************************************
 * Copyright 1999 by Caldera Thin Clients, Inc.              *
 * This software is licensed under the GNU Public License.   *
 * Please see LICENSE.TXT for further information.           *
 *************************************************************/
#ifndef RCSMAIN_H

#define RCSMAIN_H

EXTERN	WORD	hndl_menu(WORD title, WORD item);
EXTERN	VOID	send_redraw(WORD w_handle, GRECT *p);
EXTERN	VOID	hndl_dsel(VOID);
EXTERN	VOID	obj_redraw(LONG tree, WORD obj);
EXTERN	VOID	obj_nowdraw(LONG tree, WORD obj);
EXTERN	VOID	do_redraw(WORD w_handle, GRECT *dirty, LONG tree, GRECT *area);
EXTERN	VOID	hndl_redraw(WORD w_handle, GRECT *c);
EXTERN	VOID	hndl_arrowed(WORD w_handle, WORD kind);
EXTERN	VOID	hndl_hslid(WORD w_handle, WORD v_set);
EXTERN	VOID	hndl_vslid(WORD w_handle, WORD v_set);
EXTERN	BOOLEAN	hndl_keybd(WORD key);
EXTERN	VOID	GEMAIN(VOID);

#endif
