/*
   Doom Editor Utility, by Brendon Wyber and Rapha‰l Quinet.

   You are allowed to use any parts of this code in another program, as
   long as you give credits to the authors in the documentation and in
   the program itself.  Read the file README.1ST for more information.

   This program comes with absolutely no warranty.

   OBJECTS.C - object handling routines.
*/

/* the includes */
#include "deu.h"
#include "levels.h"


/*
   highlight the selected objects
*/

void HighlightSelection( short objtype, SelPtr list) /* SWAP! */
{
   SelPtr cur;

   if (list == NULL)
      return;
   for (cur = list; cur; cur = cur->next)
      HighlightObject( objtype, cur->objnum, GREEN);
}



/*
   test if an object is in the selection list
*/

Bool IsSelected( SelPtr list, short objnum)
{
   SelPtr cur;

   for (cur = list; cur; cur = cur->next)
      if (cur->objnum == objnum)
	 return TRUE;
   return FALSE;
}



/*
   add an object to the selection list
*/

void SelectObject( SelPtr *list, short objnum)
{
   SelPtr cur;


   if (objnum < 0)
      ProgError( "BUG: SelectObject called with %d", objnum);
   cur = GetMemory( sizeof( struct SelectionList));
   cur->next = *list;
   cur->objnum = objnum;
   *list = cur;
}



/*
   remove an object from the selection list
*/

void UnSelectObject( SelPtr *list, short objnum)
{
   SelPtr cur, prev;

   if (objnum < 0)
      ProgError( "BUG: UnSelectObject called with %d", objnum);
   prev = NULL;
   cur = *list;
   while (cur)
   {
      if (cur->objnum == objnum)
      {
	 if (prev)
	    prev->next = cur->next;
	 else
	    *list = cur->next;
	 FreeMemory( cur);
	 if (prev)
	    cur = prev->next;
	 else
	    cur = NULL;
      }
      else
      {
	 prev = cur;
	 cur = cur->next;
      }
   }
}



/*
   forget the selection list
*/

void ForgetSelection( SelPtr *list)
{
   SelPtr cur, prev;

   cur = *list;
   while (cur)
   {
      prev = cur;
      cur = cur->next;
      FreeMemory( prev);
   }
   *list = NULL;
}



/*
   get the number of objets of a given type minus one
*/
short GetMaxObjectNum( short objtype)
{
   switch (objtype)
   {
   case OBJ_THINGS:
      return NumThings - 1;
   case OBJ_LINEDEFS:
      return NumLineDefs - 1;
   case OBJ_SIDEDEFS:
      return NumSideDefs - 1;
   case OBJ_VERTEXES:
      return NumVertexes - 1;
   case OBJ_SEGS:
      return NumSegs - 1;
   case OBJ_SSECTORS:
      return NumSSectors - 1;
   case OBJ_SECTORS:
      return NumSectors - 1;
   }
   return -1;
}


/*
   check if there is something of interest inside the given box
*/

short GetCurObject( short objtype, short x0, short y0, short x1, short y1) /* SWAP! */
{
   short n, m, cur, curx;
   short lx0, ly0, lx1, ly1;
   short midx, midy;

   cur = -1;
   if (x1 < x0)
   {
      n = x0;
      x0 = x1;
      x1 = n;
   }
   if (y1 < y0)
   {
      n = y0;
      y0 = y1;
      y1 = n;
   }

   switch (objtype)
   {
   case OBJ_THINGS:
      ObjectsNeeded( OBJ_THINGS, 0);
      for (n = 0; n < NumThings; n++)
	 if (Things[ n].xpos >= x0 && Things[ n].xpos <= x1 && Things[ n].ypos >= y0 && Things[ n].ypos <= y1)
	 {
	    cur = n;
	    break;
	 }
      break;
   case OBJ_VERTEXES:
      ObjectsNeeded( OBJ_VERTEXES, 0);
      for (n = 0; n < NumVertexes; n++)
	 if (Vertexes[ n].x >= x0 && Vertexes[ n].x <= x1 && Vertexes[ n].y >= y0 && Vertexes[ n].y <= y1)
	 {
	    cur = n;
	    break;
	 }
      break;
   case OBJ_LINEDEFS:
      ObjectsNeeded( OBJ_LINEDEFS, OBJ_VERTEXES, 0);
      for (n = 0; n < NumLineDefs; n++)
      {
	 if (IsLineDefInside( n, x0, y0, x1, y1))
	 {
	    cur = n;
	    break;
	 }
      }
      break;
   case OBJ_SECTORS:
      /* hack, hack...  I look for the first LineDef crossing an horizontal half-line drawn from the cursor */
      ObjectsNeeded( OBJ_LINEDEFS, OBJ_VERTEXES, 0);
      curx = MapMaxX + 1;
      cur = -1;
      midx = (x0 + x1) / 2;
      midy = (y0 + y1) / 2;
      for (n = 0; n < NumLineDefs; n++)
	 if ((Vertexes[ LineDefs[ n].start].y > midy) != (Vertexes[ LineDefs[ n].end].y > midy))
	 {
	    lx0 = Vertexes[ LineDefs[ n].start].x;
	    ly0 = Vertexes[ LineDefs[ n].start].y;
	    lx1 = Vertexes[ LineDefs[ n].end].x;
	    ly1 = Vertexes[ LineDefs[ n].end].y;
	    m = lx0 + (short) ((long) (midy - ly0) * (long) (lx1 - lx0) / (long) (ly1 - ly0));
	    if (m >= midx && m < curx)
	    {
	       curx = m;
	       cur = n;
	    }
	 }
      /* now look if this LineDef has a SideDef bound to one sector */
      if (cur >= 0)
      {
	 if (Vertexes[ LineDefs[ cur].start].y > Vertexes[ LineDefs[ cur].end].y)
	    cur = LineDefs[ cur].sidedef1;
	 else
	    cur = LineDefs[ cur].sidedef2;
	 if (cur >= 0)
	 {
	    ObjectsNeeded( OBJ_SIDEDEFS, 0);
	    cur = SideDefs[ cur].sector;
	 }
	 else
	    cur = -1;
      }
      else
	 cur = -1;
      break;
   }
   return cur;
}



/*
   select all objects inside a given box
*/

SelPtr SelectObjectsInBox( short objtype, short x0, short y0, short x1, short y1) /* SWAP! */
{
   short n, m;
   SelPtr list;

   list = NULL;
   if (x1 < x0)
   {
      n = x0;
      x0 = x1;
      x1 = n;
   }
   if (y1 < y0)
   {
      n = y0;
      y0 = y1;
      y1 = n;
   }

   switch (objtype)
   {
   case OBJ_THINGS:
      ObjectsNeeded( OBJ_THINGS, 0);
      for (n = 0; n < NumThings; n++)
	 if (Things[ n].xpos >= x0 && Things[ n].xpos <= x1 && Things[ n].ypos >= y0 && Things[ n].ypos <= y1)
	    SelectObject( &list, n);
      break;
   case OBJ_VERTEXES:
      ObjectsNeeded( OBJ_VERTEXES, 0);
      for (n = 0; n < NumVertexes; n++)
	 if (Vertexes[ n].x >= x0 && Vertexes[ n].x <= x1 && Vertexes[ n].y >= y0 && Vertexes[ n].y <= y1)
	    SelectObject( &list, n);
      break;
   case OBJ_LINEDEFS:
      ObjectsNeeded( OBJ_LINEDEFS, OBJ_VERTEXES, 0);
      for (n = 0; n < NumLineDefs; n++)
      {
	 /* the two ends of the line must be in the box */
	 m = LineDefs[ n].start;
	 if (Vertexes[ m].x < x0 || Vertexes[ m].x > x1 || Vertexes[ m].y < y0 || Vertexes[ m].y > y1)
	    continue;
	 m = LineDefs[ n].end;
	 if (Vertexes[ m].x < x0 || Vertexes[ m].x > x1 || Vertexes[ m].y < y0 || Vertexes[ m].y > y1)
	    continue;
	 SelectObject( &list, n);
      }
      break;
   case OBJ_SECTORS:
      /* hack: select all sectors... */
      for (n = 0; n < NumSectors; n++)
	 SelectObject( &list, n);
      /* ... then remove the unwanted ones from the list */
      ObjectsNeeded( OBJ_LINEDEFS, OBJ_SIDEDEFS, OBJ_VERTEXES, 0);
      for (n = 0; n < NumLineDefs; n++)
      {
	 m = LineDefs[ n].start;
	 if (Vertexes[ m].x < x0 || Vertexes[ m].x > x1 || Vertexes[ m].y < y0 || Vertexes[ m].y > y1)
	 {
	    m = LineDefs[ n].sidedef1;
	    if (m >= 0 && SideDefs[ m].sector >= 0)
	       UnSelectObject( &list, SideDefs[ m].sector);
	    m = LineDefs[ n].sidedef2;
	    if (m >= 0 && SideDefs[ m].sector >= 0)
	       UnSelectObject( &list, SideDefs[ m].sector);
	    continue;
	 }
	 m = LineDefs[ n].end;
	 if (Vertexes[ m].x < x0 || Vertexes[ m].x > x1 || Vertexes[ m].y < y0 || Vertexes[ m].y > y1)
	 {
	    m = LineDefs[ n].sidedef1;
	    if (m >= 0 && SideDefs[ m].sector >= 0)
	       UnSelectObject( &list, SideDefs[ m].sector);
	    m = LineDefs[ n].sidedef2;
	    if (m >= 0 && SideDefs[ m].sector >= 0)
	       UnSelectObject( &list, SideDefs[ m].sector);
	    continue;
	 }
      }
      break;
   }
   return list;
}



/*
   highlight the selected object
*/

void HighlightObject( short objtype, short objnum, short color) /* SWAP! */
{
   short  n, m;

   /* use XOR mode : drawing any line twice erases it */
/*   setwritemode( XOR_PUT);
*/   SetColor( color);
   switch ( objtype)
   {
   case OBJ_THINGS:
      ObjectsNeeded( OBJ_THINGS, 0);
      m = (GetThingRadius( Things[ objnum].type) * 3) / 2;
      DrawMapLine( Things[ objnum].xpos - m, Things[ objnum].ypos - m, Things[ objnum].xpos - m, Things[ objnum].ypos + m);
      DrawMapLine( Things[ objnum].xpos - m, Things[ objnum].ypos + m, Things[ objnum].xpos + m, Things[ objnum].ypos + m);
      DrawMapLine( Things[ objnum].xpos + m, Things[ objnum].ypos + m, Things[ objnum].xpos + m, Things[ objnum].ypos - m);
      DrawMapLine( Things[ objnum].xpos + m, Things[ objnum].ypos - m, Things[ objnum].xpos - m, Things[ objnum].ypos - m);
      DrawMapArrow( Things[ objnum].xpos, Things[ objnum].ypos, Things[ objnum].angle * 182);
      break;
   case OBJ_LINEDEFS:
      ObjectsNeeded( OBJ_LINEDEFS, OBJ_VERTEXES, 0);
      n = (Vertexes[ LineDefs[ objnum].start].x + Vertexes[ LineDefs[ objnum].end].x) / 2;
      m = (Vertexes[ LineDefs[ objnum].start].y + Vertexes[ LineDefs[ objnum].end].y) / 2;
      DrawMapLine( n, m, n + (Vertexes[ LineDefs[ objnum].end].y - Vertexes[ LineDefs[ objnum].start].y) / 3, m + (Vertexes[ LineDefs[ objnum].start].x - Vertexes[ LineDefs[ objnum].end].x) / 3);
/*      setlinestyle(SOLID_LINE, 0, THICK_WIDTH);
*/      DrawMapVector( Vertexes[ LineDefs[ objnum].start].x, Vertexes[ LineDefs[ objnum].start].y,
		     Vertexes[ LineDefs[ objnum].end].x, Vertexes[ LineDefs[ objnum].end].y);
      if (color != 12 && LineDefs[ objnum].tag > 0)
      {
	 for (m = 0; m < NumSectors; m++)
	    if (Sectors[ m].tag == LineDefs[ objnum].tag)
	       HighlightObject( OBJ_SECTORS, m, 12);
      }
/*      setlinestyle(SOLID_LINE, 0, NORM_WIDTH);
*/      break;
   case OBJ_VERTEXES:
      ObjectsNeeded( OBJ_VERTEXES, 0);
      DrawMapLine( Vertexes[ objnum].x - OBJSIZE * 2, Vertexes[ objnum].y - OBJSIZE * 2, Vertexes[ objnum].x - OBJSIZE * 2, Vertexes[ objnum].y + OBJSIZE * 2);
      DrawMapLine( Vertexes[ objnum].x - OBJSIZE * 2, Vertexes[ objnum].y + OBJSIZE * 2, Vertexes[ objnum].x + OBJSIZE * 2, Vertexes[ objnum].y + OBJSIZE * 2);
      DrawMapLine( Vertexes[ objnum].x + OBJSIZE * 2, Vertexes[ objnum].y + OBJSIZE * 2, Vertexes[ objnum].x + OBJSIZE * 2, Vertexes[ objnum].y - OBJSIZE * 2);
      DrawMapLine( Vertexes[ objnum].x + OBJSIZE * 2, Vertexes[ objnum].y - OBJSIZE * 2, Vertexes[ objnum].x - OBJSIZE * 2, Vertexes[ objnum].y - OBJSIZE * 2);
      break;
   case OBJ_SECTORS:
      ObjectsNeeded( OBJ_LINEDEFS, OBJ_SIDEDEFS, OBJ_VERTEXES, 0);
/*      setlinestyle(SOLID_LINE, 0, THICK_WIDTH);
*/      for (n = 0; n < NumLineDefs; n++)
	 if (SideDefs[ LineDefs[ n].sidedef1].sector == objnum || SideDefs[ LineDefs[ n].sidedef2].sector == objnum)
	    DrawMapLine( Vertexes[ LineDefs[ n].start].x, Vertexes[ LineDefs[ n].start].y,
			 Vertexes[ LineDefs[ n].end].x, Vertexes[ LineDefs[ n].end].y);
      if (color != 12 && Sectors[ objnum].tag > 0)
      {
	 for (m = 0; m < NumLineDefs; m++)
	    if (LineDefs[ m].tag == Sectors[ objnum].tag)
	       HighlightObject( OBJ_LINEDEFS, m, 12);
      }
/*      setlinestyle(SOLID_LINE, 0, NORM_WIDTH);
*/      break;
   }
   /* restore normal write mode */
/*   setwritemode( COPY_PUT);
*/
}



