/* The go player utilities */
/* Ported from Pascal to C by Todd R. Johnson */
/* From the original Pascal file:
Copyright (c) 1983 by Three Rivers Computer Corp.

Written: January 17, 1983 by Stoney Ballard
*/

#include "goplayutils.h"
#include "amigo.h"
#include "go.h"

extern struct bRec goboard[19][19];

intBoard  claim, extra, bord, ndbord, sGroups, threatBord,
          groupIDs, connectMap, protPoints;
boolBoard  groupSeen, legal;
short maxGroupID;
pointList pList, pList1, plist2, plist3, pPlist;
intList nlcGroup, aList;
sgRec sList[401];
groupRec gList[maxGroup];
short killFlag,
      numCapt,
      utilPlayLevel,
      treeLibLim;
sType mySType;
short showTrees;
short sGlist[maxGroup+1];
short depthLimit;
intBoard markBoard;
short marker;

short adjInAtari, adj2Libs,
  intersectNum, spanNum, libMark;
playRec playStack[1025];
short playMark,
  newGID,
  tryLevel,
  grpMark,
  gMap[maxGroup];
short dbStop, inGenState;

 pause()
{ /* pause */
/*  if (dbStop and ! inGenState)
    {
      while ! tabswitch do;
      repeat
        if (tabYellow)
          dbStop = false;
      until ! tabswitch;
    }     */
} /* pause */

sstone(w, x, y, numb)
short w, x, y, numb;
{ /* sstone */
  if (w == 1)
    placestone(mySType, x, y);
  else if (mySType == WHITE)
    placestone(BLACK, x, y);
  else
    placestone(WHITE, x, y);
} /* sstone */

rstone(x, y)
short x, y;
{ /* rstone */
  removestone(x, y);
} /* rstone */

initBoolBoard(bb)
boolBoard bb;
{ /* initBoolBoard */
  short i, j;
#ifdef DEBUG
  printf( "initBoolBoard\n" );
#endif
  for (i = 0; i <= maxPoint; i++)
    for (j = 0; j <= maxPoint; j++)
      bb[i][j] = FALSE;
} /* initBoolBoard */

sortLibs()
{ /* sortLibs */
  short i, j, t;
#ifdef DEBUG
  printf( "sortLibs\n" );
#endif
  for (i = 1; i <= maxGroupID; i++)
    sGlist[i] = i;
  for (i = 1; i < maxGroupID; i++)
    for (j = i + 1; j <= maxGroupID; j++)
      if (gList[sGlist[i]].libC > gList[sGlist[j]].libC)
        {
          t = sGlist[i];
          sGlist[i] = sGlist[j];
          sGlist[j] = t;
        }
} /* sortLibs */

spanGroupspan(x, y, libs, lookFor)
short x, y, lookFor;
pointList *libs;
  { /* span */
    markBoard[x][y] = marker;
    if (bord[x][y] == 0)
      {
        libs->indx = libs->indx + 1;
        libs->p[libs->indx].px = x;
        libs->p[libs->indx].py = y;
      }
    else if (bord[x][y] == lookFor)
      {
        groupSeen[x][y] = TRUE;
        if ((x > 0) && (markBoard[x - 1][y] != marker))
          spanGroupspan(x - 1, y, libs, lookFor);
        if ((y > 0) && (markBoard[x][y - 1] != marker))
          spanGroupspan(x, y - 1, libs, lookFor);
        if ((x < maxPoint) && (markBoard[x + 1][y] != marker))
          spanGroupspan(x + 1, y, libs, lookFor);
        if ((y < maxPoint) && (markBoard[x][y + 1] != marker))
          spanGroupspan(x, y + 1, libs, lookFor);
      }
    else if (gList[gMap[groupIDs[x][y]]].libC == 1)
      adjInAtari = TRUE;
    else if ((gList[gMap[groupIDs[x][y]]].libC == 2) &&
            (! gList[gMap[groupIDs[x][y]]].isLive))
      adj2Libs = TRUE; 
  } /* span */

spanGroup(x, y, libs)
short x, y;
pointList *libs;
{ /* spanGroup */
  short lookFor;
#ifdef DEBUG
  printf( "spanGroup\n" );
#endif
  marker = marker + 1;
  if (marker == 0)
    {
      initArray(markBoard);
      marker = 1;
    }
  adjInAtari = FALSE;
  adj2Libs = FALSE;
  lookFor = bord[x][y];
  libs->indx = 0;
  spanGroupspan(x, y, libs, lookFor);
} /* spanGroup */

sSpanGroupspan(x, y, libs, lookFor)
short x, y, lookFor;
sPointList *libs;
  { /* span */
    markBoard[x][y] = marker;
    if (bord[x][y] == 0)
      {
        libs->indx += 1;
        if (libs->indx <= maxSPoint)
          {
            libs->p[libs->indx].px = x;
            libs->p[libs->indx].py = y;
          }
      }
    else if (bord[x][y] == lookFor)
      {
        groupSeen[x][y] = TRUE;
        if ((x > 0) && (markBoard[x - 1][y] != marker))
          sSpanGroupspan(x - 1, y, libs, lookFor);
        if ((y > 0) && (markBoard[x][y - 1] != marker))
          sSpanGroupspan(x, y - 1, libs, lookFor);
        if ((x < maxPoint) && (markBoard[x + 1][y] != marker))
          sSpanGroupspan(x + 1, y, libs, lookFor);
        if ((y < maxPoint) && (markBoard[x][y + 1] != marker))
          sSpanGroupspan(x, y + 1, libs, lookFor);
      }
    else if (gList[gMap[groupIDs[x][y]]].libC == 1)
      adjInAtari = TRUE;
    else if ((gList[gMap[groupIDs[x][y]]].libC == 2) &&
            (! gList[gMap[groupIDs[x][y]]].isLive)) 
      adj2Libs = TRUE; 
  } /* span */

