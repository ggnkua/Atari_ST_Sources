/*
 * NEWSie - an Internet NewsReader Program with GEM Interface
 *
 * Created by: John Rojewski - 06/28/96
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
#include <errno.h>
#include "newsie.h"
#include "protocol.h"

unsigned long _STACK=8192; /* 16384; */		/* 16K stack breaks Magic */

#define VERSION "0.961 Jul 27, 2000"
#define MAX_MENU_ITEM MP_Save	/* change when Menu (NEWSie) is updated */
#define MT _AESglobal[1]!=1		/* Multi-tasking OS */
#define VIEWED '\x08'
#define G_INVALID '?'
/* #define OK "+OK" */
#define ErrMsg(a) (char *)em[a].ob_spec
#define dlogMsg(a) (char *)dlog[a].ob_spec
#define OFFLINE (ncn<0)&&(prefs.offline_test=='Y')
#define MAX(x,y) ( (x) > (y) ? (x) : (y) )
#define NEWSTEST "newstest.txt"
#define XOVER "xover.txt"
#define FULLGRP "fullgrp.txt"
#define NEWGRP "newgrp.txt"

#include "global.h"		/* global variable definitions */

/*the following include in module protocol.c:
#include "cabovl.c"
#include "john.c"
#include "nntp.c"
#include "smtp.c"
#include "pop3.c"
*/

/* the following include in module mailer.c:
#include "mailer.c"  */

/* the following include in module newsaes.c:
#include "newsaes.c"  */
void log_msg_status( long num, long value );	/* prototype from newsaes.c */
int info_line( int wx, char *info );			/* prototype from newsaes.c */

char *strtoka( char *s, int tok );	/* prototype from mailer.c */
long filesize( char *filename );	/* prototype from mailer.c */
long count_lines( char *filename );	/* prototype from mailer.c */
int filelist_popup(char *mailbox, const char *mask); /* prototype from mailer.c */

void open_url_path(char *url);		/* prototype from browser.c */

/* #include "dialogs.c" */
#include "offline.c"

void parse_group_header(int c, char *header, long recent, char *name)
{
	char code[10], number[10], first[10], last[10], gname[100]; /*, posting[10];*/
	long f=0,l,recent_articles;

	if (prefs.recent_articles[0]<'0') { strcpy(prefs.recent_articles, "1000"); }
	recent_articles = atol( prefs.recent_articles );

	sscanf( header, "%s %s %s %s %s", code,
					number, first, last, gname); /*, posting );*/

	if (strcmp( name, gname )!=0) {		/* same newsgroup? */
		strcpy( gname, name );			/* no, use original name */
		f=recent; l=recent-1;			/* default to recent article */
	} else {
		l = atol( last );
		f = atol( first );
	}
	if (recent>(l+1)) { recent=0; }

	f = (recent > f) ? recent : f;	/* maximum */
	if ((l-f)>recent_articles) { f = l-recent_articles; }
	group[c].first_msg = f;
	group[c].last_msg = l;
	group[c].num_msgs = l - f + 1;
	if ((l+f)==0) { group[c].num_msgs = 0; }	/* special case */

 	strcpy( group[c].name, gname );
/*	fprintf( log, "%d %s %ld\n", c, group[c].name, group[c].first_msg ); */
	group[c].posting_allowed = 'Y'; /*posting[0];*/
	group[c].viewed = ' ';
	if (code[0]=='4') { group[c].viewed = G_INVALID; }
	count_offline_msgs(c);
}

void count_offline_msgs(int c)
{
	FILE *fid;
	char temp[10];
	char path[FMSIZE];

	if (OFFLINE) {	/* look for OFFLINE path */
		newsgroup_to_directory( group[c].name, temp );
		sprintf( path, "%s\\%s", article_path, XOVER );
		fid = fopen( path, "ra" );
		if (fid!=NULL) { 	/* file exists... */
			fclose( fid );
			group[c].num_msgs = count_lines( path ); 
		}
		else { strcpy( article_path, prefs.work_path ); }
	}
}

void load_group(char *filename)
{
	FILE *fid;
	int rc,c;
	long recent;
	char name[100],temp[100];

	graf_mouse( BUSY_BEE, NULL );
	current_group = -1;
	maximum_group = -1;
	fid = fopen( filename, "ra" );
	if (fid!=NULL) {
		for (c=0;c<GROUP_SIZE;c++) {
			if (fscanf( fid, "%s %ld", name, &recent )!=EOF) {
				strcpy( temp, name );
				temp[30]='\0';	/* truncate newsgroup name to fit */
				if (ncn>=0) {	/* are we online? */
					show_status( temp );
					rc = news_group( name );
					if (rc!=0) {	/* if any error */
						sprintf( header, "211 0 %ld %ld %s Y", recent, recent-1, name );
					}
				} else {
					status_text_nolog( temp );
					sprintf( header, "211 0 %ld %ld %s Y", recent, recent-1, name );
				}
				if (header[0]=='4') { /* 411 no such group */
					 sprintf( header, "411 0 %ld %ld %s Y",  recent, recent-1, name ); }
				parse_group_header( c, header, recent, name);
				maximum_group = c;
			} else { group[c].name[0] = '\0'; }
		}
		fclose( fid );
	}
	graf_mouse( ARROW, NULL );
	windows[1].num_lines=maximum_group;
	windows[1].line_no=0;
}

void unload_group( char *filename )
{
	FILE *fid;
	int c;

	if (maximum_group==-1) { return; }		/* nothing loaded */
	fid = fopen( filename, "wa" );
	if (fid!=NULL) {
		for (c=0;c<GROUP_SIZE;c++) {
			if (group[c].name[0]!='\0') {
				fprintf( fid, "%s %ld\n", group[c].name, group[c].first_msg );
			}
		}
		fclose( fid );
	}
}

void expand_overview()
{
	int new_size,x;
	size_t new_bytes;
	void *new_ovr,*new_thr;
	char *alert;
	char temp[80];

	new_size  = 2 * OVERVIEW_SIZE;
	new_bytes = new_size * sizeof( struct xoverview );
	new_ovr   = realloc( overview, new_bytes );
	if (!new_ovr) {
	/*	sprintf( temp,"[1][Insufficient Memory for %s][ Sorry ]", "|Overview" ); */
		rsrc_gaddr(R_STRING,Insuff_Memory,&alert); /* Insufficient Memory for ... */
		sprintf( temp, alert, "Overview" );
		form_alert( 1, temp );
		return;				/* failed */
	}
	overview = new_ovr;
	for (x=OVERVIEW_SIZE;x<new_size;x++) {	/* clear new entries */
	/*	overview[x].subject[0] = '\0'; */
		memset( &overview[x], 0, sizeof( struct xoverview ) );
	}

	new_bytes = new_size * sizeof( struct athread );
	new_thr   = realloc( threads, new_bytes );
	if (!new_thr) {
	/*	sprintf( temp,"[1][Insufficient Memory for %s][ Sorry ]", "|Threads" ); */
		rsrc_gaddr(R_STRING,Insuff_Memory,&alert); /* Insufficient Memory for ... */
		sprintf( temp, alert, "|Threads" );
		form_alert( 1, temp );
		return;				/* failed */
	}
	threads = new_thr;
	OVERVIEW_SIZE = new_size;
	fprintf( log, "Overview and Threads expanded to %d entries\n", new_size );
	fflush(log);
}

