/////////////////////////////////////////////////////////////////////////////
//
//  GEMactivity
//
//  A GEMactivity is an interaction with the user through the GEM interface.
//
//  This file is Copyright 1992,1993 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////

#ifndef GEMa_h
#define GEMa_h

#include <gemfb.h>

class GEMmenu;
class GEMdeskaccessory;
class GEMwindow;
class GEMtimer;
class GEMkeysink;
class GEMevent;

class GEMactivity
{
public:
	GEMactivity();

	virtual ~GEMactivity();

	// Standard main-loop...
	void Do();

	// Components, so you may build your own...
	void BeginDo();
	GEMfeedback OneDo();
	GEMfeedback OneDo(int eventmask);
	void EndDo();

	// These are for call by GEM* classes
	void AddWindow(GEMwindow&);
	void RemoveWindow(GEMwindow&);
	void SetMenu(GEMmenu*);
	void SetTimer(GEMtimer*);
	void SetKeySink(GEMkeysink*);
	void SetDeskAccessory(GEMdeskaccessory*);
	void Topped(const GEMwindow&);
	void Bottomed(const GEMwindow&);

	// Debug.
	void Dump();

private:
	GEMfeedback PerformMessage(const GEMevent&);
	struct WL {
		WL(GEMwindow *Wind, WL *n);
		GEMwindow *Window;
		struct WL *Next;
		struct WL *Prev;
	} *W;
	GEMwindow* Window(int ID) const;
	WL* ListWindow(int ID) const;

	GEMmenu *Menu;
	GEMdeskaccessory *Acc;
	GEMtimer *Timer;
	GEMkeysink *KeySink;
};

#endif
