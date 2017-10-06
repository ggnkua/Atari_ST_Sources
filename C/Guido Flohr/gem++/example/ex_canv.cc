#include "ex_canv.h"
#include <example.h>

#include <gemcha.h>
#include <geme.h>
#include <string.h>
#include <stdlib.h>

#define FIS_HOLLOW 0

void Shape::SetVDI(VDI& v)
{
	vdi=&v;
}

void Shape::Append(Shape* sh)
{
	Shape* cursor=this;
	while (cursor->next) {
		cursor=cursor->next;
	}
	cursor->next=sh;
}

Shape* Shape::Remove(Shape* sh)
// Remove sh from this list, returning resulting list.
{
	if (sh==this) {
		Shape* result=next;
		next=0;

		return result;
	} else {
		if (next)
			next=next->Remove(sh);
		return this;
	}
}

Shape* Shape::FindLast(int x,int y)
// Return the last shape touching (x,y).
{
	Shape* last=0;
	Shape* cursor=this;

	while (cursor) {
		if (cursor->Touches(x,y))
			last=cursor;
		cursor=cursor->next;
	}

	return last;
}

VDI& Shape::Device()
{
	return *vdi;
}

VDI* Shape::vdi=0;

void CircleShape::Draw(int xoff, int yoff)
{
	Device().circle(x+xoff,y+yoff,r);
}

void CircleShape::GetExtent(GRect& extent)
{
	extent.g_x=x-r;
	extent.g_y=y-r;
	extent.g_w=r*2+1;
	extent.g_h=r*2+1;
}

bool CircleShape::Touches(int tx,int ty)
{
	if (tx<x-r || tx>x+r || ty<y-r || ty>y+r) return false;

	int dx=abs(tx-x);
	int dy=abs(ty-y);

	// Distance formula:  sqrt(dx**2 + dy**2) < r
	return dx*dx+dy*dy <= r*r;
}

void RectangleShape::Draw(int xoff, int yoff)
{
	Device().bar(x+xoff,y+yoff,x+xoff+w-1,y+yoff+h-1);
}

void RectangleShape::GetExtent(GRect& extent)
{
	extent.g_x=x;
	extent.g_y=y;
	extent.g_w=w;
	extent.g_h=h;
}

bool RectangleShape::Touches(int tx,int ty)
{
	return tx>=x && tx<x+w && ty>=y && ty<y+h;
}

TextShape::TextShape(int xpos, int ypos, const char* text, const GEMfont& fnt, Shape* next=0) :
	Shape(next),
	x(xpos),y(ypos),txt(strdup(text)),
	font(Device(),fnt)
{
}

TextShape::~TextShape()
{
	delete txt;
}

void TextShape::Draw(int xoff, int yoff)
{
	font.Use();
	Device().gtext(x+xoff,y+yoff,txt);
}

void TextShape::GetExtent(GRect& extent)
{
	// NB:  qt_extent() does not take alignment into account.
	//      (ie. we are assuming alignement is Top-Left)
	int txt_extent[8];
	font.Use();
	Device().qt_extent(txt,txt_extent);

	extent.g_x=x+txt_extent[0];
	extent.g_y=y+txt_extent[1];
	extent.g_w=txt_extent[2]-txt_extent[0]+1;
	extent.g_h=txt_extent[5]-txt_extent[3]+1;
}

bool TextShape::Touches(int tx,int ty)
{
	GRect r;
	GetExtent(r);

	return tx>=r.g_x && tx<r.g_x+r.g_w && ty>=r.g_y && ty<r.g_y+r.g_h;
}

Canvas::Canvas(GEMform& form, int RSCindex) :
	GEMcanvas(form,RSCindex),
	shape_list(0)
{
	st_alignment(0,5);
	sf_interior(FIS_HOLLOW);
}

void Canvas::RedrawVirtualArea(GRect& rect)
{
	form.RedrawObject(myindex,rect.g_x-CanvasX(),rect.g_y-CanvasY(),rect.g_w,rect.g_h);
}

