/* The go player */
/* Ported from Pascal to C by Todd R. Johnson 4/17/88 */
/* From the original pascal file:
Go Move Generator
Copyright (c) 1983 by Three Rivers Computer Corp.

Written: January 17, 1983 by Stoney Ballard
Edit History:
*/

#include "go.h"
#include "amigo.h"
#include "goplayutils.h"

#define BIGGEST 32767	/* maximum value for short */

/* From go.c */
extern struct bRec goboard[19][19];
extern short ko, koX, koY;

/* From goplayutils.c */
extern intBoard bord;
extern intBoard ndbord;
extern intBoard claim;
extern intBoard legal;
extern intBoard connectMap;
extern intBoard threatBord;
extern short maxGroupID;
extern short treeLibLim;
extern short killFlag;
extern short depthLimit;
extern short showTrees;
extern short utilPlayLevel;
extern groupRec gList[maxGroup];
extern short sGlist[maxGroup + 1];
extern pointList pList;
extern pointList pList1;
extern pointList plist2;
extern pointList plist3;
extern intBoard groupIDs;
extern intBoard protPoints;
extern sType mySType;


short saveNLibs;
pointList dapList1, dapList2, dapList3;
char *playReason;
short maxPlayLevel = 7;
short playLevel = 7;

genBord(color)
	enum bVal	color;
{
	short		x, y, nomoves = TRUE;
	char		mv[8];

	maxPlayLevel = 7;
	utilPlayLevel = playLevel;
	mySType = color;
	if (playLevel < 2)
		treeLibLim = 2;
	else
		treeLibLim = 3;
	depthLimit = 100;
	for (y = 0; y <= 18; y++)
		for (x = 0; x <= 18; x++)
			if (goboard[x][y].Val == color)
			{
				bord[x][y] = 1;
				legal[x][y] = FALSE;
				nomoves = FALSE;
			}
			else if (goboard[x][y].Val == EMPTY)
			{
				bord[x][y] = 0;
				legal[x][y] = TRUE;
			}
			else
			{
				bord[x][y] = -1;
				legal[x][y] = FALSE;
				nomoves = FALSE;
			}
	if (ko)
	{
		legal[koX][koY] = FALSE;
	}

	if (! nomoves) 
		genState();
	else
		initGPUtils();
}


short getMove( x, y )
short *x, *y;
{
   if (takeCorner(x, y)) return TRUE;
   if (lookForSave(x, y)) return TRUE;
   if (lookForSaveN(x, y)) return TRUE;
   if (extend(x, y)) return TRUE;
   if (lookForKill(x, y)) return TRUE;
   if (doubleAtari(x, y)) return TRUE;
   if (lookForAttack(x, y)) return TRUE;
   if (threaten(x, y)) return TRUE;
   if (extend2(x, y)) return TRUE;
   if (connectCut(x, y)) return TRUE;
   if (blockCut(x, y)) return TRUE;
   if (cutHim(x, y)) return TRUE;
   if (extendWall(x, y)) return TRUE;
   if (findAttack2(x, y)) return TRUE;
   if (atariAnyway(x, y)) return TRUE;
   if (underCut(x, y)) return TRUE;
   if (dropToEdge(x, y)) return TRUE;
   if (pushWall(x, y)) return TRUE;
   if (reduceHisLiberties(x, y)) return TRUE;
   if (dropToEdge2(x, y)) return TRUE;
   return FALSE;
}

short genMove( color, x, y )
enum bVal color;
short *x, *y;
{
   if (playLevel > 2)
      saveNLibs = TRUE;
   else
      saveNLibs = FALSE;
   genBord(color);
   if (getMove(x, y))
      return TRUE;
   return FALSE;
}
   
short checkPos(x, y, field)
short x, y, field;
{
   short ok;
   ok = (((field == 0) && (claim[x][y] == 0)) ||
         ((field > 0) &&
	  (claim[x][y] >= 0) && (claim[x][y] <= field)) ||
	 ((field < 0) &&
	  (claim[x][y] <= 0) && (claim[x][y] >= field))) &&
	 (bord[x-1][y] == 0) &&
	 (bord[x+1][y] == 0) &&
	 (bord[x][y-1] == 0) &&
	 (bord[x][y+1] == 0);
   if (ok) return TRUE; else return FALSE;
}

short takeCorner( x, y )
short *x, *y;
{
   short field = -1, i;
   i = 18 - 3;
   playReason = "takeCorner";
   while (field != -4)
   {
      if (field == -1) field = 0;
      else if (field == 0) field = 4;
      else field = -4;
      if (checkPos(2, 3, field)) { *x = 2; *y = 3; return TRUE; }
      if (checkPos(3, 2, field)) { *x = 3; *y = 2; return TRUE; }
      if (checkPos(2, i, field)) { *x = 2; *y = i; return TRUE; }
      if (checkPos(3, i + 1, field)) { *x = 3; *y = i+1; return TRUE; }
      if (checkPos(i, i + 1, field)) { *x = i; *y = i+1; return TRUE; }
      if (checkPos(i + 1, i, field)) { *x = i+1; *y = i; return TRUE; }
      if (checkPos(i, 2, field)) { *x = i; *y = 2; return TRUE; }
      if (checkPos(i + 1, 3, field)) { *x = i+1; *y = 3; return TRUE; }
      if (checkPos(2, 4, field)) { *x = 2; *y = 4; return TRUE; }
      if (checkPos(4, 2, field)) { *x = 4; *y = 2; return TRUE; }
      if (checkPos(2, i - 1, field)) { *x = 2; *y = i-1; return TRUE; }
      if (checkPos(4, i + 1, field)) { *x = 4; *y = i+1; return TRUE; }
      if (checkPos(i - 1, i + 1, field)) { *x = i-1; *y = i+1; return TRUE; }
      if (checkPos(i + 1, i - 1, field)) { *x = i+1; *y = i-1; return TRUE; }
      if (checkPos(i + 1, 4, field)) { *x = i+1; *y = 4; return TRUE; }
      if (checkPos(i - 1, 2, field)) { *x = i-1; *y = 2; return TRUE; }
   }
   return FALSE;
}

printBoard(brd, name)
intBoard brd;
char *name;
{
   short x, y;
   printf( "%s\n", name );
   for (y = 0; y <= 18; y++)
   {
      for (x = 0; x <= 18; x++)
         printf("%d ", brd[x][y]);
      printf("\n");
   }
}

short noNbrs( x, y )
short x, y;
{
   if (x > 0 && bord[x-1][y] != 0) return FALSE;
   if (x < 18 && bord[x+1][y] != 0) return FALSE;
   if (y > 0 && bord[x][y-1] != 0) return FALSE;
   if (y < 18 && bord[x][y+1] != 0) return FALSE;
   return TRUE;
}

