/*
 * mailbox.c - build mailbox from mailxxxx.txt files
 *
 * Written: 06/18/97		John Rojewski
 * Modified: 11/15/97	Support mailboxes larger than 100 
 * Modified: 08/12/98	Support mail directories
 * Modified: 08/21/98	Support outbox mail w/o status, reverse to/from
 * Modified: 10/11/99	Remove possible tabs in parse_mail_header()
 */
 
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <osbind.h>
#include <dos.h>
#include <aes.h>
#include <vdi.h>

/* global variables */
#define MAILBOX_SIZE 100
#define MAX_MAILBOX 9
/* later change to 9 */

short screenx,screeny,screenw,screenh;
int finished=0;
int handle;

long count,mcount,fcount,dcount;
char boxes[3000],*pointers[200];
char dirs[3000],*dpointers[300];
int *dmpointers[300];
char dmail[10000];
char email[10000];

struct mhdr {
	char subject[80];
	char from[80];
	char to[80];
	char reply_to[80];
	char datetime[40];
	char status[5];
} mail_hdr;

char program_path[FMSIZE];
char mail_path[FMSIZE]="D:\\MAIL";
char resource[FMSIZE];


void initialize(void)
{
	int c;

	if (appl_init()<0)
		exit(EXIT_FAILURE);
	getcd( 0, program_path );
	for (c=0;c<10000;c++) { email[c]='\0'; }
	wind_get(DESK,WF_WORKXYWH,&screenx,&screeny,&screenw,&screenh);
	graf_mouse(ARROW,NULL);
}

void deinitialize(void)
{
/*	menu_bar(menu_ptr,0); */
	appl_exit();
}

/* Ask the user to find the Mail directory to be examined */
int get_mail_path(void)
{
	char path[FMSIZE],dirname[FMSIZE],select[FMSIZE],temp[80];
	int button;

	strcpy( select, "*.*" );
	sprintf( dirname, "%s\\%s", program_path, select );
	fsel_exinput( dirname, select, &button, "Locate MAIL Directory" );
	if (button) {
		stcgfp( path, dirname );
		strcpy( mail_path, path );
	/*	sprintf( mail_path, "%s\\%s", path, select ); */
		sprintf( temp, "[0][Your Mail directory is:|%s][OK|Cancel]", mail_path );
		if (form_alert( 1, temp )==1) {	chdir( path ); } else { button=0; }
	}
	return(button);
}

void beep(void)
{
	printf( "%c", '\x07' );
}

/* Find and store all of the directories, and index them in the dpointers array */
long get_directories(void)
{
	char temp[80];
	long count,c,rcnt=0;

	count = getfnl("*", dirs, sizeof(dirs), FA_SUBDIR );
	if (count > 0) {
		if (strbpl(dpointers,300,dirs)!=count) {
			fprintf(stderr, "Too many mailbox directories\n");
			deinitialize();
			exit(1);
		}
		strsrt( dpointers, count );
		for (c=0;c<count;c++) {
			if (dpointers[c][0]=='.') { continue; }
			rcnt++;
		/*	sprintf( temp, "[0][Checking Directory |%s][OK]", dpointers[c] ); */
		/*	form_alert( 1, temp ); */
		}
		sprintf( temp, "[0][You have %ld Mail Directories][OK]", rcnt );
		form_alert( 1, temp );
	} else {
		if (_OSERR) poserr( "DIRS");
		else fprintf(stderr, "Too many mailbox directories\n");
		deinitialize();
		exit(1);
	}
	return(count);
}

/* Find and store all of the mailboxes, and index them in the pointers array */
long get_mailboxes(void)
{
	char temp[80];
	long count;

	count = getfnl("*.MBX", boxes, sizeof(boxes), 0 );
	if (count > 0) {
		if (strbpl(pointers,200,boxes)!=count) {
			fprintf(stderr, "Too many mailbox files\n");
			deinitialize();
			exit(1);
		}
		sprintf( temp, "[0][You have %ld Mailboxes][OK]", count );
		form_alert( 1, temp );
		strsrt( pointers, count );
	} else {
		if (_OSERR) poserr( "FILES");
		else fprintf(stderr, "Too many mailbox files\n");
		deinitialize();
		exit(1);
	}
	return(count);
}

