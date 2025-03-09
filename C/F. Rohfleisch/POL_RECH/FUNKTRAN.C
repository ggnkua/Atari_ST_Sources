/*******************************************************************************
* Source-File: FUNKTRAN.C
*-------------------------------------------------------------------------------
* Funktionen : int     translate_formel (char *, char *);
*              int     klammer_ersatz (char *); 
*              int     funk_ersatz (char *);
*              void    find_expo (char *);
*              void    find_point (char *);
*              void    find_line (char *);
*              void    build_formel(char *);
*              int     funk_comp (char *);
*              int     isoperator (int);
*              int     isstrich_op (int);
*              int     ispunkt_op (int);
*              int     isexpo_op (int);
*-------------------------------------------------------------------------------
* Autor      : F.ROHFLEISCH, 7140 LUDWIGSBURG
*-------------------------------------------------------------------------------
* SRC-Version: 1.0
* Betriebsys.: TOS
* Compiler   : TURBO C 1.1
* Beschreib. : uebersetzt Formel von algebraische in polnische Notation; 
* History    : 22.10.1989
*******************************************************************************/

#include    <string.h>
#include    <ctype.h>

#include    <pol_rech.h>

#define     NULL       0

/*#***************************************************************************
                         GLOBALE VARIABLE
***************************************************************************#*/

static char *funktion [] =
                         {
                         "SIN",
                         "COS",
                         "TAN",
                         "SQRT",
                         "EXP",
                         "LN",
                         "ABS",
                         NULL
                         };
                         
static char buffer [BUFFER_MAX][FUNK_LANG_MAX];  
static int buffer_nr = 0;                        

/*#***************************************************************************
                           FUNKTIONSPROTOTYPEN
***************************************************************************#*/

int     translate_formel (char *, char *);
int     klammer_ersatz (char *); 
int     funk_ersatz (char *);
void    find_expo (char *);
void    find_point (char *);
void    find_line (char *);
void    build_formel(char *);
int     funk_comp (char *);
int     isoperator (int);
int     isstrich_op (int);
int     ispunkt_op (int);
int     isexpo_op (int);

/*
*******************************************************************************
* Aufruf     : translate_formel(char *formel_normal, char *formel_polnot);
* Eingabe    : char *formel_normal; Zeiger auf Formel in algebraischer Form.
* Ausgabe    : char *formel_polnot; Zeiger auf Formel in polnischer Notation.
* Return     : 0    :  bei fehlerfreien Umwandlung;
*              sonst: Fehlercode;
* Beschreib. : s.o.
* History    : 11.10.1989
*******************************************************************************
*/
int translate_formel (formel_normal, formel_polnot)
char *formel_normal;
char *formel_polnot;
   {
   int err = 0;
   int x;

   strcpy(formel_polnot, formel_normal); /* algebraische Form sichern */
   err = klammer_ersatz(formel_polnot);  /* Klammerebenen selektieren */ 
   if (err != 0)
      {
      return(err);
      }
   err = funk_ersatz (formel_polnot);    /* Funktionen ersetzen       */
   if (err != 0)
      {
      return(err);
      }
   find_expo(formel_polnot);             /* '^' umwandeln             */ 
   find_point(formel_polnot);            /* '*' und '/' umwandeln     */ 
   find_line(formel_polnot);             /* '+' und '-' umwandeln     */ 
   for (x = buffer_nr-1 ;x >= 0 ; x--)
      {
      err = funk_ersatz(buffer[x]);
      if (err != 0)
         {
         return(err);
         }
      find_expo(buffer[x]);
      find_point(buffer[x]);
      find_line(buffer[x]);
      }
   build_formel(formel_polnot);          /* Formel wieder zusammensetzen */
   return(0);
   }