short extend(x, y)
short *x, *y;
{
   short i;
   playReason = "extend";
   for (i = 2; i <= 18-2; i++)
      if (claim[2][i] == 0 && noNbrs( 2, i ))
      {
         *x = 2;
	 *y = i;
	 return TRUE;
      }
   for (i = 2; i <= 18-2; i++)
      if (claim[i][18-2] == 0 && noNbrs( 2, i ))
      {
         *x = i;
	 *y = 18-2;
	 return TRUE;
      }
   for (i = 18-2; i >= 2; i--)
      if (claim[18-2][i] == 0 && noNbrs( 18-2, i ))
      {
         *x = 18-2;
	 *y = i;
	 return TRUE;
      }
   for (i = 18-2; i >= 2; i--)
      if (claim[i][2] == 0 && noNbrs( i, 2 ))
      {
         *x = i;
	 *y = 2;
	 return TRUE;
      }
   return FALSE;
}

short extend2( x, y )
short *x, *y;
{
   short i, lowest = BIGGEST, value;
   playReason = "extend2";
   for (i = 3; i <= 18-3; i++)
      if (legal[2][i])         /* if there is nobody there */
      {
          value = claim[2][i];     /* get influence */
          if ((value < 7) &&        /* a reasonable hole in my wall */
             (value > -5) &&       /* or a reasonable gap in his */
             (bord[2][i + 1] == 0) && /* not in contact with any stones */
             (bord[2][i - 1] == 0))
            if (value < lowest) 
              {
                lowest = value;     /* lowest gets the smallest value */
                *x = 2;              /* that was seen along all the 3-lines */
                *y = i;              /* x and y save that location */
              }
        }
   for (i = 3; i <= 18-3; i++)
      if (legal[i][2])
        {
          value = claim[i][2];
          if ((value < 7) &&
             (value > -5) && 
             (bord[i + 1][2] == 0) &&
             (bord[i - 1][2] == 0))
            if (value < lowest) 
              {
                lowest = value;
                *x = i;
                *y = 2;
              }
        }
   for (i = 18-3; i >= 3; i--)
      if (legal[18 - 2][i])
        {
          value = claim[18 - 2][i];
          if ((value < 7) &&
             (value > -5) && 
             (bord[18 - 2][i + 1] == 0) &&
             (bord[18 - 2][i - 1] == 0))
            if (value < lowest) 
              {
                lowest = value;
                *x = 18 - 2;
                *y = i;
              }
        }
   for (i = 3; i <= 18-3; i++)
      if (legal[i][18 - 2])
        {
          value = claim[i][18 - 2];
          if ((value < 7) &&
             (value > -5) && 
             (bord[i + 1][18 - 2] == 0) &&
             (bord[i - 1][18 - 2] == 0))
            if (value < lowest) 
              {
                lowest = value;
                *x = i;
                *y = 18 - 2;
              }
        }
   if (lowest == BIGGEST) return FALSE;
   return TRUE;
}

  /*
    check to see if I can save anything in atari
  */
short lookForSave(x, y)
short *x, *y;
  { /* lookForSave */
    short i;
    playReason = "lookForSave";
    for (i = 1; i <= maxGroupID; i++)       /* scan the group list */
        if ((gList[i].libC == 1) &&
           (ndbord[gList[i].lx][gList[i].ly] == 1))
              if (saveable(gList[i].lx, gList[i].ly, x, y)) /* see if I can save it */
                return TRUE;
    return FALSE;
  } /* lookForSave */

  /*
    check to see if I can save anything with n libs
  */
short lookForSaveN(x, y)
short *x, *y;
  { /* lookForSaveN */
    short i;
    if (saveNLibs)
      {
        playReason = "lookForSaveN";
        for (i = 1; i <= maxGroupID; i++)       /* scan the group list */
            if ((gList[i].libC > 1) &&
               (gList[i].libC <= treeLibLim) &&
               (ndbord[gList[i].lx][gList[i].ly] == 1))
                {
                  if (killable(gList[i].lx, gList[i].ly, x, y))
                    if (saveable(gList[i].lx, gList[i].ly, x, y)) /* see if I can save it */
                      return TRUE;
                }
      }
    return FALSE;
  } /* lookForSaveN */


/*----------------------------------------------------------------
-- lookForKill()						--
--	check to see if I can kill anything.			--
----------------------------------------------------------------*/
short
lookForKill(x, y)
	short	*x, *y;
{
	short	i;
	char	mv[8];

	playReason = "lookForKill";
	for (i = 1; i <= maxGroupID; i++)       /* scan the group list */
		if ((gList[i].libC == 1) &&
				(ndbord[gList[i].lx][gList[i].ly] == -1)) 
	{    /* we found a live enemy group with one liberty */
		/* find the liberty */
		spanGroup(gList[i].lx, gList[i].ly, &pList);
		*x = pList.p[1].px;
		*y = pList.p[1].py;
		if (legal[*x][*y])
		{
			return TRUE;
		}
	}
	return FALSE;
}

short doubleAtari(x, y)
short *x, *y;
  { /* doubleAtari */
    short i, j;
    playReason = "doubleAtari";
    for (i = 1; i <= maxGroupID - 1; i++)
        if ((gList[i].libC == 2) &&
           (ndbord[gList[i].lx][gList[i].ly] == -1)) /* found an atariable group of his */
          {
            spanGroup(gList[i].lx, gList[i].ly, &dapList1);
            for (j = i + 1; j <= maxGroupID; j++)
                if ((gList[j].libC == 2) &&
                   (ndbord[gList[j].lx][gList[j].ly] == -1))
                {
                  spanGroup(gList[j].lx, gList[j].ly, &dapList2);
                  intersectPlist(&dapList1, &dapList2, &dapList3);
                  if (dapList3.indx > 0)
                      if (legal[dapList3.p[1].px][dapList3.p[1].py])
                        {
                          tryPlay(dapList3.p[1].px, dapList3.p[1].py, 1);
                          if (gList[groupIDs[dapList3.p[1].px][
				dapList3.p[1].py]].libC > 1)
                            {
                              *x = dapList3.p[1].px;
                              *y = dapList3.p[1].py;
                              restoreState();
			      return TRUE;
                            }
                          restoreState();
                        }
                }
          } 
    return FALSE;
  } /* doubleAtari */

