#ifndef gemui_h
#define gemui_h

#include "ui.h"

class GEM_UI : public UI {
public:
	GEM_UI();
	virtual ~GEM_UI();

	virtual void Go();

	int operator!() { return !rsc; }

	virtual void PlaceStone(bVal color,int x,int y);
	virtual void RemoveStone(int x,int y);
	virtual void PrisonerReport(int black,int white);
	virtual void ShowResult(int wt, int bp, int bt, int wp);

private:
	class GEMapplication* app;
	class GEMrsc* rsc;
	class GEMactivity* act;
	class GameWindow* win;
};

#endif
