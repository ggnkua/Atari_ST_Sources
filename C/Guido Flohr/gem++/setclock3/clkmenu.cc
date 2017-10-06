#include "clkmenu.h"
#include "clockrsc.h"

//
// Demonstrates GEMmenu as central to the interaction.
//
Menu::Menu(GEMactivity& in, const GEMrsc& r) :
	GEMmenu(in,r,MENU),
	act(in),
	rsc(r),
	about(rsc,ABOUT),
	mainf(in, rsc),
	kbdf(in, rsc)
/*
	itisfree(rsc,FREE),
	authors(rsc,AUTHORS),
	gnu(rsc,GNU),
	flying(rsc),
	errwin(rsc,ERRWIN),
	clocknote(rsc,CLOCKNOTE),
	various(in,rsc),
	fonts(in,rsc),
	clock(in,rsc),
	microdraw(in,rsc),
	windows(0),
	partsform(in,rsc),
	canvaswin(in,rsc,fonts),
	textwin(in,rsc,fonts),
	desktop(0)
*/
{
}

Menu::~Menu()
{
//	GEMringfiw::DeleteAll(windows);
}

GEMfeedback Menu::DoItem(int item, const GEMevent& e)
{
	switch(item) {
	case MENU_ABOUT:
		about.Do();
		break;
	case MENU_LOAD:
		fsel.Get("C:\\");
		break;
	case MENU_SAVE:
	case MENU_SAVEAS:
		break;
	case MENU_QUIT:	return EndInteraction;
	case MENU_VECT:
	case MENU_MAIN:
		mainf.Open();
		break;
	case MENU_KBD:
		kbdf.Open();
		break;
	case MENU_TIME:
	case MENU_SCRSAV:
	case MENU_PRINT:
		break;
	case MENU_HELP:
		break;
	}

	return ContinueInteraction;
}
