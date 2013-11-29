/*----------------------------------------------------------------------------------------*
 * MControl                                                                               *
 *----------------------------------------------------------------------------------------*
 * Copyright (c) 2000 - 2002 Joachim Fornallaz                                            *
 *----------------------------------------------------------------------------------------*
 * This source file is subject to the BSD license.                                        *
 *----------------------------------------------------------------------------------------*
 * Authors: Joachim Fornallaz <jf@omnis.ch>                                               *
 *----------------------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------------------*/
/* global includes																								*/
/*----------------------------------------------------------------------------------------*/

#include	<va_proto.h>
#include	<mgx_dos.h>
#include	<cflib.h>
#include	<string.h>
#include	<stdlib.h>
#include	<types2b.h>
#include <bubblgem.h>

/*----------------------------------------------------------------------------------------*/
/* local includes																									*/
/*----------------------------------------------------------------------------------------*/

#include	"appcomm.h"
#include	"strcmd.h"
#include	"file.h"

/*----------------------------------------------------------------------------------------*/
/* defines																											*/
/*----------------------------------------------------------------------------------------*/

#ifndef	NIL
#define	NIL	-1
#endif

#define	MAXLEN_PATH	256

/*----------------------------------------------------------------------------------------*/
/* global variables																								*/
/*----------------------------------------------------------------------------------------*/

uint8	*global_str1;
uint8	*global_str2;
uint8	*global_bgem;

int16	msgbuff[8];

/*----------------------------------------------------------------------------------------*/
/* function prototypes																							*/
/*----------------------------------------------------------------------------------------*/

static	boolean	send_msg(int16 id);
static	int16		get_id( uint8 *name, uint8 *path, uint8 *arg, boolean *started);

/*----------------------------------------------------------------------------------------*/
/* functions																										*/
/*----------------------------------------------------------------------------------------*/


/*----------------------------------------------------------------------------------------*/
/* init function 																									*/
/* return: -																						 				*/
/*----------------------------------------------------------------------------------------*/
void	init_comm( void )
{
	global_str1 = (uint8 *) malloc_global (256);
	global_str2 = (uint8 *) malloc_global (256);
	global_bgem = (uint8 *) malloc_global (256);
	
	if( !global_str1 || !global_str2 || !global_bgem )
		Pterm( -1 );
}


/*----------------------------------------------------------------------------------------*/
/* exit function 																									*/
/* return: -																						 				*/
/*----------------------------------------------------------------------------------------*/
void	exit_comm( void )
{
	if( global_str1 )
		Mfree( global_str1 );
	if( global_str2 )
		Mfree( global_str2 );
	if( global_bgem )
		Mfree( global_bgem );

	global_str1 = 0L;
	global_str2 = 0L;
	global_bgem = 0L;
}


/*----------------------------------------------------------------------------------------*/
/* function 																										*/
/* return: -																						 				*/
/*----------------------------------------------------------------------------------------*/
boolean	make_name( uint8 *longname, uint8 *shortname )
{
	int16	len, i;
	uint8	*p;

	if (longname[0] == EOS)
	{
		strcpy(shortname, "");
		return FALSE;
	}
	else
	{
		if( strchr(longname, '\\') )
			split_filename( longname, NULL, shortname );
		else
			strcpy( shortname, longname );
		str_upper( shortname );
		p = strrchr(shortname, '.');				/* Extension abschneiden */
		if(p)
			*p = '\0';
		len = (int16) strlen(shortname);
		for (i = len; i < 8; i++)
			strcat(shortname, " ");
		shortname[8] = EOS;
	}
	return TRUE;
}


/*----------------------------------------------------------------------------------------*/
/* function 																										*/
/* return: -																						 				*/
/*----------------------------------------------------------------------------------------*/
int16	av_server( void )
{
	int16		desk_id = NIL;
	uint8		desk_name[32];
	uint8		desk_path[MAXLEN_PATH];

	if( getenv("AVSERVER") != NULL )
	{
		strcpy( desk_path, getenv("AVSERVER") );

		if( make_name( desk_path, desk_name ) )
		{
			desk_id = appl_find( desk_name );
		}
	}

	if( gl_magx && desk_id < 0)
	{
		desk_id = 0;
	}
	else
	{
		desk_id = appl_find("THING   ");
	}
	if( desk_id < 0 )
	{
		desk_id = appl_find("JINNEE  ");
	}
	return desk_id;
}


