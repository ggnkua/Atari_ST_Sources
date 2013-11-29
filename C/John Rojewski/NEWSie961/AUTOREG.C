/* Automatic NEWSie Registration - the manual method is too time-consuming
   Created: 04/22/98
   By: John Rojewski


   1. Read REGISTER.MBX looking for Unread messages
   2. Read REGISTER.TXT into memory
   3. Of unread messages that have Subject: Request NEWSie Registration
	a. Verify user has not already registered
	b. Generate reply and add to OUTBOX.MBX (Queued)
	c. update register array as necessary
   4. Unload updated REGISTER.TXT 
*/


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#define MAILBOX_SIZE 500
#define REGISTER_SIZE 500
#define REGISTRAR "rojewski@primenet.com (John Rojewski)"
#define VERSION "0.96"
#define mail_path "D:\\MAIL"
/* following mail_path is test ONLY - need to create new MAIL folder */
/* #define mail_path "D:\\LC\\MAIL" */

#define REGISTRATION_INFO "D:\\REGISTER.TXT"
#define DUPLICATE_INFO "D:\\REGDUP.TXT"
#define TODAY "10/26/99"
#define FMSIZE 128
#define FALSE 0


struct mbox {
	char status[5];
	char author[80];
	char author_email[50];
	char subject[50];
	char datetime[22];
	char filename[FMSIZE];
	long num_lines;
	char attachment;
};
struct mbox far mailbox[MAILBOX_SIZE];		/* define register mailbox */
int current_mail=-1;
int previous_mail=-1;
int maximum_mail=-1;
int next_mail_number=1;

struct reg {
	char index[5];
	char number[8];
	char user[50];
	char date[22];
	char characteristics[200];
	int referenced;
};
struct reg far registar[REGISTER_SIZE];		/* define register buffer */
int current_reg=-1;
int first_unreg=-1;
int maximum_reg=-1;

#define CONFIG_SIZE 800
char config[CONFIG_SIZE];
char reginfo[FMSIZE];


char *strtoka( char *s, int tok )
{
	static char *p;
	char *q;

	if (s!=NULL) { p=s; }	/* returns null strings vs null pointers */
	q=p;
	while (*p!=tok) {
		if (*p=='\0') { return(p); }	/* found end of string */
		p++;
	}
	*p='\0';	/* replace token with null char */
	p++;		/* next start point */
	return(q);	/* return start point */
}

void load_register(char *filename)
{
	FILE *fid;
	int c;
	char buff[200];

	first_unreg = -1;
	current_reg = -1;
	maximum_reg = -1;
	for (c=0;c<REGISTER_SIZE;c++) { registar[c].index[0] = '\0'; }

	fid = fopen( filename, "ra" );
	if (fid!=NULL) {
		printf( "Loading Register: %s\n", filename );
		for (c=0;c<REGISTER_SIZE;c++) {
			registar[c].referenced=0;
			if (fgets( buff, sizeof(buff), fid )!=NULL) {
				parse_register_header( c, buff);
				maximum_reg = c;
			}
		}
		fclose( fid );
	} else {
		printf( "Register File: %s not found\n", filename );
		exit(EXIT_FAILURE);	/* EXIT_FAILURE==-1 ? */
	}
}

int parse_register_header(int c, char *buff)
{
	char *index, *number, *user, *date, *characteristics;

	if (c<0) { return(0); }
	if (c>=REGISTER_SIZE) { return(0); }

	index = strtoka( buff, '\t' );
	number = strtoka( NULL, '\t' );
	user = strtoka( NULL, '\t' );
	date = strtoka( NULL, '\t' );
	characteristics = strtoka( NULL, '\n' );

	memset( &registar[c], 0, sizeof(struct reg) );
	strncpy( registar[c].index, index, 4 );
	strncpy( registar[c].number, number, 7 );
	strncpy( registar[c].user, user, 49 );
	strncpy( registar[c].date, date, 21 );
	strncpy( registar[c].characteristics, characteristics, 199 );

	if (registar[c].user[0]<=' ' && first_unreg<0) { first_unreg=c; }
	return( 1 );
}

