/*
 * address.c
 * Written by: John Rojewski	09/08/99
 * split from mailer.c
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
#include "wdial_g.h"
#include "global.h"

#define VERSION "0.96  Nov 16, 1999"
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


/* Nicknames */

/* #define XDEBUG */
int expand_nickname( char *to )
{
	char nickfile[FMSIZE],buff[200],*nick,*temp,*user,*newto;
	int reset=0,done=0;
	FILE *fid;

	newto = strtoka( to, ' ' );	/* remove stuff after first space */
	#ifdef XDEBUG
	fprintf( log, "Expand Nickname: %s\n", to );
	#endif
	sprintf( nickfile, "%s\\%s", prefs.mail_path, NICKNAME );
	fid =fopen( nickfile, "ra" );
	if (fid!=NULL) {
		while (fgets( buff, sizeof(buff), fid )!=NULL ) {
			nick = strtoka( buff, '\t' );	/* nickname */
			user = strtoka( NULL, '\n' );	/* description */

			if (nick[0]!='\0') {
				#ifdef XDEBUG
				fprintf( log, "Nickname: %s, Description: %s\n", nick, user );
				#endif
				if (strcmpi( to, nick )==0) {	/* requested nickname found */
					while (fgets( buff, sizeof(buff), fid )!=NULL ) {
						temp = strtoka( buff, '\t' );	/* should be null */
						if (temp[0]=='\0') { 
							user = strtoka( NULL, '\n' );	/* user e-mail address */
							#ifdef XDEBUG
							fprintf( log, "Expanded User: %s\n", user );
							#endif
							strtoka( user, ' ' );	/* remove possible full name */
						/*	x = mail_to( user ); */
							reset = mail_to_check( user );
							if (reset) { break; }	/* user requested cancel */
						} else { break; }
					}
					done++;
				}
			}
			if (done) { break; }	/* don't continue to read if done */
		}
		fclose( fid );
	}
	return(reset);	/* 0=no error, 1=cancelled */ 
}

void expand_nicknames(void)
{
	int new_size,x;
	size_t new_bytes;
	void *new_dir;
	char temp[80];

	if (prefs.dynamic_expansion!='Y') { return; }
	new_size  = 2 * NICKNAME_SIZE;
	new_bytes = new_size * sizeof( struct nick );
	new_dir   = realloc( nickname, new_bytes );
	if (!new_dir) {
		sprintf( temp,"[1][Insufficient Memory for %s][ OK ]", "|Nicknames" );
		form_alert( 1, temp );
		return;				/* failed */
	}
	nickname = new_dir;
	for (x=NICKNAME_SIZE;x<new_size;x++) {	/* clear new entries */
		nickname[x].nick = -1;
		nickname[x].tag = -1;
		nickname[x].data[0] = '\0';
	}
	NICKNAME_SIZE = new_size;
	fprintf( log, "Nicknames expanded to %d entries\n", new_size );
}

void load_nicknames(char *nickfile)
{
	char buff[200],*nick,*user;
	register int x,current;
	FILE *fid;

	current_nick=-1;
    maximum_nick=-1;
	for (x=0;x<NICKNAME_SIZE;x++) {	/* initialize structure */
		nickname[x].nick = -1;
		nickname[x].tag = -1;
		nickname[x].data[0] = '\0';
	}

	x=-1;
	fid =fopen( nickfile, "ra" );
	if (fid!=NULL) {
		while (fgets( buff, sizeof(buff), fid )!=NULL ) {
			nick = strtoka( buff, '\t' );	/* nickname */
			user = strtoka( NULL, '\n' );	/* user or description */

			if (x==NICKNAME_SIZE-2) {		/* maximum reached? */
				expand_nicknames();		/* attempt expansion */
				if (x==NICKNAME_SIZE-2) {		/* maximum reached */
					form_alert(1,"[1][Nickname file too large!|First 100 entries loaded][ OK ]");
					break;
				}
			}
			if (nick[0]!='\0') {
			/*	fprintf( log, "Nickname: %s, Description: %s\n", nick, user ); */
				strcpy( nickname[++x].data, nick );
				nickname[x].tag = -2;		/* this is a nickname */
				nickname[++maximum_nick].nick = x;
				current = x;				/* current nickname index */

				strcpy( nickname[++x].data, user );
				nickname[x].tag = -3;		/* this is a description */
			} else {
			/*	fprintf( log, "User: %s\n", user ); */
				strcpy( nickname[++x].data, user );
				nickname[x].tag = current;	/* this is user email address */
			}
		}
		fclose( fid );
	} 
}

void unload_nicknames(char *nickfile)
{
	register int x,y,c;
	FILE *fid;

    if (maximum_nick==-1) { return; }

	fid =fopen( nickfile, "wa" );
	if (fid!=NULL) {
		for (x=0;x<maximum_nick+1;x++) {	/* for each nickname */
			c=nickname[x].nick;
			if (c<0) { break; }		/* past end of list? */
			fprintf( fid, "%s\t%s\n", nickname[c].data, nickname[c+1].data );
		/*	fprintf( log, "Nickname: %s, Description: %s\n", nickname[c].data, nickname[c+1].data ); */
			for (y=0;y<NICKNAME_SIZE;y++) {	/* for each user email id */
				if (nickname[y].tag==c) {
					fprintf( fid, "\t%s\n", nickname[y].data );
				/*	fprintf( log, "User: %s\n", nickname[y].data ); */
				}
			}
		}
		fclose( fid );
	}
}