short lookForAttack(x, y)
short *x, *y;
  { /* lookForAttack */
    short tx, ty, i;
    playReason = "lookForAttack";
    for (i = 1; i <= maxGroupID; i++)       /* scan the group list */
        if ((! gList[i].isLive) &&
           (gList[i].libC > 1) &&
           (gList[i].libC <= (treeLibLim + 1)) &&
           (ndbord[gList[i].lx][gList[i].ly] == -1)) 
              {
                if (killable(gList[i].lx, gList[i].ly, &tx, &ty)) /* can we kill it? */
                  {
                    *x = tx;        /* yep - do so */
                    *y = ty;
                    return TRUE;
                  }
              }
    return FALSE;
  } /* lookForAttack */

  /*
    Plays a move that requires a response on the opponent's part
  */
short threaten(x, y)
short *x, *y;
  { /* threaten */
    short i, j, gx, gy, tNum;
    playReason = "threaten";
    initArray(threatBord);
    for (i = 1; i <= maxGroupID; i++)
        if ((! gList[i].isLive) &&
           (ndbord[gList[i].lx][gList[i].ly] == -1))
          {
            spanGroup(gList[i].lx, gList[i].ly, &pList);
            for (j = 1; j <= pList.indx; j++)
                if (legal[pList.p[j].px][pList.p[j].py])
                  {
                    tryPlay(pList.p[j].px, pList.p[j].py, 1);
                    if (gList[groupIDs[pList.p[j].px][pList.p[j].py]].libC > 1)
                      if (killable(gList[i].lx, gList[i].ly, &gx, &gy))
                        threatBord[pList.p[j].px][pList.p[j].py] += 1;
                    restoreState();
                  }
          }
    tNum = 0;
    for (i = 0; i <= maxPoint; i++)
      for (j = 0; j <= maxPoint; j++)
        if ((threatBord[i][j] > tNum) &&
           ((threatBord[i][j] > 1) ||
            (connectMap[i][j] > 0)))
          {
            tNum = threatBord[i][j];
            *x = i;
            *y = j;
          }
    if (tNum > 0) return TRUE;
    else return FALSE;
  } /* threaten */

  /*
    connects against enemy cuts
  */
