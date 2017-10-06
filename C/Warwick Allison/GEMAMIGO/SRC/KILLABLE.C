/* By Stoney Ballard */
/* Ported from Pascal to C by Todd R. Johnson */

#include "go.h"
#include "amigo.h"
#include "goplayutils.h"

extern intBoard bord, groupIDs;
extern boolBoard legal;
extern groupRec gList[maxGroup];
extern short gMap[maxGroup], adjInAtari, adj2Libs, playMark, treeLibLim,
             utilPlayLevel, killFlag, depthLimit, dbStop, showTrees;
extern pointList plist2;

/*
  returns true if the group (at x, y) is killable.
  if so, returns the point to play at in killx, killy.
*/

  short me, him, depth, i, j, tryCount, tl, topMark, tkMark, mark2;
  char sChar;
  sPointList lList, dList;
  point tp;
  short libList[maxSPoint+1];
  short esc;

short mtNbrs(x, y)
short x, y;
  { /* mtNbrs */
    short n = 0;
    if ((x > 0) && (bord[x - 1][y] == 0))
      n = n + 1;
    if ((x < maxPoint) && (bord[x + 1][y] == 0))
      n = n + 1;
    if ((y > 0) && (bord[x][y - 1] == 0))
      n = n + 1;
    if ((y < maxPoint) && (bord[x][y + 1] == 0))
      n = n + 1;
    return n;
  } /* mtNbrs */

