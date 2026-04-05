/* ***************************** */
/* * 20/11/2016 MaJ 15/07/2017 * */
/* ***************************** */




#ifndef ___Fcm_create_sprite_mono___
#define ___Fcm_create_sprite_mono___




void Fcm_create_sprite_mono( s_tga_ldg *image, MFDB *sprite, int16 x, int16 y );




/* Fonction */
void Fcm_create_sprite_mono( s_tga_ldg *image, MFDB *sprite, int16 x, int16 y )
{

	#ifdef LOG_FILE
	sprintf( buf_log, "Fcm_create_sprite_mono"CRLF );
	log_print(FALSE);
	#endif


	/* *************************************************** */
	/* g‚n‚ration du masque … partir du sprite, en         */
	/* fonction de la couleur de transparence au pixel x,y */
	/* *************************************************** */


	/* !!! L'image doit être au format 8bits PACKED !!! */



	{
		uint32  i;
		uint8   bit;
		uint8   bitmask;
		uint8  *ptmask8;
		uint8  *ptimage8;
		uint32  nb_pixel;
		uint8   alphacolor;


		ptmask8  = (uint8 *)sprite->fd_addr;
		ptimage8 = (uint8 *)image->adr_decode;
		nb_pixel = (uint32 )image->frame_width * (uint32)image->frame_height;

		alphacolor = ptimage8[ (y * image->frame_width) + x ];

		
		#ifdef LOG_FILE
		sprintf( buf_log, "alphacolor=%d"CRLF, alphacolor );
		log_print(FALSE);
		#endif


		for( i=0; i<nb_pixel; )
		{

			bitmask=0;

			for( bit=0; bit<8; bit++)
			{
				if( *ptimage8!=alphacolor && *ptimage8!=0)
				{
					bitmask++;
				}
				if( bit<7 )
				{
					bitmask=bitmask<<1;
				}
				ptimage8++;
				i++;
			}

			*ptmask8++ = bitmask;
		}
	}


	return;

}

#endif

