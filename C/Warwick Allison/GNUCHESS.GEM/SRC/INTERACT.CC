/* interact.cc - Interactive component of CHESS
		(parent module of *ui.cc modules)

	This file was extracted from the original GNU Chess file nuxui.c
	and converted to C++ by Warwick Allison.  It is a the generic portion
	of the user interface.  1993-11-23


	Revision: 1990-05-09

	Copyright (C) 1986, 1987, 1988, 1989, 1990 Free Software Foundation, Inc.
	Copyright (c) 1988, 1989, 1990	John Stanback

	Modified extensively Nov 1989 Christopher North-Keys
		40x24 two-colour display
				option for shading black squares
				expanded game save, list, and restore features using $HOME
				option to disable display of coordinates
				optional auto-updating of positional information
				optional starring of black side
				mass toggle for reverse-video functions

	This file is part of CHESS.

	CHESS is distributed in the hope that it will be useful, but WITHOUT ANY
	WARRANTY.	No author or distributor accepts responsibility to anyone for
	the consequences of using it or for whether it serves any particular
	purpose or works at all, unless he says so in writing.	Refer to the CHESS
	General Public License for full details.

	Everyone is granted permission to copy, modify and redistribute CHESS, but
	only under the conditions described in the CHESS General Public License.
	A copy of this license is supposed to have been given to you along with
	CHESS so you can know your rights and responsibilities.	It should be in a
	file named COPYING.	Among other things, the copyright notice and this
	notice must be preserved on all copies.
*/


#include <ctype.h>
#include <signal.h>
#include <stdlib.h>
#include <time.h>
#ifdef MSDOS
#include <dos.h>
#include <conio.h>
#include <string.h>
#else
#include <sys/param.h>
#include <sys/types.h>
#include <sys/file.h>
#include <curses.h>
#undef bool // curses.h defines it to char...
#undef TRUE
#undef FALSE
#endif /* MSDOS */

extern "C" {
#include "gnuchess.h"
#include "/usr/gnuchess/src/ataks.h"
};

char *DRAW;
int mycnt1, mycnt2;

#include "ui.h"

//#define pxx " PNBRQK"
//#define qxx " pnbrqk"
//#define rxx "12345678"
//#define cxx "abcdefgh"

/* coordinates within a square for the following are ([1,5],[1,3]) */
#define VIR_C(s)	((flag.reverse) ? 7-column(s) : column(s))
#define VIR_R(s)	((flag.reverse) ? 7-row(s) : row(s))
//#define VIR_C(s)	(column(s))
//#define VIR_R(s)	(row(s))
#define Vblack(s) (!((VIR_C(s) + VIR_R(s)) % 2))

static char mvstr[4][6];
static long evrate;
short PositionFlag = 0;
short coords = 1;

void TerminateSearch (int), Die (int);

void
Initialize (void)
{
	signal (SIGINT, Die);
#ifndef MSDOS
	signal (SIGQUIT, Die);
#endif
	ui_Initialize();
	mycnt1=0;
	mycnt2=0;
}

void
ExitChess (void)
{
	//ListGame ();
	ui_Finalize();
	exit (0);
}

void
Die (int Sig)
{
	signal (SIGINT, SIG_IGN);
#ifdef MSDOS
	Sig++;																/* shut up the compiler */
#else
	signal (SIGQUIT, SIG_IGN);
#endif /* MSDOS */
	if (ui_AskAbort())
		ExitChess ();
	signal (SIGINT, Die);
#ifndef MSDOS
	signal (SIGQUIT, Die);
#endif /* MSDOS */
}

void
TerminateSearch (int Sig)
{
	signal (SIGINT, SIG_IGN);
#ifdef MSDOS
	Sig++;																/* shut up the compiler */
#else
	signal (SIGQUIT, SIG_IGN);
#endif /* MSDOS */
	if (!flag.timeout)
		flag.musttimeout = true;
	flag.bothsides = false;
	signal (SIGINT, Die);
#ifndef MSDOS
	signal (SIGQUIT, Die);
#endif /* MSDOS */
}

void
algbr (short int f, short int t, short int flag)

/*
	 Generate move strings in different formats.
*/

