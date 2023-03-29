/*****************************************************************************
 *
 * Module : AV.C
 * Author : Gerhard Stoll
 *
 * Creation date    : 01.11.02
 * Last modification: 01.11.02
 *
 *
 * Description: This module implements the av protocol
 *
 * History:
 * 01.11.02: Creation of body
 *****************************************************************************/

#include "import.h"
#include "global.h"
#include "ph_lib.h"
#include "vaproto.h"

#include "export.h"

/****** DEFINES **************************************************************/

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

LOCAL BYTE	*global_av;
LOCAL BYTE av_servername[16];
LOCAL WORD av_server;
LOCAL WORD av_shell_status;
LOCAL WORD msgbuff[8];

/****** FUNCTIONS ************************************************************/

LOCAL VOID send_message ( WORD id );

/*****************************************************************************/

LOCAL VOID send_message ( WORD id )
{
	msgbuff[1] = gl_apid;
	appl_write ( id, 16, msgbuff);
} /* send_message */

/*****************************************************************************/

GLOBAL VOID send_avstartprog ( BYTE *str, WORD magic )
{
	if ( av_server >= 0 )
	{
		memset(msgbuff, 0, (int)sizeof(msgbuff));
		msgbuff[0] = AV_STARTPROG;
		strcpy ( global_av, str );
		*(char **) (msgbuff + 3) = global_av;
		msgbuff[7] = magic;
		send_message (av_server );
	} /* if */
} /* send_avstartprog */

/*****************************************************************************/

GLOBAL WORD hndl_av ( WORD msg[16] )
{
	WORD ret;
	
	ret = FALSE;

	switch ( msg [0] )
	{
		case VA_PROTOSTATUS:
			av_shell_status = msgbuff[3];
			ret = TRUE;
		break;
		case VA_PROGSTART:
		break;
	} /* switch */
	return ret;
} /* hndl_av */

/*****************************************************************************/
/* VA-Server suchen und AV_PROTOKOLL senden																	 */
/* RÅckgabe: TRUE, wenn eine Message ausgewertet werden konnte, sonst FALSE	 */

GLOBAL WORD init_av ( VOID )
{
	BYTE *dummy;
	WORD i;

	global_av = malloc_global(256);

	dummy = getenv("AVSERVER");
	if (dummy)
	{
		strncpy ( av_servername, dummy, 9 );
		av_servername[8]=0;
		while ( strlen ( av_servername ) < 8 )
			strcat ( av_servername, " " );
		for ( i=0; i < 8; i++ )
			av_servername[i] = toupper ( av_servername[i] );
		
		av_server=appl_find( av_servername );
	} /* if */
	
	if ( av_server < 0 )
	{
		av_server=appl_find("THING   ");
		if ( av_server >= 0 )
			strcpy(av_servername,"THING   ");
		else
		{
			av_server=appl_find("GEMINI  ");
			if ( av_server >= 0 )
				strcpy(av_servername,"GEMINI  ");
			else
			{
				av_server=appl_find("EASE    ");
				if ( av_server >= 0 )
					strcpy(av_servername,"EASE    ");
				else
				{
					av_server=appl_find("MAGXDESK");
					if ( av_server >= 0 )
						strcpy(av_servername,"MAGXDESK");
					else
					{
						av_server=appl_find("JINNEE  ");
						if ( av_server >= 0 )
							strcpy(av_servername,"JINNEE  ");
					} /* if */
				} /* if */
			} /* if */
		} /* if */
	} /* if */

	if ( av_server >= 0 )
	{
		memset(msgbuff, 0, (int)sizeof(msgbuff));
		msgbuff[0] = AV_PROTOKOLL;
		msgbuff[3] = (2|16);		/* VA_START, Quoting */
		strcpy ( global_av, "MANAGER " );
		*(char **) (msgbuff + 6) = global_av;

		send_message ( av_server );

	} /* if */

	return TRUE;

} /* init_av */

/*****************************************************************************/

GLOBAL WORD term_av ( VOID )
{
	if ( av_server >= 0 )
	{
		memset(msgbuff, 0, (int)sizeof(msgbuff));
		msgbuff[0] = AV_EXIT;
		msgbuff[3] = gl_apid;
		send_message ( av_server );
	} /* if  */

	if (global_av != NULL)
		Mfree ( global_av );

	return TRUE;
} /* term_av */
