/*
   Nodes builder by Rapha‰l Quinet <quinet@montefiore.ulg.ac.be>

   You are allowed to use any parts of this code in another program, as
   long as you give credits to the authors in the documentation and in
   the program itself.  Read the file README.1ST for more information.

   This program comes with absolutely no warranty.

   *------- PLEASE READ THE COMMENT AT THE END OF THIS FILE. -------*
   | If you use the algorithm or even some of the ideas taken from  |
   | this file, you must put a message in your program, so that the |
   | user knows that all or part of the algorithm comes from DEU.   |
   *------- PLEASE READ THE COMMENT AT THE END OF THIS FILE. -------*

   NODES.C - automatic builder for Nodes, Segs and SSectors.
*/

/* the includes */
#include "deu.h"
#include "levels.h"



/*
   display some informations while the user is waiting
*/

void ShowProgress( short objtype)
{
   static short SavedNumVertexes = 0;

   if (UseMouse)
      HideMousePointer();
   switch (objtype)
   {
   case OBJ_VERTEXES:
      DrawScreenBox3D( 0, 0, 203, 22);
      DrawScreenText( 10, 8, "Number of Vertices: %d", NumVertexes);
      break;
   case OBJ_SIDEDEFS:
      DrawScreenBox3D( 0, 30, 203, 52);
      DrawScreenText( 10, 38, "Number of SideDefs: %d", NumSideDefs);
      SavedNumVertexes = NumVertexes;
      break;
   case OBJ_SSECTORS:
      DrawScreenBox3D( 0, 60, 203, 92);
      DrawScreenText( 10, 68, "Number of Segs:     %d", NumSegs);
      DrawScreenText( 10, 78, "Number of SSectors: %d", NumSSectors);
      DrawScreenMeter( 225, 28, ScrMaxX - 10, 48, (float) NumSegs / (float) (NumSideDefs + NumVertexes - SavedNumVertexes));
      break;
   }
   if (UseMouse)
      ShowMousePointer();
}



/*
   find the point of intersection for two lines (return FALSE if there is none)
*/

Bool ComputeIntersection( short *x, short *y, SEPtr seg1, SEPtr seg2) /* SWAP - needs Vertexes */
{
   /* floating-point required because long integers cause errors */
   double x1  = Vertexes[ seg1->start].x;
   double y1  = Vertexes[ seg1->start].y;
   double dx1 = Vertexes[ seg1->end].x - Vertexes[ seg1->start].x;
   double dy1 = Vertexes[ seg1->end].y - Vertexes[ seg1->start].y;
   double x2  = Vertexes[ seg2->start].x;
   double y2  = Vertexes[ seg2->start].y;
   double dx2 = Vertexes[ seg2->end].x - Vertexes[ seg2->start].x;
   double dy2 = Vertexes[ seg2->end].y - Vertexes[ seg2->start].y;
   double d;

   d = dy1 * dx2 - dx1 * dy2;
   if (d != 0.0)
   {
      x1 = y1 * dx1 - x1 * dy1;
      x2 = y2 * dx2 - x2 * dy2;
      /* (*x, *y) = intersection */
      *x = (short) ((dx1 * x2 - dx2 * x1) / d);
      *y = (short) ((dy1 * x2 - dy2 * x1) / d);
      /* check if the intersection is not at one end of a Seg (vertex grid = 8*8) */
      if (*x >= Vertexes[ seg1->start].x - 7 && *x <= Vertexes[ seg1->start].x + 7 && *y >= Vertexes[ seg1->start].y - 7 && *y <= Vertexes[ seg1->start].y + 7)
      {
	 return FALSE; /* not a real intersection point (round-off error in a previous operation) */
      }
      if (*x >= Vertexes[ seg1->end].x - 7   && *x <= Vertexes[ seg1->end].x + 7   && *y >= Vertexes[ seg1->end].y - 7   && *y <= Vertexes[ seg1->end].y + 7  )
      {
	 return FALSE; /* not a real intersection point (round-off error in a previous operation) */
      }
      if (*x >= Vertexes[ seg2->start].x - 7 && *x <= Vertexes[ seg2->start].x + 7 && *y >= Vertexes[ seg2->start].y - 7 && *y <= Vertexes[ seg2->start].y + 7)
      {
	 return FALSE; /* not a real intersection point (round-off error in a previous operation) */
      }
      if (*x >= Vertexes[ seg2->end].x - 7   && *x <= Vertexes[ seg2->end].x + 7   && *y >= Vertexes[ seg2->end].y - 7   && *y <= Vertexes[ seg2->end].y + 7  )
      {
	 return FALSE; /* not a real intersection point (round-off error in a previous operation) */
      }
      return TRUE; /* intersection OK */
   }
   else
      return FALSE; /* parallel lines */
}