sSpanGroup(x, y, libs)
short x, y;
sPointList *libs;
{ /* sSpanGroup */
  short lookFor;
#ifdef DEBUG
  printf( "sSpanGroup\n" );
#endif
  marker = marker + 1;
  if (marker == 0)
    {
      initArray(markBoard);
      marker = 1;
    }
  adjInAtari = FALSE;
  adj2Libs = FALSE;
  lookFor = bord[x][y];
  libs->indx = 0;
  sSpanGroupspan(x, y, libs, lookFor);
} /* sSpanGroup */

LAspan(x, y, me, him, iL)
short x, y, me, him;
intList *iL;
  { /* span */
#ifdef DEBUG
  printf( "LAspan\n" );
#endif
    markBoard[x][y] = marker;
    if (bord[x][y] == me)
      {
        if ((x > 0) && (markBoard[x - 1][y] != marker))
          LAspan(x - 1, y, me, him, iL);
        if ((x < maxPoint) && (markBoard[x + 1][y] != marker))
          LAspan(x + 1, y, me, him, iL);
        if ((y > 0) && (markBoard[x][y - 1] != marker))
          LAspan(x, y - 1, me, him, iL);
        if ((y < maxPoint) && (markBoard[x][y + 1] != marker))
          LAspan(x, y + 1, me, him, iL);
      }
    else if (bord[x][y] == him)
      if (gList[gMap[groupIDs[x][y]]].groupMark != grpMark)
        {
          gList[gMap[groupIDs[x][y]]].groupMark = grpMark;
          iL->indx = iL->indx + 1;
          iL->v[iL->indx] = gMap[groupIDs[x][y]];
        }
  } /* span */

listAdjacents(x, y, iL)
short x, y;
intList *iL;
{ /* listAdjacents */
  short me, him;
#ifdef DEBUG
  printf( "listAdjacents\n" );
#endif
  grpMark = grpMark + 1;
  marker = marker + 1;
  if (marker == 0)
    {
      initArray(markBoard);
      marker = 1;
    }
  iL->indx = 0;
  me = bord[x][y];
  him = -me;
  LAspan(x, y, me , him, iL);
} /* listAdjacents */

LDspan(x, y, me, diags)
short x, y, me;
sPointList *diags;
  { /* span */
#ifdef DEBUG
  printf( "LDspan\n" );
#endif
    markBoard[x][y] = marker;
    if ((x > 0) && (y > 0) &&
       (bord[x - 1][y - 1] == 0) &&
       (bord[x][y - 1] != me) &&
       (bord[x - 1][y] != me) &&
       (markBoard[x - 1][y - 1] != marker))
      {
        markBoard[x - 1][y - 1] = marker;
        diags->indx = diags->indx + 1;
        if (diags->indx <= maxSPoint)
            {
              diags->p[diags->indx].px = x - 1;
              diags->p[diags->indx].py = y - 1;
            }
      }
    if ((x < maxPoint) && (y > 0) &&
       (bord[x + 1][y - 1] == 0) &&
       (bord[x][y - 1] != me) &&
       (bord[x + 1][y] != me) &&
       (markBoard[x + 1][y - 1] != marker))
      {
        markBoard[x + 1][y - 1] = marker;
        diags->indx = diags->indx + 1;
        if (diags->indx <= maxSPoint)
	   {
              diags->p[diags->indx].px = x + 1;
              diags->p[diags->indx].py = y - 1;
           }
      }
    if ((x > 0) && (y < maxPoint) &&
       (bord[x - 1][y + 1] == 0) &&
       (bord[x][y + 1] != me) &&
       (bord[x - 1][y] != me) &&
       (markBoard[x - 1][y + 1] != marker))
      {
        markBoard[x - 1][y + 1] = marker;
        diags->indx = diags->indx + 1;
        if (diags->indx <= maxSPoint)
            {
              diags->p[diags->indx].px = x - 1;
              diags->p[diags->indx].py = y + 1;
            }
      }
    if ((x < maxPoint) && (y < maxPoint) &&
       (bord[x + 1][y + 1] == 0) &&
       (bord[x][y + 1] != me) &&
       (bord[x + 1][y] != me) &&
       (markBoard[x + 1][y + 1] != marker))
      {
        markBoard[x + 1][y + 1] = marker;
        diags->indx = diags->indx + 1;
        if (diags->indx <= maxSPoint)
            {
              diags->p[diags->indx].px = x + 1;
              diags->p[diags->indx].py = y + 1;
            }
      }
    if ((x > 0) && (bord[x - 1][y] == me) &&
       (markBoard[x - 1][y] != marker))
      LDspan(x - 1, y, me, diags);
    if ((x < maxPoint) && (bord[x + 1][y] == me) &&
       (markBoard[x + 1][y] != marker))
      LDspan(x + 1, y, me, diags);
    if ((y > 0) && (bord[x][y - 1] == me) &&
       (markBoard[x][y - 1] != marker))
      LDspan(x, y - 1, me, diags);
    if ((y < maxPoint) && (bord[x][y + 1] == me) &&
       (markBoard[x][y + 1] != marker))
      LDspan(x, y + 1, me , diags);
} /* span */

listDiags(x, y, diags)
short x, y;
sPointList *diags;
{ /* listDiags */
  short me;
#ifdef DEBUG
  printf( "listDiags\n" );
#endif
  me = bord[x][y];
  diags->indx = 0;
  marker = marker + 1;
  if (marker == 0)
    {
      initArray(markBoard);
      marker = 1;
    }
  LDspan(x, y, me, diags);
} /* listDiags */

