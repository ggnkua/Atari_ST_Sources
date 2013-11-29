/* Expansion of newsaes.c requires separate module.
 * routines moved to this module include:
 * Popup Help Routines
 * ToolBar routines
 * Support BubbleGEM explanations for Toolbar buttons
 *
 * Written by: John Rojewski	12/10/96 thru 10/26/99
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
#include "newsie.h"
#include "protocol.h"
#include "av_proto.h"
#include "global.h"

#define VERSION "0.96  Oct 30, 1999"
#define ErrMsg(a) (char *)em[a].ob_spec
#define MAILTEST "mailtest.txt"

int mail_selective(void);			/* prototype in MAILER.C */
void open_popup_mailbox(void);		/* prototype in MAILER.C */
void mail_retrieve_delete_all( char x );	/* prototype in MAILER.C */
void do_BubbleGEM_events( int *mbuff );		/* prototype for BubbleGEM */


/* Popup Help Routines */

void do_popup_help( int mouse_x, int mouse_y )
{
	GRECT r;
	int result,top,wx,rc;
	MENU pop1,pop2;
	OBJECT *box;

	pop1.mn_tree=NULL;

	wind_get( 0, WF_TOP, &top, NULL, NULL, NULL );
	wind_get( top, WF_WORKXYWH, &r.g_x, &r.g_y, &r.g_w, &r.g_h );
	wx=windows_index( top );
	switch(wx)
	{
	case 1:	rsrc_gaddr(R_TREE,Pop_Subscribed,&pop1.mn_tree); break;
	case 2:	rsrc_gaddr(R_TREE,Pop_Overview,&pop1.mn_tree);	break;
	case 3:	rsrc_gaddr(R_TREE,Pop_Article,&pop1.mn_tree); 	break;
	case 4:	rsrc_gaddr(R_TREE,Pop_GroupList,&pop1.mn_tree);	break;
	case 5:	rsrc_gaddr(R_TREE,Pop_GroupList,&pop1.mn_tree);	break;
	case 6:
		if (mail_selective()) {
			rsrc_gaddr(R_TREE,Pop_MailSelect,&pop1.mn_tree);
		} else {
			rsrc_gaddr(R_TREE,Pop_Mailbox,&pop1.mn_tree);
		}	break;
	case 7:	rsrc_gaddr(R_TREE,Pop_Mail,&pop1.mn_tree);		break;
	case 11:
		if (fpi>=0) {
			rsrc_gaddr(R_TREE,Pop_FTP_Dir,&pop1.mn_tree);
		} else {
			rsrc_gaddr(R_TREE,Pop_FTP_Server,&pop1.mn_tree);
		}
		break;
	case 12: rsrc_gaddr(R_TREE,Pop_Browser,&pop1.mn_tree);	break;
	case 14: rsrc_gaddr(R_TREE,Pop_Address_Book,&pop1.mn_tree);	break;
	}

	if (pop1.mn_tree==NULL) { help(); }
	else {
		do_popup_masking( pop1.mn_tree, wx );	/* set masks */ 
		pop1.mn_menu=ROOT;
		pop1.mn_item=1;
		pop1.mn_scroll=1;
		mouse_x&=0xfff8;
		mouse_y&=0xfff8;
		box = pop1.mn_tree;
		if (box->ob_width+mouse_x>screenw) { mouse_x=screenw-box->ob_width; }

	/*	wind_update(BEG_UPDATE); */
		if ((rc=menu_popup( &pop1, mouse_x, mouse_y, &pop2 ))) {
			result=pop2.mn_item;
			if (result==1) { help(); }
			else {
				switch(wx)
				{
				case 1:	do_Pop_Subscribed(result);	break;
				case 2:	do_Pop_Overview(result);	break;
				case 3:	do_Pop_Article(result); 	break;
				case 4:	do_Pop_GroupList(result, wx);	break;
				case 5:	do_Pop_GroupList(result, wx);	break;
				case 6:
					if (mail_selective()) {
						do_Pop_MailBoxSelect(result);
					} else {
						do_Pop_Mailbox(result);
					}	break;
				case 7:	do_Pop_Mail(result);		break;
				case 11:
					if (fpi>=0) {
						do_Pop_FTP_Directory(result);
					} else {
						do_Pop_FTP_Server(result);
					}	break;
				case 12: do_Pop_Browser(result);	break;
				case 14: do_Pop_Address(result);	break;
				}
			}
		}
		popup_works(rc);	/* set popup menu indicator */
	/*	wind_update(END_UPDATE); */
	}
}

