/* support for GEMScript for NEWSie */

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
#include "global.h"

#define VERSION "0.96  Nov 29, 1999"
#define MT _AESglobal[1]!=1		/* Multi-tasking OS */
#define MAX_MENU_ITEM MP_Save	/* change when Menu (NEWSie) is updated */

#define GS_REQUEST 0x1350
#define GS_REPLY 0x1351
#define GS_COMMAND 0x1352
#define GS_ACK 0x1353
#define GS_QUIT 0x1354
#define GS_OPENMACRO 0x1355
#define GS_MACRO 0x1356
#define GS_WRITE 0x1357
#define GS_CLOSEMACRO 0x1358

#define GSM_COMMAND 0x0001
#define GSM_MACRO 0x0002
#define GSM_WRITE 0x0004

#define GSACK_OK 0
#define GSACK_UNKNOWN 1
#define GSACK_ERROR 2

typedef struct {
 long len;		/* length the structure in bytes */
 int version;		/* version of the Protocol by the transmitter (i.e. 0x0110 = 1.1) */
 int msgs;		/* Bitmap the supported news (GSM_xxx) */
 long ext;		/* used ending, about '.SIC' */
} GS_INFO;

/* GSM_COMMAND = 0x0001 /* can GS_COMMAND receive */
/* GSM_MACRO = 0x0002 /* can GS_OPENMACRO, GS_WRITE and GS_CLOSEMACRO receive, GS_MACRO send out (Interpreter) */
/* GSM_WRITE = 0x0004 /* can GS_OPENMACRO, GS_WRITE and GS_CLOSEMACRO send out, GS_MACRO receive (aufnahmef„hige application) */

/* 0: (GSACK_OK) OK, command was or will be executed
   1: (GSACK_UNKNOWN) command unknown
   2: (GSACK_ERROR) error (command not executed)
 */

int GEMScript_set_id(int set)
{
	static int applid=-1;

	if (set) { applid=set; }
	return(applid);
}

#define GEMScript_id() GEMScript_set_id(0)

/* At application startup: (Only needed if application is sending commands to another app)
   1. Find Server via appl_find(SCRIPTER), or appl_find(SSCRIPT)
   2. If either found allocate GS_INFO and send GS_REQUEST
 */

void startup_GEMScript(void)
{
	int id=0;
	char *env;

	if( MT ) {	/* for Multi-tasking OS'es only */
		if (id=appl_find("SCRIPTER")>=0) { GEMScript_set_id(id); }
		if (id==0) {
			if (id=appl_find("SSCRIPT ")>=0) { GEMScript_set_id(id); }
		}
		if (id==0) {
			if ((env = getenv("GEMSCRIPT"))==NULL) { }
		}
	}
}

void send_GEMScript_Request( int *msg )
{
	int id;

	msg[0] = GS_REQUEST;
	msg[1] = _AESglobal[2];
	if ((id=GEMScript_id())>=0) { appl_write( id, 16, msg ); }
}

void send_GEMScript_Reply( int *msg )
{
	int id;

	msg[0] = GS_REPLY;
	msg[1] = _AESglobal[2];
	if ((id=GEMScript_id())>=0) { appl_write( id, 16, msg ); }
}

#define MGLOBAL 0x20
#define MagX_COOKIE 0x4D616758L
#define MiNT_COOKIE 0x4D694E54L

void *allocate_global_memory( int size )
{
	void *memory;
	long val;

	if ((getcookie( MagX_COOKIE, &val ) == TRUE) ||
		(getcookie( MiNT_COOKIE, &val ) == TRUE)) {
		memory = Mxalloc (size, 0 | MGLOBAL);
	} else {
		memory = Malloc (size);
	}
	return(memory);
}

