#ifndef popcolor_h
#define popcolor_h


#include "popupch.h"


class PopupColourChoice : public ArrowablePopupChoice {
public:
	PopupColourChoice(GEMform&, int RSCindex, PopupList& popup);

	virtual void InitObject(GEMrawobject& object);
	virtual void SetObject(int choice, GEMrawobject& object);
	virtual void SelectObject(int choice, bool yes, GEMrawobject& object);
	virtual int NumberOfChoices() const;
};


#endif
