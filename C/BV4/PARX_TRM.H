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
	PARX TRM file
*******************************************************************************/
typedef struct
{
	char			head[8];
	int			ver;
	int			flag;
	int			pal1[2][3];
	uchar			ind1[2];
	int			pal2[4][3];
	uchar			ind2[4];
	int			pal4[16][3];
	uchar			ind4[16];
	int			pal8[256][3];
	uchar			ind8[256];
	int			nmb;
	long cdecl	trm_call(int,int,long *,MFDB *,long *,MFDB *,long *,int);
	char			rsv[4];		/*	Routine de tramage	*/
}	PARX_TRM;


/*******************************************************************************
	Call
*******************************************************************************/
#define	TRM_INQUIRE		0
#define	TRM_DO			1
#define	TRM_INIT			2
#define	TRM_END			3
#define	TRM_IN_ZOOM		4
#define	TRM_DO_ZOOM		5


/*******************************************************************************
	Init
*******************************************************************************/
#define	TRM_ATARI_CARD	0x0	/*	Shifter ATARI entrelac‚		*/
#define	TRM_OTHER_CARD	0x1	/*	Shifter inconnu				*/


/*******************************************************************************
	Conversion
*******************************************************************************/
#define	TRM_IMPORT		0x0	/*	conversion en import	*/
#define	TRM_EXPORT		0x1	/*	conversion en export	*/

#define	TRM_AUTO			0x0	/*	Choix de tramage en fonction du No pass‚		*/
#define	TRM_USER			0x2	/*	Formulaire affich‚ par le TRM						*/

#define	TRM_PRG_PAL		0x0	/*	Palette dest impos‚e au TRM par le prg			*/
#define	TRM_SUGG_PAL	0x4	/*	Palette dest propos‚e au TRM par le prg		*/
#define	TRM_GRAY_PAL	0x8	/*	Palette en niveaux de gris impos‚e par le prg*/

#define	TRM_NOFORCE		0x0	/*	Tramage sur la source			*/
#define	TRM_FORCE		0x20	/*	Tramage sur destination autre	*/

#define	TRM_ZOOM_LQ		0		/*	Zoom basse qualit‚	*/
#define	TRM_ZOOM_HQ		1		/*	Zoom haute qualit‚	*/

/*******************************************************************************
	Messages d'erreur
*******************************************************************************/

#define	TRM_MINE				-128

#define	TRM_ERR_RSVD19		-19
#define	TRM_ERR_RSVD18		-18
#define	TRM_ERR_RSVD17		-17
#define	TRM_ERR_RSVD16		-16
#define	TRM_ERR_RSVD15		-15

#define	TRM_ERR_INIT		-12

#define	TRM_ZM_PLAN			-11

#define	TRM_DMFDB_NUL			-10
#define	TRM_DMFDB_PLAN			-9
#define	TRM_DMFDB_BAD			-8
#define	TRM_DMFDB_ADR			-7


#define	TRM_SMFDB_NUL			-6
#define	TRM_SMFDB_PLAN			-5
#define	TRM_SMFDB_BAD			-4
#define	TRM_SMFDB_ADR			-3


#define	TRM_STOP					-2
#define	TRM_CALL					-1
#define	TRM_OK					0
