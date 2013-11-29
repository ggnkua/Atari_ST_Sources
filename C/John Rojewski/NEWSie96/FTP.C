/*
 * ftp.c
 * Written by: John Rojewski	01/11/97
 *
 * see RFC 959 for details
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

#include "global.h"

#define VERSION "0.96  Dec  3, 1999"
#define ErrMsg(a) (char *)em[a].ob_spec
#define FTP_CONTROL_PORT 21

char *strtoka( char *s, int tok );		/* prototype from mailer.c */
void set_menu( int which, int func );	/* prototype from newsaes.c */
int info_line( int wx, char *info );			/* prototype from newsaes.c */

void CAB_internet_ftp_client( char *parameter )
{
	FILE *fid;
	char *user,*pswd,*server,*dir,*port;
	char userid[80],password[80],directory[FMSIZE];
	char parm[300];

/*	ftp://ftpserver:port/directory */
/*	ftp://username:password@ftpserver:port/directory */
	strcpy( parm, parameter );
	directory[0]='\0';

	sprintf( ftp_server_path, "%s\\%s", prefs.work_path, "temp.svr" );
	fid = fopen( ftp_server_path, "wa" );
	if (fid!=NULL) {
		if (strchr( parm, '@')!=NULL) {	/* non-anonymous */
			user   = strtoka( parm+6, ':' );	/* skip "ftp://" */
			pswd   = strtoka( NULL, '@' );
			server = strtoka( NULL, '/' );
			dir    = strtoka( NULL, '\0' );
			strcpy( userid, user );
			strcpy( password, pswd );
		} else {						/* anonymous */
			server = strtoka( parm+6, '/' );
			dir    = strtoka( NULL, '\0' );
			strcpy( userid, "anonymous" );
			strcpy( password, prefs.email_address );
		}
		strtoka( server, ':' );
		port   = strtoka( NULL, ':' );	/* get possible port */

		if (dir[0]!='\0')  { sprintf( directory, "/%s", dir ); }
	/*	fprintf( log, "dir=%s\ndirectory=%s\n", dir, directory ); */
		fprintf( fid, "%s\t%s\t%s\t%s\t%s\n", server, userid, password, directory, port );
		fclose( fid );
		prefs.connect_startup='N';		/* no news required */
		prefs.subscribe_startup='N';	/* don't open newsgroup window */
		try_ftp();
	}
}

void try_ftp(void)
{
	if (windows[11].id<0) {
		if (ftp_server_path[0]=='\0') {
			sprintf( ftp_server_path, "%s\\%s", program_path, "default.svr" ); }
		load_servers( ftp_server_path );
		if (current_server<0) { return; }
		strcpy( current_directory, server[current_server].directory );
		windows[11].bar_index = Tool_Server;
		windows[11].bar_object = NULL;
		new_window( 11, ErrMsg(EM_FTPServers), 100, 50, 400, 300 );
		set_menu( 1, 1 );	/* enable FTP server items */
		set_menu( 2, 0 );	/* disable FTP directory items */
	} else { key_ftp( '\r' ); }
}

void open_server(void)
{
	int rc;
	char path[FMSIZE],user[80],pswd[80],p;
	int port=FTP_CONTROL_PORT;

	if (STiK<=0) { no_stik(); return; }

	use_status( 11 );	/* use infoline in window */
	show_status( ErrMsg(EM_OpenFTP) ); /* "Opening FTP Session" */
 	if (server[current_server].port[0]!='\0') {
		port = atoi(server[current_server].port);
	}
 	rc = ftp_connect( server[current_server].name, port );
	fflush( log );
	if (fpi>=0) {
		strcpy( user, server[current_server].user );
		if (user[0]=='\0') {	/* support missing userid */
			strcpy( user, "anonymous" );
		}
		rc = ftp_user( user );

		if (memcmp(header,"331",3)==0) {	/* request password? */
			strcpy( pswd, server[current_server].password );
			if (pswd[0]=='\0') {	/* support missing password */
				if (strcmp(user,"anonymous")==0) {
					strcpy( pswd, prefs.email_address );
				} else {
					p=prefs.use_saved_password;		/* keep flag */
					prefs.use_saved_password='N';
					get_password_dialog( pswd );
					prefs.use_saved_password=p;		/* restore flag */
				}
			}
			rc = ftp_pass( pswd );
		}
		fflush( log );

		if (memcmp(header,"230",3)==0) {
			if (prefs.ftp_send_help=='Y') {
				sprintf( path, "%s\\%s", program_path, "ftphelp.txt" );
				rc = ftp_help( path );	fflush( log ); }
			if ( server[current_server].directory[0]!='\0') {
				rc = ftp_cwd( server[current_server].directory );
				fflush( log );
				if (memcmp(header,"550",3)==0) {	/*no such directory*/
					info_line( 11, header+4 );
					rc = ftp_pwd( server[current_server].directory );
				}
				fflush( log );
			} else {
				rc = ftp_pwd( server[current_server].directory );
			}
			strcpy( current_directory, server[current_server].directory );
			rc = get_cache( path );
			fflush( log );
		/*	open_directory( current_directory, path ); */
			load_directory( path );
			windows[11].bar_index = Tool_Directory;
			windows[11].bar_object = NULL;
			new_window( 11, current_directory, 100, 50, 400, 300 );
			set_menu( 1, 0 );	/* disable FTP server items */
			set_menu( 2, 1 );	/* enable FTP directory items */
		} else {
			status_text( ErrMsg(EM_NoServerAcc) );
			evnt_timer( 1000, 0 );		/* wait 1 second */
			close_ftp_connection();		/* may not be needed */
		}
	} else {
		status_text( ErrMsg(EM_NoConnect) );
		evnt_timer( 1000, 0 );		/* wait 1 second */
	}
	hide_status();
}