#if (0)
void do_new_popup_help( int mouse_x, int mouse_y )
{
	GRECT r;
	int result,top,wx;
/*	int rc; */
/*	MENU pop1,pop2; */
	OBJECT *box;
	int tree=0;	/* initialize to "no popup menu availble" */

/*	pop1.mn_tree=NULL; */

	wind_get( 0, WF_TOP, &top, NULL, NULL, NULL );
	wind_get( top, WF_WORKXYWH, &r.g_x, &r.g_y, &r.g_w, &r.g_h );
	wx=windows_index( top );
	switch(wx)
	{
	case 1:	tree=Pop_Subscribed;	break;
	case 2:	tree=Pop_Overview;	break;
	case 3:	tree=Pop_Article; 	break;
	case 4:	tree=Pop_GroupList;	break;
	case 5:	tree=Pop_GroupList;	break;
	case 6:
		if (mail_selective()) {
			tree=Pop_MailSelect;
		} else {
			tree=Pop_Mailbox;
		}
		break;
	case 7:	tree=Pop_Mail;		break;
	case 11:
		if (fpi>=0) {
			tree=Pop_FTP_Dir;
		} else {
			tree=Pop_FTP_Server;
		}
		break;
	case 12: tree=Pop_Browser;	break;
	case 14: tree=Pop_Address_Book;	break;
	}

	if (tree==0) {
		help();	/* no popup menu available */
	} else {
		do_popup_masking( tree, wx );	/* set masks */ 
		mouse_x&=0xfff8;
		mouse_y&=0xfff8;
		rsrc_gaddr(R_TREE,tree,&box);
		box->ob_x=screenx;
		box->ob_y=screeny;
		if (box->ob_width+mouse_x>screenw) { mouse_x=screenw-box->ob_width; }

	/*	wind_update(BEG_UPDATE); */
		vs_clip(handle, 0, NULL);
		if ((result=Popup( TreeAddress(tree), ROOT, mouse_x, mouse_y ))) {
			if (result==1) { help();
			} else {
				switch(wx)
				{
				case 1:	do_Pop_Subscribed(result);	break;
				case 2:	do_Pop_Overview(result);	break;
				case 3:	do_Pop_Article(result); 	break;
				case 4:	do_Pop_GroupList(result, wx);	break;
				case 5:	do_Pop_GroupList(result, wx);	break;
				case 6:
					if (mail_selective()) {
						do_Pop_MailBoxSelect(result);
					} else {
						do_Pop_Mailbox(result);
					}	break;
				case 7:	do_Pop_Mail(result);		break;
				case 11:
					if (fpi>=0) {
						do_Pop_FTP_Directory(result);
					} else {
						do_Pop_FTP_Server(result);
					}	break;
				case 12: do_Pop_Browser(result);	break;
				case 14: do_Pop_Address(result);	break;
				}
			}
		}
	/*	popup_works(rc);	/* set popup menu indicator */
	/*	wind_update(END_UPDATE); */
	}
}
#endif

void do_Pop_Subscribed(int result)
{
/*	char path[FMSIZE]; */

	switch(result)
	{
	case PS_Subscribe:		key_group( 0x5200 );	break;
	case PS_UnSubscribe:	key_group( 0x5300 );	break;
	case PS_Overview:		key_group( '\r' );		break;
	case PS_Save:			unload_group(current_newsgroup);	break;
	case PS_OpenList:		open_new_grouplist();	break;
	case PS_MarkAllRead:	mark_all_read();	break;
	case PS_ReadOffline:	handle_News_menu( MN_ReadForOff );	break;
	case PS_OpenPostBox:	handle_News_menu( MN_PostBox );		break;
	}
}

