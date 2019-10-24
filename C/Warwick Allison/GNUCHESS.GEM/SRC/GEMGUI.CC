//////////////////////////////////////////////////////////////////////////////
//
//  This file is part of the Atari GEM interface for GNU Chess,
//  and is Copyright 1993 by Warwick W. Allison.
//
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  of the CHESS General Public License described in the main chess file
//  gnuchess.cc.
//
//////////////////////////////////////////////////////////////////////////////


char* gui_version="0.9"; // 3 characters unless RSC updated.
extern char *version, *patchlevel;

#include <string.h>

#include "gnuchess.h"
#undef TRUE
#undef FALSE
#undef bool
#include "uisupport.h"
#include "ui.h"
#include "gem_rsc.h"

#define RV(x) (WhiteFromTop ? (7-(x)) : (x))

#include <gemap.h>
#include <gema.h>
#include <geme.h>
#include <gemr.h>
#include <gemfs.h>
#include <gemrubo.h>
#include <gemm.h>
#include <gemfiw.h>
#include <gemal.h>
#include <vdi.h>
#include "popcolor.h"
#include "poppattn.h"

static bool WhiteFromTop=FALSE;
static int CurrentColour=white;
static bool ComputerIsBlack=TRUE;
static int CheckMate=0;
static char* const CONFIGFILE="data\\gnuchess.cnf";


class ChessBoard;

class ColourWindow : public GEMformwindow {
public:
	ColourWindow(GEMactivity& act, const GEMrsc& rsc, ChessBoard& brd) :
		GEMformwindow(act,rsc,COLOUR),
		board(brd),
		popup(rsc,CHOICELIST,CHOICE1,CHOICEN,CHOICESCROLLBAR),
		whitepiecedatacolour(*this,WHITEDATACOLOUR,popup),
		blackpiecedatacolour(*this,BLACKDATACOLOUR,popup),
		whitepiecemaskcolour(*this,WHITEMASKCOLOUR,popup),
		blackpiecemaskcolour(*this,BLACKMASKCOLOUR,popup),
		whitesquarecolour(*this,WHITESQUARECOLOUR,popup),
		blacksquarecolour(*this,BLACKSQUARECOLOUR,popup),
		blacksquarepattern(*this,BLACKSQUAREPATTERN,popup),
		whitesquarepattern(*this,WHITESQUAREPATTERN,popup),
		cursorcolour(*this,CURSORCOLOUR,popup),
		highlightcolour(*this,HIGHLIGHTCOLOUR,popup),
		boardbordercolour(*this,BOARDBORDERCOLOUR,popup),
		surroundcolour(*this,SURROUNDCOLOUR,popup),
		surroundpattern(*this,BOARDSURROUNDPATTERN,popup)
	{
		SetName(rsc.String(COLOURWINTITLE));
	}

	int SquarePatternFor(bool isblack) const
	{
		return Object(isblack ? BLACKSQUARE : WHITESQUARE).FillPattern();
	}

	int SquareForeColFor(bool isblack) const
	{
		return Object(isblack ? BLACKSQUARE : WHITESQUARE).ForeCol();
	}

	int SquareBackColFor(bool isblack) const
	{
		return Object(isblack ? BLACKSQUARE : WHITESQUARE).BackCol();
	}

	int PieceForeColFor(bool isblack) const
	{
		return Object(isblack ? BLACKPIECE : WHITEPIECE).ForeCol();
	}

	int PieceBackColFor(bool isblack) const
	{
		return Object(isblack ? BLACKPIECE : WHITEPIECE).BackCol();
	}

	int CursorColour() const
	{
		return Object(CURSORBORDER).BorderCol();
	}

	int CursorBorder() const
	{
		return Object(CURSORBORDER).BorderWidth();
	}

	int HighlightColour() const
	{
		return Object(HIGHLIGHTBORDER).BorderCol();
	}

	int HighlightBorder() const
	{
		return Object(HIGHLIGHTBORDER).BorderWidth();
	}

	int BoardBorderColour() const
	{
		return Object(BOARDBORDERBORDER).BorderCol();
	}

	int SurroundColour() const
	{
		return Object(SURROUNDPATTERN).BackCol();
	}

	int SurroundPattern() const
	{
		return Object(SURROUNDPATTERN).FillPattern();
	}


	void SetPieceForeColFor(bool forblack, int colour)
	{
		Object(forblack ? BLACKPIECE : WHITEPIECE).ForeCol(colour);
		RedrawObject(forblack ? BLACKPIECE : WHITEPIECE);
	}