/*----------------------------------------------------------------------------------------*/
/* function 																										*/
/* return: -																						 				*/
/*----------------------------------------------------------------------------------------*/
void	av_xwind( uint8 *path )
{
	int16		desk_id = av_server();
	uint8		*p;

	strcpy( global_str2, path );
	strcpy( global_str1, "*" );

	p = strrchr( global_str2, '\\' );

	if( (p != NULL) && (p+1 != EOS) )
	{
		strcpy( global_str1, p+1 );
		p[1] = EOS;
	}

	if( path_exist( global_str2 ) && ( desk_id > NIL ) )
	{
		memset(msgbuff, 0, (int16)sizeof(msgbuff));
		msgbuff[0] = AV_XWIND;
		*(uint8 **)(msgbuff + 3) = global_str2;
		*(uint8 **)(msgbuff + 5) = global_str1;
		msgbuff[7] = 0x0001 | 0x0002;
		send_msg(desk_id);
	}
}


/*----------------------------------------------------------------------------------------*/
/* function 																										*/
/* return: -																						 				*/
/*----------------------------------------------------------------------------------------*/
void	av_path_update( uint8 *path )
{
	int16		desk_id = av_server();

	strcpy( global_str2, path );

	if( path_exist( path ) && ( desk_id > NIL ) )
	{
		memset(msgbuff, 0, (int16)sizeof(msgbuff));
		msgbuff[0] = AV_PATH_UPDATE;
		*(uint8 **)(msgbuff + 3) = global_str2;
		send_msg(desk_id);
		evnt_timer(200);
	}
}


/*----------------------------------------------------------------------------------------*/
/* Sendet BUBBLEGEM_SHOW an BubbleGEM, d.h. ”ffnet eine Sprechblase								*/
/* Funktionsergebnis:	-																						*/
/*----------------------------------------------------------------------------------------*/
boolean	bgem_show( uint8* bubble_text, int16 mx, int16 my )
{
	int16		bubble_id;
	uint8		bubble_path[MAXLEN_PATH];
	boolean	started;

	if( getenv("BUBBLEGEM") )
		strcpy( bubble_path, getenv("BUBBLEGEM") );

	bubble_id = get_id("BUBBLE  ", bubble_path, "", &started);

	if( bubble_id < 0 || !bubble_text )		/* BubbleGEM nicht gefunden -> Abbruch */
		return FALSE;	

	strcpy( global_bgem, bubble_text );

	msgbuff[0] = BUBBLEGEM_SHOW;
	msgbuff[1] = gl_apid;
	msgbuff[2] = 0;
	msgbuff[3] = mx;
	msgbuff[4] = my;
	msgbuff[5] = (int16)(((int32) global_bgem >> 16) & 0x0000ffff);
	msgbuff[6] = (int16)((int32) global_bgem & 0x0000ffff);
	msgbuff[7] = 0;

	if (appl_write(bubble_id, 16, msgbuff) == 0)
	{
		/* Fehler */
	}
	return TRUE;
}


/*----------------------------------------------------------------------------------------*/
/* Sendet BUBBLEGEM_ASKFONT an den AV-Desktop															*/
/* Funktionsergebnis:	-																						*/
/*----------------------------------------------------------------------------------------*/
void	bgem_askfont( void )
{
	int16		desk_id = av_server();

	if( desk_id > NIL )
	{
		memset(msgbuff, 0, (int16)sizeof(msgbuff));
		msgbuff[0] = BUBBLEGEM_ASKFONT;
		send_msg(desk_id);
	} 
}


/*----------------------------------------------------------------------------------------*/
/* Enpf„ngt BUBBLEGEM_ACK																						*/
/* Funktionsergebnis:	-																						*/
/*----------------------------------------------------------------------------------------*/
boolean	bgem_font( int16 *FontID, int16 *FontPt )
{
	int16		which, msg[8];
	GRECT		dummy;
	EVNTDATA	evdat;
	int16		kr, br;
	boolean	ret = FALSE;

	which = evnt_multi(	MU_TIMER|MU_MESAG, 0, 0, 0, 0, &dummy, 0, &dummy, msg, 1000, &evdat,
								&kr, &br );

	if(which & MU_MESAG)
	{
		if (!message_wdial(msg))
		{
			if( (uint16)msg[0] == BUBBLEGEM_FONT )
			{
				*FontID = msg[3];
				*FontPt = msg[4];
				ret = TRUE;
			}
		}
	}
	return ret;
}


/*----------------------------------------------------------------------------------------*/
/* Sendet AV_STARTPROG an den AV-Desktop																	*/
/* Funktionsergebnis:	-																						*/
/*----------------------------------------------------------------------------------------*/
void	av_startprog( uint8 *path, uint8 *cmd )
{
	int16		desk_id = av_server();

	if( path == NULL )
		return;

	strcpy( global_str2, path );
	
	if( cmd )
		strcpy( global_str1, cmd );
	else
		strcpy( global_str1, "" );

	if( desk_id > NIL )
	{
		memset(msgbuff, 0, (int16)sizeof(msgbuff));
		msgbuff[0] = AV_STARTPROG;
		*(uint8 **)(msgbuff + 3) = global_str2;
		*(uint8 **)(msgbuff + 5) = global_str1;
		send_msg(desk_id);
	} 
}


