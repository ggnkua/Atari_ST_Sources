/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 24/05/2003 MaJ 03/03/2024 * */
/* ***************************** */



/* -------------------------------------------------------------
	Fcm_screen.mode_palette:
		0: pas de palette (ex: TTM 194)
		1: Hardware clut
		2: Software clut (HC or TC)
	   -1: inconnu

	Fcm_screen.pixel_format:
		 0: interleaved planes, organized in words (Atari)
		 1: standard format (whole planes)
		 2: packed pixels
		-1: unknow format; not accessible

	Fcm_screen.pixel_xformat:
		  x : code pour le format ecran (voir PIXEL_FORMAT_ID.H)
		 -1 : inconnu ( PIXEL_FORMAT_INCONNU )
   ------------------------------------------------------------- */


void Fcm_get_screen_info(void)
{
	int16  work_out[280];


	FCM_LOG_PRINT("# Fcm_get_screen_info()");

   /* valeur par defaut */
	Fcm_screen.adresse       =  0L;
	Fcm_screen.pixel_xformat =  PIXEL_FORMAT_INCONNU;
	Fcm_screen.pixel_format  = -1;
	Fcm_screen.mode_palette  = -1;


	/* EdDI */
	Fcm_screen.eddi_version = Fcm_eddi_version();

	if( Fcm_screen.eddi_version != -1 )
	{
		FCM_LOG_PRINT2("- EdDi version=%x.%02x", (Fcm_screen.eddi_version>>8), (Fcm_screen.eddi_version & 0xff) );
	}
	else
	{
		Fcm_screen.eddi_version = 0;

		FCM_LOG_PRINT("- Cookie EdDi absent");
	}


	/* Dimensions du DESKTOP */
	wind_get(0,WF_WORKXYWH,&Fcm_screen.x_desktop,&Fcm_screen.y_desktop,&Fcm_screen.w_desktop,&Fcm_screen.h_desktop);

	Fcm_zone_bureau.g_x = Fcm_screen.x_desktop;
	Fcm_zone_bureau.g_y = Fcm_screen.y_desktop;
	Fcm_zone_bureau.g_w = Fcm_screen.w_desktop;
	Fcm_zone_bureau.g_h = Fcm_screen.h_desktop;

	FCM_LOG_PRINT4("- Dimension desktop: %d,%d,%d,%d", Fcm_screen.x_desktop,Fcm_screen.y_desktop,Fcm_screen.w_desktop,Fcm_screen.h_desktop);


	/* Adresse de la m‚moire ‚cran physique */
	Fcm_screen.physbase = (uint32)Physbase();

	/* Infos mode graphique */
	vq_extnd(vdihandle, 0, work_out);	/* info v_opnvwk() */

	Fcm_screen.width  = work_out[0] + 1;
	Fcm_screen.height = work_out[1] + 1;

	vq_extnd(vdihandle, 1, work_out);	/* info suppl‚mentaire */

	Fcm_screen.raster_scalling = work_out[3];

	FCM_LOG_PRINT1("- Raster scalling = %d (0=impossible 1=possible)", Fcm_screen.raster_scalling);
	FCM_LOG_PRINT1("- Performance factor = %d (number 16*16 raster operation/s)", work_out[6]);


	Fcm_screen.nb_plan = work_out[4];

	switch( Fcm_screen.nb_plan )
	{
		case 1:
			Fcm_screen.color = 2;
			Fcm_screen.pixel_xformat = PIXEL_1_PLAN;
			break;
		case 2:
			/* n'existe pas sur Atari d'origine */
			Fcm_screen.color = 4;
			break;
		case 4:
			Fcm_screen.pixel_xformat = PIXEL_4_PLAN;
			Fcm_screen.color = 16;
			break;
		case 8:
			Fcm_screen.color = 256;
			break;
		case 15:
			Fcm_screen.color = 32768;
			break;
		case 16:
			Fcm_screen.color = 65536;
			break;
		case 24:
		case 32:
			Fcm_screen.color = 16777216;
			break;
	}


	if( Fcm_screen.nb_plan > 8 )  Fcm_screen.pixel_format = 2;


	/* --------------------------------------------------------------- */
	/* valeur par d‚faut pour la conversion device <-> index color VDI */
	/* au cas o— eddi n'est pas present (pour le mode 8 bits)          */
	/* --------------------------------------------------------------- */
	{
		int16 idx;

		for( idx=0; idx < 256; idx++ )
		{
			Fcm_screen.palette_to_device[idx] = idx;
		}

		/* [couleur index] = valeur pixel */
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

		if( Fcm_screen.nb_plan == 4 )
		{
			Fcm_screen.palette_to_device[1]=15;
			Fcm_screen.palette_to_device[255]=255;
		}
	}


	if( Fcm_screen.eddi_version > 0x99 )  /* EdDI 1.00 minimum */
	{
		vq_scrninfo( vdihandle, work_out );

		Fcm_screen.color= (uint32)( ((uint32)work_out[3] << 16) + (uint32)work_out[4] );

		Fcm_screen.nb_plan      = work_out[2];
		Fcm_screen.pixel_format = work_out[0];
		Fcm_screen.mode_palette = work_out[1];

		/* --- Recherche du format du pixel --- */
		if( Fcm_screen.nb_plan == 4 )
		{
			Fcm_screen.pixel_xformat = PIXEL_4_PLAN;
		}

		if( Fcm_screen.nb_plan == 8 )
		{
			if( Fcm_screen.pixel_format == 2 )  Fcm_screen.pixel_xformat = PIXEL_8_PACKED;


			if( Fcm_screen.pixel_format == 0 )  Fcm_screen.pixel_xformat = PIXEL_8_PLAN;


			{
				int16 idx;


				FCM_LOG_PRINT1("- CLUT = %d (Fcm_screen.mode_palette)", Fcm_screen.mode_palette );

				if( Fcm_screen.mode_palette == 1 )
				{
					FCM_LOG_PRINT("  Hardware Clut:"CRLF );

					/* Hardware CLUT */
					for( idx=0; idx < 256; idx++ )
					{
						Fcm_screen.palette_to_device[idx] = work_out[16 + idx];

						FCM_LOG_PRINT2("idx=%5d - idx_pixel=%5d", idx, Fcm_screen.palette_to_device[idx] );
					}
				}
			}
		}


		if( Fcm_screen.nb_plan > 8 )
		{
			int16 position;
			int16 id_rouge=0;
			int16 id_vert=0;
			int16 id_bleu=0;
			int16 dummy;


			for(dummy=16; dummy < 32 ; dummy++)
			{
				position = work_out[dummy];
				if( position > 0   &&   position < 32 )  id_rouge = id_rouge + position;
			}
	
			for(dummy=32; dummy < 48 ; dummy++)
			{
				position = work_out[dummy];
				if( position > 0   &&   position < 32 )  id_vert = id_vert + position;
			}

			for(dummy=48; dummy < 64 ; dummy++)
			{
				position = work_out[dummy];
				if( position > 0   &&   position < 32 )  id_bleu = id_bleu + position;
			}

			if(id_rouge==65 && id_vert==40 && id_bleu==10)  Fcm_screen.pixel_xformat = PIXEL_15_FALCON;

			if(id_rouge==50 && id_vert==35 && id_bleu==10)  Fcm_screen.pixel_xformat = PIXEL_15_MOTOROLA;

			if(id_rouge==20 && id_vert==43 && id_bleu==50)  Fcm_screen.pixel_xformat = PIXEL_15_INTEL;

			if(id_rouge==65 && id_vert==45 && id_bleu==10)  Fcm_screen.pixel_xformat = PIXEL_16_MOTOROLA;

			if(id_rouge==25 && id_vert==45 && id_bleu==50)  Fcm_screen.pixel_xformat = PIXEL_16_INTEL;


			if(id_rouge==156 && id_vert==92 && id_bleu==28 && Fcm_screen.nb_plan==24) /* RVB */
				Fcm_screen.pixel_xformat = PIXEL_24_MOTOROLA;


			if(id_rouge==28 && id_vert==92 && id_bleu==156)  Fcm_screen.pixel_xformat=PIXEL_24_INTEL;


			if(id_rouge==156 && id_vert==92 && id_bleu==28 && Fcm_screen.nb_plan==32) /* _RVB */
				Fcm_screen.pixel_xformat = PIXEL_32_MOTOROLA;


			if(id_rouge==92 && id_vert==156 && id_bleu==220)  Fcm_screen.pixel_xformat = PIXEL_32_INTEL;
		}


		/* --- Adresse physique de l'‚cran --- */
		if( Fcm_screen.eddi_version > 0x109 )
		{
			Fcm_screen.adresse = ((uint32)work_out[6] << 16) + (uint32)work_out[7];
		}
	}


	FCM_LOG_PRINT4("- Ecran: %dx%d nb_Plan=%d bits (%ld couleurs)", Fcm_screen.width, Fcm_screen.height, Fcm_screen.nb_plan, Fcm_screen.color);
	FCM_LOG_PRINT1("- Adresse ‚cran    (VDI)  =$%lx (need EdDI 1.10)", Fcm_screen.adresse);
	FCM_LOG_PRINT1("- Adresse physbase (XBIOS)=$%lx", Fcm_screen.physbase);
	FCM_LOG_PRINT1("- PixelFormat=%d  (-1=inconnu, 0=interleaved planes Atari  1=standard format (whole planes)  2=packed pixels)", Fcm_screen.pixel_format );
	FCM_LOG_PRINT1("- PixelXFormat=%d (-1=inconnu,  1:15f 2:15m 3:15i 4:16m 5:16i 6:24m 7:24i 8:32m 9:32i 10:8pk 11:8bp 12:4bp 13:1bp)", Fcm_screen.pixel_xformat );
	FCM_LOG_PRINT1("- Mode palette=%d (-1=inconnu, 0=pas de palette, 1=Hardware clut, 2=Software clut (HC or TC) )"CRLF, Fcm_screen.mode_palette);


}

