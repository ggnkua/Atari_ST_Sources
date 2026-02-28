/* **************************** */
/* * Fcm_get_tos_version()    * */
/* * 23/12/2001 - 08/01/2015  * */
/* **************************** */



#ifndef __Fcm_get_tos_version__
#define __Fcm_get_tos_version__




/* Prototype */
uint16 Fcm_get_tos_version(void);
uint16 get_OS_entry(void);


/* Fonctions */
uint16 Fcm_get_tos_version(void)
{
	return( (uint16)Supexec(get_OS_entry) );
}




uint16 get_OS_entry(void)
{
	uint32	*os_entry;
	uint16	*pt_tos_version;


	os_entry=(uint32 *)0x4F2;
	pt_tos_version=(uint16 *)*os_entry;


	return( pt_tos_version[1] );


}


#endif