/*
   delete an object
*/

void DeleteObject( short objtype, short objnum) /* SWAP! */
{
   SelPtr list;

   list = NULL;
   SelectObject( &list, objnum);
   DeleteObjects( objtype, &list);
}



/*
   delete a group of objects (*recursive*)
*/

void DeleteObjects( short objtype, SelPtr *list) /* SWAP! */
{
   short    n, objnum;
   SelPtr cur;

   MadeChanges = TRUE;
   switch (objtype)
   {
   case OBJ_THINGS:
      ObjectsNeeded( OBJ_THINGS, 0);
      while (*list)
      {
	 objnum = (*list)->objnum;
	 /* delete the Thing */
	 NumThings--;
	 if (NumThings > 0)
	 {
	    for (n = objnum; n < NumThings; n++)
	       Things[ n] = Things[ n + 1];
	    Things = ResizeFarMemory( Things, NumThings * sizeof( struct Thing));
	 }
	 else
	 {
	    FreeFarMemory( Things);
	    Things = NULL;
	 }
	 for (cur = (*list)->next; cur; cur = cur->next)
	    if (cur->objnum > objnum)
	       cur->objnum--;
	 UnSelectObject( list, objnum);
      }
      break;
   case OBJ_VERTEXES:
      while (*list)
      {
	 objnum = (*list)->objnum;
	 /* delete the LineDefs bound to this Vertex and change the references */
	 ObjectsNeeded( OBJ_LINEDEFS, 0);
	 for (n = 0; n < NumLineDefs; n++)
	 {
	    if (LineDefs[ n].start == objnum || LineDefs[ n].end == objnum)
	       DeleteObject( OBJ_LINEDEFS, n--);
	    else
	    {
	       if (LineDefs[ n].start >= objnum)
		  LineDefs[ n].start--;
	       if (LineDefs[ n].end >= objnum)
		  LineDefs[ n].end--;
	    }
	 }
	 /* delete the Vertex */
	 ObjectsNeeded( OBJ_VERTEXES, 0);
	 NumVertexes--;
	 if (NumVertexes > 0)
	 {
	    for (n = objnum; n < NumVertexes; n++)
	       Vertexes[ n] = Vertexes[ n + 1];
	    Vertexes = ResizeFarMemory( Vertexes, NumVertexes * sizeof( struct Vertex));
	 }
	 else
	 {
	    FreeFarMemory( Vertexes);
	    Vertexes = NULL;
	 }
	 for (cur = (*list)->next; cur; cur = cur->next)
	    if (cur->objnum > objnum)
	       cur->objnum--;
	 UnSelectObject( list, objnum);
      }
      break;
   case OBJ_LINEDEFS:
      while (*list)
      {
	 ObjectsNeeded( OBJ_LINEDEFS, 0);
	 objnum = (*list)->objnum;
	 /* delete the two SideDefs bound to this LineDef */
	 if (LineDefs[ objnum].sidedef1 >= 0)
	 {
	    DeleteObject( OBJ_SIDEDEFS, LineDefs[ objnum].sidedef1);
	    ObjectsNeeded( OBJ_LINEDEFS, 0);
	 }
	 if (LineDefs[ objnum].sidedef2 >= 0)
	 {
	    DeleteObject( OBJ_SIDEDEFS, LineDefs[ objnum].sidedef2);
	    ObjectsNeeded( OBJ_LINEDEFS, 0);
	 }
	 /* delete the LineDef */
	 NumLineDefs--;
	 if (NumLineDefs > 0)
	 {
	    for (n = objnum; n < NumLineDefs; n++)
	       LineDefs[ n] = LineDefs[ n + 1];
	    LineDefs = ResizeFarMemory( LineDefs, NumLineDefs * sizeof( struct LineDef));
	 }
	 else
	 {
	    FreeFarMemory( LineDefs);
	    LineDefs = NULL;
	 }
	 for (cur = (*list)->next; cur; cur = cur->next)
	    if (cur->objnum > objnum)
	       cur->objnum--;
	 UnSelectObject( list, objnum);
      }
      break;
   case OBJ_SIDEDEFS:
      while (*list)
      {
	 objnum = (*list)->objnum;
	 /* change the LineDefs references */
	 ObjectsNeeded( OBJ_LINEDEFS, 0);
	 for (n = 0; n < NumLineDefs; n++)
	 {
	    if (LineDefs[ n].sidedef1 == objnum)
	       LineDefs[ n].sidedef1 = -1;
	    else if (LineDefs[ n].sidedef1 >= objnum)
	       LineDefs[ n].sidedef1--;
	    if (LineDefs[ n].sidedef2 == objnum)
	       LineDefs[ n].sidedef2 = -1;
	    else if (LineDefs[ n].sidedef2 >= objnum)
	       LineDefs[ n].sidedef2--;
	 }
	 /* delete the SideDef */
	 ObjectsNeeded( OBJ_SIDEDEFS, 0);
	 NumSideDefs--;
	 if (NumSideDefs > 0)
	 {
	    for (n = objnum; n < NumSideDefs; n++)
	       SideDefs[ n] = SideDefs[ n + 1];
	    SideDefs = ResizeFarMemory( SideDefs, NumSideDefs * sizeof( struct SideDef));
	 }
	 else
	 {
	    FreeFarMemory( SideDefs);
	    SideDefs = NULL;
	 }
	 for (cur = (*list)->next; cur; cur = cur->next)
	    if (cur->objnum > objnum)
	       cur->objnum--;
	 UnSelectObject( list, objnum);
      }
      MadeMapChanges = TRUE;
      break;
   case OBJ_SECTORS:
      while (*list)
      {
	 objnum = (*list)->objnum;
	 /* delete the SideDefs bound to this Sector and change the references */
	 ObjectsNeeded( OBJ_SIDEDEFS, 0);
	 for (n = 0; n < NumSideDefs; n++)
	    if (SideDefs[ n].sector == objnum)
	       DeleteObject( OBJ_SIDEDEFS, n--);
	    else if (SideDefs[ n].sector >= objnum)
	       SideDefs[ n].sector--;
	 /* delete the Sector */
	 ObjectsNeeded( OBJ_SECTORS, 0);
	 NumSectors--;
	 if (NumSectors > 0)
	 {
	    for (n = objnum; n < NumSectors; n++)
	       Sectors[ n] = Sectors[ n + 1];
	    Sectors = ResizeFarMemory( Sectors, NumSectors * sizeof( struct Sector));
	 }
	 else
	 {
	    FreeFarMemory( Sectors);
	    Sectors = NULL;
	 }
	 for (cur = (*list)->next; cur; cur = cur->next)
	    if (cur->objnum > objnum)
	       cur->objnum--;
	 UnSelectObject( list, objnum);
      }
      break;
   default:
      Beep();
   }
}



/*
   insert a new object
*/

void InsertObject(short objtype, short copyfrom, short xpos, short ypos) /* SWAP! */
{
   short last;

   ObjectsNeeded( objtype, 0);
   MadeChanges = TRUE;
   switch (objtype)
   {
   case OBJ_THINGS:
      last = NumThings++;
      if (last > 0)
	 Things = ResizeFarMemory( Things, (unsigned long) NumThings * sizeof( struct Thing));
      else
	 Things = GetFarMemory( sizeof( struct Thing));
      Things[ last].xpos = xpos;
      Things[ last].ypos = ypos;
      if (copyfrom >= 0)
      {
	 Things[ last].type  = Things[ copyfrom].type;
	 Things[ last].angle = Things[ copyfrom].angle;
	 Things[ last].when  = Things[ copyfrom].when;
      }
      else
      {
	 Things[ last].type  = THING_TROOPER;
	 Things[ last].angle = 0;
	 Things[ last].when  = 0x07;
      }
      break;
   case OBJ_VERTEXES:
      last = NumVertexes++;
      if (last > 0)
	 Vertexes = ResizeFarMemory( Vertexes, (unsigned long) NumVertexes * sizeof( struct Vertex));
      else
	 Vertexes = GetFarMemory( sizeof( struct Vertex));
      /* kluge: the Nodes builder will put -2 in copyfrom */
      if (copyfrom == -2)
      {
	 Vertexes[ last].x = xpos;
	 Vertexes[ last].y = ypos;
      }
      else
      {
	 Vertexes[ last].x = xpos & ~7;
	 Vertexes[ last].y = ypos & ~7;
	 if (Vertexes[ last].x < MapMinX)
	    MapMinX = Vertexes[ last].x;
	 if (Vertexes[ last].x > MapMaxX)
	    MapMaxX = Vertexes[ last].x;
	 if (Vertexes[ last].y < MapMinY)
	    MapMinY = Vertexes[ last].y;
	 if (Vertexes[ last].y > MapMaxY)
	    MapMaxY = Vertexes[ last].y;
	 MadeMapChanges = TRUE;
      }
      break;
   case OBJ_LINEDEFS:
      last = NumLineDefs++;
      if (last > 0)
	 LineDefs = ResizeFarMemory( LineDefs, (unsigned long) NumLineDefs * sizeof( struct LineDef));
      else
	 LineDefs = GetFarMemory( sizeof( struct LineDef));
      if (copyfrom >= 0)
      {
	 LineDefs[ last].start = LineDefs[ copyfrom].start;
	 LineDefs[ last].end = LineDefs[ copyfrom].end;
	 LineDefs[ last].flags = LineDefs[ copyfrom].flags;
	 LineDefs[ last].type = LineDefs[ copyfrom].type;
	 LineDefs[ last].tag = LineDefs[ copyfrom].tag;
      }
      else
      {
	 LineDefs[ last].start = 0;
	 LineDefs[ last].end = NumVertexes - 1;
	 LineDefs[ last].flags = 1;
	 LineDefs[ last].type = 0;
	 LineDefs[ last].tag = 0;
      }
      LineDefs[ last].sidedef1 = -1;
      LineDefs[ last].sidedef2 = -1;
      break;
   case OBJ_SIDEDEFS:
      /* SideDefs are added from the LineDefs menu, so "copyfrom" should always be -1.  But I test it anyway. */
      last = NumSideDefs++;
      if (last > 0)
	 SideDefs = ResizeFarMemory( SideDefs, (unsigned long) NumSideDefs * sizeof( struct SideDef));
      else
	 SideDefs = GetFarMemory( sizeof( struct SideDef));
      if (copyfrom >= 0)
      {
	 SideDefs[ last].xoff = SideDefs[ copyfrom].xoff;
	 SideDefs[ last].yoff = SideDefs[ copyfrom].yoff;
	 strncpy( SideDefs[ last].tex1, SideDefs[ copyfrom].tex1, 8);
	 strncpy( SideDefs[ last].tex2, SideDefs[ copyfrom].tex2, 8);
	 strncpy( SideDefs[ last].tex3, SideDefs[ copyfrom].tex3, 8);
	 SideDefs[ last].sector = SideDefs[ copyfrom].sector;
      }
      else
      {
	 SideDefs[ last].xoff = 0;
	 SideDefs[ last].yoff = 0;
	 strcpy( SideDefs[ last].tex1, "-");
	 strcpy( SideDefs[ last].tex2, "-");
	 strcpy( SideDefs[ last].tex3, DefaultWallTexture);
	 SideDefs[ last].sector = NumSectors - 1;
      }
      MadeMapChanges = TRUE;
      break;
   case OBJ_SECTORS:
      last = NumSectors++;
      if (last > 0)
	 Sectors = ResizeFarMemory( Sectors, (unsigned long) NumSectors * sizeof( struct Sector));
      else
	 Sectors = GetFarMemory( sizeof( struct Sector));
      if (copyfrom >= 0)
      {
	 Sectors[ last].floorh = Sectors[ copyfrom].floorh;
	 Sectors[ last].ceilh = Sectors[ copyfrom].ceilh;
	 strncpy( Sectors[ last].floort, Sectors[ copyfrom].floort, 8);
	 strncpy( Sectors[ last].ceilt, Sectors[ copyfrom].ceilt, 8);
	 Sectors[ last].light = Sectors[ copyfrom].light;
	 Sectors[ last].special = Sectors[ copyfrom].special;
	 Sectors[ last].tag = Sectors[ copyfrom].tag;
      }
      else
      {
	 Sectors[ last].floorh = DefaultFloorHeight;
	 Sectors[ last].ceilh = DefaultCeilingHeight;
	 strncpy( Sectors[ last].floort, DefaultFloorTexture, 8);
	 strncpy( Sectors[ last].ceilt, DefaultCeilingTexture, 8);
	 Sectors[ last].light = 255;
	 Sectors[ last].special = 0;
	 Sectors[ last].tag = 0;
      }
      break;
   default:
      Beep();
   }
}