intersectPlist(p1, p2, pr)
pointList *p1, *p2, *pr;
{ /* intersectPlist */
  short i, j, k;
#ifdef DEBUG
  printf( "intersectPlist\n" );
#endif
  marker = marker + 1;
  if (marker == 0)
    {
      initArray(markBoard);
      marker = 1;
    }
  pr->indx = 0;
  for (i = 1; i <= p1->indx; i++)
      markBoard[p1->p[i].px][p1->p[i].py] = marker;
  j = 0;
  for (i = 1; i <= p2->indx; i++)
      if (markBoard[p2->p[i].px][p2->p[i].py] == marker)
        {
          j = j + 1;
          pr->p[j] = p2->p[i];
        }
  pr->indx = j;
} /* intersectPlist */

initArray(ary)
intBoard ary;
{ /* initArray */
  short i, j;
  for (i = 0; i <= maxPoint; i++)
    for (j = 0; j <= maxPoint; j++)
      ary[i][j] = 0;
} /* initArray */

initState()
{ /* initState */
  short i, j;
  for (i = 0; i <= maxPoint; i++)
    for (j = 0; j <=  maxPoint; j++)
      {
        extra[i][j] = 0;
        claim[i][j] = 0;
        groupIDs[i][j] = 0;
        connectMap[i][j] = 0;
        protPoints[i][j] = 0;
      }
} /* initState */

copyArray( dest, src )
intBoard dest, src;
{
   short x, y;
   for (y = 0; y <= maxPoint; y++)
      for (x = 0; x <= maxPoint; x++)
         dest[x][y] = src[x][y];
}

/*
  generates a one-point spread in the force field array (claim)

  the spread from a single point after four calls is:

              1
           2  2  2
        2  4  6  4  2
     2  4  8 10  8  4  2
  1  2  6 10 62 10  6  2  1  
     2  4  8 10  8  4  2
        2  4  6  4  2
           2  2  2
              1

*/
stake()
{
   short x, y;
   initArray( extra );
   for (y = 0; y <= maxPoint; y++)
      for (x = 0; x <= maxPoint; x++)
      {
         extra[x][y] = extra[x][y] + claim[x][y];
	 if (claim[x][y] > 0)
	 {
	    if (x > 0) extra[x-1][y] += 1;
	    if (y > 0) extra[x][y-1] += 1;
	    if (x < maxPoint) extra[x+1][y] += 1;
	    if (y < maxPoint) extra[x][y+1] += 1;
	 }
         else if (claim[x][y] < 0)
	 {
	    if (x > 0) extra[x-1][y] -= 1;
	    if (y > 0) extra[x][y-1] -= 1;
	    if (x < maxPoint) extra[x+1][y] -= 1;
	    if (y < maxPoint) extra[x][y+1] -= 1;
	 }
      }
   copyArray( claim, extra );
} /* stake */

/*
  sets up claim from the current board position
*/
spread()
{
   short x, y;
   for (y = 0; y <= maxPoint; y++)
      for (x = 0; x <= maxPoint; x++)
         claim[x][y] = ndbord[x][y] * 50;
   stake();
   stake();
   stake();
   stake();
} /* spread */

/*
  gList is initialized with the size, loc, and libCount of each group
  groupIDs contains the serial numbers of the groups.
*/
Resspan(x, y, gID, gSize, libCount, who)
short x, y, gID, *gSize, *libCount, who;
  { /* span */
    if ((bord[x][y] == 0) &&
       (markBoard[x][y] != marker)) /* a liberty */
      {
        markBoard[x][y] = marker;
        *libCount = *libCount + 1;
      }
    else if ((bord[x][y] == who) &&
            (groupIDs[x][y] == 0))
      {
        groupIDs[x][y] = gID;
        *gSize = *gSize + 1;
        if (x > 0)
          Resspan(x - 1, y, gID, gSize, libCount, who);
        if (x < maxPoint)
          Resspan(x + 1, y, gID, gSize, libCount, who);
        if (y > 0)
          Resspan(x, y - 1, gID, gSize, libCount, who);
        if (y < maxPoint)
          Resspan(x, y + 1, gID, gSize, libCount, who);
      }
  } /* span */

respreicen()
{ /* respreicen */
  short i, j, gID, libCount, gSize, who;
  gID = 0;
#ifdef DEBUG
  printf( "respreicen\n" );
#endif
  for (i = 0; i <= maxPoint; i++)
    for (j = 0; j <= maxPoint; j++)
      groupIDs[i][j] = 0;
  for (i = 0; i <= maxPoint; i++)
    for (j = 0; j <= maxPoint; j++)
      if ((bord[i][j] != 0) &&   /* a stone there */
         (groupIDs[i][j] == 0)) /* not seen yet */
        {
          marker = marker + 1;
          if (marker == 0)
            {
              initArray(markBoard);
              marker = 1;
            }
          gID = gID + 1;
          libCount = 0;
          gSize = 0;
          who = bord[i][j];
          Resspan(i, j, gID, &gSize, &libCount, who); /* span the group, collecting info */
              gList[gID].groupMark = 0;
              gList[gID].atLevel = 0;
              gList[gID].isLive = FALSE; /* we don't know yet */
              gList[gID].isDead = FALSE;
              gList[gID].numEyes = -1;
              gList[gID].size = gSize;
              gList[gID].libC = libCount;
              gList[gID].lx = i;
              gList[gID].ly = j;
          gMap[gID] = gID; /* set up identity map */
        }
  maxGroupID = gID;
  newGID = gID;
  grpMark = 0;
} /* respreicen */

