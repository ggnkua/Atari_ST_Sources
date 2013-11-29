/*
 * NNTP.C
 * Created by: John Rojewski 		06/27/96
 *
 *	An attempt to create a news client 
 */

/* Commands 
	article	- combination of head and body
	body	- returns the body of a particular article
	group	- makes the specified newsgroup the "current" group
	head	- returns the header lines of one particular article
	help	- lists available commands
	last	- retrive last article in newsgroup
	list	- lists available newsgroups (WARNING: this can be huge)
	listgroup - returns newsgroups that match selection string
	mode	- establish a client "reader" mode
	newsgroups - new newsgroups since specified date
	next 	- retrive the next article in a newsgroup
	post	- post a response to a message
	quit	- terminates the connection
	xhdr	- summary of un-read articles
	xover	- returns overview of all un-read articles in a group
 */

/* Formats - Commands and example responses - not case sensitive
	help
	100 Legal Commands
	<commands>
	.	{period is end of response}

	list [active]
	215 Newsgroups in form "group low high"
	<newsgroups>
	.	{period is end of response}

	group <groupname>
	211 <number> <first> <last> <groupname>

	head <article>
	221 <article> <<article internal name>> head
	<lines of header info>
	.	{period is end of response}

	body <article>
	222 <article> <<article internal name>> body
	<lines of article text
	.	{period is end of response>

	article <article>
	220 <article> <<article internal name>> article
	<lines of header followed by body>
	.	{period is end of response}
	
	newsgroups <date> <time> GMT
	231 New newsgroups follow.
	<newsgroups>
	.	{period is end of response}

	quit
	205	{connection is closed by server}
 */

/*
 * Routines
 */
#define STANDARD_NEWS_SERVER	"news.primenet.com"
#define STANDARD_NEWS_PORT	119

int max_to = 30;	/* default maximum timeout */
int char_to = 15; 	/* default timeout from last character */
int kick = 20;		/* default time before issuing CNkick() */
int ncn=NO_CONNECTION;		/* initial state, modem not connected */
char log_cmd,log_data,log_resp,log_mask_pswds;	/* logging options from prefs */

/* connect to the newsserver */
int	news_connect( char *news_server )
{
	int rc;

	if (carrier_detect()>=0) {
		ncn=open_connection( news_server, STANDARD_NEWS_PORT, 0); }
	if (ncn<0) {
		fprintf( log, "open_connection returns %s \n", get_err_text(ncn));
		browser->msg_status(0, ncn);
	} else {
	/*	rc = news_send_command( ncn, "mode reader" ); */
		rc = news_receive( ncn, "dummy", FALSE );	/* get response from server */
	}
	return(ncn);
}

/* send data to the server on connection cn */
int	news_send(int cn, char *data)
{
	int x;
	char data_string[300];

	x=news_discard( cn );		/* discard residual data */
	if (x<E_NORMAL) {
		browser->msg_status(0, x);
		if (x==E_BADHANDLE&&cn==ncn) { ncn= NO_CONNECTION; }
		return(x);
	}
	sprintf( data_string, "%s\r\n", data );
	do {
		x = TCP_send( cn, data_string, (int16) strlen(data_string) );
	} while (x==E_OBUFFULL);	/* retry if 'Output Buffer full */
	browser->msg_status(5, 0);
	if (x<E_NORMAL) {
		fprintf( log, "TCP_send returns %s \n", get_err_text(x));
		fflush( log );
		browser->msg_status(0, x);
	}
	return(x);
}

/* send a command line to the server on connection cn */
int	news_send_command(int cn, char *command)
{
	int rc;
	char temp[80];

	if (log_cmd=='Y') {
		stccpy(temp,command,75);
		if (log_mask_pswds=='Y') {
			if ((memcmp(temp,"pass",4)==0)||(memcmp(temp,"PASS",4)==0)) {
				for (rc=5;rc<80;rc++) {
					if (temp[rc]=='\0') break;
					temp[rc]='*';
				}
			}
			if (memcmp(temp,"authinfo pass",13)==0) {
				for (rc=14;rc<80;rc++) {
					if (temp[rc]=='\0') break;
					temp[rc]='*';
				}
			}
		}
		fprintf( log, "-> %s\n", temp );  fflush(log);
	}
	rc = news_send( cn, command );
	return(rc);
}