void unload_register(char *filename)
{
	FILE *fid;
	int c;

	if (maximum_reg==-1) { return; }		/* nothing loaded */
	fid = fopen( filename, "wa" );
	if (fid!=NULL) {
		printf( "Unloading Register: %s\n", filename );
		for (c=0;c<REGISTER_SIZE;c++) {
			if (registar[c].index[0]!='\0') {
				fprintf( fid, "%s\t%s\t%-18s\t%s\t%s\n",
				registar[c].index, registar[c].number, registar[c].user,
				registar[c].date, registar[c].characteristics );
			}
		}
		fclose( fid );
	}
	maximum_reg=-1;			/* nothing loaded */
}

void load_mailbox(char *filename)
{
	FILE *fid;
	int c,mailnum;
	char buff[200];

	previous_mail = -1;
	current_mail = -1;
	maximum_mail = -1;
	for (c=0;c<MAILBOX_SIZE;c++) { mailbox[c].status[0] = '\0'; }

	fid = fopen( filename, "ra" );
	if (fid!=NULL) {
		printf( "Loading Mailbox: %s\n", filename );
		for (c=0;c<MAILBOX_SIZE;c++) {
			if (fgets( buff, sizeof(buff), fid )!=NULL) {
				mailnum = parse_mailbox_header( c, buff);
				maximum_mail = c;
			}
		}
		fclose( fid );
		next_mail_number = mailnum+1;
	} else {
		printf( "Mailbox: %s not found\n", filename );
		exit(EXIT_FAILURE);	/* EXIT_FAILURE==-1 ? */
	}
}

int parse_mailbox_header(int c, char *buff)
{
	char *status, *author, *author_email, *subject, *datetime;
	char *filename, *num_lines;
	char temp[FMSIZE],temp2[5];

	if (c<0) { return(0); }
	if (c>=MAILBOX_SIZE) { return(0); }

	status = strtoka( buff, '\t' );
	subject = strtoka( NULL, '\t' );
	author = strtoka( NULL, '\t' );
	author_email = strtoka( NULL, '\t' );
	datetime = strtoka( NULL, '\t' );
	filename = strtoka( NULL, '\t' );
	num_lines = strtoka( NULL, '\t' );	/* was \n */

	memset( &mailbox[c], 0, sizeof(struct mbox) );
	strncpy( mailbox[c].status, status, 4 );
	strncpy( mailbox[c].author, author, 79 );
	strncpy( mailbox[c].author_email, author_email, 49 );
	strncpy( mailbox[c].subject, subject, 49 );
	strncpy( mailbox[c].datetime, datetime, 21 );
	strncpy( mailbox[c].filename, filename, 127 );

	mailbox[c].num_lines = atol( num_lines );
	mailbox[c].attachment = ' ';
	stcgfn( temp, filename );		/* mailnnnn.txt format */
	memcpy( temp2, temp+4, 4 );
	temp2[4] = '\0';
/*	fprintf( log, "Mail: %s, %s, %s\n", filename, temp, temp2 ); */
	return( atoi(temp2) );
}

void unload_mailbox(char *filename)
{
	FILE *fid;
	int c;

	if (maximum_mail==-1) { return; }		/* nothing loaded */
	fid = fopen( filename, "wa" );
	if (fid!=NULL) {
		printf( "Unloading Mailbox: %s\n", filename );
		for (c=0;c<MAILBOX_SIZE;c++) {
			if (mailbox[c].status[0]!='\0') {
				fprintf( fid, "%s\t%s\t%s\t%s\t%s\t%s\t%ld\t%c\n",
				mailbox[c].status, mailbox[c].subject, mailbox[c].author,
				mailbox[c].author_email, mailbox[c].datetime,
				mailbox[c].filename, mailbox[c].num_lines, mailbox[c].attachment );
			}
		}
		fclose( fid );
	}
	maximum_mail=-1;			/* nothing loaded */
}

void strtrim( char *x )
{
	int len;

	len = (int)strlen(x)-1;
	if (len<0) { return; }
	while ( x[len]==' ' ) {
		x[len--]='\0';	/* truncate spaces */
		if (len<0) { break; }
	}
}

int user_registered( int c )
{
	int x,rc=0;
	char user[80],author[80],email[80];

	/* modify parameters for comparison, case in-sensitive, trim trailing spaces */
	strcpy( author, mailbox[c].author );
	strtrim( author );
	strcpy( email, mailbox[c].author_email );
	strtrim( email );
	for (x=0;x<maximum_reg+1;x++) {
		if (registar[x].index[0]=='\0') { break; }
		strcpy( user, registar[x].user );
		strtrim( user );
		if (strcmpi( user, author )==0) { rc=x; break; }
		if (strcmpi( user, email )==0) { rc=x; break; }
	}
	if (rc) { printf( "User %s already registered\n", registar[x].user ); }
	return(rc);
}

