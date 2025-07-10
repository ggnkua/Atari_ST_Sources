/******************************************************************************/
/* Datei: formel.h/ Headerdatei fuer den Formelinterpreter formel.c           */
/* Autor: Klaus Schlaeger                                                     */
/* Datum: 25.09.1990                                                          */
/******************************************************************************/

#include <math.h>
#include <stdio.h>
#include <ctype.h>
#include <string.h>

#define TRUE    1
#define FALSE   0

#define FLEN  256               /* max. Formellaenge                          */
#define TLEN  256               /* max. Tokenlaenge                           */
#define CLEN   80               /* Calculator Stack                           */
#define NLEN   80               /* Number Stack                               */
#define SLEN   20               /* max. Symbollaenge                          */

typedef struct
{
  char *kword;
  char *symbol;
} keyword;

keyword kw[]={                  /* Schluesselwoerter und zugehoerige Sybmole  */
               {"cos", "cos"},
               {"sin", "sin"},
               {"tan", "tan"},
               {"acos", "acos"},
               {"asin", "asin"},
               {"atan", "atan"},
               {"sqrt", "sqrt"},
               {"log", "log"},
               {"exp", "exp"},
               {"x", "ident1"},
               {"y", "ident2"},
               {"pi", "number"},
               {"e", "number"},
             };

enum {IDENT1=1, IDENT2,
      PLUS=200, MINUS, TIMES, DIV, MOD, NEG, POW,
      LOG, EXP, SQRT, SIN, COS, TAN, ASIN, ACOS, ATAN,
     };


/************************** Funktionsdeklarationen ****************************/
double fpc(char *, double, double); /* Fasst fpars() und fcalc() zusammen     */
int    fpars(char *);               /* Formel in Token uebersetzen            */
double fcalc(double, double);       /* Berechnet die zuletzt uebersetzte Form.*/
void   expression(void);
void   simplexpr(void);
void   term(void);
void   factor(void);
void   getsym(void);                /* Liefert das naechste Symbol            */
int    strsearch(char *, char *);   /* Testet, ob Teilstring in String        */
int    tstsym(char *, char *);      /* Testet, ob Symbol in Symbolmege        */
char   *spacekill(char *);          /* Spaces entfernen und in Kleinbuchst.   */