/*
*******************************************************************************
* Aufruf     : klammer_ersatz(char *formel_polnot);
* Eingabe    : char *formel_polnot; Zeiger auf Formel in algeabraischer Notation.
* Ausgabe    : char *formel_polnot; Zeiger auf Formel in polnischer Notation.
* Return     : 0    : bei fehlerfreien Umwandlung;
*              sonst: Fehlercode;
* Beschreib. : selektiert die Klammerebene; d.h. jede Klammerebene wird in ein
*              Puffer geschrieben und im Original durch '#'+ ASCII-Zeichen er-
*              setzt; das ASCII-Zeichen errechnet sich durch Puffernr.+'0'. 
* History    : 11.10.1989
*******************************************************************************
*/
klammer_ersatz(formel_polnot)
char formel_polnot[];
   {
   char c;
   char *dest;
   char *source;
   int klammer[KLAMMER_MAX];
   register int j = 0;
   int i = 0;
   int k = 0;
   
   for ( ; (c = formel_polnot[i]) != '\0'; i++)
      {
      if (c == '(')                    /* oeffnende Klammer gefunden */
         {
         klammer[k++] = i;
         if (k >= KLAMMER_MAX)
            {
            return (KLAMMER_VOLL);
            }
         }
      else if (c == ')')               /* schliessende Klammer gefunden */
         {
         dest = &(buffer[buffer_nr][0]);
         source = &(formel_polnot[klammer[--k]+1]);
         strncpy(dest, source, i-klammer[k]-1);
         buffer[buffer_nr][i-klammer[k]+2] = '\0';
         formel_polnot[klammer[k]]   = '#';
         formel_polnot[klammer[k]+1] = buffer_nr + '0';
         for (j = klammer[k]+2; j <= i; j++)
            {
            formel_polnot[j] = ' ';
            }
         if (++buffer_nr >= BUFFER_MAX)
            {
            return(BUFFER_VOLL);
            }
         }
      }
   if (k == 0)                           
      {
      return (0);
      }
   else /* Klammerfehler */            
      {
      return (KLAMMERFEHLER);
      }
   }

/*
*******************************************************************************
* Aufruf     : funk_ersatz(char *formel)
* Eingabe    : char *formel; zu bearbeitende Formel.
* Ausgabe    : 
* Return     : 0    : fehlerfrei;
*              sonst: Fehlercode;
* Beschreib. : ersetzt vorkommende Funktionen mitsamt ihren Argument mit
*              '#'+ 'ASCII-Zeichen';
*              die Funktion wird in polnischer Notation in einen Puffer
*              abgelegt, dessen Index sich aus 'ASCII-Zeichen' folgendermassen
*              berechnen laesst: Index = (ASCII-Code) - '0';
*              das Argument wird in algebraischer Notation (!) abgelegt, also
*              z.B. sin(x+1) wird abgelegt als (x+1) sin;
* History    : 22.10.1989
*******************************************************************************
*/
funk_ersatz(formel)
char *formel;
   {
   int c;
   long len = 0;
   int s;
   char *z;
   char *anfang;
   char *ende;

   while ((c = *(formel)) != '\0')          
      { 
      if (isupper(c) != 0 && (len = funk_comp(formel)) != 0)
         {                                    /* Funktionsausdruck gefunden */
         anfang = formel; /* Anfang merken */
         s = 0;
         for (z = formel + len; *z == ' '; z++) 
            {
            ;
            }
         while( (c = *(z++)) != ' ' && c != '\0' && isoperator(c) == 0)
            {               /* Zeichen nicht Blank, NULL oder Rechenoperator */
            /* Argument in Puffer schreiben */
            buffer[buffer_nr][s++] = (char) c ; 
            }
         buffer[buffer_nr][s++] = ' ';
         ende = z - 1 ;               /* Ende merken */
         for (z = formel; len > 0; len--)
            { /* Funktionsausdruck in Puffer schreiben */
            buffer[buffer_nr][s++] = *(z++);
            }
         z = anfang; /* Anfang merken */
         *(z++) = '#'; /* Merker in Formel uebertragen */
         *(z++) = (char)(buffer_nr + '0');
         while ((*(z++) = *(ende++)) != '\0')
            {
            ; /* Zeichen nach Funktion nach vorne 'schauffeln' */
            }
         formel += 2;
         buffer[buffer_nr][s] = '\0';  /* Puffer abschliessen */
         if (++buffer_nr >= BUFFER_MAX)
            {
            return (BUFFER_VOLL);
            }
         } /* end if Funktionsausdruck gefunden */
      else  /* kein Funktionsausdruck gefunden */
         {
         formel++;  /* Zeichen ueberlesen */
         }
      } /* end while */
   return (0);
   }

