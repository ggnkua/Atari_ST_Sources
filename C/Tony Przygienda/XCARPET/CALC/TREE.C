/* dieses Modul enthÑlt alle Funktionen zur Zerlegung der Funktion in
   einen Baum und dessen nachtrÑgliche Auswertung */
/* letzte énderung 14.10.1988  -> Erweiterung fÅr Turbo-C und ANSI-Standard */

#include "..\carpet.h"
#include <portab.h>
#include <math.h>

#if COMPILER==TURBOC
	#include "..\tree.h"
	#include <string.h>
	#include <stdlib.h>   /*  fÅr malloc  */
	#include <stdio.h>    /*  fÅr printfs */
#endif

#define IS_MAIN  TRUE

#define isalpha(c) ((c>='A' && c<='Z') || (c>='a' && c<='z'))
#define isdigit(c) (c>='0' && c<='9')

#define MAXLEN 20
#define MAXFKT 27 /* Funktionen maximal */

#if IS_MAIN  &&  COMPILER==MEGAMAX     /* MEGAMAX */
	overlay "calc"
#endif

#define abs(a)      ((a<0)?(-a):(a))
double  power(); /* vorsichtshalber schon vordefinieren */

typedef
   struct help
      {
       char          art;           /* o,v,f,z,s */
       union                        /* nÑhere Angaben */
         {
          int    fnr; /* Nummer der Funktion in der Tabelle */
          double zahl;
          char   vname;
          char   oname;
          char   sign;
         } inhalt;
       struct help *li,*re,*vat;  /* nach rechts, links und den Vater */
      } terms;
typedef
   terms *zeiger;

#define  boolean  char

#define  CHANGED   1
#define  NO_CHANGE 0	

#define  AND     &&
#define  OR      ||
#define  NOT     !

#define GENAUIGKEIT 0.00001  

zeiger func_tree=(zeiger) NIL;    /* zeigt auf den Anker des Funktionsbaumes */

double   variables[3];   /* Werte der Variablen */ 
boolean  error = FALSE ;  /* allgemeine Fehlermeldung !fÅr alle Module! */
char     errorstring[90]; /* hier wird die Fehlermeldung reingequetscht */
static 	int k=0;         /* Zeiger an welcher Stelle im String die Funktion
                             ausdruck gerade abarbeitet */

char    ch;        /* das laufende Zeichen */

char    ftab[MAXFKT+1][MAXLEN]= 
             { "sin",       /* 1 */
               "cos",
               "arctan",
               "ln",
               "exp",       /* 5 */
               "tan",
               "sqrt",
               "sinh",
               "cosh",
               "tanh",       /* 10 */
               "artanh",
               "arcsin",
               "arccos",
               "cot",
               "arsinh",    /* 15 */
               "arcosh",
               "log",
               "sqr",
               "abs",        
               "int" };
          /* Tabelle der Funktionsnamen */
#if IS_MAIN
char *funcstring;
#else
char funcstring[100]; /* funktioniert nicht mit EXTERN ??? */
#endif

extern void memory_error();
#if (IS_MAIN)  &&  (COMPILER==TURBOC)
extern void memory_error(void);    /* extern from xcarpet */
#else
void memory_error()
{
printf("\nSpeicher !!!\n");
gemdos(7);
exit(0);
}
#endif

static int funknr(
#if COMPILER==TURBOC
						char *st)
#else
			st)	         /* nimmt Pointer auf Namen einer Funktion und */
char *st;              /* liefert ihren Index im ftab-Array oder Error */
#endif
{
extern int strcmp();
extern char *strcpy(); /* standard functions */
register int i=-1;

 strcpy(ftab[MAXFKT],st);

 while(strcmp(st,ftab[++i])); /* solange bis beide gleich */

 if (i>=MAXFKT)
   {
    error=TRUE;
    sprintf(errorstring,"Unbekannte Funktion %s()",st);
    return -1; /* nicht gefunden */
   }
 return(i);
}

void new(a)
zeiger *a;
{
register short r;
#if COMPILER==MEGAMAX
	extern char *malloc();
#endif

(*a)=(zeiger) malloc(sizeof(terms));
if (!(*a))
   memory_error();  
for (r=0;r<sizeof(terms);r++)
   ((char *)(*a))[r]='\0';
}