/* discard extraneous data after timeout */
int news_discard( int cn )
{
	int16 bytes_available,x;
	int sbuf=sizeof(buffer);

/*	fprintf( log, "in news_discard(%d)\n", cn );  fflush(log); */
	while ((bytes_available=CNbyte_count(cn))>0) {

		if (handle_escape_events()==27) break;
/*
		if (Bconstat(2)==-1 && (Bconin(2) & 0xFF)==27) {
			break;
		}
*/
		if (bytes_available>sbuf) { bytes_available=sbuf; }
		CNget_block(cn, buffer, bytes_available);
	}
	if (bytes_available<0) {
		x=bytes_available;
		fprintf( log, "CNbyte_count(%d) returns (%d) %s \n", cn, x, get_err_text(x));
		fflush( log );
	}
/*	fprintf( log, "completed news_discard(%d)\n", cn );  fflush(log); */
	return(bytes_available);
}

/* error has occurred when writing a file to disk from the modem */
void file_write_error(long rc)
{
	char temp[80];

	strcpy( temp, "[1][" );
	if (rc<0) {
		sprintf( temp+4, ErrMsg(EM_FileWrErr), rc );
	} else {
		strcat( temp, ErrMsg(EM_InsuffDisk) );
	}
	strcat( temp, "][ OK ]" );
	form_alert( 1, temp );	/* issue error alert */
}

