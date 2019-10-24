/******************************************************************/
/*																						*/
/*		.RSH file Remap Utility													*/
/*		Copyright (c)1993 by Fran‡ois PLANQUE								*/
/*																						*/
/******************************************************************/

/*
 * Purpose:
 * --------
 * Create the rsh_map
 * that you must transmit to remap_rsh() during program initialization
 *
 * History:
 * --------
 * 1993: Created by fplanque
 * 02.02.95: removed some stuff
 */


/* Cr‚ation du rsh_map associ‚e au fichier RSH 	*/
/*	pr‚sent dans le mˆme module:						*/
static	RSH_MAP	rsh_map=
	{
		NUM_OBS,			&rs_object[0],				/* Objets */
		NUM_TI,			&rs_tedinfo[0],			/* TedInfos */
		NUM_BB,			&rs_bitblk[0],				/* Bitblocks */
		NUM_STRINGS, 	&rs_strings[0],			/* Strings */
		NUM_IB,			&rs_iconblk[0],			/* Iconblocks */
		NUM_FRIMG,		&rs_frimg[0],				/* Free Images */
		NUM_FRSTR,		&rs_frstr[0],				/* Free Strings */
	};