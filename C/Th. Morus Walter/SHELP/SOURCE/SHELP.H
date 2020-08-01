/*
	shelp.h
	headerdatei fÅr PureC 1.0
	written by Th. Morus Walter

	v0.9		 5. 1.1995
*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <tos.h>

typedef enum {
	ERR_INTERNAL,
	ERR_FILE,
	ERR_MEMORY,
	ERR_OPTIONS,
	ERR_BUFFER,
	ERR_NAMES,
	ERR_NOFILES,
} ERR_NUMS;

typedef enum {
	FUNCTION=0,
	TYPEDEF,
	DEFINE,
} NAME_TYP;

typedef enum {
	C_EMPTY,
	C_COMM,
	C_TEXT,
} COPY_MODE;

typedef struct {
	char *start;				/* anfang des puffers */
	char *textstart;			/* anfang des textes (falls vorher kommentar) */
	char *name;					/* anfang des namens (NICHT terminiert) */
	NAME_TYP typ;
	int  start_line;
	int  text_line;
	COPY_MODE copy_mode;		/* nur fÅr parser */
	char *write;
	long len;
} TEXT_PUFFER;


/*
	globale funktionen in parse.c
*/
void do_parse(FILE *stream);
extern TEXT_PUFFER puffer;

/*
	globale funktionen in shelp.h
*/
extern long buf_size;

void write_item(TEXT_PUFFER *puffer);
void do_error(ERR_NUMS error);