#define Button_On(x) dlog[x].ob_flags|=SELECTABLE
#define Button_Off(x) dlog[x].ob_flags&=~SELECTABLE

int modify_nickname(char *nick, char *desc)
{
	OBJECT *dlog;
	int result=0;

	rsrc_gaddr(R_TREE,Nick_Nick1,&dlog);
	set_tedinfo( dlog, N1_Nick, nick );
	set_tedinfo( dlog, N1_Desc, desc );
	if (handle_dialog(dlog, 0)==N1_OK) {
		get_tedinfo( dlog, N1_Nick, nick );
		get_tedinfo( dlog, N1_Desc, desc );
		if (nick[0]!='\0') { result=1; }
	 }
	return(result);
}

int modify_mail_address(char *address, int del)
{
	OBJECT *dlog;
	int rc=0,result;

	rsrc_gaddr(R_TREE,Nick_Nick2,&dlog);
	if (del) { Button_On(N2_Delete); } else { Button_Off(N2_Delete); }
	set_tedinfo( dlog, N2_Addr, address );
	dlog[N2_Addr].ob_flags|=TOUCHEXIT;	/* make TOUCHEXIT candidate */
	result = handle_dialog(dlog, 0);
	handle_redraw_event();
	if (result==N2_OK) {
		get_tedinfo( dlog, N2_Addr, address );
 		if (address[0]!='\0') { rc=1; }
	 }
	if (result==N2_Delete) {
		address[0] = '\0';
		rc=2;
	}
	return(rc);
}

void reset_addrs( OBJECT *dlog, int on )
{
	int c;

	Button_Off(NE_AddrUp);
	Button_Off(NE_AddrDown);
	for (c=0;c<10;c++) {
		set_tedinfo( dlog, NE_Addr1+c, "" );
		dlog[NE_Addr1+c].ob_state&=~SELECTED;	/* not selected */
		if (on) { Button_On(NE_Addr1+c); } else { Button_Off(NE_Addr1+c); }
	}
}

void Nick_UpDown( OBJECT *dlog, int *addr_offset, int *selected_nick,
	 int *current_nick, int *nick_offset )
{
	int c,d;
	char the_nick[30];

	Button_Off(NE_NickDown);
	for (c=0;c<10;c++) {
		d = nickname[*nick_offset+c].nick;
		if (d==-1) { the_nick[0]='\0'; }
		else { strcpy( the_nick, nickname[d].data ); } 
		set_tedinfo( dlog, NE_Nick1+c, the_nick );
		dlog[NE_Nick1+c].ob_state&=~SELECTED;	/* not selected */
	}
	reset_addrs(dlog, 0);	/* not selectable */
	the_nick[0]='\0';
	set_tedinfo( dlog, NE_Description, the_nick );
	if (d!=-1) { Button_On(NE_NickDown); }
	*addr_offset=0;
	*selected_nick=-1;
	*current_nick=-1;
}

