#ifndef viewwin_h
#define viewwin_h

#include <gemfw.h>
#include <poppattn.h>
#include <popcolor.h>

class GameWindow;
class GEMactivity;
class GEMrsc;

class ViewWindow : public GEMformwindow {
public:
	ViewWindow(GEMactivity& act, GEMrsc& rsc, GameWindow* user);

	int LineColour() const { return line_colour.Choice(); }
	int BoardColour() const { return board_colour.Choice(); }
	int HighlightColour() const { return highlight_colour.Choice(); }
	int BoardPattern() const { return board_pattern.Choice(); }
	int StoneSize() const;

protected:
	virtual GEMfeedback DoItem(int item, const GEMevent& e);

private:
	GameWindow* viewuser;

	PopupList popup;
	PopupColourChoice line_colour;
	PopupColourChoice board_colour;
	PopupColourChoice highlight_colour;
	PopupPatternChoice board_pattern;
};

#endif
