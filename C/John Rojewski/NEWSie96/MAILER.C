/*
 * mailer.c
 * Written by: John Rojewski	08/25/96
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <aes.h>
#include <vdi.h>
#include <osbind.h>
#include <time.h>
#include <process.h>
#include <unistd.h>		/* posix chdir */
#include <dos.h>
#include <cookie.h>
#include <sys\types.h>
#include <sys\stat.h>

#include "newsie.h"
#include "protocol.h"
#include "global.h"

#define VERSION "0.96  Dec  3, 1999"
#define ErrMsg(a) (char *)em[a].ob_spec
#define OK "+OK"
#define MAILTEST "mailtest.txt"
#define NICKNAME "nickname.txt"
#define SERVERMBX "server.mbx"
#define ATTACHMENT '@'

#define Touch_On(x) dlog[x].ob_flags|=TOUCHEXIT
#define Touch_Off(x) dlog[x].ob_flags&=~TOUCHEXIT
#define Button_Disable(x) dlog[x].ob_state|=DISABLED
#define Button_Enable(x) dlog[x].ob_state&=~DISABLED

char *strtoka( char *s, int tok );		/* prototype */
long count_lines( char *filename );		/* prototype */
int expand_mailbox(int required); 		/* prototype */
int mail_selective(void);				/* prototype */
void mail_retrieve_delete_all( char x );	/* prototype */

int popup_works(int rc);				/* prototype from NEWSAES.C */
int info_line( int wx, char *info );	/* prototype from NEWSAES.C */
int use_status( int wx );				/* prototype in NEWSAES.C */
#define status_window() use_status(-1)
void initialize_attached_menu_block( MENU *menu );	/* prototype in NEWSAES.C */

char * buffer_killfile(int which, char *buffer);	/* prototype */
#define unload_killfile() buffer_killfile(0, NULL)

int far handle_dialog(OBJECT *dlog,int editnum);	/* prototype from NEWSAES.C */
void far get_tedinfo(OBJECT *tree, int obj, char *dest);	/* prototype from NEWSAES.C */
void far set_tedinfo(OBJECT *tree, int obj, char *source);	/* prototype from NEWSAES.C */


void CAB_internet_mail_client( char *parameter )
{
	char email[80],*p,*s;
	OBJECT *dlog;

	strcpy( email, parameter+7 );	/* skip "mailto:" */
	strtoka( email, '?' );			/* locate possible subject */
	s = strtoka( NULL, '=' );
	p = strtoka( NULL, 0 );		/* after 'subject =' */
	rsrc_gaddr(R_TREE,Mail_Message,&dlog);
	set_tedinfo( dlog, MM_To, email );
	set_tedinfo( dlog, MM_Subject, p );
	prefs.connect_startup='N';		/* no news required */
	prefs.subscribe_startup='N';	/* don't open newsgroup window */
}

void CAB_internet_mail_client_part2(void)
{
	char path[FMSIZE];

	handle_redraw_event();
	sprintf( path, "%s\\%s", prefs.work_path, MAILTEST );
	Mail_Message_dialog(3, path );
}

void browser_mailto( char *parameter )
{
	char email[80],*p,*s,path[FMSIZE];
	OBJECT *dlog;

	strcpy( email, parameter+7 );	/* skip "mailto:" */
	strtoka( email, '?' );			/* locate possible subject */
	s = strtoka( NULL, '=' );
	p = strtoka( NULL, 0 );		/* after 'subject =' */
	rsrc_gaddr(R_TREE,Mail_Message,&dlog);
	set_tedinfo( dlog, MM_To, email );
	set_tedinfo( dlog, MM_Subject, p );
	handle_redraw_event();
	sprintf( path, "%s\\%s", prefs.work_path, MAILTEST );
	Mail_Message_dialog(3, path );
}

int get_password_dialog( char *user_password )
{
	OBJECT *dlog;

	if (prefs.use_saved_password=='Y') {
		strcpy( user_password, prefs.password );
		return(1);
	}
	rsrc_gaddr(R_TREE,Email_Password,&dlog);
	set_tedinfo( dlog, EM_Password, user_password );
	if (handle_dialog(dlog, EM_Password)==EM_OK) {
		get_tedinfo( dlog, EM_Password, user_password );
		return(1);
	} else { return(0); }
}

void close_pop_connection(void)
{
	int x;

	if (pcn>=0) {
		show_status( ErrMsg(EM_CloseConnect) );
		x = pop3_quit();
		hide_status();
		pcn=-1;
	}
}

void get_yymmdd( char *yymmdd )
{
	time_t timer;
	struct tm *t;

	timer=time(NULL);
	t=localtime(&timer);
/*	if (t->tm_year>=100) { t->tm_year-=100; } */
/*	sprintf( yymmdd, "%02d%02d%02d", t->tm_mon+1, t->tm_mday, t->tm_year ); */
	sprintf( yymmdd, "%04d%02d%02d", t->tm_year+1900, t->tm_mon+1, t->tm_mday );
/*	fprintf( log, "Date: %s\n", yymmdd ); */
}

int check_mail(void)
{
	int x,num=0;
	char user_account[80];
	char temp[50];
	long size;

	if (pcn<0) {
		if (STiK>0) {
			sprintf( temp, ErrMsg(EM_ConnectTo), prefs.pop_server );
			show_status( temp );
			x = pop3_connect( prefs.pop_server );
		}
	}
	if (pcn>=0) {
		if (get_password_dialog( user_password )) {
			show_status( ErrMsg(EM_LogonValidate) );
			strcpy( user_account, prefs.account_name );
			if (user_account[0]=='\0') {
				strcpy( user_account, prefs.email_address );
				strtok( user_account, "@" );
			}
			x = pop3_user( user_account );
			if (strcmp( strtok(header, " "), OK )==0) {	
				x = pop3_pass( user_password );
				if (strcmp( strtok(header, " "), OK )==0) {	
					x = pop3_status();
					sscanf( header, "%s %d %ld", temp, &num, &size );
					sprintf( temp, ErrMsg(EM_YouHaveMsgs), num );
					status_text( temp );
					if (num>0) { if (!open_helper_url( "GOTMAIL.AVR" )) beep(); }
				/*	if (num>0) { beep(); } */
				} else { status_text( ErrMsg(EM_PasswordRej) ); }
			} else { status_text( ErrMsg(EM_UserReject) ); }
		} else { status_text( ErrMsg(EM_NoPassword) ); }
	} else { status_text( ErrMsg(EM_NoConnect) ); }
	evnt_timer( 1000, 0 );		/* wait 1 second */
	hide_status();
	if (prefs.send_queued_at_check=='Y') {
		send_queued_messages();
	}
	return(num);
}

void get_mail(int num)
{
	int c,get,dummy,shift,sel=0;
	int *received;
	char inbox[FMSIZE];

	if (num==0) { return; }
	if (num<0)  { num = abs(num); sel++; }	/* indicate selective retrieval */
	if (pcn<0)  {
		num = check_mail();
		if (num==0) {			/* if no messages to receive */
			close_pop_connection();
			return;
		}
	}
	if (pcn>=0) {
		unload_mailbox( current_mailbox );
		sprintf( inbox, "%s\\%s", prefs.mail_path, "inbox.mbx" );
		c = (int16)count_lines( inbox );
		c += num;
		expand_mailbox( c );	/* expand mailbox to fit */

		received = calloc( MAILBOX_SIZE, sizeof( int ) );
		get=num;	/* initialize get to prevent Full status display */
		if (received==NULL) {
			c=MAILBOX_SIZE*(int16)sizeof( int );
			fprintf( log, "Unable to allocate Mail Received: %d %ld %d\n", MAILBOX_SIZE, sizeof(int), c );
			show_warning( ErrMsg(EM_UnableAlloc) );	/* Unable to Allocate... */
			evnt_timer( 1000, 0 );			/* wait 1 second */
		}
		if (received!=NULL) {
			graf_mkstate(&dummy,&dummy,&dummy,&shift);
			if ((shift&3)!=0||sel) {	/* select mode or shift key pressed */
				get = retrieve_selected(num, received);
				sprintf( inbox, "%s %s", ErrMsg(EM_Mailbox), prefs.pop_server );
			} else {
				get = retrieve_all(num, received, inbox);
				strcpy( inbox, ErrMsg(EM_MailInBox) );
			}
			if (prefs.delete_mail_from_server=='Y') {
				show_warning( ErrMsg(EM_DeleteMail) );
				for (c=1;c<get+1;c++) {
				/*	if (received[c]==0) { pop3_delete( c ); } */
					if (received[c]==0) { if (pop3_delete( c )==4) { break; } } /* escape from delete */
				}
			}
			free( received );
		}
		if (get<num) {
			show_warning( ErrMsg(EM_InBoxFull) );	/* InBox is Full... */
			status_text( ErrMsg(EM_MoreMail) );	/* More Mail on Server */
			evnt_timer( 2000, 0 );			/* wait 2 seconds */
		}
		close_pop_connection();
		open_mailbox( inbox, current_mailbox );
	}
}

void validate_dir( char *root, char *thedir, char *dir_path )
{
	struct FILEINFO info;

	if (prefs.mail_directories!='Y') {
		strcpy( dir_path, root );
		return;
	}
	sprintf( dir_path, "%s\\%s", root, thedir );
	if (dfind( &info, dir_path, FA_SUBDIR )) {	/* if dir does not exist */
		if (mkdir( dir_path, S_IWRITE|S_IREAD )) {	/* if cannot make dir */
			strcpy( dir_path, root );
		}
	}
}

int retrieve_all(int num, int *received, char *thebox)
{
	int c,room,get;
	int dummy,alt;
	char filename[FMSIZE],temp[80];
	char mail_dir[FMSIZE],yymmdd[10];

/*	sprintf( filename, "%s\\%s", prefs.mail_path, "inbox.mbx" ); */
	load_mailbox( thebox );
	room = MAILBOX_SIZE-1-maximum_mail;		/* room in inbox for this many */
	get = num;
	if (room<num) { get = room; }  
	get_yymmdd( yymmdd );
	validate_dir( prefs.mail_path, yymmdd, mail_dir );
	for (c=0;c<get+1;c++) { received[c]=1; }	/* initialize to not delete */
	for (c=1;c<get+1;c++) {
		sprintf( temp, ErrMsg(EM_RetrieveMail), c );
		show_status( temp );
		next_mail_number = get_unique_filename(next_mail_number, "mail", mail_dir );
		sprintf( filename, "%s\\mail%04d.txt", mail_dir, next_mail_number++ );

	/*	next_mail_number = get_unique_filename(next_mail_number, "mail", prefs.mail_path ); */
	/*	sprintf( filename, "%s\\mail%04d.txt", prefs.mail_path, next_mail_number++ ); */
		received[c] = pop3_retrieve( c, filename );
		if (received[c]!=0) {	/* if there was a timeout, escape, etc. */
			if (received[c]==1) { break; } /* file write error, eject */
			if (received[c]==4) { break; } /* escape from retrieve loop */
			graf_mkstate( &dummy, &dummy, &dummy, &alt );
		/*	fprintf( log, "Mail override = %d\n", alt ); */
			if (alt==10) {		/* if only alt and left shift keys pressed */
				received[c] = 0;	/* override failsafe, delete anyway */
			}
		}
		parse_mail_header( filename );
		receive_mail_automation( filename );
		if (mail_hdr.subject[0]!='\0') { add_mail_message( ++maximum_mail, filename ); }
	}
	unload_killfile();
	return(get);
}

