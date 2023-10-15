/*******************************************************
 *
 *  a56 - a DSP56001 assembler
 *
 *  Written by Quinn C. Jensen
 *  July 1990
 *  jensenq@npd.novell.com (or jensenq@qcj.icon.com)
 *
 *******************************************************\

/*
 *  lex.c - lexical analyzer envelope.  lexyy.c, included below,
 *  is the LEX-generated code.
 *
 */

#include "a56.h"
#include "gram.h"

extern YYSTYPE yyval;

int ldebug;

#define LDEBUG
#ifdef LDEBUG
#define RET(val) \
	if(ldebug) {\
	       	printf("%s ", tok_print(val));\
		fflush(stdout);\
	}\
	return(val)
#else
#define RET(val) return(val)
#endif

double atof();

#include "lexyy.c"



