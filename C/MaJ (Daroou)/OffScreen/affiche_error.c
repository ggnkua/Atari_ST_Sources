/* **[Offscreen]**************** */
/* *                           * */
/* * 10/12/2015 MaJ 10/01/2016 * */
/* ***************************** */



#ifndef __affiche_error__
#define __affiche_error__



#include "Offscreen_error_code.h"




/* prototype */
void affiche_error( int16 error_code );




/* Fonction */
void affiche_error( int16 error_code )
{

	int16 idx_alt_error=-1;



	#ifdef LOG_FILE
	sprintf( buf_log, CRLF" affiche_error(%d)"CRLF, error_code );
	log_print(FALSE);
	#endif



	switch( error_code )
	{
		case OFFSCREEN_ERROR_OPEN_TGA_LDG:
			idx_alt_error=ALT_ERR_OPEN_TGA;
			break;

		case OFFSCREEN_ERROR_CREATE_SURFACE:
			idx_alt_error=ALT_ERR_SURFACE;
			break;

		case OFFSCREEN_ERROR_REZ_256C:
			idx_alt_error=ALT_BAD_REZ_256C;
			break;

		case OFFSCREEN_ERROR_DATA_PATH_OVER:
			idx_alt_error=ALT_ERR_DATA_PTH;
			break;

		case OFFSCREEN_ERROR_DATAFILE_NOT_FOUND:
			idx_alt_error=ALT_ERR_DATAFILE;
			break;

		case OFFSCREEN_ERROR_REZ_TOO_LITTLE:
			idx_alt_error=ALT_ERR_REZ_LIT;
			break;

		case OFFSCREEN_ERROR_MODE_STRAM:
			idx_alt_error=ALT_ERR_MODESTRM;
			break;

		case OFFSCREEN_ERROR_MODE_TTRAM:
			idx_alt_error=ALT_ERR_MODETTRM;
			break;



		case OFFSCREEN_ERROR_ANIMATION_SIZE:
			idx_alt_error=ALT_ERR_ANIMSIZE;
			break;

		case OFFSCREEN_ERROR_ANIMATION_RAM:
			idx_alt_error=ALT_ERR_ANIM_RAM;
			break;

		case OFFSCREEN_ERROR_ANIMATION_LOAD:
			idx_alt_error=ALT_ANIM_LOAD;
			break;







		default:
			{
				#define TAILLE_BUFFER_AFFICHE_ERROR (256)

				char	 buffer[TAILLE_BUFFER_AFFICHE_ERROR];
				OBJECT	*adr_formulaire;
				int16    reponse;
				int16    dummy;


				reponse=rsrc_gaddr( R_TREE, DL_ALERTE_APPLI, &adr_formulaire );

				if(reponse==0)
				{
					printf(CRLF"affiche error(): RSC R_STRING1 error!"CRLF);
				}
				else
				{
					if( strlen( (adr_formulaire+ALT_ERR_INCONNU)->ob_spec.free_string ) < (TAILLE_BUFFER_AFFICHE_ERROR-6) )
					{
						sprintf( buffer, (adr_formulaire+ALT_ERR_INCONNU)->ob_spec.free_string, error_code );
						Fcm_affiche_alerte( DATA_MODE_USER, (uint32)buffer, &dummy );
/*						form_alert(1, buffer);*/
					}
					else
					{
						printf(CRLF"affiche error(): buffer size error"CRLF);
						Fcm_affiche_alerte( DATA_MODE_USER, (uint32)(adr_formulaire+ALT_ERR_INCONNU)->ob_spec.free_string, &dummy );
/*						form_alert(1, (adr_formulaire+ALC_BAD_CONFIG)->ob_spec.free_string);*/
					}
				}

				#undef TAILLE_BUFFER_AFFICHE_ERROR
			}
			break;
	}



	if( idx_alt_error>0 )
	{
		int16 dummy;

		Fcm_affiche_alerte( DATA_MODE_APPLI, idx_alt_error, &dummy );
	}



	return;


}


#endif  /*  __affiche_error__ */

