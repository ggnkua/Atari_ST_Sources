/* *************************** */
/* *      Get Screen Info    * */
/* * 24/05/2003 - 07/01/2015 * */
/* *************************** */


#include "Fcm_eddi_version.c"
#include "../Graphique/PIXEL_FORMAT_ID.H"




/* Prototype */
void Fcm_get_screen_info(void);


/* Fonction */
void Fcm_get_screen_info(void)
{

	int16  work_out[280];


/* -------------------------------------------------------------
	screen_mode_palette:
		0: pas de palette (ex: TTM 194)
		1: Hardware clut
		2: Software clut (HC or TC)

	screen_pixel_format:
		 0: interleaved planes, organized in words (Atari)
		 1: standard format (whole planes)
		 2: packed pixels
		-1: unknow format; not accessible

   ------------------------------------------------------------- */



	#ifdef LOG_FILE
	sprintf( buf_log, "  ## Fcm_get_screen_info()"CRLF);
	log_print(FALSE);
	#endif


	/*--------------------------------------------------*/
	/* recherchons les dimensions du DESKTOP            */
	/*--------------------------------------------------*/
	wind_get(0,WF_WORKXYWH,&screen.x_desktop, &screen.y_desktop,&screen.w_desktop,&screen.h_desktop);


	#ifdef LOG_FILE
	sprintf( buf_log, "  - Dimension desktop: %d,%d,%d,%d"CRLF, screen.x_desktop,screen.y_desktop,screen.w_desktop,screen.h_desktop);
	log_print(FALSE);
	#endif


	/***************************/
	/* lecture version de EdDI */
	/***************************/
	screen.eddi_version = Fcm_eddi_version();

	#ifdef LOG_FILE
	sprintf( buf_log, "  - EdDi version=%x.%02x"CRLF, (screen.eddi_version>>8), (screen.eddi_version & 0xff) );
	log_print(FALSE);
	#endif


	/****************************************************/
	/* recherchons les infos sur le mode graphique      */
	/****************************************************/
	vq_extnd(vdihandle, 0, work_out);	/* info v_opnvwk() */

	screen.width  = work_out[0] + 1;
	screen.height = work_out[1] + 1;


	vq_extnd(vdihandle, 1, work_out);	/* info suppl‚mentaire */

	screen.nb_plan=work_out[4];


	switch(screen.nb_plan)
	{
		case 1:
			screen.color =2;
			break;
		case 2:
			screen.color =4;
			break;
		case 4:
			screen.color =16;
			break;
		case 8:
			screen.color =256;
			break;
		case 15:
			screen.color =32768;
			break;
		case 16:
			screen.color =65536;
			break;
		case 24:
		case 32:
			screen.color =16777216;
			break;
	}


	if(screen.nb_plan>8)
	{
		screen.pixel_format=2;
	}
	else
	{
		screen.pixel_format=0;
	}




	/* --------------------------------------------------------------- */
	/* valeur par d‚faut pour la conversion device <-> index color VDI */
	/* au cas o— eddi n'est pas present (pour le mode 8 bits)          */
	/* --------------------------------------------------------------- */
	{
		int16 idx;

		for( idx=0; idx<256; idx++ )
		{
			screen.palette_to_device[idx]=idx;
		}

		screen.palette_to_device[1]=255;
		screen.palette_to_device[2]=1;
		screen.palette_to_device[3]=2;
		screen.palette_to_device[4]=4;
		screen.palette_to_device[5]=6;
		screen.palette_to_device[6]=3;
		screen.palette_to_device[7]=5;
		screen.palette_to_device[8]=7;
		screen.palette_to_device[9]=8;
		screen.palette_to_device[10]=9;
		screen.palette_to_device[11]=10;
		screen.palette_to_device[12]=12;
		screen.palette_to_device[13]=14;
		screen.palette_to_device[14]=11;
		screen.palette_to_device[15]=13;
		screen.palette_to_device[255]=15;
	}




	if(screen.eddi_version>0x99)	/* EdDI 1.00 minimum */
	{

		vq_scrninfo( vdihandle, work_out );

		screen.color= (uint32)( ((uint32)work_out[3]<<16) + (uint32)work_out[4] );

		screen.nb_plan=work_out[2];
		screen.pixel_format=work_out[0];

		screen.mode_palette=work_out[1];




		/****************************************************/
		/* ----     Recherche du format du pixel      ----  */
		/****************************************************/
		screen.pixel_xformat=0;

		if( screen.nb_plan==8 )
		{
			if( screen.pixel_format==2 )
			{
				screen.pixel_xformat=PIXEL_8_PACKED;
			}
			if( screen.pixel_format==0 )
			{
				screen.pixel_xformat=PIXEL_8_PLAN;
			}

			{
				int16 idx;

				#ifdef LOG_FILE
				sprintf( buf_log, " CLUT = %d (screen.mode_palette)"CRLF, screen.mode_palette );
				log_print(FALSE);
				#endif

				if( screen.mode_palette == 1 )
				{
					/* Hardware CLUT */
					for( idx=0; idx<256; idx++ )
					{
						screen.palette_to_device[idx]=work_out[16+idx];

					#ifdef LOG_FILE
					sprintf( buf_log, "idx=%5d - idx_pixel=%5d"CRLF, idx, screen.palette_to_device[idx] );
					log_print(FALSE);
					#endif

					}
				}
			}

		}


		if( screen.nb_plan>8 )
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
				screen.pixel_xformat=PIXEL_15_FALCON;

			if(id_rouge==50 && id_vert==35 && id_bleu==10)
				screen.pixel_xformat=PIXEL_15_MOTOROLA;

			if(id_rouge==20 && id_vert==43 && id_bleu==50)
				screen.pixel_xformat=PIXEL_15_INTEL;

			if(id_rouge==65 && id_vert==45 && id_bleu==10)
				screen.pixel_xformat=PIXEL_16_MOTOROLA;

			if(id_rouge==25 && id_vert==45 && id_bleu==50)
				screen.pixel_xformat=PIXEL_16_INTEL;

			if(id_rouge==156 && id_vert==92 && id_bleu==28 && screen.nb_plan==24)
				screen.pixel_xformat=PIXEL_24_MOTOROLA;

			if(id_rouge==28 && id_vert==92 && id_bleu==156)
				screen.pixel_xformat=PIXEL_24_INTEL;

			if(id_rouge==156 && id_vert==92 && id_bleu==28 && screen.nb_plan==32)
				screen.pixel_xformat=PIXEL_32_MOTOROLA;

			if(id_rouge==92 && id_vert==156 && id_bleu==220)
				screen.pixel_xformat=PIXEL_32_INTEL;
		}




		/****************************************************/
		/* ----     Adresse physique de l'‚cran       ----  */
		/****************************************************/
		screen.adresse=0L;

		if( screen.eddi_version>0x109 )
		{
			screen.adresse=((uint32)work_out[6]<<16) + (uint32)work_out[7];
		}

		screen.physbase = (uint32)Physbase();


	}


	#ifdef LOG_FILE
	sprintf( buf_log, "  - Ecran: %dx%d %d bits (%ld couleurs)"CRLF, screen.width, screen.height, screen.nb_plan, screen.color);
	log_print(FALSE);
	sprintf( buf_log, "  - Adresse ‚cran=$%lx"CRLF, screen.adresse);
	log_print(FALSE);
	sprintf( buf_log, "  - Adresse physbase=$%lx"CRLF, screen.physbase);
	log_print(FALSE);
	sprintf( buf_log, "  - PixelFormat=%d"CRLF, screen.pixel_format );
	log_print(FALSE);
	sprintf( buf_log, "  - PixelXFormat=%d"CRLF, screen.pixel_xformat );
	log_print(FALSE);
	sprintf( buf_log, "  - Mode palette=%d"CRLF""CRLF, screen.mode_palette);
	log_print(FALSE);
	#endif


}

