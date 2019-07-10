/*
 * dirlist.h
 */

#ifndef _DIRLIST_H
#define _DIRLIST_H

struct date_t {			/* subset of struct tm, packed into a short */
    unsigned short mday   : 5;	/* 1..31			*/
    unsigned short mon    : 4;	/* 0..11			*/
    unsigned short year   : 7;	/* 80..127 (years since 1900)	*/
} ;

struct dirList {		/* For listing files on disk.		*/
    long fd_size;		/* file size.				*/
    struct date_t fd_date;	/* date created/modified.		*/
    char fd_name[14];		/* file name.				*/
};

#endif