/* in NEWSAES.C in do_messages_events() for all messages 0x13xx */
void do_GEMScript_events( int *msg )
{
	long *p;
	static char *reply=NULL;

	if (!reply) {		/* if buffer has not been allocated */
		reply = (char * ) allocate_global_memory( 256 );
		if (!reply) { return; }	/* unable to allocate, cannot continue */
	}

	switch(msg[0])
	{
	/* If GS_REQUEST received */
		case GS_REQUEST:
			fprintf( log, "GS_REQUEST received from %d\n", msg[1] ); fflush(log);
		/* may choose to decline GEMScript depending upon conditions (as yet unknown) */
			GEMScript_set_id(msg[1]);	/* store id */
			msg[6] = 0;			/* zero = supported */
			send_GEMScript_Reply( msg );	/* acknowledge support */
			break;

	/* If GS_REPLY received (only when initiated by this program) */
		case GS_REPLY:
			fprintf( log, "GS_REPLY received from %d\n", msg[1] ); fflush(log);
			if (msg[6]==0) { GEMScript_set_id(msg[1]); }
			break;

	/* If GS_COMMMAND received:
	   1. parse and handle if possible
	      (Close,Copy,Cut,Delete,GetFront,New,Open,Paste,Print,Quit,Save,SaveAs,SelectAll,ToFront,Undo,AppGetLongName)
	      (Exec,CheckApp)
	   2. Respond with GS_ACK at completion
	*/
		case GS_COMMAND:
			fprintf( log, "GS_COMMAND received from %d\n", msg[1] ); fflush(log);
			p=(long *)&msg[3];	/* command line in mbuff[3 & 4] */
			p=(long *)*p;
			msg[5]=msg[6]=0;	/* if requestor forgot to clear previous reply */
			reply[0]=reply[1]='\0';	/* initialize reply to empty */
			msg[7] = parse_GEMScript_command( (char *)p, reply );
			if (reply[0]!='\0') {
				p=(long *)&msg[5];	/* reply line in mbuff[5 & 6] */
				*p=(long)reply;
			}
			send_GEMScript_Ack( msg );

			if (strcmp( reply+1, "quit" )==0) {
				send_GEMScript_Quit();	/* tell requestor going away */
			}
			break;

	/* If GS_ACK received, no action needed */
		case GS_ACK:
			fprintf( log, "GS_ACK received from %d\n", msg[1] ); fflush(log);
			break;
	}
}

void parameter_error(int error, char *reply)
{
	memset(reply,0,256);	/* clear entire reply area */
	if (error==1) { strcpy( reply, "Unsupported Command" ); return; }
	if (error==2) { strcpy( reply, "Unsupported Parameter" ); return; }
	if (error==3) { strcpy( reply, "Unsupported Parameter Format" ); return; }
	if (error==4) { strcpy( reply, "Too many parameters" ); return; }
}

/* Add support for "standard" window names, returns window index */
int validate_standard_window( char *name )
{
	if (strnicmp( "Status", name, 6)==0)		{ return(0); }
	if (strnicmp( "Subscribed", name, 10)==0)	{ return(1); }
	if (strnicmp( "Overview", name, 8)==0)		{ return(2); }
	if (strnicmp( "Article", name, 7)==0)		{ return(3); }
	if (strnicmp( "FullGroups", name, 10)==0)	{ return(4); }
	if (strnicmp( "NewGroups", name, 9)==0)		{ return(5); }
	if (strnicmp( "Mailbox", name, 7)==0)		{ return(6); }
	if (strnicmp( "Mail", name, 4)==0)		{ return(7); }
	if (strnicmp( "Help", name, 4)==0)		{ return(8); }
	if (strnicmp( "Log", name, 3)==0)		{ return(9); }
	if (strnicmp( "Viewer", name, 6)==0)		{ return(10); }
	if (strnicmp( "Server", name, 6)==0)		{ return(11); }
	if (strnicmp( "Browser", name, 7)==0)		{ return(12); }
	if (strnicmp( "Address", name, 7)==0)		{ return(14); }
	return(-1);	/* unknown window name */
}

/* Add support for "standard" window names, returns name for window index */
void return_standard_window( int index, char *name )
{
	name[0]='\0';
	if (index==0) { strcpy( name, "Status" ); return; }
	if (index==1) { strcpy( name, "Subscribed" ); return; }
	if (index==2) { strcpy( name, "Overview" ); return; }
	if (index==3) { strcpy( name, "Article" ); return; }
	if (index==4) { strcpy( name, "FullGroups" ); return; }
	if (index==5) { strcpy( name, "NewGroups" ); return; }
	if (index==6) { strcpy( name, "Mailbox" ); return; }
	if (index==7) { strcpy( name, "Mail" ); return; }
	if (index==8) { strcpy( name, "Help" ); return; }
	if (index==9) { strcpy( name, "Log" ); return; }
	if (index==10) { strcpy( name, "Viewer" ); return; }
	if (index==11) { strcpy( name, "Server" ); return; }
	if (index==12) { strcpy( name, "Browser" ); return; }
	if (index==14) { strcpy( name, "Address" ); return; }
}

