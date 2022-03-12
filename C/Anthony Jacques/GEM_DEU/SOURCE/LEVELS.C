/*
   Doom Editor Utility, by Brendon Wyber and Rapha‰l Quinet.

   You are allowed to use any parts of this code in another program, as
   long as you give credits to the authors in the documentation and in
   the program itself.  Read the file README.1ST for more information.

   This program comes with absolutely no warranty.

   LEVELS.C - Level loading and saving routines.
*/

/* the includes */
#include "deu.h"
#include "wstructs.h"
#include "things.h"

/* external function from objects.c */
extern Bool CreateNodes( NPtr *, short *, SEPtr); /* SWAP - needs Vertexes */

/* the global data */
MDirPtr Level = NULL;		/* master dictionary entry for the level */
short NumThings = 0;		/* number of things */
TPtr Things;			/* things data */
short NumLineDefs = 0;		/* number of line defs */
LDPtr LineDefs;			/* line defs data */
short NumSideDefs = 0;		/* number of side defs */
SDPtr SideDefs;			/* side defs data */
short NumVertexes = 0;		/* number of vertexes */
VPtr Vertexes;			/* vertex data */
short NumSectors = 0;		/* number of sectors */
SPtr Sectors;			/* sectors data */
short NumSegs = 0;		/* number of segments */
SEPtr Segs = NULL;		/* list of segments */
SEPtr LastSeg = NULL;		/* last segment in the list */
short NumSSectors = 0;		/* number of subsectors */
SSPtr SSectors = NULL;		/* list of subsectors */
SSPtr LastSSector = NULL;	/* last subsector in the list */
short NumNodes = 0;		/* number of Nodes */
NPtr Nodes = NULL;		/* nodes tree */
short NumWTexture = 0;		/* number of wall textures */
char **WTexture;		/* array of wall texture names */
short NumFTexture = 0;		/* number of floor/ceiling textures */
char **FTexture;		/* array of texture names */
short MapMaxX = -32767;		/* maximum X value of map */
short MapMaxY = -32767;		/* maximum Y value of map */
short MapMinX = 32767;		/* minimum X value of map */
short MapMinY = 32767;		/* minimum Y value of map */
Bool MadeChanges = FALSE;	/* made changes? */
Bool MadeMapChanges = FALSE;	/* made changes that need rebuilding? */