	void SetPieceBackColFor(bool forblack, int colour)
	{
		Object(forblack ? BLACKPIECE : WHITEPIECE).BackCol(colour);
		RedrawObject(forblack ? BLACKPIECE : WHITEPIECE);
	}

	void SetSquareColFor(bool forblack, int colour)
	{
		Object(forblack ? BLACKSQUARE : WHITESQUARE).BackCol(colour);
		RedrawObject(forblack ? BLACKSQUARE : WHITESQUARE);
	}

	void SetSquarePatternFor(bool forblack, int pattern)
	{
		Object(forblack ? BLACKSQUARE : WHITESQUARE).FillPattern(pattern);
		RedrawObject(forblack ? BLACKSQUARE : WHITESQUARE);
	}


	void SetCursorColour(int colour)
	{
		Object(CURSORBORDER).BorderCol(colour);
		RedrawObject(CURSORBORDER);
	}

	void SetCursorBorder(int width)
	{
		Object(CURSORBORDER).BorderWidth(width);
		RedrawObject(CURSORBORDER);
	}

	void SetHighlightColour(int colour)
	{
		Object(HIGHLIGHTBORDER).BorderCol(colour);
		RedrawObject(HIGHLIGHTBORDER);
	}

	void SetHighlightBorder(int width)
	{
		Object(HIGHLIGHTBORDER).BorderWidth(width);
		RedrawObject(HIGHLIGHTBORDER);
	}

	void SetBoardBorderColour(int colour);
	void SetSurroundColour(int colour);
	void SetSurroundPattern(int pattern);



	virtual GEMfeedback DoItem(int item, const GEMevent& e);


	void ReadConfig(FILE* file);
	void WriteConfig(FILE* file);


private:
	PopupList popup;
	PopupColourChoice whitepiecedatacolour;
	PopupColourChoice blackpiecedatacolour;
	PopupColourChoice whitepiecemaskcolour;
	PopupColourChoice blackpiecemaskcolour;
	PopupColourChoice whitesquarecolour;
	PopupColourChoice blacksquarecolour;
	PopupPatternChoice blacksquarepattern;
	PopupPatternChoice whitesquarepattern;
	PopupColourChoice cursorcolour;
	PopupColourChoice highlightcolour;
	PopupColourChoice boardbordercolour;
	PopupColourChoice surroundcolour;
	PopupPatternChoice surroundpattern;

	ChessBoard& board;
};

class GEM_GNUChess_GUI;

class ChessBoard : public GEMformiconwindow {
public:
	ChessBoard(GEMactivity& act, const GEMrsc& rsc, GEM_GNUChess_GUI* g, ColourWindow& col) :
		GEMformiconwindow(act,rsc,BOARD,BOARDICON,MOVER|NAME|FULLER|INFO),
		gui(g),
		colour(col),
		chosen(FALSE),
		sizer(rsc,SIZE),
		pieces_sml(rsc,PIECES_SML),
		pieces_mid(rsc,PIECES_MID),
		pieces_lrg(rsc,PIECES_LRG),
		pieces(&pieces_mid),
		hl_fx(-1)
	{
		SetName(rsc.String(BOARDWINTITLE));
		for (int x=0; x<8; x++) {
			for (int y=0; y<8; y++) {
				Piece(x,y).Type(G_ICON);
				Piece(x,y).ObjectSpecific(long(new ICONBLK));
				Square(x,y).BorderWidth(0);
			}
		}
		sizer[SQUARE_SML+1].Type(G_ICON);
		sizer[SQUARE_SML+1].ObjectSpecific(long(new ICONBLK));
		sizer[SQUARE_MID+1].Type(G_ICON);
		sizer[SQUARE_MID+1].ObjectSpecific(long(new ICONBLK));
		sizer[SQUARE_LRG+1].Type(G_ICON);
		sizer[SQUARE_LRG+1].ObjectSpecific(long(new ICONBLK));
	}

	int SquareIndex(int x, int y) const
	{
		return R1C1+x*(R1C2-R1C1)+(7-y)*(R2C1-R1C1);
	}

	GEMrawobject& Piece(int x, int y) const
	{
		return Object(SquareIndex(x,y)+1); // Immediate child == +1
	}

	GEMrawobject& Square(int x, int y) const
	{
		return Object(SquareIndex(x,y));
	}