void close_server(void)
{
	if (current_server>=0) {
		strcpy( server[current_server].directory, current_directory );
	}
	if (ftp_server_path[0]=='\0') {
		sprintf( ftp_server_path, "%s\\%s", program_path, "default.svr" ); }
  	unload_servers( ftp_server_path );
	empty_cache();
}

void close_ftp_connection(void)
{
	int x;

	if (fpi>=0) {
		use_status( 11 );	/* use infoline in window */
		show_status( ErrMsg(EM_CloseConnect) );
		x = ftp_quit();
		fflush( log );
		hide_status();
	}
}

int ftp_close_window(void)
{
	int rc;

	rc = (fpi>=0);
	if (rc) {
		close_ftp_connection();
		close_server();
		strcpy( windows[11].title, ErrMsg(EM_FTPServers) ); /* "FTP Servers" */
		wind_title( windows[11].id, windows[11].title );
		windows[11].num_lines=maximum_server;
		windows[11].line_no=0;
		windows[11].bar_index = Tool_Server;
		windows[11].bar_object = NULL;
		wind_set( windows[11].id, WF_VSLSIZE, 1000, 0, 0, 0 );
		wind_set( windows[11].id, WF_VSLIDE, 1, 0, 0, 0 );
		set_menu( 1, 1 );	/* enable FTP server items */
		set_menu( 2, 0 );	/* disable FTP directory items */
	} else {
		set_menu( 1, -1 );	/* enable SelectServer, disable rest */
		ftp_server_path[0]='\0';	/* reset server file */
	}
	return(rc);
}

void get_load_refresh(void)
{
	int rc;
	char path[FMSIZE];

	rc = get_cache( path );	/* returns path */
	load_directory( path );
	wind_title( windows[11].id, current_directory );
	rc	= wind_set( windows[11].id, WF_VSLSIZE, 1000, 0, 0, 0 );
	rc  = wind_set( windows[11].id, WF_VSLIDE, 1, 0, 0, 0 );
	refresh_clear_window( windows[11].id );
}

void format_directory_line(int c, char *buff)
{
	sprintf( buff, "%s %-20.20s %7ld %-6.6s %s",
			filelist[c].status,
			filelist[c].filename, filelist[c].size,
			filelist[c].date, filelist[c].time );
}

void format_server_line(int c, char *buff)
{
	sprintf( buff, "%-30.30s %-15.15s %s",
			server[c].name, server[c].user,	server[c].directory );
}

void ftp_viewer_text( int wid, char *filename )
{
	generic_window_text( wid, filename );
}

void key_ftp_viewer(int keycode)
{
	arrow_scrolling_keys( windows[10].id, keycode );
}

void ftp_text(int wid)
{
	if (fpi>=0) { directory_text( wid ); } else { server_text( wid ); }
}

void server_text(int wid)
{
	GRECT work;
	int x,y,c,lpp,start,end,refresh=1;
	char buff[200];
	OBJECT *bar;

	x = wind_get( wid, WF_WORKXYWH, &work.g_x, &work.g_y, &work.g_w, &work.g_h);
	setup_toolbar(11, &work.g_x, &work.g_y, &work.g_w, &work.g_h );
	lpp = setup_text( wid, 11, prefs.overview_font, prefs.overview_font_size,
				work.g_h, maximum_server+1 ); 
	x=work.g_x;
	y=work.g_y;
	if (windows[11].clear) {
		clear_rect( &work);
		refresh=0;
		if ((bar=windows[11].bar_object)!=NULL) {
			objc_draw( bar, ROOT, 1, clip.g_x, clip.g_y, clip.g_w, clip.g_h );
		}
	}

	start = windows[11].line_no;
	end   = start + lpp;
	if (end>SERVER_SIZE) { end=SERVER_SIZE; }
	for (c=start;c<end;c++) {
		if (c>=0) {
			if ( server[c].name[0]!='\0') {
				y+=cellh;
				if (refresh) {
					if (c==current_server) {
						format_server_line( c, buff );
						set_selected_text( 1 );
						v_gtext( handle, x, y, buff );
						set_selected_text( 0 );
					} 
					if (c==previous_file) {
						format_server_line( c, buff );
						v_gtext( handle, x, y, buff );
					}
				} else {
					format_server_line( c, buff );
					if (c==current_server) { set_selected_text( 1 ); }
					v_gtext( handle, x, y, buff );
					set_selected_text( 0 );
				}
			}
		}
	} 
}

