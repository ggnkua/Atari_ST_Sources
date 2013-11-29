/*
 * newsaes.c
 * Written by: John Rojewski	12/10/96
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
#include <mintbind.h>
#include <cookie.h>
#include "newsie.h"
#include "protocol.h"
#include "av_proto.h"
#include "global.h"

#define VERSION "0.962 Aug  8, 2000"
#define ErrMsg(a) (char *)em[a].ob_spec
#define OFFLINE (ncn<0)&&(prefs.offline_test=='Y')
#define MT _AESglobal[1]!=1		/* Multi-tasking OS */
#define MAX_MENU_ITEM MP_Save	/* change when Menu (NEWSie) is updated */
#define WA_TOP 8				/* Home key pressed */
#define WA_BOTTOM 9				/* Shift-Home key pressed */
#define MAILTEST "mailtest.txt"

char *strtoka( char *s, int tok );	/* prototype in MAILER.C */
int mail_selective(void);			/* prototype in MAILER.C */
void open_popup_mailbox(void);		/* prototype in MAILER.C */
void mail_retrieve_delete_all( char x );	/* prototype in MAILER.C */
void *html_global(int way, void *value);	/* prototype in BROWSER.C */

void do_BubbleGEM_events( int *mbuff );		/* prototype for BubbleGEM */

#if (0)
void *TreeAddress(int TreeIndex);	/* prototypes from popup.o */
int Popup(void *TreeAddress,int PopupObjectIndex,int ShowX, int ShowY);
#endif

void initialize_toolbars(void)
{
	windows[1].bar_index = Tool_Subscribed;
	windows[2].bar_index = Tool_Overview;
	windows[3].bar_index = Tool_Article;
	windows[4].bar_index = Tool_GroupList;
	windows[5].bar_index = Tool_GroupList;
	windows[6].bar_index = Tool_MailBox;
	windows[7].bar_index = Tool_Mail;
/*	windows[8].bar_index = Tool_Help; */
/*	windows[9].bar_index = Tool_Log; */
/*	windows[10].bar_index = Tool_FTP_Viewer; */
	windows[11].bar_index = Tool_Server;  /* or Tool_Directory */
	windows[12].bar_index = Tool_Browser;
	windows[14].bar_index = Tool_Address;
}

void set_menu( int which, int func )
{
/* func: 1=enable, 0=disable, -1=according to sign (+=on, -=off) */
	int ftp1[] = { MT_SelectServer, -MT_AddServer, -MT_DeleteServer, -MT_EditServer, 0 };
	int ftp2[] = { MT_MakeDir, MT_ChangeDir, MT_DeleteDir, MT_GetFile, MT_PutFileName, MT_RenameFile, MT_PutFile, MT_DeleteFile, 0 };
	int edit3[] = { -ME_Cut, ME_Copy, -ME_Paste, 0 };
	int stik4[] = { MN_ReadForOff, MS_ConnectHost, MS_Disconnect, MM_CheckMail, MM_GetMail, MM_GetSelected, MM_SendQueued, 0 };
	int offl5[] = { MN_ReadForOff, 0 };
	int find6[] = { ME_Find, ME_FindNext, 0 };
	int reply7[] = { MM_ReplyMail, MM_ForwardMail, 0 };
	int news8[] = { MN_Article, MN_Thread, -MN_MarkRead, -MN_MarkUnread, -MN_MarkThread, 0 };
	int onoff,*p;

	switch (which)
	{
		case 1: p=ftp1; break;
		case 2: p=ftp2; break;
		case 3: p=edit3; break;
		case 4: p=stik4; break;
		case 5: p=offl5; break;
		case 6: p=find6; break;
		case 7: p=reply7; break;
		case 8: p=news8; break;
		default: return;
	}
	onoff = func;
	while (*p) {
		if (func<0) { onoff = (*p>0); }
		menu_ienable( menu_ptr, abs(*p), onoff );
		p++;
	}
}

void set_cutcopypaste( int windex )
{
	switch (windex)
	{
	case 1:		set_menu( 3, 1 ); break;	/* enable cut,copy,paste */
	case 4:
	case 5:		set_menu(3, -1 ); break;	/* enable copy, disable cut,paste */
	default:	set_menu( 3, 0 ); break;	/* disable cut,copy,paste */
	}
}

void set_find_findnext( int windex )
{
	switch (windex)
	{
/*	case 1: /* subscribed newsgroups */
	case 2:	/* overview */
	case 3: /* article */
	case 4: /* fullgroups */
	case 5: /* newgroups */
	case 6: /* mailbox */
	case 7: /* mail */
	case 8: /* help */
	case 10: /* ftp viewer */
/*	case 11: /* ftp */
	case 12: /* browser, when in plain_text mode */
/*	case 13: /* available */
	case 14: /* address book */
		set_menu( 6, 1 ); break;	/* enable find, find next */
	default:	set_menu( 6, 0 ); break;	/* disable find, find next */
	}
}

void set_reply( int windex )
{
	switch(windex)
	{
	case 2:	/* overview */
	case 3: /* article */
		set_menu( 7, (current_article[0]!='\0') );
		break;
	case 6: /* mailbox */
	case 7: /* mail */
		set_menu( 7, (current_mailmsg[0]!='\0') );
		break;
	default:
		set_menu( 7, 0 );
	}
}

void set_readmsg( int windex )
{
	int rc;

	rc = current_overview>=0;		/* 0 or 1 */
	if (!rc) { if (maximum_overview>=0)  rc=-1; }	/* if 0, then possibly -1 */
	set_menu( 8, rc );
}

void set_menu_list( int windex )
{
	set_cutcopypaste( windex );
	set_find_findnext( windex );
	set_reply( windex );
	set_readmsg( windex );
}

/*
void build_spinner()
{
	BITBLK *m;
	int c,d;

	rsrc_gaddr(R_FRIMG,Mouse_Form,&m);
	for (c=0;c<4;c++) {
		spmse[c].mf_xhot = 8;
		spmse[c].mf_yhot = 8;
		spmse[c].mf_nplanes = 1;
		spmse[c].mf_fg = 0;
		spmse[c].mf_bg = 1;
		for (d=0;d<16;d++) {
			spmse[c].mf_mask[d] = m->bi_pdata[c];
			spmse[c].mf_data[d] = m->bi_pdata[(c+1)*16+d];
		}
	}
}
*/

int keyboard_preference(void)
{
	long cook,AKP=0x2d414b50;	/* "_AKP" */

	if (getcookie( AKP, &cook )) {
		return((int)cook>>8);	/* preference is in byte 3 of long */
	}
	return(0);	/* no cookie, default to 0 = English */
}

void language_preference(char *lang)
{
#define NUM_LANG 18
	char language[]= {"ENGLISH   ", "GERMAN  DM", "FRENCH  FR", "ENGLISH   ",
					  "SPANISH SP", "ITALIAN IT", "SWEDISH SV", "SWISSF  FR",
					  "SWISSD  DM", "TURKISH TU", "FINNISH FN", "NORWEGN NO",
					  "DANISH  DN", "SAUDI   SA", "DUTCH   DU", "CZECK   CZ",
					  "HUNGARY HU", "LATIN   LT"};
	char dir[12];
	int pref,c;

	strcpy( lang, language );	/* default to English */
	if (prefs.auto_language=='Y') {
		pref = keyboard_preference();
		strcpy( lang, &language[pref*11] );
		if (log) { fprintf( log, "Auto Language preference: %s\n", lang ); fflush(log); }
		return;
	}
	for (c=0;c<NUM_LANG;c++) {
		strcpy( dir, &language[c*11] );
		strtoka( dir, ' ' );
		if (strcmp(prefs.selected_language, dir )==0) {
			strcpy( lang, &language[c*11] );
			if (log) { fprintf( log, "Language preference: %s\n", lang ); fflush(log); }
			return;
		}
	}
}

#define EXP_COLOR_MENU 0		/* experimental item 0 */
#define EXP_MYFORM_DO  2		/* experimental item 2 */

void color_menu(int show)
{
	int i;

	if (prefs.experimental[EXP_COLOR_MENU]=='Y') {	/* experimental option on? */
		for (i=2;i<=MAX_MENU_ITEM;i++) {
			if (menu_ptr[i].ob_type==G_BOX) { menu_ptr[i].ob_flags |= FL3DBAK; }
			if (menu_ptr[i].ob_type==G_STRING) { menu_ptr[i].ob_flags |= FL3DBAK; }
			if (menu_ptr[i].ob_type==G_TITLE)  { menu_ptr[i].ob_flags |= FL3DBAK; }
		}
		wind_update( BEG_UPDATE );
		menu_bar(menu_ptr,show);
		wind_update( END_UPDATE );
	}
}

void initialize_attached_menu_block( MENU *menu )
{
	menu->mn_menu=ROOT;	/* parent object */
	menu->mn_item=1;	/* starting item */
	menu->mn_scroll=1;	/* 1 = allow scrolling, 0 = no scrolling */
	menu->mn_tree=NULL;	/* no OBJECT tree */
}

void initialize_resource(int show)
{
	char lang[18],rsc[FNSIZE],rscfile[FMSIZE];
	char current_path[FMSIZE];
	char rpath[FMSIZE]="";
	struct FILEINFO info;
	char *version;
	char buff[80];
	int x;
	static int first_time=0;

	strcpy( rscfile, "NEWSIE.RSC" );
	getcd( 0, current_path );		/* get current path */

	language_preference( lang );
	if (memcmp( lang+8, "  ", 2 )!=0) {	/* if not english */
		strtoka( lang, ' ' );	/* trim trailing spaces */
		sprintf( rpath, "%s\\LANGUAGE\\%s", current_path, lang );	/* language directory */
		if (chdir( rpath )!=0) { beep(); }		/* set resource path */
	/*	if (log) { fprintf( log, "Trying Resource path %s\n", rpath ); } */
		if (dfind( &info, rscfile, 0 )) {	/* if file does not exist in directory */
			rpath[0]='\0';	/* reset to default path */
			chdir( current_path );	/* restore path */
			sprintf( rsc, "NEWSIE%s.RSC", lang+8 );	/* 2-char language code */
		/*	if (log) { fprintf( log, "Trying Resource path %s\n", rsc ); } */
			if (!dfind( &info, rsc, 0 )) { strcpy( rscfile, rsc ); }	/* if file exists */
		} else { sprintf( rscfile, "%s\\NEWSIE.RSC", rpath ); }  
	}
	if (log) { fprintf( log, "Resource path is: %s\n", rscfile );  fflush(log); }
	if (!rsrc_load( rscfile ))	{
		sprintf( rsc, "[1][NEWSie Resource file error| %s | %s][ Quit ]", lang, rscfile );
		form_alert(1, rsc);
		exit(EXIT_FAILURE);
	}
	if (rpath[0]!='\0') { chdir( current_path ); }	/* restore path */

	rsrc_gaddr(R_STRING,NEWSie_Version,&version);
	if (!first_time) {
		if (version!=NULL)	{
			if (memcmp(VERSION,version,4)>0) {
				sprintf ( buff, "[1][NEWSie Resource version %.4s][ OK ]", version );
				x=form_alert( 1,buff );
			}
		} else {
			x=form_alert(1,"[1][NEWSie Resource may be incompatible][ Continue|Quit ]");
			if (x==2) { exit(EXIT_FAILURE); }
		}
		first_time++;
	}
	rsrc_gaddr(R_TREE,NEWSie,&menu_ptr);

	wind_update( BEG_UPDATE );
	menu_bar(menu_ptr,show);
	wind_update( END_UPDATE );

	set_menu( 1, -1 );	/* enable FTP SelectServer, disable rest */
	set_menu( 2, 0 );	/* disable rest */
	rsrc_gaddr(R_TREE,Error_Message,&em);
	for (x=0;x<WINDOWS_SIZE;x++) {	/* clear toolbar object addresses */
		windows[x].bar_object=NULL;
	}
	color_menu(show);	/* allow colored menu items, take on background color */
	if (log) attach_submenus();	/* attach sub-menu trees for AES 3.3 and up */
}

void initialize_gem(int show)
{
	int x;
	static char menu[]="  NEWSie xxxx";

	if (appl_init()<0)
		exit(EXIT_FAILURE);

	initialize_resource(show);

	handle = phys_handle = graf_handle( &charw, &charh, &cellw, &cellh ); 
	work_in[10]=2;
	work_in[0]=Getrez() + 2;
	for (x=1; x<10; work_in[x++]=1);
	v_opnvwk( work_in, &handle, work_out );
	if (handle==0) exit(EXIT_FAILURE);

	for (x=0;x<WINDOWS_SIZE;x++) {
		windows[x].id=-1;
		windows[x].bar_object=NULL;
	}
	wind_get(DESK,WF_WORKXYWH,&screenx,&screeny,&screenw,&screenh);
	graf_mouse(ARROW,NULL);
/*	build_mouse(); */
/*	build_spinner(); */
	initialize_fonts();
	initialize_toolbars();
	if (_AESglobal[0]>=0x0400) {	/* MultiTos */
		shel_write( 9, 0x01, 0, NULL, NULL );	/* AP_TERM handled */
	}
	if ( MT ) {
		memcpy( &menu[9], VERSION, 4 );
		menu_register( _AESglobal[2], menu );
	}
}

void no_stik(void)
{
	char *nostik;

	rsrc_gaddr(R_STRING,NoSTiK,&nostik); /* STiK not available */
	form_alert(1,nostik);
	set_menu( 4, 0 );		/* disable connection type menu items */
}

void set_clip( GRECT *r)
{
	int points[4];

	grect_conv(r, &points );
	vs_clip( handle, 1, points );
}

void clear_rect(GRECT *r)
{
	int points[4];

	vsf_interior(handle,0);
	grect_conv(r, &points );
	vr_recfl(handle,points);
}

void set_rect(GRECT *r, int interior)
{
	int points[4];

	vsf_interior(handle, interior);
/*	vsf_style( handle, pattern ); */
	grect_conv(r, &points );
	vr_recfl(handle,points);
}

void grect_conv(GRECT *r, int *array)	/* convert GRECT to array of points */
{
	*array++ = r->g_x;
	*array++ = r->g_y;
	*array++ = r->g_x + r->g_w - 1;
	*array = r->g_y + r->g_h - 1;
}

void deinitialize_gem(void)
{
	int c;

	menu_bar(menu_ptr,0);
	for (c=0;c<WINDOWS_SIZE;c++) {
		if (windows[c].open) { wind_close( windows[c].id); }	/* don't set flag */
		delete_window( windows[c].id );
		windows[c].id=-1;
	}
	v_clsvwk( handle );
	rsrc_free();
	appl_exit();
}

void release_window_buffer( int wx, int release )
{
	if (release) {
		if (windows[wx].buffer!=NULL) {
			free( windows[wx].buffer );
			windows[wx].buffer=NULL;
		}
	}
}

