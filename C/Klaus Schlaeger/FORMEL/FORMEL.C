/******************************************************************************/
/* Datei: formel.c                                                            */
/* Autor: Klaus Schlaeger                                                     */
/* Datum: 25.09.1990                                                          */
/* Dieses Modul stellt einen rekursiven Formelinterpreter zur Verfuegung.     */
/*----------------------------------------------------------------------------*/
/* Beschreibung der Syntax einer Formel in EBNF:                              */
/* expression = ["+"|"-"] simplexpr {("+"|"-") simplexpr}.                    */
/* simplexpr  = term {("*"|"/"|"%") term}.                                    */
/* term       = factor {"^" factor}.                                          */
/* factor     = x|y|number|[opr] "(" expression ")".                          */
/* opr        = "sqrt"|"log"|"exp"|sin"|"cos"|"tan"|"asin"|"acos"|"atan".     */
/******************************************************************************/
#include "formel.h"

/************************* modullokale Variablen ******************************/
static double         nstk[NLEN];
static unsigned char  token[TLEN];
static int            nindx, tindx, pos;
static char           formel[FLEN], sym[SLEN];


/******************************************************************************/
/* Funktion: fpc()                                                            */
/* Aufgabe : Fasst die Funktionen fpars() und fcalc() zusammen.               */
/******************************************************************************/
double fpc(fo, x, y)
char   *fo;
double x, y;
{
  if(fpars(fo)) return(fcalc(x, y)); else return(HUGE_VAL);
}


/******************************************************************************/
/* Funktion: fpars()                                                          */
/* Aufgabe : Uebersetzt eine Formel in ein sequentiell abzuarbeitenden Token. */
/******************************************************************************/
int fpars(fo)
char *fo;
{
  if(strlen(fo) >= FLEN) return(FALSE);
  nindx=3; tindx=0, pos=0;
  strcpy(formel, fo);
  spacekill(formel);

  getsym();
  expression();
  token[tindx]='\0';
  if(!strcmp("eof", sym)) return(TRUE); else return(FALSE);
}


/******************************************************************************/
/* Funktion: fcalc()                                                          */
/* Aufgabe : Berechnet das Ergebnis der uebersetzten Formel.                  */
/******************************************************************************/
double fcalc(x, y)
double x, y;
{
  int    cindx;
  double cstk[CLEN];

  nstk[1]=x; nstk[2]=y;
  for(tindx=0, cindx=-1; token[tindx]!='\0'; tindx++)
    switch(token[tindx])
    {
      case PLUS : cindx--;
                  cstk[cindx]=cstk[cindx]+cstk[cindx+1];
                  break;
      case MINUS: cindx--;
                  cstk[cindx]=cstk[cindx]-cstk[cindx+1];
                  break;
      case TIMES: cindx--;
                  cstk[cindx]=cstk[cindx]*cstk[cindx+1];
                  break;
      case DIV  : cindx--;
                  cstk[cindx]=cstk[cindx]/cstk[cindx+1];
                  break;
      case MOD  : cindx--;
                  cstk[cindx]=(int)cstk[cindx]%(int)cstk[cindx+1];
                  break;
      case POW  : cindx--;
                  cstk[cindx]=pow(cstk[cindx], cstk[cindx+1]);
                  break;
      case NEG  : cstk[cindx]=(double)-cstk[cindx];
                  break;
      case SQRT : cstk[cindx]=sqrt(cstk[cindx]);
                  break;
      case LOG  : cstk[cindx]=log(cstk[cindx]);
                  break;
      case EXP  : cstk[cindx]=exp(cstk[cindx]);
                  break;
      case SIN  : cstk[cindx]=sin(cstk[cindx]);
                  break;
      case COS  : cstk[cindx]=cos(cstk[cindx]);
                  break;
      case TAN  : cstk[cindx]=tan(cstk[cindx]);
                  break;
      case ASIN : cstk[cindx]=asin(cstk[cindx]);
                  break;
      case ACOS : cstk[cindx]=acos(cstk[cindx]);
                  break;
      case ATAN : cstk[cindx]=atan(cstk[cindx]);
                  break;
      default   : cstk[++cindx]=nstk[token[tindx]];
    }
  return(cstk[cindx]);
}


/******************************************************************************/
/* Funktion: expression()                                                     */
/******************************************************************************/
void expression()
{
  char addop[SLEN];

  if(tstsym("|plus|minus|", sym))
  {
    strcpy(addop, sym);
    getsym();
    simplexpr();
    if(!strcmp("minus", addop)) token[tindx++]=NEG;
  } else simplexpr();

  while(tstsym("|plus|minus|", sym))
  {
    strcpy(addop, sym);
    getsym();
    simplexpr();
    if(!strcmp("plus", addop)) token[tindx++]=PLUS; else token[tindx++]=MINUS;
  }
}


/******************************************************************************/
/* Funktion: simplexpr()                                                      */
/******************************************************************************/
void simplexpr()
{
  char mulop[SLEN];

  term();
  while(tstsym("|times|div|mod|", sym))
  {
    strcpy(mulop, sym);
    getsym();
    term();
    if(!strcmp("times", mulop)) token[tindx++]=TIMES;
    else if(!strcmp("div", mulop)) token[tindx++]=DIV;
    else token[tindx++]=MOD;
  }
}


