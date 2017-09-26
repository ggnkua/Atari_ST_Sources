/*****************************************************************************
*
*		    C P / M   C   H E A D E R   F I L E
*		    -----------------------------------
*	Copyright 1982,83 by Digital Research Inc.  All rights reserved.
*
*	This is the standard include file for the CP/M C Run Time Library.
*
*****************************************************************************/
/****************************************************************************
*	Stream I/O File Definitions
*****************************************************************************/
#define BUFSIZ	512			/*	Standard (ascii) buf size   */
struct _iobuf {				/*				    */
	short _fd;			/* file descriptor for low level io */
	short _flag;			/* stream info flags		    */
	char *_base;			/* base of buffer		    */
	char *_ptr;			/* current r/w pointer		    */
	short _cnt;			/* # chars to be read/have been wrt */
};					/*				    */
extern struct _iobuf _iob[];		/* an array of this info	    */
#define FILE struct _iobuf		/* stream definition		    */
#define NULLFILE ((FILE *)0)		/* Null return values		    */
					/* flag byte definition		    */
#define _IOREAD	0x01			/* readable file		    */
#define _IOWRT	0x02			/* writeable file		    */
#define _IOABUF	0x04			/* alloc'd buffer		    */
#define _IONBUF	0x08			/* no buffer			    */
#define _IOERR	0x10			/* error has occurred		    */
#define _IOEOF	0x20			/* EOF has occurred		    */
#define _IOLBUF 0x40			/* handle as line buffer	    */
#define _IOSTRI	0x80			/* this stream is really a string   */
#define _IOASCI	0x100			/* this was opened as an ascii file */
					/************************************/
#define stdin  (&_iob[0])		/* standard input stream	    */
#define stdout (&_iob[1])		/*    "     output  "		    */
#define stderr (&_iob[2])		/*    "     error   "		    */
					/************************************/
#define NULL	0
#define EOF	-1