int retrieve_selected(int num, int *received)
{
	int c,room,get,rc;
	long bytes;
	char filename[FMSIZE],temp[200];

	sprintf( current_mailbox, "%s\\%s", prefs.mail_path, SERVERMBX );
/*	fprintf( log, "Selected Mail Retrieve: %s\n", current_mailbox ); */
	for (c=0;c<MAILBOX_SIZE;c++) { mailbox[c].status[0] = '\0'; }
	previous_mail = -1;
	current_mail = -1;
	maximum_mail = -1;
	/*	load_mailbox( filename ); */
	room = MAILBOX_SIZE-1-maximum_mail;		/* room in inbox for this many */
	get = num;
	if (room<num) { get = room; }  
	for (c=0;c<get+1;c++) { received[c]=1; }	/* initialize to not delete */
	for (c=1;c<get+1;c++) {
		sprintf( temp, ErrMsg(EM_RetrieveMail), c );
		show_status( temp );
		sprintf( filename, "%s\\mailtemp.txt", prefs.mail_path );
		rc = pop3_top( c, filename, 0 );
		if (rc==1) { break; } /* file write error, eject */
	/*	received[c] = 1;	/* do not delete */
		sscanf( header, "%s %ld", temp, &bytes );	/* get email size */
		parse_mail_header( filename );
	/*	receive_mail_automation( filename ); */
		add_mail_message( ++maximum_mail, " " );
		mailbox[maximum_mail].num_lines = bytes;	/* size in bytes */
	/*	format_mailbox_line( c-1, temp ); */
	/*	fprintf( log, "%s\n", temp ); */
	}
	windows[6].num_lines=maximum_mail+1;
	windows[6].line_no=0;
	windows[6].bar_index = Tool_MailSelect;	/* use Select Toolbar */ 
	return(get);
}

int retrieve_one_message( int c, char *filename )
{
	int rc;
	char temp[80];
	char mail_dir[FMSIZE],yymmdd[10];

	get_yymmdd( yymmdd );
	validate_dir( prefs.mail_path, yymmdd, mail_dir );
	sprintf( temp, ErrMsg(EM_RetrieveMail), c );
	show_status( temp );
	next_mail_number = get_unique_filename(next_mail_number, "mail", mail_dir );
	sprintf( filename, "%s\\mail%04d.TXT", mail_dir, next_mail_number++ );

	rc = pop3_retrieve( c, filename );
	return( rc );
}

void mailbox_selective_retrieve(void)
{
	int *receive,c,num,mm,ret=0,del=0,rc;
	char temp[FMSIZE],filename[FMSIZE],tx;

	receive = calloc( maximum_mail+5, sizeof(int) );
	if (receive) {
		for (c=0;c<MAILBOX_SIZE;c++) {
			if (mailbox[c].status[1]=='D') { receive[c+1] = 1; del++; };
			if (mailbox[c].status[1]=='R') { receive[c+1] = 2; ret++; };
		}
		if (del+ret) {		/* anything to delete or retrieve? */
		/*	fprintf( log, "Retrieving %d and Deleting %d messages\n", ret, del ); */
		/*	fprintf( log, "maximum_mail is %d\n", maximum_mail ); */
			mm = maximum_mail+1;	/* for later use */
			if (ret) {	/* anything to retrieve, load Inbox */
				sprintf( temp, "%s\\%s", prefs.mail_path, "inbox.mbx" );
				load_mailbox( temp );	/* resets maximum_mail */
			}

			use_status( 6 );	/* use mailbox info line for status */
			tx=prefs.send_queued_at_check;	/* don't check for queued mail */
			prefs.send_queued_at_check='N';
			num = check_mail();
			prefs.send_queued_at_check=tx;
			use_status( 6 );	/* use mailbox info line for status */

			if (pcn>=0) {		/* if connected to mail server */
			/*	fprintf( log, "Mailbox is %s\n", current_mailbox ); */
			/*	fprintf( log, "Connected to mail server\n" ); */
				for (c=1;c<=mm;c++) {
				/*	fprintf( log, "receive[%d] is %d\n", c, receive[c] ); */
					if (receive[c]==1) {	/* delete */
					/*	fprintf( log, "Deleting mail %d\n", c ); */
						pop3_delete( c );
					}
					if (receive[c]==2) {	/* retrieve */
					/*	fprintf( log, "Retrieving mail %d, %s\n", c, filename ); */
						rc = retrieve_one_message( c, filename );
						if (rc==0) {	/* if not timeout, etc. */
							if (prefs.delete_mail_from_server=='Y') { pop3_delete( c ); }
						}
						parse_mail_header( filename );
						receive_mail_automation( filename );
						if (mail_hdr.subject[0]!='\0') {
							add_mail_message( ++maximum_mail, filename );
							format_mailbox_line( maximum_mail, temp ); 
						/*	fprintf( log, "Added: %s to %s\n", temp, current_mailbox ); */
						}
					}
				}
				unload_killfile();
				close_pop_connection();
			}
		}
		free( receive );
	}
	sprintf( filename, "%s\\mailtemp.txt", prefs.mail_path );
	remove( filename );
}

int get_unique_filename(int start, char *prefix, char *path )
{
	FILE *fid;
	char filename[FMSIZE];
	int c;

	for (c=start;;c++) {
		sprintf( filename, "%s\\%s%04d.txt", path, prefix, c );
		fid = fopen( filename, "ra" );
		if (fid==NULL) { break; }	/* file file does not exist... */
		fclose( fid );
	}
	return(c);
}

void mail_text( int wid, char *filename )
{
	generic_window_text( wid, filename );
}

void next_mail()
{
	if (current_mail+1<MAILBOX_SIZE) {
		if (mailbox[current_mail+1].status[0]!='\0') {
			key_mailbox( 0x5000 );		/* simulate down arrow */
			mailbox[current_mail].status[0] = ' ';		/* has been read */
			view_mail( mailbox[current_mail].subject, mailbox[current_mail].filename );
		/*	previous_mail = current_mail;
			current_mail++;
			refresh_clear_window( windows[6].id );	/* refresh mailbox */
		}
	}
}

void next_unread_mail()
{
	int c;

	for (c=current_mail+1;c<MAILBOX_SIZE;c++) {
		if (mailbox[c].status[0]=='\0') { return; }
		if (mailbox[c].status[0]=='U') {	
			previous_mail = current_mail;
			current_mail = c;
			mailbox[current_mail].status[0] = ' ';		/* has been read */
			view_mail( mailbox[current_mail].subject, mailbox[current_mail].filename );

			while (current_mail>=windows[6].line_no+windows[6].lines_per_page) {
				if ((windows[6].line_no+windows[6].lines_per_page)<windows[6].num_lines) {
					windows[6].line_no+=windows[6].lines_per_page;
				}
			}
			set_vslider( 6, windows[6].id );	/* move window slider as necessary */
			refresh_clear_window( windows[6].id );	/* refresh mailbox */
			return;
		}
	}
}

void view_mail(char *message_title, char *path)
{
	int shift=3;
	int dummy,state;

	graf_mkstate( &dummy, &dummy, &dummy, &state );
	strcpy( current_mailmsg, path );
	set_reply( 6 );

	if (state&shift) {
		call_editor_nowait( path, prefs.external_editor );
	} else {
		if (prefs.use_ext_viewer=='Y') {
			call_editor_nowait( path, prefs.external_viewer );
		} else {
			if (mailbox[current_mail].num_lines!=0) {
				windows[7].num_lines = (int16)mailbox[current_mail].num_lines;
			} else {
				windows[7].num_lines = (int16)count_lines( path );
			}
		/*	windows[7].num_lines = (int16)count_lines( path ); */
			windows[7].line_no   = 0;
			handle_generic_close( 7 );	/* release possible html anchors */
			new_window( 7, message_title, 100, 50, 500, 300 );
			handle_redraw_event();
			auto_extract_binaries();
		}
	}
}

void edit_mail(char *message_title, char *path)
{
	strcpy( current_mailmsg, path );
	set_reply( 6 );
	call_editor_nowait( path, prefs.external_editor );
}

int expand_mailbox(int required)
{
	char temp[80];
	int new_size;
	char *alert;

/*	if (prefs.dynamic_expansion!='Y') { return(1); } */
	new_size = MAILBOX_SIZE;
	while (new_size<required) { new_size+=50; }
	if (new_size!=MAILBOX_SIZE) {
		if (mailbox) { free( mailbox ); }
		mailbox = calloc( new_size, sizeof( struct mbox ) );
		if (!mailbox) {
		/*	sprintf( temp,"[1][Insufficient Memory for %s][ Quit ]", "Mailbox" ); */
			rsrc_gaddr(R_STRING,Insuff_Memory,&alert); /* Insufficient Memory for ... */
			sprintf( temp, alert, "|Mailbox" );
			form_alert( 1, temp );
			mailbox = calloc( MAILBOX_SIZE, sizeof( struct mbox ) );
			return(0);				/* failed */
		}
		MAILBOX_SIZE = new_size;
	}
	return(1);
}

void open_mailbox(char *title, char *path)
{
/*	fprintf( log, "Loading Mailbox: %s\n", path );
	fflush( log ); */
	unload_mailbox( current_mailbox );
	windows[6].num_lines = (int16)count_lines( path );
	if (expand_mailbox( windows[6].num_lines )) { 
		load_mailbox( path );
		windows[6].line_no   = 0;
		new_window( 6, title, 100, 50, 500, 300 );
	}
/*	fprintf( log, "Opening Mailbox window\n" );
	fflush( log ); */
}

void load_mailbox(char *filename)
{
	FILE *fid;
	int c,mailnum;
	char buff[200];

	graf_mouse( BUSY_BEE, NULL );
	previous_mail = -1;
	current_mail = -1;
	maximum_mail = -1;
	for (c=0;c<MAILBOX_SIZE;c++) { mailbox[c].status[0] = '\0'; }

	strcpy( current_mailbox, filename );	/* new mailbox */
	current_mailmsg[0]='\0';				/* no mailmsg selected */
	set_reply( 6 );

	fid = fopen( filename, "ra" );
	if (fid!=NULL) {
	/*	fprintf( log, "Loading Mailbox: %s\n", filename ); */
		for (c=0;c<MAILBOX_SIZE;c++) {
			if (fgets( buff, sizeof(buff), fid )!=NULL) {
				mailnum = parse_mailbox_header( c, buff);
			/*	fprintf( log, "Parsed message# %d\n", c );
				fflush( log ); */
				maximum_mail = c;
			}
		}
		fclose( fid );
		next_mail_number = mailnum+1;
	}
	graf_mouse( ARROW, NULL );
	windows[6].num_lines=maximum_mail+1;
	windows[6].line_no=0;
}

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

void check_mail_attachment( int c )
{
	char temp[FMSIZE],temp2[FMSIZE];

	strcpy( temp, current_mailmsg );		/* save mail article */
	strcpy( temp2, current_article );		/* save news article */
	strcpy( current_mailmsg, mailbox[c].filename );	/* set mail article */
	strcpy( current_article, mailbox[c].filename );	/* and news article */
	if (check_for_binaries()) { mailbox[c].attachment = ATTACHMENT; }
	strcpy( current_mailmsg, temp );		/* restore mail article */
	strcpy( current_article, temp2 );		/* restore news article */
}

