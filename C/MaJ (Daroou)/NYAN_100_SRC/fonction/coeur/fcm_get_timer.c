/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 23/12/2001 MaJ 29/11/2025 * */
/* ***************************** */



/* ------------------------------------- */
/* lecture de l'horloge system 1/200 sec */
/* ------------------------------------- */



#ifndef __FCM_GET_TIMER_C__
#define __FCM_GET_TIMER_C__



/* fonction interne a ce fichier */
int32 get_long_0x4ba( void );




uint32 Fcm_get_timer( void )
{
	return( (uint32)Supexec( get_long_0x4ba ) );
}



int32 get_long_0x4ba( void )
{
	/* cette variable contient le temps ‚coul‚ depuis  */
	/* l'allumage du micro en 1/200Šme de secondes     */
	return(  *( (int32 *)0x4BA )  );
}


#endif  /* __FCM_GET_TIMER_C__ */

