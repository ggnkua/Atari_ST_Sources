#include <stdio.h>

typedef struct hash {
 char *htext;
 char *mapto;
 int htype;
 struct hash *next;
} Hash;

extern FILE *yyin, *yyout;
extern unsigned long line_num;

extern void mkhash();
extern int lookup();
extern void yyerror();
extern void init_hash(), clear_hash(), init_scanner();