int parse_mailbox_header(int c, char *buff)
{
	char *status, *author, *author_email, *subject, *datetime;
	char *filename, *num_lines;
	char *attachment;
	char temp[FMSIZE],temp2[5];
/*	int mail_number=0; */

	if (c<0) { return(0); }
	if (c>=MAILBOX_SIZE) { return(0); }

	buff[strlen(buff)-1]='\t';	/* overlay \n with tab */
	status = strtoka( buff, '\t' );
	subject = strtoka( NULL, '\t' );
	author = strtoka( NULL, '\t' );
	author_email = strtoka( NULL, '\t' );
	datetime = strtoka( NULL, '\t' );
	filename = strtoka( NULL, '\t' );
	num_lines = strtoka( NULL, '\t' );	/* was \n' */
	attachment = strtoka( NULL, '\t' );

	memset( &mailbox[c], 0, sizeof(struct mbox) );
	strncpy( mailbox[c].status, status, 4 );
	strncpy( mailbox[c].author, author, 79 );
	strncpy( mailbox[c].author_email, author_email, 49 );
	strncpy( mailbox[c].subject, subject, 49 );
	strncpy( mailbox[c].datetime, datetime, 21 );
	strncpy( mailbox[c].filename, filename, 127 );
/*
	strcpy( mailbox[c].status, status );
	strcpy( mailbox[c].author, author );
	strcpy( mailbox[c].author_email, author_email );
	strcpy( mailbox[c].subject, subject );
	strcpy( mailbox[c].datetime, datetime );
	strcpy( mailbox[c].filename, filename );
*/
	mailbox[c].num_lines = atol( num_lines );
	mailbox[c].cmpdate = 0;
	if (mailbox[0].cmpdate!=0) {	/* are other entries calculated */
		mailbox[c].cmpdate = format_datetime( mailbox[c].datetime );
	}

	mailbox[c].attachment = *attachment;		/* copy attachment flag */
	if (*attachment=='\0') {		/* if empty, perform conversion */
		mailbox[c].attachment = ' ';
		if (!mail_selective()) {	/* not for selective filename=' ' */
			check_mail_attachment( c );
		}
	}

	stcgfn( temp, filename );		/* mailnnnn.txt format */
	memcpy( temp2, temp+4, 4 );
	temp2[4] = '\0';
/*	fprintf( log, "Mail: %s, %s, %s\n", filename, temp, temp2 ); */
	return( atoi(temp2) );
}

void remove_mailbox_dir( char *filename )
{
	char dir_path[FMSIZE],temp[FMSIZE],*p;
	struct FILEINFO info;
	int rc;

	if (prefs.mail_directories=='Y') {
/*	if (memcmp(prefs.email_address, "rojewski", 8)==0) {	/* for directories */
		strcpy( dir_path, filename );
		if (p=strrchr( dir_path, '\\' )) {
			*(p+1)='\0';				/* remove filename, leave final '\' */
			strcpy( temp, dir_path );
			strcat( temp, "*.*" );		/* append template  */
		/*	fprintf( log, "Dir_path %s, temp %s\n", dir_path, temp ); */
			if (dfind( &info, temp, 0 )) {	/* if directory is empty */
				rc=rmdir( dir_path );		/* remove empty directory */
				if (rc) {
					fprintf( log, "Unable to delete Mail Directory %s %d %ld\n", dir_path, rc, _OSERR );
				}
			}
		}
	}
}

int mail_selective(void)
{
	char *p;
	char temp[FMSIZE];

	strcpy( temp, current_mailbox );
	strlwr( temp );
	if (stcpm( current_mailbox, SERVERMBX, &p)) { return(1); }
	return(0);
}

void close_mailbox(void)
{
	char mbx[FMSIZE];

	windows[6].bar_index = Tool_MailBox;	/* default to regular Toolbar */
	windows[6].bar_object= NULL;
	if (mail_selective()) {
		strcpy( mbx, current_mailbox );	/* path for SERVERMBX */

		windows[6].open=1;		/* mark window open for info_line() */
		mailbox_selective_retrieve();	/* may change current_mailbox! */
		windows[6].open=0;		/* mark window closed, again */

		unload_mailbox( current_mailbox );
		remove( mbx );					/* erase SERVERMBX */
		return;
	}
	unload_mailbox( current_mailbox );
}

void unload_mailbox( char *filename )
{
	FILE *fid;
	int c;

	if (maximum_mail==-1) { return; }		/* nothing loaded */
	fid = fopen( filename, "wa" );
	if (fid!=NULL) {
		graf_mouse( BUSY_BEE, NULL );
		for (c=0;c<MAILBOX_SIZE;c++) {
			if (mailbox[c].status[0]!='\0') {
				if (mailbox[c].status[1]=='D') {	/* if Deleted */
					remove( mailbox[c].filename );
					remove_mailbox_dir( mailbox[c].filename );
					mailbox[c].status[0] = '\0';
					mailbox[c].status[1] = '\0';
				} else {							/* otherwise */
					if (mailbox[c].status[1]=='P') { mailbox[c].status[1]='D'; }
				/*	fprintf( fid, "%s\t%s\t%s\t%s\t%s\t%s\t%ld\n",
					mailbox[c].status, mailbox[c].subject, mailbox[c].author,
					mailbox[c].author_email, mailbox[c].datetime,
					mailbox[c].filename, mailbox[c].num_lines ); */
					fprintf( fid, "%s\t%s\t%s\t%s\t%s\t%s\t%ld\t%c\n",
					mailbox[c].status, mailbox[c].subject, mailbox[c].author,
					mailbox[c].author_email, mailbox[c].datetime,
					mailbox[c].filename, mailbox[c].num_lines, mailbox[c].attachment );
				}
			}
		}
		fclose( fid );
		graf_mouse( ARROW, NULL );
	}
	maximum_mail=-1;			/* nothing loaded */
	if (windows[6].open) {
		wind_close( windows[6].id );
		windows[6].open=0;
	}
}

void add_mail_message( int c, char *filename )
{
/*	fprintf( log, "adding mailbox[%d],%s\n", c, mail_hdr.subject ); */
	sprintf( mailbox[c].status, "%-4.4s", mail_hdr.status );
	sprintf( mailbox[c].subject, "%-.49s", mail_hdr.subject );
	strcpy( mailbox[c].filename, filename );
	simplify_author( mail_hdr.from, mailbox[c].author, mailbox[c].author_email );
	if (mail_hdr.reply_to[0]!='\0') { strcpy( mailbox[c].author_email, mail_hdr.reply_to ); }
	sprintf( mailbox[c].datetime, "%-.21s", mail_hdr.datetime );
	mailbox[c].num_lines = count_lines( filename );

	mailbox[c].cmpdate = 0;
	if (mailbox[0].cmpdate!=0) {	/* are other entries calculated */
		mailbox[c].cmpdate = format_datetime( mailbox[c].datetime );
	}
	mailbox[c].attachment = ' ';	/* default to no attachments */
	check_mail_attachment( c );	/* check the file and set flag */
}

void mailbox_infoline(void)
{
	char temp[80];
	int msgs=0,unread=0,c;

	if (maximum_mail>=0) {
		msgs=maximum_mail+1;
		for (c=0;c<maximum_mail+1;c++) {
			if (mailbox[c].status[0]=='U') { unread++; }
		}
	}
/*	sprintf( temp, "Mailbox contains %d messages, %d Unread", msgs, unread ); */
	if (mail_selective()) {
		sprintf( temp, ErrMsg(EM_MailSInfo), msgs, unread );
	} else {
		sprintf( temp, ErrMsg(EM_MailInfo), msgs, unread );
	}
	info_line( 6, temp );
}

void format_mailbox_line(int c, char *buff)
{
/*	sprintf( buff, "%-3.3s %-30.30s %-30.30s %-6.6s %4ld",
			mailbox[c].status,
			mailbox[c].subject, mailbox[c].author,
			mailbox[c].datetime, mailbox[c].num_lines ); */
	sprintf( buff, "%-3.3s %c %-30.30s %-30.30s %-6.6s %4ld",
			mailbox[c].status, mailbox[c].attachment,
			mailbox[c].subject, mailbox[c].author,
			mailbox[c].datetime, mailbox[c].num_lines );
}

void mailbox_text(int wid)
{
	GRECT work;
	int x,y,c,lpp,start,end,refresh=1;
	char buff[100];
	OBJECT *bar;

	x = wind_get( wid, WF_WORKXYWH, &work.g_x, &work.g_y, &work.g_w, &work.g_h);
	setup_toolbar(6, &work.g_x, &work.g_y, &work.g_w, &work.g_h );
	lpp = setup_text( wid, 6, prefs.overview_font, prefs.overview_font_size,
				work.g_h, maximum_mail+1 ); 
	x=work.g_x;
	y=work.g_y;
	if (windows[6].clear) {
		clear_rect( &work);
		refresh=0;
		if ((bar=windows[6].bar_object)!=NULL) {
			objc_draw( bar, ROOT, 1, clip.g_x, clip.g_y, clip.g_w, clip.g_h );
		}
	}
	mailbox_infoline();

	start = windows[6].line_no;
	end   = start + lpp;
	if (end>MAILBOX_SIZE) { end=MAILBOX_SIZE; }
	for (c=start;c<end;c++) {
		if (c>=0) {
			if ( mailbox[c].status[0]!='\0') {
				y+=cellh;
				if (refresh) {
					if (c==current_mail) {
						format_mailbox_line( c, buff );
						set_selected_text( 1 );
						v_gtext( handle, x, y, buff );
						set_selected_text( 0 );
					} 
					if (c==previous_mail) {
						format_mailbox_line( c, buff );
						if (mailbox[c].status[0]=='U') { vst_color( handle, BLUE ); }
						if (mailbox[c].status[1]=='Q') { vst_color( handle, BLUE ); }
						v_gtext( handle, x, y, buff );
						set_selected_text( 0 );
					}
				} else {
					format_mailbox_line( c, buff );
					if (mailbox[c].status[0]=='U') { vst_color( handle, BLUE ); }
					if (mailbox[c].status[1]=='Q') { vst_color( handle, BLUE ); }
					if (c==current_mail) { set_selected_text( 1 ); }
					v_gtext( handle, x, y, buff );
					set_selected_text( 0 );
				}
			}
		}
	} 
}

void select_mail(int vert, int clicks)
{
	int rc,index,refresh;
	char mail_title[60];

	rc = atoi( prefs.overview_font_size );
	vst_point( handle, rc, &charw, &charh, &cellw, &cellh );
	index = (vert / cellh ) + windows[6].line_no;
	if (index<MAILBOX_SIZE) {
		if (mailbox[index].status[0]!='\0') {
			refresh = (current_mail!=index);
			previous_mail = current_mail;
			current_mail = index;
			if (!mail_selective()) {	/* for mail on local disk */
				if (mailbox[current_mail].num_lines==0) {
					mailbox[current_mail].num_lines = count_lines( mailbox[current_mail].filename );
				}
			/*	if (mailbox[current_mail].num_lines==0) {	/* still zero lines, missing? */
			/*		show_status("Mail may be deleted or has been moved:", mailbox[current_mail].filename ); */
			/*	} */
			}
			if (clicks>1) {
				if (mail_selective()) {
					key_mailbox_selective( '\r' );	/* toggle retrieve */
				} else {
					mailbox[index].status[0] = ' ';		/* has been read */
				/*	parse_mail_header( mailbox[index].filename ); */
					sprintf( mail_title, "%s", mailbox[index].subject );
					view_mail( mail_title, mailbox[index].filename );
				}
			} else {
				strcpy( current_mailmsg, mailbox[index].filename );
				set_reply( 6 );
				if (refresh) { refresh_window( windows[6].id ); }
			}
		}
	}
}

void mail_retrieve_delete_all( char x )
{
	int c,cnt=0;

	for (c=0;c<=maximum_mail;c++) {
		if (mailbox[c].status[1]==x) { cnt++; }	/* x=D or x=R */
	}
	if (cnt>maximum_mail) { x=' '; }	/* reset all */
	for (c=0;c<=maximum_mail;c++) {	mailbox[c].status[1] = x; }
}