void enable_infoline(int wx)
{
	switch (wx)
	{
	case 2:		/* overview	*/
	case 3:		/* article	*/
	case 6:		/* mailbox	*/
	case 7:		/* mail		*/
	case 11:	/* ftp		*/
	case 12:	/* browser	*/
		if (prefs.use_info_status!='Y') { if ((wx==7)||(wx==3)) { break; } }
		windows[wx].components|=INFO; 		/* enable info line */
		memset( windows[wx].info, 0, 80 );	/* and clear it */
		break;
	}
}
 
void new_window(int wx, char *title, int x, int y, int w, int h )
{
	int wid,rc,wy,wh;
	GRECT wk;
	int components = NAME|MOVE|CLOSE|UPARROW|DNARROW|VSLIDE|FULLER|SIZER;
	char *nowindow;
	int dummy,sy,sh;

	components|=SMALLER;
	if (wx==0) { components=NAME|MOVE|CLOSE; }		/* status window */
	windows[wx].components = components;			/* mark in windows[] */
	enable_infoline( wx );							/* enable info line */
	if (title[0]!='\0') { strcpy( windows[wx].title, title ); }
	if (windows[wx].id>0) {
		if (windows[wx].open) {	windows[wx].open=2; }
	} else {
		wid = wind_create( windows[wx].components, screenx,screeny,screenw,screenh );
		if (wid<0) {
			rsrc_gaddr(R_STRING,NoWindow,&nowindow); /* no windows available */
			form_alert(1,nowindow);
			return;
		}
		windows[wx].id=wid;
		if (windows[wx].w<=0) {	/* if width is zero */
 			windows[wx].x=x;
			windows[wx].y=y;
			windows[wx].w=w;
			windows[wx].h=h;
		}

		wy=windows[wx].y;		/* limit to screen height - old TOS */
		wh=windows[wx].h;
		wind_get( DESK, WF_CXYWH, &dummy, &sy, &dummy, &sh );	/* exterior coords */
		if (wy+wh>sy+sh) {
			if ((rc=sh-wh)>=screeny) { wy=rc; windows[wx].y=wy; }
		}
		if (wy+wh>sy+sh) {
			if (wy>sh/2) { wy=wy/2; windows[wx].y=wy; }
			if (wy+wh>sy+sh) { wh=sh-wy; windows[wx].h=wh; }
		}
		if (wy+wh>sy+sh) {	/* again - if necessary */
			windows[wx].y=screeny;
		}
	}
	wid = windows[wx].id;
	rc  = wind_title( wid, windows[wx].title );
	if (windows[wx].components&VSLIDE) {
		rc	= wind_set( wid, WF_VSLSIZE, 1000, 0, 0, 0 );
		rc  = wind_set( wid, WF_VSLIDE, 1, 0, 0, 0 );
	}

	if (w+h) {		/* if not re-open after single_TOS editor */
	release_window_buffer( wx, 1);	/* release buffer if allocated */
/*	release_window_buffer( wx, windows[wx].releasebuf );	/* release buffer if allocated */
	}
	windows[wx].prev_line_no = windows[wx].line_no;

	if (windows[wx].open==2) {	/* if wid already assigned... */
		windows[wx].open=1;
		refresh_clear_window( wid );
		if (wind_get( 0, WF_TOP, &rc, NULL, NULL, NULL )!=wid) {
			wind_set( wid, WF_TOP, 0, 0, 0, 0 );
			set_menu_list( wx );
		}
		return;
	} 

 	if (windows[wx].full) {
 		wind_open( wid, screenx, screeny, screenw, screenh );
 	} else {
		wind_open( wid, windows[wx].x, windows[wx].y, windows[wx].w, windows[wx].h );
	}
	windows[wx].open=1;
	if (windows[wx].components&INFO) {
		wind_info( windows[wx].id, windows[wx].info );
	}
	set_menu_list( wx );
	graf_mouse( M_OFF, NULL );
	wind_get( DESK, WF_WORKXYWH, &wk.g_x, &wk.g_y, &wk.g_w, &wk.g_h );
	set_clip( &wk );			/* clip to screen */
	wind_get( wid, WF_WORKXYWH, &wk.g_x, &wk.g_y, &wk.g_w, &wk.g_h );
	clear_rect( &wk);
	vs_clip(handle, 0, NULL);	/* clipping off */
	graf_mouse( M_ON, NULL );
}

void delete_window( int window_id )
{
	int x;

	if (window_id>0)
		x = wind_delete( window_id );
}

void reopen_windows(int top)
{
	int w,c;

/*	graf_mouse( M_OFF, NULL ); */
	for (c=0;c<WINDOWS_SIZE;c++) {	
		if (windows[c].open) { new_window( c, "", 0, 0, 0, 0 ); }
	}
	wind_set( top, WF_TOP, 0, 0, 0, 0 );
	w=windows_index( top );
	set_menu_list( w );
/*	graf_mouse( M_ON, NULL ); */
}

int info_line( int wx, char *info )
{
	if (wx<1) { return(0); }
	if (wx>=WINDOWS_SIZE) { return(0); }
	if (windows[wx].id<0) { return(0); }	/* if window doesn't exist */
	if (!windows[wx].open) { return(0); }	/* if window is not open */
	if (windows[wx].components&INFO) {
		strncpy( windows[wx].info, info, 79 );
		windows[wx].info[79]='\0';		/* null terminate */
		wind_info( windows[wx].id, windows[wx].info );
		return(1);
	}
	return(0);
}

/* scan memory from 2048 to this module looking for WDiALOG 2. */
int is_WDialog2(void)
{
	char *p;
	static char wd[12]="WDIALOG 2.";
	static int is_W2=-1;

	if (is_W2>=0) { return(is_W2); }	/* if we already know, skip the scan */

	p=(char *)2048;
/*	fprintf( log, "Starting at %p\n", p ); */
	do {
		if (*p=='W') {
			if (memcmp(p,wd,10)==0) {	/* found the string! */
				if (*(p-2)=='\n') { return(is_W2=1); }	/* linefeed -> is WDIALOG 2 */
				if (p==wd) {
				/*	fprintf( log, "not found at %p\n", p ); */
					return(is_W2=0);	/* its mime -> not WDiALOG 2 */
				} else {
					if (*(p-2)!='\n') { return(is_W2=0); }	/* no linefeed -> not WDIALOG 2 */
					fprintf( log, "WDialog 2 found at %p\n", p );
					return(is_W2=1);	/* not mine -> is WDiALOG 2 */
				}
			}
		}
		p++;
	} while(1);
/*	fprintf( log, "Fell through at %p\n", p ); */
	return(0);	/* Not version 2.? */
}

int WDialog(void)
{
	int x,z;

	if (appl_find("?AGI")>=0) {	/* appl_getinfo supported? */
		appl_getinfo( 7, &x, &z, &z, &z );
	/*	if (x&1) { return(1); } */
		if (x&1) { return(!is_WDialog2()); }	/* return true for non-version 2 */
	}
	return(0);
}


int uncross_radio( OBJECT *dlog, int obj )
{
	if (dlog[obj].ob_flags&RBUTTON) {
		set_crossed( dlog, obj, FALSE );
		objc_draw( dlog, obj, 0, screenx, screeny, screenw, screenh );
	}
	return(1);
}

void reset_radio_buttons( OBJECT *dlog )
{
	objc_walk( dlog, ROOT, NIL, 0, uncross_radio );
}
 
#define TREE_XYWH(tree) tree[0].ob_x-3,tree[0].ob_y-3,tree[0].ob_width+6,tree[0].ob_height+6

int handle_dialog(OBJECT *dlog,int editnum)
{
	short x,y,w,h;
	int but,dbl,start=ROOT;
	char dirname[FMSIZE];
	
	form_center(dlog,&x,&y,&w,&h);
	form_dial(FMD_START,0,0,0,0,x,y,w,h);
	form_dial(FMD_GROW,x+w/2,y+h/2,0,0,x,y,w,h);
	do {
		wind_update( BEG_UPDATE );
		objc_draw(dlog,start,MAX_DEPTH,TREE_XYWH(dlog));
	/*	if (memcmp(prefs.email_address,"rojewski",8)==0) { */
		if (prefs.experimental[EXP_MYFORM_DO]!='N') {
			but = my_form_do( dlog, editnum );
		} else { 
			but = form_do(dlog,editnum);
		}
		wind_update( END_UPDATE );

		dbl=but&0x8000;	/* determine if double-click */
		but&=0x7fff;	/* mask off high bit for double-click */
		if (dlog[but].ob_flags&TOUCHEXIT) {
			start=ROOT;						/* redraw entire tree */
			if (dlog[but].ob_type==G_FTEXT) {	/* addresses from edit_nickname */
			/*	beep(); */
				display_nicknames( dlog, but-1, FALSE );
			/*	dlog[but].ob_state&=~SELECTED; */
			}
			if (dlog[but].ob_type==G_BOXCHAR) {
				display_font_list_dialog( dlog, but );
				handle_redraw_event();
			}
			if (dlog[but].ob_type==G_BOX) {
				if (dlog[but].ob_flags&RBUTTON) { reset_radio_buttons( dlog ); }
				toggle_crossed(dlog, but );
				start=but;					/* redraw only box */
			}
			if (dlog[but].ob_type==G_BOXTEXT) {		/* include nicknames */
				display_nicknames( dlog, but, TRUE );
				dlog[but].ob_state&=~SELECTED;
			}
			if (dlog[but].ob_type==(256+G_BOXTEXT)) {	/* special file selector */
				select_attach_file(dirname);
				/* strcpy(current_attachment, dirname ); */
				set_tedinfo( dlog, but, dirname);
				dlog[but].ob_state&=~SELECTED;
			}
			if (dlog[but].ob_type==(512+G_BOXTEXT)) {	/* language selector */
				select_language( dlog, but );
			/*	set_tedinfo( dlog, but, dirname); */
				dlog[but].ob_state&=~SELECTED;
			}
		}
	} while (dlog[but].ob_flags&TOUCHEXIT);
	form_dial(FMD_SHRINK,x+w/2,y+h/2,0,0,TREE_XYWH(dlog));
	form_dial(FMD_FINISH,0,0,0,0,TREE_XYWH(dlog));
	dlog[but].ob_state&=~SELECTED;	/* de-select exit button */
	return but;
}

/*
 * copy a string into a TEDINFO structure.
 */
void set_tedinfo(OBJECT *tree,int obj,char *source)
{
	char *dest;
	
	dest=((TEDINFO *)tree[obj].ob_spec)->te_ptext;
/*	strncpy(dest,source,te_txtlen); */	/* can te_txtlen be trusted? */
	strcpy(dest,source);
}

/*
 * copy the string from a TEDINFO into another string
 */
void get_tedinfo(OBJECT *tree, int obj, char *dest)
{
	char *source;

	source=((TEDINFO *)tree[obj].ob_spec)->te_ptext;	/* extract address */
	strcpy(dest,source);
}

void set_crossed(OBJECT *tree, int obj, int onoff)
{
	if (onoff)	{ tree[obj].ob_state|=CROSSED; }
		else	{ tree[obj].ob_state&=~CROSSED; }
}

void get_crossed(OBJECT *tree, int obj, char *yorn)
{
    if (tree[obj].ob_state&CROSSED) { *yorn='Y'; } else { *yorn = 'N'; }
}

void toggle_crossed(OBJECT *tree, int obj)
{
	tree[obj].ob_state^=CROSSED;	/* xor should toggle CROSSED bit */
}

void set_vslider_size(int id, int seen, int total)
{
	long size;
	int old,new;

	if (total<1) { total=1; }	/* prevent divide by zero */
	size = 1000 * (long)seen / (long)total;
	size = 1000 < size ? 1000 : size;	/* minimum */
	wind_get( id, WF_VSLSIZE, &old, NULL, NULL, NULL );
	new=(int)size;
	if (new!=old) {
		if (new<1) { new=1; }
		wind_set( id, WF_VSLSIZE, new, 0, 0, 0 );
	}
/*	fprintf( log, "Slider Size %d %d %d %d %d\n", id, seen, total, new, old ); */
}

void setup_toolbar(int wx, int *gx, int *gy, int *gw, int *gh)
{
	OBJECT *bar;

	if (windows[wx].bar_index==0) { return; }
	if (prefs.show_toolbar!='Y'&&prefs.show_toolbar!='B') {
		windows[wx].bar_object=NULL;
		return;
	}
	if (windows[wx].bar_object==NULL) {
		rsrc_gaddr( R_TREE, windows[wx].bar_index, &windows[wx].bar_object );
	}
	if ((bar=windows[wx].bar_object)!=NULL) {  /* rsrc_gaddr may not work */
		*gh-= bar->ob_height;		/* reduce available height */
		bar->ob_x = *gx;
		bar->ob_width = *gw;
		if (prefs.show_toolbar=='B') { 	/* toolbar at bottom of window */
			bar->ob_y = *gy+*gh;
		} else {
			bar->ob_y = *gy;
			*gy+= bar->ob_height;	/* move text down past toolbar */
		}
	}
}

int setup_text(int wid, int windex, char *fontname, char *fontsize,
				int g_h, int maximum )
{
	int x,lpp,dummy;

    x = find_font( fontname );
	vst_font( handle, x);
	x = atoi( fontsize );
	vst_point( handle, x, &charw, &charh, &cellw, &cellh );
	vst_alignment( handle, 0, 3, &dummy, &dummy );	/* align left, bottom */
	lpp=(g_h-2)/cellh;
	lpp = 80 < lpp ? 80 : lpp;	/* minimum of actual or 80 lines */
	windows[windex].lines_per_page=lpp;
	set_vslider_size( windows[windex].id, lpp, maximum );
	return(lpp);
}

int generic_detect_uuencoded( FILE *fid, char *q, int wx )
{
	int found=0;
	char a[100],file[FMSIZE];

	/* display 'Attachment: file.txt' for uu-encoded attachment */
	if (memcmp( q, "begin ", 6)==0) {
		found++;
		sscanf( q, "%s %s %s", a,a,file );
		sprintf( q, "Attachment: %s (UUE) ", file );
		while (fgets( a, 100, fid )!=NULL) {
			if (memcmp( a, "end", 3 )==0) { break; }
			windows[wx].num_lines--;
		}
		set_vslider_size( windows[wx].id, windows[wx].lines_per_page, windows[wx].num_lines );
	}
	return(found);
}

