#include "clk_kbd.h"
#include "clockrsc.h"

KbdForm::KbdForm(GEMactivity& in, const GEMrsc& rsc) :
	GEMformwindow(in,rsc,KEYBOARD)
{
	SetName(" Keyboard Form ");
}

GEMfeedback KbdForm::DoItem(int item, const GEMevent& e)
{
	GEMfeedback result=ContinueInteraction;

	return result;
}
