/************************************************************************
*                                                                       *
*       the F68KANS BGI-functions                                       *
*                                                                       *
************************************************************************/


#include <ext.h>



#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <graphics.h>
#include "loader.h"

void cdecl _initgraph();
long cdecl _graphresult();
char* cdecl _grapherrormsg();
void cdecl _cleardevice();
void cdecl _closegraph();
void cdecl _putpixel();
unsigned long cdecl _getpixel();
void cdecl _arc();
void cdecl _circle();
void cdecl _drawpoly();
void cdecl _ellipse();
void cdecl _getarccoords();
void cdecl _getaspectratio();
void cdecl _setaspectratio();
void cdecl _getlinesettings();
void cdecl _line();
void cdecl _lineto();
void cdecl _linerel();
void cdecl _moveto();
void cdecl _moverel();
void cdecl _rectangle();
void cdecl _setlinestyle();
void cdecl _setwritemode();
void cdecl _bar();
void cdecl _bar3d();
void cdecl _fillellipse();
void cdecl _fillpoly();

void cdecl _getviewsettings();
void cdecl _setviewport();
void cdecl _clearviewport();
void cdecl _setfillstyle();

void cdecl _gettextsettings();
void cdecl _outtext();
void cdecl _outtextxy();
void cdecl _settextjustify();
void cdecl _settextstyle();
void cdecl _setusercharsize();
long cdecl _textheight();
long cdecl _textwidth();


SI_funcarr SI_PBGI_fa[] = {
	_initgraph, 
	_graphresult,
	_grapherrormsg,
	_cleardevice,
	_closegraph,
	_putpixel, _getpixel,
	_arc,
	_circle,
	_drawpoly,
	_ellipse,
	_getarccoords,
	_getaspectratio,
	_setaspectratio,
	_getlinesettings,	
	_line,
	_lineto,
	_linerel,
	_moveto,
	_moverel,
	_rectangle,
	_setlinestyle,
	_setwritemode,
	_bar,
	_bar3d,
	_fillellipse,
	_fillpoly,	
	
	_getviewsettings, _setviewport, _clearviewport,

/* settings */
	_setfillstyle,

/* text */
	_gettextsettings,
	_outtext,
	_outtextxy,
	_settextjustify,
	_settextstyle,
	_setusercharsize,
	_textheight,
	_textwidth
};





void cdecl _initgraph( long *graphdriver, long *graphmode, 
					char *pathtodriver, long len)
{
char str[256];

	memcpy( str, pathtodriver, (size_t)len );
	str[len] = '\0'; 
	
	initgraph( (int*)graphdriver+1, (int*)graphmode+1, str);
}



long cdecl _graphresult()
{ return (long) graphresult(); }



char* cdecl _grapherrormsg( long errorcode )
{ return grapherrormsg( (int)errorcode ); }



void cdecl _cleardevice()
{ cleardevice(); }



void cdecl _closegraph()
{ closegraph(); }



void cdecl _putpixel( long x, long y, long color )
{ putpixel( (int)x, (int)y, (int)color ); }



unsigned long cdecl _getpixel( long x, long y )
{ return (unsigned long)getpixel( (int)x, (int)y ); }



/* warning: this functions expects int!! */
void cdecl _fillpoly( long num, int *polypoints )
{ fillpoly( (int)num, polypoints ); }



void cdecl _arc( long x, long y, long start, long end, long r )
{ arc( (int)x, (int)y, (int)start, (int)end, (int)r ); }



void cdecl _circle( long x, long y, long r )
{ circle( (int)x, (int)y, (int)r ); }



/* warning: this functions expects int!! */
void cdecl _drawpoly( long num, int *polypoints )
{ drawpoly( (int)num, polypoints ); }



void cdecl _ellipse( long x, long y, long start, long end, 
					long xr, long yr )
{ ellipse( (int)x, (int)y, (int)start, (int)end, (int)xr, (int)yr ); }



