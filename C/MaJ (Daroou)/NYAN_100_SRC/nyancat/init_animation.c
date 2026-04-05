/* **[NyanCat]****************** */
/* *                           * */
/* * 04/10/2014 MaJ 24/05/2018 * */
/* ***************************** */



#include "costablex2.h"



/* prototype */
void init_animation( void );



/* Fonction */
void init_animation( void )
{


	#ifdef LOG_FILE
	sprintf( buf_log, "init_animation()"CRLF );
	log_print(FALSE);
	#endif

	/* ************************************************************** */
	/* On convertit le message du scrolltext en index sur les lettres */
	/* ************************************************************** */
	{
		int16 index_lettre;
		char *pt_position;
		char  code_texte[]= "ABCDEFGHIJKLMNOPQRSTUVWXYZ.:,!?()'-/\\";


		size_scrolltext_message = strlen(scrolltext_message);

	#ifdef LOG_FILE
	sprintf( buf_log, "size_scrolltext_message=%d"CRLF, size_scrolltext_message );
	log_print(FALSE);
	#endif
	#ifdef LOG_FILE
	sprintf( buf_log, "scrolltext_message={%s}"CRLF, scrolltext_message );
	log_print(FALSE);
	#endif


		for( index_lettre=0; index_lettre<size_scrolltext_message; index_lettre++)
		{
			pt_position = strchr( code_texte, scrolltext_message[index_lettre] );

			if( pt_position != NULL )
			{
				scrolltext_message[index_lettre] = (char)(pt_position-code_texte);
			}
			else
			{
				scrolltext_message[index_lettre]=111;
			}
		}

	}



	/* ---------------------------------- */
	/* coordonnee fond                    */
	/* ---------------------------------- */
	pxy_fond[0] = 0;
	pxy_fond[1] = 0;
	pxy_fond[2] = SCREEN_WIDTH - 1;
	pxy_fond[3] = SCREEN_HEIGHT - 1;

	pxy_fond[4] = 0;
	pxy_fond[5] = 0;
	pxy_fond[6] = SCREEN_WIDTH - 1;
	pxy_fond[7] = SCREEN_HEIGHT - 1;


	/* ---------------------------------- */
	/* coordonnee Arc en Ciel             */
	/* ---------------------------------- */
	pxy_arcenciel[0] = 0;
	pxy_arcenciel[1] = 0;
	pxy_arcenciel[2] = ARCENCIEL_W - 1;
	pxy_arcenciel[3] = ARCENCIEL_H - 1;

	pxy_arcenciel[4] = ARCENCIEL_X;
	pxy_arcenciel[5] = ARCENCIEL_Y;
	pxy_arcenciel[6] = ARCENCIEL_X + ARCENCIEL_W - 1;
	pxy_arcenciel[7] = ARCENCIEL_Y + ARCENCIEL_H - 1;



	/* ---------------------------------- */
	/* coordonnee Nyancat                 */
	/* ---------------------------------- */
	pxy_nyancat[0] = 0;
	pxy_nyancat[1] = 0;
	pxy_nyancat[2] = NYANCAT_W - 1;
	pxy_nyancat[3] = NYANCAT_H - 1;

	pxy_nyancat[4] = NYANCAT_X;
	pxy_nyancat[5] = NYANCAT_Y;
	pxy_nyancat[6] = NYANCAT_X + NYANCAT_W - 1;
	pxy_nyancat[7] = NYANCAT_Y + NYANCAT_H - 1;


	/* ---------------------------------- */
	/* coordonnee Texte                   */
	/* ---------------------------------- */
	pxy_texte[1] = 0;
	pxy_texte[3] = LETTRE_HEIGHT - 1;


	return;


}

