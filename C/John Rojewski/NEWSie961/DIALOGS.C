/*
 *  dialogs.c		Dialogs for NEWSie
 *
 *  Created by: John Rojewski, July, 1996
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
#include <mintbind.h>
#include <cookie.h>
#include <sys\stat.h>

#include "newsie.h"
#include "protocol.h"
#include "av_proto.h"
#include "global.h"

#define VERSION "0.961 Jul 27, 2000"
#define ErrMsg(a) (char *)em[a].ob_spec
#define dlogMsg(a) (char *)dlog[a].ob_spec
#define OFFLINE (ncn<0)&&(prefs.offline_test=='Y')

char *strtoka( char *s, int tok );	/* prototype in MAILER.C */
long filesize( char *filename );	/* prototype in MAILER.C */
long count_lines( char *filename );	/* prototype from MAILER.C */
int filelist_popup(char *mailbox, const char *mask); /* prototype from MAILER.C */

#define SERIAL_BASE 30753

long serial_encode(int i) 
{
/*	return( SERIAL_BASE + (7*i) - (3*(i%3)) ); */
	return( 30753 + (7*i) - (3*(i%3)) );
}

int serial_decode( long value )
{
	long new;
	int  i=0;

	while (1) {
		new = serial_encode( i );	/* offset 0 = user #1 */
		i++;
	/*	if (log) fprintf( log, "serial=%ld, new=%ld, i=%d\n", value, new, i ); */
		if (new == value) { return( i ); }
		if (new > value) { return(0); }		/* invalid serial # */
	/*	if (i > 100) { return(0); }		/* too much print */
	}
}

int valid_registration_number(void)
{
	long serial;

/*	if (log) fprintf( log, "Registration number = %s\n", prefs.registration_number ); */
	if ((serial=atol(prefs.registration_number))!=0) {
	/*	if (log) fprintf( log, "Registration number = %ld\n", serial ); */
		return( serial_decode( serial ) );
	}
	return(0);
}

void about_NEWSie_dialog(void)
{
	OBJECT *dlog;
	void far *btn;
	int result;
	
	rsrc_gaddr(R_TREE,About_NEWSie,&dlog);
	set_tedinfo( dlog, About_Version, VERSION );
	btn=dlog[About_Register].ob_spec;
	if (valid_registration_number()) {
		dlog[About_Register].ob_spec=prefs.registration_number;
	/*	set_tedinfo( dlog, About_Register, prefs.registration_number ); */
	} else {
		dlog[About_Register].ob_state&=~DISABLED;
	}
	result=handle_dialog(dlog,0);
	dlog[About_Register].ob_spec=btn;
	dlog[About_Register].ob_state|=DISABLED;

	if (result==About_Contribute) {
		handle_redraw_event();
		evnt_timer( 250, 0 );	/* wait .25 seconds */
		rsrc_gaddr(R_TREE,Contributors,&dlog);
		result=handle_dialog(dlog,0);
	}
	if (result==About_Register) {
		send_registration_info();
	}
}

void handle_show_headers( int before, int after )
{
	if (before!=after) {
		if (windows[3].open) {
			release_window_buffer( 3, 1 );
			refresh_clear_window( windows[3].id );
			set_vslider( 3, windows[3].id );
		}
		if (windows[7].open) {
			release_window_buffer( 7, 1 );
			refresh_clear_window( windows[7].id );
			set_vslider( 7, windows[7].id );
		}
	}
}

void News_Reading_Preferences_dialog(void)
{
	OBJECT *dlog;
	int refresh=0;
	char tmp1,tmp2;
	
	rsrc_gaddr(R_TREE,Pref_Read,&dlog);
	set_crossed( dlog, PR_ShowAuthor, prefs.show_authors=='Y' );	
	set_crossed( dlog, PR_ShowHeaders, prefs.show_headers=='Y' );	
	set_crossed( dlog, PR_CollapseThr, prefs.collapse_threads=='Y' );	
	set_crossed( dlog, PR_CreateThr, prefs.create_threads=='Y' );	
	set_crossed( dlog, PR_KeyboardNav, prefs.allow_kbd_nav=='Y' );	
	set_crossed( dlog, PR_OfflineTest, prefs.offline_test=='Y' );	
	set_crossed( dlog, PR_ShowStatus, prefs.show_status=='Y' );	
	set_crossed( dlog, PR_EraseArticles, prefs.erase_articles=='Y' );	
	set_crossed( dlog, PR_UseExtViewer, prefs.use_ext_viewer=='Y' );	
	set_tedinfo( dlog, PR_MaxArticles, prefs.max_articles );
	set_tedinfo( dlog, PR_RecentArticle, prefs.recent_articles );
	if (handle_dialog(dlog, PR_MaxArticles)==PR_OK) {
		get_crossed( dlog, PR_ShowAuthor, &prefs.show_authors );
		get_crossed( dlog, PR_KeyboardNav, &prefs.allow_kbd_nav );	
		get_crossed( dlog, PR_OfflineTest, &prefs.offline_test );	
		get_crossed( dlog, PR_ShowStatus, &prefs.show_status );	
		get_crossed( dlog, PR_EraseArticles, &prefs.erase_articles );	
		get_crossed( dlog, PR_UseExtViewer, &prefs.use_ext_viewer );	
		get_tedinfo( dlog, PR_MaxArticles, prefs.max_articles );
		get_tedinfo( dlog, PR_RecentArticle, prefs.recent_articles );

		tmp1=prefs.show_headers;
		get_crossed( dlog, PR_ShowHeaders, &prefs.show_headers );
		handle_show_headers( tmp1, prefs.show_headers );
		tmp1=prefs.collapse_threads;
		get_crossed( dlog, PR_CollapseThr, &prefs.collapse_threads );
		if (tmp1!=prefs.collapse_threads) { refresh=1; }
		tmp2=prefs.collapse_threads;
		get_crossed( dlog, PR_CreateThr, &prefs.create_threads );	
		if (tmp2!=prefs.create_threads) { refresh=1; }
		if (prefs.create_threads=='N') { prefs.collapse_threads='N'; }
		if (refresh) {
			create_threads();
			collapse_all_threads();
			refresh_window( windows[2].id );
		}
	}
}

void Mail_Reading_Preferences_dialog(void)
{
	OBJECT *dlog;
	char tmp1;
	char ignore,respect,force;
	
	rsrc_gaddr(R_TREE,Pref_Mail,&dlog);
	set_crossed( dlog, MR_ShowHeaders, prefs.show_headers=='Y' );	
	set_crossed( dlog, MR_DeleteMail, prefs.delete_mail_from_server=='Y' );	
	set_crossed( dlog, MR_UsePassword, prefs.use_saved_password=='Y' );	
	set_crossed( dlog, MR_DeleteQueued, prefs.delete_queued_mail=='Y' );	
	set_crossed( dlog, MR_SendCheck, prefs.send_queued_at_check=='Y' );	
	set_crossed( dlog, MR_MailDirs, prefs.mail_directories=='Y' );	
	set_tedinfo( dlog, MR_Password, prefs.password );
	set_crossed( dlog, MR_Ignore, prefs.mime_headers=='N' );	/* ig'N'ore */
	set_crossed( dlog, MR_Respect, prefs.mime_headers=='R' );	
	set_crossed( dlog, MR_Force, prefs.mime_headers=='F' );	

	if (handle_dialog(dlog, MR_Password)==MR_OK) {
		get_crossed( dlog, MR_DeleteMail, &prefs.delete_mail_from_server );	
		get_crossed( dlog, MR_UsePassword, &prefs.use_saved_password );	
		get_crossed( dlog, MR_DeleteQueued, &prefs.delete_queued_mail );	
		get_crossed( dlog, MR_SendCheck, &prefs.send_queued_at_check );	
		get_crossed( dlog, MR_MailDirs, &prefs.mail_directories );
		get_tedinfo( dlog, MR_Password, prefs.password );
		get_crossed( dlog, MR_Ignore, &ignore );
		get_crossed( dlog, MR_Respect, &respect );
		get_crossed( dlog, MR_Force, &force );

		if (ignore=='Y') { prefs.mime_headers='N'; }
		if (respect=='Y') { prefs.mime_headers='R'; }
		if (force=='Y') { prefs.mime_headers='F'; }

		tmp1=prefs.show_headers;
		get_crossed( dlog, MR_ShowHeaders, &prefs.show_headers );
		handle_show_headers( tmp1, prefs.show_headers );
	}
}

void Message_Preferences_dialog(void)
{
	OBJECT *dlog;

	rsrc_gaddr(R_TREE,Pref_Message,&dlog);
	set_crossed( dlog, PM_ReplyPosting, prefs.reply_via_posting=='Y' );	
	set_crossed( dlog, PM_ReplyEmail, prefs.reply_via_email=='Y' );	
	set_crossed( dlog, PM_Copiestoself, prefs.copies_to_self=='Y' );	
	set_crossed( dlog, PM_AppendSig, prefs.append_signature=='Y' );	
	set_tedinfo( dlog, PM_QuoteString, prefs.quote_string );
	if (handle_dialog(dlog, PM_QuoteString)==PM_OK) {
		get_crossed( dlog, PM_ReplyPosting, &prefs.reply_via_posting );
		get_crossed( dlog, PM_ReplyEmail, &prefs.reply_via_email );
		get_crossed( dlog, PM_Copiestoself, &prefs.copies_to_self );
		get_crossed( dlog, PM_AppendSig, &prefs.append_signature );
		get_tedinfo( dlog, PM_QuoteString, prefs.quote_string );
	}
}

void Server_Preferences_dialog(void)
{
	OBJECT *dlog;
	
	rsrc_gaddr(R_TREE,Pref_Server,&dlog);
	set_tedinfo( dlog, PS_NewsServer, prefs.news_server );
	set_tedinfo( dlog, PS_MailServer, prefs.mail_server );
	set_tedinfo( dlog, PS_PopServer, prefs.pop_server );
	set_tedinfo( dlog, PS_ToMaximum, prefs.to_maximum );
	set_tedinfo( dlog, PS_ToLastChar, prefs.to_last_char );
	set_crossed( dlog, PS_NewsStart, prefs.subscribe_startup=='Y' );	
	set_crossed( dlog, PS_ConnectStart, prefs.connect_startup=='Y' );	
	if (handle_dialog(dlog, PS_NewsServer)==PS_OK) {
		get_tedinfo( dlog, PS_NewsServer, prefs.news_server );
		get_tedinfo( dlog, PS_MailServer, prefs.mail_server );
		get_tedinfo( dlog, PS_PopServer, prefs.pop_server );
		get_tedinfo( dlog, PS_ToMaximum, prefs.to_maximum );
		max_to = atoi( prefs.to_maximum );
		get_tedinfo( dlog, PS_ToLastChar, prefs.to_last_char );
		char_to = atoi( prefs.to_last_char );
		get_crossed( dlog, PS_ConnectStart, &prefs.connect_startup );	
		get_crossed( dlog, PS_NewsStart, &prefs.subscribe_startup );	
	}
}

