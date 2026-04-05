/* **[Fonction commune]********* */
/* *                           * */
/* * 11/04/2015 MaJ 11/04/2015 * */
/* ***************************** */



#ifndef ___FCM_PIXEL_DETECT___
#define ___FCM_PIXEL_DETECT___


#define  WINDETECT_W   (120)
#define  WINDETECT_H   (120)
#define  WINDETECT_BCL (1000)



/* prototype */
void  Fcm_pixel_detect( void );
void  Fcm_pxd_check_8bits ( uint32 adresse_pixel, int16 x, int16 y );
void  Fcm_pxd_check_8bits_old ( uint32 adresse_pixel, int16 x, int16 y, int16 w, int16 h );
void  Fcm_pxd_check_16bits( uint32 adresse_pixel, int16 x, int16 y, int16 w, int16 h );
void  Fcm_pxd_check_32bits( uint32 adresse_pixel, int16 x, int16 y, int16 w, int16 h );
int16 Fcm_pxd_recherche_couleur( int16 rgb[3] );




/* Fonction */
void Fcm_pixel_detect( void )
{
	int16	winx,winy,winw,winh;
	int16   winhandle;
	int16   nb_octet_par_pixel;
	uint32  adresse_ecran;
	uint32  adresse_pixel;






	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"- Fcm_pixel_detect()"CRLF);
	log_print(FALSE);
	sprintf( buf_log, "- Adresse ‚cran VDI      : $%lx"CRLF, Fcm_screen.adresse);
	log_print(FALSE);
	sprintf( buf_log, "- Adresse ‚cran Physbase : $%lx"CRLF, Fcm_screen.physbase);
	log_print(FALSE);
	sprintf( buf_log, "- Nombre de plan         : %d"CRLF, Fcm_screen.nb_plan);
	log_print(FALSE);
	#endif


	adresse_ecran = Fcm_screen.adresse;

	if( adresse_ecran == 0 )
	{
		adresse_ecran = Fcm_screen.physbase;
	}

	if( adresse_ecran == 0 )
	{
		#ifdef LOG_FILE
		sprintf( buf_log, "=> adresse ‚cran ind‚fini"CRLF );
		log_print(FALSE);
		#endif

		return;
	}

	#ifdef LOG_FILE
	sprintf( buf_log, "=> adresse ‚cran: $%lx"CRLF, adresse_ecran );
	log_print(FALSE);
	#endif



	{
		/* on demande … l'AES de nous calculer la taille de la fenˆtre */
		/* en fonction de la zone de travail                           */
		wind_calc(0,NAME, 0,0,WINDETECT_W,WINDETECT_H, &winx, &winy, &winw, &winh );



		/* On demande … l'AES de cr‚er notre fenˆtre */
		winhandle=wind_create(NAME,winx,winy,winw,winh);

		winx = (Fcm_screen.width-winw)/2;
		winy = (Fcm_screen.height-winh)/2;

		if( winhandle>0 )
		{
			/* Si la fenˆtre a pu ˆtre cr‚er, on lui donne un nom ... */
			wind_set_str(winhandle,WF_NAME,"Pixel Detect");
			/* ... et on demande … l'AES de l'ouvrir */
			wind_open(winhandle,winx,winy,winw,winh);


wind_update(BEG_UPDATE);


			{
				int16   pxy[4];

				/* on cherche les coordonn‚es de travail de la fenˆtre */
				wind_get(winhandle,WF_WORKXYWH,&winx,&winy,&winw,&winh);

				/* mode normal */
				pxy[0]=winx;
				pxy[1]=winy;
				pxy[2]=winx+winw-1;
				pxy[3]=winy+winh-1;

				vsf_color( vdihandle, G_BLACK);
				vsf_interior( vdihandle, 1);
				vr_recfl( vdihandle, pxy);

			}


			nb_octet_par_pixel = Fcm_screen.nb_plan / 8;

			adresse_pixel = adresse_ecran + (winy * (Fcm_screen.width * nb_octet_par_pixel) );
			adresse_pixel = adresse_pixel + (winx * nb_octet_par_pixel);


			evnt_timer(400);


			if( Fcm_screen.nb_plan == 8 )
			{
/*				Fcm_pxd_check_8bits( adresse_pixel, winx, winy, winw, winh );*/
				Fcm_pxd_check_8bits( adresse_pixel, winx, winy );
			}
			if( Fcm_screen.nb_plan == 16 )
			{
				Fcm_pxd_check_16bits( adresse_pixel, winx, winy, winw, winh );
			}
			if( Fcm_screen.nb_plan == 32 )
			{
				Fcm_pxd_check_32bits( adresse_pixel, winx, winy, winw, winh );
			}


			evnt_timer(400);


wind_update(END_UPDATE);


			wind_close(winhandle);


		}
		else
		{
			/* plus de fenetre disponible */
		}

	}


	#ifdef LOG_FILE
	sprintf( buf_log, CRLF""CRLF);
	log_print(FALSE);
	#endif


	return;


}











