/*************************************************************************/
/*************************************************************************/
/**									**/
/**		tstrcmp.C - Fehlertoleranter Stringvergleich		**/
/**      	       (C)  Dr.P.HÑrtel 				**/
/**									**/
/*************************************************************************/
/*************************************************************************/

#include <stdio.h>
#include <ctype.h>



void start(),
     stop();

unsigned int   t1 = 21177;
unsigned long  t2 = 0;
unsigned int   t3 = 569;
unsigned long  t4 = 14614783;
unsigned int   t5 = 64015;
unsigned int   t6 = 20083;

unsigned long  zeit = 0;

char *f_worte[]=
{
"Amsel",
"Drossel",
"Fink",
"ôlandfasan",
"Meise"
};

/*************************************************************************/
/**   main()      **							**/
/**---------------**							**/
/**  Einfaches Testprogramm fÅr fehlertolerante Vergleichsfunktion.	**/
/*************************************************************************/

main()
{
char    puffer[12],			/* Eingabepuffer */
	*s = puffer;
int     i,
	stelle,
	gefunden,
	f_ret_wert[5];

start();
for(i=0;i++<1000;)
   {
   strcmp("Muster", "Muster");
   }
stop();

printf("Gestoppte Zeit %ld ms\n",zeit);

start();
for(i=0;i++<1000;)
   {
   t_strcmp("Muster", "Muster");
   }
stop();

printf("Gestoppte Zeit %ld ms\n",zeit);

printf("\n\n\n");

for(i=0;i<5;i++)
   {
   printf("%s, ",f_worte[i]);
   }
printf("\n\nBitte geben Sie einige dieser Worte fehlerhaft ein.\n");
printf("Abbruch mit <Control> <C> oder 'x'!\n\n>");

while(*s != 'x')			/* Eingabeschleife */
   {
   gets(s);
   gefunden = 0;
   for(i=0;i<5;i++)			/* eingegebenes Wort suchen */
      if(!(f_ret_wert[i] = t_strcmp(f_worte[i],s)))
         {
         gefunden = 1;			/* ausgeben falls gefunden  */
         printf("\n%s %d\n",f_worte[i],f_ret_wert[i]);
         break;
         }
   if(!gefunden)
      {
      gefunden = 4;
      stelle   = 0;
      for(i=0;i<5;i++)			/* falls nicht gefunden,  */
	 if(gefunden > f_ret_wert[i])   /* suche das Wort mit der */
	    {				/* kleinsten Abweichung!  */
	    gefunden = f_ret_wert[i];
	    stelle = i;
	    }
      if(f_ret_wert[stelle] < 4)
         printf("\nMeinen Sie %s ?\n",f_worte[stelle]);
      else
         printf("Das Wort %s kenne ich nicht!\n",s);
      }
   }
}

/*************************************************************************/
/**   t_strcmp()  **							**/
/**---------------**							**/
/**  Tippfehlertolerante Variante der Funktion strcmp. Die Funktion ver-**/
/**  gleicht die beiden Strings, die ihr Åbergeben werden und gibt bei  **/
/**  öbereinstimmung Null zurÅck. Bei NichtÅbereinstimmung wird eine    **/
/**  der folgenden Zahlen zurÅckgegeben:                                **/
/**  1 -> Es handelt sich vermutlich um einen Tipp oder Schreibfehler.  **/
/**  2 -> Zwei Tippfehler oder ein Fehler, der kein Tippfehler ist.     **/
/**  3 -> Tippfehler + sonstiger Fehler.				**/
/**  4 -> zwei oder mehr Fehler - die Strings gelten als verschieden.   **/
/*************************************************************************/

