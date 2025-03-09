/************************************************/
/*            FORMULA.H von 15.10.1990          */
/*        (w) & (c) 1990 by Grischa Ekart       */
/*  erstellt mit Turbo C V1.0 von BORLAND GmbH  */
/************************************************/

/*                  defines                     */

#undef TRUE
#undef FLASE
#undef NULL
#define TRUE 1
#define FALSE 0
#define NULL ((void *)0)

/*                enumerations                  */

enum tokens
{
   EOS, NUMBER, FUNCTION, PLUS, MINUS, STAR,
   SLASH, LPAREN, RPAREN
};

enum err_codes
{
   UNKNOWN_CHAR, UNEXP_CHAR, MIS_LPAR, MIS_RPAR,
   UNKNOWN_FUNC
};

/*                 structures                   */

typedef  struct
{
   char     *name;
   double   (*function)(double);
} FUNC;

typedef  union
{
   double   number;
   int      function;
} YYTYPE;

/*                 prototypes                   */

void  yyinit(char *string);
int   yylex(void);
void  yyback(void);
void  yyerror(int message);
int   parse(char *string);
void  error_msg(int message);

/*             external definitions             */

extern   double value;
extern   int position;

