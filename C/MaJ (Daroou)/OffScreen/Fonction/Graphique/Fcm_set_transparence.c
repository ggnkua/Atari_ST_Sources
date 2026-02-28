/* ***************************** */
/* * 30/01/2013 MaJ 15/04/2015 * */
/* ***************************** */




#ifndef ___Fcm_set_transparence___
#define ___Fcm_set_transparence___




void Fcm_set_transparence( MFDB *mfdb, uint16 x, uint16 y );



/* Fonction */
void Fcm_set_transparence( MFDB *mfdb, uint16 x, uint16 y )
{

	uint32  nb_pixel=(uint32)mfdb->fd_w * (uint32)mfdb->fd_h;
	uint32  index;



	if( mfdb->fd_nplanes==24 )
	{
		/* !!! … v‚rifier !!! */
		/* !!! … v‚rifier !!! */
		/* !!! … v‚rifier !!! */
		/* !!! … v‚rifier !!! */
		/* !!! … v‚rifier !!! */
		/* !!! … v‚rifier !!! */
		/* !!! … v‚rifier !!! */
		uint8 *pt8        = (uint8 *)mfdb->fd_addr;
		uint8 *alphacolor = pt8 + (y*mfdb->fd_w*3) + (x*3);


		for( index=0; index<nb_pixel; index++ )
		{
			if( pt8[0]==alphacolor[0] && pt8[1]==alphacolor[1] && pt8[2]==alphacolor[2])
			{
				pt8[0]=0;
				pt8[1]=0;
				pt8[2]=0;
			}

			pt8 = pt8 + 3;

		}

	}




	if( mfdb->fd_nplanes == 32 )
	{
		uint32 *pt32=mfdb->fd_addr;
		uint32  alphacolor = pt32[ (y*mfdb->fd_w)+x ];


		for( index=0; index<nb_pixel; index++ )
		{
			if( *pt32==alphacolor )
			{
				*pt32=0;
			}
			pt32++;
		}
	}



	if( mfdb->fd_nplanes == 16 )
	{
		uint16 *pt16=(uint16 *)mfdb->fd_addr;
		uint16  alphacolor = pt16[ (y*mfdb->fd_w)+x ];


		for( index=0; index<nb_pixel; index++ )
		{
			if( *pt16==alphacolor )
			{
				*pt16=0;
			}
			pt16++;
		}
	}





	if( mfdb->fd_nplanes == 8 )
	{
		uint8 *pt8        = (uint8 *)mfdb->fd_addr;
		uint8  alphacolor = pt8[ (y*mfdb->fd_w)+x ];


		for( index=0; index<nb_pixel; index++ )
		{
			if( *pt8==alphacolor )
			{
				*pt8=0;
			}
			pt8++;
		}
	}




	return;


}


#endif


