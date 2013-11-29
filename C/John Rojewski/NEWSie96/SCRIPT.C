/*
 * GEMScript driver
 *
 * Written by: John Rojewski
 * Date: 12/08/98
 * Date: 12/14/98	Assign response variables, etc.
 *       12/15/98	Support longer application startup (parm.delay)
 *       12/16/98	Support simple variable assignments
 *
 */

/*
 no_alert();
 pause(nnn);
 set_delay_time(nnn);
 waitfor(on) or (off);
 log(on) or (off);	NEW
 exec(scriptfile);	NEW

 var=prog.command(parm1,parm2,...);
 var=any text;

*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <aes.h>
#include <vdi.h>
#include <dos.h>
#include "av_proto.h"

#define int short
#define TRUE 1
#define FALSE 0

int finished=0;		/* end of program */
int error;		/* error in script parsing */
OBJECT *em;		/* error messages in resource */
FILE *log=NULL;		/* log file */

struct parms {
	int alerts;
	int pause;
	long delay;
	int wait;
	int log;
} parm;

typedef struct gsinfo {
	long len;		/* length the structure in bytes */
	int version;		/* version of the Protocol by the transmitter (i.e. 0x0110 = 1.1) */
	int msgs;		/* Bitmap the supported news (GSM_xxx) */
	long ext;		/* used ending, about '.SIC' */
} GS_INFO;

typedef struct var {
	struct var *next;	/* next in list of variables defined */
	char name[32];		/* name of variable */
	char value[256];	/* current value of variable */
} VARS;

typedef struct app {
	struct app *next;	/* next in list of apps with session */
	struct gsinfo *info;	/* gsinfo block of this session */
	char   appname[10];	/* name of application */
	int    id;		/* id of this session */
	int    aes_id;		/* aes id of application */
} APPS;

char current_script[FMSIZE];
char current_line[256];
char current_response[512];
char program_path[FMSIZE];
int  current_line_number;
char *command_line=NULL;
char application[10];
GS_INFO *info=NULL;
VARS *vars=NULL;
APPS *apps=NULL;

int appid;
int reply_rcvd,ack_rcvd;

int screenx,screeny,screenw,screenh;
int charh,charw,cellh,cellw;
int handle,phys_handle;
int work_in[12], work_out[57];

/* prototypes */
int read_script(char *filename);
int initialize(void);
int terminate(void);
void handle_events(void);
void show_alert(int num);


#define MGLOBAL 0x20
#define MagX_COOKIE 0x4D616758L
#define MiNT_COOKIE 0x4D694E54L

#define GSACK_OK 0
#define GSACK_UNKNOWN 1
#define GSACK_ERROR 2

#define GS_REQUEST 0x1350
#define GS_REPLY 0x1351
#define GS_COMMAND 0x1352
#define GS_ACK 0x1353
#define GS_QUIT 0x1354

void release_vars(void)
{
	VARS *n;

	while (vars) {
		n = vars->next;
		free( vars );
		vars = n;
	}
}

void release_apps(void)
{
	APPS *n;

	while (apps) {
		n = apps->next;
		if (apps->info) { free( apps->info ); }
		free( apps );
		apps = n;
	}
}

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

void log_comms(char *sendrcv, char *text)
{
	char tofrom[6]="from";

	if (!log) { return; }
	if (parm.log) {
		if (sendrcv[0]=='S') strcpy( tofrom, "to" );
		fprintf( log, "%.7s GEMScript %.7s %s %s(%d)\n", sendrcv, tofrom, text, application, appid );
		fflush(log);
	}
}