int generic_b64encoded( FILE *fid, char *q, int wx, int display )
{
	static int is_encoded=0;
	static char file[FMSIZE]="";
	int found=0;
	char a[100],b[80],c[80],*p;

	/* display 'Attachment: file.txt' for base64-encoded attachment */

	/*	Content-Type: image/jpeg; name="ABC.JPG"
		Content-Transfer-Encoding: base64
		Content-Disposition: inline; filename="ABC.JPG"
	*/
	if (memcmp( q, "Content-", 8)==0) {
		found--;	/* don't display MIME "Content-" lines */
		sscanf( q, "%s %s %s", a,b,c );
		if (strcmpi( "base64", b )==0) { is_encoded = 1; }
		if ((memcmp( "name=", c, 5 )==0)||
		   (memcmp( "filename=", c, 9 )==0)) {	/* extract filename */
			p=strtok( c, "\"" );
			p=strtok( NULL, "\"" );
			if (p!=NULL) { strcpy( file, p ); }
		}
	}
	if (display) {
		if ((is_encoded)&&(file[0]!='\0')) {
			found=1;
			sprintf( q, "Attachment: %s (Base64) ", file );
			while (fgets( a, 100, fid )!=NULL) {
				if (memcmp( a, "---", 3 )==0) { break; }
				windows[wx].num_lines--;
			}
			is_encoded = 0 ;	/* reset indicator */
			file[0] = '\0';		/* reset filename */
			set_vslider_size( windows[wx].id, windows[wx].lines_per_page, windows[wx].num_lines );
		}
	}
	return(found);	/* <0, don't display */
}

int generic_detect_display_b64encoded( FILE *fid, char *q, int wx )
{
	return( generic_b64encoded( fid, q, wx, 1 ));	/* detect and display */
}

int generic_detect_b64encoded( FILE *fid, char *q, int wx )
{
	return( generic_b64encoded( fid, q, wx, 0 ));	/* detect only */
}

void get_MIME_boundary( char *q, char *boundary, size_t *blen )
{
	char *t;
	char temp[200];

	if (memcmp(q, "Content-Type:", 13)==0) {
		strcpy( temp, q );
		strlwr( temp );
		if ((t=strstr(temp, "boundary="))!=NULL) {	/* look for boundary */
			if (*(t+9)=='\"') { t+=1; }
			strcpy( boundary, "--" );	/* watch pointer arithmetic! */
			strcpy( boundary+2, (q-temp+t+9) );	/* copy original boundary */
			strtok( boundary, ";\"\n" );	/* truncate trailing ", semi-colon, or newline */
			*blen = strlen(boundary);
		/*	fprintf( log, "boundary=%s, len=%ld\n", boundary, *blen ); */
		}
	}
}

void get_MIME_charset( char *q, char *charset )
{
	char *t;
	char temp[180];

	if (memcmp(q, "Content-Type:", 13)==0) {
		strcpy( temp, q );
		strlwr( temp );
	/*	if (strstr(temp, "text/plain;")!=NULL) { */
			if ((t=strstr(temp, "charset="))!=NULL) {
				if (*(t+8)=='\"') { t+=1; }
				strtok( t+8, ";\"\n" );		/* truncate trailing ", semi-colon, or newline */
				strcpy( charset, t+8 );		/* copy character set */
			/*	fprintf( log, "charset=%s\n", charset ); */
			}
	/*	} */
	}
}

int generic_window_build_buffer( int wx, char *filename )
{
	FILE *fid;
	struct FILEINFO info;
	size_t c,overage;	/*,left;*/
	unsigned char *p,*q,*buff;
	int in_header=1,MIME=0;
	char charset[30],boundary[180]="";
	size_t blen=0;
	int html=0;

	if (prefs.window_buffers!='Y') { return(0); }
	if (dfind(&info, filename, 0)) { return(0); } 	/* file not found */
	overage = (info.size/10)+100;
	overage+= info.size;
/*	if (overage<10000) { overage=10000; } */
	buff = calloc( overage, sizeof(char) );	/* allocate buffer */
	if (buff==NULL) { return(0); }				/* insufficient memory */

/*	windows[wx].buffer = calloc( 1, overage );	/* allocate buffer */
/*	fprintf( log, "Allocating %ld bytes\n", overage ); fflush( log ); */
	fid = fopen( filename, "ra" );
	if (fid!=NULL) {		/* file file exists... */
		graf_mouse( M_ON, NULL );
		graf_mouse( BUSY_BEE, NULL );
		p=buff;
		q=p;
	/*	left=overage;		/* space left */
		while (q!=NULL) {
			q=fgets( p, 1000, fid );	/* was left */
			if ( q!=NULL) {
				if (*q=='\n') {	/* for "empty" lines */
					if (MIME&&(in_header&&boundary[0]!='\0')) {	/* end of header w/MIME boundary? */
						while(memcmp(q,boundary, blen)!=0) {		/* while no matching boundary */
							if (fgets( q, 1000, fid )==NULL) { break; }	/* read until found */
						}
					}
					in_header=0;
					sprintf( q, " \n" );
				}

				if (in_header) {
					if (strnicmp(q, "MIME-Version:", 13)==0) { MIME++; }
					if (MIME) {
						get_MIME_boundary( q, boundary, &blen );	/* check for multipart boundary */
						get_MIME_charset( q, charset );	/* look for MIME charset= parameter */
						if (generic_detect_b64encoded( fid, q, wx )<0) { continue; }
					}
				}

				if (!in_header) {
					if (strnicmp(q, "<HTML>", 6)==0) { html++; }
					if (MIME) {
						if (boundary[0]!='\0') {
							if (memcmp(boundary, q, blen)==0) { continue; }	/* skip boundary line display*/
						}
						get_MIME_charset( q, charset );	/* look for MIME charset= parameter */
						if (generic_detect_display_b64encoded( fid, q, wx )<0) { continue; }
					}
					generic_detect_uuencoded( fid, q, wx ); /* for MIME too! */
				}

				if (generic_hide_headers( windows[wx].id, q, in_header )) { continue; }

				c = strlen(q);	/* includes \n at end */
				if (c>256) { c=256; }
				*(q+c-1)='\0';	/* overlay '\n' at end */
				/* do some editing stuff */
				while (*q) { if (*q<' ') *q=' '; q++; }
				p+=c;
			/*	left-=c;
			/*	if (left<=0) { break; } */
				if (p>(buff+info.size)) {
					fprintf( log, "Pointer past allocated %ld bytes buffer[%d] at %p\n", info.size, wx, p );
					fflush( log );
					break;
				}
			}
		}
	/*	fprintf( log, "Size of file: %ld bytes, used: %ld bytes\n", info.size, p-buff ); */
		fflush( log );
		fclose( fid );
		graf_mouse( ARROW, NULL );
 		graf_mouse( M_OFF, NULL );
	}
/*	free( buff ); */
	windows[wx].buffer = buff;	/* allocate buffer */
	return( html );	/* return value indicates <HTML> formatting */
}

void generic_window_buffer_text( int wx, int x, int y, int lpp )
{
	int c;
	register char *p,*buff;

	p=windows[wx].buffer;
	for (c=0;c<windows[wx].line_no;c++) { /* skip some lines */
		buff = p;		/* start of line */
		while (*p) { p++; }	/* scan to end of string */
		if (p!=buff) { p++; }	/* bump to next start */
	}
	for (c=0;c<lpp;c++) {
		buff = p;		/* start of line */
		while (*p) { p++; }	/* scan to end of string */
		if (p!=buff) { p++; }	/* bump to next start */
		if (*buff) {
			if (memcmp(buff,"Attachment:",11)==0) {	vst_color( handle, BLUE ); }	/* set text color */
			v_gtext( handle, x, y+cellh, buff );
			if (memcmp(buff,"Attachment:",11)==0) {	vst_color( handle, BLACK ); }	/* reset text color */
			if ((wx==3)||(wx==7)) { generic_mark_url( wx, x, y, buff ); }
			y+=cellh;
		}
	/*	if (*buff) { v_gtext( handle, x, y+=cellh, buff ); } */
	}
}

char * generic_get_line( char *buff, int line_no )
{
	register char *p;

	p = buff;
	while (p!=NULL) {
		if (line_no==0) { break; }
		while (*p++);	/* skip over text */
		line_no--;	/* 1 less line to go */
	}
	return( p );
}

int generic_upline( int wx, GRECT work, int lpp )
{
	char *theline,*p;

/*	copy buffer down, insert line_no at top */
	if ((p=windows[wx].buffer)!=NULL) {
		screen_copy(work.g_x, work.g_y, work.g_w, (lpp-1)*cellh+1, work.g_x, work.g_y + cellh );
		theline = generic_get_line( p, windows[wx].line_no );
		work.g_h=cellh;
		clear_rect( &work );
		v_gtext( handle, work.g_x, work.g_y+cellh, theline );
		if ((wx==3)||(wx==7)) { generic_mark_url( wx, work.g_x, work.g_y, theline  ); }
		return(1);
	}
	return(0);
}
		
int generic_downline( int wx, GRECT work, int lpp )
{
	char *theline,*p;
	int newy,newh;

/*	copy buffer up, insert line_no+lpp-1 at bottom (zero-based) */
	if ((p=windows[wx].buffer)!=NULL) {
		newh = (lpp-1)*cellh;
		screen_copy(work.g_x, work.g_y+cellh, work.g_w, newh+1, work.g_x, work.g_y );
		theline = generic_get_line( p, windows[wx].line_no+lpp-1 );
		newy = work.g_y+newh;
		work.g_h = cellh+1;	/* was cellh+1 */
		work.g_y = newy;	
		clear_rect( &work );
		v_gtext( handle, work.g_x, newy+cellh, theline );
		if ((wx==3)||(wx==7)) { generic_mark_url( wx, work.g_x, newy, theline  ); }
		return(1);
	}
	return(0);
}

void screen_copy(int x_src, int y_src, int w_src, int h_src, int x_dst, int y_dst)
{
	MFDB nul={0};
	int pxy[8];
	
	/* zone source */
	pxy[0] = x_src;
	pxy[1] = y_src;
	pxy[2] = pxy[0] + w_src - 1;
	pxy[3] = pxy[1] + h_src - 1;
	/* zone dest */
	pxy[4] = x_dst;
	pxy[5] = y_dst;
	pxy[6] = pxy[4] + w_src - 1;
	pxy[7] = pxy[5] + h_src - 1;
	
	vro_cpyfm (handle, S_ONLY, pxy, &nul, &nul);	/* S_ONLY = 3? */
}


int  generic_hide_headers( int wid, char *buff, int in_header )
{
	int ret=0;
	char temp[22];

	/* handle hiding header lines in e-mail and news
		uses prefs.show_headers
		only effective for windows[3] (article) and [7] (mail)
		displays all "body" text
		displays only "From:", "Reply-To:", "Subject:", and "Date:" headers when show_headers='N'
		temporary display of "X-Newsreader: NEWSie", and "X-Mailer: NEWSie"
	*/
	if (prefs.show_headers=='N') {
		if (in_header) {
			if ((wid==windows[3].id)||(wid==windows[7].id)) {
				memcpy( temp, buff, 20 );
				temp[20]='\0';
				if (temp[0]!='X') { strtoka( temp, ' '); }
			/*	strtoka( temp, ' '); */
				if ((strcmpi( temp, "From:")!=0) &&
					(strcmpi( temp, "To:")!=0) &&
					(strcmpi( temp, "Cc:")!=0) &&
					(strcmpi( temp, "Reply-To:")!=0) &&
					(strcmpi( temp, "NewsGroups:")!=0) &&
					(strcmpi( temp, "Subject:")!=0) &&
					(memcmp( temp, "X-Mailer: NEWSie", 16)!=0) &&
					(memcmp( temp, "X-Newsreader: NEWSie", 20)!=0) &&
					(strcmpi( temp, "Date:")!=0)) {
						{ ret++; }	/* dump this line */
				}
			}
		}
	}
	return(ret);
}

void generic_window_text( int wid, char *filename )
{
	GRECT work;
	int x,y,c,wx,lpp;
	FILE *fid;
	unsigned char *p, buff[1000];
	OBJECT *bar;
	int in_header=1,html=0;

	wx = windows_index(wid);
	x = wind_get( wid, WF_WORKXYWH, &work.g_x, &work.g_y, &work.g_w, &work.g_h);
	setup_toolbar(wx, &work.g_x, &work.g_y, &work.g_w, &work.g_h );
	lpp = setup_text( wid, wx, prefs.news_font, prefs.news_font_size,
				work.g_h, windows[wx].num_lines ); 
	y=work.g_y;

	if (windows[wx].line_no==windows[wx].prev_line_no+1) {
		if (generic_downline( wx, work, lpp )) return;
	}
	if (windows[wx].line_no==windows[wx].prev_line_no-1) {
		if (generic_upline( wx, work, lpp ))	return;
	}

	if (windows[wx].clear) {
		clear_rect( &work);
		if ((bar=windows[wx].bar_object)!=NULL) {
			objc_draw( bar, ROOT, 1, clip.g_x, clip.g_y, clip.g_w, clip.g_h );
		}
	}

/*	if (wx!=9) { 0.962 */
		if (windows[wx].buffer==NULL) {
			html = generic_window_build_buffer( wx, filename );
			if ((html)&&(prefs.experimental[3]!='N')&&(wx==7)) {	/* experimental html formatting */
				sprintf( buff, "html:///%s", filename );
				open_url_path( buff );		/* open in browser window */
			}
		}
/*	} */
	if (windows[wx].buffer!=NULL)  {
		generic_window_buffer_text( wx, work.g_x, work.g_y, lpp );
#if (0)
		if ((html)&&(prefs.experimental[3]!='N')) {	/* experimental html formatting */
			browser_text_html( windows[12].id, filename );
		}
#endif
		return;
	}

	fid = fopen( filename, "ra" );
	if (fid!=NULL) {		/* file file exists... */
		for (c=0;c<windows[wx].line_no;c++) { /* skip some lines */
			p=fgets( buff, sizeof(buff), fid );
			if (buff[0]=='\n') in_header=0;
		}
		for (c=0;c<lpp;c++) {
			p=fgets( buff, sizeof(buff), fid );
			if (buff[0]=='\n') in_header=0;
			if ( p!=NULL) {
				if (generic_hide_headers( wid, buff, in_header )) { c--; continue; }

				if (strlen(buff)>256) { buff[255]='\0'; }
				x=0;
				while(buff[x]!='\0') {
					if (buff[x]<' ') buff[x]=' ';
					x++; }
				v_gtext( handle, work.g_x, y+=cellh, buff );
			}
		} 
		fclose( fid );
	}
}

int appl_running(char *prog, int aes_id)
{
	int rc,type,id;

	rc = appl_search(0, prog, &type, &id);
	while (rc) {
		if (id==aes_id) { rc=id; break; }
		rc = appl_search(1, prog, &type, &id);
	}
	return(rc);
}

void wait_window_closed( int aes_id, int wid )
{
	int x,y;

	if (wid) {	
	/*	fprintf( log, "Waiting for edit window to close\n" ); */
		while (1) {
			if (!wind_get( wid, WF_OWNER, &x, &y, NULL, NULL )) { break; }
			if ((x==aes_id)&&(y!=1)) { break; }
			if (x!=aes_id) { break; }
			handle_possible_events();
			if (finished) { break; }
		}
	}
}