	void SetSquare(int x,int y,bool isblack)
	{
		Square(x,y).FillPattern(colour.SquarePatternFor(isblack));
		Square(x,y).ForeCol(colour.SquareForeColFor(isblack));
		Square(x,y).BackCol(colour.SquareBackColFor(isblack));
	}

	GEMrawobject& SelectPiece(int rscindex, int size) const
	{
		switch (size) {
		 case -1:
			return pieces->Object(rscindex);
		break; case 0:
			return pieces_sml.Object(rscindex);
		break; case 1:
			return pieces_mid.Object(rscindex);
		break; default:
			return pieces_lrg.Object(rscindex);
		}
	}

	void SetPiece(bool used,bool isblack,int x,int y,int piece)
	{
		if (used && piece) {
			SetPieceImage(Piece(x,y),piece,isblack);
			Piece(x,y).HideTree(FALSE);
		} else {
			Piece(x,y).HideTree(TRUE);
		}
		RedrawObject(SquareIndex(x,y));
	}

	void HighlightMove(char* move,bool redraw)
	{
		Unhighlight();

		hl_fx=move[0]-'a';
		hl_fy=move[1]-'1';
		hl_tx=move[2]-'a';
		hl_ty=move[3]-'1';

		Square(RV(hl_fx),RV(hl_fy)).BorderWidth(colour.HighlightBorder());
		Square(RV(hl_tx),RV(hl_ty)).BorderWidth(colour.HighlightBorder());
		Square(RV(hl_fx),RV(hl_fy)).BorderCol(colour.HighlightColour());
		Square(RV(hl_tx),RV(hl_ty)).BorderCol(colour.HighlightColour());

		if (redraw) {
			RedrawObject(SquareIndex(RV(hl_fx),RV(hl_fy)));
			RedrawObject(SquareIndex(RV(hl_tx),RV(hl_ty)));
		}
	}

	void Unhighlight()
	{
		if (hl_fx>-1) {
			Square(RV(hl_fx),RV(hl_fy)).BorderWidth(0);
			Square(RV(hl_tx),RV(hl_ty)).BorderWidth(0);
			RedrawObject(SquareIndex(RV(hl_fx),RV(hl_fy)));
			RedrawObject(SquareIndex(RV(hl_tx),RV(hl_ty)));
			hl_fx=-1;
		}
		if (chosen) {
			Square(RV(chosenx),RV(choseny)).BorderWidth(0);
			RedrawObject(SquareIndex(RV(chosenx),RV(choseny)));
			chosen=FALSE;
		}
	}

	int ChoosePromotion()
	{
		// Can't choose king or pawn.
		pieces->Object(PAWN).HideTree(TRUE);
		pieces->Object(KING).HideTree(TRUE);

		int result=PAWN+1-pieces->Do();

		pieces->Object(PAWN).HideTree(FALSE);
		pieces->Object(KING).HideTree(FALSE);

		return result;
	}

	void Refresh(bool outline);

	void SetSize();

	void SetSize(int size); // 0, 1, 2

	int Size()
	{
		return pieces==&pieces_sml ? 0 : pieces==&pieces_mid ? 1 : 2;
	}

	void SetPieceImage(GEMrawobject& obj, int piece, bool isblack, int size=-1)
	{
		*((ICONBLK*)obj.ObjectSpecific())=
			*((ICONBLK*)SelectPiece(PAWN+1-piece,size).ObjectSpecific());
		obj.ForeCol(colour.PieceForeColFor(isblack));
		obj.BackCol(colour.PieceBackColFor(isblack));
	}

private:
	int hl_fx,hl_fy,hl_tx,hl_ty;
	GEM_GNUChess_GUI* gui;
	GEMform pieces_sml;
	GEMform pieces_mid;
	GEMform pieces_lrg;
	GEMform* pieces;
	GEMform sizer;
	ColourWindow& colour;

	bool chosen;
	int chosenx;
	int choseny;

	virtual GEMfeedback DoItem(int item, const GEMevent& e);
};