int Nick_Events( OBJECT *dlog, int *obj, int *addr_offset, int *selected_nick,
	 int *current_nick, int *nick_offset, int *selected_addr )
{
	int c,d,result;
	int done=0;
	char the_addr[80],temp2[80];
#define NICK_ADDR_INDEX 200
	static int addr[NICK_ADDR_INDEX];	/* contains nickname[index].data index */
	char path[FMSIZE];

	result = *obj;
	switch (result)
		{
		case NE_NickUp:
			if (*nick_offset>=10) { *nick_offset-=10; }
			if (*nick_offset==0) { Button_Off(NE_NickUp); }
			Nick_UpDown( dlog, addr_offset, selected_nick, current_nick, nick_offset );
			break; /*goto Nick_UpDown;*/
		case NE_NickDown:
 			Button_On(NE_NickUp);
		/*	if (*nick_offset+10<30) { *nick_offset+=10; } */
			get_tedinfo( dlog, NE_Nick10, temp2 );
			if (temp2[0]!='\0') { *nick_offset+=10; }	/* empty line? */
			Nick_UpDown( dlog, addr_offset, selected_nick, current_nick, nick_offset );
			break; /*goto Nick_UpDown;*/
		case NE_AddrUp:
			if (*addr_offset>=10) { *addr_offset-=10; }
			if (*addr_offset==0) { Button_Off(NE_AddrUp); }
			goto Addr_UpDown;
		case NE_AddrDown:
 			Button_On(NE_AddrUp);
		/*	if (*addr_offset+10<30) { *addr_offset+=10; } */
			get_tedinfo( dlog, NE_Addr10, temp2 );
			if (temp2[0]!='\0') { *addr_offset+=10; }	/* empty line? */
		/*	else { Button_Off(NE_AddrDown); } */
		Addr_UpDown:
 			Button_On(NE_AddrDown);
			for (c=0;c<10;c++) {
				d=addr[c+*addr_offset];
				if (d==-1) { the_addr[0]='\0'; }
				else { sprintf( the_addr, "%.47s", nickname[d].data ); }
				set_tedinfo( dlog, NE_Addr1+c, the_addr );
			}
			if (d==-1) { Button_Off(NE_AddrDown); }
			break;
		case NE_Nick1:
		case NE_Nick2:
		case NE_Nick3:
		case NE_Nick4:
		case NE_Nick5:
		case NE_Nick6:
		case NE_Nick7:
		case NE_Nick8:
		case NE_Nick9:
		case NE_Nick10:
			dlog[result].ob_state|=SELECTED;	/* set nickname selected */
			*selected_nick = result-NE_Nick1+*nick_offset;
			*current_nick = nickname[*selected_nick].nick;
			if (*current_nick<0) { goto Add_Nick; }	/* try to add new nickname */
			set_tedinfo( dlog, NE_Description, nickname[*current_nick+1].data );

			for (c=0;c<NICK_ADDR_INDEX;c++) { addr[c]=-1; }
			*addr_offset=0;
			reset_addrs(dlog, 1);	/* selectable */
			*selected_addr = -1;

			d=0;
			for (c=0;c<NICKNAME_SIZE;c++) {
				if (nickname[c].tag==*current_nick) {
					if (d<10) {
						sprintf( the_addr, "%.47s", nickname[c].data );
						set_tedinfo( dlog, NE_Addr1+d, the_addr );
					}
					addr[d++]=c;
					if (!(d<NICK_ADDR_INDEX)) { break; }
				}
			}
			if (d>=10) { Button_On(NE_AddrDown); }
			break;
		case NE_Addr1:
		case NE_Addr2:
		case NE_Addr3:
		case NE_Addr4:
		case NE_Addr5:
		case NE_Addr6:
		case NE_Addr7:
		case NE_Addr8:
		case NE_Addr9:
		case NE_Addr10:
			if (*current_nick==-1) { break; }
			*selected_addr = result;
			dlog[result].ob_state|=SELECTED;	/* set address selected */
			c=*addr_offset+result-NE_Addr1;
			strcpy( temp2, nickname[addr[c]].data );
		/*	get_tedinfo( dlog, result, temp2 ); */
			if (temp2[0]=='\0') { goto Add_Addr; }
			d=modify_mail_address( temp2, 1 );
			if (d>0) {
				sprintf( the_addr, "%.47s", temp2 );
				set_tedinfo( dlog, result, the_addr );
				strcpy( nickname[addr[c]].data, temp2 );
				if (d==2) {
					nickname[addr[c]].tag=-1;
					addr[c]=-1;
				}
			}
			break;
		case NE_Add:
		Add_Nick:
			if (*current_nick==-1) {
				for (c=0;c<NICKNAME_SIZE-1;c++) {
					if ((nickname[c].tag==-1)&&(nickname[c+1].tag==-1)) {
						*current_nick=c; break; }
						if (c==NICKNAME_SIZE-2) { expand_nicknames(); }
				}
				if (*current_nick==-1) { /* unable to find space */ break; }
				if (modify_nickname(nickname[*current_nick].data, nickname[*current_nick+1].data )) {
					if (nickname[*current_nick].data[0]!='\0') {
						nickname[*current_nick].tag=-2;
						nickname[*current_nick+1].tag=-3;
						nickname[++maximum_nick].nick=*current_nick;
						set_tedinfo( dlog, *selected_nick+NE_Nick1-*nick_offset, nickname[*current_nick].data );
						set_tedinfo( dlog, NE_Description, nickname[*current_nick+1].data );
					}
				} else {
					*current_nick=-1;
					reset_addrs( dlog, 0);	/* not selectable */
					dlog[result].ob_state&=~SELECTED;
				}
				Nick_UpDown( dlog, addr_offset, selected_nick, current_nick, nick_offset );
				/*goto Nick_UpDown;*/
			}
			break;
		Add_Addr:
			c=0; while (nickname[c].tag!=-1) {
				c++;
				if (c==NICKNAME_SIZE) { expand_nicknames(); }
				if (c==NICKNAME_SIZE) { c=-1; break; }
			}
			if (c==-1) { break; }	/* no space available */
			if (modify_mail_address( temp2, 0 )) {
				sprintf( the_addr, "%.47s", temp2 );
				set_tedinfo( dlog, result, the_addr );
				strcpy( nickname[c].data, temp2 );
				nickname[c].tag=*current_nick;
				addr[*addr_offset+result-NE_Addr1]=c;
				}
			break;		
		case NE_Change:
			if (*current_nick>=0) {
				if (modify_nickname(nickname[*current_nick].data, nickname[*current_nick+1].data )) {
					set_tedinfo( dlog, *selected_nick+NE_Nick1-*nick_offset, nickname[*current_nick].data );
					set_tedinfo( dlog, NE_Description, nickname[*current_nick+1].data );
				}
			}
			break;
		case NE_Delete:
			if (*current_nick>=0) {
				if (modify_nickname(nickname[*current_nick].data, nickname[*current_nick+1].data )) {
					nickname[*current_nick].tag=-1;
					nickname[*current_nick+1].tag=-1;
					nickname[*current_nick].data[0]='\0';
					nickname[*current_nick+1].data[0]='\0';
					set_tedinfo( dlog, *selected_nick+NE_Nick1-*nick_offset, "" );

					for (c=0;c<NICKNAME_SIZE;c++) {
						if (nickname[c].tag==*current_nick) {
							nickname[c].tag=-1;
							nickname[c].data[0]='\0';
						}
					}
					c=0; while (nickname[c].nick!=*current_nick) { c++; }
					for (d=c;d<maximum_nick+1;d++) {
						nickname[d].nick=nickname[d+1].nick;
					}
					--maximum_nick;
					Nick_UpDown( dlog, addr_offset, selected_nick, current_nick, nick_offset );
					/*goto Nick_UpDown;*/
				}
			}
			break;
		case NE_Cancel:
			done=1;
			break;
		case NE_OK:
			sprintf( path, "%s\\%s", prefs.mail_path, NICKNAME );
			unload_nicknames(path);
			done=1;
			break;
		}
	return(done);
}