int
t_strcmp(so,sv)
register
char    *so,					/* Original-string    */
	*sv;					/* Vergleichs-string  */
{
register
char    *soh,					/* Hilfszeiger auf so */
	*svh;
register
int     co,
	cv;
int     abweichung = 0;

anfang:

#ifdef MEGAMAX   
 
/* schnelle Assemblerroutine fÅr Megamax Compiler  */
/* 81 ms fÅr 1000 Vergleichsoperationen (strcmp braucht dafÅr 60 ms) */

asm
{
move.b  (A5)+, D0
beq.s   string_ende
cmp.b   (A4)+, D0
beq.s   anfang
bne.s   ungleich
string_ende:
cmp.b   (A4)+, D0
beq     ende
}
#endif

/* etwas langsamer in 'C' 95 ms fÅr 1000 Vergleiche */
#ifndef MEGAMAX 

while(*so && *so++ == *sv++)
   ;
if(!*so && !*sv)
   goto ende;

#endif

ungleich:
soh = so--;
svh = sv--;
co = *so;
cv = *sv;
if(co <= 'Z' || cv <= 'Z')              /* Groûgeschriebene Umlaute    */
   {					/* werden in bewertung geprÅftt*/
   if(co >= 'A' && co <= 'Z')		/* Nur Kleinbuchstaben werden  */
      co = tolower(co);			/* untersucht.                 */
   if(cv >= 'A' && cv <= 'Z')
      cv = tolower(cv);
   if(co == cv)				/* Groû- und Kleinbuchstabe    */
      {					/* wurde verwechselt.          */
      abweichung += 1;
      goto weiter;
      }
   }
if (*soh == *svh)		/* Zwei verschiedene Zeichen    */
   abweichung += bewertung(co,cv);
else if (co == *svh)		/* ein Zeichen zuviel           */
   {
   if (cv == *(--sv))		/* Zeichen doppelt,Taste prellt */
      abweichung += 1;
   else
      abweichung += bewertung(cv,*svh);
   sv = svh;
   }
else if (cv == *soh)		/* ein Zeichen zuwenig        */
   {
   if (co == *(--so))		/* Doppelbuchstabe wurde nur  */
      abweichung += 1;		/* einmal getippt!            */
   else
      abweichung += 2;		/* Sonst ein grober Fehler    */
   so = soh;
   }
else
   abweichung = 4;			/* Zwei Zeichen verschieden  */

weiter:	
					/* ist es sinnvoll, weiter zu */
if ((abweichung < 4)&&co)		/* vergleichen ?              */
   {
   so++;
   sv++;
   goto anfang;
   }
ende:
return(abweichung);
}

/*************************************************************************/
/**   bewertung() **							**/
/**---------------**							**/
/**  Diese Funktion stellt fest, ob es sich um einen Tippfehler handelt.**/
/*************************************************************************/
int
bewertung(co,cv)
int       co,cv;                     /* Original- und Vergleichszeichen */
{
int     pos;
static char f_cr[] =
       "snvfrghjoklî;mpÅwtdzibecxu-î---";	/* rechte Nachbartasten */
static char f_cl[] =
       "-vxswdfguhjknbio-earzcqy-tîlps-";	/* linke  Nachbartasten */


pos = co - 'a';
if (pos > 25)					/* Umlaute einordnen */
   switch (co)
      {
      case 'Ñ':
      case 'é':
         pos = 26;
         break;
      case 'î':
      case 'ô':
         pos = 27;
         break;
      case 'Å':
      case 'ö':
         pos = 28;
         break;
      case 'û':
         pos = 29;
         break;
      default:
         pos = 30;
      }					/* Sind die Zeichen auf der */
if (cv == f_cr[pos]||			/* Tatatur benachbart ?     */
    cv == f_cl[pos])
   return(1);				/* wenn ja, dann Tippfehler */
else
   return(2);				/* wenn nicht, grober Fehler*/
}

void start()
{
unsigned int v1,v2,v3,v4;
unsigned long  v5;

zeit = 0;
t2 = (unsigned long)&zeit;
v1 = 31;
v2 = 0;
v3 = 4;
v4 = 48;
v5 = (unsigned long)&t1;

xbios(v1,v2,v3,v4,v5);
}
void stop()
{
unsigned int v1,v2,v3,v4;
unsigned long  v5;

t2 = (unsigned long)&zeit;
v1 = 31;
v2 = v3 = v4 = v5 = 0;

xbios(v1,v2,v3,v4,v5);
}