void build_config( int which )
{
	char system[20]="ST/Mega",aes[20]="Unknown",stack[20]="Unknown";
	char *p;

	if (p = strstr( config, "STiK = " )) {	/* "STiK = " */
		strcpy ( stack, "Found" );
		if (strstr(p, "Peter"))	{ strcpy( stack, "STinG" ); }
		if (strstr(p, "D.Ack"))	{ strcpy( stack, "STiK" ); }
		if (strstr(p, "Scott"))	{ strcpy( stack, "GlueSTiK" ); }
	}

	if (p = strstr( config, "AES = " )) {	/* "AES = " */
		sprintf( aes, "AES %4.4s", p+6);
		if (memcmp(p+6, "0399", 4)==0) { strcpy( aes, "MagiC" ); }
	}

	if (p = strstr( config, "_MCH = " )) {	/* "_MCH = " */
		if (strstr(p, "00010000")) { strcpy( system, "STe" ); }
		if (strstr(p, "00010010")) { strcpy( system, "MegaSTe" ); }
		if (strstr(p, "00020000")) { strcpy( system, "TT030" ); }
		if (strstr(p, "00030000")) { strcpy( system, "Falcon030" ); }
	}

	if (strstr( config, "MiNT" )) { strcat( aes, " MiNT" ); }

	sprintf( registar[which].characteristics, "%s %s %s",system, aes, stack );
}

void copy_configuration_info( FILE *fid, char *filename )
{
	FILE *fid2;
	char buff[200];
	int in_header=1;

	memset( config, 0, CONFIG_SIZE );	/* clear config info */
	fid2 = fopen( filename, "ra" );
	if (fid2!=NULL) {
		while (fgets(buff, sizeof(buff), fid2)!=NULL) {
			if (buff[0]=='\n') { in_header--; }
			if (in_header>0) { continue; }
			if (buff[0]=='.') { break; }
			if (buff[0]==' ') { buff[0]='>'; }	/* insert '>' */
			fputs( buff, fid );		/* copy config to reply */
			strcat( config, buff );		/* append to global config */
			if (in_header<0) { break; }	/* break if second empty line */
		}
		fclose( fid2 );
	}	
	fid2 = fopen( reginfo, "ra" );	/* copy registration/duplicate info */
	if (fid2!=NULL) {
		while (fgets( buff, sizeof(buff), fid2 )!=NULL) {
			fputs( buff, fid );
		}
		fclose( fid2 );
	}	
}

void build_registration_reply( int c, int reg_num, char *extra )
{
	char article[FMSIZE];
	char to[90],subject[50];
	FILE *fid;

	/* create register.tmp message with header and put into outbox */
	sprintf( article, "D:\\LC\\REGISTER.TMP" );
	if ((fid=fopen( article, "wa" ))!=NULL) {
		sprintf( to, "%s (%s)", mailbox[c].author_email, mailbox[c].author );
		sprintf( subject, "NEWSie Registration #%s %s", registar[reg_num].number, extra );
	
		fprintf( fid, "To: %s\n", to );
		fprintf( fid, "From: %s\n", REGISTRAR ); 
	/*	fprintf( fid, "Organization: %s\n", prefs.organization ); */
		fprintf( fid, "Subject: %s\n", subject );
		fprintf( fid, "X-Mailer: NEWSie Version %.4s (Atari)\n", VERSION );
	/*	fprintf( fid, "\n" ); */
		copy_configuration_info( fid, mailbox[c].filename );
		fclose( fid );
		add_to_outbox(article, subject, to, FALSE);
	}
}

int get_unique_filename(int start, char *prefix, char *path )
{
	FILE *fid;
	char filename[FMSIZE];
	int c;

	for (c=start;;c++) {
		sprintf( filename, "%s\\%s%04d.TXT", path, prefix, c );
		fid = fopen( filename, "ra" );
		if (fid==NULL) { break; }	/* file file does not exist... */
		fclose( fid );
	}
	return(c);
}

int copy_file(char *newfile, char *filename)
{
	FILE *fid,*fid2;
	char  buff[400];
	int lines=0;

	fid = fopen( filename, "ra" );
	if (fid!=NULL) { 
		fid2 = fopen( newfile, "wa" );
		if (fid2!=NULL) { 
			while (fgets( buff, sizeof(buff), fid )!=NULL) {
				fputs( buff, fid2 );
				lines++;
			}
			fclose( fid2 );
		}
		fclose( fid );
	}
	return(lines);
}