short killTree(tx, ty, gx, gy, escape, tkMark)
short tx, ty, gx, gy, *escape, tkMark;
    { /* killTree */
      short curMark, mark2, mark3, i, j, k, tl, dStart, result;
      sPointList lList1, lList2;
      short libList[maxSPoint+1];
      point tp;
      short esc = FALSE;
      tryCount = tryCount + 1;
      if (tryCount > tryLimit)
        {
          undoTo(tkMark);
/*          for (i = 1; i <= depth - 1; i++)
            {
              sClearChar(sChar, rXor); 
            } */
          depth = 1;
	  return FALSE;
        }
/*      write(sChar); */
      depth = depth + 1;
      curMark = playMark;
      tryPlay(tx, ty, me); /* try my move */
      pause();
      if (gList[gMap[groupIDs[tx][ty]]].libC == 0) /* I'm dead */
	{
	result = FALSE;
	goto one;
	}
      else if (killFlag) /* I killed something of his */
	{
	result = TRUE;
	goto one;
	}
      else if (gList[gMap[groupIDs[gx][gy]]].libC > treeLibLim) /* safe */
	{
	result = FALSE;
	goto one;
	}
      else
        {
          sSpanGroup(gx, gy, &lList1); /* find his liberties */
          if (gList[gMap[groupIDs[tx][ty]]].libC == 1) /* he can kill me */
            {
              if (lList1.indx < maxSPoint) /* add that option to his list */
                {
                  lList1.indx = lList1.indx + 1;
                  spanGroup(tx, ty, &plist2); /* find my liberty */
                      lList1.p[lList1.indx].px = plist2.p[1].px;
                      lList1.p[lList1.indx].py = plist2.p[1].py;
                }
              else
		{
		result = FALSE;
		goto one;
		}
            }
          for (i = 1; i <= maxSPoint; i++)    /* init liblist so diags can be marked */
            libList[i] = -1;
          if ((utilPlayLevel > 4) &&
             (lList1.indx > 1) &&
             (gList[gMap[groupIDs[gx][gy]]].libC > 1)) /* try diags */
            {
              listDiags(gx, gy, &dList);
              j = 0;
              i = lList1.indx;
              while ((j < dList.indx) &&
                    (i < maxSPoint))
                {
                  j = j + 1;
                  i = i + 1;
                  libList[i] = 0;     /* mark this as a diag */
                      lList1.p[i].px = dList.p[j].px;
                      lList1.p[i].py = dList.p[j].py;
                }
              lList1.indx = i;
            }
          if (lList1.indx > 1) /* sort by decreasing lib count */
            {
              for (i = 1; i <= lList1.indx; i++)
                if (libList[i] != 0)       /* diags are tried last */
                    {
                      mark2 = playMark;
                      tryPlay(lList1.p[i].px, lList1.p[i].py, him);
                      libList[i] = gList[gMap[groupIDs[gx][gy]]].libC;
                      if ((libList[i] > treeLibLim) ||
                         ((libList[i] > (depthLimit - depth)) &&
                          (libList[i] > 2)))
			{
			*escape = TRUE;
			result = FALSE;
			goto one;
			}
                      undoTo(mark2);
                    }
              for (i = 1; i <= lList1.indx - 1; i++)
                for (j = i + 1; j <= lList1.indx; j++)
                  if (libList[i] < libList[j])
                    {
                      tl = libList[i];
                      libList[i] = libList[j];
                      libList[j] = tl;
                      tp = lList1.p[i];
                      lList1.p[i] = lList1.p[j];
                      lList1.p[j] = tp;
                    }
            }
          for (i = 1; i <= lList1.indx + 1; i++) /* try his responses */
            {
              mark2 = playMark;
              if (i <= lList1.indx) /* try his move */
                  {
                    tryPlay(lList1.p[i].px, lList1.p[i].py, him); /* play his response */
                    pause();
                    if (gList[gMap[groupIDs[lList1.p[i].px]
		                           [lList1.p[i].py]]].libC < 2)
                      goto two; /* a bogus move */
                  }
              else if (gList[gMap[groupIDs[gx][gy]]].libC <= 1)
			{
			result = TRUE;
			goto one;
			}
              if (gList[gMap[groupIDs[gx][gy]]].libC > treeLibLim)
                {
                  *escape = TRUE;
		  result = FALSE;
		  goto one;
                }
              if (gList[gMap[groupIDs[gx][gy]]].libC > 1)
                {  /* look at my responses */
                  sSpanGroup(gx, gy, &lList2); /* list his liberties */
                  dStart = lList2.indx + 1;
                  if (adjInAtari) /* he wins */
                     {
                       result = FALSE;
                       goto one;
                     }
                  if ((lList2.indx > 2) && adj2Libs) /* he wins */
                     {
                       result = FALSE;
                       goto one;
                     }
                  for (k = 1; k <= maxSPoint; k++)
                    libList[k] = -1;
                  if (utilPlayLevel > 4) /* account for diagonal moves */
                    {
                      listDiags(gx, gy, &dList);
                      j = 0;
                      k = lList2.indx;
                      while ((j < dList.indx) &&
                            (k < maxSPoint))
                        {
                          j = j + 1;
                          k = k + 1;
                          libList[k] = 100;
                              lList2.p[k].px = dList.p[j].px;
                              lList2.p[k].py = dList.p[j].py;
                        }
                      lList2.indx = k;
                    }
                  if (lList2.indx > 1) /* sort by increasing lib count */
                    {
                      for (k = 1; k <= lList2.indx; k++)
                        if (libList[k] != 100)     /* diags go last */
                            {
                              mark3 = playMark;
                              tryPlay(lList2.p[k].px, lList2.p[k].py, me);
                              libList[k] = gList[gMap[groupIDs[gx][gy]]].libC;
                              undoTo(mark3);
                            }
                      for (k = 1; k <= lList2.indx - 1; k++)
                        for (j = k + 1; j <= lList2.indx; j++)
                          if (libList[k] > libList[j])
                            {
                              tl = libList[k];
                              libList[k] = libList[j];
                              libList[j] = tl;
                              tp = lList2.p[k];
                              lList2.p[k] = lList2.p[j];
                              lList2.p[j] = tp;
                            }
                          else if ((libList[k] == libList[j]) &&
                                  (libList[k] == 1))
                            if (mtNbrs(lList2.p[k].px, lList2.p[k].py) <
                               mtNbrs(lList2.p[j].px, lList2.p[j].py))
                              {
                                tl = libList[k];
                                libList[k] = libList[j];
                                libList[j] = tl;
                                tp = lList2.p[k];
                                lList2.p[k] = lList2.p[j];
                                lList2.p[j] = tp;
                              }
                    }
                  for (j = 1; j <= lList2.indx; j++)
                    {
                      if (killTree(lList2.p[j].px, lList2.p[j].py, gx,
				gy, &esc, tkMark))
                        goto two; /* this kills him */
                      if (esc && (j >= dStart))
                        {
                          result = FALSE;
                          goto one; /* don't bother with more diags if escapes */
                        }
                    }
                  result = FALSE;  /* none of my responses kills him */
                  goto one;
                }
    two:
             undoTo(mark2);
           }
          result = TRUE; /* none of his responses saves him */
        }
    one:
      undoTo(curMark);
/*      sClearChar(sChar, rXor); */
      depth = depth - 1;
      return result;
    } /* killTree */

