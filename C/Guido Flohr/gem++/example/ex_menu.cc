#include "ex_menu.h"
#include "ex_dupl.h"
#include <example.h>

//
// Demonstrates GEMmenu as central to the interaction.
//
Menu::Menu(GEMactivity& in, const GEMrsc& r) :
	GEMmenu(in,r,MENU),
	act(in),
	rsc(r),
	about(rsc,ABOUT),
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
{
}

Menu::~Menu()
{
	GEMringfiw::DeleteAll(windows);
}

GEMfeedback Menu::DoItem(int item, const GEMevent& e)
{
	switch (item) {
	 case DOABOUT:
		about.Do();
	break; case DOFREE:	
		itisfree.Do();
	break; case DOAUTHORS:
		authors.Do();
	break; case DOGNU:
		gnu.Do();
	break; case DOQUIT:
		return EndInteraction;
	break; case SHOW_DESKTOP:
		if (desktop) {
			delete desktop;
			desktop=0;
		} else {
			desktop=new Desktop(act,rsc);
		}
	break; case DOVARIOUS:
		various.Open();
	break; case DOFLYING:
		flying.Do();
	break; case DOBIGFORM:
		partsform.Open();
	break; case DOSHARING:
		if (!GEMringfiw::OpenNew(act,rsc,SHARING,SHARINGI,windows))
			switch (errwin.Alert()) {
			 case 1: return DoItem(item,e);
			break; case 2: about.Do();
			}
	break; case DOFONTS:
		fonts.Open();
	break; case DOCANVAS:
		canvaswin.Open();
	break; case DOCLOCK:
		clocknote.Alert();
		clock.Open();
	break; case DOXIMG:
		microdraw.Open();
	break; case DOTEXTEDIT:
		textwin.Open();
	}

	return ContinueInteraction;
}