{
	int m3p;

	if (f != t)
		{
			/* algebraic notation */
			mvstr[0][0] = cxx[column (f)];
			mvstr[0][1] = rxx[row (f)];
			mvstr[0][2] = cxx[column (t)];
			mvstr[0][3] = rxx[row (t)];
			mvstr[0][4] = mvstr[3][0] = '\0';
			if ((mvstr[1][0] = pxx[board[f]]) == 'P')
				{
					if (mvstr[0][0] == mvstr[0][2])				/* pawn did not eat */
						{
							mvstr[2][0] = mvstr[1][0] = mvstr[0][2];				/* to column */
							mvstr[2][1] = mvstr[1][1] = mvstr[0][3];				/* to row */
							m3p = 2;
						}
					else
						/* pawn ate */
						{
							mvstr[2][0] = mvstr[1][0] = mvstr[0][0];				/* from column */
							mvstr[2][1] = mvstr[1][1] = mvstr[0][2];				/* to column */
							mvstr[2][2] = mvstr[0][3];
							m3p = 3;								/* to row */
						}
					mvstr[2][m3p] = mvstr[1][2] = '\0';
					if (flag & promote)
						{
							mvstr[0][4] = mvstr[1][2] = mvstr[2][m3p] = qxx[flag & pmask];
							mvstr[1][3] = mvstr[2][m3p + 1] = mvstr[0][5] = '\0';
						}
				}
			else
				/* not a pawn */
				{
					mvstr[2][0] = mvstr[1][0];
					mvstr[2][1] = mvstr[0][1];
					mvstr[2][2] = mvstr[1][1] = mvstr[0][2];				/* to column */
					mvstr[2][3] = mvstr[1][2] = mvstr[0][3];				/* to row */
					mvstr[2][4] = mvstr[1][3] = '\0';
					strcpy (mvstr[3], mvstr[2]);
					mvstr[3][1] = mvstr[0][0];
					if (flag & cstlmask)
						{
							if (t > f)
								{
									strcpy (mvstr[1], "o-o");
									strcpy (mvstr[2], "O-O");
								}
							else
								{
									strcpy (mvstr[1], "o-o-o");
									strcpy (mvstr[2], "O-O-O");
								}
						}
				}
		}
	else
		mvstr[0][0] = mvstr[1][0] = mvstr[2][0] = mvstr[3][0] = '\0';
}

int
VerifyMove (char *s, short int iop, short unsigned int *mv)

/*
	 Compare the string 's' to the list of legal moves available for the
	 opponent. If a match is found, make the move on the board.
*/

{
	static short pnt, tempb, tempc, tempsf, tempst, cnt;
	static struct leaf xnode;
	struct leaf *node;
	*mv = 0;

	if (iop == 2) {
		UnmakeMove (opponent, &xnode, &tempb, &tempc, &tempsf, &tempst);
		return (false);
	}
	cnt = 0;
	MoveList (opponent, 2);
	pnt = TrPnt[2];
	while (pnt < TrPnt[3]) {
		node = &Tree[pnt++];
		algbr (node->f, node->t, (short) node->flags);
		if (strcmp (s, mvstr[0]) == 0 || strcmp (s, mvstr[1]) == 0 ||
				strcmp (s, mvstr[2]) == 0 || strcmp (s, mvstr[3]) == 0) {
			cnt++;
			xnode = *node;
		}
	}
	if (cnt == 1) {
		MakeMove (opponent, &xnode, &tempb, &tempc, &tempsf, &tempst, &INCscore);
		if (SqAtakd (PieceList[opponent][0], computer)) {
			UnmakeMove (opponent, &xnode, &tempb, &tempc, &tempsf, &tempst);
			ShowMessage ("Illegal Move!");
			return (false);
		} else {
			if (iop == 1)
				return (true);
			UpdateDisplay (xnode.f, xnode.t, 0, (short) xnode.flags);
			if ((board[xnode.t] == pawn)
					|| (xnode.flags & capture)
					|| (xnode.flags & cstlmask)) {
				Game50 = GameCnt;
				ZeroRPT ();
			}
			GameList[GameCnt].depth = GameList[GameCnt].score = 0;
			GameList[GameCnt].nodes = 0;
			ElapsedTime (1);
			GameList[GameCnt].time = (short) (et+50)/100;
			if (TCflag) {
				TimeControl.clock[opponent] -= et;
				timeopp[oppptr] = et;
				--TimeControl.moves[opponent];
			}
			*mv = (xnode.f << 8) | xnode.t;
			algbr (xnode.f, xnode.t, false);
			return (true);
		}
	}
	if (cnt > 1) {
		ShowMessage ("Ambiguous Move!");
	}
	return (false);
}

