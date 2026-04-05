/* ********************************** */
/* * Conversion VDI to pixel format * */ 
/* * 14/01/2015 # 14/01/2015        * */
/* ********************************** */


/* utilise par screen emu */

#define VDI_ROUGE (0)
#define VDI_VERT  (1)
#define VDI_BLEU  (2)



/* Prototype */
uint32 Fcm_vdi2pixelformat( int16 rgb[13], int16 pixelformat );


/* Fonction */
uint32 Fcm_vdi2pixelformat( int16 rgb[13], int16 pixelformat )
{

	uint32	couleur=0;


	/* VDI (0-1000) to RGB (0-255) */
	rgb[VDI_ROUGE] = (rgb[VDI_ROUGE] *255) / 1000;
	rgb[VDI_VERT ] = (rgb[VDI_VERT ] *255) / 1000;
	rgb[VDI_BLEU ] = (rgb[VDI_BLEU ] *255) / 1000;



	/* La valeur 'couleur' doit ˆtre au format   */
	/* 32bits Motorola _RVB                      */
	/* Les conversions vers 32bits Motorola et   */
	/* 24 bits motorola ne sont donc pas … faire */

	switch( pixelformat )
	{
		case PIXEL_15_FALCON:
			couleur=0;	/*      rrrrrvvv vv0bbbbb */

			break;



		case PIXEL_15_MOTOROLA:

			couleur=0;	/*      0rrrrrvv vvvbbbbb */

			break;




		case PIXEL_15_INTEL:

			couleur=0;			/* vvvbbbbb 0rrrrrvv */

			break;




		case PIXEL_16_MOTOROLA:

			couleur=0;	/*      rrrrrvvv vvvbbbbb */

			break;





		case PIXEL_16_INTEL:

			couleur=0;				/* vvvbbbbb rrrrrvvv */

			break;




		case PIXEL_24_INTEL:

			couleur=0;	/* 0BVR */
			break;




		case PIXEL_32_INTEL:

			couleur=0;	/* BVR0 */

			break;



		case PIXEL_32_MOTOROLA:

			/* 0RVB */
			couleur=((uint32)rgb[VDI_ROUGE]<<16) + (rgb[VDI_VERT]<<8) + rgb[VDI_BLEU];

			break;

	}


	return( couleur );

}


#undef VDI_ROUGE
#undef VDI_VERT
#undef VDI_BLEU

