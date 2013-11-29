/*
 * ftpp.c	01/03/97
 * J. Rojewski
 */

/*
	USER 
	PASS
	HELP
	TYPE {AN,I}
	LIST
	NLST
	CWD
	PWD
	MKD
	RMD
	MODE
	PASV
	RETR
	STOR
	STOU
	QUIT
	ALLOcate
 */

#define FTP_CONTROL_PORT 21
#define FTP_DATA_PORT 20
#define DEFAULT_FTP_SERVER "ftp.primenet.com"
/* #define FTP_OBUFF_SIZE 1024 */
#define FTP_OBUFF_SIZE 4096

int fpi =NO_CONNECTION;
int fdtp=NO_CONNECTION;
int pasv_failed;
char ftp_send_help,ftp_send_alloc,ftp_use_port;

int ftp_connect(char *ftp_server, int port)
{
	int rc;

	if (carrier_detect()>=0) {
		fpi = open_connection( ftp_server, port, 0 ); }
	if (fpi<0) {
		fprintf( log, "open_connection returns %s \n", get_err_text(fpi));
		browser->msg_status(0, fpi);
	} else {
		rc = ftp_receive_continuations( fpi, "dummy", FALSE );	/* get response from server */
	/*	rc = news_receive( fpi, "dummy", FALSE );	/* get response from server */
	/*	fputs( header, log ); */
	}
	pasv_failed=0;
	return(fpi);
}

int ftp_receive_continuations( int cn, char *file, int file_reqd )
{
	int rc;
	char match[5]="    ";

	do {
		rc = news_receive( cn, file, file_reqd );	/* get response from server */
		if (rc==4) { break; }
		if (match[0]==' ') { memcpy(match,header,3); }	/* copy 3 digits */
	} while (memcmp(match,header,4)!=0); /* until "nnn " */
	fflush( log );
	return(rc);
}

int ftp_listen( int cn )
{
	size_t timeout;
	int rc;

	timeout=clock()+max_to*CLK_TCK;		/* timeout */
	while ((rc=CNbyte_count( cn ))<0) {
		if (clock()>timeout) { rc=E_CNTIMEOUT; break; }
		if (handle_escape_events()==27) { rc=E_USERTIMEOUT;  break; }
	}
	return(rc);
}

int ftp_listen_connect(void)
{
	int rc;

	rc = TCP_open( 0, FTP_DATA_PORT, 0, FTP_OBUFF_SIZE );	/* open in 'Listen' mode on default port */
	return(rc);
}

int ftp_port_connect(void)
{
	uint32 host,h1,h2,h3,h4;
	int16 p1,p2;	/* port */
	int rc;
	CIB *cib;
	char buff[100];

	/* get local ip address */
	cib = CNgetinfo( fpi );
	if (cib!=NULL) { host = cib->lhost; }
	else { host = stik_cfg->client_ip; }

	h1 = host>>24 & 0x000000ff;
	h2 = host>>16 & 0x000000ff;
	h3 = host>>8  & 0x000000ff;
	h4 = host     & 0x000000ff;
	p1 = 4;		/* can't be zero? */
	p2 = FTP_DATA_PORT;

	sprintf( buff, "PORT %ld,%ld,%ld,%ld,%d,%d", h1, h2, h3, h4, p1, p2 );
/*	fprintf( log, "%s\n", buff );	fflush(log); */
 	rc = news_send_command( fpi, buff );
	header[0]='\0';
	rc = ftp_receive_continuations( fpi, "dummy", FALSE );
/*	if (header[0]!='\0') { fprintf( log, "PORT: %s\n", header ); fflush( log ); } */
/*	if (memcmp(header,"200",3)!=0) { return(E_REFUSE); }	/* can't open PORT */

	rc = TCP_open( 0, FTP_DATA_PORT+1024, 0, FTP_OBUFF_SIZE );	/* open in 'Listen' mode on default port */
/*	fprintf( log, "PORT connection: %d\n", rc ); fflush( log ); */
	return(rc);
}

int ftp_passive_connect(void)
{
	uint32 host,h1,h2,h3,h4;
	int16 port,p1,p2;
	int rc;
	CIB *cib;
	char *p;

	if (pasv_failed) { return(E_REFUSE); }
	rc = news_send_command( fpi, "PASV" );
	header[0]='\0';
	rc = ftp_receive_continuations( fpi, "dummy", FALSE );
	if (header[0]!='\0') { fprintf( log, "PASV: %s\n", header ); fflush( log ); }
	if (memcmp(header,"227",3)!=0) { pasv_failed++; return(E_REFUSE); }	/* can't open PASV */
	if (1) /*(rc==0)*/ {
		p = strtok( header, "(" );
		p = strtok( NULL, "\n" );
		sscanf( p, "%ld%*c%ld%*c%ld%*c%ld%*c%d%*c%d", &h1,&h2,&h3,&h4,&p1,&p2 );
	/*	fprintf( log, "host=%ld,%ld,%ld,%ld port=%d,%d\n", h1,h2,h3,h4,p1,p2 ); */
		host = (h1<<24) | (h2<<16) | (h3<<8) | h4;
		if (host==0) {	/* support for cahan's VAX */
			cib = CNgetinfo( fpi );
			if (cib!=NULL) { host = cib->rhost; }
		} 
		port = (p1<<8) | p2;
	/*	fprintf( log, "host=%p port=%x\n", host,port );	fflush( log ); */
		rc = TCP_open( host, port, 0, FTP_OBUFF_SIZE );
		return(rc);
	}
	return(E_CONNECTFAIL);
}

