/********************************************************************/
/* Include filer                                                    */
/********************************************************************/
#include	<stdio.h>
#include	<osbind.h>
#include	<gemlib.h>
#include	"..\windia\win_dia.h"
#include	"..\fire.h"
#include	"..\list.h"
#include	"fireconf\fireicq.h"
/********************************************************************/
/********************************************************************/

#define	CONFIGFILE			"firenews.cfg"
#define	RESURSL				"fireicq.rsc"
#define	RESURSH				"fireicq.rsc"
#define	VALIDKEY			"t71MHkJIhgCsw2Qf4TASZX39dvD8qazRNEV6y5YcBGijxbnrmFUuKlpoLPeO0W"
#define	VERSION				"0.01"
#define	VERSION_CFG			"FI 0.01"
#define	MAX_MSG_SIZE		450

#define	SIZE_ID				8
#define	SIZE_NAME			31
#define	MAX_NAME_SIZE		31
#define MAX_DEFAULT_MSG		8

#define CONFIG_NAME			"Name          : {%s}\n"
#define CONFIG_ADRESS1		"Adress1       : {%s}\n"
#define CONFIG_ADRESS2		"Adress2       : {%s}\n"
#define CONFIG_ADRESS3		"Adress3       : {%s}\n"
#define CONFIG_KEY			"Key           : {%s}\n"
#define CONFIG_UIN			"Uin           : %d\n"
#define CONFIG_STRINGSRV	"Stringserver  : {%s}\n"
#define USER_NICK			"Nick          : {%s}\n"
#define USER_UIN			"Uin           : {%s}\n"
#define USER_MESSAGES		"MessageDir    : {%s}\n"
#define USER_EMAIL			"E-mail        : {%s}\n"
#define USER_REALNAME		"Real-Name     : {%s}\n"
#define CONFIG_WIND1		"Wind-1        : %d %d %d %d\n"
#define CONFIG_WIND2		"Wind-2        : %d %d %d %d\n"
#define CONFIG_WIND3		"Wind-3        : %d %d %d %d\n"
#define CONFIG_WIND4		"Wind-4        : %d %d %d %d\n"
#define CONFIG_WIND5		"Wind-5        : %d %d %d %d\n"
#define CONFIG_WIND6		"Wind-6        : %d %d %d %d\n"
#define CONFIG_WIND7		"Wind-7        : %d %d %d %d\n"
#define CONFIG_WIND8		"Wind-8        : %d %d %d %d\n"
#define USER_HOMEPAGE		"HomePage      : {%s}\n"
#define CONFIG_UNKNOWN		"AES-Messages  : %d\n"

typedef struct
{
	char					errorstring			[ MAXSTRING ],
							lastpath			[ MAXSTRING ],
							lastfile			[ MAXSTRING ];
	int						registered			: 1,
							config_changed		: 1,
							user_changed		: 1,
							no_config			: 1;
							
}VARIABLES;

typedef struct
{
	char					id[ SIZE_ID + 1 ],
							name[ SIZE_NAME + 1 ],
							adr1[ SIZE_NAME + 1 ],
							adr2[ SIZE_NAME + 1 ],
							adr3[ SIZE_NAME + 1 ],
							key[ SIZE_NAME + 1 ],
							stringserver[ SIZE_ID + 1 ];
	long					active_uin;
}CONFIG;

typedef struct
{
	long					uin;
	char					nick[ SIZE_NAME + 1 ];
	char					realname[ SIZE_NAME + 1 ];
	short					main_wind_pos[ 4 ];
	long					last_status;
	char					away_msg[ MAX_DEFAULT_MSG ][ MAX_MSG_SIZE + 1 ],
							dnd_msg[ MAX_DEFAULT_MSG ][ MAX_MSG_SIZE + 1 ];
}USERINFO;

#ifdef	LOGGING
#define	COMMAND_LOG			"-LOG"
#define	LOG_MAXTYPES		20
#define	LOG_STRINGSIZE		80
#define	LOG_FILEOP			"F"
#define	LOG_MEMORY			"M"
#define	LOG_WINDOW			"W"
#define	LOG_ERROR			"E"
#define	LOG_GENERAL			" "
#define	LOG_INIT			"I"
#define	LOG_AESMESSAGE		"A"
#define	LOG_DIALOG			"D"
#define	LOG_FUNCTION		"P"
#define	LOG_FUNCTION2		"V"
#define	LOG_TEMPORARY		"T"
typedef struct
{
	int  on  :1,
	     all :1;
	char what[LOG_MAXTYPES+1];
	char mess[LOG_STRINGSIZE+1];
}LOGG;

#define Return  Log(LOG_FUNCTION,"End function\n"); Log(LOG_MEMORY,"Checking Memory\n"); Log(LOG_MEMORY,"Free Mem (Largest block)=%l\n",(long)Malloc(-1)); return
#else
#define Return return
#endif

/********************************************************************/
/* Deklarationer av funktioner                                      */
/********************************************************************/
#ifdef LOGGING
void    Log(const char *logtype,char *logstring,...);
#endif

#include "variable.h"