#ifndef ex_text_h
#define ex_text_h

#include <gemst.h>
#include <gemfiw.h>

class FontWindow;

//
// Demonstrates GEMscrolltext objects
//
class TextWindow : public GEMformiconwindow {
public:
	TextWindow(GEMactivity& in, const GEMrsc& rsc, FontWindow& fontselector);

protected:
	virtual GEMfeedback DoItem(int item, const GEMevent& e);

private:
	GEMscrolltext filename;
	GEMscrolltext ted1;
	GEMscrolltext ted2;
	GEMscrolltext ted3;
	GEMform help;
	FontWindow& fontselector;
};

#endif
