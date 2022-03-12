/*
   Doom Editor Utility, by Brendon Wyber and Rapha‰l Quinet.

   GEM-DEU port by Anthony Jacques (jacquesa@cs.man.ac.uk)

   You are allowed to use any parts of this code in another program, as
   long as you give credits to the authors in the documentation and in
   the program itself.  Read the file README.1ST for more information.

   This program comes with absolutely no warranty.

   MEMORY.C - Memory allocation routines.
*/

/* the includes */
#include "deu.h"

/*
   Note from RQ:
      To prevent memory fragmentation on large blocks (greater than 1K),
      the size of all blocks is rounded up to 8K.  Thus, "realloc" will
      move the block if and only if it has grown or shrunk enough to
      cross a 8K boundary.
      I don't do that for smaller blocks (smaller than 1K), because this
      would waste too much space if these blocks were rounded up to 8K.
      There are lots of "malloc"'s for very small strings (9 characters)
      or filenames, etc.
      Thanks to Craig Smith (bcs@cs.tamu.edu) for some of his ideas
      about memory fragmentation.
*/

#define SIZE_THRESHOLD	1024
#define SIZE_OF_BLOCK	4095  /* actually, this is (size - 1) */


/*
** allocate memory with error checking
*/
void *GetMemory( size_t size)
{
 void *ret;

 /* limit fragmentation on large blocks */
 if (size >= (size_t) SIZE_THRESHOLD)
     size = (size + (size_t) SIZE_OF_BLOCK) & ~((size_t) SIZE_OF_BLOCK);
 ret = malloc( size);
 if (!ret)
    {
     /* retry after having freed some memory, if possible */
     FreeSomeMemory();
     ret = malloc( size);
    }
 if (!ret)
     ProgError( "out of memory (cannot allocate %u bytes)", size);

 return ret;
}



/*
** reallocate memory with error checking
*/
void *ResizeMemory( void *old, size_t size)
{
 void *ret;

 /* limit fragmentation on large blocks */
 if (size >= (size_t) SIZE_THRESHOLD)
     size = (size + (size_t) SIZE_OF_BLOCK) & ~((size_t) SIZE_OF_BLOCK);
 ret = realloc(old, size);
 if (!ret)
    {
     FreeSomeMemory();
     ret = realloc( old, size);
    }
 if (!ret)
     ProgError( "out of memory (cannot reallocate %u bytes)", size);

 return ret;
}



/*
** free memory
*/
void FreeMemory( void *ptr)
{
 /* just a wrapper around free(), but provide an entry point */
 /* for memory debugging routines... */

 free( ptr);
}


/*
** PC Use: allocate memory from the far heap with error checking
**
** Atari Use: wrapper to GetMemory, as we dont have a 'far heap'...
*/
void huge *GetFarMemory( unsigned long size)
{
 size_t s=(size_t) size;

 return(GetMemory(s));
}



/*
** PC Use: reallocate memory from the far heap with error checking
**
** Atari Use: see above.
*/
void huge *ResizeFarMemory( void huge *old, unsigned long size)
{
 size_t s=(size_t) size;

 return(ResizeMemory(old,s));
}



/*
** PC Use: free memory from the far heap
**
** Atari use: see above.
*/
void FreeFarMemory( void huge *ptr)
{
 FreeMemory(ptr);
}


/* end of file */
