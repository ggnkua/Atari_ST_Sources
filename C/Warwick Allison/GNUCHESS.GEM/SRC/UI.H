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

#include <bool.h>
void ui_Initialize();
void ui_Finalize();
void ui_GiveHelp (int compiswhite,int level,int easy,int maxdep,int dither,int hash);
void ui_ShowEditHelp();
void ui_ShowEditColor(int col);
void ui_GetPieceAndLocation(char *s);
void ui_ShowPlayers(bool reverse,int CompIsBlack);
void ui_ShowDepth(int depth, char ch);
void ui_ShowScore(int score);
void ui_ShowMessage(char *msg);
void ui_ClearMessage();
void ui_ShowCurrentMove(int pnt, char *move);
void ui_ShowTitle();
void ui_ShowSideToMove(int movenum, int who);
void ui_PromptForMove();
void ui_ShowNodeCnt(long int NodeCnt, long int evrate);
void ui_ShowPlyMove(int ply,char *move);
void ui_NoMorePly(int ply);
void ui_SearchStartStuff(int side);
void ui_ShowComputerMove(char *move, int feature);
void ui_ShowMaxTree(int maxtree);
void ui_ShowClock(bool OnWhiteSide, int minutes, int seconds);
void ui_ClrScreen();
void ui_DrawPiece(bool used, bool isblack, int x, int y, int piece);
void ui_DrawSquare(int x, int y, bool isblack);
void ui_DrawCoords();
void ui_ShowPosnValue(short sq, int score);
void ui_GetFilename(char *prompt,char *name);
void ui_ShowFileLoading(char *name);
void ui_LoadDone();
void ui_LoadFailed();
void ui_ShowFileSaving(char *name);
void ui_SaveFailed();
void ui_SaveDone();
void ui_ChangeSearchDepth(int *newdepth);
void ui_ChangeContempt(int *newcontempt);
void ui_ChangeLevel(int *newlevel);
void ui_ChoosePiece(char *s);
void ui_GetMove(char *s);
void ui_PromptForMove();;
void ui_ToggleRV();
void ui_ToggleStars();
void ui_ToggleShade();
void ui_ClrScreen();;
int ui_AskAbort();
void ui_ClearEditHelp();
void ui_RefreshEarly();
void ui_ShowHint(char *move);
void ui_RejectMove(char *move);
extern char* DRAW; /* reason for draw. */