void edit_nicknames_dialog(void)
{
	OBJECT *dlog;
	char path[FMSIZE];
	int result,done=0;
	int nick_offset=0,addr_offset=0;
	int selected_nick=-1,selected_addr=-1;

	rsrc_gaddr(R_TREE,Nickname,&dlog);
	sprintf( path, "%s\\%s", prefs.mail_path, NICKNAME );
	load_nicknames(path);

	Button_Off(NE_NickUp);
	Nick_UpDown( dlog, &addr_offset, &selected_nick, &current_nick, &nick_offset );

	while (!done) {
		result = handle_dialog(dlog, 0);
		done = Nick_Events( dlog, &result, &addr_offset, &selected_nick, &current_nick, &nick_offset, &selected_addr );
	} 
}

/* Wdialog support for edit_nicknames() */

void temp_a4(void)
{
	geta4();
}

int cdecl nick_handle( void *dialog, EVNT *events, int obj, int clicks, void *data )
{
	OBJECT *dlog=NULL;
	GRECT r;
	char path[FMSIZE];
	int event,done=0;
	long a4;
	static int nick_offset=0,addr_offset=0;
	static int selected_nick=-1,selected_addr=-1;

	a4 = getreg( REG_A4 );	/* copy current a4 reg to local variable */
	geta4();				/* establish Lattice global variable base */
	wdlg_get_tree( dialog, &dlog, &r );
	if (obj<0) {
	/*	return(0); */
		switch (obj) 
		{
			case HNDL_INIT:	break;
			case HNDL_MOVE: break;
			case HNDL_TOPW:	break;
			case HNDL_OPEN:
				sprintf( path, "%s\\%s", prefs.mail_path, NICKNAME );
				load_nicknames(path);
				Button_Off(NE_NickUp);
				Nick_UpDown( dlog, &addr_offset, &selected_nick, &current_nick, &nick_offset );
 				break;
			case HNDL_CLSD: done++; /* return(0); */ break;
			case HNDL_UNTP: break;
			case HNDL_EDIT: break;
			case HNDL_EDDN: break;
			case HNDL_EDCH: break;
		}
	} else {
	/*	return(0); */
	/*	fprintf( log, "wdlg obj=%d\n", obj ); fflush(log); */
		if (dlog[obj].ob_flags&EXIT) {
			dlog[obj].ob_state&=~SELECTED;	/* de-select exit buttons */
		}
		switch (obj)
		{
			case NE_Cancel: done++; /* return(0); */
		/*	case NE_OK: return(0);
			/*	sprintf( path, "%s\\%s", prefs.mail_path, NICKNAME );
				unload_nicknames(path);
				ret=0; */
				break;
			default:
				event = obj;
				done = Nick_Events( dlog, &event, &addr_offset, &selected_nick, &current_nick, &nick_offset, &selected_addr );
				wind_update( BEG_UPDATE );
				wdlg_redraw( dialog, &r, ROOT, MAX_DEPTH );
				wind_update( END_UPDATE );
				break;
		}
	}
	putreg( REG_A4, a4 ); 	/* restore previous a4 register from variable */
	return(!done);			/* continue */
}

int handle_wdialog_events( DIALOG *dialog, EVNT *ev )
{
	int res;
	int flags=MU_KEYBD|MU_BUTTON|MU_MESAG|MU_TIMER;

/*	res = evnt_multi( flags, 2, 1, 1, */
	res = evnt_multi( flags, 0x0102, 3, 0,	/* left or right mouse */
				0, 0, 0, 0, 0,
				0, 0, 0, 0, 0,
				ev->msg, 0, 0,
				&(ev->mx), &(ev->my), &(ev->mbutton), &(ev->kstate), &(ev->key), &(ev->mclicks) );
	ev->mwhich = res;
	res = wdlg_evnt( dialog, ev );
	if (ev->mwhich&MU_MESAG) { do_message_events( ev->msg ); }
	if (ev->mwhich&MU_KEYBD) { do_keyboard_events( ev->kstate, ev->key ); }
	if (ev->mwhich&MU_BUTTON) { do_mouse_events( ev->mx, ev->my, ev->mbutton, ev->mclicks ); }
	auto_top_window(ev->mx, ev->my, ev->mwhich);
/*	sort_clock=clock()+CLK_TCK; */
	return(res);
}

