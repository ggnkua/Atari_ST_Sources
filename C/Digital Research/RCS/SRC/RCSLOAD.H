   /* external function declarations for rcsload.c */
/*************************************************************
 * Copyright 1999 by Caldera Thin Clients, Inc.              *
 * This software is licensed under the GNU Public License.   *
 * Please see LICENSE.TXT for further information.           *
 *************************************************************/
#ifndef RCSLOAD_H

#define RCSLOAD_H

EXTERN	VOID	just_name(BYTE *pname);
EXTERN	BYTE	dig_to_char(WORD number);
EXTERN	WORD	writ_icon(LONG praster, WORD icon_w, WORD icon_h, WORD data_size, BOOLEAN data_field);
EXTERN	VOID	get_icnfile(BYTE *full_path, WORD label);
EXTERN	WORD	char_to_dig(BYTE chr);
EXTERN	VOID	get_number(BYTE *ptr, WORD *result);
EXTERN	LONG	read_icon(BYTE *buffer, WORD *icon_w, WORD *icon_h, WORD *data_size, BYTE *icon_name, BOOLEAN mask, WORD *icn_size);
EXTERN	WORD	bb_get(LONG taddr, WORD *icon_w, WORD *icon_h);
EXTERN	WORD	ib_get(LONG taddr, WORD *icon_w, WORD *icon_h, WORD maskp, WORD *file_size);
EXTERN	VOID	load_part(WORD obj);

#endif
