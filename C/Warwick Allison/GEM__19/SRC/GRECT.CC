/////////////////////////////////////////////////////////////////////////
//
// File:	GRect.cc
//
// Description:	
//		Implementation der Klasse GRect
//
// $Author$
//		( e-mail:	pareis@cs.tu-berlin.de			)
//		( NeXT-mail:	subiaagb@w271zrz.zrz.tu-berlin.de	)
//
// $Id$
//
/////////////////////////////////////////////////////////////////////////


#include "grect.h"




///////////////////
// Konstruktor
///////////////////

GRect::GRect( int x, int y, int w, int h )
{
	g_x = x;
	g_y = y;
	g_w = w;
	g_h = h;
}







////////////////////////////////////////////////////////////////////////
//
//	Diverse Memberfunktionen
//
////////////////////////////////////////////////////////////////////////



GRect&	GRect::SetRect( int x, int y, int w, int h )
{
	g_x = x;
	g_y = y;
	g_w = w;
	g_h = h;
	
	return *this;
}




GRect& GRect::MoveAbs( int x, int y )
{
	g_x = x;
	g_y = y;
	
	return *this;
}




GRect& GRect::MoveRel( int xOffset, int yOffset )
{
	g_x += xOffset;
	g_y += yOffset;
	
	return *this;
}




GRect& GRect::Resize( int w, int h )
{
	g_w = w;
	g_h = h;
	
	return *this;
}





void GRect::GetRect( int& x, int& y, int& w, int& h ) const
{
	GetOrigin( x,y );
	GetSize( w,h );
}





GRect&	GRect::Clip(const GRect& border)
{
	if (g_x < border.g_x) {
		g_w -= border.g_x-g_x;
		g_x = border.g_x;
	}

	if (g_y < border.g_y) {
		g_h -= border.g_y-g_y;
		g_y = border.g_y;
	}
	
	if (g_x+g_w > border.g_x+border.g_w)
		g_w = border.g_x+border.g_w-g_x;
	
	if (g_y+g_h > border.g_y+border.g_h)
		g_h = border.g_y+border.g_h-g_y;
	
	return *this;
}




GRect&	GRect::Constrain( const GRect& border )
{
	if (g_x < border.g_x)
		g_x = border.g_x;

	if (g_y < border.g_y)
		g_y = border.g_y;

	if (g_w <= border.g_w) {
		if (g_x+g_w > border.g_x+border.g_w)
			g_x = border.g_x+border.g_w-g_w;
	} else {
		g_x = border.g_x - (border.g_w-g_w)/2;
	}
	
	if (g_h <= border.g_h) {
		if (g_y+g_h > border.g_y+border.g_h)
			g_y = border.g_y+border.g_h-g_h;
	} else {
		g_y = border.g_y - (border.g_h-g_h)/2;
	}

	return *this;
}






////////////////////////////////////////////////////////////////////////
//
//	Operatoren
//
////////////////////////////////////////////////////////////////////////



////////////////////////////////////////////////////////////////////////
//
// SPC: operator==( GRect& other )
//	PRE:	TRUE
//	POST:	g_x==other.g_x AND g_y==other.g_y
//		AND g_w==other.g_w AND g_h==other.g_h
//		-- es muss exakte Uebereinstimmung vorliegen
//
////////////////////////////////////////////////////////////////////////

int GRect::operator==( const GRect& other ) const
{
	return !( *this != other );
}



////////////////////////////////////////////////////////////////////////
//
// SPC: operator!=( GRect& other )
//	PRE:	TRUE
//	POST:	NOT POST( operator==(GRect& other) )
//
////////////////////////////////////////////////////////////////////////

int GRect::operator!=( const GRect& other ) const
{
	return 	  g_x^other.g_x | g_y^other.g_y
		| g_w^other.g_w | g_h^other.g_h;
}



GRect&  GRect::Scale(int hscale, int vscale)
{
	g_x*=hscale;
	g_w*=hscale;
	g_y*=vscale;
	g_h*=vscale;

	return *this;
}
