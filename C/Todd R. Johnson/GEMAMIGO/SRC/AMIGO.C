/* Go started 4/17/88 by Todd R. Johnson */
/* 8/8/89 cleaned up for first release */
/* Public Domain */

#include "go.h"
#include "amigo.h"


extern char	*playReason;
extern short	playLevel, showTrees;

struct bRec	goboard[19][19];	/*-- The main go board		--*/

struct Group	GroupList[MAXGROUPS];	/*-- The list of Groups		--*/
short		DeletedGroups[4];	/*-- Codes of deleted groups	--*/

short		GroupCount = 0;		/*-- The total number of groups	--*/
short		DeletedGroupCount;	/*-- The total number of groups	--*/
					/*-- deleted on a move		--*/
short		ko, koX, koY;
short		blackTerritory,whiteTerritory;
short		blackPrisoners, whitePrisoners;
short		showMoveReason	= FALSE,
		groupInfo	= FALSE,
		whitePassed	= FALSE,
		blackPassed	= FALSE;


/* Arrays for use when checking around a point */
short		xVec[4] = {0, 1, 0, -1};
short		yVec[4] = {-1, 0, 1, 0};

short
member(group, grouplist, cnt)
	short		group;
	short		grouplist[4];
	short		cnt;
{
	unsigned short	i;


	for (i = 0; i < cnt; i++)
		if (grouplist[i] == group)
			return TRUE;
	return FALSE;
}

/* Does a stone at x, y connect to any groups of color? */
short
Connect( color, x, y, fGroups, fCnt, eGroups, eCnt)
	enum bVal	color;
	short		x, y;
	short		fGroups[4], eGroups[4];
	short		*fCnt, *eCnt;
{
	unsigned short	point = 0;
	short		tx, ty, total = 0;
	enum bVal	opcolor = WHITE;


	*fCnt = 0;
	*eCnt = 0;
	if (color == WHITE)
		opcolor = BLACK;
	for (point = 0; point <= 3; point++ )  
	{
		tx = x + xVec[point];
		ty = y + yVec[point];
		if (!LegalPoint(tx,ty))
			continue;
		if (goboard[tx][ty].Val == color)
		{
			total++;
			if (!member(goboard[tx][ty].GroupNum, fGroups, *fCnt))
				fGroups[(*fCnt)++] = goboard[tx][ty].GroupNum;
		}
		else if (goboard[tx][ty].Val == opcolor)
		{
			total++;
			if (!member(goboard[tx][ty].GroupNum, eGroups, *eCnt))
				eGroups[(*eCnt)++] = goboard[tx][ty].GroupNum;
		}
	}
	return total;
}

/* Returns the maximum number of liberties for a given intersection */
short
Maxlibs(x, y)
	short	x, y;
{
	short	cnt = 4;


	if (x == 0 || x == 18)
		cnt--;
	if (y == 0 || y == 18)
		cnt--;
	return cnt;
}

DeleteGroupFromStone(x,y)
	short	x,y;
{
	if (goboard[x][y].Val != EMPTY)
		GroupCapture(goboard[x][y].GroupNum);
}

/* Determine whether x, y is suicide for color */
short
Suicide(color, x, y)
	enum bVal	color;
	short		x, y;
{
	enum bVal	opcolor = BLACK;
	short		friendlycnt, friendlygroups[4],
			enemycnt, enemygroups[4],
			total;
	short		maxlibs, i, libcnt = 0;


	if (color == BLACK)
		opcolor = WHITE;
	maxlibs = Maxlibs( x, y);
	total = Connect(color, x, y, friendlygroups, &friendlycnt,
					enemygroups, &enemycnt);

	if (total < maxlibs)
		return FALSE;

	/* Check for a capture */
	for (i = 0; i < enemycnt; i++)
		if (GroupList[enemygroups[i]].liberties == 1)
			return FALSE;
	for (i = 0; i < friendlycnt; i++)
		libcnt += (GroupList[friendlygroups[i]].liberties - 1);
	if (libcnt != 0)
		return FALSE;
	return TRUE;
}
   