void directory_text(int wid)
{
	GRECT work;
	int x,y,c,lpp,start,end,refresh=1;
	char buff[200];
	OBJECT *bar;

	x = wind_get( wid, WF_WORKXYWH, &work.g_x, &work.g_y, &work.g_w, &work.g_h);
	setup_toolbar(11, &work.g_x, &work.g_y, &work.g_w, &work.g_h );
	lpp = setup_text( wid, 11, prefs.overview_font, prefs.overview_font_size,
				work.g_h, maximum_file+1 ); 
	x=work.g_x;
	y=work.g_y;
	if (windows[11].clear) {
		clear_rect( &work);
		refresh=0;
	 	if ((bar=windows[11].bar_object)!=NULL) {
			objc_draw( bar, ROOT, 1, clip.g_x, clip.g_y, clip.g_w, clip.g_h );
		}
	}

	start = windows[11].line_no;
	end   = start + lpp;
	if (end>FTP_FILELIST_SIZE) { end=FTP_FILELIST_SIZE; }
	for (c=start;c<end;c++) {
		if (c>=0) {
			if ( filelist[c].status[0]!='\0') {
				y+=cellh;
				if (refresh) {
					if (c==current_file) {
						format_directory_line( c, buff );
						set_selected_text( 1 );
						v_gtext( handle, x, y, buff );
						set_selected_text( 0 );
					} 
					if (c==previous_file) {
						format_directory_line( c, buff );
						if (filelist[c].status[0]=='d') { vst_color( handle, BLUE ); }
						v_gtext( handle, x, y, buff );
						set_selected_text( 0 );
					}
				} else {
					format_directory_line( c, buff );
					if (filelist[c].status[0]=='d') { vst_color( handle, BLUE ); }
					if (c==current_file) { set_selected_text( 1 ); }
					v_gtext( handle, x, y, buff );
					set_selected_text( 0 );
				}
			}
		}
	} 
}

void select_ftp(int vert, int clicks)
{
	if (fpi<0) {
		select_server( vert, clicks );
	} else {
		select_file( vert, clicks );
	}
}

void select_server(int vert, int clicks)
{
	int rc,index,refresh;

	rc = atoi( prefs.overview_font_size );
	vst_point( handle, rc, &charw, &charh, &cellw, &cellh );
	index = (vert / cellh ) + windows[11].line_no;
	if (index<SERVER_SIZE) {
		if (server[index].name[0]!='\0') {
			refresh = (current_server!=index);
			previous_file = current_server;
			current_server = index;
			if (clicks>1) {
				open_server();
			} else {
				strcpy( current_directory, server[current_server].directory );
				if (refresh) { refresh_window( windows[11].id ); }
			}
		}
	}
}

void select_file(int vert, int clicks)
{
	int rc,c,refresh;
	char path[FMSIZE],type;

	rc = atoi( prefs.overview_font_size );
	vst_point( handle, rc, &charw, &charh, &cellw, &cellh );
	c = (vert / cellh ) + windows[11].line_no;		/* calculate index */
	if (c<FTP_FILELIST_SIZE) {
		if (filelist[c].status[0]!='\0') {
			refresh = (current_file!=c);
			previous_file = current_file;
			current_file = c;
			if (clicks>1) {
				type = filelist[c].status[0];
				if (type=='l') {
					rc = ftp_cwd( filelist[c].filename );
					if (memcmp(header,"250",3)==0) {
						rc = ftp_pwd( current_directory );
						get_load_refresh();
					} else { type='-'; }	/* try to retrieve file link */
				}
				if (type=='-') {
					sprintf( path, "%s\\%s", prefs.ftp_download_path, filelist[c].filename );
					use_status( 11 );	/* use infoline in window */
					show_status( ErrMsg(EM_RetrieveFile) );	/* "Retrieving File" */
					rc = ftp_retrieve( filelist[c].filename, path );
					hide_status();
				}
				if (type=='d') {
					change_directory(c);
				}
			} else {
				if (refresh) { refresh_window( windows[11].id ); }
			}
		}
	}
}

void key_ftp(int keycode)
{
	if (fpi<0) { key_servers( keycode ); } else { key_directory(keycode); }
}

void key_servers(int keycode)
{
	int c;

	if (arrow_page_scrolling_keys( windows[11].id, keycode )) { return; }

	if ((keycode>>8)=='\x48') {	/* up arrow */
		if (current_server>0) {
			previous_file = current_server;
			current_server--;
			strcpy( current_directory, server[current_server].directory );
			if (current_server<windows[11].line_no) {
				handle_arrows( windows[11].id, WA_UPPAGE );
			} else {
				refresh_window( windows[11].id );
			}
		}
	}
	if ((keycode>>8)=='\x50') {	/* down arrow */
		if (current_server<maximum_server) {
			previous_file = current_server;
			current_server++;
			strcpy( current_directory, server[current_server].directory );
			if (current_server>=windows[11].line_no+windows[11].lines_per_page) {
				handle_arrows( windows[11].id, WA_DNPAGE );
			} else {
				refresh_window( windows[11].id );
			}
		}	
	}
	if ((char)keycode=='\r') {	/* return = open the server */
		if (current_server>=0) { open_server();	}
	}
	if ((keycode>>8)=='\x53') {	/* delete current_server */
		if (current_server>=0) {
			if (current_server<maximum_server) {
				for (c=current_server;c<maximum_server;c++) {
					memcpy( &server[c], &server[c+1], sizeof(server[0]) );
				}		
			}
			server[maximum_server--].name[0]='\0';	/* reduce maximum_server by 1 */
			if (current_server>maximum_server) { current_server = -1; }
			close_server();
			refresh_clear_window( windows[11].id );
		}
	}
	if ((keycode>>8)=='\x52') {	/* Insert - add a new server */
		if ((maximum_server+1)>=SERVER_SIZE) { expand_servers(); }
		if ((maximum_server+1)<SERVER_SIZE) {
			if (edit_server(maximum_server+1)) {
				maximum_server++;
				current_server=maximum_server;
				close_server();
				refresh_clear_window( windows[11].id );
			}
		}
	}
	if ((char)keycode=='?') {	/* ? - edit a server */
		if (current_server>=0) {
			if (edit_server(current_server)) {
				close_server();
				refresh_clear_window( windows[11].id );
			}
		}
	}
}