void do_Pop_Overview(int result)
{
/*	char path[FMSIZE]; */

	switch(result)
	{
	case PN_NextArticle:	next_article();	break;
	case PN_NextThread:		next_thread();	break;
	case PN_NextGroup:		next_group();	break;
	case PN_MarkRead:		mark_read();	break;
	case PN_MarkUnread:		mark_unread();	break;
	case PN_MarkThread:		mark_thread_read();	break;
	case PN_MarkAllRead:	mark_all_read();	break;
	case PN_NewPost:		new_post();		break;
	case PN_FollowupPost:	followup_post();	break;
	case PN_ReadOffline:	handle_News_menu( MN_ReadForOff );	break;
	case PN_OpenPostBox:	handle_News_menu( MN_PostBox );		break;
	}
}

void do_Pop_Article(int result)
{
	switch(result)
	{
	case PA_Post:			new_post();	break;
	case PA_Followup:		followup_post();	break;
	case PA_DeleteArticle:	key_article( 0x5300 );	break;
	case PA_SaveAs:			save_as();	break;
	case PA_ExtractBinary:	extract_binaries();	break;
	}
}

void do_Pop_GroupList(int result, int wx)
{
	switch(result)
	{
	case PG_Search:
		if (wx==4) { key_fullgroups( 's' ); } else { key_newgroups( 's'); }
		break;
	case PG_Match:
		if (wx==4) { key_fullgroups( 'm' ); } else { key_newgroups( 'm'); }
		break;
	case PG_Subscribe:
		subscribe();	break;
	}
}

void do_Pop_Mailbox(int result)
{
	char path[FMSIZE];
	int dummy,shift;

	switch(result)
	{
	case PMB_ViewMessage:	key_mailbox( '\r' );	break;
	case PMB_SendMail:
		sprintf( path, "%s\\%s", prefs.work_path, MAILTEST );
		Mail_Message_dialog(0, path );
		break;
	case PMB_ReplyMail:
		sprintf( path, "%s\\%s", prefs.work_path, MAILTEST );
		Mail_Message_dialog(1, path );
		break;
	case PMB_ForwardMail:
		sprintf( path, "%s\\%s", prefs.work_path, MAILTEST );
		Mail_Message_dialog(2, path );
		break;
	case PMB_EditNickname:	edit_nicknames();	break;
	case PMB_OpenInBox:		key_control( '\x09', 0 );	break;
	case PMB_OpenMailbox:
		open_popup_mailbox();
	/*	if (select_mailbox( dirname )) {
			stcgfn( select, dirname );
			strtok( select, "." );
			sprintf( path, "%s %s", ErrMsg(EM_Mailbox), select );
			open_mailbox(path, dirname);
		} */
		break;
	case PMB_DeleteMsg:		key_mailbox( 0x5300 ); break;
	case PMB_Transfer:		key_mailbox( 't' ); break;
	case PMB_SortAuthor:	key_mailbox( 'a' ); break;
	case PMB_SortSubject:	key_mailbox( 's' ); break;
	case PMB_SortDate:
		graf_mkstate(&dummy,&dummy,&dummy,&shift);
		if (shift&3) {	/* either shift key pressed */
			key_mailbox( 'D' ); } else { key_mailbox( 'd' ); }
		break;
	/*	key_mailbox( 'd' ); break; */
	}
}

void do_Pop_MailBoxSelect(int result)
{
	int c;

	switch(result)
	{
	case PMS_Retrieve:		key_mailbox_selective( '\r' ); break;
	case PMS_Delete:		key_mailbox_selective( 0x5300 ); break;
	case PMS_RetrieveAll:
		mail_retrieve_delete_all( 'R' );
		refresh_clear_window( windows[6].id );
		break;
	case PMS_ResetAll:
		for (c=0;c<=maximum_mail;c++) { mailbox[c].status[1]=' '; }
		refresh_clear_window( windows[6].id );
		break;
	case PMS_DeleteRead:
		for (c=0;c<=maximum_mail;c++) {
			if (mailbox[c].status[0]=='R') {  mailbox[c].status[1]='D'; }
		}
		refresh_clear_window( windows[6].id );
		break;
	case PMS_DeleteAll:
		mail_retrieve_delete_all( 'D' );
		refresh_clear_window( windows[6].id );
		break;
	case PMS_Close:	handle_File_menu( MF_Close );	break;
	}
}

