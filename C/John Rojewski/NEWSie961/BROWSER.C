/*
 *  browser.c
 *  Written by: John Rojewski	10/03/96
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
#include "newsie.h"
#include "protocol.h"
#include "http.h"

#include "global.h"

#define VERSION "0.962 Aug  8, 2000"
#define ErrMsg(a) (char *)em[a].ob_spec
#define Button_Enable(x) dlog[x].ob_state&=~DISABLED
#define MT _AESglobal[1]!=1		/* Multi-tasking OS */

char *strtoka( char *s, int tok );	/* prototype */
void beep(void);					/* prototype */

typedef struct html_option {
/*	struct html_option *next; */
	int index;
	char value[20][60];	/* maximum of 20 options/select */	
} HTMLOPTION;

typedef struct html_select {
	struct html_select *next;
	char name[40];
	int size;
	char multiple[5];
	struct html_option *options;
	int selected;		/* which options->value is currently selected */
} HTMLSELECT;

typedef struct html_input {
	TEDINFO ted;	/* TEDINFO structure for editable text */
	int type;		/* see INPUT_ defines below */
	int x,y;		/* location relative to start of form */
	char initial[60];	/* initial value */
	char value[60];
	char name[40];
	int size;
	int index;
	int local;		/* parms not sent during submit */
} HTMLINPUT;

#define INPUT_UNSUPPORTED 0
#define INPUT_TEXT	1
#define INPUT_PASSWORD	2
#define INPUT_FILE	3
#define INPUT_CHECKBOX	4
#define INPUT_RADIO	5
#define INPUT_SUBMIT	6
#define INPUT_RESET	7
#define INPUT_IMAGE	8
#define INPUT_HIDDEN	9

typedef struct htmlform {
	struct htmlform *next;		/* next <form> definition */
	OBJECT *tree;				/* allocated AES object tree */
	int x,y,voffset;			/* location relative to start of document */
	int treesize;
	int treeindex;
	struct html_select *select;
	struct html_input input[20];	/* maximum 20 inputs per form */
	char validate[80];			/* tedinfo validation */
	char format[80];			/* tedinto format string */
	char action_url[256];		/* action= parameter */
	char method[10];			/* method= (GET|POST) */
	char enctype[40];			/* method= parameter */
} HTMLFORM;

typedef struct htmlmap {
	struct htmlmap *next;		/* next <map> definition */
	OBJECT *tree;				/* allocated AES object tree */
	int treesize;
	int treeindex;
	char name[64];				/* usemap= name */
} HTMLMAP;

typedef struct htmlanchor {
	struct htmlanchor *next;
	struct urlinfo {
		GRECT r;			/* rectangle location/size */
		char url[256];
		char filename[FMSIZE];
		char title[80];
	} urls[20];
} HTMLANCHOR;

typedef struct htmlinfo {
	struct htmlinfo *previous;	/* pointer to previous htmlinfo block */
	struct htmlanchor *anchors;	/* name= or id= urls/files */
 	struct htmlanchor *links;	/* href= */
	struct htmlform *forms;		/* pointer forms urls/files */
	struct htmlmap *maps;		/* pointer image maps urls/files */
	char url[256];
	char base[256];
	char filename[FMSIZE];
	char content_type[256];      /* MIME type of the object */
	char title[80];
	int	window_index;	/* window_index where this document originated */
	int	display_index;	/* display_index is where this document is displayed */
	int counter;		/* counter of # times of displayed */ 
	int num_lines;		/* number of lines in formatted file */
	int line_no;		/* current line number */
	int list_num;		/* current number for ol and ul */
	char *buff;			/* start of entire file */
	char *body;			/* start of html body text */
	char *current;		/* current location in file */
	char *cmd;			/* start of command (after '<') */
	char *cmd_parms;	/* start of command parameters */
	char *cmd_end;		/* end of command (after '>') */
	char *cmd_tail;		/* start of command tail (after '</') */
	char *cmd_tail_end;	/* end of command tail (after '>') */
	char *last_anchor;	/* start of last anchor command */
/*	char *enclosed;		/* start of enclosed text (within cmd and tail) */
} HTMLINFO;


void *html_global(int way, void *value)
{
	static *glob=NULL;
	static *glob3=NULL;
	static *glob7=NULL;
	static *glob8=NULL;	/* help window */

	if (way==3) { return ( glob3 ); }
	if (way==-3) { return( glob3=value ); }

	if (way==7) { return( glob7 ); }
	if (way==-7) { return( glob7=value ); }

	if (way==8) { return( glob8 ); }
	if (way==-8) { return( glob8=value ); }

	if (way==12) { return( glob ); }
	if (way==-12) { return( glob=value ); }

	return(NULL);
}

#define html_get(x)	html_global( 12, x ) 
#define html_set(x)	html_global(-12, x )

/*
GEM window                                
  title                                   
  info line (for URL)                     
  scrolling                               
  cursor tracing                          
  GDOS fonts                              
  menu handling                           
  popup menus                             
  selectable fields(URLs)                 
URL processing                            
  relative                                
  fixed                                   
  file system (TOS) translation           
Font selectionpresets                     
  normal                                  
  h1 thru h6                              
  menu                                    
  directory                               
  address                                 
  blockquite                              
  example                                 
  preformatted                            
  listing                                 
HTML format tags                          
  Structure                               
    <html> </html>                        
    <head> </head>                        
    <body> </body>                        
  Titles and Headings                     
    <title> </title>                      
    <h1> </h1> and <h2> thru <h6>         
  General Formatting                      
    <! comment>                           
    <p> </p>                              
    <br>                                  
    <hr>                                  
    <blockquite> </blockquite>            
    <address> </address>                  
    <pre> </pre>                          
    <center> </center>                    
    <font size=> </font>                  
  Lists                                   
    <ul> </ul>                            
    <ol> </ol>                            
    <li>                                  
    <dl> </dl>                            
    <dd>                                  
    <dt>                                  
  Logical Styles                          
    <em> </em>                            
    <strong> </strong>                    
    <code> </code>                        
    <kdb> </kbd>                          
    <samp> </samp>                        
    <var> </var>                          
    <dfn> </dfn>                          
    <cite> </cite>                        
  Physical Styles                         
    <b> </b>                                  
    <i> </i>                                   
    <tt> </tt>                                  
  Images                                  
    <img align= src= width= height= alt=> 
  Linkages                                
    <a href= name=> </a>                  
  Forms                                   
    <form method= action=> </form>        
    <input type= name= value=>            
    <select> </select>                    
    <option>                              
  Special Characters and escapes          
    &quot;                                
    &amp;                                 
    &lt;                                  
    &gt;                                  
    &#nnn;                                
GIF Image processing                      
  need source or linkable module          
*/

void purge_url_files(void)
{
	struct FILEINFO info;
	char path[FMSIZE],file[FMSIZE];

	sprintf( path, "%s\\url*.*", prefs.browser_cache_path );
	if (!dfind(&info, path, 0)) {	/* determine if file exists */
		do {
			sprintf( file, "%s\\%s", prefs.browser_cache_path, info.name );
		/*	fprintf( log, "Deleting %s\n", file ); */
			remove( file );
		} while (!dnext(&info));
	}
}

void assign_url_file( char *url, char *path )
{
	static long urlnum;	/* unique for single execution */

	sprintf( path, "%s\\url%05ld.htm", prefs.browser_cache_path, urlnum );
	urlnum++;
}
	
void build_file_directory( char *url, char *path )
{
	FILE *fid;
	int c;
	long count;
	struct FILEINFO info;
	char dir[FMSIZE];
	char files[2500],*pointers[200];	/* maximum of 200 files */

	strcpy( dir, path );
	assign_url_file( url, path );
	if ((fid = fopen( path, "wa" ))!=NULL) {
		fprintf( fid, "<html>\n<head>\n" ); 
		fprintf( fid, "<title>Directory for %s</title>\n", url ); 
		fprintf( fid, "</head>\n<body>\n" ); 
		fprintf( fid, "<h1>Directory for %s</h1>\n", url ); 

		chdir( dir );
		if ((count = getfnl("*.*", files, sizeof(files), FA_SUBDIR ))>0) {	/* sub directories */
			if (strbpl(pointers,200,files)==count) {
			/*	fprintf( log, "%s contains %ld files\n", dir, count ); */
				strsrt( pointers, count );
				for (c=0;c<count;c++) {
					if (!dfind(&info, pointers[c], FA_SUBDIR )) {	/* directories only */
						if (info.attr&FA_SUBDIR) {
							fprintf( fid, "<p><a href=\"%s%s/\">%s\\</a>\n", url,info.name,info.name );
							pointers[c][0]='\0';
						}
					}
				}
				for (c=0;c<count;c++) {
					if (pointers[c][0]=='.') {pointers[c][0]='\0'; }
					if (pointers[c][0]!='\0') {
						fprintf( fid, "<p><a href=\"%s%s\">%s</a>\n", url,pointers[c],pointers[c] ); 
					}
				}
			}
		} else {
			fprintf( fid, "<p>Too many entries in Directory\n" ); 
		}
		chdir( program_path );
		fprintf( fid, "</body>\n</html>\n" ); 
		fclose( fid );
	}
}
 
void edit_url(char *url, char *path)
{
	char index[15]=" index.html";	/* leading space */
	char *p;

	p = strrchr( url, '/' );		/* last forward slash, filename */
	if (p!=NULL) {
		if (*(p+1)=='\0') {		/* directory only? */
		/*	strcat( url, &index[1] ); */
			index[10]='\0';
			p=index;
		}
		sprintf( path, "%s\\%s", prefs.browser_cache_path, (p+1) );
	}
	if (path[0]=='\0') { assign_url_file( url, path ); }
}

int open_url_dialog(char *url, char *path)
{
	OBJECT *dlog;
	int result;
	char temp[256];
	
	rsrc_gaddr(R_TREE,Open_URL,&dlog);
	set_tedinfo( dlog, OU_url, current_url );
	if (prefs.browser_home[0]!='\0') { Button_Enable(OU_Home); }
	result = handle_dialog(dlog, OU_url );
	if (result==OU_OK) {
		get_tedinfo( dlog, OU_url, url );
		if (strpbrk( url, ":./")==NULL) {	/* if this is a single word, w/o protocol */
			sprintf( temp, "http://www.%s.com", url );	/* try putting www. and .com on it */
			strcpy( url, temp );
		}
		if (strchr( url, ':')==NULL) {	/* if w/o protocol */
			sprintf( temp, "http://%s", url );	/* try putting http:// on it */
			strcpy( url, temp );
		}
		edit_url( url, path);
		strcpy( current_url, url );
		return(1);
	}
	if (result==OU_Home) {
		open_url_home();
	}
	return(0);
}

int open_helper_url( char *path )
{
	int c=0;
	char ext[FMSIZE];
	struct FILEINFO finfo;

	if (!dfind(&finfo, path, 0)) {	/* determine if file exists */
		stcgfe( ext, path );
		strlwr( ext );		/* lowercase for next compare */
		if (memcmp( ext, "avr", 3 )==0) {
			info.content_type[0]='\0';
			avr( path );
			c=1;
		}
		if (memcmp( ext, "wav", 3 )==0) {
			info.content_type[0]='\0';
			wav( path );
			c=1;
		}
	}
	return(c);
}


