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
	PARX WIM files (Write IMage)
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
	long cdecl	(INFO_SAUVE)(MFDB *);
	char			rsv1[4];
	long cdecl	(ESTIME_TAILLE)(MFDB *,long);
	char			rsv2[4];
	long cdecl	(TRAITE_FICHIER)(MFDB *,long,long);
	char			rsv3[4];
	long cdecl	(DO_PARAM)(int,char *);
	char			rsv4[4];
}	PARX_WIM;


/*******************************************************************************
	Type de WIM
*******************************************************************************/
#define	WIM_SAVE		0
#define	WIM_GEN		2
#define	WIM_ANI		4


/*******************************************************************************
	Format de WIM
*******************************************************************************/
#define	WIM_VDI		'_VDI'
#define	WIM_SHI		'_SHI'
#define	WIM_VSH		'_VSH'


/*******************************************************************************
	Messages d'erreur
*******************************************************************************/
#define	WIM_OK		0
#define	WIM_BUSY		-1
#define	WIM_NOWIM	-2
#define	WIM_NODIM	-3
#define	WIM_NOTRM	-4
#define	WIM_NOZOOM	-5
#define	WIM_FILE		-6
#define	WIM_NOFILE	-7