/*
  play z at [x, y].
  killFlag is set true if anything is killed.
*/
killGroup(x, y, me, him)
short x, y, me, him;
  { /* killGroup */
#ifdef DEBUG
  printf( "killGroup\n" );
#endif
    playMark = playMark + 1;
                /* record this kill */
        playStack[playMark].kind = rem;
        playStack[playMark].uval.rem.who = him;
        playStack[playMark].uval.rem.xl = x;
        playStack[playMark].uval.rem.yl = y;
        playStack[playMark].gID = groupIDs[x][y];
        playStack[playMark].uval.rem.sNumber = goboard[x][y].mNum;
        if (showTrees)
          rstone(x, y);
    numCapt = numCapt + 1;
    bord[x][y] = 0;
    groupIDs[x][y] = 0;
    if (x > 0)
      {
        if (bord[x - 1][y] == me)
          {
            nlcGroup.indx = nlcGroup.indx + 1;
            nlcGroup.v[nlcGroup.indx] = gMap[groupIDs[x - 1][y]];
          }
        else if (bord[x - 1][y] == him)
          killGroup(x - 1, y, me , him);
      }
    if (x < maxPoint)
      {
        if (bord[x + 1][y] == me)
          {
            nlcGroup.indx = nlcGroup.indx + 1;
            nlcGroup.v[nlcGroup.indx] = gMap[groupIDs[x + 1][y]];
          }
        else if (bord[x + 1][y] == him)
          killGroup(x + 1, y, me, him);
      }
    if (y > 0)
      {
        if (bord[x][y - 1] == me)
          {
            nlcGroup.indx = nlcGroup.indx + 1;
            nlcGroup.v[nlcGroup.indx] = gMap[groupIDs[x][y - 1]];
          }
        else if (bord[x][y - 1] == him)
          killGroup(x, y - 1, me, him);
      }
    if (y < maxPoint)
      {
        if (bord[x][y + 1] == me)
          {
            nlcGroup.indx = nlcGroup.indx + 1;
            nlcGroup.v[nlcGroup.indx] = gMap[groupIDs[x][y + 1]];
          }
        else if (bord[x][y + 1] == him)
          killGroup(x, y + 1, me, him);
      }
  } /* killGroup */

mergeGroup(sGID, myGID)
short sGID, myGID;
  { /* mergeGroup */
    short i;
#ifdef DEBUG
  printf( "mergeGroup\n" );
#endif
    for (i = 1; i <= newGID; i++)
      if (gMap[i] == sGID)
        {
          playMark = playMark + 1;
              playStack[playMark].kind = reMap;
              playStack[playMark].gID = i;
              playStack[playMark].uval.reMap.oldGID = sGID;
          gMap[i] = myGID;
        }
  } /* mergeGroup */

