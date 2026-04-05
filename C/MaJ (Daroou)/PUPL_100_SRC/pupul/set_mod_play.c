/* **[Pupul]******************** */
/* *                           * */
/* * 09/11/2023 MaJ 09/11/2023 * */
/* ***************************** */



#ifndef  __SET_MOD_PLAY__
 #define __SET_MOD_PLAY__

#include  "../fonction/ldg/mod.h"

#include "appli_error_code.h"
#include "affiche_error.c"

#include  "set_mod_config.c"




void set_mod_play( void );




/* Fonction */
void set_mod_play( void )
{
	int32 reponse;
	
#ifdef LOG_FILE
sprintf( buf_log, "# set_mod_play()"CRLF );
log_print(FALSE);
#endif




	/*     test si son locked      */

#ifdef LOG_FILE
sprintf( buf_log, "global_mod_ldg_update=%d global_mod_ldg_frequence=%d"CRLF,global_mod_ldg_update, global_mod_ldg_frequence );
log_print(FALSE);
#endif



	set_mod_config();


#ifdef LOG_FILE
sprintf( buf_log, "mod_play(%ld (%lx) )"CRLF, adr_buffer_MOD,adr_buffer_MOD );
log_print(FALSE);
#endif
	reponse=mod_play( (void *)adr_buffer_MOD );
	/* la LDG lock le son si tout est ok */


/*
see MOD.H
0 -> pas d'erreur
MOD_LOCKED_SOUND	-1
MOD_BAD_FORMAT		-2
MOD_BAD_MDBUF		-3
*/

	/* son locked par une autre appli ? */
	if( reponse == MOD_LOCKED_SOUND )
	{
		OBJECT	*adr_dialogue_option;
		global_mute_sound = TRUE;

		rsrc_gaddr( R_TREE, DL_OPTIONS, &adr_dialogue_option );
		SET_BIT_W( adr_dialogue_option[CHECK_MUTESOUND].ob_state, OS_SELECTED, 1);
		Fcm_objet_draw( adr_dialogue_option, h_win[W_OPTIONS], CHECK_MUTESOUND, FCM_WU_BLOCK );

		affiche_error(APPLI_ERROR_DMA_LOCKED);
	}
		
	
	
#ifdef LOG_FILE
sprintf( buf_log, "mod_checkbuf()"CRLF );
log_print(FALSE);
#endif
	if( global_mute_sound==FALSE && global_mod_ldg_update==MODLDG_UPDATE_POLLING )
	{
		mod_checkbuf();

#ifdef LOG_FILE
sprintf( buf_log, "END mod_checkbuf()"CRLF );
log_print(FALSE);
#endif
	}



	return;

}


#endif	/* #ifndef __SET_MOD_PLAY__ */