int open_url_file(char *url, char *path)
{
	int c=-1;
	char *p;
	char ext[FMSIZE];
	struct FILEINFO finfo;

	if (strlen(url)>8) {	/* if url exists */
		p=url+7;			/* point past "file://" */
		if (memcmp(p,"localhost",9)==0) { p+=9; }	/* skip over "localhost" */
		if (*p=='/') {
			strcpy( path, p+1 );
			while ((p=strchr(path,'/'))!=NULL) { *p='\\'; }
			if (!dfind(&finfo, path, 0)) {	/* determine if file exists */
				stcgfe( ext, path );
				strlwr( ext );		/* lowercase for next compare */
				if (memcmp( ext, "htm", 3 )==0) {
					strcpy(info.content_type,"text/html" );
				} else {
					strcpy(info.content_type,"text/plain" );
				}
				c=0;
				c = open_helper_url( path );
				DHST_Add( path );	/* Support DHST (Document History) */
			} else {
				build_file_directory( url, path );
				strcpy(info.content_type,"text/html" );
				c=0;
			}
		}
	}
	return(c);
}

int open_url_http(char *url, char *path)
{
	int c=-1;

	edit_url( url, path );
	if (STiK>0) {
		use_status( 12 );
		show_status( ErrMsg(EM_RetrieveURL) );
		c = get_url( url, path );
	/*	if (c<100) { fprintf( log, "http retrieval error = %d for %s", c, url ); } */
		if (c==401) {
			if (memcmp( info.www_authenticate, "Basic ", 6)==0) {
				if (www_authenticate()) {
					c = get_url( url, path );	/* retry retrieve */
				}
			}
		}
		if (c>=100) { c = 0; }	/* handle HTTP/1.x nnn return code */
		hide_status();
	} else { no_stik(); }	
/*	strcpy( info.content_type, "text/plain" );	/* temporary for testing */
	if (c==0) {	c = open_helper_url( path ); }
	return(c);
}

int open_url_ftp( char *url, char *path)
{
	char c,s;

	if ((fpi>=0)||(windows[11].id>0)) { 	/* error, ftp active */
	/*	show_warning( "FTP session currently active" ); */
	/*	status_text( "Terminate session and retry" );	*/
	/*	evnt_timer( 2000, 0 );		/* wait 2 seconds */
	/*	hide_status(); */
		return(-1);
	}

	c=prefs.connect_startup;	/* save parameters */
	s=prefs.subscribe_startup;
	CAB_internet_ftp_client( url );
	prefs.connect_startup=c;	/* restore parameters */
	prefs.subscribe_startup=s;
	return(1);	/* good, no browser window */
}

int open_url_news(char *url, char *path)
{
	int c;

	/* news:newsgroup supported, news:message_id not supported */
	if (strchr(url, '@')!=NULL) { 	/* error, message_id */
	/*	show_warning( "news: format not supported" ); */
	/*	evnt_timer( 2000, 0 );		/* wait 2 seconds */
	/*	hide_status(); */
		return(-1);
	}

	unload_overview();		/* unload possible open overview */

	/* attempt to find newsgroup in current_newsgroup first */
	for (c=0;c<maximum_group+1;c++) {
		if (strcmp( group[c].name, url+5 )==0) {
			current_group=c;	/* set current_group */
			key_group( '\r' );	/* and retrieve overview */
			return(1);			/* good, no browser window */
		}
	}

	/* otherwise create and open a new newsgroup file
	unload_group( current_newsgroup );
	CAB_internet_news_client( url );
	standard_startup();
	current_group=0;	/* set current_group to first newsgroup */
	key_group( '\r' );	/* and retrieve overview */
	return(1);		/* good, no browser window */
}

int open_url_continue_window( char *url, char *path, int wx )
{
	int c=-1;
	/* 0=good, 1=good/no window, -1=bad/no window */

	if (strnicmp(url,"http://",7)==0) { c = open_url_http(url, path); }
	if (strnicmp(url,"file://",7)==0) { c = open_url_file(url, path); } 
	if (strnicmp(url,"ftp://", 6)==0) { c = open_url_ftp(url, path); }
	if (strnicmp(url,"news:", 5)==0)  { c = open_url_news(url, path); }
	if (strnicmp(url,"mailto:",7)==0) { c=1; browser_mailto( url ); } 

	if (strnicmp(url,"html://",7)==0) {	/* internal, non-standard protocol */
		c = open_url_file(url, path);
		if (c==0) strcpy( info.content_type, "text/html" );	/* override content_type */
	} 

	if (c==0) {
		fprintf( log, "%s %s in window %d\n", ErrMsg(EM_FileRetrieved), path, wx );
		if (memcmp(info.content_type,"text",4)==0) {
			if (wx==12) { strcpy( current_browse, path ); }
			windows[wx].num_lines = (int16)count_lines( path );
			windows[wx].line_no   = 0;
			new_window( wx, url, screenx, screeny, 530, 280 );
		} else { c=1; }	/* not "text" means no window */
	}
	return(c);
}

/* re-define open_url_continue() to call open_url_continue_window() */
int open_url_continue( char *url, char *path )
{
	return( open_url_continue_window( url, path, 12 ) );
}

void open_url(void)
{
	char url[FMSIZE],path[FMSIZE];

	if (open_url_dialog( url, path )) {
		handle_redraw_event();
		open_url_continue( url, path );
	}
}

void *new_htmlcs(int wx)
{
	HTMLINFO *cs,*prev=NULL;

	if ((cs = html_global(wx, NULL))!=NULL) { prev = cs; }	/* previous block? */
	if ((cs = calloc( 1, sizeof(HTMLINFO) ))!=NULL) {
		cs->previous = prev;			/* link to possible previous */
		prev = cs;						/* hold allocated address */
		cs = html_global(-1*wx, cs);	/* save this address in list */
		if (cs==NULL) { free( prev ); }	/* window does not have global!!!, cannot store */
		if (cs) {
			cs->window_index = wx;		/* establish originator window */
			cs->display_index = wx;		/* establish display window */
			if ((wx==3)||(wx==7)) { cs->display_index = 12; }	/* limit for mail and articles */
		}
	} /* else report allocation error */
	return(cs);
}

void *new_htmlinfo(void)
{
	return( new_htmlcs( 12 ) );
}

void new_form( HTMLINFO *cs )
{
	HTMLFORM *next=NULL,*form;
	int c;
	OBJECT *dlog;

	next = cs->forms;
	if ((form = calloc( 1, sizeof(HTMLFORM) ))!=NULL) {
		cs->forms = form;
		form->next = next;
		memset( form->validate, 'X', 79 );	/* all characters are valid */
		memset( form->format, '_', 79 );	/* all characters editable */
		form->treesize = 20;
		form->treeindex = 1;
		form->tree = calloc( cs->forms->treesize, sizeof(OBJECT) );
		if (dlog=form->tree) {
		/* initialize object zero x,y,w,h and ob_type=G_IBOX */
			for (c=0;c<20;c++) {
				dlog[c].ob_next=dlog[c].ob_head=dlog[c].ob_tail=NIL;
			}
			memcpy( &(dlog[0].ob_x), &screenx, 8 );
			dlog[0].ob_type=G_IBOX;
		}
	/*	form->select = NULL; */
	}
}

void new_select( HTMLFORM *form )
{
	HTMLSELECT *next=NULL,*select;

	next = form->select;
	if ((select = calloc( 1, sizeof(HTMLSELECT) ))!=NULL) {
		form->select = select;
		select->next = next;
	}
}

void *release_form( HTMLFORM *form )
{
	void *next,*nselect;

	while (form!=NULL)	{
		next=form->next;
		if (form->tree) { free(form->tree); }
		while (form->select) {
			if (form->select->options) { free(form->select->options); }
			nselect=form->select->next;
			free(form->select);
			form->select=nselect;
		}
		free( form );
		form=next;
	}
	return(form);
}

void open_url_path(char *url)
{
	char path[FMSIZE],*p;
	HTMLINFO *cs=NULL;

	edit_url( url, path);
	if ((cs = new_htmlinfo())!=NULL) {	/* push down previous block */
		strcpy( cs->url, url );
		while ((p=strchr(cs->url,'\\'))!=NULL) { *p='/'; }
		if (open_url_continue( url, path )==0) {
			strcpy( cs->content_type, info.content_type );
		} else {
			key_browser( 0x0e08 );	/* backspace to previous document */
		}
	}
}

void open_url_path_window(char *url, int wx)
{
	char path[FMSIZE],*p;
	HTMLINFO *cs=NULL;

	edit_url( url, path);
	if ((cs=new_htmlcs(wx))!=NULL) {	/* push down previous block */
		strcpy( cs->url, url );
		while ((p=strchr(cs->url,'\\'))!=NULL) { *p='/'; }
		open_url_continue_window( url, path, wx );
		strcpy( cs->content_type, info.content_type );
	}
}

void open_url_home(void)
{
	char url[FMSIZE];

	if (strcmp(current_browse, prefs.browser_home)==0) { return; }
	if (prefs.browser_home[0]!='\0') {
		sprintf( url, "file:///%s", prefs.browser_home );
		open_url_path( url );
	}
}

void open_url_hotlist(void)
{
	char url[FMSIZE];

	if (strcmp(current_browse, prefs.browser_hotlist)==0) { return; }
	if (prefs.browser_hotlist[0]!='\0') {
		sprintf( url, "file:///%s", prefs.browser_hotlist );
		open_url_path( url );
	}
}

void open_url_history(void)
{
	char url[FMSIZE],*where;
	struct FILEINFO finfo;

	sprintf( url, "%s\\%s", prefs.browser_cache_path, "history.htm" );
	if (dfind(&finfo, url, 0)) { return; } /* exit if no file exists */

	if (stcpm(current_browse, "history.htm", &where)) { return; }
	sprintf( url, "file:///%s/%s", prefs.browser_cache_path, "history.htm" );
	open_url_path( url );
}

int select_html_file(char *dirname)
{
	char select[FMSIZE];
	char path[FMSIZE];
	int button;

	select[0]='\0';
	sprintf( dirname, "%s\\*.htm", prefs.work_path );	
	fsel_exinput( dirname, select, &button, ErrMsg(EM_SelectFile) ); /* "Select File" */
	if (button) {
		stcgfp( path, dirname );
		sprintf( dirname, "%s\\%s", path, select );
	}
	return(button);
}

void *release_anchors(HTMLANCHOR *anc)
{
	HTMLANCHOR *next;

	while (anc!=NULL)	{
		next=anc->next; free( anc ); anc=next;
	}
	return(anc);
}

void *release_htmlinfo( HTMLINFO *cs )
{
	void *prev=NULL;

	if (cs!=NULL) {
		prev=cs->previous;
		if (cs->buff!=NULL)		{ free( cs->buff ); }
		release_anchors( cs->anchors );
		release_form( cs->forms );
		free( cs );
	}
	return(prev);	
}

void *pop_htmlinfo( HTMLINFO *cs )
{
	int wx;

	if (cs) {
		wx = cs->window_index;	/* originating window index */
		cs = release_htmlinfo( cs );
		/* cs = html_set(cs); */
		cs = html_global(-1*wx, cs);	/* store new/previous cs */
	}
	return(cs);
}