void ColourWindow::ReadConfig(FILE* file)
{
	int value;

	fscanf(file,"%d",&value); SetPieceForeColFor(TRUE, value);
	fscanf(file,"%d",&value); SetPieceForeColFor(FALSE, value);
	fscanf(file,"%d",&value); SetPieceBackColFor(TRUE, value);
	fscanf(file,"%d",&value); SetPieceBackColFor(FALSE, value);
	fscanf(file,"%d",&value); SetSquareColFor(TRUE, value);
	fscanf(file,"%d",&value); SetSquareColFor(FALSE, value);
	fscanf(file,"%d",&value); SetSquarePatternFor(TRUE, value);
	fscanf(file,"%d",&value); SetSquarePatternFor(FALSE, value);
	fscanf(file,"%d",&value); SetCursorColour(value);
	fscanf(file,"%d",&value); SetCursorBorder(value);
	fscanf(file,"%d",&value); SetHighlightColour(value);
	fscanf(file,"%d",&value); SetHighlightBorder(value);
	fscanf(file,"%d",&value); SetBoardBorderColour(value);
	fscanf(file,"%d",&value); SetSurroundColour(value);
	fscanf(file,"%d",&value); SetSurroundPattern(value);
}

void ColourWindow::WriteConfig(FILE* file)
{
	fprintf(file,"%d\n",PieceForeColFor(TRUE));
	fprintf(file,"%d\n",PieceForeColFor(FALSE));
	fprintf(file,"%d\n",PieceBackColFor(TRUE));
	fprintf(file,"%d\n",PieceBackColFor(FALSE));
	fprintf(file,"%d\n",SquareBackColFor(TRUE));
	fprintf(file,"%d\n",SquareBackColFor(FALSE));
	fprintf(file,"%d\n",SquarePatternFor(TRUE));
	fprintf(file,"%d\n",SquarePatternFor(FALSE));
	fprintf(file,"%d\n",CursorColour());
	fprintf(file,"%d\n",CursorBorder());
	fprintf(file,"%d\n",HighlightColour());
	fprintf(file,"%d\n",HighlightBorder());
	fprintf(file,"%d\n",BoardBorderColour());
	fprintf(file,"%d\n",SurroundColour());
	fprintf(file,"%d\n",SurroundPattern());
}

void ColourWindow::SetBoardBorderColour(int colour)
{
	Object(BOARDBORDERBORDER).BorderCol(colour);
	RedrawObject(BOARDBORDERBORDER);
	board[BOARDBORDER].BorderCol(colour);
}

void ColourWindow::SetSurroundColour(int colour)
{
	Object(SURROUNDPATTERN).BackCol(colour);
	RedrawObject(SURROUNDPATTERN);
	board[BOARDSURROUND].BackCol(colour);
}

void ColourWindow::SetSurroundPattern(int pattern)
{
	Object(SURROUNDPATTERN).FillPattern(pattern);
	RedrawObject(SURROUNDPATTERN);
	board[BOARDSURROUND].FillPattern(pattern);
}

GEMfeedback ColourWindow::DoItem(int item, const GEMevent& e)
{
	// Deal with simple buttons.

	switch (item) {
	 case HIGHLIGHTBORDERMINUS:
		if (HighlightBorder()>1) SetHighlightBorder(HighlightBorder()-1);
	break; case HIGHLIGHTBORDERPLUS:
		if (HighlightBorder()<100) SetHighlightBorder(HighlightBorder()+1);
	break; case CURSORBORDERMINUS:
		if (CursorBorder()>1) SetCursorBorder(CursorBorder()-1);
	break; case CURSORBORDERPLUS:
		if (CursorBorder()<100) SetCursorBorder(CursorBorder()+1);
	break; case BOARDBORDERMINUS:
		// It's an outside border, so -ve everything.
		if (board[BOARDBORDER].BorderWidth()<0) {
			board[BOARDBORDER].BorderWidth(board[BOARDBORDER].BorderWidth()+1);
			Object(BOARDBORDERBORDER).BorderWidth(board[BOARDBORDER].BorderWidth());
			RedrawObject(SURROUNDPATTERN);
			board.Refresh(TRUE);
		}
	break; case BOARDBORDERPLUS:
		if (board[BOARDBORDER].BorderWidth()>-20) {
			board[BOARDBORDER].BorderWidth(board[BOARDBORDER].BorderWidth()-1);
			Object(BOARDBORDERBORDER).BorderWidth(board[BOARDBORDER].BorderWidth());
			RedrawObject(SURROUNDPATTERN);
			board.Refresh(TRUE);
		}
	break; default:
		// Deal with fancy popups..
		GEMformwindow::DoItem(item,e);

		// Look up until we see something we recognize.
		bool recog=FALSE;
		while (item && !recog) {
			recog=TRUE;
			switch (item) {
			 case WHITEDATACOLOUR:
				SetPieceForeColFor(FALSE,whitepiecedatacolour.Choice());
				board.Refresh(FALSE);
			break; case BLACKDATACOLOUR:
				SetPieceForeColFor(TRUE,blackpiecedatacolour.Choice());
				board.Refresh(FALSE);
			break; case WHITEMASKCOLOUR:
				SetPieceBackColFor(FALSE,whitepiecemaskcolour.Choice());
				board.Refresh(FALSE);
			break; case BLACKMASKCOLOUR:
				SetPieceBackColFor(TRUE,blackpiecemaskcolour.Choice());
				board.Refresh(FALSE);
			break; case WHITESQUARECOLOUR:
				SetSquareColFor(FALSE,whitesquarecolour.Choice());
				board.Refresh(FALSE);
			break; case BLACKSQUARECOLOUR:
				SetSquareColFor(TRUE,blacksquarecolour.Choice());
				board.Refresh(FALSE);
			break; case BLACKSQUAREPATTERN:
				SetSquarePatternFor(TRUE,blacksquarepattern.Choice());
				board.Refresh(FALSE);
			break; case WHITESQUAREPATTERN:
				SetSquarePatternFor(FALSE,whitesquarepattern.Choice());
				board.Refresh(FALSE);
			break; case CURSORCOLOUR:
				SetCursorColour(cursorcolour.Choice());
				board.Refresh(TRUE);
			break; case HIGHLIGHTCOLOUR:
				SetHighlightColour(highlightcolour.Choice());
				board.Refresh(TRUE);
			break; case BOARDBORDERCOLOUR:
				SetBoardBorderColour(boardbordercolour.Choice());
				board.Refresh(TRUE);
			break; case SURROUNDCOLOUR:
				SetSurroundColour(surroundcolour.Choice());
				board.Refresh(TRUE);
			break; case BOARDSURROUNDPATTERN:
				SetSurroundPattern(surroundpattern.Choice());
				board.Refresh(TRUE);
			break; default:
				recog=FALSE;
			}
			item=Parent(item);
		}
	}

	return ContinueInteraction;
}