/*
   choose a nodeline amongst the list of Segs
*/

SEPtr FindNodeLine( SEPtr seglist) /* SWAP - needs Vertexes */
{
   short   splits;
#ifdef OLD_ALGORITHM
   short   minsplits = 32767;
#endif /* OLD_ALGORITHM */
   short   mindiff = 32767;
   short   num1, num2;
   SEPtr nodeline, bestnodeline;
   SEPtr curseg;
   long  x, y;
   long  dx, dy;
   long  a, b, c, d;
   short   dummyx, dummyy;
   /* ***DEBUG*** */
   static SEPtr lastnodeline = NULL;

   /* find nodeline - brute force: try with all Segs */
   bestnodeline = NULL;
   for (nodeline = seglist; nodeline; nodeline = nodeline->next)
   {
      /* compute x, y, dx, dy */
      x = Vertexes[ nodeline->start].x;
      y = Vertexes[ nodeline->start].y;
      dx = Vertexes[ nodeline->end].x - Vertexes[ nodeline->start].x;
      dy = Vertexes[ nodeline->end].y - Vertexes[ nodeline->start].y;
      /* compute number of splits */
      if (dx == 0 || dy == 0)
	 splits = 0;
      else
	 splits = 1; /* small penalty for oblique lines */
      num1 = 0;
      num2 = 0;
      for (curseg = seglist; curseg; curseg = curseg->next)
      {
	 if (curseg == nodeline)
	 {
	    num1++;
	    continue;
	 }
	 /* you love maths, don't you? */
	 a = ((long) Vertexes[ curseg->start].x - x) * dy;
	 b = ((long) Vertexes[ curseg->start].y - y) * dx;
	 c = ((long) Vertexes[ curseg->end].x - x) * dy;
	 d = ((long) Vertexes[ curseg->end].y - y) * dx;
	 if ((a != b) && (c != d) && ((a > b) != (c > d)) && ComputeIntersection( &dummyx, &dummyy, nodeline, curseg))
	 {
	    splits++; /* one more split */
	    num1++;
	    num2++;
	 }
	 else if ((a > b) || ((a == b) && (c > d))
		  || ((a == b) && (c == d) && ((dx > 0) == ((Vertexes[ curseg->end].x - Vertexes[ curseg->start].x) > 0)) && ((dy > 0) == ((Vertexes[ curseg->end].y - Vertexes[ curseg->start].y) > 0))))
	    num1++; /* one more Seg on the first (right) side */
	 else
	    num2++; /* one more Seg on the second (left) side */
#ifdef OLD_ALGORITHM
	 if (splits > minsplits)
	    break;  /* don't waste time */
#else
	 if (max( num1, num2) + SplitFactor * splits > mindiff)
	    break;  /* don't waste time */
#endif /* OLD_ALGORITHM */
      }

      /* there must be at least one Seg on each side */
      if (num1 > 0 && num2 > 0)
      {
#ifdef OLD_ALGORITHM
	 /* now, num1 = difference in number of Segs between two sides */
	 if (num1 > num2)
	    num1 = num1 - num2;
	 else
	    num1 = num2 - num1;
	 /* minimal number of splits = candidate for nodeline */
	 if (splits < minsplits || (splits == minsplits && num1 < mindiff))
	 {
	    minsplits = splits; /* minimal number of splits */
	    mindiff = num1; /* minimal difference between the two sides */
	    bestnodeline = nodeline; /* save the nodeline */
	 }
#else
	 /* now, num1 = rating for this nodeline */
	 num1 = max( num1, num2) + SplitFactor * splits;
	 /* this nodeline is better than the previous one */
	 if (num1 < mindiff)
	 {
	    mindiff = num1; /* save the rating */
	    bestnodeline = nodeline; /* save the nodeline */
	 }
#endif /* OLD_ALGORITHM */
      }
   }

   /* ***DEBUG*** */
   if (bestnodeline && bestnodeline == lastnodeline)
      ProgError( "nodeline picked twice (this is a BUG!)");
   lastnodeline = nodeline;

   return bestnodeline;
}



