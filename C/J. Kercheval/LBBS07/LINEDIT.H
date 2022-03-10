/* Linedit - line editor header file */

typedef struct _line_ {
	struct _line_ *next, *prev;
	int cr_before, cr_at_end;
	char *text;
} A_line;

/* Prototypes for functions defined in D:\PROJLINN\LAZYREAD\LINEDIT.C */
int yes(void);
void listbuffer(int );
A_line *whichline(int );
int geti(int ,
         int ,
         int );
void deleteline(A_line *);
A_line *insertline(char *,
                   A_line *);
int ifold(char *);
void insertbefore(int );
int menu_loop(void);
int edit_file(char *);