void do_Pop_Mail(int result)
{
	char path[FMSIZE];

	switch(result)
	{
	case PM_SendMail:
		sprintf( path, "%s\\%s", prefs.work_path, MAILTEST );
		Mail_Message_dialog(0, path );
		break;
	case PM_ReplyMail:
		sprintf( path, "%s\\%s", prefs.work_path, MAILTEST );
		Mail_Message_dialog(1, path );
		break;
	case PM_ForwardMail:
		sprintf( path, "%s\\%s", prefs.work_path, MAILTEST );
		Mail_Message_dialog(2, path );
		break;
	case PM_EditNicknames:	edit_nicknames();	break;
	case PM_DeleteMsg:		key_mail( 0x5300 );	break;
	case PM_SaveAs:			save_as();	break;
	case PM_ExtractBinary:	extract_binaries();	break;
	}
}

void do_Pop_FTP_Server(int result)
{
	switch(result)
	{
	case PFS_OpenServer:	key_ftp( '\r' );	break;
	case PFS_AddServer:		key_ftp( 0x5200 );	break;
	case PFS_EditServer:	key_ftp( '?' );		break;
	case PFS_DeleteServer:	key_ftp( 0x5300 );	break;
	}
}

void do_Pop_FTP_Directory(int result)
{
	switch(result)
	{
	case PFD_MakeDir:		key_ftp( 'm' );		break;
	case PFD_ChangeDir:
		if (filelist[current_file].status[0]=='d') { key_ftp( '\r' ); }
		break;
	case PFD_DeleteDir:
		if (filelist[current_file].status[0]=='d') { key_ftp( 0x5300 );	}
		break;
	case PFD_GetFile:
		if (filelist[current_file].status[0]=='-') { key_ftp( '\r' ); }
		break;
	case PFD_PutFile:		key_ftp( 0x5200 );	break;
	case PFD_PutFileName:	key_ftp( 0x5230 );	break;	/* shift-Ins */
	case PFD_RenameFile:
		if (filelist[current_file].status[0]=='-') { key_ftp( 'r' ); }
		break;
	case PFD_DeleteFile:
		if (filelist[current_file].status[0]=='-') { key_ftp( 0x5300 );	}
		break;
	}
}

void do_Pop_Address(int result)
{
	switch(result)
	{
	case PAB_SendMail:		key_address( '\r' );	break;
	case PAB_AddEntry:		key_address( 0x5200 );	break;
	case PAB_EditEntry:		key_address( '?' );		break;
	case PAB_DeleteEntry:	key_address( 0x5300 );	break;
	case PAB_SortAddress:	key_address( 's' );		break;
	case PAB_Load:			key_address( 'l' );		break;
	}
}

void do_Pop_Browser(int result)
{
	switch(result)
	{
	case PB_Back:		key_browser( 0x0e08 );	break;
	case PB_Home:		open_url_home();		break;
	case PB_URL:		key_browser( 'u' );		break;
	case PB_File:		key_browser( 'f' );		break;
	case PB_Source:		key_browser( 's' );		break;
	case PB_Reload:		browser_reload();		break;
	case PB_HotList:	open_url_hotlist();		break;
	case PB_Stop:		press_key( 27, 0, 0 );	break;
	}
}

/* ToolBar routines */

int do_toolbar_events(int wid, int mx, int my)
{
	int result,wx,rc,res,ox,oy;
	int msx,msy,btn,kst,resup;
	OBJECT *tree;

	wx = windows_index( wid );
	if ((tree=windows[wx].bar_object)==NULL) { return(0); }
	if ((result=objc_find(tree, ROOT, MAX_DEPTH, mx, my))==-1) { return(0); }
	if (result==0) { return(1); }	/* ignore click in Root box */

	tree[result].ob_state|=SELECTED;
	rc = objc_draw( tree, result, 1, tree[0].ob_x, tree[0].ob_y, tree[0].ob_width, tree[0].ob_height );

	objc_offset(tree, result, &ox, &oy );
	res = evnt_multi( MU_M1|MU_BUTTON, 1, 1, 0,	/* mouse leave or button up */
				1, ox, oy, tree[result].ob_width, tree[result].ob_height,
				0, 0, 0, 0, 0,
				&kst, 0, 0,
				&msx, &msy, &btn, &kst, &kst, &kst );

	tree[result].ob_state&=~SELECTED;
	rc = objc_draw( tree, result, 1, tree[0].ob_x, tree[0].ob_y, tree[0].ob_width, tree[0].ob_height );

	if (res & MU_M1)  { return(1); }	/* left rectangle, ignore */

	if ((resup=objc_find(tree, ROOT, MAX_DEPTH, msx, msy))!=result) { return(1); }	/* ignore */

	switch(wx)
	{
		case 1:	do_Tool_Subscribed(result);	break;
		case 2:	do_Tool_Overview(result);	break;
		case 3:	do_Tool_Article(result); 	break;
		case 4:	do_Tool_GroupList(result, wx);	break;
		case 5:	do_Tool_GroupList(result, wx);	break;
		case 6:
			if (mail_selective()) {
				do_Tool_MailBoxSelect(result);
			} else {
				do_Tool_Mailbox(result);
			}	break;
		case 7:	do_Tool_Mail(result);		break;
		case 11:
			if (fpi>=0) {
				do_Tool_Directory(result);
			} else {
				do_Tool_Server(result);
			}	break;
		case 12: do_Tool_Browser(result);	break;
		case 14: do_Tool_Address(result);	break;
	}
	return(1);
}

