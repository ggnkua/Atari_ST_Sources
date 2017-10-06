#include "clk_main.h"
#include "clockrsc.h"
#include <geme.h>
#include <gemal.h>

MainForm::MainForm(GEMactivity& in, const GEMrsc& rsc) :
	GEMformwindow(in,rsc,MAIN),
	GEMobject(*this, GRABBER),
	kbd_popup(rsc, POP_KBD)
{
	SetName(" Main ");
}

GEMfeedback MainForm::DoItem(int item, const GEMevent& e)
{
	GEMfeedback result=ContinueInteraction;

	return result;
}

GEMfeedback MainForm::Touch(int x, int y, const GEMevent& e)
{
	switch (kbd_popup.Do(e.X(),e.Y())) {
	case FIRST:
	 	break;
	case SECOND:
		break;
	}
	// redraw item
	return ContinueInteraction;
}
