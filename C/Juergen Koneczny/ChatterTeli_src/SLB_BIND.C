/*
*
* Binding for the use of a "shared library"
*
* Andreas Kromke
* 22.10.97
*
*/

#include <mgx_dos.h>

/*****************************************************************
*
* Opens a "shared lib".
*
* Input:
*     name             Name of the library, including extension
*     path             Search path with '\', optional
*     min_ver          Minimum required version number
* Returns:
*     sl               Library descriptor
*     fn               Function for calling a library function
*     <ret>            Actual version number, or error code
*
*****************************************************************/

LONG Slbopen( char *name, char *path, LONG min_ver,
                    SHARED_LIB *sl, SLB_EXEC *fn,
                    LONG param )
{
     return(gemdos(0x16, name, path, min_ver, sl, fn, param));
}


/*****************************************************************
*
* Closes a "shared lib".
*
* Returns:
*     <ret>          EACCDN, if library not opened
*
*****************************************************************/

extern LONG Slbclose( SHARED_LIB *sl )

{
     return(gemdos(0x17, sl));
}