int ftp_quit(void)
{
	int rc;

	rc = news_send_command( fpi, "QUIT" );
	rc = ftp_receive_continuations( fpi, "dummy", FALSE );
	rc = (int16)TCP_close(fpi, 5);	/* close connection locally */
	fpi= NO_CONNECTION;
	return(rc);
}

int ftp_send_file(char *filename, char *command)
{
	int rc,state,x;
	size_t bytes,total=0,timeout;
	char buff[512];
	FILE *fid;
	int dtp=E_REFUSE;

	if (ftp_use_port!='Y') { dtp = ftp_passive_connect(); }
/*	if (dtp==E_REFUSE) { dtp = ftp_listen_connect(); } */
	if (dtp==E_REFUSE) { dtp = ftp_port_connect(); }
	if (dtp>=0) {
		rc= ftp_allocate(filename);
		rc= news_send_command( fpi, command );
/*		rc=CNbyte_count(dtp);
		fprintf( log, "Pre-Listen CNbyte_count returns %d, %s \n", rc, get_err_text(rc));
*/
		if (CNbyte_count( dtp )==E_LISTEN) {
			if ((state=ftp_listen( dtp ))>=0) { state = E_NORMAL; }
		} else {
			state = TCP_wait_state( dtp, TESTABLISH, 15 );
		}
		if (state==E_NORMAL) {
			rc = ftp_receive_continuations( fpi, "dummy", FALSE );
			fid = fopen( filename, "rb" );
			if (fid!=NULL) {
				while ((bytes=fread( buff, 1, 512, fid))>0) {
					timeout=clock()+max_to*CLK_TCK;	/* timeout */
					do {
						x = TCP_send( dtp, buff, (int16)bytes );
						if (x!=0) {
							if (clock()>timeout) {
								if (x==E_OBUFFULL) { bytes=-FTP_OBUFF_SIZE; }
								x=E_CNTIMEOUT;
							}
						}
						if (handle_escape_events()==27) { x=E_USERTIMEOUT; }
 
					/*	if (Bconstat(2)==-1 && (Bconin(2) & 0xFF)==27) { /* Esc key */
					/*		x=E_USERTIMEOUT; } */
					} while (x==E_OBUFFULL);	/* retry if 'Output Buffer full */
					total+=bytes;
					browser->msg_status(8, total);
					if (x<0) {
						fprintf( log, "TCP_send returns %s \n", get_err_text(x));
						browser->msg_status(0, x);
						break;
					}
				}
				fclose( fid );
			}
		} else {
			fprintf( log, "TCP_wait_state returns %s \n", get_err_text(state));
			rc=CNbyte_count(dtp);
			fprintf( log, "CNbyte_count returns %d, %s \n", rc, get_err_text(rc));
			rc = state;
		}
		TCP_close( dtp, 5 );	/* wait for connection to close */
	} else {
		fprintf( log, "open_connection returns %s \n", get_err_text(dtp));
		rc = dtp;
	}
	return(rc);
}

int ftp_receive_file(char *filename, char *command)
{
	int rc,state;
	int dtp=E_REFUSE;

	if (ftp_use_port!='Y') { dtp = ftp_passive_connect(); }
/*	if (dtp==E_REFUSE) { dtp = ftp_listen_connect(); } */
	if (dtp==E_REFUSE) { dtp = ftp_port_connect(); }
	if (dtp>=0) {
		rc = news_send_command( fpi, command );
/*		rc=CNbyte_count(dtp);
		fprintf( log, "Pre-Listen CNbyte_count returns %d, %s \n", rc, get_err_text(rc));
*/
		if (CNbyte_count( dtp )==E_LISTEN) {
			if ((state=ftp_listen( dtp ))>=0) {	state = E_NORMAL; }
		} else {
			state = TCP_wait_state( dtp, TESTABLISH, 15 );
		}
		if (state==E_NORMAL) {
			rc = ftp_receive_continuations( fpi, "dummy", FALSE );
			rc = news_receive( dtp, filename, 2 );
		} else {
			fprintf( log, "TCP_wait_state returns %s \n", get_err_text(state));
			rc=CNbyte_count(dtp);
			fprintf( log, "CNbyte_count returns %d, %s \n", rc, get_err_text(rc));
			rc = state;
		}
		TCP_close( dtp, 5 );	/* wait for connection to close */
	} else {
		fprintf( log, "open_connection returns %s \n", get_err_text(dtp));
		rc = dtp;
	}
	return(rc);
}

