#include "ex_var.h"
#include <example.h>

#define FIS_PATTERN 2

//
// Demonstrates GEMvdiobject
//
GEMliney::GEMliney(GEMform& form, int RSCindex, VDI& vdi) :
	GEMvdiobject(form,RSCindex,vdi)
{
}

int GEMliney::Draw(int x, int y)
{
	int j=Width() < Height() ? Width() : Height();
	for (int i=0; i<j; i+=3) {
		vdi.line(x,y+j-i,x+i,y);
	}
	return 0; // No decorations
}

//
// Demonstrates GEMvdiobject, with special "Selected" state display.
//
GEMellipse::GEMellipse(GEMform& form, int RSCindex, VDI& vdi) :
	GEMvdiobject(form,RSCindex,vdi)
{
}

int GEMellipse::Draw(int x, int y)
{
	vdi.sf_interior(FIS_PATTERN);
	if (Selected()) vdi.sf_style(20);
	else vdi.sf_style(10);
	vdi.ellipse(x+Width()/2,y+Height()/2,Width()/2,Height()/2);
	return 0; // No decorations
}

//
// Demonstrates that GEMuserobjects (and GEMvdiobjects) retain
// the features of the object that is having its display representation
// redefined.
//
GEMroundbutton::GEMroundbutton(GEMform& f, int RSCindex, VDI& v) :
	GEMvdiobject(f,RSCindex,v)
{
	int j;
	graf_handle(&j,&texth,&j,&j);
}

int GEMroundbutton::Draw(int x, int y)
{
	if (Selected()) vdi.sf_interior(1);
	else vdi.sf_interior(0);
	vdi.rfbox(x,y,x+Width()-1,y+Height()-1);
	vdi.swr_mode(MD_XOR);
	int j;
	vdi.st_alignment(1,3,&j,&j); // Centre-Bottom aligned
	vdi.gtext(x+Width()/2,y+(Height()+texth)/2-1,Text());
	vdi.swr_mode(MD_REPLACE);
	return 0; // No decorations
}


//
// Demonstrates various GEMobjects, and the GEMformiconwindow
//
Various::Various(GEMactivity& in, const GEMrsc& rsc) :
	GEMformiconwindow(in,rsc,VARIOUS,VARIOUSI),
	picture(*this,PIC),
	panner(*this,PANKNOB,PANRACK,PANLEFT,PANRIGHT,PANUP,PANDOWN),
	vertslider(*this,VKNOB,VRACK,UP,DOWN),
	horzslider(*this,HKNOB,HRACK,LEFT,RIGHT),
	vdi(),
	ellipse(*this,ELLIPSE,vdi),
	liney(*this,LINEY,vdi),
	r1(*this,RBUT1,vdi),
	r2(*this,RBUT2,vdi)
{
	picture.Read("example.img");
	SetName(" Various GEM++ objects ");
}
