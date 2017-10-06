/*
 * Miscellaneous functions for the Turingol parser
 *
 */

#ifndef _SYMTABS_H
#define _SYMTABS_H

#include <stdio.h>

/* Additional node type */
#define HALT 0

/* Forward-reference types */
typedef int SType;	/* Use the parser's #define's */
typedef struct STNode STNode;
typedef struct SymNode SymNode;

/* Type of a state graph node */
struct STNode {
  SType type;
  int number;
  SymNode *label;       /* if this node has a label */
  SymNode *symbol;	/* for IF / PRINT */
  union {
    STNode *dest;	/* for IF / GOTO */
    int direction;	/* for MOVE */
  } data;
  STNode *next;
};

/* State graph operations */
STNode *st_init();
STNode *st_last();
void    st_labelled(char *label);
STNode *st_GOTO(STNode *dest);
STNode *st_StartIF(SymNode *sym);
STNode *st_EndIF(STNode *this);
STNode *st_MOVE(int direction);
STNode *st_PRINT(SymNode *sym);
void    st_run(FILE *f);

/* Type of a symbol node */
/* This is a bit grotty - it handles 3 types of data:
 *  1. The alphabet - name = symbolic name, state = nothing
 *  2. The labelled instructions - name = label, state = the labelled state
 *  3. The forward-goto's: label = label to match, state = state to patch
*/
struct SymNode {
  char *name;
  STNode *state;
  SymNode *next;
};

/* Symbol table operations */
SymNode *sym_insert(SymNode **list, char *name, STNode *state);
SymNode *sym_lookup(SymNode **list, char *name);
SymNode *sym_traverse(SymNode **list);

/* Symbol tables */
extern SymNode *alphabet;
extern SymNode *labels;
extern SymNode *forwardrefs;

extern SymNode *blank;

/* Graph traversal definitions */

typedef void (*OutputFunction) (FILE *f, STNode *state);

void traverse_graph(FILE *f, OutputFunction out_func);

#endif
