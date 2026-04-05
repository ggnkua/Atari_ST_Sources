/* **[Boing]******************** */
/* *                           * */
/* * 20/09/2015 MaJ 27/05/2018 * */
/* ***************************** */



/* prototype */
void init_animation( void );



/* Fonction */
void init_animation( void )
{


	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"# init_animation()"CRLF );
	log_print( FALSE );
	#endif


	/* Dimension de la zone ‚cran pour Fcm_make_liste_redraw_transparent() */
	Fcm_make_liste_redraw_xywh_ecran.g_x = 0;
	Fcm_make_liste_redraw_xywh_ecran.g_y = 0;
	Fcm_make_liste_redraw_xywh_ecran.g_w = SCREEN_WIDTH;
	Fcm_make_liste_redraw_xywh_ecran.g_h = SCREEN_HEIGHT;



	/* position de depart du boing */
	boing_ball_xywh.g_x = (int16)(SCREEN_WIDTH  - BOING_BALL_W) / 2;
	boing_ball_xywh.g_y = (int16)(SCREEN_HEIGHT - BOING_BALL_H) / 2;
	boing_ball_xywh.g_w =  BOING_BALL_W;
	boing_ball_xywh.g_h =  BOING_BALL_H;

	*( &boing_ball_xywh_old )  = *( &boing_ball_xywh );


	/* position de depart de l'ombre  */
	boing_ombre_xywh.g_x = boing_ball_xywh.g_x;
	boing_ombre_xywh.g_y = boing_ball_xywh.g_y;
	boing_ombre_xywh.g_w = BOING_OMBRE_W;
	boing_ombre_xywh.g_h = BOING_OMBRE_H;

	*( &boing_ombre_xywh_old )  = *( &boing_ombre_xywh );




	/* ------------------------------ */
	/* Trajectoire Y BALL             */
	/* ------------------------------ */
	{
		#define BALL_POS_Y_MAX    (24)
		#define BALL_POS_Y_UP     (22)
		#define BOING_BALL_Y_NBPAS (BALL_POS_Y_UP*2)

		float acceleration = 0;
		int16 idx          = 0;


		for( idx=0; idx<BALL_POS_Y_UP; idx++ )
		{
			boing_ball_y[idx] = BALL_POS_Y_MAX + (int16)(acceleration*acceleration);

			boing_ball_y[BOING_BALL_Y_NBPAS-idx-1] = boing_ball_y[idx];

			acceleration += 0.36;
		}
		#undef BALL_POS_Y_MAX
		#undef BALL_POS_Y_UP



		#ifdef LOG_FILE
		{
			int16 i = 0;

			for( i=0; i<=(BOING_BALL_Y_END); i++ )
			{
				sprintf( buf_log, "	boing_ball_y[%d]=%d"CRLF, i, 	boing_ball_y[i] );
				log_print( FALSE );
			}
		}
		#endif

	}



	return;


}