void disp_tree(pt) /* ein Baum wird freigegeben bis unten von pt an */
register zeiger pt;
{
#if COMPILER==TURBOC
	void disp_tree(zeiger);
#endif

if (pt)
   {
   if (pt->li)
      disp_tree(pt->li);
   if (pt->re)
      disp_tree(pt->re);
   free(pt);
   }
}

void disp_all() /* ganzen Baum */
{
if (func_tree)
   disp_tree(func_tree);
func_tree=NIL;
}

#define o(z)      (z-'0')

void concat(st,chr)   /* hÑngt an einen fname-String einen Buchstaben */
char st[];
char chr;
{
 register int counter;

 for(counter=0;st[counter]!='\0';counter++);
 if (counter<MAXLEN-2)
   {
    st[counter++]=chr;
    st[counter   ]='\0';
   }
 else
   {
    error= TRUE;
    sprintf(errorstring,"Funktion zu lange in %d",k);
   }
}

void readch()  /* liest den nÑchsten Charakter aus dem String */
{
#if COMPILER==MEGAMAX
	extern int strlen();
#endif

 if (k > strlen(funcstring))
   {
   error= TRUE;
   sprintf(errorstring,"UngÅltiger Ausdruck");
   ch='@';
   }
 else
   {
   if (funcstring[k]>='A' AND funcstring[k]<='Z')
      funcstring[k]+=32; /* in kleine umwandeln */
   ch=funcstring[k++];
   }
} 

void lies(locpoint)  /* liest eine Zahl, Funktion OR Variable und macht */
zeiger locpoint;     /* daraus eine Struktur, auf die locpoint zeigt   */
{
#if COMPILER==TURBOC
	void readch(void);
	void concat(char *,char);
	int  funknr(char *);
#endif

if (isdigit(ch) OR ch=='.') /* eine Zahl ? */
   {
   if (ch!='.')        /* eine Zahl der Form D.DDDDD ? */
      {
      locpoint->art='z';
      locpoint->inhalt.zahl=o(ch);
      readch();
      while (isdigit(ch))
         {
         locpoint->inhalt.zahl *= 10;
         locpoint->inhalt.zahl += o(ch); /* solange Zahl, *10 + n~chste */
         readch();           /* Zahl          */
         }  
      }
   if (ch=='.')        /* eine Zahl der Form .DDDD oder einfach noch */
      {            /* Nachkommastellen einlesen         */
      double bs=10.;

      readch();
      locpoint->art='z';
      while (isdigit(ch))
         {
         locpoint->inhalt.zahl += o(ch) / bs;
         readch();
         bs *= 10;
         }
      } /* of if der Nachkommastellen */
   } /* of if , somit eine Zahl abgearbeitet */
else
   if (isalpha(ch))   /* nicht eine Zahl, also Func oder Var */
      {
      char first_char = ch;
      char fname[MAXLEN+2];

      readch();
      if (isalpha(ch))  /* Falls das zweite Zeichen ein Buchstabe */
         {       /* ist dies eine Funktion */
         locpoint->art = 'f';
         fname[0] = first_char;
         fname[1] = '\0';
         do
            {
            concat(fname, ch);
            readch();
            } 
         while ((ch!='(') AND (!error)); 
         locpoint->inhalt.fnr=funknr(fname); /* muss nicht gefunden werden */
               /* die Funktion kann ja zu */
            }                   /* lange sein        */
      else       /* sonst halt eine Variable */
         {
         locpoint->art = 'v';
         locpoint->inhalt.vname = first_char;
         }
      }
   else
      {
      /* sonst's ist's halt ein syntax */
      locpoint->art='z';
      locpoint->inhalt.zahl = 0.;
      error = TRUE;
      sprintf(errorstring,"Syntax Fehler in %d",k);
      }
}