void Canvas::AppendShape(Shape* sh)
{
	if (shape_list)
		shape_list->Append(sh);
	else
		shape_list=sh;

	GRect extent;
	sh->GetExtent(extent);
	RedrawVirtualArea(extent);
}

Shape* Canvas::FindShape(int x, int y)
{
	if (shape_list)
		return shape_list->FindLast(x,y);
	else
		return 0;
}

void Canvas::DeleteShape(Shape* sh)
{
	if (shape_list) {
		GRect extent;
		sh->GetExtent(extent);

		shape_list=shape_list->Remove(sh);

		RedrawVirtualArea(extent);

		delete sh;
	}
}

void Canvas::DeleteAll()
{
	while (shape_list) {
		Shape* sh=shape_list;
		shape_list=shape_list->Next();
		delete sh;
	}
	Redraw();
}

void Canvas::Circle(int x, int y, int radius)
{
	AppendShape(new CircleShape(x,y,radius));
}

void Canvas::Rectangle(int x, int y, int w, int h)
{
	AppendShape(new RectangleShape(x,y,w,h));
}

void Canvas::Text(int x, int y, char* text, const GEMfont& fnt)
{
	GEMfont to_use(*this,fnt);
	AppendShape(new TextShape(x,y,text,to_use));
}

int Canvas::DrawAt(int x, int y, const GRect& clip)
{
	// Clear background.
	r_recfl(x+clip.g_x,y+clip.g_y,x+clip.g_x+clip.g_w-1,y+clip.g_y+clip.g_h-1);

	// Just rely on VDI clipping to decide what to draw.
	// More appropriately, we could store our shapes in a fashion that
	// allowed us to instantly decide which subgroup to actually draw.
	DrawAll(x,y);

	return 0; // No AES decorations
}

void Canvas::DrawAll(int x, int y)
{
	for (Shape* sh=shape_list; sh; sh=sh->Next()) {
		sh->Draw(x,y);
	}
}

void Canvas::DrawOn(VDI& v)
{
	Shape::SetVDI(v);
	DrawAll(0,0);
	Shape::SetVDI(*this);
}

void Canvas::WriteMetafile(char* filename)
{
	VDI metafile(filename);

	GEMchangearea bb; // Bounding Box

	for (Shape* sh=shape_list; sh; sh=sh->Next()) {
		GRect extent;
		sh->GetExtent(extent);
		bb.Include(extent);
	}

	metafile.m_pagesize(bb.g_w*PixelWidth()/100,bb.g_h*PixelHeight()/100);
	metafile.meta_extents(bb.g_x,bb.g_y,bb.g_x+bb.g_w-1,bb.g_y+bb.g_h-1);

	DrawOn(metafile);
}

static void Untouch(int timeout)
{
	GEMevent event;
	if (event.Button()) {
		event.Interval(timeout); // Wait for timeout
		event.Button(1,0); // or leftbutton release
		event.Get(MU_TIMER|MU_BUTTON);
	}
}

GEMfeedback GEMslidable::Touch(int x, int y, const GEMevent&)
{
	GEMobject parent(form,form.Parent(myindex));

	int tx,ty;
	parent.GetAbsoluteXY(tx,ty);

	int ox,oy,nx,ny;
	ox=tx+X();
	oy=ty+Y();

	graf_dragbox(Width(),Height(),ox,oy,
		tx,ty,parent.Width(),parent.Height(),&nx,&ny);

	// Redraw parent with this hidden
	HideTree(true);

	int cx,cy;
	GetAbsoluteXY(cx,cy);

	form.RedrawObject(form.Parent(myindex), cx-tx, cy-ty,
		Width(), Height());

	MoveTo(nx-tx,ny-ty);

	HideTree(false);

	Redraw();

	return ContinueInteraction;
}

