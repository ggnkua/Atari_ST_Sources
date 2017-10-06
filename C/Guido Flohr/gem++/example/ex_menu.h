#ifndef ex_menu_h
#define ex_menu_h

#include "ex_font.h"
#include "ex_clock.h"
#include "ex_fly.h"
#include "ex_parts.h"
#include "ex_canv.h"
#include "ex_var.h"
#include "ex_img.h"
#include "ex_text.h"
#include "ex_desk.h"
#include <gemal.h>
#include <gemm.h>

//
// Demonstrates GEMmenu as central to the interaction.
//
class Menu : GEMmenu {
public:
	Menu(GEMactivity& in, const GEMrsc& r);
	~Menu();

protected:
	virtual GEMfeedback DoItem(int item, const GEMevent& e);

private:
	class GEMringfiw* windows;
	GEMactivity& act;
	const GEMrsc& rsc;
	FontWindow fonts; // defined before othrs, because it loads fonts.
	Clock clock;
	GEMform about,itisfree,authors,gnu;
	Flying flying;
	PartsForm partsform;
	CanvasWindow canvaswin;
	TextWindow textwin;
	Various various;
	MicroDraw microdraw;
	GEMalert errwin;
	GEMalert clocknote;
	Desktop* desktop;
};

#endif
