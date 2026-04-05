/* **[PUPUL]******************** */
/* *                           * */
/* * 09/11/2023 MaJ 09/11/2023 * */
/* ***************************** */



/* prototype */
void build_screen_mono( void );




/* Fonction */
void build_screen_mono( void )
{



	/* restauration du fond de l'‚cran */
	vrt_cpyfm(global_vdihandle_framebuffer, VRT_COPY_MODE, pxy_fond_ecran, &mfdb_fond_ecran, &mfdb_framebuffer, couleur_vrt_copy );






	/* ---------------------------------------------------------------------- */
	/*    Damier                                                              */
	/* ---------------------------------------------------------------------- */
	{
		static int16 damier_idx=0;


		vrt_cpyfm(global_vdihandle_framebuffer,VRT_COPY_MODE,pxy_damier, &mfdb_damier[damier_idx], &mfdb_framebuffer, couleur_vrt_copy );

		damier_idx++;
		if( damier_idx==NB_DAMIER)
		{
			damier_idx=0;
		}
	}




#ifdef LOG_FILE
sprintf( buf_log, " animation_logo.logo_state=%d"CRLF, animation_logo.logo_state );
log_print(FALSE);
#endif






	/* ---------------------------------------------------------------------- */
	/* gestion de l'affichage du logo (fadein, fadeout, fadezero              */
	/* ---------------------------------------------------------------------- */

	/* LOGO_FADEIN -> LOGO_FADEZERO -> LOGO_FADEOUT -> LOGO_OFF */
	/* LOGO_FADEIN every  animation_logo.next_frame==0 */

	/* un logo doit etre affich‚ ? */
	if( animation_logo.logo_state != LOGO_OFF )
	{
		animation_logo.logo_frame--;

		if( animation_logo.logo_frame==0 )
		{

			/* Couleur FADE IN */
			if( animation_logo.morph_mode==LOGO_FADEIN )
			{
				animation_logo.logo_color++;

				if( animation_logo.logo_color < gray_nbindex )
				{
					animation_logo.logo_frame=LOGO_COLORSPEED;
				}
				if( animation_logo.logo_color == gray_nbindex )
				{
					animation_logo.morph_mode=LOGO_FADEZERO;
					animation_logo.logo_frame=LOGO_COLORPAUSE;
					animation_logo.logo_color--;
				}
			}

			/* Couleur FADE OUT */
			if( animation_logo.morph_mode==LOGO_FADEOUT )
			{
				animation_logo.logo_color--;

				if( animation_logo.logo_color >= 0  )
				{
					animation_logo.logo_frame=LOGO_COLORSPEED;
				}
				if( animation_logo.logo_color < gray_nbindex /*0*/ )
				{
					animation_logo.logo_state=LOGO_OFF;
					animation_logo.logo_color=0;
				}
			}

			/* Couleur FADE ZERO */
			if( animation_logo.morph_mode==LOGO_FADEZERO && animation_logo.logo_frame==0)
			{
				animation_logo.morph_mode=LOGO_FADEOUT;
				animation_logo.logo_frame=LOGO_COLORSPEED;
			}
		}
	}





	/* ---------------------------------------------------------------------- */
	/* Gestion de l'affichage du logo Equinox                                 */
	/* ---------------------------------------------------------------------- */
	if( animation_logo.logo_state==LOGO_EQUINOX )
	{
		logo_couleur[0]=gray_index[animation_logo.logo_color];


/*#ifdef LOG_FILE
sprintf( buf_log, " logo_couleur[0]=%d   animation_logo.logo_color=%d gray_index[animation_logo.logo_color]=%d"CRLF, logo_couleur[0], animation_logo.logo_color, gray_index[animation_logo.logo_color] );
log_print(FALSE);
#endif*/

		//coordfond[render_screen_built].x1min = MIN( coordfond[render_screen_built].x1min, pxy_logo_equinox[4] );
		//coordfond[render_screen_built].y1min = MIN( coordfond[render_screen_built].y1min, pxy_logo_equinox[5] );
		//coordfond[render_screen_built].x2max = MAX( coordfond[render_screen_built].x2max, pxy_logo_equinox[6] );
		//coordfond[render_screen_built].y2max = MAX( coordfond[render_screen_built].y2max, pxy_logo_equinox[7] );

		vrt_cpyfm(global_vdihandle_framebuffer,VRT_MASQUE_MODE,pxy_logo_equinox, &mfdb_logo_equinox_mask, &mfdb_framebuffer, logo_couleur);
	}



	/* ---------------------------------------------------------------------- */
	/* Gestion de l'affichage des d‚mons                                      */
	/* ---------------------------------------------------------------------- */
	{
		int16 idx_sprite;


		for( idx_sprite=0; idx_sprite<7; idx_sprite++)
		{
			/* gestion de la forme du sprite */
			/* ----------------------------- */

			/* doit-on changer l'apparence du sprite ? */
			if( animation[idx_sprite].morph_mode != FORM_BALL )
			{
				animation[idx_sprite].sprite_frame--;

				if( animation[idx_sprite].sprite_frame==0 )
				{
					/* on doit g‚rer l'animation du d‚mon ou d'un morphisme */



					/* animation du demon */
					if( animation[idx_sprite].morph_mode==FORM_DEMON_IN )
					{
						switch( animation[idx_sprite].sprite_forme )
						{
							case SPRITE_DEMON1:
								animation[idx_sprite].sprite_forme=SPRITE_DEMON2;
								animation[idx_sprite].sprite_frame=SPRITE_SWITCH_ANIME;
								break;
							case SPRITE_DEMON2:
								animation[idx_sprite].sprite_forme=SPRITE_DEMON3;
								animation[idx_sprite].sprite_frame=SPRITE_SWITCH_ANIME;
								break;
							case SPRITE_DEMON3:
								animation[idx_sprite].morph_mode=FORM_DEMON_OUT;
								break;
						}
					}
					if( animation[idx_sprite].morph_mode==FORM_DEMON_OUT )
					{
						switch( animation[idx_sprite].sprite_forme )
						{
							case SPRITE_DEMON3:
								animation[idx_sprite].sprite_forme=SPRITE_DEMON2;
								animation[idx_sprite].sprite_frame=SPRITE_SWITCH_ANIME;
								break;
							case SPRITE_DEMON2:
								animation[idx_sprite].sprite_forme=SPRITE_DEMON1;
								animation[idx_sprite].sprite_frame=SPRITE_SWITCH_ANIME;
								animation[idx_sprite].morph_mode=FORM_DEMON_IN;
								break;
						}
					}



					/* animation d'une transformation */
					if( animation[idx_sprite].morph_mode==DEMON_TO_BALL )
					{
						switch( animation[idx_sprite].sprite_forme )
						{
							case SPRITE_MORPH1:
								animation[idx_sprite].sprite_forme=SPRITE_MORPH2;
								animation[idx_sprite].sprite_frame=5;
								break;
							case SPRITE_MORPH2:
								animation[idx_sprite].sprite_forme=SPRITE_BALL1;
								animation[idx_sprite].sprite_frame=0;
								animation[idx_sprite].morph_mode=FORM_BALL;
								break;
						}
					}



					/* animation d'une transformation */
					if( animation[idx_sprite].morph_mode==BALL_TO_DEMON )
					{
						switch( animation[idx_sprite].sprite_forme )
						{
							case SPRITE_MORPH2:
								animation[idx_sprite].sprite_forme=SPRITE_MORPH1;
								animation[idx_sprite].sprite_frame=5;
								break;
							case SPRITE_MORPH1:
								animation[idx_sprite].sprite_forme=SPRITE_DEMON1;
								animation[idx_sprite].sprite_frame=5;
								animation[idx_sprite].morph_mode=FORM_DEMON_IN;
								break;
						}
					}
				}
			}


			/* affichage des d‚mons */
			pxy_demons[4]=demon_xy[ animation[idx_sprite].index_coord ].x;
			pxy_demons[5]=demon_xy[ animation[idx_sprite].index_coord ].y;
			pxy_demons[6]=pxy_demons[4]+pxy_demons[2];
			pxy_demons[7]=pxy_demons[5]+pxy_demons[3];

			//coordfond[render_screen_built].x1min = MIN( coordfond[render_screen_built].x1min, pxy_demons[4] );
			//coordfond[render_screen_built].y1min = MIN( coordfond[render_screen_built].y1min, pxy_demons[5] );
			//coordfond[render_screen_built].x2max = MAX( coordfond[render_screen_built].x2max, pxy_demons[6] );
			//coordfond[render_screen_built].y2max = MAX( coordfond[render_screen_built].y2max, pxy_demons[7] );

			/* affichage du masque */
			vrt_cpyfm(global_vdihandle_framebuffer,VRT_MASQUE_MODE,pxy_demons, &mfdb_demons_mask[ animation[idx_sprite].sprite_forme ], &mfdb_framebuffer, couleur_mask_vrt);
			/* affichage du sprite */
			vrt_cpyfm(global_vdihandle_framebuffer,VRT_SPRITE_MODE,pxy_demons, &mfdb_demons_sprite[ animation[idx_sprite].sprite_forme ], &mfdb_framebuffer, couleur_mask_vrt);


			/* Les coordonn‚es sont pr‚vu pour du 50fps, on avance */
			/* par pas de 2 pour avoir un affichage … 25 fps       */
			animation[idx_sprite].index_coord++;
			animation[idx_sprite].index_coord++;


			/* Gestion du rebouclage de la trajectoire des sprites */
			if( animation[idx_sprite].index_coord > 7337 )
			{
				animation[idx_sprite].index_coord=animation[idx_sprite].index_coord-6052; /* -7337 + 1285 */
			}


			/* gestion des transformations du sprite */
			/* ------------------------------------- */

			animation[idx_sprite].next_frame--;

			if( animation[idx_sprite].next_frame==0 )
			{
				animation[idx_sprite].next_frame=SPRITE_MORPHING_FRAME;

				if( animation[idx_sprite].next_forme==BALL_TO_DEMON)
				{
					animation[idx_sprite].next_forme=DEMON_TO_BALL;

					animation[idx_sprite].sprite_forme=SPRITE_MORPH2;
					animation[idx_sprite].sprite_frame=5;
					animation[idx_sprite].morph_mode=BALL_TO_DEMON;
				}
				else
				{
					animation[idx_sprite].next_forme=BALL_TO_DEMON;

					animation[idx_sprite].sprite_forme=SPRITE_MORPH1;
					animation[idx_sprite].sprite_frame=5;
					animation[idx_sprite].morph_mode=DEMON_TO_BALL;
				}
			}
		}
	}





		/* ---------------------------------------------------------------------- */
		/* Gestion de l'affichage du logo Renaissance                             */
		/* ---------------------------------------------------------------------- */

		if( animation_logo.logo_state==LOGO_RENAISSANCE )
		{
			logo_couleur[0]=gray_index[animation_logo.logo_color];

/*#ifdef LOG_FILE
sprintf( buf_log, " logo_couleur[0]=%d   animation_logo.logo_color=%d gray_index[animation_logo.logo_color]=%d"CRLF, logo_couleur[0], animation_logo.logo_color, gray_index[animation_logo.logo_color] );
log_print(FALSE);
#endif*/

			//coordfond[render_screen_built].x1min = MIN( coordfond[render_screen_built].x1min, pxy_logo_renaissance[4] );
			//coordfond[render_screen_built].y1min = MIN( coordfond[render_screen_built].y1min, pxy_logo_renaissance[5] );
			//coordfond[render_screen_built].x2max = MAX( coordfond[render_screen_built].x2max, pxy_logo_renaissance[6] );
			//coordfond[render_screen_built].y2max = MAX( coordfond[render_screen_built].y2max, pxy_logo_renaissance[7] );

			vrt_cpyfm(global_vdihandle_framebuffer,2,pxy_logo_renaissance, &mfdb_logo_renaissance_mask, &mfdb_framebuffer, logo_couleur);
		}




		/* ---------------------------------------------------------------------- */
		/* gestion des apparitions des logos                                      */
		/* ---------------------------------------------------------------------- */

		animation_logo.next_frame--;

		if( animation_logo.next_frame==0 )
		{
			animation_logo.next_frame=LOGO_ECART_VIEW;
			animation_logo.logo_color=0;
			animation_logo.logo_frame=LOGO_COLORSPEED;
			animation_logo.morph_mode=LOGO_FADEIN;

			if( animation_logo.next_forme==LOGO_EQUINOX)
			{
				animation_logo.next_forme=LOGO_RENAISSANCE;
				animation_logo.logo_state=LOGO_EQUINOX;
			}
			else
			{
				animation_logo.next_forme=LOGO_EQUINOX;
				animation_logo.logo_state=LOGO_RENAISSANCE;
			}
		}







		/* ------------------------------------------------------------ */
		/* Fond du scrollText                                           */
		/* ------------------------------------------------------------ */

		vrt_cpyfm(global_vdihandle_framebuffer,VRT_COPY_MODE,pxy_fond_scrolltext, &mfdb_fond_scrolltext, &mfdb_framebuffer, couleur_vrt_copy );



		/* ------------------------------------------------------------------------------ */
		/* barre texte                                                                    */
		/* ------------------------------------------------------------------------------ */
		{
			#define B_ACCELERATION (7+2)
			#define B_POS_Y        (28+12)
			#define B_POS_Y_MIN    (184-12)


			static int16 acceleration=B_ACCELERATION;
			static int16 position_y=B_POS_Y;
			static int16 direction=1;
			static int16 premier_plan=0;


			/* position de la barre */
			pxy_barre_scrolltext[5]=B_POS_Y_MIN+position_y;
			pxy_barre_scrolltext[7]=B_POS_Y_MIN+position_y+11;



			/* vers le haut */
			if( direction == 1 )
			{
				position_y = position_y - acceleration;
				if( acceleration>1)
				{
					acceleration = acceleration - 1;
				}

				if( position_y<0 )
				{
					direction=0;
					if( premier_plan==0 )
					{
						premier_plan=1;
					}
					else
					{
						premier_plan=0;
					}
				}

			}
			else
			/* vers le bas */
			{

				position_y = position_y + acceleration;
				acceleration++;

				if( position_y>B_POS_Y )
				{
					position_y=B_POS_Y;
					acceleration=B_ACCELERATION;
					direction=1;
				}
			}

			#undef B_ACCELERATION
			#undef B_POS_Y
			#undef B_POS_Y_MIN



			/* barre derriŠre le texte */
			if( premier_plan==0 )
			{
				vrt_cpyfm(global_vdihandle_framebuffer,VRT_COPY_MODE,pxy_barre_scrolltext, &mfdb_barre_scrolltext, &mfdb_framebuffer, couleur_vrt_copy );
			}








			/* ------------------------------------------------------------------------------ */
			/* texte                                                                          */
			/* ------------------------------------------------------------------------------ */
			{
				static uint16 decalage_x=0;
				static uint16 lettre=0;
				static uint16 idx_lettre=0;
				uint16  offset_x, offset_w, pos_x, nb_lettre;


				nb_lettre=11;
				if(decalage_x==0)
				{
					nb_lettre=10;
				}

				for( lettre=0; lettre<nb_lettre; lettre++ )
				{

					offset_x = 0;
					offset_w = 31;
					pos_x    = decalage_x;

					if( lettre==0)
					{
						offset_x = decalage_x;
						offset_w = 31-offset_x;
						pos_x    = 0;
					}

					if( lettre==10)
					{
						offset_w = decalage_x-1;
					}

					if( scrolltext_message[idx_lettre+lettre] != 111 )
					{

						/* x<<5 = x*32 */
						pxy_texte[0] = ( scrolltext_message[idx_lettre+lettre] << 5 ) + offset_x;
						pxy_texte[2] = pxy_texte[0] + offset_w;

						pxy_texte[4] = ( lettre<<5 ) - pos_x;
						pxy_texte[6] = MIN( 319, (pxy_texte[4]+offset_w) );

						vrt_cpyfm(global_vdihandle_framebuffer,VRT_MASQUE_MODE,pxy_texte, &mfdb_fonte_texte_mask, &mfdb_framebuffer, couleur_mask_vrt );
						vrt_cpyfm(global_vdihandle_framebuffer,VRT_SPRITE_MODE,pxy_texte, &mfdb_fonte_texte, &mfdb_framebuffer, couleur_mask_vrt );
					}
				}

				/* vitesse du scroll */
				decalage_x = decalage_x + 8;

				if( decalage_x>31 )
				{
					decalage_x=decalage_x-32;

					idx_lettre++;
					if( idx_lettre > (size_scrolltext_message-11) )
					{
						idx_lettre=0;
					}
				}
			}









			/* barre devant le texte */
			if( premier_plan==1 )
			{
				vrt_cpyfm(global_vdihandle_framebuffer,VRT_COPY_MODE,pxy_barre_scrolltext, &mfdb_barre_scrolltext, &mfdb_framebuffer, couleur_vrt_copy );
			}



		}












		/* ---------------------------------------------------------------------- */
		/* On n'affiche pas … l'‚cran physique, la totalit‚ du contenus des       */
		/* ‚crans mais uniquement les zones qui ont ‚t‚ modifi‚es                 */
		/* On d‚termine la zone max sur les 3 derniers affichage (2 ecrans +1)    */
		/* ---------------------------------------------------------------------- */
		{

/*			coordredraw[coordredraw_idx].x1min = coordfond[render_screen_built].x1min;
			coordredraw[coordredraw_idx].y1min = coordfond[render_screen_built].y1min;
			coordredraw[coordredraw_idx].x2max = coordfond[render_screen_built].x2max;
			coordredraw[coordredraw_idx].y2max = coordfond[render_screen_built].y2max;

			coordredraw_idx++;

			if( coordredraw_idx > 2 )
			{
				coordredraw_idx=0;
			}

			redraw_x1min = MIN( coordredraw[0].x1min, coordredraw[1].x1min );
			redraw_y1min = MIN( coordredraw[0].y1min, coordredraw[1].y1min );
			redraw_x2max = MAX( coordredraw[0].x2max, coordredraw[1].x2max );
			redraw_y2max = MAX( coordredraw[0].y2max, coordredraw[1].y2max );

			redraw_x1min = MIN( redraw_x1min, coordredraw[2].x1min );
			redraw_y1min = MIN( redraw_y1min, coordredraw[2].y1min );
			redraw_x2max = MAX( redraw_x2max, coordredraw[2].x2max );
			redraw_y2max = MAX( redraw_y2max, coordredraw[2].y2max );
*/
		}




	return;


}

