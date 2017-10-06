/////////////////////////////////////////////////////////////////////////////
//
//  This file is Copyright 1992,1993 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////

#include <aesbind.h>
#include "gemm.h"
#include "gema.h"
#include "geme.h"
#include "gemo.h"

GEMmenu::GEMmenu(GEMactivity& in, const GEMrsc& rsc, int RSCindex) :
	GEMform(rsc, RSCindex),
	act(in)
{
	act.SetMenu(this);
}

GEMmenu::~GEMmenu()
{
	act.SetMenu(0);
}

void GEMmenu::Show(bool on=true)
{
	menu_bar(Obj,on);
	FlagOpen(on ? +1 : -1);
}

GEMfeedback GEMmenu::Select(const GEMevent& event)
// Processes Message events.
// Uses GEMobject callback to pass on message.
// If no GEMobject declared in form or callback is ignored, use DoItem()
// to pass on message.
{
	GEMfeedback result=IgnoredClick;
	int heading=event.Message(3);
	int item=event.Message(4);

	result=DoItem(item,event);

	// Always ensure no button pressed.  It's amazing how many
	// programs don't do this.  Maybe I shouldn't...
	//
/*
	GEMevent waitevent;
	waitevent.Button(1,0); // Wait for leftbutton release
	waitevent.Get(MU_BUTTON);
*/

	menu_tnormal(Obj,heading,1);

	return result;
}