/* warning: this functions expects int!! */
void cdecl _getarccoords( int *arccoords )
{ getarccoords( (struct arccoordstype*)arccoords ); }



void cdecl _getaspectratio( long *xasp, long *yasp )
{ getaspectratio( (int*)xasp+1, (int*)yasp+1 ); }



void cdecl _setaspectratio( long xasp, long yasp )
{ setaspectratio( (int)xasp, (int)yasp ); }



/* warning: this functions expects int!! */
void cdecl _getlinesettings( int *lineinfo )
{ getlinesettings( (struct linesettingstype*)lineinfo ); } 



void cdecl _line( long x0, long y0, long x1, long y1 )
{ line( (int)x0, (int)y0, (int)x1, (int)y1 ); }



void cdecl _lineto( long x0, long y0 )
{ lineto( (int)x0, (int)y0 ); }



void cdecl _linerel( long dx, long dy )
{ linerel( (int)dx, (int)dy ); }



void cdecl _moveto( long x0, long y0 )
{ moveto( (int)x0, (int)y0 ); }



void cdecl _moverel( long dx, long dy )
{ moverel( (int)dx, (int)dy ); }



void cdecl _rectangle( long left, long top, long right, long bottom )
{ rectangle( (int)left, (int)top, (int)right, (int)bottom ); }



void cdecl _setlinestyle( long style, unsigned long pattern, 
						long thick )
{ setlinestyle( (int)style, (unsigned int)pattern, (int)thick ); }



void cdecl _setwritemode( long mode )
{ setwritemode( (int)mode ); }



void cdecl _bar( long left, long top, long right, long bottom )
{ bar( (int)left, (int)top, (int)right, (int)bottom ); }



void cdecl _bar3d( long left, long top, long right, long bottom,
					long depth, long topflag )
{ 
	bar3d( (int)left, (int)top, (int)right, (int)bottom,
			(int)depth, (int)topflag ); 
}



void cdecl _fillellipse( long x, long y, long xr, long yr )
{ fillellipse( (int)x, (int)y, (int)xr, (int)yr ); }





void cdecl _getviewsettings( void *vp )
{ getviewsettings( (struct viewporttype*)vp ); }



void cdecl _setviewport( long left, long top, long right,
						long bottom, long clipflag )
{ setviewport( (int) left, (int) top, (int) right,
						(int) bottom, (int) clipflag ); }



void cdecl _clearviewport()
{ clearviewport(); }



/* settings */

void cdecl _setfillstyle( long pattern, long color )
{ setfillstyle( (int)pattern, (int)color ); }




/* text */

void cdecl _gettextsettings( void *texttypeinfo )
{ gettextsettings( (struct textsettingstype*)texttypeinfo ); }



void cdecl _outtext( char *s, long len )
{ 
char str[256];

	memcpy( str, s, (size_t)len );
	str[len] = '\0'; 

	outtext( str ); 
}




void cdecl _outtextxy( long x, long y, char *s, long len )
{ 
char str[256];

	memcpy( str, s, (size_t)len );
	str[len] = '\0'; 

	outtextxy( (int)x, (int)y, str ); 
}



void cdecl _settextjustify( long horiz, long vert )
{ settextjustify( (int)horiz, (int)vert ); }



void cdecl _settextstyle( long font, long dir, long size )
{ settextstyle( (int)font, (int)dir, (int)size ); }



void cdecl _setusercharsize( long multx, long divx, 
							long multy, long divy )
{ setusercharsize( (int)multx, (int)divx, (int)multy, (int)divy); }



long cdecl _textheight( char *s, long len )
{ 
char str[256];

	memcpy( str, s, (size_t)len );
	str[len] = '\0'; 

	return (long)textheight( str ); 
}



long cdecl _textwidth( char *s, long len )
{ 
char str[256];

	memcpy( str, s, (size_t)len );
	str[len] = '\0'; 

	return (long)textwidth( str ); 
}




