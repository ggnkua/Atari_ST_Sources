/*******************************************************************************
	Bitmap view Copyright (c) 1995 by	Christophe BOYANIQUE
													http://www.raceme.org
													tof@raceme.org
********************************************************************************
	This program is free software; you can redistribute it and/or modify it
	under the terms of the GNU General Public License as published by the Free
	Software Foundation; either version 2 of the License, or any later version.
	This program is distributed in the hope that it will be useful, but WITHOUT
	ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
	FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
	more details.
	You should have received a copy of the GNU General Public License along
	with this program; if not, write to the Free Software Foundation, Inc.,
	59 Temple Place - Suite 330, Boston, MA 02111, USA.
********************************************************************************
	TABULATION: 3 CARACTERES
*******************************************************************************/


/*******************************************************************************
	PARX Memory Manager
*******************************************************************************/
#define		MM_ERROR		0L
#define		MM_NOFILL	0xAAAA

extern int	cdecl	(*manag_version)(void);
extern long cdecl	(*manag_malloc)(long *,long *,int,int,long);
extern long cdecl	(*manag_free)(void);
extern long cdecl	(*manag_shrink)(long);
extern long cdecl	(*manag_grow)(int,long);
extern long cdecl	(*manag_size)(void);
extern long cdecl	(*blk_malloc)(long *,long *,int,int,long,int);
extern long cdecl	(*blk_free)(long *,long *,int,int);
extern long cdecl	(*blk_shrink)(long *,long *,int,int,long,long);
extern long cdecl	(*blk_grow)(long *,long *,int,int,long,int,long);
