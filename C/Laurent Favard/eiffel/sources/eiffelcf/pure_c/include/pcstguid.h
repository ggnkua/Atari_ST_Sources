/*
 * ----------------------------------------------------------------------------------------------
 *					Interfacage avec ST-GUIDE
 *
 * 	Author  : 	FAVARD Laurent, FunShip (c)
 *	File    : 	Exit.C
 *	Date    : 	05 September 1997
 *	Release : 	05 Septemnbre 1997
 *	Version : 	1.0
 *	Country : 	FRANCE
 *			
 *
 *								- Copyright Atari FunShip (c) 1994-97 -
 *							- Atari ST, STE, TT, Falcon, C-LAB, Medusa, Hades -
 * ----------------------------------------------------------------------------------------------
 */

#ifndef	__STGUIDE__
#define	__STGUIDE__		__STGUIDE__

/*
 * ----------------------------------------------------------------------------------------------
 *			Type definitions
 */

typedef struct	{
						int	MessageNumber;
					   int	HandleSource;
						int	NU0;
						char	*String;
						int	NU1;
						int	NU2;
						int	NU3;		
	
		 			} TYPE_MESSAGE_START;

/*
 * ----------------------------------------------------------------------------------------------
 *			Constantes
 */

/*	ST-Guide	*/

#define		G_STGUIDE					"ST-GUIDE"
#define		AV_START						0x4711

/*
 * ----------------------------------------------------------------------------------------------
 *		Entry point into hypertext ST-Guide help file
 */

extern	int STG_Open(char *HelpFile, char *Parameter);
extern	int STG_Bubble(char *String, int MouseX, int MouseY);

#endif