/*
   check if a (part of a) LineDef is inside a given block
*/

Bool IsLineDefInside( short ldnum, short x0, short y0, short x1, short y1) /* SWAP - needs Vertexes & LineDefs */
{
   short lx0 = Vertexes[ LineDefs[ ldnum].start].x;
   short ly0 = Vertexes[ LineDefs[ ldnum].start].y;
   short lx1 = Vertexes[ LineDefs[ ldnum].end].x;
   short ly1 = Vertexes[ LineDefs[ ldnum].end].y;
   short i;

   /* do you like mathematics? */
   if (lx0 >= x0 && lx0 <= x1 && ly0 >= y0 && ly0 <= y1)
      return TRUE; /* the LineDef start is entirely inside the square */
   if (lx1 >= x0 && lx1 <= x1 && ly1 >= y0 && ly1 <= y1)
      return TRUE; /* the LineDef end is entirely inside the square */
   if ((ly0 > y0) != (ly1 > y0))
   {
      i = lx0 + (short) ( (long) (y0 - ly0) * (long) (lx1 - lx0) / (long) (ly1 - ly0));
      if (i >= x0 && i <= x1)
	 return TRUE; /* the LineDef crosses the y0 side (left) */
   }
   if ((ly0 > y1) != (ly1 > y1))
   {
      i = lx0 + (short) ( (long) (y1 - ly0) * (long) (lx1 - lx0) / (long) (ly1 - ly0));
      if (i >= x0 && i <= x1)
	 return TRUE; /* the LineDef crosses the y1 side (right) */
   }
   if ((lx0 > x0) != (lx1 > x0))
   {
      i = ly0 + (short) ( (long) (x0 - lx0) * (long) (ly1 - ly0) / (long) (lx1 - lx0));
      if (i >= y0 && i <= y1)
	 return TRUE; /* the LineDef crosses the x0 side (down) */
   }
   if ((lx0 > x1) != (lx1 > x1))
   {
      i = ly0 + (short) ( (long) (x1 - lx0) * (long) (ly1 - ly0) / (long) (lx1 - lx0));
      if (i >= y0 && i <= y1)
	 return TRUE; /* the LineDef crosses the x1 side (up) */
   }
   return FALSE;
}



/*
   get the Sector number of the SideDef opposite to this SideDef
   (returns -1 if it cannot be found)
*/

short GetOppositeSector( short ld1, Bool firstside) /* SWAP! */
{
   short x0, y0, dx0, dy0;
   short x1, y1, dx1, dy1;
   short x2, y2, dx2, dy2;
   short ld2, dist;
   short bestld, bestdist, bestmdist;

   /* get the coords for this LineDef */
   ObjectsNeeded( OBJ_LINEDEFS, OBJ_VERTEXES, 0);
   x0  = Vertexes[ LineDefs[ ld1].start].x;
   y0  = Vertexes[ LineDefs[ ld1].start].y;
   dx0 = Vertexes[ LineDefs[ ld1].end].x - x0;
   dy0 = Vertexes[ LineDefs[ ld1].end].y - y0;

   /* find the normal vector for this LineDef */
   x1  = (dx0 + x0 + x0) / 2;
   y1  = (dy0 + y0 + y0) / 2;
   if (firstside == TRUE)
   {
     dx1 = dy0;
     dy1 = -dx0;
   }
   else
   {
     dx1 = -dy0;
     dy1 = dx0;
   }

   bestld = -1;
   /* use a parallel to an axis instead of the normal vector (faster method) */
   if (abs( dy1) > abs( dx1))
   {
      if (dy1 > 0)
      {
	 /* get the nearest LineDef in that direction (increasing Y's: North) */
	 bestdist = 32767;
	 bestmdist = 32767;
	 for (ld2 = 0; ld2 < NumLineDefs; ld2++)
	    if (ld2 != ld1 && ((Vertexes[ LineDefs[ ld2].start].x > x1) != (Vertexes[ LineDefs[ ld2].end].x > x1)))
	    {
	       x2  = Vertexes[ LineDefs[ ld2].start].x;
	       y2  = Vertexes[ LineDefs[ ld2].start].y;
	       dx2 = Vertexes[ LineDefs[ ld2].end].x - x2;
	       dy2 = Vertexes[ LineDefs[ ld2].end].y - y2;
	       dist = y2 + (short) ((long) (x1 - x2) * (long) dy2 / (long) dx2);
	       if (dist > y1 && (dist < bestdist || (dist == bestdist && (y2 + dy2 / 2) < bestmdist)))
	       {
		  bestld = ld2;
		  bestdist = dist;
		  bestmdist = y2 + dy2 / 2;
	       }
	    }
      }
      else
      {
	 /* get the nearest LineDef in that direction (decreasing Y's: South) */
	 bestdist = -32767;
	 bestmdist = -32767;
	 for (ld2 = 0; ld2 < NumLineDefs; ld2++)
	    if (ld2 != ld1 && ((Vertexes[ LineDefs[ ld2].start].x > x1) != (Vertexes[ LineDefs[ ld2].end].x > x1)))
	    {
	       x2  = Vertexes[ LineDefs[ ld2].start].x;
	       y2  = Vertexes[ LineDefs[ ld2].start].y;
	       dx2 = Vertexes[ LineDefs[ ld2].end].x - x2;
	       dy2 = Vertexes[ LineDefs[ ld2].end].y - y2;
	       dist = y2 + (short) ((long) (x1 - x2) * (long) dy2 / (long) dx2);
	       if (dist < y1 && (dist > bestdist || (dist == bestdist && (y2 + dy2 / 2) > bestmdist)))
	       {
		  bestld = ld2;
		  bestdist = dist;
		  bestmdist = y2 + dy2 / 2;
	       }
	    }
      }
   }
   else
   {
      if (dx1 > 0)
      {
	 /* get the nearest LineDef in that direction (increasing X's: East) */
	 bestdist = 32767;
	 bestmdist = 32767;
	 for (ld2 = 0; ld2 < NumLineDefs; ld2++)
	    if (ld2 != ld1 && ((Vertexes[ LineDefs[ ld2].start].y > y1) != (Vertexes[ LineDefs[ ld2].end].y > y1)))
	    {
	       x2  = Vertexes[ LineDefs[ ld2].start].x;
	       y2  = Vertexes[ LineDefs[ ld2].start].y;
	       dx2 = Vertexes[ LineDefs[ ld2].end].x - x2;
	       dy2 = Vertexes[ LineDefs[ ld2].end].y - y2;
	       dist = x2 + (short) ((long) (y1 - y2) * (long) dx2 / (long) dy2);
	       if (dist > x1 && (dist < bestdist || (dist == bestdist && (x2 + dx2 / 2) < bestmdist)))
	       {
		  bestld = ld2;
		  bestdist = dist;
		  bestmdist = x2 + dx2 / 2;
	       }
	    }
      }
      else
      {
	 /* get the nearest LineDef in that direction (decreasing X's: West) */
	 bestdist = -32767;
	 bestmdist = -32767;
	 for (ld2 = 0; ld2 < NumLineDefs; ld2++)
	    if (ld2 != ld1 && ((Vertexes[ LineDefs[ ld2].start].y > y1) != (Vertexes[ LineDefs[ ld2].end].y > y1)))
	    {
	       x2  = Vertexes[ LineDefs[ ld2].start].x;
	       y2  = Vertexes[ LineDefs[ ld2].start].y;
	       dx2 = Vertexes[ LineDefs[ ld2].end].x - x2;
	       dy2 = Vertexes[ LineDefs[ ld2].end].y - y2;
	       dist = x2 + (short) ((long) (y1 - y2) * (long) dx2 / (long) dy2);
	       if (dist < x1 && (dist > bestdist || (dist == bestdist && (x2 + dx2 / 2) > bestmdist)))
	       {
		  bestld = ld2;
		  bestdist = dist;
		  bestmdist = x2 + dx2 / 2;
	       }
	    }
      }
   }

   /* no intersection: the LineDef was pointing outwards! */
   if (bestld < 0)
      return -1;

   /* now look if this LineDef has a SideDef bound to one sector */
   if (abs( dy1) > abs( dx1))
   {
      if ((Vertexes[ LineDefs[ bestld].start].x < Vertexes[ LineDefs[ bestld].end].x) == (dy1 > 0))
	 x0 = LineDefs[ bestld].sidedef1;
      else
	 x0 = LineDefs[ bestld].sidedef2;
   }
   else
   {
      if ((Vertexes[ LineDefs[ bestld].start].y < Vertexes[ LineDefs[ bestld].end].y) != (dx1 > 0))
	 x0 = LineDefs[ bestld].sidedef1;
      else
	 x0 = LineDefs[ bestld].sidedef2;
   }

   /* there is no SideDef on this side of the LineDef! */
   if (x0 < 0)
      return -1;

   /* OK, we got it -- return the Sector number */
   ObjectsNeeded( OBJ_SIDEDEFS, 0);
   return SideDefs[ x0].sector;
}



/*
   copy a group of objects to a new position
*/

