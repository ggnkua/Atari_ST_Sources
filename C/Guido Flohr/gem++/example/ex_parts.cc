#include "ex_parts.h"
#include <example.h>

// A ColourSlider is a simple slider (no arrowers) that shows the current
// value in the knob as text and colour.
//
// TODO: Auto-detect orientation.  Currently ONLY HORIZONTAL.
//
ColourSlider::ColourSlider(GEMform& form, int rack, int minvalue, int maxvalue) :
	GEMslider(form,rack+1,rack)
{
	SetTotalColumns(maxvalue-minvalue+1);
	SetVisibleColumns(2);
	SetLeftColumn(0);
}

int ColourSlider::HPageAmount()
{
	return 1;
}

void ColourSlider::HFlush()
{
	int v=Value();
	char* text=form[FirstChild()].Text();
	if (v<10) {
		text[0]=v+'0';
		text[1]=0;
	} else {
		text[0]=v/10+'0';
		text[1]=v%10+'0';
		text[2]=0;
	}

	form[FirstChild()].BackCol(Value());
	if (Value()==0) {
		form[FirstChild()].ForeCol(1);
	} else {
		form[FirstChild()].ForeCol(0);
	}
	GEMslider::HFlush();
}

int ColourSlider::Value()
{
	return LeftColumn();
}

void ColourSlider::Value(int v)
{
	SetLeftColumn(v);
	HFlush();
}

PartsForm::PartsForm(GEMactivity& in, const GEMrsc& rsc) :
	GEMformwindow(in,rsc,BIGFORM,/*BIGFORMI,*/
		/* ALL */ NAME|CLOSER|FULLER|MOVER|SIZER|INFO|UPARROW|DNARROW|VSLIDE|LFARROW|RTARROW|HSLIDE|SMALLER),
	borderslider(*this,BORDERRACK,0,15),
	textslider(*this,TEXTRACK,0,15),
	fillslider(*this,FILLRACK,0,15)
{
	Resize(200,200);
	GEMform enabled(rsc,WCACTIVE);
	GEMform disabled(rsc,WCINACTIVE);
	SetPartColours(enabled,disabled);
	SetName(" Big Form ");

	int p;
	for (p=PART0; p<=PARTN && !Object(p).Selected(); p++)
		;

	if (p>PARTN) {
		p=PART0;
		Object(p).Select();
	}

	SetCurrentPart(p-PART0);
}

GEMfeedback PartsForm::DoItem(int item, const GEMevent& e)
{
	GEMfeedback result=ContinueInteraction;

	if (item==MODEBUTTON) {
		Object(MODEBUTTON).Transparent(bool(!Object(MODEBUTTON).Transparent()));
		colour.bits.textmode=Object(MODEBUTTON).Transparent();
		RedrawObject(MODEBUTTON);
	} else if (item>=PART0 && item<=PARTN) {
		SetCurrentPart(item-PART0);
	} else if (item>=FILL0 && item<=FILLN) {
		SelectPattern(item-FILL0);
	} else if (item==INACTIVE) {
		RedrawObject(Parent(INACTIVE));
		result=RedrawMyParent;
		SetCurrentPart(currentpart);
	} else if (item==ACTIVE) {
		SetCurrentPart(currentpart);
	} else {
		// The sliders are real objects.
		result=GEMformwindow::DoItem(item,e);

		switch (item) {
		 case BORDERKNOB: case BORDERRACK:
			colour.bits.framecol=borderslider.Value();
		break; case TEXTKNOB: case TEXTRACK:
			colour.bits.textcol=textslider.Value();
		break; case FILLKNOB: case FILLRACK:
			colour.bits.interiorcol=fillslider.Value();
		}
	}

	if (Object(ACTIVE).Selected()) {
		SetPartColour(currentpart,colour.packed,-1);
	} else {
		SetPartColour(currentpart,-1,colour.packed);
	}

	return result;
}

void PartsForm::SetCurrentPart(int part)
{
	currentpart=part;

	if (Object(ACTIVE).Selected()) {
		colour.packed=PartColour(part,true);
	} else {
		colour.packed=PartColour(part,false);
	}

	borderslider.Value(colour.bits.framecol);
	textslider.Value(colour.bits.textcol);

	Object(MODEBUTTON).Transparent(bool(colour.bits.textmode));

	SelectPattern(colour.bits.fillpattern);

	fillslider.Value(colour.bits.interiorcol);
}

void PartsForm::SelectPattern(int p)
{
	if (p<0) p=0;
	else if (p+FILL0>FILLN) p=FILLN-FILL0;

	colour.bits.fillpattern=p;

	for (int i=FILL0; i<=FILLN; i++) {
		if (*(Object(i).Text())=='\010') {
			Object(i).SetText(" ");
			RedrawObject(i);
			break;
		}
	}

	Object(FILL0+p).SetText("\010");
	RedrawObject(FILL0+p);
}
