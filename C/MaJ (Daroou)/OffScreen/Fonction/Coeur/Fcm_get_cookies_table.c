/* *************************** */
/* * Table des Cookies       * */ 
/* * 31/12/2002  08/01/2015  * */
/* *************************** */



#ifndef __Fcm_get_cookies_table__
#define __Fcm_get_cookies_table__



/* Prototype */
uint32 *Fcm_get_cookies_table(void);
uint32  get_adresse_table_cookie(void);


/* Fonction */
uint32 *Fcm_get_cookies_table(void)
{

	/* On recupere l'adresse de la table des cookies */
	return( (uint32 *)Supexec(get_adresse_table_cookie) );


}




uint32 get_adresse_table_cookie(void)
{
	return(  *( (uint32 *)0x5A0L )  );
}



#endif