tryPlay(x, y, z)
short x, y, z;
{ /* plei */
  short i, me, him, myGID;
  short isNew;
#ifdef DEBUG
  printf( "tryPlay\n" );
#endif
  me = z;
  him = -me;
  killFlag = FALSE;  /* set true if something is killed */
  numCapt = 0;
  tryLevel = tryLevel + 1;
  isNew = FALSE;
  bord[x][y] = z;  /* play the stone */
  if ((x > 0) && (bord[x - 1][y] == me))   /* connect to adjacent group */
    myGID = gMap[groupIDs[x - 1][y]];
  else if ((x < maxPoint) && (bord[x + 1][y] == me))
    myGID = gMap[groupIDs[x + 1][y]];
  else if ((y > 0) && (bord[x][y - 1] == me))
    myGID = gMap[groupIDs[x][y - 1]];
  else if ((y < maxPoint) && (bord[x][y + 1] == me))
    myGID = gMap[groupIDs[x][y + 1]];
  else  /* nobody to connect to */
    {
      newGID = newGID + 1;
      isNew = TRUE;
      myGID = newGID;
          gList[myGID].groupMark = 0;
          gList[myGID].atLevel = tryLevel;
          gList[myGID].isLive = FALSE;
          gList[myGID].numEyes = -1;
          gList[myGID].size = -1;
          gList[myGID].lx = x;
          gList[myGID].ly = y;
      gMap[myGID] = myGID;
    }
  groupIDs[x][y] = myGID;
  playMark = playMark + 1;
      /* record this move */
      playStack[playMark].kind = add;
      playStack[playMark].uval.add.who = me;
      playStack[playMark].uval.add.xl = x;
      playStack[playMark].uval.add.yl = y;
      playStack[playMark].gID = myGID;
      playStack[playMark].uval.add.sNumber = 0;
      if (isNew)
        playStack[playMark].uval.add.nextGID = newGID - 1;
      else
        playStack[playMark].uval.add.nextGID = newGID;
      if (showTrees)
        sstone(me, x, y, 0);
  /* merge adjacent groups */
  if ((x > 0) && (bord[x - 1][y] == me) &&
     (gMap[groupIDs[x - 1][y]] != myGID))
    mergeGroup(gMap[groupIDs[x - 1][y]], myGID);
  if ((x < maxPoint) && (bord[x + 1][y] == me) &&
     (gMap[groupIDs[x + 1][y]] != myGID))
    mergeGroup(gMap[groupIDs[x + 1][y]], myGID);
  if ((y > 0) && (bord[x][y - 1] == me) &&
     (gMap[groupIDs[x][y - 1]] != myGID))
    mergeGroup(gMap[groupIDs[x][y - 1]], myGID);
  if ((y < maxPoint) && (bord[x][y + 1] == me) &&
     (gMap[groupIDs[x][y + 1]] != myGID))
    mergeGroup(gMap[groupIDs[x][y + 1]], myGID);
  /* kill opposing groups, listing affected groups */
  nlcGroup.indx = 1;
  nlcGroup.v[1] = myGID; /* init list to include me */
  if ((x > 0) && (bord[x - 1][y] == him) &&
     (gList[gMap[groupIDs[x - 1][y]]].libC == 1))
    {
      killFlag = TRUE;
      killGroup(x - 1, y, me, him);
    }
  if ((x < maxPoint) && (bord[x + 1][y] == him) &&
     (gList[gMap[groupIDs[x + 1][y]]].libC == 1))
    {
      killFlag = TRUE;
      killGroup(x + 1, y, me, him);
    }
  if ((y > 0) && (bord[x][y - 1] == him) &&
     (gList[gMap[groupIDs[x][y - 1]]].libC == 1))
    {
      killFlag = TRUE;
      killGroup(x, y - 1, me, him);
    }
  if ((y < maxPoint) && (bord[x][y + 1] == him) &&
     (gList[gMap[groupIDs[x][y + 1]]].libC == 1))
    {
      killFlag = TRUE;
      killGroup(x, y + 1, me, him);
    }
  /* list groups adjacent to me */
  if ((x > 0) && (bord[x - 1][y] == him))
    {
      nlcGroup.indx = nlcGroup.indx + 1;
      nlcGroup.v[nlcGroup.indx] = gMap[groupIDs[x - 1][y]];
    }
  if ((x < maxPoint) && (bord[x + 1][y] == him))
    {
      nlcGroup.indx = nlcGroup.indx + 1;
      nlcGroup.v[nlcGroup.indx] = gMap[groupIDs[x + 1][y]];
    }
  if ((y > 0) && (bord[x][y - 1] == him))
    {
      nlcGroup.indx = nlcGroup.indx + 1;
      nlcGroup.v[nlcGroup.indx] = gMap[groupIDs[x][y - 1]];
    }
  if ((y < maxPoint) && (bord[x][y + 1] == him))
    {
      nlcGroup.indx = nlcGroup.indx + 1;
      nlcGroup.v[nlcGroup.indx] = gMap[groupIDs[x][y + 1]];
    }
  /* fix liberty count for affected groups */
  grpMark = grpMark + 1;
  for (i = 1; i <= nlcGroup.indx; i++)
      if (gList[nlcGroup.v[i]].groupMark != grpMark)
        {
          if (gList[nlcGroup.v[i]].atLevel != tryLevel)
            {
              playMark = playMark + 1;
                  playStack[playMark].kind = chLib;
                  playStack[playMark].gID = nlcGroup.v[i];
                  playStack[playMark].uval.chLib.oldLevel = 
		               gList[nlcGroup.v[i]].atLevel;
                  playStack[playMark].uval.chLib.oldLC =
		               gList[nlcGroup.v[i]].libC;
            }
          gList[nlcGroup.v[i]].groupMark = grpMark;
          gList[nlcGroup.v[i]].atLevel = tryLevel;
          spanGroup(gList[nlcGroup.v[i]].lx, gList[nlcGroup.v[i]].ly, &pPlist);
          gList[nlcGroup.v[i]].libC = pPlist.indx;
        }
} /* plei */

saveState()
{ /* saveState */
  playMark = 0;
  tryLevel = 0;
  newGID = maxGroupID;
} /* saveState */

/*
  undoes a move sequence back to uMark
*/
undoTo(uMark)
short uMark;
{ /* undoTo */
  short i, xl, yl;
#ifdef DEBUG
  printf( "undoTo\n" );
#endif
  for (i = playMark; i >= uMark + 1; i--)
      if (playStack[i].kind == rem)
        {
          xl = playStack[i].uval.rem.xl;
          yl = playStack[i].uval.rem.yl;
          bord[xl][yl] = playStack[i].uval.rem.who;
          groupIDs[xl][yl] = playStack[i].gID;
          if (showTrees)
            sstone(playStack[i].uval.rem.who, xl, yl,
	           playStack[i].uval.rem.sNumber);
        }
      else if (playStack[i].kind == add)
        {
          xl = playStack[i].uval.add.xl;
          yl = playStack[i].uval.add.yl;
          bord[xl][yl] = 0;
          groupIDs[xl][yl] = 0;
          tryLevel = tryLevel - 1;
          newGID = playStack[i].uval.add.nextGID;
          if (showTrees)
            rstone(xl, yl);
        }
      else if (playStack[i].kind == reMap)
        gMap[playStack[i].gID] = playStack[i].uval.reMap.oldGID;
      else /* change libs of group - gID is pre-mapped */
          {
            gList[playStack[i].gID].libC = playStack[i].uval.chLib.oldLC;
            gList[playStack[i].gID].atLevel = playStack[i].uval.chLib.oldLevel;
          }
  playMark = uMark;
} /* undoTo */

/*
  restores the state of the world after trying a move sequence
*/
restoreState()
{ /* restoreState */
#ifdef DEBUG
  printf( "restoreState\n" );
#endif
  if (playMark > 0)
    {
      undoTo(0);
      playMark = 0;
      tryLevel = 0;
    }
} /* restoreState */

/* exception bpt; */


