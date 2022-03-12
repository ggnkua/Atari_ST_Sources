/*
   Memory swapping by Rapha‰l Quinet <quinet@montefiore.ulg.ac.be>
		  and Christian Johannes Schladetsch <s924706@yallara.cs.rmit.OZ.AU>

   You are allowed to use any parts of this code in another program, as
   long as you give credits to the authors in the documentation and in
   the program itself.  Read the file README.1ST for more information.

   This program comes with absolutely no warranty.

   SWAPMEM.C - When the memory is low....

   Note from RQ:
      Yuck!  I don't like this horrible thing.  The program should be
      able to swap almost anything to XMS or to disk, not only the
      five objects used here (Things, LineDefs, SideDefs, Vertexes and
      Sectors).  That was a quick and dirty hack...  I didn't have the
      time to write a cleaner code...

   Note2 from RQ:
      After having tested these routines, I see that they are not very
      useful...  I'm still getting "out of memory" errors while editing
      E2M7 and other huge levels.  I should rewrite all this for GCC,
      use a flat memory model and a DOS extender, then just delete all
      this code...  I will have to do that anyway if I want to port it
      to other systems (Unix, Linux), so why not?
      Moral of the story: never waste long hours writing high-level
      memory swapping routines on a deficient OS.  Use a real OS with
      a better memory management instead.

   Note for CJS:
      It should be easy to include your XMS code in this file.  Just
      add the necessary lines in InitSwap(), SwapIn() and SwapOut().
      You won't need to edit any other file.  Put all your routines
      in XMS.C, with the necessary includes in XMS.H.  Please keep it
      short and simple... :-)
      ... And delete this note once you're done.
*/

/* the includes and typedefs */
#include "deu.h"
#include "levels.h"
#ifdef SWAP_TO_XMS
#include "xms.h"
typedef XMSHandle SwapHandle;	/* XMS handle */
#define INVALID_HANDLE		-1
#else
typedef char SwapHandle[ 128];	/* name of the temporary disk file */
#define INVALID_HANDLE		"..."
#endif /* SWAP_TO_XMS */

/* global variables */
Bool NeedThings = FALSE;
Bool NeedLineDefs = FALSE;
Bool NeedSideDefs = FALSE;
Bool NeedVertexes = FALSE;
Bool NeedSectors = FALSE;
SwapHandle ThingsH;
SwapHandle LineDefsH;
SwapHandle SideDefsH;
SwapHandle VertexesH;
SwapHandle SectorsH;


/*
   do the necessary initialisation for the secondary storage
*/

void InitSwap()
{
#ifdef SWAP_TO_XMS
   /* Init XMS */
   ...
#else
   strcpy(ThingsH, INVALID_HANDLE);
   strcpy(LineDefsH, INVALID_HANDLE);
   strcpy(SideDefsH, INVALID_HANDLE);
   strcpy(VertexesH, INVALID_HANDLE);
   strcpy(SectorsH, INVALID_HANDLE);
#endif /* SWAP_TO_XMS */
}



/*
   moves an object from secondary storage to lower RAM
*/

void huge *SwapIn( SwapHandle handle, unsigned long size)
{
   void huge *ptr;
#ifdef SWAP_TO_XMS
   /* allocate a new memory block (in lower RAM) */
   ptr = GetFarMemory( size);
   /* read the data from XMS */
   ...
   /* free the XMS memory block */
   ...
   /* delete the handle */
   ...
#else
   FILE      *file;
   char huge *data;
   SwapHandle oldhandle;

   /* Note from RQ:
	 the following test is there to prevent an infinite loop when
	 SwapIn calls GetFarMemory, which calls FreeSomeMemory, which
	 in turn calls SwapOut, then SwapIn...
    */
   if (! strcmp( handle, INVALID_HANDLE))
      return NULL;
#ifdef DEBUG
   LogMessage( "swapping in %lu bytes from %s\n", size, handle);
#endif /* DEBUG */
   strcpy( oldhandle, handle);
   /* invalidate the handle (must be before "GetFarMemory") */
   strcpy( handle, INVALID_HANDLE);
   /* allocate a new memory block (in lower RAM) */
   ptr = GetFarMemory( size);
   /* read the data from the temporary file */
   file = fopen( oldhandle, "rb");
   data = ptr;
   if (file == NULL)
   {
#ifdef DEBUG
      LogMessage( "\nFree memory before crash: %lu bytes.", farcoreleft());
#endif /* DEBUG */
      ProgError( "error opening temporary file \"%s\"", oldhandle);
   }
   while (size > 0x8000)
   {
      if (fread( data, 1, 0x8000, file) != 0x8000)
	 ProgError( "error reading from temporary file \"%s\"", oldhandle);
      data = data + 0x8000;
      size -= 0x8000;
   }
   if (fread( data, 1, size, file) != size)
      ProgError( "error reading from temporary file \"%s\"", oldhandle);
   fclose( file);
   /* delete the file */
   unlink( oldhandle);
#endif /* !SWAP_TO_XMS */
   return ptr;
}



/*
   moves an object from lower RAM to secondary storage
*/