int validate_VA_START_window( int owner_id, int oldtop )
{
	long to;
	int tmp,owner,newtop=0;

	evnt_timer( 2000, 0 );		/* wait 2 seconds */
	to=clock()+(CLK_TCK*3);		/* 3 second timeout */
	while (clock()<to) {
		handle_possible_events();
		wind_get( 0, WF_TOP, &tmp, &owner, NULL, NULL );
		if (tmp!=oldtop) {
		/*	fprintf( log, "Window %d, Owner %d\n", tmp, owner ); */
			if (owner==owner_id) { newtop=tmp; break; }
		}
	}
/*	if (newtop)	fprintf( log, "VA_START window opened\n" ); */
	return(newtop);
}

void send_VA_Start( int aes_id, char *path )
{
	int mbuff[8];
	long *p;

	mbuff[0] = VA_START;
	mbuff[1] = _AESglobal[2];
	mbuff[2] = 0;
	p=(long *)&mbuff[3];	/* command line in mbuff[3 & 4] */
	*p=(long)path;
	appl_write( aes_id, 16, &mbuff );	/* send message */
}

void send_AV_SendKey( int keystate, int keycode )
{
	int mbuff[8];
	int aes_id;
	char *env;

	if ((env = getenv( "AVSERVER" ))==NULL) { return; }
	if ((aes_id=appl_find( env ))==-1) { return; }

	mbuff[0] = AV_SENDKEY;
	mbuff[1] = _AESglobal[2];
	mbuff[2] = 0;
	mbuff[3] = keystate;
	mbuff[4] = keycode;
	appl_write( aes_id, 16, &mbuff );	/* send message */
	if (log) fprintf( log, "Sending key to AVSERVER=%s id=%d\n", env, aes_id );
}

int call_external_editor(char *article, char *editorpath, int wait)
{
	int rc=0,top,wid;
	long cook,MagX=0x4d616758;	/* "MagX" */
	char tail[FMSIZE],path[FMSIZE],temp[FMSIZE],prog[FMSIZE];

	if ( MT ) {
		stcgfp( temp, editorpath );
		sprintf( path, "%s\\", temp );
	/*	rc = chdir( path );
		if (rc) {
			fprintf( log, "chdir(%s) %d %d %d\n", path, rc, errno, _OSERR );
		} */
		stcgfn( temp, editorpath );
		strtok( temp, "." );
		sprintf( prog, "%-8.8s", temp );
		strcpy( tail+1, article );
		tail[0] = strlen(article);

		if ((rc=appl_find( prog ))!=-1) {
			if (!wait) {
			/*	fprintf( log, "Sending %s(%d) a VA_START for %s\n", prog, rc, article ); */
				send_VA_Start( rc, article );
				return(rc);
			} else {
				wind_get( 0, WF_TOP, &top, NULL, NULL, NULL );
			/*	fprintf( log, "Sending %s(%d) a VA_START for %s\n", prog, rc, article ); */
				send_VA_Start( rc, article );
				if ((wid=validate_VA_START_window( rc, top ))>0) {
					wait_window_closed( rc, wid );	/* if window opened, wait for close */
					return(rc);
				}
			}
		}
		if (getcookie( MagX, &cook )) {
			rc = shel_write( 1, 1, 100, editorpath, tail );
		} else {
			rc = shel_write( 1, 1, 100, editorpath, tail );
		}
		if (!wait) { return(rc); }

		if (rc>0) {
			evnt_timer( 2000, 0 );		/* wait 2 seconds */
			radio = rc;
			while (rc==radio) {
				handle_possible_events();
				if (finished) break;
				if (appl_find( prog )==-1) break;
				if (appl_running( prog, rc )==0) break;
			}
		} else {
		/*	fprintf( log, "aes id=%ld\n", rc ); */
			show_warning( ErrMsg(EM_ExtEditNFound) );	/* External Editor not Found */
			status_text( ErrMsg(EM_CheckPathPref) );	/* Check Path Preferences */
			evnt_timer( 2000, 0 );		/* wait 2 seconds */
			hide_status();
		}
	/*	chdir( program_path ); */
	} else {
		rc = call_single_editor(article, editorpath);
	}
	return(rc);
}

int call_editor( char *article, char *editorpath )
{
	return( call_external_editor( article, editorpath, 1 ) );	/* wait */
}

int call_editor_nowait( char *article, char *editorpath )
{
	return( call_external_editor( article, editorpath, 0 ) );	/* no wait */
}

int call_single_editor(char *article, char *editorpath)
{
	int rc;
	char prog[FMSIZE],path[FMSIZE],temp[FMSIZE];
	int mobj[MAX_MENU_ITEM+1];
	int top,c;

	wind_get( 0, WF_TOP, &top, NULL, NULL, NULL );
	for (c=20;c<MAX_MENU_ITEM+1;c++) { mobj[c]=menu_ptr[c].ob_state; }
	deinitialize_gem();

	stcgfp( temp, editorpath );
	sprintf( path, "%s\\", temp );
	rc = chdir( path );
	if (rc) {
		fprintf( log, "chdir(%s) %d %d %d\n", path, rc, errno, _OSERR );
	}
	stcgfn( prog, editorpath );
	rc = spawnl( P_WAIT, prog, prog, article, NULL );
	if (rc==-1) {
		fprintf( log, "%s %d %d\n", prog, errno, _OSERR );
		show_warning( ErrMsg(EM_ExtEditNFound) );	/* External Editor not Found */
		status_text( ErrMsg(EM_CheckPathPref) );	/* Check Path Preferences */
		evnt_timer( 2000, 0 );		/* wait 2 seconds */
		hide_status();
	}
	chdir( program_path );
	initialize_gem(1);
	for (c=20;c<MAX_MENU_ITEM+1;c++) { menu_ptr[c].ob_state=mobj[c]; }
	reopen_windows( top );
	return(rc);
}

int w_redraw( int hand, GRECT *box )
{
	char path[FMSIZE];

	set_clip( box );
	clip.g_x = box->g_x;	/* copy clipping rectangle */
	clip.g_y = box->g_y;
	clip.g_w = box->g_w;
	clip.g_h = box->g_h;
	if (hand==windows[0].id) { redraw_status( box ); }
	if (hand==windows[1].id) { group_text( hand ); }
	if (hand==windows[2].id) { overview_text( hand ); }
	if (hand==windows[3].id) { article_text( hand, current_article ); }
	if (hand==windows[4].id) {
		sprintf( path, "%s\\%s", prefs.work_path, "fullgrp.txt" ); 
		full_group_text( hand, path );
	}
	if (hand==windows[5].id) {
		sprintf( path, "%s\\%s", prefs.work_path, "newgrp.txt" );
		new_group_text( hand, path );
	}
	if (hand==windows[6].id) { mailbox_text( hand ); }
	if (hand==windows[7].id) { mail_text( hand, current_mailmsg ); }
	if (hand==windows[8].id) { help_text( hand, current_helpfile ); }
	if (hand==windows[9].id) {
		sprintf( path, "%s\\%s", prefs.work_path, "log" );
		log_text( hand, path );
	}
	if (hand==windows[10].id) { ftp_viewer_text( hand, ftp_viewer_path ); }
	if (hand==windows[11].id) { ftp_text( hand ); }
	if (hand==windows[12].id) { browser_text( hand, current_browse ); }
	if (hand==windows[14].id) { address_book_text( hand ); }
	vs_clip(handle, 0, NULL);
	return(1);
}

int windows_index(int wid)
{
	int x,w=0;

	for (x=1;x<WINDOWS_SIZE;x++) {
		if (windows[x].id==wid) { w = x; break; }
	}
	return(w);
}

void refresh_window(int wid)
{
	int x,msg[8];

	if (wid<=0) { return; }
	msg[0] = WM_REDRAW;
	msg[1] = _AESglobal[2];
	x = windows_index(wid);
	if (windows[x].clear) { msg[2]=0; } else { msg[2]=45; }
	msg[3] = wid;
	x = wind_get( wid, WF_WORKXYWH, &msg[4], &msg[5], &msg[6], &msg[7] );
	if (_AESglobal[0]>0x0140) {	/* greater than TOS 1.62? */
		appl_write( msg[1], 16, &msg );	/* write message to event queue */
	} else {
		do_message_events( msg );	/* handle the message now */
	}
/*	appl_write( msg[1], 16, &msg ); */
}

void refresh_clear_window(int wid)
{
	int wx;

	if (wid<=0) { return; }
	wx = windows_index(wid);
	windows[wx].clear=1;
	refresh_window(wid);
}

void refresh_multiple_lines_window(int wid)
{
	int wx;

	if (wid<=0) { return; }
	wx = windows_index(wid);
	windows[wx].clear=2;
	refresh_window(wid);
}

void refresh_window_fonts( char *nfont, char *nsize, char *font, char *size, int which )
{
	int winds[] = {0,1,2,3,3,3,2,3,3,3,3,2,3,3,2,3,3,3};
	int c;

	if ((strcmp(font,nfont)==0)&&(strcmp(size,nsize)==0)) return;
	for (c=1;c<WINDOWS_SIZE;c++) {
		if (winds[c]==which) {
			refresh_clear_window( windows[c].id );
			handle_redraw_event();
		}
	}
}

void cycle_windows()
{
	int c,w,x,top;

	wind_get( 0, WF_TOP, &top, NULL, NULL, NULL );
	if (top==0) { return; }

	w = windows_index(top);
	for (c=1;c<WINDOWS_SIZE;c++) {
		x=c+w;
		if (x>=WINDOWS_SIZE) { x-=WINDOWS_SIZE; }
		if (windows[x].open) {
			wind_set( windows[x].id, WF_TOP, 0, 0, 0, 0 );
			set_menu_list( x );
			return;
		}
	}
}

void log_msg_status( long num, long value )
{
	char ms[] = "Message Status:";
	char msg[80];

	switch (num) 
	{
	case 0:	fprintf( log, "%s %s\n", ms, get_err_text( (int16)value ) ); break;
	case 1:	fprintf( log, "%s %s\n", ms, ErrMsg(EM_Connect) ); break;
	case 2:	
		sprintf( msg, "%s %s\n", ms, ErrMsg(EM_ReceiveData) ); 
		fprintf( log, msg, value );
		break;
	case 3:	fprintf( log, "%s %s\n", ms, ErrMsg(EM_WaitResponse) ); break;	
	case 4:	fprintf( log, "%s %s\n", ms, ErrMsg(EM_ResolveHost) ); break;
	case 5:	fprintf( log, "%s %s\n", ms, ErrMsg(EM_SendRequest) ); break;
	case 6:	fprintf( log, "%s %s\n", ms, ErrMsg(EM_FormatText) ); break;
	case 7:	fprintf( log, "%s %s\n", ms, ErrMsg(EM_ConvertImage) ); break;
	case 8:	
		sprintf( msg, "%s %s\n", ms, ErrMsg(EM_TransmitData) ); 
		fprintf( log, msg, value );
		break;
	}
}

void spinner()
{
/*	graf_mouse( 255, &spmse[++sppos%4] ); */
	graf_mouse( fakemse[++sppos%3], NULL );
}

void no_msg_status( long num, long value )
{
	spinner();		/* spin the mouse */
}

int use_status( int wx )
{
	static int wind[8]={0,0,0,0,0,0,0,0};	/* initialize status */
	static int index=0;

	if (prefs.use_info_status!='Y') { return(0); }
	if (wx==-1) {	/* return current status - status_window() */
		return( wind[index] );
	}
	if (wx==-2) {	/* pop_status() and return previous */
		if (index>0) { index--; }
		return( wind[index] );
	}
	if (wx<0) { return(0); }
	if (wx>=WINDOWS_SIZE) { return(0); }

	/* valid input, push index, and store */
	if (index<7) { index++; }
	return( wind[index]=wx );
}

#define status_window() use_status(-1)
#define pop_status() use_status(-2)


void disp_msg_status( long num, long value )
{
	char msg[80];

	switch (num) 
	{
	case 0:	sprintf( msg, "%s", get_err_text( (int16)value ) ); break;
	case 1:	sprintf( msg, ErrMsg(EM_Connect) ); break;
	case 2:	sprintf( msg, ErrMsg(EM_ReceiveData), value ); break;
	case 3:	sprintf( msg, ErrMsg(EM_WaitResponse) ); break;	
	case 4:	sprintf( msg, ErrMsg(EM_ResolveHost) ); break;
	case 5:	sprintf( msg, ErrMsg(EM_SendRequest) ); break;
	case 6:	sprintf( msg, ErrMsg(EM_FormatText) ); break;
	case 7:	sprintf( msg, ErrMsg(EM_ConvertImage) ); break;
	case 8:	sprintf( msg, ErrMsg(EM_TransmitData), value ); break;
	}
	if (info_line( status_window(), msg )) {	/* update info line only */
		spinner();
		return;
	}

	msg[30]='\0';	/* truncate at 30 characters */
	set_tedinfo( sd, NS_StatusMsg, msg );
	if (windows[0].id<0) {
		objc_draw(sd,NS_StatusMsg,0,sx,sy,sw,sh);
	} else {
		refresh_window( windows[0].id );
		handle_redraw_event();
	}
	spinner();			/* spin the mouse */
		
	if (num==0) { evnt_timer( 2000, 0 ); }	/* wait 2 seconds */
}

void show_status(char *activity)
{
	OBJECT *dlog;
	short x,y,w,h;
	
	if (prefs.show_status!='Y') {
		in.msg_status = no_msg_status;
		sd = NULL;			/* no display allowed */
		return;
	}
	if (info_line( status_window(), activity )) {	/* update info line only */
		in.msg_status = disp_msg_status;
		sd = NULL;
		return;
	}

	rsrc_gaddr(R_TREE,News_Status,&dlog);
	set_tedinfo( dlog, NS_Activity, activity );
	set_tedinfo( dlog, NS_StatusMsg, "" );
	if (windows[0].id>0) {
		refresh_clear_window( windows[0].id );
		handle_redraw_event();
		return;
	}
	form_center(dlog,&x,&y,&w,&h);
	new_window( 0, activity, x, y, w, h );
	windows[0].clear=1;
	if (windows[0].id<0) {
		form_dial(FMD_START,0,0,0,0,x,y,w,h);
	} else {
		wind_get( windows[0].id, WF_CURRXYWH, &dlog->ob_x, &dlog->ob_y, &dlog->ob_width, &dlog->ob_height );
		wind_get( windows[0].id, WF_CURRXYWH, &x, &y, &w, &h );
	}

/*	form_dial(FMD_GROW,x+w/2,y+h/2,0,0,x,y,w,h); */
	objc_draw(dlog,0,10,x,y,w,h);

	sd = dlog;
	objc_offset( sd, NS_StatusMsg, &sx, &sy );		/* StatusMsg */
	sw = sd[NS_StatusMsg].ob_width;
	sh = sd[NS_StatusMsg].ob_height;
	in.msg_status = disp_msg_status;
}

void show_warning(char *activity)
{
	OBJECT *dlog;
	
	rsrc_gaddr(R_TREE,News_Status,&dlog);
	dlog[NS_Esc].ob_flags|=HIDETREE;
	show_status( activity );
}