/* Returns the number of liberties for x, y */
short
StoneLibs(x, y)
	short		x, y;
{
	short		cnt = 0, tx, ty;
	unsigned short	point;


	for (point = 0; point <= 3; point++)
	{
		tx = x + xVec[point];
		ty = y + yVec[point];
		if (LegalPoint(tx,ty) && goboard[tx][ty].Val == EMPTY)
			cnt++;
	}
	return cnt;
}
   
void
EraseMarks()
{
	register short		i;
	register struct bRec	*gpt	= &goboard[0][0];


	for (i=0; i<361; gpt++,i++)
			gpt->marked = FALSE;
}

/* Place a stone of color at x, y */
short
GoPlaceStone(color, x, y)
	enum bVal	color;
	short		x, y;
{
	short	fgroups[4], egroups[4];	/* group codes surrounding stone */
	short	fcnt, ecnt, i;
	short	lowest = GroupCount + 1;


	DeletedGroupCount = 0;
	if (goboard[x][y].Val != EMPTY || Suicide(color,x,y))
		return FALSE;

	if (ko && koX == x && koY == y)
		return FALSE;

	ko = FALSE;
	placestone(color, x, y);
	goboard[x][y].Val = color;
	/* Does the new stone connect to any friendly stone(s)? */
	Connect(color, x, y, fgroups, &fcnt, egroups, &ecnt);
	if (fcnt)
	{
		/* Find the connecting friendly group with the lowest code */
		for (i = 0; i < fcnt; i++)
			if (fgroups[i] <= lowest)
				lowest = fgroups[i];
		/*-- Renumber resulting group --*/
		/*-- Raise the stone count of the lowest by one to account --*/
		/*-- for new stone --*/
		goboard[x][y].GroupNum = lowest;
		GroupList[lowest].count++;
		for (i = 0; i < fcnt; i++)
			if (fgroups[i] != lowest)
				MergeGroups(lowest, fgroups[i]);
		/* Fix the liberties of the resulting group */
		CountLiberties(lowest);
	}
	else
	{
		/* Isolated stone.  Create new group. */
		GroupCount++;
		lowest = GroupCount;
		GroupList[lowest].color = color;
		GroupList[lowest].count = 1;
		GroupList[lowest].internal = 0;
		GroupList[lowest].external = StoneLibs( x, y);
		GroupList[lowest].liberties = GroupList[lowest].external;
		GroupList[lowest].eyes = 0;
		GroupList[lowest].alive = 0;
		GroupList[lowest].territory = 0;
		goboard[x][y].GroupNum = lowest;
	}
	/* Now fix the liberties of enemy groups adjacent to played stone */
	FixLibs(color, x, y, PLACED);  /* Fix the liberties of opcolor */
	ReEvalGroups(color, x, y, lowest);
	RelabelGroups();
	return TRUE;
}

/* Remove a stone from the board */
void
GoRemoveStone(x, y)
	short	x, y;
{
	goboard[x][y].Val = EMPTY;
	goboard[x][y].GroupNum = 0;
	removestone( x, y);
}

/* Merges two groups -- Renumbers stones and deletes second group from
list.  Fixes stone count of groups.  This does not fix anything else. 
FixLibs must be called to fix liberties, etc. */
void
MergeGroups(g1, g2)
	short	g1, g2;
{
	short	x, y;


	ForeachPoint(y,x)
		if (goboard[x][y].GroupNum == g2)
			goboard[x][y].GroupNum = g1;
	GroupList[g1].count += GroupList[g2].count;
	DeleteGroup( g2 );  /* Removes group from GroupList */
}

/* Stores a group code to be deleted */
void
DeleteGroup(code)
	short	code;
{
	DeletedGroups[DeletedGroupCount++] = code;
}

