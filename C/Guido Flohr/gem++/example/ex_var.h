#ifndef ex_var_h
#define ex_var_h

#include <gemro.h>
#include <gemsl.h>
#include <gemvo.h>
#include <gemfiw.h>
#include <vdi.h>

//
// Demonstrates GEMvdiobject
//
class GEMliney : public GEMvdiobject {
public:
	GEMliney(GEMform& form, int RSCindex, VDI& vdi);

protected:
	virtual int Draw(int x, int y);
};

//
// Demonstrates GEMvdiobject, with special "Selected" state display.
//
class GEMellipse : public GEMvdiobject {
public:
	GEMellipse(GEMform& form, int RSCindex, VDI& vdi);

protected:
	virtual int Draw(int x, int y);
};

//
// Demonstrates that GEMuserobjects (and GEMvdiobjects) retain
// the features of the object that is having its display representation
// redefined.
//
class GEMroundbutton : public GEMvdiobject {
public:
	GEMroundbutton(GEMform& f, int RSCindex, VDI& v);

protected:
	virtual int Draw(int x, int y);

private:
	int texth;
};


//
// Demonstrates various GEMobjects, and the GEMformiconwindow
//
class Various : public GEMformiconwindow {
public:
	Various(GEMactivity& in, const GEMrsc& rsc);

private:
	GEMrasterobject picture;
	GEMslider panner;
	GEMslider vertslider;
	GEMslider horzslider;
	VDI vdi;
	GEMellipse ellipse;
	GEMliney liney;
	GEMroundbutton r1;
	GEMroundbutton r2;
};

#endif
