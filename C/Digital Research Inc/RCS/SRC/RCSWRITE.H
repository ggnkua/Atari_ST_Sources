   /* external function declarations for rcswrite.c */
/*************************************************************
 * Copyright 1999 by Caldera Thin Clients, Inc.              *
 * This software is licensed under the GNU Public License.   *
 * Please see LICENSE.TXT for further information.           *
 *************************************************************/
#ifndef RCSWRITE_H

#define RCSWRITE_H

#if	MC68K				      
EXTERN  UWORD   swap_bytes(UWORD x);
#endif
EXTERN	WORD	write_files(VOID);

#endif