void
help (void)
{
	ui_GiveHelp(computer,0,flag.easy,MaxSearchDepth,dither,flag.hash);
}

void
EditBoard (void)

/*
	Set up a board position. Pieces are entered by typing the piece
	followed by the location. For example, Nf3 will place a knight on
	square f3.
*/

{
	short a, r, c, sq, i;
	char s[80];

	ui_ShowEditHelp();
	a = white;
	do
		{
			ui_ShowEditColor(a);
			ui_GetPieceAndLocation(s);
			if (s[0] == '#')
				{
					for(sq = 0; sq < 64; sq++)
						{
							board[sq] = no_piece;
							color[sq] = neutral;
							DrawPiece (sq);
						}
				}
			if (s[0] == 'c' || s[0] == 'C')
				a = otherside[a];
			c = s[1] - 'a';
			r = s[2] - '1';
			if ((c >= 0) && (c < 8) && (r >= 0) && (r < 8))
				{
					sq = locn (r, c);
					for (i = king; i > no_piece; i--)
						if ((s[0] == pxx[i]) || (s[0] == qxx[i]))
							break;
					board[sq] = i;
					color[sq] = (board[sq] == no_piece) ? neutral : a;		
					DrawPiece (sq);
				}
	} while (s[0] != '.');

	for (sq = 0; sq < 64; sq++)
		Mvboard[sq] = (board[sq] != Stboard[sq]) ? 10 : 0;
	GameCnt = 0;
	Game50 = 1;
	ZeroRPT ();
	Sdepth = 0;
	InitializeStats ();
	ui_ClearEditHelp();
	UpdateDisplay (0, 0, 1, 0);
}




void
ShowPlayers (void)
{			
	ui_ShowPlayers(flag.reverse,computer==black);
}


void
ShowDepth (char ch)
{
	ui_ShowDepth(Sdepth,ch);
	ui_RefreshEarly();
}


void
ShowScore (short score)
{
	ui_ShowScore(score);
}


void
ShowMessage (char *s)
{
	ui_ShowMessage(s);
}


void
ClearMessage (void)
{
	ui_ClearMessage();
}


void
ShowCurrentMove (short int pnt, short int f, short int t)
{
	algbr (f, t, false);
	ui_ShowCurrentMove(pnt,mvstr[0]);
}


void
ShowHeader (void)
{
	ui_ShowTitle();
}


void
ShowSidetoMove (void)
{
	ui_ShowSideToMove(1+GameCnt/2,player);
}


void
ShowPrompt (void)
{
	ui_PromptForMove();
}


void
ShowNodeCnt (long int NodeCnt, long int evrate)
{			
	ui_ShowNodeCnt(NodeCnt,evrate);
}


void
ShowResults (short int score, short unsigned int *bstline, char ch)
{
	unsigned char d, ply;
	if (flag.post)
		{
			ShowDepth (ch);
			ShowScore (score);
			d = 7;
			for (ply = 1; bstline[ply] > 0; ply++)
				{
					algbr ((short) bstline[ply] >> 8, (short) bstline[ply] & 0xFF, false);
					ui_ShowPlyMove(ply,mvstr[0]);
				}
			ui_NoMorePly(ply);
		}
}



void
SearchStartStuff (short int side)
{
	ui_SearchStartStuff(side);
}


void
OutputMove (void)
{
	if(flag.illegal){ShowMessage(CP[225]);return;}

	int i;

	if (root->flags & draw)
		i=1;
	else if (root->score == -9999)
		i=2;
	else if (root->score == 9998)
		i=3;
	else if (root->score < -9000)
		i=4;
	else if (root->score > 9000)
		i=5;
	else
		i=0;

	ui_ShowComputerMove(mvstr[0],i);

	UpdateDisplay (root->f, root->t, 0, (short) root->flags);

	if (flag.post)
		{
			ShowNodeCnt (NodeCnt, evrate);
			for (i = 1999; i >= 0 && Tree[i].f == 0 && Tree[i].t == 0; i--);
			ui_ShowMaxTree(i);
		}
}