int edit_server(int x)
{
	OBJECT *dlog;
	int result;

	if (current_server>=0) {
		rsrc_gaddr(R_TREE,FTP_Edit_Server,&dlog);
		set_tedinfo( dlog, DFS_Server, server[x].name );
		set_tedinfo( dlog, DFS_Logon, server[x].user );
		set_tedinfo( dlog, DFS_Password, server[x].password );
		set_tedinfo( dlog, DFS_Directory, server[x].directory );
		set_tedinfo( dlog, DFS_Port, server[x].port );
		set_crossed( dlog, DFS_SaveDir, prefs.ftp_save_last_dir=='Y' );	
		result=handle_dialog(dlog, DFS_Server);
		if (result==DFS_ServerOK) {
			get_tedinfo( dlog, DFS_Server, server[x].name );
			get_tedinfo( dlog, DFS_Logon, server[x].user );
			get_tedinfo( dlog, DFS_Password, server[x].password );
			get_tedinfo( dlog, DFS_Directory, server[x].directory );
			get_tedinfo( dlog, DFS_Port, server[x].port );
			get_crossed( dlog, DFS_SaveDir, &prefs.ftp_save_last_dir );	
			strcpy( current_directory, server[x].directory );
		}
		return (result==DFS_ServerOK);
	}
	return(0);
}

void change_directory(int c)
{
	int rc;
	char path[FMSIZE],temp[FMSIZE],*p;

	if (current_directory[0]=='/') {
		if (strcmp(current_directory,"/")==0) {
			sprintf( path, "/%s", filelist[c].filename );
		} else {
			sprintf( path, "%s/%s", current_directory, filelist[c].filename );
		}
		if (strcmp(filelist[c].filename,".")==0) {	/* root */
			sprintf( path, "/" );
		}
		if (strcmp(filelist[c].filename,"..")==0) {	/* back up */
			strcpy( path, current_directory );
			if ((p = strrchr( path, '/' ))!=NULL) { *p='\0'; }
			if (path[0]=='\0') { sprintf( path, "/" ); }
		}
		rc = ftp_cwd( path );
		if (memcmp(header,"250",3)==0) {
			strcpy( current_directory, path );
			get_load_refresh();
		}
		if (memcmp(header,"550",3)==0) { info_line( 11, header+4 ); }
	} else if ((p = strchr( current_directory, ']' ))!=NULL) {	/* VAX/VMS */
		*p='\0';
		strcpy( temp, filelist[c].filename );
		strtok( temp, "." );
		sprintf( path, "%s.%s]", current_directory, temp );
		fprintf( log, "Prev: %s, was: %s\n", path, current_directory ); fflush( log );
		rc = ftp_cwd( path );
		if (memcmp(header,"250",3)==0) {
			strcpy( current_directory, path );
			get_load_refresh();
		}
		if (memcmp(header,"550",3)==0) { info_line( 11, header+4 ); }
	}
}