void Personal_Preferences_dialog(void)
{
	OBJECT *dlog;
	
	rsrc_gaddr(R_TREE,Pref_Personal,&dlog);
	set_tedinfo( dlog, PP_FullName, prefs.full_name );
	set_tedinfo( dlog, PP_Organization, prefs.organization );
	set_tedinfo( dlog, PP_AccountName, prefs.account_name );
	set_tedinfo( dlog, PP_Email, prefs.email_address );
	if (handle_dialog(dlog, PP_FullName)==PP_OK) {
		get_tedinfo( dlog, PP_FullName, prefs.full_name );
		get_tedinfo( dlog, PP_Organization, prefs.organization );
		get_tedinfo( dlog, PP_AccountName, prefs.account_name );
		get_tedinfo( dlog, PP_Email, prefs.email_address );
	}
}

void Signature_Preferences_dialog(void)
{
	OBJECT *dlog;
	int result,button;
	char select[FMSIZE];
	char dirname[FMSIZE],path[FMSIZE],filename[FMSIZE];
	
	rsrc_gaddr(R_TREE,Pref_Signature,&dlog);
	set_tedinfo( dlog, PSig_Path, prefs.signature_file );
	strcpy( filename, prefs.signature_file );

	preview_signature_file( dlog, filename );

	do {
		result = handle_dialog(dlog, 0);
		switch (result) {
			case PSig_File :
			case PSig_Path :
				stcgfp( dirname, filename );
				strcat( dirname, "\\*.*" );
			 	*select = 0;
				fsel_exinput( dirname, select, &button, dlogMsg(PSig_File) );
				if (button) {
					stcgfp( path, dirname );
					sprintf( filename, "%s\\%s", path, select );
				 	set_tedinfo( dlog, PSig_Path, filename );
					preview_signature_file( dlog, filename );
				}
				break;
		}
 	} while (result<PSig_Cancel);
	if (result==PSig_OK) {
		strcpy(prefs.signature_file, filename);
	}
}

void preview_signature_file( OBJECT *dlog, char *filename )
{
	FILE *fid;
	int c;
	char *p,buff[80];

	for (c=0;c<6;c++) {		/* clear lines in dialog */
		buff[0] = '\0';
		set_tedinfo( dlog, PSig_Line1+c, buff );
	}

	fid = fopen( filename, "ra" );
	if (fid!=NULL) {
		for (c=0;c<6;c++) {
			if (fgets( buff, sizeof(buff), fid )!=NULL) {
				p = strtok( buff, "\n" );	/* remove new_line */
				buff[59] = '\0';			/* null terminated */
				set_tedinfo( dlog, PSig_Line1+c, buff );
			}
		}
		fclose( fid );
	} else { filename[0] = '\0'; }			/* invalid filename */
}

void Font_Preferences_dialog(void)
{
	OBJECT *dlog;
	char tfont[35],tsize[3];
	
	rsrc_gaddr(R_TREE,Pref_Fonts,&dlog);
	set_tedinfo( dlog, PF_News_Fname, prefs.newsgroup_font );
	set_tedinfo( dlog, PF_Over_Fname, prefs.overview_font );
	set_tedinfo( dlog, PF_Art_Fname, prefs.news_font );
	set_tedinfo( dlog, PF_News_Fsize, prefs.newsgroup_font_size );
	set_tedinfo( dlog, PF_Over_Fsize, prefs.overview_font_size );
	set_tedinfo( dlog, PF_Art_Fsize, prefs.news_font_size );
	if (handle_dialog(dlog, PF_News_Fsize)==PF_OK) {
		strcpy( tfont, prefs.newsgroup_font );
		strcpy( tsize, prefs.newsgroup_font_size );
		get_tedinfo( dlog, PF_News_Fname, prefs.newsgroup_font );
		get_tedinfo( dlog, PF_News_Fsize, prefs.newsgroup_font_size );
		refresh_window_fonts( tfont, tsize, prefs.newsgroup_font, prefs.newsgroup_font_size, 1 );

		strcpy( tfont, prefs.overview_font );
		strcpy( tsize, prefs.overview_font_size );
		get_tedinfo( dlog, PF_Over_Fname, prefs.overview_font );
		get_tedinfo( dlog, PF_Over_Fsize, prefs.overview_font_size );
		refresh_window_fonts( tfont, tsize, prefs.overview_font, prefs.overview_font_size, 2 );

		strcpy( tfont, prefs.news_font );
		strcpy( tsize, prefs.news_font_size );
		get_tedinfo( dlog, PF_Art_Fname, prefs.news_font );
		get_tedinfo( dlog, PF_Art_Fsize, prefs.news_font_size );
		refresh_window_fonts( tfont, tsize, prefs.news_font, prefs.news_font_size, 3 );
	}
}

void display_font_list_dialog(OBJECT *tree, int obj)
{
/*	char default_font[]="6x6 system";*/
	char *dest;
	OBJECT *dlog;
	int result,c,fstart=0;
	int x,y,w,h;
	char current_font[40];

	rsrc_gaddr(R_TREE,Font_List,&dlog);
	form_center(dlog,&x,&y,&w,&h);
	objc_offset( tree, obj-2, &x, &y );		/* locate fontname */
	x-=8; y-=4;

	if (x<0) { x=0; }	/* keep dialog on screen */
	if ((x+w)>(screenx+screenw)) { x = screenx + screenw - w; }
	if ((y+h)>(screeny+screenh)) { y = screeny + screenh - h; }

	dlog[0].ob_x = x;
	dlog[0].ob_y = y;
	if (!save_restore_screen( 1, dlog )) {	/* save */
		form_dial(FMD_START,0,0,0,0,x,y,w,h);
	}
	get_tedinfo( tree, obj-2, current_font );
	set_tedinfo( dlog, FL_Exit1, current_font );
	do {
		for (c=FL_FontName1;c<FL_FontName10+1;c++) {
			dest=(char *)dlog[c].ob_spec;
			strcpy(dest,font[fstart+c-FL_FontName1].name);
		}
		objc_draw(dlog,0,10,x,y,w,h);
		result=form_do(dlog, 0);
		switch (result)
		{
			case FL_UpArrow :
				fstart = (fstart-10 > 0) ? fstart-10 : 0;	/* maximum */
				break;
			case FL_DnArrow :
				if (fstart+10 < (FONT_SIZE-1)) { fstart+=10; }	/* minimum */
				break;
			case FL_Exit1 :
			case FL_Exit2 :
				break;
			default :
				set_tedinfo( tree, obj-2, font[fstart+result-FL_FontName1].name );
		}
		dlog[result].ob_state&=~SELECTED;	/* de-select exit button */
	} while ((result==FL_UpArrow)|(result==FL_DnArrow ));
	if (!save_restore_screen( 0, dlog )) {	/* restore */
		h-=	tree[0].ob_y + tree[0].ob_height - y;
		if (h>0) {
			y =	tree[0].ob_y + tree[0].ob_height;
			form_dial(FMD_FINISH,0,0,0,0,x,y+3,w,h-3);
			handle_redraw_event();
		}
	}
}

int find_font( char *fontname )
{
	int c;

	for (c=0;c<FONT_SIZE;c++) {
		if(strcmp(fontname,font[c].name)==0) return(font[c].index);
	}
	return(0);
}

void Path_Preferences_dialog(void)
{
	OBJECT *dlog;
	int result,button;
	char select[FMSIZE];
	char dirname[FMSIZE],temp[FMSIZE];
	char path[FMSIZE],mailpath[FMSIZE],editor[FMSIZE],viewer[FMSIZE];
	char offline[FMSIZE],download[FMSIZE];
	
	rsrc_gaddr(R_TREE,Pref_Path,&dlog);
	set_tedinfo( dlog, PPa_WorkPath, prefs.work_path );
	set_tedinfo( dlog, PPa_MailPath, prefs.mail_path );
	set_tedinfo( dlog, PPa_OfflinePath, prefs.offline_path );
	set_tedinfo( dlog, PPa_ExtViewer, prefs.external_viewer );
	set_tedinfo( dlog, PPa_ExtEditor, prefs.external_editor );
	set_tedinfo( dlog, PPa_FTPDownload, prefs.ftp_download_path );

	strcpy( path, prefs.work_path );
	strcpy( mailpath, prefs.mail_path );
	strcpy( offline, prefs.offline_path );
	strcpy( viewer, prefs.external_viewer );
	strcpy( editor, prefs.external_editor );
	strcpy( download, prefs.ftp_download_path );
	do {
		result = handle_dialog(dlog, 0);
		switch (result) {
			case PPa_PathConst :
			case PPa_WorkPath :
				stcgfp( dirname, path );
				strcat( dirname, "\\*.*" );
			 	*select = 0;
				fsel_exinput( dirname, select, &button, dlogMsg(PPa_PathConst) );
				if (button) {
					stcgfp( path, dirname );
				 	set_tedinfo( dlog, PPa_WorkPath, path );
				}
				break;
			case PPa_MailConst :
			case PPa_MailPath :
				/* get_a_path( mailpath, "\\*.*", PPa_MailConst, PPa_MailPath ); */
				stcgfp( dirname, mailpath );
				strcat( dirname, "\\*.*" );
			 	*select = 0;
				fsel_exinput( dirname, select, &button, dlogMsg(PPa_MailConst) );
				if (button) {
					stcgfp( mailpath, dirname );
				 	set_tedinfo( dlog, PPa_MailPath, mailpath );
				}
				break;
			case PPa_OfflineConst :
			case PPa_OfflinePath :
				/* get_a_path( offline, "\\*.*", PPa_OfflineConst, PPa_OfflinePath ); */
				stcgfp( dirname, offline );
				strcat( dirname, "\\*.*" );
			 	*select = 0;
				fsel_exinput( dirname, select, &button, dlogMsg(PPa_OfflineConst) );
				if (button) {
					stcgfp( offline, dirname );
				 	set_tedinfo( dlog, PPa_OfflinePath, offline );
				}
				break;
			case PPa_ViewConst :
			case PPa_ExtViewer :
				stcgfp( dirname, viewer );
				strcat( dirname, "\\*.prg" );
			 	*select = 0;
				fsel_exinput( dirname, select, &button, dlogMsg(PPa_ViewConst) );
				if (button) {
					stcgfp( temp, dirname );
					sprintf( viewer, "%s\\%s", temp, select );
				 	set_tedinfo( dlog, PPa_ExtViewer, viewer );
				}
				break;
			case PPa_EditConst :
			case PPa_ExtEditor :
				stcgfp( dirname, editor );
				strcat( dirname, "\\*.prg" );
			 	*select = 0;
				fsel_exinput( dirname, select, &button, dlogMsg(PPa_EditConst) );
				if (button) {
					stcgfp( temp, dirname );
					sprintf( editor, "%s\\%s", temp, select );
				 	set_tedinfo( dlog, PPa_ExtEditor, editor );
				}
				break;
			case PPa_FTPDownCon :
			case PPa_FTPDownload :
				/* get_a_path( offline, "\\*.*", PPa_OfflineConst, PPa_OfflinePath ); */
				stcgfp( dirname, download );
				strcat( dirname, "\\*.*" );
			 	*select = 0;
				fsel_exinput( dirname, select, &button, dlogMsg(PPa_FTPDownCon) );
				if (button) {
					stcgfp( download, dirname );
				 	set_tedinfo( dlog, PPa_FTPDownload, download );
				}
				break;
		}
 	} while (result<PPa_Cancel);
	if (result==PPa_OK) {
		strcpy( prefs.work_path, path );
		strcpy( prefs.mail_path, mailpath );
		strcpy( prefs.offline_path, offline );
		strcpy( prefs.external_viewer, viewer );
		strcpy( prefs.external_editor, editor );
		strcpy( prefs.ftp_download_path, download );
	}
}