/*
** read in the level data
*/
void ReadLevelData( short episode, short mission) /* SWAP! */
{
 MDirPtr dir;
 char name[ 7];
 short n, m;
 short val;
 short OldNumVertexes;
 short *VertexUsed;

 /* No objects are needed: they may be swapped after they have been read */
 ObjectsNeeded( 0);

 /* find the various level information from the master directory */
 sprintf( name, "E%dM%d", episode, mission);

/* DisplayMessage( -1, -1, "Reading data for level %s...", name);
*/ Level = FindMasterDir( MasterDir, name);

 if (!Level) ProgError( "level data not found");

 /* get the number of Vertices */
 dir = FindMasterDir( Level, "VERTEXES");
 if (dir != NULL) OldNumVertexes = (short) (dir->dir.size / 4L);
     else OldNumVertexes = 0;

 if (OldNumVertexes > 0)
    {
     VertexUsed = GetMemory( OldNumVertexes * sizeof( short));
     for (n = 0; n < OldNumVertexes; n++)
          VertexUsed[ n] = FALSE;
    }

 /* read in the Things data */
 dir = FindMasterDir( Level, "THINGS");
 if (dir != NULL) NumThings = (short) (dir->dir.size / 10L);
     else NumThings = 0;
 if (NumThings > 0)
    {
     Things = GetFarMemory( (unsigned long) NumThings * sizeof( struct Thing));
     BasicWadSeek( dir->wadfile, dir->dir.start);
     for (n = 0; n < NumThings; n++)
         {
          BasicWadRead( dir->wadfile, &(Things[ n].xpos), 2);
          fixword(&(Things[n].xpos));
          BasicWadRead( dir->wadfile, &(Things[ n].ypos), 2);
          fixword(&(Things[n].ypos));
          BasicWadRead( dir->wadfile, &(Things[ n].angle), 2);
          fixword(&(Things[n].angle));
          BasicWadRead( dir->wadfile, &(Things[ n].type), 2);
          fixword(&(Things[n].type));
          BasicWadRead( dir->wadfile, &(Things[ n].when), 2);
          fixword(&(Things[n].when));
         }
    }

 /* read in the LineDef information */
 dir = FindMasterDir( Level, "LINEDEFS");
 if (dir != NULL) NumLineDefs = (short) (dir->dir.size / 14L);
     else NumLineDefs = 0;
 if (NumLineDefs > 0)
    {
     LineDefs = GetFarMemory( NumLineDefs * sizeof( struct LineDef));
     BasicWadSeek( dir->wadfile, dir->dir.start);
     for (n = 0; n < NumLineDefs; n++)
         {
          BasicWadRead( dir->wadfile, &(LineDefs[ n].start), 2);
          fixword(&(LineDefs[n].start));
          VertexUsed[ LineDefs[ n].start] = TRUE;
          BasicWadRead( dir->wadfile, &(LineDefs[ n].end), 2);
          fixword(&(LineDefs[n].end));
          VertexUsed[ LineDefs[ n].end] = TRUE;
          BasicWadRead( dir->wadfile, &(LineDefs[ n].flags), 2);
          fixword(&(LineDefs[n].flags));
          BasicWadRead( dir->wadfile, &(LineDefs[ n].type), 2);
          fixword(&(LineDefs[n].type));
          BasicWadRead( dir->wadfile, &(LineDefs[ n].tag), 2);
          fixword(&(LineDefs[n].tag));
          BasicWadRead( dir->wadfile, &(LineDefs[ n].sidedef1), 2);
          fixword(&(LineDefs[n].sidedef1));
          BasicWadRead( dir->wadfile, &(LineDefs[ n].sidedef2), 2);
          fixword(&(LineDefs[n].sidedef2));
         }
    }

 /* read in the SideDef information */
 dir = FindMasterDir( Level, "SIDEDEFS");
 if (dir != NULL) NumSideDefs = (short) (dir->dir.size / 30L);
     else NumSideDefs = 0;
 if (NumSideDefs > 0)
    {
     SideDefs = GetFarMemory( (unsigned long) NumSideDefs * sizeof( struct SideDef));
     BasicWadSeek( dir->wadfile, dir->dir.start);
     for (n = 0; n < NumSideDefs; n++)
         {
          BasicWadRead( dir->wadfile, &(SideDefs[ n].xoff), 2);
          fixword(&(SideDefs[n].xoff));
          BasicWadRead( dir->wadfile, &(SideDefs[ n].yoff), 2);
          fixword(&(SideDefs[n].yoff));
          BasicWadRead( dir->wadfile, &(SideDefs[ n].tex1), 8);
          BasicWadRead( dir->wadfile, &(SideDefs[ n].tex2), 8);
          BasicWadRead( dir->wadfile, &(SideDefs[ n].tex3), 8);
          BasicWadRead( dir->wadfile, &(SideDefs[ n].sector), 2);
          fixword(&(SideDefs[n].sector));
         }
    }

 /* read in the Vertices which are all the corners of the level, but ignore the */
 /* Vertices not used in any LineDef (they usually are at the end of the list). */
 NumVertexes = 0;
 for (n = 0; n < OldNumVertexes; n++)
     if (VertexUsed[ n]) NumVertexes++;
 if (NumVertexes > 0)
    {
     Vertexes = GetFarMemory( (unsigned long) NumVertexes * sizeof( struct Vertex));
     dir = FindMasterDir( Level, "VERTEXES");
     BasicWadSeek( dir->wadfile, dir->dir.start);
     MapMaxX = -32767;
     MapMaxY = -32767;
     MapMinX = 32767;
     MapMinY = 32767;
     m = 0;
     for (n = 0; n < OldNumVertexes; n++)
         {
          BasicWadRead( dir->wadfile, &val, 2);
          fixword(&val);
          if (VertexUsed[ n])
             {
              if (val < MapMinX) MapMinX = val;
              if (val > MapMaxX) MapMaxX = val;
              Vertexes[ m].x = val;
             }
          BasicWadRead( dir->wadfile, &val, 2);
          fixword(&val);
          if (VertexUsed[ n])
             {
              if (val < MapMinY) MapMinY = val;
              if (val > MapMaxY) MapMaxY = val;
              Vertexes[ m].y = val;
              m++;
             }
         }
     if (m != NumVertexes)
	 ProgError("inconsistency in the Vertexes data\n");
    }

 if (OldNumVertexes > 0)
    {
     /* update the Vertex numbers in the LineDefs (not really necessary, but...) */
     m = 0;
     for (n = 0; n < OldNumVertexes; n++)
	      if (VertexUsed[ n]) VertexUsed[ n] = m++;
     ObjectsNeeded( OBJ_LINEDEFS, 0);
     for (n = 0; n < NumLineDefs; n++)
         {
          LineDefs[ n].start = VertexUsed[ LineDefs[ n].start];
          LineDefs[ n].end = VertexUsed[ LineDefs[ n].end];
         }
     ObjectsNeeded( 0);
     FreeMemory( VertexUsed);
    }

 /* ignore the Segs, SSectors and Nodes */

 /* read in the Sectors information */
 dir = FindMasterDir( Level, "SECTORS");
 if (dir != NULL) NumSectors = (short) (dir->dir.size / 26L);
     else NumSectors = 0;
 if (NumSectors > 0)
    {
     Sectors = GetFarMemory( (unsigned long) NumSectors * sizeof( struct Sector));
     BasicWadSeek( dir->wadfile, dir->dir.start);
     for (n = 0; n < NumSectors; n++)
         {
          BasicWadRead( dir->wadfile, &(Sectors[ n].floorh), 2);
          fixword(&(Sectors[n].floorh));
          BasicWadRead( dir->wadfile, &(Sectors[ n].ceilh), 2);
          fixword(&(Sectors[n].ceilh));
          BasicWadRead( dir->wadfile, &(Sectors[ n].floort), 8);
          BasicWadRead( dir->wadfile, &(Sectors[ n].ceilt), 8);
          BasicWadRead( dir->wadfile, &(Sectors[ n].light), 2);
          fixword(&(Sectors[n].light));
          BasicWadRead( dir->wadfile, &(Sectors[ n].special), 2);
          fixword(&(Sectors[n].special));
          BasicWadRead( dir->wadfile, &(Sectors[ n].tag), 2);
          fixword(&(Sectors[n].tag));
         }
    }

 /* ignore the last entries (Reject & BlockMap) */
}



