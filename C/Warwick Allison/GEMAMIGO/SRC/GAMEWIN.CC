#include "amigo.h"
#include "gemui.h"
#include "gamewin.h"
#undef BLACK
#undef WHITE
#include <gemamigo.h>

#include <grect.h>
#include <geme.h>
#include <gemr.h>
#include <minmax.h>

#define FIS_HOLLOW 0
#define FIS_SOLID 1
#define FIS_PATTERN 2


extern short	showTrees,showMoveReason,groupInfo;
extern char	*playReason;

GameWindow::GameWindow(GEMactivity& act, GEMrsc& rsc) :
	GEMformwindow(act,rsc,GAMEWIN,CLOSER|MOVER|NAME|INFO|SIZER),
	VDI(),
	GEMuserobject(*this,GRID),
	screen(*this),
	colour_choice(rsc,COLOUR_MENU),
	handicap_choice(rsc,HANDICAP_MENU),
	viewwin((({Open();/* Open me first! */}),act),rsc,this),
	game_not_in_progress(rsc.String(NO_GAME)),
	game_over(rsc.String(GAMEOVER)),
	i_am_thinking(rsc.String(THINKING)),
	cpu_passed(rsc.String(CPUPASSED)),
	click_on_dead_groups(rsc.String(COUNTUP)),
	about(rsc,ABOUT)
{
	for (int im=0; im<NUMSTONESIZES; im++) {
		char black_stone_file[]="BLACKST?.IMG";
		char white_stone_file[]="WHITEST?.IMG";
		char  stone_mask_file[]="STN_MAS?.IMG";
		//                       01234567

		black_stone_file[7]=im+'0';
		white_stone_file[7]=im+'0';
		stone_mask_file[7]=im+'0';

		black_stone[im]=new IMG(black_stone_file);
		white_stone[im]=new IMG(white_stone_file);
		stone_mask[im]=new IMG(stone_mask_file);

		//black_stone[im]->TranslateTo(FALSE);
		//white_stone[im]->TranslateTo(FALSE);
		//stone_mask[im]->TranslateTo(FALSE);

		//black_stone[im]->ClearCache();
		//white_stone[im]->ClearCache();
		//stone_mask[im]->ClearCache();
	}

	SetName(rsc.String(GAMEWIN_TITLE));
	// Don't need to modify them - keep them in dev form.

	ingame = counting = 0;
	new_handicap = current_handicap = 0;
	humanColor = WHITE;
	new_color = amigoColor = BLACK;
	amigo_last_x = amigo_last_y = human_last_x = human_last_y = -1;

	ShowAndHide();
	ClearBoard();
}

void GameWindow::ShowAndHide()
{
	bool redraw=FALSE;

	if (Object(NEW_GAME).HideTree(ingame||counting)!=(ingame||counting)) redraw=TRUE;
	if (Object(PASS).HideTree(!ingame)!=!ingame) redraw=TRUE;
	if (Object(COUNTING_DONE).HideTree(!counting)!=!counting) redraw=TRUE;
	if (Object(RESIGN).HideTree(!ingame)!=!ingame) redraw=TRUE;

	if (redraw) {
		RedrawObjectFromRoot(VARIABLE_BUTTONS);
		//RedrawObject(CONTROL_PANEL,0,0,Object(CONTROL_PANEL).Width(),Object(VARIABLE_BUTTONS).Height());
	}
}

GEMfeedback GameWindow::DoItem(int item, const GEMevent& e)
{
	switch (item) {
	 case GRID:
		InputStone(e);
	break; case NEW_GAME:
		NewGame();
	break; case PASS:
		Pass();
	break; case COUNTING_DONE:
		Pass(); // (in Xamigo, pass is used for both)
	break; case RESIGN:
		Resign();
	break; case COLOUR:
		ChooseColour();
	break; case HANDICAP:
		ChooseHandicap();
	break; case SHOW_REASON:
		; // It's just a flag
	break; case DO_VIEW:
		viewwin.Open();
	break; case DO_ABOUT:
		about.Do();
	}

	return ContinueInteraction;
}

