#ifndef ex_parts_h
#define ex_parts_h

#include <gemsl.h>
#include <gemfw.h>

class ColourSlider : public GEMslider {
public:
	ColourSlider(GEMform& form, int rack, int minvalue, int maxvalue);

	virtual int HPageAmount();
	void HFlush();
	int Value();
	void Value(int v);
};

class PartsForm : public GEMformwindow {
public:
	PartsForm(GEMactivity& in, const GEMrsc& rsc);

	virtual GEMfeedback DoItem(int item, const GEMevent& e);

private:
	ColourSlider borderslider,textslider,fillslider;

	void SetCurrentPart(int part);
	void SelectPattern(int p);

	int currentpart;

	union {
		short packed;
		struct {
			unsigned short framecol    :  4;
			unsigned short textcol     :  4;
			unsigned short textmode    :  1;
			unsigned short fillpattern :  3;
			unsigned short interiorcol :  4;
		} bits;
	} colour;
};

#endif