/*
  returns true if (the group (at gx, gy) is saveable.
  if so, returns the point to play at in savex, savey
*/
short saveable(gx, gy, savex, savey)
short gx, gy, *savex, *savey;
{ /* saveable */
  short me, him, gx1, gx2, i, j, smark, mark2, tl, result;
  char sChar;
  sPointList dList;
  point tp;
  short libList[maxSPoint+1];
#ifdef DEBUG
  printf( "saveable\n" );
#endif
  dbStop = TRUE;
  me = bord[gx][gy];
  him = -me;
  if (me == 1)
    sChar = '|';
  else
    sChar = '>';
/*  write(sChar); */
  spanGroup(gx, gy, &plist3); /* find my liberties */
  if (adjInAtari) /* one of my options is to kill */
    {
      listAdjacents(gx, gy, &aList);
      for (i = 1; i <= aList.indx; i++)
        if (gList[aList.v[i]].libC == 1)
            {
              spanGroup(gList[aList.v[i]].lx, gList[aList.v[i]].ly,
 				&pList1); /* find it's liberty */
              plist3.indx = plist3.indx + 1;
              plist3.p[plist3.indx].px = pList1.p[1].px;
              plist3.p[plist3.indx].py = pList1.p[1].py;
            }
    }
  for (i = 1; i <= maxSPoint; i++)
    libList[i] = -1;
  if ((utilPlayLevel > 4) &&
     (gList[gMap[groupIDs[gx][gy]]].libC > 1)) /* account for diags */
    {
      listDiags(gx, gy, &dList);
      j = 0;
      i = plist3.indx;
      while ((j < dList.indx) &&
            (i < maxSPoint))
        {
          j = j + 1;
          i = i + 1;
          libList[i] = 100;
              plist3.p[i].px = dList.p[j].px;
              plist3.p[i].py = dList.p[j].py;
        }
      plist3.indx = i;
    }
  if (plist3.indx > 1) /* sort by decreasing lib count */
    {
      for (i = 1; i <= plist3.indx; i++)
        if (libList[i] != 100)
            {
              mark2 = playMark;
              tryPlay(plist3.p[i].px, plist3.p[i].py, me);
              libList[i] = gList[gMap[groupIDs[gx][gy]]].libC;
              if (libList[i] > treeLibLim) /* i'm safe */
                {
                  *savex = plist3.p[i].px;
                  *savey = plist3.p[i].py;
                  result = TRUE;
                  goto one;
                }
              undoTo(mark2);
            }
      for (i = 1; i <= plist3.indx - 1; i++)
        for (j = i + 1; j <= plist3.indx; j++)
          if (libList[i] < libList[j])
            {
              tl = libList[i];
              libList[i] = libList[j];
              libList[j] = tl;
              tp = plist3.p[i];
              plist3.p[i] = plist3.p[j];
              plist3.p[j] = tp;
            }
    }
  for (i = 1; i <= plist3.indx; i++)
    {
      *savex = plist3.p[i].px;
      *savey = plist3.p[i].py;
      if (legal[*savex][*savey])
        {
          smark = playMark;
          tryPlay(*savex, *savey, me);
          pause();
          if (gList[gMap[groupIDs[*savex][*savey]]].libC > 1)
            if (gList[gMap[groupIDs[gx][gy]]].libC > treeLibLim)
              {
                restoreState();
/*                sClearChar(sChar, rXor); */
                return TRUE;
              }
            else if (gList[gMap[groupIDs[gx][gy]]].libC > 1)
              if (! killable(gx, gy, &gx1, &gx2))
                {
                  restoreState();
/*                  sClearChar(sChar, rXor); */
                  return TRUE;
                }
          undoTo(smark);
        }
    }
  result = FALSE;
one:
  restoreState();
/*  sClearChar(sChar, rXor); */
  return result;
} /* saveable */

/*
  marks unsavable groups as dead
*/
markDead()
{ /* markDead */
  short i, j, gx, gy, result;
#ifdef DEBUG
  printf( "markDead\n" );
#endif
  for (i = 1; i <= maxGroupID; i++)
      if (killable(gList[i].lx, gList[i].ly, &gx, &gy))
        result = ! saveable(gList[i].lx, gList[i].ly, &gx, &gy);
      else
        result = FALSE;
  for (i = 0; i <= maxPoint; i++)
    for (j = 0; j <= maxPoint; j++)
      if (bord[i][j] == 0)
        ndbord[i][j] = 0;
      else if (gList[groupIDs[i][j]].isDead)
        ndbord[i][j] = 0;
      else
        ndbord[i][j] = bord[i][j];
} /* markDead */

/*
  marks groups with two eyes as live
*/
MLspan(x, y, saw1, sawm1, size, sMark)
short x, y, *saw1, *sawm1, *size, sMark;
  { /* span */
    if (ndbord[x][y] == 1)
      *saw1 = TRUE;
    else if (ndbord[x][y] == -1)
      *sawm1 = TRUE;
    else if (sGroups[x][y] == 0)
      {
if (sMark<0 || sMark>400) printf("ERROR: %d\n",sMark);
        sGroups[x][y] = sMark;
        *size = *size + 1;
        if (x > 0)
          MLspan(x - 1, y, saw1, sawm1, size, sMark);
        if (x < maxPoint)
          MLspan(x + 1, y, saw1, sawm1, size, sMark);
        if (y > 0)
          MLspan(x, y - 1, saw1, sawm1, size, sMark);
        if (y < maxPoint)
          MLspan(x, y + 1, saw1, sawm1, size, sMark);
      }
  } /* span */