void simplify_author(char *both, char *author, char *email )
{
	int rc;
	char *p,*t;

	/* support the 3 forms:
		email@address (Name)
		Name <email@address>
		email@address
	*/
	rc = (int)stcpm( both, "(?*)", &t );
	if (rc) {
		sprintf( author, "%.*s", rc-2,t+1 );
		t[-1] = '\0';
		sprintf( email,  "%-.39s", both );	
	} else {
		p = strtok( both, "<" );
		p = strtok( NULL, ">" );
		sprintf( author,  "%-.39s", both );
		if (p==NULL) { strcpy( email, author); }	/* duplicate */
			else { sprintf( email,  "%-.39s", p ); }
	}
}

void add_to_outbox(char *filename, char *subject, char *author, int result)
{
	FILE *fid;
	char dirname[FMSIZE],newfile[FMSIZE];
	char author_name[80],author_email[80];
	char temp[40],datetime[30],status[]=" Q ";
	char buff[200];
	struct tm *tp;
	time_t t;
	int lines;

	next_mail_number = get_unique_filename(next_mail_number, "REGISTER\\MAIL", mail_path );
	sprintf( newfile, "%s\\REGISTER\\MAIL%04d.TXT", mail_path, next_mail_number++ );
	lines = copy_file(newfile, filename);

	time(&t);
	tp = localtime(&t);
	strcpy( temp, asctime(tp) );
	strtok( temp, "\n" );
	sprintf( datetime, "%-.21s", temp+4 );

	simplify_author( author, author_name, author_email );
	if (author_name[0]=='\0') { strcpy( author_name, "( )" ); }
	sprintf( buff, "%s\t%s\t%s\t%s\t%s\t%s\t%d\n",
		status, subject, author_name, author_email, datetime,
		newfile, lines );

	sprintf( dirname, "%s\\%s", mail_path, "OUTBOX.MBX" );
	fid = fopen( dirname, "aa" );		/* append to outbox */
	if (fid!=NULL) {
		fputs( buff, fid );
		fclose( fid );
	}
}

void process_registration_request(void)
{
	int c,r;

	for (c=0;c<maximum_mail+1;c++) {
		if (mailbox[c].status[0]=='U') {	/* unread message? */
			if (memcmp(mailbox[c].subject,"Request NEWSie Registration #",28)==0) {
			/*	printf( "Found candidate: %s\n", mailbox[c].author ); */
				if ((r=user_registered( c ))!=0) {	/* already registered? */
				/*	if (strcmp( registar[r].date, TODAY )!=0) {	/* but not Today */ 
					if (registar[r].referenced) {	/* but not referenced yet */ 
		 				strcpy( mailbox[c].status, "  * " );
					} else {
						strcpy( reginfo, DUPLICATE_INFO );
						build_registration_reply( c, r, "(Duplicate)" );
						build_config(r);	/* update configuration */
						registar[r].referenced++;
		 				strcpy( mailbox[c].status, " R* " );
					}
				} else {				/* new registration */
				/*	strcpy( config, "not empty" );	/* test ONLY */
					strcpy( reginfo, REGISTRATION_INFO );
					build_registration_reply( c, first_unreg, "" );
					strcpy( registar[first_unreg].user, mailbox[c].author );
					strcpy( registar[first_unreg].date, TODAY );
					build_config(first_unreg);
					registar[first_unreg].referenced++;
					first_unreg++;
					strcpy( mailbox[c].status, " R* " );
				}
			}
		}
	}
}

int main(int argc, char *argv[])
{
	char register_box[]="D:\\MAIL\\REGISTER.MBX";
	char register_txt[]="D:\\LC\\REGISTER.TXT";

	load_register( register_txt );
	load_mailbox( register_box);

	process_registration_request();

	unload_mailbox( register_box );
/*	unload_register( register_txt ); */

/*	unload_mailbox( "D:\\LC\\REGISTER.MBZ" );	/* test ONLY */
	unload_register( "D:\\LC\\REGISTER.TXZ" );	/* test ONLY */

	return EXIT_SUCCESS;	/* EXIT_SUCCESS==0 ? */
}

/* end of autoreg.c */
