/*      ERRNO.H

        Library error code definitions

        Copyright (c) Borland International 1990
        All Rights Reserved.
*/


#if !defined(__ERRNO)
#define __ERRNO


extern int errno;

#define EPERM   1       /* file permission denied     */
#define ENOENT  2       /* file not found             */
#define EIO     5       /* general i/o error          */
#define EBADF   9       /* invalid file handle        */
#define EILLSPE 10      /* illegal file specification */
#define EINVMEM 11      /* invalid heap block         */
#define ENOMEM  12      /* heap overflow              */
#define EACCES  13      /* file access mode error     */
#define EEXIST  17      /* file already exists        */
#define EPLFMT  18      /* program load format error  */
#define ENODEV  19      /* device error               */
#define ENOTDIR 20      /* path not found             */
#define EINVAL  22      /* invalid parameter          */
#define ENFILE  23      /* file table overflow        */
#define EMFILE  24      /* too many open files        */
#define ENOSPC  28      /* disk full                  */
#define ESPIPE  29      /* seek error                 */
#define EROFS   30      /* read only device           */
#define EDOM    33      /* domain error               */
#define ERANGE  34      /* range error                */
#define ENMFILE 35      /* no more matching file      */

#define sys_nerr 35

#endif

/************************************************************************/