/* Re-evaluate the groups given the last move.  This assumes that the
last move has been merged into adjoining groups and all liberty counts
are correct.  Handles capture. Checks for Ko.  Keeps track of captured
stones. code is the group number of the stone just played. */
void
ReEvalGroups(color, x, y, code)
	enum bVal	color;
	short		x, y, code;
{
	short		fgroups[4], egroups[4],
			fcnt, ecnt, i, killcnt = 0, count = 0;
	enum bVal	opcolor = BLACK;

	if (color == BLACK)
		opcolor = WHITE;
	/* Check for capture */
	Connect( color, x, y, fgroups, &fcnt, egroups, &ecnt);
	if (ecnt)
	{
		/* See if any of the groups have no liberties */
		for (i = 0; i < ecnt; i++)
			if (GroupList[egroups[i]].liberties == 0)
			{
				killcnt++;
				count = GroupList[egroups[i]].count;
				GroupCapture( egroups[i]);
			}
	}
	/* Check for ko.  koX and koY are set in GroupCapture above. */
	if (killcnt == 1 && count == 1 && GroupList[ code  ].count == 1
				&& GroupList[ code ].liberties == 1)
	{
		ko = TRUE;
	}
	if (killcnt)
		intrPrisonerReport( blackPrisoners, whitePrisoners);
	/* Set eye count for groups */
	CountEyes();
}

/* Remove a captured group from the board and fix the liberties of any
   adjacent groups.  Fixes prisoner count. Sets KoX and KoY */
/*-- update display of captured stones -neilb --*/
void
GroupCapture(code)
	short	code;
{
	short	x, y;

	if (GroupList[code].color == BLACK)
		blackPrisoners += GroupList[code].count;
	else
		whitePrisoners += GroupList[code].count;
	intrPrisonerReport(blackPrisoners, whitePrisoners);
	ForeachPoint(y,x)
		if (goboard[x][y].GroupNum == code)
		{
			FixLibs(GroupList[code].color,x,y,REMOVED);
			GoRemoveStone(x, y);
			koX = x;
			koY = y;
		}
	DeleteGroup( code);
}

/* Fix the liberties of groups adjacent to x, y.  move indicates
  whether a stone of color was placed or removed at x, y
  This does not change liberty counts of friendly groups when a stone
  is placed.  Does not do captures. */
void
FixLibs( color, x, y, move)
	enum	bVal color;
	short	x, y, move;
{
	short	fgroups[4], fcnt, egroups[4], ecnt, i;
	enum	bVal opcolor = BLACK;

	if (color == BLACK)
		opcolor = WHITE;
	Connect( color, x, y, fgroups, &fcnt, egroups, &ecnt);
	if (move == PLACED)
		for (i = 0; i < ecnt; i++)
			GroupList[egroups[i]].liberties--;
	else /* Stone removed so increment opcolor */
		for (i = 0; i < ecnt; i++)
			GroupList[egroups[i]].liberties++;
}

void
goSetHandicap(handicap)
{
	if (handicap < 2)
		return;

	GoPlaceStone(BLACK,3,3);
	GoPlaceStone(BLACK,15,15);

	if (handicap >= 3)
		GoPlaceStone(BLACK,15,3);
	if (handicap >= 4)
		GoPlaceStone(BLACK,3,15);
	if (handicap == 5 || handicap == 7 || handicap == 9)
		GoPlaceStone(BLACK,9,9);
	if (handicap >= 6)
	{
		GoPlaceStone(BLACK,15,9);
		GoPlaceStone(BLACK,3,9);
	}
	if (handicap >= 8)
	{
		GoPlaceStone(BLACK,9,15);
		GoPlaceStone(BLACK,9,3);
	}
}