void Fcm_pxd_check_8bits_old( uint32 adresse_pixel, int16 x, int16 y, int16 w, int16 h )
{
	uint8 *pt_pixel = (uint8 *)adresse_pixel;
	int16  index;
	int16  pixel_value;
	int16  color_idx;
	int16  bit_packed=0;



	#ifdef LOG_FILE
	sprintf( buf_log, " Fcm_check_8bits()"CRLF );
	log_print(FALSE);
	#endif


	pxy[0]=x;
	pxy[1]=y;
	pxy[2]=x+w-1;
	pxy[3]=y+h-1;
	vsf_interior( vdihandle, 1);


	for( index=0; index<256; index++ )
	{

		vsf_color( vdihandle, index );
		vr_recfl( vdihandle, pxy);

		*pt_pixel = index;
		v_get_pixel( vdihandle, x, y, &pixel_value, &color_idx );

		if( index == pixel_value )
		{
			bit_packed++;
		}

		#ifdef LOG_FILE
		sprintf( buf_log, " index=%03d - pixel_value=%04d - color_idx=%04d  pt_pixel=%04d"CRLF, index, pixel_value, color_idx, *pt_pixel );
		log_print(FALSE);
		#endif
	}

	#ifdef LOG_FILE
	sprintf( buf_log, " bit_packed=%d/256"CRLF, bit_packed );
	log_print(FALSE);
	#endif

	Fcm_screen.pixel_xformat = PIXEL_8_PLAN;

	if( bit_packed == 256 )
	{
		Fcm_screen.pixel_xformat = PIXEL_8_PACKED;
	}

	#ifdef LOG_FILE
	sprintf( buf_log, " Fcm_screen.pixel_xformat=%d"CRLF, Fcm_screen.pixel_xformat );
	log_print(FALSE);
	#endif

	return;


}
















void Fcm_pxd_check_8bits( uint32 adresse_pixel, int16 x, int16 y )
{
	uint8 *pt_pixel = (uint8 *)adresse_pixel;
	int16  index;
	int16  pixel_value;
	int16  color_idx;
	int16  bit_packed=0;



	#ifdef LOG_FILE
	sprintf( buf_log, " Fcm_check_8bits()"CRLF );
	log_print(FALSE);
	#endif


	for( index=0; index<256; index++ )
	{
		*pt_pixel = index;
		v_get_pixel( vdihandle, x, y, &pixel_value, &color_idx );

		if( index == pixel_value )
		{
			bit_packed++;
		}

		#ifdef LOG_FILE
		sprintf( buf_log, " index=%03d - pixel_value=%04d - color_idx=%04d"CRLF, index, pixel_value, color_idx );
		log_print(FALSE);
		#endif
	}

	#ifdef LOG_FILE
	sprintf( buf_log, " bit_packed=%d/256"CRLF, bit_packed );
	log_print(FALSE);
	#endif

	Fcm_screen.pixel_xformat = PIXEL_8_PLAN;

	if( bit_packed == 256 )
	{
		Fcm_screen.pixel_xformat = PIXEL_8_PACKED;
	}

	#ifdef LOG_FILE
	sprintf( buf_log, " Fcm_screen.pixel_xformat=%d"CRLF, Fcm_screen.pixel_xformat );
	log_print(FALSE);
	#endif

	return;


}