/* Add support for "standard" keyboard key names, returns AES keycode */
int validate_standard_key( char *name )
{
	if (strnicmp( "Return", name, 6)==0)		{ return('\r'); }
	if (strnicmp( "Delete", name, 6)==0)		{ return(0x5300); }
	if (strnicmp( "Insert", name, 8)==0)		{ return(0x5200); }
	if (strnicmp( "Backspace", name, 9)==0)		{ return(0x0e00); }
	if (strnicmp( "UpArrow", name, 7)==0)		{ return(0x4800); }
	if (strnicmp( "DownArrow", name, 9)==0)		{ return(0x5000); }
	if (strnicmp( "LeftArrow", name, 9)==0)		{ return(0x4b00); }
	if (strnicmp( "RightArrow", name, 10)==0)	{ return(0x4d00); }
	if (strnicmp( "Help", name, 4)==0)		{ return(0x6200); }
	if (strnicmp( "Undo", name, 4)==0)		{ return(0x6100); }
	if (strnicmp( "PageUp", name, 6)==0)		{ return(0x4838); }
	if (strnicmp( "PageDown", name, 8)==0)		{ return(0x5032); }
	if (strnicmp( "Home", name, 4)==0)		{ return(0x4700); }
	if (strnicmp( "Bottom", name, 6)==0)		{ return(0x4737); }
	return(-1);	/* unknown key name */
}

