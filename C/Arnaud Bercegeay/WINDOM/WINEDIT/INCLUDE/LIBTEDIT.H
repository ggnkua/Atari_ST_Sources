/*
 *	Routines d'‚dition de texte
 *  D.B‚r‚ziat 1998/1999/200
 *	D‚finition g‚n‚rales
 *
 *	version 1.02	bug fix‚ dans line_rem()
 *	version 1.01	bug fix‚ dans la r‚allocation des lignes
 *	version 1.00	premiŠre version fonctionnelle
 */

#ifndef pos_t
typedef size_t pos_t;
#endif

#define MAXBUF			256
#define SIZE_REALLOC	128
#define NEWLINE			'\n'
#define ENDLINE			'\0'
#define TABULATOR		'\t'

/* type */
#define T_AUTO 		-1
#define T_DOS		0
#define T_NULL		1
#define T_BIN		2
#define T_UNIX		3
#define T_MAC		4
#define T_USER		5

/* typedef unsigned int uint; */

typedef struct edline {
	char *buf;			/* adresse buffer ligne */
	int len;			/* longueur de la ligne */
	int size;			/* taille en octet de la ligne, octet en surplus y compris */
	struct edline *prev, *next;
} EDLINE;

typedef struct cursor {
	EDLINE *line;		/* ligne */
	int		row;		/* colonne */
	int		index;		/* index de la ligne */
} CURSOR;

typedef struct edit {
	EDLINE *top;		/* premiere ligne */
	EDLINE *bot;		/* derniere ligne */
	CURSOR  cur;		/* position curseur */
	int		maxcur;		/* col max curseur */
	pos_t 	maxline;	/* nombre de lignes */
	int		type;		/* Type du buffer */
	char    name[255];	/* Nom du buffer */
	void   *gr;			/* Interface utilisateur  */
} EDIT;

/* mode de line_add */
#define ED_TOP	1
#define ED_BOT	2
#define ED_CUR	3

/* qqs macros */
#define IS_TOP( edit) ((!(edit)->cur.row && !(edit)->cur.line->prev)?1:0)
#define IS_BOT( edit) (((edit)->cur.line->buf[(edit)->cur.row] == ENDLINE \
						&& !edit->cur.line->next)?1:0)
#define IS_UP( edit) (((edit)->cur.line->prev)?0:1)
#define IS_DN( edit) (((edit)->cur.line->next)?0:1)

#define GET_CHAR( edit)	((edit)->cur.line->buf[(edit)->cur.row])
#define GET_ROW( edit)	((edit)->cur.row)

#ifndef NOPROTO

int  	curs_left	( EDIT *edit);
int  	curs_right	( EDIT *edit);
int  	curs_up		( EDIT *edit);
int  	curs_down	( EDIT *edit);
int  	char_del	( EDIT *edit);
void 	char_put	( EDIT *edit, int c);
void 	string_put	( EDIT *edit, char *str);
EDIT *	edit_new	( void);
void 	edit_free	( EDIT *edit);
int 	edit_load	( EDIT *edit, char *file, void (*)(EDIT*,int));
int 	edit_save	( EDIT *edit, char *file, int type, char *end, void (*)(EDIT*,int));
EDLINE *line_new	( char *buf);
void 	line_add	( EDIT *edit, EDLINE *line, int mode);
void 	line_rem	( EDIT *edit);

char *	tab2spc		( int tab, char *dest, char *src, int );
size_t 	edit_size	( EDIT *edit);
int 	diff_line	( EDLINE *up, EDLINE *dn);

#endif
