#include "popupch.h"
#include <gemrubo.h>


PopupList::PopupList(GEMrsc& rsc,
	int RSCform,
	int RSCchoice1,
	int RSCchoicen,
	int RSCscrollbar) :
		GEMhotform(rsc,RSCform),
		GEMslider(*this,RSCscrollbar+4,RSCscrollbar+3,RSCscrollbar+1,RSCscrollbar+2),
		tell(0),
		choice1(RSCchoice1),
		choicen(RSCchoicen),
		scrollbar(RSCscrollbar)
{
}

int PopupList::DoHot(int ob, bool inside)
{
	tell->SelectObject(ob-choice1+TopLine(),inside,Object(ob));
	RedrawObject(ob);
	return Ignore;
}

int PopupList::Choose(int x, int y, PopupChoice* t)
{
	tell=t;

	for (int i=0; i<=choicen-choice1; i++) {
		GEMrawobject& choice=Object(choice1+i);

		if (i<tell->NumberOfChoices()) {
			choice.HideTree(false);
			tell->InitObject(choice);
			tell->SetObject(i,choice);
		} else {
			choice.HideTree(true);
		}
	}

	// Do we need a scrollbar?
	if (tell->NumberOfChoices() > choicen-choice1+1) {
		Object(scrollbar).HideTree(false);
		SetTopLine(0);
		SetTotalLines(tell->NumberOfChoices());
		SetVisibleLines(choicen-choice1+1);
	} else {
		SetTopLine(0);
		Object(scrollbar).HideTree(true);
	}

	// Shrink outer box.
	GEMrubberobject fullbox(*this,ROOT);
	fullbox.Fit(0);

	int result=Do(x,y)-choice1+TopLine();

	tell=0;

	return result;
}


void PopupList::VFlush()
{
	if (tell) {
		for (int i=0; i<=choicen-choice1 && i<tell->NumberOfChoices(); i++) {
			tell->SetObject(i+TopLine(),Object(choice1+i));
		}
		RedrawObject(Parent(choice1));
	}
}


PopupChoice::PopupChoice(GEMform& form, int RSCindex, PopupList& pop) :
	GEMobject(form,RSCindex),
	popup(pop),
	lastchosen(0)
{
}

GEMfeedback PopupChoice::Touch(int x, int y, const GEMevent&)
{
	GetAbsoluteXY(x,y);
	int choice=popup.Choose(x,y,this);
	if (choice>=0) Choose(choice);
	return ContinueInteraction;
}

void PopupChoice::Choose(int chosen)
{
	if (lastchosen!=chosen) {
		lastchosen=chosen;
		SetObject(chosen,form[myindex]); // Look like choice.
		Redraw();
		ChoiceChanged();
	}
}

void PopupChoice::InitObject(GEMrawobject& object)
{
	// Be my size.
	object.Resize(Width(),Height());
}

void PopupChoice::SelectObject(int, bool yes, GEMrawobject& object)
{
	object.Selected (yes);
}

void PopupChoice::ChoiceChanged()
{
}

class Upper : public GEMobject {
public:
	Upper(GEMform& form, int RSCindex, ArrowablePopupChoice* tll) :
		GEMobject(form,RSCindex),
		tell(tll)
	{
	}

	virtual GEMfeedback Touch(int, int, const GEMevent&)
	{
		tell->UpList();
  		return ContinueInteraction;
	}

private:
	ArrowablePopupChoice* tell;
};

class Downer : public GEMobject {
public:
	Downer(GEMform& form, int RSCindex, ArrowablePopupChoice* tll) :
		GEMobject(form,RSCindex),
		tell(tll)
	{
	}

	virtual GEMfeedback Touch(int, int, const GEMevent&)
	{
		tell->DownList();
  		return ContinueInteraction;
	}

private:
	ArrowablePopupChoice* tell;
};

ArrowablePopupChoice::ArrowablePopupChoice(GEMform& form, int RSCindex, PopupList& popup) :
	PopupChoice(form,RSCindex+2,popup),
	upper(new Upper(form,RSCindex+1,this)),
	downer(new Downer(form,RSCindex+3,this))
{
}

ArrowablePopupChoice::~ArrowablePopupChoice()
{
	delete upper;
	delete downer;
}

void ArrowablePopupChoice::UpList()
{
	int last=Choice();
	if (last>0) Choose(last-1);
}

void ArrowablePopupChoice::DownList()
{
	int last=Choice();
	if (last<NumberOfChoices()-1) Choose(last+1);
}
