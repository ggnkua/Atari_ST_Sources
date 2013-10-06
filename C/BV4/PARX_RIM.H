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
	PARX RIM files (Read IMage)
*******************************************************************************/
typedef struct
{
	unsigned long	seek;
	unsigned int	w;
	unsigned int	h;
	unsigned int	wdw;
	unsigned int	stand;
	unsigned int	nplanes;
	unsigned long	len;
	unsigned int	handle;
}	MF_RIM;

typedef struct
{
	char			head[8];
	long			fmt;
	int			type;
	char			id[8];
	int			ver;
	char			name[31];
	char			opt;
	long cdecl	(TEST_FICHIER)(int,long *,long,long,long,MF_RIM *);
	char			rsv1[4];
	long cdecl	(EXTRAIT_PALETTE)(int,long *,long,long *,long,MF_RIM *);
	char			rsv2[4];
	long cdecl	(TRAITE_FICHIER)(int,long *,long,MF_RIM *);
	char			rsv3[4];
	long cdecl	(DO_PARAM)(int,char *);
	char			rsv4[4];
}	PARX_RIM;


/*******************************************************************************
	Type de RIM
*******************************************************************************/
#define	RIM_TOT		0		/*	Rim total										*/
#define	RIM_PAR		1		/*	Rim partiel										*/
#define	RIM_DGN		2		/*	Rim g‚n‚rant avec demande de dimension	*/
#define	RIM_GEN		3		/*	Rim g‚n‚rant									*/
#define	RIM_ANI		4		/*	Rim animation									*/


/*******************************************************************************
	Format de RIM
*******************************************************************************/
#define	RIM_VDI		'_VDI'
#define	RIM_SHI		'_SHI'
#define	RIM_VSH		'_VSH'


/*******************************************************************************
	Messages d'erreur
*******************************************************************************/
#define	RIM_OK		0
#define	RIM_NEXT		1
#define	RIM_FILE		-1
#define	RIM_MEM		-2
#define	RIM_NORIM	-3
#define	RIM_NONE		-4
#define	RIM_CANCEL	-5
#define	RIM_ERROR	-6