/*
** forget the level data
*/
void ForgetLevelData() /* SWAP! */
{
 /* forget the Things */
 ObjectsNeeded( OBJ_THINGS, 0);
 NumThings = 0;
 if (Things) FreeFarMemory( Things);
 Things = NULL;

 /* forget the Vertices */
 ObjectsNeeded( OBJ_VERTEXES, 0);
 NumVertexes = 0;
 if (Vertexes) FreeFarMemory( Vertexes);
 Vertexes = NULL;

 /* forget the LineDefs */
 ObjectsNeeded( OBJ_LINEDEFS, 0);
 NumLineDefs = 0;
 if (LineDefs) FreeFarMemory( LineDefs);
 LineDefs = NULL;

 /* forget the SideDefs */
 ObjectsNeeded( OBJ_SIDEDEFS, 0);
 NumSideDefs = 0;
 if (SideDefs) FreeFarMemory( SideDefs);
 SideDefs = NULL;

 /* forget the Sectors */
 ObjectsNeeded( OBJ_SECTORS, 0);
 NumSectors = 0;
 if (Sectors) FreeFarMemory( Sectors);
 Sectors = NULL;
 ObjectsNeeded( 0);
}



/*
** recursively save the Nodes data to a PWAD file
*/
void SaveNodes( FILE *file, NPtr node)
{
 /* Nodes tree walk: save child1, save child2, save parent */
 if ((node->child1 & 0x8000) == 0)
    {
     SaveNodes( file, node->node1);
     node->child1 = node->node1->num;
    }
 if ((node->child2 & 0x8000) == 0)
    {
     SaveNodes( file, node->node2);
     node->child2 = node->node2->num;
    }

 fixword(&(node->x));
 fixword(&(node->y));
 fixword(&(node->dx));
 fixword(&(node->dy));
 fixword(&(node->maxy1));
 fixword(&(node->miny1));
 fixword(&(node->minx1));
 fixword(&(node->maxx1));
 fixword(&(node->maxy2));
 fixword(&(node->miny2));
 fixword(&(node->minx2));
 fixword(&(node->maxx2));
 fixword(&(node->child1));
 fixword(&(node->child2));

 WriteBytes( file, &(node->x), 2L);
 WriteBytes( file, &(node->y), 2L);
 WriteBytes( file, &(node->dx), 2L);
 WriteBytes( file, &(node->dy), 2L);
 WriteBytes( file, &(node->maxy1), 2L);
 WriteBytes( file, &(node->miny1), 2L);
 WriteBytes( file, &(node->minx1), 2L);
 WriteBytes( file, &(node->maxx1), 2L);
 WriteBytes( file, &(node->maxy2), 2L);
 WriteBytes( file, &(node->miny2), 2L);
 WriteBytes( file, &(node->minx2), 2L);
 WriteBytes( file, &(node->maxx2), 2L);
 WriteBytes( file, &(node->child1), 2L);
 WriteBytes( file, &(node->child2), 2L);

 fixword(&(node->x));
 fixword(&(node->y));
 fixword(&(node->dx));
 fixword(&(node->dy));
 fixword(&(node->maxy1));
 fixword(&(node->miny1));
 fixword(&(node->minx1));
 fixword(&(node->maxx1));
 fixword(&(node->maxy2));
 fixword(&(node->miny2));
 fixword(&(node->minx2));
 fixword(&(node->maxx2));
 fixword(&(node->child1));
 fixword(&(node->child2));

 node->num = NumNodes++;
}



/*
** forget the Nodes
*/
void ForgetNodes( NPtr node)
{
 if ((node->child1 & 0x8000) == 0) ForgetNodes( node->node1);
 if ((node->child2 & 0x8000) == 0) ForgetNodes( node->node2);

 FreeFarMemory( node);
}