int ftp_list(char *filename)
{
	int rc;

	rc = ftp_receive_file( filename, "LIST" );
	return(rc);
}

int ftp_type(char *type)
{
	int rc;
	char command[80];

	sprintf( command, "TYPE %s", type );
	rc = news_send_command( fpi, command );
	rc = ftp_receive_continuations( fpi, "dummy", FALSE );
	return(rc);
}

int ftp_retrieve(char *filename, char *path)
{
	int rc;
	char command[200];

	sprintf( command, "RETR %s", filename );
	rc = ftp_receive_file( path, command );
	return(rc);
}

int ftp_store(char *localfile, char *remotefile)
{
	int rc;
	char command[200];

	sprintf( command, "STOR %s", remotefile );
	rc = ftp_send_file( localfile, command );
	return(rc);
}

int ftp_namelist(char *filename)
{
	int rc;

	rc = ftp_receive_file( filename, "NLST" );
	return(rc);
}

int ftp_allocate(char *filename)
{
	long fsize;
	int rc=0;
	char command[80];

	if (ftp_send_alloc=='Y') {
		fsize = filesize( filename );
		sprintf( command, "ALLO %ld", fsize );
		rc = news_send_command( fpi, command );
		rc = ftp_receive_continuations( fpi, "dummy", FALSE );
	}
	return(rc);
}

int ftp_cwd(char *directory)
{
	int rc;
	char command[80];

	sprintf( command, "CWD %s", directory );
	rc = news_send_command( fpi, command );
	rc = ftp_receive_continuations( fpi, "dummy", FALSE );
	return(rc);
}

int ftp_pwd(char *directory)
{
	int rc;
	char *p;

	directory[0]='\0';	/* initialize to enpty */
	rc = news_send_command( fpi, "PWD" );
	rc = ftp_receive_continuations( fpi, "dummy", FALSE );
	if (memcmp(header,"257",3)==0) {
		p=strtok( header, "\"" );
		p=strtok( NULL, "\"" );
		if (p!=NULL) {
			strcpy( directory, p );
		} else {
			fprintf( log, "non-standard directory\n");  fflush( log );
			strcpy( directory, header+4);
			p=strtok( directory, " " );		/* remove trailing */
			fprintf( log, "non-standard directory %s\n", directory);  fflush( log );
		}	
	}
	return(rc);
}

int ftp_mkd(char *directory)
{
	int rc;
	char command[80];

	sprintf( command, "MKD %s", directory );
	rc = news_send_command( fpi, command );
	rc = ftp_receive_continuations( fpi, "dummy", FALSE );
	return(rc);
}

int ftp_rmd(char *directory)
{
	int rc;
	char command[80];

	sprintf( command, "RMD %s", directory );
	rc = news_send_command( fpi, command );
	rc = ftp_receive_continuations( fpi, "dummy", FALSE );
	return(rc);
}

int ftp_rename(char *oldfile, char *newfile)
{
	int rc;
	char command[80];

	sprintf( command, "RNFR %s", oldfile );
	rc = news_send_command( fpi, command );
	rc = ftp_receive_continuations( fpi, "dummy", FALSE );
/*	if (memcmp(header,"257",3)==0) { */
	if (rc==0) {
		sprintf( command, "RNTO %s", newfile );
		rc = news_send_command( fpi, command );
		rc = ftp_receive_continuations( fpi, "dummy", FALSE );
	}
	return(rc);
}


int ftp_help(char *filename)
{
	int rc=0;

	if (ftp_send_help=='Y') {
		rc = news_send_command( fpi, "HELP" );
		rc = ftp_receive_continuations( fpi, "dummy", FALSE );
	}
	return(rc);
}

int ftp_delete(char *filename)
{
	int rc;
	char command[80];

	sprintf( command, "DELE %s", filename );
	rc = news_send_command( fpi, command );
	rc = ftp_receive_continuations( fpi, "dummy", FALSE );
	return(rc);
}

int ftp_user(char *userid)
{
	int rc;
	char command[80];

	sprintf( command, "USER %s", userid );
	rc = news_send_command( fpi, command );
	rc = ftp_receive_continuations( fpi, "dummy", FALSE );
	return(rc);
}

int ftp_pass(char *password)
{
	int rc;
	char command[80];

	sprintf( command, "PASS %s", password );
	rc = news_send_command( fpi, command );
	rc = ftp_receive_continuations( fpi, "dummy", FALSE );
	return(rc);
}


