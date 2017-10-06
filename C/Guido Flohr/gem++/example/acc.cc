#include <gem++.h>
#include "acc.h"


/* Gcc convention for accessories */

extern int _app;
char _stack_heap[8192];
void *_heapbase = (void *)_stack_heap;
long _stksize = sizeof(_stack_heap);


class MyDeskAccessory : public GEMdeskaccessory {
public:
	MyDeskAccessory(const GEMapplication& appl, GEMactivity& act, GEMrsc& rsc, GEMformwindow& w) :
		GEMdeskaccessory(appl,act,rsc.String(ACCNAME)),
		window(w)
	{ }

	void Open()
	{
		window.Open();
	}

	void Close()
	{
		window.BecomeDeleted();
	}

private:
	GEMwindow& window;
};

class MyMenu : public GEMmenu {
public:
	MyMenu(GEMactivity& act, GEMrsc& rsc, GEMformwindow& w) :
		GEMmenu(act,rsc,MENU),
		window(w)
	{ }

	virtual GEMfeedback DoItem(int item, const GEMevent&)
	{
		switch (item) {
		 case DOOPEN:
			window.Open();
		break; case DOQUIT:
			return EndInteraction;
		}
		return ContinueInteraction;
	}

private:
	GEMwindow& window;
};


main()
{
	GEMapplication appl;
	GEMactivity activity;
	GEMrsc rsc("acc.rsc",8,16);
	GEMformwindow sayhello(activity,rsc,SAYHELLO);

	if (_app) {
		MyMenu menu(activity,rsc,sayhello);
		activity.Do();
	} else {
		MyDeskAccessory da(appl,activity,rsc,sayhello);
		activity.Do();
	}
}