void
goRestart(handicap)
	int	handicap;
{
	register short		i;
	register struct bRec	*gpt	= &goboard[0][0];


	GroupCount = 0;
	ko = FALSE;
	blackPrisoners = whitePrisoners = 0;
	intrPrisonerReport(0, 0);
	for (i=0; i<361; gpt++,i++)
	{
		gpt->Val = EMPTY;
		gpt->GroupNum = 0;
	}
	goSetHandicap(handicap);
}


/* if any groups have been deleted as a result of the last move, this
   routine will delete the old group numbers from GroupList and
   reassign group numbers. */
void
RelabelGroups()
{
	unsigned	short i, j, x, y;

	for (i = 0; i < DeletedGroupCount; i++)
	{
		/* Relabel all higher groups */
		ForeachPoint(y,x)
			if (goboard[x][y].GroupNum > DeletedGroups[i])
				goboard[x][y].GroupNum--;
		/* Move the groups down */
		for (y = DeletedGroups[i]; y < GroupCount; y++)
			GroupList[y] = GroupList[y+1];
		/* fix the group numbers stored in the deleted list */
		for (j = i+1; j < DeletedGroupCount; j++)
			if (DeletedGroups[j] > DeletedGroups[i])
				DeletedGroups[j]--;
		GroupCount--;
	}
}

/* Returns liberty count for x, y intersection.  Sets marked to true
   for each liberty */
short
CountAndMarkLibs( x, y)
	short	x, y;
{
	short	tx,ty,i;
	short	cnt = 0;


	for (i=0;i<4;i++)
	{
                tx = x + xVec[i];
                ty = y + yVec[i];
                if (LegalPoint(tx,ty) && goboard[tx][ty].Val == EMPTY
					&& goboard[tx][ty].marked == FALSE)
		{
			cnt++;
			goboard[tx][ty].marked = TRUE;
		}
	}
	return cnt;
}

/* Determine the number of liberties for a group given the group code
   num */
void
CountLiberties( code)
	short	code;
{
	short	x, y, libcnt = 0;

	ForeachPoint(y,x)
		if (goboard[x][y].GroupNum == code)
			libcnt += CountAndMarkLibs( x, y);
	EraseMarks();
	GroupList[code].liberties = libcnt;
}

void
CheckForEye( x, y, groups, cnt, recheck)
	short	x, y, groups[4], cnt, *recheck;
{
	short	i;

	for (i = 0; i < (cnt-1); i++)
		if (groups[i] != groups[i+1])
		{
			/* Mark liberty for false eye check */
			goboard[x][y].marked = TRUE;
			(*recheck)++;
			return;
		}
	/* It is an eye */
	GroupList[groups[i]].eyes += 1;
}
   
/* Set the eye count for the groups */
void CountEyes()
{
	short	i, x, y,
		wgroups[4], bgroups[4], wcnt, bcnt, max, cnt, recheck = 0, eye;

	for (i = 1; i <= GroupCount; i++)
		GroupList[i].eyes = 0;

	ForeachPoint(y,x)
	{
		if (goboard[x][y].Val != EMPTY)
			continue;
		cnt = Connect(WHITE,x,y,wgroups,&wcnt,bgroups,&bcnt);
		max = Maxlibs( x, y);
		if (cnt == max && wcnt == 1 && bcnt == 0)
			GroupList[wgroups[0]].eyes++;
		else if (cnt == max && bcnt == 1 && wcnt == 0)
			GroupList[bgroups[0]].eyes++;
		else if (cnt == max && ( bcnt == 0 || wcnt == 0 ))
		{
			goboard[x][y].marked = TRUE;
			recheck++;
		}
	}

	/*-- Now recheck marked liberties to see if two or more one eye --*/
	/*-- groups contribute to a false eye */
	if (recheck == 0)
		return;

	ForeachPoint(y,x)
		if (goboard[x][y].marked)
		{
			recheck--;
			goboard[x][y].marked = FALSE;
			Connect( WHITE, x, y, wgroups, &wcnt, bgroups, &bcnt);
			/* If all the groups have at least one eye then all the
			groups are safe from capture because of the common
			liberty at x, y */
			eye = TRUE;
			for (i = 0; i < wcnt; i++)
				if (GroupList[wgroups[i]].eyes == 0)
					eye = FALSE;
			if (eye)
				for (i = 0; i < wcnt; i++)
					GroupList[wgroups[i]].eyes++;
			for (i = 0; i < bcnt; i++)
				if (GroupList[bgroups[i]].eyes == 0)
					eye = FALSE;
			if (eye)
				for (i = 0; i < bcnt; i++)
					GroupList[bgroups[i]].eyes++;
			if (recheck == 0)
				return;
		}
}


