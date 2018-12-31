/*
	file: bufman.h
	utility: header file of bufman.c
	date: 
	author: 
	modifications:
	comments: 
*/

#ifndef BUFMAN_H
#define BUFMAN_H

/*
	includes
*/
#include "wind.h"	/* defs for windowptr */

/*
	globals variables
*/
extern	char	*cutbuffer;
extern	long	cutlength;		/* markbuf end pointer			*/

/*
	globals functions
*/
extern linkbufptr addmember(windowptr thewin);
extern int insert_member(linkbufptr	bufptr);
extern void dispose_buf(windowptr 	thewin);
extern void dispose_member(windowptr thewin, linkbufptr memtodel);

#endif