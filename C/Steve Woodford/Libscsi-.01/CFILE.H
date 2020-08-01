/*
 * cfile.h - Copyright Steve Woodford, August 1993.
 *
 * Interface to 'cfile' library.
 */

#ifndef __cfile_h
#define __cfile_h

#define CFILE_OPEN      1
#define CFILE_CLOSE     2
#define CFILE_SEARCH    3

#ifndef __cfile_c
extern  long    config_file(int, ...);
#endif

#endif  /* __cfile_h */