void send_GEMScript_Request( int *msg )
{
	int x;
	long *p;

	if (!info) {		/* if buffer has not been allocated */
		info = allocate_global_memory( sizeof(GS_INFO) );
		if (!info) {
			show_alert(-7);	/* unable to allocate, cannot continue */
			return;
		}
	}
	info->len = sizeof(GS_INFO);
	info->version = 0x0110;
	info->msgs = 1;
	info->ext = 0x2e534753;	/* .SGS */

	for (x=2;x<8;x++) { msg[x]=0; }
	msg[0] = GS_REQUEST;
	msg[1] = _AESglobal[2];
	p=(long *)&msg[3];	/* info block in mbuff[3 & 4] */
	*p=(long)info;
	msg[7]=_AESglobal[2];		/* assign session ID */
	if (appid>=0) {
		appl_write( appid, 16, msg );
		log_comms( "Sending", "Request" );
	}
	reply_rcvd=0;
}

void send_GEMScript_Command( int *msg )
{
	int x;
	long *p;

	for (x=2;x<8;x++) { msg[x]=0; }
	msg[0] = GS_COMMAND;
	msg[1] = _AESglobal[2];
	p=(long *)&msg[3];	/* command line in mbuff[3 & 4] */
	*p=(long)command_line;
	msg[7]=_AESglobal[2];		/* assign session ID */
	if (appid>=0) {
		appl_write( appid, 16, msg );
		log_comms( "Sending", "Command" );
	}
	ack_rcvd=0;
	current_response[0]='\0';
}

void send_GEMScript_Ack( int *msg )
{
	msg[0] = GS_ACK;
	msg[1] = _AESglobal[2];
	msg[3] = 0;
	msg[4] = 0;
	msg[7] = 0;
	if (appid>=0) {
		appl_write( appid, 16, msg );
	 	log_comms( "Sending", "Ack" );
	}
}

#if (0)
void send_VA_Start( char *path )
{
	int mbuff[8];
	int aes_id;
	long *p;
	char *env;

	if ((env = getenv( "AVSERVER" ))==NULL) { return; }
	if ((aes_id=appl_find( env ))==-1) { return; }

	mbuff[0] = VA_START;
	mbuff[1] = _AESglobal[2];
	mbuff[2] = 0;
	p=(long *)&mbuff[3];	/* command line in mbuff[3 & 4] */
	*p=(long)path;
	appl_write( aes_id, 16, mbuff );	/* send message */
}
#endif

void show_alert(int num)
{
	char alert[256],temp[90],scr[30];

	if (error<0) { return; }	/* ignore multiple alerts after error */
	if (parm.alerts) {
		if (num<0) { strcpy(alert,"[1]["); } else { strcpy(alert,"[0]["); }
		switch (num)
		{
		case  0: strcat( alert, "John's Script|Version: 0.2|December, 1998" );	break;
		case -1: strcat( alert, "Unable to open script file!" );	break;
		case -2: strcat( alert, "Unknown command" );		break;
		case -3: strcat( alert, "Invalid Parameter" );		break;
		case -4: strcat( alert, "Unknown/Undefined Application" );	break;
		case -5: strcat( alert, "Invalid format" );		break;
		case -6: strcat( alert, "Unable to open INF file!" );	break;
		case -7: strcat( alert, "Unable to allocate GS_INFO" );	break;
		case -8: strcat( alert, "Application not running" );	break;
		case -9: strcat( alert, "App rejected GEMScript request" );	break;
		case -10: strcat( alert, "App ignored GEMScript request" );	break;
		case -11: strcat( alert, "Command not executed" );	break;
		case -12: strcat( alert, "Application not found in path" );	break;
		case -13: strcat( alert, "Unable to allocate Command" );	break;
		case -14: strcat( alert, "Command exceeds 19 parameters" );	break;
		}
		if (num<0) {
			stcgfn( scr, current_script );
			sprintf( temp, "|in file: %s|on line: %d", scr, current_line_number );
			strcat( alert, temp );
			if (current_response[0]!='\0') {
				sprintf( temp, "|%s %.20s", application, current_response );
				strcat( alert, temp );
			}
			strcat( alert, "][Cancel]" );
		} else {
			strcat( alert, "][OK]" );
		}
		form_alert( 1, alert );
	}
	error=num;	/* error indicated, possibly terminate script */
}