void
ElapsedTime (short int iop)

/*
	Determine the time that has passed since the search was started. If
	the elapsed time exceeds the target (ResponseTime+ExtraTime) then set
	timeout to true which will terminate the search.
*/

{
	et = (time ((long *) 0) - time0) * 100;
	ETnodes = NodeCnt + ZNODES;
	if (et < 0)
		et = 0;
	if (iop == 1)
		{
			if (et > ResponseTime + ExtraTime && Sdepth > MINDEPTH)
				flag.timeout = true;
			ETnodes = NodeCnt + ZNODES;
			time0 = time ((long *) 0);
		}

	UpdateClocks ();
}

void
UpdateClocks (void)
{
	short m, s;

	m = (short) (et / 6000);
	s = (short) (et - 6000 * (long) m) / 100;
	if (TCflag)
		{
			m = (short) ((TimeControl.clock[player] - et) / 6000);
			s = (short) ((TimeControl.clock[player] - et - 6000 * (long) m) / 100);
		}
	if (m < 0)
		m = 0;
	if (s < 0)
		s = 0;

	ui_ShowClock(flag.reverse ^ (player==white),m,s);
	if (flag.post)
		ShowNodeCnt (NodeCnt, evrate);
	/*refresh ();*/
}


void
SetTimeControl (void)
{
	if (TCflag)
		{
			TimeControl.moves[white] = TimeControl.moves[black] = TCmoves;
			TimeControl.clock[white] += 6000L * TCminutes + TCseconds * 100;
			TimeControl.clock[black] += 6000L * TCminutes + TCseconds * 100;
		}
	else
		{
			TimeControl.moves[white] = TimeControl.moves[black] = 0;
			TimeControl.clock[white] = TimeControl.clock[black] = 0;
		}
	flag.onemove = (TCmoves == 1);
	et = 0;
	ElapsedTime (1);
}

void
DrawPiece (short int sq)
{
	ui_DrawPiece(color[sq]!=neutral,color[sq]==black,VIR_C(sq),VIR_R(sq),board[sq]);
}


void
DrawSquare (short int sq)
{
	ui_DrawSquare(VIR_C(sq),VIR_R(sq),Vblack(sq));
}


void
DrawCoords (void)
{
	ui_DrawCoords();
}


void
ShowPostnValue (short int sq)

/*
	must have called ExaminePosition() first
*/
		 
{
	short score;
	
	score = ScorePosition (color[sq]);
	ui_ShowPosnValue(sq,score);
}



void
ShowPostnValues (void)
{
	short sq, score;

	ExaminePosition ();
	for (sq = 0; sq < 64; sq++)
		ShowPostnValue (sq);
	score = ScorePosition (opponent);
	ShowScore (score);
}

void
UpdateDisplay (short int f, short int t, short int redraw, short int isspec)
{
	short sq;
	
	if (redraw)
		{
			ShowHeader ();
			ShowPlayers ();
			for (sq = 0; sq < 64; sq++)
				{
					DrawSquare (sq);
					DrawPiece (sq);
				}
			if (coords)
				DrawCoords ();
		}
	else
		{
			DrawPiece (f);
			DrawPiece (t);
			if (isspec & cstlmask)
				if (t > f)
					{
						DrawPiece (f + 3);
						DrawPiece (t - 1);
					}
				else
					{
						DrawPiece (f - 4);
						DrawPiece (t + 1);
					}
			else if (isspec & epmask)
				{
					DrawPiece (t - 8);
					DrawPiece (t + 8);
				}
		}
	if (PositionFlag)
		ShowPostnValues ();
	/*refresh ();*/
}