void Browser_Preferences_dialog(void)
{
	OBJECT *dlog;
	int result,button;
	char select[FMSIZE];
	char dirname[FMSIZE],temp[FMSIZE];
	char cache[FMSIZE],home[FMSIZE],hotlist[FMSIZE];
	
	rsrc_gaddr(R_TREE,Pref_Browser,&dlog);
	set_crossed( dlog, PB_HistoryLog, prefs.browser_history=='Y' );
	set_tedinfo( dlog, PB_HomePath, prefs.browser_home );
	set_tedinfo( dlog, PB_HotPath, prefs.browser_hotlist );
	set_tedinfo( dlog, PB_CachePath, prefs.browser_cache_path );

	strcpy( home, prefs.browser_home );
	strcpy( hotlist, prefs.browser_hotlist );
	strcpy( cache, prefs.browser_cache_path );
	do {
		result = handle_dialog(dlog, 0);
		switch (result) {
			case PB_CacheCon :
			case PB_CachePath :
				/* get_a_path( cache, "\\*.*", PPa_OfflineConst, PPa_OfflinePath ); */
				stcgfp( dirname, cache );
				strcat( dirname, "\\*.*" );
			 	*select = 0;
				fsel_exinput( dirname, select, &button, dlogMsg(PB_CacheCon) );
				if (button) {
					stcgfp( cache, dirname );
				 	set_tedinfo( dlog, PB_CachePath, cache );
				}
				break;
			case PB_HomeCon :
			case PB_HomePath :
				stcgfp( dirname, home );
				strcat( dirname, "\\*.htm" );
			 	*select = 0;
				fsel_exinput( dirname, select, &button, dlogMsg(PB_HomeCon) );
				if (button) {
					stcgfp( temp, dirname );
					sprintf( home, "%s\\%s", temp, select );
				 	set_tedinfo( dlog, PB_HomePath, home );
				}
				break;
			case PB_HotCon :
			case PB_HotPath :
				stcgfp( dirname, hotlist );
				strcat( dirname, "\\*.htm" );
			 	*select = 0;
				fsel_exinput( dirname, select, &button, dlogMsg(PB_HotCon) );
				if (button) {
					stcgfp( temp, dirname );
					sprintf( hotlist, "%s\\%s", temp, select );
				 	set_tedinfo( dlog, PB_HotPath, hotlist );
				}
				break;		}
 	} while (result<PB_Cancel);
	if (result==PB_OK) {
		get_crossed( dlog, PB_HistoryLog, &prefs.browser_history );
		strcpy( prefs.browser_home, home );
		strcpy( prefs.browser_hotlist, hotlist );
		strcpy( prefs.browser_cache_path, cache );
	}
}

void Log_Preferences_dialog(void)
{
	OBJECT *dlog;

	rsrc_gaddr(R_TREE,Pref_Log,&dlog);
	set_crossed( dlog, PL_DataTrans, prefs.log_data=='Y' );	
	set_crossed( dlog, PL_Commands, prefs.log_commands=='Y' );	
	set_crossed( dlog, PL_Responses, prefs.log_responses=='Y' );	
	set_crossed( dlog, PL_MaskPswd, prefs.log_mask_pswds=='Y' );	
	if (handle_dialog(dlog, 0)==PL_OK) {
		get_crossed( dlog, PL_DataTrans, &prefs.log_data );
		get_crossed( dlog, PL_Commands, &prefs.log_commands );
		get_crossed( dlog, PL_Responses, &prefs.log_responses );
		get_crossed( dlog, PL_MaskPswd, &prefs.log_mask_pswds );	
		log_data = prefs.log_data;
		log_cmd  = prefs.log_commands;
		log_resp = prefs.log_responses;
		log_mask_pswds = prefs.log_mask_pswds;
	}
}

void FTP_Preferences_dialog(void)
{
	OBJECT *dlog;

	rsrc_gaddr(R_TREE,Pref_FTP,&dlog);
	set_crossed( dlog, PFTP_SendHelp, prefs.ftp_send_help=='Y' );	
	set_crossed( dlog, PFTP_SaveLast, prefs.ftp_save_last_dir=='Y' );	
	set_crossed( dlog, PFTP_SendAlloc, prefs.ftp_send_alloc=='Y' );	
	set_crossed( dlog, PFTP_UsePort, prefs.ftp_use_port=='Y' );
	set_crossed( dlog, PFTP_SaveLower, prefs.ftp_savelower!='N' );
	if (handle_dialog(dlog, 0)==PFTP_OK) {
		get_crossed( dlog, PFTP_SendHelp, &prefs.ftp_send_help );	
		get_crossed( dlog, PFTP_SaveLast, &prefs.ftp_save_last_dir );	
		get_crossed( dlog, PFTP_SendAlloc, &prefs.ftp_send_alloc );	
		get_crossed( dlog, PFTP_UsePort, &prefs.ftp_use_port );
		get_crossed( dlog, PFTP_SaveLower, &prefs.ftp_savelower );

		ftp_send_help  = prefs.ftp_send_help;
		ftp_send_alloc = prefs.ftp_send_alloc;
		ftp_use_port   = prefs.ftp_use_port;
	/*	ftp_save  = prefs.ftp_save_last_dir; */
	}
}

void resize_font_dialog(OBJECT *dlog, int resize )
{
	int c;

	dlog[0].ob_width+=resize;
	dlog[FL_Exit1].ob_width+=resize;
	for (c=FL_FontName1;c<FL_FontName10+1;c++) { dlog[c].ob_width+=resize; }
	dlog[FL_UpArrow].ob_x+=resize;
	dlog[FL_DnArrow].ob_x+=resize;
	dlog[FL_Exit2].ob_x+=resize;
}

void select_language(OBJECT *tree, int obj)
{
	char *dest;
	OBJECT *dlog;
	int result,c,fstart=0;
	long count;
	int x,y,w,h;
	char current_font[40],empty[]="";
	struct FILEINFO info;
	char dir[FMSIZE];
	char files[200],*pointers[30];	/* maximum of 17 languages */

	sprintf( dir, "%s\\language", program_path );
/*	fprintf( log, "Directory: %s\n", dir ); */

	if (!dfind(&info, dir, FA_SUBDIR )) {
		chdir( dir );
	} else {
		fprintf( log, "Directory: %s not found\n", dir ); fflush(log);
		return;
	}

	if ((count = getfnl("*.*", files, sizeof(files), FA_SUBDIR ))>0) {	/* sub directories */
	/*	fprintf( log, "%s contains %ld files\n", dir, count ); */
		if (strbpl(pointers,20,files)==count) {
			for (c=0;c<count;c++) {
				if (pointers[c][0]=='.') { pointers[c][0]='z'; continue; }
				if (!dfind(&info, pointers[c], FA_SUBDIR )) {	/* directories only */
					if (info.attr&FA_SUBDIR) {
					/*	fprintf( log, "Language: %s\n", info.name ); */
					} else { pointers[c][0]='z'; }
				}
			}
			strsrt( pointers, count );
			for (c=0;c<count;c++) {
				if (pointers[c][0]=='z')  pointers[c]=empty;
			}
		}
	}
	chdir( program_path );
	for (c=(short)count;c<20;c++) { pointers[c]=empty; }

	rsrc_gaddr(R_TREE,Font_List,&dlog);
	resize_font_dialog( dlog, -176 );		/* reduce dialog size */
	form_center(dlog,&x,&y,&w,&h);
	objc_offset( tree, obj, &x, &y );		/* locate fontname */
	x-=8; y-=4;

	if (x<0) { x=0; }
	if ((x+w)>(screenx+screenw)) { x = screenx + screenw - w; }
	if ((y+h)>(screeny+screenh)) { y = screeny + screenh - h; }

	dlog[0].ob_x = x;
	dlog[0].ob_y = y;
	if (!save_restore_screen( 1, dlog )) {	/* save */
		form_dial(FMD_START,0,0,0,0,x,y,w,h);
	}
	get_tedinfo( tree, obj, current_font );
	set_tedinfo( dlog, FL_Exit1, current_font );
	do {
		for (c=FL_FontName1;c<FL_FontName10+1;c++) {
			dest=(char *)dlog[c].ob_spec;
			strcpy(dest,pointers[fstart+c-FL_FontName1]);
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
				if (fstart+10 < (20-1)) { fstart+=10; }	/* minimum */
				break;
			case FL_Exit1 :
			case FL_Exit2 :
				break;
			default :
				set_tedinfo( tree, obj, pointers[fstart+result-FL_FontName1] );
		}
		dlog[result].ob_state&=~SELECTED;	/* de-select exit button */
	} while ((result==FL_UpArrow)|(result==FL_DnArrow ));
	if (!save_restore_screen( 0, dlog )) {	/* restore */
		h-=	tree[0].ob_y + tree[0].ob_height - y;
		if (h>0) {
			y =	tree[0].ob_y + tree[0].ob_height;
			form_dial(FMD_FINISH,0,0,0,0,x,y+3,w,h-3);
			handle_redraw_event();
		}
	}
	resize_font_dialog( dlog, 176 );	/* restore dialog size */
}

#define Touch_On(x) dlog[x].ob_flags|=TOUCHEXIT
#define Touch_Off(x) dlog[x].ob_flags&=~TOUCHEXIT
#define Button_Disable(x) dlog[x].ob_state|=DISABLED
#define Button_Enable(x) dlog[x].ob_state&=~DISABLED

