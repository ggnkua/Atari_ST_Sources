/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 23/12/2001 MaJ 03/03/2024 * */
/* ***************************** */



#ifndef __FCM_GET_TOS_VERSION_C__
#define __FCM_GET_TOS_VERSION_C__


/* Prototype */
uint16 get_OS_entry( void );



uint16 Fcm_get_tos_version( void )
{
	return( (uint16)Supexec( get_OS_entry ) );
}





uint16 get_OS_entry( void )
{
	uint32	*os_entry;
	uint16	*pt_osheader;


	os_entry = (uint32 *)0x4F2;  /* contient un pointeur vers struct OSHEADER */
	/* https://freemint.github.io/tos.hyp/en/OSHEADER.html */


	pt_osheader = (uint16 *)*os_entry;
	/* pt_osheader pointe sur le premier champ de la structure OSHEADER */

	/*
	typedef struct _osheader
	{
		uint16_t    os_entry;    pt_osheader[0]    BRAnch instruction to Reset-handler
		uint16_t    os_version;  pt_osheader[1]    TOS version number
	    ...
	} OSHEADER;
	*/


	return( pt_osheader[1] );


}


#endif   /*   __FCM_GET_TOS_VERSION_C__   */