void
GetGame (void)
{
	FILE *fd;
	char fname[256];
	char *tmp;
	int c;
	short sq;
	unsigned short m;

	fname[0] = 0;
	ui_GetFilename("Load",fname);

	if (fname[0]!=-1) {
		if (!fname[0])
			strcpy (fname, "chess.000");

		ui_ShowFileLoading(fname);

		if ((fd = fopen (fname, "r")) == NULL) {
			ui_LoadFailed();
			return;
		}

		fscanf (fd, "%hd%hd%hd", &computer, &opponent, &Game50);
		fscanf (fd, "%hd%hd", &castld[white], &castld[black]);
		fscanf (fd, "%hd%hd", &TCflag, &OperatorTime);
		fscanf (fd, "%ld%ld%hd%hd",
						&TimeControl.clock[white], &TimeControl.clock[black],
						&TimeControl.moves[white], &TimeControl.moves[black]);
		for (sq = 0; sq < 64; sq++)
			{
				fscanf (fd, "%hd%hd", &m, &Mvboard[sq]);
				board[sq] = (m >> 8);
				color[sq] = (m & 0xFF);
				if (color[sq] == 0)
					color[sq] = neutral;
				else
					--color[sq];
			}
		GameCnt = 0;
		c = '?';
		while (c != EOF)
			{
				++GameCnt;
				c = fscanf (fd, "%hd%hd%hd%ld%hd%hd%hd", &GameList[GameCnt].gmove,
										&GameList[GameCnt].score, &GameList[GameCnt].depth,
										&GameList[GameCnt].nodes, &GameList[GameCnt].time,
										&GameList[GameCnt].piece, &GameList[GameCnt].color);
				if (GameList[GameCnt].color == 0)
					GameList[GameCnt].color = neutral;
				else
					--GameList[GameCnt].color;
			}
		GameCnt--;
		if (TimeControl.clock[white] > 0)
		TCflag = true;
		computer--;
		opponent--;

		fclose (fd);

		InitializeStats ();
		Sdepth = 0;
		ui_LoadDone();
		UpdateDisplay (0, 0, 1, 0);
	}
}


void
SaveGame (void)
{
	FILE *fd;
	char fname[256];
	char *tmp;
	short sq, i, c;

	fname[0] = 0;

	ui_GetFilename("Save",fname);

	if (!fname[0])
		strcpy (fname, "chess.000");

	ui_ShowFileSaving(fname);

	if (NULL == (fd = fopen (fname, "w"))) {
		ui_SaveFailed();
		return;
	}

	fprintf (fd, "%d %d %d\n", computer + 1, opponent + 1, Game50);
	fprintf (fd, "%d %d\n", castld[white], castld[black]);
	fprintf (fd, "%d %d\n", TCflag, OperatorTime);
	fprintf (fd, "%ld %ld %d %d\n",
					 TimeControl.clock[white], TimeControl.clock[black],
					 TimeControl.moves[white], TimeControl.moves[black]);
	for (sq = 0; sq < 64; sq++)
		{
			if (color[sq] == neutral)
				c = 0;
			else
				c = color[sq] + 1;
			fprintf (fd, "%d %d\n", 256 * board[sq] + c, Mvboard[sq]);
		}
	for (i = 1; i <= GameCnt; i++)
		{
			if (GameList[i].color == neutral)
				c = 0;
			else
				c = GameList[i].color + 1;
			fprintf (fd, "%d %d %d %ld %d %d %d\n",
							 GameList[i].gmove, GameList[i].score, GameList[i].depth,
							 GameList[i].nodes, GameList[i].time,
							 GameList[i].piece, c);
		}
	fclose (fd);
	ui_SaveDone();
}




void
ListGame (void)
{
	FILE *fd;
	char fname[256];
	char *tmp;
	short i, f, t;

	fname[0] = 0;
	ui_GetFilename("List",fname);
	if (!fname[0])
		strcpy (fname, "chess.lst");

	if (!(fd = fopen (fname, "w"))) {
		ShowMessage ("Cannot write move list");
		return;
	}

	fprintf (fd, "\n");
	fprintf (fd, "       score  depth   nodes  time         ");
	fprintf (fd, "       score  depth   nodes  time\n");
	for (i = 1; i <= GameCnt; i++) {
		f = GameList[i].gmove >> 8;
		t = (GameList[i].gmove & 0xFF);
		algbr (f, t, false);
		if ((i % 2) == 1)
			fprintf (fd, "\n");
		else
			fprintf (fd, "         ");
		fprintf (fd, "%5s  %5d     %2d %7ld %5d", mvstr[0],
					 GameList[i].score, GameList[i].depth,
					 GameList[i].nodes, GameList[i].time);
	}
	fprintf (fd, "\n\n");
	fclose (fd);
	//ShowMessage ("Move list written");
}

