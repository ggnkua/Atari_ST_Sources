/*=================================*/
/* Is_Appl_Search.c                */
/* 02/02/2004 # 19/01/2013         */
/*_________________________________*/

/*
 * Fonction extraite du source ldginfo.c de
 *
 * Dominique B‚r‚ziat.
 *
 *
 *
 *
 * Cette fonction verifie si la fonction Appl_Search()
 * est disponible (1) ou non (0).
 *
 *
 */


/* Prototype */
int Fcm_is_appl_search( void);


/* Fonction */
int Fcm_is_appl_search( void)
{
	short dummy, parm3;


	if( appl_find("?AGI") != -1)
	{
		appl_getinfo( AES_PROCESS, &dummy, &dummy, &parm3, &dummy);
		if( parm3 == 1) return 1;	
	}
	return 0;

}