void key_directory(int keycode)
{
	int rc,c,ctl;
	char select[FMSIZE],dirname[FMSIZE],path[FMSIZE],type;
	static char store_path[FMSIZE]="";
	int button;

	if (arrow_page_scrolling_keys( windows[11].id, keycode )) { return; }

	if (store_path[0]=='\0') { strcpy( store_path, prefs.work_path ); }

	if ((keycode>>8)=='\x48') {	/* up arrow */
		if (current_file>0) {
			previous_file = current_file;
			current_file--;
			if (current_file<windows[11].line_no) {
				handle_arrows( windows[11].id, WA_UPPAGE );
			} else {
				refresh_window( windows[11].id );
			}
		}
		return;
	}
	if ((keycode>>8)=='\x50') {	/* down arrow */
		if (current_file<maximum_file) {
			previous_file = current_file;
			current_file++;
			if (current_file>=windows[11].line_no+windows[11].lines_per_page) {
				handle_arrows( windows[11].id, WA_DNPAGE );
			} else {
				refresh_window( windows[11].id );
			}
		}
		return;	
	}
	if ((char)keycode=='\r') {	/* return = get the file/directory */
		if (current_file>=0) {
			c = current_file;
			type = filelist[c].status[0];
			if (type=='l') {
				rc = ftp_cwd( filelist[c].filename );
				if (memcmp(header,"250",3)==0) {
					rc = ftp_pwd( current_directory );
					get_load_refresh();
				} else { type='-'; }	/* try to retrieve file link */
			}
			if (type=='-') {
				sprintf( path, "%s\\%s", prefs.ftp_download_path, filelist[c].filename );
				use_status( 11 );	/* use infoline in window */
				show_status( ErrMsg(EM_RetrieveFile) ); 	/* "Retrieving File" */
				rc = ftp_retrieve( filelist[c].filename, path );
				hide_status();
			}
			if (type=='d') {
				change_directory(c);
			}
		}
		return;
	}
	if ((char)keycode=='v') {	/* view file */
		if (current_file>=0) {
			c = current_file;
			type = filelist[c].status[0];
			if ((type=='-')||(type=='l')) {
				sprintf( ftp_viewer_path, "%s\\%s", prefs.ftp_download_path, filelist[c].filename );
				use_status( 11 );	/* use infoline in window */
				show_status( ErrMsg(EM_RetrieveFile) ); 	/* "Retrieving File" */
				rc = ftp_retrieve( filelist[c].filename, ftp_viewer_path );
				hide_status();
				windows[10].line_no=0;
				windows[10].num_lines = (int16)count_lines( ftp_viewer_path );
				new_window( 10, filelist[c].filename, 100, 100, 400, 300 );
			}
		}
		return;
	}
	if ((keycode>>8)=='\x0e') {	/* backspace to previous directory */
		previous_directory();
		return;
	}
	if (keycode==0x5200) {	/* insert - store a file on server */
		graf_mkstate(&rc,&rc,&rc,&ctl);	/* ctl key means multiple, i.e. loop */
		c=0;	/* times through, number files stored */
		use_status( 11 );	/* use infoline in window */
		do {
			sprintf( dirname, "%s\\*.*", store_path );
	 		*select = '\0';
	 		fsel_exinput( dirname, select, &button, ErrMsg(EM_StoreFile) );	/* Storing File */
	 		if (button) {
				stcgfp( store_path, dirname );
				sprintf( dirname, "%s\\%s", store_path, select );
			} else { break; }
			if (prefs.ftp_savelower!='N') {	strlwr( select ); }	/* lowercase on server */
			show_status( ErrMsg( EM_StoreFile ) );	/* "Storing File" */
			rc = ftp_store( dirname, select );
			c++;	/* increment counter */
		} while (ctl&K_CTRL);
		if (c) { refresh_directory(); }
		hide_status();
		return;
	}
	if (keycode==0x5230) {	/* shift insert - store file w/newname */
		store_with_name( store_path );
		return;
	}
	if ((char)keycode=='a') {	/* ascii transfer */
		use_status( 11 );	/* use infoline in window */
		show_warning( ErrMsg(EM_FTPAscii) ); /* "Set for ASCII Transfer" */
		rc = ftp_type( "A" );
		hide_status();
		return;
	}
	if ((char)keycode=='b') {	/* binary transfer */
		use_status( 11 );	/* use infoline in window */
		show_warning( ErrMsg(EM_FTPBinary) ); /* "Set for Binary Transfer" */
		rc = ftp_type( "I" );
		hide_status();
		return;
	}
	if ((char)keycode=='r') {	/* rename file */
		if (current_file>=0) {
			if (filelist[current_file].status[0]=='-') { ftp_rename_file(); }
		}
		return;
	}
	if ((char)keycode=='m') {	/* make directory */
		ftp_make_directory();
		return;
	}
	if ((keycode>>8)=='\x53') {	/* delete the file */
		if (current_file>=0) {
			c = current_file;
			if (filelist[c].status[0]=='-') {
				use_status( 11 );	/* use infoline in window */
	 			show_status( ErrMsg(EM_DeleteFile) );	/* "Deleting File" */
				rc = ftp_delete( filelist[current_file].filename );
				refresh_directory();
				hide_status();
			}
			if (filelist[c].status[0]=='d') {
				use_status( 11 );	/* use infoline in window */
	 			show_status( ErrMsg(EM_DeleteDir) );	/* "Deleting Directory" */
				rc = ftp_rmd( filelist[current_file].filename );
				refresh_directory();
				hide_status();
			}
		}
	}
}

void previous_directory(void)
{
	int rc;
	char path[FMSIZE],*p;

	if (strcmp(current_directory,"/")>0) {
		strcpy( path, current_directory );
		if ((p = strrchr( path, '/' ))!=NULL) {	/* UNIX */
			*p='\0';
			if (path[0]=='\0') { sprintf( path, "/" ); }
			fprintf( log, "Prev: %s, was: %s\n", path, current_directory ); fflush( log );
			rc = ftp_cwd( path );
			if (memcmp(header,"250",3)==0) {
				strcpy( current_directory, path );
				get_load_refresh();
			}
			if (memcmp(header,"550",3)==0) { info_line( 11, header+4 ); }
		} else if ((p = strrchr( path, '.' ))!=NULL) {	/* VAX/VMS */
			*p='\0';
			strcat( path, "]" );
			fprintf( log, "Prev: %s, was: %s\n", path, current_directory ); fflush( log );
			rc = ftp_cwd( path );
			if (memcmp(header,"250",3)==0) {
				strcpy( current_directory, path );
				get_load_refresh();
			}
			if (memcmp(header,"550",3)==0) { info_line( 11, header+4 ); }
		}
	}
}