int edit_nicknames_window(void)
{
	DIALOG *dialog=NULL;
	static int handle=-1;
	OBJECT *tree;
	EVNT events;
	int kind=NAME|CLOSER|MOVER;
	int rc=0;
	
	menu_tnormal(menu_ptr,M_Mail,1);	/* reset menubar */
	if (handle>=0) {	/* make it the top window */
	/*	nick_handle( dialog, NULL, HNDL_TOPW, 1, NULL ); */
		wind_set( handle, WF_TOP, 0, 0, 0, 0 );
		return(1);
	}
	rsrc_gaddr( R_TREE, Nickname, &tree );
	dialog = wdlg_create( nick_handle, tree, NULL, 1, NULL, WDLG_BKGD );
	if (dialog!=NULL) {
		handle = wdlg_open( dialog, "Edit Nicknames", kind, -1, -1, 1, NULL );
		if (handle) {
		/*	fprintf( log, "wdlg_open = %d\n", handle ); fflush(log); */
			while (handle_wdialog_events( dialog, &events )!=0) {
				if (finished) { break; }
			}
		/*	fprintf( log, "wdlg_close and delete\n" ); fflush(log); */
			wdlg_close( dialog );
			rc++;
		}
		wdlg_delete( dialog );
		handle=-1;		/* mark window closed */
	}
	return(rc);
}

void edit_nicknames(void)
{
	if (WDialog()) { if (edit_nicknames_window()) { return; } }
	edit_nicknames_dialog();
}

#define NICKS_SIZE 300
void display_nicknames(OBJECT *tree, int obj, int include_nicks )
{
	char buff[128],*dest,*nick;
	OBJECT *dlog;
	int result,c=0,fstart=0,d,abk=200;
	int x,y,w,h;
	char empty=0,real_nick[30][20];
	char *nicks[NICKS_SIZE];
	FILE *fid;
/*	MFDB save; */

	for (d=0;d<NICKS_SIZE; d++) { nicks[d]=&empty; }

	if (include_nicks) {
		sprintf( buff, "%s\\%s", prefs.mail_path, NICKNAME );
		fid =fopen( buff, "ra" );
		if (fid!=NULL) {
			while (fgets( buff, sizeof(buff), fid )!=NULL ) {
				nick = strtoka( buff, '\t' );	/* get nickname */
				if (nick[0]!='\0') {
	 				strcpy( real_nick[c], nick );
					nicks[c] = real_nick[c];
					c++;
				}
				if (c>=30) { break; }	/* internal array limit */
			}
			fclose( fid );
		}
	}
#if (0)
	if (Addr_Book==NULL) {		/* make address book available */
		sprintf( buff, "%s\\%s", program_path, "ADDRESS.ABK" );
		load_address_book( buff );
	}
#endif
	if (Addr_Book!=NULL) {
		abk=c;			/* start point */
		d=0;
		while (c<NICKS_SIZE) {
			if (Addr_Book[d].name[0]!='\0') {
				nicks[c] = Addr_Book[d++].name;
			} else { break; }	/* finished */
			c++;
		}	
	}
	if (*nicks[0]=='\0') { return; }

	rsrc_gaddr(R_TREE,Font_List,&dlog);
	form_center(dlog,&x,&y,&w,&h);
	objc_offset( tree, obj+1, &x, &y );		/* locate email name */
	x-=8; y-=4;

	if (x<0) { x=0; }
	if ((x+w)>(screenx+screenw)) { x = screenx + screenw - w; }
	if ((y+h)>(screeny+screenh)) { y = screeny + screenh - h; }

	dlog[0].ob_x = x;
	dlog[0].ob_y = y;

	if (!save_restore_screen( 1, dlog )) {	/* save */
		form_dial(FMD_START,0,0,0,0,x,y,w,h);
	}
	get_tedinfo( tree, obj+1, buff );
	set_tedinfo( dlog, FL_Exit1, buff );
	do {
		for (c=FL_FontName1;c<FL_FontName10+1;c++) {
			d = fstart+c-FL_FontName1;
			dest=(char *)dlog[c].ob_spec;
			strcpy(dest,nicks[d]);
		}
		objc_draw(dlog,0,10,x,y,w,h);
		result=form_do(dlog, 0);
		switch (result)
		{
			case FL_UpArrow :
				fstart = (fstart-10 > 0) ? fstart-10 : 0;	/* maximum */
				break;
			case FL_DnArrow :
			/*	if (nicks[fstart+9][0]=='\0') { break; }	/* last in display */
				if (*nicks[fstart+9]=='\0') { break; }	/* last in display */
				fstart = (fstart+10 < NICKS_SIZE) ? fstart+10 : NICKS_SIZE;	/* minimum */
				break;
			case FL_Exit1 :
			case FL_Exit2 :
				break;
			default :
			/*	d = nickname[fstart+result-FL_FontName1].nick; */
				d = fstart+result-FL_FontName1;
				set_tedinfo( tree, obj+1, nicks[d]);
			/*	if (nicks[d][0]=='\0') { break; }	/* if empty */
				if (*nicks[d]=='\0') { break; }	/* if empty */
				if (d>=abk) {		/* Address Book entry */
					c=d-abk;
					sprintf( buff, "%s (%s)", Addr_Book[c].email, Addr_Book[c].name );
					if (strlen(buff)>50) { strcpy( buff, Addr_Book[c].email ); }
					set_tedinfo( tree, obj+1, buff );
				}
		}
		dlog[result].ob_state&=~SELECTED;	/* de-select exit button */
	} while ((result==FL_UpArrow)|(result==FL_DnArrow ));
	if (!save_restore_screen( 0, dlog )) {	/* restore */
		h-=	tree[0].ob_y + tree[0].ob_height - y;
		if (h>0) {
			y =	tree[0].ob_y + tree[0].ob_height;
			form_dial(FMD_FINISH,0,0,0,0,x,y+2,w,h-2);
			handle_redraw_event();
		}
	}
}

