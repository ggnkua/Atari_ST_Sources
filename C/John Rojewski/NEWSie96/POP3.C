/*
 *	pop3.c		Post Office Protocol
 *			Reference: RFC 1939
 *
 *	Created by:	John Rojewski 	08/13/96
 */

/*
	Commands:
	user - identify user
	pass - provide user password
	stat - determine if messages in mailbox
	list - list messages and sizes
	top  - list message headers only
	retr - retrieve selected message
	dele - delete selected message
	noop - nothing
	rset - reset session state
	quit - end of pop3 session
 */

/*
	Example of Usage:
	connect
	+OK Opening Service
	user abcd
	+OK
	pass password
	+OK
	stat
	+OK 3 125		( 3 messages, 125 bytes total )
	data
	retr 1
	+OK 120 octets		
	<message 1>
	.
	dele 1
	+OK message 1 deleted
	quit
	+OK Closing Service
 */

#define STANDARD_POP3_PORT 110
#define OK "+OK"
int pcn=NO_CONNECTION;		/* initial state, modem not connected */

int pop3_connect(char *pop3_server)
{
	int rc;

	if (carrier_detect()>=0) {
		pcn = open_connection( pop3_server, STANDARD_POP3_PORT, 0 ); }
	if (pcn<0) {
		fprintf( log, "open_connection returns %s \n", get_err_text(pcn));
		browser->msg_status(0, pcn);
	} else {
		rc = news_receive( pcn, "dummy", FALSE );	/* get response from server */
	}
	return(pcn);
}

int pop3_user(char *user_account)
{
	int x;
	char buff[80];

	sprintf( buff, "user %s", user_account ); 
	x = news_send_command( pcn, buff );
	x = news_receive( pcn, "dummy", FALSE );
	return(x);
}

int pop3_pass(char *password)
{
	int x;
	char buff[80];

	sprintf( buff, "pass %s", password ); 
	x = news_send_command( pcn, buff );
	x = news_receive( pcn, "dummy", FALSE );
	return(x);
}

int pop3_quit(void)
{
	int x;

	x = news_send_command( pcn, "quit" );
	x = news_receive( pcn, "dummy", FALSE );
	x = (int16)TCP_close( pcn, 5 );
	pcn=NO_CONNECTION;
	return(x);
}

int pop3_status(void)
{
	int x;

	x = news_send_command( pcn, "stat" );
	x = news_receive( pcn, "dummy", FALSE );
	return(x);
}

int pop3_list( int message, char *filename )
{
	int x;
	char buff[80];

	if (message==0) {
		x = news_send_command( pcn, "list" );
		x = news_receive( pcn, filename, TRUE );
	} else {
		sprintf( buff, "list %d", message ); 
		x = news_send_command( pcn, buff );
		x = news_receive( pcn, "dummy", FALSE );
	}
	return(x);
}

int pop3_retrieve( int message, char *filename )
{
	int x;
	char buff[80];

	sprintf( buff, "retr %d", message ); 
	x = news_send_command( pcn, buff );
	x = news_receive( pcn, filename, TRUE );
	return(x);
}

int pop3_top( int message, char *filename, int lines )
{
	int x;
	char buff[80];

	sprintf( buff, "top %d %d", message, lines ); 
	x = news_send_command( pcn, buff );
	x = news_receive( pcn, filename, TRUE );
	return(x);
}

int pop3_delete( int message )
{
	int x;
	char buff[80];

	sprintf( buff, "dele %d", message ); 
	x = news_send_command( pcn, buff );
	x = news_receive( pcn, "dummy", FALSE );
	return(x);
}

int pop3_reset(void)
{
	int x;

	x = news_send_command( pcn, "rset" );
	x = news_receive( pcn, "dummy", FALSE );
	return(x);
}

int pop3_noop(void)
{
	int x;

	x = news_send_command( pcn, "noop" );
	x = news_receive( pcn, "dummy", FALSE );
	return(x);
}