void do_Tool_Subscribed(int result)
{
/*	char path[FMSIZE]; */

	switch(result)
	{
	case TS_Subscribe:		key_group( 0x5200 );	break;
	case TS_UnSubscribe:	key_group( 0x5300 );	break;
	case TS_Overview:		key_group( '\r' );		break;
	case TS_Save:			unload_group(current_newsgroup);	break;
	case TS_Open:			open_new_grouplist();	break;
	case TS_MarkAll:		mark_all_read();	break;
	case TS_ReadOffline:	handle_News_menu( MN_ReadForOff );	break;
	case TS_PostBox:		handle_News_menu( MN_PostBox );		break;
	}
}

void do_Tool_Overview(int result)
{
/*	char path[FMSIZE]; */

	switch(result)
	{
	case TO_NextArticle:	next_article();	break;
	case TO_NextThread:		next_thread();	break;
	case TO_NextGroup:		next_group();	break;
	case TO_MarkRead:		mark_read();	break;
	case TO_MarkUnread:		mark_unread();	break;
	case TO_MarkThread:		mark_thread_read();	break;
	case TO_MarkAll:		mark_all_read();	break;
	case TO_Post:			new_post();		break;
	case TO_Followup:		followup_post();	break;
	case TO_ReadOffline:	handle_News_menu( MN_ReadForOff );	break;
	case TO_Postbox:		handle_News_menu( MN_PostBox );		break;
	}
}

void do_Tool_Article(int result)
{
	switch(result)
	{
	case TA_Post:		new_post();		break;
	case TA_Followup:	followup_post();	break;
	case TA_Delete:		key_article( 0x5300 );	break;
	case TA_SaveAs:		save_as();	break;
	case TA_Extract:	extract_binaries();	break;
	case TA_NextArticle:	next_article();	break;
	}
}

void do_Tool_GroupList(int result, int wx)
{
	switch(result)
	{
	case TG_Search:
		if (wx==4) { key_fullgroups( 's' ); } else { key_newgroups( 's'); }
		break;
	case TG_Match:
		if (wx==4) { key_fullgroups( 'm' ); } else { key_newgroups( 'm'); }
		break;
	case TG_Subscribe:
		subscribe();	break;
	}
}

void do_Tool_Mailbox(int result)
{
	char path[FMSIZE];
	int dummy,shift;

	switch(result)
	{
	case TMB_View:	key_mailbox( '\r' );	break;
	case TMB_Send:
		sprintf( path, "%s\\%s", prefs.work_path, MAILTEST );
		Mail_Message_dialog(0, path );
		break;
	case TMB_Reply:
		sprintf( path, "%s\\%s", prefs.work_path, MAILTEST );
		Mail_Message_dialog(1, path );
		break;
	case TMB_Forward:
		sprintf( path, "%s\\%s", prefs.work_path, MAILTEST );
		Mail_Message_dialog(2, path );
		break;
	case TMB_Nicknames:	edit_nicknames();	break;
	case TMB_InBox:		key_control( '\x09', 0 );	break;
	case TMB_Other:
		open_popup_mailbox();
	/*	if (select_mailbox( dirname )) {
			stcgfn( select, dirname );
			strtok( select, "." );
			sprintf( path, "%s %s", ErrMsg(EM_Mailbox), select );
			open_mailbox(path, dirname);
		} */
		break;
	case TMB_Delete:		key_mailbox( 0x5300 ); break;
	case TMB_Transfer:		key_mailbox( 't' ); break;
	case TMB_Author:		key_mailbox( 'a' ); break;
	case TMB_Subject:		key_mailbox( 's' ); break;
	case TMB_Date:
		graf_mkstate(&dummy,&dummy,&dummy,&shift);
		if (shift&3) {	/* either shift key pressed */
			key_mailbox( 'D' ); } else { key_mailbox( 'd' ); }
		break;
	/*	key_mailbox( 'd' ); break; */
	}
}

