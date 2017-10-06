/*
 *	Autre test de frame, avec du texte
 */

#include <windom.h>
#include <winedit.h>

#define SET_FLAGS 1

int main( void)
{
	WINDOW *win, *frame;
	EDIT *ptext;
	
	ApplInit();
	FrameInit();
		
	win = FrameCreate( NAME|MOVER|FULLER|SMALLER|CLOSER);
	WindSet( win, WF_NAME, "Test Frame");
	FrameSet( win, FRAME_BORDER, 6, 0);
	FrameSet( win, FRAME_COLOR, LWHITE, 0);
	FrameSet( win, FRAME_NOBG, 1, 0);	

	ptext = init_text();
	load_text( ptext, "txtframe.c");
	frame = WindText( HSLIDE|VSLIDE|DNARROW|INFO, ptext);
	WindSet( frame, WF_INFO, "txtframe.c");
	FrameAttach( win, frame, 0, 0, 20, 50, FRAME_WSCALE|FRAME_HSCALE|FRAME_SELECT);
	
	ptext = init_text();
	load_text( ptext, "txtframe.c");
	frame = WindText( WAT_ALL-SIZER, ptext);
	WindSet( frame, WF_INFO, "txtframe.c");
	FrameAttach( win, frame, 0, 1, 40, 50, FRAME_WSCALE|FRAME_HSCALE|FRAME_SELECT);

	ptext = init_text();
	load_text( ptext, "txtframe.c");
	frame = WindText( WAT_ALL-SIZER, ptext);
	WindSet( frame, WF_INFO, "txtframe.c");
	FrameAttach( win, frame, 0, 2, 40, 50, FRAME_WSCALE|FRAME_HSCALE|FRAME_SELECT);

	ptext = init_text();
	load_text( ptext, "txtframe.c");
	frame = WindText( WAT_ALL, ptext);
	WindSet( frame, WF_INFO, "txtframe.c");
	FrameAttach( win, frame, 1, 0, 100, 50, FRAME_WSCALE|FRAME_HSCALE|FRAME_SELECT);
	WindOpen( win, 100, 100, 300, 300);
	FrameSet( win, FRAME_ACTIV, FrameSearch(win,0,0));
	FrameSet( win, FRAME_TOPPED_ACTIV, TRUE);
	
	do {
		EvntWindom( MU_MESAG|MU_BUTTON|MU_KEYBD);
	} while( evnt.buff[0] != AP_TERM && wglb.first!=NULL);
	while( wglb.first) {
		snd_msg( wglb.first, WM_CLOSED, 0, 0, 0, 0);
		EvntWindom(MU_MESAG);
	}
	
	FrameExit();	
	ApplExit();
	return 0;
}