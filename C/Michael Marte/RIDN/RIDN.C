/*
RIDN
"Retter in der Not"
Programm zum KÅrzen von Header-Files auf das Wesentliche
by Michael Marte  (c) 1992 MAXON Computer
*/


#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ext.h>


/* Typendefinitionen */

/*
Folgende Typen stehen in meiner STDDEF.H :

typedef unsigned char byte;
typedef unsigned int word;
typedef unsigned long lword;

typedef enum {failed=0,false=0,ok=1,true=1} bool;
typedef bool succ;
*/


/* Variablendefinitionen */

struct ffblk fspec;
/* Dateinformationen */

char sdir[65];
/* Quellverzeichnis */

char ddir[65];
/* Zielverzeichnis */

char sfile[81];
/* Quelldatei (kompletter Pfad) */

char dfile[81];
/* Zieldatei (kompletter Pfad) */


char *white_blanks=" \t\n\r";
/* Weiûe Leerzeichen */

char *separators=" \t\n\r,;=+-!?:*%&|/\<>()[]{}";
/* Trennzeichen */


/* Prototypen */

succ ridn(char *sfile,char *dfile,lword size);
void show_err(char *msg);

   
main(){
   int choice;

   do{
      do{
         printf("\x1b\x45"
                "RIDN - \"Retter in der Not\"\n"
                "Programm zum KÅrzen von Header-"
                "Files auf das Wesentliche\n"
                "v1.02 vom 12.12.1991\n"
                "(c)1990 by Michael Marte\n\n"
                "1. Datei bearbeiten\n"
                "2. Alle Dateien eines Ordners "
                "bearbeiten\n"
                "3. Ende\n\n"
                "Bitte wÑhlen Sie : ");
         scanf("%d",&choice);
      }while(choice<1 || choice>3); 
      printf("\x1b\x45");

      switch(choice){
         case 1:
            printf("Quelldatei : ");
            scanf("%80s",sfile);
            printf("Zieldatei  : ");
            scanf("%80s",dfile);
            if(findfirst(sfile,&fspec,0)==0)
               (void)ridn(sfile,dfile,fspec.ff_fsize);
            break;
         case 2:
            printf("Quellordner : ");
            scanf("%64s",sdir);
            printf("Zielordner  : ");
            scanf("%64s",ddir);
            (void)strcpy(sfile,sdir);
            (void)strcat(sfile,"\\*.H");
            if(findfirst(sfile,&fspec,0)==0)
               do{
                  (void)strcpy(sfile,sdir);
                  (void)strcat(sfile,"\\");
                  (void)strcat(sfile,fspec.ff_name);
                  (void)strcpy(dfile,ddir);
                  (void)strcat(dfile,"\\");
                  (void)strcat(dfile,fspec.ff_name);
                  if(!ridn(sfile,dfile,fspec.ff_fsize))
                     break;
                  (void)strcpy(sfile,sdir);
                  (void)strcat(sfile,"\\*.H");
               }while(findnext(&fspec)==0);
      }

   }while(choice!=3);

   return 0;
}


