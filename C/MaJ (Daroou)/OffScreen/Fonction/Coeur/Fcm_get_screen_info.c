/* ***************************** */
/* * Get Screen Info           * */
/* * 24/05/2003 MaJ 16/11/2015 * */
/* ***************************** */


#include "Fcm_eddi_version.c"
#include "../Graphique/PIXEL_FORMAT_ID.H"
#include "../Graphique/Fcm_pixel_detect.c"




/* Prototype */
void Fcm_get_screen_info(void);


/* Fonction */
void Fcm_get_screen_info(void)
{

	int16  work_out[280];


/* -------------------------------------------------------------
	Fcm_screen.mode_palette:
		0: pas de palette (ex: TTM 194)
		1: Hardware clut
		2: Software clut (HC or TC)

	Fcm_screen.pixel_format:
		 0: interleaved planes, organized in words (Atari)
		 1: standard format (whole planes)
		 2: packed pixels
		-1: unknow format; not accessible

	Fcm_screen.pixel_xformat:
		 code pour le format ecran (voir PIXEL_FORMAT_ID.H)
   ------------------------------------------------------------- */


	Fcm_screen.adresse=0L;
	Fcm_screen.pixel_xformat=-1;
	Fcm_screen.pixel_format=-1;


	#ifdef LOG_FILE
	sprintf( buf_log, "  ## Fcm_get_screen_info()"CRLF);
	log_print(FALSE);
	#endif



	/* --------------------------------------------------------------- */
	/* valeur par d‚faut pour la conversion device <-> index color VDI */
	/* au cas o— eddi n'est pas present (pour le mode 8 bits)          */
	/* --------------------------------------------------------------- */
	{
		int16 idx;

		for( idx=0; idx<256; idx++ )
		{
			Fcm_screen.palette_to_device[idx]=idx;
		}

		Fcm_screen.palette_to_device[1]=255;
		Fcm_screen.palette_to_device[2]=1;
		Fcm_screen.palette_to_device[3]=2;
		Fcm_screen.palette_to_device[4]=4;
		Fcm_screen.palette_to_device[5]=6;
		Fcm_screen.palette_to_device[6]=3;
		Fcm_screen.palette_to_device[7]=5;
		Fcm_screen.palette_to_device[8]=7;
		Fcm_screen.palette_to_device[9]=8;
		Fcm_screen.palette_to_device[10]=9;
		Fcm_screen.palette_to_device[11]=10;
		Fcm_screen.palette_to_device[12]=12;
		Fcm_screen.palette_to_device[13]=14;
		Fcm_screen.palette_to_device[14]=11;
		Fcm_screen.palette_to_device[15]=13;
		Fcm_screen.palette_to_device[255]=15;
	}



	/*--------------------------------------------------*/
	/* recherchons les dimensions du DESKTOP            */
	/*--------------------------------------------------*/
	wind_get(0,WF_WORKXYWH,&Fcm_screen.x_desktop,&Fcm_screen.y_desktop,&Fcm_screen.w_desktop,&Fcm_screen.h_desktop);


	#ifdef LOG_FILE
	sprintf( buf_log, "  - Dimension desktop: %d,%d,%d,%d"CRLF, Fcm_screen.x_desktop,Fcm_screen.y_desktop,Fcm_screen.w_desktop,Fcm_screen.h_desktop);
	log_print(FALSE);
	#endif



	/*--------------------------------------------------*/
	/* Adresse de la m‚moire ‚cran physique             */
	/*--------------------------------------------------*/
	Fcm_screen.physbase = (uint32)Physbase();




	/****************************************************/
	/* recherchons les infos sur le mode graphique      */
	/****************************************************/
	vq_extnd(vdihandle, 0, work_out);	/* info v_opnvwk() */

	Fcm_screen.width  = work_out[0] + 1;
	Fcm_screen.height = work_out[1] + 1;


	vq_extnd(vdihandle, 1, work_out);	/* info suppl‚mentaire */


	#ifdef LOG_FILE
	sprintf( buf_log, "  - Raster scalling = %d (0=impossible 1=possible)"CRLF, work_out[3] );
	log_print(FALSE);
	#endif

	#ifdef LOG_FILE
	sprintf( buf_log, "  - Performance factor = %d (number 16*16 raster operation/s)"CRLF, work_out[6] );
	log_print(FALSE);
	#endif

	Fcm_screen.nb_plan=work_out[4];


	switch(Fcm_screen.nb_plan)
	{
		case 1:
			Fcm_screen.color =2;
			break;
		case 2:
			Fcm_screen.color =4;
			break;
		case 4:
			Fcm_screen.color =16;
			break;
		case 8:
			Fcm_screen.color =256;
			break;
		case 15:
			Fcm_screen.color =32768;
			break;
		case 16:
			Fcm_screen.color =65536;
			break;
		case 24:
		case 32:
			Fcm_screen.color =16777216;
			break;
	}


	if(Fcm_screen.nb_plan>8)
	{
		Fcm_screen.pixel_format=2;
	}
/*	else
	{
		Fcm_screen.pixel_format=0;
	}*/



/*	if( Fcm_screen.nb_plan==8 )
	{
		if( Fcm_screen.pixel_format==2 )
		{
			Fcm_screen.pixel_xformat=PIXEL_8_PACKED;
		}
		if( Fcm_screen.pixel_format==0 )
		{
			Fcm_screen.pixel_xformat=PIXEL_8_PLAN;
		}
	}*/





	/***************************/
	/* lecture version de EdDI */
	/***************************/
	Fcm_screen.eddi_version = Fcm_eddi_version();

	#ifdef LOG_FILE
	sprintf( buf_log, "  - EdDi version=%x.%02x"CRLF, (Fcm_screen.eddi_version>>8), (Fcm_screen.eddi_version & 0xff) );
	log_print(FALSE);
	#endif




	if(Fcm_screen.eddi_version>0x99)	/* EdDI 1.00 minimum */
	{

		vq_scrninfo( vdihandle, work_out );

		Fcm_screen.color= (uint32)( ((uint32)work_out[3]<<16) + (uint32)work_out[4] );

		Fcm_screen.nb_plan=work_out[2];
		Fcm_screen.pixel_format=work_out[0];

		Fcm_screen.mode_palette=work_out[1];




		/****************************************************/
		/* ----     Recherche du format du pixel      ----  */
		/****************************************************/

		if( Fcm_screen.nb_plan==8 )
		{
			if( Fcm_screen.pixel_format==2 )
			{
				Fcm_screen.pixel_xformat=PIXEL_8_PACKED;
			}
			if( Fcm_screen.pixel_format==0 )
			{
				Fcm_screen.pixel_xformat=PIXEL_8_PLAN;
			}

			{
				int16 idx;

				#ifdef LOG_FILE
				sprintf( buf_log, "  - CLUT = %d (Fcm_screen.mode_palette)"CRLF, Fcm_screen.mode_palette );
				log_print(FALSE);
				#endif

				if( Fcm_screen.mode_palette == 1 )
				{
					#ifdef LOG_FILE
					sprintf( buf_log, "    Hardware Clut:"CRLF );
					log_print(FALSE);
					#endif

					/* Hardware CLUT */
					for( idx=0; idx<256; idx++ )
					{
						Fcm_screen.palette_to_device[idx]=work_out[16+idx];

						#ifdef LOG_FILE
						sprintf( buf_log, "    idx=%5d  -  idx_pixel=%5d"CRLF, idx, Fcm_screen.palette_to_device[idx] );
						log_print(FALSE);
						#endif

					}
				}
			}

		}


		if( Fcm_screen.nb_plan>8 )
		{
			int16 position;
			int16 id_rouge=0;
			int16 id_vert=0;
			int16 id_bleu=0;
			int16 dummy;


			for(dummy=16; dummy<32 ; dummy++)
			{
				position=work_out[dummy];
				if(position>0 && position<32) id_rouge=id_rouge+position;
			}
			for(dummy=32; dummy<48 ; dummy++)
			{
				position=work_out[dummy];
				if(position>0 && position<32) id_vert=id_vert+position;
			}
			for(dummy=48; dummy<64 ; dummy++)
			{
				position=work_out[dummy];
				if(position>0 && position<32) id_bleu=id_bleu+position;
			}


			if(id_rouge==65 && id_vert==40 && id_bleu==10)
				Fcm_screen.pixel_xformat=PIXEL_15_FALCON;

			if(id_rouge==50 && id_vert==35 && id_bleu==10)
				Fcm_screen.pixel_xformat=PIXEL_15_MOTOROLA;

			if(id_rouge==20 && id_vert==43 && id_bleu==50)
				Fcm_screen.pixel_xformat=PIXEL_15_INTEL;

			if(id_rouge==65 && id_vert==45 && id_bleu==10)
				Fcm_screen.pixel_xformat=PIXEL_16_MOTOROLA;

			if(id_rouge==25 && id_vert==45 && id_bleu==50)
				Fcm_screen.pixel_xformat=PIXEL_16_INTEL;

			if(id_rouge==156 && id_vert==92 && id_bleu==28 && Fcm_screen.nb_plan==24)
				Fcm_screen.pixel_xformat=PIXEL_24_MOTOROLA;

			if(id_rouge==28 && id_vert==92 && id_bleu==156)
				Fcm_screen.pixel_xformat=PIXEL_24_INTEL;

			if(id_rouge==156 && id_vert==92 && id_bleu==28 && Fcm_screen.nb_plan==32)
				Fcm_screen.pixel_xformat=PIXEL_32_MOTOROLA;

			if(id_rouge==92 && id_vert==156 && id_bleu==220)
				Fcm_screen.pixel_xformat=PIXEL_32_INTEL;
		}




		/****************************************************/
		/* ----     Adresse physique de l'‚cran       ----  */
		/****************************************************/

		if( Fcm_screen.eddi_version>0x109 )
		{
			Fcm_screen.adresse=((uint32)work_out[6]<<16) + (uint32)work_out[7];
		}

	}


/*	if( Fcm_screen.pixel_xformat==-1)
	{
		Fcm_pixel_detect();
	}*/


	#ifdef LOG_FILE
	sprintf( buf_log, "  - Ecran: %dx%d nb_Plan=%d bits (%ld couleurs)"CRLF, Fcm_screen.width, Fcm_screen.height, Fcm_screen.nb_plan, Fcm_screen.color);
	log_print(FALSE);
	sprintf( buf_log, "  - Adresse ‚cran    (VDI)  =$%lx"CRLF, Fcm_screen.adresse);
	log_print(FALSE);
	sprintf( buf_log, "  - Adresse physbase (XBIOS)=$%lx"CRLF, Fcm_screen.physbase);
	log_print(FALSE);
	sprintf( buf_log, "  - PixelFormat=%d  (0=interleaved planes Atari  1=standard format (whole planes)  2=packed pixels)"CRLF, Fcm_screen.pixel_format );
	log_print(FALSE);
	sprintf( buf_log, "  - PixelXFormat=%d (-1=inconnu,  1:15f 2:15m 3:15i 4:16m 5:16i 6:24m 7:24i 8:32m 9:32i 10:8pk 11:8bp)"CRLF, Fcm_screen.pixel_xformat );
	log_print(FALSE);
	sprintf( buf_log, "  - Mode palette=%d ( 0=pas de palette, 1=Hardware clut, 2=Software clut (HC or TC) )"CRLF""CRLF, Fcm_screen.mode_palette);
	log_print(FALSE);
	#endif


}

