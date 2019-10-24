/******************************************************************/
/*																						*/
/*		.RSH file Remap Utility													*/
/*		Copyright (c)1993 by Fran‡ois PLANQUE								*/
/*																						*/
/******************************************************************/

/*
 * Purpose:
 * --------
 * Header d‚finissant les types utilis‚s pat RSHCRMAP
 *
 * History:
 * --------
 * 1993: Created by fplanque
 * 02.01.95: PLUS DE FOOBAR
 * 02.02.95: removed even more stuff
 */

/* Structure RSH_MAP: */
typedef
	struct
	{
		int		num_obs;			/* Nombre d'objets */
		OBJECT	*rs_object;		/* Adresse des objets en m‚moire */
		
		int		num_ti;			/* Nombre de tedinfos */
		TEDINFO	*rs_tedinfo;	/* Adresse des tedinfos en m‚moire */
		
		int		num_bb;			/* Nombre de bitblocks */
		BITBLK	*rs_bitblk;		/* Adresse des bitblocks en m‚moire */
		
		int		num_strings;	/* Nombre de chaines */
		BYTE		**rs_strings;	/* Adresse des chaines en m‚moire */
		
		int		num_ib;			/* Nombre d'iconblocks */
		ICONBLK	*rs_iconblk;	/* Adresse des iconblocks en m‚moire */

		int		num_frimg;		/* Nombre de Free-Images */
		LONG		*rs_frimg;		/* Adresse en m‚moire */

		int		num_frstr;		/* Nombre de Free-Strings */
		LONG		*rs_frstr;		/* Adresse en m‚moire */

	}
	RSH_MAP;