void key_mailbox_selective(int keycode)
{
	int shift=3;
	int c,state;

	graf_mkstate( &c, &c, &c, &state );
	if (state&shift) {
		if ((char)keycode=='\r') {	/* return = read all mail */
			mail_retrieve_delete_all( 'R' );
		/*	for (c=0;c<=maximum_mail;c++) {
				mailbox[c].status[1] = 'R';
			} */
			refresh_clear_window( windows[6].id );
			return;
		}
		if ((keycode>>8)=='\x53') {	/* delete all mail messages */
			mail_retrieve_delete_all( 'D' );
		/*	for (c=0;c<=maximum_mail;c++) {
				mailbox[c].status[1] = 'D';
			} */
			refresh_clear_window( windows[6].id );
			return;
		}
	}
	if ((char)keycode=='\r') {	/* return = read mail message */
		if (current_mail>=0) {
			if (mailbox[current_mail].status[1]=='R') {
				mailbox[current_mail].status[1] = ' ';	/* no retrieve */
			} else {
				mailbox[current_mail].status[1] = 'R';
			}
			refresh_window( windows[6].id );
		}
		return;
	}
	if ((keycode>>8)=='\x53') {	/* delete/undelete the mail message */
		if (current_mail>=0) {
			if (mailbox[current_mail].status[1]=='D') {
				mailbox[current_mail].status[1] = ' ';	/* undelete */
			} else {
				mailbox[current_mail].status[1] = 'D';
			}
			refresh_window( windows[6].id );
		}
		return;
	}
}

void key_mailbox(int keycode)
{
	char temp[FMSIZE],*p;

	strcpy( temp, current_mailbox );
	strlwr( temp );

	if (arrow_page_scrolling_keys( windows[6].id, keycode )) { return; }

	if ((keycode>>8)=='\x48') {	/* up arrow */
		if (current_mail>0) {
			previous_mail = current_mail;
			current_mail--;
			strcpy( current_mailmsg, mailbox[current_mail].filename );
			set_reply( 6 );
			if (current_mail<windows[6].line_no) {
				handle_arrows( windows[6].id, WA_UPPAGE );
			} else {
				refresh_window( windows[6].id );
			}
		}
		return;
	}
	if ((keycode>>8)=='\x50') {	/* down arrow */
		if (current_mail<maximum_mail) {
			previous_mail = current_mail;
			current_mail++;
			strcpy( current_mailmsg, mailbox[current_mail].filename );
			set_reply( 6 );
			if (current_mail>=windows[6].line_no+windows[6].lines_per_page) {
				handle_arrows( windows[6].id, WA_DNPAGE );
			} else {
				refresh_window( windows[6].id );
			}
		}	
		return;
	}

	if (mail_selective()) {
		key_mailbox_selective(keycode);
		return;
	}

	if ((char)keycode=='\r') {	/* return = read mail message */
		if (current_mail>=0) {
			if (mailbox[current_mail].num_lines==0) {
				mailbox[current_mail].num_lines = count_lines( mailbox[current_mail].filename );
			}
		/*	parse_mail_header( mailbox[current_mail].filename ); */
			mailbox[current_mail].status[0] = ' ';	/* has been read */
			view_mail( mailbox[current_mail].subject, mailbox[current_mail].filename );
		}
		return;
	}
	if ((char)keycode=='e') {	/* e = edit mail message */
		if (current_mail>=0) {
			mailbox[current_mail].status[0] = ' ';	/* has been read */
			edit_mail( mailbox[current_mail].subject, mailbox[current_mail].filename );
		}
		return;
	}
	if ((char)keycode=='q') {	/* q = re-queue a message to be sent */
		if (current_mail>=0) {
			if (stcpm( temp, "outbox.mbx", &p)) { /* for OUTBOX only */
				mailbox[current_mail].status[1] = 'Q';	/* re-queue for send */
				refresh_window( windows[6].id );
			}
			if (stcpm( temp, "draft.mbx", &p)) { /* for DRAFT only */
				mailbox[current_mail].status[1] = 'Q';	/* re-queue for send */
				transfer_mail( "outbox.mbx" );
			}
		}
		return;
	}
	if ((char)keycode=='t') {	/* t = transfer to another mailbox */
		if (current_mail>=0) {
			transfer_mail( "" );
		}
		return;
	}
	if ((char)keycode=='a') {	/* s = sort mailbox by author */
		sort_mailbox(1);
		return;
	}
	if ((char)keycode=='d') {	/* d = sort mailbox by date */
		sort_mailbox(2);
		return;
	}
	if ((char)keycode=='s') {	/* s = sort mailbox by subject */
		sort_mailbox(3);
		return;
	}
	if ((char)keycode=='D') {	/* shift-d = sort mailbox by date reverse */
		sort_mailbox(4);
		return;
	}
	if ((char)keycode=='u') {	/* u = mark mail as unread */
		if (current_mail>=0) {
			mailbox[current_mail].status[0] = 'U';	/* mark unread */
			mailbox[current_mail].status[1] = ' ';
			refresh_window( windows[6].id );
		}
		return;
	}
	if ((keycode>>8)=='\x53') {	/* delete/undelete the mail message */
		if (current_mail>=0) {
			if (mailbox[current_mail].status[1]=='D') {
				mailbox[current_mail].status[1] = ' ';	/* undelete */
			} else {
				mailbox[current_mail].status[1] = 'D';
			}
			refresh_window( windows[6].id );
		}
		return;
	}
}

void key_mail(int keycode)
{
	if ((keycode>>8)=='\x53') {	/* delete the mail message */
		if (current_mail>=0) {
			mailbox[current_mail].status[1] = 'D';
			wind_close( windows[7].id );
			windows[7].open=0;
		/*	delete_window( windows[7].id ); */
		/*	windows[7].id=-1; */
			refresh_window( windows[6].id );
		}
		return;
	}
	arrow_scrolling_keys( windows[7].id, keycode );
}

void handle_extended_Mail_menu( int item, OBJECT *tree, int sub_item )
{
	char path[FMSIZE];
	OBJECT *mn_tree=NULL;
	char fname[FMSIZE]="";

	if (tree) {
		get_menu_block( "mbx", NULL, &mn_tree, NULL, NULL );
		if (tree==mn_tree) {
			sprintf( fname, "%s.mbx", tree[item].ob_spec );	/* copy filename from selected attached menu */
			item = MM_OpenMailbox;	/* continue with processing */
		}
		get_menu_block( "abk", NULL, &mn_tree, NULL, NULL );
		if (tree==mn_tree) {
			sprintf( fname, "%s.abk", tree[item].ob_spec );	/* copy filename from selected attached menu */
			item = MM_OpenAddress;	/* continue with processing */
		}
	}

	switch (item)
	{
		case MM_SendMail:
			sprintf( path, "%s\\%s", prefs.work_path, MAILTEST );
			Mail_Message_dialog(0, path );
			break;

		case MM_ReplyMail:
			sprintf( path, "%s\\%s", prefs.work_path, MAILTEST );
			Mail_Message_dialog(1, path );
			break;

		case MM_ForwardMail:
			sprintf( path, "%s\\%s", prefs.work_path, MAILTEST );
			Mail_Message_dialog(2, path );
			break;

		case MM_EditNick:
			edit_nicknames();
			break;

		case MM_OpenAddress:
			open_popup_address_book_name( fname );
#if (0)
			sprintf( path, "%s\\%s", program_path, "address.abk" );
			sprintf( select, "%s: %s", ErrMsg(EM_AddressBook), "Address" );
			open_address_book( select, path );
#endif
			break;

		case MM_AddToAddress:
			add_to_address_book();
			break;

		case MM_CheckMail:
			if (STiK>0) {
				check_mail();
				close_pop_connection();
			} else { no_stik(); }
			break;

		case MM_GetMail:
			if (STiK>0) { get_mail(1); } else { no_stik(); }
			break;

		case MM_GetSelected:
			if (STiK>0) { get_mail(-1); } else { no_stik(); }
			break;
	
		case MM_SendQueued:
			if (STiK>0) { send_queued_messages(); } else { no_stik(); }
			break;

		case MM_OpenInBox:
			sprintf( path, "%s\\%s", prefs.mail_path, "inbox.mbx" );
			open_mailbox( ErrMsg(EM_MailInBox), path );
			break;

		case MM_OpenMailbox:
			open_popup_mailbox_name( fname );
			break;
	}
}

void handle_Mail_menu( int item )
{
	handle_extended_Mail_menu( item, NULL, 0 );	/* pass to extended handler */
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

void parse_mail_header( char *filename )
{
	FILE *fid;
	size_t index;
	char field[512],entry[512],line[512],*dt;

	memset( &mail_hdr, 0, sizeof(mail_hdr) );
	strcpy( mail_hdr.subject, "<no subject>" );		/* initialize */
	strcpy(mail_hdr.status,"U  ");	/* status may be empty */

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
					strncpy(mail_hdr.subject, entry, 79);
				else if (strcmpi("From", field)==0)
					strncpy(mail_hdr.from, entry, 79);
				else if (strcmpi("Reply-to", field)==0)
					strncpy(mail_hdr.reply_to, entry,79);
				else if (strcmpi("To", field)==0)
					strncpy(mail_hdr.to, entry,79);
				else if (strcmpi("Date", field)==0) {
					dt = strpbrk( entry, "123456789" );
					strncpy(mail_hdr.datetime, dt, 29); }
				else if (strcmpi("Status", field)==0)
					strncpy(mail_hdr.status, entry, 4);
				else if (strcmpi("MIME-Version", field)==0)
					strncpy(mail_hdr.mime_version, entry, 19);
				else if (strcmpi("Content-Type", field)==0)
					strncpy(mail_hdr.mime_type, entry, 79);
				else if (strcmpi("Content-Transfer-Encoding", field)==0)
					strncpy(mail_hdr.mime_encoding, entry,79);
				else if (strcmpi("Content-Disposition", field)==0)
					strncpy(mail_hdr.mime_disposition, entry,79);
			}
		}
	/*	fprintf( log, "Subject: %s\n", mail_hdr.subject );
		fprintf( log, "From: %s\n", mail_hdr.from );
		fprintf( log, "Reply_to: %s\n", mail_hdr.reply_to ); */
		fclose( fid );
	}
}

int select_mailbox(char *dirname)
{
	char select[FMSIZE];
	char path[FMSIZE];
	int button;

	strcpy( select, "*.mbx" );
	sprintf( dirname, "%s\\%s", prefs.mail_path, select );	
	fsel_exinput( dirname, select, &button, ErrMsg(EM_SMailbox) );	/* Select Mailbox */
	if (button) {
		stcgfp( path, dirname );
		rebuild_attach_list( dirname, "mbx" );	/* update mailbox list */
		sprintf( dirname, "%s\\%s", path, select );
	/*	fprintf( log, "dir %s, sel %s, filename %s\n", path, select, dirname ); */
	}
	return(button);
}

void open_popup_mailbox_name(char *fname)
{
	int c=2;
	char dirname[FMSIZE],path[FMSIZE],select[FMSIZE];

	sprintf( dirname, "%s\\", prefs.mail_path );
	if (fname[0]==' ') { c=1; }	/* "  new  " */
	if (fname[0]=='\0') {	/* passed empty string? */
		c = filelist_popup( dirname, "*.mbx" );
	} else {
		strcat( dirname, fname );	/* complete mailbox path in dirname */
	}
/*	c = filelist_popup( dirname, "*.mbx" ); */

	if (c==0) { return; }
	if (c==1) { if (!select_mailbox( dirname )) { return; } }
	stcgfn( select, dirname );
	strtok( select, "." );
	strupr( select );	/* force uppercase */
	strlwr( select+1 );	/* leave only first char uppercase */
	sprintf( path, "%s %s", ErrMsg(EM_Mailbox), select );
	open_mailbox( path, dirname );
}

void open_popup_mailbox(void)
{
	open_popup_mailbox_name( "" );	/* empty filename */
}

