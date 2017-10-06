#ifndef clk_main_h
#define clk_main_h

#include <gemfw.h>
#include <gemt.h>
#include <gemo.h>
#include <gemal.h>
#include <gemhf.h>
#include <gemto.h>

class MainForm : public GEMformwindow, GEMobject {
public:
	MainForm(GEMactivity& in, const GEMrsc& rsc);

	virtual GEMfeedback DoItem(int item, const GEMevent& e);

protected:
	virtual GEMfeedback Touch(int x, int y, const GEMevent& e);

private:
	GEMhotform kbd_popup;
};

#endif
