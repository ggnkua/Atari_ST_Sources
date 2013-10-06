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
	RSC DEFINES
*******************************************************************************/
#define	USD_CROSS		0x0100				/*	STRING with a [checked] box		*/
#define	USD_ROUND		0x0200				/*	STRING with a radio button			*/
#define	USD_POPUP		0x0300				/*	PopUp menu BUTTON						*/
#define	USD_XPOPUP		0x0400				/*	Extended PopUp menu BUTTON			*/
#define	USD_NUM			0x0600				/*	Number with arrow						*/
#define	USD_DNARROW		0xFD00				/*	USERDEF: down arrow					*/
#define	USD_UPARROW		0xFC00				/*	USERDEF: up arrow						*/
#define	USD_LFARROW		0xFB00				/*	USERDEF: left arrow					*/
#define	USD_RTARROW		0xFA00				/*	USERDEF: right arrow					*/
#define	USD_LQARROW		0xF900				/*	USERDEF: double left arrow			*/
#define	USD_RQARROW		0xF800				/*	USERDEF: double right arrow		*/


/*******************************************************************************
	POPUP DEFINES
*******************************************************************************/
#define	POP_VALUE	0
#define	POP_XLEFT	1
#define	POP_XTOP		1
#define	POP_LEFT		2
#define	POP_TOP		2
#define	POP_CENTER	3
#define	POP_RIGHT	4
#define	POP_BOTTOM	4
#define	POP_XRIGHT	5
#define	POP_XBOTTOM	5

#define	ED_CLIP			0x100


/*******************************************************************************
	struct for USERDEF objects
*******************************************************************************/
typedef struct
{
	int			type;
	USERBLK		blk;
	long			spec;
	uint			user1;
	uint			user2;
	uint			user3;
	uint			user4;
	uint			user5;
	long			userl1;
	long			userl2;
}	UBLK;

/*******************************************************************************
	RSC header and support struct
*******************************************************************************/
typedef struct
{
	long			nobs;
	long			ntree;
	long			nted;
	long			ncib;
	long			nib;
	long			nbb;
	long			nfstr;
	long			nfimg;
	OBJECT		*object;
	TEDINFO		*tedinfo;
	ICONBLK		*iconblk;
	BITBLK		*bitblk;
	CICON			*cicon;
	CICONBLK		*ciconblk;
	char			**frstr;
	BITBLK		**frimg;
	OBJECT		**trindex;
}	myRSHDR;

typedef struct
{
	char		name[FILENAME_MAX];			/*	RSC file name			*/
	myRSHDR	head;								/*	RSC Header				*/
	int		in;								/*	Index of Memory		*/
	long		adr;								/*	Adr of memory bloc	*/
	long		len;								/*	Len of memory bloc	*/
	long		max;								/*	Max len of bloc		*/
	UBLK		*ublk;							/*	userdef array			*/
	CICON		*cicon;							/*	color icon array		*/
}	RSC;
