#ifndef ex_clock_h
#define ex_clock_h

#include <gemfw.h>
#include <gemt.h>
#include <gemo.h>
#include <gemal.h>
#include <gemhf.h>
#include <gemto.h>

class MenuItemToggle : public GEMobject {
public:
	MenuItemToggle(GEMform& form, int RSCindex) :
		GEMobject(form,RSCindex)
	{
	}

	virtual GEMfeedback Touch(int x, int y, const GEMevent& e);
};

class Clock : public GEMformwindow, GEMtimer, GEMobject {
public:
	Clock(GEMactivity& act, const GEMrsc& rsc);

private:
	void Update();

protected:
	virtual GEMfeedback Expire(const GEMevent&);
	virtual GEMfeedback Touch(int x, int y, const GEMevent& e);

private:
	GEMtextobject timetext,datetext;
	GEMhotform popup;
	MenuItemToggle gmt;
	GEMalert gmjoke;
};

#endif