int validate_application(char *app)
{
	FILE *fid;
	char buff[FMSIZE],tail[3]="";
	char appath[FMSIZE],*p;
	char *appl,*path;
	int x,rc=0;
	struct FILEINFO finfo;

	if ((fid=fopen("SCRIPT.INF", "ra"))==NULL) {
		show_alert(-6);	/* Unable to open INF file! */
		return(0);
	}
	if (fid) {
		while(fgets( buff, FMSIZE, fid )!=NULL) {
			if (buff[0]=='#') { continue; }	/* ignore comments */
			appl=strtok( buff, "=" );
			path=strtok( NULL, "; \n" );
			if (strcmp( app, appl )==0) {
				sprintf( application, "%-8.8s", appl );
				strupr( application );
				if ((appid=appl_find( application ))==-1) {
					if (dfind( &finfo, path, 0 )) {	/* if file does not exist in directory */
						show_alert(-12); /* Application not found in path */
						break;
					}
					/* Support for Start of application here */
					strcpy( appath, path );
					if ((p=strrchr( appath, '\\' ))!=NULL) { *p='\0'; }
					chdir( appath );
				/*	appid = shel_write( 1, 1, 100, path, tail ); */
					appid = shel_write( 1, 1, 100, path, NULL );
					chdir( program_path );

					for (x=0;x<10;x++) {
						evnt_timer( (int)parm.delay, 0);	/* wait awhile */
						if (appl_find( application )!=-1) { break; }
					}
					if ((appid=appl_find( application ))==-1) {
						show_alert(-8);	/* Application (still) not running */
						break;
					}
				}
				rc=1; break;
			}
		}
		fclose(fid);
	}
	if (!rc) show_alert(-4);	/* Unknown/Undefined Application */
	return(rc);
}

void handle_GEMScript_Ack( int *msg )
{
	long *p;

	memset( current_response, 0, 512);
	p=(long *)&msg[5];	/* response message in mbuff[5 & 6] */
	p=(long *)*p;
	if (p!=NULL) { strncpy( current_response, (char *)p, 512); }

	if (log&&parm.log) {
		fprintf( log, "Ack code=%d, response=%s\n", msg[7], current_response );
		fflush(log);
	}

	switch (msg[7])
	{
	case GSACK_OK:
		break;
	case GSACK_UNKNOWN:	/* unknown command */
		show_alert(-2);
		break;	
	case GSACK_ERROR:	/* command not executed */
		show_alert(-11);
		break;	
	}
}

void assign_response_variable( char *thevar, char *response )
{
	VARS *new,*v;

	if (thevar==NULL) { return; }	/* no variable assigned for result */
	v = vars;
	while (v) {
		if (strncmp( v->name, thevar, 31 )==0) {	/* found existing variable */
			strncpy( v->value, response, 255 );
			return;
		}
		v = v->next;	/* try next (possible) variable */
	}

	new = malloc( sizeof( VARS ) );	/* not found, allocate new variable */
	if (new!=NULL) {
		memset( new, 0, sizeof(VARS) );
		new->next = vars;
		strncpy( new->name, thevar, 31 );
		strncpy( new->value, response, 255 );
		vars = new;
	}	
}

