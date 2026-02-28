/* ***************************************** */
/* *          Fonction GET_TIMER()         * */
/* * lecture de l'horloge system 1/200 sec * */
/* * 23/12/2001 - 06/04/2013               * */
/* ***************************************** */



#ifndef __Fcm_get_timer__
#define __Fcm_get_timer__ 




/* Prototype */
uint32 Fcm_get_timer(VOID);
uint32 get_long_0x4ba(VOID);


/* Fonctions */
uint32 Fcm_get_timer(VOID)
{


	return( Supexec(get_long_0x4ba) );


}




uint32 get_long_0x4ba(VOID)
{
	/* cette variable contient le temps ‚coul‚ depuis  */
	/* l'allumage du micro en 1/200Šme de secondes     */

	return(  *( (uint32 *)0x4BA )  );

}



#endif