zeiger faktor(pt)
zeiger pt;
{
zeiger ausdruk(    );
#if COMPILER==TURBOC
	zeiger ausdruk(zeiger); 			/* ANSI like! */
	void lies(zeiger);
	void new(zeiger *);
#endif

 if (!error)
   {
    if (ch=='(')
      {
       pt=ausdruk(pt);
       if (ch!=')')
         {
         error = TRUE;
         sprintf(errorstring,"Geschlossene Klammer erwartet in %d",k);
         }
       else
         readch();
      }
    else
      {
       lies(pt);
       if (!error)
         {
         if (pt->art=='f')
            {
            new(&pt->li);
            pt->li=ausdruk(pt->li);
            if (ch!=')')
               {
               error = TRUE;
               sprintf(errorstring,"Geschlossene Klammer nach Funktion erwartet in %d",k);
               }
            else
               readch();
            }
         }
      }
   }
 return pt;
}

zeiger pterm(pt)
zeiger pt;
{
zeiger faktor();
#if COMPILER==TURBOC
	zeiger faktor(zeiger); 			/* ANSI like! */
	zeiger pterm(zeiger);
	void new(zeiger *);
#endif

 if (!error)
   {
    pt=faktor(pt);
    while (ch=='^' AND (!error))
      {
       new(&pt->vat);
       pt->vat->art =    'o';
       pt->vat->inhalt.oname =   '^';
       pt->vat->li    =  pt;
       pt = pt->vat;
       readch();
       new(&pt->re);
       if ((ch=='+') OR (ch=='-'))
          {
          pt->re->art='s';
          pt->re->inhalt.sign= ch;
          readch();
          new(&pt->re->li);
          pt->re->li=pterm(pt->re->li);
          }
       else
          pt->re=pterm(pt->re);
      }
   }
 return pt;
}

zeiger term(pt)
zeiger pt;
{
zeiger pterm();
#if COMPILER==TURBOC
	zeiger pterm(zeiger); 			/* ANSI like! */
	void new(zeiger *);
#endif

 if (!error)
   {
    pt=pterm(pt);
    while ((ch=='*' OR ch=='/') AND (!error))
      {
       new(&pt->vat);
       pt->vat->art =    'o';
       pt->vat->inhalt.oname =   ch;
       pt->vat->li    =  pt;
       readch();
       new(&pt->vat->re);
       pt->vat->re=pterm(pt->vat->re);
       pt= pt->vat;
      }
   }
 return pt;
}

zeiger ausdruk(pt)
zeiger pt;
{
zeiger term();
#if COMPILER==TURBOC
	zeiger term(zeiger); 			/* ANSI like! */
	void new(zeiger *);
#endif

if (!error)
   {
   readch();
   if ((ch=='+' OR ch=='-') AND (!error))
      {
      pt->art='s';
      pt->inhalt.sign=ch;
      readch();
      new(&pt->li);
      pt->li=term(pt->li);
      }
   else
      pt=term(pt);
   
   if (!error)
      {
      while ((ch=='+' OR ch=='-') AND (!error))
         {
         new(&pt->vat);
         pt->vat->art =     'o';
         pt->vat->inhalt.oname =   ch;
         pt->vat->li    =   pt;
         readch();
         new(&pt->vat->re);
         pt->vat->re=term(pt->vat->re);
         pt= pt->vat;
         }
      }
   }
 return pt;
}

zeiger ausdruck(pt)       /* aus einer Zeichenkette */
zeiger pt;                /* und einem Anfangspointer pt wird ein Baum */
{
zeiger ausdruk();
#if COMPILER==TURBOC
	zeiger ausdruk(zeiger); 			/* ANSI like! */
#endif

 error=FALSE;
 k=0;
 
 return ausdruk(pt);
}

double funcwert(x,y)
double x,y;
{
double auswert();
#if COMPILER==TURBOC
	double auswert(zeiger, double, double); 			/* ANSI like! */
#endif

return auswert(func_tree,x,y);
}