/*
** save the level data to a PWAD file
*/
void SaveLevelData( char *outfile) /* SWAP! */
{
 FILE   *file;
 MDirPtr dir;
 long    counter = 11;
 short   n, i, j;
 void   *data;
 long    size;
 long    dirstart;
 short   *blockptr;
 long    blocksize;
 short   blockcount;
 long    oldpos;
 Bool    newnodes;
 long    rejectsize;
 short   oldNumVertexes;

 LogMessage( ": Saving data to \"%s\"...\n", outfile);
 oldNumVertexes = NumVertexes;
 /* open the file */
 if ((file = fopen( outfile, "wb")) == NULL)
      ProgError( "Unable to open file \"%s\"", outfile);
 WriteBytes( file, "PWAD", 4L);     /* PWAD file */
 fixlong(&counter);
 WriteBytes( file, &counter, 4L);   /* 11 entries */
 WriteBytes( file, &counter, 4L);   /* fix this up later */
 fixlong(&counter);
 counter = 12L;
 dir = Level->next;

 /* output the things data */
 ObjectsNeeded( OBJ_THINGS, 0);
 for (n = 0; n < NumThings; n++)
     {
      fixlong(&(Things[n].xpos));
      WriteBytes( file, &(Things[ n].xpos), 2L);
      fixlong(&(Things[n].xpos));
      fixlong(&(Things[n].ypos));
      WriteBytes( file, &(Things[ n].ypos), 2L);
      fixlong(&(Things[n].ypos));
      fixlong(&(Things[n].angle));
      WriteBytes( file, &(Things[ n].angle), 2L);
      fixlong(&(Things[n].angle));
      fixlong(&(Things[n].type));
      WriteBytes( file, &(Things[ n].type), 2L);
      fixlong(&(Things[n].type));
      fixlong(&(Things[n].when));
      WriteBytes( file, &(Things[ n].when), 2L);
      fixlong(&(Things[n].when));
      counter += 10L;
     }
 dir = dir->next;

 /* update MapMinX, MapMinY, MapMaxX, MapMaxY */
 ObjectsNeeded( OBJ_VERTEXES, 0);
 MapMaxX = -32767;
 MapMaxY = -32767;
 MapMinX = 32767;
 MapMinY = 32767;
 for (n = 0; n < NumVertexes; n++)
     {
      if (Vertexes[ n].x < MapMinX) MapMinX = Vertexes[ n].x;
      if (Vertexes[ n].x > MapMaxX)	MapMaxX = Vertexes[ n].x;
      if (Vertexes[ n].y < MapMinY)	MapMinY = Vertexes[ n].y;
      if (Vertexes[ n].y > MapMaxY) MapMaxY = Vertexes[ n].y;
     }

 /* do we need to rebuild the Nodes, Segs and SSectors? */
 if (MadeMapChanges && (Expert || form_alert(1,"[2][Do you want to rebuild the data-structures? |WARNING: You won't be able to use your level |if you don't do this... [Yes|No]")==1))
    {
     SEPtr seglist;

     printf( "Rebuilding the NODES...");
     seglist = NULL;
     ObjectsNeeded( OBJ_LINEDEFS, OBJ_VERTEXES, 0);
     for (n = 0; n < NumLineDefs; n++)
         {
          if (LineDefs[ n].sidedef1 >= 0)
             {
              if (seglist)
                 {
                  LastSeg->next = GetMemory( sizeof( struct Seg));
                  LastSeg = LastSeg->next;
                 }
                else
                 {
                  seglist = GetMemory( sizeof( struct Seg));
                  LastSeg = seglist;
                 }
              LastSeg->next = NULL;
              LastSeg->start = LineDefs[ n].start;
              LastSeg->end = LineDefs[ n].end;
              LastSeg->angle = ComputeAngle(Vertexes[ LineDefs[ n].end].x - Vertexes[ LineDefs[ n].start].x,
              Vertexes[ LineDefs[ n].end].y - Vertexes[ LineDefs[ n].start].y);
              LastSeg->linedef = n;
              LastSeg->flip = 0;
              LastSeg->dist = 0;
             }
          if (LineDefs[ n].sidedef2 >= 0)
             {
              if (seglist)
                 {
                  LastSeg->next = GetMemory( sizeof( struct Seg));
                  LastSeg = LastSeg->next;
                 }
                else
                 {
                  seglist = GetMemory( sizeof( struct Seg));
                  LastSeg = seglist;
                 }
              LastSeg->next = NULL;
              LastSeg->start = LineDefs[ n].end;
              LastSeg->end = LineDefs[ n].start;
              LastSeg->angle = ComputeAngle(Vertexes[ LineDefs[ n].start].x - Vertexes[ LineDefs[ n].end].x,
              Vertexes[ LineDefs[ n].start].y - Vertexes[ LineDefs[ n].end].y);
              LastSeg->linedef = n;
              LastSeg->flip = 1;
              LastSeg->dist = 0;
             }
         }
/*   ShowProgress( OBJ_VERTEXES);
     ShowProgress( OBJ_SIDEDEFS);
*/   LogMessage( ": Starting Nodes builder...\n");
     LogMessage( "\tNumber of Vertices: %d\n", NumVertexes);
     LogMessage( "\tNumber of Segs:     %d\n", NumSegs);
     ObjectsNeeded( OBJ_VERTEXES, 0);
     if (CreateNodes( &Nodes, &n, seglist) == FALSE)
        {
         Beep();
         Beep();
         Beep();
         LogMessage( "\nError: CreateNodes failed!\n\n");
         Beep();
         Beep();
         Beep();
        }
     LogMessage( ": Nodes created OK.\n");
     LogMessage( "\tNumber of Vertices: %d\n", NumVertexes);
     LogMessage( "\tNumber of SideDefs: %d\n", NumSideDefs);
     LogMessage( "\tNumber of Segs:     %d\n", NumSegs);
     LogMessage( "\tNumber of SSectors: %d\n", NumSSectors);
     newnodes = TRUE;
    }
   else newnodes = FALSE;

 /* output the LineDefs */
 ObjectsNeeded( OBJ_LINEDEFS, 0);
 for (n = 0; n < NumLineDefs; n++)
     {
      fixword(&(LineDefs[n].start));
      WriteBytes( file, &(LineDefs[ n].start), 2L);
      fixword(&(LineDefs[n].start));
      fixword(&(LineDefs[n].end));
      WriteBytes( file, &(LineDefs[ n].end), 2L);
      fixword(&(LineDefs[n].end));
      fixword(&(LineDefs[n].flags));
      WriteBytes( file, &(LineDefs[ n].flags), 2L);
      fixword(&(LineDefs[n].flags));
      fixword(&(LineDefs[n].type));
      WriteBytes( file, &(LineDefs[ n].type), 2L);
      fixword(&(LineDefs[n].type));
      fixword(&(LineDefs[n].tag));
      WriteBytes( file, &(LineDefs[ n].tag), 2L);
      fixword(&(LineDefs[n].tag));
      fixword(&(LineDefs[n].sidedef1));
      WriteBytes( file, &(LineDefs[ n].sidedef1), 2L);
      fixword(&(LineDefs[n].sidedef1));
      fixword(&(LineDefs[n].sidedef2));
      WriteBytes( file, &(LineDefs[ n].sidedef2), 2L);
      fixword(&(LineDefs[n].sidedef2));
      counter += 14L;
     }
 dir = dir->next;

 /* output the SideDefs */
 ObjectsNeeded( OBJ_SIDEDEFS, 0);
 for (n = 0; n < NumSideDefs; n++)
     {
      fixword(&(SideDefs[n].xoff));
      WriteBytes( file, &(SideDefs[ n].xoff), 2L);
      fixword(&(SideDefs[n].xoff));
      fixword(&(SideDefs[n].yoff));
      WriteBytes( file, &(SideDefs[ n].yoff), 2L);
      fixword(&(SideDefs[n].yoff));
      WriteBytes( file, &(SideDefs[ n].tex1), 8L);
      WriteBytes( file, &(SideDefs[ n].tex2), 8L);
      WriteBytes( file, &(SideDefs[ n].tex3), 8L);
      fixword(&(SideDefs[n].sector));
      WriteBytes( file, &(SideDefs[ n].sector), 2L);
      fixword(&(SideDefs[n].sector));
      counter += 30L;
     }
 dir = dir->next;

 if (MadeMapChanges)
    {
     /* output the Vertices */
     ObjectsNeeded( OBJ_VERTEXES, 0);
     for (n = 0; n < NumVertexes; n++)
         {
          fixword(&(Vertexes[n].x));
          WriteBytes( file, &(Vertexes[ n].x), 2L);
          fixword(&(Vertexes[n].x));
          fixword(&(Vertexes[n].y));
          WriteBytes( file, &(Vertexes[ n].y), 2L);
          fixword(&(Vertexes[n].y));
          counter += 4L;
         }
    }
   else
    {
     /* copy the Vertices */
     ObjectsNeeded( 0);
     size = dir->dir.size;
     counter += size;
     BasicWadSeek( dir->wadfile, dir->dir.start);
     CopyBytes( file, dir->wadfile->fileinfo, size);
    }
 dir = dir->next;

 if (newnodes)
    {
     SEPtr curse, oldse;
     SSPtr curss, oldss;

     ObjectsNeeded( 0);
     /* output and forget the Segments */
     curse = Segs;
     while (curse)
       {
        fixword(&(curse->start));
        WriteBytes( file, &(curse->start), 2L);
        fixword(&(curse->start));
        fixword(&(curse->end));
        WriteBytes( file, &(curse->end), 2L);
        fixword(&(curse->end));
        fixword(&(curse->angle));
        WriteBytes( file, &(curse->angle), 2L);
        fixword(&(curse->angle));
        fixword(&(curse->linedef));
        WriteBytes( file, &(curse->linedef), 2L);
        fixword(&(curse->linedef));
        fixword(&(curse->flip));
        WriteBytes( file, &(curse->flip), 2L);
        fixword(&(curse->flip));
        fixword(&(curse->dist));
        WriteBytes( file, &(curse->dist), 2L);
        fixword(&(curse->dist));
        oldse = curse;
        curse = curse->next;
        FreeFarMemory( oldse);
        counter += 12L;
       }
    Segs = NULL;
    dir = dir->next;

    /* output and forget the SSectors */
    curss = SSectors;
    while (curss)
      {
       fixword(&(curss->num));
       WriteBytes( file, &(curss->num), 2L);
       fixword(&(curss->num));
       fixword(&(curss->first));
       WriteBytes( file, &(curss->first), 2L);
       fixword(&(curss->first));
       oldss = curss;
       curss = curss->next;
       FreeFarMemory( oldss);
       counter += 4L;
      }
    SSectors = NULL;
    dir = dir->next;

    /* output the Nodes */
    NumNodes = 0;
    SaveNodes( file, Nodes);
    counter += (long) NumNodes * 28L;
    dir = dir->next;

    /* forget the Nodes */
    ForgetNodes( Nodes);
    Nodes = NULL;
   }
  else
   {
    /* copy the Segs, SSectors and Nodes */
    for (n = 0; n < 3; n++)
        {
         size = dir->dir.size;
         counter += size;
         BasicWadSeek( dir->wadfile, dir->dir.start);
         CopyBytes( file, dir->wadfile->fileinfo, size);
         dir = dir->next;
        }
   }
 /* output the Sectors */
 ObjectsNeeded( OBJ_SECTORS, 0);
 for (n = 0; n < NumSectors; n++)
     {
      fixword(&(Sectors[n].floorh));
      WriteBytes( file, &(Sectors[ n].floorh), 2L);
      fixword(&(Sectors[n].floorh));
      fixword(&(Sectors[n].ceilh));
      WriteBytes( file, &(Sectors[ n].ceilh), 2L);
      fixword(&(Sectors[n].ceilh));
      WriteBytes( file, &(Sectors[ n].floort), 8L);
      WriteBytes( file, &(Sectors[ n].ceilt), 8L);
      fixword(&(Sectors[n].light));
      WriteBytes( file, &(Sectors[ n].light), 2L);
      fixword(&(Sectors[n].light));
      fixword(&(Sectors[n].special));
      WriteBytes( file, &(Sectors[ n].special), 2L);
      fixword(&(Sectors[n].special));
      fixword(&(Sectors[n].tag));
      WriteBytes( file, &(Sectors[ n].tag), 2L);
      fixword(&(Sectors[n].tag));
      counter += 26L;
     }
 dir = dir->next;

 if (newnodes)
    {
     /* create and output the reject data */
     ObjectsNeeded( OBJ_SECTORS, 0); /* !!! */
     printf("Rebuilding the REJECT data...");
     rejectsize = ((long) NumSectors * (long) NumSectors + 7L) / 8L;
     data = GetMemory( (size_t) rejectsize);
     for (i = 0; i < rejectsize; i++)
          ((char *) data)[ i] = 0;
     for (i = 0; i < NumSectors; i++)
         {
/*        DrawScreenMeter( 225, 108, ScrMaxX - 10, 128, (float) i / (float) NumSectors);
*/
          for (j = 0; j < NumSectors; j++)
              {

            /* Here is some code which is not finished in DEU 5.21... Bummer.
            *  if (Reject( i, j))
            *     data[ (i * NumSectors + j) / 8] |= 1 <<
            */
              }
         }
     WriteBytes( file, data, rejectsize);
     counter += rejectsize;
     dir = dir->next;
     FreeMemory( data);
    }
   else
    {
     /* copy the Reject data */
     ObjectsNeeded( 0);
     rejectsize = dir->dir.size;
     size = rejectsize;
     counter += size;
     BasicWadSeek( dir->wadfile, dir->dir.start);
     CopyBytes( file, dir->wadfile->fileinfo, size);
     dir = dir->next;
    }

 if (newnodes)
    {
     short mminx, mminy, mnumx, mnumy, n2;

     /* create and output the blockmap */
     ObjectsNeeded( OBJ_LINEDEFS, OBJ_VERTEXES, 0);
     printf( "Rebuilding the BLOCKMAP...");
     mminx = (short) (MapMinX / 8 - 8) * 8;
     fixword(&(mminx));
     WriteBytes( file, &mminx, 2L);
     fixword(&(mminx));
     mminy = (short) (MapMinY / 8 - 8) * 8;
     fixword(&(mminy));
     WriteBytes( file, &mminy, 2L);
     fixword(&(mminy));
     mnumx = MapMaxX / 128 - mminx / 128 + 2;
     fixword(&(mnumx));
     WriteBytes( file, &mnumx, 2L);
     fixword(&(mnumx));
     mnumy = MapMaxY / 128 - mminy / 128 + 2;
     fixword(&(mnumy));
     WriteBytes( file, &mnumy, 2L);
     fixword(&(mnumy));
     counter += 8L;
     oldpos = ftell( file);
     blocksize = (long) (mnumx * mnumy * sizeof( short));
     blockptr = GetMemory( blocksize);
     WriteBytes( file, blockptr, blocksize);
     blocksize += 8L;
     counter += blocksize - 7L;
     blockcount = mnumx * mnumy + 4;
     for (i = 0; i < mnumy; i++)
         {
/*        DrawScreenMeter( 225, 188, ScrMaxX - 10, 208, (float) i / (float) mnumy);
*/
          for (j = 0; j < mnumx; j++)
              {
               blockptr[ mnumx * i + j] = blockcount;
               n2 = 0;
               fixword(&(n2));
               WriteBytes( file, &n2, 2L);
               fixword(&(n2));
               counter += 2L;
               blocksize += 2L;
               blockcount++;
               for (n2 = 0; n2 < NumLineDefs; n2++)
                    if (IsLineDefInside( n, mminx + j * 128, mminy + i * 128, mminx + 127 + j * 128, mminy + 127 + i * 128))
                       {
                        fixword(&(n2));
                        WriteBytes( file, &n2, 2L);
                        fixword(&(n2));
                        counter += 2L;
                        blocksize += 2L;
                        blockcount++;
                       }
               n2 = -1;
               fixword(&(n2));
               WriteBytes( file, &n2, 2L);
               fixword(&(n2));
               counter += 2L;
               blocksize += 2L;
               blockcount++;
              }
         }
     size = ftell( file);
     fseek( file, oldpos, SEEK_SET);
     WriteBytes( file, blockptr, (long) (mnumx * mnumy * sizeof( short)));
     fseek( file, size, SEEK_SET);
     if (FindMasterDir( dir, "P2_END"))
	 counter--;
     FreeMemory( blockptr);
    }
   else
    {
     /* copy the blockmap data */
     ObjectsNeeded( 0);
     blocksize = dir->dir.size;
     size = blocksize;
     counter += size;
     BasicWadSeek( dir->wadfile, dir->dir.start);
     CopyBytes( file, dir->wadfile->fileinfo, size);
     dir = dir->next;
    }

 /* output the actual directory */
 dirstart = counter;
 counter = 12L;
 size = 0L;
 dir = Level;
 fixlong(&(counter));
 WriteBytes( file, &counter, 4L);
 fixlong(&(counter));
 fixlong(&(size));
 WriteBytes( file, &size, 4L);
 fixlong(&(size));
 WriteBytes( file, &(dir->dir.name), 8L);
 dir = dir->next;

 size = (long) NumThings * 10L;
 fixlong(&(counter));
 WriteBytes( file, &counter, 4L);
 fixlong(&(counter));
 fixlong(&(size));
 WriteBytes( file, &size, 4L);
 fixlong(&(size));
 WriteBytes( file, "THINGS\0\0", 8L);
 counter += size;
 dir = dir->next;

 size = (long) NumLineDefs * 14L;
 fixlong(&(counter));
 WriteBytes( file, &counter, 4L);
 fixlong(&(counter));
 fixlong(&(size));
 WriteBytes( file, &size, 4L);
 fixlong(&(size));
 WriteBytes( file, "LINEDEFS", 8L);
 counter += size;
 dir = dir->next;

 size = (long) NumSideDefs * 30L;
 fixlong(&(counter));
 WriteBytes( file, &counter, 4L);
 fixlong(&(counter));
 fixlong(&(size));
 WriteBytes( file, &size, 4L);
 fixlong(&(size));
 WriteBytes( file, "SIDEDEFS", 8L);
 counter += size;
 dir = dir->next;

 if (MadeMapChanges) size = (long) NumVertexes * 4L;
     else size = dir->dir.size;
 fixlong(&(counter));
 WriteBytes( file, &counter, 4L);
 fixlong(&(counter));
 fixlong(&(size));
 WriteBytes( file, &size, 4L);
 fixlong(&(size));
 WriteBytes( file, "VERTEXES", 8L);
 counter += size;
 dir = dir->next;

 if (newnodes) size = (long) NumSegs * 12L;
     else size = dir->dir.size;
 fixlong(&(counter));
 WriteBytes( file, &counter, 4L);
 fixlong(&(counter));
 fixlong(&(size));
 WriteBytes( file, &size, 4L);
 fixlong(&(size));
 WriteBytes( file, "SEGS\0\0\0\0", 8L);
 counter += size;
 dir = dir->next;

 if (newnodes) size = (long) NumSSectors * 4L;
     else size = dir->dir.size;
 fixlong(&(counter));
 WriteBytes( file, &counter, 4L);
 fixlong(&(counter));
 fixlong(&(size));
 WriteBytes( file, &size, 4L);
 fixlong(&(size));
 WriteBytes( file, "SSECTORS", 8L);
 counter += size;
 dir = dir->next;

 if (newnodes) size = (long) NumNodes * 28L;
     else size = dir->dir.size;
 fixlong(&(counter));
 WriteBytes( file, &counter, 4L);
 fixlong(&(counter));
 fixlong(&(size));
 WriteBytes( file, &size, 4L);
 fixlong(&(size));
 WriteBytes( file, "NODES\0\0\0", 8L);
 counter += size;
 dir = dir->next;

 size = (long) NumSectors * 26L;
 fixlong(&(counter));
 WriteBytes( file, &counter, 4L);
 fixlong(&(counter));
 fixlong(&(size));
 WriteBytes( file, &size, 4L);
 fixlong(&(size));
 WriteBytes( file, "SECTORS\0", 8L);
 counter += size;
 dir = dir->next;

 size = rejectsize;
 fixlong(&(counter));
 WriteBytes( file, &counter, 4L);
 fixlong(&(counter));
 fixlong(&(size));
 WriteBytes( file, &size, 4L);
 fixlong(&(size));
 WriteBytes( file, "REJECT\0\0", 8L);
 counter += size;
 dir = dir->next;

 size = blocksize;
 fixlong(&(counter));
 WriteBytes( file, &counter, 4L);
 fixlong(&(counter));
 fixlong(&(size));
 WriteBytes( file, &size, 4L);
 fixlong(&(size));
 WriteBytes( file, "BLOCKMAP", 8L);
 counter += size;
 dir = dir->next;

 /* fix up the directory start information */
 if (fseek( file, 8L, SEEK_SET))
     ProgError( "error writing to file");
 fixlong(&(dirstart));
 WriteBytes( file, &dirstart, 4L);
 fixlong(&(dirstart));

 /* close the file */
 fclose( file);

 NumSegs = 0;
 NumSSectors = 0;
 NumNodes = 0;

 /* delete the vertices added by the Nodes builder */
 if (NumVertexes != oldNumVertexes)
    {
     ObjectsNeeded( OBJ_VERTEXES, 0);
     NumVertexes = oldNumVertexes;
     ResizeFarMemory( Vertexes, NumVertexes * sizeof( struct Vertex));
    }

 /* the file is now up to date */
 MadeChanges = FALSE;
 if (newnodes) MadeMapChanges = FALSE;
 ObjectsNeeded( 0);

 /* update pointers in Master Directory */
 OpenPatchWad( outfile);

 /* this should free the old "*.BAK" file */
 CloseUnusedWadFiles();
}