short connectCut(x, y)
short *x, *y;
  { /* connectCut */
    short i, j, nap, gid, infl;
    playReason = "connectCut";
    for (i = 0; i <= maxPoint; i++)
      for (j = 0; j <= maxPoint; j++)
        if (legal[i][j] &&
           (protPoints[i][j] == 0))   /* not a protected point */
          {
            nap = 0;     /* how many of my stones am I adjacent to? */
            if ((i > 0) && (bord[i - 1][j] == 1))
              {
                nap = nap + 1;
                pList.p[nap].px = i - 1;
                pList.p[nap].py = j;
              }
            if ((j > 0) && (bord[i][j - 1] == 1))
              {
                nap = nap + 1;
                pList.p[nap].px = i;
                pList.p[nap].py = j - 1;
              }
            if ((i < maxPoint) && (bord[i + 1][j] == 1))
              {
                nap = nap + 1;
                pList.p[nap].px = i + 1;
                pList.p[nap].py = j;
              }
            if ((j < maxPoint) && (bord[i][j + 1] == 1))
              {
                nap = nap + 1;
                pList.p[nap].px = i;
                pList.p[nap].py = j + 1;
              }
            if (nap == 1) /* possible knight's || 2-point extention */
                {
                  gid = groupIDs[pList.p[1].px][pList.p[1].py];
                  if ((i > 0) && (i < maxPoint) &&
                     (ndbord[i - 1][j] == 1) &&
                     (ndbord[i + 1][j] == 0)) /* contact on left */
                    {
                      if (((j > 0) && (ndbord[i][j - 1] == -1) &&
                          (ndbord[i + 1][j - 1] == 1) &&
                          (gid != groupIDs[i + 1][j - 1])) ||
                         ((j < maxPoint) && (ndbord[i][j + 1] == -1) &&
                          (ndbord[i + 1][j + 1] == 1) &&
                          (gid != groupIDs[i + 1][j + 1])) ||
                         ((((j > 0) && (ndbord[i][j - 1] == -1)) ||
                           ((j < maxPoint) && (ndbord[i][j + 1] == -1))) &&
                          (i < (maxPoint - 1)) &&
                          (ndbord[i + 2][j] == 1) &&
                          (gid != groupIDs[i + 2][j])))
                        {
                          *x = i;
                          *y = j;
                          if (safeMove(*x, *y))
                            return TRUE;
                        }
                    }
                  else if ((i < maxPoint) && (i > 0) &&
                          (ndbord[i + 1][j] == 1) &&
                          (ndbord[i - 1][j] == 0)) /* r */
                    {
                      if (((j > 0) && (ndbord[i][j - 1] == -1) &&
                          (ndbord[i - 1][j - 1] == 1) &&
                          (gid != groupIDs[i - 1][j - 1])) ||
                         ((j < maxPoint) && (ndbord[i][j + 1] == -1) &&
                          (ndbord[i - 1][j + 1] == 1) &&
                          (gid != groupIDs[i - 1][j + 1])) ||
                         ((((j > 0) && (ndbord[i][j - 1] == -1)) ||
                           ((j < maxPoint) && (ndbord[i][j + 1] == -1))) &&
                          (i > 1) &&
                          (ndbord[i - 2][j] == 1) &&
                          (gid != groupIDs[i - 2][j])))
                        {
                          *x = i;
                          *y = j;
                          if (safeMove(*x, *y))
                            return TRUE;
                        }
                    }
                  else if ((j > 0) && (j < maxPoint) &&
                          (ndbord[i][j - 1] == 1) &&
                          (ndbord[i][j + 1] == 0)) /* top */
                    {
                      if (((i > 0) && (ndbord[i - 1][j] == -1) &&
                          (ndbord[i - 1][j + 1] == 1) &&
                          (gid != groupIDs[i - 1][j + 1])) ||
                         ((i < maxPoint) && (ndbord[i + 1][j] == -1) &&
                          (ndbord[i + 1][j + 1] == 1) &&
                          (gid != groupIDs[i + 1][j + 1])) ||
                         ((((i > 0) && (ndbord[i - 1][j] == -1)) ||
                           ((i < maxPoint) && (ndbord[i + 1][j] == -1))) &&
                          (j < (maxPoint - 1)) &&
                          (ndbord[i][j + 2] == 1) &&
                          (gid != groupIDs[i][j + 2])))
                        {
                          *x = i;
                          *y = j;
                          if (safeMove(*x, *y))
                            return TRUE;
                        }
                    }
                  else if ((j > 0) && (j < maxPoint) &&
                          (ndbord[i][j + 1] == 1) &&
                          (ndbord[i][j - 1] == 0)) /* bottom */
                    {
                      if (((i > 0) && (ndbord[i - 1][j] == -1) &&
                          (ndbord[i - 1][j - 1] == 1) &&
                          (gid != groupIDs[i - 1][j - 1])) ||
                         ((i < maxPoint) && (ndbord[i + 1][j] == -1) &&
                          (ndbord[i + 1][j - 1] == 1) &&
                          (gid != groupIDs[i + 1][j - 1])) ||
                         ((((i > 0) && (ndbord[i - 1][j] == -1)) ||
                           ((i < maxPoint) && (ndbord[i + 1][j] == -1))) &&
                          (j > 1) &&
                          (ndbord[i][j - 2] == 1) &&
                          (gid != groupIDs[i][j - 2])))
                        {
                          *x = i;
                          *y = j;
                          if (safeMove(*x, *y))
                            return TRUE;
                        }
                    }
                }
            else if (nap == 2) /* diagonal or 1-point extention */
              {
                if (groupIDs[pList.p[1].px][pList.p[1].py] !=
                   groupIDs[pList.p[2].px][pList.p[2].py])
                  {
                    if ((pList.p[1].px != pList.p[2].px) &&
                       (pList.p[1].py != pList.p[2].py)) /* diag */
                      {
                        spanGroup(pList.p[1].px,
                                  pList.p[1].py, &pList1);
                        spanGroup(pList.p[2].px,
                                  pList.p[2].py, &plist2);
                        intersectPlist(&pList1, &plist2, &plist3);
                        if (plist3.indx == 1)
                          if ((i > 0) && (ndbord[i - 1][j] == -1) ||
                             (i < maxPoint) && (ndbord[i + 1][j] == -1) ||
                             (j > 0) && (ndbord[i][j - 1] == -1) ||
                             (j < maxPoint) && (ndbord[i][j + 1] == -1))
                            { /* must make direct connection */
                              *x = i;
                              *y = j;
                              if (heCanCut(*x, *y))
                                if (safeMove(*x, *y))
                                  return TRUE;
                            }
                          else if (heCanCut(i, j))
                            {     /* protect point if possible */
                              infl = 1000;
                              if ((i > 0) && legal[i - 1][j] &&
                                 ((i == 1) || (ndbord[i - 2][j] == 0)) &&
                                 ((j == 0) || (ndbord[i - 1][j - 1] == 0)) &&
                                 ((j == maxPoint) ||
                                  (ndbord[i - 1][j + 1] == 0)))
                                if (safeMove(i - 1, j))
                                  if (claim[i - 1][j] < infl)
                                    {
                                      *x = i - 1;
                                      *y = j;
                                      infl = claim[i - 1][j];
                                    }
                              if ((j > 0) && legal[i][j - 1] &&
                                 ((j == 1) || (ndbord[i][j - 2] == 0)) &&
                                 ((i == 0) || (ndbord[i - 1][j - 1] == 0)) &&
                                 ((i == maxPoint) ||
                                  (ndbord[i + 1][j - 1] == 0)))
                                if (safeMove(i, j - 1))
                                  if (claim[i][j - 1] < infl)
                                    {
                                      *x = i;
                                      *y = j - 1;
                                      infl = claim[i][j - 1];
                                    }
                              if ((i < maxPoint) && legal[i + 1][j] &&
                                 ((i == (maxPoint - 1)) ||
                                  (ndbord[i + 2][j] == 0)) &&
                                 ((j == 0) || (ndbord[i + 1][j - 1] == 0)) &&
                                 ((j == maxPoint) ||
                                  (ndbord[i + 1][j + 1] == 0)))
                                if (safeMove(i + 1, j))
                                  if (claim[i + 1][j] < infl)
                                    {
                                      *x = i + 1;
                                      *y = j;
                                      infl = claim[i + 1][j];
                                    }
                              if ((j < maxPoint) && legal[i][j + 1] &&
                                 ((j == (maxPoint - 1)) ||
                                  (ndbord[i][j + 2] == 0)) &&
                                 ((i == 0) || (ndbord[i - 1][j + 1] == 0)) &&
                                 ((i == maxPoint) ||
                                  (ndbord[i + 1][j + 1] == 0)))
                                if (safeMove(i, j + 1))
                                  if (claim[i][j + 1] < infl)
                                    {
                                      *x = i;
                                      *y = j + 1;
                                      infl = claim[i][j + 1];
                                    }
                              if (infl < 1000)
                                return TRUE;
                              *x = i;      /* direct connection */
                              *y = j;
                              if (safeMove(*x, *y))
                                return TRUE;
                            }
                      }
                    else /* 1-point extension, only protect if threatened */
                      {
                        if ((i > 0) && (ndbord[i - 1][j] == -1) ||
                           (j > 0) && (ndbord[i][j - 1] == -1) ||
                           (i < maxPoint) && (ndbord[i + 1][j] == -1) ||
                           (j < maxPoint) && (ndbord[i][j + 1] == -1))
                          {
                            *x = i;
                            *y = j;
                            if (heCanCut(*x, *y))
                              if (safeMove(*x, *y))
                                return TRUE;
                          }
                      }
                  }
              }
            else if (nap == 3) /* unprotected, but me on 3 sides */
              {
                if ((groupIDs[pList.p[1].px][pList.p[1].py] !=
                    groupIDs[pList.p[2].px][pList.p[2].py]) ||
                   (groupIDs[pList.p[1].px][pList.p[1].py] !=
                    groupIDs[pList.p[3].px][pList.p[3].py]) ||
                   (groupIDs[pList.p[3].px][pList.p[3].py] !=
                    groupIDs[pList.p[2].px][pList.p[2].py]))
                  {
                    spanGroup(pList.p[1].px, pList.p[1].py, &pList1);
                    spanGroup(pList.p[2].px, pList.p[2].py, &plist2);
                    intersectPlist(&pList1, &plist2, &plist3);
                    spanGroup(pList.p[3].px, pList.p[3].py, &plist2);
                    intersectPlist(&plist2, &plist3, &pList1);
                    if (pList1.indx == 1) /* a common connect point */
                      if (heCanCut(i, j))
                        if (safeMove(i, j))
                          {
                            *x = i;
                            *y = j;
                            return TRUE;
                          }
                  }
              }
          }
    return FALSE;
  } /* connectCut */

short heCanCut(x, y)
short x, y;
  { /* heCanCut */
    short gx, gy, result;
    if (playLevel > 3)
      {
        tryPlay(x, y, -1);  /* try his cut */
        result = ! killable(x, y, &gx, &gy);
        restoreState();
        return result;
      }
    else
      return FALSE;
  } /* heCanCut */

  /*
    Checks out a move.
    If my stone is not killable then true.
  */