void handle_FTP_menu( int item )
{
/*	char select[FNSIZE],dirname[FMSIZE],path[FMSIZE]; */

	if (fpi<0) {
		if (item==MT_SelectServer) { try_ftp(); }
		if (windows[11].id>0) {
			switch (item)
			{
			/*	case MT_SelectServer:	key_ftp( '\r' );	break; */
				case MT_AddServer:		key_ftp( 0x5200 );	break;
				case MT_EditServer:		key_ftp( '?' );		break;
				case MT_DeleteServer:	key_ftp( 0x5300 );	break;
			}
		}
	} else {
		switch (item)
		{
			case MT_MakeDir:		key_ftp( 'm' );		break;
			case MT_ChangeDir:
				if (filelist[current_file].status[0]=='d') { key_ftp( '\r' ); }
				break;
			case MT_DeleteDir:
				if (filelist[current_file].status[0]=='d') { key_ftp( 0x5300 );	}
				break;
			case MT_GetFile:
				if (filelist[current_file].status[0]=='-') { key_ftp( '\r' ); }
				break;
			case MT_PutFile:		key_ftp( 0x5200 );	break;
			case MT_PutFileName:	key_ftp( 0x5230 );	break;	/* shift-Ins */
			case MT_RenameFile:
				if (filelist[current_file].status[0]=='-') { key_ftp( 'r' ); }
				break;
			case MT_DeleteFile:
				if (filelist[current_file].status[0]=='-') { key_ftp( 0x5300 );	}
				break;
		}
	}		
} 

void ftp_rename_file(void)
{
	char newname[40],oldname[40];
	OBJECT *dlog;
	int rc,result;
	
	rsrc_gaddr(R_TREE,FTP_SaveRename,&dlog);
	strcpy( oldname, filelist[current_file].filename );
	set_tedinfo( dlog, DFS_SaveOldName, oldname );
	set_tedinfo( dlog, DFS_SaveAsRename, oldname );
	result=handle_dialog(dlog, DFS_SaveAsRename);
	if (result==DFS_SaveAsOK) {
		get_tedinfo( dlog, DFS_SaveAsRename, newname );
		if ((newname[0]!='\0')&&(strcpy(oldname,newname)!=0)) {
			use_status( 11 );	/* use infoline in window */
			show_status( ErrMsg(EM_RenameFile) ); 	/* "Renaming File" */
			rc = ftp_rename( filelist[current_file].filename, newname );
			refresh_directory();
			hide_status();
		}
	}
}

void store_with_name(char *store_path)
{
	OBJECT *dlog;
	int rc,result;
	char select[FMSIZE],dirname[FMSIZE];
/*	char ext[8]; */
	int button,ctl,c=0;
	struct FILEINFO info;

	graf_mkstate(&rc,&rc,&rc,&ctl);	/* ctl key means multiple, i.e. loop */
	use_status( 11 );	/* use infoline in window */
	do {
	/*	stcgfe( ext, store_path );	/* get any extension, w/o path */
	/*	if (ext[0]=='\0') {	/* extension not here, assume path */
		if (dfind( &info, store_path, 0 )) {	/* if this is a path, not a file */
			sprintf( dirname, "%s\\*.*", store_path );
			*select = '\0';
			fsel_exinput( dirname, select, &button, ErrMsg(EM_StoreFile) );	/* Storing File */
			if (button) {
				stcgfp( store_path, dirname );
				sprintf( dirname, "%s\\%s", store_path, select );
			} else { break; }	/* exit loop */
		} else {
			stcgfn( select, store_path );	/* get any filename, w/o path */
			strcpy( dirname, store_path );	/* is entire filename */
			ctl=0;	/* disable possible multiple, this is a single file */
		}
	
		rsrc_gaddr(R_TREE,FTP_SaveRename,&dlog);
		set_tedinfo( dlog, DFS_SaveOldName, select );
		if (prefs.ftp_savelower!='N') { strlwr( select ); }	/* lowercase on server */
		set_tedinfo( dlog, DFS_SaveAsRename, select );
		result=handle_dialog(dlog, DFS_SaveAsRename);
		if (result==DFS_SaveAsOK) {
			get_tedinfo( dlog, DFS_SaveAsRename, select );
			if (select[0]!='\0') {
				show_status( ErrMsg( EM_StoreFile ) );	/* "Storing File" */
				rc = ftp_store( dirname, select );
				c++;	/* increment counter */
			}
		} else { break; }	/* exit loop */
	} while (ctl&K_CTRL);
	if (c) { refresh_directory(); }
	hide_status();
}