/* Address Book */

void open_popup_address_book_name( char *fname )
{
	int c=2;
	char dirname[FMSIZE],path[FMSIZE],select[FMSIZE];

	sprintf( dirname, "%s\\", program_path );
	if (fname[0]==' ') { c=1; }	/* "  new  " */
	if (fname[0]=='\0') {	/* passed empty string? */
	/*	c = filelist_popup( dirname, "*.abk" ); */
		strcpy( fname, "address.abk" );
		strcat( dirname, fname );	/* default to address.abk */
	} else {
		strcat( dirname, fname );	/* complete address book path in dirname */
	}

	if (c==0) { return; }
	if (c==1) { if (!select_address_book( dirname )) { return; } }
	stcgfn( select, dirname );
	strtok( select, "." );
	strupr( select );	/* force uppercase */
	strlwr( select+1 );	/* leave only first char uppercase */
	sprintf( path, "%s %s", ErrMsg(EM_AddressBook), select );
	open_address_book( path, dirname );
}

int select_address_book(char *dirname)
{
	char select[FMSIZE];
	char path[FMSIZE];
	int button;

	strcpy( select, "*.abk" );
	sprintf( dirname, "%s\\%s", program_path, select );	
	fsel_exinput( dirname, select, &button, ErrMsg(EM_SAddrBook) );	/* Select Address Book */
	if (button) {
		stcgfp( path, dirname );
		sprintf( dirname, "%s\\%s", path, select );
		rebuild_attach_list( dirname, "abk" );	/* update address book list */
	/*	fprintf( log, "dir %s, sel %s, filename %s\n", path, select, dirname ); */
	}
	return(button);
}

void open_address_book(char *title, char *path)
{
	load_address_book( path );
	new_window( 14, title, 400, 50, 200, 300 );
	windows[14].clear=1;
}

void read_address_book(char *filename, A_BOOK *Addr_Book, int alloc)
{
	FILE *fid;
	char buff[200],*name,*email,*org;
	int c;

	graf_mouse( BUSY_BEE, NULL );
	previous_abook = -1;
	current_abook = -1;
	maximum_abook = alloc;
	strcpy( current_address_book, filename );	/* new address book */
	fid = fopen( filename, "ra" );
	if (fid!=NULL) {
	/*	fprintf( log, "Loading Mailbox: %s\n", filename ); */
		for (c=0;c<alloc;c++) {
			Addr_Book[c].name[0]='\0';
			if (fgets( buff, sizeof(buff), fid )!=NULL) {
				name  = strtoka( buff, '\t' );	/* user name */
				email = strtoka( NULL, '\t' );	/* email address */
				org   = strtoka( NULL, '\n' );	/* organization, etc. */
				strcpy(Addr_Book[c].name, name);
				strcpy(Addr_Book[c].email, email);
				strcpy(Addr_Book[c].password, org);
			}
		}
		fclose( fid );
	}
	graf_mouse( ARROW, NULL );
}

void load_address_book(char *filename)
{
	int lines,alloc;

	if (Addr_Book!=NULL) { free( Addr_Book ); }
	lines = (int16)count_lines( filename );
	alloc = lines + 50;
	Addr_Book = (A_BOOK *)calloc( alloc, sizeof(A_BOOK) );
	read_address_book( filename, Addr_Book, alloc );
	windows[14].num_lines=lines;
	windows[14].line_no=0;
}

void unload_address_book(char *filename)
{
	FILE *fid;
	int c;

	if (maximum_abook==-1) { return; }		/* nothing loaded */
	if (Addr_Book==NULL) { return; }
	fid = fopen( filename, "wa" );
	if (fid!=NULL) {
		graf_mouse( BUSY_BEE, NULL );
		for (c=0;c<maximum_abook;c++) {
			if (Addr_Book[c].name[0]!='\0') {
				fprintf( fid, "%s\t%s\t%s\n",
				Addr_Book[c].name, Addr_Book[c].email, Addr_Book[c].password );
			}
		}
		fclose( fid );
		graf_mouse( ARROW, NULL );
	}
}

void format_address_book_line(int c, char *buff)
{
	if (Addr_Book!=NULL) {
		sprintf( buff, "%-30.30s %-40.40s %-30.30s",
				Addr_Book[c].name, Addr_Book[c].email,
				Addr_Book[c].password );
	}
}

