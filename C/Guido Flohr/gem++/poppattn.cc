#include "poppattn.h"


PopupPatternChoice::PopupPatternChoice(GEMform& form, int RSCindex, PopupList& popup) :
	ArrowablePopupChoice(form,RSCindex,popup)
{
}

void PopupPatternChoice::InitObject(GEMrawobject& object)
{
	object.BackCol(BLACK);
	ArrowablePopupChoice::InitObject(object);
}

void PopupPatternChoice::SetObject(int choice, GEMrawobject& object)
{
	object.FillPattern(choice);
}

int PopupPatternChoice::NumberOfChoices() const
{
	return 8;
}

void PopupPatternChoice::SelectObject(int, bool yes, GEMrawobject& object)
{
	object.BorderWidth(yes ? 2 : 0);
	object.Crossed(yes);
}
