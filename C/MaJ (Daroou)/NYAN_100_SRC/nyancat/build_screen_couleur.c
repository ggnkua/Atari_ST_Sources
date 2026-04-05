/* **[NyanCat]****************** */
/* *                           * */
/* * 22/06/2014 MaJ 28/09/2023 * */
/* ***************************** */



/* prototype */
void build_screen_couleur( void );




/* Fonction */
void build_screen_couleur( void )
{


	/* restauration du fond de l'‚cran */
	vro_cpyfm(global_vdihandle_framebuffer, VRO_COPY_MODE, pxy_fond, &mfdb_fond_ecran, &mfdb_framebuffer );



	/* Affichage arc en ciel */
	{
		static uint16 aspect_arcenciel=1;
		static uint16 frame_cpt=0;


		vrt_cpyfm(global_vdihandle_framebuffer, VRT_MASQUE_MODE, pxy_arcenciel, &mfdb_arcenciel_mask[aspect_arcenciel], &mfdb_framebuffer, couleur_mask_vrt);
		vro_cpyfm(global_vdihandle_framebuffer, VRO_SPRITE_MODE, pxy_arcenciel, &mfdb_arcenciel[aspect_arcenciel], &mfdb_framebuffer);


		frame_cpt++;

		if( frame_cpt == 2 )
		{
			frame_cpt = 0;

			if( aspect_arcenciel == 0 )
			{
				aspect_arcenciel = 1;
			}
			else
			{
				aspect_arcenciel = 0;
			}
		}
	}




	/* Affichage des etoiles */
	{
		static  int16 position=0;
		        int16 index_etoile;
				int16 decalage_x;
				int16 decalage_y;
				int16 largeur;


		for( index_etoile=0; index_etoile<6; index_etoile++ )
		{
			decalage_x = 0;
			decalage_y = 0;
			largeur    = 0;

			/* si vaut 999, l'etoile n'est pas visible, donc pas afficher */
			if( coord_star[index_etoile][position] != 999 )
			{
				/* si le sprite est en dehors de l'ecran, inférieur a 0 sur l'axe X */
				if( coord_star[index_etoile][position] < 0 )
				{
					decalage_x = -coord_star[index_etoile][position];
					
				}
				/* si le sprite est en dehors de l'ecran, superieur a SCREEN_WIDTH sur l'axe X */
				if( coord_star[index_etoile][position] > ((SCREEN_WIDTH-1)-STAR_WIDTH) )
				{
					largeur = (coord_star[index_etoile][position]+(STAR_WIDTH-1)) - (SCREEN_WIDTH-1);
				}
				/* si le sprite est en dehors de l'ecran, inférieur a 0 sur l'axe Y */
				if( coord_y[index_etoile] < 0 )
				{
					decalage_y = -coord_y[index_etoile];
				}


				pxy[0] = 0 + decalage_x;
				pxy[1] = 0 + decalage_y;
				pxy[2] = (STAR_WIDTH  - 1) - largeur;
				pxy[3] = (STAR_HEIGHT - 1);

				pxy[4] = coord_star[index_etoile][position] + decalage_x;
				pxy[5] = coord_y[index_etoile] + decalage_y;
				pxy[6] = pxy[4] + pxy[2] - decalage_x;
				pxy[7] = pxy[5] + pxy[3] - decalage_y;

				vrt_cpyfm(global_vdihandle_framebuffer, VRT_MASQUE_MODE, pxy, &mfdb_star_mask[ formstar[index_etoile][position] ], &mfdb_framebuffer, couleur_etoile);
			}
		}

		position++;
		if( position > 11 )
		{
			position = 0;
		}

	}






	/* Affichage du Nyan Cat */
	{
		static uint16 aspect_nyancat=0;


		vrt_cpyfm(global_vdihandle_framebuffer, VRT_MASQUE_MODE,pxy_nyancat, &mfdb_nyancat_mask[aspect_nyancat], &mfdb_framebuffer, couleur_mask_vrt);
		vro_cpyfm(global_vdihandle_framebuffer, VRO_SPRITE_MODE,pxy_nyancat, &mfdb_nyancat_sprite[aspect_nyancat], &mfdb_framebuffer);


		aspect_nyancat++;

		if( aspect_nyancat > 5 )
		{
			aspect_nyancat=0;
		}
	}






	/* scroll texte */
	{
		static  uint16 decalage_x=0;
		static  uint16 decalage_cos=0;
		static  uint16 lettre=0;
		static  uint16 idx_lettre=0;
				uint16 offset_lettre_x;
				uint16 largeur_lettre;
				uint16 pos_x;
				uint16 nb_lettre;


		nb_lettre = 10;
		if(decalage_x == 0)
		{
			nb_lettre = 9;
		}

		for( lettre=0; lettre<nb_lettre; lettre++ )
		{

			offset_lettre_x = 0;
			largeur_lettre  = (LETTRE_WIDTH-1);
			pos_x           = decalage_x;

			if( lettre == 0 )
			{
				offset_lettre_x = decalage_x;
				largeur_lettre  = (LETTRE_WIDTH-1)-offset_lettre_x;
				pos_x           = 0;
			}

			if( lettre==9 )
			{
				largeur_lettre = decalage_x-1;
			}

			/* '111' est le code pour un espace, on affiche donc rien */
			if( scrolltext_message[idx_lettre+lettre] != 111 )
			{

				/* coordonnee de la lettre dans la fonte */
				pxy_texte[0] = ( scrolltext_message[idx_lettre+lettre] * 32 ) + offset_lettre_x;
				pxy_texte[2] = pxy_texte[0] + largeur_lettre;


				/* position de la lettre a l'ecran */
				pxy_texte[4] = ( lettre<<5 ) - pos_x;
				pxy_texte[6] = MIN( (SCREEN_WIDTH-1), (pxy_texte[4]+largeur_lettre) );

				pxy_texte[5] = 104 + costable[ pxy_texte[4]+decalage_cos ];
				pxy_texte[7] = pxy_texte[5] + (LETTRE_HEIGHT-1);


				vrt_cpyfm(global_vdihandle_framebuffer,2,pxy_texte, &mfdb_mask_font, &mfdb_framebuffer, couleur_mask_vrt );
				vro_cpyfm(global_vdihandle_framebuffer,7,pxy_texte, &mfdb_font, &mfdb_framebuffer );
			}
		}

		/* vitesse du scroll */
		decalage_x = decalage_x + LETTRE_SPEED;

		if( decalage_x > 31 )
		{
			decalage_x=0;

			idx_lettre++;
			if( idx_lettre > (size_scrolltext_message-11) )
			{
				idx_lettre = 0;
			}
		}


		decalage_cos = decalage_cos + 2;

		if( decalage_cos == 180 )
		{
			decalage_cos = 0;
		}
	}


	return;


}

