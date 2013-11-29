/* Support IMAP4rev1, port 143.
 *
 * imap4.c	09/09/98
 * J. Rojewski
 */

/*
NOOP
LOGOUT
CAPABILITY

AUTHENTICATE
LOGIN <userid> <password>

SELECT <mailbox>
EXAMINE <mailbox>
CREATE <mailbox>
DELETE <mailbox>
SUBSCRIBE <mailbox>
UNSUBSCRIBE <mailbox>
APPEND <mailbox>
RENAME <oldmailbox> <newmailbox>
LIST
LSUB
STATUS <mailbox> (options)

CHECK
CLOSE
EXPUNGE
SEARCH
FETCH
STORE
COPY
UID
*/

#define IMAP_PORT 143
#define DEFAULT_IMAP_SERVER "imap.primenet.com"

int imapi = NO_CONNECTION;

int imap_connect(char *imap_server, int port)
{
	int rc;
	char server[80];

	if (port==0) { port = IMAP_PORT; }
	strcpy( server, imap_server );
	if (server[0]=='\0') { strcpy( server, DEFAULT_IMAP_SERVER ); }

	if (carrier_detect()>=0) { imapi = open_connection( server, port, 0 ); }
	if (imapi<0) {
		fprintf( log, "open_connection returns %s \n", get_err_text(imapi));
		browser->msg_status(0, imapi);
	} else {
	/*	rc = imap_receive_continuations( imapi, "dummy", FALSE, "*" );	/* get response from server */
		rc = news_receive( imapi, "dummy", FALSE );	/* get response from server */
		if (header[0]=='*') { imap_queue_unsolicited( header ); }
	/*	fputs( header, log ); */
	}
	return(imapi);
}

int imap_queue( int function, char *line )
{
	struct element {
		struct element *next;
		char line[80];
	};
	static struct element *queue=NULL;
	static struct element *deque=NULL;
	struct element *temp;
	int rc=0;
	long slen;
/*
	deque--> next text
		 next text
	queue--> null text
*/
	if (function==0) {	/* enqueue */
		if (temp=malloc( (size_t)strlen(line)+5 )) {
			temp->next  = NULL;
			strcpy( temp->line, line );
			if (queue) {
				queue->next = temp;	/* chain to new element */
				queue = temp;		/* move to new element */
			} else {
				queue = temp;	/* set enque pointer */
				deque = temp;	/* set deque pointer too */
			}
			rc++;
		}
	} else {	/* dequeue */
		line[0]='\0';	/* empty */
		if (deque) {
			slen=strlen(deque->line);
			strncpy( line, deque->line, function );	/* maximum size of buffer */
			if (queue==deque) { queue=NULL; }	/* will be released! */
			temp = deque;
			deque = temp->next;	/* point to next element */
			free( temp );		/* release this element */
			if (slen>function) { return(-1); }	/* truncated! */
			rc++;
		}
	}
	return(rc);
}

int imap_queue_unsolicited( char *line )
{
	int rc=0;

	fprintf( log, "%s\n", line ); fflush(log);
/*	rc=imap_queue( 0, line );	/* enqueue new element */
	return(rc);
}

int imap_deque_unsolicited( char *line, int max_line )
{
	int rc=0;

	if (max_line==0) { return(rc); }
/*	rc=imap_queue( max_line, line );	/* dequeue new element */
	if (rc) { fprintf( log, "%s\n", line ); }
	return(rc);
}

int imap_receive_continuations( int cn, char *file, int file_reqd, char *id )
{
	int rc;
	char match[8];

	sscanf( id, "%s", match );
	do {
		rc = news_receive( cn, file, file_reqd );	/* get response from server */
		if (rc==4) { break; }
		if (header[0]=='*') { imap_queue_unsolicited( header ); }
		if (header[0]=='-') { break; }
	} while (memcmp(match,id,4)!=0); /* until matching id */
	fflush( log );
	return(rc);
}

char *imap_next_id(void)
{
	static int id=0;
	static char prefix='A';
	static char tag[8];

	if (id==9999) { id=0; prefix++; }
	sprintf( tag, "%c%03d", prefix, id++ );
	return( tag );
}

int imap_login(char *userid, char *password)
{
	int rc;
	char command[80];

	sprintf( command, "%s LOGIN %s %s", imap_next_id(), userid, password );
	rc = news_send_command( imapi, command );
	rc = imap_receive_continuations( imapi, "dummy", FALSE, command );
	return(rc);
}

int imap_logout(void)
{
	int rc;
	char command[80];

	sprintf( command, "%s LOGOUT", imap_next_id());
	rc = news_send_command( imapi, command );
	rc = imap_receive_continuations( imapi, "dummy", FALSE, command );
	rc = (int16)TCP_close(imapi, 5);	/* close connection locally */
	imapi= NO_CONNECTION;
	return(rc);
}

int imap_noop(void)
{
	int rc;
	char command[80];

	sprintf( command, "%s NOOP", imap_next_id());
	rc = news_send_command( imapi, command );
	rc = imap_receive_continuations( imapi, "dummy", FALSE, command );
	return(rc);
}

int imap_capability(void)
{
	int rc;
	char command[80];

	sprintf( command, "%s CAPABILITY", imap_next_id());
	rc = news_send_command( imapi, command );
	rc = imap_receive_continuations( imapi, "dummy", FALSE, command );
	return(rc);
}

int imap_mailbox_command( char *cmd, char *mailbox )
{
	int rc;
	char command[80];

	sprintf( command, "%s %s %s", imap_next_id(), cmd, mailbox );
	rc = news_send_command( imapi, command );
	rc = imap_receive_continuations( imapi, "dummy", FALSE, command );
	return(rc);
}

int imap_select( char *mailbox )
{
	return( imap_mailbox_command( "SELECT", mailbox ));
}

int imap_examine( char *mailbox )
{
	return( imap_mailbox_command( "EXAMINE", mailbox ));
}

int imap_create( char *mailbox )
{
	return( imap_mailbox_command( "CREATE", mailbox ));
}

int imap_delete( char *mailbox )
{
	return( imap_mailbox_command( "DELETE", mailbox ));
}

int imap_subscribe( char *mailbox )
{
	return( imap_mailbox_command( "SUBSCRIBE", mailbox ));
}

int imap_unsubscribe( char *mailbox )
{
	return( imap_mailbox_command( "UNSUBSCRIBE", mailbox ));
}

int imap_append( char *mailbox )
{
	return( imap_mailbox_command( "APPEND", mailbox ));
}

/*
RENAME <oldmailbox> <newmailbox>
LIST
LSUB
STATUS <mailbox> (options)
*/

/* sample calling segment */
#if (0)
void try_imap4(void)
{
	char user_account[80];

	imap_connect( "", 0 );	/* connect to default server */
	if (imapi) {		/* connection successful? */
		imap_capability();
		if (get_password_dialog( user_password )) {
		/*	show_status( ErrMsg(EM_LogonValidate) ); */
			strcpy( user_account, prefs.account_name );
			if (user_account[0]=='\0') {
				strcpy( user_account, prefs.email_address );
				strtok( user_account, "@" );
			}
			imap_login( user_account, user_password );
			imap_select( "INBOX" );
			imap_noop();
			imap_logout();
			while (imap_deque_unsolicited( header, (int)sizeof(header) );
		}
	}
}
#endif


/* end of imap4.c */