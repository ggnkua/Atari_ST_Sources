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
	PARX IFX files (Image FX)
*******************************************************************************/
typedef struct
{
	char			head[8];
	long			fmt;
	int			type;
	char			id[8];
	int			ver;
	char			name[31];
	char			opt;
	long cdecl	(DO_IFX)(long *,long *,long *,long *);
	char			rsv1[4];
	long cdecl	(DO_PARAM)(int,char *);
	char			rsv2[4];
}	PARX_IFX;


/*******************************************************************************
	Type d'IFX
*******************************************************************************/
#define	IFX_ONE		0		/*	Une image	*/
#define	IFX_TWO		1		/*	Deux images	*/
