/*
 *			GEM Mouse Manager Sub-Library:
 *
 *
 *	Author  : FunShip
 *	File	: PcXMouse.h
 *	Date    : 13 December 1995
 *	Release : 13 December 1995
 *	Version : 1.20
 *	Language: Pure C, Version du 3 Fevrier 1992 
 *	Country : FRANCE
 *	
 *
 *		  - Copyright Atari FunShip (c) 19995
 *		      - ATARI ST/STE/TT & Falcon -
 * -----------------------------------------------------------------------------------------
 */

#ifndef	__PCXMOUSE__
#define	__PCXMOUSE__	__PCXMOUSE__

/*
 * -----------------------------------------------------------------------------------------
 *				News AADS's mouse shape
 */
 
#define	MS_ATARI		8
#define	MS_APPLE		9
#define	MS_AMIGA		10
#define	MS_MAC			11
#define	MS_HOURGLASS		12
#define	MS_BOMB			13
#define	MS_DISK			14
#define	MS_SLEEP		15
#define	MS_POINTFLATHAND	16
#define	MS_HELP			17
#define	MS_MOUSE		18

/*
 * -----------------------------------------------------------------------------------------
 *				Publics Procedures
 */

void	MS_Get(int *Mouse, MFORM **MouseForm); 
int	MS_Mouse(int Mouse,MFORM *MouseForm);

#endif
