/* **[Fonction Commune]********* */
/* *                           * */
/* * 29/12/2012  =  10/01/2014 * */
/* ***************************** */



#ifndef __Fcm_objet_draw__
#define __Fcm_objet_draw__



#include "Fcm_get_indexwindow.c"
#include "Fcm_get_objet_parent.c"



/* Prototypes */
VOID Fcm_objet_draw( OBJECT *adr_formulaire, WORD handle, UWORD objet, WORD windupdate_mode );


/* Fonction */
VOID Fcm_objet_draw( OBJECT *adr_formulaire, WORD handle_win, UWORD objet, WORD windupdate_mode )
{
	WORD	index_win;


	#ifdef LOG_FILE
	sprintf( buf_log, TAB8"* Fcm_objet_draw()"CRLF);
	log_print(FALSE);
	sprintf( buf_log, TAB8" - adr_form=%p, handle=%d, objet=%d, update mode=$%x"CRLF, adr_formulaire,handle_win, objet, windupdate_mode);
	log_print(FALSE);
	#endif


	/* on cherche l'index du tableau correspondant … ce handle de fenetre */
	index_win = Fcm_get_indexwindow( handle_win );



	/* on v‚rifie la demande... */
	if( 	index_win             != FCM_NO_MY_WINDOW	/* c'est une fenetre … nous ? */
		&&	handle_win            != FCM_NO_OPEN_WINDOW	/* la fenetre est ouverte ?   */
		&&	win_shaded[index_win] == FALSE )			/* la fenetre n'est pas shaded ?    */
	{
		GRECT	r1,r2;

/* ========================================================= */
/* A Determiner: fonctionnement si la fenetre est iconifi‚ ? */
/* ========================================================= */


		/* on peut lancer l'operation de redraw */

		/* coordonnee de la zone de l'objet a redessinner */
		objc_offset(adr_formulaire, objet, &r1.g_x,&r1.g_y);

/*sprintf( texte, "*** OBJET DRAW: x=%d y=%d (%ld)   ", r1.g_x, r1.g_y, get_timer() );
v_gtext(vdihandle,4*8,5*16,texte);*/


		r1.g_w=(adr_formulaire+objet)->ob_width;
		r1.g_h=(adr_formulaire+objet)->ob_height;

		{
			WORD type_objet=(adr_formulaire+objet)->ob_type & 0xff;
			WORD epaisseur_cadre;

			switch(type_objet)
			{
				case G_STRING:
				case G_IMAGE:
				case G_ICON:
				case G_CICON:
				case G_USERDEF:
				case G_BUTTON:
				case G_TEXT:
				case G_FTEXT:
					epaisseur_cadre=0;
					break;

				case G_BOXTEXT:
				case G_FBOXTEXT:
					epaisseur_cadre=(adr_formulaire+objet)->ob_spec.tedinfo->te_thickness;
					break;

				case G_BOX:
				case G_IBOX:
				case G_BOXCHAR:
					epaisseur_cadre=(adr_formulaire+objet)->ob_spec.obspec.framesize;
					break;

				default:
					#ifdef LOG_FILE
					sprintf( buf_log, "ERREUR !!! Fcm_objet_draw, type objet non reconnu (%d)"CRLF, type_objet);
					log_print(FALSE);
					#endif
/*					sprintf(texte,"Fcm_objet_draw, type objet non reconnu (%d)", type_objet );
					v_gtext(vdihandle,4*8,2*16,texte);*/
					epaisseur_cadre=0;
			}




			if( epaisseur_cadre<0 )
			{
				/* si n‚gatif, cadre vers l'exterieur */
				epaisseur_cadre=ABS(epaisseur_cadre);

				/* on ajuste la zone … redessiner au cadre */
				r1.g_x=r1.g_x-epaisseur_cadre;
				r1.g_y=r1.g_y-epaisseur_cadre;
				r1.g_w=r1.g_w+(epaisseur_cadre*2);
				r1.g_h=r1.g_h+(epaisseur_cadre*2);
			}
		}




		{
			WORD type_objet=(adr_formulaire+objet)->ob_type & 0xff;

			/* L'objet est-il cach‚ ou n'a pas de fond ? */
			if( ((adr_formulaire+objet)->ob_flags & OF_HIDETREE) 
				||	type_objet == G_TEXT
				||	type_objet == G_STRING
				||	type_objet == G_IMAGE   )
			{
				/* Si l'objet est cach‚, ou si c'est un objet qui
				   n'a pas de fond, pas besoin de tout redessiner
				   en s'envoyant un message de redraw sur la zone de 
				   l'objet, on r‚affiche seulement la zone de l'objet 
				   cach‚ avec le fond de l'objet pŠre. */

				do
				{
					objet=Fcm_get_objet_parent( adr_formulaire, objet );
					/* Si le pere est une IBOX ou est cach‚, on cherche   */
					/* le pere de niveau sup‚rieur jusqu'… l'objet racine */
				}
				while(	(		((adr_formulaire+objet)->ob_flags & OF_HIDETREE)
							||	((adr_formulaire+objet)->ob_type == G_IBOX)
						)
						&&	objet != 0
					 );
			}
		}




		if( wind_update(BEG_UPDATE|windupdate_mode) )
		{

			wind_get(handle_win,WF_FIRSTXYWH,&r2.g_x,&r2.g_y,&r2.g_w,&r2.g_h);

			while ( r2.g_w && r2.g_h )
			{
				if ( rc_intersect(&r1,&r2) )
				{

					pxy[0] = r2.g_x;
					pxy[1] = r2.g_y;
					pxy[2] = r2.g_x + r2.g_w - 1;
					pxy[3] = r2.g_y + r2.g_h - 1;


				   	graf_mouse(M_OFF, NULL);

					vs_clip( vdihandle, CLIP_ON, pxy );


					objc_draw( adr_formulaire, objet,7,r2.g_x,r2.g_y,r2.g_w,r2.g_h );


				 	vs_clip( vdihandle, CLIP_OFF, 0);

					graf_mouse(M_ON, NULL);

				}

				wind_get(handle_win,WF_NEXTXYWH,&r2.g_x,&r2.g_y,&r2.g_w,&r2.g_h);
			}

			wind_update(END_UPDATE);
		}

	}
	else
	{
		#ifdef LOG_FILE
		sprintf( buf_log, "ERREUR * index win ou handle win non valide index_win=%d handle_win=%d"CRLF, index_win, handle_win );
		log_print(FALSE);
		#endif
	}

	return;


}


#endif

