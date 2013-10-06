#ifndef	INCLUDED_CLI_H
#define	INCLUDED_CLI_H

/* ###################################################################################
#  INCLUDES
################################################################################### */

#include	<GODLIB\BASE\BASE.H>

/* ###################################################################################
#  DEFINES
################################################################################### */

#define	dCLI_ACTIVE


/* ###################################################################################
#  ENUMS
################################################################################### */

typedef	void	(*fCliCommandFunc)( const char * apArgs );


/* ###################################################################################
#  PROTOTYPES
################################################################################### */

#ifdef	dCLI_ACTIVE

void			Cli_Init( void );
void			Cli_DeInit( void );
void			Cli_Update( void );
void			Cli_Main( void );

void			Cli_CmdInit( char * apCommandString, fCliCommandFunc afCmd, char * apHelpTxt );
void			Cli_CmdDeInit( char * apCommandString );

void			Cli_PrintLine( char * apTxt );

S32				Cli_GrabNumber( const char * apTxt );
U16 *			Cli_GetpSavedPal( void );
U16 *			Cli_GetpPal( void );

#else

#define			Cli_Init()
#define			Cli_DeInit()
#define			Cli_Update()
#define			Cli_Main()

#endif

/* ################################################################################ */

#endif	/*	INCLUDED_CLI_H	*/