void transfer_mail(char *thebox)
{
	FILE *fid;
	char dirname[FMSIZE],box[FMSIZE];
	int c;
	long size;
	
	if (thebox[0]=='\0') {		/* user selected mailbox? */
		sprintf( dirname, "%s\\", prefs.mail_path );
		c = filelist_popup(dirname, "*.mbx");
		if (c==0) { return; }
		if (c==1) { if (!select_mailbox( dirname )) { return; } }
	} else {
		sprintf( dirname, "%s\\%s", prefs.mail_path, thebox );
	}

	if (prefs.dynamic_expansion!='Y') {		/* if no dynamic expansion */
		size = count_lines( dirname );
		stcgfn( box, dirname );	/* extract filename */
		strtok( box, "."); 	/* remove extension */
		if (mailbox_full(size, 2, box)) { return; }
	}

	fid = fopen( dirname, "aa" );
	if (fid!=NULL) {
		c = current_mail;
		fprintf( fid, "%s\t%s\t%s\t%s\t%s\t%s\t%ld\n",
		mailbox[c].status, mailbox[c].subject, mailbox[c].author,
		mailbox[c].author_email, mailbox[c].datetime,
		mailbox[c].filename, mailbox[c].num_lines );
		fclose( fid );
		for (c=current_mail;c<maximum_mail;c++) {
			memcpy( &mailbox[c], &mailbox[c+1], sizeof(mailbox[0]) );
		}
		mailbox[maximum_mail].status[0]='\0';	/* clear final entry */
		strcpy( current_mailmsg, mailbox[current_mail].filename );
		set_reply( 6 );

		if (maximum_mail==0) {		/* only message in mailbox? */
			unload_mailbox( current_mailbox );
			current_mailmsg[0]='\0';		/* no mailmsg selected */
			set_reply( 6 );
			return;
		}		
		maximum_mail--;				/* reduce maximum_mail by 1 */
		if (current_mail>maximum_mail) {
			current_mail = -1;
			previous_mail = -1;
			current_mailmsg[0]='\0';		/* no mailmsg selected */
			set_reply( 6 );
		}
		refresh_clear_window( windows[6].id );
	}
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

int mailbox_full(int size, int result, char *box)
{
	int  status[]={EM_UnableQueue,EM_UnableSave,EM_TransCancel};
	char temp[80];

	if (size>=MAILBOX_SIZE) {
		expand_mailbox( size+1 );	/* expand mailbox to fit */
	}
	if (size>=MAILBOX_SIZE) {
		sprintf( temp, ErrMsg(EM_MailboxFull), box ); /* Mailbox %s is Full... */
		show_warning( temp );
		status_text( ErrMsg(status[result]) );	/* Unable to Queue,Save, or Transfer */
		evnt_timer( 2000, 0 );		/* wait 2 seconds */
		hide_status();
		return(1);
	}
	if (size>MAILBOX_SIZE-10) {
		sprintf( temp, ErrMsg(EM_NearlyFull), box ); /* Mailbox %s is nearly Full... */
		show_warning( temp );
		evnt_timer( 1000, 0 );		/* wait 1 second */
		hide_status();
	}
	return(0);	/* mailbox is ok */
}

void add_to_outbox(char *filename, char *subject, char *author, int result)
{
	FILE *fid;
	char dirname[FMSIZE],newfile[FMSIZE];
	char author_name[60],author_email[60];
	char temp[40],datetime[30],status[]=" Q ";
	char buff[200];
	char mail_dir[FMSIZE],yymmdd[10];
	struct tm *tp;
	time_t t;
	int lines;

	if (result) { status[1]='S'; }	/* 1=sent, 0=failed */
	if (result==-1) { status[1]='I'; }	/* -1=incomplete */

	get_yymmdd( yymmdd );
	validate_dir( prefs.mail_path, yymmdd, mail_dir );
	next_mail_number = get_unique_filename(next_mail_number, "mail", mail_dir );
	sprintf( newfile, "%s\\mail%04d.txt", mail_dir, next_mail_number++ );

/*	next_mail_number = get_unique_filename(next_mail_number, "mail", prefs.mail_path ); */
/*	sprintf( newfile, "%s\\mail%04d.txt", prefs.mail_path, next_mail_number++ ); */
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

	if (result==-1) {	/* -1=incomplete - override to draft */
		strcpy( temp, "draft" );
		sprintf( dirname, "%s\\%s.mbx", prefs.mail_path, temp );
		result=2;	/* this is a transfer to Draft */
	} else {
		strcpy( temp, "outbox" );
		sprintf( dirname, "%s\\%s.mbx", prefs.mail_path, temp );
	}
	temp[0] = toupper( temp[0] );
/*	strlwr( temp+1 );	/* leave 1st character capitalized for pretty */

/*	Is the mailbox to append to also the current mailbox, i.e. OutBox? */
	if ((strcmpi(current_mailbox,dirname)==0)&&(windows[6].open)) {
		if (mailbox_full(maximum_mail+1, result, temp )) { return; }
		parse_mailbox_header( ++maximum_mail, buff );
		refresh_clear_window( windows[6].id );
	} else {
		if (prefs.dynamic_expansion!='Y') {		/* if no dynamic expansion */
			lines = (int16)count_lines( dirname );
			if (mailbox_full(lines, result, temp )) { return; }
		}
		fid = fopen( dirname, "aa" );		/* append to outbox */
		if (fid!=NULL) {
			fputs( buff, fid );
			fclose( fid );
		}
	}
}

void send_queued_messages(void)
{
	char filename[FMSIZE];
	char to[120],cc[]="";
	int c,tried=FALSE;

	unload_mailbox( current_mailbox );
	sprintf( filename, "%s\\%s", prefs.mail_path, "outbox.mbx" );

	c = (int16)count_lines( filename );
	expand_mailbox( c );	/* expand mailbox to fit */

	load_mailbox( filename );
	for (c=0;c<maximum_mail+1;c++) {
		if (mailbox[c].status[1]=='Q') {	/* Queued? */
			show_warning( ErrMsg(EM_SendQueued) ); /* Sending Queued Mail... */
			strcpy( filename, mailbox[c].filename );
			sprintf( to, "%s (%s)", mailbox[c].author_email, mailbox[c].author );
			if (strlen(to)>50) { strcpy( to, mailbox[c].author_email ); }
			if (try_mail( filename, to, cc, prefs.copies_to_self, FALSE )) {
				mailbox[c].status[1]='S';
				tried = TRUE;
				if (prefs.delete_queued_mail=='Y') { /* sent, now delete */
					mailbox[c].status[1]='D';
				}
			}
		}
	}
	if (tried) { mail_quit(); }
	unload_mailbox( current_mailbox );
}

int identify_maillist( char *list )
{
	FILE *fid;
	int found=0;
	char buff[100],path[FMSIZE];

	sprintf( path, "%s\\listsrv.txt", prefs.mail_path );
	fid = fopen( path, "ra" );
	if (fid!=NULL) {
		while (fgets( buff, sizeof(buff), fid )!=NULL) {
			strtok( buff, "\n" );		/* remove linefeed */
			if (strcmp( list, buff )==0) { found++; break; }
		}
		fclose( fid );
	}
	return( found );
}

int mime_headers_only( OBJECT *dlog )
{
	Button_Disable( MM_None );
	Button_Disable( MM_UUE );
	Button_Disable( MM_MIME );
	set_crossed( dlog, MM_UUE,  FALSE );
	set_crossed( dlog, MM_MIME, TRUE  );
	return(1);
}

int select_attach_file(char *dirname)
{
	char select[FMSIZE];
	char path[FMSIZE];
	int button;
	OBJECT *dlog;

	rsrc_gaddr(R_TREE,Mail_Message,&dlog);
	strcpy( select, "*.*" );
	sprintf( dirname, "%s\\%s", prefs.work_path, select );	
	fsel_exinput( dirname, select, &button, ErrMsg(EM_SelAttach) );	/* Select Attachment */
	if (button) {
		stcgfp( path, dirname );
		sprintf( dirname, "%s\\%s", path, select );
		Button_Enable(MM_Send);			/* enable Send button */
		Button_Enable(MM_Queue);		/* enable Queue button */
	/*	fprintf( log, "dir %s, sel %s, filename %s\n", path, select, dirname ); */
	} else {
		dirname[0]='\0';
		Button_Disable(MM_Send);		/* disable Send button */
		Button_Disable(MM_Queue);		/* disable Queue button */
	}
	return(button);
}

void Mail_Message_dialog(int reply, char *article)
{
	/* reply(0)=Send, reply(1)=Reply, reply(2)=Forward, reply(3)=CAB Client*/
	OBJECT *dlog;
	FILE *fid,*fid2;
	char toself,newstatus=' ';
	char None,UUE,MIME;
	char to[100]="",subject[80]="",thefile[FMSIZE],cc[80];
	char buff[200],attach[80],charset[20]="us-ascii";
	int result,copy=0,top,org,remove_temp=0;	
	int dummy,state;
	int mime_only=0;

	if (Addr_Book==NULL) {
		sprintf( thefile, "%s\\%s", program_path, "ADDRESS.ABK" );
		load_address_book( thefile );
	}
	wind_get( 0, WF_TOP, &top, NULL, NULL, NULL );
	if ((windows[6].id==top)||(windows[7].id==top)) {
		org=0;
		strcpy( thefile, current_mailmsg );		/* mail message */
	} else if (windows[14].id==top) {
		org=2;									/* address book */	
	} else {	
		org=1;
		strcpy( thefile, current_article );		/* news article */
	}
	rsrc_gaddr(R_TREE,Mail_Message,&dlog);
	set_crossed( dlog, MM_CopyToSelf, prefs.copies_to_self=='Y' );
	switch (reply)
	{
    case 0: /* send */
		if (org==0) {
			if (current_mail<0) { break; }
			newstatus=mailbox[current_mail].status[0];
			if (mailbox[current_mail].author_email[0]=='\0') {
				strcpy( mailbox[current_mail].author_email, mailbox[current_mail].author ); }
			sprintf( to, "%s (%s)", mailbox[current_mail].author_email,
				mailbox[current_mail].author );
			if (strlen(to)>50) {		/* limit to 50 characters */
				strcpy( to, mailbox[current_mail].author_email );
			}
		}
		if (org==2) { /* address book */
			if (Addr_Book[current_abook].email[0]=='\0') {
				strcpy( Addr_Book[current_abook].email, Addr_Book[current_abook].name ); }
			sprintf( to, "%s (%s)", Addr_Book[current_abook].email,
				Addr_Book[current_abook].name );
			if (strlen(to)>50) {		/* limit to 50 characters */
				strcpy( to, Addr_Book[current_abook].email );
			}
		}
		break;
	case 1: /* reply */
		if (org) {
			sprintf( to, "%s (%s)", overview[current_overview].author_email,
				overview[current_overview].author );
			if (strlen(to)>50) {		/* limit to 50 characters */
				strcpy( to, overview[current_overview].author_email );
			}
			strcpy( subject, overview[current_overview].subject );
		} else {
			if (current_mail<0) { return; }
			newstatus='R';
			if (mailbox[current_mail].author_email[0]=='\0') {
				strcpy( mailbox[current_mail].author_email, mailbox[current_mail].author ); }
			sprintf( to, "%s (%s)", mailbox[current_mail].author_email,
				mailbox[current_mail].author );
			if (strlen(to)>50) {		/* limit to 50 characters */
				strcpy( to, mailbox[current_mail].author_email );
			}
			strcpy( subject, mailbox[current_mail].subject );
		}
		if (memcmp(subject, "Re: ", 4)!=0) { /* insert "Re: " if needed */
			sprintf( buff, "Re: %s", subject );
			strcpy( subject, buff );
		}
		break;
	case 2: /* forward */
		if (org) {
			strcpy( subject, overview[current_overview].subject );
		} else {
			if (current_mail<0) { return; }
			newstatus='F';
			strcpy( subject, mailbox[current_mail].subject );
		}
		break;
	}
	if (strlen(subject)>49) { subject[49]='\0'; }
	if (reply!=3) {
		set_tedinfo( dlog, MM_To, to );
		set_tedinfo( dlog, MM_Subject, subject );
	}
	set_tedinfo( dlog, MM_Cc, "" );
	set_tedinfo( dlog, MM_Attach, "" );
	set_crossed( dlog, MM_AppendSig, prefs.append_signature=='Y' );	

	Button_Disable(MM_Send);		/* disable Send button */
	Button_Disable(MM_Queue);		/* disable Queue button */
	dlog[MM_Attach].ob_type=(256+G_BOXTEXT);	/* file selector for Attach */
	set_crossed( dlog, MM_None, FALSE );		
	set_crossed( dlog, MM_UUE,  TRUE  );		/* init to Encode: UUE */
	set_crossed( dlog, MM_MIME, FALSE );

	if (prefs.mime_headers=='R') {	/* respect MIME headers */
		if (reply==2||reply==3) {	/* for reply for forward only */
			parse_mail_header( thefile );
			if (mail_hdr.mime_version[0]!='\0') { mime_only=mime_headers_only( dlog ); }
		}
	}
	if (prefs.mime_headers=='F') {	/* force MIME headers */ 
		mime_only=mime_headers_only( dlog );
	}

	result = handle_dialog(dlog, MM_To );

	if (mime_only) {
		Button_Enable( MM_None );	/* if previously disabled */	
		Button_Enable( MM_UUE );
		Button_Enable( MM_MIME );
	}

	if (result==MM_Cancel) { return; }

	Button_Enable(MM_Send);			/* enable Send button */
	Button_Enable(MM_Queue);		/* enable Queue button */
/*	Touch_Off(MM_Attach);			/* disable Attach field */

	handle_redraw_event();
	get_crossed( dlog, MM_CopyToSelf, &toself );
	get_tedinfo( dlog, MM_To, to );
	get_tedinfo( dlog, MM_Cc, cc );
	get_tedinfo( dlog, MM_Subject, subject );
	get_crossed( dlog, MM_AppendSig, &prefs.append_signature );	
	get_tedinfo( dlog, MM_Attach, attach );
	get_crossed( dlog, MM_None, &None );	
	get_crossed( dlog, MM_UUE,  &UUE );	
	get_crossed( dlog, MM_MIME, &MIME );	
	fid = fopen( article, "wa" );
	if (fid!=NULL) {
		if (strchr( to, '@' )!=NULL) {
			fprintf( fid, "To: %s\n", to );
		} 
		if (strchr( cc, '@' )!=NULL) { 
			if (cc[0]!='\0') { fprintf( fid, "cc: %s\n", cc ); }
		}
	/*	fprintf( fid, "From: %s <%s>\n", prefs.full_name, prefs.email_address ); */ 
		fprintf( fid, "From: %s (%s)\n", prefs.email_address, prefs.full_name ); 
		fprintf( fid, "Organization: %s\n", prefs.organization ); 
		fprintf( fid, "Subject: %s\n", subject ); 
		fprintf( fid, "X-Mailer: NEWSie Version %.4s (Atari)\n", VERSION );
		if (MIME=='Y') {
			fprintf( fid, "MIME-Version: 1.0\n" ); 
			if (attach[0]!='\0') {	/* attachment selected */
				fprintf( fid, "Content-Type: multipart/mixed; boundary=boundary\n" ); 
				fprintf( fid, "\n--boundary\n" );
			} else {				/* no attachment(s) */
				fprintf( fid, "Content-Type: text/plain; charset=%s\n", charset ); 
			}
		}
		fprintf( fid, "\n" ); 
		if (reply==1) {	/* quote original message in reply */
			if (identify_maillist( mailbox[current_mail].author_email )) {
				fprintf( fid, "On %.21s, %s wrote:\n", mailbox[current_mail].datetime, mailbox[current_mail].author );
			} 
			fid2 = fopen( thefile, "ra" );
			if (fid2!=NULL) {			/* if original file exists */ 
				while (fgets( buff, sizeof(buff), fid2 )!=NULL) {
					if (copy) {
						fprintf( fid, "%s%s", prefs.quote_string, buff );
					} 
					if (buff[0]=='\n') copy=1;	/* enable copy after null line */
				}
				fclose( fid2 );
			} 
		}
		if (reply==2) {	/* copy original message for forward */
			if (org) {
			fprintf( fid, "The following is from: %s (%s)", overview[current_overview].author_email,
				overview[current_overview].author );
			} else {
			fprintf( fid, "The following is from: %s (%s)", mailbox[current_mail].author_email,
				mailbox[current_mail].author );
			}
			fprintf( fid, "\n" );
			fid2 = fopen( thefile, "ra" );
			if (fid2!=NULL) { 		/* if original file exists */
				while (fgets( buff, sizeof(buff), fid2 )!=NULL) {
					if (strcmp( buff, ".\n")!=0) { fputs( buff, fid ); }
				}
				fprintf( fid, "\n" ); 
 				fprintf( fid, "End of Original message\n" ); 
		 		fclose( fid2 );
			} 
		}
		if (attach[0]!='\0') {	/* attachment(s) selected */
			if (UUE=='Y') {
				uuencode( attach );
				remove_temp++;
			}
			if (MIME=='Y') {
				fprintf( fid, "\n--boundary\n" );
				stcgfn( buff, attach );
				fprintf( fid, "Content-Type: application/octet-stream; name=\"%s\"\n", buff ); 
				fprintf( fid, "Content-Transfer-Encoding: base64\n" ); 
				fprintf( fid, "\n" ); 
				base64_encode( attach );
				remove_temp++;
			}
			fid2 = fopen( attach, "ra" );
			if (fid2!=NULL) { 		/* if original file exists */
				while (fgets( buff, sizeof(buff), fid2 )!=NULL) {
					fputs( buff, fid );
				}
		 		fclose( fid2 );
			} 
			if (remove_temp) { remove( attach ); }	/* delete encoded file */
			if (MIME=='Y') { fprintf( fid, "--boundary--\n" ); }
		}
		fclose( fid );
	}
	if (result==MM_Edit) {
		if (call_editor( article, prefs.external_editor )>=0) {
			handle_redraw_event();
			/* redisplay dialog for Send or Cancel */
			rsrc_gaddr(R_TREE,Mail_Message,&dlog);
			set_crossed( dlog, MM_CopyToSelf, toself=='Y' );
			set_tedinfo( dlog, MM_To, to );
			set_tedinfo( dlog, MM_Cc, cc );
			set_tedinfo( dlog, MM_Subject, subject );
			set_tedinfo( dlog, MM_Attach, attach );
			set_crossed( dlog, MM_AppendSig, prefs.append_signature=='Y' );	
			Button_Disable(MM_Edit);			/* disable Edit */
			dlog[MM_Edit].ob_flags&=~DEFAULT;	/* not Default	*/
			Touch_Off(MM_Attach);				/* disable Attach */

			result = handle_dialog(dlog, MM_To );

			Touch_On(MM_Attach);				/* enable Attach */
			Button_Enable(MM_Edit);				/* enable Edit	 */
			dlog[MM_Edit].ob_flags|=DEFAULT;	/* reset Default */
		}
	}
	if (result==MM_Send) {
		get_crossed( dlog, MM_AppendSig, &prefs.append_signature );	
		handle_redraw_event();
		result = try_mail( article, to, cc, toself, TRUE );
		add_to_outbox(article, subject, to, result);
		if (org==0&&current_mail>=0) { mailbox[current_mail].status[1]=newstatus; }
	}
	if (result==MM_Queue) {
		get_crossed( dlog, MM_AppendSig, &prefs.append_signature );	
		graf_mkstate( &dummy, &dummy, &dummy, &state );
		if (state&3) { result = -1; } 	/* if either Shift key, Incomplete status */
			else { result = FALSE; }	/* Queued status */
		handle_redraw_event();
		add_to_outbox(article, subject, to, result);
		if (org==0&&current_mail>=0) { mailbox[current_mail].status[1]=newstatus; }
	}
}

/* issuer mail_to() and check for "bad" address response, display alert */
int mail_to_check( char *user )
{
	int x;
	char temp[100];

	x = mail_to( user );
	if (memcmp(header, "550", 3)==0) {
	/*	sprintf( temp,"[1][%.26s|%.26s][ Continue, Cancel ]", header+4, user ); */
		sprintf( temp, ErrMsg(EM_UnknownMail), user );	/* Unknown Mail Recipient */
		x = form_alert( 1, temp );
		if (x!=1) { x = mail_reset(); return(1); }	/* cancel with reset */
	}
	return(0);
}


int try_mail(char *path, char *to, char *cc, char toself, int close_connection )
{
	int x,rc=0,reset=0;			/* rc=0=not sent (i.e failure) */
	int send_hello;
	char status[80];

	send_hello=(mcn<0);		/* true if connection not open */

	if (mcn<0) {	/* if no connection exists */
		if (STiK>0) {	/* and STiK is in system */
			sprintf( status, ErrMsg(EM_ConnectTo), prefs.mail_server ); /* "Connect: %s" */
			show_status( status );
			x = mail_connect( prefs.mail_server );
		}
	}
	if (mcn>=0) {
		append_signature( path );
		show_status( ErrMsg(EM_SendingMail) );
		if (send_hello) { x = mail_hello(); }
		strcpy( status, prefs.email_address );
	/*	sprintf( status, "%s (%s)", prefs.email_address, prefs.full_name ); */
	/*	sprintf( status, "%s <%s>", prefs.full_name, prefs.email_address ); */ 

		x = mail_from( status );
		if (strchr( to, '@' )==NULL) { reset = expand_nickname( to ); }
		else {
			strcpy( status, to );
			strtoka( status, ' ' );		/* remove possible full name */
		/*	x = mail_to( status ); */
			reset = mail_to_check( status );
		}

		if (reset==0) {
			if (cc[0]!='\0') {	/* support for cc: */
				if (strchr( cc, '@' )==NULL) { reset = expand_nickname( cc ); }
				else {
					strcpy( status, cc );
					strtoka( status, ' ' );		/* remove possible full name */
				/*	x = mail_to( status ); */
					reset = mail_to_check( status );
				}
			}
		}

		if (reset==0) {
			if (toself=='Y') { x = mail_to( prefs.email_address ); }
			x = mail_data( path );
		}

		if (close_connection) { x = mail_quit(); }
		rc = !reset;	/* its good if not reset */
	} else { status_text( ErrMsg(EM_NoConnect) ); }
	hide_status();
	return(rc);
}

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
			if (pos>20000) { show_warning( ErrMsg(EM_SizeFile) ); }	/* Sizing file... */
			while (fgets( buff, sizeof( buff), fid )!=NULL) { count++; }
			if (pos>20000) {
				use_status(status_window());	/* duplicate window index */
				hide_status();
			}
			fclose( fid );
		}
	}
	return(count);
}