/* For a email filename, attempt to find the email number in the dmpointers list(s) */
int check_mailbox_directories(char *filename, int index)
{
	int c,d;

	for (c=0;c<dcount;c++) {
		if (dpointers[c][0]=='.') { continue; }
		if (strstr(filename, dpointers[c])!=NULL) {
		/*	beep(); */
		/*	index = get_mail_index( filename ); */
			if (dmpointers[c]!=NULL) {
				for (d=1;d<=dmpointers[c][0];d++) {
					if (dmpointers[c][d]==index) {
						dmpointers[c][d]=0;
					/*	beep(); */
						return(1);
					}
				}
			}
			break;
		}
	}
	return(0);
}

/* Read each mailbox line, and mark the email filename number as being assigned */
void load_mailbox(char *filename)
{
	FILE *fid;
	int  mailnum;
	char buff[200],mailname[FMSIZE];

	graf_mouse( BUSY_BEE, NULL );

	fid = fopen( filename, "ra" );
	if (fid!=NULL) {
	/*	fprintf( log, "Loading Mailbox: %s\n", filename ); */
	/*	for (c=0;c<MAILBOX_SIZE;c++) { */
		while (fgets( buff, sizeof(buff), fid )!=NULL) {
			mailnum = parse_mailbox_header( buff, mailname );
			if (!check_mailbox_directories(mailname, mailnum)) {	/* check directory */
				if (email[mailnum]=='T') {	/* if marked, reset it */
					email[mailnum]='\0';
				}
			}
		}
		fclose( fid );
	}
	graf_mouse( ARROW, NULL );
}

/* strtok parsing option to returning a NULL string instead of a NULL pointer */
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

/* Return the numeric (nnnn) part of the filename (mailnnnn.txt) */
int get_mail_index( char *filename )
{
	char temp[FNSIZE],temp2[5];

	stcgfn( temp, filename );		/* mailnnnn.txt format */
	memcpy( temp2, temp+4, 4 );
	temp2[4] = '\0';
	return( atoi(temp2) );
}

/* For each mailbox line, we need to determine the email filename, to count/match it */
int parse_mailbox_header( char *buff, char *mailname )
{
	char *status, *author, *author_email, *subject, *datetime;
	char *filename, *num_lines;

	status = strtoka( buff, '\t' );
	subject = strtoka( NULL, '\t' );
	author = strtoka( NULL, '\t' );
	author_email = strtoka( NULL, '\t' );
	datetime = strtoka( NULL, '\t' );
	filename = strtoka( NULL, '\t' );
	num_lines = strtoka( NULL, '\n' );
	strcpy( mailname, filename );

	return(get_mail_index( filename ));
}

/* Count and remember the number of email messages in the Root mail directory */
long get_mail(void)
{
	struct FILEINFO info;
	int found=0,index;
	char temp[80];

	if (!dfind(&info,"mail*.txt",0)) {
		do {
			index = get_mail_index( info.name );
			email[index]='T';
			found++;
		} while (!dnext(&info));
	}
	sprintf( temp, "[0][You have %d Mail messages][OK]", found );
	form_alert( 1, temp );
	return(found);
}

/* Count and remember the number of email messages in each directory and a total */
long get_directory_mail(void)
{
	int c,d,index;
	long count=0,mail_cnt=0;
	char temp[FMSIZE];
	char **dmptr;

	for (c=0;c<dcount;c++) {	/* for each directory */
		dmpointers[c] = NULL;
		if (dpointers[c][0]=='.') { continue; }
		chdir( dpointers[c] );
		count = getfnl("mail*.txt", dmail, sizeof(dmail), 0 );
	/*	sprintf( temp, "[0][Directory %s has|%ld messages][OK]", dpointers[c], count ); */
	/*	form_alert( 1, temp ); */
		if (count > 0) {
			dmpointers[c] = calloc( count+1, sizeof(int) );
			dmpointers[c][0] = (int)count;
			dmptr = calloc( count+1, sizeof(size_t) );
			if (strbpl(dmptr,count+1,dmail)==count) {
				for (d=0;d<count;d++) {
					index = get_mail_index( dmptr[d] );
					dmpointers[c][d+1] = index;
				}
			}
			free( dmptr );
			mail_cnt += count;
		}
		chdir( mail_path );
	}
	sprintf( temp, "[0][You have %ld Directory messages][OK]", mail_cnt );
	form_alert( 1, temp );
	return(mail_cnt);
}

