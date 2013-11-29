/*
 * offline.c
 * written by: John Rojewski   date: 08/23/96
 * updated: 10/10/98  Version: 0.94
 * updated: 11/01/98  Version: 0.94
 */

#include <sys\types.h>
#include <sys\stat.h>

#define SELECT_RET 'S'

/* test for shift key, and mark as 'selected' rather than VIEWED */
char view_or_select(void)
{
	int dummy,shift;

	if (ncn<0) { return( VIEWED ); }	/* no 'select' while offline */
	graf_mkstate(&dummy,&dummy,&dummy,&shift);
	if (shift&(K_RSHIFT+K_LSHIFT)) { return( SELECT_RET ); } else { return( VIEWED ); }
}

void toggle_selected_article( int c )
{
	if (c<maximum_overview+1) {
		if (overview[c].viewed==SELECT_RET) {
			overview[c].viewed=' ';	/* not selective retrieval candidate */
		} else {
			overview[c].viewed=SELECT_RET;	/* selective retrieval candidate */
		}
	}
}

void read_all_articles(int g, char *the_path)
{
	long c,first,last;
	int x;
	char status[50];

	first = group[g].first_msg;
	last = group[g].last_msg;
	fprintf( log, "newsgroup: %s, first: %ld, last: %ld\n", group[g].name, first, last ); fflush(log);
	use_status( 2 );	/* use overview window info line */
    if (first<=last) {
		for (c=first;c<last+1;c++) {
			sprintf( current_article, "%s\\%ld.txt", the_path, c );
		/*	sprintf( status, "%s %ld", ErrMsg(EM_RetrieveArt), c ); */
		/*	sprintf( status, "%s %ld, %ld more", ErrMsg(EM_RetrieveArt), c, group[g].num_msgs ); */
			sprintf( status, ErrMsg(EM_RetrieveArt), c, group[g].num_msgs );
			show_status( status );
			x = news_article( c, current_article );
			if (x==1) { break; }		/* file write error, eject */
			if (x==4) { break; }		/* leave if escape key used */
			if (x==3) { break; }		/* loss of carrier, etc.	*/
			if (x==0) {					/* update group display */
				group[g].first_msg++;
				group[g].num_msgs--;
			}		
			if (memcmp(header, "4", 1)==0) {	/* 412, 420, 423, 430 responses */
				remove( current_article );
			} else {
				create_xover_header( c, current_article );
			}
		}
	}
	hide_status();
}

void newsgroup_to_directory( char *newsgroup, char *directory )
{
	char *p,*q,temp[50],temp2[60];
	int d=0;

	strcpy( temp, newsgroup ); 
	p = strtok( temp, "." );
	while ((q = strtok( NULL, "." ))!=NULL) {
		temp2[d++] = p[0];
		p = q;
	}
/*	compress vowels out of *p if necessary */
	strcpy( temp2+d, p );
/*	fprintf( log, "newsgroup: %s, directory: %s\n", newsgroup, temp2 ); */
	temp2[8] = '\0';		/* maximum of 8 characters */
	strcpy( directory, temp2 );
	sprintf( article_path, "%s\\%s", prefs.offline_path, directory );
}

void read_all_groups(void)
{
	int rc,c;
	char the_path[FMSIZE],directory[15];
/*	char status[50]; */

	if (ncn<0) { return; }
	strcpy( the_path, article_path );		/* save article_path */
	for (c=0;c<maximum_group+1;c++) {
		if (group[c].first_msg<=group[c].last_msg) {	/* any articles? */
			use_status( 2 );	/* use window info line */
			newsgroup_to_directory( group[c].name, directory );
			mkdir( article_path, S_IWRITE|S_IREAD ); 
			show_status( group[c].name );
			evnt_timer( 1200, 0 );		/* wait 1.2 seconds */
			if (ncn>=0) {
				rc = news_group( group[c].name );
				read_all_articles( c, article_path );
				group[c].viewed = VIEWED;
			}
			hide_status();
		}
	}
	unload_group( current_newsgroup );
	strcpy( article_path, the_path );		/* restore article_path */
}

