/* **[NyanCat]****************** */
/* *                           * */
/* * 04/10/2014 MaJ 23/05/2018 * */
/* ***************************** */



#ifndef __affiche_error__
#define __affiche_error__



#include	"Appli_error_code.h"




/* prototype */
void affiche_error( int32 error_code );




/* Fonction */
void affiche_error( int32 error_code )
{

	int16 idx_alt_error = -1;



	#ifdef LOG_FILE
	sprintf( buf_log, CRLF" affiche_error(%ld)"CRLF, error_code );
	log_print(FALSE);
	#endif



	switch( error_code )
	{
		case APPLI_ERROR_OPEN_TGA_LDG:
			idx_alt_error=ALT_ERR_OPEN_TGA;
			break;
		case APPLI_ERROR_BAD_TGA_LDG:
			idx_alt_error=ALT_ERR_BAD_TGA;
			break;
		case APPLI_ERROR_TGA_LOAD:
			idx_alt_error=ALT_ERR_TGALOAD;
			break;

		case APPLI_ERROR_CREATE_SURFACE:
			idx_alt_error=ALT_ERR_SURFACE;
			break;


		case APPLI_ERROR_INIT_SOUND:
			idx_alt_error=ALT_ERR_INITSND;
			break;

		case APPLI_ERROR_XBIOS_FALCON:
			idx_alt_error=ALT_ERR_XBIOSDMA;
			break;

		case APPLI_ERROR_DMA_LOCKED:
			idx_alt_error=ALT_ERR_DMA_LOCK;
			break;





		case APPLI_ERROR_DATA_PATH_OVER:
			idx_alt_error=ALT_ERR_DATA_PTH;
			break;

		case APPLI_ERROR_DATAFILE_NOT_FOUND:
			idx_alt_error=ALT_ERR_DATAFILE;
			break;

		case APPLI_ERROR_AVR_NOT_FOUND:
			idx_alt_error=ALT_ERR_NYAN_AVR;
			break;



		case APPLI_ERROR_AVR_PATH_OVER:
			idx_alt_error=ALT_ERR_AVR_PATH;
			break;
		case APPLI_ERROR_AVR_SIZE:
			idx_alt_error=ALT_ERR_AVR_SIZE;
			break;
		case APPLI_ERROR_RESERVE_RAM:
			idx_alt_error=ALT_ERR_RES_RAM;
			break;
		case APPLI_ERROR_LOAD_AVR:
			idx_alt_error=ALT_ERR_LOAD_AVR;
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
					}
					else
					{
						printf(CRLF"affiche error(): buffer size error"CRLF);
						Fcm_affiche_alerte( DATA_MODE_USER, (uint32)(adr_formulaire+ALT_ERR_INCONNU)->ob_spec.free_string, &dummy );
					}
				}

				#undef TAILLE_BUFFER_AFFICHE_ERROR
			}
			break;
	}



	if( idx_alt_error>0 )
	{
		int16 dummy;

		Fcm_affiche_alerte( DATA_MODE_APPLI, (uint16)idx_alt_error, &dummy );
	}


	return;


}


#endif

