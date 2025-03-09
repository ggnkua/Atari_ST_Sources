/**********************************************/
/* Modul:   REM_KILL.C                        */
/* ------------------------------------------ */
/* Funktionen:                                */
/*    Lîscht alle C-Remarks in einem File     */
/* Ersteller:                                 */
/*    Hartmut Klindtworth, 26.04.1992         */
/*    Copyright 1992 by MAXON-Verlag, Eschborn*/
/* Extern:                                    */
/*    MEMORY.C                                */
/**********************************************/

/*= INCLUDES =================================*/
#include <ext.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

/*= EXTERNE FUNKTIONEN =======================*/
extern int  init_malloc( long ul_maxmemory );
extern int  ende( void );
extern void *mallocn(int ui_vh,long ul_groesse);
extern int freen(int ui_vh,void *uvp_oldadress);
extern int  Mshrinkn(int ui_vh, int ui_zero, 
              void *uvp_block, long ul_newsize);
extern void *callocn( int ui_vh, long ul_nitems,
                                  long ul_size);

/*= PROTOTYPEN ===============================*/
void exit_ende( void );

int main(int argc, char *argv[])
{
  FILE  *daten=NULL;
  char  pfad[MAXPATH];
  char  *dest,*source;
  long  laenge,sc,dc;
  int   remcount;       

  if(init_malloc(0)==-1)
      return( 39 ); /* Kein Speicher mehr da! */

  /* Bei Programmabbruch erst Speicher zurÅck */
  atexit(exit_ende);  
  
  /* Information Åber das Programm ausgeben.  */
  puts("C-REM - KILLER V 1.0");
  puts(  "Autor:  Hartmut Klindtworth, 1992\n");

  /* Wurde etwas der Routine Åbergeben ?      */
  memset(pfad,0,MAXPATH);
  if(argc>1 && strlen(argv[1])>0)
    strcpy(pfad,argv[1]);
  else
  { /* Da nichts Åbergeben worden ist, ...    */
    puts("Bitte den Pfad und Dateinamen"
                                  " angeben:");
    gets(pfad);
    if(strlen(pfad)==0) exit(0);
  }   
  /* Exist. die Datei, lÑût sie sich îffnen?  */
  daten=fopen(pfad,"rb");
  if(daten==NULL) exit(2);

  /* LÑnge des Files ermitteln und Speicher   */
  /*  zum Einlesen reservieren.               */
  laenge=filelength(fileno(daten));
  
  if( (long)mallocn(0,-1) < 2*laenge ) exit(39);

  source=(char *)mallocn(1,laenge);
  dest  =(char *)callocn(0,1,laenge);

  /* Datei komplett einlesen                  */
  fread(source,laenge,1,daten);
  fclose(daten);
  
  /* Funktion:                                */
  /*  Es wird jedes Byte verifiziert, ob es   */
  /*  ein Remark einleitet oder beendet. Ent- */
  /*  sprechend wird dann der Remarkcounter   */
  /*  erhîht oder erniedrigt. Nur wenn dieser */
  /*  0 ist, ist der Text nicht in ein Remark */
  /*  geschachtelt.                           */

  dc=remcount=0;
  for(sc=0; sc<laenge; sc++)
  { /* Jedes Byte nachsehen, ob es ein REM ist*/
    if(*(source+sc)=='/' && *(source+sc+1)=='*')
        remcount++;
    else
    if(*(source+sc)=='*' && *(source+sc+1)=='/')
    { remcount--;   sc++;
      if(remcount<0)
      { puts("FEHLER in REMARKS!");
        freen(0,dest);
        freen(1,source);
        exit(1);
      }
    }else
      if(remcount==0)
      { *(dest+dc)=*(source+sc);
        dc++;
      };  
  }

  /* Speicher des kopierten Speicherblocks    */
  /*  auf benîtigte Grîûe verkleinern         */
  Mshrinkn(0,0,dest,dc);

  /* Source-Speicher freigeben.               */
  freen(1,source);

  strcpy(strrchr(pfad,'.'),".REM");
  if( ( daten=fopen(pfad,"wb") )!=NULL)
  { /* Daten jetzt in ".REM"-Datei schreiben  */
    fwrite(dest,1,dc,daten);
    fclose(daten);
    freen(0,dest);
  }else
  { freen(0,dest);
    exit(2);
  }
  exit(0);
  return(0);
}   

void exit_ende( void )
{
  ende();
}