void ftp_make_directory(void)
{
	char newname[40],oldname[40]="directory";
	OBJECT *dlog;
	int rc,result;
	
	rsrc_gaddr(R_TREE,FTP_SaveRename,&dlog);
	set_tedinfo( dlog, DFS_SaveOldName, oldname );
	set_tedinfo( dlog, DFS_SaveAsRename, oldname );
	result=handle_dialog(dlog, DFS_SaveAsRename);
	if (result==DFS_SaveAsOK) {
		get_tedinfo( dlog, DFS_SaveAsRename, newname );
		if (newname[0]!='\0') {
			use_status( 11 );	/* use infoline in window */
			show_status( ErrMsg(EM_CreateDir) ); 	/* "Creating Directory..." */
			rc = ftp_mkd( newname );
			refresh_directory();
			hide_status();
		}
	}
}


void refresh_directory(void)
{
	int rc;
	char path[FMSIZE];

	rc = get_cache( path );			/* returns path and cache index */
	remove( ftp_cache[rc].filename ); /* delete file */
	ftp_cache[rc].filename[0]='\0';	/* force reload of directory */
	get_load_refresh();
}

void expand_directory(void)
{
	int new_size,x;
	size_t new_bytes;
	void *new_dir;
	char temp[80];

	new_size  = 2 * FTP_FILELIST_SIZE;
	new_bytes = new_size * sizeof( struct flist );
	new_dir   = realloc( filelist, new_bytes );
	if (!new_dir) {
		sprintf( temp,"[1][Insufficient Memory for %s][ OK ]", "|FTP Directory" );
		form_alert( 1, temp );
		return;				/* failed */
	}
	filelist = new_dir;
	for (x=FTP_FILELIST_SIZE;x<new_size;x++) {	/* clear new entries */
	/*	filelist[x].status[0] = '\0'; */
		memset( &filelist[x], 0, sizeof( struct flist ) );
	}
	FTP_FILELIST_SIZE = new_size;
	fprintf( log, "FTP Directory expanded to %d entries\n", new_size );
}

void load_directory(char *path)
{
	char buff[200],day[3];
	register int x,c;
	FILE *fid;
	char vsize[20],vstatus[30],vdate[20],*p;

	graf_mouse( BUSY_BEE, NULL );
	current_file=-1;
    maximum_file=-1;
	for (x=0;x<FTP_FILELIST_SIZE;x++) {	/* initialize structure */
	/*	memset( &filelist[x], 0, sizeof( struct flist ) ); */
		filelist[x].status[0] = '\0';
		filelist[x].date[0] = '\0';
		filelist[x].time[0] = '\0';
		filelist[x].filename[0] = '\0';
		filelist[x].size = 0;
	}

	x=-1;
	fid =fopen( path, "ra" );
	if (fid!=NULL) {
		for (c=0;c<FTP_FILELIST_SIZE;c++) {	/* maximum structure size */
			if (fgets( buff, sizeof(buff), fid )!=NULL ) {
				if (c==FTP_FILELIST_SIZE-1) { expand_directory(); }
				if ((buff[0]=='-')||(buff[0]=='d')||(buff[0]=='l')) {
				/*	fprintf( log, "%s", buff ); */
					x++;
					sscanf( buff, "%s%*s%*s%*s%ld%s%2s%s%s",
						filelist[x].status, &filelist[x].size, filelist[x].date,
						day, filelist[x].time, filelist[x].filename );
					filelist[x].date[3]=' ';
					strcpy( filelist[x].date+4, day );
					maximum_file = x;
				} else if (strchr( buff, '\t')!=0) {
				/*	fprintf( log, "%s", buff ); */
					x++;
					sscanf( buff, "%s%s%s%*s%s",
						filelist[x].filename, vsize, vdate,
						vstatus );
					filelist[x].size = atol(vsize)*512;
					vdate[6]='\0';
					strcpy( filelist[x].date, vdate );
					strcpy( filelist[x].time, vdate+7 ); 
					strcpy( filelist[x].status, "-r--r--r--" );
					if (stcpm(buff, ".DIR", &p)==4) { filelist[x].status[0]='d'; }
					maximum_file = x;
				}
			} else { break; }
		}
		fclose( fid );
	} 
	graf_mouse( ARROW, NULL );
	windows[11].num_lines=maximum_file+1;
	windows[11].line_no=0;
}

void expand_servers()
{
	int new_size,x;
	size_t new_bytes;
	void *new_ptr;
	char temp[80];

	new_size  = 2 * SERVER_SIZE;
	new_bytes = new_size * sizeof( struct fservers );
	new_ptr   = realloc( server, new_bytes );
	if (!new_ptr) {
		sprintf( temp,"[1][Insufficient Memory for %s][ OK ]", "|FTP Servers" );
		form_alert( 1, temp );
		return;				/* failed */
	}
	server = new_ptr;
	for (x=SERVER_SIZE;x<new_size;x++) {	/* clear new entries */
	/*	server[x].name[0] = '\0'; */
		memset( &server[x], 0, sizeof( struct fservers ) );
	}
	SERVER_SIZE = new_size;
	fprintf( log, "FTP Servers expanded to %d entries\n", new_size );
}

