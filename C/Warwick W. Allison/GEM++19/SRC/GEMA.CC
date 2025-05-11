/////////////////////////////////////////////////////////////////////////////
//
//  This file is Copyright 1992,1993 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////


#include <vt52.h>

#include <aesbind.h>
#include "gema.h"
#include "gemw.h"
#include "gemm.h"
#include "gemt.h"
#include "gemda.h"
#include "geme.h"
#include "gemks.h"
#include "grect.h"
#include "contract.h"
#include "scancode.h"

#ifndef WM_BOTTOMED
#define WM_BOTTOMED 33
#endif

GEMactivity::WL::WL(GEMwindow *Wind, GEMactivity::WL *n) :
	Window(Wind),
	Next(n),
	Prev(n ? n->Prev : 0)
{
	if (n) n->Prev=this;
}

GEMactivity::GEMactivity() :
	W(0), Menu(0), Acc(0), Timer(0), KeySink(0)
{ }

GEMactivity::~GEMactivity()
{ }

// XXX This is a bit of a problem.
// XXX Maybe the desktop shouldn't be a window.
//
static bool IsDesktop(GEMwindow* w)
{
	return w->IsOpen() && w->Handle()==0;
}

void GEMactivity::AddWindow(GEMwindow& w)
{
	W=new struct WL(&w,W);
}

void GEMactivity::RemoveWindow(GEMwindow& w)
{
	for (WL* c=W; c && c->Window!=&w;  c=c->Next)
		;

	if (c) {
		// Cut it out
		if (c->Prev) c->Prev->Next=c->Next;
		if (c->Next) c->Next->Prev=c->Prev;
		if (c==W) W=c->Next;

		delete c;
	}
}

void GEMactivity::SetMenu(GEMmenu* m)
{
	Menu=m;
}

void GEMactivity::SetTimer(GEMtimer* t)
{
	Timer=t;
}

void GEMactivity::SetKeySink(GEMkeysink* k)
{
	KeySink=k;
}

void GEMactivity::SetDeskAccessory(GEMdeskaccessory* a)
{
	Acc=a;
}

void GEMactivity::Do()
{
	GEMfeedback res=ContinueInteraction;

	BeginDo();

	while (res != EndInteraction) {
		res=OneDo();
	}

	EndDo();
}

void GEMactivity::BeginDo()
{
	if (Menu) Menu->Show();

	graf_mouse(ARROW,0);
}

GEMfeedback GEMactivity::OneDo()
{
	return OneDo(0xffff); // Allow any events
}

GEMfeedback GEMactivity::OneDo(int eventmask)
{
	GEMfeedback res=ContinueInteraction;

	GEMevent event;

	int get=MU_BUTTON|MU_MESAG;

	if (Timer && Timer->NextInterval()>=0) {
		get|=MU_TIMER;
		event.Interval(Timer->NextInterval());
	}

	if (KeySink) get|=MU_KEYBD;

	event.Get(get&eventmask);

	if (event.Keyboard()) {
		res=KeySink->Consume(event);
	}

	if (event.Timer()) {
		res=Timer->ExpireNext(event);
	}

	if (event.Button()) {
		GEMwindow *win=0;
		for (WL* c=W; c && !win; c=c->Next) {
			int X,Y,W,H;
			if (c->Window->IsOpen()) {
				wind_get(c->Window->Handle(),WF_WORKXYWH,&X,&Y,&W,&H);
				if (event.X()>=X && event.X()<X+W && event.Y()>=Y && event.Y()<Y+H)
					win=c->Window;
			}
		}
		if (win) res=win->Click(event);
	}

	if (event.Message()) {
		res = PerformMessage(event);
	}

	return res;
}

void GEMactivity::EndDo()
{
	if (Menu) Menu->Hide();
}

GEMwindow* GEMactivity::Window(int ID) const
{
	for (WL* c=W; c && c->Window->Handle()!=ID;  c=c->Next)
		;
	return c ? c->Window : 0;
}

