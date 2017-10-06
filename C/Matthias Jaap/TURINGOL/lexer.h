/*
 * Export some of (f)lex's internal variables for the parser
 */

#ifndef _LEXER_H
#define _LEXER_H

extern FILE *yyin;
extern int line_num;

int yylex();

#endif
