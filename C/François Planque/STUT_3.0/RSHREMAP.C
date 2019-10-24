/*
 * rshremap.c
 *
 *		.RSH file Remap Utility
 *		Copyright (c)1993 by Fran‡ois PLANQUE
 *
 * Purpose:
 * --------
 * Remaps .RSH files in memory
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */

 
 	#include "!OPTIONS.H"				/* Options de compilation */         
          

/*
 * System headers:
 */
	#include	<aes.h>			/* D‚finitions AES standard:			
									 * OBJECT, TEDINFO, etc...
									 * rsrc_obfix()...
									 */
	#include	"rsh_map.h"		/* Definition du type RSH_MAP
									 * Inclure dans le module contenant
									 * le .RSH, le fichier RSHCRMAP.H
									 * qui se charge de cr‚er un
									 * rsh_map associ‚...
									 */
   
/*
 * ------------------------ FUNCTIONS -------------------------
 */

/*
 * remap_rsh(-)
 *
 * Purpose:
 * --------
 * Routine de relocation
 *
 * Notes:
 * ------
 * Cette routine va reloger la ressource en m‚moire.
 *	Attention: si le compilateur r‚unit les chaines de caractŠres
 * identiques en compilant le module contenany le fichier RSH,
 *	il y a risque de bobo!
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 01.02.95: ne reloge plus les pointeurs sur bitmaps (iconblk et bitblk), il est en effet possible de les fixer directement dans le .RSH
 */
void	remap_rsh( RSH_MAP *rsh_map )
{

	int	i;									/* Pour les boucles */

	/****************************************************/
	/* Relocation des objets: (en particulier: OB_SPEC) */
	/****************************************************/
	if ( rsh_map -> num_obs )
	{
		/* Parcourt les objets: */
		for( i = 0; i < rsh_map -> num_obs; i++ )
		{
			/* Conversion coordonn‚es */
			rsrc_obfix( &( (rsh_map -> rs_object)[ i ] ), 0 );
			
			/* Relocation de OB_SPEC: */
			switch( (rsh_map -> rs_object)[ i ] .ob_type )	/* Type de l'objet */
			{
				case	G_BOX:
				case	G_IBOX:
				case	G_BOXCHAR:
				/* OBSPEC n'est pas un pointeur */
					break;
					
				case	G_TEXT:
				case	G_BOXTEXT:
				case	G_FTEXT:
				case	G_FBOXTEXT:
				/* OBSPEC Pointe sur TEDINFO: */
					(rsh_map -> rs_object)[ i ] .ob_spec.tedinfo =
						&(rsh_map -> rs_tedinfo)[ (rsh_map -> rs_object)[ i ] .ob_spec.index ];
					break;

				case	G_IMAGE:
				/* OBSPEC Pointe sur BITBLK: */
					(rsh_map -> rs_object)[ i ] .ob_spec.bitblk =
						&(rsh_map -> rs_bitblk)[ (rsh_map -> rs_object)[ i ] .ob_spec.index ];
					break;

				case	G_USERDEF:
				/* OBSPEC Pointe sur USERBLK: */
					break;

				case	G_BUTTON:
				case	G_STRING:
				case	G_TITLE:
				/* OBSPEC Pointe sur STRING: */
					(rsh_map -> rs_object)[ i ] .ob_spec .free_string =
						(rsh_map -> rs_strings)[ (rsh_map -> rs_object)[ i ] .ob_spec .index ];
					break;
					
				case	G_ICON:
				/* OBSPEC Pointe sur ICONBLK: */
					(rsh_map -> rs_object)[ i ] .ob_spec.iconblk =
						&(rsh_map -> rs_iconblk)[ (rsh_map -> rs_object)[ i ] .ob_spec.index ];
					break;
					
				default:
					break;
			}
		}
	}


	/****************************/
	/* Relocation des tedinfos: */
	/****************************/
	if ( rsh_map -> num_ti )
	{
	/* Parcourt les objets: */
		for( i = 0; i < rsh_map -> num_ti; i++ )
		{
		/* Reloge pointeur sur ptext: */
			(rsh_map -> rs_tedinfo)[ i ] .te_ptext =
				(rsh_map -> rs_strings)[ (int) (rsh_map -> rs_tedinfo)[ i ] .te_ptext ];
		/* Reloge pointeur sur ptmplt: */
			(rsh_map -> rs_tedinfo)[ i ] .te_ptmplt =
				(rsh_map -> rs_strings)[ (int) (rsh_map -> rs_tedinfo)[ i ] .te_ptmplt ];
		/* Reloge pointeur sur pvalid: */
			(rsh_map -> rs_tedinfo)[ i ] .te_pvalid =
				(rsh_map -> rs_strings)[ (int) (rsh_map -> rs_tedinfo)[ i ] .te_pvalid ];
				/*		printf("%lu\n",(rsh_map -> rs_tedinfo)[ i ] .te_pvalid); */
		}
	}

	/******************************/
	/* Relocation des IconBlocks: */
	/******************************/
	if ( rsh_map -> num_ib )
	{
	/* Parcourt les objets: */
		for( i = 0; i < rsh_map -> num_ib; i++ )
		{
		/* Reloge pointeur sur pmask: */
		/*	(rsh_map -> rs_iconblk)[ i ] .ib_pmask =
		/*		(rsh_map -> rs_imdope)[ (int) (rsh_map -> rs_iconblk)[ i ] .ib_pmask ] .image; */
		/* Reloge pointeur sur pdata: */
		/*	(rsh_map -> rs_iconblk)[ i ] .ib_pdata =
		/*		(rsh_map -> rs_imdope)[ (int) (rsh_map -> rs_iconblk)[ i ] .ib_pdata ] .image; */
		/* Reloge pointeur sur ptext: */
			(rsh_map -> rs_iconblk)[ i ] .ib_ptext =
				(rsh_map -> rs_strings)[ (int) (rsh_map -> rs_iconblk)[ i ] .ib_ptext ];
		}
	}

}
