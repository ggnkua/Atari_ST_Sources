/*
 * Tape for the execution of the machine
 *
 */

#include <stdlib.h>
#include "tape.h"

/* Global state (yuk) */
TapeNode *tape;
TapeNode *farleft;

/* Create a new tape */
void tape_new()
{
  tape = malloc(sizeof(TapeNode));

  tape->symbol = blank;
  tape->prev = NULL;
  tape->next = NULL;

  farleft = tape;
}

/* Move the tape left */
void tape_left()
{
  if(tape->prev == NULL) {
    TapeNode *t = malloc(sizeof(TapeNode));

    t->symbol = blank;
    t->prev = NULL;
    t->next = tape;
    tape->prev = t;
    farleft = t;
  }

  tape = tape->prev;
}

/* Move the tape right */
void tape_right()
{
  if(tape->next == NULL) {
    TapeNode *t = malloc(sizeof(TapeNode));

    t->symbol = blank;
    t->prev = tape;
    t->next = NULL;
    tape->next = t;
  }

  tape = tape->next;
}

/* Read the current cell */
SymNode *tape_read()
{
  return(tape->symbol);
}

/* Write the current cell */
void tape_write(SymNode *data)
{
  tape->symbol = data;
}

/* Print the tape contents */
void tape_print(FILE *f)
{
  TapeNode *t;

  for(t = farleft; t != NULL; t = t->next) {
    if(t == tape)
      /* Current cell */
      fprintf(f, " ||%s||", t->symbol->name);
    else
      fprintf(f, " %s", t->symbol->name);
  }
  fprintf(f, "\n");
}