void handle_browser_close(void)
{
	HTMLINFO *cs=NULL;

	purge_url_files();
	cs = html_get(NULL);
	while (cs!=NULL) { cs=pop_htmlinfo( cs ); }
	current_browse[0]='\0';
}

void *previous_document( HTMLINFO *cs, int display )
{
	int wx;

	if (cs->previous!=NULL) {	/* if previous block exists */
 		wx = cs->display_index;	/* display window */
		cs = pop_htmlinfo( cs );
		if (wx==12) {
			strcpy( current_url, cs->url );
			strcpy( current_browse, cs->filename );
			strcpy( info.content_type, cs->content_type );
		}
		if (wx==8) {
			strcpy( current_helpfile, cs->filename );
		}
		windows[wx].line_no = cs->line_no;
		windows[wx].num_lines = cs->num_lines;
		release_window_buffer( wx, 1 );
		set_vslider( wx, windows[wx].id );
		if (cs->title[0]!='\0') { strcpy( windows[wx].title, cs->title ); }
		else { strncpy( windows[wx].title, cs->url, 79 ); }
		wind_title( windows[wx].id, windows[wx].title );
		if (display) refresh_clear_window( windows[wx].id );
	}
	return( cs );
}

void key_browser( int keycode )
{
	char filename[FMSIZE],ext[FNSIZE],*p;
/*	char title[FMSIZE]; */
	HTMLINFO *cs=NULL,*ns;

/*	if (arrow_page_scrolling_keys( windows[12].id, keycode )) { return; } */
	if (arrow_scrolling_keys( windows[12].id, keycode )) { return; }

	if ((keycode>>8)=='\x0e') {	/* backspace to previous document */
		if ((cs=html_get(cs))!=NULL) {	/* if HTMLINFO block */
			if (cs->previous!=NULL) {	/* if previous block */
				previous_document( cs, 1 );
			} else { beep(); }
		}
		return;
	}
	if ((char)keycode=='u') {	/* open url */
		open_url();
		return;
	}
	if ((char)keycode=='s') {	/* display source */
		if ((cs=html_get(NULL))!=NULL) {
			strcpy( filename, cs->filename );
			if ((ns = new_htmlinfo())!=NULL) {	/* push down previous block */
				strcpy(info.content_type,"text/plain" );
				strcpy( ns->content_type, info.content_type );
				strcpy( ns->url, cs->url );
				strcpy( ns->filename, cs->filename );
				ns->line_no = windows[12].line_no = 0;
				ns->num_lines = windows[12].num_lines = (int16)count_lines( filename );
				refresh_clear_window( windows[12].id );
				set_vslider( 12, windows[12].id );
			}
		}
		return;
	}
	if ((char)keycode=='d') {	/* display documents dialog */
		browser_documents();
		return;
	}
	if ((char)keycode=='?') {	/* display fields/anchors dialog */
		browser_fields();
		return;
	}
	if ((char)keycode=='h') {	/* display history.htm */
		open_url_history();
		return;
	}
	if ((char)keycode=='f') {	/* open local file */
		if (select_html_file( filename )) {
			stcgfe( ext, filename );
			strlwr( ext );		/* lowercase for next compare */
			if (memcmp( ext, "htm", 3 )==0) {
				strcpy(info.content_type,"text/html" );
			} else {
				strcpy(info.content_type,"text/plain" );
			}
			if ((cs=html_get(cs))!=NULL) {	/* if HTMLINFO block */
				if (strcmpi(cs->filename,filename)!=0) {
					if (cs->buff!=NULL) {
						free(cs->buff);
						cs->buff=NULL;
					}
				}
			}
			strcpy( current_browse, filename );
			windows[12].num_lines = (int16)count_lines( filename );
			windows[12].line_no   = 0;
			if ((cs = new_htmlinfo())!=NULL) {	/* push down previous block */
				strcpy( cs->content_type, info.content_type );
				sprintf( cs->url, "file:///%s", filename );
				while ((p=strchr(cs->url,'\\'))!=NULL) { *p='/'; }
			/*	strcpy( cs->url, current_url ); */
				strcpy( cs->filename, filename );
				cs->line_no = windows[12].line_no;
				cs->num_lines = windows[12].num_lines;
				new_window( 12, cs->url, screenx, screeny, 500, 300 );
			}
		}
	}
}

#define FORM_INPUTS 20

void submit_form( HTMLFORM *form )
{
	char url[1000];
	struct html_select *select;
	int c;

	if (strcmpi(form->method,"GET")==0) {
		strcpy( url, form->action_url );
		strcat( url, "?" );
		for (c=0;c<FORM_INPUTS;c++) {	/* get all input fields */
			if (!form->input[c].local) {
				if (c!=0) { strcat( url, "," ); }
				strcat( url, form->input[c].name );
				strcat( url, "=" );
			/*	encode special characters to %nn, ' ' to '+' */
				strcat( url, form->input[c].value );
			}
		}
		while (select=form->select) {	/* include select/option values */
			if (c!=0) { strcat( url, "," ); }
			strcat( url, select->name );
			strcat( url, "=" );
		/*	encode special characters to %nn, ' ' to '+' */
			strcat( url, select->options->value[select->selected] );
			select = select->next;
		}
		fprintf( log, "Submit URL: %s\n", url );
	/*	open_url_continue( url, path ); */
	}
	if (strcmpi(form->method,"PUT")==0) {
		fprintf( log, "Form type PUT not supported\n" );
	}
}

/* handle reset form button */
void reset_form( HTMLFORM *form )
{
	int c;

	for (c=0;c<FORM_INPUTS;c++) {
		switch (form->input[c].type)
		{
		case INPUT_TEXT:
			strcpy (form->input[c].value, form->input[c].initial );
		}
	}
}

void click_on_form( HTMLFORM *form, int index )
{
	int c;
	OBJECT *dlog;

/*	fprintf( log, "Click on form, index=%d\n", index ); */

	for (c=0;c<20;c++) {		/* translate object index to input field/button */
		if (form->input[c].index==index) {
			dlog = form->tree;
		/*	fprintf( log, "Click on input[%d], %d %s\n", c, form->input[c].type, form->input[c].name ); */
			switch (form->input[c].type)
			{
			case INPUT_SUBMIT:
				beep();
				submit_form( form );
				break;
			case INPUT_RESET:
				beep();
			/*	reset_form( form ); */
				break;
			case INPUT_CHECKBOX:
			/* 	toggle_crossed(dlog, tindex ); */
				dlog[index].ob_state ^= CROSSED;	/* toggle bit */
				break;
			}
			objc_draw( dlog, index, MAX_DEPTH, clip.g_x, clip.g_y, clip.g_w, clip.g_h );
		}
	}
}

int select_browser_form( HTMLINFO *cs, int mx, int my, int clicks )
{
	HTMLFORM *form;
	int result,voffset;
	int wx=12;
	GRECT r;

	voffset=(windows[wx].line_no*cellh);	/* offset for forms */
	wind_get( windows[wx].id, WF_WORKXYWH, &r.g_x, &r.g_y, &r.g_w, &r.g_h );
	mx += r.g_x;	/* make x,y screen absolute again */
	my += r.g_y;
	form = cs->forms;

	while (form) {
		r.g_y += form->voffset + form->y;
	/*	if (rc_inside( mx, my, &r )) {	/* is this form visible on screen? */
		if (voffset==form->voffset) {
			if ((result=objc_find(form->tree, ROOT, MAX_DEPTH, mx, my))!=-1) {
				beep();			/* mouse in form */
				if (result!=0)  { click_on_form( form, result ); }
				return(result);
			}
		}
		form = form->next;		/* try next form */
	}
	return(0);
}

int select_browser_map( HTMLINFO *cs, int mx, int my, int clicks )
{
	HTMLMAP *map;
	int result;

	map = cs->maps;
	while (map) {
		if ((result=objc_find(map->tree, ROOT, MAX_DEPTH, mx, my))!=-1) {
			beep();			/* mouse in map */
			return(result);
		}
		map = map->next;		/* try next map */
	}
	return(0);
}

void select_browser_none( int alt )
{
	if (alt&3) { browser_documents(); } else { browser_fields(); }
}

void find_html_fragment( HTMLINFO *cs, HTMLANCHOR *anx, int cx )
{
	HTMLANCHOR *anc;
	int c,alt,dummy,wx;
	char *p;
	GRECT r;

	wx=cs->display_index;
	if ((p=strchr( anx->urls[cx].url, '#'))==NULL) { /* check for fragment */
		beep();	return;
	}
	graf_mkstate(&dummy,&dummy,&dummy,&alt);

	if ((anc=cs->anchors)==NULL) { return; }
	while (anc!=NULL) {
		for (c=0;c<20;c++) {
			r=anc->urls[c].r;
			if (alt&8) { fprintf( log, "rect= %d, %d, %d, %d\n", r.g_x, r.g_y, r.g_w, r.g_h ); }
			if (r.g_w==0) { break; }
			if (r.g_h!=0) { continue; }		/* look for names only */
			if (alt&8) { fprintf( log, "Fragment find: %s %s\n", (p+1), anc->urls[c].url ); }
			if (strcmp( (p+1), anc->urls[c].url )==0) {
				/* if current document, just scroll window */
				windows[wx].line_no=anc->urls[c].r.g_y/cellh;
				refresh_clear_window( windows[wx].id );
				set_vslider( wx, windows[wx].id );
				return;
			}
		}
		anc=anc->next;
	}
	if (cs->display_index==12) {	/* since select_browser_none() only works w/id 12 */
		select_browser_none( alt );		/* exhausted blocks */
	}
}

/* send url to CAB for display via Shift, or to clipboard via Control key */
/* CAB must be running because NEWSie doesn't know what path to execute CAB from */
int send_url_to_CAB( char *url )
{
	int rc,shift,dummy;
	char prog[20];
	int id;
	char *env,*p;
	struct FILEINFO info;
	long cook,MagX=0x4d616758;	/* "MagX" */
	char tail[256],path[FMSIZE];

	if ((env = getenv( "BROWSER" ))!=NULL) {	/* user has specified browser? */
		strcpy( path, env );	/* had bombs in CAB w/env */
		if (dfind( &info, path, 0 )) { goto old_method; }	/* if file does not exist */
		if ((p=strrchr(path,'\\'))==NULL) { p=path; } else { p++; }
		if (strnicmp(p,"NEWSIE",6)==0) { goto old_method; }	/* not handled here! */

		if ( MT ) {		/* if we are in Multi-tasking OS */
			strtok(info.name, ".");
			sprintf( prog, "%-8.8s", info.name ); 
			if ((rc=appl_find( prog ))!=-1) {
			/*	fprintf( log, "Sending %s(%d) a VA_START for %s\n", prog, rc, url ); */
				send_VA_Start( rc, url );
				return(rc);
			}
		/*	This could also work for StringServer, etc. if designated */
			if (strnicmp(p,"CAB",3)==0) {	/* only CAB supported here (and now) */
	 			strcpy( tail+1, url );
			 	tail[0] = strlen(url);
		 		if (getcookie( MagX, &cook )) {	/* MagiC */
					shel_write( 1, 1, 100, path, tail );
				} else {			/* MiNT, Geneva, etc. */
					shel_write( 1, 1, 100, path, tail );
				}
				return(1);
			}
		}
	}

old_method:
	graf_mkstate(&dummy,&dummy,&dummy,&shift);	
	if (shift&4) {		/* if user holding control key */
		copy_text( url);
		return(1);
	}
	if (shift&3) {		/* if user holding either Shift key */
		if ( MT ) {		/* if we are in Multi-taking OS */
			rc=appl_search( 0, prog, &dummy, &id );
			while (rc) {
				if (memcmp(prog, "CAB", 3)==0) {	/* and appl "CAB" is running */
				/*	fprintf( log, "Sending %s(%d) a VA_START for %s\n", prog, id, url ); */
					send_VA_Start( id, url );
					return(1);
				}
				rc = appl_search( 1, prog, &dummy, &id );
			}
		}
	}
	return(0);
}