void address_book_text(int wid)
{
	GRECT work;
	int x,y,c,lpp,start,end,refresh=1;
	char buff[200];
	OBJECT *bar;

	x = wind_get( wid, WF_WORKXYWH, &work.g_x, &work.g_y, &work.g_w, &work.g_h);
	setup_toolbar(14, &work.g_x, &work.g_y, &work.g_w, &work.g_h );
	lpp = setup_text( wid, 14, prefs.overview_font, prefs.overview_font_size,
				work.g_h, windows[14].num_lines ); 
	x=work.g_x;
	y=work.g_y;
	if (windows[14].clear) {
		clear_rect( &work);
		refresh=0;
		if ((bar=windows[14].bar_object)!=NULL) {
			objc_draw( bar, ROOT, 1, clip.g_x, clip.g_y, clip.g_w, clip.g_h );
		}
	}

	start = windows[14].line_no;
	end   = start + lpp;
	if (end>windows[14].num_lines) { end=windows[14].num_lines; }
	for (c=start;c<end;c++) {
		if (c>=0) {
			if ( Addr_Book[c].name[0]!='\0') {
				y+=cellh;
				if (refresh) {
					if (c==current_abook) {
						format_address_book_line( c, buff );
						set_selected_text( 1 );
						v_gtext( handle, x, y, buff );
						set_selected_text( 0 );
					} 
					if (c==previous_abook) {
						format_address_book_line( c, buff );
						v_gtext( handle, x, y, buff );
						set_selected_text( 0 );
					}
				} else {
					format_address_book_line( c, buff );
					if (c==current_abook) { set_selected_text( 1 ); }
					v_gtext( handle, x, y, buff );
					set_selected_text( 0 );
				}
			}
		}
	} 
}

int edit_address_entry(int c)
{
	/* return 1 if edit ok or 0 if cancel */
	OBJECT *dlog;
	char temp;
	
	rsrc_gaddr(R_TREE, Address_Book, &dlog);
	set_tedinfo( dlog, AB_Name, Addr_Book[c].name );
	temp=Addr_Book[c].password[29];
	Addr_Book[c].password[29]='\0';	/* prevent string overrun */
	set_tedinfo( dlog, AB_Notes, Addr_Book[c].password );
	set_tedinfo( dlog, AB_Email, Addr_Book[c].email );
	if (handle_dialog(dlog, AB_Name)==AB_OK) {
		get_tedinfo( dlog, AB_Name, Addr_Book[c].name );
		get_tedinfo( dlog, AB_Notes, Addr_Book[c].password );
		get_tedinfo( dlog, AB_Email, Addr_Book[c].email );
		Addr_Book[c].password[29]=temp;
		return(1);
	}
	Addr_Book[c].password[29]=temp;
	return(0);
}

int address_book_cmp( const void *a, const void *b )
{
	const A_BOOK *ma,*mb;
	char *ca,*cb;
	ma=a;
	mb=b;

	ca = strrchr( ma->name, ' ' );	/* look for last name */
	cb = strrchr( mb->name, ' ' );
	if ((ca!=NULL)&&(cb!=NULL)) {
		return( strcmp( ca+1, cb+1 ));
	}	
	return ( strcmp( ma->name, mb->name ) );
}

int find_text_addressbook(int wx, char start, char *key)
{
	int found=0,line;
	char *where;

	if (start=='Y') { line=0; } else { line=current_abook+1; }
	while (line<maximum_abook+1) {
		if (stcpm( Addr_Book[line].name, key, &where )) { found=1; break; }
		if (stcpm( Addr_Book[line].name,  key, &where )) { found=1; break; }
		if (stcpm( Addr_Book[line].name,  key, &where )) { found=1; break; }
		line++;
	}
	if (found) {
		if ((line<windows[wx].line_no)||(line>=windows[wx].line_no+windows[wx].lines_per_page)) {
			windows[wx].line_no = line;
		} else {
			found=2;	/* on same page, no erase needed */
		}
	/*	windows[wx].line_no = line; */
		previous_abook=current_abook;
		current_abook=line;
	/*	strcpy( current_mailmsg, mailbox[current_mail].filename ); */
		set_reply( wx );
	}
	return(found);
}

