/*
	example to show the message pipe to TC_HELP accessory
	(c) 1990 by Borland International
*/

#include <aes.h>

#include "helpmsg.h"

#define NULL (void *)0L

/*
	call the Help DA
*/
static void Help( int acc_id, int ap_id, char *KeyWord )
{
	int msg_buff[8], top;

	msg_buff[0] = AC_HELP;				/* magic message number 	*/
	msg_buff[1] = ap_id;				/* my own id				*/
	msg_buff[2] = 0;					/* no more than 16 bytes	*/
	*(char **)&msg_buff[3] = KeyWord;	/* the KeyWord				*/
	appl_write( acc_id, 16, msg_buff );  /* write message			*/

	/* wait for reply */
	do
	{
		evnt_mesag( msg_buff );
	}while( msg_buff[0] != AC_REPLY );
	
	/* wait until DA has window closed */ 	
	do
	{
		wind_get( 0, WF_TOP, &top );
	} while( top );	
}

int main( int argc, char **argv )
{
	int acc_id, ap_id;
	
	ap_id = appl_init();
	graf_mouse( ARROW, NULL );

	/* which id has our DA */
	acc_id = appl_find( AC_NAME	);
	if( acc_id < 0 )
	{	/* non, therefore no help available */
		form_alert( 1, "[3][|" AC_NAME "|not found.][ OK ]" );
	}
	else
	{
		if( argc >= 2 )							/* keyword given ?	*/
			Help( acc_id, ap_id, argv[1] );		/* call DA			*/
		else									/* error alert		*/
			form_alert( 1, "[1][|No Keyword given][ OK ]" );	
	}
	appl_exit();
	return( 0 );
}