class GEM_GNUChess_GUI : GEMactivity, GEMmenu {
public:
	GEM_GNUChess_GUI(GEMrsc& rsc) :
		GEMactivity(),
		GEMmenu(*this,rsc,MENUBAR),
		board(*this,rsc,this,colour),
		colour(*this,rsc,board),
		about(rsc,ABOUT),
		levellist(rsc,LEVEL),
		message(rsc,MESSAGE_F),
		lastchosenlevel(-1),
		loadfailed(rsc,LOADFAILED),
		savefailed(rsc,SAVEFAILED),
		bookwarn(rsc,BOOKWARN)
	{
		about[GUIVERSION].SetText(gui_version);
		about[CHESSVERSION].SetText(version);
		about[CHESSPATCHLEVEL].SetText(patchlevel);

		if (!LoadConfiguration(CONFIGFILE)) {
			GEMalert noconfig(rsc,NOCONFIG);
			noconfig.Alert();
			colour.Open();
		}
		Object(EDITCLEAR).Disable();
		BeginDo();
	}

	~GEM_GNUChess_GUI()
	{
		EndDo();
	}

	bool LoadConfiguration(const char* cnffile)
	{
		FILE* file=fopen(cnffile,"r");
		if (!file) return FALSE;
		colour.ReadConfig(file);
		int value,value2;
		fscanf(file,"%d",&value);
		board.SetSize(value);
		fscanf(file,"%d",&value);
		fscanf(file,"%d",&value2); board.Move(value,value2);
		fclose(file);
		return TRUE;
	}

	void SaveConfiguration(const char* cnffile)
	{
		FILE* file=fopen(cnffile,"w");
		if (!file) return;
		colour.WriteConfig(file);
		fprintf(file,"%d\n",board.Size());
		GRect boardpos=board.BorderRect();
		fprintf(file,"%d\n%d\n",boardpos.g_x,boardpos.g_y);
		fclose(file);
	}

	bool InEditMode() const
	{
		return Object(EDITTOGGLE).Checked();
	}

	bool HumanIsWhite() const
	{
		return Object(HUMANVSCPU).Checked();
	}

	void SetEditColour(int item)
	{
		if (!Object(item).Checked()) {
			Object(EDITWHITE).Uncheck();
			Object(EDITBLACK).Uncheck();
			Object(item).Checked(item);
			SetMove("C");
		}
	}

	int ChosenPiece()
	{
		for (int i=EDITKING; i<=EDITPAWN; i++) {
			if (Object(i).Checked()) {
				return EDITPAWN+1-i;
			}
		}

		return 0; // EDITNONE
	}