short safeMove(x, y)
short x, y;
  { /* safeMove */
    short gbx, gby, result;
    tryPlay(x, y, 1);              /* try playing at point */
    if (killFlag) /* I shouldn't kill if lookForKill didn't */
      result = FALSE;
    else if (gList[groupIDs[x][y]].libC < 2)
      {                   /* if it is in atari or dead */
        result = FALSE;      /* reject it */
      }
    else if (gList[groupIDs[x][y]].libC <= treeLibLim) /* see if killable */
      if (playLevel > 0)
        result = ! killable(x, y, &gbx, &gby);
      else
        result = TRUE;
    else
      result = TRUE;
    restoreState();
    return result;
  } /* safeMove */

  /*
    Extends walls in a connected fashion.
    Finds the lowest influence (mine) point that is connected to one
    of my groups.
    Only looks in the center of the board.
  */
short extendWall(x, y)
short *x, *y;
  { /* extendWall */
    short infl, i, j;
    playReason = "extendWall";
    *x = iNil;
    *y = iNil;
    infl = 11;
    for (i = 2; i <= maxPoint - 2; i++)
      for (j = 2; j <= maxPoint - 2; j++)
        if (legal[i][j])
          if (connectMap[i][j] > 0)
            if ((claim[i][j] < infl) &&
               (ndbord[i - 1][j] < 1) &&
               (ndbord[i + 1][j] < 1) &&
               (ndbord[i][j - 1] < 1) &&
               (ndbord[i][j + 1] < 1) &&
               ((claim[i - 1][j] < 0) ||
                (claim[i + 1][j] < 0) ||
                (claim[i][j - 1] < 0) ||
                (claim[i][j + 1] < 0)))
              if (safeMove(i, j))
                {
                  infl = claim[i][j];
                  *x = i;
                  *y = j;
                }
    if (*x != iNil) return TRUE;
    return FALSE;
  } /* extendWall */


  /*
    check to see if I can attack one of his groups
    uses limited depth search so that it can work on larger lib counts
  */
short findAttack2(x, y)
short *x, *y;
  { /* findAttack2 */
    short tx, ty, i, otll;
    if (playLevel < 7)
      return FALSE;
    playReason = "findAttack2";
    depthLimit = 8;
    otll = treeLibLim;
    for (i = 1; i <= maxGroupID; i++)       /* scan the group list */
        if ((! gList[i].isLive) &&
           (ndbord[gList[i].lx][gList[i].ly] == -1) &&
           (gList[i].libC > 1))
              {
                treeLibLim = 6;
                if (killable(gList[i].lx, gList[i].ly, &tx, &ty)) /* can we kill it? */
                  {
                    *x = tx;        /* yep - do so */
                    *y = ty;
                    return TRUE;
                  }
                treeLibLim = otll;
              }
    depthLimit = 100;
    return FALSE;
  } /* findAttack2 */


  /*
    blocks enemy cuts thru 1-point extensions
  */
short blockCut(x, y)
short *x, *y;
  { /* blockCut */
    short i, j;
    playReason = "blockCut";
    for (i = 0; i <= maxPoint; i++)
      for (j = 0; j <= maxPoint; j++)
        if (legal[i][j])
          {
            if ((i > 0) && (j > 0) && (j < maxPoint))
              {
                if ((ndbord[i - 1][j] == -1) &&
                   (ndbord[i - 1][j - 1] == 1) &&
                   (ndbord[i - 1][j + 1] == 1) &&
                   (groupIDs[i - 1][j - 1] != groupIDs[i - 1][j + 1]))
                  {
                    *x = i;
                    *y = j;
                    if (heCanCut(*x, *y))
                      if (safeMove(*x, *y))
                        return TRUE;
                  }
              }
            if ((i < maxPoint) && (j > 0) && (j < maxPoint))
              {
                if ((ndbord[i + 1][j] == -1) &&
                   (ndbord[i + 1][j - 1] == 1) &&
                   (ndbord[i + 1][j + 1] == 1) &&
                   (groupIDs[i + 1][j - 1] != groupIDs[i + 1][j + 1]))
                  {
                    *x = i;
                    *y = j;
                    if (heCanCut(*x, *y))
                      if (safeMove(*x, *y))
                        return TRUE;
                  }
              }
            if ((j > 0) && (i > 0) && (i < maxPoint))
              {
                if ((ndbord[i][j - 1] == -1) &&
                   (ndbord[i - 1][j - 1] == 1) &&
                   (ndbord[i + 1][j - 1] == 1) &&
                   (groupIDs[i - 1][j - 1] != groupIDs[i + 1][j - 1]))
                  {
                    *x = i;
                    *y = j;
                    if (heCanCut(*x, *y))
                      if (safeMove(*x, *y))
                        return TRUE;
                  }
              }
            if ((j < maxPoint) && (i > 0) && (i < maxPoint))
              {
                if ((ndbord[i][j + 1] == -1) &&
                   (ndbord[i - 1][j + 1] == 1) &&
                   (ndbord[i + 1][j + 1] == 1) &&
                   (groupIDs[i - 1][j + 1] != groupIDs[i + 1][j + 1]))
                  {
                   *x = i;
                   *y = j;
                    if (heCanCut(*x, *y))
                      if (safeMove(*x, *y))
                        return TRUE;
                  }
              }
          }
    return FALSE;
  } /* blockCut */


  /*
    cuts the enemy
  */