void General_Preferences_dialog(void)
{
	OBJECT *dlog;
	char bar,bot,c,prompt;
	char lang[12],aut;

	rsrc_gaddr(R_TREE,Pref_General,&dlog);
	bar = prefs.show_toolbar;
	set_crossed( dlog, PG_AutoTop, prefs.auto_top=='Y' );	
	set_crossed( dlog, PG_ShowToolBar, (prefs.show_toolbar=='Y'||prefs.show_toolbar=='B') );	
	set_crossed( dlog, PG_BottomToolBar, prefs.show_toolbar=='B' );	
	set_crossed( dlog, PG_AutoLanguage, prefs.auto_language=='Y' );	
	set_tedinfo( dlog, PG_SelLanguage, prefs.selected_language );
	aut=prefs.auto_language;
	strcpy( lang, prefs.selected_language );
	set_crossed( dlog, PG_WindowBuffer, prefs.window_buffers=='Y' );	
	set_crossed( dlog, PG_DynamicExp, prefs.dynamic_expansion=='Y' );	
	set_crossed( dlog, PG_BubbleHelp, prefs.show_bubble_help=='Y' );
	set_crossed( dlog, PG_InfoStatus, prefs.use_info_status=='Y' );	
	set_crossed( dlog, PG_AutoExtract, (prefs.auto_extract=='Y'||prefs.auto_extract=='P') );
	set_crossed( dlog, PG_AutoPrompt, prefs.auto_extract=='P' );
	if (appl_find("BUBBLE  ") >= 0) {
		Button_Enable(PG_BubbleHelp); Touch_On(PG_BubbleHelp);
	} else {
	 	Button_Disable(PG_BubbleHelp); Touch_Off(PG_BubbleHelp);
	}
	dlog[PG_SelLanguage].ob_type=(512+G_BOXTEXT);	/* file selector for Language Select */
	Touch_On(PG_SelLanguage);
/*	dlog[PG_SelLanguage].ob_flags|=TOUCHEXIT; */

	if (handle_dialog(dlog, 0)==PG_OK) {
		get_crossed( dlog, PG_AutoTop, &prefs.auto_top );
		get_crossed( dlog, PG_ShowToolBar, &prefs.show_toolbar );
		get_crossed( dlog, PG_BottomToolBar, &bot );
		get_crossed( dlog, PG_AutoLanguage, &prefs.auto_language );	
		get_tedinfo( dlog, PG_SelLanguage, prefs.selected_language );
		get_crossed( dlog, PG_WindowBuffer, &prefs.window_buffers );	
		get_crossed( dlog, PG_DynamicExp, &prefs.dynamic_expansion );	
		get_crossed( dlog, PG_BubbleHelp, &prefs.show_bubble_help );
		get_crossed( dlog, PG_InfoStatus, &prefs.use_info_status );
		get_crossed( dlog, PG_AutoExtract, &prefs.auto_extract );
		get_crossed( dlog, PG_AutoPrompt, &prompt );
		if (prompt=='Y'&&prefs.auto_extract=='Y') { prefs.auto_extract='P'; }
		if (bot=='Y'&&prefs.show_toolbar=='Y') { prefs.show_toolbar='B'; }
		if (bar!=prefs.show_toolbar) {	/* if changed */
			for (c=1;c<WINDOWS_SIZE;c++) {
				if (windows[c].open&&windows[c].bar_index) {
					refresh_clear_window( windows[c].id ); }
				toolbar_height( -1 );	/* reset toolbar window */
			}
		}
		if ((strcmp(lang, prefs.selected_language)!=0)||(aut!=prefs.auto_language)) {
			initialize_resource( 1 );	/* new language resource */
		}
	}
}

void Edit_FirstLast_dialog(int current)
{
	OBJECT *dlog;
	long f,l,n;
	char first[10],last[10];

	if (current<0) { return; }
	
	rsrc_gaddr(R_TREE,NewsGroup_Edit,&dlog);
	f = group[current].first_msg;
	sprintf( first, "%ld", f );
	sprintf( last, "%ld", f+group[current].num_msgs-1 );
	set_tedinfo( dlog, NG_First, first );
	set_tedinfo( dlog, NG_Last, last );	
	if (handle_dialog(dlog, NG_First)==NG_OK) {
		get_tedinfo( dlog, NG_First, first );
		get_tedinfo( dlog, NG_Last, last );
		f = atol( first );
		l = atol( last );
		if (l<-1||f<0) { return; }	/* check valid numbers */
		if (l-f+1<0) { return; }	/* number msgs cannot be negative */
		group[current].first_msg = f;
		n = l - f + 1;
		if (n<0) { n = 0; }
		group[current].num_msgs = n;
	}
}

void Delete_Newsgroup_dialog(void)
{
	OBJECT *dlog;
	int c;
	
	rsrc_gaddr(R_TREE,News_Delete,&dlog);
	set_tedinfo( dlog, ND_NewsGroup, group[current_group].name );
	if (handle_dialog(dlog, 0)==ND_OK) {
		if (current_group<maximum_group) {
			for (c=current_group;c<maximum_group;c++) {
				memcpy( &group[c], &group[c+1], sizeof(group[0]) );
			}		
		}
		group[maximum_group--].name[0]='\0';	/* reduce maximum_group by 1 */
		if (current_group>maximum_group) { current_group = -1; }
 	}
}

void Add_Newsgroup_dialog(char *newsgroup)
{
	OBJECT *dlog;
	char groupname[60];
	int rc;
	
	rsrc_gaddr(R_TREE,News_Add,&dlog);
	if (strlen(newsgroup)>49) { newsgroup[49] = '\0'; }	/* truncate */
	set_tedinfo( dlog, NA_NewsGroup, newsgroup );
	if (handle_dialog(dlog, NA_NewsGroup)==NA_OK) {
		get_tedinfo( dlog, NA_NewsGroup, groupname  );
		if (ncn>=0) {
			rc = news_group( groupname );
			if (header[0]!='4') {
				maximum_group++;
				parse_group_header( maximum_group, header, (long)0, groupname );
				windows[1].num_lines=maximum_group;
			}
		} else {
			maximum_group++;
			strcpy(group[maximum_group].name, groupname );
			group[maximum_group].first_msg = 0;
			group[maximum_group].viewed = ' ';
			windows[1].num_lines=maximum_group;
		}
 	}
}

void Check_New_Groups_dialog(char *path, long fulltime)
{
	OBJECT *dlog;
	char the_time[8]="000000",the_date[8]="960701";
	char a_date[8];
	char ftime[8];
	int rc,to;

/*	fprintf( log, "New_Groups %ld\n", fulltime ); */
	if (fulltime!=-1) {
	/*	fprintf( log, "Time/date: %lx\n", fulltime ); */
	/*	ftunpk( fulltime, ftime ); */
		ftime[0]=(fulltime>>9)&127;
		ftime[1]=(fulltime>>5)&15;
		ftime[2]=fulltime&31;
	/*	ftime[3]=fulltime>>27; */
	/*	ftime[4]=(fulltime>>21)&63; */
	/*	ftime[5]=(fulltime>>16)&31; */
		stpdate( a_date, 1, ftime );
		strcpy( the_date, a_date );	/* copy date string */
		if (strlen(a_date)==7) { strcpy( the_date, a_date+1 ); }	/* right 6 digits only */
	/*	stptime( the_time, 1, &ftime[3] ); */
	}
	rsrc_gaddr(R_TREE,New_NewsGroup,&dlog);
	set_tedinfo( dlog, NN_Date, the_date );
	set_tedinfo( dlog, NN_Time, the_time );
	if (handle_dialog(dlog, NN_Date)==NN_OK) {
		get_tedinfo( dlog, NN_Date, the_date );
		get_tedinfo( dlog, NN_Time, the_time );

		if (ncn>=0) {
			handle_redraw_event();
			show_status( ErrMsg(EM_NewNewsGroups) );
			to = char_to;				/* char_to used in news_receive() */
			if (to<60) { char_to=60; }	/* if less than 60 seconds, increase */
			rc = news_newgroups( path, the_date, the_time );
			char_to = to;				/* reset default timeout */
			show_warning( ErrMsg(EM_SortNewsGroup) );
			grouplist_sort( 0, path );	/* sort the newgroups file */
			hide_status();
		}
 	}
}

void Retrieve_Full_Groups_dialog(char *path)
{
	OBJECT *dlog;
	int rc,to;

	rsrc_gaddr(R_TREE,FullList_Warning,&dlog);
	if (handle_dialog(dlog, 0)==FL_Continue) {

		if (ncn>=0) {
			show_status( ErrMsg(EM_FullNewsGroup) );
			to = char_to;				/* char_to used in news_receive() */
			if (to<60) { char_to=60; }	/* if less than 60 seconds, increase */
			rc = news_list( path );
			char_to = to;				/* reset default timeout */
			show_warning( ErrMsg(EM_SortNewsGroup) );
			grouplist_sort( 1, path );
			hide_status();
		}
 	}
}

void load_fullindex(char *filename)
{
	FILE *idx;
	char index[FMSIZE];
	long d;

	strcpy( index, filename );
	d=strlen(index)-3;
	strcpy( index+d, "IDX");

	idx = fopen( index, "rb");
	if (idx!=NULL) {
		fread( fullgroup_index, 4, FULLINDEX_SIZE, idx );
		fclose( idx );
	/*	fprintf( log, "Size= %ld, Incr= %ld\n", fullgroup_index[0], fullgroup_index[1] ); */
	}
}

void Show_Full_Groups_dialog(char *path)
{
	OBJECT *dlog;
	FILE *fid;
	int c;

	fid = fopen( path, "ra" );
	if (fid==NULL) {		/* NULL = file not found */
		Retrieve_Full_Groups_dialog( path );
	} else {				/* otherwise file exists */
		fclose( fid );
		rsrc_gaddr(R_TREE,FullList_Exists,&dlog);
		if (handle_dialog(dlog, 0)==FL_Retrieve) {
			Retrieve_Full_Groups_dialog( path );
 		}
	}
    if (fullgroup_index[0]==0) {	/* initialize and load index */
		for (c=1;c<FULLINDEX_SIZE;c++) { fullgroup_index[c]=0; }
		load_fullindex( path );
	}
}

void Search_Groups_dialog(char *path, int wx)
{
	OBJECT *dlog;
	FILE *fid;
	static char key[50]="";
	char starttop,buff[100],*where;

	rsrc_gaddr(R_TREE,Search_Group,&dlog);
	set_tedinfo( dlog, SG_SearchGroup, key );
	set_crossed( dlog, SG_StartTop, 0 );	
	if (handle_dialog(dlog, SG_SearchGroup)==SG_OK) {
		get_tedinfo( dlog, SG_SearchGroup, key );
		get_crossed( dlog, SG_StartTop, &starttop );
		fid = fopen( path, "ra" );
		if (fid!=NULL) {		/* NULL = file not found */
			if (starttop=='Y') {
				windows[wx].line_no=0;
			} else {
				position_group_text( fid, wx );
			}
			graf_mouse( BUSY_BEE, NULL );
			while (fgets( buff, sizeof(buff), fid )!=NULL) {
				if (stcpm( buff, key, &where )) {
					fclose( fid );
					break;
				}
				windows[wx].line_no++;
	 		}
			graf_mouse( ARROW, NULL );
			windows[wx].reread = 1;
			refresh_clear_window( windows[wx].id );
		}
	}
}