/*
*******************************************************************************
* Aufruf     :  find_expo(char *string);
* Eingabe    :  char *string; zu untersuchender String;
* Ausgabe    :
* Return     :  
* Beschreib. :  sucht in 'string' nach '^' und wandelt in polnische Notation um;
*               d.h. 'a ^ b' ---> 'a b ^'. 
* History    :  22.10.1989
*******************************************************************************
*/
void find_expo(string)
char *string;
   {
   char *start;
   char hilf[FUNK_LANG_MAX];
   int i = 0;
   
   start = string;
   while (*start != '\0')
      {
      if (*start == '^')
         {
         hilf[i++] = ' ';
         while (isoperator(*(++start)) == 0 && *start != '\0')
            {
            hilf[i++] = *start;
            }
         hilf[i++] = ' ';
         hilf[i++] = '^';
         hilf[i++] = ' ';
         }
      else
         {
         hilf[i++] = *(start++);
         }
      }
   hilf[i] = '\0';
   strcpy(string,hilf);
   } 

/*
*******************************************************************************
* Aufruf     :  find_point(char *string);
* Eingabe    :  char *string; zu untersuchender String;
* Ausgabe    :
* Return     :  
* Beschreib. :  sucht in 'string' nach '*' oder '/' und wandelt in polnische 
*               Notation um; d.h. 'a * b' ---> 'a b *'.
* History    :  22.10.1989
*******************************************************************************
*/
void find_point(string)
char *string;
   {
   char *start;
   char hilf[FUNK_LANG_MAX];
   char op_merker;
   int i = 0;
   
   start = string;
   while (*start != '\0')
      {
      if (ispunkt_op(*start))
         {
         op_merker = *start;
         hilf[i++] = ' ';
         while (ispunkt_op(*(++start)) == 0 && isstrich_op(*start) == 0 &&
                *start != '\0')
            {
            hilf[i++] = *start;
            }
         hilf[i++] = ' ';
         hilf[i++] = op_merker;
         hilf[i++] = ' ';
         }
      else
         {
         hilf[i++] = *(start++);
         }
      }
   hilf[i] = '\0';
   strcpy(string,hilf);
   }

/*
*******************************************************************************
* Aufruf     :  find_line(char *string);
* Eingabe    :  char *string; zu untersuchender String;
* Ausgabe    :
* Return     :  
* Beschreib. :  sucht in 'string' nach '+' oder '-' und wandelt in polnische 
*               Notation um; d.h. 'a + b' ---> 'a b +'.
* History    :  22.10.1989
*******************************************************************************
*/
void find_line(string)
char *string;
   {
   char *start;
   char hilf[FUNK_LANG_MAX];
   int  firstletter = 1;
   char op_merker;
   int i = 0;
   
   start = string;
   while (*start != '\0')
      {
      if (firstletter == 1 && *start != ' ')
         {
         if (*start == '-' || *start == '+')        /* unaere Operatoren? */
            {                                       /* Dann Ruecksprung   */  
            return;
            }
         else
            {
            firstletter = 0;
            }
         }
      if (isstrich_op(*start))
         {
         op_merker = *start;
         hilf[i++] = ' ';
         while (isstrich_op(*(++start)) == 0 && *start != '\0')
            {
            hilf[i++] = *start;
            }
         hilf[i++] = ' ';
         hilf[i++] = op_merker;
         hilf[i++] = ' ';
         }
      else
         {
         hilf[i++] = *(start++);
         }
      }
   hilf[i] = '\0';
   strcpy(string,hilf);
   }