static bool XThroughRect(int x, GRect& r)
{
	return x>=r.g_x && x<r.g_x+r.g_w;
}

static bool YThroughRect(int y, GRect& r)
{
	return y>=r.g_y && y<r.g_y+r.g_h;
}

static bool InRect(int x, int y, GRect& r)
{
	return XThroughRect(x,r)
	    && YThroughRect(y,r);
}

void GameWindow::Draw(const PARMBLK* p)
{
	// Clip
	GRect drawclip(p->pb_xc,p->pb_yc,p->pb_wc,p->pb_hc);
	GRect objclip(p->pb_x,p->pb_y,GEMuserobject::Width(),GEMuserobject::Height());
	drawclip.Clip(objclip);
	clip(drawclip.g_x,drawclip.g_y,drawclip.g_x+drawclip.g_w-1,drawclip.g_y+drawclip.g_h-1);

	int size=viewwin.StoneSize();

	// Pixel units
	int x=p->pb_x;
	int y=p->pb_y;
	int xspace=(GEMuserobject::Width()-1)/(NUMLINES+1);
	int yspace=(GEMuserobject::Height()-1)/(NUMLINES+1);
	int mx=x+xspace*(NUMLINES+1);
	int my=y+yspace*(NUMLINES+1);
	int spotradius=max(min(xspace,yspace)/5,1);
	int highlightradius=min(xspace/5,min(yspace/5,stone_mask[size]->Width()/2-1));

	// Position units (0..NUMLINES-1)
	GRect posclip;
	posclip.g_x=max(0,(drawclip.g_x-x-xspace)/xspace);
	posclip.g_y=max(0,(drawclip.g_y-y-xspace)/yspace);
	posclip.g_w=min(NUMLINES-posclip.g_x,(drawclip.g_w+xspace*2-1)/xspace);
	posclip.g_h=min(NUMLINES-posclip.g_y,(drawclip.g_h+yspace*2-1)/yspace);

	// Box
	int pat=viewwin.BoardPattern();
	if (pat>0 && pat<7) {
		sf_color(viewwin.BoardColour());
		sf_interior(FIS_PATTERN);
		sf_style(pat);
	} else {
		sf_color(pat ? viewwin.BoardColour() : 0);
		sf_interior(FIS_SOLID);
	}
	sf_perimeter(1);
	bar(x,y,mx,my);

	// Lines
	sl_color(viewwin.LineColour());
	sl_width(1);

	// Horizontal lines
	for (int j=0; j<NUMLINES; j++) {
		if (YThroughRect(j,posclip)) {
			line(x+xspace,y+yspace+j*yspace,mx-xspace,y+yspace+j*yspace);
		}
	}

	// Vertical lines
	for (int i=0; i<NUMLINES; i++) {
		if (XThroughRect(i,posclip)) {
			line(x+xspace+i*xspace,y+yspace,x+xspace+i*xspace,my-yspace);
		}
	}

	// Spots
	const int NUMSPOTS=8;
	const int A=3;
	const int B=NUMLINES/2;
	const int C=NUMLINES-1-3;
	static int spotx[NUMSPOTS]={A,B,C,A,C,A,B,C};
	static int spoty[NUMSPOTS]={A,A,A,B,B,C,C,C};

	sf_interior(FIS_SOLID);
	sf_color(viewwin.LineColour());
	for (int s=0; s<NUMSPOTS; s++) {
		if (InRect(spotx[s],spoty[s],posclip))
			circle(x+xspace+spotx[s]*xspace,y+yspace+spoty[s]*yspace,spotradius);
	}

	// Stones
	for (j=posclip.g_y; j<posclip.g_y+posclip.g_h; j++) {
		for (i=posclip.g_x; i<posclip.g_x+posclip.g_w; i++) {
			IMG* img=0;
			if (grid[i][j]==BLACK) img=black_stone[size];
			else if (grid[i][j]==WHITE) img=white_stone[size];
			if (img) {
				int tox=x+xspace+xspace*i-img->Width()/2;
				int toy=y+yspace+yspace*j-img->Height()/2;

				// Monochrome
				int b_w[2]={1,0}; // BLACK, WHITE [gemfast #undef'd here though]
				int w_b[2]={0,1};
				screen.MonoBlit(MD_TRANS,*stone_mask[size],tox,toy,w_b);
				screen.MonoBlit(MD_TRANS,*img,tox,toy,b_w);

				// Colour
				//screen.Blit(DST&!SRC,*stone_mask[size],tox,toy);
				//screen.Blit(DST|SRC,*img,tox,toy);
			}
		}
	}

	// Highlights
	int col=viewwin.HighlightColour();

	if (col==0 && amigoColor==WHITE || col==1 && amigoColor==BLACK)
		col=1-col;

	sf_color(col);

	if (InRect(amigo_last_x,amigo_last_y,posclip)) {
		circle(
			x+xspace+amigo_last_x*xspace,
			y+yspace+amigo_last_y*yspace,
			highlightradius
		);
	}

	// Clip off
	clip_off();
}