long filesize( char *filename )
{
	FILE *fid;
	int x;
	long count=0;
	fpos_t pos;

	fid = fopen( filename, "ra" );
	if (fid!=NULL) {		/* if file exists... */
		x = fseek( fid, 0, SEEK_END );
		x = fgetpos( fid, &pos );
	/*	fprintf( log, "Size of %s is %ld\n", filename, pos ); */
		count = (long)pos;
		fclose( fid );
	}
	return(count);
}

int subject_cmp( const void *a, const void *b )
{
	const struct mbox *ma,*mb;
	ma=a;
	mb=b;
	
	return ( strcmp( ma->subject, mb->subject ) );
}

int author_cmp( const void *a, const void *b )
{
	const struct mbox *ma,*mb;
	ma=a;
	mb=b;

	return ( strcmp( ma->author, mb->author ) );
}

long format_datetime(const char *in)
{
	register int c;
	int day,year;
	char mon[4],time[20],t;
	char mth[12][3]={"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"};

	if (in[0]=='\0') { return(1996*400); }	/* empty date string */
	if (strchr( in, ' ' )==NULL) { return(1996*400); }	/* invalid date string */
 
	if (in[0]<='9') {
		sscanf( in, "%d %s %d", &day, mon, &year );
	} else {
		sscanf( in, "%s %d %d%c", mon, &day, &year, &t );
	/*	if (year<96) { fprintf(log, "year=%d t=%c\n", year, t); } */
		if (t==':') {
			sscanf( in, "%s %d %s %d", mon, &day, time, &year );
		}
	}
	for (c=0;c<12;c++) {
		if (memcmp(mon,mth[c],3)==0) { break; }
	}
	if (year<50) { year+=2000; }	/* good thru 2050 */
	if (year<100) { year+=1900; }
/*	fprintf( log, "%d %.3s %d %d\n", day, mon, year, c ); */
	return((year*400)+(c*31)+day);
}