void Match_Groups_dialog(char *path, int wx)
{
	OBJECT *dlog;
	FILE *fid;
	int c;
	static char key[50]="";
	char starttop,buff[100],*where,*p;

	rsrc_gaddr(R_TREE,Match_Group,&dlog);
	set_tedinfo( dlog, MG_MatchGroup, key );
	set_crossed( dlog, MG_StartTop, 0 );	
	if (handle_dialog(dlog, MG_MatchGroup)==MG_OK) {
		get_tedinfo( dlog, MG_MatchGroup, key );
		get_crossed( dlog, MG_StartTop, &starttop );
		fid = fopen( path, "ra" );
		if (fid!=NULL) {		/* NULL = file not found */
			graf_mouse( BUSY_BEE, NULL );
			if (starttop=='Y') {
				windows[wx].line_no=0;
			} else {
				position_group_text( fid, wx );
			}
			if (wx==4) {
				for (c=0;c<FULLGROUPS_SIZE;c++) { fullgroups[c].x[0]='\0'; }
			} else {
				for (c=0;c<NEWGROUPS_SIZE;c++) { newgroups[c].x[0]='\0'; }
			}
			c=0;
			while (fgets( buff, sizeof(buff), fid )!=NULL) {
				windows[wx].line_no++;
				if (stcpm( buff, key, &where )) {
					p = strtok( buff, "\n" );	/* remove new_line */
					if (wx==4) {
						sprintf( fullgroups[c++].x, "%.49s", buff );
					} else {
						sprintf( newgroups[c++].x, "%.49s", buff );
					}
				}
				if (c>=FULLGROUPS_SIZE) { break; }
	 		}
			graf_mouse( ARROW, NULL );
			fclose( fid );
			windows[wx].reread = 0;
			refresh_clear_window( windows[wx].id );
		}
	}
}

int www_authenticate(void)
{
	OBJECT *dlog;
	char in[FMSIZE],out[FMSIZE],user[20],pass[20],buff[80];
	FILE *fid;
	int rc=0;

	rsrc_gaddr(R_TREE, WWW_Auth, &dlog);
	set_tedinfo( dlog, WWW_What, info.www_authenticate );
	set_tedinfo( dlog, WWW_User, "" );
	set_tedinfo( dlog, WWW_Pass, "" );
	if (handle_dialog(dlog, WWW_User)==WWW_OK) {
		get_tedinfo( dlog, WWW_User, user );
		get_tedinfo( dlog, WWW_Pass, pass );

		sprintf( in, "%s\\%s", prefs.work_path, "wwwauth.txt" );
		strcpy( out, in );		/* duplicate filename */
		if ((fid=fopen( in, "wa" ))!=NULL) {	/* write to file */
			fprintf( fid, "%s:%s", user, pass );
			fprintf( log, "WWW_Auth: %s:%s\n", user, pass );
			fclose( fid ); 
			base64_encode( out );		/* filename will be changed! */
			if ((fid=fopen( out, "ra" ))!=NULL) {	/* read encoded data */
				if (fgets( buff, sizeof(buff), fid )!=NULL) {
					strtok( buff, "\n" );
				/*	strcpy( info.www_authenticate, buff ); */
					strcpy( info.authorization, "Basic " );
					strcat( info.authorization, buff );
					fprintf( log, "WWW_Auth: %s\n", buff );
					rc = 1;		/* lets try it */
				} 
				fclose( fid );
				remove( out );
			}
			remove( in );		/* security! */
		}
	}
	return(rc); 
}

void build_followup_references(FILE *fid)
{
	char *p,*q;
	int cont=0;

	fprintf( fid, "References: " ); 
	if (overview[current_overview].refids[0]!='\0') {
		p = overview[current_overview].refids;	/* references from overview */

		if (memcmp(p,"parse",5)==0) {	/* parse headers from article? */
			parse_news_header( current_article );
			p = news_hdr.ref_id;	/* references from article */
		}
		q = p;	/* starting point */

		while (strlen( p ) > 180) {
			q = strchr( (q+1), '>' );	/* end of a reference */
			if (q==NULL) { fprintf( log, "Followup Reference Error\n" ); fflush(log); break; }
		/*	fprintf( log, "p=%P len=%ld q=%P\n", p, strlen(p), q ); */
			if ((q - p) > 160) {	/* reached 90% of limit? */
				*(q+1) = '\0';	/* terminate string */
				fprintf (fid, "%s\n\t", p);	/* print references and continuation */
				*(q+1) = ' ';	/* restore string */
				p = q+2;	/* continue, next '<' */
				cont++;
			}
			if (cont>9) { break; }	/* maximum of 9 continuation lines */
		}
		fprintf (fid, "%s ", p);	/* print remaining references */
	/*	fprintf( fid, "%s ", overview[current_overview].refids ); */
	}
	fprintf( fid, "%s\n", overview[current_overview].msgid ); 
}