short tKillTree(tx, ty, gx, gy)
short tx, ty, gx, gy;
  { /* tKillTree */
    short tkMark, escape;
    tryCount = 0;
    tkMark = playMark;
    return killTree(tx, ty, gx, gy, &escape, tkMark);
  } /* tKillTree */

short killable(gx, gy, killx, killy)
short gx, gy, *killx, *killy;
{ /* killable */
#ifdef DEBUG
  printf( "killable\n" );
  showTrees = TRUE;
#endif
  dbStop = TRUE;
  him = bord[gx][gy]; /* find out who I am */
  me = -him;
/*  if (me == 1)
    sChar = '>';
  else
    sChar = '|'; */
/*  write(sChar); */
  depth = 1;
  topMark = playMark;
  sSpanGroup(gx, gy, &lList); /* find his liberties */
  if (lList.indx == 1)
    {
      *killx = lList.p[1].px;
      *killy = lList.p[1].py;
      return TRUE;
    }
  else if (lList.indx > treeLibLim)
    return FALSE;
  else if (adjInAtari)
    return FALSE;
  else if ((lList.indx > 2) && adj2Libs)
    return FALSE;
  else
    {
      for (i = 1; i <= maxSPoint; i++)
        libList[i] = -1;
      if (utilPlayLevel > 4) /* account for diagonal moves */
        {
          listDiags(gx, gy, &dList);
          j = 0;
          i = lList.indx;
          while ((j < dList.indx) &&
                (i < maxSPoint))
            {
              j = j + 1;
              i = i + 1;
              libList[i] = 100;
                  lList.p[i].px = dList.p[j].px;
                  lList.p[i].py = dList.p[j].py;
            }
          lList.indx = i;
        }
      if (lList.indx > 1) /* sort by increasing lib count */
        {
          for (i = 1; i <= lList.indx; i++)
            if (libList[i] != 100)  /* diags go last */
                {
                  mark2 = playMark;
                  tryPlay(lList.p[i].px, lList.p[i].py, me);
                  libList[i] = gList[gMap[groupIDs[gx][gy]]].libC;
                  undoTo(mark2);
                }
          for (i = 1; i <= lList.indx - 1; i++)
            for (j = i + 1; j <= lList.indx; j++)
              if (libList[i] > libList[j])
                {
                  tl = libList[i];
                  libList[i] = libList[j];
                  libList[j] = tl;
                  tp = lList.p[i];
                  lList.p[i] = lList.p[j];
                  lList.p[j] = tp;
                }
              else if ((libList[i] == libList[j]) &&
                      (libList[i] == 1))
                if (mtNbrs(lList.p[i].px, lList.p[i].py) <
                   mtNbrs(lList.p[j].px, lList.p[j].py))
                  {
                    tl = libList[i];
                    libList[i] = libList[j];
                    libList[j] = tl;
                    tp = lList.p[i];
                    lList.p[i] = lList.p[j];
                    lList.p[j] = tp;
                  }
        }
      for (i = 1; i <= lList.indx; i++)
        {
          if (legal[lList.p[i].px, lList.p[i].py])
            {
              *killx = lList.p[i].px;
              *killy = lList.p[i].py;
              if (tKillTree(*killx, *killy, gx, gy))
                {
/*                  sClearChar(sChar, rXor); */
                  return TRUE;
                }
            }
        }
      return FALSE;
    }
/*   sClearChar(sChar, rXor); */
} /* killable */