/* Produce count of email messages in a directory that are not assigned to a mailbox */
int check_free_directory_mail(void)
{
	int c,d,found=0;
	char temp[80];

	for (c=0;c<dcount;c++) {
		if (dmpointers[c]!=NULL) {
			for (d=1;d<=dmpointers[c][0];d++) {
				if (dmpointers[c][d]!=0) { found++; }
			}
		}
	}
	sprintf( temp, "[0][You have %d unassigned|Directory messages][OK]", found );
	form_alert( 1, temp );
	return( found ); 	/* debug only */
/*	return( 0 ); */
}

/* Produce a count of the number of email messages that are not assigned to a mailbox */
int check_free_mail(void)
{
	int found=0,c;
	char temp[80];

	for (c=0;c<10000;c++) { if (email[c]=='T') { found++; } }
	found += check_free_directory_mail();
	sprintf( temp, "[0][You have %d |unassigned Mail messages][OK]", found );
	form_alert( 1, temp );
	return( found );
}

/* We have found all the emails, now find which ones are assigned to a mailbox */
void check_mailboxes(void)
{
	int c;
	char temp[80];

	for (c=0;c<count;c++) {
		sprintf( temp, "[0][Checking Mailbox |%s][OK]", pointers[c] );
		form_alert( 1, temp );
		load_mailbox( pointers[c] );
	}
}

/* translate contents of string 'text' in string 'from' to character 'to' */
/* usage */
/*	strtran( mailbox[c].subject, "\t", ' ' );	/* translate tabs to spaces */
char * strtran( char *text, char *from, char to)
{
	char *p;
	while( p=strpbrk( text, from ) ) { *p = to; }
	return( text );
}

/* Parse the header lines in an email, and put data into the mail_hdr structure */
void parse_mail_header( char *filename )
{
	FILE *fid;
	size_t index;
	char field[512],entry[512],line[512],*dt;
	struct FILEINFO info;
	char ftime[8];

	strcpy( mail_hdr.subject, "<no subject>" );		/* initialize */
	mail_hdr.from[0]='\0';
	mail_hdr.to[0]='\0';
	mail_hdr.reply_to[0]='\0';
	mail_hdr.datetime[0]='\0';
/*	strcpy(mail_hdr.status,"U  ");	/* status may be empty */
	strcpy(mail_hdr.status," S ");	/* empty status, default to sent */

	fid = fopen( filename, "ra" );
	if (fid!=NULL) {
		while (fgets( line, sizeof(line), fid )!=NULL) {
			if (memcmp( line, "\n", 1 )==0) { break; }
			strtok( line, "\n" );		/* remove linefeed */
			/* Copy all bytes up to and not including the ":" into field[] */
			index=strcspn(line, ":");
			if (index>0) {
				strncpy(field, line, index);
				field[index]=0;
				strcpy(entry, &line[index+2]);	/* Copy the rest into entry[] */
				strtran( entry, "\t", ' ' );	/* translate all tabs to spaces */
				#ifdef MDEBUG
					printf("%s: %s\n", field, entry);
				#endif
				if (strcmpi("Subject", field)==0)
					strcpy(mail_hdr.subject, entry);
				else if (strcmpi("From", field)==0)
					strcpy(mail_hdr.from, entry);
				else if (strcmpi("To", field)==0)
					strcpy(mail_hdr.to, entry);
				else if (strcmpi("Reply-to", field)==0)
					strcpy(mail_hdr.reply_to, entry);
				else if (strcmpi("Date", field)==0) {
					dt = strpbrk( entry, "123456789" );
					strcpy(mail_hdr.datetime, dt); }
				else if (strcmpi("Status", field)==0)
					strcpy(mail_hdr.status, entry);
			}
		}
		fclose( fid );
	}
	if (strcmp(mail_hdr.status," S ")==0) {	/* replace from w/To or Reply-to */
		if (mail_hdr.to[0]!='\0') { strcpy(mail_hdr.from, mail_hdr.to); }
		if (mail_hdr.reply_to[0]!='\0') { strcpy(mail_hdr.from, mail_hdr.reply_to); }
	}
	if (mail_hdr.datetime[0]=='\0') {
		if (!dfind(&info,filename,0)) {	/* if file exists */
			if (info.time!=-1) {
				ftime[0]=(info.time>>9)&127;
				ftime[1]=(info.time>>5)&15;
				ftime[2]=info.time&31;
				stpdate( mail_hdr.datetime, 7, ftime );	/* dd MMM yyyy */
				strlwr( mail_hdr.datetime+4 );	/* dd Mmm yyyy */
			}
		}
	}
}

