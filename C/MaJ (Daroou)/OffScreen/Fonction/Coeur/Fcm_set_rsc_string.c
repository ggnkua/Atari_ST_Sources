/* **[Fonction Commune]******* */
/* *                         * */
/* * 10/03/2013 = 14/03/2015 * */
/* *************************** */


#ifndef __Fcm_set_rsc_string__
#define __Fcm_set_rsc_string__




/* Prototype */
void Fcm_set_rsc_string( const int16 idx_dialogue, const int16 objet, const char *chaine );


/* Fonction */
void Fcm_set_rsc_string( const int16 idx_dialogue, const int16 objet, const char *chaine )
{
	OBJECT	*adr_formulaire;
	int16	erreur;




	#ifdef LOG_FILE
	sprintf( buf_log, "    * Fcm_set_rsc_string( dialogue:%d, objet:%d, chaine:{%s} )", idx_dialogue, objet, chaine );
	log_print(FALSE);
	#endif


	/* on cherche l'adresse du formulaire */
	erreur=rsrc_gaddr( R_TREE, idx_dialogue, &adr_formulaire );

	#ifdef LOG_FILE
	sprintf( buf_log, " -> reponse rsrc_gaddr() : %d"CRLF, erreur );
	log_print(FALSE);
	#endif


	if( erreur==0 || adr_formulaire<(OBJECT *)0 )
	{
		#ifdef LOG_FILE
		sprintf( buf_log, "ERREUR l'objet n'existe pas "CRLF );
		log_print(FALSE);
		#endif

		return;
	}






	erreur=FALSE;

	switch( adr_formulaire[objet].ob_type )
	{
		case G_STRING:
		case G_BUTTON:
			{
				int16   size_str_rsc;
				int16   size_str;
				int16   index;


				size_str_rsc = strlen( adr_formulaire[objet].ob_spec.free_string);
				size_str = strlen(chaine);

				if( size_str_rsc >= size_str )
				{
					strcpy( adr_formulaire[objet].ob_spec.free_string, chaine );

					if( size_str < size_str_rsc )
					{
						for( index=size_str; index<size_str_rsc; index++ )
						{
							adr_formulaire[objet].ob_spec.free_string[index]=' ';
						}
/*						adr_formulaire[objet].ob_spec.free_string[index-1]='*';*/
						adr_formulaire[objet].ob_spec.free_string[size_str_rsc]='\0';
					}

				}
				else
				{
					erreur=TRUE;
				}
			}
			break;


		case G_TEXT:
		case G_FTEXT:
		case G_BOXTEXT:
		case G_FBOXTEXT:
			{
				int16   size_str_rsc;
				int16   size_str;
				int16   index;


				size_str_rsc = strlen( adr_formulaire[objet].ob_spec.tedinfo->te_ptext);
				size_str = strlen(chaine);

				if( size_str_rsc >= size_str )
				{
					strcpy( adr_formulaire[objet].ob_spec.tedinfo->te_ptext, chaine );

					if( size_str < size_str_rsc )
					{
						for( index=size_str; index<size_str_rsc; index++ )
						{
							adr_formulaire[objet].ob_spec.tedinfo->te_ptext[index]=' ';
						}
/*						adr_formulaire[objet].ob_spec.tedinfo->te_ptext[index-1]='*';*/
						adr_formulaire[objet].ob_spec.tedinfo->te_ptext[size_str_rsc]='\0';
					}

				}
				else
				{
					erreur=TRUE;
				}
			}
			break;

		default:
			#ifdef LOG_FILE
			sprintf( buf_log, "ERREUR type d'objet non gere pour le moment (%d)"CRLF, adr_formulaire[objet].ob_type );
			log_print(FALSE);
			#endif
			break;
	}



	if( erreur==TRUE )
	{
		{
			char texte[256];

			sprintf(texte,"Fcm_set_rsc_string - chaine plus longue que la destination        " );
			v_gtext(vdihandle,41*8,2*16,texte);
			sprintf(texte," {%s} ", chaine );
			v_gtext(vdihandle,41*8,3*16,texte);
		}
		#ifdef LOG_FILE
		sprintf( buf_log, "ERREUR !!! chaine plus longue que la destination"CRLF);
		log_print(FALSE);
		#endif
	}


	return;


}


#endif