/*
*******************************************************************************
* Aufruf     :  funk_comp (char *string);
* Eingabe    :  char *string; zu untersuchender String;
* Ausgabe    :
* Return     :  0: kein Funktionsausdruck gefunden;
*              >0: Laenge des gefundenen Funktionsausdrucks;
* Beschreib. :  sucht einen Funktionsausdruck in String, der am Anfang (!) des
*               Strings stehen muss;
*               gesuchte Funktionsaudruecke muessen in einem Feld char
*               *funktion[] definiert sein;
* History    :  22.10.1989
*******************************************************************************
*/
int funk_comp(string)
char *string;
   {
   register int i;
   int len = 0;

   for ( i = 0; funktion[i] != NULL; i++) /*Ende des Funktionsfeldes erreicht*/
      {
      if (strncmp(funktion[i],string,strlen(funktion[i])) == 0) 
         {                                /* Funktion gefunden */
         len = (int)strlen(funktion[i]);
         return (len);                    /* Laenge des Funktionsausdrucks */
         }
      }
   return (0); 
   }

/*
*******************************************************************************
* Aufruf     :  build_formel(char *string);
* Eingabe    :  char *string; zusammenzusetzender String;
* Return     :  
* Beschreib. :  setzt die Formel aus den verschiedenen Puffern wieder zusammen;
* History    :  22.10.1989
*******************************************************************************
*/
void build_formel(formel_polnot)
char *formel_polnot;
   {
   char hilf[FUNK_LANG_MAX];
   char *merker;
   int i = 0;
   int j;
   int x;
   
   merker = formel_polnot;
   while (*formel_polnot != '\0')
      {
      if (*formel_polnot == '#')             /* Pufferzeichen gefunden */
         {
         j = 0;
         x = (int)(*(++formel_polnot)-'0');
         build_formel(buffer[x]);            /* rekursiver(!) Aufruf */
         while(buffer[x][j] != '\0')
            {
            if (buffer[x][j] == ' ')         /* Leerzeichen gefunden?    */
               {                             /* Dann eins einfuegen      */
               hilf[i++] = ' ';              /* und restliche ueberlesen */
               while(buffer[x][++j] == ' ' && buffer[x][j] != '\0')
                  {
                  ;
                  }
               }
            else
               {
               hilf[i++] = buffer[x][j++];
               }
            }
         formel_polnot++;
         }
      else                                    /* normales Zeichen */
         {              
         if (*formel_polnot == ' ')
            {
            hilf[i++] = ' ';
            while(*(++formel_polnot) == ' ' && *formel_polnot != '\0')
               {
               ;
               }
            }
         else
            {
            hilf[i++] = *(formel_polnot++);
            }                    
         }
      }
   hilf[i] = '\0';
   strcpy(merker,hilf);
   }

/*
*******************************************************************************
* Aufrufe    :  int isoperator(int);
*               int isstrich_op(int);
*               int ispunkt_op(int);
*               int isexpo_op(int);
* Eingabe    :  int zeichen; zu untersuchendes Zeichen;
* Ausgabe    :  
* Return     :  0: kein ensprechendes Zeichen;
*               1: entsprechendes Zeichen;
* Beschreib. :  isoperator   : untersucht Zeichen, ob es '+','-','*','/','^' ist.  
*               isstrich_op  : untersucht Zeichen, ob es '+','-' ist.
*               ispunkt_op   : untersucht Zeichen, ob es '*','/' ist.
*               isexpo_op    : untersucht Zeichen, ob es '^' ist.
* History    :  22.10.1989
*******************************************************************************
*/
isoperator(c)
int c;
   {
   if (isstrich_op(c) || ispunkt_op(c) || isexpo_op(c))
      {
      return (1);
      }
   else
      {
      return (0);
      }
   }


ispunkt_op(c)
int c;
   {
   if (c == '*' || c == '/')
      {
      return (1);
      }
   else
      {
      return (0);
      }
   }

isstrich_op(c)
int c;
   {
   if (c == '+' || c == '-')
      {
      return (1);
      }
   else
      {
      return (0);
      }
   }

isexpo_op(c)
int c;
   {
   if (c == '^')
      {
      return (1);
      }
   else
      {
      return (0);
      }
   }