void show_window_status( int wx, char *text )
{
	use_status( wx );
	show_status( text );
}

void redraw_status( GRECT *box )
{
	OBJECT *dlog;
	GRECT area;

	if (windows[0].clear) {
		rsrc_gaddr(R_TREE,News_Status,&dlog);
		area.g_x=dlog->ob_x;
		area.g_y=dlog->ob_y;
		area.g_w=dlog->ob_width;
		area.g_h=dlog->ob_height;
		if (rc_intersect( box, &area )) {
			objc_draw(dlog,0,10,area.g_x,area.g_y,area.g_w,area.g_h); }
	} else {
		area.g_x=sx;
		area.g_y=sy;
		area.g_w=sw;
		area.g_h=sh;
		if (rc_intersect( box, &area )) {
			objc_draw(sd,NS_StatusMsg,0,area.g_x,area.g_y,area.g_w,area.g_h); }
	}
}

void hide_status(void)
{
	OBJECT *dlog;
	short x,y,w,h;

	if (sd!=NULL) { 
		sd[NS_Esc].ob_flags&=~HIDETREE; 	/* make visible again */
	}
	if (windows[0].open) {
		wind_close( windows[0].id );
		windows[0].open=0;
		delete_window( windows[0].id );
		windows[0].id=-1;
		sd = NULL;
	}
	if (sd!=NULL) { 
		rsrc_gaddr(R_TREE,News_Status,&dlog);
		form_center(dlog,&x,&y,&w,&h);
	/*	form_dial(FMD_SHRINK,x+w/2,y+h/2,0,0,x,y,w,h); */
		form_dial(FMD_FINISH,0,0,0,0,x,y,w,h);
	}
	info_line( status_window(), "" );	/* clear info line */
	pop_status();
	in.msg_status = log_msg_status;
	graf_mouse( ARROW, NULL );
}

void status_text_nolog(char *msg)
{
	if (info_line( status_window(), msg )) { return; }
	if (sd!=NULL) {
		set_tedinfo( sd, NS_StatusMsg, msg );
		refresh_window( windows[0].id );
		handle_redraw_event();
	}
}

void status_text(char *msg)
{
	if (info_line( status_window(), msg )) { return; }
	if (sd!=NULL) {
		set_tedinfo( sd, NS_StatusMsg, msg );
		refresh_window( windows[0].id );
		handle_redraw_event();
		fprintf( log, "%s\n", msg );
	}
}

void set_vslider(int wx, int wid)
{
	long pos=1;

	if ((windows[wx].num_lines - windows[wx].lines_per_page)>1) {
		pos = 1000 * (long)windows[wx].line_no / (long)(windows[wx].num_lines - windows[wx].lines_per_page);
	}
	if (pos<1) { pos = 1; }
	wind_set( wid, WF_VSLIDE, (int)pos, 0, 0, 0 );
	/*	fprintf( log, "Slider Pos %d %d %d %d %ld\n", w, windows[wx].lines_per_page,
			windows[wx].line_no, windows[wx].num_lines, pos ); */
}

void handle_arrows(int wid, int action )
{
	int wx,refresh=0;

	wx = windows_index(wid);
	switch(action)
	{
		case WA_UPPAGE:
			if (windows[wx].line_no>0) {
				windows[wx].prev_line_no = windows[wx].line_no;
				windows[wx].line_no-=windows[wx].lines_per_page;
				if (windows[wx].line_no<0) { windows[wx].line_no=0; }
				refresh = TRUE;
			}
			break;
		case WA_DNPAGE:
			if ((windows[wx].line_no+windows[wx].lines_per_page)<windows[wx].num_lines) {
				windows[wx].prev_line_no = windows[wx].line_no;
				windows[wx].line_no+=windows[wx].lines_per_page;
				refresh = TRUE;
			}
			break;
		case WA_UPLINE:
			if (windows[wx].line_no>0) {
			/*	windows[wx].prev_line_no = windows[wx].line_no; */
				if (windows[wx].prev_line_no!=windows[wx].line_no) break;
				windows[wx].line_no--;
				refresh = TRUE;
			}
			break;
		case WA_DNLINE:
			if ((windows[wx].line_no+windows[wx].lines_per_page)<windows[wx].num_lines) {
			/*	windows[wx].prev_line_no = windows[wx].line_no; */
				if (windows[wx].prev_line_no!=windows[wx].line_no) break;
				windows[wx].line_no++;
				refresh = TRUE;
			}
			break;
		case WA_TOP:
			if (windows[wx].line_no>0) {
				windows[wx].prev_line_no = windows[wx].line_no;
				windows[wx].line_no=0;
				refresh = TRUE;
			}
			break;
		case WA_BOTTOM:
			if (windows[wx].line_no<windows[wx].num_lines-windows[wx].lines_per_page) {
				windows[wx].prev_line_no = windows[wx].line_no;
				windows[wx].line_no=windows[wx].num_lines-windows[wx].lines_per_page;
				refresh = TRUE;
			}
			break;
	}
	if (refresh) {
		windows[wx].reread = 1;
		set_vslider( wx, windows[wx].id );
		refresh_clear_window( windows[wx].id );
	}
}

void handle_slider(int wid, int newpos )
{
	int wx,npos,refresh=0;
	long lineno;

	wind_get( wid, WF_VSLIDE, &npos, NULL, NULL, NULL );
	if (npos==newpos) { return; }

	npos = newpos;
	if (npos<1) {npos = 1;}
	wind_set( wid, WF_VSLIDE, npos, 0, 0, 0 );
	wx = windows_index(wid);
	lineno = (long)npos * (long)(windows[wx].num_lines - windows[wx].lines_per_page) / 1000;
	if (lineno<0) { lineno = 0; }		/* no non-positive line numbers please */
/*	fprintf( log, "Slider New %d %d %d %d %d %ld\n", wx, windows[wx].lines_per_page,
		windows[wx].line_no, windows[wx].num_lines, npos, lineno ); */
	refresh = TRUE;
	windows[wx].line_no = (int)lineno;
	windows[wx].reread = 1;
	refresh_clear_window( windows[wx].id );
}

void handle_full(int wid)
{
	int wx;

	wx = windows_index(wid);
	windows[wx].full = !windows[wx].full;
	windows[wx].clear = 1;
	if (windows[wx].full) {
		wind_set( wid, WF_CXYWH, screenx, screeny, screenw, screenh );
	} else {
		wind_set( wid, WF_CXYWH, windows[wx].x, windows[wx].y, windows[wx].w, windows[wx].h  );
	}
	set_vslider( wx, windows[wx].id );
	refresh_clear_window( windows[wx].id );
}

void handle_draw_icon(int *mbuff)
{
	OBJECT *tree;
	int rc;

	rsrc_gaddr(R_TREE,NEWSie_Icon,&tree);
	rc = objc_draw( tree, 1, 1, mbuff[4], mbuff[5], mbuff[6], mbuff[7] );
}

int find_text_mailbox(int wx, char start, char *key)
{
	int found=0,line;
	char *where;

	if (start=='Y') { line=0; } else { line=current_mail+1; }
	while (line<maximum_mail+1) {
		if (stcpm( mailbox[line].subject, key, &where )) { found=1; break; }
		if (stcpm( mailbox[line].author,  key, &where )) { found=1; break; }
		if (stcpm( mailbox[line].author_email,  key, &where )) { found=1; break; }
		line++;
	}
	if (found) {
		if ((line<windows[wx].line_no)||(line>=windows[wx].line_no+windows[wx].lines_per_page)) {
			windows[wx].line_no = line;
		} else {
			found=2;	/* on same page, no erase needed */
		}
	/*	windows[wx].line_no = line; */
		previous_mail=current_mail;
		current_mail=line;
		strcpy( current_mailmsg, mailbox[current_mail].filename );
		set_reply( wx );
	}
	return(found);
}

int find_text_overview(int wx, char start, char *key)
{
	int found=0,line,thr;
	char *where;

	if (start=='Y') { line=0; } else { line=current_thread+1; }
	while ((thr=threads[line].zero)>=0) {
		if (stcpm( overview[thr].subject, key, &where )) { found=1; break; }
		if (stcpm( overview[thr].author,  key, &where )) { found=1; break; }
		if (stcpm( overview[thr].author_email,  key, &where )) { found=1; break; }
		line++;
	}
	if (found) {
		if ((line<windows[wx].line_no)||(line>=windows[wx].line_no+windows[wx].lines_per_page)) {
			windows[wx].line_no = line;
		} else {
			found=2;	/* on same page, no erase needed */
		}
	/*	current_thread = windows[wx].line_no = line; */
		current_thread   = line;
		previous_overview=current_overview;
		current_overview=thr;
	}
	return(found);
}

int find_text_generic(int wx, char start, char *key)
{
	int found=0,line;
	char *p,*where;
	static char *pbuff,*pwhere;	/* where was I last time? */
	static int pw,pline;

	if ((p=windows[wx].buffer)!=NULL) {
		if ((p!=pbuff)||(wx!=pw)) {	/* if buffer has moved, or different window */
			pbuff=p;
			pwhere=p;
			pw=wx;
			pline=0;
		}
		graf_mouse( BUSY_BEE, NULL );
		if (start=='Y') {
			line=0; pwhere=p;
		} else {
			if (pline>windows[wx].line_no) { pwhere=p; }
			if (p<pwhere) {	/* in same line as last time? */
				 p=pwhere; line=pline;
			} else {
				line=windows[wx].line_no;
				p = generic_get_line( p, line );
			}
		}
		do {
			if (stcpm( p, key, &where )) {
				found=1;
				pline = windows[wx].line_no = line;
				pwhere = where + strlen( key );
			/*	windows[wx].prev_line_no = 0;	/* force full refresh */
				break;
			}
			line++;
			while (*p++);	/* next line */
		} while (*p);
		graf_mouse( ARROW, NULL );
	}
	return(found);
}

void find_text(int show)
{
	OBJECT *dlog;
	static char find[40]="";
	char starttop='N';
	int top,wx,found=0;

	wind_get( 0, WF_TOP, &top, NULL, NULL, NULL );
	wx = windows_index( top );
	if (wx==4) { key_fullgroups('s'); return; }	/* support for fullgroups */
	if (wx==5) { key_newgroups('s');  return; }	/* support for newgroups  */

	if (show) { /* no show same as find next, find again, i.e. no dialog */
	 	rsrc_gaddr( R_TREE, Find_NewsGroup, &dlog );
		set_tedinfo( dlog, S_Keyword, find );
	/*	set_crossed( dlog, S_StartBegin, 0 ); */
		if (handle_dialog( dlog, S_Keyword )!=S_OK) { return; }
		get_tedinfo( dlog, S_Keyword, find );
		get_crossed( dlog, S_StartBegin, &starttop );
	/*	get_crossed( dlog, S_CaseSense, &case ); 	/* if later want case-sensitive/insensitive */
		handle_redraw_event();
	}

	/*	char case,key[40];	*/
	/*	strcpy( key, find );		/* support case insensitive */
	/*	if (case!='Y') { strlwr( key ); } */
	/* change references for 'find' to 'key'  add parameter 'case' to every call  */
	if (find[0]!='\0') {
		wind_get( 0, WF_TOP, &top, NULL, NULL, NULL );
		wx = windows_index( top );
	/*	fprintf( log, "Find text in window[%d]\n", wx ); fflush( log ); */
		switch (wx) {
			case 2: found = find_text_overview( wx, starttop, find );
				break;
			case 6: found = find_text_mailbox( wx, starttop, find );
				break;
			case 3:
			case 7:
			case 12: found = find_text_generic( wx, starttop, find );
				break;
			case 14: found = find_text_addressbook( wx, starttop, find );
				break;
			default: break;
		}
		if (found) {
			if (found==2) { refresh_window(top); return; }
			windows[wx].reread = 1;
			set_vslider( wx, windows[wx].id );
			refresh_clear_window( top );
		}
	}
}

void copy_text( char *text)
{
	FILE *fid;
	struct FILEINFO info;
	char dir[FMSIZE];
	long len;

	if (scrp_read( dir )) {
		len=strlen(dir)-1;
		if (dir[len]!='\\') { strcat( dir, "\\" ); }
		chdir( dir );
		while (!dfind( &info, "scrap.*", 0)) { remove( info.name ); } 
		chdir( program_path );
		strcat( dir, "scrap.txt" );
		if (fid = fopen( dir, "wa")) {
			fputs( text, fid );
			fclose( fid );
		}
	}
}

void paste_text( char *text, long maxsize )
{
	FILE *fid;
	char dir[FMSIZE];
	long len;

	text[0]='\0';			/* initialize to Null string */
	if (scrp_read( dir )) {
		len=strlen(dir)-1;
		if (dir[len]!='\\') { strcat( dir, "\\" ); }
		strcat( dir, "scrap.txt" );
		if (fid = fopen( dir, "ra")) {
			fgets( text, maxsize, fid );
			text[maxsize-1]='\0';	/* insure null terminated */
			fclose( fid );
		}
	}
}

void cut_text( char *text )
{
	copy_text( text );
/*	do_keyboard_events( 0, 0x5300 );	/* generate delete key on window */
}

void handle_cut_copy_paste(int ccp)
{
	int top;
	char buff[80];

	wind_get( 0, WF_TOP, &top, NULL, NULL, NULL );
	if (windows[1].id==top) {
		if (current_group<0) return;
		switch (ccp)
		{
		case 1:	copy_text( group[current_group].name );
				unsubscribe();
				break;
		case 2:	copy_text( group[current_group].name );
				break;
		case 3: paste_text( buff, 50 );
				Add_Newsgroup_dialog( buff );
				refresh_window( windows[1].id );
				break;
		}
	}	
	if (windows[4].id==top) {
		if (current_fullgroups<0) return;
		switch (ccp)
		{
		case 2:	copy_text( fullgroups[current_fullgroups].x );
				break;
		}
	}	
	if (windows[5].id==top) {
		if (current_newgroups<0) return;
		switch (ccp)
		{
		case 2:	copy_text( newgroups[current_newgroups].x );
				break;
		}
	}	
}

void handle_NEWSie_menu( int item )
{
	if (item==MAbout) {	about_NEWSie_dialog(); }			
}

void handle_Edit_menu( int item )
{
	switch (item)
	{
		case ME_Clear:			break;
		case ME_Cut:			handle_cut_copy_paste(1);	break;
		case ME_Copy:			handle_cut_copy_paste(2);	break;
		case ME_Paste:			handle_cut_copy_paste(3);	break;
		case ME_Find:			find_text(1); break;
		case ME_FindNext:		find_text(0); break;
		case ME_ShowDetails:	break;
	}
}