short CLspan(x, y, numEyes, who)
short x, y, *numEyes, who;
    { /* span */
      markBoard[x][y] = marker;
      if (ndbord[x][y] == 0)
          {
            if ((sList[sGroups[x][y]].sm != marker) &&
               (sList[sGroups[x][y]].w == who))
              {
                sList[sGroups[x][y]].sm = marker;
                if (sList[sGroups[x][y]].s > 6)
                  return TRUE;
                *numEyes = *numEyes + 1;
                if (*numEyes > 1)
                  return TRUE;
              }  
          }
      else if (bord[x][y] == who)
        {
          if ((x > 0) &&
             (markBoard[x - 1][y] != marker))
            if (CLspan(x - 1, y, numEyes, who)) return TRUE;
          if ((x < maxPoint) &&
             (markBoard[x + 1][y] != marker))
            if (CLspan(x + 1, y, numEyes, who)) return TRUE;
          if ((y > 0) &&
             (markBoard[x][y - 1] != marker))
            if (CLspan(x, y - 1, numEyes, who)) return TRUE;
          if ((y < maxPoint) &&
             (markBoard[x][y + 1] != marker))
            if (CLspan(x, y + 1, numEyes, who)) return TRUE;
        }
    return FALSE;
    } /* span */

short checkLive(x, y)
short x, y;
  { /* checkLive */
    short numEyes, who;
#ifdef DEBUG
  printf( "checkLive\n" );
#endif
    numEyes = 0;
    who = bord[x][y];
    marker = marker + 1;
    return CLspan(x, y, &numEyes, who);
  } /* checkLive */

markLive()
{ /* markLive */
  short i, j, size, sMark = 0;
  short saw1, sawm1;
#ifdef DEBUG
  printf( "markLive\n" );
#endif
  initArray(sGroups);
  for (i = 0; i <= maxPoint; i++)
    for (j = 0; j <= maxPoint; j++)
      if ((sGroups[i][j] == 0) &&
         (ndbord[i][j] == 0))
        {
          size = 0;
          sMark = sMark + 1;
          sawm1 = FALSE;
          saw1 = FALSE;
          MLspan(i, j, &saw1, &sawm1, &size, sMark);
          sList[sMark].s = size;
          sList[sMark].sm = 0;
          if (sawm1)
            if (saw1)
              sList[sMark].w = 0;
            else
              sList[sMark].w = -1;
          else if (saw1)
            sList[sMark].w = 1;
          else
            sList[sMark].w = 0;
        }
  for (i = 1; i <= maxGroupID; i++)
      if (! gList[i].isDead)
        gList[i].isLive = checkLive(gList[i].lx, gList[i].ly);
} /* markLive */

/*
  generates the connection map and the protected point map.
*/
genConnects()
{ /* genConnects */
  short x, y, numStones;
#ifdef DEBUG
  printf( "genConnects\n" );
#endif
  for (x = 0; x <= maxPoint; x++)
    for (y = 0; y <= maxPoint; y++)
      {
        connectMap[x][y] = 0;
        protPoints[x][y] = 0;
      }
  for (x = 0; x <= maxPoint; x++)
    for (y = 0; y <= maxPoint; y++)
      if (bord[x][y] == 1)   /* map connections to this stone */
        {
          if (x > 0)        /* direct connection */
            connectMap[x - 1][y] += 1;
          if (x < maxPoint)
            connectMap[x + 1][y] += 1;
          if (y > 0)
            connectMap[x][y - 1] += 1;
          if (y < maxPoint)
            connectMap[x][y + 1] += 1;
          if ((x > 0) && (y > 0) &&   /* diagonal connection */
             (bord[x - 1][y] == 0) && (bord[x][y - 1] == 0))
            connectMap[x - 1][y - 1] += 1;
          if ((x < maxPoint) && (y > 0) &&
             (bord[x + 1][y] == 0) && (bord[x][y - 1] == 0))
            connectMap[x + 1][y - 1] += 1;
          if ((x < maxPoint) && (y < maxPoint) &&
             (bord[x + 1][y] == 0) && (bord[x][y + 1] == 0))
            connectMap[x + 1][y + 1] += 1;
          if ((x > 0) && (y < maxPoint) &&
             (bord[x - 1][y] == 0) && (bord[x][y + 1] == 0))
            connectMap[x - 1][y + 1] += 1;
          if ((x > 1) && (claim[x - 1][y] > 3))   /* one point jump */
            connectMap[x - 2][y] += 1;
          if ((x < (maxPoint - 1)) && (claim[x + 1][y] > 3))
            connectMap[x + 2][y] += 1;
          if ((y > 1) && (claim[x][y - 1] > 3))
            connectMap[x][y - 2] += 1;
          if ((y < (maxPoint - 1)) && (claim[x][y + 1] > 3))
            connectMap[x][y + 2] += 1;
          if ((x > 1) && (y > 0) &&        /* knight's move */
             (claim[x - 1][y] > 3) && (claim[x - 1][y - 1] > 3))
            connectMap[x - 2][y - 1] += 1;
          if ((x > 0) && (y > 1) &&
             (claim[x][y - 1] > 3) && (claim[x - 1][y - 1] > 3))
            connectMap[x - 1][y - 2] += 1;
          if ((x < (maxPoint - 1)) && (y > 0) &&
             (claim[x + 1][y] > 3) && (claim[x + 1][y - 1] > 3))
            connectMap[x + 2][y - 1] += 1;
          if ((x < maxPoint) && (y > 1) &&
             (claim[x][y - 1] > 3) && (claim[x + 1][y - 1] > 3))
            connectMap[x + 1][y - 2] += 1;
          if ((x > 1) && (y < maxPoint) &&
             (claim[x - 1][y] > 3) && (claim[x - 1][y + 1] > 3))
            connectMap[x - 2][y + 1] += 1;
          if ((x > 0) && (y < (maxPoint - 1)) &&
             (claim[x][y + 1] > 3) && (claim[x - 1][y + 1] > 3))
            connectMap[x - 1][y + 2] += 1;
          if ((x < (maxPoint - 1)) && (y < maxPoint) &&
             (claim[x + 1][y] > 3) && (claim[x + 1][y + 1] > 3))
            connectMap[x + 2][y + 1] += 1;
          if ((x < maxPoint) && (y < (maxPoint - 1)) &&
             (claim[x][y + 1] > 3) && (claim[x + 1][y + 1] > 3))
            connectMap[x + 1][y + 2] += 1;
        }
      else if (bord[x][y] == 0) /* see if protected point */
        {
          numStones = 0;
          if (x == 0)
            numStones = numStones + 1;
          if (y == 0)
            numStones = numStones + 1;
          if (x == maxPoint)
            numStones = numStones + 1;
          if (y == maxPoint)
            numStones = numStones + 1;
          if ((x > 0) && (bord[x - 1][y] == 1))
            numStones = numStones + 1;
          if ((y > 0) && (bord[x][y - 1] == 1))
            numStones = numStones + 1;
          if ((x < maxPoint) && (bord[x + 1][y] == 1))
            numStones = numStones + 1;
          if ((y < maxPoint) && (bord[x][y + 1] == 1))
            numStones = numStones + 1;
          if (numStones == 4)
            protPoints[x][y] = 1;
          else if (numStones == 3)
            {
              if ((x > 0) &&
                 ((bord[x - 1][y] == 0) ||
                  ((bord[x - 1][y] == -1) &&
                   (gList[groupIDs[x - 1][y]].libC == 1))))
                 protPoints[x][y] = 1;
              else if ((x < maxPoint) &&
                      ((bord[x + 1][y] == 0) ||
                       ((bord[x + 1][y] == -1) &&
                        (gList[groupIDs[x + 1][y]].libC == 1))))
                 protPoints[x][y] = 1;
              else if ((y > 0) &&
                      ((bord[x][y - 1] == 0) ||
                       ((bord[x][y - 1] == -1) &&
                        (gList[groupIDs[x][y - 1]].libC == 1))))
                 protPoints[x][y] = 1;
              else if ((y < maxPoint) &&
                      ((bord[x][y + 1] == 0) ||
                       ((bord[x][y + 1] == -1) &&
                        (gList[groupIDs[x][y + 1]].libC == 1))))
                 protPoints[x][y] = 1;
            }
        } 
  for (x = 0; x <= maxPoint; x++)
    for (y = 0; y <= maxPoint; y++)
      if (bord[x][y] != 0)
        {
          connectMap[x][y] = 0;
          protPoints[x][y] = 0;
        }
} /* genConnects */