void load_overview()
{
	FILE *fid;
	int rc=0,c,maxarticles;
	long x;
	char buff[2000];	/* XREF field can be long! */
	char temp[10];
	char *number, *subject, *author, *datetime, *msgid,
		 *refid, *bytes, *lines;
/*	char *p; */
	long last,lastmsg,len;
	char path[FMSIZE];

	current_overview = -1;
	previous_overview = -1;
	maximum_overview = -1;
	current_article[0]='\0';

	if (OFFLINE) {	/* look for OFFLINE path */
		newsgroup_to_directory( group[current_group].name, temp );
		sprintf( path, "%s\\%s", article_path, XOVER );
		fid = fopen( path, "ra" );
		if (fid!=NULL) { fclose( fid );		/* file exists... */
		/*	group[current_group].num_msgs = count_lines( path ); */ 
		}
		else { strcpy( article_path, prefs.work_path ); }
	} else { strcpy( article_path, prefs.work_path ); }

	sprintf( path, "%s\\%s", article_path, XOVER );
	if (ncn>=0) {
		c = current_group;
		rc = news_group( group[c].name ); 
	}
	maxarticles = atoi(prefs.max_articles);
	if (ncn>=0) {
		if (header[0]=='4') { 
			 sprintf( header, "411 0 1 0 %s Y", group[c].name ); }
	/*	fprintf( log, "XOVER %d %s %ld\n", c, group[c].name, group[c].first_msg ); */

		lastmsg = group[c].last_msg;
		last = lastmsg;
		if ((last-group[c].first_msg)>maxarticles) {
			last = group[c].first_msg+maxarticles-1; }
		rc = news_xover( path, group[c].first_msg, last );

		while ((filesize( path )==3)&&((group[c].first_msg+100)<lastmsg)) {
			group[c].first_msg+=maxarticles;
			group[c].num_msgs-=maxarticles;
			last = lastmsg;
			if ((last-group[c].first_msg)>maxarticles) {
				last = group[c].first_msg+maxarticles-1; }
			show_status( ErrMsg(EM_CatchUp) );		/* Catching up... */
			rc = news_xover( path, group[c].first_msg, last );
		}
	}
	fid = fopen( path, "ra" );
	if (fid!=NULL) {		/* if file exists... */
		for (c=0;c<OVERVIEW_SIZE;c++) {
			overview[c].subject[0] = '\0';
			overview[c].viewed = '\0';
			if (fgets( buff, sizeof(buff), fid )!=NULL) {
				if (c==OVERVIEW_SIZE-1) { expand_overview(); }
				if (strrchr( buff, '\n' )!=NULL) {
					if (buff[0]!='.') {
						overview[c].viewed = ' ';
						number = strtoka( buff, '\t' );
						len=strlen(number);
						if (number[len-1]=='*') {	/* offline marked as read? */
							number[len-1]='\0';
							overview[c].viewed = VIEWED;
						}
						subject = strtoka( NULL, '\t' );
						author = strtoka( NULL, '\t' );
						datetime = strtoka( NULL, '\t' );
						msgid = strtoka( NULL, '\t' );
						refid = strtoka( NULL, '\t' );
						bytes = strtoka( NULL, '\t' );
						lines = strtoka( NULL, '\t' );

						overview[c].article_number = atol(number);
			 	 		sprintf( overview[c].subject, "%.39s", subject);
						simplify_author( author, overview[c].author, overview[c].author_email );
						datetime = strpbrk( datetime, "123456789" );
					 	sprintf( overview[c].datetime, "%.21s", datetime);
					 	sprintf( overview[c].msgid, "%.80s", msgid);
						overview[c].num_bytes = atol( bytes );
						overview[c].num_lines = atol( lines );
						overview[c].refids[0] = '\0';
#if (0)
						if (refid[0]=='<') {
							while (strlen(refid) > 299) {
								p = strrchr( refid, '<' );
								p[-1] = '\0';	
							}
							sprintf( overview[c].refids, "%s", refid );
						}
#endif
						if ((strlen(refid) > 299)||(memcmp(refid,"parse",5)==0)) {
							strcpy( overview[c].refids, "parse" );
						} else {
							if (refid[0]=='<') {
								strcpy( overview[c].refids, refid );
							}
						}
						overview[c].thread = ' ';
						maximum_overview = c;
	 				}
				}
			}
		}
		create_threads();
		collapse_all_threads();
		fclose( fid );
		windows[2].num_lines=maximum_overview+1;
		windows[2].line_no=0;
	}
	if (rc==0) {	/* if a good (complete) transfer */
		if ((x=group[current_group].num_msgs)<maxarticles) {
			group[current_group].num_msgs=maximum_overview+1;
			if (x!=(maximum_overview+1)) { refresh_window( windows[1].id ); }
		}
	}
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
	rc = (int16)stcpm( both, "(?*)", &t );
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

void unload_overview()
{
	int c,count=0;
	long rc;
	FILE *fid=NULL;
	char path[FMSIZE],article[15];
	struct FILEINFO info;

	if ((current_group>=0)&&(maximum_overview>=0)) {
		if (OFFLINE) {
			sprintf( path, "%s\\%s", article_path, XOVER );
			fid = fopen( path, "wa" );
		}
		for (c=0;c<OVERVIEW_SIZE;c++) {
			if (OFFLINE) {
				if ((overview[c].viewed!='D')&&(overview[c].subject[0]!='\0')) {
					if (fid!=NULL) {
						count++;
						sprintf( article, "%ld", overview[c].article_number );
						if (overview[c].viewed==VIEWED) { strcat( article, "*"); }
						fprintf( fid, "%s\t%s\t%s (%s)\t%s\t%s\t%s\t%ld\t%ld\t%s\n",
							article, overview[c].subject,
							overview[c].author_email, overview[c].author,
							overview[c].datetime, overview[c].msgid,
							overview[c].refids, overview[c].num_bytes,
							overview[c].num_lines, overview[c].refids );
					}
				}
				if (overview[c].viewed=='D') {
					sprintf( path, "%s\\%ld.txt", article_path, overview[c].article_number );
					if (!dfind(&info, path, 0)) { /* if file does exist */
						rc=remove( path );
						if (rc) { beep(); return; }	/* error occurred */
					}
				}
			} else {
				/* read overview and update current_group.recent for articles read */
				if (overview[c].viewed!=VIEWED) { break; }
				else {
					if (overview[c].subject[0]!='\0') {
						group[current_group].first_msg = overview[c].article_number+1;
						if (group[current_group].num_msgs>0) {
							group[current_group].num_msgs--; }
					}
				}
			}
		}
		if (fid!=NULL) {
			fclose( fid );
			if (strcmp(article_path,prefs.work_path)!=0) {
				group[current_group].num_msgs=count; }
		}
	}
	current_overview = -1;
	previous_overview = -1;
	maximum_overview = -1;
	current_thread = -1;
	current_article[0]='\0';
	set_reply( 2 );
}

void determine_current_article(void)
{
	if (current_overview<0) {
		current_article[0]='\0';
		set_reply( 2 );
		return;
	}
	if (OFFLINE) {  
		sprintf( current_article, "%s\\%ld.txt", article_path, overview[current_overview].article_number );
	} else {
		current_article[0]='\0';
	}
	set_reply( 2 );
}

void create_threads()
{
	register int d,c,t=0;
	int *temp;
	int mov;

	mov = maximum_overview+1;
	current_thread = -1;
	for (c=mov;c<OVERVIEW_SIZE;c++) {
		threads[c].zero = -1;		/* not used */
		threads[c].one = -1;		/* init to: 'not a thread' */
	}
	for (c=0;c<mov;c++) {
		threads[c].zero = c;
		threads[c].one = -1;		/* init to: 'not a thread' */
		overview[c].thread = ' ';
		if (memcmp(overview[c].subject, "Re: ", 4)==0) {
			for (d=0;d<c;d++) {
			/*	if ((memcmp(overview[d].subject, overview[c].subject+4, 20)==0) ||
					(memcmp(overview[d].subject, overview[c].subject, 20)==0)) { */
				if ((strcmp(overview[d].subject, overview[c].subject+4)==0) ||
					(strcmp(overview[d].subject, overview[c].subject)==0)) {
					threads[c].one = d;
					d = c;  /* force exit after first match */
				}
			}
		}
	}
	if (prefs.create_threads=='Y') {  /* just sort, no collapse */
		temp = calloc( OVERVIEW_SIZE, sizeof( int ) );
		if (temp==NULL) { return; }
		for (c=0;c<mov;c++) {
			if ((threads[c].zero==c)&&(threads[c].one<0)) {
				temp[t++]=c; 
				for (d=c+1;d<mov;d++) {
					if (threads[d].one==c) {
						temp[t++]=d;
						overview[c].thread = '+';
						overview[d].thread = '-';
					}
				}
			}
		}
		for (c=0;c<mov;c++) { threads[c].zero = temp[c]; }
		free( temp );
	}
}

void collapse_all_threads()
{
	register int c,t=0;
	int *temp;

	if (prefs.collapse_threads=='Y') {  /* collapse sorted threads */
		temp = calloc( OVERVIEW_SIZE, sizeof( int ) );
		if (temp==NULL) { return; }

		for (c=0;c<OVERVIEW_SIZE;c++) { temp[c] = -1; }
		for (c=0;c<maximum_overview+1;c++) {
			if (threads[c].one<0) { temp[t++]=c; }
		}
		for (c=0;c<OVERVIEW_SIZE;c++) { threads[c].zero = temp[c]; }
		free( temp );
	}
}

int expand_thread(int which)
{
	int c=0,d,i,ov;
	int *temp;

/*	fprintf( log, "expand thread %d [%d][%d]\n", which, threads[which].zero, threads[which].one ); */
	ov = threads[which].zero;
	if (overview[ov].thread!='+') { return(0); }
	for (d=0;d<OVERVIEW_SIZE;d++) {	/* check for already expanded */
	/*	fprintf( log, "c %d [%d][%d]\n", d, threads[d].zero, threads[d].one ); */
		i = threads[d].zero;
		if (i<0) { break; }
		if (threads[i].one==ov) { return(0); }
	}

	temp = calloc( OVERVIEW_SIZE, sizeof( int ) );
	if (temp==NULL) { return(0); }

	do {
	/*	fprintf( log, "c %d [%d][%d]\n", c, threads[c].zero, threads[c].one ); */
		temp[c] = threads[c].zero;
		c++;
	} while ((temp[c-1])!=ov);
	d=c;
/*	fprintf( log, "d %d [%d][%d]\n", d, threads[d].zero, threads[d].one ); */
	for (i=0;i<OVERVIEW_SIZE;i++) {	/* start with first overview[] */
		if (threads[i].one==ov) {
		/*	fprintf( log, "i %d [%d][%d]\n", i, threads[i].zero, threads[i].one ); */
			temp[d++] = i;
		}
	}
	for (i=d;i<OVERVIEW_SIZE;i++) { temp[i] = threads[c++].zero; }
	for (c=0;c<OVERVIEW_SIZE;c++) { threads[c].zero = temp[c]; }
	free( temp );
	return(1);
}

int collapse_thread(int which)
{
	int c=0,d,ov,ot,x;
	int *temp;

/*	fprintf( log, "collapse thread %d [%d][%d]\n", which, threads[which].zero, threads[which].one ); */
	ov = threads[which].zero;		/* get overview index */
	ot = threads[ov].one;		/* get overview thread index */
	if (ot<0) { ot = ov; }
	if (overview[ov].thread==' ') { return(0); }
	for (d=0;d<OVERVIEW_SIZE;d++) {	/* check for already collapsed */
	/*	fprintf( log, "c %d [%d][%d]\n", d, threads[d].zero, threads[d].one ); */
		x = threads[d].zero;
		if (x<0) { return(0); }
		if (threads[x].one==ov) { break; }
		if (threads[x].one==ot) { break; }
	}

	temp = calloc( OVERVIEW_SIZE, sizeof( int ) );
	if (temp==NULL) { return(0); }

	for (d=0;d<OVERVIEW_SIZE;d++) { temp[d] = -1; }

/*	fprintf( log, "ov %d,ot %d\n", ov, ot ); */
	for (d=0;d<OVERVIEW_SIZE;d++) {
		x = threads[d].zero;
		if (x==ot) { current_thread = c; }
		if (threads[x].one!=ot) {
			temp[c++] = threads[d].zero;
		}
	}
	for (c=0;c<OVERVIEW_SIZE;c++) { threads[c].zero = temp[c]; }
	free( temp );

/*	fprintf( log, "new current_thread %d\n", current_thread ); */
	previous_overview = current_overview;
	current_overview = threads[current_thread].zero;
	determine_current_article();
	return(1);
}

void allocate_failure(char *type)
{
	char temp[80];
	char *alert;

	if (appl_init()<0) exit(EXIT_FAILURE);
	rsrc_gaddr(R_STRING,Insuff_Memory,&alert); /* Insufficient Memory for ... */
/*	sprintf( temp,"[1][Insufficient Memory for %s][ Sorry ]", type ); */
	sprintf( temp, alert, type );
	form_alert( 1, temp );
	appl_exit();
	exit(EXIT_FAILURE);
}

void allocate_startup(void)
{
	group = calloc( GROUP_SIZE, sizeof( struct newsgroups ) );
	if (!group) { allocate_failure( "Groups" ); }

	overview = calloc( OVERVIEW_SIZE, sizeof( struct xoverview ) );
	if (!overview) { allocate_failure( "Overview" ); }

	threads = calloc( OVERVIEW_SIZE, sizeof( struct athread ) );
	if (!threads) { allocate_failure( "Threads" ); }

	newgroups = calloc( NEWGROUPS_SIZE, sizeof( struct agroup ) );
	if (!newgroups) { allocate_failure( "Newgroups" ); }

	fullgroups = calloc( FULLGROUPS_SIZE, sizeof( struct agroup ) );
	if (!fullgroups) { allocate_failure( "Fullgroups" ); }

	fullgroup_index = calloc( FULLINDEX_SIZE, sizeof( size_t ) );
	if (!fullgroup_index) { allocate_failure( "Fullgroup index" ); }

	font = calloc( FONT_SIZE, sizeof( struct fontinfo ) );
	if (!font) { allocate_failure( "Fonts" ); }

	mailbox = calloc( MAILBOX_SIZE, sizeof( struct mbox ) );
	if (!mailbox) { allocate_failure( "Mailbox" ); }

	nickname = calloc( NICKNAME_SIZE, sizeof( struct nick ) );
	if (!nickname) { allocate_failure( "Nicknames" ); }

	ftp_cache = calloc( FTP_CACHE_SIZE, sizeof( struct fpath ) );
	if (!ftp_cache) { allocate_failure( "FTP cache" ); }

	filelist = calloc( FTP_FILELIST_SIZE, sizeof( struct flist ) );
	if (!filelist) { allocate_failure( "FTP directory" ); }

	server = calloc( SERVER_SIZE, sizeof( struct fservers ) );
	if (!server) { allocate_failure( "FTP servers" ); }
}

void initialize(void)
{
	struct tm *tp;
	time_t t;
	char logfile[FMSIZE],path[FMSIZE],*env,*p;
	int x,dummy,shift;
	char lang[18];

	allocate_startup();		/* allocate arrays */
	initialize_gem(0);
	for (x=0;x<WINDOWS_SIZE;x++) {
		windows[x].open=0;
		windows[x].buffer=NULL;
	}

	if (shel_read( path, logfile )) {		/* identify program path */
		if ((p=strrchr( path, '\\' ))!=NULL) {	/* look for last '\' */
			if (memcmp(p+1,"NEWSIE",6)==0) { *p='\0'; strcpy( program_path, path ); }
		} else { getcd( 0, program_path ); }
	} else {
		getcd( 0, program_path );		/* shel_read failed */
	}

	load_preferences( "prefs.inf" );
	color_menu(1);

	sprintf( logfile, "%s\\%s", prefs.work_path, "log" );
	log = fopen( logfile, "wa" );

	if (log==NULL) {	/* work_path is invalid! */
		sprintf( logfile, "%s\\%s", program_path, "log" );
		strcpy( prefs.work_path, program_path );
		log = fopen( logfile, "wa" );
	}

	time(&t);
	tp = localtime(&t);
	fprintf( log, "Log file opened: %s", asctime(tp) );
	fprintf( log, "Program Path: %s\n", program_path );
	fprintf( log, "NEWSie version: %s\n", VERSION );
/*	fprintf( log, "shel_read() path: %s\n", path ); */
/*	fprintf( log, "AES version: %04x\n", _AESglobal[0] ); */
	if (WDialog()) { fprintf( log, "WDIALOG supported\n" ); }

	if ((env = getenv( "AVSERVER" ))!=NULL) {
		fprintf( log, "AVSERVER is: %s\n", env );
	} else {
		fprintf( log, "No AVSERVER found\n" );
	}

	language_preference( lang );
/*	fprintf( log, "NEWSIE%s.RSC\n", &lang[8] );	/* 2-char language code */
/* 	fprintf( log, "Using Resource %s\n", lang ); */
	if (memcmp( &lang[8],"  ",2 )!=0) {	/* if not English */ 
	/*	menu_bar(menu_ptr,0); */
		rsrc_free();
		initialize_resource(1);
	} else {
		attach_submenus();	/* attach sub-menu trees for AES 3.3 and up */
		menu_bar(menu_ptr,1);
	}

/*	if (memcmp(prefs.last_version, VERSION, 4)!=0) {
		fprintf( log, "Preferences were not current\n" );
		save_preferences( "prefs.inf" );
		load_preferences( "prefs.inf" );	
	}
*/
	graf_mkstate(&dummy,&dummy,&dummy,&shift);
	if (shift&3) {					/* if either shift key down */
		load_preferences( "" );		/* user wants prefs choice */	
	}

	fullgroup_index[0]=0;	/* initialize index */

/*	sprintf( current_article, "%s\\%s", prefs.work_path, "article.txt" ); */
	current_article[0]='\0';
	sprintf( current_newsgroup, "%s\\%s", prefs.work_path, "default.grp" );
/*	sprintf( current_mailmsg, "%s\\%s", prefs.work_path, "article.txt" ); */
	current_mailmsg[0]='\0';
/*	sprintf( current_mailbox, "%s\\%s", prefs.mail_path, "inbox.mbx" ); */
	current_mailbox[0]='\0';
/*	current_address_book='\0'; */
	sprintf( current_address_book, "%s\\%s", program_path, "address.abk" );
	strcpy( article_path, prefs.work_path );
/*	fprintf( log, "NewsGroup Path: %s\n", current_newsgroup ); */

	sprintf( path, "%s\\fkeys.txt", program_path );
	load_function_keys( path );		/* support for function keys */
	fflush(log);
}

void initialize_fonts()
{
	int c,fonts_loaded;
	int new_size;
	char temp[80];
	char *alert;

	if (vq_gdos()) {
		fonts_loaded = vst_load_fonts( handle, 0);
		new_size = FONT_SIZE;
		while (new_size<fonts_loaded) { new_size+=10; }
		if (new_size!=FONT_SIZE) {
			if (font) { free( font ); }
			font = calloc( new_size, sizeof( struct fontinfo ) );
			if (!font) {
			/*	sprintf( temp,"[1][Insufficient Memory for %s][ Sorry ]", "|Font List" ); */
				rsrc_gaddr(R_STRING,Insuff_Memory,&alert); /* Insufficient Memory for ... */
				sprintf( temp, alert, "|Font List" );
				form_alert( 1, temp );
				font = calloc( FONT_SIZE, sizeof( struct fontinfo ) );
			} else {
				FONT_SIZE = new_size;
			/*	fprintf( log, "Font List expanded to %d entries\n", new_size ); */
			}
		}
		for (c=0;c<FONT_SIZE;c++) {
			font[c].index = 0;
			font[c].name[0] = '\0';
			if (c<fonts_loaded) {
				font[c].index = vqt_name( handle, c, font[c].name );
			/*	fprintf( log, "%s", font[c].name ); */
			}
		}
	}
}

void deinitialize(void)
{
	struct tm *tp;
	time_t t;
	int c,buff[8];

	for (c=WINDOWS_SIZE;c>0;c--) {	/* force close on all windows */
		if (windows[c-1].open) {
			buff[0]=WM_CLOSED;
			buff[3]=windows[c-1].id;
			do_message_events( buff );
		}
	}

	deinitialize_gem();

	if (log!=NULL) {
		time(&t);
		tp = localtime(&t);
		fprintf( log, "Log file closed: %s\n", asctime(tp) );
		fflush( log );
		fclose( log );
	}
}

void log_with_flush( char *msg )
{
	if (log) {
		fprintf( log, "%s\n", msg );
		fflush( log );
	}
}

/*
void set_button(OBJECT *tree,int parent,int button)
{
	int b;
	
	for (b=tree[parent].ob_head; b!=parent; b=tree[b].ob_next)
		if (b==button)
			tree[b].ob_state|=SELECTED;
		else
			tree[b].ob_state&=~SELECTED;
}

int get_button(OBJECT *tree,int parent)
{
	int b;

	b=tree[parent].ob_head;
	for (; b!=parent && !(tree[b].ob_state&SELECTED); b=tree[b].ob_next)
		;

	return b;
}

void test_dialog(void)
{
	OBJECT *dlog;
	int result;
	
	rsrc_gaddr(R_TREE,TestDialog,&dlog);
	set_tedinfo(dlog,DEditable,edit);
	set_button(dlog,DParent,radio);
	result=handle_dialog(dlog,DEditable);
	if (result==DOK)
	{
		get_tedinfo(dlog,DEditable,edit);
		radio=get_button(dlog,DParent);
	}
}
*/

void set_selected_text( int onoff )
{
	if (onoff) {
		if (work_out[13]==2) { vst_effects( handle, UNDERLINED ); }
		else { vst_color( handle, RED ); }
	} else {
		if (work_out[13]==2) { vst_effects( handle, 0 ); }
		else { vst_color( handle, BLACK ); }
	}
}

void group_text(int wid)
{
	GRECT work;
	int x,y,c,lpp,start,end;
	char buff[80];
	OBJECT *bar;

	x = wind_get( wid, WF_WORKXYWH, &work.g_x, &work.g_y, &work.g_w, &work.g_h);
	setup_toolbar(1, &work.g_x, &work.g_y, &work.g_w, &work.g_h );
	lpp = setup_text( wid, 1, prefs.newsgroup_font, prefs.newsgroup_font_size,
				work.g_h, maximum_group+1 ); 
	y=work.g_y;
	if (windows[1].clear) {
		clear_rect( &work);
		if ((bar=windows[1].bar_object)!=NULL) {
			objc_draw( bar, ROOT, 1, clip.g_x, clip.g_y, clip.g_w, clip.g_h );
		}
	}

	start = windows[1].line_no;
	end   = start + lpp;
	for (c=start;c<end;c++) {
		if ( group[c].name[0]!='\0') {
			sprintf( buff, "%c %5ld %-40.40s", group[c].viewed, group[c].num_msgs, group[c].name );
			if (c==current_group) {
				set_selected_text( 1 );
				v_gtext( handle, work.g_x, y+=cellh, buff );
				set_selected_text( 0 );
			} else {
				v_gtext( handle, work.g_x, y+=cellh, buff ); }
		}
	} 
}

void overview_infoline(void)
{
	char temp[80];
	int msgs=0,unread=0,c;
	int selected=0;

	if (maximum_overview>=0) {
		unread=msgs=maximum_overview+1;
		for (c=0;c<maximum_overview+1;c++) {
			if (overview[c].viewed==VIEWED) { unread--; }
			if (overview[c].viewed==SELECT_RET) { selected++; }
		}
	}
/*	sprintf( temp, "Newsgroup contains %d messages, %d Unread, %d Selected", msgs, unread, selected ); */
	sprintf( temp, ErrMsg(EM_OverInfo), msgs, unread, selected );
/*	sprintf( temp, ErrMsg(EM_OverInfo), msgs, unread ); */
	info_line( 2, temp );
/*	set_menu( 9, (selected>0) );	/* enable/disable 'Read Selected Offline' */
}

void format_overview_line(int c, char *buff)
{
	sprintf( buff, "%c %c %6ld %-30.30s %-30.30s %-6.6s %4ld",
		overview[c].viewed,
		overview[c].thread, overview[c].article_number,
		overview[c].subject, overview[c].author,
		overview[c].datetime, overview[c].num_lines );
}

void overview_text(int wid)
{
	GRECT work;
	int x,y,c,d,lpp,start,end,refresh=1;
	char buff[100];
	OBJECT *bar;

	x = wind_get( wid, WF_WORKXYWH, &work.g_x, &work.g_y, &work.g_w, &work.g_h);
	setup_toolbar(2, &work.g_x, &work.g_y, &work.g_w, &work.g_h );
	lpp = setup_text( wid, 2, prefs.overview_font, prefs.overview_font_size,
				work.g_h, maximum_overview+1 );
 
	if (windows[2].clear) {
		clear_rect( &work);
		refresh=0;
		if ((bar=windows[2].bar_object)!=NULL) {
			objc_draw( bar, ROOT, 1, clip.g_x, clip.g_y, clip.g_w, clip.g_h );
		}
	}
	x=work.g_x;
	y=work.g_y;

	overview_infoline();
	set_readmsg( 2 );
	if (maximum_overview<0) { return; }	/* nothing to display */

	start = windows[2].line_no;
	end   = start + lpp;
	if (end>OVERVIEW_SIZE) { end=OVERVIEW_SIZE; }
	for (d=start;d<end;d++) {
		c = threads[d].zero;
		if (c>=0) {
			if ( overview[c].subject[0]!='\0') {
				y+=cellh;
				if (refresh) {
					if (c==previous_overview) {
						format_overview_line( c, buff );
						v_gtext( handle, x, y, buff );
					}
					if (c==current_overview) {
						format_overview_line( c, buff );
						set_selected_text( 1 );
						v_gtext( handle, x, y, buff );
						set_selected_text( 0 );
					} 
				} else {
					format_overview_line( c, buff );
					if (c==current_overview) {
						set_selected_text( 1 );
						v_gtext( handle, x, y, buff );
						set_selected_text( 0 );
					} else {
						v_gtext( handle, x, y, buff );
					}
				}
			}
		}
	} 
}

void article_text( int wid, char *filename )
{
	generic_window_text( wid, filename );
}

void position_group_text(FILE *fid, int wx)
{
	int x,z,c;
	char *p, buff[400];

    if (wx!=4) {
 		for (c=0;c<windows[wx].line_no;c++) { /* skip some lines */
			p=fgets( buff, sizeof(buff), fid );
		}
		return;
	}

    if (fullgroup_index[0]==0) {
 		for (c=0;c<windows[wx].line_no;c++) { /* skip some lines */
			p=fgets( buff, sizeof(buff), fid );
		}
	} else {
		x=(int16)(windows[wx].line_no/fullgroup_index[1])+2;
		fsetpos( fid, &fullgroup_index[x] );
		z=(int16)(windows[wx].line_no%fullgroup_index[1]);
	/*	fprintf( log, "Index= %d, %d\n", x, z ); */
 		for (c=0;c<z;c++) { /* skip some lines */
			p=fgets( buff, sizeof(buff), fid );
		}
	}
}

void full_group_text( int wid, char *filename )
{
	GRECT work;
	int x,y,c,lpp,wx=4;
	FILE *fid;
	char *p, buff[400];
	OBJECT *bar;

	x = wind_get( wid, WF_WORKXYWH, &work.g_x, &work.g_y, &work.g_w, &work.g_h);
	setup_toolbar(wx, &work.g_x, &work.g_y, &work.g_w, &work.g_h );
	lpp = setup_text( wid, wx, prefs.news_font, prefs.news_font_size,
				work.g_h, windows[wx].num_lines ); 
	y=work.g_y;
	if (windows[wx].clear) {
		clear_rect( &work);
		if ((bar=windows[wx].bar_object)!=NULL) {
			objc_draw( bar, ROOT, 1, clip.g_x, clip.g_y, clip.g_w, clip.g_h );
		}
	}

	if (windows[wx].reread) {	/* need to reread, fill fullgroups[] */
		graf_mouse( BUSY_BEE, NULL );
		if ((fid=fopen( filename, "ra"))!=NULL) {
			position_group_text( fid, wx );
			for (c=0;c<lpp;c++) {
				fullgroups[c].x[0] = '\0';
				if (fgets( buff, sizeof(buff), fid )!=NULL) {
					p = strtok( buff, " \n" );
					if (strcmp(buff,".")==0) { buff[0] = '\0'; }	/* end? */
				/*	if (buff[0]=='.') { buff[0] = '\0'; }	/* end? */
					strcpy( fullgroups[c].x, buff );
					fullgroups[c].x[49] = '\0';	/* null terminated */
				}
			}
			fclose( fid );
		}
		graf_mouse( ARROW, NULL );
		current_fullgroups = -1;
	}
	for (c=0;c<lpp;c++) {		/* display only */
		if (c==current_fullgroups) {
			set_selected_text( 1 );
			v_gtext( handle, work.g_x+6, y+=cellh, fullgroups[c].x );
			set_selected_text( 0 );
		} else {
			v_gtext( handle, work.g_x+6, y+=cellh, fullgroups[c].x );
		}
	} 
	windows[wx].reread = 0;		/* reset to no read */
}

void new_group_text( int wid, char *filename )
{
	GRECT work;
	int x,y,c,lpp,wx=5;
	FILE *fid;
	char *p, buff[400];
	OBJECT *bar;

	x = wind_get( wid, WF_WORKXYWH, &work.g_x, &work.g_y, &work.g_w, &work.g_h);
	setup_toolbar(wx, &work.g_x, &work.g_y, &work.g_w, &work.g_h );
	lpp = setup_text( wid, wx, prefs.news_font, prefs.news_font_size,
				work.g_h, windows[wx].num_lines ); 
	y=work.g_y;
	if (windows[wx].clear) {
		clear_rect( &work);
		if ((bar=windows[wx].bar_object)!=NULL) {
			objc_draw( bar, ROOT, 1, clip.g_x, clip.g_y, clip.g_w, clip.g_h );
		}
	}

	if (windows[wx].reread) {	/* need to reread, fill newgroups[] */
		graf_mouse( BUSY_BEE, NULL );
		if ((fid=fopen( filename, "ra"))!=NULL) {
			for (c=0;c<windows[wx].line_no;c++) { /* skip some lines */
				p=fgets( buff, sizeof(buff), fid );
			}
			for (c=0;c<lpp;c++) {
				newgroups[c].x[0] = '\0';
				if (fgets( buff, sizeof(buff), fid )!=NULL) {
					p = strtok( buff, " \n" );
					if (strcmp(buff,".")==0) { buff[0] = '\0'; }	/* end? */
				/*	if (buff[0]=='.') { buff[0] = '\0'; }	/* end? */
					strcpy( newgroups[c].x, buff );
					newgroups[c].x[49] = '\0';	/* null terminated */
				}
			} 
			fclose( fid );
		}
		graf_mouse( ARROW, NULL );
		current_newgroups = -1;
	}
	for (c=0;c<lpp;c++) {		/* display only */
		if (c==current_newgroups) {
			set_selected_text( 1 );
			v_gtext( handle, work.g_x+6, y+=cellh, newgroups[c].x );
			set_selected_text( 0 );
		} else {
			v_gtext( handle, work.g_x+6, y+=cellh, newgroups[c].x );
		}
	} 
	windows[wx].reread = 0;		/* reset to no read */
}

void view_article(char *article_title)
{
	int shift=3;
	int dummy,state;

	graf_mkstate( &dummy, &dummy, &dummy, &state );
	if (state&shift) {
		call_editor_nowait( current_article, prefs.external_editor );
	} else {
		if (prefs.use_ext_viewer=='Y') {
			call_editor_nowait( current_article, prefs.external_viewer );
		} else {
			windows[2].clear=0;
			refresh_window( windows[2].id );	/* refresh overview w/check */
			handle_possible_events();
			windows[3].num_lines = (int16)count_lines( current_article );
			windows[3].line_no   = 0;
			handle_generic_close( 3 );	/* release possible html anchors */
			new_window( 3, article_title, 0, 100, 500, 300 );
			set_reply( 3 );		/* allow email reply */
			handle_redraw_event();
			auto_extract_binaries();
			DHST_Add( current_article );	/* support DHST */
		}
	}
}

void next_article()
{
	int c,rc;
	int top;
	char temp[80];

	wind_get( 0, WF_TOP, &top, NULL, NULL, NULL );
	if ((windows[6].id==top)||(windows[7].id==top)) {
		next_mail();
		return;
	}
	if (maximum_overview<0) { return; }
	if (threads[current_thread+1].zero>=0) {
		if (prefs.erase_articles=='Y') {
			if (ncn>=0) {	remove( current_article ); }
		}
		previous_overview = current_overview;
		current_overview = threads[++current_thread].zero;
		c = current_overview;
		overview[c].viewed = VIEWED;
		sprintf( article_title, "%ld", overview[c].article_number ); 
		sprintf( current_article, "%s\\%ld.txt", article_path, overview[c].article_number );
		if (ncn>=0) {
			use_status( windows_index( top ) ); /* overview or article window */
			strcpy( temp, ErrMsg(EM_RetrieveArt) );
			strtok( temp, "%");
			show_status( temp );	/* Retrieving Article */
			rc = news_article(overview[c].article_number, current_article);
			hide_status(); 
		}
		view_article( article_title );
	}
}

void next_thread()
{
	int nt,no;

	if (maximum_overview<0) { return; }
	nt = current_thread;
	while(threads[nt+1].zero>=0) {
		no=threads[++nt].zero;
		if (threads[no].one<0) {
			current_thread=nt;
			previous_overview = current_overview;
			current_overview=no;
			determine_current_article();
			refresh_window( windows[2].id );	
			return;
		} 
	}
}

void next_group()
{
	if (current_group<maximum_group) {
		unload_overview();
		current_group++;
		if (group[current_group].viewed!=G_INVALID) {
			group[current_group].viewed = VIEWED;
			use_status( 2 );	/* use info line in overview window */
			show_status( ErrMsg(EM_RetrieveOver) );
			load_overview();
			hide_status();
			new_window( 2, group[current_group].name, 50, 50, 530, 280 );
		}
	}
}

void print_article(void)
{
	FILE *fid;
	char  buff[400],thefile[FMSIZE];
	int top;

	wind_get( 0, WF_TOP, &top, NULL, NULL, NULL );
	if ((windows[6].id==top)||(windows[7].id==top)) {
		strcpy( thefile, current_mailmsg );		/* mail article */
	} else {
		strcpy( thefile, current_article );		/* news article */
	}
	fid = fopen( thefile, "r" );
	if (fid!=NULL) { 
		while (fgets( buff, sizeof(buff), fid )!=NULL) {
			fputs( buff, stdprt );
		}
		fclose( fid );
		fputc( '\n', stdprt );		/* new line */
		fputc( '\f', stdprt );		/* form feed */
		fflush( stdprt );
	}
}

void append_signature(char *path)
{
	FILE *fid,*fid2;
	char  buff[400];

	if (prefs.append_signature=='Y' ) {
		fid = fopen( prefs.signature_file, "r" );
		if (fid!=NULL) { 
			fid2 = fopen( path, "a" );
			if (fid2!=NULL) { 
				fputc( '\n', fid2 );		/* force newline */
				while (fgets( buff, sizeof(buff), fid )!=NULL) {
					fputs( buff, fid2 );
				}
				fclose( fid2 );
			}
			fclose( fid );
		}
	}
}

int try_news(char *path)
{
	int x,rc=-1;

	if (ncn>=0) {
		append_signature( path );
		show_status( ErrMsg(EM_SendingNews) );
		x = news_post( path );	/* 0=ok */
		hide_status();
		rc=x;
	}	
	return(rc);
}
	
void mark_read(void)
{
	if (current_overview<0) { return; }
	overview[current_overview].viewed = view_or_select();
	refresh_window( windows[2].id );	
}

void mark_thread_read(void)
{
	int c,x;
	char v;

	if (current_overview<0) { return; }
	x = threads[current_overview].one;
	if (x<0) { x = threads[current_thread].zero; }
	v = view_or_select();
	for (c=0;c<maximum_overview+1;c++) {
		if (threads[c].one==x) {	overview[c].viewed = v; }
		if (threads[c].zero==x) {	overview[threads[c].zero].viewed = v; }
	}
	refresh_clear_window( windows[2].id );	
}

void mark_unread(void)
{
	if (current_overview<0) { return; }
	overview[current_overview].viewed = ' ';
	refresh_window( windows[2].id );	
}

void mark_all_read(void)
{
	int c;
	char v;

	if (windows[2].open) {
		if (maximum_overview<0) { return; }
		v = view_or_select();
		for (c=0;c<maximum_overview+1;c++) {
			overview[c].viewed = v;
		}
		if (current_overview<0) {
			previous_overview = current_overview;
			current_overview++;
			determine_current_article();
		} 
		refresh_clear_window( windows[2].id );
	} else {
		if (current_group>=0) {
			group[current_group].first_msg = group[current_group].last_msg+1;
		  	group[current_group].num_msgs = 0;
			refresh_window( windows[1].id );
		}
	}
}	

void subscribe(void)
{
	int top;

	wind_get( 0, WF_TOP, &top, NULL, NULL, NULL );
	if (top==windows[4].id) {	/* fullgroup window */
		if (current_fullgroups>=0) {
			Add_Newsgroup_dialog( fullgroups[current_fullgroups].x );
			refresh_window( windows[1].id );
			return;
		}
	}
	if (top==windows[5].id) {	/* newgroups window */
		if (current_newgroups>=0) {
			Add_Newsgroup_dialog( newgroups[current_newgroups].x );
			refresh_window( windows[1].id );
			return;
		}
	}
		Add_Newsgroup_dialog( "" );		/* add your own */
		refresh_window( windows[1].id );
}

void unsubscribe(void)
{
	if (current_group>=0) {
		Delete_Newsgroup_dialog();
		refresh_clear_window( windows[1].id );
	}
}

int extract_binaries_common( int check )
{
	char prog[FNSIZE]="uud.ttp",path[FMSIZE],thepath[FMSIZE];
	char thefile[FMSIZE];
	char buff[500],a[80],b[80],c[80],file[FMSIZE],*p;
	long rc;
	int is_encoded=0,top;
	struct FILEINFO finfo;
	FILE *fid;

	wind_get( 0, WF_TOP, &top, NULL, NULL, NULL );
	if ((windows[6].id==top)||(windows[7].id==top)) {
		strcpy( thefile, current_mailmsg );		/* mail article */
	} else {
		strcpy( thefile, current_article );		/* news article */
	}

	file[0]='\0';						/* clear filename */
	if (check!=1) {
		use_status( windows_index( top ) );	/* use window info line */
		show_warning( ErrMsg(EM_LookBinary) );
	} 
	fid = fopen( thefile, "ra" );
	if (fid!=NULL) {
		while (fgets(buff, sizeof(buff), fid)!=NULL) {
			if (memcmp( buff, "begin", 5)==0) {
				is_encoded = 1;
				sscanf( buff, "%s %s %s", a,b,file );
				break;
			}
		/*	Content-Type: image/jpeg; name="ABC.JPG"
			Content-Transfer-Encoding: base64
			Content-Disposition: inline; filename="ABC.JPG" */
			if (memcmp( buff, "Content-", 8)==0) {
				sscanf( buff, "%s %s %s", a,b,c );
				if (strcmpi( "base64", b )==0) {
					is_encoded = 1;
					strcpy( prog, "munpack.ttp" );
				}
				if ((memcmp( "name=", c, 5 )==0)||
				   (memcmp( "filename=", c, 9 )==0)) {	/* extract filename */
					p=strtok( c, "\"" );
					p=strtok( NULL, "\"" );
					if (p!=NULL) { strcpy( file, p ); }
				}
				if ((is_encoded)&&(file[0]!='\0')) { break; }
			}
		}
		fclose( fid );
	}

	if (check==1) { return( is_encoded ); }	/* check only? */

	if (is_encoded==0) { status_text( ErrMsg(EM_NoBinaryFound) ); }

	if (is_encoded>0) {
		sprintf( thepath, "%s\\%s", prefs.work_path, prog );
		if (dfind( &finfo, thepath, 0 )) {	/* not found in work_path, try program_path */
			sprintf( thepath, "%s\\%s", program_path, prog );
			if (dfind( &finfo, thepath, 0 )) {	/* also not found, issue message */
				sprintf( buff, ErrMsg(EM_CantLocate), prog ); 	/* program cannot be located */
			/*	sprintf( buff, "%s cannot be located", prog ); 	/* program cannot be located */
				status_text( buff );
				is_encoded = -is_encoded;	/* negate w/no more action */
			}
		}
	}

	if (is_encoded==-1) {	/* is this UU Encoded, but UUD.TTP not found? */
		sprintf( path, "%s\\", prefs.work_path );
		chdir( path );
		sprintf( buff, ErrMsg(EM_Decoding), file );
		show_warning( buff );
		graf_mouse( BUSY_BEE, NULL );
		if (uudecode( thefile )!=0) {
			status_text( ErrMsg(EM_DecodeFailed) );
		} else {
			status_text( ErrMsg(EM_DecodeComplet) );
			is_encoded = -1;
		}
		graf_mouse( ARROW, NULL );
		chdir( program_path );
	}

	if (is_encoded>0) {
		sprintf( path, "%s\\", prefs.work_path );
		chdir( path );
		sprintf( buff, ErrMsg(EM_Decoding), file );
		show_warning( buff );
/*		rc = spawnl( P_WAIT, prog, prog, thefile, NULL ); */
		rc = spawnl( P_WAIT, thepath, prog, thefile, NULL );
		menu_bar(menu_ptr,1);		/* re-display menu bar */
		if (rc<0) {
			fprintf( log, "%s error %ld\n", prog, rc ); fflush(log);
			status_text( ErrMsg(EM_DecodeFailed) );
		} else {
			status_text( ErrMsg(EM_DecodeComplet) );
		}
		chdir( program_path );
	}
	evnt_timer( 1000, 0 );		/* wait 1 second */
	hide_status();
	return( is_encoded );
}

void extract_binaries(void)
{
	extract_binaries_common( 0 );
}

int check_for_binaries(void)
{
	return( extract_binaries_common( 1 ));
}


void auto_extract_binaries(void)
{
	int x;
	char *alert;

	if (prefs.auto_extract=='N') { return; }	/* no auto extract */
	if (prefs.auto_extract=='Y') {			/* yes, automatic */
		if (extract_binaries_common( 1 )) {	/* test for binary present */
			extract_binaries();
		}
	}
	if (prefs.auto_extract=='P') {			/* yes, Prompt user with alert */
		if (extract_binaries_common( 1 )) {	/* test for binary present */
			rsrc_gaddr(R_STRING,Extract_Prompt,&alert); /* Extract the Attached File(s)? */
			x = form_alert(1, alert);
		/*	x = form_alert(1,"[1][Extract the Attached File(s)?][ Yes | No ]"); */
			if (x==1) { extract_binaries(); }
		}
	}
}

void new_post()
{
	char path[FMSIZE];

	sprintf( path, "%s\\%s", prefs.work_path, NEWSTEST );
	Post_Message_dialog(0, path );
}

void followup_post()
{
	char path[FMSIZE];

	if (current_overview>-1) {
		sprintf( path, "%s\\%s", prefs.work_path, NEWSTEST );
		Post_Message_dialog(1, path );
	}
}

void cancel_article(void)
{
	char path[FMSIZE];
	FILE *fid;
	int result;

	if (current_overview>-1) {
		fprintf( log, "%s:%s\n", prefs.email_address, overview[current_overview].author_email);
		fflush(log);
		if (strcmp(prefs.email_address, overview[current_overview].author_email)==0) {
			sprintf( path, "%s\\%s", prefs.work_path, NEWSTEST );
			fid = fopen( path, "wa" );
			if (fid!=NULL) {
				fprintf( fid, "Newsgroups: %s\n", group[current_group].name ); 
				fprintf( fid, "From: %s (%s)\n", prefs.email_address, prefs.full_name ); 
				fprintf( fid, "Organization: %s\n", prefs.organization ); 
				fprintf( fid, "Subject: %s\n", overview[current_overview].subject ); 
				fprintf( fid, "X-Newsreader: NEWSie Version %.4s (Atari)\n", VERSION ); 
				fprintf( fid, "Control: cancel %s\n", overview[current_overview].msgid ); 
				fprintf( fid, "Approved: %s\n", prefs.email_address ); 
				fprintf( fid, "\n" );
				fclose( fid );
				result=try_news( path );	/* 0=posted, !0=some error */
				add_to_postbox( path, group[current_group].name,
						overview[current_overview].subject, "", !result );	/* 1=sent 0=queue */
			}
		} 
	}
}

void open_selected_grouplist( char *fname )
{
	char select[FMSIZE];
	char dirname[FMSIZE],path[FMSIZE];
	int button,c=2;

	unload_group(current_newsgroup);	/* write newsgroup table */
	sprintf( dirname, "%s\\", prefs.work_path );
	if (fname[0]==' ') { c=1; }	/* "  new  " */
	if (fname[0]=='\0') {	/* empty string? */
		c = filelist_popup( dirname, "*.grp" );
	} else {
		strcat( dirname, fname );
	}
/*	c = filelist_popup( dirname, "*.grp" ); */
	if (c==0) { return; }	/* cancelled */
	if (c==1) {				/* "new" or popup doesn't work */
		strcpy( dirname, prefs.work_path );
		strcat( dirname, "\\*.grp" );
	 	*select = 0;
		fsel_exinput( dirname, select, &button, ErrMsg(EM_SelectNewsGrp) );
		if ((button)&&(select[0]!='\0')) {
			stcgfp( path, dirname );
		/*	unload_group(current_newsgroup);	/* write newsgroup table */
		/*	sprintf( current_newsgroup, "%s\\%s", path, select ); */
			sprintf( dirname, "%s\\%s", path, select );
			rebuild_attach_list( dirname, "grp" );	/* update newsgroup file list */
		} else { return; }
	}
	strcpy( current_newsgroup, dirname );
	show_status( ErrMsg(EM_RetrieveNews) );
	load_group(current_newsgroup);	/* fill newsgroup table */
	hide_status();
	new_window( 1, ErrMsg(EM_SubNewsGroup), 50, 100, 300, 300 );
}

void open_new_grouplist(void)
{
	open_selected_grouplist( "" );	/* empty string */
}


void save_as(void)
{
	char select[FMSIZE],dirname[FMSIZE],path[FMSIZE];
	int button,top;

	wind_get( 0, WF_TOP, &top, NULL, NULL, NULL );
	if (top==windows[1].id) {	/* Subscribed Newsgroups */
		strcpy( dirname, prefs.work_path );
		strcat( dirname, "\\*.grp" );
	 	*select = 0;
		fsel_exinput( dirname, select, &button, ErrMsg(EM_SaveNewsGroup) );
		if ((button)&&(select[0]!='\0')) {
			stcgfp( path, dirname );
			sprintf( dirname, "%s\\%s", path, select );
			rebuild_attach_list( dirname, "grp" );	/* update newsgroup file list */
			unload_group( dirname );	/* write newsgroup */
		}
	}
	if (top==windows[3].id) {	/* news article */
		stcgfp( dirname, current_article );
		strcat( dirname, "\\*.txt" );
	 	*select = 0;
		fsel_exinput( dirname, select, &button, ErrMsg(EM_SaveAs) );
		if ((button)&&(select[0]!='\0')) {
			stcgfp( path, dirname );
			sprintf( dirname, "%s\\%s", path, select );
			copy_file( dirname, current_article );
		}
	}
	if (top==windows[7].id) {	/* mail message */
		stcgfp( dirname, current_mailmsg );
		strcat( dirname, "\\*.txt" );
	 	*select = 0;
		fsel_exinput( dirname, select, &button, ErrMsg(EM_SaveAs) );
		if ((button)&&(select[0]!='\0')) {
			stcgfp( path, dirname );
			sprintf( dirname, "%s\\%s", path, select );
			copy_file( dirname, current_mailmsg );
		}
	}
}

void key_group(int keycode)
{
	if (arrow_page_scrolling_keys( windows[1].id, keycode )) { return; }

	if ((keycode>>8)=='\x48') {	/* up arrow */
		if ((current_group)>0) {
			unload_overview();
			current_group--;
			if (current_group<windows[1].line_no) {
				handle_arrows( windows[1].id, WA_UPPAGE );
			} else {
				refresh_window( windows[1].id );
			}
		}
		return;
	}
	if ((keycode>>8)=='\x50') {	/* down arrow */
		if (current_group<maximum_group) {
			unload_overview();
			current_group++;
			if (current_group>=windows[1].line_no+windows[1].lines_per_page) {
				handle_arrows( windows[1].id, WA_DNPAGE );
			} else {
				refresh_window( windows[1].id );
			}
		}	
		return;
	}
	if ((keycode>>8)=='\x52') {	/* insert */
		subscribe();
		return;
	}
	if ((keycode>>8)=='\x53') {	/* delete */
		unsubscribe();
		return;
	}
	if ((char)keycode=='\r') {	/* return */
		if (current_group>=0) {
			if (group[current_group].viewed!=G_INVALID) {
				group[current_group].viewed = VIEWED;
				show_status( ErrMsg(EM_RetrieveOver) );		/* Retrieving Group Overview */
				load_overview();
				hide_status();
				new_window( 2, group[current_group].name, 50, 50, 530, 280 );
			}
		}
		return;
	}	
	if ((char)keycode=='?') {	/* question mark? */
	/*	if (!(OFFLINE)) { */
			if (current_group>=0) {
				Edit_FirstLast_dialog( current_group );
				refresh_window( windows[1].id );
			}
	/*	} */
		return;
	}
}

void key_overview(int keycode)
{
	char article_title[FMSIZE];
	int rc,dummy,state,c=0,d=0;
	char temp[80];
/*	char *alert; */

	if (arrow_page_scrolling_keys( windows[2].id, keycode )) { return; }

	if ((keycode>>8)=='\x48') {	/* up arrow */
		if (threads[current_thread].zero>0) {
			previous_overview = current_overview;
			current_overview = threads[--current_thread].zero;
			determine_current_article();
			if (current_thread<windows[2].line_no) {
				handle_arrows( windows[2].id, WA_UPPAGE );
			} else {
				refresh_window( windows[2].id );
			}
		}
		return;
	}
	if ((keycode>>8)=='\x50') {	/* down arrow */
		if (threads[current_thread+1].zero>=0) {
			previous_overview = current_overview;
			current_overview = threads[++current_thread].zero;
			determine_current_article();
			if (current_thread>=windows[2].line_no+windows[2].lines_per_page) {
				handle_arrows( windows[2].id, WA_DNPAGE );
			} else {
				refresh_window( windows[2].id );
			}
		}	
		return;
	}
	if ((keycode>>8)=='\x4B') {	/* left arrow - collapse thread */
		if (prefs.create_threads=='Y') { 
			if (current_thread>=0) {
				if (collapse_thread(current_thread)) {
					refresh_clear_window( windows[2].id ); }
			}
		}
		return;
	}
	if ((keycode>>8)=='\x4D') {	/* right arrow - expand thread */
		if (prefs.create_threads=='Y') {  
			if (current_thread>=0) {
				if (expand_thread(current_thread)) {
					refresh_clear_window( windows[2].id ); }
			}
		}
		return;
	}
	if ((char)keycode=='\r') {	/* return */
		if (current_overview>=0) {
			overview[current_overview].viewed = VIEWED;
			sprintf( article_title, "%ld", overview[current_overview].article_number );
			sprintf( current_article, "%s\\%ld.txt", article_path, overview[current_overview].article_number );
			if (ncn>=0) {
				use_status( 2 );	/* use info line in overview window */
				strcpy( temp, ErrMsg(EM_RetrieveArt) );
				strtok( temp, "%");
				show_status( temp );	/* Retrieving Article */
			/*	show_status( ErrMsg(EM_RetrieveArt) );	/* Retrieving Article */
				rc = news_article(overview[current_overview].article_number, current_article); 
				hide_status();
			}
			view_article( article_title );
		}	
		return;
	}
	if ((char)keycode=='c') {	/* cancel */
		cancel_article();
	}
	if (OFFLINE) {	/* support Del key in OFFLINE mode */
		graf_mkstate( &dummy, &dummy, &dummy, &state );
		if (((keycode>>8)=='\x53')&&(state&3)) {	/* shift-delete all files */
			for (rc=0;rc<maximum_overview+1;rc++) {
				c++; if (overview[rc].viewed=='D') { d++; }	/* c=all, d=deleted */
			}
			if (c==d) { /* if all are already deleted, undelete all */
				for (rc=0;rc<maximum_overview+1;rc++) {	overview[rc].viewed = ' '; }
				refresh_clear_window( windows[2].id );
				return;
			}

			strcpy( temp, ErrMsg( EM_DelAllArt ));	/* Delete All Articles? */
		/*	sprintf( temp,"[1][Delete All Articles?][ OK | Cancel ]" ); */
			if (form_alert( 2, temp )==1) {	/* default to Cancel, but if OK */
				for (rc=0;rc<maximum_overview+1;rc++) {	overview[rc].viewed = 'D'; }
				refresh_clear_window( windows[2].id );
			}
		} else {
			if (current_overview<0) { return; }
	 		sprintf( current_article, "%s\\%ld.txt", article_path, overview[current_overview].article_number );
			key_article( keycode );
		}
	} 
}

void key_article(int keycode)
{
	struct FILEINFO info;
	long rc;

	if ((keycode>>8)=='\x53') {	/* delete the file */
		if (!(OFFLINE)) { 
			if (!dfind(&info, current_article, 0)) { /* if file does exist */
				rc=remove( current_article );
				if (rc) { beep(); return; }	/* error occurred */
			}
		}
		if (windows[3].id>0) {	/* check valid window id? */
			wind_title( windows[3].id, ErrMsg(EM_FileDeleted) );	/* (deleted) */
		}
		if (windows[3].buffer==NULL) { refresh_clear_window( windows[3].id ); }
		if (OFFLINE) {
			if (current_overview>=0) {
				if (overview[current_overview].viewed!='D') {
					overview[current_overview].viewed = 'D';
				} else {
					overview[current_overview].viewed = ' ';
				}
				refresh_window( windows[2].id );
			}
		}
		current_article[0]='\0';
		set_reply( 2 );
		return;
	}
	arrow_scrolling_keys( windows[3].id, keycode );
}

void key_fullgroups(int keycode)
{
	char path[FMSIZE];

	arrow_scrolling_keys( windows[4].id, keycode );

	if ((char)keycode=='s') {	/* s = search for newsgroup */
		sprintf( path, "%s\\%s", prefs.work_path, FULLGRP );
		Search_Groups_dialog(path, 4);
	}
	
	if ((char)keycode=='m') {	/* s = match newsgroup */
		sprintf( path, "%s\\%s", prefs.work_path, FULLGRP );
		Match_Groups_dialog(path, 4);
	}
}

void key_newgroups(int keycode)
{
	char path[FMSIZE];

	arrow_scrolling_keys( windows[5].id, keycode );

	if ((char)keycode=='s') {	/* s = search for newsgroup */
		sprintf( path, "%s\\%s", prefs.work_path, NEWGRP );
		Search_Groups_dialog(path, 5);
	}
	
	if ((char)keycode=='m') {	/* s = match newsgroup */
		sprintf( path, "%s\\%s", prefs.work_path, NEWGRP );
		Match_Groups_dialog(path, 5);
	}
}

void select_group(int vert, int clicks )
{
	int rc,index,refresh;

	rc = atoi( prefs.newsgroup_font_size );
	vst_point( handle, rc, &charw, &charh, &cellw, &cellh );
	index = (vert / cellh ) + windows[1].line_no;
	if (index<GROUP_SIZE) {
		if (group[index].name[0]!='\0') {
			refresh = (current_group!=index);
			unload_overview();
			current_group = index;
			if ((clicks>1)&&(group[index].viewed!=G_INVALID)) {
				group[index].viewed = VIEWED;
				show_status( ErrMsg(EM_RetrieveOver) );	/* Retrieving Group Overview */
				load_overview();
				hide_status();
				new_window( 2, group[index].name, 50, 50, 530, 280 );
			} else {
				if (refresh) { refresh_window( windows[1].id ); }
			}
		}
	}
}

void select_article(int vert, int clicks)
{
	int rc,index,refresh;
	char v;
	char temp[80];

	rc = atoi( prefs.overview_font_size );
	vst_point( handle, rc, &charw, &charh, &cellw, &cellh );
	index = (vert / cellh ) + windows[2].line_no;
	if ((index<OVERVIEW_SIZE)&&(threads[index].zero!=-1)) {
		current_thread = index;
		index = threads[index].zero;
		if (overview[index].subject[0]!='\0') {
			refresh = (current_overview!=index);
			previous_overview = current_overview;
			current_overview = index;
			if (clicks>1) {
				overview[index].viewed = VIEWED;
				sprintf( article_title, "%ld", overview[index].article_number );
				sprintf( current_article, "%s\\%ld.txt", article_path, overview[index].article_number );
				if (ncn>=0) {
					use_status( 2 );	/* use info line in overview window */
					strcpy( temp, ErrMsg(EM_RetrieveArt) );
					strtok( temp, "%");
					show_status( temp );	/* Retrieving Article */
				/*	show_status( ErrMsg(EM_RetrieveArt) );	/* Retrieving Article */
					rc = news_article(overview[index].article_number, current_article); 
					hide_status();
				}
				view_article( article_title );
			} else {
				determine_current_article();
				if ((v=view_or_select())==SELECT_RET) {	/* handle selected */
					toggle_selected_article(index);
					refresh++;
				}
				if (refresh) { refresh_window( windows[2].id ); }
			}
		}
	}
}

void select_fullgroup(int vert, int clicks)
{
	int rc,index,refresh;

	rc = atoi( prefs.news_font_size );
	vst_point( handle, rc, &charw, &charh, &cellw, &cellh );
	index = (vert / cellh );
	if (index<FULLGROUPS_SIZE) {
		if (fullgroups[index].x[0]!='\0') {
			refresh = (current_fullgroups!=index);
			current_fullgroups = index;
			if (clicks>1) {	subscribe(); } 
			if (refresh) { refresh_window( windows[4].id ); }
		}
	}
}

void select_newgroup(int vert, int clicks)
{
	int rc,index,refresh;

	rc = atoi( prefs.news_font_size );
	vst_point( handle, rc, &charw, &charh, &cellw, &cellh );
	index = (vert / cellh );
	if (index<NEWGROUPS_SIZE) {
		if (newgroups[index].x[0]!='\0') {
			refresh = (current_newgroups!=index);
			current_newgroups = index;
			if (clicks>1) {	subscribe(); } 
			if (refresh) { refresh_window( windows[5].id ); }
		}
	}
}

void newsserver_connect(void)
{
	int x;
	char command[80];

	sprintf( command, ErrMsg(EM_ConnectTo), prefs.news_server );
	fprintf( log, "%s\n", command ); fflush(log); 
	show_status( command );
	x = news_connect( prefs.news_server );	/* make connection */
	if (ncn>=0) {
		if (header[0]>'2') { /* 200 NewsReader */
			x = news_quit();
		/*	ncn=-19; */
			status_text( ErrMsg(EM_NoServerAcc) );	/* Server Denied Access */
			evnt_timer( 2000, 0 );		/* wait 2 seconds */
		} else {
			x = news_reader();
		/*	if (prefs.post_offline_on_connect=="Y") { send_queued_articles(); } */
			send_queued_articles();
		}
	}
	standard_startup();
}

void newsserver_disconnect(void)
{
	int x;

	if (ncn>=0) {							/* if connected */
		unload_overview();	
		unload_group(current_newsgroup);	/* write newsgroup table */
		x = news_quit();
	/*	ncn = -19; */	/* leave as NO_CONNECTION = -12 */
	}
	set_menu( 5, -1*(ncn>=0) );
}

void CAB_internet_news_client( char *parameter )
{
	FILE *fid;
	char *newsgroup;
/*	char *article; */
	char parm[300];

	strcpy( parm, parameter );
	sprintf( current_newsgroup, "%s\\%s", prefs.work_path, "temp.grp" );
	fid = fopen( current_newsgroup, "wa" );
	if (fid!=NULL) {
		newsgroup = strtoka( parm+5, '\0' );
	/*	article   = strtoka( NULL, '\0' ); */
		fprintf( fid, "%s 0\n", newsgroup );
		fclose( fid );
	}
}

void standard_startup(void)
{
	set_menu( 5, -1*(ncn>=0) );
	if (ncn>=0) { show_status( ErrMsg(EM_RetrieveNews) ); }
	load_group(current_newsgroup);		/* fill newsgroup table */
	hide_status();
	if ((prefs.subscribe_startup=='Y')||(windows[1].open)) {
		new_window( 1, ErrMsg(EM_SubNewsGroup), 50, 100, 300, 300 );
	}
}

void startup_file_parameter(char *argv)
{
	char url[FMSIZE],parm[FMSIZE],*p;
	FILE *fid;

	strcpy( parm, argv );
	strlwr( parm );
	if (stcpm(parm, ".grp", &p)) {			/* drag and drop .GRP files */
		if ((fid=fopen(argv, "ra"))!=NULL) {
			fclose( fid );
			strcpy( current_newsgroup, argv);
		}
	} else if (stcpm(parm, ".htm", &p)) {	/* drag and drop .HTM files */
		if ((fid=fopen(argv, "ra"))!=NULL) {
			fclose( fid );
			sprintf( url, "file:///%s", argv );
		/*	strcpy(info.content_type,"text/html" ); */
			open_url_path( url );
		}
	} else if (stcpm(parm, ".inf", &p)) {	/* drag and drop .INF files */
		if ((fid=fopen(argv, "ra"))!=NULL) {
			fclose( fid );
			load_preferences( argv );
		}
	}
}

int main(int argc, char *argv[])
{
	int stikid;
	int msg[8];
	char temp[8];

	initialize();
	msg[0]=0;
	if (argc>1) {
		if (argv[1]!=NULL) {
			stccpy( temp, argv[1], 8 );
			strlwr( temp );
			fprintf( log, "Parameter: %s\n", argv[1] ); fflush(log);
			if (memcmp(temp, "news:", 5 )==0) {
				CAB_internet_news_client( argv[1] );
			} else if (memcmp(temp, "ftp://", 6 )==0) {
				CAB_internet_ftp_client( argv[1] );
			} else if (memcmp(temp, "mailto:", 7 )==0) {
				CAB_internet_mail_client( argv[1] );
				msg[0]=3;	/* special kludge for mail dialog */
			} else startup_file_parameter( argv[1] );	/* might be a file */
		}
	}

	do { 
		STiK = init_stik();					/* initialize stik */
		if (STiK>0) {	
			fprintf( log, "STiK Version: %s %s\n", tpl->version, tpl->author );
			fflush(log);
			in.msg_status = log_msg_status;
			if (prefs.connect_startup=='Y') {
				newsserver_connect();
			} else { standard_startup(); }
			if (msg[0]==3) { CAB_internet_mail_client_part2(); }
		} else {
			stikid = appl_find( "STIK    ");
			if (stikid==-1) {
				no_stik();
				STiK=-1;
				standard_startup();
			} else {
				msg[0] = AC_OPEN;
				msg[1] = _AESglobal[2];
				msg[2] = 0;
				msg[3] = stikid;
				appl_write( stikid, 16, &msg );
				evnt_timer( 10000, 0 );		/* wait 10 seconds */
			}
		}
	} while (STiK==0);

	handle_multiple_events();

	newsserver_disconnect();

	deinitialize();
	return EXIT_SUCCESS;
}


/* end of NEWSIE.C */