void key_address(int keycode)
{
	char path[FMSIZE],select[FMSIZE];
	int c;

	if (arrow_page_scrolling_keys( windows[14].id, keycode )) { return; }

	if ((keycode>>8)=='\x48') {	/* up arrow */
		if (current_abook>0) {
			previous_abook = current_abook;
			current_abook--;
			if (current_abook<windows[14].line_no) {
				handle_arrows( windows[14].id, WA_UPPAGE );
			} else {
				refresh_window( windows[14].id );
			}
		}
		return;
	}
	if ((keycode>>8)=='\x50') {	/* down arrow */
		if (current_abook<windows[14].num_lines-1) {
			previous_abook = current_abook;
			current_abook++;
			if (current_abook>=windows[14].line_no+windows[14].lines_per_page) {
				handle_arrows( windows[14].id, WA_DNPAGE );
			} else {
				refresh_window( windows[14].id );
			}
		}	
		return;
	}
	if ((char)keycode=='\r') {	/* return = send mail */
		if (current_abook>=0) {
			sprintf( path, "%s\\%s", prefs.work_path, MAILTEST );
			Mail_Message_dialog(0, path );
		}
		return;
	}
	if ((char)keycode=='s') {	/* s = sort address book by name */
		if (Addr_Book!=NULL) {
			qsort( Addr_Book, windows[14].num_lines, sizeof(A_BOOK), address_book_cmp );
			unload_address_book(current_address_book);
			refresh_clear_window( windows[14].id );
		}
		return;
	}
	if ((char)keycode=='?') {	/* ? = edit address book entry */
		if (current_abook>=0) {
			if (edit_address_entry(current_abook)) {
				unload_address_book(current_address_book);
				refresh_window( windows[14].id );
			}
		}	
		return;
	}
	if ((keycode>>8)=='\x52') {	/* insert - add new entry */
		if (windows[14].num_lines<maximum_abook) {
			if (edit_address_entry(windows[14].num_lines)) {
				windows[14].num_lines++;
				qsort( Addr_Book, windows[14].num_lines, sizeof(A_BOOK), address_book_cmp );
				unload_address_book(current_address_book);
				refresh_clear_window( windows[14].id );
			}
		}	
		return;
	}
	if ((keycode>>8)=='\x53') {	/* delete an entry */
		if (current_abook>=0) {
			if (current_abook<windows[14].num_lines) {
				for (c=current_abook;c<windows[14].num_lines;c++) {
					memcpy( &Addr_Book[c], &Addr_Book[c+1], sizeof(A_BOOK) );
				}		
			}
			memset( &Addr_Book[windows[14].num_lines--], 0, sizeof(A_BOOK) );	/* reduce by 1 */
			if (current_abook>windows[14].num_lines-1) { current_abook = -1; }
			unload_address_book(current_address_book);
			refresh_clear_window( windows[14].id );
		}
	}
	if ((char)keycode=='l') {	/* l = load address book by name */
		if (Addr_Book!=NULL) {
			unload_address_book(current_address_book);
		/*	call file selector(*.ABK) or produce popup display */
			sprintf( path, "%s\\", program_path );
			c = filelist_popup(path, "*.abk");
			if (c==0) { return; }
			if (c==1) { if (!select_address_book( path )) { return; } }
		/*	fprintf( log, "Address Book = %s\n", path ); */
			load_address_book( path );

			stcgfn( select, path );		/* change window title */
			strtok( select, "." );
			strupr( select );	/* force uppercase */
			strlwr( select+1 );	/* leave only first char uppercase */
			sprintf( path, "%s: %s", ErrMsg(EM_AddressBook), select );
			new_window( 14, path, 400, 50, 200, 300 );
			windows[14].clear=1;
		/*	strcpy( windows[14].title, path ); */
		/*	refresh_clear_window( windows[14].id ); */
		}
		return;
	}
}

void select_address(int vert, int clicks)
{
	int rc,index,refresh;
	char path[FMSIZE];

	rc = atoi( prefs.overview_font_size );
	vst_point( handle, rc, &charw, &charh, &cellw, &cellh );
	index = (vert / cellh ) + windows[14].line_no;
	if (index<windows[14].num_lines) {
		if (Addr_Book[index].name[0]!='\0') {
			refresh = (current_abook!=index);
			previous_abook = current_abook;
			current_abook = index;
			if (clicks>1) {
				sprintf( path, "%s\\%s", prefs.work_path, MAILTEST );
				Mail_Message_dialog(0, path );
				handle_redraw_event();
				if (refresh) { refresh_window( windows[14].id ); }
			} else {
				if (refresh) { refresh_window( windows[14].id ); }
			}
		}
	}
}

void add_to_address_book(void)
{
	char path[FMSIZE];
	int top,c,update=0;

	/* handle reallocation if (windows[14].num_lines==maximum_abook-1)  */
	if (Addr_Book==NULL) {
		sprintf( path, "%s\\%s", program_path, "ADDRESS.ABK" );
		load_address_book( path);
	}
	c=windows[14].num_lines;

	/* determine top window, move data to dialog to edit */
	wind_get( 0, WF_TOP, &top, NULL, NULL, NULL );
	if ((windows[6].id==top)||(windows[7].id==top)) {	/* mail */
		if (current_mail>=0) {
			strcpy( Addr_Book[c].name, mailbox[current_mail].author );
			strcpy( Addr_Book[c].email, mailbox[current_mail].author_email );
			update++;
		}
	}
	if ((windows[2].id==top)||(windows[3].id==top)) {	/* news */
		if (current_overview>=0) {
			strcpy( Addr_Book[c].name, overview[current_overview].author );
			strcpy( Addr_Book[c].email, overview[current_overview].author_email );
			update++;
		}
	}
	if (update) {
		Addr_Book[c].password[0]= '\0';
		if (edit_address_entry( c )) {
			windows[14].num_lines++;
			qsort( Addr_Book, windows[14].num_lines, sizeof(A_BOOK), address_book_cmp );
			unload_address_book(current_address_book);
			if (windows[14].open) { refresh_clear_window( windows[14].id ); }
		} else {
			Addr_Book[c].name[0]='\0';	/* if cancel, clear again */
			Addr_Book[c].email[0]='\0';
		}
	}
}

/* end of address.c */