void CopyObjects( short objtype, SelPtr obj) /* SWAP! */
{
   short        n, m;
   SelPtr     cur;
   SelPtr     list1, list2;
   SelPtr     ref1, ref2;

   if (obj == NULL)
      return;
   ObjectsNeeded( objtype, 0);
   /* copy the object(s) */
   switch (objtype)
   {
      case OBJ_THINGS:
	 for (cur = obj; cur; cur = cur->next)
	 {
	    InsertObject( OBJ_THINGS, cur->objnum, Things[ cur->objnum].xpos, Things[ cur->objnum].ypos);
	    cur->objnum = NumThings - 1;
	 }
	 MadeChanges = TRUE;
	 break;

      case OBJ_VERTEXES:
	 for (cur = obj; cur; cur = cur->next)
	 {
	    InsertObject( OBJ_VERTEXES, cur->objnum, Vertexes[ cur->objnum].x, Vertexes[ cur->objnum].y);
	    cur->objnum = NumVertexes - 1;
	 }
	 MadeChanges = TRUE;
	 MadeMapChanges = TRUE;
	 break;

      case OBJ_LINEDEFS:
	 list1 = NULL;
	 list2 = NULL;
	 /* create the LineDefs */
	 for (cur = obj; cur; cur = cur->next)
	 {
	    InsertObject( OBJ_LINEDEFS, cur->objnum, 0, 0);
	    cur->objnum = NumLineDefs - 1;
	    if (!IsSelected( list1, LineDefs[ cur->objnum].start))
	    {
	       SelectObject( &list1, LineDefs[ cur->objnum].start);
	       SelectObject( &list2, LineDefs[ cur->objnum].start);
	    }
	    if (!IsSelected( list1, LineDefs[ cur->objnum].end))
	    {
	       SelectObject( &list1, LineDefs[ cur->objnum].end);
	       SelectObject( &list2, LineDefs[ cur->objnum].end);
	    }
	 }
	 /* create the Vertices */
	 CopyObjects( OBJ_VERTEXES, list2);
	 ObjectsNeeded( OBJ_LINEDEFS, 0);
	 /* update the references to the Vertexes */
	 for (ref1 = list1, ref2 = list2; ref1 && ref2; ref1 = ref1->next, ref2 = ref2->next)
	 {
	    for (cur = obj; cur; cur = cur->next)
	    {
	       if (ref1->objnum == LineDefs[ cur->objnum].start)
		  LineDefs[ cur->objnum].start = ref2->objnum;
	       if (ref1->objnum == LineDefs[ cur->objnum].end)
		  LineDefs[ cur->objnum].end = ref2->objnum;
	    }
	 }
	 ForgetSelection( &list1);
	 ForgetSelection( &list2);
	 break;

      case OBJ_SECTORS:
	 ObjectsNeeded( OBJ_LINEDEFS, OBJ_SIDEDEFS, 0);
	 list1 = NULL;
	 list2 = NULL;
	 /* create the LineDefs (and Vertices) */
	 for (cur = obj; cur; cur = cur->next)
	 {
	    for (n = 0; n < NumLineDefs; n++)
	       if ( (((m = LineDefs[ n].sidedef1) >= 0 && SideDefs[ m].sector == cur->objnum)
		  || ((m = LineDefs[ n].sidedef2) >= 0 && SideDefs[ m].sector == cur->objnum))
		 && ! IsSelected( list1, n))
	       {
		  SelectObject( &list1, n);
		  SelectObject( &list2, n);
	       }
	 }
	 CopyObjects( OBJ_LINEDEFS, list2);
	 /* create the SideDefs */
	 ObjectsNeeded( OBJ_LINEDEFS, 0);
	 for (ref1 = list1, ref2 = list2; ref1 && ref2; ref1 = ref1->next, ref2 = ref2->next)
	 {
	    if ((n = LineDefs[ ref1->objnum].sidedef1) >= 0)
	    {
	       InsertObject( OBJ_SIDEDEFS, n, 0, 0);
	       n = NumSideDefs - 1;
	       ObjectsNeeded( OBJ_LINEDEFS, 0);
	       LineDefs[ ref2->objnum].sidedef1 = n;
	    }
	    if ((m = LineDefs[ ref1->objnum].sidedef2) >= 0)
	    {
	       InsertObject( OBJ_SIDEDEFS, m, 0, 0);
	       m = NumSideDefs - 1;
	       ObjectsNeeded( OBJ_LINEDEFS, 0);
	       LineDefs[ ref2->objnum].sidedef2 = m;
	    }
	    ref1->objnum = n;
	    ref2->objnum = m;
	 }
	 /* create the Sectors */
	 for (cur = obj; cur; cur = cur->next)
	 {
	    InsertObject( OBJ_SECTORS, cur->objnum, 0, 0);
	    ObjectsNeeded( OBJ_SIDEDEFS, 0);
	    for (ref1 = list1, ref2 = list2; ref1 && ref2; ref1 = ref1->next, ref2 = ref2->next)
	    {
	       if (ref1->objnum >= 0 && SideDefs[ ref1->objnum].sector == cur->objnum)
		  SideDefs[ ref1->objnum].sector = NumSectors - 1;
	       if (ref2->objnum >= 0 && SideDefs[ ref2->objnum].sector == cur->objnum)
		  SideDefs[ ref2->objnum].sector = NumSectors - 1;
	    }
	    cur->objnum = NumSectors - 1;
	 }
	 ForgetSelection( &list1);
	 ForgetSelection( &list2);
	 break;
   }
}



/*
   move a group of objects to a new position
   (must be called with obj = NULL before moving the objects)
*/

Bool MoveObjectsToCoords( short objtype, SelPtr obj, short newx, short newy, short grid) /* SWAP! */
{
   short        n, m;
   short        dx, dy;
   SelPtr     cur, vertices;
   static short refx, refy; /* previous position */

   ObjectsNeeded( objtype, 0);
   if (grid > 0)
   {
      newx = (newx + grid / 2) & ~(grid - 1);
      newy = (newy + grid / 2) & ~(grid - 1);
   }

   /* only update the reference point? */
   if (obj == NULL)
   {
      refx = newx;
      refy = newy;
      return TRUE;
   }
   /* compute the displacement */
   dx = newx - refx;
   dy = newy - refy;
   /* nothing to do? */
   if (dx == 0 && dy == 0)
      return FALSE;

   /* move the object(s) */
   switch (objtype)
   {
      case OBJ_THINGS:
	 for (cur = obj; cur; cur = cur->next)
	 {
	    Things[ cur->objnum].xpos += dx;
	    Things[ cur->objnum].ypos += dy;
	 }
	 refx = newx;
	 refy = newy;
	 MadeChanges = TRUE;
	 break;
      case OBJ_VERTEXES:
	 for (cur = obj; cur; cur = cur->next)
	 {
	    Vertexes[ cur->objnum].x += dx;
	    Vertexes[ cur->objnum].y += dy;
	 }
	 refx = newx;
	 refy = newy;
	 MadeChanges = TRUE;
	 MadeMapChanges = TRUE;
	 break;
      case OBJ_LINEDEFS:
	 vertices = NULL;
	 for (cur = obj; cur; cur = cur->next)
	 {
	    if (!IsSelected( vertices, LineDefs[ cur->objnum].start))
	       SelectObject( &vertices, LineDefs[ cur->objnum].start);
	    if (!IsSelected( vertices, LineDefs[ cur->objnum].end))
	       SelectObject( &vertices, LineDefs[ cur->objnum].end);
	 }
	 MoveObjectsToCoords( OBJ_VERTEXES, vertices, newx, newy, grid);
	 ForgetSelection( &vertices);
	 break;
      case OBJ_SECTORS:
	 ObjectsNeeded( OBJ_LINEDEFS, OBJ_SIDEDEFS, 0);
	 vertices = NULL;
	 for (cur = obj; cur; cur = cur->next)
	 {
	    for (n = 0; n < NumLineDefs; n++)
	       if (((m = LineDefs[ n].sidedef1) >= 0 && SideDefs[ m].sector == cur->objnum)
		|| ((m = LineDefs[ n].sidedef2) >= 0 && SideDefs[ m].sector == cur->objnum))
	       {
		  if (!IsSelected( vertices, LineDefs[ n].start))
		     SelectObject( &vertices, LineDefs[ n].start);
		  if (!IsSelected( vertices, LineDefs[ n].end))
		     SelectObject( &vertices, LineDefs[ n].end);
	       }
	 }
	 MoveObjectsToCoords( OBJ_VERTEXES, vertices, newx, newy, grid);
	 ForgetSelection( &vertices);
	 break;
   }
   return TRUE;
}



/*
   get the coordinates (approx.) of an object
*/

void GetObjectCoords( short objtype, short objnum, short *xpos, short *ypos) /* SWAP! */
{
   short  n, v1, v2, sd1, sd2;
   long accx, accy, num;

   switch (objtype)
   {
      case OBJ_THINGS:
	 ObjectsNeeded( OBJ_THINGS, 0);
	 *xpos = Things[ objnum].xpos;
	 *ypos = Things[ objnum].ypos;
	 break;
      case OBJ_VERTEXES:
	 ObjectsNeeded( OBJ_VERTEXES, 0);
	 *xpos = Vertexes[ objnum].x;
	 *ypos = Vertexes[ objnum].y;
	 break;
      case OBJ_LINEDEFS:
	 ObjectsNeeded( OBJ_LINEDEFS, 0);
	 v1 = LineDefs[ objnum].start;
	 v2 = LineDefs[ objnum].end;
	 ObjectsNeeded( OBJ_VERTEXES, 0);
	 *xpos = (Vertexes[ v1].x + Vertexes[ v2].x) / 2;
	 *ypos = (Vertexes[ v1].y + Vertexes[ v2].y) / 2;
	 break;
      case OBJ_SIDEDEFS:
	 ObjectsNeeded( OBJ_LINEDEFS, 0);
	 for (n = 0; n < NumLineDefs; n++)
	    if (LineDefs[ n].sidedef1 == objnum || LineDefs[ n].sidedef2 == objnum)
	    {
	       v1 = LineDefs[ n].start;
	       v2 = LineDefs[ n].end;
	       ObjectsNeeded( OBJ_VERTEXES, 0);
	       *xpos = (Vertexes[ v1].x + Vertexes[ v2].x) / 2;
	       *ypos = (Vertexes[ v1].y + Vertexes[ v2].y) / 2;
	       return;
	    }
	 *xpos = (MapMinX + MapMaxX) / 2;
	 *ypos = (MapMinY + MapMaxY) / 2;
      case OBJ_SECTORS:
	 accx = 0L;
	 accy = 0L;
	 num = 0L;
	 for (n = 0; n < NumLineDefs; n++)
	 {
	    ObjectsNeeded( OBJ_LINEDEFS, 0);
	    sd1 = LineDefs[ n].sidedef1;
	    sd2 = LineDefs[ n].sidedef2;
	    v1 = LineDefs[ n].start;
	    v2 = LineDefs[ n].end;
	    ObjectsNeeded( OBJ_SIDEDEFS, 0);
	    if ((sd1 >= 0 && SideDefs[ sd1].sector == objnum) || (sd2 >= 0 && SideDefs[ sd2].sector == objnum))
	    {
	       ObjectsNeeded( OBJ_VERTEXES, 0);
	       /* if the Sector is closed, all Vertices will be counted twice */
	       accx += (long) Vertexes[ v1].x;
	       accy += (long) Vertexes[ v1].y;
	       num++;
	       accx += (long) Vertexes[ v2].x;
	       accy += (long) Vertexes[ v2].y;
	       num++;
	    }
	 }
	 if (num > 0)
	 {
	    *xpos = (short) ((accx + num / 2L) / num);
	    *ypos = (short) ((accy + num / 2L) / num);
	 }
	 else
	 {
	    *xpos = (MapMinX + MapMaxX) / 2;
	    *ypos = (MapMinY + MapMaxY) / 2;
	 }
	 break;
   }
}



/*
   rotate and scale a group of objects around the center of gravity
*/