/*
   Move a Seg into a list and update the bounding box
*/

void StoreInSegList( SEPtr seg, SEPtr *seglist, SEPtr *slistend) /* SWAP - needs Vertexes */
{
   if (*seglist)
   {
      (*slistend)->next = seg;
      *slistend = (*slistend)->next;
   }
   else
   {
      *seglist = seg;
      *slistend = *seglist;
   }
   (*slistend)->next = NULL;
}



/*
   compute the bounding box (limits on X, Y) for a list of Segs
*/

void ComputeBoundingBox( SEPtr seglist, short *minx, short *maxx, short *miny, short *maxy) /* SWAP - needs Vertexes */
{
   SEPtr curseg;

   *maxx = -32767;
   *maxy = -32767;
   *minx = 32767;
   *miny = 32767;
   for (curseg = seglist; curseg; curseg = curseg->next)
   {
      if (Vertexes[ curseg->start].x < *minx)
	 *minx = Vertexes[ curseg->start].x;
      if (Vertexes[ curseg->start].x > *maxx)
	 *maxx = Vertexes[ curseg->start].x;
      if (Vertexes[ curseg->start].y < *miny)
	 *miny = Vertexes[ curseg->start].y;
      if (Vertexes[ curseg->start].y > *maxy)
	 *maxy = Vertexes[ curseg->start].y;

      if (Vertexes[ curseg->end].x < *minx)
	 *minx = Vertexes[ curseg->end].x;
      if (Vertexes[ curseg->end].x > *maxx)
	 *maxx = Vertexes[ curseg->end].x;
      if (Vertexes[ curseg->end].y < *miny)
	 *miny = Vertexes[ curseg->end].y;
      if (Vertexes[ curseg->end].y > *maxy)
	 *maxy = Vertexes[ curseg->end].y;
   }
}



/*
   create a SSector from a list of Segs
*/

short CreateSSector( SEPtr seglist)
{
   /* update the SSectors list */
   NumSSectors++;
   if (SSectors)
   {
      LastSSector->next = GetMemory( sizeof( struct SSector));
      LastSSector = LastSSector->next;
   }
   else
   {
      SSectors = GetMemory( sizeof( struct SSector));
      LastSSector = SSectors;
   }
   LastSSector->next = NULL;
   /* number of first Segment in this SubSector */
   LastSSector->first = NumSegs;
   /* update the Segs list */
   if (Segs == NULL)
      Segs = seglist;
   else
      LastSeg->next = seglist;
   NumSegs++;
   for (LastSeg = seglist; LastSeg->next; LastSeg = LastSeg->next)
      NumSegs++;
   /* total number of Segments in this SubSector */
   LastSSector->num = NumSegs - LastSSector->first;
   /* while the user is waiting... */
   ShowProgress( OBJ_SSECTORS);

   /* return the number of this SubSector */
   return NumSSectors - 1;
}



/*
   create all Nodes from a list of Segs
*/

