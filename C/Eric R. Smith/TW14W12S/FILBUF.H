/*
 * Copyright 1992 Eric R. Smith. All rights reserved.
 * Redistribution is permitted only if the distribution
 * is not for profit, and only if all documentation
 * (including, in particular, the file "copying")
 * is included in the distribution in unmodified form.
 * THIS PROGRAM COMES WITH ABSOLUTELY NO WARRANTY, NOT
 * EVEN THE IMPLIED WARRANTIES OF MERCHANTIBILITY OR
 * FITNESS FOR A PARTICULAR PURPOSE. USE AT YOUR OWN
 * RISK.
 */
#define FILBUFSIZ	1024

typedef struct filbuf {
	int	fd;
	int	nbytes;
	unsigned char *ptr;
	unsigned char buf[FILBUFSIZ];
} FILBUF;

FILBUF *FBopen		__PROTO(( char * ));
void	FBclose		__PROTO(( FILBUF * ));
int	FBgetchar	__PROTO(( FILBUF * ));
char   *FBgets		__PROTO(( FILBUF *, char *, int));
