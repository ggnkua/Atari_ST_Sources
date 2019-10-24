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

void CalculateLegalMoves(int x,int y);
int LegalMove(int x, int y);
void TerminateSearch (int);
int NeedPromotion(int,int);
int RankAt(int,int);
int ColourAt(int,int);
