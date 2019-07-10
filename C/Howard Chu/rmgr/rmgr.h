/* Copyright (c) 1987,1988 Oliver Laumann, Technical University of Berlin.
 * Not derived from licensed software.
 *
 * Permission is granted to freely use, copy, modify, and redistribute
 * this software, provided that no attempt is made to gain profit from it,
 * the author is not construed to be liable for any results of using the
 * software, alterations are clearly marked as such, and this notice is
 * not modified.
 */

#include <mgr/term.h>

#define MAXSTR       128
#define	MAXARGS      64

#define IOSIZE       256
#define	SCRBUFSIZE	2048	/* About 1 screenful of characters */

struct win {
    int wpid;
    int ptyfd;
    int rows;
    int cols;
    char cmd[MAXSTR];
    char tty[MAXSTR];
    int slot;
    int win_ok;
    int outful;
    char outbuf[SCRBUFSIZE];
    char *outptr;
};

#define MY_MAXLINE 1024

#define MSG_CREATE    0
#define MSG_ERROR     1
#define MSG_ATTACH    2
#define MSG_CONT      3

struct msg {
    int type;
    union {
	struct {
	    int nargs;
	    char line[MY_MAXLINE];
	    char dir[1024];
	    char name[MAXSTR];
	} create;
	struct {
	    int apid;
	    char tty[1024];
	} attach;
	char message[MY_MAXLINE];
    } m;
};
