#include <stdarg.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <windom.h>
#include <libtedit.h>
#include "wglobal.h"

WINDOW *WeditCreate( int, EDIT *);
void WeditSet( WINDOW *, int, ...);
void wedit_newline	( WINDOW *win);
void wedit_insert_string( WINDOW *win, char *string);

#define WPRTF_TOP			0x1
#define WPRTF_OPEN			0x2
#define WPRTF_UNICONIFY		0x4

typedef struct _wprintf {
	int init, mode;
	int x, y, w, h;
} WPRINTF;


void wprintf_closed( WINDOW *win) {
	WindClose(win);
}

void wprintf_destroy( WINDOW *win) {
	void wedit_kill( WINDOW *win);
	
	if( vq_gdos()) vst_unload_fonts( win->graf.handle, 0);
	free( DataSearch( win, WD_PRNT));
	DataDelete( win, WD_PRNT);
	wedit_kill( win);
}

/*
 * Fenˆtre wprintf 
 */

WINDOW *wprintf_init( int watt, int x, int y, int w, int h, int mode) {
	WINDOW *win;
	EDIT *edit;
	WPRINTF *wdata;
	
	edit = edit_new();
	line_add( edit, line_new( ""), ED_BOT);
	edit -> cur.line = edit->top;

	if( edit == NULL) return NULL;
	win = WeditCreate( watt, edit);
	WeditSet( win, WES_FLAGS, SHOWTAB, FLG_ON);
	WeditSet( win, WES_FLAGS, READONLY, FLG_ON);
	/* WindSet( win, WF_NAME, title); */
	/* La fenetre StdOut doit etre d‚truite … la main */
	EvntAttach( win, WM_CLOSED, wprintf_closed);
	EvntAttach( win, WM_DESTROY, wprintf_destroy);
	wdata = (WPRINTF*)malloc( sizeof(WPRINTF));
	wdata -> init = TRUE;
	wdata -> x = x;
	wdata -> y = y;
	wdata -> w = w;
	wdata -> h = h;
	wdata -> mode = mode;
	DataAttach( win, WD_PRNT, wdata);
	return win;
}

void wprintf( WINDOW *win, const char *format, ...) {
	va_list args;
	char fo_buff[255], *p, *q;
	int x, y, w, h;
	WPRINTF *wdata = DataSearch( win, WD_PRNT);
	
	/* Lecture des arguments */
	va_start( args, format);
	vsprintf( fo_buff, format, args);
	p = fo_buff;
	va_end( args);

	if( wdata->init) {
		wdata->init = FALSE;
		WindOpen( win, wdata->x, wdata->y, wdata->w, wdata->h);
	}
	if( !(wdata->mode & WPRTF_OPEN) && !(win -> status & WS_OPEN)) {
		WindGet( win, WF_PREVXYWH, &x, &y, &w, &h);
		WindOpen( win, x, y, w, h);
	} 
	if( !(wdata->mode & WPRTF_TOP) && (win != wglb.front)) {
		WindSet( win, WF_TOP, 0, 0, 0, 0);
		wglb.front = win;	
	} 
	if( !(wdata->mode & WPRTF_UNICONIFY) && (win -> status & WS_ICONIFY))
		WindSet( win, WF_UNICONIFY, win->icon.x, win->icon.y,
					 win->icon.w, win->icon.h);	

	q = p;
	
	do {
		q = strchr( p, '\n');
		if( q) {
			*q = '\0';
			wedit_insert_string( win, p);
			wedit_newline( win);
		/*	EvntWindom( MU_MESAG); */
			p = q+1;
		} else
			wedit_insert_string( win, p);
	} while( q);

}