void parse_GEMScript_parameters( char *parms )
{
	char *parmlist[20];
	int nparms,x;
	long parmlen;
	VARS *v;

	if (!command_line) {		/* if buffer has not been allocated */
		command_line = (char * ) allocate_global_memory( 512 );
		if (!command_line) {	/* unable to allocate, cannot continue */
			show_alert(-13);
			return;
		}
	}
	parmlen = strlen(parms)+1;
	strcpy( command_line, parms );	/* parse parms into command_line list */
	strtok( command_line, "(" );
	while (strtok(NULL, ",);" ));

	if (!vars) { return; }	/* no variables exist, no substitution needed */

	memcpy( parms, command_line, parmlen );	/* copy parsed list back to parms */
	for (x=0;x<20;x++) { parmlist[x]=NULL; }
	if ((nparms=strbpl(parmlist,20,parms))==-1) {
		show_alert(-14);	/* too many parameters! */
		return;
	}

	for (x=1;x<nparms;x++) {
		if (parmlist[x]!=NULL) {
		/*	if (*parms[x]=='\1') { parameter_error(1, reply); return(GSACK_ERROR); }	/* unsupported */
			v = vars;
			while (v) {
				if (strncmp( v->name, parmlist[x], 31 )==0) {	/* found existing variable? */
					parmlist[x] = v->value;	/* use current value instead */
		 			if (log&&parm.log) {
		 				fprintf( log, "Parameter substitution: '%s' to '%s'\n", v->name, v->value );
						fflush(log);
					}
					break;
				}
				v = v->next;	/* try next (possible) variable */
			}
		}
	}

	memset( command_line, 0, 512);	/* clear command_line */

	strcpy( command_line, parmlist[0] );
	for (x=1;x<nparms;x++) {
		if (parmlist[x]!=NULL) {
			strcat( command_line, "," );	/* for concatenation */
			strcat( command_line, parmlist[x] );
		}
	}
	strtok( command_line, "," );	/* break into parameters again */
	while (strtok(NULL, "," ));
}

void parse_variable_assignment(char *buff)
{
	char *p,value[256];

	if ((p=strchr(buff,'='))!=NULL) {	/* is there a variable? */
		*p='\0';			/* terminate with = */
		strcpy( value, ++p );		/* value is first char after = */
		assign_response_variable( buff, value );
	} else {
		show_alert(-5);
	}
}

void parse_GEMScript_commands(char *buff)
{
	char theline[256];
	char *var,*app,*parms,*p;
	int msg[8];

	memset( theline, 0, 256);		/* clear theline */
	strtok( current_line, ");" );	/* remove trailing stuff */
	strcpy( theline, current_line);
	if (strchr(theline,'.')==NULL) {	/* no app, try simple assignment */
		parse_variable_assignment( theline );
		return;
	}

	app   = strtok(theline,".");	/* split at period */
	parms = strtok(NULL,"\0);\n");	/* get parms */
	var   = NULL;					/* no var */

	if ((p=strchr(theline,'='))!=NULL) {	/* is there a variable? */
		*p='\0';			/* terminate with = */
		var = theline;			/* var is up to = */
		app=++p;			/* app is first char after = */
	}
	if (validate_application(app)) {	/* validate and format parameters */
		send_GEMScript_Request( msg );
		handle_multiple_events( msg );	/* wait for GS_REPLY with positive response */

		if (!reply_rcvd) {
			show_alert(-10);	/* App ignored GEMScript request */
			return;
		}
		if (appid>=0) {	/* if GEMScript supported by Application */
	 		if (log&&parm.log) {
	 			fprintf( log, "%s Parms=%s);\n", app, parms );
				fflush(log);
			}
			parse_GEMScript_parameters( parms );	/* tokenize commands and parameters */

			send_GEMScript_Command( msg );
			handle_multiple_events( msg );		/* wait for GS_REPLY with positive response */

			if (ack_rcvd) {	/* if message received, i.e. no timeout */
				handle_GEMScript_Ack( msg );
				assign_response_variable( var, current_response );	/* may be none! */
			}
			if (msg[5]!=0) { send_GEMScript_Ack( msg ); }
		}
		return;
	}
	show_alert(-2);
}

void execute_script( char *filename )
{
	char save_script[FMSIZE];
	int  save_line_number;

	strcpy( save_script, current_script );
	save_line_number = current_line_number;

	read_script( filename );

	current_line_number = save_line_number;
	strcpy( current_script, save_script );
}