/******************************************************************************/
/* Funktion: term()                                                           */
/******************************************************************************/
void term()
{
  factor();
  while(!strcmp("pow", sym))
  {
    getsym();
    factor();
    token[tindx++]=POW;
  }
}


/******************************************************************************/
/* Funktion: factor()                                                         */
/******************************************************************************/
void factor()
{
  char funcop[SLEN];

  if(tstsym("|ident1|ident2|", sym))
  {
    if(!strcmp("ident1", sym)) token[tindx++]=IDENT1;
    else token[tindx++]=IDENT2;
    getsym();
  }
  else if(!strcmp("number", sym))
  {
    token[tindx++]=nindx-1;
    getsym();
  }
  else
  {
    if(tstsym("|sqrt|log|exp|sin|cos|tan|asin|acos|atan|", sym))
    {
      strcpy(funcop, sym);
      getsym();
    } else strcpy(funcop, "");

    if(!strcmp("lparen", sym))
    {
      getsym();
      expression();
      if(!strcmp("rparen", sym))
      {
        if(strcmp(funcop, ""))
        {
          if(!strcmp("sqrt", funcop)) token[tindx++]=SQRT;
          else if(!strcmp("log", funcop)) token[tindx++]=LOG;
          else if(!strcmp("exp", funcop)) token[tindx++]=EXP;
          else if(!strcmp("asin", funcop)) token[tindx++]=ASIN;
          else if(!strcmp("acos", funcop)) token[tindx++]=ACOS;
          else if(!strcmp("atan", funcop)) token[tindx++]=ATAN;
          else if(!strcmp("sin", funcop)) token[tindx++]=SIN;
          else if(!strcmp("cos", funcop)) token[tindx++]=COS;
          else token[tindx++]=TAN;
        }
        getsym();
      } else strcpy(sym, "error1");
    } else strcpy(sym, "error2");
  }
}


/******************************************************************************/
/* Funktion: getsym()                                                         */
/* Aufgabe : Liefert jeweils das naechste Symbol aus dem Formelstring formel[]*/
/*           in der Variablen sym.                                            */
/******************************************************************************/
void getsym()
{
  int         i=0;
  double      num;
  char        buffer[SLEN];

  switch(formel[pos])
  {
    case '#' : strcpy(sym, "eof");
               break;
    case '(' : strcpy(sym, "lparen");
               pos++; break;
    case ')' : strcpy(sym, "rparen");
               pos++; break;
    case '+' : strcpy(sym, "plus");
               pos++; break;
    case '-' : strcpy(sym, "minus");
               pos++; break;
    case '*' : strcpy(sym, "times");
               pos++; break;
    case '/' : strcpy(sym, "div");
               pos++; break;
    case '%' : strcpy(sym, "mod");
               pos++; break;
    case '^' : strcpy(sym, "pow");
               pos++; break;
    default  : if(isdigit(formel[pos]))
               {
                 if(sscanf(&(formel[pos]), "%lf%s", &num, formel) == 1)
                   formel[0]='\0';
                 strcpy(sym, "number");
                 pos=0;
               }
               else
               if(isalpha(formel[pos]))
               {
                 while(isalpha(formel[pos])) buffer[i++]=formel[pos++];
                 buffer[i]='\0';
                 for(i=0; i<sizeof(kw)/sizeof(keyword); i++)
                 {
                   if(!strcmp(kw[i].kword, buffer))
                   {
                     strcpy(sym, kw[i].symbol);
                     break;
                   }
                 }
                 if(!strcmp(buffer, "e")) num=M_E;
                 if(!strcmp(buffer, "pi")) num=M_PI;
                 if(i >= sizeof(kw)/sizeof(keyword)) strcpy(sym, "null");
               } else strcpy(sym, "null");
  }
  if(!strcmp("number", sym)) nstk[nindx++]=num;
} 


/******************************************************************************/
/* Funktion: strsearch()                                                      */
/* Aufgabe : Sucht einen Teilstring b in dem String a und liefert dessen      */
/*           Index oder -1 zurueck.                                           */
/******************************************************************************/
int strsearch(a, b)
char *a, *b;
{
  int  i, j, blen;

  blen=strlen(b);
  for(i=0; i <= strlen(a)-blen; i++)
  {
    for(j=0; (a[i+j] == b[j]) && (j < blen); j++);
    if(j >= blen) return(i);
  }
  return(-1);
}


/******************************************************************************/
/* Funktion: tstsym()                                                         */
/* Aufgabe : Testet, ob ein Symbol sym in einer Symbolmenge symset enthalten  */
/*           ist.                                                             */
/******************************************************************************/
int tstsym(symset, sym)
char *symset, *sym;
{
  char s[SLEN];

  strcpy(s, "|");
  strcat(s, sym);
  strcat(s, "|");
  if(strsearch(symset, s) >= 0) return(TRUE); else return(FALSE);
}  


/******************************************************************************/
/* Funktion: spacekill()                                                      */
/* Aufgabe : Entfernt in dem String a alle Leerzeichen und wandelt            */
/*           Grossbuchstaben in Kleinbuchstaben um.                           */
/******************************************************************************/
char *spacekill(a)
char *a;
{
  int  i=0, j=0;

  while(a[j] != '\0')
  {
    if(isalpha(a[j])) a[i++]=tolower(a[j++]);
    else if(a[j] == ' ') j++;
    else a[i++]=a[j++];
  }
  a[i++]='#';
  a[i]='\0';
  return((char *)a);
}