int parse_GEMScript_command( char *command, char *reply )
{
	char *parms[10];
	int x,rc=GSACK_UNKNOWN;
	OBJECT *dlog;
	long parm_len,nparms;
	int msg[8],wx;

	for (x=0;x<10;x++) { parms[x]=NULL; }
	if ((nparms=strbpl(parms,10,command))==-1) {
		parameter_error(4, reply);
		return(GSACK_ERROR);
	}
	fprintf( log, "GS_COMMAND contains %ld parameters\n", nparms ); fflush(log);

/*	handle first character \1,\2,\3, etc. transformations for parms[1-9] */
	for (x=1;x<nparms;x++) {
		if (parms[x]!=NULL) {
			if (*parms[x]=='\1') { parameter_error(3, reply); return(GSACK_ERROR); }	/* unsupported */
			if (*parms[x]=='\2') { parameter_error(3, reply); return(GSACK_ERROR); }	/* unsupported */
			if (*parms[x]=='\3') { parameter_error(3, reply); return(GSACK_ERROR); }	/* unsupported */
			if (*parms[x]=='\4') { parameter_error(3, reply); return(GSACK_ERROR); }	/* unsupported */
			if (*parms[x]=='\5') { parameter_error(3, reply); return(GSACK_ERROR); }	/* unsupported */
			if (*parms[x]=='\6') { parameter_error(3, reply); return(GSACK_ERROR); }	/* unsupported */
		}
	}

	if (stricmp("Close",command)==0) {
		if (nparms==1) {	/* if command only */
			handle_File_menu( MF_Close );	/* close top window */
			return(GSACK_OK);
		}
		if ((wx=validate_standard_window( parms[1] ))<0) {
			parameter_error(2, reply);	/* Unsupported window name */
			return(GSACK_ERROR);	/* error */
		}
		if (!windows[wx].open) { return(GSACK_ERROR); }	/* error */
		msg[0] = WM_CLOSED;
		msg[3] = windows[wx].id;
		do_message_events( msg );
		return(GSACK_OK);
	/*	parameter_error(2, reply);	/* Unsupported Parameter */
	/*	return(GSACK_ERROR);	/* does not handle other windows yet */
	}
	if (stricmp("Copy",command)==0) {
		handle_menu( M_Edit, ME_Copy );
		return(GSACK_OK);
	}
	if (stricmp("Cut",command)==0) {
		handle_menu( M_Edit, ME_Cut );
		return(GSACK_OK);
	}
	if (stricmp("Delete",command)==0) {
		parameter_error(1, reply);
		return(rc);
	}
	if (stricmp("GetFront",command)==0) {
		wind_get( 0, WF_TOP, &x, NULL, NULL, NULL );
		for (wx=0;wx<WINDOWS_SIZE;wx++) {
			if (x==windows[wx].id) {
				return_standard_window( wx, reply );
				return(GSACK_OK);	/* found top window */
			}
		}
		return(GSACK_ERROR);	/* error */
	/*	parameter_error(1, reply);
		return(rc); */
	}
	if (stricmp("New",command)==0) {
		parameter_error(1, reply);
		return(rc);
	}
	if (stricmp("Open",command)==0) {
		handle_menu( M_File, MF_Open );
		return(GSACK_OK);
	}
	if (stricmp("Paste",command)==0) {
		handle_menu( M_Edit, ME_Paste );
		return(GSACK_OK);
	}
	if (stricmp("Print",command)==0) {
		handle_menu( M_File, MF_Print );
		return(GSACK_OK);
	}
	if (stricmp("Quit",command)==0) {
		handle_menu( M_File, MF_Quit );
		strcpy( reply+1, "quit" );	/* tell requestor going away */
		return(GSACK_OK);
	}
	if (stricmp("Save",command)==0) {
		handle_menu( M_File, MF_Save );
		return(GSACK_OK);
	}
	if (stricmp("SaveAs",command)==0) {
		handle_menu( M_File, MF_SaveAs );
		return(GSACK_OK);
	}
	if (stricmp("SelectAll",command)==0) {
		parameter_error(1, reply);
		return(rc);
	}
	if (stricmp("ToFront",command)==0) {
		if ((wx=validate_standard_window( parms[1] ))<0) {
			parameter_error(2, reply);	/* Unsupported window name */
			return(GSACK_ERROR);	/* error */
		}
		if (!windows[wx].open) { return(GSACK_ERROR); }	/* error */
		wind_set( windows[wx].id, WF_TOP, 0, 0, 0, 0 );
		set_menu_list( wx );
		return(GSACK_OK);
	/*	parameter_error(1, reply);
		return(rc); */
	}
	if (stricmp("Undo",command)==0) {
		do_keyboard_events( 0, 0x6100 );
		return(GSACK_OK);
	}
	if (stricmp("AppGetLongName",command)==0) {
		parameter_error(1, reply);
		return(rc);
	}
	if (stricmp("Exec",command)==0) {
		parameter_error(1, reply);
		return(rc);
	}
	if (stricmp("CheckApp",command)==0) {
		parameter_error(1, reply);
		return(rc);
	}
	if (stricmp("Menu",command)==0) {	/* non-standard, single parameter = Menu Title text */
		rsrc_gaddr( R_TREE, NEWSie, &dlog );
		if (dlog!=NULL) {
			parm_len= strlen(parms[1]);
			for (x=0;x<MAX_MENU_ITEM+1;x++) {
				if (dlog[x].ob_type==G_STRING) {
				/*	fprintf( log, "comparing to %*s\n", (int)parm_len, (char *)dlog[x].ob_spec+2 ); */
					if (strnicmp( parms[1], (char *)dlog[x].ob_spec+2, parm_len )==0) {
						handle_menu( 0, x );
					/*	fprintf( log, "menu index=%d: %s\n", index, fkeys[index] ); */
						return(GSACK_OK);
					}
				}
			}
		}
		parameter_error(2, reply);	/* Unsupported Parameter */
		return(GSACK_ERROR);	/* menu item not found */
	}
	if (stricmp("Key",command)==0) {	/* non-standard, single parameter = ascii 4 hex digit AES keycode, or character */
		if (strlen( parms[1] )==1) {	/* if single chracter passed */
			wx = *parms[1];		/* get the character */
		} else {
	 		if ((wx=validate_standard_key( parms[1] ))==-1) {	/* not standard keyname? */
		 		if ((x=sscanf( parms[1], "%4x", &wx ))==0) {
	 				parameter_error(3, reply);	/* Unsupported parameter format */
	 				return(GSACK_ERROR);	/* error */
				}
			}
		}
		do_keyboard_events( 0, wx );	/* execute keystroke */
		return(GSACK_OK);
	}
	parameter_error(1, reply);
	return(rc);
}

void send_GEMScript_Ack( int *msg )
{
	int id;

	msg[0] = GS_ACK;
	msg[1] = _AESglobal[2];
	if ((id=GEMScript_id())>=0) { appl_write( id, 16, msg ); }
}

/* At application end, Send GS_QUIT to server */
void send_GEMScript_Quit(void)
{
	int msg[8];
	int id;

	memset(&msg,0,16);
	msg[0] = GS_QUIT;
	msg[1] = _AESglobal[2];
	if ((id=GEMScript_id())>=0) {
		msg[7]=id;
		appl_write( id, 16, &msg );
		GEMScript_set_id(-1);	/* end of conversation */
	}
}

/* end of GEMSCRPT.C */