void GameWindow::RedrawPosition(int x, int y)
{
	// From Draw
	int xspace=(GEMuserobject::Width()-1)/(NUMLINES+1);
	int yspace=(GEMuserobject::Height()-1)/(NUMLINES+1);
	// From Draw
	int size=viewwin.StoneSize();
	int tox=xspace+xspace*x-stone_mask[size]->Width()/2;
	int toy=yspace+yspace*y-stone_mask[size]->Height()/2;

	RedrawObject(GRID,tox,toy,stone_mask[size]->Width(),stone_mask[size]->Height());
}


void GameWindow::NewGame()
{
	ingame = 0;
	current_handicap = new_handicap;
	human_passed = amigo_passed = FALSE;

	amigo_last_x = amigo_last_y = human_last_x = human_last_y = -1;
	amigoColor = new_color;
	humanColor = (amigoColor==BLACK?WHITE:BLACK);

	ClearBoard();
	goRestart(current_handicap);

	Message("");

	ingame = 1;

	if ((amigoColor == BLACK && current_handicap == 0) ||
				(amigoColor == WHITE && current_handicap > 0))
		AmigoMove();

	ShowAndHide();
}

void GameWindow::Pass()
{
	if (!ingame && !counting)
	{
		Message(game_not_in_progress);
		return;
	}

	if (!ingame)
	{
		if (counting)
		{
			CountUp();
			counting=0;
			ShowAndHide();
		}
		Message("");
		return;
	}

	human_passed = TRUE;
	CheckBothPassed();
	if (ingame)
		AmigoMove();
}

void GameWindow::Resign()
{
	counting = 0;
	ingame = 0;
	Message(game_over);
	ShowAndHide();
}

void GameWindow::ChooseColour()
{
	colour_choice[CHOOSE_BLACK].Checked(new_color==WHITE);// ie. human is black
	colour_choice[CHOOSE_WHITE].Checked(new_color==BLACK);// ie. human is white

	GEMobject colour(*this,COLOUR);

	int x,y;
	colour.GetAbsoluteXY(x,y);

	int item=colour_choice.Do(x,y);

	switch (item) {
	 case CHOOSE_BLACK:
		new_color=WHITE; // ie. human is white
	break; case CHOOSE_WHITE:
		new_color=BLACK; // ie. human is black
	break; default:
		return;
	}

	colour.SetText(colour_choice[item].Text()+2);// 2 = skip checkmark and space
}

void GameWindow::ChooseHandicap()
{
	for (int i=NO_HANDICAP; i<=MAX_HANDICAP; i++) {
		handicap_choice[i].Checked(new_handicap==i-NO_HANDICAP);
	}

	GEMobject handicap(*this,HANDICAP);

	int x,y;
	handicap.GetAbsoluteXY(x,y);

	int item=handicap_choice.Do(x,y);

	if (item<NO_HANDICAP) return;

	new_handicap = item-NO_HANDICAP;

	handicap.Text()[0]='0'+new_handicap;
}