void handle_extended_File_menu( int item, OBJECT *tree, int sub_item )
{
	short mbuff[8];
	char fname[40]="";

	if (tree) {		/* attached sub_menu? */
		sprintf( fname, "%s.grp", tree[item].ob_spec );	/* copy filename from selected attached menu */
		item = MF_NewGroup;	/* continue with processing */
	}

	switch (item)
	{
		case MF_NewGroup:
			open_selected_grouplist( fname );
			break;

		case MF_Close:
			mbuff[0] = WM_CLOSED;
			wind_get( 0, WF_TOP, &mbuff[3], NULL, NULL, NULL );
			do_message_events( mbuff );
			break;

		case MF_Open:
			new_window( 1, ErrMsg(EM_SubNewsGroup), 50, 100, 300, 300 );
			break;

		case MF_Save:
			unload_group(current_newsgroup);	/* write newsgroup table */
			break;

		case MF_SaveAs:
			save_as();
			break;

		case MF_Append:
			break;

		case MF_Print:
			print_article();
			break;

		case MF_Quit:
			finished=1;
			break;
	}
}

void handle_File_menu( int item )
{
	handle_extended_File_menu( item, NULL, 0 );	/* pass to extended handler */
}

void handle_News_menu( int item )
{
	char path[FMSIZE];

	switch (item)
	{
		case MN_Article:
			next_article();
			break;

		case MN_Thread:
			next_thread();
			break;

		case MN_Group:
			next_group();
			break;

		case MN_MarkRead:
			mark_read();
			break;

		case MN_MarkUnread:
			mark_unread();
			break;

		case MN_MarkThread:
			mark_thread_read();
			break;

		case MN_MarkAll:
			mark_all_read();
			break;

		case MN_NewPost:
			new_post();
			break;

		case MN_FollowPost:
			followup_post();
			break;

		case MN_ReadForOff:
			if (STiK>0) {
				read_offline_support();
			} else { no_stik(); }	
			break;

		case MN_PostBox:
			sprintf( path, "%s\\%s", prefs.work_path, "posts.pbx" );
			open_mailbox( ErrMsg(EM_PostBox), path );
			break;
	}
}

void handle_Special_menu( int item )
{
	char path[FMSIZE];
	unsigned long filetime=-1;	/* initialize */
	struct FILEINFO s;

	switch (item)
	{
		case MS_ConnectHost:
			if (STiK>0) { newsserver_connect(); } else { no_stik(); }
			break;

		case MS_Disconnect:
			if (STiK>0) { newsserver_disconnect(); }
			break;

		case MS_Extract:
			extract_binaries();
			break;

		case MS_Subscribe:
			subscribe();
			break;

		case MS_Unsubscribe:
			unsubscribe();
			break;

		case MS_ShowLog:
			show_log();
			break;

		case MS_CheckNew:
			sprintf( path, "%s\\%s", prefs.work_path, "fullgrp.txt" );
			if (!dfind( &s, path, 0 )) { filetime = s.time; }
			sprintf( path, "%s\\%s", prefs.work_path, "newgrp.txt" );
			Check_New_Groups_dialog( path, filetime );

			windows[5].line_no = 0;
			windows[5].reread = 1;
			windows[5].num_lines = (int16)count_lines( path );
			new_window( 5, ErrMsg(EM_NewNGrpList), 200, 100, 250, 300 );
			break;

		case MS_FullGroup:
			sprintf( path, "%s\\%s", prefs.work_path, "fullgrp.txt" );
			Show_Full_Groups_dialog( path );

			windows[4].line_no = 0;
			windows[4].reread = 1;
		    if (fullgroup_index[0]==0) {
				windows[4].num_lines = (int16)count_lines( path );
			} else {
				windows[4].num_lines = (int16)fullgroup_index[0];
			}
			if (windows[4].num_lines<0) { windows[4].num_lines = 0x7fff; }	/* maximum positive, temporary */	
			new_window( 4, ErrMsg(EM_FullNGrpList), 300, 100, 250, 300 );
			break;

		case MS_OpenURL:
			open_url();
			break;
	}
}

void handle_extended_Preferences_menu( int item, OBJECT *tree, int sub_item )
{
	char fname[40]="";

	if (tree) {		/* attached sub_menu? */
		if (item>1) { sprintf( fname, "%s.inf", tree[item].ob_spec ); }	/* copy filename from selected attached menu */
	/*	if (item>1) { fprintf( log, "%s.inf\n", tree[item].ob_spec ); }	/* copy filename from selected attached menu */
		item = MP_Load;	/* continue with processing */
	}

	switch (item)
	{
		case MP_NewsReading:
			News_Reading_Preferences_dialog();
			break;

		case MP_MailReading:
			Mail_Reading_Preferences_dialog();
			break;

		case MP_Message:
			Message_Preferences_dialog();
			break;

		case MP_Server:
			Server_Preferences_dialog();
			break;

		case MP_Personal:
			Personal_Preferences_dialog();
			break;

		case MP_Signature:
			Signature_Preferences_dialog();
			break;

		case MP_Fonts:
			Font_Preferences_dialog();
			break;

		case MP_Path:
			Path_Preferences_dialog();
			break;

		case MP_Log:
			Log_Preferences_dialog();
			break;

		case MP_General:
			General_Preferences_dialog();
			break;

		case MP_FTP:
			FTP_Preferences_dialog();
			break;

		case MP_Browser:
			Browser_Preferences_dialog();
			break;

		case MP_EditFKeys:
			edit_function_keys();
			break;

		case MP_Save:
			save_preferences( fname );
			break;

		case MP_Load:
			load_preferences( fname );
			break;
	}
}

void handle_Preferences_menu( int item )
{
	handle_extended_Preferences_menu( item, NULL, 0 );	/* pass to extended handler */
}

void handle_menu( int title, int item, OBJECT *tree, int sub_item )
{
	switch (title)
	{
		case 0:						/* function key handler */
			handle_NEWSie_menu( item );
			handle_File_menu( item );
			handle_Edit_menu( item );
			handle_News_menu( item );
			handle_Mail_menu( item );
			handle_FTP_menu( item );
			handle_Special_menu( item );
			handle_Preferences_menu( item );
			break;
		case M_NEWSie:		handle_NEWSie_menu( item );		break;
		case M_File:		handle_extended_File_menu( item, tree, sub_item );		break;
		case M_Edit:		handle_Edit_menu( item );		break;
		case M_News:		handle_News_menu( item );		break;
		case M_Mail:		handle_extended_Mail_menu( item, tree, sub_item );		break;
		case M_FTP:			handle_FTP_menu( item );		break;
		case M_Special:		handle_Special_menu( item );	break;
		case M_Preferences:	handle_extended_Preferences_menu( item, tree, sub_item );	break;
	}
	menu_tnormal(menu_ptr,title,1);
}

void do_VA_START_file( char *filename )
{
	char url[FMSIZE],temp[FMSIZE],*p;
	char select[FMSIZE],path[FMSIZE];

	strcpy( temp, filename );
	strlwr( temp );

	if (stcpm(temp, ".grp", &p)) {		/* drag and drop .GRP files */
		unload_group(current_newsgroup);	/* from open_new_grouplist()*/
		strcpy( current_newsgroup, filename );
		show_status( ErrMsg(EM_RetrieveNews) );
		load_group(current_newsgroup);	/* fill newsgroup table */
		hide_status();
		new_window( 1, ErrMsg(EM_SubNewsGroup), 50, 100, 300, 300 );
		return;
	}
	if (stcpm(temp, ".htm", &p)) {		/* drag and drop .HTM files */
		sprintf( url, "file:///%s", filename );	
		open_url_path( url );
		return;
	}	
	if (stcpm(temp, ".txt", &p)) {		/* drag and drop .TXT files */
		sprintf( url, "file:///%s", filename );	
		open_url_path( url );
		return;
	}	
	if (stcpm(temp, ".mbx", &p)) {		/* drag and drop .MBX files */
		stcgfn( select, filename );
		strtok( select, "." );
		sprintf( path, "%s %s", ErrMsg(EM_Mailbox), select );
		open_mailbox(path, filename);
		return;
	}
	if (stcpm(temp, ".inf", &p)) {		/* drag and drop .INF files */
		load_preferences( filename );
		return;
	}
	if (stcpm(temp, ".avr", &p)) {		/* drag and drop .AVR files */
		open_helper_url( filename );		/* play the file */
		return;
 	}	
	if (stcpm(temp, ".wav", &p)) {		/* drag and drop .WAV files */
		open_helper_url( filename );		/* play the file */
		return;
	}	
}

void do_VA_Protocol_events(int *mbuff)
{
	long *p;
	char c,s,temp[8],*q;
/*	int mx,my,dummy; */

	switch(mbuff[0])
	{
	case VA_START:
		p=(long *)&mbuff[3];	/* command line in mbuff[3 & 4] */
		p=(long *)*p;
		if (p==NULL) {			/* make NEWSie active */
			wind_update( BEG_UPDATE );
			menu_bar(menu_ptr,1);
			wind_update( END_UPDATE );
			return;
		}
	/*	fprintf( log, "VA_START received: %s\n", p ); */

		stccpy( temp, (char *)p, 8 );
		strlwr( temp );
		if (memcmp(temp,"mailto:",7)==0) { browser_mailto( p ); break; } 
		if (memcmp(temp,"news:",  5)==0) {
			unload_overview();
			unload_group( current_newsgroup );
			CAB_internet_news_client( p );
			standard_startup();
			break;
		}
		if (memcmp(temp,"ftp://", 6)==0) {
			c=prefs.connect_startup;	/* save parameters */
			s=prefs.subscribe_startup;
			CAB_internet_ftp_client( p );
			prefs.connect_startup=c;	/* restore parameters */
			prefs.subscribe_startup=s;
			break;
		}
		q = (char *)p;
#if (0)
		graf_mkstate(&mx,&my,&dummy,&dummy);
		if ((wind_find(mx, my)==windows[11].id) && (fpi>=0)) {	/* if ftp directory window selected */
			store_with_name( q );	/* attempt to upload file */
			break;
		}
#endif
		if (q[1]=':') { do_VA_START_file( q ); }
		break;
	case AV_SENDCLICK:
	/*	if (mbuff[5]==1) { /* left button down, simulate click */	
	/*		do_mouse_events( mbuff[3], mbuff[4], mbuff[5], 1);
		}
	/*
		msg[5] = ev_mmobutton;
		msg[6] = ev_mmokstate;
		msg[7] = ev_mbreturn;
	*/
		break;
	default:
		fprintf( log, "VA Protocol message %x received\n", mbuff[0] ); fflush( log );
		break;
	}
}

void do_message_events(int *mbuff)
{
	int wx,rc;
	unsigned int ev;
	GRECT box,work;
	long *p;

	if ((mbuff[0]>>8)==0x0047) { do_VA_Protocol_events(mbuff); return; }
	if ((mbuff[0]>>8)==0x0013) { do_GEMScript_events(mbuff); return; }
	ev = mbuff[0];
	if ((ev>>8)==0x00BA) { do_BubbleGEM_events(mbuff); return; }
	switch(mbuff[0])
	{
	case WM_REDRAW:
		wx=windows_index( mbuff[3] );
		windows[wx].clear = (mbuff[2]!=45);
		box.g_x = mbuff[4];
		box.g_y = mbuff[5];
		box.g_w = mbuff[6];
		box.g_h = mbuff[7];
 	/*	graf_mouse( M_OFF, NULL ); */
		wind_redraw( mbuff[3], &box, w_redraw );
	/*	graf_mouse( M_ON, NULL ); */
		windows[wx].clear = 0;
		windows[wx].prev_line_no=windows[wx].line_no;
		break;
	case MN_SELECTED:
	/*	fprintf( log, "MN_SELECTED [4]=%d, [5]=%d, [6]=%d, [7]=%d\n", mbuff[4], mbuff[5], mbuff[6], mbuff[7] ); */
		if (_AESglobal[0]<0x0330) { mbuff[5]=0; mbuff[6]=0; mbuff[7]=0; }
		p=(long *)&mbuff[5];	/* OBJECT TREE in mbuff[5 & 6] */
		p=(long *)*p;
		if ((OBJECT *)p==menu_ptr) { mbuff[7]=0; p=NULL; }	/* sub_item=0 if object tree is NULL */
		handle_menu( mbuff[3], mbuff[4], (OBJECT *)p, mbuff[7] );
	/*	handle_menu(mbuff[3],mbuff[4]); */
		break;
	case WM_CLOSED:
		if (mbuff[3]<=0) { break; }	/* ignore desktop window id */

		if (mbuff[3]==windows[11].id) {	/* ftp directory/servers */
			rc=ftp_close_window();
			if (rc) {
				refresh_clear_window( windows[11].id );
				break;
			}
		}

		wx = windows_index( mbuff[3] );
		windows[wx].open=0;		/* mark window closed */

		if (mbuff[3]==windows[0].id) {	/* status window */
			sd = NULL;
			in.msg_status = no_msg_status;
		}
		if (mbuff[3]==windows[2].id) {	/* overview */
			unload_overview();
			refresh_clear_window( windows[1].id );
		}
		if (mbuff[3]==windows[3].id) {	/* article */
			if (prefs.erase_articles=='Y') {
				if (!(OFFLINE)) {	remove( current_article ); }
			}
		}
		if (mbuff[3]==windows[3].id) {	/* article window */
			handle_generic_close( 3 );
		/*	if (strcmp( current_browse, current_article)==0) { key_browser( 0x0e08 ); }	/* backspace to previous document */
		}
		if (mbuff[3]==windows[7].id) {	/* mail window */
			handle_generic_close( 7 );
			if (strcmp( current_browse, current_mailmsg)==0) { key_browser( 0x0e08 ); }	/* backspace to previous document */
		}
		if (mbuff[3]==windows[8].id) {
			handle_generic_close( 8 );
			current_helpfile[0] = '\0';
		}
		if (mbuff[3]==windows[6].id) { close_mailbox(); }
		if (mbuff[3]==windows[12].id) { handle_browser_close(); }

		wind_close( mbuff[3] );
		delete_window( windows[wx].id );
		windows[wx].id=-1;
		break;
	case WM_TOPPED:
		wx=windows_index( mbuff[3] );
		windows[wx].clear=1;
		wind_set( mbuff[3], WF_TOP, 0, 0, 0, 0 );
		set_menu_list( wx );
		if ( MT ) {
			wind_update( BEG_UPDATE );
			menu_bar(menu_ptr,1);	/* for multitasking os */
			wind_update( END_UPDATE );
		}
		break;
	case WM_MOVED:
		wind_set( mbuff[3], WF_CXYWH, mbuff[4], mbuff[5], mbuff[6], mbuff[7] );
		wx=windows_index( mbuff[3] );
		windows[wx].x = mbuff[4];
		windows[wx].y = mbuff[5];
		if (wx==0) {
			if (sd!=NULL) {
				sd->ob_x=mbuff[4]; sd->ob_y=mbuff[5];
				objc_offset( sd, NS_StatusMsg, &sx, &sy );
			}
		}
		rc = wind_get( mbuff[3], WF_WORKXYWH, &work.g_x, &work.g_y, &work.g_w, &work.g_h);
		setup_toolbar(wx, &work.g_x, &work.g_y, &work.g_w, &work.g_h );
		break;
	case WM_SIZED:
		wx = windows_index( mbuff[3] );
		windows[wx].clear=1;
		windows[wx].w = mbuff[6];
		windows[wx].h = mbuff[7];
		wind_set( mbuff[3], WF_CXYWH, mbuff[4], mbuff[5], mbuff[6], mbuff[7] );
		set_vslider( wx, windows[wx].id );
		refresh_clear_window( windows[wx].id );
	/*	if (prefs.show_toolbar=='B') {
			rc = wind_get( mbuff[3], WF_WORKXYWH, &work.g_x, &work.g_y, &work.g_w, &work.g_h);
			setup_toolbar(wx, &work.g_x, &work.g_y, &work.g_w, &work.g_h );
		} */
		break;
	case WM_ARROWED:	handle_arrows( mbuff[3], mbuff[4] );	break;
	case WM_VSLID:	handle_slider( mbuff[3], mbuff[4] );	break;
	case WM_FULLED:	handle_full( mbuff[3] );	break;
/*	case WM_NEWTOP:
		wx = windows_index( mbuff[3] );
		set_menu_list( wx );
		break;
*/
	case WM_ICONIFY:
		wind_set( mbuff[3], WF_ICONIFY, mbuff[4], mbuff[5], mbuff[6], mbuff[7] );
		handle_draw_icon(mbuff);
		break;
	case WM_UNICONIFY:
		wx=windows_index( mbuff[3] );
		windows[wx].clear=1;
		windows[wx].w = mbuff[6];
		windows[wx].h = mbuff[7];
		wind_set( mbuff[3], WF_UNICONIFY, mbuff[4], mbuff[5], mbuff[6], mbuff[7] );
		break;
	case WM_ALLICONIFY:
		for (wx=0;wx<WINDOWS_SIZE;wx++) {
			if (windows[wx].open) {
				wind_set( windows[wx].id, WF_ICONIFY, mbuff[4], mbuff[5], mbuff[6], mbuff[7] );
				handle_draw_icon(mbuff);
			}
		}
		break;
	case WM_ONTOP:
		wx=windows_index( mbuff[3] );
		set_menu_list( wx );
		if ( 0 /*MT*/ ) {
			rc=1;		/* assume we are switching applications */
			for (wx=0;wx<WINDOWS_SIZE;wx++) {	/* if its our window, ignore */
				if (windows[wx].id==mbuff[3]) { rc=0; break; }
			}
			if (rc) {
				wind_update( BEG_UPDATE );
				menu_bar(menu_ptr,1);	/* for multitasking os */
				wind_update( END_UPDATE );
			}
		}
		break;
	case WM_TOOLBAR:
		beep();
		break;
	case AP_TERM:
		handle_File_menu( MF_Quit );
		break;
	case CH_EXIT:
	/*	beep(); */
	/*	radio=-1; */
		if (radio==mbuff[3]) { radio=mbuff[4]; }
		break;
	case AP_DRAGDROP:
		handle_dragdrop( mbuff );	/* handle it */
		break;
	}
}