double auswert(p,x,y)
register zeiger p;
register double x,y;
{
double power();
#if COMPILER==TURBOC
	double auswert(zeiger, double, double); 			/* ANSI like! */
	double power(double, double);
#endif
register double left,right;
register int fnum;
register double arg;   /* argument der funktion */

if (!error)
   switch (p->art)
      {
      case 's':
         switch (p->inhalt.sign)
            {
            case '+':
               return auswert(p->li,x,y);
               /* break; */
            case '-':
               return -1.*auswert(p->li,x,y);
               /* break; */
            default:
               puts("\n***NO '+' OR '-' SIGN IN AUSWERT()***\n");
               return 0.;
               /* break; */
            }
         /* break; */
      case 'z':
         return p->inhalt.zahl;
         /* break; */
      case 'v':
         if (p->inhalt.vname>='a' AND p->inhalt.vname<='c')
            return variables[p->inhalt.vname-'a'];
         else 
            if (p->inhalt.vname=='x' OR p->inhalt.vname=='y')
               return (p->inhalt.vname=='x' ? x:y);
            else
               {
               error=TRUE;
               sprintf(errorstring,"Unerlaubte Variable");
               return 0.;
               }
         /* break; */
      case 'f':
         arg=auswert(p->li,x,y);
         if (!error)
            sprintf(errorstring,"Argument unerlaubt fÅr Funktion %s()",
                        ftab[p->inhalt.fnr]);
         /* Funktion ist in der Tabelle, sonst wÅrde give_function motzen */
 
         if (!error)   /* zB. Funktion nicht gefunden */
            switch (p->inhalt.fnr) /* direkt Nummer der Funktion */
               {
               case 0:
                  return sin(arg);
                  /* break; */
               case 1:
                  return cos(arg);
                  /* break; */
               case 2: /* not allowed */
                  if ((arg+PID2<0.) OR (arg>PID2))
                     {
                     error=TRUE;
                     return 0.;
                     }
                  return atan(arg);
                  /* break; */
               case 3:
                  if (arg<=0.)
                     {
                     error=TRUE;
                     return 0.;
                     }
                  return   log(arg);
                  /* break; */
               case 4:
                  return   exp(arg);
                  /* break; */
               case 5:
                  left=abs(arg-PID2)/PI; /* irgendwo im Pol */
                  if (left-(long) left<GENAUIGKEIT)
                     return 1.e100;
                  else   
                     return   tan(arg);
                  /* break; */
               case 6:
                  if (arg<0.)
                     {
                     error=TRUE;
                     return 0.;
                     }
                  return   sqrt(arg);
                  /* break; */
               case 7:
                  return .5*(exp(arg)-exp(-arg)); /* sinh(x) */
                  /* break; */
               case 8:
                  return .5*(exp(arg)+exp(-arg)); /* cosh(x) */
                  /* break; */
               case 9:
                  return (exp(arg)-exp(-arg))
                        /(exp(arg)+exp(-arg));   /* tanh(x) */
                  /* break; */
               case 10:
                  if ((arg>=1.) OR (arg+1.<=0.))
                     {
                     error=TRUE;
                     return 0.;
                     }
                  return .5*log((arg+1.)/(1.-arg));   /* arctanh */
                  /* break; */
               case 11:
                  if ((arg>1.) OR (arg<-1.))
                     {
                     error=TRUE;
                     return 0.;
                     }
                  return asin(arg);
                  /* break; */
               case 12:
                  if ((arg>1.) OR (arg+1<0.))
                     {
                     error=TRUE;
                     return 0.;
                     }
                  return acos(arg);
                  /* break; */
               case 13:
                  left=abs(arg)/PI; /* irgendwo im Pol */
                  if (left-(long) left<GENAUIGKEIT)
                     return 1.e100;
                  else   
                     return   1/tan(arg);
                  /* break; */
               case 14:
                  /* arsinh() */ return log(arg+sqrt(arg*arg+1));
                  /* break; */
               case 15:
                  if (arg-1.<0.)
                     {
                     error=TRUE;
                     return 0.;
                     }
                  else   
                  /* arcosh() */ return log(arg+sqrt(arg*arg-1));                                      
                  /* break; */
               case 16:
                  /* log */
                  if (arg<=0.)
                     {
                     error=TRUE;
                     return 0.;
                     }
                  else
                     return log(arg)/2.3202585093; /* ln(10) */
                  /* break; */
               case 17: /* sqr() */
                  return arg*arg;
                  /* break; */
               case 18: /* abs() */
                  return abs(arg);
                  /* break; */
               case 19: /* int() */
                  return (double) ((long) arg);
                  /* break; */
               default:
                  strcpy(errorstring,"Funktion unbekannt in Auswert()");
                  return 0.;
                  /* break; */
               }
         break;
      case 'o':
         left=auswert(p->li,x,y);
         right=auswert(p->re,x,y);
         switch(p->inhalt.oname)
            {
            case '+':
               return left+right;
               /* break; */
            case '-':
               return left-right;
               /* break; */
            case '*':
               return left*right;
               /* break; */
            case '/':
               if (abs(right)<GENAUIGKEIT)
                  return 1.e100;   /* NO ERROR !!! */   
               return left/right;
               /* break; */
            case '^':
               return power(left,right);
               /* break; */
            default:
               puts("\nOPERAND UNKNOWN IN AUSWERT()\n");
               return 0.;
               /* break; */
            }
         /* break; */
      }
error=TRUE;      
return 0.; /* falls alle durch und keinen erfÅllt */
}
             