void do_Tool_MailBoxSelect(int result)
{
	int c;

	switch(result)
	{
	case TMS_Retrieve:		key_mailbox_selective( '\r' ); break;
	case TMS_Delete:		key_mailbox_selective( 0x5300 ); break;
	case TMS_RetrieveAll:
		mail_retrieve_delete_all( 'R' );
		refresh_clear_window( windows[6].id );
		break;
	case TMS_ResetAll:
		for (c=0;c<=maximum_mail;c++) { mailbox[c].status[1]=' '; }
		refresh_clear_window( windows[6].id );
		break;
	case TMS_DeleteRead:
		for (c=0;c<=maximum_mail;c++) {
			if (mailbox[c].status[0]=='R') {  mailbox[c].status[1]='D'; }
		}
		refresh_clear_window( windows[6].id );
		break;
	case TMS_DeleteAll:
		mail_retrieve_delete_all( 'D' );
		refresh_clear_window( windows[6].id );
		break;
	case TMS_Close:	handle_File_menu( MF_Close );	break;
	}
}

void do_Tool_Mail(int result)
{
	char path[FMSIZE];

	switch(result)
	{
	case TM_Send:
		sprintf( path, "%s\\%s", prefs.work_path, MAILTEST );
		Mail_Message_dialog(0, path );
		break;
	case TM_Reply:
		sprintf( path, "%s\\%s", prefs.work_path, MAILTEST );
		Mail_Message_dialog(1, path );
		break;
	case TM_Forward:
		sprintf( path, "%s\\%s", prefs.work_path, MAILTEST );
		Mail_Message_dialog(2, path );
		break;
	case TM_Nicknames:	edit_nicknames();	break;
	case TM_Delete:		key_mail( 0x5300 );	break;
	case TM_SaveAs:		save_as();	break;
	case TM_Extract:	extract_binaries();	break;
	case TM_NextMail:	next_mail();	break;
	case TM_NextUnread:	next_unread_mail();	break;
	}
}

void do_Tool_Directory(int result)
{
	switch(result)
	{
	case TFD_MakeDir:		key_ftp( 'm' );		break;
	case TFD_ChangeDir:
		if (filelist[current_file].status[0]=='d') { key_ftp( '\r' ); }
		break;
	case TFD_DeleteDir:
		if (filelist[current_file].status[0]=='d') { key_ftp( 0x5300 );	}
		break;
	case TFD_Get:
		if (filelist[current_file].status[0]=='-') { key_ftp( '\r' ); }
		break;
	case TFD_Put:		key_ftp( 0x5200 );	break;
	case TFD_PutName:	key_ftp( 0x5230 );	break;	/* shift-Ins */
	case TFD_Rename:
		if (filelist[current_file].status[0]=='-') { key_ftp( 'r' ); }
		break;
	case TFD_Delete:
		if (filelist[current_file].status[0]=='-') { key_ftp( 0x5300 );	}
		break;
	}
}

void do_Tool_Server(int result)
{
	switch(result)
	{
	case TFS_Open:		key_ftp( '\r' );	break;
	case TFS_Add:		key_ftp( 0x5200 );	break;
	case TFS_Edit:		key_ftp( '?' );		break;
	case TFS_Delete:	key_ftp( 0x5300 );	break;
	}
}

void do_Tool_Address(int result)
{
	switch(result)
	{
	case TAB_SendMail:		key_address( '\r' );	break;
	case TAB_AddEntry:		key_address( 0x5200 );	break;
	case TAB_EditEntry:		key_address( '?' );		break;
	case TAB_DeleteEntry:	key_address( 0x5300 );	break;
	case TAB_SortAddress:	key_address( 's' );		break;
	case TAB_Load:			key_address( 'l' );		break;
	}
}