GEMactivity::WL* GEMactivity::ListWindow(int ID) const
{
	for (WL* c=W; c && c->Window->Handle()!=ID;  c=c->Next)
		;
	return c;
}

void GEMactivity::Bottomed(const GEMwindow& w)
{
	// Find the window.
	for (WL* c=W; c && c->Window!=&w;  c=c->Next)
		;

	if (c) {
		// Find the end (&& Can't bottom below desktop root window)
		WL* end=c;
		while (end->Next && !IsDesktop(end->Next->Window)) {
			end=end->Next;
		}

		// If found and not already last.
		if (c!=end) {
			// Cut c out
			if (c->Prev) c->Prev->Next=c->Next;
			if (c->Next) c->Next->Prev=c->Prev;
			if (c==W) W=c->Next;

			// Put c at end
			c->Next=end->Next;
			if (c->Next) c->Next->Prev=c;
			end->Next=c;
			c->Prev=end;
		}
	}
}

void GEMactivity::Topped(const GEMwindow& w)
{
	// Find the window.
	for (WL* c=W; c && c->Window!=&w;  c=c->Next)
		;

	// If found and not already first.
	if (c && c!=W) {
		// Cut it out.
		if (c->Prev) c->Prev->Next=c->Next;
		if (c->Next) c->Next->Prev=c->Prev;

		// Put at head.
		c->Next=W;
		c->Prev=0;
		W->Prev=c;
		W=c;
	}
}






GEMfeedback GEMactivity::PerformMessage(const GEMevent& event)
{
	GEMfeedback	r = ContinueInteraction;

	if (event.Message(0)==MN_SELECTED && Menu) {
		return Menu->Select(event);
	} else if (event.Message(0)==AC_OPEN) {
		if (Acc) Acc->Open(event);
		return ContinueInteraction;
	} else if (event.Message(0)==AC_CLOSE) {
		if (Acc) Acc->Close(event);
		return ContinueInteraction;
	}

	GEMwindow* To=Window(event.Message(3));

	if (To) {
		switch (event.Message(0)) {
		 case WM_NEWTOP:		// it's a test
			form_alert(1,"[1][ NewTop Message received! ][  OK  ]");

		break; case WM_REDRAW:
			To->RedrawOverlaps(GRect(event.Message(4),event.Message(5),event.Message(6),event.Message(7)));

		break; case WM_CLOSED:	r=To->UserClosed();
		break; case WM_MOVED:	To->UserMoved(event.Message(4),event.Message(5));
		break; case WM_TOPPED:	To->Top(event);
		break; case WM_BOTTOMED:	To->Bottom(event);
		break; case WM_FULLED:	To->UserFulled();
		break; case WM_SIZED:	To->UserResized(event.Message(6),event.Message(7));
		break; case WM_VSLID:	To->VSlidered(event.Message(4));
		break; case WM_HSLID:	To->HSlidered(event.Message(4));

		break; case WM_ARROWED:
			switch (event.Message(4)) {
			 case WA_UPLINE:
				To->LineUp();
			break; case WA_DNLINE:
				To->LineDown();
			break; case WA_UPPAGE:
				To->PageUp();
			break; case WA_DNPAGE:
				To->PageDown();
			break; case WA_LFLINE:
				To->ColumnLeft();
			break; case WA_RTLINE:
				To->ColumnRight();
			break; case WA_LFPAGE:
				To->PageLeft();
			break; case WA_RTPAGE:
				To->PageRight();
			}
		}
	}
	
	if (r == RedrawMe) {
		To->RedrawOverlaps(To->WorkRect());
		r = ContinueInteraction;
	}

	return r;
}

void GEMactivity::Dump()
{
	printf("\n");
	WL* w=W;

	if (w->Prev!=0) {
		printf("window list head error!\n");
	}

	while (w) {
		GEMwindow* gw=w->Window;
		printf("window %x %s %d %s\n",gw,gw->Name(),gw->Handle(),gw->IsOpen() ? "open" : "closed");
		if (w->Next && w->Next->Prev!=w) {
			printf("window list error!\n");
		}
		w=w->Next;
	}
}
