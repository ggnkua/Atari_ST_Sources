  /* external function declarations for rcsfiles.c */
/*************************************************************
 * Copyright 1999 by Caldera Thin Clients, Inc.              *
 * This software is licensed under the GNU Public License.   *
 * Please see LICENSE.TXT for further information.           *
 *************************************************************/
#ifndef RCSFILES_H

#define RCSFILES_H

EXTERN	VOID	get_path(BYTE *tmp_path, BYTE *spec);
EXTERN	VOID	r_to_xfile(BYTE *where, BYTE *ext);
EXTERN	WORD	get_file(WORD label);
EXTERN	WORD	rvrt_files(VOID);
EXTERN	WORD	ok_rvrt_files(VOID);
EXTERN	VOID	rsc_title(VOID);
EXTERN	WORD	abandon_button(VOID);
EXTERN	WORD	new_rsc(VOID);
EXTERN	WORD	open_rsc(VOID);
EXTERN	WORD	clos_rsc(VOID);
EXTERN	VOID	save_rsc(VOID);
EXTERN	WORD	svas_rsc(VOID);
EXTERN	WORD	rvrt_rsc(VOID);
EXTERN	VOID	merge_rsc(VOID);
EXTERN	WORD	quit_rsc(VOID);

#endif