int menu_down(void)
{
	int c,rc=0;

	for (c=M_NEWSie;c<=M_Preferences;c++) {
		rc|=menu_ptr[c].ob_state;
	}
	return(rc&SELECTED);
}

int auto_top_window(int mx, int my, int result)
{
	int top,now,c,d,x;

	if (prefs.auto_top=='Y') {
		if (menu_down()) { return(result); }
		wind_get( 0, WF_TOP, &top, NULL, NULL, NULL );
		if (top>0) {
			if (top==windows[0].id) { return(result); }	/* status window */
			now = wind_find( mx, my );
			if (now==0) { return(result); }		/* ignore desktop */
			if (now==top) { return(result); }	/* already top */
			for (c=1;c<WINDOWS_SIZE;c++) {
				if (now==windows[c].id) {
					wind_set( now, WF_TOP, 0, 0, 0, 0 );
					set_menu_list( c );
					if ( MT ) {		/* for multitasking os */
						x=1;		/* assume not my window */
						for (d=1;d<WINDOWS_SIZE;d++) {
							if (top==windows[d].id) { x=0; break; }
						}	
						if (x) {
							wind_update( BEG_UPDATE );
							menu_bar(menu_ptr,1);
							wind_update( END_UPDATE );
						}
					}
					result = 0;
					break;
				}
			}
		}
	}
	return(result);
}

void beep(void)
{
	printf( "%c", '\x07' );
}

/* simulate a key press thrrough AES GEM */
void press_key(char ascii, char scan, int shift)
{
	EVNTREC event;

	if (_AESglobal[0]>=0x0140) { 	/* if AES 1.4 or greater */
		event.ap_event = 3;	/* APPEVNT_KEYBOARD */
		event.ap_value = (long)shift<<16|((scan<<8)|ascii);	/* construct value */
		appl_tplay( &event, 1, 100 );	/* play single event, normal speed */
	}
}

void key_control( int keycode, int shiftkey )
{
	char path[FMSIZE];

	if ((char)keycode=='\x01') { 	/* ctl A */
		next_article();
		return;
	}
	if ((char)keycode=='\x03') { 	/* ctl C */
		handle_cut_copy_paste( 2 );	/* copy */
		return;
	}
	if ((char)keycode=='\x06') { 	/* ctl F */
	/*	followup_post(); */
		find_text( !(shiftkey&3) );
		return;
	}
	if ((char)keycode=='\x07') { 	/* ctl G */
		next_group();
		return;
	} 
	if ((char)keycode=='\x09') { 	/* ctl I */
		sprintf( path, "%s\\%s", prefs.mail_path, "inbox.mbx" );
		open_mailbox( ErrMsg(EM_MailInBox), path );
		return;
	} 
	if ((char)keycode=='\x0d') { 	/* ctl M */
		if (STiK>0) { check_mail(); } else { no_stik(); }
		return;
	}
	if ((char)keycode=='\x0e') { 	/* ctl N */
		new_post();
		return;
	}
	if ((char)keycode=='\x10') { 	/* ctl P */
		print_article();
		return;
	}
	if ((char)keycode=='\x11') {	/* ctl Q */
		finished=1;
		return;
	}
	if ((char)keycode=='\x12') { 	/* ctl R */
		mark_read();
		return;
	}
	if ((char)keycode=='\x13') { 	/* ctl S */
		unload_group(current_newsgroup);
		return;
	}	
	if ((char)keycode=='\x14') { 	/* ctl T */
		next_thread();
		return;
	}	
	if ((char)keycode=='\x15') { 	/* ctl U */
		mark_unread();
		return;
	}
	if ((char)keycode=='\x16') { 	/* ctl V */
		handle_cut_copy_paste( 3 );	/* paste */
		return;
	}
	if ((char)keycode=='\x17') { 	/* ctl W */
		cycle_windows();
		return;
	}
	if ((char)keycode=='\x18') { 	/* ctl X */
		handle_cut_copy_paste( 1 );	/* cut */
		return;
	}
	if ((char)keycode=='\x19') { 	/* ctl Y */
		mark_thread_read();
		return;
	}
	/* ctl-b, ctl-d, ctl-e, ctl-h, ctl-j, ctl-k, ctl-l, ctl-o, ctl-z passed */
	send_AV_SendKey( shiftkey, keycode );
}

int arrow_page_scrolling_keys( int wid, int keycode )
{
	if (keycode==0x4838) {	/* shift up arrow */
		handle_arrows( wid, WA_UPPAGE );
		return(1);
	}
	if (keycode==0x5032) {	/* shift down arrow */
		handle_arrows( wid, WA_DNPAGE );
		return(1);
	}
	if (keycode==0x4700) {	/* home */
		handle_arrows( wid, WA_TOP );
		return(1);
	}
	if (keycode==0x4737) {	/* shift home */
		handle_arrows( wid, WA_BOTTOM );
		return(1);
	}
	return(0);
}

int arrow_scrolling_keys( int wid, int keycode )
{
	if (keycode==0x4800) {	/* up arrow */
		handle_arrows( wid, WA_UPLINE );
		return(1);
	}
	if (keycode==0x5000) {	/* down arrow */
		handle_arrows( wid, WA_DNLINE );
		return(1);
	}
	return(arrow_page_scrolling_keys( wid, keycode ));
}

#define F1 0x3b00
#define F10 0x4400
#define F11 0x5400
#define F20 0x5d00

void do_keyboard_events(int shiftkey, int keycode)
{
	int top;

	if (shiftkey&K_CTRL) {
		if ((keycode>>8)!='\x52') {	/* all except ctl-(shift)-insert */
			key_control(keycode, shiftkey);
			return;
		}
	}

	if (keycode==0x6200) { help(); return; }
	if (keycode==0x6100) {
		if (STiK>0) {
			if (memcmp(prefs.email_address,"rojewski",8)==0) { try_imap4(); }	/* type imap server */
		} else { no_stik(); }	
		return;
	}
/*	if (keycode==0x6100) {
		if (shiftkey&K_RSHIFT) { find_text(1); }
		if (shiftkey&K_LSHIFT) { find_text(0); }
		return;
	} 
*/
/*	if (prefs.allow_kbd_nav!='Y') { return; } */

	if (((keycode>=F1)&&(keycode<=F10))||
	   ((keycode>=F11)&&(keycode<=F20))) {
		execute_function_key( keycode, shiftkey );
		return;
	}

	wind_get( 0, WF_TOP, &top, NULL, NULL, NULL );
	if (windows[1].id==top) { key_group( keycode ); return; }	
	if (windows[2].id==top) { key_overview( keycode ); return; }
	if (windows[3].id==top) { key_article( keycode ); return; }
	if (windows[4].id==top) { key_fullgroups( keycode ); return; }
	if (windows[5].id==top) { key_newgroups( keycode ); return; }
	if (windows[6].id==top) { key_mailbox( keycode ); return; }
	if (windows[7].id==top) { key_mail( keycode ); return; }
	if (windows[8].id==top) { key_help( keycode ); return; }
	if (windows[9].id==top) { key_log( keycode ); return; }
	if (windows[10].id==top) { key_ftp_viewer( keycode ); return; }
	if (windows[11].id==top) { key_ftp( keycode ); return; }
	if (windows[12].id==top) { key_browser( keycode ); return; }
	if (windows[14].id==top) { key_address( keycode ); return; }

	send_AV_SendKey( shiftkey, keycode );
}

void do_mouse_events(int mousex, int mousey, int button, int clicks)
{
	GRECT r,w;
	int top,wx;
	static int drag_window=-1;

	if (button==0) {	/* no buttons down, i.e. mouseup */
		drag_window = -1;
		return;
	} 

	if (button&2) {	/* right mouse button */
		if (do_toolbar_help( mousex, mousey )) { return; } /* bubble help */
		if (_AESglobal[0]>=0x0330) {
			do_popup_help( mousex, mousey );
		} else {
			help();
		}
		return;
	}

	if (button&1) {	/* left mouse button */
		wind_get( 0, WF_TOP, &top, NULL, NULL, NULL );
		wind_get( top, WF_WORKXYWH, &r.g_x, &r.g_y, &r.g_w, &r.g_h );
		if (_AESglobal[0]<0x0340) {	/* 0140/0206 problem with lower AES version */
			if (drag_window==top) { return; }	/* mouse down in movebar */
			w = r; w.g_h = 4;
		/*	wind_get( top, WF_CURRXYWH, &w.g_x, &w.g_y, &w.g_w, &w.g_h );
		/*	w.g_h = w.g_y - r.g_y;	/* calculate height of title/mover bar */
		/*	w.g_x += w.g_h;  w.g_w -= 2*w.g_h;	/* left and width w/close and full */
			if (rc_inside( mousex, mousey, &w )==1) {	/* near title bar area? */
				drag_window = top;	/* set to indicate ignore mouse */
				return;
			}
			w = r; w.g_x += (w.g_w - 4); w.g_w = 4;
			if (rc_inside( mousex, mousey, &w )==1) {	/* near vert scrollbar area? */
				drag_window = top;	/* set to indicate ignore mouse */
				return;
			}
		}
		if (rc_inside( mousex, mousey, &r )==1) {
			if (do_toolbar_events(top, mousex, mousey)) { return; }
			wx = windows_index(top);
			if (prefs.show_toolbar=='Y') {	/* adjust for Toolbar at top */
				if (windows[wx].bar_object!=NULL) {
					r.g_y += windows[wx].bar_object->ob_height; }
			}
			if (windows[1].id==top) { select_group( mousey - r.g_y, clicks ); }	
			if (windows[2].id==top) { select_article( mousey - r.g_y, clicks ); }
			if (windows[3].id==top) { select_generic( 3, mousex-r.g_x, mousey-r.g_y, clicks ); }
			if (windows[4].id==top) { select_fullgroup( mousey - r.g_y, clicks ); }
			if (windows[5].id==top) { select_newgroup( mousey - r.g_y, clicks ); }
			if (windows[6].id==top) { select_mail( mousey - r.g_y, clicks ); }
			if (windows[7].id==top) { select_generic( 7, mousex-r.g_x, mousey-r.g_y, clicks ); }
			if (windows[8].id==top) { select_help( mousex-r.g_x, mousey-r.g_y, clicks ); }
			if (windows[9].id==top) { select_log( mousey - r.g_y, clicks ); }
			if (windows[11].id==top) { select_ftp( mousey - r.g_y, clicks ); }
			if (windows[12].id==top) { select_browser( mousex-r.g_x, mousey-r.g_y, clicks ); }
			if (windows[14].id==top) { select_address( mousey - r.g_y, clicks ); }
		}
	}
}

/* support for mouse rectange tracking within certain windows */
void do_mouse_tracking_events( int mousex, int mousey )
{
	GRECT r;
	int top,wx;

	wind_get( 0, WF_TOP, &top, NULL, NULL, NULL );
	wind_get( top, WF_WORKXYWH, &r.g_x, &r.g_y, &r.g_w, &r.g_h );
	if (rc_inside( mousex, mousey, &r )==1) {
		wx = windows_index(top);
		if (html_global(wx, NULL)!=NULL) {
			handle_mouse_tracking( wx, mousex - r.g_x, mousey - r.g_y );
		}
	}
}

void handle_multiple_events(void)
{
	short buff[8];
	int res, mx, my, btn, shft, keycode, clicks;
	int flags=MU_KEYBD|MU_BUTTON|MU_MESAG|MU_TIMER;

	for (; !finished;)
	{
	/*	for (res=0;res<8;res++) { buff[res]=0; } */
	/*	res = evnt_multi( flags, 2, 1, 1, */
		res = evnt_multi( flags, 0x0102, 3, 0,	/* left or right mouse */
					0, 0, 0, 0, 0,
					0, 0, 0, 0, 0,
					buff, 500, 0,
					&mx, &my, &btn, &shft, &keycode, &clicks );
		if (btn==0) { do_mouse_events(mx, my, btn, clicks); }
		if (res & MU_MESAG)  { do_message_events( buff ); }
		if (res & MU_KEYBD)  { do_keyboard_events(shft, keycode); }
		if (res & MU_BUTTON) { do_mouse_events(mx, my, btn, clicks); }
		if (res & MU_TIMER)  { auto_top_window(mx, my, res); }
		do_mouse_tracking_events( mx, my );
	} 
}

