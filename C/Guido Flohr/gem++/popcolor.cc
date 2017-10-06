#include "popcolor.h"


PopupColorChoice::PopupColorChoice(GEMform& form, int RSCindex, PopupList& popup) :
	ArrowablePopupChoice(form,RSCindex,popup)
{
}

void PopupColorChoice::InitObject(GEMrawobject& object)
{
	object.FillPattern(IP_SOLID);
	ArrowablePopupChoice::InitObject(object);
}

void PopupColorChoice::SetObject(int choice, GEMrawobject& object)
{
	object.BackCol(choice);
}

int PopupColorChoice::NumberOfChoices() const
{
	return 16;
}

void PopupColorChoice::SelectObject(int, bool yes, GEMrawobject& object)
{
	object.BorderWidth(yes ? 2 : 0);
	object.Crossed(yes);
}
