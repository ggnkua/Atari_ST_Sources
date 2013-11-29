/*
 *	smtp.c		Simple Mail Transfer Protocol
 *			Reference: RFC 821
 *
 *	Created by:	John Rojewski 	07/08/96
 */

/*
	Commands:
	helo - initiate and verify endpoints
	mail - initiate mail transfer
	rcpt - define message receivers
	data - subject and text
	rset - cancel transfer
	noop - nothing
	quit - end of mail session
 */

/*
	Example of Usage:
	connect
	220 Opening Service
	helo [nn.nn.nn.nn]
	250 OK
	mail from:<user@domain>
	250 OK
	rcpt to:<user@domain>
	250 OK
	data
	354
	<subject and data lines>
	.
	250 OK
	quit
	221 Closing Service
 */

#define STANDARD_MAIL_PORT 25
int mcn=NO_CONNECTION;		/* initial state, modem not connected */

int mail_connect(char *mail_server)
{
	int rc;

	if (carrier_detect()>=0) {
		mcn = open_connection( mail_server, STANDARD_MAIL_PORT, 0 ); }
	if (mcn<0) {
		fprintf( log, "open_connection returns %s \n", get_err_text(mcn));
		browser->msg_status(0, mcn);
	} else {
		rc = news_receive( mcn, "dummy", FALSE );	/* get response from server */
	}
	return(mcn);
}

int mail_hello()
{
	int x;
	char buff[50];

	sprintf( buff, "helo [%s]", dotted_quad(stik_cfg->client_ip) ); 
	x = news_send_command( mcn, buff );
	x = news_receive( mcn, "dummy", FALSE );
	return(x);
}

int mail_from(char *from)
{
	int x;
	char buff[80];

	sprintf( buff, "mail from:<%s>", from ); 
	x = news_send_command( mcn, buff );
	x = news_receive( mcn, "dummy", FALSE );
	return(x);
}

int mail_quit()
{
	int x;

	x = news_send_command( mcn, "quit" );
	x = news_receive( mcn, "dummy", FALSE );
	x = (int16)TCP_close( mcn, 5 );
	mcn=NO_CONNECTION;
	return(x);
}

int mail_to(char *to)
{
	int x;
	char buff[80];

	sprintf( buff, "rcpt to:<%s>", to ); 
	x = news_send_command( mcn, buff );
	x = news_receive( mcn, "dummy", FALSE );
	return(x);
}

int mail_data(char *filename)
{
	FILE *fid;
	char buff[1025],*b;
	int x;

	fid = fopen( filename, "ra" );
	x = news_send_command( mcn, "data" );
	x = news_receive( mcn, "dummy", FALSE );
	x = atoi(header);
	if (x==354) {
		while (fgets(buff, sizeof(buff), fid)!=NULL) {
			if (buff[0]=='\n') buff[0]='\0';	/* handle empty line */
			b = strtok( buff, "\r\n" );	/* remove cr and/or newline */
		/*	do { */
				x = news_send( mcn, buff );
		/*	} while (x==E_OBUFFULL); */	/* retry if 'Output Buffer full */
		}
		if (strcmp( buff, ".\r\n")!=0) {	/* add '.' if needed */
			x = news_send( mcn, "." );
		}
		x = news_receive( mcn, "dummy", FALSE );
		x = atoi(header);
	}
	fclose( fid );
	return(x);
}

int mail_reset()
{
	int x;

	x = news_send_command( mcn, "rset" );
	x = news_receive( mcn, "dummy", FALSE );
	return(x);
}

int mail_noop()
{
	int x;

	x = news_send_command( mcn, "noop" );
	x = news_receive( mcn, "dummy", FALSE );
	return(x);
}


