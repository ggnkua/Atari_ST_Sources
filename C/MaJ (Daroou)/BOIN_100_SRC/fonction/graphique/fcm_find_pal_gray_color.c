/* **[Graphique]**************** */
/* * 08/11/2023 MaJ 08/11/2023 * */
/* ***************************** */



#ifndef ___FCM_FIND_PAL_GRAY_COLOR___
#define ___FCM_FIND_PAL_GRAY_COLOR___

#define FFPGC_TOLERANCE (16)

#include "../coeur/coeur_define.h"


/*

Parametre:

	ffpgc_tab_gray_index[ffpgc_tab_max_index];  tableau : liste des index dans la palette, index sont triés
	      ffpgc_tab_gray_index[0] couleur plus clair -> ffpgc_tab_gray_index[ffpgc_gray_nbindex] couleur plus sombre

	ffpgc_max_val_color                   niveau max teinte couleur voulu (0-1000)

	retourne le nombre de niveau de gris trouvé.

*/




/* prototype */
uint16 Fcm_find_pal_gray_color( int16 *ffpgc_tab_gray_index, uint16 ffpgc_tab_max_index, int16 ffpgc_max_val_color );


/* vdihandle de l'application */
extern  int16  global_vdihandle_ecran;


/* Fonction */
uint16 Fcm_find_pal_gray_color( int16 *ffpgc_tab_gray_index, uint16 ffpgc_tab_max_index, int16 ffpgc_max_val_color )
{
	/* recherche des niveaux de gris present dans la patette */

	typedef struct {
		int16 index;
		int16 color;
	} s_pal_ffpgc;


	s_pal_ffpgc gray[256];
	uint16      compteur=0;
	uint16		ffpgc_gray_nbindex=0;


	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"# Fcm_find_pal_gray_color()"CRLF);
	log_print(FALSE);
	#endif



	/* ----------------------------------------------------- */
	/* on recherche tous les niveaux de gris dans la palette */
	/* ----------------------------------------------------- */
	{
		int16 idx;
		int16 reponse;
		int16 rgb_in[3];

		for( idx=0; idx<256; idx++ )
		{
			reponse=vq_color( global_vdihandle_ecran, idx, 1, rgb_in);

/*#ifdef LOG_FILE
sprintf( buf_log, "vq_color(%d)=%d "CRLF,idx, reponse );
log_print(FALSE);
#endif*/

			if( reponse != -1 )
			{

/*#ifdef LOG_FILE
sprintf( buf_log, "rgb_in[0,1,2]={%d,%d,%d}"CRLF,rgb_in[0], rgb_in[1], rgb_in[2] );
log_print(FALSE);
#endif*/

				//if(  rgb_in[0]==rgb_in[1] &&  rgb_in[0]==rgb_in[2] ) /* zero tolerance */
				if(  ABS(rgb_in[0]-rgb_in[1])<FFPGC_TOLERANCE &&  ABS(rgb_in[0]-rgb_in[2])<FFPGC_TOLERANCE )
				{
					if( rgb_in[0] <= ffpgc_max_val_color )
					{
						gray[compteur].index=idx;
						gray[compteur].color=rgb_in[0];
						compteur++;
					}
				}
			}
		}
	}





	/* ----------------------------------------------------- */
	/* on trie les couleurs trouv‚es                         */
	/* ----------------------------------------------------- */
	{
		int16 idx;
		int16 swap;

		for( idx=0; idx<(compteur-1); idx++ )
		{

			if( gray[idx+1].color > gray[idx].color )
			{
				swap=gray[idx].color;
				gray[idx].color=gray[idx+1].color;
				gray[idx+1].color=swap;

				swap=gray[idx].index;
				gray[idx].index=gray[idx+1].index;
				gray[idx+1].index=swap;

				idx=-1;
			}
		}


		/* on garde au max 'ffpgc_tab_max_index' niveau de gris */
		ffpgc_gray_nbindex=MIN( ffpgc_tab_max_index, compteur );

#ifdef LOG_FILE
sprintf( buf_log, " ffpgc_tab_max_index=%d   nb index trouve=%d"CRLF, ffpgc_tab_max_index, compteur);
log_print(FALSE);
#endif

		for( idx=0; idx<ffpgc_gray_nbindex; idx++ )
		{
			ffpgc_tab_gray_index[idx]=gray[idx].index;

#ifdef LOG_FILE
sprintf( buf_log, "-> ffpgc_tab_gray_index[%d]=%d   color teinte=%d (0-1000)"CRLF, idx, ffpgc_tab_gray_index[idx], gray[idx].color );
log_print(FALSE);
#endif
		}

	}



	return ffpgc_gray_nbindex;


}


#endif   /*  ___FCM_FIND_PAL_GRAY_COLOR___  */