	void SetEditPiece(int item)
	{
		for (int i=EDITKING; i<=EDITNONE; i++) {
			Object(i).Checked(i==item);
		}
	}

	void DrawPiece(bool used,bool isblack,int x,int y,int piece)
	{
		board.SetPiece(used,isblack,x,y,piece);
	}

	void DrawSquare(int x, int y, bool isblack)
	{
		board.SetSquare(x,y,isblack);
	}

	int ChooseLevel()
	{
		if (lastchosenlevel<=0) {
			lastchosenlevel=levellist.Do()-LEVEL1+1;
		}
		return lastchosenlevel;
	}

	void GetMove(char* m)
	{
		if (!board.IsOpen()) board.Open(); // Keep it open, but don't top.

		move[0]=0;
		while (!move[0]) OneDo();
		strcpy(m,move);

		Unhighlight();
	}

	void SetMove(const char* m)
	{
		strcpy(move,m);
	}

	void Message(char* msg)
	{
		char info[128];
		sprintf(info," %02d:%02d  %s",minutes,seconds,msg);
		board.SetInfoText(info);
	}

	void SetTime(int mins, int secs)
	{
		minutes=mins;
		seconds=secs;
		Message("");
	}

	void HighlightMove(char* move,bool redraw)
	{
		board.HighlightMove(move,redraw);
	}

	void Unhighlight()
	{
		board.Unhighlight();
	}

	void LoadFailed()
	{
		loadfailed.Alert();
	}

	void SaveFailed()
	{
		savefailed.Alert();
	}

	void SetReverse(bool yes)
	{
		Object(DOREVERSE).Checked(yes);
	}

private:
	int lastchosenlevel;
	int minutes,seconds;
	char move[32];
	GEMalert loadfailed,savefailed;

	// Menu override.
	virtual GEMfeedback DoItem(int item, const GEMevent& e)
	{
		switch (item) {
		 case DOABOUT:
			about.Do();
		break; case DONEW:
			SetMove("new");
		break; case DORANDOM:
			SetMove("random");
		break; case DOLOAD:
			SetMove("get");
		break; case DOSAVE:
			SetMove("save");
		break; case DOLIST:
			SetMove("list");
		break; case DOQUIT:
			SetMove("quit");
		break; case EDITTOGGLE:
			if (Object(EDITTOGGLE).Checked()) {
				Object(EDITTOGGLE).Uncheck();
				Object(EDITCLEAR).Disable();

				for (int i=FIRSTMENUTITLE; i<=LASTMENUTITLE; i++) {
					if (i!=EDITMENUTITLE) {
						Object(i).Enable();
						RedrawObject(i);
					}
				}

				SetMove(".");
			} else {
				Object(EDITTOGGLE).Check();
				Object(EDITCLEAR).Enable();

				for (int i=FIRSTMENUTITLE; i<=LASTMENUTITLE; i++) {
					if (i!=EDITMENUTITLE) {
						Object(i).Disable();
						RedrawObject(i);
					}
				}

				SetMove("edit");
			}
		break; case EDITWHITE:
			SetEditColour(item);
		break; case EDITBLACK:
			SetEditColour(item);
		break; case EDITKING: case EDITQUEEN: case EDITBISHOP:
				case EDITKNIGHT: case EDITROOK: case EDITPAWN: case EDITNONE:
			SetEditPiece(item);
		break; case EDITCLEAR:
			SetMove("#");
		break; case HUMANVSCPU: case CPUVSHUMAN: case CPUVSCPU:
			if (!Object(item).Checked()) {
				Object(HUMANVSCPU).Checked(item==HUMANVSCPU);
				Object(CPUVSHUMAN).Checked(item==CPUVSHUMAN);
				Object(CPUVSCPU).Checked(item==CPUVSCPU);

				switch (item) {
				 case HUMANVSCPU:
					SetMove("black");
				break; case CPUVSHUMAN:
					SetMove("white");
				break; case CPUVSCPU:
					SetMove("both");
				}
			}
		break; case DOREVERSE:
			SetMove("reverse");
		break; case DOLEVEL:
			lastchosenlevel=levellist.Do(e.X()-8,e.Y()-8)-LEVEL1+1;
			if (lastchosenlevel>0) SetMove("level");
		break; case DOSIZE:
			board.SetSize();
		break; case DOHINT:
			SetMove("hint");
		break; case BACK1MOVE:
			SetMove("undo");
		break; case BACK2MOVES:
			SetMove("remove");
		break; case DOCOLOUR:
			colour.Open();
		break; case DISABLEBOOK:
			if (bookwarn.Alert()==2) {
				SetMove("book");
			}
		break; case DOSAVECONFIG:
			SaveConfiguration(CONFIGFILE);
		}

		return ContinueInteraction;
	}

private:
	ChessBoard board;
	ColourWindow colour;
	GEMform about;
	GEMhotform levellist;
	GEMalert message;
	GEMalert bookwarn;
};

