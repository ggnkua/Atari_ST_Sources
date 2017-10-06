/*
 * Symbol table functions for the Turingol parser
 *
 */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "symtabs.h"
#include "y.tab.h"
#include "tape.h"

/* State number counter */
int state_num = 0;

/* Remember the last node we added */
static STNode *last;
static STNode *graph = NULL;

/* Symbol tables */
SymNode *alphabet = NULL;
SymNode *labels = NULL;
SymNode *forwardrefs = NULL;

/* Keep a pointer to the first symbol inserted; this is the "blank" */
SymNode *blank = NULL;

/* State graph operations */

/* Create a "lookahead" node */
STNode *st_NewNode()
{
  STNode *node = (STNode *)malloc(sizeof(STNode));

  /* indicate uninitialised */
  node->type = HALT;
  node->number = state_num++;
  node->label = NULL;
  node->next = NULL;

  /* Special case the first statement */
  if(graph == NULL)
    graph = node;
  else
    last->next = node;

  last = node;
  return(node);
}

/* Initialise the graph */
STNode *st_init()
{
  return(graph = st_NewNode());
}

/* Get the current node */
STNode *st_last()
{
  return(last);
}

/* A labelled instruction */
void st_labelled(char *label)
{
  last->label = sym_insert(&labels, strdup(label), last);
}

/* Fill out a GOTO node */
STNode *st_GOTO(STNode *dest)
{
  last->type = GOTO;
  last->data.dest = dest;
  return(st_NewNode());
}

/* Fill out an IF node */
/* Two stages - encounter the IF, finish the body */
/* end refers to the node following the body ie goto it if false */
STNode *st_StartIF(SymNode *sym)
{
  STNode *this;

  this = last;
  this->type = IF;
  this->symbol = sym;
  st_NewNode();
  return(this);
}

STNode *st_EndIF(STNode *this)
{
  this->data.dest = last;
  return(last);
}

/* Fill out a MOVE node */
STNode *st_MOVE(int direction)
{
  last->type = MOVE;
  last->data.direction = direction;
  return(st_NewNode());
}

/* Fill out a PRINT node */
STNode *st_PRINT(SymNode *sym)
{
  last->type = PRINT;
  last->symbol = sym;
  return(st_NewNode());
}

/* Traverse state graph */
void traverse_graph(FILE *f, OutputFunction out_func)
{
  STNode *state;

  for(state = graph; state != NULL; state = state->next) {
    out_func(f, state);
  }
}


/* Symbol table operations */

/* Insert an element into a list, WITHOUT copying the key */
SymNode *sym_insert(SymNode **list, char *name, STNode *state)
{
  SymNode *node = (SymNode *)malloc(sizeof(SymNode));

  node->name = name;
  node->state = state;
  node->next = *list;
  *list = node;

  /* The first symbol entered is the "blank" */
  if(blank == NULL)
    blank = node;
  return(node);
}

/* Find a node given a key */
SymNode *sym_lookup(SymNode **list, char *name)
{
  SymNode *node = *list;

  for(; node != NULL && strcmp(node->name, name); node = sym_traverse(&node));
  return(node);
}

/* Traverse a list */
SymNode *sym_traverse(SymNode **list)
{
  return((*list == NULL) ? NULL : (*list)->next);
}


/* Run the machine */
void st_run(FILE *f)
{
  STNode *state = graph;

  tape_new();

  while(state->type != HALT) {
    switch(state->type) {
    case GOTO:
      fprintf(f, "[%d] GOTO %d\n", state->number, state->data.dest->number);
      state = state->data.dest;
      break;
    case IF:
      fprintf(f, "[%d] IF \"%s\" GOTO %d ELSE GOTO %d\n", state->number, state->symbol->name, state->next->number, state->data.dest->number);
      if(tape_read() == state->symbol)
	state = state->next;
      else
	state = state->data.dest;
      break;
    case MOVE:
      {
	char c;

	switch(state->data.direction) {
	case -1 : c = 'L'; tape_left(); break;
	case +1 : c = 'R'; tape_right(); break;
	}

	fprintf(f, "[%d] MOVE `%c`\n", state->number, c);
	state = state->next;
	break;
      }
    case PRINT:
      fprintf(f, "[%d] PRINT \"%s\"\n", state->number, state->symbol->name);
      tape_write(state->symbol);
      state = state->next;
      break;
    default:
      fprintf(f, "[%d] unrecognised node.\n", state->number);
    }

    tape_print(f);
  }
}