int parse_internal_commands(char *buff)
{
	if (strnicmp("no_alerts();",buff,12)==0) { 
		parm.alerts=0;	/* no alert messages */
		return(1);
	}
	if (strnicmp("pause(",buff,6)==0) { 
		parm.pause=atoi(buff+6);	/* set pause parameter */
		evnt_timer( parm.pause, 0 );
		return(1);
	}
	if (strnicmp("set_delay_time(",buff,15)==0) { 
		parm.delay=atol(buff+15);	/* set delay time */
		return(1);
	}
	if (strnicmp("waitfor(",buff,8)==0) { 
		if (strnicmp(buff+8,"off",3)==0) {
			parm.wait=0;	/* do not wait for response */
			return(1);
		}
		if (strnicmp(buff+8,"on",2)==0) {
			parm.wait=1;	/* do wait for response */
			return(1);
		}
		show_alert(-3);	/* Invalid Parameter */
	}
	if (strnicmp("log(",buff,4)==0) { 
		if (strnicmp(buff+4,"off",3)==0) {
			parm.log=0;	/* do not log anything */
			return(1);
		}
		if (strnicmp(buff+4,"on",2)==0) {
			parm.log=1;	/* log data and responses */
			return(1);
		}
		show_alert(-3);	/* Invalid Parameter */
	}
	if (strnicmp("exec(",buff,5)==0) { 
		strtok( buff+5, ",)" );		/* extract first parameter as filename */
		execute_script( buff+5 );	/* execute this as a script file */
		return(1);
	}
	return(0);
}

int read_script(char *filename)
{
	FILE *script;	/* interpreted script file */

	if ((script=fopen(filename, "ra"))==NULL) {
		show_alert(-1);	/* Unable to open script file! */
		return(0);
	}
	strcpy( current_script, filename );
	current_line_number = 0;

	if (script) {
		while(fgets( current_line, FMSIZE, script )!=NULL) {
			current_line_number++;
			if (current_line[0]=='\n') { continue; }	/* ignore empty lines */
			if (current_line[0]=='#') { continue; }	/* ignore comments */
			if (!parse_internal_commands(current_line)) {
				parse_GEMScript_commands(current_line);
			}
			if (error<0) { break; }
		}
		fclose( script );
		return(1);
	}
	return(0);
}

void initialize_gem(void)
{
	int x;
	char rscfile[FMSIZE];
/*	rsc[FMSIZE]; */
	char path[FMSIZE],temp[FMSIZE],*p;

	if (appl_init()<0) exit(EXIT_FAILURE);

	if (shel_read( path, temp )) {		/* identify program path */
		if ((p=strrchr( path, '\\' ))!=NULL) {	/* look for last '\' */
			if (memcmp(p+1,"SCRIPT",6)==0) { *p='\0'; strcpy( program_path, path ); }
		} else { getcd( 0, program_path ); }
	} else {
		getcd( 0, program_path );		/* shel_read failed */
	}

	/* initialize resource file */
	strcpy( rscfile, "SCRIPT.RSC" );
#if (0)
	if (!rsrc_load( rscfile ))	{
		sprintf( rsc, "[1][SCRIPT Resource file error|%s][ Quit ]", rscfile );
		form_alert(1, rsc);
		exit(EXIT_FAILURE);
	}
/*	rsrc_gaddr(R_TREE,Error_Message,&em); */
#endif

	handle = phys_handle = graf_handle( &charw, &charh, &cellw, &cellh ); 
	work_in[10]=2;
	work_in[0]=Getrez() + 2;
	for (x=1; x<10; work_in[x++]=1);
	v_opnvwk( work_in, &handle, work_out );
	if (handle==0) exit(EXIT_FAILURE);

	wind_get(DESK,WF_WORKXYWH,&screenx,&screeny,&screenw,&screenh);
	graf_mouse(ARROW,NULL);

	if (_AESglobal[0]>=0x0400) {	/* MultiTos */
		shel_write( 9, 0x01, 0, NULL, NULL );	/* AP_TERM handled */
	}
/*	if ( MT ) {
		memcpy( &menu[9], VERSION, 4 );
		menu_register( _AESglobal[2], menu );
	} */
}


int initialize(void)
{
	current_script[0]='\0';	/* no script file */
	current_response[0]='\0';	/* no application response */
	parm.alerts=1;		/* default is on */
	parm.pause=1000;	/* default is 1 second */
	parm.delay=1000;	/* default is 10 seconds */
	parm.wait=0;		/* default is off */
	parm.log=0;		/* default is on */
	appid=-1;		/* no connection to an app */
	error=0;		/* no errors in this script */
	release_vars();		/* release all varaibles defined */
	if (!log) { log=fopen( "SCRIPT.LOG", "wa" ); }	/* open log file */
	return(0);
}