void ChessBoard::Refresh(bool outline)
{
	if (outline) {
		RedrawObject(0);
	} else {
		gui->SetMove("bd");
	}
}

void ChessBoard::SetSize()
{
	bool isblack=!gui->HumanIsWhite();

	SetPieceImage(sizer[SQUARE_SML+1],king,isblack,0);
	SetPieceImage(sizer[SQUARE_MID+1],king,isblack,1);
	SetPieceImage(sizer[SQUARE_LRG+1],king,isblack,2);

	int size=sizer.Do();
	if (size>0) {
		while (!sizer[size].Selectable())
			size=sizer.Parent(size);
		SetSize(size==SQUARE_SML ? 0 : size==SQUARE_MID ? 1 : 2);
	}
}

void ChessBoard::SetSize(int size)
{
	int RSCsize;

	switch (size) {
	 case 0:
		pieces=&pieces_sml;
		RSCsize=SQUARE_SML;
	break; case 1:
		pieces=&pieces_mid;
		RSCsize=SQUARE_MID;
	break; default:
		pieces=&pieces_lrg;
		RSCsize=SQUARE_LRG;
	}

	GEMrawobject& sized=sizer.Object(RSCsize);

	for (int x=0; x<8; x++) {
		for (int y=0; y<8; y++) {
			Square(x,y).Resize(sized.Width(),sized.Height());
			Square(x,y).MoveTo(0,(7-y)*sized.Height());
			Piece(x,y).MoveTo(sizer.Object(RSCsize+1).X(),sizer.Object(RSCsize+1).Y());
			Piece(x,y).HideTree(TRUE); // Go away - come back on refresh.
		}
		GEMrubberobject colmn(*this,C1+(C2-C1)*x);
		colmn.MoveTo(x*sized.Width(),0);
		colmn.Fit(0);
	}

	GEMrubberobject box(*this,BOARDBORDER);
	box.Fit(0);

	GEMrubberobject root(*this,BOARDSURROUND);
	root.Fit(box.X());

	GRect rect(root.X(),root.Y(),root.Width(),root.Height());

	// XXX Excessive redraws here.
	SetWorkRect(rect);
	RedrawObject(0);
	Refresh(FALSE);
}

GEMfeedback ChessBoard::DoItem(int item, const GEMevent& e)
{
	item-=R1C1;

	int x=item/(R1C2-R1C1);
	int y=(item-x*(R1C2-R1C1))/(R2C1-R1C1);

	x=RV(x);
	y=RV(7-y);

	if (gui->InEditMode()) {
		char move[4];
		move[0]=pxx[gui->ChosenPiece()];
		move[1]='a'+x;
		move[2]='1'+y;
		move[3]=0;
		gui->SetMove(move);
	} else {
		if (chosen) {
			char move[5];
			move[0]='a'+chosenx;
			move[1]='1'+choseny;
			move[2]='a'+x;
			move[3]='1'+y;
			move[4]=0;
			if (NeedPromotion(chosenx,choseny)) {
				move[4]=qxx[ChoosePromotion()];
				move[5]=0;
			}
			gui->SetMove(move);
			chosen=FALSE;
		} else {
			chosen=TRUE;
			chosenx=x;
			choseny=y;
		}

		Square(RV(chosenx),RV(choseny)).BorderWidth(chosen ? colour.CursorBorder() : 0);
		Square(RV(chosenx),RV(choseny)).BorderCol(colour.CursorColour());
		RedrawObject(SquareIndex(RV(chosenx),RV(choseny)));
	}

	GEMevent event;
	event.Button(1,0); // leftbutton release
	event.Get(MU_BUTTON);

	return ContinueInteraction;
}

static GEMapplication* app;
static GEMrsc* rsc;
static GEM_GNUChess_GUI* gem_gui;

