#ifndef ex_canv_h
#define ex_canv_h

#include "ex_font.h"
#include "gemo.h"
#include "gemsl.h"
#include "gemfn.h"
#include "gemto.h"
#include "gemfiw.h"
#include "gemc.h"

class Shape {
public:
	// Set the device on which all Shapes are drawn.
	static void SetVDI(VDI& v);

	Shape(Shape* n=0) : next(n) { }

	void Append(Shape* sh);

	Shape* Next() { return next; }

	virtual void Draw(int xoff, int yoff)=0;
	virtual void GetExtent(GRect& extent)=0;
	virtual bool Touches(int x,int y)=0;

	// Remove sh from this list, returning resulting list.
	Shape* Remove(Shape* sh);

	// Return the last shape touching (x,y).
	Shape* FindLast(int x,int y);

protected:
	VDI& Device();

private:
	static VDI* vdi;
	Shape* next;
};


class CircleShape : public Shape {
public:
	CircleShape(int xpos, int ypos, int radius, Shape* next=0) :
		Shape(next),
		x(xpos),y(ypos),r(radius)
	{
	}

	virtual void Draw(int xoff, int yoff);
	virtual void GetExtent(GRect& extent);
	virtual bool Touches(int tx,int ty);

private:
	int x,y,r;
};

class RectangleShape : public Shape {
public:
	RectangleShape(int xpos, int ypos, int width, int height, Shape* next=0) :
		Shape(next),
		x(xpos),y(ypos),w(width),h(height)
	{
	}

	virtual void Draw(int xoff, int yoff);
	virtual void GetExtent(GRect& extent);
	virtual bool Touches(int tx,int ty);

private:
	int x,y,w,h;
};

class TextShape : public Shape {
public:
	TextShape(int xpos, int ypos, const char* text, const GEMfont& fnt, Shape* next=0);
	virtual ~TextShape();

	virtual void Draw(int xoff, int yoff);
	virtual void GetExtent(GRect& extent);
	virtual bool Touches(int tx,int ty);

private:
	int x,y;
	char* txt;
	GEMfont font;
};

class Canvas : public GEMcanvas {
public:
	Canvas(GEMform& form, int RSCindex);

	void RedrawVirtualArea(GRect& rect);
	void AppendShape(Shape* sh);
	Shape* FindShape(int x, int y);
	void DeleteShape(Shape* sh);
	void DeleteAll();

	void Circle(int x, int y, int radius);
	void Rectangle(int x, int y, int w, int h);
	void Text(int x, int y, char* text, const GEMfont& fnt);

	virtual int DrawAt(int x, int y, const GRect& clip);
	void DrawAll(int x, int y);
	void DrawOn(VDI& v);

	void WriteMetafile(char* filename);

private:
	Shape* shape_list;
};

// A trivial sliding object.
class GEMslidable : public GEMobject {
public:
	GEMslidable(GEMform& form, int RSCindex) :
		GEMobject(form,RSCindex)
	{
	}

	virtual GEMfeedback Touch(int x, int y, const GEMevent&);
};

class CanvasWindow : public GEMformiconwindow {
public:
	CanvasWindow(GEMactivity& in, const GEMrsc& rsc, FontWindow& fntselector);

	virtual GEMfeedback DoItem(int item, const GEMevent& e);

private:
	Canvas canvas;

	GEMslidable cursor;
	GEMslider speed;
	GEMtextobject parameter;
	GEMform canvashelp;
	GEMformwindow canvasphelp;
	FontWindow& fontselector;
};

#endif
