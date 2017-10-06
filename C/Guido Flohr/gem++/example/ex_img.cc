#include "ex_img.h"
#include <example.h>
#include <geme.h>
#include <stdlib.h>
#include <yd.h>

//
// Demonstrates the IMG class.
//
MicroDraw::MicroDraw(GEMactivity& in, const GEMrsc& rsc) :
	GEMformiconwindow(in,rsc,XIMG,XIMGI),
	drawbox(*this,XIMG_DRAWBOX),
	vdi(),
	colour(0),
	col0(*this,XIMG_COL0+0,vdi),
	col1(*this,XIMG_COL0+1,vdi),
	col2(*this,XIMG_COL0+2,vdi),
	col3(*this,XIMG_COL0+3,vdi),
	col4(*this,XIMG_COL0+4,vdi),
	col5(*this,XIMG_COL0+5,vdi)
{
	col0.Colour(drawbox.Color_BitmapToVDI(0));
	col1.Colour(drawbox.Color_BitmapToVDI(1));
	col2.Colour(drawbox.Color_BitmapToVDI(2));
	col3.Colour(drawbox.Color_BitmapToVDI(3));
	col4.Colour(drawbox.Color_BitmapToVDI(4));
	col5.Colour(drawbox.Color_BitmapToVDI(5));

	SetColour(1);
	drawbox.Clear();
	SetName(" XIMG - Draw! ");
}

GEMfeedback MicroDraw::DoItem(int item, const GEMevent& e)
{
	switch (item) {
	 case XIMG_DRAWBOX:
		int x,y;
		drawbox.GetAbsoluteXY(x,y);
		x=e.X()-x;
		y=e.Y()-y;
		if (x>0 && y>0 && x<drawbox.IMG::Width()-1 && y<drawbox.IMG::Height()-1) {
			int depth=drawbox.Depth();
			IMGcursor cursor=drawbox.Cursor(x,y);

			cursor.PutPixel(colour,depth); cursor.Right();
			cursor.PutPixel(colour,depth); cursor.Down();
			cursor.PutPixel(colour,depth); cursor.Left();
			cursor.PutPixel(colour,depth); cursor.Left();
			cursor.PutPixel(colour,depth); cursor.Up();
			cursor.PutPixel(colour,depth); cursor.Up();
			cursor.PutPixel(colour,depth); cursor.Right();
			cursor.PutPixel(colour,depth); cursor.Right();
			cursor.PutPixel(colour,depth);

			GRect changearea(x-1,y-1,3,3);
			drawbox.TranslateArea(changearea);
			RedrawObject(XIMG_DRAWBOX,x-1,y-1,3,3);
		}
	break; case XIMG_LOAD:
		Load();
	break; case XIMG_SAVE:
		Save();
	break; case XIMG_DELETE:
		drawbox.Clear();
		drawbox.Redraw();
	break; default:
		if (item>=XIMG_COL0 && item<=XIMG_COLN) {
			SetColour(item-XIMG_COL0);
		}
	}

	return ContinueInteraction;
}

void MicroDraw::SetColour(int c)
{
	Object(XIMG_COL0+colour).Checked(false);
	colour=c;
	Object(XIMG_COL0+colour).Checked(true);
	RedrawObject(XIMG_COLBOX);
}

void MicroDraw::Load()
{
	if (file.Get("Load XIMG file")) {
		IMG loaded(file.Filename());
		if (!!loaded) {
			drawbox.Copy(loaded);
		}
	}
}

void MicroDraw::Save()
{
	if (file.Get("Save XIMG file")) {
		drawbox.Write(file.Filename());
	}
}