void activate_selected_browser_link( HTMLINFO *cs, HTMLANCHOR *anc, int c )
{
	int z;
	HTMLINFO *ns;

	if (send_url_to_CAB( anc->urls[c].url )) { return; }
	if ((z=open_url_continue( anc->urls[c].url, anc->urls[c].filename ))==0) {
		strcpy( current_browse, anc->urls[c].filename );
		windows[12].num_lines = (int16)count_lines( anc->urls[c].filename );
		windows[12].line_no   = 0;
		if ((ns = new_htmlinfo())!=NULL) {	/* push down previous block */
			strcpy( ns->content_type, info.content_type );
		/*	sprintf( current_url, "file:///%s", filename ); */
			strcpy( ns->url, anc->urls[c].url );
			new_window( 12, ns->url, screenx, screeny, 500, 300 );
		}
	} else {
		strcpy( info.content_type, cs->content_type );
		if (z<0) beep();
	}
}

void select_browser(int x, int y, int clicks)
{
	HTMLINFO *cs=NULL;
	HTMLANCHOR *anc;
	int c,ty,wx=12;
	int dummy,alt;
	GRECT r;

	if ((cs=html_get(cs))==NULL) { return; }

	ty=y+(windows[wx].line_no*cellh);	/* zero-based for scrolling */
	graf_mkstate(&dummy,&dummy,&dummy,&alt);
	if (alt&8) { fprintf( log, "click at: %d, %d\n", x, ty ); }

	if (cs->forms!=NULL)	{ if (select_browser_form( cs, x, y, clicks )) return; }
	if (cs->maps!= NULL)	{ if (select_browser_map( cs, x, y, clicks )) return; }
	if ((anc=cs->anchors)==NULL) { select_browser_none( 3 ); return; }

	while (anc!=NULL) {
		for (c=0;c<20;c++) {
			r=anc->urls[c].r;
			if (alt&8) { fprintf( log, "rect= %d, %d, %d, %d\n", r.g_x, r.g_y, r.g_w, r.g_h ); }
			if (r.g_w==0) { select_browser_none( alt ); return; }
			if (rc_inside( x, ty, &r )) {
				if (alt&8) { fprintf( log, "Found: %s\n", anc->urls[c].url ); }
				if (anc->urls[c].url[0]!='#') { /* check for fragment name in this url */
					activate_selected_browser_link( cs, anc, c );
					if (strchr( anc->urls[c].url, '#' )!=NULL) {	/* detect '#' in old url link */
						handle_redraw_event();		/* wait for anchor building in new HTMLINFO */
						if ((cs = html_global( wx, NULL))==NULL) { return; }
						find_html_fragment( cs, anc, c );	/* find in new HTMLINFO block */
					}
				} else {
					find_html_fragment( cs, anc, c );
				}
			return;
			}
		}
		anc=anc->next;
	}
	select_browser_none( alt );		/* exhausted blocks */
}

void browser_text( int wid, char *filename )
{
	if (strcmp(info.content_type,"text/html")==0) {
		browser_text_html( wid, filename );
		return;
	}
	if (strcmp(info.content_type,"text/plain")==0) {
		generic_window_text( wid, filename );
		return;
	}
/*	beep(); */
}

int text_extent( char *line )
{
	int points[8];

	vqt_extent( handle, line, points );	/* see documentation for points usage */
	return( points[2]-points[0] );		/* return width of string in pixels */
}

int toolbar_height( int wid )
{
	int wndx;
	static int oldwid=-1,height=0;

	if (wid<=0) { oldwid=-1; height=0; return(0); }	/* reset */

	if (wid!=oldwid) {
		height = 0;
		wndx=windows_index(wid);
		if (windows[wndx].bar_object!=NULL) {	/* has a toolbar */
			if (prefs.show_toolbar=='Y') { 	/* and on top */
				height = windows[wndx].bar_object->ob_height;	/* add height of toolbar */
			/*	beep(); */
			/*	fprintf( log, "wid=%d, height=%d\n", wid, height ); */
			}
		}
		oldwid = wid;
	}
	return( height );
}

int put_html_line(int wid, int x, int *y, char *buff, int *min_height)
{
	int wx,wy,ww,wh,rc=0;

	if (*buff!='\0') {	/* if not empty line */
		wind_get( wid, WF_WORKXYWH, &wx, &wy, &ww, &wh );
		wy += toolbar_height( wid );
		if (*min_height>cellh) { *y+=*min_height; } else { *y+=cellh; }
			v_gtext( handle, wx+x, wy+*y, buff );
		memset( buff, '\0', strlen(buff) );
		rc=1;
	}
	*min_height=0;
	return(rc);
}

void put_html_subline(int wid, int *x, int *y, char *buff)
{
	int s,v;
	int wx,wy,ww,wh;

	if (*buff!='\0') {	/* if not empty line */
		wind_get( wid, WF_WORKXYWH, &wx, &wy, &ww, &wh );
		wy += toolbar_height( wid );
		s = (short)strlen(buff);
		v=*y; 
			v_gtext( handle, wx+*x, wy+v+cellh, buff );
	/*	*x+=cellw*s; */
		*x+=text_extent( buff );
		memset( buff, '\0', s );
	}
}

void reset_html_effects(void)
{
	vst_effects( handle, 0 );	/* turn off text effects */
	vst_color( handle, BLACK );	/* reset text color */
}

#define html_available			0x000f7f10	/* remove bits when used below (18) */
#define html_pre				0x80000000
#define html_flush_buffer		0x40000000
#define html_put_subline		0x20000000
#define html_skip_a_line		0x10000000	/* was 01000000 */
#define html_form_form			0x08000000
#define html_form_input			0x04000000
#define html_form_select		0x02000000
#define html_form_option		0x01000000
#define html_put_title			0x00800000
#define html_horizontal_rule	0x00400000
#define html_list				0x00200000
#define html_img                0x00100000
#define html_color_blue			0x00008000
#define html_underline			0x00000080
#define html_bold				0x00000040
#define html_italic				0x00000020
#define html_reset_effects		0x00000008
#define html_reserved			0x00000007

#define html_set_list			0x40200000
#define html_end_anchor			0x20008088
#define html_start_anchor		0x20000000
#define html_paragraph			0x50000000	/* was 41000000 */
#define html_start_heading		0x40000040
#define html_end_heading		0x40000008
#define html_start_effect       0x20000000
#define html_end_effect         0x20000008
#define html_end_bold			0x20000048
#define html_end_italic			0x20000028
#define html_end_underline		0x20000088
#define html_form_begin			0x48000000
#define html_form_end			0x48000000
#define html_form_select_begin	0x02000000
#define html_form_select_end	0x02000000


long exec_command( int cmd, HTMLINFO *cs )
{
	long rtn=0;

	switch( cmd )
	{
		case 1:
			if (memcmp(cs->cmd,"hr",2)==0) { rtn=html_horizontal_rule; break; }
			if (memcmp(cs->cmd,"li",2)==0) rtn|=html_set_list;	
			if (memcmp(cs->cmd,"a ",2)==0) {
				rtn|=html_start_anchor;
				cs->last_anchor = cs->cmd;	/* mark command */
			}
			if (memcmp(cs->cmd,"br",2)==0) rtn|=html_flush_buffer;	
			if (memcmp(cs->cmd,"dt",2)==0) rtn|=html_paragraph;
			if (memcmp(cs->cmd,"p>",2)==0) rtn|=html_paragraph;
			if (memcmp(cs->cmd,"b>",2)==0) rtn=html_start_effect;
			if (memcmp(cs->cmd,"strong",6)==0) rtn=html_start_effect;
			if (memcmp(cs->cmd,"i>",2)==0) rtn=html_start_effect;
			if (memcmp(cs->cmd,"em>",3)==0) rtn=html_start_effect;
			if (memcmp(cs->cmd,"cite",4)==0) rtn=html_start_effect;
			if (memcmp(cs->cmd,"img",3)==0) rtn=html_img;
			if (memcmp(cs->cmd,"ul>",2)==0) { rtn=html_paragraph; cs->list_num=0; }
			if (memcmp(cs->cmd,"ol>",2)==0) { rtn=html_paragraph; cs->list_num=1; }
			if (memcmp(cs->cmd,"pre",3)==0) { rtn=html_pre; break; }
			if (memcmp(cs->cmd,"xmp",3)==0) { rtn=html_pre; break; }
			if (memcmp(cs->cmd,"listing",7)==0) { rtn=html_pre; break; }
			if (memcmp(cs->cmd,"form",4)==0) { rtn=html_form_begin; break; }
			if (memcmp(cs->cmd,"input",5)==0) { rtn=html_form_input; break; }
			if (memcmp(cs->cmd,"select",5)==0) { rtn=html_form_select_begin; break; }
			if (memcmp(cs->cmd,"option",5)==0) { rtn=html_form_option; break; }
			if (cs->cmd[0]=='h') {
				if (cs->cmd[1]=='1') { rtn=html_start_heading; break; }	
				if (cs->cmd[1]=='2') { rtn=html_start_heading; break; }	
				if (cs->cmd[1]=='3') { rtn=html_start_heading; break; }	
				if (cs->cmd[1]=='4') { rtn=html_start_heading; break; }	
				if (cs->cmd[1]=='5') { rtn=html_start_heading; break; }	
				if (cs->cmd[1]=='6') { rtn=html_start_heading; break; }	
			}
		/*	rtn|=html_flush_buffer; */
		/*	fprintf( log, "Command <%.6s lx\n", cs->cmd, rtn ); */
			break;
		case 2:
		/*	fprintf( log, "Command tail </%.6s\n", cs->cmd_tail ); */
			if (memcmp(cs->cmd_tail,"title",5)==0) rtn|=html_put_title;	
			if (memcmp(cs->cmd_tail,"a>",2)==0) { rtn=html_end_anchor; break; }	
			if (memcmp(cs->cmd_tail,"b>",2)==0) { rtn=html_end_bold; break; }
			if (memcmp(cs->cmd_tail,"strong",6)==0) { rtn=html_end_bold; break; }
			if (memcmp(cs->cmd_tail,"i>",2)==0) { rtn=html_end_italic; break; }
			if (memcmp(cs->cmd_tail,"em>",3)==0) { rtn=html_end_italic; break; }
			if (memcmp(cs->cmd_tail,"cite",4)==0) { rtn=html_end_italic; break; }
			if (memcmp(cs->cmd_tail,"ul>",2)==0) { rtn=html_paragraph; break; }
			if (memcmp(cs->cmd_tail,"ol>",2)==0) { rtn=html_paragraph; break; }
			if (memcmp(cs->cmd_tail,"pre",3)==0) { rtn=html_pre; break; }
			if (memcmp(cs->cmd_tail,"xmp",3)==0) { rtn=html_pre; break; }
			if (memcmp(cs->cmd_tail,"listing",7)==0) { rtn=html_pre; break; }
			if (memcmp(cs->cmd_tail,"form",4)==0) { rtn=html_form_end; break; }	
			if (memcmp(cs->cmd_tail,"select",5)==0) { rtn=html_form_select_end; break; }
			rtn|=html_flush_buffer;
			if (cs->cmd_tail[0]=='h') {
				if (cs->cmd_tail[1]=='1') { rtn=html_end_heading; break; }	
				if (cs->cmd_tail[1]=='2') { rtn=html_end_heading; break; }	
				if (cs->cmd_tail[1]=='3') { rtn=html_end_heading; break; }	
				if (cs->cmd_tail[1]=='4') { rtn=html_end_heading; break; }	
				if (cs->cmd_tail[1]=='5') { rtn=html_end_heading; break; }	
				if (cs->cmd_tail[1]=='6') { rtn=html_end_heading; break; }	
			}
			break;
	}
	return(rtn);
}

