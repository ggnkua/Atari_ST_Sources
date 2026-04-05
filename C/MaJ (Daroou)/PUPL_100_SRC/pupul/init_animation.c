/* **[Pupul]******************** */
/* *                           * */
/* * 22/06/2014 MaJ 23/02/2015 * */
/* ***************************** */



/* prototype */
void init_animation( void );



/* Fonction */
void init_animation( void )
{



	/* ********************************************************* */
	/* initialisation des paramŠtres pour l'animation des demons */
	/* ********************************************************* */
	animation[0].index_coord=0;
	animation[0].sprite_forme=SPRITE_BALL1;
	animation[0].sprite_frame=0;
	animation[0].morph_mode=SPRITE_BALL1;
	animation[0].next_frame=SPRITE_MORPHING_FRAME+(SPRITE_DECALAGE_FRAME*6);
	animation[0].next_forme=BALL_TO_DEMON;

	animation[1].index_coord=SPRITE_ECART_FRAME*1;
	animation[1].sprite_forme=SPRITE_BALL1;
	animation[1].sprite_frame=0;
	animation[1].morph_mode=SPRITE_BALL1;
	animation[1].next_frame=SPRITE_MORPHING_FRAME+(SPRITE_DECALAGE_FRAME*5);
	animation[1].next_forme=BALL_TO_DEMON;

	animation[2].index_coord=SPRITE_ECART_FRAME*2;
	animation[2].sprite_forme=SPRITE_BALL1;
	animation[2].sprite_frame=0;
	animation[2].morph_mode=SPRITE_BALL1;
	animation[2].next_frame=SPRITE_MORPHING_FRAME+(SPRITE_DECALAGE_FRAME*4);
	animation[2].next_forme=BALL_TO_DEMON;

	animation[3].index_coord=SPRITE_ECART_FRAME*3;
	animation[3].sprite_forme=SPRITE_BALL1;
	animation[3].sprite_frame=0;
	animation[3].morph_mode=SPRITE_BALL1;
	animation[3].next_frame=SPRITE_MORPHING_FRAME+(SPRITE_DECALAGE_FRAME*3);
	animation[3].next_forme=BALL_TO_DEMON;

	animation[4].index_coord=SPRITE_ECART_FRAME*4;
	animation[4].sprite_forme=SPRITE_BALL1;
	animation[4].sprite_frame=0;
	animation[4].morph_mode=SPRITE_BALL1;
	animation[4].next_frame=SPRITE_MORPHING_FRAME+(SPRITE_DECALAGE_FRAME*2);
	animation[4].next_forme=BALL_TO_DEMON;

	animation[5].index_coord=SPRITE_ECART_FRAME*5;
	animation[5].sprite_forme=SPRITE_BALL1;
	animation[5].sprite_frame=0;
	animation[5].morph_mode=SPRITE_BALL1;
	animation[5].next_frame=SPRITE_MORPHING_FRAME+(SPRITE_DECALAGE_FRAME*1);
	animation[5].next_forme=BALL_TO_DEMON;

	animation[6].index_coord=SPRITE_ECART_FRAME*6;
	animation[6].sprite_forme=SPRITE_BALL1;
	animation[6].sprite_frame=0;
	animation[6].morph_mode=SPRITE_BALL1;
	animation[6].next_frame=SPRITE_MORPHING_FRAME+(SPRITE_DECALAGE_FRAME*0);
	animation[6].next_forme=BALL_TO_DEMON;




	/* ******************************************************* */
	/* initialisation des paramŠtres pour l'animation des Logo */
	/* ******************************************************* */
	animation_logo.logo_state=LOGO_OFF;
	animation_logo.logo_color=0;
	animation_logo.logo_frame=LOGO_COLORSPEED;
	animation_logo.morph_mode=LOGO_EQUINOX;
	animation_logo.next_frame=LOGO_ECART_VIEW;
	animation_logo.next_forme=LOGO_RENAISSANCE;



	/* ************************************************************ */
	/* Pr‚-remplissage des tableaus pour la construction des ‚crans */
	/* ************************************************************ */
	/* fond d'ecran */
	pxy_fond_ecran[0] = 26;
	pxy_fond_ecran[1] = 44;
	pxy_fond_ecran[2] = 298;
	pxy_fond_ecran[3] = 112;

	pxy_fond_ecran[0] = 16; /* aligne sur 16 pour reso bit plan */
	pxy_fond_ecran[1] = 44;
	pxy_fond_ecran[2] = 304; /* aligne sur 16 pour reso bit plan */
	pxy_fond_ecran[3] = 112;

	pxy_fond_ecran[4] = pxy_fond_ecran[0];
	pxy_fond_ecran[5] = pxy_fond_ecran[1];
	pxy_fond_ecran[6] = pxy_fond_ecran[2];
	pxy_fond_ecran[7] = pxy_fond_ecran[3];



	/* position & position logo Equinox */
	pxy_logo_equinox[0]=0;
	pxy_logo_equinox[1]=0;
	pxy_logo_equinox[2]=LOGO_EQUINOX_W-1;
	pxy_logo_equinox[3]=LOGO_EQUINOX_H-1;

	pxy_logo_equinox[4]=LOGO_EQUINOX_X;
	pxy_logo_equinox[5]=LOGO_EQUINOX_Y;
	pxy_logo_equinox[6]=LOGO_EQUINOX_X+LOGO_EQUINOX_W-1;
	pxy_logo_equinox[7]=LOGO_EQUINOX_Y+LOGO_EQUINOX_H-1;

	/* position & position logo Renaissance */
	pxy_logo_renaissance[0]=0;
	pxy_logo_renaissance[1]=0;
	pxy_logo_renaissance[2]=LOGO_RENAISSANCE_W-1;
	pxy_logo_renaissance[3]=LOGO_RENAISSANCE_H-1;

	pxy_logo_renaissance[4]=LOGO_RENAISSANCE_X;
	pxy_logo_renaissance[5]=LOGO_RENAISSANCE_Y;
	pxy_logo_renaissance[6]=LOGO_RENAISSANCE_X+LOGO_RENAISSANCE_W-1;
	pxy_logo_renaissance[7]=LOGO_RENAISSANCE_Y+LOGO_RENAISSANCE_H-1;


	/* dimension & position des sprites d‚mons/ball */
	pxy_demons[0]=0;
	pxy_demons[1]=0;
	pxy_demons[2]=31;
	pxy_demons[3]=25;


	/* dimension & position du fond scrolltexte */
	pxy_fond_scrolltext[0]=0;
	pxy_fond_scrolltext[1]=0;
	pxy_fond_scrolltext[2]=319;
	pxy_fond_scrolltext[3]=25;

	pxy_fond_scrolltext[4]=0;
	pxy_fond_scrolltext[5]=(0+200);
	pxy_fond_scrolltext[6]=319;
	pxy_fond_scrolltext[7]=(200+25);


	/* dimension & position de la barre du scrolltexte */
	pxy_barre_scrolltext[0]=0;
	pxy_barre_scrolltext[1]=0;
	pxy_barre_scrolltext[2]=319;
	pxy_barre_scrolltext[3]=11;

	pxy_barre_scrolltext[4]=0;
	pxy_barre_scrolltext[6]=319;


	/* dimension & position des lettres du scrolltexte */
	pxy_texte[1]=0;
	pxy_texte[3]=25;

	pxy_texte[5]=200;
	pxy_texte[7]=(200+25);


	/* dimension & position du damier */
	pxy_damier[0]=0;
	pxy_damier[1]=0;
	pxy_damier[2]=319;
	pxy_damier[3]=87;

	pxy_damier[4]=0;
	pxy_damier[5]=112;
	pxy_damier[6]=319;
	pxy_damier[7]=199;



	/* ********************************************** */
	/* on copie l'‚cran de fond sur le framebuffer    */
	/* ********************************************** */
	{
		//int16 pxy[8];


		pxy[0]=0;
		pxy[1]=0;
		pxy[2]=319;
		pxy[3]=199;

		pxy[4]=0;
		pxy[5]=0;
		pxy[6]=319;
		pxy[7]=199;

		if( Fcm_screen.nb_plan != 1  &&  global_force_mode_mono == FALSE )
		{
			vro_cpyfm(global_vdihandle_ecran,3,pxy, &mfdb_fond_ecran, &mfdb_framebuffer );
		}
		else
		{
			vrt_cpyfm(global_vdihandle_framebuffer, VRT_COPY_MODE, pxy, &mfdb_fond_ecran, &mfdb_framebuffer, couleur_vrt_copy );
		}
	}




	/* ************************************************************* */
	/* On positionne les coordonn‚es pour la restauration des fonds  */
	/* sur les valeurs maximales                                     */
	/* ************************************************************* */
	//coordfond[SURFACE_OFFSCREEN1].x1min=0;
	//coordfond[SURFACE_OFFSCREEN1].y1min=0;
	//coordfond[SURFACE_OFFSCREEN1].x2max=319;
	//coordfond[SURFACE_OFFSCREEN1].y2max=199;

	//coordfond[SURFACE_OFFSCREEN2].x1min=0;
	//coordfond[SURFACE_OFFSCREEN2].y1min=0;
	//coordfond[SURFACE_OFFSCREEN2].x2max=319;
	//coordfond[SURFACE_OFFSCREEN2].y2max=199;



	/* ************************************************************** */
	/* On convertit le message du scrolltext en index sur les lettres */
	/* ************************************************************** */
	{
		static int16 texte_decode_flag=FALSE;
		
		int16 index;
		char *pt_position;
		char  code_texte[]= "ABCDEFGHIJKLMNOPQRSTUVWXYZ.:,!?()'-";


		if( texte_decode_flag == FALSE )
		{
			size_scrolltext_message = strlen(scrolltext_message);

			for( index=0; index<size_scrolltext_message; index++)
			{
				pt_position = strchr( code_texte, scrolltext_message[index] );

				if( pt_position != NULL )
				{
					scrolltext_message[index] = (char)(pt_position-code_texte);
				}
				else
				{
					scrolltext_message[index]=111;
				}
			}
		}

		/* on mémorise que le texte a été codé en cas de redemarrage */
		texte_decode_flag=TRUE;
	}




	return;


}