void RotateAndScaleObjects( short objtype, SelPtr obj, double angle, double scale) /* SWAP! */
{
   short    n, m;
   short    dx, dy;
   short    centerx, centery;
   long   accx, accy, num;
   SelPtr cur, vertices;

   if (obj == NULL)
      return;
   ObjectsNeeded( objtype, 0);

   switch (objtype)
   {
      case OBJ_THINGS:
	 accx = 0L;
	 accy = 0L;
	 num = 0L;
	 for (cur = obj; cur; cur = cur->next)
	 {
	    accx += (long) Things[ cur->objnum].xpos;
	    accy += (long) Things[ cur->objnum].ypos;
	    num++;
	 }
	 centerx = (short) ((accx + num / 2L) / num);
	 centery = (short) ((accy + num / 2L) / num);
	 for (cur = obj; cur; cur = cur->next)
	 {
	    dx = Things[ cur->objnum].xpos - centerx;
	    dy = Things[ cur->objnum].ypos - centery;
	    RotateAndScaleCoords( &dx, &dy, angle, scale);
	    Things[ cur->objnum].xpos = centerx + dx;
	    Things[ cur->objnum].ypos = centery + dy;
	 }
	 MadeChanges = TRUE;
	 break;
      case OBJ_VERTEXES:
	 accx = 0L;
	 accy = 0L;
	 num = 0L;
	 for (cur = obj; cur; cur = cur->next)
	 {
	    accx += (long) Vertexes[ cur->objnum].x;
	    accy += (long) Vertexes[ cur->objnum].y;
	    num++;
	 }
	 centerx = (short) ((accx + num / 2L) / num);
	 centery = (short) ((accy + num / 2L) / num);
	 for (cur = obj; cur; cur = cur->next)
	 {
	    dx = Vertexes[ cur->objnum].x - centerx;
	    dy = Vertexes[ cur->objnum].y - centery;
	    RotateAndScaleCoords( &dx, &dy, angle, scale);
	    Vertexes[ cur->objnum].x = (centerx + dx + 4) & ~7;
	    Vertexes[ cur->objnum].y = (centery + dy + 4) & ~7;
	 }
	 MadeChanges = TRUE;
	 MadeMapChanges = TRUE;
	 break;
      case OBJ_LINEDEFS:
	 vertices = NULL;
	 for (cur = obj; cur; cur = cur->next)
	 {
	    if (!IsSelected( vertices, LineDefs[ cur->objnum].start))
	       SelectObject( &vertices, LineDefs[ cur->objnum].start);
	    if (!IsSelected( vertices, LineDefs[ cur->objnum].end))
	       SelectObject( &vertices, LineDefs[ cur->objnum].end);
	 }
	 RotateAndScaleObjects( OBJ_VERTEXES, vertices, angle, scale);
	 ForgetSelection( &vertices);
	 break;
      case OBJ_SECTORS:
	 ObjectsNeeded( OBJ_LINEDEFS, OBJ_SIDEDEFS, 0);
	 vertices = NULL;
	 for (cur = obj; cur; cur = cur->next)
	 {
	    for (n = 0; n < NumLineDefs; n++)
	       if (((m = LineDefs[ n].sidedef1) >= 0 && SideDefs[ m].sector == cur->objnum)
		|| ((m = LineDefs[ n].sidedef2) >= 0 && SideDefs[ m].sector == cur->objnum))
	       {
		  if (!IsSelected( vertices, LineDefs[ n].start))
		     SelectObject( &vertices, LineDefs[ n].start);
		  if (!IsSelected( vertices, LineDefs[ n].end))
		     SelectObject( &vertices, LineDefs[ n].end);
	       }
	 }
	 RotateAndScaleObjects( OBJ_VERTEXES, vertices, angle, scale);
	 ForgetSelection( &vertices);
	 break;
   }
}



/*
   find a free tag number
*/

short FindFreeTag() /* SWAP! */
{
   short  tag, n;
   Bool ok;

   ObjectsNeeded( OBJ_LINEDEFS, OBJ_SECTORS, 0);
   tag = 1;
   ok = FALSE;
   while (! ok)
   {
      ok = TRUE;
      for (n = 0; n < NumLineDefs; n++)
	 if (LineDefs[ n].tag == tag)
	 {
	    ok = FALSE;
	    break;
	 }
      if (ok)
	 for (n = 0; n < NumSectors; n++)
	    if (Sectors[ n].tag == tag)
	    {
	       ok = FALSE;
	       break;
	    }
      tag++;
   }
   return tag - 1;
}



/*
   flip one or several LineDefs
*/

void FlipLineDefs( SelPtr obj, Bool swapvertices) /* SWAP! */
{
   SelPtr cur;
   short    tmp;

   ObjectsNeeded( OBJ_LINEDEFS, 0);
   for (cur = obj; cur; cur = cur->next)
   {
      if (swapvertices)
      {
	 /* swap starting and ending Vertices */
	 tmp = LineDefs[ cur->objnum].end;
	 LineDefs[ cur->objnum].end = LineDefs[ cur->objnum].start;
	 LineDefs[ cur->objnum].start = tmp;
      }
      /* swap first and second SideDefs */
      tmp = LineDefs[ cur->objnum].sidedef1;
      LineDefs[ cur->objnum].sidedef1 = LineDefs[ cur->objnum].sidedef2;
      LineDefs[ cur->objnum].sidedef2 = tmp;
   }
   MadeChanges = TRUE;
   MadeMapChanges = TRUE;
}



/*
   delete a Vertex and join the two LineDefs
*/

void DeleteVerticesJoinLineDefs( SelPtr obj) /* SWAP! */
{
   short    lstart, lend, l;
   SelPtr cur;
   char   msg[ 80];

   ObjectsNeeded( OBJ_LINEDEFS, 0);
   while (obj != NULL)
   {
      cur = obj;
      obj = obj->next;
      lstart = -1;
      lend = -1;
      for (l = 0; l < NumLineDefs; l++)
      {
	 if (LineDefs[ l].start == cur->objnum)
	 {
	    if (lstart == -1)
	       lstart = l;
	    else
	       lstart = -2;
	 }
	 if (LineDefs[ l].end == cur->objnum)
	 {
	    if (lend == -1)
	       lend = l;
	    else
	       lend = -2;
	 }
      }
      if (lstart < 0 || lend < 0)
      {
	 Beep();
	 sprintf(msg, "[1][Cannot delete Vertex #%d| and join the LineDefs. The Vertex must |be the start of one LineDef and| the end of another.][Oh]", cur->objnum);
     form_alert(1,msg);
	 continue;
      }
      LineDefs[ lend].end = LineDefs[ lstart].end;
      DeleteObject( OBJ_LINEDEFS, lstart);
      DeleteObject( OBJ_VERTEXES, cur->objnum);
      MadeChanges = TRUE;
      MadeMapChanges = TRUE;
   }
}



/*
   merge several vertices into one
*/

void MergeVertices( SelPtr *list) /* SWAP! */
{
   short    v, l;

   ObjectsNeeded( OBJ_LINEDEFS, 0);
   v = (*list)->objnum;
   UnSelectObject( list, v);
   if (*list == NULL)
   {
      Beep();
      form_alert(1,"[1][|You must select at least two vertices][Oh]");
      return;
   }
   /* change the LineDefs starts & ends */
   for (l = 0; l < NumLineDefs; l++)
   {
      if (IsSelected( *list, LineDefs[ l].start))
      {
	 /* don't change a LineDef that has both ends on the same spot */
	 if (!IsSelected( *list, LineDefs[ l].end) && LineDefs[ l].end != v)
	    LineDefs[ l].start = v;
      }
      else if (IsSelected( *list, LineDefs[ l].end))
      {
	 /* idem */
	 if (LineDefs[ l].start != v)
	    LineDefs[ l].end = v;
      }
   }
   /* delete the Vertices (and some LineDefs too) */
   DeleteObjects( OBJ_VERTEXES, list);
   MadeChanges = TRUE;
   MadeMapChanges = TRUE;
}



/*
   check if some vertices should be merged into one
*/

Bool AutoMergeVertices( SelPtr *list) /* SWAP! */
{
   SelPtr ref, cur;
   Bool   confirmed, redraw;
   Bool   flipped, mergedone, isldend;
   short    v, refv;
   short    ld, sd;
   short    oldnumld;

   ObjectsNeeded( OBJ_VERTEXES, 0);
   confirmed = FALSE;
   redraw = FALSE;
   mergedone = FALSE;
   isldend = FALSE;

   /* first, check if two (or more) Vertices should be merged */
   ref = *list;
   while (ref)
   {
      refv = ref->objnum;
      ref = ref->next;
      /* check if there is a Vertex at the same position (same X and Y) */
      for (v = 0; v < NumVertexes; v++)
	 if (v != refv && Vertexes[ refv].x == Vertexes[ v].x && Vertexes[ refv].y == Vertexes[ v].y)
	 {
	    redraw = TRUE;
	    if (confirmed || Expert || form_alert(1,"[2][Some Vertices occupy the same position.|Do you want to merge them into one?][Yes|No]")==1)
	    {
	       /* don't ask for confirmation twice */
	       confirmed = TRUE;
	       /* merge the two vertices */
	       mergedone = TRUE;
	       cur = NULL;
	       SelectObject( &cur, refv);
	       SelectObject( &cur, v);
	       MergeVertices( &cur);
	       /* not useful but safer... */
	       ObjectsNeeded( OBJ_VERTEXES, 0);
	       /* update the references in the selection list */
	       for (cur = *list; cur; cur = cur->next)
		  if (cur->objnum > refv)
		     cur->objnum = cur->objnum - 1;
	       if (v > refv)
		  v--;
	       /* the old Vertex has been deleted */
	       UnSelectObject( list, refv);
	       /* select the new Vertex instead */
	       if (!IsSelected( *list, v))
		  SelectObject( list, v);
	       break;
	    }
	    else
	       return redraw;
	 }
   }
   confirmed = FALSE;

   /* now, check if one or more Vertices are on a LineDef */
   ref = *list;
   while (ref)
   {
      refv = ref->objnum;
      ref = ref->next;
      oldnumld = NumLineDefs;
      /* check if this Vertex is on a LineDef */
      for (ld = 0; ld < oldnumld; ld++)
      {
	 ObjectsNeeded( OBJ_VERTEXES, OBJ_LINEDEFS, 0);
	 if (LineDefs[ ld].start == refv || LineDefs[ ld].end == refv)
	 {
	    /* one Vertex had a LineDef bound to it -- check it later */
	    isldend = TRUE;
	 }
	 else if (IsLineDefInside( ld, Vertexes[ refv].x - 3, Vertexes[ refv].y - 3, Vertexes[ refv].x + 3, Vertexes[ refv].y + 3))
	 {
	    redraw = TRUE;
	    if (confirmed || Expert || form_alert(1,"[2][Some Vertices are on a LineDef.|Do you want to split the LineDef there?][Yes][No]")==1)
	    {
	       /* don't ask for confirmation twice */
	       confirmed = TRUE;
	       /* split the LineDef */
	       mergedone = TRUE;
	       InsertObject( OBJ_LINEDEFS, ld, 0, 0);
	       LineDefs[ ld].end = refv;
	       LineDefs[ NumLineDefs - 1].start = refv;
	       sd = LineDefs[ ld].sidedef1;
	       if (sd >= 0)
	       {
		  InsertObject( OBJ_SIDEDEFS, sd, 0, 0);
		  ObjectsNeeded( OBJ_LINEDEFS, 0);
		  LineDefs[ NumLineDefs - 1].sidedef1 = NumSideDefs - 1;
	       }
	       sd = LineDefs[ ld].sidedef2;
	       if (sd >= 0)
	       {
		  InsertObject( OBJ_SIDEDEFS, sd, 0, 0);
		  ObjectsNeeded( OBJ_LINEDEFS, 0);
		  LineDefs[ NumLineDefs - 1].sidedef2 = NumSideDefs - 1;
	       }
	       MadeChanges = TRUE;
	       MadeMapChanges = TRUE;
	    }
	    else
	       return redraw;
	 }
      }
   }

   /* don't continue if this isn't necessary */
   if (isldend == FALSE || mergedone == FALSE)
      return redraw;

   confirmed = FALSE;

   /* finally, test if two LineDefs are between the same pair of Vertices */
   for (v = 0; v < NumLineDefs - 1; v++)
      for (ld = v + 1; ld < NumLineDefs; ld++)
	 if ((LineDefs[ v].start == LineDefs[ ld].start && LineDefs[ v].end == LineDefs[ ld].end)
	  || (LineDefs[ v].start == LineDefs[ ld].end && LineDefs[ v].end == LineDefs[ ld].start))
	 {
	    redraw = TRUE;
	    if (confirmed || Expert || form_alert(1,"[2][Some LineDefs are superimposed|Do you want to merge them into one?][Yes|No]")==1)
	    {
	       /* don't ask for confirmation twice */
	       confirmed = TRUE;
	       /* test if the LineDefs have the same orientation */
	       if (LineDefs[ v].start == LineDefs[ ld].end)
		  flipped = TRUE;
	       else
		  flipped = FALSE;
	       /* merge the two LineDefs */
	       if (LineDefs[ v].sidedef1 < 0)
	       {
		  if (flipped)
		  {
		    LineDefs[ v].sidedef1 = LineDefs[ ld].sidedef2;
		    LineDefs[ ld].sidedef2 = -1;
		  }
		  else
		  {
		    LineDefs[ v].sidedef1 = LineDefs[ ld].sidedef1;
		    LineDefs[ ld].sidedef1 = -1;
		  }
	       }
	       if (LineDefs[ v].sidedef2 < 0)
	       {
		  if (flipped)
		  {
		    LineDefs[ v].sidedef2 = LineDefs[ ld].sidedef1;
		    LineDefs[ ld].sidedef1 = -1;
		  }
		  else
		  {
		    LineDefs[ v].sidedef2 = LineDefs[ ld].sidedef2;
		    LineDefs[ ld].sidedef2 = -1;
		  }
	       }
	       if (LineDefs[ v].sidedef1 >= 0 && LineDefs[ v].sidedef2 >= 0 && (LineDefs[ v].flags & 0x04) == 0)
		  LineDefs[ v].flags = 0x04;
	       DeleteObject( OBJ_LINEDEFS, ld);
	    }
	 }
   return redraw;
}