double power(base,expt)
double base,expt;
{
if (abs(expt)<1e-15 && abs(base)<1e-15) /* Fall 0^0 */
   return 1.;
else if (abs(expt)<1e-15) /* exponent 0 */
   return 1.; 
else if (abs(base)<1e-15) /* Basis 0 */
   return 0.;  
else if((base<0.) AND  (abs(expt-(int) expt)>GENAUIGKEIT))
        /* Basis <0 und Exponent nicht ganzzahlig */
        {
        error=TRUE;
        strcpy(errorstring,"Potenz undefiniert");
        return 0.;
        }
else if ((-base < 0.) OR (abs(expt)<GENAUIGKEIT))
        return exp(expt*log(base));
else /* Basis kleiner NIL und Exponent ganzzahlig,negativ */
        {
        register unsigned run;
        double ret;
        
        for (ret=1., run=0; run<abs(expt); ret*=base,run++);
        
        return (expt<0.) ? 1./ret : ret;
        } 
}
                                       
#define TESTFUNC FALSE
                
#if TESTFUNC
void tree_output(pt,tab)
zeiger pt;
int tab;
{
#define TAB_INC 4
#define putchar(a) gemdos(0x2,(WORD) a)
 register int i;

 if (pt->li != NIL)
   tree_output(pt->li,tab+TAB_INC);

 printf("%lx",(long) pt);
 for (i=1;i++<tab;putchar(' '));
 switch (pt->art)
   {
    case 'z':
       printf(":%.2f",pt->inhalt.zahl);
       break;
    case 'v':
       printf(":%c",pt->inhalt.vname);
       break;
    case 'o':
       printf(":%c",pt->inhalt.oname);
       break;
    case 's':
       printf(":s%c",pt->inhalt.sign);
       break;
    case 'f':
       if (pt->inhalt.fnr==-1)
         printf("fun?");
       else
         printf(":%s",ftab[pt->inhalt.fnr]);
       break;
    default:
       printf("Was vergessen !");
       break;
   }
 printf("\n");
 if (pt->re != NIL)
    tree_output(pt->re,tab+TAB_INC);
}
#endif

#if IS_MAIN
void give_function(f,erstring)
char *f;
char **erstring; /* extern char* funktioniert intermodular nicht !! */
#else
main()
#endif
{
#if COMPILER==TURBOC
	void disp_all(void);
	zeiger ausdruck(zeiger);
#endif
#if IS_MAIN
funcstring=f; /* wegen dem dÑmlichen extern */
#else
printf("?:");
scanf("%80s",funcstring); 
#endif       
#if TESTFUNC
   printf("\nvor dispose\n");
   gemdos(7);
#endif
disp_all();
#if TESTFUNC
   printf("\nnach dispose\n");
   gemdos(7);
   printf("\nFunc:%lx\n",funcstring);
#if COMPILER==TURBOC
   printf("len:%l\n",strlen(funcstring));
#else
   printf("len:%d\n",strlen(funcstring));
#endif
   gemdos(7);
#endif
new(&func_tree);
#if TESTFUNC
   printf("\nfunc_tree:%lx\n",func_tree);
   gemdos(7);
#endif
func_tree=ausdruck(func_tree);
#if TESTFUNC
   printf("\nFunktion aufgenommen\n");
   if (error)
      printf("\n%s\n",errorstring);
   tree_output(func_tree,2);
   printf("Var: %f %f %f\n",variables[0],variables[1],variables[2]);
   gemdos(7);
#endif   
(*erstring)=errorstring;
}