short cutHim(x, y)
short *x, *y;
  { /* cutHim */
    short i, j, nap, gid;
    playReason = "cutHim";
    for (i = 0; i <= maxPoint; i++)
      for (j = 0; j <= maxPoint; j++)
        if (legal[i][j])
          {
            nap = 0;     /* how many of his stones am I adjacent to? */
            if ((i > 0) && (ndbord[i - 1][j] == -1))
              {
                nap = nap + 1;
                pList.p[nap].px = i - 1;
                pList.p[nap].py = j;
              }
            if ((j > 0) && (ndbord[i][j - 1] == -1))
              {
                nap = nap + 1;
                pList.p[nap].px = i;
                pList.p[nap].py = j - 1;
              }
            if ((i < maxPoint) && (ndbord[i + 1][j] == -1))
              {
                nap = nap + 1;
                pList.p[nap].px = i + 1;
                pList.p[nap].py = j;
              }
            if ((j < maxPoint) && (ndbord[i][j + 1] == -1))
              {
                nap = nap + 1;
                pList.p[nap].px = i;
                pList.p[nap].py = j + 1;
              }
            if (nap == 1) /* possible knight's or 2-point extention */
                {
                  gid = groupIDs[pList.p[1].px][pList.p[1].py];
                  if ((i > 0) && (i < maxPoint) &&
                     (ndbord[i - 1][j] == -1) &&
                     (connectMap[i][j] > 0)) /* contact on left */
                    {
                      if (((j > 0) &&
                          (ndbord[i + 1][j - 1] == -1) &&
                          (gid != groupIDs[i + 1][j - 1])) ||
                         ((j < maxPoint) &&
                          (ndbord[i + 1][j + 1] == -1) &&
                          (gid != groupIDs[i + 1][j + 1])) ||
                         ((i < (maxPoint - 1)) &&
                          (ndbord[i + 1][j] == 0) &&
                          (ndbord[i + 2][j] == -1) &&
                          (gid != groupIDs[i + 2][j])))
                        {
                          *x = i;
                          *y = j;
                          if (safeMove(*x, *y))
                            return TRUE;
                        }
                    }
                  else if ((i < maxPoint) && (i > 0) &&
                          (ndbord[i + 1][j] == -1) &&
                          (connectMap[i][j] > 0)) /* r */
                    {
                      if (((j > 0) &&
                          (ndbord[i - 1][j - 1] == -1) &&
                          (gid != groupIDs[i - 1][j - 1])) ||
                         ((j < maxPoint) &&
                          (ndbord[i - 1][j + 1] == -1) &&
                          (gid != groupIDs[i - 1][j + 1])) ||
                         ((i > 1) &&
                          (ndbord[i - 1][j] == 0) &&
                          (ndbord[i - 2][j] == -1) &&
                          (gid != groupIDs[i - 2][j])))
                        {
                          *x = i;
                          *y = j;
                          if (safeMove(*x, *y))
                            return TRUE;
                        }
                    }
                  else if ((j > 0) && (j < maxPoint) &&
                          (ndbord[i][j - 1] == -1) &&
                          (connectMap[i][j] > 0)) /* top */
                    {
                      if (((i > 0) &&
                          (ndbord[i - 1][j + 1] == -1) &&
                          (gid != groupIDs[i - 1][j + 1])) ||
                         ((i < maxPoint) &&
                          (ndbord[i + 1][j + 1] == -1) &&
                          (gid != groupIDs[i + 1][j + 1])) ||
                         ((j < (maxPoint - 1)) &&
                          (ndbord[i][j + 1] == 0) &&
                          (ndbord[i][j + 2] == -1) &&
                          (gid != groupIDs[i][j + 2])))
                        {
                          *x = i;
                          *y = j;
                          if (safeMove(*x, *y))
                            return TRUE;
                        }
                    }
                  else if ((j > 0) && (j < maxPoint) &&
                          (ndbord[i][j + 1] == -1) &&
                          (connectMap[i][j] > 0)) /* bottom */
                    {
                      if (((i > 0) &&
                          (ndbord[i - 1][j - 1] == -1) &&
                          (gid != groupIDs[i - 1][j - 1])) ||
                         ((i < maxPoint) &&
                          (ndbord[i + 1][j - 1] == -1) &&
                          (gid != groupIDs[i + 1][j - 1])) ||
                         ((j > 1) &&
                          (ndbord[i][j - 1] == 0) &&
                          (ndbord[i][j - 2] == -1) &&
                          (gid != groupIDs[i][j - 2])))
                        {
                          *x = i;
                          *y = j;
                          if (safeMove(*x, *y))
                            return TRUE;
                        }
                    }
                }
            else if (nap == 2) /* diagonal or 1-point extention */
              {
                if (groupIDs[pList.p[1].px][pList.p[1].py] !=
                   groupIDs[pList.p[2].px][pList.p[2].py])
                  {
                    if ((pList.p[1].px != pList.p[2].px) &&
                       (pList.p[1].py != pList.p[2].py)) /* diag */
                      {
                        spanGroup(pList.p[1].px,
                                  pList.p[1].py, &pList1);
                        spanGroup(pList.p[2].px,
                                  pList.p[2].py, &plist2);
                        intersectPlist(&pList1, &plist2, &plist3);
                        if (plist3.indx == 1)
                          {
                            *x = i;
                            *y = j;
                            if (safeMove(*x, *y))
                              return TRUE;
                          }
                      }
                    else /* 1-point extension, only cut if connected */
                      {
                        if (connectMap[i][j] > 0)
                          {
                            *x = i;
                            *y = j;
                            if (safeMove(*x, *y))
                              return TRUE;
                          }
                      }
                  }
              }
            else if (nap == 3) /* unprotected, but him on 3 sides */
              {
                if ((groupIDs[pList.p[1].px][pList.p[1].py] !=
                    groupIDs[pList.p[2].px][pList.p[2].py]) ||
                   (groupIDs[pList.p[1].px][pList.p[1].py] !=
                    groupIDs[pList.p[3].px][pList.p[3].py]) ||
                   (groupIDs[pList.p[3].px][pList.p[3].py] !=
                    groupIDs[pList.p[2].px][pList.p[2].py]))
                  {
                    spanGroup(pList.p[1].px, pList.p[1].py, &pList1);
                    spanGroup(pList.p[2].px, pList.p[2].py, &plist2);
                    intersectPlist(&pList1, &plist2, &plist3);
                    spanGroup(pList.p[3].px, pList.p[3].py, &plist2);
                    intersectPlist(&plist2, &plist3, &pList1);
                    if (pList1.indx == 1) /* a common connect point */
                      if (safeMove(i, j))
                        {
                          *x = i;
                          *y = j;
                          return TRUE;
                        }
                  }
              }
          }
    return FALSE;
  } /* cutHim */


  /*
    ataris a group just for the hell of it
  */
short atariAnyway(x, y)
short *x, *y;
  { /* atariAnyway */
    short i;
    playReason = "atariAnyway";
    for (i = 1; i <= maxGroupID; i++)       /* scan the group list */
        if ((gList[i].libC == 2) &&
           (ndbord[gList[i].lx][gList[i].ly] == -1)) 
              {
                spanGroup(gList[i].lx, gList[i].ly, &pList);
                  if (legal[pList.p[1].px][pList.p[1].py] &&
                     ((connectMap[pList.p[1].px][pList.p[1].py] > 0) ||
                      ((pList.p[1].px > 0) &&
		       (connectMap[pList.p[1].px - 1][pList.p[1].py] > 0)) ||
                      ((pList.p[1].px < maxPoint) &&
		       (connectMap[pList.p[1].px + 1][pList.p[1].py] > 0)) ||
                      ((pList.p[1].py > 0) &&
		       (connectMap[pList.p[1].px][pList.p[1].py - 1] > 0)) ||
                      ((pList.p[1].py < maxPoint) &&
		       (connectMap[pList.p[1].px][pList.p[1].py + 1] > 0))))
                    if (safeMove(pList.p[1].px, pList.p[1].py))
                      {
                        *x = pList.p[1].px;
                        *y = pList.p[1].py;
                        return TRUE;
                      }
                  if (legal[pList.p[2].px][pList.p[2].py] &&
                     ((connectMap[pList.p[2].px][pList.p[2].py] > 0) ||
                      ((pList.p[2].px > 0) &&
		       (connectMap[pList.p[2].px - 1][pList.p[2].py] > 0)) ||
                      ((pList.p[2].px < maxPoint) &&
		       (connectMap[pList.p[2].px + 1][pList.p[2].py] > 0)) ||
                      ((pList.p[2].py > 0) &&
		       (connectMap[pList.p[2].px][pList.p[2].py - 1] > 0)) ||
                      ((pList.p[2].py < maxPoint) &&
		       (connectMap[pList.p[2].px][pList.p[2].py + 1] > 0))))
                    if (safeMove(pList.p[2].px, pList.p[2].py))
                      {
                        *x = pList.p[2].px;
                        *y = pList.p[2].py;
                        return TRUE;
                      }
              }
    return FALSE;
  } /* atariAnyway */


  /*
    undercuts his groups
  */