/*
   split one or more LineDefs in two, adding new Vertices in the middle
*/

void SplitLineDefs( SelPtr obj) /* SWAP! */
{
   SelPtr cur;
   short    vstart, vend, sd;

   ObjectsNeeded( OBJ_LINEDEFS, 0);
   for (cur = obj; cur; cur = cur->next)
   {
      vstart = LineDefs[ cur->objnum].start;
      vend = LineDefs[ cur->objnum].end;
      InsertObject( OBJ_VERTEXES, -1, (Vertexes[ vstart].x + Vertexes[ vend].x) / 2, (Vertexes[ vstart].y + Vertexes[ vend].y) / 2);
      InsertObject( OBJ_LINEDEFS, cur->objnum, 0, 0);
      LineDefs[ cur->objnum].end = NumVertexes - 1;
      LineDefs[ NumLineDefs - 1].start = NumVertexes - 1;
      sd = LineDefs[ cur->objnum].sidedef1;
      if (sd >= 0)
      {
	 InsertObject( OBJ_SIDEDEFS, sd, 0, 0);
	 ObjectsNeeded( OBJ_LINEDEFS, 0);
	 LineDefs[ NumLineDefs - 1].sidedef1 = NumSideDefs - 1;
      }
      sd = LineDefs[ cur->objnum].sidedef2;
      if (sd >= 0)
      {
	 InsertObject( OBJ_SIDEDEFS, sd, 0, 0);
	 ObjectsNeeded( OBJ_LINEDEFS, 0);
	 LineDefs[ NumLineDefs - 1].sidedef2 = NumSideDefs - 1;
      }
   }
   MadeChanges = TRUE;
   MadeMapChanges = TRUE;
}



/*
   split a Sector in two, adding a new LineDef between the two Vertices
*/

void SplitSector( short vertex1, short vertex2) /* SWAP! */
{
   SelPtr llist;
   short    curv, s, l, sd;
   char   msg1[ 80], msg2[ 80];

   /* check if there is a Sector between the two Vertices (in the middle) */
   s = GetCurObject( OBJ_SECTORS, Vertexes[ vertex1].x, Vertexes[ vertex1].y, Vertexes[ vertex2].x, Vertexes[ vertex2].y);
   if (s < 0)
   {
      Beep();
      sprintf( msg1, "[1]There is no Sector between |Vertex #%d and Vertex #%d][Oh]", vertex1, vertex2);
      form_alert(1, msg1);
      return;
   }
   /* check if there is a closed path from vertex1 to vertex2, along the edge of the Sector s */
   ObjectsNeeded( OBJ_LINEDEFS, OBJ_SIDEDEFS, 0);
   llist = NULL;
   curv = vertex1;
   while (curv != vertex2)
   {
      for (l = 0; l < NumLineDefs; l++)
      {
	 sd = LineDefs[ l].sidedef1;
	 if (sd >= 0 && SideDefs[ sd].sector == s && LineDefs[ l].start == curv)
	 {
	    curv = LineDefs[ l].end;
	    SelectObject( &llist, l);
	    break;
	 }
	 sd = LineDefs[ l].sidedef2;
	 if (sd >= 0 && SideDefs[ sd].sector == s && LineDefs[ l].end == curv)
	 {
	    curv = LineDefs[ l].start;
	    SelectObject( &llist, l);
	    break;
	 }
      }
      if (l >= NumLineDefs)
      {
	 Beep();
	 sprintf( msg1, "[1][Cannot find a closed path|from Vertex #%d to Vertex #%d|", vertex1, vertex2);
	 if (curv == vertex1)
	    sprintf( msg2, "There is no SideDef starting |from Vertex #%d on Sector #%d][Oh]", vertex1, s);
	 else
	    sprintf( msg2, "Check if Sector #%d is closed (cannot go past Vertex #%d)][Oh]", s, curv);
     strcat(msg1,msg2);
	 form_alert(1, msg1);
	 ForgetSelection( &llist);
	 return;
      }
      if (curv == vertex1)
      {
	 Beep();
	 sprintf( msg1, "[1]Vertex #%d is not on the same|Sector (#%d) as Vertex #%d][Oh]", vertex2, s, vertex1);
	 form_alert(1, msg1);
	 ForgetSelection( &llist);
	 return;
      }
   }
   /* now, the list of LineDefs for the new Sector is in llist */

   /* add the new Sector, LineDef and SideDefs */
   InsertObject( OBJ_SECTORS, s, 0, 0);
   InsertObject( OBJ_LINEDEFS, -1, 0, 0);
   LineDefs[ NumLineDefs - 1].start = vertex1;
   LineDefs[ NumLineDefs - 1].end = vertex2;
   LineDefs[ NumLineDefs - 1].flags = 4;
   InsertObject( OBJ_SIDEDEFS, -1, 0, 0);
   SideDefs[ NumSideDefs - 1].sector = s;
   strncpy( SideDefs[ NumSideDefs - 1].tex3, "-", 8);
   InsertObject( OBJ_SIDEDEFS, -1, 0, 0);
   strncpy( SideDefs[ NumSideDefs - 1].tex3, "-", 8);
   ObjectsNeeded( OBJ_LINEDEFS, OBJ_SIDEDEFS, 0);
   LineDefs[ NumLineDefs - 1].sidedef1 = NumSideDefs - 2;
   LineDefs[ NumLineDefs - 1].sidedef2 = NumSideDefs - 1;

   /* bind all LineDefs in llist to the new Sector */
   while (llist)
   {
      sd = LineDefs[ llist->objnum].sidedef1;
      if (sd < 0 || SideDefs[ sd].sector != s)
	 sd = LineDefs[ llist->objnum].sidedef2;
      SideDefs[ sd].sector = NumSectors - 1;
      UnSelectObject( &llist, llist->objnum);
   }

   /* second check... uselful for Sectors within Sectors */
   ObjectsNeeded( OBJ_LINEDEFS, OBJ_SIDEDEFS, 0);
   for (l = 0; l < NumLineDefs; l++)
   {
      sd = LineDefs[ l].sidedef1;
      if (sd >= 0 && SideDefs[ sd].sector == s)
      {
         curv = GetOppositeSector( l, TRUE);
         ObjectsNeeded( OBJ_LINEDEFS, OBJ_SIDEDEFS, 0);
         if (curv == NumSectors - 1)
            SideDefs[ sd].sector = NumSectors - 1;
      }
      sd = LineDefs[ l].sidedef2;
      if (sd >= 0 && SideDefs[ sd].sector == s)
      {
         curv = GetOppositeSector( l, FALSE);
         ObjectsNeeded( OBJ_LINEDEFS, OBJ_SIDEDEFS, 0);
         if (curv == NumSectors - 1)
            SideDefs[ sd].sector = NumSectors - 1;
      }
   }

   MadeChanges = TRUE;
   MadeMapChanges = TRUE;
}



/*
   split two LineDefs, then split the Sector and add a new LineDef between the new Vertices
*/

void SplitLineDefsAndSector( short linedef1, short linedef2) /* SWAP! */
{
   SelPtr llist;
   short    s1, s2, s3, s4;
   char   msg[ 80];

   /* check if the two LineDefs are adjacent to the same Sector */
   ObjectsNeeded( OBJ_LINEDEFS, 0);
   s1 = LineDefs[ linedef1].sidedef1;
   s2 = LineDefs[ linedef1].sidedef2;
   s3 = LineDefs[ linedef2].sidedef1;
   s4 = LineDefs[ linedef2].sidedef2;
   ObjectsNeeded( OBJ_SIDEDEFS, 0);
   if (s1 >= 0)
      s1 = SideDefs[ s1].sector;
   if (s2 >= 0)
      s2 = SideDefs[ s2].sector;
   if (s3 >= 0)
      s3 = SideDefs[ s3].sector;
   if (s4 >= 0)
      s4 = SideDefs[ s4].sector;
   if ((s1 < 0 || (s1 != s3 && s1 != s4)) && (s2 < 0 || (s2 != s3 && s2 != s4)))
   {
      Beep();
      sprintf( msg, "[1]LineDefs #%d and #%d are not|adjacent to the same Sector][Oh]", linedef1, linedef2);
      form_alert(1, msg);
      return;
   }
   /* split the two LineDefs and create two new Vertices */
   llist = NULL;
   SelectObject( &llist, linedef1);
   SelectObject( &llist, linedef2);
   SplitLineDefs( llist);
   ForgetSelection( &llist);
   /* split the Sector and create a LineDef between the two Vertices */
   SplitSector( NumVertexes - 1, NumVertexes - 2);
}



/*
   merge two or more Sectors into one
*/

void MergeSectors( SelPtr *slist) /* SWAP! */
{
  SelPtr cur;
  short    n, olds, news;

  /* save the first Sector number */
  news = (*slist)->objnum;
  UnSelectObject( slist, news);
  ObjectsNeeded( OBJ_SIDEDEFS, 0);

  /* change all SideDefs references to the other Sectors */
  for (cur = *slist; cur; cur = cur->next)
  {
     olds = cur->objnum;
     for (n = 0; n < NumSideDefs; n++)
     {
	if (SideDefs[ n].sector == olds)
	   SideDefs[ n].sector = news;
     }
  }

  /* delete the Sectors */
  DeleteObjects( OBJ_SECTORS, slist);

  /* the returned list contains only the first Sector */
  SelectObject( slist, news);
}



/*
   delete one or several two-sided LineDefs and join the two Sectors
*/

void DeleteLineDefsJoinSectors( SelPtr *ldlist) /* SWAP! */
{
   SelPtr cur, slist;
   short    sd1, sd2;
   short    s1, s2;
   char   msg[ 80];

   /* first, do the tests for all LineDefs */
   for (cur = *ldlist; cur; cur = cur->next)
   {
      ObjectsNeeded( OBJ_LINEDEFS, 0);
      sd1 = LineDefs[ cur->objnum].sidedef1;
      sd2 = LineDefs[ cur->objnum].sidedef2;
      if (sd1 < 0 || sd2 < 0)
      {
         Beep();
         sprintf( msg, "[1][ERROR: LineDef #%d has only one side]", cur->objnum);
         form_alert(1, msg);
         return;
      }
      ObjectsNeeded( OBJ_SIDEDEFS, 0);
      s1 = SideDefs[ sd1].sector;
      s2 = SideDefs[ sd2].sector;
      if (s1 < 0 || s2 < 0)
      {
         Beep();
         sprintf( msg, "[1][ERROR: LineDef #%d has two sides,| but one side is not bound to any Sector][Oh]", cur->objnum);
         form_alert(1, msg);
         return;
      }
   }

   /* then join the Sectors and delete the LineDefs */
   for (cur = *ldlist; cur; cur = cur->next)
   {
      ObjectsNeeded( OBJ_LINEDEFS, 0);
      sd1 = LineDefs[ cur->objnum].sidedef1;
      sd2 = LineDefs[ cur->objnum].sidedef2;
      ObjectsNeeded( OBJ_SIDEDEFS, 0);
      s1 = SideDefs[ sd1].sector;
      s2 = SideDefs[ sd2].sector;
      slist = NULL;
      SelectObject( &slist, s2);
      SelectObject( &slist, s1);
      MergeSectors( &slist);
      ForgetSelection( &slist);
   }
   DeleteObjects( OBJ_LINEDEFS, ldlist);
}




/*
   turn a Sector into a door: change the LineDefs and SideDefs
*/