void do_Tool_Browser(int result)
{
	switch(result)
	{
	case TB_Back:		key_browser( 0x0e08 );	break;
	case TB_Home:		open_url_home();		break;
	case TB_URL:		key_browser( 'u' );		break;
	case TB_File:		key_browser( 'f' );		break;
	case TB_Source:		key_browser( 's' );		break;
	case TB_Reload:		browser_reload();		break;
	case TB_HotList:	open_url_hotlist();		break;
	case TB_Stop:		press_key( 27, 0, 0 );	break;
	}
}

/* Support BubbleGEM explanations for Toolbar buttons */

int do_toolbar_help( int mx, int my )
{
	int result,wx,top,res,ox,oy;
	int msx,msy,btn,kst,resup;
	OBJECT *tree;
/*	,*htree=NULL; */
	GRECT r;

	if (prefs.show_bubble_help!='Y') { return(0); }
	wind_get( 0, WF_TOP, &top, NULL, NULL, NULL );
	wind_get( top, WF_WORKXYWH, &r.g_x, &r.g_y, &r.g_w, &r.g_h );
	if (rc_inside( mx, my, &r )!=1) { return(0); }	/* mouse not in top window */

	wx = windows_index( top );
	if ((tree=windows[wx].bar_object)==NULL) { return(0); }	/* no toolbar in window */
	if ((result=objc_find(tree, ROOT, MAX_DEPTH, mx, my))==-1) { return(0); }	/* not in toolbar */
	if (result==0) { return(1); }	/* ignore click in Root box */

	objc_offset(tree, result, &ox, &oy );
	res = evnt_multi( MU_M1|MU_BUTTON, 1, 2, 0,	/* mouse leave or right button up */
				1, ox, oy, tree[result].ob_width, tree[result].ob_height,
				0, 0, 0, 0, 0,
				&kst, 0, 0,
				&msx, &msy, &btn, &kst, &kst, &kst );

	if (res & MU_M1)  { return(1); }	/* left rectangle, ignore */

	if ((resup=objc_find(tree, ROOT, MAX_DEPTH, msx, msy))!=result) { return(1); }	/* redundant! */

	display_toolbar_helptext( wx, result, mx, my );
	return(1);
}

void display_toolbar_helptext( int wx, int result, int mx, int my )
{
	OBJECT *htree=NULL;

/*	Add the following resource trees with help text to Resource File(s),
	keeping the text and associated button object indexes matched
 */
	switch(wx)
	{
	case 1:	rsrc_gaddr(R_TREE,TH_Subscribed, &htree); break;
	case 2:	rsrc_gaddr(R_TREE,TH_Overview,&htree);	break;
	case 3:	rsrc_gaddr(R_TREE,TH_Article,&htree); 	break;
	case 4:	rsrc_gaddr(R_TREE,TH_GroupList,&htree);	break;
	case 5:	rsrc_gaddr(R_TREE,TH_GroupList,&htree);	break;
	case 6:
		if (mail_selective()) {
			rsrc_gaddr(R_TREE,TH_MailSelect,&htree);
		} else {
			rsrc_gaddr(R_TREE,TH_MailBox,&htree);
		}	break;
	case 7:	rsrc_gaddr(R_TREE,TH_Mail,&htree);		break;
	case 11:
		if (fpi>=0) {
			rsrc_gaddr(R_TREE,TH_Directory,&htree);
		} else {
			rsrc_gaddr(R_TREE,TH_Server,&htree);
		}	break;
	case 12: rsrc_gaddr(R_TREE,TH_Browser,&htree);	break;
	case 14: rsrc_gaddr(R_TREE,TH_Address,&htree);	break;
	}

	if (htree) { 
		do_BubbleGEM( mx, my, (char *)htree[result].ob_spec );
/*	} else {
		do_BubbleGEM( mx, my, "This is a Toolbar button" ); */
	}
}

#define BUBBLEGEM_REQUEST 0xBABA
#define BUBBLEGEM_SHOW	  0xBABB
#define BUBBLEGEM_ACK     0xBABC
#define BUBBLEGEM_ASKFONT 0xBABD
#define BUBBLEGEM_FONT    0xBABE
#define BUBBLEGEM_HIDE    0xBABF