void load_servers(char *serverfile)
{
	char buff[300],*name,*user,*pswd,*dir,*port;
	register int x;
	FILE *fid;

	graf_mouse( BUSY_BEE, NULL );
	current_server=-1;
    maximum_server=-1;
	for (x=0;x<SERVER_SIZE;x++) {	/* initialize structure */
	/*	memset( &server[x], 0, sizeof( struct fservers ) ); */
		server[x].name[0] = '\0';
		server[x].user[0] = '\0';
		server[x].password[0] = '\0';
		server[x].directory[0] = '\0';
		server[x].port[0] = '\0';
	}

/*	fprintf( log, "Opening FTP Server File: %s\n", serverfile ); */
	fid =fopen( serverfile, "ra" );
	if (fid!=NULL) {
		for (x=0;x<SERVER_SIZE;x++) {	/* initialize structure */
			if (fgets( buff, sizeof(buff), fid )!=NULL ) {
				if (x==SERVER_SIZE-1) { expand_servers(); }
			/*	fprintf( log, "%s", buff ); */
				buff[strlen(buff)-1]='\t';
			/*	strtok( buff, "\n" );			/* remove newline */
				name = strtoka( buff, '\t' );	/* server name */
				user = strtoka( NULL, '\t' );	/* user logon id */
				pswd = strtoka( NULL, '\t' );	/* logon password */
				dir  = strtoka( NULL, '\t' );	/* start directory */
				port = strtoka( NULL, '\t' );	/* non-default port */
	
				strcpy( server[x].name, name );
				strcpy( server[x].user, user );
				strcpy( server[x].password, pswd );
				strcpy( server[x].directory, dir );
				strcpy( server[x].port, port );
				maximum_server = x;
				current_server = 0;		/* default to first */
			}
		}
		fclose( fid );
	}
	initialize_cache();
	graf_mouse( ARROW, NULL );
	windows[11].num_lines=maximum_server+1;
	windows[11].line_no=0;
}

void unload_servers(char *serverfile)
{
	register int x;
	FILE *fid;

    if (maximum_server==-1) { return; }

	fid =fopen( serverfile, "wa" );
	if (fid!=NULL) {
		for (x=0;x<maximum_server+1;x++) {	/* for each server */
			if (server[x].name[0]!='\0') {
				fprintf( fid, "%s\t%s\t%s\t%s\t%s\n", server[x].name, server[x].user, server[x].password, server[x].directory, server[x].port );
			}
		}
		fclose( fid );
	}
}

void empty_cache(void)
{
	int x;

	for (x=0;x<FTP_CACHE_SIZE;x++) {
		if (ftp_cache[x].directory[0]!='\0') {
			ftp_cache[x].directory[0]='\0';
			if (ftp_cache[x].filename[0]!='\0') {
			/*	fprintf( log, "Erasing: %s\n", ftp_cache[x].filename ); fflush( log ); */
				remove( ftp_cache[x].filename );	/* purge file */
				ftp_cache[x].filename[0]='\0';
			}
		}
	}
}

void initialize_cache(void)
{
	int x;

	for (x=0;x<FTP_CACHE_SIZE;x++) {
		ftp_cache[x].directory[0]='\0';
		ftp_cache[x].filename[0]='\0';
	}
}

int get_dir_list( char *filename )
{
	int rc;
	char dir[FMSIZE];

	use_status( 11 );	/* use infoline in window */
	show_status( ErrMsg(EM_RetrieveDir) );	/* "Retrieving Directory" */
	rc = ftp_type( "A" );
	fflush( log );
	rc = ftp_list( filename );
	fflush( log );
	rc = ftp_pwd( dir );
	fflush( log );
	if (strcmp( dir, current_directory )!=0) {
		fprintf( log, "Error - dir: %s, current: %s\n", dir, current_directory );
		fflush( log );
	}
	rc = ftp_type( "I" );
	hide_status();
	return(rc);
}

int get_cache(char *path)
{
	int x,rc;
	static int next_dir_number=0;
	char filename[FMSIZE];

/*	fprintf( log, "Entering get_cache()\n"); fflush(log); */
	/* must handle overflow, i.e.
	if (ftp_cache[FTP_CACHE_SIZE-1].directory!='\0') {
		for (x=0;x<FTP_CACHE_SIZE-1;x++) {
			memcpy( &ftp_cache[x], &ftp_cache[x+1], sizeof(ftp_cache[0]) );
		}
		ftp_cache[x].directory[FTP_CACHE_SIZE-1]='\0';
		ftp_cache[x].filename[FTP_CACHE_SIZE-1]='\0';
	} */
	for (x=0;x<FTP_CACHE_SIZE;x++) {
		if (ftp_cache[x].directory[0]=='\0') {	/* new */
			strcpy(ftp_cache[x].directory, current_directory);
		}
		if (strcmp(ftp_cache[x].directory, current_directory )==0) {	/*found*/
			if (ftp_cache[x].filename[0]=='\0') {	/* new */
				next_dir_number = get_unique_filename(next_dir_number, "ftpd", prefs.ftp_download_path );
				sprintf( filename, "%s\\ftpd%04d.txt", prefs.ftp_download_path, next_dir_number++ );
				strcpy(ftp_cache[x].filename, filename);
				rc = get_dir_list( filename );
			}
			strcpy( path, ftp_cache[x].filename );	/* return filename */
			return(x);
		}
	}
/*	fprintf( log, "Leaving get_cache()\n"); fflush(log); */
}

/* end of FTP.C */