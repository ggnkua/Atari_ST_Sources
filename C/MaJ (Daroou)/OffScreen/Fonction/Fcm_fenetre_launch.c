/* **[]************************* */
/* *                           * */
/* * 20/04/2015 MaJ 01/12/2015 * */
/* ***************************** */

#ifndef ___FENETRE_LAUNCH___
#define ___FENETRE_LAUNCH___


#include "Fcm_ouvre_fenetre_launch.c"
#include "Fcm_redraw_fenetre_launch.c"


#define LAUNCH_OPEN   (1)
#define LAUNCH_CLOSE  (2)
#define LAUNCH_UPDATE (3)

#define LAUNCH_WAIT_SLOW   (1200)
#define LAUNCH_WAIT_NORMAL (400)
#define LAUNCH_WAIT_FAST   ( 20)

/* sp‚cial idx_message pour message de progression  */
#define LH_INIT_SURFACE    (999)




/* prototype */
void Fcm_fenetre_launch( int16 idx_message, int16 launch_mode, int16 launch_wait );




/* Fonction */
void Fcm_fenetre_launch( int16 idx_message, int16 launch_mode, int16 launch_wait )
{
	static	uint16  max_caractere=0;
	static	uint16  init_start=0;
	static	uint16  idx_init_surface=0;
			OBJECT *adr_dial_launch;
			OBJECT *adr_dial_message;
			int32   reponse;


	if( init_start==0 )
	{
		init_start=1;
		win_rsc               [ W_LAUNCH ] = DL_LAUNCH;
		win_rsc_iconify       [ W_LAUNCH ] = FCM_NO_WIN_RSC;
		table_ft_ouvre_fenetre[ W_LAUNCH ] = Fcm_ouvre_fenetre_launch;
		table_ft_redraw_win   [ W_LAUNCH ] = Fcm_redraw_fenetre_launch;
	}

	if( idx_message == LH_INIT_SURFACE )
	{
		idx_init_surface++;
		if( idx_init_surface>5 )
		{
			idx_init_surface=1;
		}

		switch(idx_init_surface)
		{
			case 1:
				idx_message=LH_INIT_SURFACE1;
				break;
			case 2:
				idx_message=LH_INIT_SURFACE2;
				break;
			case 3:
				idx_message=LH_INIT_SURFACE3;
				break;
			case 4:
				idx_message=LH_INIT_SURFACE4;
				break;
			case 5:
				idx_message=LH_INIT_SURFACE5;
				break;
		}

	}




	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"# fenetre_launch()"CRLF);
	log_print(FALSE);
	#endif




	if( launch_mode==LAUNCH_OPEN || launch_mode==LAUNCH_UPDATE )
	{
		reponse=rsrc_gaddr( R_TREE, DL_LAUNCH, &adr_dial_launch );

		if(reponse==0)
		{
			return;
		}

		/* c'est la chaine dans le RSC qui definit la taille max */
		if( max_caractere==0 )
		{
			max_caractere=strlen( adr_dial_launch[STRING_LAUNCH].ob_spec.free_string);
		}


		reponse=rsrc_gaddr( R_TREE, DL_LAUNCH_TEXTE, &adr_dial_message );

		if(reponse==0)
		{
			return;
		}

		#ifdef LOG_FILE
		sprintf( buf_log, CRLF"=> OUT {%s}"CRLF, adr_dial_message[idx_message].ob_spec.free_string );
		log_print(FALSE);
		#endif

		if( strlen(adr_dial_message[idx_message].ob_spec.free_string) < max_caractere )
		{
			strcpy( adr_dial_launch[STRING_LAUNCH].ob_spec.free_string, adr_dial_message[idx_message].ob_spec.free_string );
		}
		else
		{
			sprintf( adr_dial_launch[STRING_LAUNCH].ob_spec.free_string, "error size char %ld", strlen(adr_dial_message[idx_message].ob_spec.free_string) );
		}


		if( launch_mode==LAUNCH_OPEN )
		{
			/* pour que la fenetre soit centr‚ … l'ouverture */
			win_posxywh[W_LAUNCH][0]=FCM_NO_WINPOS;
			win_posxywh[W_LAUNCH][1]=FCM_NO_WINPOS;

			Fcm_ouvre_fenetre_launch();
			Fcm_purge_redraw();
		}


		if( launch_mode==LAUNCH_UPDATE )
		{
			Fcm_objet_draw( adr_dial_launch, h_win[W_LAUNCH], BOX_LAUNCH , FCM_WU_BLOCK );
		}

	}



	if( launch_mode==LAUNCH_CLOSE )
	{
		Fcm_fermer_fenetre(W_LAUNCH);
	}


	Fcm_gestion_aes_message();


	evnt_timer(launch_wait);


/*		{
			char texte[256];



			sprintf( texte, "sortie Fenetre launch %ld     ", Fcm_get_timer() );
			v_gtext(vdihandle,4*8,7*16,texte);
		}*/

	return;


}


#endif