void do_BubbleGEM_events( int *mbuff )
{
	if (prefs.show_bubble_help!='Y') { return; }
	switch( mbuff[0] )
	{
	case BUBBLEGEM_REQUEST:		/* support time-controlled deamon */
		if (do_toolbar_BubbleGEM( mbuff )) { return; }	/* toolbar bubble help */
	/*	if (do_window_line_BubbleGEM( mbuff )) { return; }	/* help on window lines */		
		break;
	}
}

int do_toolbar_BubbleGEM( int *mbuff )
{
	int wx,result;
	OBJECT *tree;

	wx = windows_index( mbuff[3] );
	if (wx==0) { return(0); }		/* not my window, or wdialog? */
	if ((tree=windows[wx].bar_object)==NULL) { return(0); }	/* no toolbar in window */
	if ((result=objc_find(tree, ROOT, MAX_DEPTH, mbuff[4], mbuff[5]))==-1) { return(0); }	/* not in toolbar */
	if (result==0) { return(1); }	/* ignore mouse in Root box */
	display_toolbar_helptext( wx, result, mbuff[4], mbuff[5] );
	return(1);
}

void do_BubbleGEM( int mx, int my, char *text )
{
	short msg[8];
	short bubble_id,first=0;
	long val;
	static char *bubble_text=NULL;

/* BUBBLEGEM_SHOW -news:
 * msg[0] $BABB
 * msg[1] ap_id
 * msg[2] 0
 * msg[3] mouse X
 * msg[4] mouse Y
 * msg[5/6] Pointer at nullterminierte character string in the global  
 * memory
 * msg[7] 0
 */

#define MGLOBAL 0x20
#define MagX_COOKIE 0x4D616758L
#define MiNT_COOKIE 0x4D694E54L

/* Feststellen, if Mxalloc() available is, if yes,
 * then Speicherschutz-mode at "Global" put
 */
	if (!bubble_text ) {		/* if buffer has not been allocated */
		if ((getcookie( MagX_COOKIE, &val ) == TRUE) ||
			(getcookie( MiNT_COOKIE, &val ) == TRUE)) {
			bubble_text = (char *) Mxalloc (256, 0 | MGLOBAL);
		} else {
			bubble_text = (char *) Malloc (256);
		}
		if (memcmp(prefs.email_address,"rojewski",8)==0) { 
			first++;		/* set BubbleGEM font */
			msg[0] = BUBBLEGEM_FONT;	/* build font message */
			msg[1] = _AESglobal[2];
			msg[2] = 0;
			msg[3] = find_font( prefs.news_font );
			msg[4] = atoi( prefs.news_font_size );
			msg[5] = 0;
			msg[6] = 0;
			msg[7] = 0;
		}
	}

	if ((bubble_id = appl_find("BUBBLE  ")) >= 0) {
		if (first) { appl_write(bubble_id, 16, msg); } /* set font first time */
		strcpy( bubble_text, text );	/* copy text to allocated buffer */
		msg[0] = BUBBLEGEM_SHOW;
		msg[1] = _AESglobal[2];
		msg[2] = 0;
		msg[3] = mx;
		msg[4] = my;
		msg[5] = (int)(((long) bubble_text >> 16) & 0x0000ffff);
		msg[6] = (int)((long) bubble_text & 0x0000ffff);
		msg[7] = 0;
		if (appl_write(bubble_id, 16, msg) == 0) { /* error */ }
	}
}

/*
As Antwortnachricht receive one BUBBLEGEM_ACK ($BABC) with the Pointer
at the character string, whose memory one now with requirement release
can. The Arrayelemente 2, 3, 4 and 7 are ausgenullt.
*/

/* BUBBLEGEM_ACK ($BABC)
 *
 * msg[0] $BABC
 * msg[1] ap_id
 * msg[2] 0
 * msg[3] 0
 * msg[4] 0
 * msg[5/6] Pointer from BUBBLEGEM_SHOW
 * msg[7] 0
 */

/* shorter Beispielcode */

/*if (msg[5] == 0 && msg[6] == 0) {  /* error, ungÅltiger Pointer */
/* }

pointer = *(BYTE **) &msg[5];


}
*/

/* end of NEWSAES2.C */