/*
** function used by qsort to sort the texture names
*/
short SortTextures( const void *a, const void *b)
{
 return strcmp( *((char **)a), *((char **)b));
}



/*
** read in the wall texture names
*/
void ReadWTextureNames()
{
 MDirPtr dir;
 long *offsets;
 short n;
 long val;

 LogMessage("Reading wall texture names\n");
 dir = FindMasterDir( MasterDir, "TEXTURE1");
 BasicWadSeek( dir->wadfile, dir->dir.start);
 BasicWadRead( dir->wadfile, &val, 4);
 fixlong(&val);
 NumWTexture = (short) val + 1;
 /* read in the offsets for texture1 names */
 offsets = GetMemory( NumWTexture * sizeof( long));
 for (n = 1; n < NumWTexture; n++)
     {
      BasicWadRead( dir->wadfile, &(offsets[ n]), 4);
      fixlong(&(offsets[n]));
     }
 /* read in the actual names */
 WTexture = GetMemory( NumWTexture * sizeof( char *));
 WTexture[ 0] = GetMemory( 9 * sizeof( char));
 strcpy(WTexture[ 0], "-");
 for (n = 1; n < NumWTexture; n++)
     {
      WTexture[ n] = GetMemory( 9 * sizeof( char));
      BasicWadSeek( dir->wadfile, dir->dir.start + offsets[ n]);
      BasicWadRead( dir->wadfile, WTexture[ n], 8);
      WTexture[ n][ 8] = '\0';
     }
 FreeMemory( offsets);
 if (Registered)
    {
     dir = FindMasterDir( MasterDir, "TEXTURE2");
     BasicWadSeek( dir->wadfile, dir->dir.start);
     BasicWadRead( dir->wadfile, &val, 4);
     fixlong(&val);
     /* read in the offsets for texture2 names */
     offsets = GetMemory( val * sizeof( long));
     for (n = 0; n < val; n++)
         {
          BasicWadRead( dir->wadfile, &(offsets[ n]), 4);
          fixlong(&(offsets[n]));
         }
     /* read in the actual names */
     WTexture = ResizeMemory( WTexture, (NumWTexture + val) * sizeof( char *));
     for (n = 0; n < val; n++)
         {
          WTexture[ NumWTexture + n] = GetMemory( 9 * sizeof( char));
          BasicWadSeek( dir->wadfile, dir->dir.start + offsets[ n]);
          BasicWadRead( dir->wadfile, WTexture[ NumWTexture + n], 8);
          WTexture[ NumWTexture + n][ 8] = '\0';
         }
     NumWTexture += val;
     FreeMemory( offsets);
    }
 /* sort the names */
 qsort( WTexture, NumWTexture, sizeof( char *), SortTextures);
}