/* wait for the response from the newsserver */
int news_receive(int cn, char *file, int file_reqd)
{
	/* copied from http_get in CABCOVL.C  */
	int16 x, bytes_available, eof=0;
	long bytes_read=0,rc;
	int return_code=0;
	int file_handle, status=0, header_pos=0;
	time_t timeout,kicker,total;
	int bug=0;
	int sbuf=sizeof(buffer);

	if (file_reqd) {
		file_handle=(int) Fcreate(file, 0);
		if (bug) {
			fprintf( log, "news_receive - opening file = %d\n", file_handle );
			fflush( log );
		}
		if (file_handle<0) {
			#ifdef ERR_MSGS
				printf("Couldn't create %s!\n", file);
			#endif
			return(1);
		}
	}
	total=clock();					/* total time in routine */
	timeout=clock()+max_to*CLK_TCK;	/* timeout */
	kicker=clock()+kick*CLK_TCK;		/* conversation kicker */
	if (file_reqd) {
		browser->msg_status(2,0); /* Getting data... */
	}
	if (file_reqd==2) { status=2; }

	while (eof==0) {
		bytes_available=CNbyte_count(cn);
		/* printf("received %d bytes \n", (long)bytes_available ); */

		if (handle_escape_events()==27) { eof=4; }
		/*
		if (Bconstat(2)==-1 && (Bconin(2) & 0xFF)==27) { eof=4;	}
		*/
		if (clock()>timeout) {
			#ifdef MDEBUG
				printf("Timeout!\n");
			#endif
			eof=2;
		} else if (clock()>kicker) {
			#ifdef MDEBUG
				printf("Kick Connection!\n");
			#endif
			CNkick(cn);
			kicker=clock()+kick*CLK_TCK;	/* conversation kicker */
		} else if (bytes_available==E_EOF) {
			#ifdef MDEBUG
				printf("EOF!\n");
			#endif
			eof=1;
		} else if (bytes_available<E_NODATA) {
			#ifdef ERR_MSGS
				printf("CNbyte_count() returns: %s\n", get_err_text(bytes_available));
			#endif
			eof=3;
		} else if (bytes_available>0) {
			timeout=clock()+char_to*CLK_TCK;	/* timeout after last char */
			kicker=clock()+kick*CLK_TCK;		/* conversation kicker */
			if (status==2) {
				if (bytes_available>sbuf) { bytes_available=sbuf; }
				if (CNget_block(cn, buffer, bytes_available)>=E_NODATA) {
					rc = Fwrite(file_handle, bytes_available, &buffer);
					if (rc!=bytes_available) { 	/* didn't write everything */
						file_write_error(rc);
						Fclose(file_handle);
						return(1);
					}
					bytes_read+=bytes_available;
					if (bug) {
						fprintf( log, "received %d bytes, total %ld\n",
							bytes_available , bytes_read);
						fflush( log );
					} else { browser->msg_status(2, bytes_read); }

				/* look for period (.) on a line by itself */
					if (strncmp(&buffer[bytes_available-5], "\r\n.\r\n", 5)==0 ||
					    strncmp(&buffer[bytes_available-5], "\n\r.\n\r", 5)==0 ||
					    strncmp(&buffer[bytes_available-3], "\r.\r", 3)==0 ||
					    strncmp(&buffer[bytes_available-3], "\n.\n", 3)==0)
					eof=1;
					if (bytes_read==3 &&
					    strncmp(&buffer[bytes_available-3], ".\r\n", 3)==0)
					eof=1;
				} else {
					#ifdef ERR_MSGS
						printf("Error in CNget_block()!\n");
					#endif
					eof=3;
				}
			} else {
				x = CNget_char(cn);
				if (x<E_NODATA) {
					#ifdef ERR_MSGS
						printf("CNget_char() returns: %s\n", get_err_text(x));
					#endif
					eof=3;
				} else
					header[header_pos++]=(char) x;
			}
			/* only an empty line and response line in NNTP responses */
			/* when status = 0, drop until valid non-control, when = 1, store in header */
			if (status==0) {
				if (strncmp(&header[header_pos-1], " ", 1)<0) {
					header_pos = 0;
				} else { status++;}
			}
			if (status==1) {
				if (strncmp(&header[header_pos-2], "\r\n", 2)==0 ||
				    strncmp(&header[header_pos-2], "\n\r", 2)==0) {
				/*	strncmp(&header[header_pos-1], "\r", 1)==0 ||
				    strncmp(&header[header_pos-1], "\n", 1)==0) { */
					header[header_pos-2]=0;
					if (log_resp=='Y') { fprintf( log, "%s\n", header ); fflush(log); }
					#ifdef MDEBUG
						printf("Header: %s\n", header );
						printf("End of header.\n");
					#endif
					if (!file_reqd) { eof=1; } else { status++; }
					if (memcmp(header,"423",3)==0) { eof=1; }
				} else if (header_pos>2000) {
					rc = Fwrite(file_handle, header_pos, header);
					if (rc!=header_pos) { 	/* didn't write everything */
						file_write_error(rc);
						Fclose(file_handle);
						return(1);
					}
					status++;
				}
			}
		}
	}
	#ifdef MDEBUG
	printf("EOF= %d \n", (long)eof );
	#endif

	if (eof>1) {	/* timeout or worse*/
	/*	x = (int16)TCP_close(cn, 2);
		if (x < 0) {
			#ifdef MDEBUG
				printf("TCP_close() returns: %s\n", get_err_text(x));
			#endif
		} 
	*/
		if (bug) {
			fprintf( log, "news_receive - error - eof = %d\n", eof );
			fflush( log );
		}	
		if (file_reqd) {
		#ifdef MDEBUG
			printf("Fclose returns %i\n", Fclose(file_handle));
		#else
			/**** I might get a bug here! ****/
			if((x=(int16)Fclose(file_handle))<0) {
				#ifdef ERR_MSGS
					printf("Error with Fclose! (%i)\n", x);
				#endif
			}
		#endif
			if (bug) {
				fprintf( log, "news_receive - error - closing file = %d\n", x );
				fflush( log );
			}
		}
		if (eof==3) { eof=bytes_available; }  /* return negative value */
		return(eof);
	}	

	if (file_reqd) {
		if (log_data=='Y') {
			total=clock()-total;	/* total time in clock ticks */
			if (total) {
				fprintf( log, "Transfer Rate = %ld cps\n", (bytes_read*CLK_TCK)/total ); fflush(log);
			}
		}
		#ifdef MDEBUG
			printf("Fclose returns %d\n", Fclose(file_handle));
		#else
			if((x=(int16)Fclose(file_handle))<0)	browser->msg_error(x);
		#endif
		if (bug) {
			fprintf( log, "news_receive - good - closing file = %d\n", x );
			fflush( log );
		}
	}
	#ifdef MDEBUG
		printf("Hit a key.\n");
		Bconin(2);
	#endif
	return(return_code);	/* return(0)     if getting data was successful,	 */
        					/* return(errno) if it fails, return an error number */
}

/*
 *   Test the newsreader primitives
 */

/*
void test_news()
{
	long rc;
	char code[10], number[10], first[10], last[10], group[40];
	long f,l;

	rc = news_connect(STANDARD_NEWS_SERVER);
	rc = news_help();
	rc = news_group( "comp.protocols.tcp-ip" );
	sscanf( header, "%s %s %s %s %s", code, number, first, last, group );
	f = atol( first );
	l = atol( last );
	rc = news_xover( "D:\\XOVER.TXT", f, l );
	rc = news_article( f ); 
	rc = news_article( l );
 	rc = news_list( "D:\\FULLGRP.TXT" );
	rc = news_quit();
}
*/

int news_quit()
{
	int rc;

	rc = news_send_command( ncn, "quit" );
	rc = news_receive( ncn, "dummy", FALSE );
	rc = (int16)TCP_close(ncn, 2);	/* close connection locally */
	ncn= NO_CONNECTION;
	return(rc);
}

