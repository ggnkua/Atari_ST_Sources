#ifndef popupch_h
#define popupch_h


#include <gemhf.h>
#include <gemsl.h>

// GCC 2.5.3 is having GREAT troubles with private inheritance!
#define NOTpublic public

class PopupList : NOTpublic GEMhotform, NOTpublic GEMslider {
public:
	PopupList(GEMrsc&,
		int RSCform,
		int RSCchoice1,
		int RSCchoicen,
		int RSCscrollbar);

	int Choose(int x, int y, class PopupChoice* tell);
	int DoHot(int ob, bool inside);

private:
	virtual void VFlush();
	PopupChoice* tell; // actually, static would do.
	int choice1,choicen,scrollbar;
};

class PopupChoice : NOTpublic GEMobject {
public:
	PopupChoice(GEMform&, int RSCindex, PopupList& popup);

	int Choice() const { return lastchosen; }
	virtual void ChoiceChanged(); // Default = do nothing (ie. poll Choice())

	virtual void InitObject(GEMrawobject& object); // Sizes to size of this.
	virtual void SelectObject(int choice, bool yes, GEMrawobject& object); // SELECT
	virtual void SetObject(int choice, GEMrawobject& object)=0;
	virtual int NumberOfChoices() const=0;

	void Choose(int);

protected:
	virtual GEMfeedback Touch(int x, int y, const GEMevent& e);

private:
	PopupList& popup;
	int lastchosen;
};


class ArrowablePopupChoice : NOTpublic PopupChoice {
public:
	ArrowablePopupChoice(GEMform&, int RSCindex, PopupList& popup);
	~ArrowablePopupChoice();

	void UpList();
	void DownList();

protected:
	GEMobject* upper;
	GEMobject* downer;
};


#endif
