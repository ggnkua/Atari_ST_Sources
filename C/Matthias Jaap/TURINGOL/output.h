/*
 * Output functions for the Turingol parser
 *
 */

#ifndef _OUTPUT_H
#define _OUTPUT_H

#include "symtabs.h"

void tuple_header(FILE *f);
void tuple_out(FILE *f, STNode *state);

#endif
