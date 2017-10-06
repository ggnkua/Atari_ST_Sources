/* 
 * Auth : Dominique B‚r‚ziat, 1996 - 2001
 *        This file is a part of WinDom Developer Kit
 * File : EVNT-AV.C
 * Desc : Example of using AV-protocol.
 */

#include <windom.h>
#include <stdio.h>
#include <stdarg.h>
#include <string.h>
#include <av.h>
#include "demo.h"

OBJECT *get_tree( int);

static
char *va_status1[] = {
		"AV_SENDKEY",
		"AV_ASKFILEFONT",
		"AV_ASKCONFONT",
		"AV_ASKOBJECT",
		"AV_OPENWIND",
		"AV_STARTPROG",
		"AV_ACCWINDOPEN, AV_ACCWINDCLOSED",
		"AV_STATUS, AV_GETSTATUS",
		"AV_COPY_DRAGGED",
		"AV_PATH_UPDATE, AV_WHAT_IZIT, AV_DRAG_ON_WINDOW",
		"AV_EXIT",
		"AV_XWIND",
		"AV_FONTCHANGED",
		"AV_STARTED",
		"quoted file name",
		"AV_FILEINFO, VA_FILECHANGED",
	};

static
char *va_status2[] = {
	"AV_COPYFILE, VA_FILECOPIED",
	"AV_DELFILE, VA_FILEDELETED",
	"AV_VIEW, VA_VIEWED",
	"AV_SETWINDPOS"
	};
	
static INT16 *status;

#define WCAR	attrib[6]
#define HCAR	attrib[7]
#define WCELL	attrib[8]
#define HCELL	attrib[9]

static
void av_status_redraw( WINDOW *win) {
	INT16 x, y, w, h;
	char text[80];
	int i;
	INT16 attrib[10];
		
	WindGet( win, WF_WORKXYWH, &x, &y, &w, &h);
	vqt_attributes( win->graf.handle, attrib);
	y += HCELL;
	vswr_mode( win->graf.handle, MD_TRANS);
	
	for( i=0; i<16; i++) {
		if( status[0] & (1<<i) )
			sprintf( text, "%s : yes", va_status1[i]);
		else
			sprintf( text, "%s : no", va_status1[i]);
		v_gtext( win->graf.handle, x, y, text);
		y += HCELL;
	}
	for( i=0; i<4; i++) {
		if( status[1] & (1<<i) )
			sprintf( text, "%s : yes", va_status2[i]);
		else
			sprintf( text, "%s : no", va_status2[i]);
		v_gtext( win->graf.handle, x, y, text);
		y += HCELL;
	}
}


static char title[] = "AV server status";

/*
 * Get Status of AV server
 */

void av_status ( void ) {
	
	status = AvStatus();
	
	if( app.avid >= 0) {
		if( FormAlert( 1, "[1][avserver: %d '%s'|word #0 : 0x%X|word #1 : Ox%X][OK|Details]",
					app.avid, AvServer(), status[0], status[1]) == 2)
		{
			WINDOW *win = WindFind( WDF_NAME, title) ;
			
			if( win == NULL) {
				win = WindCreate( WAT_NOINFO, app.x, app.y, app.w, app.h);
				WindSetStr( win, WF_NAME, title);
				EvntAdd( win, WM_REDRAW, av_status_redraw, EV_BOT);
				WindOpen( win, -1, -1, 400, 300);
			} else 
				WindTop( win);
		}
	} else
		FormAlert( 1, "[1][No AVserver found !][OK]");
}

void av_opendir( void) {
	char file[32];
	
	app.pipe[0] = 0;
	*file = 0;
	if( FselInput( app.pipe, file, "*", "Open directory", NULL, NULL)) {
		ApplWrite( app.avid, AV_OPENWIND, ADR(app.pipe), ADR("*.*"), 0);
	}
}

void av_sendfile( void) {
	char file[32];
	
	app.pipe[0] = 0;
	*file = 0;
	if( FselInput( app.pipe, file, "*", "Send file", NULL, NULL)) {
		strcat( app.pipe, "\\");
		strcat( app.pipe, file);
		ApplWrite( app.avid, AV_STARTPROG, ADR(app.pipe), 0, 0, 0);
	}
}

void av_view( void) {
	char file[32];
	
	app.pipe[0] = 0;
	*file = 0;
	if( FselInput( app.pipe, file, "*", "View file", NULL, NULL)) {
		strcat( app.pipe, "\\");
		strcat( app.pipe, file);
		ApplWrite( app.avid, AV_VIEW, ADR(app.pipe), 0, 0, 0);
		if( AvWaitfor( VA_VIEWED, evnt.buff, 1000) == 1 && evnt.buff[3] == 0) {
			FormAlert( 1, "[1][Error from AVserver][OK]");
		} 
	}
}

void av_sendkey( void) {
	OBJECT *tree = get_tree( CAPTUREKEY);
	MFDB back;
	
	FormBegin( tree, &back);
	EvntWindom( MU_KEYBD);
	FormEnd( tree, &back);

	FormAlert( 1, "[1][state: %s %s %s |"
					  "scancode : %d |"
					  "asciicode : %c][OK]", 
					(evnt.mkstate & K_CTRL)?"Ctrl":"", 
					(evnt.mkstate & K_ALT) ?"Alt":"", 
					(evnt.mkstate & (K_LSHIFT+K_RSHIFT))?"Shift":"", 
					evnt.keybd,
					((char)evnt.keybd)?(char)evnt.keybd: ' ');
	ApplWrite( app.avid, AV_SENDKEY, evnt.mkstate, evnt.keybd, 0, 0, 0);
}

/* EOF */ 
