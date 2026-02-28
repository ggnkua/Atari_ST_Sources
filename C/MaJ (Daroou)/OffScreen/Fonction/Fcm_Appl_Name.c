/*=================================*/
/* Appl_Name.c                     */
/* 02/02/2004 # 19/01/2013         */
/*_________________________________*/

/*
 * Fonction extraite du source ldginfo.c de
 * Dominique BÇrÇziat lägärement modifiÇ.
 *
 *
 *
 *
 * Cette fonction rÇcupäre le nom de l'applivation
 * correspondant Ö l'ID transmise en paramätre.
 *
 *
 */


/* Prototype */
CHAR *Fcm_appl_name( const WORD my_ap_id );


/* Fonction */
CHAR *Fcm_appl_name( const WORD my_ap_id )
{
/*
 *
 */
	#define	UNKNOW	"???"

	static char name[16]="";
	WORD ap_id_found;
	WORD type=APP_SYSTEM|APP_APPLICATION|APP_ACCESSORY|APP_SHELL;
	WORD more_process;
	CHAR get_name[16]="";


	#ifdef LOG_FILE
	sprintf( buf_log, "# Fcm_appl_name(%d)=", my_ap_id );
	log_print( FALSE );
	#endif



	strcpy( name, UNKNOW);


	if( Fcm_is_appl_search() != 0 )
	{
		more_process=appl_search( APP_FIRST, get_name, &type, &ap_id_found);


		if( ap_id_found==my_ap_id )
		{
			strcpy( name, get_name );
		}
		else if( more_process!=0 )
		{
			while( appl_search(APP_NEXT, get_name, &type, &ap_id_found) )
			{
				if( ap_id_found == my_ap_id )
				{
					strcpy( name, get_name );
					break;
				}
			}
		}
	}

	#ifdef LOG_FILE
	sprintf( buf_log, "{%s}"CRLF, name );
	log_print( FALSE );
	#endif

	return name;


}