/*----------------------------------------------------------------------------------------*/
/* av_response																										*/
/* Funktionsergebnis:	-																						*/
/*----------------------------------------------------------------------------------------*/
boolean	va_progstart( int16 *code )
{
	int16		which, msg[8];
	GRECT		dummy;
	EVNTDATA	evdat;
	int16		kr, br;
	boolean	ret = FALSE;

	which = evnt_multi(	MU_TIMER|MU_MESAG, 0, 0, 0, 0, &dummy, 0, &dummy, msg, 1000, &evdat,
								&kr, &br );

	if(which & MU_MESAG)
	{
		if (!message_wdial(msg))
		{
			if( msg[0] == VA_PROGSTART && msg[3] != 0 )
			{
				*code = msg[7];
				ret = TRUE;
			}
		}
	}
	return ret;
}


/*----------------------------------------------------------------------------------------*/
/* function 																										*/
/* return: -																						 				*/
/*----------------------------------------------------------------------------------------*/
boolean	open_hyp( uint8 *file, uint8 *arg )
{
	int16			stg_id;
	uint8 		help[MAXLEN_PATH];
	uint8			stg_path[MAXLEN_PATH];
	boolean		started;

	sprintf( help, "%s %s", file, arg );

	if(getenv("ST-GUIDE") != NULL)
		strcpy( stg_path, getenv("ST-GUIDE") );
	else if(getenv("STGUIDE") != NULL)
		strcpy( stg_path, getenv("STGUIDE") );
	else strcpy(stg_path, "C:\\ST-GUIDE.ACC");

	stg_id = get_id("ST-GUIDE", stg_path, help, &started);
	if ((stg_id > 0) && !started)			/* nicht gestartet, da es bereits lief! */
		send_vastart(stg_id, help);		/* -> also Message schicken */
	return (stg_id > 0);
}


/*----------------------------------------------------------------------------------------*/
/* function 																										*/
/* return: -																						 				*/
/*----------------------------------------------------------------------------------------*/
void	open_url( uint8 *url )
{
	int16		cab_id;
	uint8 	help[MAXLEN_PATH];
	uint8		cab_path[MAXLEN_PATH];
	boolean		started;

	if( !url )
		return;

	strcpy(help, url);

	if(getenv("BROWSER") != NULL)
		strcpy( cab_path, getenv("BROWSER") );
	else if(getenv("CAB") != NULL)
		strcpy( cab_path, getenv("CAB") );

	cab_id = get_id("CAB     ", cab_path, help, &started);
	if ((cab_id >= 0) && !started)		/* nicht gestartet, da es bereits lief! */
		send_vastart(cab_id, help);		/* -> also Message schicken */
	if (cab_id < 0)
		av_startprog( help, NULL );
}


/*----------------------------------------------------------------------------------------*/
/* function 																										*/
/* return: -																						 				*/
/*----------------------------------------------------------------------------------------*/
static	int16	get_id( uint8 *name, uint8 *path, uint8 *arg, boolean *started)
{
	int16		ret = -1;
	int16		gem;
	uint8		help[128] = "";
	boolean		s = FALSE;

	gem = _GemParBlk.global[0];

	if (name[0] != EOS)
	{
		ret = appl_find(name);
		if (ret < 0)							/* ggf. als Programm nachstarten */
		{
			if (arg != NULL)					/* Kommandozeile einrichten */
			{
				strcpy(help, " ");
				strcat(help, arg);
				help[0] = (uint8)strlen(arg);
			}

			if( file_exist(path) && file_isprog(path) )
			{
				if (gem >= 0x400)
				{
					ret = shel_write(1, 1, SHW_CHAIN, path, help);
					s = (ret > 0);
				}
				else if (gl_magx)
				{
					ret = shel_write(1, 1, SHW_PARALLEL, path, help);
					s = (ret > 0);
				}
				else
				{
					ret = -1;
				}
			}
			else
			{
				ret = - 1;
			}
		}
	}
	if (started != NULL)
		*started = s;
	return ret;
}


/*----------------------------------------------------------------------------------------*/
/* function 																										*/
/* return: -																						 				*/
/*----------------------------------------------------------------------------------------*/
static	boolean	send_msg(int16 id)
{
	int16	ret;

	msgbuff[1] = gl_apid;
	msgbuff[2] = 0;
	ret = appl_write(id, (short) sizeof(msgbuff), msgbuff);
	return (ret > 0);
}
