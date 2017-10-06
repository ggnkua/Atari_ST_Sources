#ifndef clk_kbd_h
#define clk_kbd_h
#include <config.h>
#include <gemfw.h>

class KbdForm : public GEMformwindow {
public:
	KbdForm(GEMactivity& in, const GEMrsc& rsc);

	virtual GEMfeedback DoItem(int item, const GEMevent& e);
};

#endif
