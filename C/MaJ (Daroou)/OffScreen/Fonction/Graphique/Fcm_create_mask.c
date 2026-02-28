/* ***************************** */
/* * 30/01/2013 MaJ 15/04/2015 * */
/* ***************************** */




#ifndef ___Fcm_create_mask___
#define ___Fcm_create_mask___




void Fcm_create_mask( MFDB *surface, MFDB *mask, int16 x, int16 y );




/* Fonction */
void Fcm_create_mask( MFDB *surface, MFDB *mask, int16 x, int16 y )
{


	/* *************************************************** */
	/* g‚n‚ration du masque … partir du sprite, en         */
	/* fonction de la couleur de transparence au pixel x,y */
	/* *************************************************** */





	/* ----------------------------------- */
	/* Ecran en 24 bits                    */
	/* ----------------------------------- */
	if( Fcm_screen.nb_plan==24 )
	{
		/* !!! … v‚rifier !!! */
		/* !!! … v‚rifier !!! */
		/* !!! … v‚rifier !!! */
		/* !!! … v‚rifier !!! */
		/* !!! … v‚rifier !!! */
		/* !!! … v‚rifier !!! */
		uint32  i;
		uint8   bit;
		uint8   bitmask;
		uint8  *ptmask8;
		uint8  *ptimage8;
		uint8  *alphacolor;
		uint32  nb_pixel;


		ptmask8  = (uint8 *)mask->fd_addr;
		ptimage8 = (uint8 *)surface->fd_addr;
		nb_pixel = (uint32 )surface->fd_w * (uint32)surface->fd_h;

		alphacolor = ptimage8 + (y*surface->fd_w*3) + (x*3);

		for( i=0; i<nb_pixel; )
		{

			bitmask=0;

			for( bit=0; bit<8; bit++)
			{
				if( ptimage8[0] != alphacolor[0] ||  ptimage8[1] != alphacolor[1] ||  ptimage8[2] != alphacolor[2] )
				{
					bitmask++;
				}
				if( bit<7 )
				{
					bitmask=bitmask<<1;
				}
				i++;

				ptimage8 = ptimage8 + 3;

			}

			*ptmask8++ = bitmask;
		}
	}







	/* ----------------------------------- */
	/* Ecran en 8 bits                     */
	/* ----------------------------------- */
	if( Fcm_screen.nb_plan == 8 )
	{
		uint32  i;
		uint8   bit;
		uint8   bitmask;
		uint8  *ptmask8;
		uint8  *ptimage8;
		uint32  nb_pixel;
		uint8   alphacolor;


		ptmask8  = (uint8 *)mask->fd_addr;
		ptimage8 = (uint8 *)surface->fd_addr;
		nb_pixel = (uint32 )surface->fd_w * (uint32)surface->fd_h;

		alphacolor = ptimage8[ (y * surface->fd_w) + x ];

		for( i=0; i<nb_pixel; )
		{

			bitmask=0;

			for( bit=0; bit<8; bit++)
			{
				if( *ptimage8++ != alphacolor )
				{
					bitmask++;
				}
				if( bit<7 )
				{
					bitmask=bitmask<<1;
				}
				i++;
			}

			*ptmask8++ = bitmask;
		}
	}




	/* ----------------------------------- */
	/* Ecran en 32 bits                    */
	/* ----------------------------------- */
	if( Fcm_screen.nb_plan==32 )
	{
		uint32  i;
		uint8   bit;
		uint8   bitmask;
		uint8  *pt8;
		uint32 *pt32;
		uint32  nb_pixel;
		uint32  alphacolor;


		pt8     = (uint8  *)mask->fd_addr;
		pt32    = (uint32 *)surface->fd_addr;
		nb_pixel= (uint32)surface->fd_w * (uint32)surface->fd_h;

		alphacolor = pt32[ (y*surface->fd_w)+x ];


		for( i=0; i<nb_pixel; )
		{

			bitmask=0;

			for( bit=0; bit<8; bit++)
			{
				if( *pt32++ != alphacolor )
				{
					bitmask++;
				}
				if( bit<7 )
				{
					bitmask=bitmask<<1;
				}
				i++;
			}

			*pt8++ = bitmask;
		}
	}









	/* ----------------------------------- */
	/* Ecran en 16 bits                    */
	/* ----------------------------------- */
	if( Fcm_screen.nb_plan == 16 )
	{
		uint32  i;
		uint8   bit;
		uint8   bitmask;
		uint8  *pt8;
		uint16 *pt16;
		uint32  nb_pixel;
		uint16  alphacolor;


		pt8     = (uint8  *)mask->fd_addr;
		pt16    = (uint16 *)surface->fd_addr;
		nb_pixel= (uint32)surface->fd_w * (uint32)surface->fd_h;

		alphacolor = pt16[ (y*surface->fd_w)+x ];

		for( i=0; i<nb_pixel; )
		{

			bitmask=0;

			for( bit=0; bit<8; bit++)
			{
				if( *pt16++ != alphacolor )
				{
					bitmask++;
				}
				if( bit<7 )
				{
					bitmask=bitmask<<1;
				}
				i++;
			}

			*pt8++ = bitmask;
		}
	}






	return;


}



#endif


