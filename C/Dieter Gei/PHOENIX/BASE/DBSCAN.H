/*****************************************************************************
 *
 * Module : DBSCAN.H
 * Author : Purex & Jürgen Geiß
 *
 * Creation date    : 01.04.91
 * Last modification: 18.11.92
 *
 *
 * Description: This module defines the database scan routines.
 *
 * History:
 * 18.11.92: Packing pragma added
 * 25.10.92: Module header added
 * 01.04.89: Creation of body
 *****************************************************************************/

#ifndef _DBSCAN_H
#define _DBSCAN_H

#ifdef __cplusplus
extern "C" {
#endif

typedef	enum
{
	TK_EOI,				/*	end of input					*/
	TK_CONST,			/*	numeric constants				*/
	TK_STRING,			/*	string literals					*/
	TK_PLUS,			/*	"+"								*/
	TK_MINUS,			/*	"-"								*/
	TK_TIMES,			/*	"*"								*/
	TK_SLASH,			/*	"/"								*/
	TK_EQ,				/*	"=="							*/
	TK_NE,				/*	"!=" or "<>"					*/
	TK_GT,				/*	">"								*/
	TK_LT,				/*	"<"								*/
	TK_GE,				/*	">="							*/
	TK_LE,				/*	"<="							*/
	TK_AND,				/*	"&"								*/
	TK_OR,				/*	"|"								*/
	TK_NOT,				/*	"~" or "!"						*/
	TK_COLON,			/*	":"								*/
	TK_LPAREN,			/*	"("								*/
	TK_RPAREN,			/*	")"								*/
	TK_SEMIC,			/*	";"								*/
	TK_COMMA,			/*	","								*/
	TK_BECOMES,			/*	"="								*/
	TK_IDENTIFIER,		/*	a name							*/

	TK_IF,				/*	"if"							*/
	TK_THEN,			/*	"then"							*/
	TK_ELSE,			/*	"else" 							*/
	TK_END,				/*	"end" 							*/
	TK_WHILE,			/*	"while"							*/
	TK_DO,				/*	"do" 							*/
	TK_REPEAT,			/*	"repeat" 						*/
	TK_UNTIL,			/*	"until" 						*/
	TK_VAR,				/*	"var"							*/
	TK_EXIT,			/*  "exit"							*/
	TK_OTHER,			/*	something else					*/

}	TOK;


#define	MAXSTR	255

#if MSDOS | NT
#pragma pack(1)
#endif

typedef	struct
{
	SHORT	tok;
	SHORT	line;
	SHORT	col;
	CHAR	str[MAXSTR+1];
}	TOKEN;

#if MSDOS | NT
#pragma pack()
#endif

GLOBAL	TOKEN	token;
GLOBAL	VOID	StartScan	_((CHAR *text));
GLOBAL	TOK		Scan		_((VOID));
GLOBAL	VOID	ScanNum		_((VOID));

#ifdef __cplusplus
}
#endif

#endif /* _DBSCAN_H */

