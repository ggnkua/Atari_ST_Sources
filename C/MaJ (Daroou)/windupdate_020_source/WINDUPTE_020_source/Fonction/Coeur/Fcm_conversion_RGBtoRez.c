/* **************************************** */
/* * Conversion _RGB to Resolution format * */ 
/* * 31/12/2002  04/03/2013               * */
/* **************************************** */


/* Prototype */
ULONG Fcm_conversion_RGBtoRez( ULONG couleur );


/* Fonction */
ULONG Fcm_conversion_RGBtoRez( ULONG couleur )
{
/*
 * extern	UWORD	screen_pixel_xformat;
 *
 */

	UWORD	rouge,vert,bleu;



	/* La valeur 'couleur' doit ˆtre au format   */
	/* 32bits Motorola _RVB                      */
	/* Les conversions vers 32bits Motorola et   */
	/* 24 bits motorola ne sont donc pas … faire */

	switch( screen_pixel_xformat )
	{
		case PIXEL_15_FALCON:

			/* couleur contient 00000000rrrrrrrrvvvvvvvvbbbbbbbb */
			rouge=(UWORD)( (float)( (couleur>>16)& 0xFF )*0.125 );
			/* rouge contient maintenant 00000000000rrrrr */

			vert =(UWORD)( (float)( (couleur>> 8)& 0xFF )*0.125 );
			/* vert contient maintenant  00000000000vvvvv */

			bleu =(UWORD)( (float)(  couleur     & 0xFF )*0.125 );
							   /* bleu contient 00000000000bbbbb */

			rouge= rouge << 11;		/* contient rrrrr00000000000 */
			vert = vert  <<  6;		/* contient 00000vvvvv000000 */
			couleur=rouge+vert+bleu;	/*      rrrrrvvvvv0bbbbb */

			break;



		case PIXEL_15_MOTOROLA:

			/* couleur contient 00000000rrrrrrrrvvvvvvvvbbbbbbbb */
			rouge=(UWORD)( (float)( (couleur>>16)& 0xFF )*0.125 );
			/* rouge contient maintenant 00000000000rrrrr */

			vert =(UWORD)( (float)( (couleur>> 8)& 0xFF )*0.125 );
			/* vert contient maintenant  00000000000vvvvv */

			bleu =(UWORD)( (float)(  couleur     & 0xFF )*0.125 );
							   /* bleu contient 00000000000bbbbb */


			rouge= rouge << 10;		/* contient 0rrrrr0000000000 */
			vert = vert  <<  5;		/* contient 000000vvvvv00000 */
			couleur=rouge+vert+bleu;	/*      0rrrrrvvvvvbbbbb */

			break;




		case PIXEL_15_INTEL:

			/* couleur contient 00000000rrrrrrrrvvvvvvvvbbbbbbbb */
			rouge=(UWORD)( (float)( (couleur>>16)& 0xFF )*0.125 );
			/* rouge contient maintenant 00000000000rrrrr */

			vert =(UWORD)( (float)( (couleur>> 8)& 0xFF )*0.125 );
			/* vert contient maintenant  00000000000vvvvv */

			bleu =(UWORD)( (float)(  couleur     & 0xFF )*0.125 );
							   /* bleu contient 00000000000bbbbb */

			rouge= rouge << 10;		/* contient 0rrrrr0000000000 */
			vert = vert  <<  5;		/* contient 000000vvvvv00000 */
			couleur=rouge+vert+bleu;	/*      0rrrrrvvvvvbbbbb */

			rouge  =(couleur & 0xFF00) >> 8;	/* 000000000rrrrrvv */
			couleur=(couleur & 0x00FF) << 8;	/* vvvbbbbb00000000 */
			couleur=couleur+rouge;				/* vvvbbbbb0rrrrrvv */

			break;




		case PIXEL_16_MOTOROLA:

			/* couleur contient 00000000rrrrrrrrvvvvvvvvbbbbbbbb */
			rouge=(UWORD)( (float)( (couleur>>16)& 0xFF )*0.125 );
			/* rouge contient maintenant 00000000000rrrrr */

			vert =(UWORD)( (float)( (couleur>> 8)& 0xFF )*0.250 );
			/* vert contient maintenant  0000000000vvvvvv */

			bleu =(UWORD)( (float)(  couleur     & 0xFF )*0.125 );
							   /* bleu contient 00000000000bbbbb */

			rouge= rouge << 11;		/* contient rrrrr00000000000 */
			vert = vert  <<  5;		/* contient 00000vvvvvv00000 */
			couleur=rouge+vert+bleu;	/*      rrrrrvvvvvvbbbbb */

			break;





		case PIXEL_16_INTEL:

			/* couleur contient 00000000rrrrrrrrvvvvvvvvbbbbbbbb */
			rouge=(UWORD)( (float)( (couleur>>16)& 0xFF )*0.125 );
			/* rouge contient maintenant 00000000000rrrrr */

			vert =(UWORD)( (float)( (couleur>> 8)& 0xFF )*0.250 );
			/* vert contient maintenant  0000000000vvvvvv */

			bleu =(UWORD)( (float)(  couleur     & 0xFF )*0.125 );
							   /* bleu contient 00000000000bbbbb */
			rouge= rouge << 11;		/* contient rrrrr00000000000 */
			vert = vert  <<  5;		/* contient 00000vvvvvv00000 */

			couleur=rouge+vert+bleu;			/* rrrrrvvvvvvbbbbb */
			rouge  =(couleur & 0xFF00) >> 8;	/* 00000000rrrrrvvv */
			couleur=(couleur & 0x00FF) << 8;	/* vvvbbbbb00000000 */
			couleur=couleur+rouge;				/* vvvbbbbbrrrrrvvv */

			break;




		case PIXEL_24_INTEL:

			/* couleur contient 00000000rrrrrrrrvvvvvvvvbbbbbbbb */
			rouge=(couleur & 0x00FF0000) >> 16;
			vert =(couleur & 0x0000FF00);
			bleu =(couleur & 0x000000FF) << 16;
			couleur=rouge+vert+bleu;	/* 0BVR */
			break;




		case PIXEL_32_INTEL:

			/* couleur contient 00000000rrrrrrrrvvvvvvvvbbbbbbbb */
			rouge=(couleur & 0x00FF0000) >>  8;
			vert =(couleur & 0x0000FF00) <<  8;
			bleu =(couleur & 0x000000FF) << 24;
			couleur=rouge+vert+bleu;	/* BVR0 */

			break;
	}


	return( couleur );

}

