/* Compile-time options for Booz to allow custom versions to be built */

/* 
Use buffer sizes of at least 1024, larger if enough memory is
available.  Buffer sizes of over 8192 have not been confirmed to work.
*/
#define  IN_BUF_SIZE       1024
#define  OUT_BUF_SIZE      1024

/* 
Decompression stack.  Except in pathological cases, 2000 bytes should
be enough.  Rare files may need a bigger stack to decompress.
May be decreased to 1000 bytes if memory is tight.
*/
#define  STACKSIZE   2000        /* adjust to conserve memory */

/* 
Define one of the symbols TINY, SMALL, and BIG.  Do not define more than
one of these symbols.  The effects are:

   Symbol      Effect

   TINY        A very tiny barebones version that always extracts an entire
               archive at a time.  Should compile and run under CP/M.

   SMALL       A slightly bigger version that will let the user specify
               which files are to be extracted from the archive.  Wildcards
               "?" and "*" are accepted in any combination.  Still quite
               small.  Will probably compile and run under CP/M.

   BIG         Does everything that the SMALL version does.  In addition, 
               it will list and test archives.  May or may not compile 
               and run under CP/M.
*/

/* Only one of the three following symbols should be defined */
/* #define TINY  */
/* #define SMALL */
#define BIG  

/* Define FIXFNAME to activate the fixfname() function that converts
filename syntax to be acceptable to the host system */
#define FIXFNAME 