int handle_possible_events(void)
{
	short buff[8];
	int res, mx, my, btn, shft, keycode, clicks;
	int flags=MU_KEYBD|MU_BUTTON|MU_MESAG|MU_TIMER;

/*	for (res=0;res<8;res++) { buff[res]=0; } */
/*	res = evnt_multi( flags, 2, 1, 1, */
	res = evnt_multi( flags, 0x0102, 3, 0,	/* left or right mouse */
				0, 0, 0, 0, 0,
				0, 0, 0, 0, 0,
				buff, 0, 0,
				&mx, &my, &btn, &shft, &keycode, &clicks );
	if (btn==0) { do_mouse_events(mx, my, btn, clicks); }
	if (res & MU_MESAG)  { do_message_events( buff ); }
	if (res & MU_KEYBD)  { do_keyboard_events(shft, keycode); }
	if (res & MU_BUTTON) { do_mouse_events(mx, my, btn, clicks); }
	res = auto_top_window(mx, my, res);
	sort_clock=clock()+CLK_TCK;
	do_mouse_tracking_events( mx, my );
	return(res);
}

int handle_escape_events(void)		/* like handle_possible... */
{
	short buff[8];
	int res, mx, my, btn, shft, keycode, clicks;
	int flags=MU_KEYBD|MU_BUTTON|MU_MESAG|MU_TIMER;

/*	for (res=0;res<8;res++) { buff[res]=0; } */
/*	res = evnt_multi( flags, 2, 1, 1, */
	res = evnt_multi( flags, 0x0102, 3, 0,	/* left or right mouse */
				0, 0, 0, 0, 0,
				0, 0, 0, 0, 0,
				buff, 0, 0,
				&mx, &my, &btn, &shft, &keycode, &clicks );
	if (btn==0) { do_mouse_events(mx, my, btn, clicks); }
	if (res & MU_MESAG)  { do_message_events( buff ); }
	if (res & MU_KEYBD)  { do_keyboard_events(shft, keycode); } else { keycode=0; }
	if (res & MU_BUTTON) { do_mouse_events(mx, my, btn, clicks); }
	if (res & MU_TIMER)  {
		auto_top_window(mx, my, res);
		sort_clock=clock()+CLK_TCK;
	}
	return( (char)keycode );		/* return low byte of keycode */
}

void handle_redraw_event(void)
{
	while (handle_possible_events()!=MU_TIMER);
}

/* help */

int help_ST_Guide(char *args)
{
	int msg[8], i;
	struct FILEINFO s;

	if (dfind( &s, args, 0 )!=0) { return(0); }

	if ((i=appl_find("ST-GUIDE"))>=0) {
		msg[0] = VA_START;   /* VA_START == 0x4711 */
		msg[1] = _AESglobal[2];
		msg[2] = 0;
		msg[3] = (int)(((long)args >> 16) & 0x0000ffff);
		msg[4] = (int)((long)args & 0x0000ffff);
		msg[5] = 0;
		msg[6] = 0;
		msg[7] = 0;
		appl_write(i, 16, msg);
		return(1);
	}
	return(0);
}

void determine_help_path( char *help_path )
{
	char lang[12];
	struct FILEINFO info;

	language_preference( lang );
	if (memcmp( lang, "ENGLISH", 7 )==0) {
		sprintf( help_path, "%s\\HELP", program_path );
	} else {
		strtoka( lang, ' ' );	/* trim trailing spaces */
		sprintf( help_path, "%s\\LANGUAGE\\%s\\HELP", program_path, lang );
		if (dfind( &info, help_path, FA_SUBDIR )) { /* if dir does not exist */
			fprintf( log, "help path %s does not exist\n", help_path );
			sprintf( help_path, "%s\\HELP", program_path );
		}
	}
}

void help(void)
{
	int top,w;
	char filename[FNSIZE]="GENERAL.HLP";
	char help_path[FMSIZE],previous_helpfile[FMSIZE];
	char *p,title[80]="General Help";
	char content[256];
	FILE *fid;

	strncpy( previous_helpfile, current_helpfile, FMSIZE );	/* save current help */
	determine_help_path( help_path );
	sprintf( current_helpfile, "%s\\%s", help_path, "newsie.hyp" );
	if (help_ST_Guide( current_helpfile )) { return; }
	windows[8].line_no = 0;
	windows[8].reread = 1;
	wind_get( 0, WF_TOP, &top, NULL, NULL, NULL );
	w=windows_index(top);
	switch(w)
	{
		case 1:	strcpy( filename, "newsgrp.hlp" );	break;
		case 2:	strcpy( filename, "overview.hlp" );	break;
		case 3:	strcpy( filename, "article.hlp" );	break;
		case 4: strcpy( filename, "fullgrp.hlp" );	break;
		case 5:	strcpy( filename, "newgrp.hlp" );	break;
		case 6:
			if (mail_selective()) {
				strcpy( filename, "mailsel.hlp" );
			} else {
				strcpy( filename, "mailbox.hlp" );
			}	break;
		case 7: strcpy( filename, "mail.hlp" );		break;
		case 11:
			if (fpi>=0) {
				strcpy( filename, "ftpd.hlp" );
			} else {
				strcpy( filename, "ftps.hlp" );
			}	break;
		case 12: strcpy( filename, "browser.hlp" );	break;
		case 14: strcpy( filename, "address.hlp" );	break;
	}
	sprintf( current_helpfile, "%s\\%s", help_path, filename );
	if (strcmp(previous_helpfile, current_helpfile)==0) { return; }	/* if same file, ignore */

	if ((fid=fopen( current_helpfile, "ra" ))!=NULL) {
		fgets( title, 80, fid );
		p = strtok( title, "\n" );
		fclose( fid );
		windows[8].num_lines = (int16)count_lines( current_helpfile );
		new_window( 8, title, 0, 20, 530, 280 );
	} else {
		p=strrchr( current_helpfile, '.' );	/* find file extension */
		strcpy( p, ".htm" );		/* change to htm */
		if (strcmp(previous_helpfile, current_helpfile)==0) { return; }	/* if same file, ignore */
	/*	fprintf( log, "%s\n", current_helpfile ); fflush( log ); */
		if ((fid=fopen( current_helpfile, "ra" ))!=NULL) {
			fclose( fid );
			sprintf( title, "file:///%s", current_helpfile );
		/*	fprintf( log, "%s\n", title ); fflush( log ); */
			strcpy( content, info.content_type );	/* save it before */
			open_url_path_window( title, 8 );	/* window 8 is help window */
			strcpy( info.content_type, content );	/* restore it after */
		}
	}
}

void help_text( int wid, char *filename )
{
	if (strstr(current_helpfile, ".htm" )) {
		browser_text_html( wid, filename );
	} else {
		generic_window_text( wid, filename );
	}
}

void key_help(int keycode)
{
	void *cs;

	if (arrow_scrolling_keys( windows[8].id, keycode )) { return; }
	if ((keycode>>8)=='\x0e') {	/* backspace to previous document */
		if ((cs=html_global(8, NULL))!=NULL) {	/* if HTMLINFO block */
			previous_document( cs, 1 );
		} else { beep(); }
		return;
	}
	send_AV_SendKey( 0, keycode );
}

void select_help( int x, int y, int clicks )
{
	if (strstr(current_helpfile, ".htm" )) {
	/*	select_browser( x, y, clicks );	/* still not ready for window id !=12 */
		select_generic( 8, x, y, clicks );
	}
}

int popup_works(int rc)
{
	static popup=0;		/* 0=popups not verified, <>0=popups do work */

	if (rc) { popup=1; }
	return( popup );
}

/* set enable/disable status in popup items according to main menu */
void mask_status( int to, int tindex, int from, int frindex )
{
	OBJECT *frt,*tot;

	rsrc_gaddr(R_TREE,to,&tot);
	rsrc_gaddr(R_TREE,from,&frt);
	tot[tindex].ob_state = frt[frindex].ob_state;
}

void do_popup_masking( OBJECT *poptree, int wx )
{
	switch (wx)
	{
	case 1: 
		mask_status(Pop_Subscribed,PS_ReadOffline,NEWSie,MN_ReadForOff);
		break;
	case 2:  
		mask_status(Pop_Overview,PN_NextArticle,NEWSie,MN_Article);
		mask_status(Pop_Overview,PN_NextThread,NEWSie,MN_Thread);
		mask_status(Pop_Overview,PN_NextGroup,NEWSie,MN_Group);
		mask_status(Pop_Overview,PN_MarkRead,NEWSie,MN_MarkRead);
		mask_status(Pop_Overview,PN_MarkUnread,NEWSie,MN_MarkUnread);
		mask_status(Pop_Overview,PN_MarkThread,NEWSie,MN_MarkThread);
		mask_status(Pop_Overview,PN_MarkAllRead,NEWSie,MN_MarkAll);
		mask_status(Pop_Overview,PN_ReadOffline,NEWSie,MN_ReadForOff);
		break;
	case 6:  
		mask_status(Pop_Mailbox,PMB_ReplyMail,NEWSie,MM_ReplyMail);
		mask_status(Pop_Mailbox,PMB_ForwardMail,NEWSie,MM_ForwardMail);
		break;
	}	
}

/* log */

void show_log(void)
{
	char logfile[FMSIZE],title[80]="Log File";

	if (log!=NULL) { fflush( log ); }
	sprintf( logfile, "%s\\%s", prefs.work_path, "LOG" );
	windows[9].line_no = 0;
	windows[9].reread = 1;
	windows[9].num_lines = (int16)count_lines( logfile );
/*	windows[9].bar_index = Button_Bar; */
	new_window( 9, title, 0, 80, 530, 280 );
}

void log_text( int wid, char *filename )
{
	generic_window_text( wid, filename );
}

void key_log(int keycode)
{
	char logfile[FMSIZE];

	if (log!=NULL) { fflush( log ); }

	if (arrow_scrolling_keys( windows[9].id, keycode )) { return; }

	sprintf( logfile, "%s\\%s", prefs.work_path, "LOG" );
	windows[9].num_lines = (int16)count_lines( logfile );
	release_window_buffer( 9, 1 );	/* release buffer for refresh */
	refresh_clear_window( windows[9].id );
}

void select_log(int vert, int clicks)
{
	char logfile[FMSIZE];

	if (log!=NULL) { fflush( log ); }
	sprintf( logfile, "%s\\%s", prefs.work_path, "LOG" );
	windows[9].num_lines = (int16)count_lines( logfile );
	refresh_clear_window( windows[9].id );
}

/* function keys */

void load_function_keys(char *filename)
{
	FILE *fid;
	char buff[80],*key,*cmd;
	int c,index;

	for (c=0;c<20;c++) {	/* clear fkeys table */
		fkeys[c][0] = '\0';
	}
	if ((fid=fopen(filename, "ra"))!=NULL) {
		while(fgets( buff, 80, fid )!=NULL) {
			if (buff[0]==';') { continue; }	/* comments */
			key = strtoka( buff, '\t' );
			cmd = strtoka( NULL, '\n' );
			index = atoi( key+1 );
			if ((index>0)&&(index<=20)) {
			/*	fprintf( log, "fkey[%d] = %s\n", index-1, cmd ); */
				strcpy( fkeys[index-1], cmd ); }	
		}
		fclose( fid );
	}
}

void execute_function_key(int keycode, int shift)
{
	OBJECT *dlog;
	int msg[8],c,index;
	long cmd_len;

/*
	Convert internal GEM keystroke for function key into index 0 thru 19.
	Then search through menu items looking for a caseless string match.
	If found, send Menu Selection message to NEWSie.
	This will work for Multi-language Resources.
*/
	if (shift&3) {
		index = ((keycode-F11)>>8)+10;	/* shifted scancode */
	} else {
		index = (keycode-F1)>>8;	/* un-shifted scancode */
	}
	cmd_len = strlen( fkeys[index] );
	if (cmd_len==0) {
	/*	fprintf( log, "fkey %d is empty\n", index+1 ); */
		send_AV_SendKey( shift, keycode );
		return;
	}

/*	fprintf( log, "fkey %d = %s\n", index+1, fkeys[index] ); */
	rsrc_gaddr( R_TREE, NEWSie, &dlog );
	if (dlog!=NULL) {
		for (c=0;c<MAX_MENU_ITEM+1;c++) {
			if (dlog[c].ob_type==G_STRING) {
			/*	fprintf( log, "comparing to %*s\n", (int)cmd_len, (char *)dlog[c].ob_spec+2 ); */
				if (strnicmp( fkeys[index], (char *)dlog[c].ob_spec+2, cmd_len )==0) {
					msg[0] = MN_SELECTED;
					msg[1] = _AESglobal[2];
					msg[2] = 0;
					msg[3] = 0;
					msg[4] = c;
					msg[5] = 0; msg[6] = 0; msg[7] = 0;
					appl_write( _AESglobal[2], 16, &msg );	/* simulate menu */
				/*	fprintf( log, "menu index=%d: %s\n", index, fkeys[index] ); */
					break;
				}
			}
		}
	}
}

void unload_function_keys(char *filename)
{
	FILE *fid;
	int c,index;

	if ((fid=fopen(filename, "wa"))!=NULL) {
		for (c=0;c<20;c++) {
			index = c+1;
			fprintf( fid, "F%d\t%s\n", index, fkeys[c] );
		}
		fclose( fid );
	}
}

/*
   4 columns  F1-F10 labels (small) F1-F10 editable fields 20 characters,
              F11-F20 labels (small) and F11-F20 editable fields, 
   sort resource dialog entries top to bottom, left to right
   name editable fields DF_F1, and DF_F11, and
   exit buttons DF_Cancel and DF_OK, make Cancel default
 */
 
void edit_function_keys(void)
{
	OBJECT *dlog;
	char path[FMSIZE];
	int c;

	rsrc_gaddr( R_TREE, Edit_FKeys, &dlog );
	if (dlog!=NULL) {
		for (c=0;c<10;c++) { set_tedinfo( dlog, DF_F1+c, fkeys[c] ); }
		for (c=0;c<10;c++) { set_tedinfo( dlog, DF_F11+c, fkeys[c+10] ); }
		if (handle_dialog( dlog, DF_F1 )==DF_OK) {
			for (c=0;c<10;c++) { get_tedinfo( dlog, DF_F1+c, fkeys[c] ); }
			for (c=0;c<10;c++) { get_tedinfo( dlog, DF_F11+c, fkeys[c+10]); }
			sprintf( path, "%s\\%s", program_path, "fkeys.txt" );
			unload_function_keys( path );
		}
	}
	/* else {
		fprintf( log, "Edit Function Keys dialog(%d) not found\n", Edit_FKeys );
		fflush( log );
	} */
}

/* end of NEWSAES.C */

