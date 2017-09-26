  /* external function declarations for rcsinit.c */
/*************************************************************
 * Copyright 1999 by Caldera Thin Clients, Inc.              *
 * This software is licensed under the GNU Public License.   *
 * Please see LICENSE.TXT for further information.           *
 *************************************************************/
#ifndef RCSINIT_H

#define RCSINIT_H

EXTERN	WORD	ini_rsrc(VOID);
EXTERN	WORD	ini_windows(WORD view_parts);
EXTERN	VOID	rd_inf(WORD flag);
EXTERN	WORD	rcs_init(VOID);
EXTERN	WORD	cont_rcsinit(WORD flag);
EXTERN	VOID	rcs_exit(WORD term_type);

#endif