void expand_relative_url( HTMLINFO *cs, char *url )
{
	char fullurl[256],*p,*q;

	if (url[0]=='#') { return; }
	/*	cs->url = http://domain/xxxxxxx/xxxxxx/file.htm */
	if ((strchr(url,':'))==NULL) {		/* no ':', must be relative */
		if (cs->base[0]) {
			strcpy( fullurl, cs->base );	/* base url */
		} else {
			strcpy( fullurl, cs->url );		/* document url */
		}
		if ((q=strchr(fullurl,':'))==NULL) { return; }
	/*	if ((p=strrchr((q+3),'/'))!=NULL) { *(p+1)='\0'; } */
		if ((p=strrchr((q+3),'/'))!=NULL) {	/* end of last directory */
			*(p+1)='\0';			/* http://domain/xxxxxxx/xxxxxx/ */
			if (memcmp( url, "../", 3 )==0) { 	/* up 2 directories */
				*p='\0';		/* http://domain/xxxxxxx/xxxxxx */
				if ((p=strrchr((q+3),'/'))!=NULL) {
					*p='\0';	/* http://domain/xxxxxxx */
					if ((p=strrchr((q+3),'/'))!=NULL) { *(p+1)='\0'; }	/* http://domain/ */
				}
			}
			if (url[0]=='/') {	/* up single directory */
				*p='\0';	/* remove last slash */
				if ((p=strrchr((q+3),'/'))!=NULL) { *(p+1)='\0'; }
			}
		}
		else { strcat(fullurl,"/"); }	/* append '/' */
		strcat( fullurl, url );
	/*	fprintf( log, "Expanded: %s to %s\n", url, fullurl ); */
		strcpy( url, fullurl );
	}
/*	 else {
		if ((memcmp(url,"http://",7)==0)&&(p=strrchr( url+7, '/'))!=NULL) {
			if ((strchr( p, '.')==NULL)&&(*(p+1)!='\0')) { strcat( url, "/" ); }
		} else { strcat( url, "/" ); }
	} */
}

int extract_long_parameter( char *cmd, char *tag, char *parm, int psize )
{
	char *p,*q;
	long len;

	if (cmd==NULL) { return(0); }
	p=cmd;
	*parm='\0';
	len=strlen(tag);
	while (*p!='>') {
		if (memcmp(p,tag,len)==0) {
			p+=len;
			while (*p==' ') { p++; }
			if    (*p=='=') { p++; } else { continue; }	/* nope */
			while (*p==' ') { p++; }
			if    (*p=='\"') { p++; }
		/*	memcpy( parm, p, 120 ); */
			strncpy( parm, p, psize );
			p=parm;
		/*	*(p+120)='\0'; */
			*(p+psize-1)='\0';
			if ((q=strchr(p,'\"'))) { *q='\0'; }
			if ((p=strchr(p,'>'))) { *p='\0'; }
		/*	fprintf( log, "extract=%.80s\n", cmd ); */
			return(1);
		}
		p++;
	}
	return(0);
}

void extract_flag( char *cmd, char *tag, char *found )
{
	char *p;
	long len;

	if (cmd==NULL) { return; }
	p=cmd;
	*found='\0';
	len=strlen(tag);
	while (*p!='>') {
		if (memcmp(p,tag,len)==0) { *found='Y'; return; }
		p++;
		if (*p=='\0') { return; }
	}
}

int insert_html_anchor( HTMLINFO *cs, int x, int y, int w, int h, char *title )
{
	/* 0=not inserted, 1=inserted href=, 2=inserted name= */
	int c,depth=0,rc=0;
	HTMLANCHOR *anc;
	GRECT anc2;
	char url[256];

/*	fprintf( log, "Insert anchor at %d, %d, %d, %d\n", x, y, w, h ); */
	anc2.g_x=x; anc2.g_y=y; anc2.g_w=w; anc2.g_h=h;
	if (w==0) { return(0); }
	if (cs!=NULL) {
		if (cs->anchors==NULL) {
			cs->anchors = calloc( 1, sizeof(HTMLANCHOR) );
		}
		anc=cs->anchors;
		while (anc!=NULL) {
			if (anc->urls[19].r.g_w==0) { /* if block not full */
				for (c=0;c<20;c++) {
					if (rc_equal( &(anc->urls[c].r), &anc2)) { return(0); }	/* duplicate entry */
					if (anc->urls[c].r.g_w==0) { /* width==0 = empty */

					/* extract url from command parm list */
						if (extract_long_parameter( cs->last_anchor, "name", url, 256)) {
						/*	h=0;	/* special flag for name= anchors */
						/*	expand_relative_url( cs, url ); */
							rc=2;
						} else if (extract_long_parameter( cs->last_anchor, "href", url, 256)) {
							expand_relative_url( cs, url );
							rc=1;
						} else if (cs->cmd[0]=='h') {
							if (extract_long_parameter( cs->cmd, "id", url, 256)) {
							/*	h=0;	/* special flag for name= anchors */
								rc=2;
							}
						}
						if (rc) {
							anc->urls[c].r.g_x=x;
							anc->urls[c].r.g_y=y;
							anc->urls[c].r.g_w=w;
							anc->urls[c].r.g_h=h;
							if (rc==2) anc->urls[c].r.g_h=0;	/* flag for name/id fragments */
						/* save link explanitory text/title */
							strncpy( anc->urls[c].title, title, 80 );
							anc->urls[c].title[79]='\0';
							strcpy( anc->urls[c].url, url );
						}
						return(rc);	/* no href or name found */
					}
				}
			}
			if (anc->next==NULL) {
				anc->next = calloc( 1, sizeof(HTMLANCHOR) );
			}
			anc=anc->next;
			depth++;
			if (depth>10) { fprintf( log, "Anchor depth>10\n" ); return(0); }
		}
	}
	return(0);
}

int browser_escape( char *p, char *z )
{
#define NUM_HTML_ESCAPE 6
	static char esc[NUM_HTML_ESCAPE][8] = { "lt;", "gt;", "quot;", "amp;", "copy;", "nbsp;" };
	static char chx[NUM_HTML_ESCAPE] = { '<', '>', '\"', '&', 189, ' ' };
	char *q;
	long i,j;
	int  ret=0;

	if (p[1]=='#') {	/* numeric escape */
		if ((q = strchr( p, ';' ))==NULL) { return(ret); }
		i = atoi( &p[2] );	/* get numeric value */
		if (i<1) { return(ret); }	/* i must be greater than zero */ 
		*(z-1)=i;			/* set specified character */
		ret=(int)(q-p)+1;		/* return displacement */
	} else {		/* character escape */
		for (i=0;i<NUM_HTML_ESCAPE;i++) {
			j=strlen( esc[i] );
			if (memcmp( &p[1], esc[i], j )==0) {
			/*	fprintf( log, "%s = %ld %c %c\n", esc[i], j, *p, chx[i] ); */
				*(z-1)=chx[i];
				ret=(int)j;
				break;
			}
		}
	}
	return(ret);
}	

void append_http_history( char *url, char *title )
{
	FILE *fid;
	char path[FMSIZE],desc[80];
	struct tm *tp;
	time_t t;

	if (memcmp( url, "http://", 7)!=0) { return; }
 	if (prefs.browser_history!='Y') { return; }	
	sprintf( path, "%s\\history.htm", prefs.browser_cache_path );
	fid = fopen( path, "aa" );
	if (fid!=NULL) {
		time(&t);
		tp = localtime(&t);
	/*	fprintf( fid, "<p>%s ", asctime(tp) ); */
		fprintf( fid, "<p>%24.24s ", asctime(tp) );
		strcpy( desc, title );		/* copy title */
		if (desc[0]=='\0') {		/* if title empty */
			memcpy( desc, url, 80);	/* copy some of url */
			desc[79]='\0';		/* and terminate */
		}
		fprintf( fid, "<a href=%s>%s</a>\n", url, desc );
		fclose( fid );
	}
}

void build_html_form( HTMLINFO *cs, int cmd, int x, int y, int voffset )
{
/*	char startend[3][6]={"","Begin","End"}; */
	HTMLFORM *form;
	GRECT r;
	int tindex;

	if (cmd==1) {
	/*	fprintf( log, "%s Form: %.40s\n", startend[cmd], cs->cmd ); */
		new_form( cs );		/* allocate and initialize form block */
		if (form=cs->forms) {
			form->x = x;
			form->y = y;
			form->voffset = voffset;
			extract_long_parameter( cs->cmd, "action", form->action_url, sizeof(form->action_url));
			extract_long_parameter( cs->cmd, "method", form->method, sizeof(form->method));
			extract_long_parameter( cs->cmd, "enctype", form->enctype, sizeof(form->enctype));
			wind_get( windows[12].id, WF_WORKXYWH, &r.g_x, &r.g_y, &r.g_w, &r.g_h );
		/*	form->tree[0].ob_x = 50;
			form->tree[0].ob_y = 50; */
		/*	form->tree[0].ob_x = r.g_x + 50;
			form->tree[0].ob_y = r.g_y + 50;
			form->tree[0].ob_width =  r.g_w - 50;
			form->tree[0].ob_height = r.g_h - 50; */
			form->tree[0].ob_x = r.g_x + x;
			form->tree[0].ob_y = r.g_y + y;
			form->tree[0].ob_width =  r.g_w - 50;
			form->tree[0].ob_height = r.g_h - 50;
		}
	}
	if (cmd==2) {
		if (form=cs->forms) {
			form->tree[0].ob_height=200;	/* test only */
			if ((tindex = form->treeindex - 1)>0) {
			/*	form->tree[0].ob_height = tindex*16;	/* test only */
			/*	form->tree[0].ob_height = form->tree[0].ob_x+(tindex*16); */
				form->tree[0].ob_height = form->tree[tindex].ob_x+form->tree[tindex].ob_height;
				form->tree[tindex].ob_flags |= LASTOB;
			}
		}
	/*	fprintf( log, "%s Form: %.40s\n", startend[cmd], startend[0] ); */
	}
}