void
Undo (void)

/*
	Undo the most recent half-move.
*/

{
	short f, t;
	f = GameList[GameCnt].gmove >> 8;
	t = GameList[GameCnt].gmove & 0xFF;
	if (board[t] == king && distance (t, f) > 1)
		(void) castle (GameList[GameCnt].color, f, t, 2);
	else {
		/* Check for promotion: */
		if ((color[t] == white && row (f) == 6 && row (t) == 7)
				|| (color[t] == black && row (f) == 1 && row (t) == 0))
			{
				int g, from = f;
				for (g = GameCnt - 1; g > 0; g--)
					if (GameList[g].gmove & 0xFF == from)
						from = GameList[g].gmove >> 8;
				if ((color[t] == white && row (from) == 1)
						|| (color[t] == black && row (from) == 6))
					board[t] = pawn;
			}
		board[f] = board[t];
		color[f] = color[t];
		board[t] = GameList[GameCnt].piece;
		color[t] = GameList[GameCnt].color;
		if (color[t] != neutral)
			Mvboard[t]--;
		Mvboard[f]--;
	}
	if (TCflag)
		++TimeControl.moves[color[f]];
	GameCnt--;
	computer = otherside[computer];
	opponent = otherside[opponent];
	flag.mate = false;
	Sdepth = 0;
	UpdateDisplay (0, 0, 1, 0);
	InitializeStats ();
}

/*
void
ChangeAlphaWindow (void)
{
	ShowMessage ("Awindow= ");
	scanz ("%hd", &Awindow);
}

void
ChangeBetaWindow (void)
{
	ShowMessage ("Bwindow= ");
	scanz ("%hd", &Bwindow);
}
*/

void
GiveHint (void)
{
	algbr ((short) (hint >> 8), (short) (hint & 0xFF), false);
	ui_ShowHint(mvstr[0]);
}

void
ChangeSearchDepth (void)
{
	int msd;
	ui_ChangeSearchDepth(&msd);
	MaxSearchDepth=(short)msd;
}


void
SetContempt (void)
{
	int c;
	ui_ChangeContempt(&c);
	contempt=(short)c;
}


/*
void
ChangeXwindow (void)
{
	ShowMessage ("xwndw= ");
	scanz ("%hd", &xwndw);
}
*/


void SelectLevel (char *sx)
{
	OperatorTime = 0;
	TCmoves = 60;
	TCminutes = 5;
	TCseconds = 0;

	int Level=1;
	ui_ChangeLevel(&Level);

	switch ((int) Level)
		{
		case 1:
			TCmoves = 60;
			TCminutes = 5;
			break;
		case 2:
			TCmoves = 60;
			TCminutes = 15;
			break;
		case 3:
			TCmoves = 60;
			TCminutes = 30;
			break;
		case 4:
			TCmoves = 40;
			TCminutes = 30;
			break;
		case 5:
			TCmoves = 40;
			TCminutes = 60;
			break;
		case 6:
			TCmoves = 40;
			TCminutes = 120;
			break;
		case 7:
			TCmoves = 40;
			TCminutes = 240;
			break;
		case 8:
			TCmoves = 1;
			TCminutes = 15;
			break;
		case 9:
			TCmoves = 1;
			TCminutes = 60;
			break;
		case 10:
			TCmoves = 1;
			TCminutes = 600;
			break;
		}

	TCflag = (TCmoves > 0);
	TimeControl.clock[white] = TimeControl.clock[black] = 0;
	SetTimeControl ();
	/*ClrScreen (); WHY?
	UpdateDisplay (0, 0, 1, 0);*/
}


