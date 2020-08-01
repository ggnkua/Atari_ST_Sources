/////////////////////////////////////////////////////////////////////////
//
// File:	grect.h
//
// Description:	
//		Die Klasse GRect ist ein GRECT im Sinne der ueblichen
//		AES-Definition, erlaubt jedoch komplexere Operationen
//		wie Vergleiche mit anderen Rectangles, Intersection,
//		Herausfinden von diversen GRect's, die fuer zwei
//		ueberlappende GRect's spezifisch sind (umgebendes GRect,
//		daraus entstehende leere GRect's)
//		( Siehe Dokumentation )
//
// $Author$
//		( e-mail:	pareis@cs.tu-berlin.de			)
//		( NeXT-mail:	subiaagb@w271zrz.zrz.tu-berlin.de	)
//
// $Id$
//
/////////////////////////////////////////////////////////////////////////


#ifndef _GRect_h
#define _GRect_h


#include <aesbind.h>





struct GRect : public GRECT
{

	// Konstruktor:
	GRect() {  }
	GRect( int x, int y, int w, int h );
	
	// Memberfunktionen
	GRect&	MoveAbs( int x, int y );
	GRect&	MoveRel( int xOffset, int yOffset );
	GRect&	Resize( int w, int h );
	GRect&	SetRect( int x, int y, int w, int h );
	
	void	GetOrigin( int& x, int& y ) const;
	void	GetSize( int& w, int& h ) const;
	void	GetRect( int& x, int& y, int& w, int& h ) const;
	
	GRect&	Clip( const GRect& border );
	GRect&	Bound( const GRect& border );
	GRect&	Constrain( const GRect& border );

	GRect&	Scale(int hscale, int vscale);
	
	// Operatoren
	int	operator==( const GRect& ) const;
	int	operator!=( const GRect& ) const;
	
};






////////////////////////////////////////////////////////////////////////
//
//	Inline Memberfunktionen
//
////////////////////////////////////////////////////////////////////////


inline void GRect::GetOrigin( int& x, int& y ) const
{
	x = g_x;
	y = g_y;
}


inline void GRect::GetSize( int& w, int& h ) const
{
	w = g_w;
	h = g_h;
}



#endif

//EOF//