Bool CreateNodes( NPtr *node_r, short *ssector_r, SEPtr seglist) /* SWAP - needs Vertexes */
{
   NPtr         node;
   SEPtr        segs1, segs2;
   static SEPtr nodeline, curseg;
   static long  a, b, c, d;
   static SEPtr lastseg1, lastseg2;

   /* new Node */
   node = GetMemory( sizeof( struct Node));

   /* find the best nodeline */
   nodeline = FindNodeLine( seglist);

   /* nodeline could not be found: return a SSector */
   if (nodeline == NULL)
   {
      *node_r = NULL;
      *ssector_r = CreateSSector( seglist) | 0x8000;
      return FALSE;
   }

   /* compute x, y, dx, dy */
   node->x = Vertexes[ nodeline->start].x;
   node->y = Vertexes[ nodeline->start].y;
   node->dx = Vertexes[ nodeline->end].x - node->x;
   node->dy = Vertexes[ nodeline->end].y - node->y;

   /* split seglist in segs1 and segs2 */
   segs1 = NULL;
   segs2 = NULL;
   while (seglist)
   {
      curseg = seglist;
      seglist = seglist->next;
      /* now, where is that old book about analytic geometry? */
      a = (long) (Vertexes[ curseg->start].x - node->x) * (long) (node->dy);
      b = (long) (Vertexes[ curseg->start].y - node->y) * (long) (node->dx);
      c = (long) (Vertexes[ curseg->end].x - node->x) * (long) (node->dy);
      d = (long) (Vertexes[ curseg->end].y - node->y) * (long) (node->dx);
      /* check if starting vertex is on the right side of the nodeline, */
      /* or if starting vertex is on the nodeline and ending vertex on the right side, */
      /* or if both are on the nodeline and the Seg has the same orientation as the nodeline. */
      if ((a > b) || ((a == b) && (c > d))
	  || ((a == b) && (c == d) && ((node->dx > 0) == ((Vertexes[ curseg->end].x - Vertexes[ curseg->start].x) > 0)) && ((node->dy > 0) == ((Vertexes[ curseg->end].y - Vertexes[ curseg->start].y) > 0))))
      {
	 /* the starting Vertex is on the first side (right) of the nodeline */
	 StoreInSegList( curseg, &segs1, &lastseg1);
	 if (c < d)
	 {
	    short newx, newy;

	    /* the ending Vertex is on the other side: split the Seg in two */
	    if (ComputeIntersection( &newx, &newy, nodeline, curseg))
	    {
	       InsertObject( OBJ_VERTEXES, -2, newx, newy);
	       StoreInSegList( GetFarMemory( sizeof( struct Seg)), &segs2, &lastseg2);
	       lastseg2->start = NumVertexes - 1;
	       lastseg2->end = lastseg1->end;
	       lastseg2->angle = lastseg1->angle;
	       lastseg2->linedef = lastseg1->linedef;
	       lastseg2->flip = lastseg1->flip;
	       lastseg2->dist = lastseg1->dist + ComputeDist( newx - Vertexes[ lastseg1->start].x, newy - Vertexes[ lastseg1->start].y);
	       lastseg1->end = NumVertexes - 1;
	       ShowProgress( OBJ_VERTEXES);
	    }
	 }
      }
      else
      {
	 /* the starting Vertex is on the second side (left) of the nodeline */
	 StoreInSegList( curseg, &segs2, &lastseg2);
	 if (c > d)
	 {
	    short newx, newy;

	    /* the ending Vertex is on the other side: split the Seg in two */
	    if (ComputeIntersection( &newx, &newy, nodeline, curseg))
	    {
	       InsertObject( OBJ_VERTEXES, -2, newx, newy);
	       StoreInSegList( GetFarMemory( sizeof( struct Seg)), &segs1, &lastseg1);
	       lastseg1->start = NumVertexes - 1;
	       lastseg1->end = lastseg2->end;
	       lastseg1->angle = lastseg2->angle;
	       lastseg1->linedef = lastseg2->linedef;
	       lastseg1->flip = lastseg2->flip;
	       lastseg1->dist = lastseg2->dist + ComputeDist( newx - Vertexes[ lastseg2->start].x, newy - Vertexes[ lastseg2->start].y);
	       lastseg2->end = NumVertexes - 1;
	       ShowProgress( OBJ_VERTEXES);
	    }
	 }
      }
   }

   /* now, we should have all the Segs in segs1 and segs2 (seglist is empty) */
   if (segs1 == NULL || segs2 == NULL)
      ProgError("could not split the Segs list (this is a BUG!)");

   /* compute bounding box limits for segs1 */
   ComputeBoundingBox( segs1, &(node->minx1), &(node->maxx1), &(node->miny1), &(node->maxy1));

   /* create Nodes or SSectors from segs1 */
   CreateNodes( &(node->node1), &(node->child1), segs1);

   /* compute bounding box limits for segs2 */
   ComputeBoundingBox( segs2, &(node->minx2), &(node->maxx2), &(node->miny2), &(node->maxy2));

   /* create Nodes or SSectors from segs2 */
   CreateNodes( &(node->node2), &(node->child2), segs2);

   /* this Node is OK */
   *node_r = node;
   *ssector_r = 0;
   return TRUE;
}