int build_html_input( HTMLINFO *cs, int cmd, int *x, int *y )
{
	char type[10],value[60],name[60],csize[10];
/*	char src[256],align[10]; */
	int c,size,rc=0;
	OBJECT *dlog;
	HTMLFORM *form;
	TEDINFO *td;
	int tindex;

/*	fprintf( log, "Input: %.20s\n", cs->cmd ); */

	if (!(form=cs->forms)) { return(rc); }

	extract_long_parameter( cs->cmd, "type", type, sizeof(type));
	extract_long_parameter( cs->cmd, "value", value, sizeof(value));
	extract_long_parameter( cs->cmd, "name", name, sizeof(name));
	extract_long_parameter( cs->cmd, "size", csize, sizeof(csize));
	if (csize[0]!=0) { size = atoi( csize ); }
	if (size>80) { size=80; }

	for (c=0;c<20;c++) {	/* find slot for input parameters */
		if (form->input[c].type==0) { break; }
		if (c==19) {
			fprintf( log, "Form input slots exceeded\n" );  /* no available slot */
			return(rc);
		}
	}
/*
	strcpy( form->input[c].type, type );
	strcpy( form->input[c].value, value );
	strcpy( form->input[c].name, name );
	form->input[c].index = form->treeindex;
	form->input[c].x = *x - form->x;
	form->input[c].y = *y - form->y;
*/
	dlog = form->tree;
	tindex = form->treeindex;

	if (type[0]==0) { strcpy(type,"text"); }

	if (strcmp(type,"text")==0) {	/* G_FBOXTEXT */
		form->input[c].type = INPUT_TEXT;
		form->input[c].size = size;
		dlog[tindex].ob_type = G_FBOXTEXT;
		td = &form->input[c].ted;
		dlog[tindex].ob_spec  = td;
	/* need to build TEDINFO structure for text editing */
		td->te_ptext  = form->input[c].value;
		td->te_ptmplt = form->format+80-size;
		td->te_pvalid = form->validate+80-size;
		td->te_font   = 3;	/* IBM */
	/*	td->te_fontid = x; */
	/*	td->te_just   = x; */
	/*	td->te_fontsize = x; */
		td->te_color  = 0x1170;		/* set color bits */
		td->te_thickness = -1;
		td->te_txtlen = size;
		td->te_tmplen = size;
	/* need to set x,y,w,h  (TEMP values) */
	/*	dlog[tindex].ob_x = 20;
		dlog[tindex].ob_y = 50+(16*c); */
		dlog[tindex].ob_x = *x - form->x;	/* offset from form */
		dlog[tindex].ob_y = *y - form->y;	/* offset from form */
		*x += dlog[tindex].ob_width = size*8;
		dlog[tindex].ob_height = 16;
		rc = dlog[tindex].ob_height + 2;
		objc_add( dlog, ROOT, tindex );	/* add the object to the tree */
	}
#if (0)
	if (strcmp(type,"hidden")==0) {
	}
	if (strcmp(type,"password")==0) {
	}
	if (strcmp(type,"file")==0) {	/* not supported? */
	}
#endif
	if (strcmp(type,"checkbox")==0) {	/* G_BOXCHAR */
		form->input[c].type = INPUT_CHECKBOX;
		dlog[tindex].ob_type = G_BOXCHAR;
		dlog[tindex].ob_state = CROSSED+SELECTED;
		dlog[tindex].ob_flags = NONE;
	/*	dlog[tindex].ob_x = 20;
		dlog[tindex].ob_y = 50+(16*c); */
		dlog[tindex].ob_x = *x - form->x;	/* offset from form */
		dlog[tindex].ob_y = *y - form->y;	/* offset from form */
		*x += dlog[tindex].ob_width = 16;
		dlog[tindex].ob_height = 16;
		rc = dlog[tindex].ob_height + 2;
		objc_add( dlog, ROOT, tindex );	/* add the object to the tree */
	}
#if (0)
	if (strcmp(type,"radio")==0) {	/* G_PROGDEF */
	/*	dlog[treeindex].ob_type = G_PROGDEF; */
	}
#endif
	if (strcmp(type,"submit")==0) {	/* G_BUTTON */
		dlog[form->treeindex].ob_type = G_BUTTON;
		if (value[0]=='\0') strcpy( value, "Submit" );
		dlog[form->treeindex].ob_spec = form->input[c].value;
		form->input[c].type = INPUT_SUBMIT;
		form->input[c].local = 1;
		dlog[tindex].ob_flags = EXIT+DEFAULT;
	/*	dlog[tindex].ob_x = 20;
		dlog[tindex].ob_y = 50+(16*c); */
		dlog[tindex].ob_x = *x - form->x;	/* offset from form */
		dlog[tindex].ob_y = *y - form->y;	/* offset from form */
		*x += dlog[tindex].ob_width = (int)(strlen(value)+2)*8;
		dlog[tindex].ob_height = 16;
		rc = dlog[tindex].ob_height + 2;
		objc_add( dlog, ROOT, tindex );	/* add the object to the tree */
	}
	if (strcmp(type,"reset")==0) {	/* G_BUTTON */
		dlog[form->treeindex].ob_type = G_BUTTON;
		if (value[0]=='\0') strcpy( value, "Reset" );
		dlog[form->treeindex].ob_spec = form->input[c].value;
		form->input[c].type = INPUT_RESET;
		form->input[c].local = 1;
		dlog[tindex].ob_flags = TOUCHEXIT;
	/*	dlog[tindex].ob_x = 20;
	 	dlog[tindex].ob_y = 50+(16*c); */
		dlog[tindex].ob_x = *x - form->x;	/* offset from form */
		dlog[tindex].ob_y = *y - form->y;	/* offset from form */
		*x += dlog[tindex].ob_width = (int)(strlen(value)+2)*8;
		dlog[tindex].ob_height = 16;
		rc = dlog[tindex].ob_height + 2;
		objc_add( dlog, ROOT, tindex );	/* add the object to the tree */
	}
#if (0)
	if (strcmp(type,"image")==0) {
		extract_long_parameter( cs->cmd, "src", src, sizeof(src));
		extract_long_parameter( cs->cmd, "align", align, sizeof(align));
	}
#endif
	if (form->input[c].type) {
		strcpy( form->input[c].value, value );
		strcpy( form->input[c].name, name );
		form->input[c].index = tindex;
		form->treeindex++;
		fprintf( log, "input[%d] index=%d x,y,w,h=%d,%d,%d,%d\n", c, tindex, 
			dlog[tindex].ob_x, dlog[tindex].ob_y, dlog[tindex].ob_width, dlog[tindex].ob_height );
	}
	return(rc);
}

void build_html_select( HTMLINFO *cs, int cmd )
{
/*	char startend[3][6]={"","Begin","End"}; */
	char name[60],size[6];

	if (!cs->forms) { return; }

	if (cmd==1) {
	/*	fprintf( log, "%s Select: %.20s\n", startend[cmd], cs->cmd ); */
		extract_long_parameter( cs->cmd, "name", name, sizeof(name));
		extract_long_parameter( cs->cmd, "size", size, sizeof(size));
	/*	extract_long_parameter( cs->cmd, "multiple", multiple, sizeof(multiple)); */
	/*	new_select( cs->forms );	/* allocate a select block */
	}
	if (cmd==2) {
	/*	fprintf( log, "%s Select: %.20s\n", startend[cmd], startend[0] ); */
	}
}

void build_html_option( HTMLINFO *cs, int cmd )
{
	char value[60];
	char selected;

/*	fprintf( log, "Option: %.20s\n", cs->cmd ); */

	if (!cs->forms) { return; }

	extract_long_parameter( cs->cmd, "value", value, sizeof(value));
	extract_flag( cs->cmd, "selected", &selected );

	if (!cs->forms->select) { return; }
}

void browser_lowercase( char *buff, long size )
{
/*
	lowercase all commands (<...>)
	remove any '\r\n' characters (except for <pre> </pre>)
	translate non-printable characters to spaces
	re-define inpre=1 until <html> and again after </html>
*/
	register char *p,*end;
	int cmd=0,inquote=0,inpre=1;	/* 0.962 pre until <html> */

	p=buff;
	end=buff+size;
	while(p<end) { /* until end of string */
		if (!inpre) {
			if (*p=='\r') *p=' ';
			if (*p=='\n') *p=' ';
			if (*p<' ') *p=' ';		/* if less than space */
		}
	/*	if (*p=='<') { cmd=1; inquote=0; } */
		if (*p=='<') { 
			if (memcmp( p+1, "!--", 3)==0) { /* if comment start? */
				p+=2;		/* skip over start */
				while ((*p)&&(memcmp(p,"->",2)!=0)) { p++; }
				p++; 
			} else {
				cmd=1; inquote=0;
			}
		}
		if (*p=='>') {
			cmd=0;
			if (memcmp( p-3, "pre", 3 )==0) { inpre=1; }
			if (memcmp( p-4, "/pre", 4 )==0) { inpre=0; }
			if (memcmp( p-3, "xmp", 3 )==0) { inpre=1; }
			if (memcmp( p-4, "/xmp", 4 )==0) { inpre=0; }
			if (memcmp( p-7, "listing", 7 )==0) { inpre=1; }
			if (memcmp( p-8, "/listing", 8 )==0) { inpre=0; }
			if (memcmp( p-4, "html", 4 )==0) { inpre=0; }
			if (memcmp( p-5, "/html", 5 )==0) { inpre=1; }
		}
		if (*p=='\"')  inquote=!inquote;
		if (cmd&&!inquote) *p = tolower( *p);
		p++;
	}
}