short	foo[19][19];

/*----------------------------------------------------------------
-- CountUp()							--
--	Count up final scores at the end of the game.		--
----------------------------------------------------------------*/
CountUp()
{
	short	x,y;
	short	CountFromPoint();
	short	vv;
	int	btotal,wtotal;
	char	buff[512];


	blackTerritory = whiteTerritory = 0;
	ForeachPoint(y,x)
	{
		goboard[x][y].marked = FALSE;
		foo[x][y] = CNT_UNDECIDED;
	}
	ForeachPoint(y,x)
		if (goboard[x][y].Val==EMPTY && foo[x][y]==CNT_UNDECIDED)
		{
			FillPoints(x,y,CountFromPoint(x,y));
		}

	wtotal = whiteTerritory + blackPrisoners;
	btotal = blackTerritory + whitePrisoners;

	showresult(whiteTerritory,blackPrisoners,blackTerritory,whitePrisoners);

/* XXX
	sprintf(buff,"White : %3d territory + %3d prisoners = %d\n\
Black : %3d territory + %3d prisoners = %d\n\n%s.",
			whiteTerritory,blackPrisoners,wtotal,
			blackTerritory,whitePrisoners,btotal,
			(btotal>wtotal?"Black wins":(wtotal>btotal?"White wins":
			"A draw")));
	XtVaSetValues(message,XtNstring,buff,0);
*/
}

void FillPoints(x,y,val)
	short	x,y,val;
{
	int	i;
	short	tx,ty;


	if ((foo[x][y] = val) == CNT_BLACK_TERR)
		blackTerritory++;
	else if (val == CNT_WHITE_TERR)
		whiteTerritory++;
	for (i=0;i<4;i++)
	{
		tx = x + xVec[i];
		ty = y + yVec[i];
		if (!LegalPoint(tx,ty))
			continue;
		if (goboard[tx][ty].Val==EMPTY && foo[tx][ty]==CNT_UNDECIDED)
			FillPoints(tx,ty,val);
	}
}

short
CountFromPoint(x,y)
	short	x,y;
{
	int	i;
	short	tx,ty;
	short	blkcnt=0,whtcnt=0;
	short	baz;


	goboard[x][y].marked = TRUE;
	for (i=0;i<4;i++)
	{
		tx = x + xVec[i];
		ty = y + yVec[i];
		if (!LegalPoint(tx,ty))
			continue;
		if (goboard[tx][ty].Val == BLACK)
			blkcnt++;
		else if (goboard[tx][ty].Val == WHITE)
			whtcnt++;
		else
		{
			if (goboard[tx][ty].marked)
				continue;
			baz = CountFromPoint(tx,ty);
			if (baz == CNT_NOONE)
				return CNT_NOONE;
			else if (baz == CNT_BLACK_TERR)
				blkcnt++;
			else if (baz == CNT_WHITE_TERR)
				whtcnt++;
		}
		if (blkcnt && whtcnt)
			return CNT_NOONE;
	}
	if (blkcnt && !whtcnt)
		return CNT_BLACK_TERR;
	else if (whtcnt && !blkcnt)
		return CNT_WHITE_TERR;
	else
		return CNT_UNDECIDED;
}