void ui_Initialize()
{
	app=new GEMapplication;

	{
		VDI vdi;
		if (vdi.CharCellHeight()<=8) {
			rsc=new GEMrsc("data\\low_rsc.rsc");
		} else {
			rsc=new GEMrsc("data\\gem_rsc.rsc");
		}
	}

	gem_gui=new GEM_GNUChess_GUI(*rsc);
}

void ui_Finalize()
{
	delete gem_gui;
	delete rsc;
	delete app;
}


void ui_GiveHelp (int compiswhite,int level,int easy,int maxdep,int dither,int hash)
{
}

void ui_ShowEditHelp()
{
}

void ui_ShowEditColor(int col)
{
	gem_gui->SetEditColour(col+EDITWHITE);
}

void ui_GetPieceAndLocation(char *s)
{
	gem_gui->GetMove(s);
}

void ui_ShowComputerMove(char *move, int feature)
{
	switch (feature) {
	 case 1:; // Draw
	break; case 2:
		CheckMate=1;
		ui_ShowMessage("Mate");
	break; case 3:
		CheckMate=2;
		ui_ShowMessage("Mate");
	break; case 4:; // Near win
		//ui_ShowMessage("Oh dear.");
	break; case 5:; // Near loss
		//ui_ShowMessage("Watch out.");
	}

	gem_gui->HighlightMove(move,FALSE/*DrawPiece called anyway*/);
}

void ui_DrawPiece(bool used, bool isblack, int x, int y, int piece)
{
	gem_gui->DrawPiece(used,isblack,x,y,piece);
}

void ui_DrawSquare(int x, int y, bool isblack)
{
	gem_gui->DrawSquare(x,y,isblack);
}

void ui_GetFilename(char *prompt,char *name)
{
	GEMfileselector* filesource=0;

	if (!filesource) filesource=new GEMfileselector;

	if (!filesource->Get(prompt,name))
		name[0]=-1;
}

void ui_LoadDone()
{
}

void ui_LoadFailed()
{
	gem_gui->LoadFailed();
}

void ui_SaveDone()
{
}

void ui_SaveFailed()
{
	gem_gui->SaveFailed();
}

void ui_ChangeLevel(int *newlevel)
{
	*newlevel=gem_gui->ChooseLevel();
}

void ui_GetMove(char *s)
{
	gem_gui->GetMove(s);
}

void ui_ShowHint(char *move)
{
	gem_gui->HighlightMove(move,TRUE);
}
 
void ui_ShowPlayers(bool Reverse,int CompIsBlack)
{
	WhiteFromTop=Reverse;
	ComputerIsBlack=CompIsBlack;
	gem_gui->SetReverse(Reverse);
}

void ui_ShowSideToMove(int movenum, int who)
{
	CurrentColour=who;
}

void ui_RejectMove(char *move)
{
	int ifx=move[0]-'a';
	int ify=move[1]-'1';
	int itx=move[2]-'a';
	int ity=move[3]-'1';

	ui_DrawPiece(TRUE,ColourAt(ifx,ify),RV(ifx),RV(ify),RankAt(ifx,ify));
}

void ui_ShowClock(bool OnWhiteSide, int minutes, int seconds)
{
	gem_gui->SetTime(minutes,seconds);
}

void ui_ShowMessage(char *msg)
{
	gem_gui->Message(msg);
}

// Unused interface hooks...

void ui_PromptForMove() {}
void ui_ToggleRV() {}
void ui_ToggleStars() {}
void ui_ToggleShade() {}
int ui_AskAbort() { return 0; }
void ui_ClearEditHelp() {}
void ui_RefreshEarly() {}
void ui_ChoosePiece(char *s) {}
void ui_ChangeSearchDepth(int *newdepth) {}
void ui_ChangeContempt(int *newcontempt) {}
void ui_ShowFileSaving(char *name) {}
void ui_ShowFileLoading(char *name) {}
void ui_DrawCoords() {}
void ui_ShowPosnValue(short sq, int score) {}
void ui_ShowMaxTree(int maxtree) {}
void ui_ClrScreen() {}
void ui_ShowDepth(int depth, char ch) {}
void ui_ShowScore(int score) {}
void ui_ClearMessage() { gem_gui->Message(""); gem_gui->Unhighlight(); }
void ui_ShowCurrentMove(int pnt, char *move) {}
void ui_ShowTitle() {}
void ui_ShowNodeCnt(long int NodeCnt, long int evrate) {}
void ui_ShowPlyMove(int ply,char *move) {}
void ui_NoMorePly(int ply) {}
void ui_SearchStartStuff(int side) {}