void browser_extended_text( int wid, int wx, GRECT *work, char *filename )
{
	unsigned char *start,*p,*q;
	char buff[200],parm[130];
	struct FILEINFO finfo;
	FILE *fid;
	int x,y,width,margin,ax,bx,voffset,c,remain;
	int cmd=0,inpre=0,inhtml=0;
/*	int inquote=0; */
	long cmdrtn,tsize;
	HTMLINFO *cs=NULL;
	HTMLFORM *form;
	int points[4],text_size[8]={0,6,4,2,0,0,0,0};
	int min_height=0,bar_height;

	for (c=1;c<7;c++) { text_size[c]+=cellh; }
	bar_height = toolbar_height(wid);

	if (!dfind(&finfo, filename, 0)) {	/* locate file and size */
		if ((cs=html_global( wx, cs))==NULL) {
		/*	if ((cs = new_htmlinfo())!=NULL) {	/* push down previous block */
		/*	cs = new_htmlinfo(); */
			cs = new_htmlcs( wx );
			if (cs==NULL) { return; }	/* cannot continue */
		/*	fprintf( log, "html_get = %lx\n", cs ); */
			strcpy( cs->url, current_url );
		}
		strcpy( cs->content_type, info.content_type );
		if (cs->buff==NULL) {
			if ((cs->buff = malloc( finfo.size+1 ))!=NULL) {
				if ((fid = fopen( filename, "rb" ))!=NULL) {
					fread( cs->buff, finfo.size, 1, fid ); 
					fclose( fid );
				}
				cs->buff[finfo.size]='\0';		/* terminate file */
				strcpy( cs->filename, filename );
				browser_lowercase( cs->buff, finfo.size );
			}
		}
		if (cs->buff!=NULL) {
			cs->anchors = release_anchors( cs->anchors );	/* release anchor block */
 
			/*  start display process */

			margin=cellw;			/* left/right establish page margins */
			width=(work->g_w/cellw)-2;	/* in characters */
		/*	x=work->g_x+margin; */
		/*	y=work->g_y; */
			x=margin;					/* zero-based */
			voffset=(windows[wx].line_no*cellh);	/* offset for anchors */
			cs->line_no=windows[wx].line_no;
			cs->num_lines=0;	/* initialize */
			y=-voffset;
			start=cs->buff;
			p=buff;
			memset( buff, '\0', sizeof(buff) );

			while(start<(cs->buff+finfo.size)) { /* until past end */
				/*	parse commands	*/
				if (*start=='<')  {	/* this is a command or tail */
				/*	if (handle_escape_events()==27) { break; }	/* escape from format loop */
					if (*(start+1)=='/')  {
						cs->cmd_tail=start+2;
						cmd=2;
					} else {
						cs->cmd=start+1;
						cs->cmd_parms=NULL;
						cmd=1;
					}
					while (*start!='>') { start++; }
					if (cmd==1)  {	/* is this a command? */
						cs->cmd_end=start+1;
						if (memcmp(cs->cmd, "html", 4)==0) { inhtml=1; }	/* begin formatting */
					}
					if (cmd==2)  {	/* is this a command tail? */
						cs->cmd_tail_end=start+1;
						if (memcmp(cs->cmd_tail, "html", 4)==0) { inhtml=2; }	/* end formatting */
					}
					cmdrtn = exec_command( cmd, cs );

					if (cmdrtn==html_pre) { inpre=(cmd==1); }
					if (cmdrtn==html_img) {
						sprintf( p, "[IMG] " );
					/*	extract_long_parameter( cs->cmd, "src", parm); */
						extract_long_parameter( cs->cmd, "alt", parm, 130 );
						strcpy( p+6, parm );
						p+=strlen(p);
					}	
					if (cmdrtn&html_put_title) {	/* </title> */
						buff[79]='\0';				/* less than 80 chars */
						strcpy( windows[wx].title, buff );
						strcpy( cs->title, buff );
						wind_title( wid, windows[wx].title );
						memset( buff, '\0', strlen(buff) );
						p=buff;
					}
					if (cmdrtn&html_underline) {
						vst_effects( handle, UNDERLINED );
					}
					if (cmdrtn&html_color_blue) {
						vst_color( handle, BLUE );
					}
					bx=x;				/* for html_end_anchor */
				/*	ax=x+((int)strlen(buff)*cellw);	/* for htm_end_anchor */
					ax=x+text_extent( buff );	/* for htm_end_anchor */
					if (cmdrtn==html_end_heading) {
						q=cs->last_anchor;
						cs->last_anchor=NULL;
						insert_html_anchor( cs, bx, y+voffset, ax-bx, cellh, buff );
						cs->last_anchor=q;
					}
					if (cmdrtn&html_flush_buffer) {
						if (put_html_line( wid, x, &y, buff, &min_height )) { cs->num_lines++; }
						if (x!=margin) { y+=cellh; cs->num_lines++; } /* break w/empty line */
						x=margin;
						p=buff;
					}
					if (cmdrtn&html_bold) {
						vst_effects( handle, THICKENED );
					}
					if (cmdrtn&html_italic) {
						vst_effects( handle, SKEWED );
					}
					if ((tsize=cmdrtn&html_reserved)) {
					/*	vst_point( handle, text_size[tsize] ); */
					}
					if (cmdrtn==html_end_anchor) {
					/*	insert_html_anchor( cs, bx, y+voffset, ax-bx, cellh ); */
						if (insert_html_anchor( cs, bx, y+voffset, ax-bx, cellh, buff )==2) {
							reset_html_effects();	/* no blue/underline for name= */
						}
					}
					if (cmdrtn&html_skip_a_line) {
						y+=cellh;
						cs->num_lines++;
					}
					if (cmdrtn==html_set_list) {
						if (cs->list_num) {
							sprintf( buff, "%d.", cs->list_num++ );
						} else {
							sprintf( buff, "* " );
						}
						p=buff+strlen(buff);
					}
					if (cmdrtn&html_put_subline) {
						put_html_subline( wid, &x, &y, buff );
						p=buff;
					}
					if (cmdrtn&html_reset_effects) {
						reset_html_effects();
					}
					if (cmdrtn&html_horizontal_rule) {	/* <hr> */
					/*	fprintf( log, "hr=%lx\n", cmdrtn ); */
						if (x!=margin) { y+=cellh; cs->num_lines++; }
						x=margin;
						points[0]=x+work->g_x;
						points[1]=y+work->g_y+(cellh/2);
						points[2]=work->g_w-(2*margin);
						points[3]=points[1];
						v_pline( handle, 2, points );
						y+=cellh; 
						cs->num_lines++;
					}

					if (memcmp(prefs.email_address,"rojewski",8)==0) {
					/*	if (cs->counter==0) { /* build only first time */
							if (cmdrtn&html_form_form) {
								build_html_form( cs, cmd, x, y, voffset );
							}
							if (cmdrtn&html_form_input) {
								put_html_subline( wid, &x, &y, buff ); /* put subline */
								p=buff;
								min_height = build_html_input( cs, cmd, &x, &y ); /* */
								if (inpre) strcat(buff, " " );	/* force new line */
							}
							if (cmdrtn&html_form_select) {
								build_html_select( cs, cmd );
							}
							if (cmdrtn&html_form_option) {
								build_html_option( cs, cmd );
							}
					/*	} */
					}

					if (inhtml==2) { break; }	/* after flushing buffer, finish */
					cmd=0;
					start++;
					continue;
				}
				if (!cmd) {
				/*	if (!inhtml) { continue; }	/* ignore text outside <html> and </html> */

					if (inpre) {
						if ((*start=='\r')||(*start=='\n')) {
							if (put_html_line( wid, x, &y, buff, &min_height )) { cs->num_lines++; }
							x=margin;
							p=buff;
							if ((*start=='\r')&&(*(start+1)=='\n')) { start++; } 	/* skip possible linefeed */
						} else {
							if (*start=='\t') {	/* support tab expansion */
								strcat( buff, "    " ); p+=4;
							} else {		/* store the character */
								if ((p-buff)<190) *p++ = *start;
							}
						}
						if (*start=='&') { start+=browser_escape( start, p ); }
						start++;
						continue;
					}

					if (*start!=' ') {
						remain=((width*cellw)-x)/cellw;
						if (remain>width) { remain=width; }
						if (p>buff+remain) { /* wrap text */
							q=strrchr( buff, ' ');		/* word wrap */
							if (q!=NULL) *q='\0';
							if (put_html_line( wid, x, &y, buff, &min_height )) { cs->num_lines++; }
							x=margin;
							p=buff;
							if (q!=NULL) {
								p = stpcpy( p, q+1 );
								*q=' ';
								while(*q) { *q++='\0'; }
							}
						}
						*p++ = *start;
						if (*start=='&') { start+=browser_escape( start, p ); }
					}
					/*	suppress extra space characters */
					else {
						if ((p!=buff)&&(*(p-1)!=' ')) { *p++ = *start; }
						if ((p==buff)&&(x!=margin)) { *p++ = *start; }
					}
				}
				start++;
			}

			/* perform actual drawing of AES tree in browser window */
			form=cs->forms;
			if (form) {
				objc_draw( form->tree, ROOT, MAX_DEPTH, work->g_x, work->g_y, work->g_w, work->g_h );
				form = form->next;
			}
			windows[wx].num_lines=cs->num_lines;
			set_vslider_size( wid, windows[wx].lines_per_page, cs->num_lines );
			if (cs->counter++==0) { append_http_history( cs->url, cs->title ); } 	
		}
	}
}

void browser_text_html( int wid, char *filename )
{
	GRECT work,temp;
	int x,y,wx,lpp;
	OBJECT *bar;

	wx = windows_index(wid);
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

	temp = work;		/* copy rectangle */
	if (rc_intersect( &clip, &temp )) {		/* if there is an intersect */
		set_clip( &temp );					/* set smaller clipping rectangle */
		browser_extended_text(wid, wx, &work, filename);
	}
/*	if (rc_intersect( &work, &clip )) {	set_clip( &clip ); } */
/*	browser_extended_text(wid, w, &work, filename); */
}

void browser_reload(void)
{
	HTMLINFO *cs=NULL;
	char url[256],path[FMSIZE];

	if ((cs = html_get(NULL))!=NULL) {	/* if document being displayed */
		strcpy( url, cs->url );		/* get url */
		strcpy( info.content_type, cs->content_type );
#if (0)
		if (cs->buff!=NULL) {		/* release document buffer */
			free( cs->buff );
			cs->buff=NULL;
		}
		cs->anchors = release_anchors( cs->anchors );	/* release anchors, etc. */
#endif
		cs = pop_htmlinfo( cs );	/* release current information */
		if ((cs = new_htmlinfo())!=NULL) {	/* push down previous block */
			strcpy( cs->content_type, info.content_type );
			strcpy( cs->url, url );
		}

		path[0] = '\0';			/* clear pathname = ignore cache/force retrieve */
		open_url_continue( url, path );	/* fetch it again (for the first time) */
	}
}

int browser_dialog_common( char *pointers[], int count )
{
	int c,result,chosen=-1,fstart=0;
	int x,y,w,h,width=0;
	char empty[]="";
	void *dest[10];
	OBJECT *dlog;

	rsrc_gaddr(R_TREE,Font_List,&dlog);
	for (c=0;c<count;c++) {
		x=(int)(strlen(pointers[c])+3)*8;
		if (width+dlog[0].ob_width>x) { continue; }
	/*	fprintf( log, "width[%d] = %d\n", count, width); */
		if (x>dlog[0].ob_width) width=x-dlog[0].ob_width;
	}
	if ((width+dlog[0].ob_width)>screenw) { width = screenw - dlog[0].ob_width - 16; }	/* keep on screen */

	resize_font_dialog( dlog, width );			/* change dialog size */
	form_center(dlog,&x,&y,&w,&h);
	graf_mkstate( &x, &y, &c, &c );			/* close to mouse */
	x-=8; y-=4;

	if (x<0) { x=0; }
	if ((x+w)>(screenx+screenw)) { x = screenx + screenw - w; }
	if ((y+h)>(screeny+screenh)) { y = screeny + screenh - h; }

	dlog[0].ob_x = x;
	dlog[0].ob_y = y;
	if (!save_restore_screen( 1, dlog )) {	/* save */
		form_dial(FMD_START,0,0,0,0,x,y,w,h);
	}

	set_tedinfo( dlog, FL_Exit1, empty );
	for (c=0;c<10;c++) {		/* save original ob_specs */
		dest[c]=dlog[FL_FontName1+c].ob_spec;
	}
	do {
		for (c=FL_FontName1;c<FL_FontName10+1;c++) {
			dlog[c].ob_spec=pointers[fstart+c-FL_FontName1];
		}
		objc_draw(dlog,0,10,x,y,w,h);
		result=form_do(dlog, 0);
		switch (result)
		{
			case FL_UpArrow :
				fstart = (fstart-10 > 0) ? fstart-10 : 0;	/* maximum */
				break;
			case FL_DnArrow :
				if (pointers[fstart+9][0]=='\0') { break; }
				if (fstart+10 < (count-1)) { fstart+=10; }	/* minimum */
				break;
			case FL_Exit1 :
			case FL_Exit2 :
				break;
			default :
				chosen=fstart+result-FL_FontName1;
		}
		dlog[result].ob_state&=~SELECTED;	/* de-select exit button */
	} while ((result==FL_UpArrow)|(result==FL_DnArrow ));
	for (c=0;c<10;c++) {		/* restore original ob_specs */
		dlog[FL_FontName1+c].ob_spec=dest[c];
	}
	if (!save_restore_screen( 0, dlog )) {	/* restore */
		form_dial(FMD_FINISH,0,0,0,0,x,y,w,h);
	}
	resize_font_dialog( dlog, -width );	/* restore size */

	return(chosen);
}