succ ridn(char *sfile,char *dfile,lword size){

   char *sptr;
   /* Zeiger in den Quelltext */

   char *dptr;
   /* Zeiger hinter das "Eingemachte" */

   char *start;
   /* Zeiger auf den Beginn der Quelltextes */

   char *end;
   /* Zeiger auf dessen Ende */

   bool ppc=false;
   /*
   Bearbeitungsmodus :
   ppc=true =>
     ein PrÑprozessorkommando wird bearbeitet
   */

   int sfid,dfid;
   /* Handles der Quell- und Zieldatei */


   printf("Quelle : %s  Ziel : %s\n",sfile,dfile);

   /* Quelldatei îffnen */
   if((sfid=open(sfile,O_RDONLY))==-1){
      show_err("Quelldatei îffnen ");
      return failed;
   }

   /* Speicher reservieren */
   if((start=(char *)malloc(size))==NULL){
      show_err("Speicher reservieren ");
      (void)close(sfid);
      return failed;
   }

   end=start+size-1;

   /* Quelldatei einlesen */
   if(read(sfid,start,size)<size){
      show_err("Quelldatei lesen ");
      free(start);
      (void)close(sfid);
      return failed;
   }
   (void)close(sfid);

   /* Quelldatei komprimieren */

   sptr=dptr=start;

   while(sptr<=end){

      switch(*dptr=*sptr++){
         case '#':
            /* PrÑprozessor-Kommando */
            ppc=true;
            dptr++;
            break;
         case '\r':
            /* Carriage Return */
            if(ppc)
               /*
               Wenn am Ende der vorherigen Zeile kein
               Backslash steht, wenn die Zeile also zu
               Ende ist, muû der ppc-Bearbeitungsmodus
               ausgeschaltet werden.
               */
               if(dptr>start && *(dptr-1)!='\\') ppc=false;
            /*
            Wenn das letzte Zeichen des Eingemachten
            kein Line Feed ist, dann ist die aktuelle
            Zeile keine Leerzeile und das Line Feed 
            muû kopiert werden.
            */
            if(dptr>start && *(dptr-1)!='\n') dptr++;
            break;
         case '\n':
            /* Line Feed*/
            /*
            SinngemÑûer Kommentar s. bei 'Carriage Return'.
            */
            if(dptr>start && *(dptr-1)!='\n') dptr++;
            break;
         case '/':
            /* eventuell Kommentar */
            if(*sptr!='*') dptr++;
            else{
               int rem_count=1;
               /*
               ZÑhler zur Bearbeitung verschachtelter
               Kommentare
               */

               sptr++;
               while(rem_count>0 && sptr<end){
                  switch(*sptr++){
                     case '/':
                        /* eventuell noch ein Kommentar */
                        if(*sptr=='*'){
                           sptr++;
                           rem_count++;
                        }
                        break;
                     case '*':
                        /* eventuell Ende eines Kommentars */
                        if(*sptr=='/'){
                           sptr++;
                           rem_count--;
                        }                       
                  }
               }
            }
            break;
         case '\'':
            /* Stringkonstante */
            {
               bool eos=false;
               /* Stringende noch nicht erreicht */

               dptr++;

               /* String kopieren */
               while(!eos && sptr<=end){
                  switch(*dptr++=*sptr++){
                     case '\\':
                        /* Escapesequenz kopieren */
                        *dptr++=*sptr++;
                        break;
                     case '\'':
                        /* Stringende erreicht */
                        eos=true;
                  }
               }
            }
            break;
         case '\"':
            /*
            String :
            SinngemÑûer Kommentar s. bei
            'Stringkonstante'
            */
            {
               bool eos=false;

               dptr++;
               while(!eos && sptr<=end){
                  switch(*dptr++=*sptr++){
                     case '\\':
                        *dptr++=*sptr++;
                        break;
                     case '\"':
                        eos=true;
                  }
               }
            }
            break;
         case '\t':
            /* Tabulator */
         case ' ':
            /* Space */
            /*
            Wenn das Zeichen unbedingt zur Trennung
            zweier Bezeichner benîtigt wird, dann
            muû es kopiert werden.
            */
            if(ppc){
               if(strchr(white_blanks,*sptr)==NULL &&
                  strchr(white_blanks,*(dptr-1))==NULL)
                  dptr++;
            }else
               if(dptr>start &&
                  strchr(separators,*sptr)==NULL &&
                  strchr(separators,*(dptr-1))==NULL)
                  dptr++;
            break;
         default:
            /* sonstiges Zeichen */
            dptr++;
         }
   }

   /* Zieldatei îffnen */
   if((dfid=creat(dfile))==-1){
      show_err("Zieldatei îffnen/anlegen ");
      return failed;
   }

   /* Eingemachtes schreiben */
   if(write(dfid,start,size=dptr-start)<size){
      show_err("Zieldatei schreiben ");
      (void)close(dfid);
      return failed;
   }

   /* Zieldatei schlieûen */
   if(close(dfid)==-1){
      show_err("Zieldatei schlieûen ");
      return failed;
   }

   return ok;

}


void show_err(char *msg){
   perror(msg);
   printf("\n<Taste>\n");
   (void)getch();
}
