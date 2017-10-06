/*
 * Output functions for the Turingol parser
 *
 */

#include <stdlib.h>
#include <stdio.h>
#include "output.h"
#include "y.tab.h"

/* Header */
void tuple_header(FILE *f)
{
  SymNode *sym;

  fprintf(f, "# Tape alphabet\nalphabet = (");

  for(sym = alphabet; sym != NULL; sym = sym_traverse(&sym))
    fprintf(f, "\"%s\"%s", sym->name, (sym->next != NULL) ? ", " : "");

  fprintf(f, ")\n");
}

/* Dump graph in tuple form */
void tuple_out(FILE *f, STNode *state)
{
  SymNode *sym;

  if(state->label != NULL)
    fprintf(f, "# %s:\n", state->label->name);

  switch(state->type) {
  case HALT:
    fprintf(f, "# final statement.\n");
    break;
  case GOTO:
    fprintf(f, "# go to %s;\n", state->data.dest->label->name);
    for(sym = alphabet; sym != NULL; sym = sym_traverse(&sym))
      fprintf(f, "(%d, \"%s\", \"%s\", N, %d)\n", state->number, sym->name, sym->name, state->data.dest->number);
    break;
  case IF:
    fprintf(f, "# if(\"%s\")\n", state->symbol->name);
    for(sym = alphabet; sym != NULL; sym = sym_traverse(&sym))
      if(sym == state->symbol)
	fprintf(f, "(%d, \"%s\", \"%s\", N, %d)\n", state->number, sym->name, sym->name, state->next->number);
      else
	fprintf(f, "(%d, \"%s\", \"%s\", N, %d)\n", state->number, sym->name, sym->name, state->data.dest->number);
    break;
  case MOVE:
    {
      char s;

      switch(state->data.direction) {
      case -1 : s = 'L'; break;
      case +1 : s = 'R'; break;
      }

      fprintf(f, "# move %c\n", s);
      for(sym = alphabet; sym != NULL; sym = sym_traverse(&sym))
	fprintf(f, "(%d, \"%s\", \"%s\", %c, %d)\n", state->number, sym->name, sym->name, s, state->next->number);
    }

    break;
  case PRINT:
    fprintf(f, "# print \"%s\";\n", state->symbol->name);
    for(sym = alphabet; sym != NULL; sym = sym_traverse(&sym))
      fprintf(f, "(%d, \"%s\", \"%s\", N, %d)\n", state->number, sym->name, state->symbol->name, state->next->number);
    break;
  default:
    fprintf(f, "# unrecognised node.\n");
  }
}
