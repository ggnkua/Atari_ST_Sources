#include <windom.h>
#include <winedit.h>
#include <string.h>
#include <stdlib.h>
#include <dragdrop.h>
#include <stdio.h>

char path[128], name[64], info1[250], info2[250];
int anim = 0;

void IconDraw( WINDOW *win)
{
	int x,y,w,h;
	WINDOW *frame;
	char *p;
	
	WindClear( win);
	WindGet( win, WF_WORKXYWH, &x, &y, &w, &h);
	switch( anim) {
	case 1:
		frame = FrameSearch( win, 0, 0);
		vst_color(  win->graf.handle, RED);
		p = strrchr( frame->info, '\\');
		v_gtext( win->graf.handle, x+1, y+h/2, p?(p+1):"No file");
		break;
	case 2:
		frame = FrameSearch( win, 1, 0);
		vst_color(  win->graf.handle, BLUE);
		p = strrchr( frame->info, '\\');
		v_gtext( win->graf.handle, x+1, y+h/2, p?(p+1):"No file");
		break;
	default:
		vst_color(  win->graf.handle, BLACK);
		v_gtext( win->graf.handle, x+1, y+h/2, "Frames!");
		break;
	}
}

void TimerIcon( WINDOW *win)
{
	if( win->status & WS_ICONIFY) {
		anim = anim ++ % 3	;
		snd_rdw( win);
	}
}

void OpenText( WINDOW *win)
{
	EDIT *ptext = win->data;
	
	if( (evnt.mbut & 0x02) && FselInput( path, name, "*.*", "Select an ascii file ...")) {
		strcpy( win->info, path);
		strcat( win->info, name);
		reinit_text( ptext);
		load_text( ptext, win->info);
		win->xpos=win->ypos=0;
		win->ypos_max=(int)ptext->maxline;
		WindSet( win, WF_INFO, win->info);
		WindSlider( win, HSLIDER|VSLIDER);
		snd_rdw( win);
	}
}

void ExtraMsg( WINDOW *win) {
	
	if( evnt.buff[0] == AP_DRAGDROP && !(win->status & WS_ICONIFY))
	{
		char file[128], name[ 128], *buff;
		int dd_hdl, dd_msg; /* pipe-handle */
		LONG size;
		char ext[32];

		/* on accepte le drag&drop */
		dd_hdl = ddopen( evnt.buff[7], DD_OK);
		if( dd_hdl<0)	return;	/* erreur, pipe non ouvert */
				
		/*	On envoit notre liste de prefs:
		 *	Notre liste de prefs se borne au type ARGS
		 *	qui a une signification sp‚ciale: on attends
		 *	une liste de nom de fichiers dans le pipe
		 */
		strnset( ext, '\0', 32);
		strcpy( ext, "ARGS");
		dd_msg = ddsexts( dd_hdl, ext);
		if( dd_msg<0)	return;	/* erreur lecture du pipe */
		
		/* Lectures des infos re‡us */	
		dd_msg = ddrtry( dd_hdl, name, file, ext, &size);
		if( !strncmp( ext, "ARGS", 4))
		{
			/* on accepte les donn‚es */
			ddreply(dd_hdl, DD_OK);
			/* On lit les "size" octets des donn‚es dans le pipe */
			buff = (char*)malloc(sizeof(char)*size);
			if( Fread( dd_hdl, size, buff) == size) {
				WINDOW *frame;
				EDIT *ptext;
				
				/* Dans quelle frame ? */
				frame = FrameFind( win, evnt.mx, evnt.my);
				if( frame) {
					ptext = frame->data;
					reinit_text( ptext);
					load_text( ptext, buff);
					frame->xpos=frame->ypos=0;
					frame->ypos_max=(int)ptext->maxline;
					strcpy( frame->info, buff);
					WindSet( frame, WF_INFO, frame->info);
					WindSlider( frame, HSLIDER|VSLIDER);
					snd_rdw( frame);
				}
			}
			else
			/* erreur lecture pipe */
				;
			free( buff);
		ddclose( dd_hdl);	/* fin du protocole */
		}	
		else
			ddreply(dd_hdl, DD_NAK); 
					
		ddclose( dd_hdl);	/* fin du protocole */			 
	}
}

int main( int argc, char *argv[]){
	WINDOW *win, *frame;
	EDIT *ptext;
	
	ApplInit();
	FrameInit();
		
	win = FrameCreate( NAME|MOVER|FULLER|SMALLER|CLOSER);
	WindSet( win, WF_NAME, "Frames are usefull no?");
	FrameSet( win, FRAME_BORDER, 6, 0);
	FrameSet( win, FRAME_COLOR, LWHITE, 0);
	FrameSet( win, FRAME_NOBG, 1, 0);
	win -> extramsg = ExtraMsg;
	win -> icon.draw = IconDraw;
	win -> timed = TimerIcon;
	
	ptext = init_text();
	if( argc >= 2)	{load_text( ptext, argv[1]);strcpy(info1, argv[1]);}
	frame = WindText( WAT_ALL-SIZER, ptext);
	frame->clicked = OpenText;
	WindSet( frame, WF_INFO, "No file.");
	frame->info = info1;
	FrameAttach( win, frame, 0, 0, 100, 50, FRAME_WSCALE|FRAME_HSCALE|FRAME_SELECT);
	
	ptext = init_text();
	if( argc >= 3)	{load_text( ptext, argv[2]);strcpy(info2, argv[2]);}
	frame = WindText( WAT_ALL, ptext);
	frame->clicked = OpenText;
	WindSet( frame, WF_INFO, "No file.");
	frame->info = info2;
	FrameAttach( win, frame, 1, 0, 100, 50, FRAME_WSCALE|FRAME_HSCALE|FRAME_SELECT);

	WindOpen( win, 100, 100, 300, 300);
	FrameSet( win, FRAME_ACTIV, FrameSearch(win,0,0));

	evnt.lo_timer = 1000;
	evnt.hi_timer = 0;
	
	do {
		EvntWindom( MU_MESAG|MU_BUTTON|MU_KEYBD|MU_TIMER);
	} while( evnt.buff[0] != AP_TERM && wglb.first!=NULL);
	while( wglb.first) {
		snd_msg( wglb.first, WM_CLOSED, 0, 0, 0, 0);
		EvntWindom(MU_MESAG);
	}
	FrameExit();	
	ApplExit();
	return 0;
}