void
DoDebug (void)
{
	short c, p, sq, tp, tc, tsq, score;
	char s[40];
	
	ExaminePosition ();

	ui_ChoosePiece(s);

	c = neutral;
	if (s[0] == 'w' || s[0] == 'W')
		c = white;
	if (s[0] == 'b' || s[0] == 'B')
		c = black;
	for(p = king; p > no_piece; p--)
		if ((s[1] == pxx[p]) || (s[1] == qxx[p]))
			break;
	for (sq = 0; sq < 64; sq++)
		{
			tp = board[sq];
			tc = color[sq];
			board[sq] = p;
			color[sq] = c;
			tsq = PieceList[c][1];
			PieceList[c][1] = sq;
			ShowPostnValue (sq);
			PieceList[c][1] = tsq;
			board[sq] = tp;
			color[sq] = tc;
		}
	score = ScorePosition (opponent);
	ShowScore (score);
}

void
// C header = TestSpeed(void (*f) (short int side, short int ply))
TestSpeed(void f(short int side, short int ply))
{
	short i;
	long t1, t2;

	t1 = time (0);
	for (i = 0; i < 10000; i++)
		{
			f (opponent, 2);
		}
	t2 = time (0);
	NodeCnt = 10000L * (TrPnt[3] - TrPnt[2]);
	evrate = NodeCnt / (t2 - t1);
	ShowNodeCnt (NodeCnt, evrate);
}


void
InputCommand (void)

/*
	Process the users command. If easy mode is OFF (the computer is thinking
	on opponents time) and the program is out of book, then make the 'hint'
	move on the board and call SelectMove() to find a response. The user
	terminates the search by entering ^C (quit siqnal) before entering a
	command. If the opponent does not make the hint move, then set Sdepth to
	zero.
*/