void Fcm_pxd_check_16bits( uint32 adresse_pixel, int16 x, int16 y, int16 w, int16 h )
{
	uint16 *pt_pixel = (uint16 *)(adresse_pixel);
/*	int16   index;*/
/*	int16   pixel_value;*/
/*	int16   color_idx;*/
/*	int16   bit_packed=0;*/
	int16   pxy[4];
	int16   idx_couleur;
	int16   bcl;
	uint16   old_value=0x1234;
	int16   pos=0;
	uint16  red=0;
	uint16  green=0;
	uint16  blue=0;



	#ifdef LOG_FILE
	sprintf( buf_log, " Fcm_check_16bits()"CRLF );
	log_print(FALSE);
	#endif


	#ifdef LOG_FILE
	sprintf( buf_log, " adresse_pixel=%04lx x=%d y=%d "CRLF, adresse_pixel, x, y );
	log_print(FALSE);
	#endif
	#ifdef LOG_FILE
	sprintf( buf_log, " offset adresse_pixel=%04ld "CRLF, adresse_pixel- (Fcm_screen.physbase | Fcm_screen.adresse) );
	log_print(FALSE);
	#endif



	pxy[0]=x;
	pxy[1]=y;
	pxy[2]=x+w-1;
	pxy[3]=y+h-1;
	vsf_interior( vdihandle, 1);



	#ifdef LOG_FILE
	sprintf( buf_log, CRLF" Check pixel BLACK"CRLF );
	log_print(FALSE);
	#endif


	old_value=0x1234;


	/* Check pixel BLACK */
	for( bcl=0; bcl<WINDETECT_BCL; bcl++)
	{
		/*v_get_pixel( vdihandle, x, y, &pixel_value, &color_idx );*/

		if( *pt_pixel != old_value )
		{
			break;
		}
		evnt_timer(20);

	}
#ifdef LOG_FILE
sprintf( buf_log, " old_value=%04x - *pt_pixel=%04x bcl=%d"CRLF, old_value, pt_pixel[0], bcl );
log_print(FALSE);
#endif



	old_value=*pt_pixel;





	#ifdef LOG_FILE
	sprintf( buf_log, CRLF" Check pixel RED"CRLF );
	log_print(FALSE);
	#endif


	evnt_timer(400);



	/* Check pixel RED */
	{
		int16 rgb[3];

		rgb[0]=1000;
		rgb[1]=0;
		rgb[2]=0;

		idx_couleur = Fcm_pxd_recherche_couleur( rgb  );
	}


	if( idx_couleur != -1 )
	{
		vsf_color( vdihandle, idx_couleur);
		vr_recfl( vdihandle, pxy);
		pos=0;

		for( bcl=0; bcl<WINDETECT_BCL; bcl++)
		{

/*#ifdef LOG_FILE
sprintf( buf_log, " old_value=%04x - pt_pixel[%d]=%04x bcl=%d"CRLF, old_value, pos, pt_pixel[pos], bcl );
log_print(FALSE);
#endif*/

			if( pt_pixel[pos] != old_value )
			{
				break;
			}

			pos++;
			if( pos == WINDETECT_W )
			{
				pos=0;
			}

/*			evnt_timer(20);*/

		}

#ifdef LOG_FILE
sprintf( buf_log, " old_value=%04x - *pt_pixel=%04x bcl=%d"CRLF, old_value, pt_pixel[pos], bcl );
log_print(FALSE);
#endif

		red=pt_pixel[pos];

	}

	old_value=pt_pixel[pos];


	evnt_timer(400);




	#ifdef LOG_FILE
	sprintf( buf_log, CRLF" Check pixel GREEN"CRLF );
	log_print(FALSE);
	#endif

	/* Check pixel GREEN */
	{
		int16 rgb[3];

		rgb[0]=0;
		rgb[1]=1000;
		rgb[2]=0;

		idx_couleur = Fcm_pxd_recherche_couleur( rgb  );
	}


	if( idx_couleur != -1 )
	{
		vsf_color( vdihandle, idx_couleur);
		vr_recfl( vdihandle, pxy);
		pos=0;

		for( bcl=0; bcl<WINDETECT_BCL; bcl++)
		{

/*#ifdef LOG_FILE
sprintf( buf_log, " old_value=%04x - pt_pixel[%d]=%04x bcl=%d"CRLF, old_value, pos, pt_pixel[pos], bcl );
log_print(FALSE);
#endif*/

			if( pt_pixel[pos] != old_value )
			{
				break;
			}

			pos++;
			if( pos == WINDETECT_W )
			{
				pos=0;
			}

/*			evnt_timer(20);*/

		}

#ifdef LOG_FILE
sprintf( buf_log, " old_value=%04x - *pt_pixel=%04x bcl=%d"CRLF, old_value, pt_pixel[pos], bcl );
log_print(FALSE);
#endif

		green=pt_pixel[pos];

	}

	old_value=pt_pixel[pos];





	#ifdef LOG_FILE
	sprintf( buf_log, CRLF" Check pixel BLUE"CRLF );
	log_print(FALSE);
	#endif

	/* Check pixel BLUE */
	{
		int16 rgb[3];

		rgb[0]=0;
		rgb[1]=0;
		rgb[2]=1000;

		idx_couleur = Fcm_pxd_recherche_couleur( rgb  );
	}


	if( idx_couleur != -1 )
	{
		vsf_color( vdihandle, idx_couleur);
		vr_recfl( vdihandle, pxy);
		pos=0;

		for( bcl=0; bcl<WINDETECT_BCL; bcl++)
		{

/*#ifdef LOG_FILE
sprintf( buf_log, " old_value=%04x - pt_pixel[%d]=%04x bcl=%d"CRLF, old_value, pos, pt_pixel[pos], bcl );
log_print(FALSE);
#endif*/

			if( pt_pixel[pos] != old_value )
			{
				break;
			}

			pos++;
			if( pos == WINDETECT_W )
			{
				pos=0;
			}

/*			evnt_timer(20);*/

		}

#ifdef LOG_FILE
sprintf( buf_log, " old_value=%04x - *pt_pixel=%04x bcl=%d"CRLF, old_value, pt_pixel[pos], bcl );
log_print(FALSE);
#endif

		blue=pt_pixel[pos];

	}

	old_value=pt_pixel[pos];



#ifdef LOG_FILE
sprintf( buf_log, CRLF" red=%04x - green=%04x - blue=%04x"CRLF, red, green, blue );
log_print(FALSE);
#endif




	if( red==0xf800 && green==0x7c0 && blue==0x1f )
	{
		Fcm_screen.pixel_xformat = PIXEL_15_FALCON;
	}

	if( red==0x7c && green==0xe003 && blue==0x1f00 )
	{
		Fcm_screen.pixel_xformat = PIXEL_15_INTEL;
	}

	if( red==0x7c00 && green==0x3e0 && blue==0x1f )
	{
		Fcm_screen.pixel_xformat = PIXEL_15_MOTOROLA;
	}

	if( red==0xf8 && green==0xe007 && blue==0x1f00 )
	{
		Fcm_screen.pixel_xformat = PIXEL_16_INTEL;
	}
	if( red==0xf800 && green==0x7e0 && blue==0x1f )
	{
		Fcm_screen.pixel_xformat = PIXEL_16_MOTOROLA;
	}





	return;


}












