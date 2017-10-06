/*
 * Tape for the execution of the machine
 *
 */

#ifndef _TAPE_H
#define _TAPE_H

#include "symtabs.h"
#include <stdio.h>

/* Use a doubly-linked list for the tape */
typedef struct TapeNode TapeNode;

struct TapeNode {
  SymNode *symbol;
  TapeNode *prev;
  TapeNode *next;
};

/* Tape functions */
void tape_new();
void tape_left();
void tape_right();
SymNode *tape_read();
void tape_write(SymNode *data);
void tape_print(FILE *f);

#endif