/*----------------------------------------------------------------
-- AmigoMove()
--	Generate a move for the computer player.  Update
--	message window, mark stone placed.  If we passed, check
--	to see if game is over.
----------------------------------------------------------------*/
void GameWindow::AmigoMove()
{
	short	x,y;

	Message(i_am_thinking);
	if (genMove(amigoColor,&x,&y))
	{
		GoPlaceStone(amigoColor,x,y);
		int ox=amigo_last_x;
		int oy=amigo_last_y;
		amigo_last_x = x;
		amigo_last_y = y;
		RedrawPosition(ox, oy);
		RedrawPosition(amigo_last_x, amigo_last_y);
		if (Object(SHOW_REASON).Selected()) Message(playReason);
		else Message("");
		amigo_passed = FALSE;
	}
	else
	{
		Message(cpu_passed);
		amigo_passed = TRUE;
		CheckBothPassed();
	}
}

/*----------------------------------------------------------------
-- CheckBothPassed()						--
--	Check to see whether the last two moves were both PASS.	--
--	If so, go into `remove dead stone' mode.		--
----------------------------------------------------------------*/
void GameWindow::CheckBothPassed()
{
	if (human_passed && amigo_passed)
	{
		Message(click_on_dead_groups);
		ingame = 0;
		counting = 1;
		ShowAndHide();
	}
}


void GameWindow::InputStone(const GEMevent& event)
{
	int ax,ay;
	GetAbsoluteXY(ax,ay);
	int	x = event.X() - ax;
	int	y = event.Y() - ay;

	if (!PixelToPosition(x, y)) return;

	if (!ingame && counting)
	{
		DeleteGroupFromStone(x,y);
		return;
	}

	if (!ingame && !counting)
		return;

	if (!GoPlaceStone(humanColor,x,y))
		return;

	human_last_x = x;
	human_last_y = y;

	human_passed = FALSE;

	AmigoMove();
}

void GameWindow::ClearBoard()
{
	for (int j=0; j<NUMLINES; j++)
		for (int i=0; i<NUMLINES; i++) {
			grid[i][j]=EMPTY;
		}
	RedrawObject(GRID);
}

bool GameWindow::PixelToPosition(int& x, int& y)
{
	// Input:  (x,y) click in grid ((0,0) is top-left, in pixels
	// Output: (x,y) grid position
	int xspace=(GEMuserobject::Width()-1)/(NUMLINES+1);
	int yspace=(GEMuserobject::Height()-1)/(NUMLINES+1);
	x=(x-xspace/2)/xspace;
	y=(y-yspace/2)/yspace;
	GRect range(0,0,NUMLINES,NUMLINES);
	return InRect(x,y,range);
}

void GameWindow::PlaceStone(bVal c, int x, int y)
{
	grid[x][y]=c;
	RedrawPosition(x,y);
}

void GameWindow::RemoveStone(int x, int y)
{
	grid[x][y]=EMPTY;
	RedrawPosition(x,y);
}

void GameWindow::PrisonerReport(int black, int white)
{
	sprintf(Object(BLACK_PRISONERS).Text(),"%3d",black);
	sprintf(Object(WHITE_PRISONERS).Text(),"%3d",white);
	RedrawObject(BLACK_PRISONERS);
	RedrawObject(WHITE_PRISONERS);
}

void GameWindow::Message(const char* text)
{
	SetInfoText(text);
}

void GameWindow::ViewChanged()
{
	RedrawObject(GRID);
}

void GameWindow::SetWorkRect(const GRect& r)
{
	GRect before=WorkRect();

	GEMformwindow::SetWorkRect(r);

	if (before.g_w!=r.g_w || before.g_h!=r.g_h) {
		Object(0).Resize(r.g_w,r.g_h);

		// Top-right
		Object(CONTROL_PANEL).
			MoveTo(
				r.g_w-Object(CONTROL_PANEL).Width(),
				0
			);

		// Left side, up to about/panel
		Object(GRID).
			Resize(
				Object(CONTROL_PANEL).X(),
				r.g_h
			);

		RedrawOverlapsViaMessage(WorkRect());
	}
}
