/**************************************************************************
* Source-File: POL_RECH.C
*--------------------------------------------------------------------------
* Autor      : F.ROHFLEISCH, 7140 LUDWIGSBURG
*--------------------------------------------------------------------------
* Funktionen : double     pol_rech (char *, double x1, double x2, int *);
*              int        next_op (char **, char *);
*              double     get_stack (int *);
*              int        put_stack (int *, double);
*--------------------------------------------------------------------------
* SRC-Version: 1.0
* Betriebsys.: TOS
* Compiler   : TURBO C 1.1
*--------------------------------------------------------------------------
* Beschreib. : Das Modul berechnet den Wert einer in polnischer 
*              Notation uebergebenen Formel.
*              Dabei koennen auch 2 Variable uebergeben werden, die
*              in der Formel fuer 'X' bzw. 'Y' verwendet werden.
*              Die uebergebene Formel darf nur Grossbuchstaben enthalten. 
* History    : 10.10.1989
***************************************************************************/


#include   <math.h>
#include   <ctype.h>
#include   <string.h>
 
#include   <pol_rech.h>

/*
****************************************************************************
                      Funktionsprototypen
****************************************************************************
*/

double          pol_rech (char *, double x1, double x2, int *);
int             next_op (char **, char *);
double          get_stack (int *);
int             put_stack (int *, double);

/*
****************************************************************************
*                               globale Variable
****************************************************************************
*/

int        stack_nr;              /* zaehlt die auf Stack abgelegten, 
                                     bzw. aufgelegten Elemente.       */
double     stack[STACK_MAX];      /* Stack                            */