int date_cmp( const void *a, const void *b )
{
/*	long da,db; */
	const struct mbox *ma,*mb;
	ma=a;
	mb=b;

/*	da=format_datetime( ma->datetime ); */
/*	db=format_datetime( mb->datetime ); */
/*	return ( (int)(da - db) ); */
  	return ( (int)(ma->cmpdate - mb->cmpdate) );
}

int date_descending_cmp( const void *a, const void *b )
{
/*	long da,db; */
	const struct mbox *ma,*mb;
	ma=a;
	mb=b;

/*	da=format_datetime( ma->datetime ); */
/*	db=format_datetime( mb->datetime ); */
/* 	return ( (int)(db - da) ); */
  	return ( (int)(mb->cmpdate - ma->cmpdate) );
}

void sort_mailbox( int key )
{
	int c;

	if ((key==2)||(key==4)) {
	 	if (mailbox[0].cmpdate==0) {	/* need to calculate */
			for (c=0;c<maximum_mail+1;c++) {
				fprintf( log, "c=%d date=%s\n", c, mailbox[c].datetime ); fflush(log);
				mailbox[c].cmpdate = format_datetime( mailbox[c].datetime );
			}
		}
	}

	switch (key)
	{
	case 1:
		qsort( mailbox, maximum_mail+1, sizeof(struct mbox), author_cmp );
		break;
	case 2:
		qsort( mailbox, maximum_mail+1, sizeof(struct mbox), date_cmp );
		break;
	case 3:
		qsort( mailbox, maximum_mail+1, sizeof(struct mbox), subject_cmp );
		break;
	case 4:
		qsort( mailbox, maximum_mail+1, sizeof(struct mbox), date_descending_cmp );
		break;
	}	
	refresh_clear_window( windows[6].id );
}

/* create method to save/restore screen memory via vro_cpyfm() */
/* uses dlog[0] for x,y,w,h of screen area */

int save_restore_screen( int sr, OBJECT *dlog )
{
	MFDB screen;
	static MFDB save;
	int points[8],ret=0;
	size_t size;
	long *mem,*sz;

	if (_AESglobal[0]<0x0140) { return(0); }	/* no WF_SCREEN before 1.4 */
	screen.fd_addr=0L;			/* initialize screen MFDB */
	wind_get( 0, WF_SCREEN, &points[0], &points[1], &points[2], &points[3] );
	mem=(long *)&points[0];
	sz=(long *)&points[2];
/*	fprintf( log, "Buffer at %p, size %ld\n", *mem, *sz );  fflush( log ); */
/*	return(ret);				/* given up on this... */

	if (sr) {	/* sr=1 = save */
		save.fd_addr=NULL;					/* build save MFDB */
		save.fd_w=dlog[0].ob_width-1;
		save.fd_h=dlog[0].ob_height-1;
		save.fd_wdwidth=(save.fd_w+16)/16;
		save.fd_stand=0;					/* ST specific format */
		vq_extnd( handle, 1, work_out );
		save.fd_nplanes=work_out[4];
		vq_extnd( handle, 0, work_out );	/* reload v_opnvwk values */

		size = save.fd_wdwidth * save.fd_h;	/* allocate memory for image */
		size = size * 2 * save.fd_nplanes; 
	/*	fprintf( log, "Attempting to Allocate %ld bytes of screen save memory for %d by %d by %d\n", size, save.fd_w, save.fd_h, save.fd_nplanes ); fflush( log ); */
		if (*sz>=size) {
			save.fd_addr=(int *)*mem;	
		/*	fprintf( log, "Buffer at %p\n", save.fd_addr ); fflush( log ); */

			/* establish points */
			points[0]=dlog[0].ob_x;			/* source is screen */
			points[1]=dlog[0].ob_y;
			points[2]=points[0]+dlog[0].ob_width-1;
			points[3]=points[1]+dlog[0].ob_height-1;
			points[4]=points[5]=0;			/* dest is save */
			points[6]=dlog[0].ob_width-1;
			points[7]=dlog[0].ob_height-1;
			
	 		graf_mouse( M_OFF, NULL );
			vro_cpyfm( handle, S_ONLY, points, &screen, &save );
			graf_mouse( M_ON, NULL );

			ret=1;
		} else {
			fprintf( log, "Buffer too small for %ld bytes\n", size ); fflush( log );
		}
	} else {	/* restore */
		if (save.fd_addr!=NULL) {
		/*	fprintf( log, "Screen memory at %p\n", save.fd_addr ); fflush( log ); */

			/* establish points */
			points[0]=points[1]=0;			/* source is save */
			points[2]=dlog[0].ob_width-1;
			points[3]=dlog[0].ob_height-1;
			points[4]=dlog[0].ob_x;			/* dest is screen */
			points[5]=dlog[0].ob_y;
			points[6]=points[4]+dlog[0].ob_width-1;
			points[7]=points[5]+dlog[0].ob_height-1;
			
	 		graf_mouse( M_OFF, NULL );
			vro_cpyfm( handle, S_ONLY, points, &save, &screen );
			graf_mouse( M_ON, NULL );

			save.fd_addr=NULL;
			ret=1;
		} else {
			fprintf( log, "Unable to restore screen memory\n" );  fflush( log );
		}
	}
/*	fprintf( log, "Returning from save_restore_screen()\n" );  fflush( log ); */
	return(ret);
}

/* popup_menu for mail_transfer, and other popup file lists */

/* return value of pointer if non_null, or NULL if null pointer */
/*
void * px( void **p )
{
	if (p!=NULL) { return( *p ); } else { return( p ); }
}
*/

/* encapsulate menu block data without requiring global definition */
int get_set_menu_blocks( int get_set, char *type, MENU **menu, OBJECT **tree, char far ***pointers, char **buff )
{
	struct menuAttach {
		MENU ma_menu;
		OBJECT ma_tree[45];
		char far *ma_pointers[45];
		char *ma_buff;
	} static far menu_block[4];
	int c,which=-1;
	static int first_time=1;

	if (first_time) {
		first_time=0;	/* no longer first_time */
		for (c=0;c<4;c++) {	/* initialize */
			initialize_attached_menu_block( &menu_block[c].ma_menu );
			menu_block[c].ma_buff=NULL;
		}
		if (get_set==-1) { return(1); }	/* initialize */
	}
	
	if (strstr(type,"grp")) { which=0; }
	if (strstr(type,"abk")) { which=1; }
	if (strstr(type,"mbx")) { which=2; }
	if (strstr(type,"inf")) { which=3; }
	
	if (which<0) { return(0); }

	if (get_set==1)	{	/* set? */
		menu_block[which].ma_buff=*buff;	/* buffer address is only setable parm */ 
	}
	if (get_set==0) {	/* allow for NULL entries in parameter list */
		if (menu)  *menu = &menu_block[which].ma_menu;
		if (tree)  *tree = menu_block[which].ma_tree;
		if (pointers)  *pointers = menu_block[which].ma_pointers;
		if (buff)  *buff = menu_block[which].ma_buff;
	/*	fprintf( log, "gsmb menu=%p, tree=%p, pointers=%p, buff=%p\n", menu, tree, pointers, buff ); */
	/*	fprintf( log, "gsmb menu=%p, tree=%p, pointers=%p, buff=%p\n", px(menu), px(tree), px(pointers), px(buff) ); */
	}
#if (0)
	if (get_set==-1) {	/* initialize */
		for (c=0;c<4;c++) {
			initialize_attached_menu_block( &menu_block[c].ma_menu );
			menu_block[c].ma_buff=NULL;
		}
	}
#endif
	return(1);
}

int get_menu_block( char *type, MENU **menu, OBJECT **tree, char far ***pointers, char **buff )
{
	return( get_set_menu_blocks( 0, type, menu, tree, pointers, buff ) );
}

int set_menu_block( char *type, char **buff )
{
	return( get_set_menu_blocks( 1, type, NULL, NULL, NULL, buff ) );
}

/*
int init_menu_block( void )
{
	return( get_set_menu_blocks( -1, NULL, NULL, NULL, NULL, NULL ) );
}
*/

/* examples of use */
/*	get_menu_block( "grp", &menu, &tree, &pointers, &buff ); */
/*	set_menu_block( "grp", buff ); */	/* NOT &buff! */

char *fill_file_menu_trees(OBJECT *tree, char *mailbox, char far **pointers, const char *mask)
{
	int c;
	long count;
	char *files=NULL;
	static char new[10]="  new  ";

	pointers[1] = new;
	if ((files = malloc( 500 ))!=NULL) {	/* allocate 500 byte buffer */
		chdir( mailbox );
		if ((count = getfnl( mask, files, 500, 0 ))>0) {
			if (strbpl(&pointers[2],40,files)==count) {
			/*	fprintf( log, "%s contains %ld files\n", dir, count ); */
				strsrt( &pointers[2], count );

				count++;
				for (c=1;c<=count;c++) {
					objc_add( tree, ROOT, c );
					strtoka(pointers[c],'.');
					tree[c].ob_spec=pointers[c];
				}
				tree[ROOT].ob_height=16*(short)count;
			}
		}
		if (tree[ROOT].ob_head==NIL) { free( files ); files=NULL; }	/* release storage */
		chdir( program_path );
	}
	return( files );
}

void update_file_menu(char *type)
{
	char dirname[FMSIZE],mask[12];
	MENU *menu=NULL;
	OBJECT *tree=NULL;
	char far **pointers=NULL;
	char *buff=NULL;

	if (get_menu_block( type, &menu, &tree, &pointers, &buff )==0) { return; }
	if ((_AESglobal[0]>=0x0330)&&(prefs.experimental[1]!='N')) {	/* attach unless 'N' */
/*	if (_AESglobal[0]>=0x0330) {	/* if menu_popup() is available */
		if (buff!=NULL) { free( buff ); }
		initialize_file_menu_trees( tree, pointers, 45 );
		sprintf( mask, "*.%s", type );

		if (strcmpi(type,"grp")==0) {
			sprintf( dirname, "%s\\", prefs.work_path );
		}
		if (strcmpi(type,"abk")==0) {
			sprintf( dirname, "%s\\", program_path );
		}
		if (strcmpi(type,"mbx")==0) {
			sprintf( dirname, "%s\\", prefs.mail_path );
		}
		if (strcmpi(type,"inf")==0) {
			sprintf( dirname, "%s\\", program_path );
		}

		buff = fill_file_menu_trees( tree, dirname, pointers, mask );
		if (buff!=NULL) { menu->mn_tree=tree; }	/* establish menu attach */
		set_menu_block( type, &buff );
	}
}

void rebuild_attach_list( char *filename, char *type )
{
	struct FILEINFO info;
	FILE *fid;

	if (dfind( &info, filename, 0 )) {	/* if file does not exist */
		fid = fopen( filename, "wa" );	/* create file */
		if (fid!=NULL) {		/* if successful */
			fclose( fid );		/* close created file and */
			update_file_menu( type );	/* update "mbx", "abk", "inf", or "grp" list */
		}
	}
}

void initialize_attached_menus(void)
{
	update_file_menu( "grp" );
	update_file_menu( "abk" );
	update_file_menu( "mbx" );
	update_file_menu( "inf" );
}