void create_xover_header(long c, char *article )
{
	FILE *fid;
	char path[FMSIZE];

	parse_news_header( article );
	if (strlen( news_hdr.ref_id )> 299) { strcpy( news_hdr.ref_id, "parse" ); }	/* parse again for followup */
	sprintf( path, "%s\\xover.txt", article_path );
	fid = fopen( path, "aa" );
	if (fid!=NULL) {
		fprintf( fid, "%ld\t%s\t%s\t%s\t%s\t%s\t%ld\t%d\t%s\n",
			c, news_hdr.subject, news_hdr.from, news_hdr.datetime,
			news_hdr.msg_id, news_hdr.ref_id, (long)filesize(article), news_hdr.lines, news_hdr.xref );
		fclose( fid );
	}
}

void parse_news_header( char *filename )
{
	FILE *fid;
	size_t index;
	char field[1000],entry[1000],line[1000],*p;
	long l1,l2;

	strcpy( news_hdr.subject, "<no subject>" );		/* initialize */
	news_hdr.from[0]='\0';
	news_hdr.reply_to[0]='\0';
	news_hdr.followup_to[0]='\0';
	news_hdr.datetime[0]='\0';
	news_hdr.msg_id[0]='\0';
	news_hdr.ref_id[0]='\0';
	news_hdr.xref[0]='\0';

	fid = fopen( filename, "ra" );
	if (fid!=NULL) {
		while (fgets( line, sizeof(line), fid )!=NULL) {
			if (memcmp( line, "\n", 1 )==0) { break; }
			strtok( line, "\n" );		/* remove linefeed */
			/* determine if this is a header continuation line */
			if (line[0]=='\t'||line[0]==' ') {	/* is first character a tab or space, i.e. continuation? */
				if (strcmpi("References", field)==0) {	/* continuation of References? */
					l1 = strlen( news_hdr.ref_id );	/* what is there already */
					l2 = strlen( line );			/* and length of this line */
					if ((l1+l2) < (sizeof( news_hdr.ref_id)-1)) {	/* will they both fit? */
						p = strchr( news_hdr.ref_id, '\0' );	/* locate end of string */
						strcpy( p, line );
						*p = ' ';	/* overlay tab with space */
					}
					continue;	/* read next line */
				}
				/* handle other continuations of other headers here */
				continue;	/* read next line */
			}
			/* Copy all bytes up to and not including the ":" into field[] */
			index=strcspn(line, ":");
			if (index>0) {
				strncpy(field, line, index);
				field[index]=0;
				strcpy(entry, &line[index+2]);	/* Copy the rest into entry[] */
				#ifdef MDEBUG
					printf("%s: %s\n", field, entry);
				#endif
				if (strcmpi("Subject", field)==0)
					strncpy(news_hdr.subject, entry, 79);
				else if (strcmpi("From", field)==0)
					strncpy(news_hdr.from, entry, 79);
				else if (strcmpi("Reply-to", field)==0)
					strncpy(news_hdr.reply_to, entry, 79);
				else if (strcmpi("Date", field)==0)
					strncpy(news_hdr.datetime, entry, 29);
				else if (strcmpi("Message-ID", field)==0)
					strncpy(news_hdr.msg_id, entry, 79);
				else if (strcmpi("References", field)==0) {
					l1 = sizeof( news_hdr.ref_id )-1;
					while (strlen(entry) > l1) {
						p = strrchr( entry, '<' );	/* last < */
						p[-1] = '\0';	/* remove reference */
					}
					strncpy(news_hdr.ref_id, entry, l1);
				}
				else if (strcmpi("Xref", field)==0) {
					l1 = sizeof( news_hdr.xref )-1;
					while (strlen(entry) > l1) {
						p = strrchr( entry, ' ' );	/* last ' ' */
						p[0] = '\0';	/* remove reference */
					}
					strncpy(news_hdr.xref, entry, l1);
				}
				else if (strcmpi("Followup-To", field)==0)
					strncpy(news_hdr.followup_to, entry, 79);
				else if (strcmpi("Lines", field)==0)
					news_hdr.lines = atoi(entry);
			}
		}
		fclose( fid );
	}
}