/*
***************************************************************************
* Aufruf      : pol_rech (char *formel, double x, double y, int fehler)
* Eingabe     : char *formel; Formel in polnischer Notation.
*               double x1,x2;   Variable.
* Ausgabe     : int fehler;   Fehlercode (definiert in pol_rech.h).
* Return      : double y;     Formel-Ergebnis.
* Beschreibung: s.o. 
* History     : 10.10.1989
***************************************************************************
*/
double pol_rech(formel,x1,x2,fehler)
char *formel;
double x1;
double x2;
int *fehler;
   {
   char operator[25];
   double op1, op2, temp;
   int code;
   register int i;

   stack_nr = 0;
   *fehler = 0;
   while((code = next_op(&formel, operator)) != ENDE)
      {
      if (*fehler > 0)
         {
         return (0);
         }
      switch (code)
         {
         case NUMBER:
               put_stack(fehler,atof(operator));
               break;
         case '+': 
               put_stack (fehler,get_stack(fehler) + get_stack(fehler));
               break;
         case '-': 
               op2 = get_stack(fehler);
               put_stack (fehler,get_stack(fehler) - op2);
               break;
         case '*': 
               put_stack (fehler,get_stack(fehler) * get_stack(fehler));
               break;
         case '/': 
               op2 = get_stack(fehler);
               if (op2 != 0)
                  {
                  put_stack (fehler,get_stack(fehler) / op2);
                  }
               else
                  {
                  *fehler = NULL_DIVISION;
                  }
               break;
         case ('^'): /* Exponent */
               op2 = get_stack(fehler);
               op1 = get_stack(fehler);
               if (op1 > 0 && *fehler == 0)
                  {
                  put_stack(fehler,exp(op2 * log(op1)));
                  }
               else if (op1 == 0 && *fehler == 0)
                  {
                  if (op2 == 0)
                     {
                     put_stack(fehler,1);
                     }
                  else
                     {
                     put_stack(fehler,0);
                     }
                  }
               else
                  {
                  put_stack(fehler,0);
                  *fehler = NEG_BASIS;
                  }
               break;
         case NEG_PI:     
               put_stack(fehler,NPI);
               break;
         case VARIABLE:
               switch (operator[0])
                  {     
                  case 'X':                    /* Variable x */
                        put_stack(fehler,x1);
                        break;
                  case 'Y':                    /* Variable y */
                        put_stack(fehler,x2);
                        break;
                  case '-':                    /* negative Variable */
                        if (operator[1] == 'X')
                           {
                           put_stack(fehler, x1* (-1));
                           }
                        else
                           {
                           put_stack(fehler, x2 * (-1));
                           }
                        break;
                  default:
                        *fehler = UNBEKANNTE_VARIABLE;
                        break;
                  }
               break;
         case FUNKTION:
               for (code = 0, i = 0; operator[i] != ENDE; i++)
                  {
                  code += operator[i];
                  }
               switch (code)
                  {
                  case SIN:                 
                        put_stack(fehler,sin(get_stack(fehler)));
                        break;
                  case COS:              
                        put_stack(fehler,cos(get_stack(fehler)));
                        break;
                  case TAN:                 
                        op1 = get_stack(fehler);
                        temp = (op1 - PI2) / PI;
                        (temp > 0) ? (temp -= (int)(temp+0.5)) :
                                     (temp -= (int)(temp-0.5)) ;
                        if (fabs(temp) > 1E-08)
                           {
                           put_stack(fehler, tan(op1));
                           }
                        else if (temp > 0)
                           {
                           *fehler = NEG_UNENDLICH;
                           put_stack(fehler,(-1E+4932));
                           }
                        else 
                           {
                           *fehler = POS_UNENDLICH;
                           put_stack(fehler,1E+4932);
                           }
                        break;
                  case SQRT:                 
                        op1 = get_stack(fehler);
                        if (op1 >= 0.0 && *fehler == 0)
                           {
                           put_stack(fehler,(sqrt(op1)));
                           }
                        else
                           {
                           *fehler = NEG_WURZEL;
                           }
                        break;
                  case EXP:                  
                        {
                        put_stack(fehler,exp(get_stack(fehler)));
                        break;
                        }
                  case LN:                 
                        {
                        op1 = get_stack(fehler);
                        if (op1 > 0)
                           {
                           put_stack(fehler, log(op1));
                           }
                        else
                           {
                           put_stack(fehler,0);
                           *fehler = NEG_LOG;
                           }
                        break;
                        }     
                  case ABS:                 
                        {
                        put_stack(fehler,fabs(get_stack(fehler)));
                        break;
                        } 
                  case PI:                 
                        put_stack(fehler,PI1);
                        break; 
                  default:
                        *fehler = UNBEKANNTE_FUNKTION;
                        break;
                  }
               break;
         default:
               *fehler = UNBEKANNTER_OPERATOR;
               break;
         }
      }
   if (*fehler == 0)
      {
      if (stack_nr != 1)
         {
         *fehler = NOTAT_FEHLER;
         return (0);
         }
      else
         {
         return (stack[0]);
         }
      }
   else
      {
      return (0);
      }
   }

