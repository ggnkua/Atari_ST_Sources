#include "ex_text.h"
#include "ex_font.h"
#include <example.h>

TextWindow::TextWindow(GEMactivity& in, const GEMrsc& rsc, FontWindow& fontsel) :
	GEMformiconwindow(in,rsc,TEXTEDIT,TEXTEDITI),
	filename(*this,TED_FILENAME),
	ted1(*this,TED1),
	ted2(*this,TED2),
	ted3(*this,TED3),
	help(rsc,TEXTEDITHELP),
	fontselector(fontsel)
{
	filename.st_load_fonts();
	ted1.st_load_fonts();
	ted2.st_load_fonts();
	ted3.st_load_fonts();
}

GEMfeedback TextWindow::DoItem(int item, const GEMevent& e)
{
	switch (item) {
	 case TED_HELP:
		help.Do();
	break; case TED_SAVE:
		;
	break; case TED_LOAD:
		;
	break; case TED_USE_FONT: {
		GEMfont f1(filename,fontselector.Chosen()); f1.Use();
		GEMfont f2(ted1,fontselector.Chosen()); f2.Use();
		GEMfont f3(ted2,fontselector.Chosen()); f3.Use();
		GEMfont f4(ted3,fontselector.Chosen()); f4.Use();
		filename.FontChanged();
		ted1.FontChanged();
		ted2.FontChanged();
		ted3.FontChanged();
		filename.Redraw();
		ted1.Redraw();
		ted2.Redraw();
		ted3.Redraw(); }
	}

	return GEMformiconwindow::DoItem(item,e);
}