void Fcm_pxd_check_32bits( uint32 adresse_pixel, int16 x, int16 y, int16 w, int16 h )
{
	uint32 *pt_pixel = (uint32 *)(adresse_pixel);
/*	int16   index;*/
/*	int16   pixel_value;*/
/*	int16   color_idx;*/
/*	int16   bit_packed=0;*/
	int16   pxy[4];
	int16   idx_couleur;
	int16   bcl;
	uint32   old_value=0x1234;
	int16   pos=0;
	uint32  red=0;
	uint32  green=0;
	uint32  blue=0;



	#ifdef LOG_FILE
	sprintf( buf_log, " Fcm_check_32bits()"CRLF );
	log_print(FALSE);
	#endif


	#ifdef LOG_FILE
	sprintf( buf_log, " adresse_pixel=%04lx x=%d y=%d "CRLF, adresse_pixel, x, y );
	log_print(FALSE);
	#endif
	#ifdef LOG_FILE
	sprintf( buf_log, " offset adresse_pixel=%04ld "CRLF, adresse_pixel- (Fcm_screen.physbase | Fcm_screen.adresse) );
	log_print(FALSE);
	#endif



	pxy[0]=x;
	pxy[1]=y;
	pxy[2]=x+w-1;
	pxy[3]=y+h-1;
	vsf_interior( vdihandle, 1);



	#ifdef LOG_FILE
	sprintf( buf_log, CRLF" Check pixel BLACK"CRLF );
	log_print(FALSE);
	#endif


	old_value=0x12345678;


	/* Check pixel BLACK */
	for( bcl=0; bcl<WINDETECT_BCL; bcl++)
	{
		/*v_get_pixel( vdihandle, x, y, &pixel_value, &color_idx );*/

		if( *pt_pixel != old_value )
		{
			break;
		}
		evnt_timer(20);

	}
/*#ifdef LOG_FILE
sprintf( buf_log, " old_value=%08lx - *pt_pixel=%08lx bcl=%d"CRLF, old_value, pt_pixel[0], bcl );
log_print(FALSE);
#endif*/



	old_value=*pt_pixel;





	#ifdef LOG_FILE
	sprintf( buf_log, CRLF" Check pixel RED"CRLF );
	log_print(FALSE);
	#endif





	/* Check pixel RED */
	{
		int16 rgb[3];

		rgb[0]=1000;
		rgb[1]=0;
		rgb[2]=0;

		idx_couleur = Fcm_pxd_recherche_couleur( rgb  );
	}


	if( idx_couleur != -1 )
	{
		vsf_color( vdihandle, idx_couleur);
		vr_recfl( vdihandle, pxy);
		pos=0;

		for( bcl=0; bcl<WINDETECT_BCL; bcl++)
		{

/*#ifdef LOG_FILE
sprintf( buf_log, " pt_pixel[%d]=%08lx bcl=%d"CRLF, pos, pt_pixel[pos], bcl );
log_print(FALSE);
#endif*/

			if( pt_pixel[pos] != old_value )
			{
				break;
			}

			pos++;
			if( pos == WINDETECT_W )
			{
				pos=0;
			}

			evnt_timer(20);

		}

#ifdef LOG_FILE
sprintf( buf_log, " old_value=%08lx - *pt_pixel=%08lx bcl=%d"CRLF, old_value, pt_pixel[pos], bcl );
log_print(FALSE);
#endif

		red=pt_pixel[pos];

	}

	old_value=pt_pixel[pos];





	evnt_timer(400);




	#ifdef LOG_FILE
	sprintf( buf_log, CRLF" Check pixel GREEN"CRLF );
	log_print(FALSE);
	#endif

	/* Check pixel GREEN */
	{
		int16 rgb[3];

		rgb[0]=0;
		rgb[1]=1000;
		rgb[2]=0;

		idx_couleur = Fcm_pxd_recherche_couleur( rgb  );
	}


	if( idx_couleur != -1 )
	{
		vsf_color( vdihandle, idx_couleur);
		vr_recfl( vdihandle, pxy);
		pos=0;

		for( bcl=0; bcl<WINDETECT_BCL; bcl++)
		{

/*#ifdef LOG_FILE
sprintf( buf_log, " pt_pixel[%d]=%08lx bcl=%d"CRLF, pos, pt_pixel[pos], bcl );
log_print(FALSE);
#endif*/

			if( pt_pixel[pos] != old_value )
			{
				break;
			}

			pos++;
			if( pos == WINDETECT_W )
			{
				pos=0;
			}

			evnt_timer(20);

		}

#ifdef LOG_FILE
sprintf( buf_log, " old_value=%08lx - *pt_pixel=%08lx bcl=%d"CRLF, old_value, pt_pixel[pos], bcl );
log_print(FALSE);
#endif

		green=pt_pixel[pos];

	}

	old_value=pt_pixel[pos];





	evnt_timer(400);




	#ifdef LOG_FILE
	sprintf( buf_log, CRLF" Check pixel BLUE"CRLF );
	log_print(FALSE);
	#endif

	/* Check pixel BLUE */
	{
		int16 rgb[3];

		rgb[0]=0;
		rgb[1]=0;
		rgb[2]=1000;

		idx_couleur = Fcm_pxd_recherche_couleur( rgb  );
	}


	if( idx_couleur != -1 )
	{
		vsf_color( vdihandle, idx_couleur);
		vr_recfl( vdihandle, pxy);
		pos=0;

		for( bcl=0; bcl<WINDETECT_BCL; bcl++)
		{

/*#ifdef LOG_FILE
sprintf( buf_log, " old_value=%04x - pt_pixel[%d]=%04x bcl=%d"CRLF, old_value, pos, pt_pixel[pos], bcl );
log_print(FALSE);
#endif*/

			if( pt_pixel[pos] != old_value )
			{
				break;
			}

			pos++;
			if( pos == WINDETECT_W )
			{
				pos=0;
			}

			evnt_timer(20);

		}

#ifdef LOG_FILE
sprintf( buf_log, " old_value=%08lx - *pt_pixel=%08lx bcl=%d"CRLF, old_value, pt_pixel[pos], bcl );
log_print(FALSE);
#endif

		blue=pt_pixel[pos];

	}

	old_value=pt_pixel[pos];



#ifdef LOG_FILE
sprintf( buf_log, CRLF" red=%08lx - green=%08lx - blue=%08lx"CRLF, red, green, blue );
log_print(FALSE);
#endif





	if( red==0xff && green==0xff00 && blue==0xff0000 )
	{
		Fcm_screen.pixel_xformat = PIXEL_32_INTEL;
	}

	if( red==0xff0000 && green==0xff00 && blue==0xff )
	{
		Fcm_screen.pixel_xformat = PIXEL_32_MOTOROLA;
	}





	return;


}













int16  Fcm_pxd_recherche_couleur( int16 rgb[3] )
{
	int16 idx;
	int16 reponse=-1;
	int16 rgb_in[3];


	for( idx=0; idx<256; idx++ )
	{
		if( vq_color( vdihandle, idx, 1, rgb_in) != -1 )
		{
			if(  rgb_in[0]==rgb[0] &&  rgb_in[1]==rgb[1] &&  rgb_in[2]==rgb[2] )
			{
				reponse=idx;
				break;
			}
		}
	}

	return reponse;

}




#endif

