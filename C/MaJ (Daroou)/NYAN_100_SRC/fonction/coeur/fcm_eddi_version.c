/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 27/05/2018 MaJ 03/03/2024 * */
/* ***************************** */



/*
 * retourne la version de EdDI ou -1 si le cookie est absent
 *
 */


int16 Fcm_eddi_version( void )
{
	uint32 val_cookie;
	int32  reponse;


/*FCM_LOG_PRINT("-> Fcm_eddi_version()");*/

	reponse = Fcm_get_cookies( COOKIE_EdDI, &val_cookie );

/*FCM_LOG_PRINT2(" reponse Fcm_get_cookies=%ld  (val_cookie=0x%lx)", reponse, val_cookie);*/


	if( reponse == 0 )
	{

/*FCM_LOG_PRINT(" appel fonction 0 de EdDI");*/


		/* Je me rappel plus où j'ai pris ce code asm, mes excuses à l'auteur :( (Patrice Mandin?) */
		/* J'utilise ce code interne pour remplacer mon code asm extern qui posait problème pour   */
		/* la compilation du source par d'autres utilisateurs / autres compilateurs */
		__asm__ __volatile__
		(
			"move.l %1,%%a0\n\t"
			"clrl %%d0\n\t"
			"jsr (%%a0)\n\t"
			"move.w %%d0,%0\n\t"
			: "=r" (reponse) /* outputs */
			: "r"  (val_cookie) /* inputs */
			: "d0", "d1", "d2", "a0", "a1", "a2" /* clobbered regs */
		);

/*FCM_LOG_PRINT2(" reponse=%ld (0x%lx) (version EdDI sur les 16 bits bas)"CRLF, reponse, reponse );*/


		return( (int16)(reponse & 0x0000ffff) );

	}

	return( -1 );

}