void SwapOut( void huge *ptr, SwapHandle handle, unsigned long size)
{
#ifdef SWAP_TO_XMS
   /* get a new XMS handle */
   ...
   /* write the data to XMS */
   ...
#else
   FILE      *file;
   char huge *data;
   char      *tmp;

   /* get a new (unique) file name */
   tmp = /*tempnam( NULL, "{DEU}")*/ "deutmp.swp\0";
   if (tmp == NULL)
   {
#ifdef DEBUG
      LogMessage( "\nFree memory before crash: %lu bytes.", farcoreleft());
#endif /* DEBUG */
      ProgError( "cannot create a temporary file name (out of memory)");
   }
   strcpy( handle, tmp);
   free( tmp);
#ifdef DEBUG
   LogMessage( "swapping out %lu bytes to %s\n", size, handle);
#endif /* DEBUG */
   /* write the data to the temporary file */
   data = ptr;
   file = fopen( handle, "wb");
   if (file == NULL)
   {
#ifdef DEBUG
      LogMessage( "\nFree memory before crash: %lu bytes.", farcoreleft());
#endif /* DEBUG */
      ProgError( "error creating temporary file \"%s\"", handle);
   }
   while (size > 0x8000)
   {
      if (fwrite( data, 1, 0x8000, file) != 0x8000)
	 ProgError( "error writing to temporary file \"%s\"", handle);
      data = data + 0x8000;
      size -= 0x8000;
   }
   if (fwrite( data, 1, size, file) != size)
      ProgError( "error writing to temporary file \"%s\"", handle);
   fclose( file);
#endif /* !SWAP_TO_XMS */
   /* free the data block (in lower RAM) */
   FreeFarMemory( ptr);
}



/*
   get the objects needed (if they aren't already in memory)
*/

void SwapInObjects( void)
{
   if (NeedThings && NumThings > 0 && Things == NULL)
      Things = SwapIn( ThingsH, (unsigned long) NumThings * sizeof (struct Thing));
   if (NeedLineDefs && NumLineDefs > 0 && LineDefs == NULL)
      LineDefs = SwapIn( LineDefsH, (unsigned long) NumLineDefs * sizeof (struct LineDef));
   if (NeedSideDefs && NumSideDefs > 0 && SideDefs == NULL)
      SideDefs = SwapIn( SideDefsH, (unsigned long) NumSideDefs * sizeof (struct SideDef));
   if (NeedVertexes && NumVertexes > 0 && Vertexes == NULL)
      Vertexes = SwapIn( VertexesH, (unsigned long) NumVertexes * sizeof (struct Vertex));
   if (NeedSectors && NumSectors > 0 && Sectors == NULL)
      Sectors = SwapIn( SectorsH, (unsigned long) NumSectors * sizeof (struct Sector));
}


/*
   mark the objects that should be in lower RAM
*/

void ObjectsNeeded( short objtype, ...)
{
   va_list args;

   /* get the list of objects */
   NeedThings = FALSE;
   NeedLineDefs = FALSE;
   NeedSideDefs = FALSE;
   NeedVertexes = FALSE;
   NeedSectors = FALSE;
   va_start( args, objtype);
   while (objtype > 0)
   {
      switch (objtype)
      {
      case OBJ_THINGS:
	 NeedThings = TRUE;
	 break;
      case OBJ_LINEDEFS:
	 NeedLineDefs = TRUE;
	 break;
      case OBJ_SIDEDEFS:
	 NeedSideDefs = TRUE;
	 break;
      case OBJ_VERTEXES:
	 NeedVertexes = TRUE;
	 break;
      case OBJ_SECTORS:
	 NeedSectors = TRUE;
	 break;
      }
      objtype = va_arg( args, int);
   }
   va_end( args);
   /* get the objects if they aren't already in memory */
   SwapInObjects();
}



/*
   free as much memory as possible by moving some objects out of lower RAM
*/

void FreeSomeMemory( void)
{
   /* move everything to secondary storage */
   if (NumSectors > 0 && Sectors != NULL)
   {
      SwapOut( Sectors, SectorsH, (unsigned long) NumSectors * sizeof (struct Sector));
      Sectors = NULL;
   }
   if (NumVertexes > 0 && Vertexes != NULL)
   {
      SwapOut( Vertexes, VertexesH, (unsigned long) NumVertexes * sizeof (struct Vertex));
      Vertexes = NULL;
   }
   if (NumSideDefs > 0 && SideDefs != NULL)
   {
      SwapOut( SideDefs, SideDefsH, (unsigned long) NumSideDefs * sizeof (struct SideDef));
      SideDefs = NULL;
   }
   if (NumLineDefs > 0 && LineDefs != NULL)
   {
      SwapOut( LineDefs, LineDefsH, (unsigned long) NumLineDefs * sizeof (struct LineDef));
      LineDefs = NULL;
   }
   if (NumThings > 0 && Things != NULL)
   {
      SwapOut( Things, ThingsH, (unsigned long) NumThings * sizeof (struct Thing));
      Things = NULL;
   }
   /* re-load the objects that are needed */
   SwapInObjects();
}


/* end of file */
