#ifndef gamewin_h
#define gamewin_h

#include "viewwin.h"
#include "go.h"

#include <gemfw.h>
#include <gemuo.h>
#include <gemhf.h>
#include <vdi.h>
#include <img.h>

class GEMactivity;
class GEMrsc;

class GameWindow : public GEMformwindow, VDI, GEMuserobject {
public:
	GameWindow(GEMactivity& act, GEMrsc& rsc);

	void PlaceStone(bVal color, int x, int y);
	void RemoveStone(int x, int y);
	void PrisonerReport(int black, int white);

	void Message(const char* text);

	void ViewChanged();

protected:
	virtual GEMfeedback DoItem(int item, const GEMevent& e);
	virtual void Draw(const PARMBLK*);

private:
	void NewGame();
	void ClearBoard();
	void Pass();
	void Resign();
	void ChooseColour();
	void ChooseHandicap();
	void AmigoMove();
	void CheckBothPassed();
	void InputStone(const GEMevent&);
	bool PixelToPosition(int& x, int& y);
	void ShowAndHide();
	void RedrawPosition(int x, int y);

	int current_handicap, new_handicap;
	int ingame,counting;
	short humanColor, amigoColor;
	short new_color;
	short human_passed,amigo_passed;
	short amigo_last_x,amigo_last_y;
	short human_last_x,human_last_y;

	virtual void SetWorkRect(const GRect& r);

private:
	enum { NUMLINES=19, NUMSTONESIZES=3 };
	bVal grid[NUMLINES][NUMLINES];
	IMG screen;
	IMG* black_stone[NUMSTONESIZES];
	IMG* white_stone[NUMSTONESIZES];
	IMG* stone_mask[NUMSTONESIZES];
	GEMhotform colour_choice;
	GEMhotform handicap_choice;
	char* game_not_in_progress;
	char* game_over;
	char* i_am_thinking;
	char* cpu_passed;
	char* click_on_dead_groups;

	ViewWindow viewwin;
	GEMform about;
};

#endif