int news_list(char *filename)
{
	int rc;

	rc = news_send_command( ncn, "list" );
	rc = news_receive( ncn, filename, TRUE );
	return(rc);
}

int news_help()
{
	int rc;

	rc = news_send_command( ncn, "help" );
	rc = news_receive( ncn, "D:\\HELP.TXT", TRUE );
	return(rc);
}

int news_group(char *groupname )
{
	int rc;
	char command[80];

	sprintf( command, "group %s",groupname );
	rc = news_send_command( ncn, command );
	rc = news_receive( ncn, "dummy", FALSE );
	if (memcmp(header, "480", 3)==0) { rc = news_authenticate( command ); }
	if (memcmp(header, "450", 3)==0) { rc = news_authenticate_simple( command ); }
	return(rc);
}

int news_authenticate(char *prev_cmd )
{
	int rc;
	char command[80],userid[80],password[80];

	rc = get_news_auth( 1, userid, password );
 	sprintf( command, "authinfo user %s", userid );
	rc = news_send_command( ncn, command );
	rc = news_receive( ncn, "dummy", FALSE );
	if (memcmp(header, "381", 3)==0) {
		rc = get_news_auth( 2, userid, password );
		sprintf( command, "authinfo pass %s", password );
		rc = news_send_command( ncn, command );
		rc = news_receive( ncn, "dummy", FALSE );
	}
	if (memcmp(header, "281", 3)==0) {
		rc = news_send_command( ncn, prev_cmd );
		rc = news_receive( ncn, "dummy", FALSE );
	}
	return(rc);
}

int news_authenticate_simple(char *prev_cmd )
{
	int rc;
	char command[80],userid[80],password[80];

 	strcpy( command, "authinfo simple" );
	rc = news_send_command( ncn, command );
	rc = news_receive( ncn, "dummy", FALSE );
	if (memcmp(header, "350", 3)==0) {
		rc = get_news_auth( 3, userid, password );
		sprintf( command, "%s %s", userid, password );
		rc = news_send( ncn, command );		/* was news_send_command() */
		rc = news_receive( ncn, "dummy", FALSE );
	}
	if (memcmp(header, "250", 3)==0) {
		rc = news_send_command( ncn, prev_cmd );
		rc = news_receive( ncn, "dummy", FALSE );
	}
	return(rc);
}

int news_article(long article_number, char *path )
{
	int rc;
	char article[10];
	char command[80];

	sprintf( article, "%ld", article_number );
	sprintf( command, "article %s", article );
	#ifdef MDEBUG
	fprintf( log, "FileName is: %s\n", path );
	#endif
	rc = news_send_command( ncn, command );
	rc = news_receive( ncn,  path, TRUE );
	return(rc);
}

int news_xover( char *path, long first, long last )
{
	int rc;
	char command[80];

	sprintf( command, "xover %ld-%ld", first, last );
	rc = news_send_command( ncn, command );
	rc = news_receive( ncn, path, TRUE );
	return(rc);
}

int news_reader()
{
	int rc;

	rc = news_send_command( ncn, "mode reader" );
	rc = news_receive( ncn, "dummy", FALSE );
	return(rc);
}

int news_post(char *filename)
{
	int rc;
	FILE *fid;
	char buff[500],*b;

	fid = fopen(filename, "ra" );
	rc = news_send_command( ncn, "post" );
	rc = news_receive( ncn, "dummy", FALSE );
	if (memcmp(header, "480", 3)==0) { rc = news_authenticate( "post" ); }
	if (memcmp(header, "450", 3)==0) { rc = news_authenticate_simple( "post" ); }
	rc = atoi(header);
	if (rc==340) {
		while (fgets( buff, sizeof(buff), fid)!=NULL) {	
			if (buff[0]=='\n') buff[0]='\0';	/* handle empty line */
			b = strtok( buff, "\r\n" );		/* remove cr and/or newline */
			rc = news_send( ncn, buff );	/* send article */
		}
		if (strcmp( buff, ".\r\n")!=0) {	/* add '.' if needed */
			rc = news_send( ncn, "." );
		}
		rc = news_receive( ncn, "dummy", FALSE );
	/*	if (atol(header)==240) { } /* good post */
	}
	fclose( fid );
	return(rc);
}

int news_newgroups(char *filename, char *the_date, char *the_time )
{
	char command[80];
	int rc;

	sprintf( command, "newgroups %s %s GMT", the_date, the_time );
	rc = news_send_command( ncn, command );
	rc = news_receive( ncn, filename, TRUE );
	return(rc);
}