/* attach sub-menus when a menubar is installed */
void attach_submenus(void)
{
	MENU *menu=NULL;
/*	char *buff; */

	initialize_attached_menus();	/* fill in object trees if AES 3.30 or greater */

	if (get_menu_block( "mbx", &menu, NULL, NULL, NULL )) {
		if (menu->mn_tree!=NULL) { menu_attach( 1, menu_ptr, MM_OpenMailbox, menu ); }
	}
	if (get_menu_block( "grp", &menu, NULL, NULL, NULL )) {
		if (menu->mn_tree!=NULL) { menu_attach( 1, menu_ptr, MF_NewGroup, menu ); }
	}
	if (get_menu_block( "abk", &menu, NULL, NULL, NULL )) {
		if (menu->mn_tree!=NULL) { menu_attach( 1, menu_ptr, MM_OpenAddress, menu ); }
	}
	if (get_menu_block( "inf", &menu, NULL, NULL, NULL )) {
		if (menu->mn_tree!=NULL) { menu_attach( 1, menu_ptr, MP_Load, menu ); }
	}
}

void initialize_file_menu_trees(OBJECT *tree, int number)
{
	int c;

	for (c=0;c<number;c++) {
		tree[c].ob_next=NIL;	tree[c].ob_head=NIL;	tree[c].ob_tail=NIL;
		tree[c].ob_type=G_STRING;
		tree[c].ob_flags=SELECTABLE;
		tree[c].ob_state=0;
		tree[c].ob_x=0;
		tree[c].ob_y=((c-1)*16);	
		tree[c].ob_width=64;	/* 8*8 */
		tree[c].ob_height=16;
	/*	if (prefs.experimental[0]=='Y') { tree[c].ob_flags|=FL3DBAK; } */
	}
	tree[ROOT].ob_y=0;	
	tree[ROOT].ob_type=G_BOX;
	tree[ROOT].ob_flags=0;
	tree[ROOT].ob_state=SHADOWED;	/* OUTLINED+ */
	tree[ROOT].ob_spec=(void *)0x00ff1170;
/*	if (prefs.experimental[0]=='Y') {
		tree[ROOT].ob_flags|=FL3DBAK;
		tree[ROOT].ob_spec=(void *)0x00ff1101;	/* hollow, black */
/*	}	/* background color */
}

int filelist_popup(char *mailbox, char *mask)
{
	OBJECT *tree=NULL;
	int ret=1;
	char dir[FMSIZE];
	char *flist=NULL;
	char far **pointers=NULL;

	get_menu_block( mask, NULL, &tree, &pointers, &flist );
/*	fprintf( log, "flpop tree=%p, pointers=%p, buff=%p\n", tree, pointers, flist ); */

	if (tree==NULL)	tree = (void *)header;
	strcpy( dir, mailbox );
	if (_AESglobal[0]>=0x0330) {	/* if menu_popup() is available */
		if (flist==NULL) {	/* if filelist has not been created */
	 		initialize_file_menu_trees( tree, 45 );
			flist = fill_file_menu_trees( tree, mailbox, pointers, mask);
			set_menu_block( mask, &flist );	/* don't need to keep building */
		}

		if (flist) {
			ret=do_popup_filelist( tree );
			if (ret) {
				sprintf( mailbox, "%s%s%s", dir, pointers[ret], mask+1 );
			/*	fprintf( log, "[%d] %s %s %s", ret, pointers[ret], tree[ret].ob_spec, mailbox ); */
			}
		}

	}
	return(ret);
}

int do_popup_filelist( OBJECT *tree )
{
	int result,rc;
	MENU pop1,pop2;
	OBJECT *box;
	int mx,my,btn,state;

	graf_mkstate( &mx, &my, &btn, &state );
	pop1.mn_tree=tree;
	pop1.mn_menu=ROOT;
	pop1.mn_item=1;
	pop1.mn_scroll=1;	/* 0 = no scrolling */
	mx&=0xfff8;
	my&=0xfff8;
	box = pop1.mn_tree;
	if (box->ob_width+mx>screenw) { mx=screenw-box->ob_width; }
	if ((rc=menu_popup( &pop1, mx, my, &pop2 ))) {
		popup_works(rc);		/* indicate popups do work! */
		result=pop2.mn_item;
		return(result);
	}
	return(!popup_works(rc));	/* 0=cancel, 1=popup failed */
}

#define REGISTRAR "rojewski@primenet.com (John Rojewski)"

/* build email request message with specific subject for me/NEWSie to receive */

#define MiNT	0x4d694e54
#define _AKP	0x5f414b50
#define MagX	0x4d616758

void print_configuration_info( FILE *fid )
{	
	long clist[] = { _MCH, _SND, _AKP, MagX, MiNT, 0 };
	long p,value,i=0;

	if (STiK) {
		fprintf( fid, " STiK = %s %s\n", tpl->version, tpl->author );
	}
	fprintf( fid, "  AES = %0.4x\n", _AESglobal[0]);
	while (p=clist[i++]) {
		if (getcookie( p, &value)) { fprintf( fid, " %4.4s = $%0.8lx\n", &p, value ); }
	}  
}

void send_registration_info(void)
{
	char article[FMSIZE];
	char to[50],subject[50],cc[2]="";
	int result;
	FILE *fid;

	/* create mailtest.txt message with header and try_mail() */
	sprintf( article, "%s\\%s", prefs.work_path, MAILTEST );
	if ((fid=fopen( article, "wa" ))!=NULL) {
		strcpy( to, REGISTRAR );
		strcpy( subject, "Request NEWSie Registration #" );
		fprintf( log, "%s\n", subject ); fflush( log );
	
		fprintf( fid, "To: %s\n", to );
		fprintf( fid, "From: %s (%s)\n", prefs.email_address, prefs.full_name ); 
		fprintf( fid, "Organization: %s\n", prefs.organization );
		fprintf( fid, "Subject: %s\n", subject );
		fprintf( fid, "X-Mailer: NEWSie Version %.4s (Atari)\n", VERSION );
		fprintf( fid, "\n" );
		print_configuration_info( fid );
		fclose( fid );
		result = try_mail( article, to, cc, prefs.copies_to_self, TRUE );
		add_to_outbox(article, subject, to, result);
	}
}

/* killfile processing */

char * buffer_killfile(int which, char *buffer)
{
	static char *killfile=NULL,*next=NULL;
	char *p=NULL;
	struct FILEINFO finfo;
	FILE *fid;

	switch (which)
	{
		case 0:		/* unload */
			if (killfile!=NULL) {	/* currenty loaded? */
				free(killfile);
				killfile=NULL;
			}
			break;
		case 1:		/* load */
			if (killfile) {	/* already loaded? */
				p=next=killfile;	/* yes, rewind first */
				break;
			}
			if (!dfind(&finfo, buffer, 0)) {	/* locate file and size */
				if ((killfile = malloc( finfo.size+1 ))!=NULL) {
					if ((fid = fopen( buffer, "ra" ))!=NULL) {
						fread( killfile, finfo.size, 1, fid ); 
						fclose( fid );
						*(killfile+finfo.size)='\0';
					}
				}
			}
			p=next=killfile;
			break;
		case 2:		/* read next */
			if (killfile==NULL) { break; }
			if (next==NULL) { break; }
			buffer[0]='\0';		/* empty */
			if ((p=strchr( next, '\n' ))!=NULL) {
				strncpy( buffer, next, p-next+1 );
				buffer[p-next+1]='\0';	/* null terminate */
				next=p+1;
				if (*next=='\0') { next=NULL ; }
			} else {
				strcpy( buffer, next );
				next=NULL;
			}
			p=buffer;	/* start of buffer */
			break;
		case 3:		/* rewind */
			p=next=killfile;
			break;
	}
	return(p);
}

#define load_killfile(x) buffer_killfile(1, x)
#define next_killfile(x) buffer_killfile(2, x)
#define rewind_killfile() buffer_killfile(3, NULL)


void auto_mail_transfer( char *newbox, char * filename )
{
	FILE *fid;

	char author_name[60],author_email[60];
	char mbx[FMSIZE];
	int lines;

	sprintf( mbx, "%s\\%s.mbx", prefs.mail_path, newbox ); 

	/* determine if mailbox is not expandable and in danger of overflow */
	if (prefs.dynamic_expansion!='Y') {		/* not expandable */
		lines = (int16)count_lines( mbx );
		if (lines>=MAILBOX_SIZE) { return; }			/* too large, ignore request */
	}

	fid = fopen( mbx, "aa" );
	if (fid!=NULL) {
		simplify_author( mail_hdr.from, author_name, author_email );
		if (mail_hdr.reply_to[0]!='\0') { strcpy( author_email, mail_hdr.reply_to ); }
		lines = (int16)count_lines( filename );
		mail_hdr.status[2]='*';		/* automation */

		fprintf( fid, "%-4.4s\t%-.49s\t%s\t%s\t%-.21s\t%s\t%d\n",
			mail_hdr.status, mail_hdr.subject, author_name,
			author_email, mail_hdr.datetime,
			filename, lines );
		fclose( fid );
		mail_hdr.subject[0]='\0';	/* transfered */
	}
}

int killfile_find( char *what, char *where, char *action, char *value, char *filename )
{
	char *p;
	int ret=0;

	if ((stcpm( where, what, &p))!=0) {
		ret++;			/* set return code = found */
		fprintf( log, "Killfile for %s %s %s\n", what, action, value );
		switch (action[0]) {
			case 's':	mail_hdr.status[1]=*value;
						mail_hdr.status[2]='*';
						break;
		/*	case 't':	break; */
			case 't':	auto_mail_transfer( value, filename );	break;
			case 'r':	break;
		}
	}
	return(ret);
}

void killfile_text( char *filename )
{
/*	FILE *fid; */
	char buff[200],*find,*text,*action,*value;
	int rc=0;

	sprintf( buff, "%s\\%s", prefs.work_path, "killfile.txt" );
/*	if ((fid=fopen( buff, "ra" ))!=NULL) { */
	if (load_killfile( buff )!=NULL) {
/*		while ((fgets( buff, sizeof(buff), fid))!=NULL) { */
		while ((next_killfile(buff))!=NULL) {
			if (buff[0]=='#') { continue; }	/* comment */
			buff[strlen(buff)-1]='\t';	/* append tab */
			find = strtoka( buff, '\t' );
			text = strtoka( NULL, '\t' );
			action = strtoka( NULL, '\t' );
			value = strtoka( NULL, '\t' );

			switch (find[0]) {
				case 's':  rc=killfile_find( text, mail_hdr.subject, action, value, filename );	break;
				case 'a':  rc=killfile_find( text, mail_hdr.from, action, value, filename );	break;
				case 'e':  rc=killfile_find( text, mail_hdr.from, action, value, filename );	break;
				case 'd':  rc=killfile_find( text, mail_hdr.from, action, value, filename );	break;
				case 't':  rc=killfile_find( text, mail_hdr.to, action, value, filename );		break;
				case 'r':  rc=killfile_find( text, mail_hdr.reply_to, action, value, filename );	break;
			}
			if (rc) { break; }
		}
	/*	fclose( fid ); */
	}
}

/* receive email and produce automated responses */

void receive_mail_automation( char *filename )
{
	receive_registration_response();
	receive_registration_request();
	killfile_text( filename );
}

/* receive email response message with subject w/registration number */
void receive_registration_response(void)
{
	char cprefs[FMSIZE];

	if (memcmp(mail_hdr.subject, "NEWSie Registration #", 21)==0) {
		memcpy(prefs.registration_number, mail_hdr.subject+21, 6);
		status_text( "Receiving Registration Number" );
		strcpy( cprefs, current_preferences );
		save_preferences( cprefs );
		fprintf( log, "%s Received\n", mail_hdr.subject ); fflush( log );
	}
}

/* receive request from users to register NEWSie - should ONLY be me */
void receive_registration_request(void)
{
	if (memcmp(mail_hdr.subject+8, "NEWSie Registration #", 21)==0) {
		if (memcmp(prefs.email_address, REGISTRAR, 12)==0) {
			status_text( "Receiving Registration Request" );
			fprintf( log, "%s from %s\n", mail_hdr.subject, mail_hdr.from ); fflush( log );
		}
	}
}


/* end of MAILER.C */