void browser_documents(void)
{
	HTMLINFO *cs;
	int c,count=0,chosen;
	char empty[]="";
	char *pointers[100];	/* maximum of 100 documents deep */

	for (c=0;c<100;c++) { pointers[c]=empty; }
	cs = html_get(NULL);
	while (cs!=NULL) {
		if (cs->title[0]!='\0') {
			pointers[count++]=cs->title;
		} else {
			pointers[count++]=cs->url;
		}
		cs=cs->previous;
	}
	if (count==0) { return; }	/* number of documents */

	chosen = browser_dialog_common( pointers, count );

	if (chosen==-1) { return;}
	if (pointers[chosen]==empty) { return; }
	cs = html_get(NULL);
	while (cs!=NULL) {	/* back to selected document, dropping others */
		if ((pointers[chosen]==cs->url)||(pointers[chosen]==cs->title)) {
			refresh_clear_window( windows[12].id );
			break;
		}
		cs = previous_document( cs, 0 );	/* previous doc, no display */
	}
}

void browser_links(int wx)
{
	HTMLINFO *cs;
	HTMLANCHOR *anc;
	int c,count=0,chosen;
	char empty[]="";
#define MAX_BR_FIELDS 200
	char *pointers[MAX_BR_FIELDS];	/* maximum of 200 fields per document */

	for (c=0;c<MAX_BR_FIELDS;c++) { pointers[c]=empty; }
	if ((cs = html_global( wx, NULL))!=NULL) {
/*	if ((cs = html_get(NULL))!=NULL) { */
		anc=cs->anchors;
		while (anc!=NULL) {
			for (c=0;c<20;c++) {	/* anchors per HTMLANCHOR block */
				if (anc->urls[c].r.g_h==0) { continue; }	/* special flag for name= anchors */
				if (anc->urls[c].title[0]!='\0') {
					pointers[count++]=anc->urls[c].title;
				} else {
					pointers[count++]=anc->urls[c].url;
				}
			/*	pointers[count++]=anc->urls[c].url; */
				if (count>=MAX_BR_FIELDS) { break;}
			}
			anc=anc->next;
		}
	}

	if (count==0) { return; }	/* number of anchor fields */

	chosen = browser_dialog_common( pointers, count );

	if (chosen==-1) { return;}
	if (pointers[chosen]==empty) { return; }

	if ((cs = html_global( wx, NULL))!=NULL) {	/* locate chosen url and activate */
		anc=cs->anchors;
		while (anc!=NULL) {
			for (c=0;c<20;c++) {	/* anchors per HTMLANCHOR block */
			/*	if (pointers[chosen]==anc->urls[c].url) { */
				if ((pointers[chosen]==anc->urls[c].url)||(pointers[chosen]==anc->urls[c].title)) {
					if (anc->urls[c].url[0]!='#') { /* check for fragment name in this url */
				/*	if (strchr( anc->urls[c].url, '#')==NULL) { /* check for fragment IN SAME document */
						activate_selected_browser_link( cs, anc, c );
						if (strchr( anc->urls[c].url, '#' )!=NULL) {	/* detect '#' in old url link */
							handle_redraw_event();		/* wait for anchor building in new HTMLINFO */
							if ((cs = html_global( wx, NULL))==NULL) { return; }
							find_html_fragment( cs, anc, c );	/* find in new HTMLINFO block */
						}
					} else {
						find_html_fragment( cs, anc, c );
					}
				}
			}
			anc=anc->next;
		}
	}
}

void browser_fields(void)
{
	browser_links( 12 );
}

/* clickable links for "generic" windows */

void select_generic( int wx, int x, int y, int clicks )
{
	HTMLINFO *cs;
	HTMLANCHOR *anc;
	int c,ty;
	int dummy,alt;
	GRECT r;

	if ((cs=html_global(wx, NULL))==NULL) { return; }

	ty=y+(windows[wx].line_no*cellh);	/* zero-based for scrolling */
	graf_mkstate(&dummy,&dummy,&dummy,&alt);
	if (alt&8) { fprintf( log, "click at: %d, %d\n", x, ty ); }

	if ((anc=cs->anchors)==NULL) { browser_links( wx ); return; }

	while (anc!=NULL) {
		for (c=0;c<20;c++) {
			r=anc->urls[c].r;
			if (alt&8) { fprintf( log, "rect= %d, %d, %d, %d\n", r.g_x, r.g_y, r.g_w, r.g_h ); }
			if (r.g_w==0) { browser_links( wx ); return; }
			if (rc_inside( x, ty, &r )) {
				if (alt&8) { fprintf( log, "Found: %s\n", anc->urls[c].url ); }
			/*	activate_selected_browser_link( cs, anc, c ); */
				if (anc->urls[c].url[0]!='#') { /* check for fragment name in this url */
					activate_selected_browser_link( cs, anc, c );
					if (strchr( anc->urls[c].url, '#' )!=NULL) {	/* detect '#' in old url link */
						handle_redraw_event();		/* wait for anchor building in new HTMLINFO */
						if ((cs = html_global( wx, NULL))==NULL) { return; }
						find_html_fragment( cs, anc, c );	/* find in new HTMLINFO block */
					}
				} else {
					find_html_fragment( cs, anc, c );
				}
			return;
			}
		}
		anc=anc->next;
	}
	browser_links( wx );
}

void handle_generic_close( int wx )
{
	HTMLINFO *cs=NULL;

	cs = html_global(wx, NULL);
	while (cs!=NULL) {
		cs = release_htmlinfo( cs );
		cs = html_global(-1*wx, cs);
	}
}

void generic_mark_url( int wx, int x, int y, char *line )
{
	HTMLINFO *cs=NULL;
	int w,t,voffset;
	int zx,zy,zw,zh;
	char buff[200],*where,ch;

	if (stcpm( line, "http://", &where )) {
		sprintf( buff, "href=%.190s", where);
		buff[199]='\0';
	/*	strcpy( buff, where ); */
	/*	strtok( buff, " \n" ); */
		strtok( buff, " \n\"\'>)" );	/* space, newline, quotes, greater, paren */
		if (strlen(buff)==12) { return; }	/* ignore just "href=http://" */
		if (buff[(w=(int)strlen(buff)-1)]=='.') buff[w]='\0';	/* remove trailing period */
		vst_effects( handle, UNDERLINED );
		vst_color( handle, BLUE );

/*		t=(int)(where-line)*cellw; */
		ch=*where;	/* save character */
		*where=0;	/* terminate line here */
		t=text_extent( line );
		*where=ch;	/* restore character */

		v_gtext( handle, x+t, y+cellh, buff+5 );
		vst_effects( handle, 0 );	
		vst_color( handle, BLACK );

		if ((cs=html_global(wx, NULL))==NULL) { cs=new_htmlcs(wx); }
		if (cs) {
		/*	if (strchr( buff+12, '/')==NULL) { strcat( buff, "/" ); } */
		/*	w=(int)strlen(buff+5)*cellw; */
			w=text_extent( buff+5 );
			if ((where=strrchr( buff+12, '/'))!=NULL) {
				if ((strchr( where, '.')==NULL)&&(*(where+1)!='\0')) { strcat( buff, "/" ); }
			} else { strcat( buff, "/" ); }
			voffset=(windows[wx].line_no*cellh);	/* offset for anchors */
			wind_get( windows[wx].id, WF_WORKXYWH, &zx, &zy, &zw, &zh );
			setup_toolbar(wx, &zx, &zy, &zw, &zh );	/* adjust for toolbar at top */
			cs->last_anchor=buff;
			insert_html_anchor( cs, x+t-zx, y+voffset-zy, w, cellh, "" );
		}
	}
} 

void do_URL_BubbleGEM( int wx, int x, int y )
{
	GRECT r;

	if (prefs.show_bubble_help!='Y') { return; }
	wind_get( windows[wx].id, WF_WORKXYWH, &r.g_x, &r.g_y, &r.g_w, &r.g_h );
	do_BubbleGEM( x+r.g_x, y+r.g_y, ErrMsg(EM_RetrURLHelp) );	/* "Click to Retrieve and Open the document" */
}

void handle_mouse_tracking( int wx, int x, int y )
{
	HTMLINFO *cs;
	HTMLANCHOR *anc;
	int c,ty;
	static int count=0,mouse=ARROW;
	GRECT r;
/*	int dummy,alt; */

	if ((cs=html_global(wx, NULL))!=NULL) {
		ty=y+(windows[wx].line_no*cellh)-toolbar_height(windows[wx].id);	/* zero-based for scrolling */
		anc=cs->anchors;
		while (anc!=NULL) {
			for (c=0;c<20;c++) {
				r=anc->urls[c].r;
			/*	if (alt&8) { fprintf( log, "rect= %d, %d, %d, %d\n", r.g_x, r.g_y, r.g_w, r.g_h ); } */
				if (r.g_w==0) { 	/* last, entry, not found */
					if (mouse!=ARROW) {
						graf_mouse( ARROW, NULL );		/* change mouse pointer to arrow */
						if (windows[wx].info[0]!='\0') {	/* clear info line */
							memset(windows[wx].info, 0, 80);
							wind_info( windows[wx].id, windows[wx].info );
						}
						mouse=ARROW;
					}
					return;
				}
				if (r.g_h==0) { continue; }	/* ignore fragments */
				if (rc_inside( x, ty, &r )) {
				/*	if (alt&8) { fprintf( log, "Found: %s\n", anc->urls[c].url ); } */
					if (mouse!=POINT_HAND) {
	 					graf_mouse( POINT_HAND, NULL );	/* change mouse pointer to finger */
						mouse=POINT_HAND;
						count=0;
					} else {	/* must be already pointing */
						count++;
						if (count==3) { do_URL_BubbleGEM( wx, x, y ); }
					}
					if (windows[wx].components&INFO) {	/* put url in window info */
						if (strncmp( windows[wx].info+2, anc->urls[c].url, 77 )!=0) {
							strncpy( windows[wx].info+2, anc->urls[c].url, 77 );
							windows[wx].info[79]='\0';
							windows[wx].info[0]='\x03';	/* => arrow */
							windows[wx].info[1]=' ';
							wind_info( windows[wx].id, windows[wx].info );
						}
					}
					return;
				}
			}
			anc=anc->next;
		}
	}
}

/* end browser.c */
	