void read_selected_articles(int g, char *the_path)
{
	long c,over,more=0;
	int x,update=0;
	char status[50];

	if (current_overview<0) { return; }
	fprintf( log, "Selected newsgroup: %s\n", group[g].name ); fflush(log);
	for (over=0;over<maximum_overview+1;over++) {
		if (overview[over].viewed==SELECT_RET) { more++; }
	}
	use_status( 2 );	/* use window info line */
	for (over=0;over<maximum_overview+1;over++) {
		if (overview[over].viewed!=SELECT_RET) { continue; }
		c = overview[over].article_number;
		sprintf( current_article, "%s\\%ld.txt", the_path, c );
	/*	sprintf( status, "%s %ld, %ld more", ErrMsg(EM_RetrieveArt), c, more-- ); */
		sprintf( status, ErrMsg(EM_RetrieveArt), c, more-- );
		show_status( status );
		x = news_article( c, current_article );
		if (x==1) { break; }		/* file write error, eject */
		if (x==4) { break; }		/* leave if escape key used */
		if (x==3) { break; }		/* loss of carrier, etc. */
		if (x==0) {					/* update group display */
			overview[over].viewed=VIEWED;	/* retrieved */
			update++;
		}		
		if (memcmp(header, "4", 1)==0) {	/* 412, 420, 423, 430 responses */
			remove( current_article );
		} else {
			create_xover_header( c, current_article );
		}
	}
	hide_status();
	if (update) { refresh_clear_window(windows[2].id); }
}

/* read all articles in the selected newsgroup */
void read_all_selected_group(int index)
{
	int rc;
	char the_path[FMSIZE],directory[15];
/*	char status[50]; */

	if (ncn<0) { return; }
	strcpy( the_path, article_path );		/* save article_path */
	if (index<maximum_group+1) {
		if (group[index].first_msg<=group[index].last_msg) {	/* any articles? */
			use_status( 2 );	/* use overview window info line */
			newsgroup_to_directory( group[index].name, directory );
			mkdir( article_path, S_IWRITE|S_IREAD ); 
			show_status( group[index].name );
			evnt_timer( 1200, 0 );		/* wait 1.2 seconds */
			if (ncn>=0) {
				rc = news_group( group[index].name );
				read_all_articles( index, article_path );
				group[index].viewed = VIEWED;
			}
			hide_status();
		}
	}
	unload_group( current_newsgroup );
	strcpy( article_path, the_path );		/* restore article_path */
}

/* read selected articles in the selected newsgroup */
void read_selected_selected_group(int index)
{
	int rc;
	char the_path[FMSIZE],directory[15];

	if (ncn<0) { return; }
	if (index<0) { return; }
	strcpy( the_path, article_path );		/* save article_path */
	if (index<maximum_group+1) {
		newsgroup_to_directory( group[index].name, directory );
		mkdir( article_path, S_IWRITE|S_IREAD ); 
		if (ncn>=0) {
			rc = news_group( group[index].name );
			read_selected_articles( index, article_path );
		}
	}
	strcpy( article_path, the_path );		/* restore article_path */
}

void read_offline_support(void)
{
	int c,selected=0;

	if (current_group<0) {	/* no group selected, get all */
		read_all_groups();
		if (windows[1].id>0) { refresh_clear_window( windows[1].id ); }
		return;
	}
	if (maximum_overview>=0) {
		for (c=0;c<maximum_overview+1;c++) {
			if (overview[c].viewed==SELECT_RET) { selected++; }
		}
	}
	if (selected) {	/* get selected articles */
		read_selected_selected_group( current_group );
	} else {	/* get all articles */
		read_all_selected_group( current_group );
	}
	if (windows[1].id>0) { refresh_window( windows[1].id ); }
}


/* end of OFFLINE.C */

