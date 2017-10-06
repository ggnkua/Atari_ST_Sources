#include "gemkfoc.h"
#include "gemfoc.h"
#include "gemw.h"

GEMkeyfocus::GEMkeyfocus(GEMactivity& act) :
	GEMkeysink(act)
{
}

GEMkeyfocus::~GEMkeyfocus()
{
}


GEMfeedback GEMkeyfocus::Consume(const GEMevent& ev)
{
	GEMwindow* focus=GEMfocus::Focus();
	if (focus) {
		focus->Key(ev);
	} else {
		// XXX could pass to other virtual method,
		// XXX such as shortcut handler (or should that go first?)
	}
	return ContinueInteraction;
}

