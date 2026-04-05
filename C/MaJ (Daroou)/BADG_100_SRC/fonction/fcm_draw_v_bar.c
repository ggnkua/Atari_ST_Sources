/* **[Fonction Commune]********* */
/* *                           * */
/* * 31/12/2012  =  31/12/2012 * */
/* ***************************** */

/* Prototypes */
VOID Fcm_draw_v_bar( const WORD handle, const WORD *array_pxy  );


/* Fonction */
VOID Fcm_draw_v_bar( const WORD index_win, const WORD *array_pxy )
{

/*	#ifdef LOG_FILE
	sprintf( buf_log, "# Fcm_draw_v_bar"CRLF);
	log_print(FALSE);
	sprintf( buf_log, "# handle=%d"CRLF, handle_win);
	log_print(FALSE);
	#endif*/
/*	WORD array_pxy2[16];*/


/*	sprintf(texte,"Frame 0=%d, 1=%d, 2=%d, 3=%d        ", array_pxy[0],array_pxy[1],array_pxy[2],array_pxy[3] );
	v_gtext(vdihandle,20*8,11*16,texte);*/

/*	array_pxy2[0]=array_pxy[0];
	array_pxy2[1]=array_pxy[1];
	array_pxy2[2]=array_pxy[2];
	array_pxy2[3]=array_pxy[3];*/

/*	sprintf(texte,"Frame 0=%d, 1=%d, 2=%d, 3=%d        ", array_pxy2[0],array_pxy2[1],array_pxy2[2],array_pxy2[3] );
	v_gtext(vdihandle,20*8,12*16,texte);*/


	/* on v‚rifie la demande... */
	if( 	index_win             != FCM_NO_MY_WINDOW	/* c'est une fenetre … nous ? */
		&&	h_win[index_win]      > 0                   /* la fenetre est ouverte ?   */
		&&	win_shaded[index_win] == FALSE )			/* la fenetre n'est pas shaded ?    */
	{
		GRECT	r1,r2;

/* ========================================================= */
/* A Determiner: fonctionnement si la fenetre est iconifi‚ ? */
/* ========================================================= */


		/* on peut lancer l'operation de redraw */

		/* coordonnee de la zone de l'objet a redessinner */
		r1.g_x=array_pxy[0];
		r1.g_y=array_pxy[1];
		r1.g_w=array_pxy[2]-r1.g_x+1;
		r1.g_h=array_pxy[3]-r1.g_y+1;


		if( wind_update(BEG_UPDATE) )
		{
			wind_get(h_win[index_win],WF_FIRSTXYWH,&r2.g_x,&r2.g_y,&r2.g_w,&r2.g_h);

			while ( r2.g_w && r2.g_h )
			{
				if ( rc_intersect(&r1,&r2) )
				{
					pxy[0] = r2.g_x;
					pxy[1] = r2.g_y;
					pxy[2] = r2.g_x + r2.g_w - 1;
					pxy[3] = r2.g_y + r2.g_h - 1;

				   	v_hide_c( vdihandle );

/*	sprintf(texte,"      pxy 0=%d, 1=%d, 2=%d, 3=%d        ", pxy[0],pxy[1],pxy[2],pxy[3] );
	v_gtext(vdihandle,20*8,11*16,texte);
	sprintf(texte,"array pxy 0=%d, 1=%d, 2=%d, 3=%d        ", array_pxy[0],array_pxy[1],array_pxy[2],array_pxy[3] );
	v_gtext(vdihandle,20*8,12*16,texte);*/


					vs_clip( vdihandle, CLIP_ON, pxy );

/*	sprintf(texte,"******* V_BAR ****** (%ld)", get_timer() );
	v_gtext(vdihandle,20*8,13*16,texte);*/


/*	sprintf(texte,"vdihandle=%d", vdihandle );
	v_gtext(vdihandle,20*8,14*16,texte);*/

/*	vsf_interior(vdihandle,1);
	vsf_perimeter(vdihandle,0);*/

/*	array_pxy2[0]=0;
	array_pxy2[1]=0;
	array_pxy2[2]=100;
	array_pxy2[3]=100;
					v_bar( vdihandle, array_pxy2);
	array_pxy2[0]=0;
	array_pxy2[1]=0+200;
	array_pxy2[2]=100;
	array_pxy2[3]=100+200;*/

/*evnt_timer(400);*/
/*					vsf_color(vdihandle, 6 );*/
					vr_recfl( vdihandle,  (WORD * )array_pxy);
/*evnt_timer(400);*/
/*					vsf_color(vdihandle, 6 );
					v_bar( vdihandle, (WORD * )array_pxy);*/
/*evnt_timer(100);*/



				 	vs_clip( vdihandle, CLIP_OFF, 0);

					v_show_c(vdihandle,TRUE);

				}

				wind_get(h_win[index_win],WF_NEXTXYWH,&r2.g_x,&r2.g_y,&r2.g_w,&r2.g_h);
			}

			wind_update(END_UPDATE);
		}

	}


/*evnt_timer(200);*/


}