/*
***************************************************************************
* Aufruf      : next_op(char **, char *)
* Eingabe     : char **formel;  Zeiger auf aktuelle Position in Formel.
*               char *operator; String mit ggf. nummerischen Ausdruck.
* Return      : int; ENDE falls String-Ende,
*               NUMBER falls nummerischer Ausdruck,
*               FUNKTION falls Funktion,
*               sonst eingelesenes Zeichen.
* Beschreibung: Die Funktion sucht in einem Formelstring den naechsten
*               Operator, und gibt ihn in der Variablen 'operator' zurueck,
*               wenn es eine Zahl oder Funktion ist, bzw. liefert Rechen-
*               anweisungen als Returnwert zurueck. 
* History     : 10.10.1989
***************************************************************************
*/
next_op (formel, operator)
char **formel;  
char *operator; 
   {
   int c;

   /* Tabulatoren, Line Feeds und Blanks ueberlesen */
   while ((c = *((*formel)++)) == '\t' || c == ' ' || c == '\n')
      {  
      ; 
      }
   if (c == '\0') /* Stringende erreicht */
      {
      return(ENDE); /* Endemerker zurueckgeben */
      }
   /* Zeichen ist kein '.', kein '-' und keine Zahl */
   if (c != '-' && c != '.' && (c < '0' || c >'9'))
      {
      if (isupper(c) == 0) /* Zeichen ist kein Grossbuchstabe */
         {
         return(c); /* Rechenoperator zurueckgeben */
         }
      else
         {
         *(operator++) = c; /* Zeichen sichern */
         /* naechstes Zeichen ist Blank, NULL oder Tabulator */
         if ((c = *((*formel)++)) == ' ' || c == '\0' || c == '\t')
            {
            (*formel)--;
            *operator = '\0';
            return(VARIABLE);
            }
         *(operator++) = c; /* Zeichen sichern */
         /* naechstes Zeichen ist kein Blank, kein NULL oder kein Tab.*/
         while ((c = *((*formel)++)) != ' ' && c != '\0' && c != '\t')
            {
            *(operator++) = c; /* Zeichen sichern */
            }
         (*formel)--;
         *operator = '\0'; /* String abschliessen */
         return(FUNKTION); /* Funktionmerker zurueckgeben */
         }
      }
   *(operator++) = c; /* Zeichen sichern */
   if ((c = *((*formel)++)) == ' ' || c == '\0' || c == '\t' || isupper(c))
      { /* Naechstes Zeichen ist Blank, NULL oder Tabulator, bzw. Grossbuchstabe */
      if (*(operator-1) == '-')  
         { /* letztes Zeichen ist '-' */
         if (c == 'X' || c == 'Y')
            {
            *(operator++) = c;
            *operator = '\0';
            return (VARIABLE);
            }
         else if (strncmp((*formel-1),"PI",2) == 0)
            {
            (*formel)++;
            return(NEG_PI);
            }
         else
            {   
            (*formel)--;
            return(*(operator-1));   /* Minus-Operator zurueckgeben */
            }        
         }
      else
         {
         (*formel)--;
         *operator = '\0'; /* String abschliessen */
         return (NUMBER);  /* Zahl-Merker zurueckgeben */
         }
      }
   *(operator++) = c;
   /* naechstes Zeichen kein Blank, kein Line Feed oder '\0' */
   while ((c = *((*formel)++)) != ' ' && c != '\n' && c != '\0') 
      {
      *(operator++) = c; /* Zeichen sichern */
      }
   (*formel)--;
   *operator = '\0'; /* String abschliessen */
   return (NUMBER);  /* Zahl-Merker zurueckgeben */
   }

/*
***************************************************************************
* Aufruf      : put_stack(int, double);
* Eingabe     : double x;   Wird auf den Stack gelegt.
* Ausgabe     : int fehler; Fehlercode.
* Beschreibung: Die Funktion legt eine Zahl auf den Stack und erhoeht dabei
*               den Stackzaehler.
* History     : 10.10.1989
***************************************************************************
*/
put_stack(fehler,x)
int *fehler;
double x;
   {
   if (stack_nr < STACK_MAX)
      {
      stack[stack_nr] = x;
      stack_nr++;
      }
   else
      {
      *fehler = STACK_VOLL;
      return(0);
      }
   return(0);
   }

/*
***************************************************************************
* Aufruf      : get_stack (int *fehler);
* Eingabe     :
* Ausgabe     : int *fehler;   Fehlercode.
* Return      : double zahl; Vom Stack geholte double-Zahl.
* Beschreibung: Die Funktion holt die zuoberst liegende Zahl vom Stack und
*               dekrementiert dabei den Stackzaehler. 
* History     : 10.10.1989
***************************************************************************
*/
double get_stack(fehler)
int *fehler;
   {
   if (stack_nr > 0)
      {
      return(stack[--stack_nr]);
      }
   else
      {
      *fehler = STACK_LEER;
      return(0);
      }
   }

