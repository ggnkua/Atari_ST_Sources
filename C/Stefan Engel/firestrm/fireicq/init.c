#include "fireicq.h"
#include <mintbind.h>
#include <dos.h>
//********************************************************************
// 1998-09-16 - Created
//********************************************************************
// init: Calls all other initiation routines
//********************************************************************
int init( int argc , char *argv[] )
{
	init_default();
	if( !init_appl() )	{	Return( FALSE );	}
	if( !init_graph() )	{	Return( FALSE );	}
	if( !init_rsc() )	{	Return( FALSE );	}

	load_config();

	#ifdef USE_MENU
	if( !open_menu( menu_tree , 1 ) )
	{
		sprintf(tempvar.errorstring, MENU_ERROR );
		alertbox( 1 , tempvar.errorstring );
		
		#ifdef LOGGING 
		Log( LOG_INIT , "Could not open menu-system!!!!\n" ); 
		#endif

		Return FALSE ;
	} 
	#endif

	if( !tempvar.registered )
	{
		open_dialog( &info_win , NULL );
	}
	else
	{
		open_dialog( &main_win , NULL );
	}
	Return TRUE ;
}

//********************************************************************
// 1998-08-16 - Created
//********************************************************************
// init_default: Puts some default values into some variables
//********************************************************************
void init_default( void )
{
	tempvar.config_changed = FALSE;
	tempvar.user_changed = FALSE;
	tempvar.registered = FALSE;
	strcpy(tempvar.errorstring,"");
}

//********************************************************************
// 1998-09-16 - Created
//********************************************************************
// Initiates the Application so that it can make AES calls
//********************************************************************
int init_appl(void)
{
	char	args[ MAXSTRING ];
	char	progname[ SIZE_ID + 1 ];  
	int		flag;
	char	*temp_s;
	char	*addr;
	
	ap_id = appl_init();
	if( ap_id == FAIL )
	{
		sprintf( tempvar.errorstring , APPL_ERROR );
		alertbox( 1 , tempvar.errorstring );
		
		#ifdef LOGGING 
		Log( LOG_INIT , "Could register Application!!!!\n" ); 
		#endif

		Return FALSE;
	}

	Pdomain( 1 );

	flag = shel_read( system_dir , args);
	if( !flag )
	{
		#ifdef LOGGING
			Log( LOG_INIT , "shell_read, did not work :( %d\n" , flag );
		#endif
		Return FALSE;
	}

	#ifdef LOGGING
	Log(LOG_INIT,"system-path returned by shell_read: %s\n",system_dir);
	#endif

	temp_s = ( char * )strrchr( system_dir , '\\' );
	if( temp_s == NULL )
	{
		#ifdef LOGGING
		Log( LOG_INIT , "there was no end '\\' in the pathname: %s\n " , system_dir);
		#endif
		Return FALSE;
	}
	*temp_s++ = 0;
	strncpy( progname , temp_s , 8 );
	strcat( system_dir , "\\fireconf\\" );
	progname[ 8 ] = 0;
	temp_s = ( char * )strchr( progname , '.' );
	if( temp_s )
		*temp_s = 0;
	while ( strlen( progname ) < 8 )
		strcat( progname, " " );

	if( ( !strcmp( progname , "LC5     " ) ) || ( system_dir[ 0 ] == 0 ) )
	{
		#ifdef LOGGING
		Log( LOG_INIT , "could not use path provided from shell-read , resorting to a different method \n " );
		#endif
		strcpy( system_dir , "A:" );
		system_dir[ 0 ] = Dgetdrv() + 'A';
		Dgetpath( system_dir + 2 , 0 );
		strcat( system_dir , "\\fireconf\\" );
	}
  
	#ifdef LOGGING
	Log( LOG_INIT , "Getting the name of the AV-Server\n" );
	#endif

	flag = shel_envrn( &addr , "AVSERVER=" );
	if( !addr )
	{
		#ifdef LOGGING
		Log( LOG_INIT , "NO AVSERVER enviroment string found \n" );
		#endif
    	if( appl_find( "AVSERVER" ) >= 0 )
    	{
			#ifdef LOGGING
			Log( LOG_INIT , "AVSERVER Application found\n" );
			#endif

			strcpy( avserver , "AVSERVER" );
		}
		else if( appl_find( "THING   " ) >=0 )
		{
			#ifdef LOGGING
			Log( LOG_INIT , "THING Application found\n" );
			#endif

			strcpy(avserver,"THING   ");
		}
		else if( appl_find( "GEMINI  " ) >=0 )
		{
			#ifdef LOGGING
			Log( LOG_INIT , "GEMINI Application found\n" );
			#endif
			
			strcpy( avserver , "GEMINI  " );
		}

		if( avserver[ 0 ] == 0 )
		{
			#ifdef LOGGING
			Log( LOG_INIT , "No AVSERVER application found\n" );
			#endif
		}
	}
	else
	{
		#ifdef LOGGING
		Log( LOG_INIT , "AVSERVER: %s\n" , addr );
		#endif

		strcpy( avserver , addr );
		while ( strlen( avserver ) < 8 )
			strcat( avserver, " ");
	}  
	flag = appl_find( avserver );
	if ( flag == ap_id )
		strcpy( avserver , "" );

	Return TRUE;
}

//********************************************************************
// 1998-09-16 - Created
//********************************************************************
// init_rsc: Loads and initiates the resource-file
//********************************************************************
int init_rsc()
{
	short dummy;
	char  filnamn[ MAXSTRING ];

	rsrc_free(); 
	strcpy( filnamn , system_dir );
	if( screeny > 15 )
		strcat( filnamn , RESURSL );
	else
		strcat( filnamn , RESURSH );
	dummy = rsrc_load( filnamn );

	if( !dummy )
	{
		strcpy( tempvar.errorstring , RESOURCE_ERROR );
		alertbox( 1 , tempvar.errorstring );

		#ifdef LOGGING
		Log( LOG_INIT , "Could not load resource-file: %s\n" , filnamn );
		#endif

		Return FALSE;
	}
  
	for( dummy = 0 ; dummy < MAX_ALERTS ; dummy++ )
		rsrc_gaddr( R_STRING , dummy , &alerts[ dummy ] );	
  
	rsrc_gaddr(R_TREE,ICONS,&icons);

	init_info_win();
//	init_main_win();
	
	#ifdef USE_MENU
	rsrc_gaddr(R_TREE,MENU,&menu_tree);
	#endif

	Return TRUE;
}

//********************************************************************
// 1998-09-16 - Created
//********************************************************************
// init_config: Creates an default config that will be used the first
//              time an user uses the program
//********************************************************************
void init_config()
{
	memset( &config , NOLL , sizeof( CONFIG ) );
  
	strcpy( config.name , "FireSTorm" );
	strcpy( config.adr1 , "Streetadress" );
	strcpy( config.adr2 , "Postalcode, City" );
	strcpy( config.adr3 , "Country" );
	strcpy( config.key , "Key" );
	strcpy( config.stringserver , "STRNGSRV" );
	config.active_uin = 0;
}

//********************************************************************
// 1998-09-16 - Created
//********************************************************************
// deinit: De-inits everything from memory de-allocations to closing
//         files and windows
//********************************************************************
void deinit(void)
{
	#ifdef LOGGING
	Log(LOG_FUNCTION,"deinit()\n");
	#endif
  
//	close_main_win();
  
	deinit_graph();
	
	#ifdef USE_MENU
	menu_bar(menu_tree,0);
	#endif
  
	if(icons)
		rsrc_free();
    
	if(ap_id!=NOLL)
		appl_exit();

}