{
	short ok, tmp;
	unsigned short mv;
	char s[80];

	ok = flag.quit = false;
	player = opponent;
	//ShowSidetoMove ();	// Delayed until ready to GetMove
	ft = 0;
	if (hint > 0 && !flag.easy && Book == NULL)
		{
			fflush (stdout);
			time0 = time ((long *) 0);
			algbr ((short) hint >> 8, (short) hint & 0xFF, false);
			strcpy (s, mvstr[0]);
			tmp = epsquare;
			if (VerifyMove (s, 1, &mv))
				{
					ShowPrompt ();
					SelectMove (computer, 2);
					(void) VerifyMove (mvstr[0], 2, &mv);
					if (Sdepth > 0)
						Sdepth--;
				}
			ft = time ((long *) 0) - time0;
			epsquare = tmp;
		}
	signal (SIGINT, Die);
#ifndef MSDOS
	signal (SIGQUIT, Die);
#endif /* MSDOS */
	while (!(ok || flag.quit))
		{
			player = opponent;
			ShowSidetoMove();
			MoveList (opponent, 2); // For CalculateLegalMove
			ui_GetMove(s);
			ok = VerifyMove (s, 0, &mv);
			if (ok) {
				if (mv != hint) {
					Sdepth = 0;
					ft = 0;
				}
			} else if (*s == '\0')
				UpdateDisplay (0, 0, 1, 0);
			else if (strcmp (s, "bd") == 0) {
					/*ClrScreen ();*/
					UpdateDisplay (0, 0, 1, 0);
			} else if ((strcmp (s, "quit") == 0) || (strcmp (s, "exit") == 0))
				flag.quit = true;
			else if (strcmp (s, "post") == 0)
				flag.post = !flag.post;
			else if (strcmp (s, "edit") == 0)
				EditBoard ();
			else if (strcmp (s, "go") == 0)
				ok = true;
			else if (strcmp (s, "help") == 0)
				help ();
			else if (strcmp (s, "force") == 0)
				flag.force = !flag.force;
			else if (strcmp (s, "book") == 0)
				Book = NULL;
			else if (strcmp (s, "undo") == 0 && GameCnt > 0)
				Undo ();
			else if (strcmp (s, "new") == 0) {
				NewGame ();
				UpdateDisplay (0, 0, 1, 0);
			} else if (strcmp (s, "list") == 0)
				ListGame ();
			else if (strcmp (s, "level") == 0)
				SelectLevel ("");
			else if (strcmp (s, "hash") == 0)
				flag.hash = !flag.hash;
			else if (strcmp (s, "beep") == 0)
				flag.beep = !flag.beep;
/*
			else if (strcmp (s, "Awindow") == 0)
				ChangeAlphaWindow ();
			else if (strcmp (s, "Bwindow") == 0)
				ChangeBetaWindow ();
*/
			else if (strcmp (s, "hint") == 0)
				GiveHint ();
			else if (strcmp (s, "both") == 0) {
					flag.bothsides = !flag.bothsides;
					Sdepth = 0;
					SelectMove (opponent, 1);
					ok = true;
			} else if (strcmp (s, "reverse") == 0) {
					flag.reverse = !flag.reverse;
					/*ClrScreen ();*/
					UpdateDisplay (0, 0, 1, 0);
			}
#if !defined(MSDOS) || defined(SEVENBIT)
			else if (strcmp (s, "shade") == 0)
				ui_ToggleShade();
#endif /* MSDOS && !SEVENBIT */
			else if (strcmp (s, "switch") == 0) {
					computer = otherside[computer];
					opponent = otherside[opponent];
					flag.force = false;
					Sdepth = 0;
					ok = true;
			} else if (strcmp (s, "white") == 0) {
					computer = white;
					opponent = black;
					ok = true;
					flag.force = false;
					Sdepth = 0;
			} else if (strcmp (s, "black") == 0) {
					computer = black;
					opponent = white;
					ok = true;
					flag.force = false;
					Sdepth = 0;
			} else if (strcmp (s, "remove") == 0 && GameCnt > 1) {
					Undo ();
					Undo ();
			} else if (strcmp (s, "get") == 0)
				GetGame ();
			else if (strcmp (s, "save") == 0)
				SaveGame ();
			else if (strcmp (s, "depth") == 0)
				ChangeSearchDepth ();
			else if (strcmp (s, "random") == 0)
				dither = 6;
			else if (strcmp (s, "easy") == 0)
				flag.easy = !flag.easy;
			else if (strcmp (s, "contempt") == 0)
				SetContempt ();
/*
			else if (strcmp (s, "xwndw") == 0)
				ChangeXwindow ();
*/
			else if (strcmp (s, "coords") == 0) {
					coords = !coords;
					UpdateDisplay (0, 0, 1, 0);
			}
#if !defined(MSDOS) || defined(SEVENBIT)
			else if (strcmp (s, "stars") == 0)
				ui_ToggleStars();
#endif /* MSDOS && !SEVENBIT */
			else if (strcmp (s, "test") == 0) {
					ShowMessage("Testing MoveList Speed");
					TestSpeed (MoveList);
					ShowMessage("Testing CaptureList Speed");
					TestSpeed (CaptureList);
			} else if (strcmp (s, "p") == 0)
				ShowPostnValues ();
			else if (strcmp (s, "debug") == 0)
				DoDebug ();
			else if (strcmp (s, "rv") == 0)
				ui_ToggleRV();
			else
				ui_RejectMove(s);
		}

	ClearMessage ();
	ElapsedTime (1);
	if (flag.force)
		{
			computer = opponent;
			opponent = otherside[computer];
		}
	signal (SIGINT, TerminateSearch);
#ifndef MSDOS
	signal (SIGQUIT, TerminateSearch);
#endif /* MSDOS */
}

int NeedPromotion(int x, int y)
{
	int sq=locn(y,x);
	return ((color[sq]==white && y==6) || (color[sq]==black && y==1)) && board[sq]==pawn;
}

int RankAt(int x,int y)
{
	return board[locn(y,x)];
}

int ColourAt(int x,int y)
{
	return color[locn(y,x)];
}


static int Legal[8][8];

void CalculateLegalMoves(int x,int y)
// Fairly fast
{
	for (int i=0; i<8; i++)
		for (int j=0; j<8; j++)
			Legal[i][j]=0;

	int pnt = TrPnt[2];
	while (pnt < TrPnt[3]) {
		int f=Tree[pnt].f;
		int t=Tree[pnt].t;
		if (x==column(f) && y==row(f)) {
			Legal[column(t)][row(t)]=1;
		}
		pnt++;
	}
}

int LegalMove(int x, int y)
// Very fast
{
	return Legal[x][y];
}


void ClrScreen()
{
	ui_ClrScreen();
}