int terminate(void)
{
	v_clsvwk( handle );
/*	rsrc_free(); */
	appl_exit();
	if (log) { fclose(log); }
	return(0);
}

void do_GEMScript_events( int *msg )
{
	switch(msg[0])
	{
	/* If GS_REPLY received (only when initiated by this program) */
		case GS_REPLY:
			reply_rcvd=1;
		 	log_comms( "Receive", "Reply" );
			if (msg[6]!=0) {
				show_alert(-9);	/* App rejected GEMScript request */
				appid=-1;
			}
			break;

	/* If GS_ACK received, set flag */
		case GS_ACK:
			ack_rcvd=1;
		 	log_comms( "Receive", "Ack" );
			break;

	/* If GS_QUIT received, clear appid */
		case GS_QUIT:
		 	log_comms( "Receive", "Quit" );
			appid=-2;	/* no more communication with app */
			break;
	}
}

void do_VA_Protocol_events(int *mbuff)
{
	long *p;
/*	char c,s,temp[8],*q; */

	switch(mbuff[0])
	{
	case VA_START:
		p=(long *)&mbuff[3];	/* command line in mbuff[3 & 4] */
		p=(long *)*p;
		if (p==NULL) {	return;	}
		if (*(char *)p=='\0') { return; }	/* ignore empty filename */
		if (parm.log&&log) { fprintf( log, "VA_START received: %s\n", p ); fflush(log); }

		read_script((char *)p);	/* execute script file */
		initialize();		/* initialize for next file */
		break;
	}
}

void do_message_events(int *mbuff)
{

	if ((mbuff[0]>>8)==0x0047) { do_VA_Protocol_events(mbuff); return; }
	if ((mbuff[0]>>8)==0x0013) { do_GEMScript_events(mbuff); return; }
	switch(mbuff[0])
	{
	case WM_REDRAW:		break;
	case MN_SELECTED:	break;
	case WM_CLOSED:		break;
	case WM_TOPPED:		break;
	case WM_MOVED:		break;
	case WM_SIZED:		break;
	case WM_ARROWED:	break;
	case WM_VSLID:		break;
	case WM_FULLED:		break;
	case WM_ICONIFY:	break;
	case WM_UNICONIFY:	break;
	case WM_ALLICONIFY:	break;
	case WM_ONTOP:		break;
	case WM_TOOLBAR:	break;
	case AP_TERM:
		finished=1;
		break;
	case CH_EXIT:		break;
	case AP_DRAGDROP:
	/*	handle_dragdrop( mbuff );	/* handle it */
		break;
	}
}

void handle_multiple_events(int *buff)
{
	long delay;
	int dell,delh;
	int res, mx, my, btn, shft, keycode, clicks;
	int flags=MU_MESAG|MU_TIMER;

	delay = parm.delay*10;
	dell  = delay&0x0000ffffL;
	delh  = (delay>>16)&0x0000ffffL;
	if (parm.wait) { flags=MU_MESAG; }	/* if waitfor(on), no timeout */
	res = evnt_multi( flags, 0x0102, 3, 0,	/* left or right mouse */
				0, 0, 0, 0, 0,
				0, 0, 0, 0, 0,
				buff, dell, delh, 
				&mx, &my, &btn, &shft, &keycode, &clicks );
	if (res & MU_MESAG)  { do_message_events( buff ); }
}

int main(int argc, char *argv[])
{
	short buff[8];

	initialize();
	initialize_gem();
	if (argc>1) {
		read_script( argv[1] );
		initialize();
	} else { show_alert(0); }	/* welcome */
	for (; !finished;) { handle_multiple_events( buff ); } 
	terminate();
	return EXIT_SUCCESS;
}

/* end of script.c */ 