void Post_Message_dialog(int followup, char *article)
{
	OBJECT *dlog;
	FILE *fid,*fid2;
	char postit,mailit,toself;
	char None,UUE,MIME;
	char newsgroup[48],author[48],subject[48];
	char buff[100],attach[FMSIZE];
	int result,copy=0,remove_temp=0;

	rsrc_gaddr(R_TREE,Post_Message,&dlog);
	set_crossed( dlog, PO_Postit, prefs.reply_via_posting=='Y' );	
	set_crossed( dlog, PO_Mailit, prefs.reply_via_email=='Y' );	
	set_crossed( dlog, PO_toSelf, prefs.copies_to_self=='Y' );
	set_crossed( dlog, PO_AppendSig, prefs.append_signature=='Y' );	
	set_tedinfo( dlog, PO_Attach, "" );
	set_tedinfo( dlog, PO_NewsGroup, group[current_group].name );
	if (followup) {
		set_tedinfo( dlog, PO_Author, overview[current_overview].author );
		strcpy( subject, overview[current_overview].subject );
		if (memcmp(subject, "Re: ", 4)!=0) { /* insert "Re: " if needed */
			sprintf( buff, "Re: %s", subject );
			strcpy( subject, buff );
		}
		set_tedinfo( dlog, PO_Subject, subject );
	} else {
		set_tedinfo( dlog, PO_Author, "" );
		set_tedinfo( dlog, PO_Subject, "" );
	}

	Button_Disable(PO_Send);		/* disable Send button */
	Button_Disable(PO_Queue);		/* disable Queue button */
	dlog[PO_Attach].ob_type=(256+G_BOXTEXT);	/* special file selector */
	set_crossed( dlog, PO_None, FALSE );		
	set_crossed( dlog, PO_UUE,  TRUE );			/* init to Encode: UUE */
	set_crossed( dlog, PO_MIME, FALSE );

	result = handle_dialog(dlog, PO_NewsGroup );
	Button_Enable(PO_Send);			/* enable Send button */
	Button_Enable(PO_Queue);		/* enable Queue button */
	Touch_Off(PO_Attach);			/* disable Attach field */

	if (result==PO_Edit) {
		handle_redraw_event();
		get_crossed( dlog, PO_Postit, &postit );
		get_crossed( dlog, PO_Mailit, &mailit );
		get_crossed( dlog, PO_toSelf, &toself );
		get_crossed( dlog, PO_AppendSig, &prefs.append_signature );	
		get_tedinfo( dlog, PO_NewsGroup, newsgroup );
		get_tedinfo( dlog, PO_Author, author );
		get_tedinfo( dlog, PO_Subject, subject );
		get_tedinfo( dlog, PO_Attach, attach );
		get_crossed( dlog, PO_None, &None );	
		get_crossed( dlog, PO_UUE, &UUE );	
		get_crossed( dlog, PO_MIME, &MIME );	

		fid = fopen( article, "wa" );
		if (fid!=NULL) {
			fprintf( fid, "Newsgroups: %s\n", newsgroup ); 
			fprintf( fid, "From: %s (%s)\n", prefs.email_address, prefs.full_name ); 
			fprintf( fid, "Organization: %s\n", prefs.organization ); 
			if (followup) {
				build_followup_references( fid );	/* create References line(s) */
			}
			fprintf( fid, "Subject: %s\n", subject ); 
			fprintf( fid, "X-Newsreader: NEWSie Version %.4s (Atari)\n", VERSION ); 
			if (MIME=='Y') {
				fprintf( fid, "MIME-Version: 1.0\n" ); 
				fprintf( fid, "Content-Type: multipart/mixed; boundary=boundary\n" ); 
				fprintf( fid, "\n--boundary\n" );
			}
			fprintf( fid, "\n" ); 
			if (followup) {
			/*	fprintf( fid, "In article %s,\n", overview[current_overview].msgid ); */ 
			/*	fprintf( fid, " %s wrote:\n", overview[current_overview].author ); */
				fprintf( fid, "On %.21s, %s wrote:\n", overview[current_overview].datetime, overview[current_overview].author ); 
				fid2 = fopen( current_article, "ra" );
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
			if (attach[0]!='\0') {	/* attachment selected */
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
			}
			if (MIME=='Y') { fprintf( fid, "--boundary--\n" ); }
			fclose( fid );
		}
		if (call_editor( article, prefs.external_editor )>=0) {
		/*	handle_redraw_event(); */ /* problem for ST's */
			/* redisplay dialog for Send or Cancel */
			rsrc_gaddr(R_TREE,Post_Message,&dlog);
			set_crossed( dlog, PO_Postit, postit=='Y' );	
			set_crossed( dlog, PO_Mailit, mailit=='Y' );	
			set_crossed( dlog, PO_toSelf, toself=='Y' );
			set_crossed( dlog, PO_AppendSig, prefs.append_signature=='Y' );	
			set_tedinfo( dlog, PO_NewsGroup, newsgroup );
			set_tedinfo( dlog, PO_Author, author );
			set_tedinfo( dlog, PO_Subject, subject );
			set_tedinfo( dlog, PO_Attach, attach );
			Button_Disable(PO_Edit);				/* disable Edit */
			dlog[PO_Edit].ob_flags&=~DEFAULT;		/* not Default	*/
			Touch_Off(PO_Attach);					/* disable Attach */

			result = handle_dialog(dlog, PO_NewsGroup );

			if (result==PO_Send) {
				get_crossed( dlog, PO_AppendSig, &prefs.append_signature );	
				handle_redraw_event();
				result=try_news( article );	/* 0=posted, !0=some error */
			/*	if (result) { add_to_postbox( article, newsgroup, subject, author, !result ); } */
				add_to_postbox( article, newsgroup, subject, author, !result );
			}
			if (result==PO_Queue) {
				get_crossed( dlog, PO_AppendSig, &prefs.append_signature );	
				handle_redraw_event();
				add_to_postbox( article, newsgroup, subject, author, FALSE );
			}
			Button_Enable(PO_Edit);					/* enable Edit button */
			dlog[PO_Edit].ob_flags|=DEFAULT;		/* reset Default*/
		}
	}
	Touch_On(PO_Attach);							/* enable Attach */
}

void add_to_postbox(char *filename, char *newsgroup, char *subject, char *author, int result)
{
	FILE *fid;
	char dirname[FMSIZE],newfile[FMSIZE];
	char temp[40],datetime[30],status[]=" Q ";
	char buff[300];
	struct tm *tp;
	time_t t;
	int lines,next_num=0;
	struct FILEINFO info;

	if (result) { status[1]='S'; }	/* 1=sent, 0=queue */

	sprintf( dirname, "%s\\%s", prefs.work_path, "posts" );
	if (dfind( &info, dirname, FA_SUBDIR )) {	/* if dir does not exist */
		if (mkdir( dirname, S_IWRITE|S_IREAD )) {	/* if cannot make dir */
			strcpy( dirname, prefs.work_path );	/* just use main path */
		}
	}
	next_num = get_unique_filename(next_num, "post", dirname );
	sprintf( newfile, "%s\\post%04d.txt", dirname, next_num );
	lines = copy_file(newfile, filename);

	time(&t);
	tp = localtime(&t);
	strcpy( temp, asctime(tp) );
	strtok( temp, "\n" );
	sprintf( datetime, "%-.21s", temp+4 );

	sprintf( buff, "%s\t%s\t%s\t%s\t%s\t%s\t%d\n",
		status, newsgroup, subject, author, datetime, newfile, lines );

	sprintf( dirname, "%s\\%s", prefs.work_path, "posts.pbx" );
	if ((strcmp(current_mailbox,dirname)==0)&&(windows[6].open)) {
		if (mailbox_full(maximum_mail+1, result, "PostBox")) { return; }
		parse_mailbox_header( ++maximum_mail, buff );
		refresh_clear_window( windows[6].id );
	} else {
		lines = (int16)count_lines( dirname );
		if (mailbox_full(lines, result, "PostBox")) { return; }
		fid = fopen( dirname, "aa" );		/* append to postbox */
		if (fid!=NULL) {
			fputs( buff, fid );
			fclose( fid );
		}
	}
}

#if (0)
void send_queued_articles(void)
{
	char postbox[FMSIZE];
	char buff[300];
	char *status, *newsgroup, *subject, *author, *datetime, *filename, *lines;
	int tried=FALSE;
	FILE *fid;

	sprintf( postbox, "%s\\%s", prefs.work_path, "posts.pbx" );
	if ((strcmp(current_mailbox,postbox)==0)&&(windows[6].open)) {
		unload_mailbox( postbox );
	}
	if ((fid=fopen( postbox, "ra" ))!=NULL) {
		while (fgets(buff, sizeof(buff), fid )!=NULL) {
			status = strtoka( buff, '\t' );
			newsgroup = strtoka( NULL, '\t' );
			subject = strtoka( NULL, '\t' );
			author = strtoka( NULL, '\t' );
			datetime = strtoka( NULL, '\t' );
			filename = strtoka( NULL, '\t' );
			lines = strtoka( NULL, '\t' );

			if (status[1]=='Q') {	/* Queued? */
				show_warning( ErrMsg(EM_PostQueued) ); /* Post Queued Articles... */
				if (try_news( filename )) {
					remove( filename );
					tried = TRUE;
				}
			}
		}
		fclose( fid );
		if (tried) { remove( postbox ); }
	}
}
#endif

void send_queued_articles(void)
{
	char filename[FMSIZE],postbox[FMSIZE];
	int rc,c,tried=FALSE;

	unload_mailbox( current_mailbox );
	sprintf( postbox, "%s\\%s", prefs.work_path, "posts.pbx" );

	c = (int16)count_lines( postbox );
	expand_mailbox( c );	/* expand mailbox to fit */
	load_mailbox( postbox );

	for (c=0;c<maximum_mail+1;c++) {
		if (mailbox[c].status[1]=='Q') {	/* Queued? */
			show_warning( ErrMsg(EM_PostQueued) ); /* Post Queued Articles... */
			strcpy( filename, mailbox[c].filename );
			rc = try_news( filename );
			if (rc==4) { break; }	/* escape key pressed */
		/*	if (rc==2) { break; }	/* timeout while sending */
			if (memcmp( header, "240", 3)==0) {	/* article posted? */
				mailbox[c].status[1]='S';
				tried = TRUE;
				if (prefs.delete_queued_mail=='Y') { /* sent, now delete */
					mailbox[c].status[1]='D';
				}
			}
		}
	}
	unload_mailbox( current_mailbox );
}

int get_news_auth( int req, char *userid, char *password )
{
	int rc=1;

	if (req&1) {
		strcpy( userid, prefs.email_address );
		strtok( userid, "@" );
	}
	if (req&2) {
		rc = get_password_dialog( password );
	}
	return(rc);
}

void check_pref_paths(void)
{
	int failed=0;

	if (chdir( prefs.work_path )!=0) { failed++; }
	if (chdir( prefs.mail_path )!=0) { failed++; }
	if (chdir( prefs.offline_path )!=0) { failed++; }
	if (chdir( prefs.ftp_download_path)!=0) {failed++; }
	chdir( program_path );
	if (failed) { Path_Preferences_dialog(); }

	failed=0;
	if (chdir( prefs.browser_cache_path )!=0) { failed++; }
	chdir( program_path );
	if (failed) { Browser_Preferences_dialog(); }

}

void check_current_preferences(void)
{
	char prefname[FMSIZE];

	if (memcmp(prefs.last_version, VERSION, 4)!=0) {
		if (log) {
			fprintf( log, "Preferences were not current\n" ); fflush(log);
		}
		strcpy( prefname, current_preferences );
		save_preferences( prefname );
		load_preferences( prefname );
	}
}

void load_preferences(char *filename)
{
	FILE *fid;
	char buff[300],temp[80];
	char *tag, *equal, *parm;
	char select[FMSIZE];
	char dirname[FMSIZE],path[FMSIZE];
	int button,c;

	strcpy( dirname, filename );

	if (dirname[0]!='\0') {		/* if not null string */
		if ((fid = fopen( dirname, "ra" ))==NULL) { dirname[0]='\0'; }	/* non-existant file */
		else { fclose( fid ); }
	}
	if (dirname[0]=='\0') {		/* if null string */
		sprintf( dirname, "%s\\", program_path );
		c = filelist_popup( dirname, "*.inf" );
		if (c==0) { return; }	/* cancel */
		if (c==1) {
			strcpy( select, "prefs.inf" );
			sprintf( dirname, "%s\\%s", program_path, "*.inf" );	
			fsel_exinput( dirname, select, &button, ErrMsg(EM_LoadPrefs) );	/* Load Preferences */
			if (button) {
				stcgfp( path, dirname );
				sprintf( dirname, "%s\\%s", path, select );
				rebuild_attach_list( dirname, "inf" );	/* update info file list */
			/*	fprintf( log, "dir %s, sel %s, filename %s\n", path, select, dirname ); */
			} else { return; }	/* cancel */
		}
	} 

	if (strcmp( current_preferences, dirname )!=0) { strcpy( current_preferences, dirname ); }
	fid = fopen( dirname, "aa+" );
	while (fgets(buff, sizeof(buff), fid )!=NULL) {
		temp[0] = '\0';
		tag = strtok( buff, "\t " );
		equal = strtok( NULL, "\t " );
		parm = strtok( NULL, "\n\t" );
		if (parm==NULL) { parm = temp; }

		if (strcmp(tag,"last_version")==0) {
			strcpy(prefs.last_version, parm);
		}
		if (strcmp(tag,"news_server")==0) {
			strcpy(prefs.news_server, parm);
		}
		if (strcmp(tag,"mail_server")==0) {
			strcpy(prefs.mail_server, parm);
		}
		if (strcmp(tag,"pop_server")==0) {
			if (parm[0]<'0') { strcpy( parm, prefs.mail_server ); }
			strcpy(prefs.pop_server, parm);
		}
		if (strcmp(tag,"connect_startup")==0) {
			prefs.connect_startup = parm[0];
		}
		if (strcmp(tag,"subscribe_startup")==0) {
			prefs.subscribe_startup = parm[0];
		}
		if (strcmp(tag,"maximum_timeout")==0) {
			strcpy(prefs.to_maximum, parm );
			max_to = atoi( prefs.to_maximum );
		}
		if (strcmp(tag,"from_last_character")==0) {
			strcpy(prefs.to_last_char, parm );
			char_to = atoi( prefs.to_last_char );
		}
 		if (strcmp(tag,"full_name")==0)	{
			strcpy(prefs.full_name, parm);
		}
		if (strcmp(tag,"organization")==0) {
			strcpy(prefs.organization, parm);
		}
		if (strcmp(tag,"account_name")==0) {
			strcpy(prefs.account_name, parm);
		}
		if (strcmp(tag,"email_address")==0) {
			strcpy(prefs.email_address, parm);
		}
		if (strcmp(tag,"show_authors")==0) {
			prefs.show_authors = parm[0];
		}
		if (strcmp(tag,"show_headers")==0) {
			prefs.show_headers = parm[0];
		}
		if (strcmp(tag,"collapse_threads")==0) {
			prefs.collapse_threads = parm[0];
		}
		if (strcmp(tag,"create_threads")==0) {
			prefs.create_threads = parm[0];
		}
		if (strcmp(tag,"allow_key_nav")==0) {
			prefs.allow_kbd_nav = parm[0];
		}
		if (strcmp(tag,"offline_test")==0) {
			prefs.offline_test = parm[0];
		}	
		if (strcmp(tag,"show_status")==0) {
			prefs.show_status = parm[0];
		}	
		if (strcmp(tag,"use_ext_viewer")==0) {
			prefs.use_ext_viewer = parm[0];
		}
		if (strcmp(tag,"erase_articles")==0) {
			prefs.erase_articles = parm[0];
		}	
		if (strcmp(tag,"max_articles")==0) {
			if (parm[0]<'0') { strcpy( parm, "200" ); }
			strcpy(prefs.max_articles, parm);
		}
		if (strcmp(tag,"recent_articles")==0) {
			if (parm[0]<'0') { strcpy( parm, "1000" ); }
			if (strcmp(parm,"9999")>0) { parm = "1000"; }
			strcpy(prefs.recent_articles, parm);
		}
		if (strcmp(tag,"reply_via_posting")==0) {
			prefs.reply_via_posting = parm[0];
		}
		if (strcmp(tag,"reply_via_email")==0) {
			prefs.reply_via_email = parm[0];
		}
		if (strcmp(tag,"append_signature")==0) {
			prefs.append_signature = parm[0];
		}
		if (strcmp(tag,"copies_to_self")==0) {
			prefs.copies_to_self = parm[0];
		}
		if (strcmp(tag,"quote_string")==0) {
			strcpy(prefs.quote_string, parm);
		}
		if (strcmp(tag,"signature_file")==0) {
			strcpy(prefs.signature_file, parm);
		}
		if (strcmp(tag,"work_path")==0) {
			if(parm[0]=='\0') { strcpy( parm, program_path ); }
			strcpy(prefs.work_path, parm);
		}
		if (strcmp(tag,"mail_path")==0) {
			if(parm[0]=='\0') { strcpy( parm, prefs.work_path ); }
			strcpy(prefs.mail_path, parm);
		}
		if (strcmp(tag,"external_viewer")==0) {
			strcpy(prefs.external_viewer, parm);
		}
		if (strcmp(tag,"external_editor")==0) {
			strcpy(prefs.external_editor, parm);
		}
		if (strcmp(tag,"news_font")==0) {
			strcpy(prefs.news_font, parm);
		}
		if (strcmp(tag,"news_font_size")==0) {
			if(parm[0]=='\0') { strcpy( parm, "8" ); }
			strcpy(prefs.news_font_size, parm);
		}
		if (strcmp(tag,"newsgroup_font")==0) {
			strcpy(prefs.newsgroup_font, parm);
		}
		if (strcmp(tag,"newsgroup_font_size")==0) {
			if(parm[0]=='\0') { strcpy( parm, "9" ); }
			strcpy(prefs.newsgroup_font_size, parm);
		}
		if (strcmp(tag,"overview_font")==0) {
			strcpy(prefs.overview_font, parm);
		}
		if (strcmp(tag,"overview_font_size")==0) {
			if(parm[0]=='\0') { strcpy( parm, "8" ); }
			strcpy(prefs.overview_font_size, parm);
		}
		if (strcmp(tag,"log_data")==0) {
			prefs.log_data = parm[0];
			log_data = parm[0];
		}
		if (strcmp(tag,"log_commands")==0) {
			prefs.log_commands = parm[0];
			log_cmd = parm[0];
		}
		if (strcmp(tag,"log_responses")==0) {
			prefs.log_responses = parm[0];
			log_resp = parm[0];
		}
		if (strcmp(tag,"log_mask_pswds")==0) {
			prefs.log_mask_pswds = parm[0];
			log_mask_pswds = parm[0];
		}
		if (strcmp(tag,"delete_mail_from_server")==0) {
			prefs.delete_mail_from_server = parm[0];
		}
		if (strcmp(tag,"use_saved_password")==0) {
			prefs.use_saved_password = parm[0];
		}
		if (strcmp(tag,"password")==0) {
			strcpy(prefs.password, parm );
		}
		if (strcmp(tag,"delete_queued_mail")==0) {
			prefs.delete_queued_mail = parm[0];
		}
		if (strcmp(tag,"send_queued_at_check")==0) {
			prefs.send_queued_at_check = parm[0];
		}
		if (strcmp(tag,"mail_directories")==0) {
			prefs.mail_directories = parm[0];
		}
		if (strcmp(tag,"offline_path")==0) {
			if(parm[0]=='\0') { strcpy( parm, prefs.work_path ); }
			strcpy(prefs.offline_path, parm);
		}
		if (strcmp(tag,"windows")==0) {
			if (parm[0]!='\0') { get_window_prefs( parm ); }
		}
		if (strcmp(tag,"ftp_send_help")==0) {
			prefs.ftp_send_help = parm[0];
			ftp_send_help  = prefs.ftp_send_help;
		}
		if (strcmp(tag,"ftp_send_alloc")==0) {
			prefs.ftp_send_alloc = parm[0];
			ftp_send_alloc = prefs.ftp_send_alloc;
		}
		if (strcmp(tag,"ftp_save_last_dir")==0) {
			prefs.ftp_save_last_dir = parm[0];
		}
		if (strcmp(tag,"ftp_use_port")==0) {
			prefs.ftp_use_port = parm[0];
			ftp_use_port = prefs.ftp_use_port;
		}
		if (strcmp(tag,"ftp_savelower")==0) {
			if (parm[0]!='N') { parm[0]='Y'; }
			prefs.ftp_savelower = parm[0];
		}
		if (strcmp(tag,"auto_top_windows")==0) {
			prefs.auto_top = parm[0];
		}
		if (strcmp(tag,"show_toolbar")==0) {
			prefs.show_toolbar = parm[0];
		}
		if (strcmp(tag,"auto_language")==0) {
			prefs.auto_language = parm[0];
		}
		if (strcmp(tag,"selected_language")==0) {
			strcpy(prefs.selected_language, parm);
		}
		if (strcmp(tag,"window_buffers")==0) {
			prefs.window_buffers = parm[0];
		}
		if (strcmp(tag,"dynamic_expansion")==0) {
			prefs.dynamic_expansion = parm[0];
		}
		if (strcmp(tag,"show_bubble_help")==0) {
			prefs.show_bubble_help = parm[0];
		}
		if (strcmp(tag,"ftp_download_path")==0) {
			if(parm[0]=='\0') { strcpy( parm, prefs.work_path ); }
			strcpy(prefs.ftp_download_path, parm);
		}
		if (strcmp(tag,"browser_cache_path")==0) {
			if(parm[0]=='\0') { strcpy( parm, prefs.work_path ); }
			strcpy(prefs.browser_cache_path, parm);
		}
		if (strcmp(tag,"browser_home")==0) {
			strcpy(prefs.browser_home, parm);
		}
		if (strcmp(tag,"browser_hotlist")==0) {
			strcpy(prefs.browser_hotlist, parm);
		}
		if (strcmp(tag,"registration_number")==0) {
			if (!valid_registration_number()) {
				strcpy(prefs.registration_number, parm);
			}
		}
		if (strcmp(tag,"browser_history")==0) {
			prefs.browser_history = parm[0];
		}
		if (strcmp(tag,"auto_extract")==0) {
			prefs.auto_extract = parm[0];
		}
		if (strcmp(tag,"use_info_status")==0) {
			prefs.use_info_status = parm[0];
		}
		if (strcmp(tag,"mime_headers")==0) {
			prefs.mime_headers = parm[0];
		}
		if (strcmp(tag,"experimental")==0) {
			strncpy(prefs.experimental, parm, 19);
		}
	}
	fclose( fid );
	check_pref_paths();				/* validate paths still exist */
	check_current_preferences();	/* ensure preference versions are current */
}

void get_window_prefs(char *parm)
{
	char *p;
	int c;

	p=strtoka( parm, ' ' );
	for (c=0;c<WINDOWS_SIZE;c++) {
		sscanf(p, "%*c%d%*c%d%*c%d%*c%d", &windows[c].x, &windows[c].y, &windows[c].w, &windows[c].h );
		p=strtoka( NULL, ' ' );
	}
	
}
void save_preferences(char *filename)
{
	FILE *fid;
	char select[FMSIZE];
	char dirname[FMSIZE],path[FMSIZE];
	int button,c;

	strcpy( dirname, filename );
	if (dirname[0]=='\0') {		/* if null string */
		sprintf( dirname, "%s\\", program_path );
		c = filelist_popup( dirname, "*.inf" );
		if (c==0) { return; }	/* cancel */
		if (c==1) {
			strcpy( select, "prefs.inf" );
			sprintf( dirname, "%s\\%s", program_path, "*.inf" );
			fsel_exinput( dirname, select, &button, ErrMsg(EM_SavePrefs) );	/* Save Preferences */
			if (button) {
				stcgfp( path, dirname );
				sprintf( dirname, "%s\\%s", path, select );
				rebuild_attach_list( dirname, "inf" );	/* update info file list */
			/*	fprintf( log, "dir %s, sel %s, filename %s\n", path, select, dirname ); */
			} else { return; }	/* cancel */
		}
	}

	if (strcmp( current_preferences, dirname )!=0) { strcpy( current_preferences, dirname ); }
	fid = fopen( dirname, "wa" );
	fprintf(fid, "%s\t=\t%.5s\n", "last_version", VERSION );
	fprintf(fid, "%s\t=\t%s\n", "news_server", prefs.news_server );
	fprintf(fid, "%s\t=\t%s\n", "mail_server", prefs.mail_server );
	fprintf(fid, "%s\t=\t%s\n", "pop_server", prefs.pop_server );
	fprintf(fid, "%s\t=\t%c\n", "connect_startup", prefs.connect_startup );
	fprintf(fid, "%s\t=\t%c\n", "subscribe_startup", prefs.subscribe_startup );
	fprintf(fid, "%s\t=\t%s\n", "maximum_timeout", prefs.to_maximum );
	fprintf(fid, "%s\t=\t%s\n", "from_last_character", prefs.to_last_char );
	fprintf(fid, "%s\t=\t%s\n", "full_name", prefs.full_name );
	fprintf(fid, "%s\t=\t%s\n", "organization", prefs.organization );
	fprintf(fid, "%s\t=\t%s\n", "account_name", prefs.account_name );
	fprintf(fid, "%s\t=\t%s\n", "email_address", prefs.email_address );
	fprintf(fid, "%s\t=\t%c\n", "show_authors", prefs.show_authors );
	fprintf(fid, "%s\t=\t%c\n", "show_headers", prefs.show_headers );
	fprintf(fid, "%s\t=\t%c\n", "collapse_threads", prefs.collapse_threads );
	fprintf(fid, "%s\t=\t%c\n", "create_threads", prefs.create_threads );
	fprintf(fid, "%s\t=\t%c\n", "allow_key_nav", prefs.allow_kbd_nav );
	fprintf(fid, "%s\t=\t%c\n", "offline_test", prefs.offline_test );
	fprintf(fid, "%s\t=\t%c\n", "show_status", prefs.show_status );
	fprintf(fid, "%s\t=\t%c\n", "use_ext_viewer", prefs.use_ext_viewer );
	fprintf(fid, "%s\t=\t%c\n", "erase_articles", prefs.erase_articles );
	fprintf(fid, "%s\t=\t%s\n", "max_articles", prefs.max_articles );
	fprintf(fid, "%s\t=\t%s\n", "recent_articles", prefs.recent_articles );
	fprintf(fid, "%s\t=\t%c\n", "reply_via_posting", prefs.reply_via_posting );
	fprintf(fid, "%s\t=\t%c\n", "reply_via_email", prefs.reply_via_email );
	fprintf(fid, "%s\t=\t%c\n", "append_signature", prefs.append_signature );
	fprintf(fid, "%s\t=\t%c\n", "copies_to_self", prefs.copies_to_self );
	fprintf(fid, "%s\t=\t%s\n", "quote_string", prefs.quote_string );
	fprintf(fid, "%s\t=\t%s\n", "signature_file", prefs.signature_file );
	fprintf(fid, "%s\t=\t%s\n", "work_path", prefs.work_path );
	fprintf(fid, "%s\t=\t%s\n", "mail_path", prefs.mail_path );
	fprintf(fid, "%s\t=\t%s\n", "external_viewer", prefs.external_viewer );
	fprintf(fid, "%s\t=\t%s\n", "external_editor", prefs.external_editor );
	fprintf(fid, "%s\t=\t%s\n", "news_font", prefs.news_font );
	fprintf(fid, "%s\t=\t%s\n", "news_font_size", prefs.news_font_size );
	fprintf(fid, "%s\t=\t%s\n", "newsgroup_font", prefs.newsgroup_font );
	fprintf(fid, "%s\t=\t%s\n", "newsgroup_font_size", prefs.newsgroup_font_size );
	fprintf(fid, "%s\t=\t%s\n", "overview_font", prefs.overview_font );
	fprintf(fid, "%s\t=\t%s\n", "overview_font_size", prefs.overview_font_size );
	fprintf(fid, "%s\t=\t%c\n", "log_data", prefs.log_data );
	fprintf(fid, "%s\t=\t%c\n", "log_commands", prefs.log_commands );
	fprintf(fid, "%s\t=\t%c\n", "log_responses", prefs.log_responses );
	fprintf(fid, "%s\t=\t%c\n", "log_mask_pswds", prefs.log_mask_pswds );
	fprintf(fid, "%s\t=\t%c\n", "delete_mail_from_server", prefs.delete_mail_from_server );
	fprintf(fid, "%s\t=\t%c\n", "use_saved_password", prefs.use_saved_password );
	fprintf(fid, "%s\t=\t%s\n", "password", prefs.password );
	fprintf(fid, "%s\t=\t%c\n", "delete_queued_mail", prefs.delete_queued_mail );
	fprintf(fid, "%s\t=\t%c\n", "send_queued_at_check", prefs.send_queued_at_check );
	fprintf(fid, "%s\t=\t%c\n", "mail_directories", prefs.mail_directories );
	fprintf(fid, "%s\t=\t%s\n", "offline_path", prefs.offline_path );
	fprintf(fid, "%s\t=\t%c\n", "auto_top_windows", prefs.auto_top );
	fprintf(fid, "%s\t=\t%c\n", "show_toolbar", prefs.show_toolbar );
	fprintf(fid, "%s\t=\t%c\n", "ftp_send_help", prefs.ftp_send_help );
	fprintf(fid, "%s\t=\t%c\n", "ftp_send_alloc", prefs.ftp_send_alloc );
	fprintf(fid, "%s\t=\t%c\n", "ftp_use_port", prefs.ftp_use_port );
	fprintf(fid, "%s\t=\t%c\n", "ftp_save_last_dir", prefs.ftp_save_last_dir );
	fprintf(fid, "%s\t=\t%c\n", "ftp_savelower", prefs.ftp_savelower );
	fprintf(fid, "%s\t=\t%c\n", "auto_language", prefs.auto_language );
	fprintf(fid, "%s\t=\t%s\n", "selected_language", prefs.selected_language );
	fprintf(fid, "%s\t=\t%c\n", "window_buffers", prefs.window_buffers );
	fprintf(fid, "%s\t=\t%c\n", "dynamic_expansion", prefs.dynamic_expansion );
	fprintf(fid, "%s\t=\t%c\n", "show_bubble_help", prefs.show_bubble_help );
	fprintf(fid, "%s\t=\t%s\n", "registration_number", prefs.registration_number );
	fprintf(fid, "%s\t=\t%s\n", "ftp_download_path", prefs.ftp_download_path );
	fprintf(fid, "%s\t=\t%s\n", "browser_cache_path", prefs.browser_cache_path );
	fprintf(fid, "%s\t=\t%s\n", "browser_home", prefs.browser_home );
	fprintf(fid, "%s\t=\t%s\n", "browser_hotlist", prefs.browser_hotlist );
	fprintf(fid, "%s\t=\t%c\n", "browser_history", prefs.browser_history );
	fprintf(fid, "%s\t=\t%c\n", "auto_extract", prefs.auto_extract );
	fprintf(fid, "%s\t=\t%c\n", "use_info_status", prefs.use_info_status );
	fprintf(fid, "%s\t=\t%c\n", "mime_headers", prefs.mime_headers );
	fprintf(fid, "%s\t=\t%s\n", "experimental", prefs.experimental );
	save_window_prefs( fid );
	fclose( fid );
}

void save_window_prefs(FILE *fid)
{
	int c;

	fprintf(fid, "%s\t=\t", "windows" );
	for (c=0;c<WINDOWS_SIZE;c++) {
		if (windows[c].full) {
			fprintf(fid, "(%d,%d,%d,%d) ", screenx, screeny, screenw, screenh );
		} else {
			fprintf(fid, "(%d,%d,%d,%d) ", windows[c].x, windows[c].y, windows[c].w, windows[c].h );
		}
	}
	fprintf(fid, "\n" );
}

double exp(double x);

int nxcmp( const void *a, const void *b )
{
	char percent[20];
	long pct;

	sort_swap++;
	if (clock()>sort_clock) {
		handle_redraw_event();
		pct = sort_swap/sort_number;
		if (pct>100) { pct = 100; }
		sprintf( percent, "%ld%%", pct );  
		status_text_nolog( percent );
		spinner();			/* spin the mouse */
	}
	return ( strcmp( *(const char **)a, *(const char **)b ) );	/* inputs are pointers to char strings */
}

void new_sortfile(char *input, char *output )
{
	struct FILEINFO finfo;
	char far **grp,**tmp;
	char far *file,*p;
	FILE *infile,*outfile,*idx;
	char temp[80],*alert,index[FMSIZE];
	size_t smax=0,slen,c=0,d=0,opos,incr=500;

	if (dfind(&finfo, input, 0)) { return; }	/* file does not exist */
	/* allocate space for entire file and read file into area. (i.e 1.2Meg) */
	if ((file = malloc( finfo.size+1 ))!=NULL) {
		if ((infile = fopen( input, "ra" ))!=NULL) {
			status_text( ErrMsg(EM_SortReadFile) );	/* "Reading file..." */
			memset( file, 0, finfo.size+1 );
			fread( file, finfo.size, 1, infile ); 
			fclose( infile );
		} else { free( file ); return; }	/* could not open file */
		fprintf( log, "Read in File\n" );
	} else /* if (file==NULL) */ {
		rsrc_gaddr(R_STRING,Insuff_Memory,&alert); /* Insufficient Memory for ... */
		sprintf( temp, alert, "Sort" );
		form_alert( 1, temp );
		return;		/* unable to sort */
	}

	p = file;
	while ((p=strchr(p, '\n'))!=NULL) { d++; p++; }
	fprintf( log, "Found %ld lines\n", d );

	/* allocate space for list of newsgroups, each is far pointer to a group name */
	if ((grp = calloc( sizeof(size_t), d+10))!=NULL) { 	/* 50000 = 200K */
	/*	keep address of every line start (i.e. after crlf) in *grp array. */
		fprintf( log, "Allocated %ld indexes\n", d+10 );
		p = file;
		tmp = grp;
		*tmp = p;
		if (*p!='.') { c++; }	/* count first newsgroup */
		while ((p=strchr(p, '\n'))!=NULL) {
			*p = ' ';	/* change newline to a space */
			if (*(p+1)=='.') { break; }
			++tmp;	*tmp = p+1; c++;		
		}
		fprintf( log, "Found %ld newsgroups in file\n", c );
	/*	scan thru file and change spaces to nulls. */
		fprintf( log, "Converting spaces to Nulls\n" );
		p = file;
		while ((p=strchr(p, ' '))!=NULL) { *p='\0'; p++; }

	/*	sort grp array */
		fprintf( log, "Sorting newsgroups\n" );
			handle_redraw_event();
		/*	lines=c; */
			fprintf( log, "Sorting %ld entries\n", c );
			sort_swap=0;
			for (d=4;d<15;d++) {	/* approximate ln(c) via exp() */
				if (exp((double)d)>c) { break; }
			}
		/*	fprintf( log, "Approx ln(%ld) = %ld\n", c, d ); */
			sort_number=(c*d)/100;
			sort_clock=clock();
			status_text( ErrMsg(EM_SortStart) );	/* "Starting Sort..." */
			qsort( grp, c, sizeof(size_t), nxcmp );
			status_text( ErrMsg(EM_SortWriteFile) );	/* "Writing Sorted file..." */

	/*	unload file indexed by grp array */
			/* produce index file and put maximum size and increment */
			strcpy( index, output );
			d=strlen(index)-3;
			strcpy( index+d, "idx");
		/*	fprintf( log, "Index file: %s\n", index ); */
			idx = fopen( index, "wb");
			fwrite( &c, 4, 1, idx );
			fwrite( &incr, 4, 1, idx );
		if ((outfile = fopen( output, "wa"))!=NULL) {
			fprintf( log, "Unloading %ld newsgroups\n", c );
		 	tmp = grp;
		/*	while (tmp) { fprintf( outfile, "%s\n", *tmp ); tmp++; } */
			for (d=0;d<c;d++) {
				if ((d%incr)==0) {
					fgetpos( outfile, &opos ); 
					fwrite( &opos, 4, 1, idx );
				}
				slen = strlen( *tmp );
				if (slen>smax) { smax=slen; }
				if (slen>79) {
					fprintf( log, "::%s\n", *tmp );
				} else {
					fprintf( outfile, "%s\n", *tmp );
				}
				tmp++;
			}
			fprintf( log, "Maximum newsgroup name was %ld bytes\n", smax );
			fclose( outfile );
			fclose( idx );
		}
		free( grp );
	} else /* if (grp==NULL) */ {
		rsrc_gaddr(R_STRING,Insuff_Memory,&alert); /* Insufficient Memory for ... */
		sprintf( temp, alert, "Sort" );
		form_alert( 1, temp );
	}
	free( file );
}

void grouplist_sort(int full, char *path)
{
	char index[FMSIZE];
	size_t d;

	strcpy( index, path );
	d=strlen(index)-3;
	strcpy( index+d, "idx");
	remove(index );		/* delete .IDX file */

	if (full) {
		fullgroup_index[0]=0;
		new_sortfile( path, path /*"D:\\FULLGRP.OUT"*/ );
	} else {
		new_sortfile( path, path /*"D:\\NEWGRP.OUT"*/ );
	}
}

/* end of DIALOGS.C */

