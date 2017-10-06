#include <stdio.h>
#include <windom.h>
#include <winvdi.h>

/* Creer un faux bord */

WINDOW *FrameBorder( WINDOW *win, int line, int col, int w, int h, int mode) 
{
	WINDOW *frame;
	
	frame = WindCreate( 0, app.x, app.y, app.w, app.h);
	frame -> redraw = NULL;
	mode |= FRAME_NOBORDER;
	FrameAttach( win, frame, line, col, w, h, mode);
	return frame;
}

void test_click( WINDOW *win)
{
	char string[120];
	
	if( evnt.mkstate & K_CTRL) {
		if( win->status & WS_FRAME) {
			WINDOW *frame = WindHandle( win->handle);
			WINDOW *new;
			
			new = FrameRemove( frame, win, 0, 0);
			if( new) {
				WindOpen ( new, 200, 200, 100, 100);
				snd_rdw( frame);
			}
		}
	} else {
		sprintf(string, "[1][frame (%d,%d)][OK]", win->frame.col, win->frame.line);
		form_alert( 1, string);
	}
}

void draw_carre_bleu( WINDOW *win)
{
	int x, y, w, h;
	int xy[4];
	
	WindGet( win, WF_WORKXYWH, &x, &y, &w, &h);
	xy[0]=x;xy[1]=y;
	xy[2]=x+w-1;xy[3]=y+h-1;
	vsf_color( win->graf.handle, BLUE);
	v_bar( win->graf.handle, xy);
}

void draw_carre_noir( WINDOW *win)
{
	int x, y, w, h;
	int xy[4];
	
	WindGet( win, WF_WORKXYWH, &x, &y, &w, &h);
	xy[0]=x;xy[1]=y;
	xy[2]=x+w-1;xy[3]=y+h-1;
	vsf_color( win->graf.handle, BLACK);
	v_bar( win->graf.handle, xy);
}

int main( void) {
	WINDOW *win, *frame;
	
	ApplInit();
	FrameInit();
			
	win = FrameCreate( MOVER|NAME|CLOSER|SMALLER|FULLER);
	FrameSet( win, FRAME_BORDER, 6);
	FrameSet( win, FRAME_COLOR, LWHITE);
	
	frame = WindVdi( WAT_NOINFO-0x20, 500, 400);
	frame->clicked = test_click;
	w_gtext( frame, 10, 50, "blablabla");
	FrameAttach( win, frame, 0, 0, 60, 100, FRAME_WSCALE|FRAME_SELECT);
	
	frame = WindVdi( WAT_NOINFO-0x20, 500, 400);
	frame->clicked = test_click;
	wsf_color( frame, LRED);
	w_circle( frame, 50, 50, 40);
	FrameAttach( win, frame, 0, 1, 40, 100, FRAME_WSCALE|FRAME_SELECT);
	
	FrameBorder( win, 1, 0, 100, 30, FRAME_WSCALE);
	
	frame = WindCreate( 0, app.x, app.y, app.w, app.h);
	frame->redraw = draw_carre_bleu;
	frame->clicked = test_click;
	FrameAttach( win, frame, 2, 0, 100, 100, FRAME_HSCALE);

	frame = WindCreate( SIZER, app.x, app.y, app.w, app.h);
	frame->redraw = draw_carre_noir;
	frame->clicked = test_click;
	FrameAttach( win, frame, 2, 1, 100, 100, FRAME_WSCALE|FRAME_HSCALE|FRAME_SELECT);

	WindOpen( win, 50, 50, 300, 200);
/*	snd_msg( win, WM_SIZED, 50, 50, 300, 200); */
	
	while( wglb.first) {
		EvntWindom( MU_MESAG|MU_BUTTON);
	}
	FrameExit();
	ApplExit(); 
	return 0;
}