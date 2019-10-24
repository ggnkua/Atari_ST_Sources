#ifndef poppattn_h
#define poppattn_h


#include "popupch.h"


class PopupPatternChoice : public ArrowablePopupChoice {
public:
	PopupPatternChoice(GEMform&, int RSCindex, PopupList& popup);

	virtual void InitObject(GEMrawobject& object);
	virtual void SetObject(int choice, GEMrawobject& object);
	virtual void SelectObject(int choice, bool yes, GEMrawobject& object);
	virtual int NumberOfChoices() const;
};


#endif