/* Format the author and email address for a mailbox line */
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

/* Count the lines in an email */
long count_lines( char *filename )
{
	FILE *fid;
	char buff[1000];
	int x;
	long count=0;
	fpos_t pos;

	fid = fopen( filename, "ra" );
	if (fid!=NULL) {		/* if file exists... */
		x = fseek( fid, 0, SEEK_END );
		if (x!=0) { return(0); }
		x = fgetpos( fid, &pos );
		if (x!=0) { return(0); }
	/*	fprintf( log, "Size of %s is %ld\n", filename, pos ); */
		if (pos>200000) {	/* 200k or more, take a guess */
			count = pos/40;
		} else {
			x = fseek( fid, 0, SEEK_SET );
			while (fgets( buff, sizeof( buff), fid )!=NULL) { count++; }
			fclose( fid );
		}
	}
	return(count);
}

/* Format a mailbox line for the unassigned email */
void append_email(FILE *fid, int c, char *the_path)
{
	char filepath[FMSIZE];
	char author_name[60],author_email[60];

	sprintf( filepath, "%s\\mail%04d.txt", the_path, c );
	parse_mail_header( filepath );
	simplify_author( mail_hdr.from, author_name, author_email );
/*	fprintf( fid, "%s\t%s\t%s\t%s\t%s\t%s\t%d\n",
		mail_hdr.status, mail_hdr.subject, author_name, 
		author_email, "Jan 01 1997",
		filepath, 0 ); */
	fprintf( fid, "%s\t%-.49s\t%s\t%s\t%-.21s\t%s\t%ld\n",
		mail_hdr.status, mail_hdr.subject, author_name, 
		author_email, mail_hdr.datetime,
		filepath, count_lines( filepath ) );
}

/* For directories, find the unassigned emails (with mailnnnn.txt number in dmpointers[][]) */
void build_directory_mailbox(FILE *fid, int count)
{
	int c,d;
	char temp[FMSIZE];

	for (c=0;c<dcount;c++) {
		sprintf( temp, "%s\\%s", mail_path, dpointers[c] );
		if (dmpointers[c]!=NULL) {
			for (d=1;d<=dmpointers[c][0];d++) {
				if (dmpointers[c][d]!=0) {
					append_email( fid, dmpointers[c][d], temp );
					dmpointers[c][d]=0;	/* this one's done */
					fcount--;
					if (++count>=MAILBOX_SIZE) { return; }
				}
			}
			free( dmpointers[c] ); dmpointers[c]=NULL;
		}
	}
}

/* When we have found unassigned emails, we create new RECOVERn.MBX mailboxes */
void build_new_mailbox(void)
{
	int c,count=0;
	static int box=0;
	FILE *fid;
	char mboxpath[FMSIZE],temp[80];

	if (box>MAX_MAILBOX) {
		fprintf(stderr, "Too many mail messages\n");
		deinitialize();
		exit(1);
	}
	sprintf( mboxpath, "%s\\RECOVER%d.MBX", mail_path, box++ );
	sprintf( temp, "[0][Creating Mailbox |%s][OK]", mboxpath );
	form_alert( 1, temp );

	fid = fopen( mboxpath, "aa" );
	if (fid!=NULL) {
		graf_mouse( BUSY_BEE, NULL );
		for (c=0;c<10000;c++) {		/* for the 'regular' mail files */
			if (email[c]=='T') {
				append_email( fid, c, mail_path );
				email[c]='\0';
				fcount--;
				if (++count>=MAILBOX_SIZE) { break; }
			}		
		}
		if (count<MAILBOX_SIZE) {	/* for the directory mail files */
			build_directory_mailbox( fid, count );
		}
		fclose( fid );
		graf_mouse( ARROW, NULL );
	}
}

/* Everything happens from here to find any unassigned email messages, 
	and create new mailbox(s) if required */
int main(void)
{
	initialize();
	if (get_mail_path()) {
		count = get_mailboxes();
		dcount = get_directories();
		mcount = get_mail();
		mcount += get_directory_mail();
		check_mailboxes();
		fcount = check_free_mail();
		while (fcount>0) { build_new_mailbox(); }
	}
	deinitialize();
	return EXIT_SUCCESS;
}

/* end of mailbox.c */