short underCut(x, y)
short *x, *y;
  { /* underCut */
    short i, j;
    playReason = "underCut";
    for (i = 1; i <= maxPoint - 1; i++)
      {
        if (legal[0][i])
          {
            if (ndbord[1][i] == -1)
              if (safeMove(0, i))
                {
                  *x = 0;
                  *y = i;
                  return TRUE;
                }
          }
        if (legal[maxPoint][i])
          {
            if (ndbord[maxPoint - 1][i] == -1)
              if (safeMove(maxPoint, i))
                {
                  *x = maxPoint;
                  *y = i;
                  return TRUE;
                }
          }
        if (legal[i][0])
          {
            if (ndbord[i][1] == -1)
              if (safeMove(i, 0))
                {
                  *x = i;
                  *y = 0;
                  return TRUE;
                }
          }
        if (legal[i][maxPoint])
          {
            if (ndbord[i][maxPoint - 1] == -1)
              if (safeMove(i, maxPoint))
                {
                  *x = i;
                  *y = maxPoint;
                  return TRUE;
                }
          }
      }
    return FALSE;
  } /* underCut */

  /*
    drops to the edge of the board if threatened
  */
short dropToEdge(x, y)
short *x, *y;
  { /* dropToEdge */
    short i;
    playReason = "dropToEdge";
    for (i = 1; i <= maxPoint - 1; i++)
      {
        if (legal[1][i])
          if ((ndbord[2][i] == 1) &&
             (ndbord[0][i] == 0) &&
             (ndbord[1][i - 1] < 1) &&
             (ndbord[1][i + 1] < 1) &&
             ((ndbord[2][i - 1] == -1) ||
              (ndbord[2][i + 1] == -1) ||
              (ndbord[1][i - 1] == -1) ||
              (ndbord[1][i + 1] == -1)))
            {
              *x = 1;
              *y = i;
              if (safeMove(*x, *y))
                return TRUE;
            }
        if (legal[maxPoint - 1][i])
          if ((ndbord[maxPoint - 2][i] == 1) &&
             (ndbord[maxPoint][i] == 0) &&
             (ndbord[maxPoint - 1][i - 1] < 1) &&
             (ndbord[maxPoint - 1][i + 1] < 1) &&
             ((ndbord[maxPoint - 2][i - 1] == -1) ||
              (ndbord[maxPoint - 2][i + 1] == -1) ||
              (ndbord[maxPoint - 1][i - 1] == -1) ||
              (ndbord[maxPoint - 1][i + 1] == -1)))
            {
              *x = maxPoint - 1;
              *y = i;
              if (safeMove(*x, *y))
                return TRUE;
            }
        if (legal[i][1])
          if ((ndbord[i][2] == 1) &&
             (ndbord[i][0] == 0) &&
             (ndbord[i - 1][1] < 1) &&
             (ndbord[i + 1][1] < 1) &&
             ((ndbord[i - 1][2] == -1) ||
              (ndbord[i + 1][2] == -1) ||
              (ndbord[i - 1][1] == -1) ||
              (ndbord[i + 1][1] == -1)))
            {
              *x = i;
              *y = 1;
              if (safeMove(*x, *y))
                return TRUE;
            }
        if (legal[i][maxPoint - 1])
          if ((ndbord[i][maxPoint - 2] == 1) &&
             (ndbord[i][maxPoint] == 0) &&
             (ndbord[i - 1][maxPoint - 1] < 1) &&
             (ndbord[i + 1][maxPoint - 1] < 1) &&
             ((ndbord[i - 1][maxPoint - 2] == -1) ||
              (ndbord[i + 1][maxPoint - 2] == -1) ||
              (ndbord[i - 1][maxPoint - 1] == -1) ||
              (ndbord[i + 1][maxPoint - 1] == -1)))
            {
              *x = i;
              *y = maxPoint - 1;
              if (safeMove(*x, *y))
                return TRUE;
            }
        if (legal[0][i])
          if ((ndbord[1][i] == 1) &&
             (ndbord[0][i - 1] < 1) &&
             (ndbord[0][i + 1] < 1) &&
             (((ndbord[1][i - 1] == -1) &&
               (ndbord[1][i + 1] == -1)) ||
              (ndbord[0][i - 1] == -1) ||
              (ndbord[0][i + 1] == -1)))
            {
              *x = 0;
              *y = i;
              if (safeMove(*x, *y))
                return TRUE;
            }
        if (legal[maxPoint][i])
          if ((ndbord[maxPoint - 1][i] == 1) &&
             (ndbord[maxPoint][i - 1] < 1) &&
             (ndbord[maxPoint][i + 1] < 1) &&
             (((ndbord[maxPoint - 1][i - 1] == -1) &&
               (ndbord[maxPoint - 1][i + 1] == -1)) ||
              (ndbord[maxPoint][i - 1] == -1) ||
              (ndbord[maxPoint][i + 1] == -1)))
            {
              *x = maxPoint;
              *y = i;
              if (safeMove(*x, *y))
                return TRUE;
            }
        if (legal[i][0])
          if ((ndbord[i][1] == 1) &&
             (ndbord[i - 1][0] < 1) &&
             (ndbord[i + 1][0] < 1) &&
             (((ndbord[i - 1][1] == -1) &&
               (ndbord[i + 1][1] == -1)) ||
              (ndbord[i - 1][0] == -1) ||
              (ndbord[i + 1][0] == -1)))
            {
              *x = i;
              *y = 0;
              if (safeMove(*x, *y))
                return TRUE;
            }
        if (legal[i][maxPoint])
          if ((ndbord[i][maxPoint - 1] == 1) &&
             (ndbord[i - 1][maxPoint] < 1) &&
             (ndbord[i + 1][maxPoint] < 1) &&
             (((ndbord[i - 1][maxPoint - 1] == -1) &&
               (ndbord[i + 1][maxPoint - 1] == -1)) ||
              (ndbord[i - 1][maxPoint] == -1) ||
              (ndbord[i + 1][maxPoint] == -1)))
            {
              *x = i;
              *y = maxPoint;
              if (safeMove(*x, *y))
                return TRUE;
            }
      }
    return FALSE;
  } /* dropToEdge */

  /*
    Pushes walls in a tightly connected fashion.
    Finds the lowest influence (mine) point that is connected to one
    of my groups.
  */