/*
  generates the whole state of the game.
*/
genState()
{ /* genState */
#ifdef DEBUG
  printf( "genState\n" );
#endif
  inGenState = TRUE;
  respreicen();
  markDead();
  markLive();
  spread();
  genConnects();
#ifdef DEBUG
/*  printBoard( claim, "claim" ); */
/*  printBoard( bord, "bord" ); */
/*  printBoard( ndbord, "ndbord" );
  printBoard( sGroups, "sGroups" );
  printBoard( groupIDs, "groupIDs" );
  printBoard( connectMap, "connectMap" );
  printBoard( protPoints, "protPoints" ); */
#endif
  inGenState = FALSE;
} /* genState */

/*
  generates a value for the [x, y] location that appears to get larger
  for points that are saddle points in the influence graph (klein)
*/
short tencen(x, y)
short x, y;
{ /* tencen */
  short a, b, c, d, w, z;
#ifdef DEBUG
  printf( "tencen\n" );
#endif
  if (claim[x][y] > -1)  /* if (he does not influence this area, return 50 */
    {
      return 50;
    }
  w = claim[x][y]; /* w <= -1 */
  a = iNil;
  if (x > 0)
    if (claim[x - 1][y] > -1)  /* if (neighbor is not influenced by him */
      a = claim[x - 1][y] - w;   /* score is sum of his influence on central */
  b = iNil;                      /*  point and my influence on this neighbor */
  if (y > 0)
    if (claim[x][y - 1] > -1)
      b = claim[x][y - 1] - w;
  c = iNil;
  if (x < maxPoint)
    if (claim[x + 1][y] > -1)
      c = claim[x + 1][y] - w;
  d = iNil;
  if (y < maxPoint)
    if (claim[x][y + 1] > -1)
      d = claim[x][y + 1] - w;
  z = a;             /* z = max(a, b, c, d) */
  if (z != iNil)
    {
      if ((b != iNil) &&
         (b > z))
        z = b;
    }
  else
    z = b; 
  if (z != iNil)
    {
      if ((c != iNil) &&
         (c > z))
        z = c;
    }
  else
    z = c; 
  if (z != iNil)
    {
      if ((d != iNil) &&
         (d > z))
        z = d;
    }
  else
    z = d; 
  if ((z != iNil) &&
     ((x == 0) ||
      (y == 0) ||
      (x == maxPoint) ||
      (y == maxPoint)))
    z = z * 2;     /* double z if (on the edge of the board ?? */
  if (z != iNil)
    return z;
  else
    return 50;
} /* tencen */

initGPUtils()
{ /* initGPUtils */
#ifdef DEBUG
  printf( "initGPUtils\n" );
#endif
  initArray(markBoard);
  initState();
  marker = 0;
  playMark = 0;
      gList[0].isLive = FALSE;
      gList[0].isDead = FALSE;
      gList[0].libC = 0;
      gList[0].size = 0;
      gList[0].numEyes = 0;
      gList[0].lx = -1;
      gList[0].ly = -1;
  gMap[0] = 0;
  dbStop = FALSE;
  inGenState = FALSE;
} /* initGPUtils */

