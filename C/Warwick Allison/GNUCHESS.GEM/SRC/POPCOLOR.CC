#include "popcolor.h"


PopupColourChoice::PopupColourChoice(GEMform& form, int RSCindex, PopupList& popup) :
	ArrowablePopupChoice(form,RSCindex,popup)
{
}

void PopupColourChoice::InitObject(GEMrawobject& object)
{
	object.FillPattern(IP_SOLID);
	ArrowablePopupChoice::InitObject(object);
}

void PopupColourChoice::SetObject(int choice, GEMrawobject& object)
{
	object.BackCol(choice);
}

int PopupColourChoice::NumberOfChoices() const
{
	return 16;
}

void PopupColourChoice::SelectObject(int choice, bool yes, GEMrawobject& object)
{
	object.BorderWidth(yes ? 2 : 0);
	object.Crossed(yes);
}