short pushWall(x, y)
short *x, *y;
  { /* pushWall */
    short infl, i, j, na;
    playReason = "pushWall";
    *x = iNil;
    *y = iNil;
    infl = 11;
    for (i = 0; i <= maxPoint; i++)
      for (j = 0; j <= maxPoint; j++)
        if (legal[i][j])
          if (connectMap[i][j] > 0)
            if ((claim[i][j] < infl) &&
               (((i > 0) && (ndbord[i - 1][j] == 1)) ||
                ((i < maxPoint) && (ndbord[i + 1][j] == 1)) ||
                ((j > 0) && (ndbord[i][j - 1] == 1)) ||
                ((j < maxPoint) && (ndbord[i][j + 1] == 1)) ||
                ((i > 0) && (j > 0) && (ndbord[i - 1][j - 1] == 1)) ||
                ((i < maxPoint) && (j > 0) && (ndbord[i + 1][j - 1] == 1)) ||
                ((i > 0) && (j < maxPoint) && (ndbord[i - 1][j + 1] == 1)) ||
                ((i < maxPoint) && (j < maxPoint) &&
                 (ndbord[i + 1][j + 1] == 1))) &&
               (((i > 0) && (claim[i - 1][j] < 0)) ||
                ((i < maxPoint) && (claim[i + 1][j] < 0)) ||
                ((j > 0) && (claim[i][j - 1] < 0)) ||
                ((j < maxPoint) && (claim[i][j + 1] < 0))))
              {
                na = 0;
                if ((i > 0) && (ndbord[i - 1][j] != 0))
                  na = na + 1;
                if ((i < maxPoint) && (ndbord[i + 1][j] != 0))
                  na = na + 1;
                if ((j > 0) && (ndbord[i][j - 1] != 0))
                  na = na + 1;
                if ((j < maxPoint) && (ndbord[i][j + 1] != 0))
                  na = na + 1;
                if (na < 3)
                  if (safeMove(i, j))
                    {
                      infl = claim[i][j];
                      *x = i;
                      *y = j;
                    }
              }
    if (*x != iNil) return TRUE;
    return FALSE;
  } /* pushWall */


  /*
    reduces the liberty count of one of his groups
  */
short reduceHisLiberties(x, y)
short *x, *y;
  { /* reduceHisLiberties */
    short i, j;
    playReason = "reduceHisLiberties";
    sortLibs();
    for (i = 1; i <= maxGroupID; i++)
        if ((! gList[sGlist[i]].isLive) &&
           (gList[sGlist[i]].libC > 2) &&
           (ndbord[gList[sGlist[i]].lx][gList[sGlist[i]].ly] == -1))
          {
            spanGroup(gList[sGlist[i]].lx, gList[sGlist[i]].ly, &pList);
            for (j = 1; j <= pList.indx; j++)
                if (legal[pList.p[j].px][pList.p[j].py] &&
                   (connectMap[pList.p[j].px][pList.p[j].py] > 0))
                  if (safeMove(pList.p[j].px, pList.p[j].py))
                    {
                      *x = pList.p[j].px;
                      *y = pList.p[j].py;
                      return TRUE;
                    }
          }
    return FALSE;
  } /* reduceHisLiberties */


  /*
    connects a group to the edge
  */
short dropToEdge2(x, y)
short *x, *y;
  { /* dropToEdge2 */
    short i;
    playReason = "dropToEdge2";
    for (i = 1; i <= maxPoint - 1; i++)
      {
        if (legal[i][0])
          {
            if ((ndbord[i][1] == 1) &&
               ((ndbord[i - 1][0] < 1) ||
                (groupIDs[i - 1][0] != groupIDs[i][1])) &&
               ((ndbord[i + 1][0] < 1) ||
                (groupIDs[i + 1][0] != groupIDs[i][1])) &&
               ((ndbord[i - 1][1] == -1) ||
                (ndbord[i + 1][1] == -1)))
              {
                *x = i;
                *y = 0;
                if (safeMove(*x, *y))
                  return TRUE;
              }
          }
        if (legal[0][i])
          {
            if ((ndbord[1][i] == 1) &&
               ((ndbord[0][i - 1] < 1) ||
                (groupIDs[0][i - 1] != groupIDs[1][i])) &&
               ((ndbord[0][i + 1] < 1) ||
                (groupIDs[0][i + 1] != groupIDs[1][i])) &&
               ((ndbord[1][i - 1] == -1) ||
                (ndbord[1][i + 1] == -1)))
              {
                *x = 0;
                *y = i;
                if (safeMove(*x, *y))
                  return TRUE;
              }
          }
        if (legal[i][maxPoint])
          {
            if ((ndbord[i][maxPoint - 1] == 1) &&
               ((ndbord[i - 1][maxPoint] < 1) ||
                (groupIDs[i - 1][maxPoint] != groupIDs[i][maxPoint - 1])) &&
               ((ndbord[i + 1][maxPoint] < 1) ||
                (groupIDs[i + 1][maxPoint] != groupIDs[i][maxPoint - 1])) &&
               ((ndbord[i - 1][maxPoint - 1] == -1) ||
                (ndbord[i + 1][maxPoint - 1] == -1)))
              {
                *x = i;
                *y = maxPoint;
                if (safeMove(*x, *y))
                  return TRUE;
              }
          }
        if (legal[maxPoint][i])
          {
            if ((ndbord[maxPoint - 1][i] == 1) &&
               ((ndbord[maxPoint][i - 1] < 1) ||
                (groupIDs[maxPoint][i - 1] != groupIDs[maxPoint - 1][i])) &&
               ((ndbord[maxPoint][i + 1] < 1) ||
                (groupIDs[maxPoint][i + 1] != groupIDs[maxPoint - 1][i])) &&
               ((ndbord[maxPoint - 1][i - 1] == -1) ||
                (ndbord[maxPoint - 1][i + 1] == -1)))
              {
                *x = maxPoint;
                *y = i;
                if (safeMove(*x, *y))
                  return TRUE;
              }
          }
      }
    return FALSE;
  } /* dropToEdge2 */

