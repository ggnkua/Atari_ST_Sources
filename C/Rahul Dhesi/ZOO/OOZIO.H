/* oozio.h */
/* Definitions for portable I/O.

Definitions are:

OPEN(x)     open file x for read
CREATE(x)   create file x for read/write

Note that files opened by OPEN() and CREATE() must be opened in
binary mode (not involving any LF <-> CR/LF translation).

The contents of this file are hereby released to the public domain.
                                   -- Rahul Dhesi 1987/02/08
*/

/* MIX C compiler for CP/M. */
#ifdef   MIXC
#define  CREATE(x)      (iofilter(0,0), creat (x, 0))
#define  OPEN(x)        (iofilter (0,0), open (x, 0))
#endif

/* Microsoft C 3.0 under MS-DOS */
#ifdef   MSC
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <io.h>
#define  CREATE(x) \
   open (x, O_CREAT|O_WRONLY|O_TRUNC|O_BINARY, S_IREAD|S_IWRITE)
#define  OPEN(x)     open (x, O_RDONLY|O_BINARY)
#endif

/* Turbo C 1.0 under MS-DOS */
#ifdef   TURBOC
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <io.h>
#define  CREATE(x) \
   open (x, O_CREAT|O_WRONLY|O_TRUNC|O_BINARY, S_IREAD|S_IWRITE)
#define  OPEN(x)     open (x, O_RDONLY|O_BINARY)
#endif

/* **IX family I/O */
#ifdef   NIX_IO
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#define  CREATE(x) \
   open (x, O_CREAT|O_WRONLY|O_TRUNC, S_IREAD|S_IWRITE)
#define  OPEN(x)     open (x, O_RDONLY)
#endif

/* Atari ST for GNU CC 1.23 ;-) */
#ifdef atarist
#include <file.h>
#define OPEN(x)		open (x, O_RDONLY, 0)
#define CREATE(x)	open (x, O_RDWR | O_CREAT | O_TRUNC, 0)
#endif /* atarist */