void MakeDoorFromSector( short sector) /* SWAP! */
{
   short    sd1, sd2;
   short    n, s;
   SelPtr ldok, ldflip, ld1s;

   ldok = NULL;
   ldflip = NULL;
   ld1s = NULL;
   s = 0;
   /* build lists of LineDefs that border the Sector */
   for (n = 0; n < NumLineDefs; n++)
   {
      ObjectsNeeded( OBJ_LINEDEFS, 0);
      sd1 = LineDefs[ n].sidedef1;
      sd2 = LineDefs[ n].sidedef2;
      if (sd1 >= 0 && sd2 >= 0)
      {
	 ObjectsNeeded( OBJ_SIDEDEFS, 0);
	 if (SideDefs[ sd2].sector == sector)
	 {
	    SelectObject( &ldok, n); /* already ok */
	    s++;
	 }
	 if (SideDefs[ sd1].sector == sector)
	 {
	    SelectObject( &ldflip, n); /* must be flipped */
	    s++;
	 }
      }
      else if (sd1 >= 0 && sd2 < 0)
      {
	 ObjectsNeeded( OBJ_SIDEDEFS, 0);
	 if (SideDefs[ sd1].sector == sector)
	    SelectObject( &ld1s, n); /* wall (one-sided) */
      }
   }
   /* a normal door has two sides... */
   if (s < 2)
   {
      Beep();
      form_alert(1, "[1][The door must be connected|to two other Sectors.][Oh]");
      ForgetSelection( &ldok);
      ForgetSelection( &ldflip);
      ForgetSelection( &ld1s);
      return;
   }
   if ((s > 2) && !(Expert || form_alert(1, "[2][The door will have more than two sides.|Do you still want to create it?][Yes|No]")==1))
   {
      ForgetSelection( &ldok);
      ForgetSelection( &ldflip);
      ForgetSelection( &ld1s);
      return;
   }
   /* flip the LineDefs that have the wrong orientation */
   if (ldflip != NULL)
      FlipLineDefs( ldflip, TRUE);
   /* merge the two selection lists */
   while (ldflip != NULL)
   {
      if (!IsSelected( ldok, ldflip->objnum))
	 SelectObject( &ldok, ldflip->objnum);
      UnSelectObject( &ldflip, ldflip->objnum);
   }
   /* change the LineDefs and SideDefs */
   while (ldok != NULL)
   {
      /* give the "normal door" type and flags to the LineDef */
      ObjectsNeeded( OBJ_LINEDEFS, 0);
      n = ldok->objnum;
      LineDefs[ n].type = 1;
      LineDefs[ n].flags = 0x04;
      sd1 = LineDefs[ n].sidedef1; /* outside */
      sd2 = LineDefs[ n].sidedef2; /* inside */
      /* adjust the textures for the SideDefs */
      ObjectsNeeded( OBJ_SIDEDEFS, 0);
      if (strncmp( SideDefs[ sd1].tex3, "-", 8))
      {
	 if (!strncmp( SideDefs[ sd1].tex1, "-", 8))
	    strncpy( SideDefs[ sd1].tex1, SideDefs[ sd1].tex3, 8);
	 strncpy( SideDefs[ sd1].tex3, "-", 8);
      }
      if (!strncmp( SideDefs[ sd1].tex1, "-", 8))
	 strncpy( SideDefs[ sd1].tex1, "BIGDOOR2", 8);
      strncpy( SideDefs[ sd2].tex3, "-", 8);
      UnSelectObject( &ldok, n);
   }
   while (ld1s != NULL)
   {
      /* give the "door side" flags to the LineDef */
      ObjectsNeeded( OBJ_LINEDEFS, 0);
      n = ld1s->objnum;
      LineDefs[ n].flags = 0x11;
      sd1 = LineDefs[ n].sidedef1;
      /* adjust the textures for the SideDef */
      ObjectsNeeded( OBJ_SIDEDEFS, 0);
      if (!strncmp( SideDefs[ sd1].tex3, "-", 8))
	 strncpy( SideDefs[ sd1].tex3, "DOORTRAK", 8);
      strncpy( SideDefs[ sd1].tex1, "-", 8);
      strncpy( SideDefs[ sd1].tex2, "-", 8);
      UnSelectObject( &ld1s, n);
   }
   /* adjust the ceiling height */
   ObjectsNeeded( OBJ_SECTORS, 0);
   Sectors[ sector].ceilh = Sectors[ sector].floorh;
}



/*
   turn a Sector into a lift: change the LineDefs and SideDefs
*/

void MakeLiftFromSector( short sector) /* SWAP! */
{
   short    sd1, sd2;
   short    n, s, tag;
   SelPtr ldok, ldflip, ld1s;
   SelPtr sect, curs;
   short    minh, maxh;

   ldok = NULL;
   ldflip = NULL;
   ld1s = NULL;
   sect = NULL;
   /* build lists of LineDefs that border the Sector */
   for (n = 0; n < NumLineDefs; n++)
   {
      ObjectsNeeded( OBJ_LINEDEFS, 0);
      sd1 = LineDefs[ n].sidedef1;
      sd2 = LineDefs[ n].sidedef2;
      if (sd1 >= 0 && sd2 >= 0)
      {
	 ObjectsNeeded( OBJ_SIDEDEFS, 0);
	 if (SideDefs[ sd2].sector == sector)
	 {
	    SelectObject( &ldok, n); /* already ok */
	    s = SideDefs[ sd1].sector;
	    if (s != sector && !IsSelected( sect, s))
	       SelectObject( &sect, s);
	 }
	 if (SideDefs[ sd1].sector == sector)
	 {
	    SelectObject( &ldflip, n); /* will be flipped */
	    s = SideDefs[ sd2].sector;
	    if (s != sector && !IsSelected( sect, s))
	       SelectObject( &sect, s);
	 }
      }
      else if (sd1 >= 0 && sd2 < 0)
      {
	 ObjectsNeeded( OBJ_SIDEDEFS, 0);
	 if (SideDefs[ sd1].sector == sector)
	    SelectObject( &ld1s, n); /* wall (one-sided) */
      }
   }
   /* there must be a way to go on the lift... */
   if (sect == NULL)
   {
      Beep();
      form_alert(1,"[1][The lift must be connected to|at least one other Sector.][Oh]");
      ForgetSelection( &ldok);
      ForgetSelection( &ldflip);
      ForgetSelection( &ld1s);
      return;
   }
   /* flip the LineDefs that have the wrong orientation */
   if (ldflip != NULL)
      FlipLineDefs( ldflip, TRUE);
   /* merge the two selection lists */
   while (ldflip != NULL)
   {
      if (!IsSelected( ldok, ldflip->objnum))
	 SelectObject( &ldok, ldflip->objnum);
      UnSelectObject( &ldflip, ldflip->objnum);
   }

   /* find a free tag number */
   tag = FindFreeTag();

   /* find the minimum and maximum altitudes */
   ObjectsNeeded( OBJ_SECTORS, 0);
   minh = 32767;
   maxh = -32767;
   for (curs = sect; curs; curs = curs->next)
   {
      if (Sectors[ curs->objnum].floorh < minh)
	 minh = Sectors[ curs->objnum].floorh;
      if (Sectors[ curs->objnum].floorh > maxh)
	 maxh = Sectors[ curs->objnum].floorh;
   }
   ForgetSelection( &sect);

   /* change the lift's floor height if necessary */
   if (Sectors[ sector].floorh < maxh)
      Sectors[ sector].floorh = maxh;

   /* change the lift's ceiling height if necessary */
   if (Sectors[ sector].ceilh < maxh + 56)
      Sectors[ sector].ceilh = maxh + 56;

   /* assign the new tag number to the lift */
   Sectors[ sector].tag = tag;

   /* change the LineDefs and SideDefs */
   while (ldok != NULL)
   {
      /* give the "lower lift" type and flags to the LineDef */
      ObjectsNeeded( OBJ_LINEDEFS, 0);
      n = ldok->objnum;
      LineDefs[ n].type = 62; /* lower lift (switch) */
      LineDefs[ n].flags = 0x04;
      LineDefs[ n].tag = tag;
      sd1 = LineDefs[ n].sidedef1; /* outside */
      sd2 = LineDefs[ n].sidedef2; /* inside */
      /* adjust the textures for the SideDef visible from the outside */
      ObjectsNeeded( OBJ_SIDEDEFS, 0);
      if (strncmp( SideDefs[ sd1].tex3, "-", 8))
      {
	 if (!strncmp( SideDefs[ sd1].tex2, "-", 8))
	    strncpy( SideDefs[ sd1].tex2, SideDefs[ sd1].tex3, 8);
	 strncpy( SideDefs[ sd1].tex3, "-", 8);
      }
      if (!strncmp( SideDefs[ sd1].tex2, "-", 8))
	 strncpy( SideDefs[ sd1].tex2, "SHAWN2", 8);
      /* adjust the textures for the SideDef visible from the lift */
      strncpy( SideDefs[ sd2].tex3, "-", 8);
      s = SideDefs[ sd1].sector;
      ObjectsNeeded( OBJ_SECTORS, 0);
      if (Sectors[ s].floorh > minh)
      {
	 ObjectsNeeded( OBJ_SIDEDEFS, 0);
	 if (strncmp( SideDefs[ sd2].tex3, "-", 8))
	 {
	    if (!strncmp( SideDefs[ sd2].tex2, "-", 8))
	       strncpy( SideDefs[ sd2].tex2, SideDefs[ sd1].tex3, 8);
	    strncpy( SideDefs[ sd2].tex3, "-", 8);
	 }
	 if (!strncmp( SideDefs[ sd2].tex2, "-", 8))
	    strncpy( SideDefs[ sd2].tex2, "SHAWN2", 8);
      }
      else
      {
	 ObjectsNeeded( OBJ_SIDEDEFS, 0);
	 strncpy( SideDefs[ sd2].tex2, "-", 8);
      }
      strncpy( SideDefs[ sd2].tex3, "-", 8);
      ObjectsNeeded( OBJ_SECTORS, 0);
      /* if the ceiling of the Sector is lower than that of the lift */
      if (Sectors[ s].ceilh < Sectors[ sector].ceilh)
      {
	 ObjectsNeeded( OBJ_SIDEDEFS, 0);
	 if (strncmp( SideDefs[ sd2].tex1, "-", 8))
	    strncpy( SideDefs[ sd2].tex1, DefaultUpperTexture, 8);
      }
      ObjectsNeeded( OBJ_SECTORS, 0);
      /* if the floor of the Sector is above the lift */
      if (Sectors[ s].floorh >= Sectors[ sector].floorh)
      {
	 ObjectsNeeded( OBJ_LINEDEFS, 0);
	 LineDefs[ n].type = 88; /* lower lift (walk through) */
	 /* flip it, just for fun */
	 curs = NULL;
	 SelectObject( &curs, n);
	 FlipLineDefs( curs, TRUE);
	 ForgetSelection( &curs);
      }
      /* done with this LineDef */
      UnSelectObject( &ldok, n);
   }

   while (ld1s != NULL)
   {
      /* these are the lift walls (one-sided) */
      ObjectsNeeded( OBJ_LINEDEFS, 0);
      n = ld1s->objnum;
      LineDefs[ n].flags = 0x01;
      sd1 = LineDefs[ n].sidedef1;
      /* adjust the textures for the SideDef */
      ObjectsNeeded( OBJ_SIDEDEFS, 0);
      if (!strncmp( SideDefs[ sd1].tex3, "-", 8))
	 strncpy( SideDefs[ sd1].tex3, DefaultWallTexture, 8);
      strncpy( SideDefs[ sd1].tex1, "-", 8);
      strncpy( SideDefs[ sd1].tex2, "-", 8);
      UnSelectObject( &ld1s, n);
   }
}



/*
   get the absolute height from which the textures are drawn
*/

short GetTextureRefHeight( short sidedef) /* SWAP! */
{
   short l, sector;
   short otherside;

   /* find the SideDef on the other side of the LineDef, if any */
   ObjectsNeeded( OBJ_LINEDEFS, 0);
   for (l = 0; l < NumLineDefs; l++)
   {
      if (LineDefs[ l].sidedef1 == sidedef)
      {
	 otherside = LineDefs[ l].sidedef2;
	 break;
      }
      if (LineDefs[ l].sidedef2 == sidedef)
      {
	 otherside = LineDefs[ l].sidedef1;
	 break;
      }
   }
   /* get the Sector number */
   ObjectsNeeded( OBJ_SIDEDEFS, 0);
   sector = SideDefs[ sidedef].sector;
   /* if the upper texture is displayed, then the reference is taken from the other Sector */
   if (otherside >= 0)
   {
      l = SideDefs[ otherside].sector;
      if (l > 0)
      {
	 ObjectsNeeded( OBJ_SECTORS, 0);
	 if (Sectors[ l].ceilh < Sectors[ sector].ceilh && Sectors[ l].ceilh > Sectors[ sector].floorh)
	    sector = l;
      }
   }
   /* return the altitude of the ceiling */
   ObjectsNeeded( OBJ_SECTORS, 0);
   if (sector >= 0)
      return Sectors[ sector].ceilh; /* textures are drawn from the ceiling down */
   else
      return 0; /* yuck! */
}



