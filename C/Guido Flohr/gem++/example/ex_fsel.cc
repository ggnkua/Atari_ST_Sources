#include "ex_fsel.h"

//
// Demonstrates GEMfileselector
//
FileChooser::FileChooser(GEMform& f, int RSCibutn, GEMobject& disp, char* prmpt) :
	GEMobject(f,RSCibutn),
	GEMfileselector(disp.Text()),
	display(disp),
	prompt(prmpt)
{
	display.Redraw();
}

GEMfeedback FileChooser::Touch(int x, int y, const GEMevent& e)
{
	if (Get(prompt)) display.Redraw();

	return ContinueInteraction;
}
