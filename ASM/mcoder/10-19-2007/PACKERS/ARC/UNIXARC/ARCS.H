/*  ARC - Archive utility - Archive file header format

    Version 2.12, created on 12/17/85 at 14:40:26

(C) COPYRIGHT 1985 by System Enhancement Associates; ALL RIGHTS RESERVED

    By:  Thom Henderson

    Description:
         This file defines the format of an archive file header, excluding
         the archive marker and the header version number.

         Each entry in an archive begins with a one byte archive marker,
         which is set to 26.  The marker is followed by a one byte
         header type code, from zero to 7.

         If the header type code is zero, then it is an end marker, and
         no more data should be read from the archive.

         If the header type code is in the range 2 to 7, then it is
         followed by a standard archive header, which is defined below.

         If the header type code is one, then it is followed by an older
         format archive header.  The older format header does not contain
         the true length.  A header should be read for a length of
         sizeof(struct heads)-sizeof(long).  Then set length equal to size
         and change the header version to 2.

    Programming note:
         The crc value given in the header is based on the unpacked data.

    Language:
         Computer Innovations Optimizing C86
*/

struct heads                           /* archive entry header format */
{   char name[13];                 /* file name */
    long size;                         /* size of file, in bytes */
    unsigned int date;                 /* creation date */
    unsigned int time;                 /* creation time */
    int crc;                           /* cyclic redundancy check */
    long length;                       /* true file length */
}   ;
