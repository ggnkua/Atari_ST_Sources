#ifndef ui_h
#define ui_h

#include "go.h"

class UI {
public:
	virtual void Go()=0;

	virtual int operator!()=0;

	virtual void PlaceStone(bVal color,int x,int y)=0;
	virtual void RemoveStone(int x,int y)=0;
	virtual void PrisonerReport(int black,int white)=0;
	virtual void ShowResult(int wt, int bp, int bt, int wp)=0;
};

extern UI* ui;

#endif