/*
   Align all textures for the given SideDefs

   Note from RQ:
      This function should be improved!
      But what should be improved first is the way the SideDefs are selected.
      It is stupid to change both sides of a wall when only one side needs
      to be changed.  But with the current selection method, there is no
      way to select only one side of a two-sided wall.
*/

void AlignTexturesY( SelPtr *sdlist) /* SWAP! */
{
   short h, refh;

   if (*sdlist == NULL)
      return;

   /* get the reference height from the first SideDef */
   refh = GetTextureRefHeight( (*sdlist)->objnum);
   ObjectsNeeded( OBJ_SIDEDEFS, 0);
   SideDefs[ (*sdlist)->objnum].yoff = 0;
   UnSelectObject( sdlist, (*sdlist)->objnum);

   /* adjust Y offset in all other SideDefs */
   while (*sdlist != NULL)
   {
      h = GetTextureRefHeight( (*sdlist)->objnum);
      ObjectsNeeded( OBJ_SIDEDEFS, 0);
      SideDefs[ (*sdlist)->objnum].yoff = (refh - h) % 128;
      UnSelectObject( sdlist, (*sdlist)->objnum);
   }
   MadeChanges = TRUE;
}



/*
	Function is to align all highlighted textures in the X-axis

	Note from RJH:
		LineDefs highlighted are read off in reverse order of highlighting.
		The '*sdlist' is in the reverse order of the above mentioned LineDefs
		i.e. the first LineDef SideDefs you highlighted will be processed first.

	Note from RQ:
		See also the note for the previous function.

	Note from RJH:
		For the menu for aligning textures 'X' NOW operates upon the fact that
		ALL the SIDEDEFS from the selected LINEDEFS are in the *SDLIST, 2nd
		SideDef is first, 1st SideDef is 2nd). Aligning textures X now does
		SIDEDEF 1's and SIDEDEF 2's.  If the selection process is changed,
		the following needs to be altered radically.
*/

void AlignTexturesX(SelPtr *sdlist) /* SWAP! */
{
	char texname[9];       	/* FIRST texture name used in the highlited objects */
	char errormessage[80];	/* area to hold the error messages produced */
	short  ldef;		/* linedef number */
	short  sd1;         	/* current SideDef in *sdlist */
	short  vert1, vert2;	/* vertex 1 and 2 for the linedef under scrutiny */
	short  xoffset;		/* xoffset accumulator */
	short  useroffset;        /* user input offset for first input */
	short  texlength;        	/* the length of texture to format to */
	short  length;		/* length of linedef under scrutiny */
	short  dummy;		/* holds useless data */
	short  type_off;		/* do we have an initial offset to use */
	short  type_tex;          /* do we check for same textures */
	short  type_sd;		/* do we align SideDef 1 or SideDef2 */

	type_sd  = 0;     /* which SideDef to align, 1 = SideDef1, 2 = SideDef2 */
	type_tex = 0;     /* do we test for similar textures, 0 = inactive, 1 = active */
	type_off = 0;     /* do we have an inital offset, 0 = inactive, 1 = active */

	vert1   = -1;
	vert2   = -1;		/* first time round the while loop the -1 value is needed */
	texlength  = 0;
	xoffset    = 0;
	useroffset = 0;

	switch(DisplayMenu( 250, 110, "Aligning textures 'X' menu:",

			  " SideDef 1,  Check for identical textures.     ",
			  " SideDef 1,  As above, but with inital offset. ",
			  " SideDef 1,  No texture checking.              ",
			  " SideDef 1,  As above, but with inital offset. ",

			  " SideDef 2, Check for identical textures.     ",
			  " SideDef 2, As above, but with inital offset. ",
			  " SideDef 2, No texture checking.              ",
			  " SideDef 2, As above, but with inital offset. ",
			  NULL))
		{
		 case 1: 		/* SideDef 1 with checking for same textures   */
			type_sd = 1; type_tex = 1; type_off = 0;
			break;

		 case 2: 		/* SideDef 1 as above, but with inital offset  */
			type_sd = 1; type_tex = 1; type_off = 1;
			break;

		 case 3: 		/* SideDef 1 regardless of same textures       */
			type_sd = 1; type_tex = 0; type_off = 0;
			break;

		 case 4: 		/* SideDef 1 as above, but with inital offset  */
			type_sd = 1; type_tex = 0; type_off = 1;
			break;

		 case 5: 		/* SideDef 2 with checking for same textures   */
			type_sd = 2; type_tex = 1; type_off = 0;
			break;

		 case 6: 		/* SideDef 2 as above, but with initial offset */
			type_sd = 2; type_tex = 1; type_off = 1;
			break;

		 case 7: 		/* SideDef 2 regardless of same textures       */
			type_sd = 2; type_tex = 0; type_off = 0;
			break;

		 case 8: /* SideDef 2 as above, but with initial offset       */
			type_sd = 2; type_tex = 0; type_off = 1;
			break;
		}

	ldef = 0;
	sd1 = (*sdlist) ->objnum;

	if(type_sd == 1) /* throw out all 2nd SideDefs untill a 1st is found */
	{
		while((*sdlist)!=NULL && LineDefs[ldef].sidedef1!=sd1 && ldef<=NumLineDefs)
		{
			ldef++;
			if(LineDefs[ldef].sidedef2 == sd1)
			{
				UnSelectObject(sdlist, (*sdlist)->objnum);
				sd1 = (*sdlist) ->objnum;
				ldef = 0;
				if((*sdlist)==NULL)
					return;
			}
		}
	}

	if(type_sd == 2) /* throw out all 1st SideDefs untill a 2nd is found */
	{
		while(LineDefs[ldef].sidedef2!=sd1 && ldef<=NumLineDefs)
		{
			ldef++;
			if(LineDefs[ldef].sidedef1 == sd1)
			{
				UnSelectObject(sdlist, (*sdlist)->objnum);
				sd1 = (*sdlist) ->objnum;
				ldef = 0;
				if((*sdlist) == NULL)
					return;
			}
		}
	}

	ObjectsNeeded( OBJ_SIDEDEFS, 0);

	/* get texture name of the SideDef in the *sdlist) */
	strncpy( texname, SideDefs[ (*sdlist)->objnum].tex3, 8);

	/* test if there is a texture there */
	if (texname[0] == '-')
	{
		Beep();
		sprintf( errormessage, "[1][No texture for SideDef #%d.][Oh]", (*sdlist)->objnum);
		form_alert(1, errormessage);
		return;
	}

	GetWallTextureSize( &texlength, &dummy, texname); /* clunky, but it works */

	/* get initial offset to use (if requrired) */
	if(type_off == 1)    /* source taken from InputObjectNumber */
	{
		short  x0;          /* left hand (x) window start     */
		short  y0;		      /* top (y) window start           */
		short  key;			/* holds value returned by InputInteger */
		char prompt[80];  /* prompt for inital offset input */

		if(UseMouse)
			HideMousePointer();

		sprintf(prompt, "Enter initial offset between 0 and %d:", texlength);

		x0 = (ScrMaxX - 25 - 8 * strlen(prompt)) / 2;
		y0 = (ScrMaxY - 55) / 2;

		DrawScreenBox3D( x0, y0, x0 + 25 + 8 * strlen( prompt), y0 + 55);
		SetColor( WHITE);
		DrawScreenText( x0 + 10, y0 + 8, prompt);

		while ( ((key=InputInteger(x0+10, y0+28, &useroffset, 0, texlength))&0x00FF)!=0x000D
					&& (key & 0x00FF) != 0x001B)
			Beep();

		if (UseMouse)
			ShowMousePointer();
	}

	while (*sdlist != NULL)  /* main processing loop */
	{
		ldef = 0;
		sd1 = (*sdlist)->objnum;

		if(type_sd == 1) /* throw out all 2nd SideDefs untill a 1st is found */
		{
			while(LineDefs[ldef].sidedef1!=sd1 && ldef<=NumLineDefs)
			{
				ldef++;
				if(LineDefs[ldef].sidedef2 == sd1)
				{
					UnSelectObject(sdlist, (*sdlist)->objnum);
					sd1 = (*sdlist) ->objnum;
					ldef = 0;
					if((*sdlist) == NULL)
						return;
				}
			}
		}

		if(type_sd == 2) /* throw out all 1st SideDefs untill a 2nd is found */
		{
			while(LineDefs[ldef].sidedef2!=sd1 && ldef<=NumLineDefs)
			{
				ldef++;
				if(LineDefs[ldef].sidedef1 == sd1)
				{
					UnSelectObject(sdlist, (*sdlist)->objnum);
					sd1 = (*sdlist) ->objnum;
					ldef = 0;
					if((*sdlist) == NULL)
						return;
				}
			}
		}

		if(type_tex == 1) /* do we test for same textures for the SideDef in question?? */

		{
			ObjectsNeeded( OBJ_SIDEDEFS, 0);
			if (strncmp( SideDefs[ (*sdlist)->objnum].tex3, texname,8))
			{
				Beep();
				sprintf( errormessage, "[1][No texture for SideDef #%d.][Oh]", (*sdlist)->objnum);
				form_alert(1, errormessage);
				return;
			}
		}

		sd1 = (*sdlist)->objnum;
		ldef = 0;

		ObjectsNeeded(OBJ_LINEDEFS,0);

		/* find out which LineDef holds that SideDef */
		if(type_sd == 1)
		{
			while (LineDefs[ ldef].sidedef1 != sd1 && ldef < NumLineDefs)
				ldef++;
		}
		else
		{
			while (LineDefs[ ldef].sidedef2 != sd1 && ldef < NumLineDefs)
				ldef++;
		}

		vert1 = LineDefs[ ldef].start;
		/* test for linedef highlight continuity */
		if (vert1 != vert2 && vert2 != -1)
		{
			Beep();
			sprintf( errormessage, "[1][LineDef #%d is not contiguous|with the previous LineDef,|please reselect.][Ok]", (*sdlist)->objnum);
			form_alert(1, errormessage);
			return;
		}
		/* is this the first time round here */
		if(vert1 != vert2)
		{
			if(type_off == 1)  /* do we have an initial offset ? */
			{
				SideDefs[sd1].xoff = useroffset;
				xoffset = useroffset;
			}
			else
				SideDefs[sd1].xoff = 0;
		}
		else		/* put new xoffset into the SideDef */
			SideDefs[sd1].xoff = xoffset;

		/* calculate length of LineDef */
		vert2 = LineDefs[ldef].end;
		ObjectsNeeded( OBJ_VERTEXES, 0);
		length = ComputeDist( Vertexes[vert2].x - Vertexes[vert1].x, Vertexes[vert2].y - Vertexes[vert1].y);

		xoffset += length;
		/* remove multiples of texlength from xoffset */
		xoffset = xoffset % texlength;
		/* move to next object in selected list */
		UnSelectObject( sdlist, (*sdlist)->objnum);
	}
	MadeChanges = TRUE;
}



/*
   Distribute sector floor heights
*/

void DistributeSectorFloors( SelPtr obj) /* SWAP! */
{
   SelPtr cur;
   short    n, num, floor1h, floor2h;

   ObjectsNeeded( OBJ_SECTORS, 0);

   num = 0;
   for (cur = obj; cur->next; cur = cur->next)
      num++;

   floor1h = Sectors[ obj->objnum].floorh;
   floor2h = Sectors[ cur->objnum].floorh;

   n = 0;
   for (cur = obj; cur; cur = cur->next)
   {
      Sectors[ cur->objnum].floorh = floor1h + n * (floor2h - floor1h) / num;
      n++;
   }
   MadeChanges = TRUE;
}



/*
   Distribute sector ceiling heights
*/

void DistributeSectorCeilings( SelPtr obj) /* SWAP! */
{
   SelPtr cur;
   short    n, num, ceil1h, ceil2h;

   ObjectsNeeded( OBJ_SECTORS, 0);

   num = 0;
   for (cur = obj; cur->next; cur = cur->next)
      num++;

   ceil1h = Sectors[ obj->objnum].ceilh;
   ceil2h = Sectors[ cur->objnum].ceilh;

   n = 0;
   for (cur = obj; cur; cur = cur->next)
   {
      Sectors[ cur->objnum].ceilh = ceil1h + n * (ceil2h - ceil1h) / num;
      n++;
   }
   MadeChanges = TRUE;
}



/* end of file */
