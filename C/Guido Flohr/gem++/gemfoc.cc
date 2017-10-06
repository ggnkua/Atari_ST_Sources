#include <aesbind.h>

#include "aesext.h"
#include "gempa.h"
#include "bool.h"
#include "grect.h"
#include "gemw.h"
#include "gemfoc.h"

void GEMfocus::FocusOn(GEMwindow* win)
{
	if ((GEMwindow*) focus != win) {
		if (focus) focus->InFocus(false);
		focus=win;
		if (focus) focus->InFocus(true);
	}
}

void GEMfocus::FocusOff(GEMwindow* win)
{
	if (focus==win) {
		focus->InFocus(false);
		focus=0;
	}
}

GEMwindow* GEMfocus::Focus()
{
	return focus;
}

GEMwindow* GEMfocus::focus=0;