/*
** forget the wall texture names
*/
void ForgetWTextureNames()
{
 short n;

 /* forget all names */
 for (n = 0; n < NumWTexture; n++)
      FreeMemory( WTexture[ n]);

 /* forget the array */
 NumWTexture = 0;
 FreeMemory( WTexture);
}



/*
** read in the floor/ceiling texture names
*/
void ReadFTextureNames()
{
 MDirPtr dir;
 short n, m;

 LogMessage("Reading floor/ceiling texture names\n");
 /* count the names */
 dir = FindMasterDir( MasterDir, "F1_START");
 dir = dir->next;
 for (n = 0; dir && strcmp(dir->dir.name, "F1_END"); n++)
      dir = dir->next;
 NumFTexture = n;
 /* get the actual names from master dir. */
 dir = FindMasterDir( MasterDir, "F1_START");
 dir = dir->next;
 FTexture = GetMemory( NumFTexture * sizeof( char *));
 for (n = 0; n < NumFTexture; n++)
     {
      FTexture[ n] = GetMemory( 9 * sizeof( char));
      strncpy( FTexture[ n], dir->dir.name, 8);
      FTexture[ n][ 8] = '\0';
      dir = dir->next;
     }
 if (Registered)
    {
     /* count the names */
     dir = FindMasterDir( MasterDir, "F2_START");
     dir = dir->next;
     for (n = 0; dir && strcmp(dir->dir.name, "F2_END"); n++)
	      dir = dir->next;
     /* get the actual names from master dir. */
     dir = FindMasterDir( MasterDir, "F2_START");
     dir = dir->next;
     FTexture = ResizeMemory( FTexture, (NumFTexture + n) * sizeof( char *));
     for (m = NumFTexture; m < NumFTexture + n; m++)
         {
          FTexture[ m] = GetMemory( 9 * sizeof( char));
          strncpy( FTexture[ m], dir->dir.name, 8);
          FTexture[ m][ 8] = '\0';
          dir = dir->next;
         }
     NumFTexture += n;
    }
 /* sort the names */
 qsort( FTexture, NumFTexture, sizeof( char *), SortTextures);
}



/*
** forget the floor/ceiling texture names
*/
void ForgetFTextureNames()
{
 short n;

 /* forget all names */
 for (n = 0; n < NumFTexture; n++)
      FreeMemory( FTexture[ n]);

 /* forget the array */
 NumFTexture = 0;
 FreeMemory( FTexture);
}



/* end of file */