/*
   IF YOU ARE WRITING A DOOM EDITOR OR ANOTHER ADD-ON, PLEASE READ THIS:

   I spent a lot of time writing the Nodes builder.  There may be some bugs in
   it, but most of the code is OK.  If you steal any ideas from this program,
   put a prominent message in your own editor (i.e. it must be displayed when
   the program starts or in an "about" box) to make it CLEAR that some
   original ideas were taken from DEU.  You need not credit me.  Just credit
   DEU and its contributors.  Thanks.

   While everyone was talking about LineDefs, I had the idea of taking only
   the Segs into account, and creating the Segs directly from the SideDefs.
   Also, dividing the list of Segs in two after each call to CreateNodes makes
   the algorithm faster.  I use several other tricks, such as looking at the
   two ends of a Seg to see on which side of the nodeline it lies or if it
   should be split in two.  I took me a lot of time and efforts to do this.

   I give this algorithm to whoever wants to use it, but with this condition:
   if your program uses SOME of the IDEAS from DEU or the whole ALGORITHM, you
   MUST tell it to the user.  And if you post a message with all or parts of
   this algorithm in it, please post THIS NOTICE also.  I don't want to speak
   legalese; I hope that you understand me...  I kindly give the sources of my
   program to you: please be kind with me...

   If you need more information about this, here is my E-mail address:
   quinet@montefiore.ulg.ac.be (Rapha‰l Quinet).

   Short description of the algorithm:
     1 - Create one Seg for each SideDef: pick each LineDef in turn.  If it
	 has a "first" SideDef, then create a normal Seg.  If it has a
	 "second" SideDef, then create a flipped Seg.
     2 - Call CreateNodes with the current list of Segs.  The list of Segs is
	 the only argument to CreateNodes.
     3 - Save the Nodes, Segs and SSectors to disk.  Start with the leaves of
	 the Nodes tree and continue up to the root (last Node).

   CreateNodes does the following:
     1 - Pick a nodeline amongst the Segs (minimize the number of splits and
	 keep the tree as balanced as possible).
     2 - Move all Segs on the right of the nodeline in a list (segs1) and
	 move all Segs on the left of the nodeline in another list (segs2).
     3 - If the first list (segs1) contains references to more than one
	 Sector or if the angle between two adjacent Segs is greater than
	 180ø, then call CreateNodes with this (smaller) list.  Else, create
	 a SubSector with all these Segs.
     4 - Do the same for the second list (segs2).
     5 - Return the new node (its two children are already OK).

   Each time CreateSSector is called, the Segs are put in a global list.
   When there is no more Seg in CreateNodes' list, then they are all in the
   global list and ready to be saved to disk.

   Note: now that the nice guys at Id software have released their algorithm,
   I have changed the way CreateNodes work.  Instead of checking if the Segs
   list should be split, I try to find a nodeline.  If I found one, then I
   split the list of Segs and call CreateNodes on both lists.  Else, I just
   return a SSector which contains the list of Segs.
*/


/* end of file */