CanvasWindow::CanvasWindow(GEMactivity& in, const GEMrsc& rsc, FontWindow& fntselector) :
	GEMformiconwindow(in,rsc,CANVAS,CANVASI),
	canvas(*this,CNVBOX),
	speed(*this,CNVKNOB,CNVRACK),
	parameter(*this,CNVPARM),
	cursor(*this,CNVCURSOR),
	canvashelp(rsc,CANVASHELP),
	canvasphelp(in,rsc,CANVASPHELP),
	fontselector(fntselector)
{
	canvas.st_load_fonts();

	SetName(" Canvas ");
	canvasphelp.SetName(" Canvas - parameters ");

	Shape::SetVDI(canvas);
}

GEMfeedback CanvasWindow::DoItem(int item, const GEMevent& e)
{
	int cursor_x=canvas.CanvasX()+Object(CNVCURSOR).X()+7;
	int cursor_y=canvas.CanvasY()+Object(CNVCURSOR).Y()+7;

	switch (item) {
	 case CNVUP: case CNVDOWN: case CNVLEFT: case CNVRIGHT: {
		// Redraw CNVBOX with CNVCURSOR hidden
		Object(CNVCURSOR).HideTree(true);

		// XXX This should be provided by GEMform
		int cx,cy,bx,by;
		objc_offset(Obj,CNVCURSOR,&cx,&cy);
		objc_offset(Obj,CNVBOX,&bx,&by);
		RedrawObject(CNVBOX,cx-bx,cy-by,
			Object(CNVCURSOR).Width(),
			Object(CNVCURSOR).Height());

		int delay=speed.TotalColumns()-speed.LeftColumn()-speed.VisibleColumns();
		int scroll_amount=1;

		// Delay 0..7 is implemented using scroll amount 16..2, no delay.
		// Delay 8.. is implemented using scroll amount of 1 and time delay.
		//
		// Why?  Because it looks nice.
		//
		if (delay < 8) {
			scroll_amount=(8-delay)*2;
			delay=0;
		} else {
			delay-=7;
		}

		switch (item) {
		 case CNVUP:
			canvas.VScroll(-scroll_amount);
		break; case CNVDOWN:
			canvas.VScroll(+scroll_amount);
		break; case CNVLEFT:
			canvas.HScroll(-scroll_amount);
		break; case CNVRIGHT:
			canvas.HScroll(+scroll_amount);
		}

		if (delay) {
			Untouch(delay*5);
		}

		// Replace cursor
		Object(CNVCURSOR).HideTree(false);
		RedrawObject(CNVCURSOR);
	}; break;
	case CNVCIRCLE: {
		int radius=atoi(parameter);
		if (radius < 1) radius=1;
		canvas.Circle(cursor_x,cursor_y,radius);
	}; break;
	case CNVSQUARE: {
		int hside=atoi(parameter);
		if (hside < 1) hside=1;
		char* parm;
		for (parm=parameter; *parm && *parm!=',' && *parm!='x' && *parm!='*'; parm++)
			;
		int vside=*parm ? atoi(parm+1) : hside;
		if (vside < 1) vside=hside;
		canvas.Rectangle(cursor_x,cursor_y,hside,vside);
	}; break;
	case CNVTEXT: {
		canvas.Text(cursor_x,cursor_y,parameter,fontselector.Chosen());
	}; break;
	case CNVDELETE1: {
		Shape* sh=canvas.FindShape(cursor_x,cursor_y);
		if (sh) {
			canvas.DeleteShape(sh);
		}
	}; break;
	case CNVERASE: {
		if (parameter[0]=='y') canvas.DeleteAll();
	}; break;
	case CNVHELP: {
		// Popup canvas help on top of canvas window.
		// (it's an overlayed help box).
		canvashelp.Do(Object(0).X(),Object(0).Y());
	}; break;
	case CNVPHELP: {
		// Open canvas parameter help window.
		canvasphelp.Open();
	}; break;
	case CNVWRITE:
		canvas.WriteMetafile(parameter);
	break; default:
		GEMformiconwindow::DoItem(item,e);
	}

	return ContinueInteraction;
}
