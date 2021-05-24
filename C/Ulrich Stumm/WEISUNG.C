/*****************************************************************************/
/*                                                                           */
/*                    Druckprogramm fÅr öberweisungsformulare                */
/*                                                                           */
/*   programmiert von Ulrich und Holger Stumm im MÑrz 1987  (UHS-Software)   */
/*                                                                           */
/*****************************************************************************/

int mo_hiden=0;                                  /* Steuerung des Mauszeiger */
#define hidemaus() {if (mo_hiden==0) {graf_mouse(256,0L); mo_hiden=1;}}
#define showmaus() {if (mo_hiden==1) {graf_mouse(257,0L); mo_hiden=0;}}
#define pfeilmaus() graf_mouse(0,0L)             /* Mausform als Pfeil       */
#define bienemaus() graf_mouse(2,0L)             /* Mausform als Biene       */

#include "gembind.h"
#include "taddr.h"
#include "obdefs.h"
#include "osbind.h"
#include "stdio.h"
#include "weisung.h"  /* Datei muû erst mit Construction-Set erstellt werden */

#define tiefe 3                           /* Ebenen der Dialogbox 'formular' */

int contrl[12],intin[128],ptsin[128],ptsout[128],intout[128];
int work_out[57],work_in[12];

int xd,yd,wd,hd;                                          /* Dialogboxgrîûen */

int handle;                                         /* Arbeitsstationsnummer */
FILE *file_handle;                                    /* fÅr Dateiverwaltung */

long form_addr;                        /* Adresse des Dialogbaums 'FORMULAR' */
long tree;                              /* Adresse fÅr beliebigen Dialogbaum */

char pfad[64],                           /* Laufwerk + Suchpfad 'C:\MEGAMAX' */
     wahl[13],                           /* Auswahlkriterium      '\*.*'     */
     name[13],                           /* Filename der AusgewÑhlt wurde    */
     pfad_name[64];                      /* Laufwerk + Suchpfad + Filename   */

char protoname[64];                     /* Pfad und Namen fÅr Protokolldatei */

char *text;                                       /* allgemiener Textpointer */
char ***p_form[13];           /* EnthÑlt Felder fÅr ein öberweisungsformular */

int knopf,taste;                         /* fÅr RÅckmeldungen aus Funktionen */
int xy[4];                        /* fÅr v_bar (weiûes Rechteck als Leiste ) */

/*****************************************************************************/

gem_init()               /* nîtige Initialisierungen fÅr den Betrieb mit GEM */
{
  int i;

  appl_init();                                         /* Anwendung anmelden */
  for (i=0;i<10;i++)
    work_in[i]=1;
  work_in[10]=2;
  v_opnvwk(work_in,&handle,work_out);               /* Arbeitsstation îffnen */
  if (rsrc_load("WEISUNG.RSC")==0)                         /* RSC-File laden */
  {
    text="[3][Achtung Fehler| |Das RSC-File ist nicht vorhanden.][Abbruch]";
    form_alert(1,text);
    gemdos(0x0); /* Abbruch */
  }
  rsrc_gaddr(0,FORMULAR,&form_addr);     /* Adresse fÅr Dialogbaum ermitteln */
}

/*****************************************************************************/

laden()                           /* öberweisungsformular von Diskette laden */
{
  int fehler,i,k;
  char zeile[255];

  taste=file_box(pfad,wahl,name,pfad_name);          /* Dateinamen auswÑhlen */
  objc_draw(form_addr,5,tiefe,0,19,639,399);      /* Bildschirm restaurieren */
  if (taste==1)
  {
    bienemaus();
    if ((file_handle=fopen(pfad_name,"r"))!=0)      /* Datei zum Lesen îffen */
    {
      i=0;
      while((fehler!=0)&&(i<=12))         /* 12 Zeilen sollen gelesen werden */ 
      {
        k=0;
        do
        {
          fehler=(int)(fgets(&zeile[k],2,file_handle)); /* ein Zeichen lesen */
        }
        while((fehler!=0)&&(zeile[k++]!='\n'));
        zeile[k-1]='\0';
        sprintf(**p_form[i++],"%s",zeile); /* Textzeile in Editfeld eintragen*/
      }
      if ((fehler==0)&&(i!=13))
        form_alert(1,"[3][Die Formulardatei|ist fehlerhaft][Abbruch]");
      fclose(file_handle);                                /* Datei schleiûen */
    }
    else                                   /* wenn Datei nicht vorhanden ist */
      form_alert(1,
               "[3][Die Formulardatei konnte|nicht geîffnet werden][Abbruch]");
    pfeilmaus();
  }                                                             /* end of if */
}                                                        /* end of prozedure */

/*****************************************************************************/

speichern()            /* speichern eines öberweisungsformulars auf Diskette */
{
  int i;

  taste=file_box(pfad,wahl,name,pfad_name);          /* Dateinamen auswÑhlen */
  objc_draw(form_addr,5,tiefe,0,19,639,399);      /* Bildschirm restaurieren */
  if (taste==1)                      /* wenn Fileselectbox mit  "OK" beendet */
  {
    bienemaus();
    file_handle=fopen(pfad_name,"w");           /* Datei zum Schreiben îffen */
    for (i=0; i<=12; i++)
      fprintf(file_handle,"%s\n",**p_form[i]);  /* Editfelder rausschreiben  */
    fclose(file_handle);                                  /* Datei schlieûen */
    pfeilmaus();
  }
}

/*****************************************************************************/

drucken()                 /* druckt Editfelder auf öberweisungs-Endlospapier */
{
  int i;
  char zeile[81];                         /* nimmt immer eine Druckzeile auf */

  do                                    /* drucken ? und Drucker einschalten */
    taste=form_alert(1,
         "[3][öberweisung drucken?|Drucker einschalten!][ drucken | Abbruch ]");
  while((!Cprnos())&&(taste==1));           /* ist der Drucker eingeschaltet */

  if (taste==1)                     /* wenn mit 'drucken' beendet worden ist */
  {                                         /* Schriftart fÅr Drucker wÑhlen */
    taste=form_alert(1,
             "[1][WÑhlen Sie eine SchriftstÑrke][ NORMAL | DICK | SUPER ]");
    bienemaus();
    switch(taste)
    {
      case 1:                                                 /* Doppeldruck */
           print("\033G");
           break;
      case 2:                                                 /* Fettschrift */
           print("\033E");
           break;
      case 3:                                   /* Doppeldruck + Fettschrift */
           print("\033G");
           print("\033E");
           break;
    }
    print("\033R\002");                   /* ESC "R" 2 (Zeichensatz DEUTSCH) */
    print("\033A\006");           /* ESC "A" 6 (Zeilenabstand auf 6/72 inch) */

    sprintf(zeile," %s\n",**p_form[0]);
    print(zeile);                                      /* EmpfÑnger 1. Zeile */
    sprintf(zeile,"%43s%s\n","",**p_form[2]);
    print(zeile);                                            /* Bankleitzahl */
    sprintf(zeile," %s\n\n\n\n",**p_form[1]);
    print(zeile);                                      /* EmpfÑnger 2. Zeile */
    sprintf(zeile," %s",**p_form[3]);
    print(zeile);                                   /* Kontonummer EmpfÑnger */
    sprintf(zeile,"\r%16s%s\n\n","",**p_form[4]);
    print(zeile);                                            /* Bankinstitut */
    sprintf(zeile,"\n\n%s\n\n",**p_form[5]);
    print(zeile);                               /* Verwendungszweck 1. Zeile */
    sprintf(zeile,"%s",**p_form[6]);
    print(zeile);                               /* Verwendungszweck 2. Zeile */
    sprintf(zeile,"%s",**p_form[8]);
    if (strlen(zeile)!=0)                       /* Nur wenn Betrag vorhanden */
      sprintf(zeile,"\r%41s**%s**\n\n","",**p_form[8]);
    else
      sprintf(zeile,"\n\n");
    print(zeile);                                    /* öberweisungsbetrag */
    sprintf(zeile,"%s\n\n\n\n",**p_form[7]);
    print(zeile);                               /* Verwendungszweck 3. Zeile */
    sprintf(zeile,"%15s%s\n","",**p_form[10]);
    print(zeile);                         /* 1. Zeile Anschrift Auftraggeber */
    sprintf(zeile," %s\n",**p_form[9]);
    print(zeile);                               /* Kontonummer des EmpfÑnger */
    sprintf(zeile,"%15s%s\n\n\n\n\n","",**p_form[11]);
    print(zeile);                         /* 2. Zeile Anschrift Auftraggeber */
    sprintf(zeile,"%17s%s\n","",**p_form[12]);
    print(zeile);                                                   /* Datum */
    print("\0332");                            /* Zeilenabstand auf 1/6 inch */
    for (i=1; i<=12; i++)                      /* auf nÑchste Seite mit LF's */
      print("\n");
    print("\033F");                            /* Fettschrift ausschalten    */
    print("\033H");                            /* Doppeldruck ausschalten    */
    protokoll();                             /* öberweisung in Liste sichern */
    pfeilmaus();
  }
}

/*****************************************************************************/

print(string)                     /* konvertiert und druckt einen String aus */
char string[255];
{
  int i=0,flag=1;

  while(string[i]!='\0')              /* Solange das Ende nicht erreicht ist */
  {
    switch(string[i])                /* eventuelle Konvertierung fÅr Drucker */
    {
      case '›':  string[i]=64;   flag=1;  break; /* mit DEUTSCH-Zeichensatz */
      case 'é':  string[i]=91;   flag=1;  break;
      case 'ö':  string[i]=93;   flag=1;  break;
      case 'ô':  string[i]=92;   flag=1;  break;
      case 'Ñ':  string[i]=123;  flag=1;  break;
      case 'î':  string[i]=124;  flag=1;  break;
      case 'Å':  string[i]=125;  flag=1;  break;
      case 'û':  string[i]=126;  flag=1;  break;
      case '@':  string[i]=64;   flag=0;  break; /* mit USA-Zeichensazt */
      case '[':  string[i]=91;   flag=0;  break;
      case '\\': string[i]=92;   flag=0;  break;
      case ']':  string[i]=93;   flag=0;  break;
      case '{':  string[i]=123;  flag=0;  break;
      case '|':  string[i]=124;  flag=0;  break;
      case '}':  string[i]=125;  flag=0;  break;
      case '~':  string[i]=126;  flag=0;  break;
    }

    if (flag==0)                  /* wenn flag 0 mit USA-Zeichensatz drucken */
    {
      print("\033R\000");                     /* ESC "R" 0 (Zeichensatz USA) */
      Cprnout(string[i++]);                 /* ein Zeichen an Drucker senden */
      print("\033R\002");                 /* ESC "R" 2 (Zeichensatz DEUTSCH) */
      flag=1;
    }
    else                          /* sonst mit DEUTSCH-Zeichensatz drucken   */
      Cprnout(string[i++]);                 /* ein Zeichen an Drucker senden */
  }
}

/*****************************************************************************/

protokoll()      /* Speichert Daten der öberweisung in Liste auf Diskette ab */
{
  int i;

  file_handle=fopen(protoname,"a");             /* Datei zum AnhÑngen îffnen */
  fprintf(file_handle,"%13s | %s\n",**p_form[12],**p_form[ 0]);
  fprintf(file_handle,"%13s | %s\n",""          ,**p_form[ 1]);
  fprintf(file_handle,"%13s | %s\n",**p_form[ 3],**p_form[ 4]);
  fprintf(file_handle,"%13s | %s\n",""          ,**p_form[ 5]);
  fprintf(file_handle,"%13s | %s\n",**p_form[ 8],**p_form[ 6]);
  fprintf(file_handle,"%13s | %s\n",""          ,**p_form[ 7]);
  fprintf(file_handle,"%13s | %s\n",**p_form[ 9],**p_form[10]);
  fprintf(file_handle,"%13s | %s\n",""          ,**p_form[11]);
  fprintf(file_handle,
                 "--------------------------------------------------------\n");
  fclose(file_handle);                                    /* Datei schlieûen */
}

/*****************************************************************************/

akt_datum()                   /* aktuelles Datum aus der Compteruhr auslesen */
{
  int date;
  char zr,datestr[11];

  date=Tgetdate();                                         /* Datum auslesen */
  zr=((char)date)&0x1f;
  datestr[0]=zr/10+'0';                           /*  Zehnerstelle des Tages */
  datestr[1]=zr%10+'0';                           /*  Einerstelle  des Tages */
  zr=((char)(date>>=5))&0xf;
  datestr[2]='.';
  datestr[3]=zr/10+'0';                           /* Zehnerstelle des Monats */
  datestr[4]=zr%10+'0';                           /* Einerstelle  des Monats */
  zr=((char)((date>>4)+80L)%100)&0x7f;
  datestr[5]='.'; datestr[6]='1'; datestr[7]='9';
  datestr[8]=zr/10+'0';                           /* Zehnerstelle des Jahres */
  datestr[9]=zr%10+'0';                           /* Einerstelle  des Jahres */
  datestr[10]='\0';
  sprintf(**p_form[12],"%s",datestr);         /* Datum in Formular eintragen */
}

/*****************************************************************************/

file_box(path,choise,word,path_name)         /* eigene Fileselectbox-routine */
char *path,*choise,*word,*path_name;
{
  int key,ii,kk;
  char kette[64];

  ii=strlen(path);                                /* LÑnge des Vorgabepfades */
  while((ii!=0)&&(path[ii]!=':'))        /* Laufwerkangaben suchen (vor ':') */
    ii--;
  if (ii==0)            /* Wenn kein ':' vorhanden dann Laufwerkangabe holen */
  {
    kette[0]=Dgetdrv()+'A';                   /* aktuelles Laufwerk auslesen */
    strcpy(&kette[1],":");
    strcat(kette,path);                     /* Laufwerk + restl. Pfadvorgabe */
    strcpy(path,kette);                          /* zurÅck auf path kopieren */
  }
  if (strlen(choise)==0)                  /* Wenn noch kein Auswahlkriterium */
    sprintf(choise,"\\*.*");                      /* absolutes Suchkriterium */
  strcat(path,choise);                                 /* Kriterium anhÑngen */

  fsel_input(path,word,&key);      /* eigentlicher Fileselect aufruf fÅr GEM */

  ii=strlen(path);                             /* nach '\' von hinten suchen */
  while ((ii!=0)&&(path[ii]!='\\'))
    ii--;
  path[ii]='\0';                                /* Suchkriterium abschneiden */

  if (key!=0)                                   /* wenn mit OK abgeschlossen */
  {
    ii=strlen(word);                           /* nach '.' von hinten suchen */
    while((ii!=0)&&(word[ii]!='.'))
      ii--;
    if (ii==0)                               /* Wenn kein Extention dran ist */
    {
      ii=strlen(choise);             /* Position des '.' im Extention suchen */
      while(choise[ii]!='.')
        ii--;
      for (kk=ii; kk<=strlen(choise); kk++)   /* ab dieser Position bis Ende */
        kette[kk-ii]=choise[kk];              /* Extention kopieren und ...  */
      kette[++kk]='\0';
      strcat(word,kette);                     /* ... anhÑngen (z.B. '.FRM')  */
    }
              /* Filename besteht aus Laufwerk + Pfad und ausgewÑhltem Namen */
    sprintf(path_name,"%s\\%s",path,word);
  }
  else
    path_name[0]='\0';           /* mit Abbruch beendet => kein Name gewÑhlt */
  return(key);
}

/*****************************************************************************/

main()              /* Hauptprogramm Åbernimmt Kontrolle des Programmablaufs */
{
  int k;
  char drive[2];               /* fÅr aktuelles Laufwerk */

  gem_init();                  /* Arbeitsstation anmelden und RSC-File laden */

  Dgetpath(pfad,0);  /* aktuellen Pfad auslesen und als 1. Vorgabe verwenden */
  sprintf(wahl,"\\*.FRM");     /* Auswahlkriterium nach allen FoRMat-Dateien */

  drive[0]=Dgetdrv()+'A';                        /* aktuelles Laufwerk holen */
  strcpy(&drive[1],":");
  sprintf(protoname,"%s%s\\PROTOKOLL.DAT",drive,pfad);      /* Protokollpfad */

  hidemaus();
  pfeilmaus();
  xy[0]=0; xy[1]=0; xy[2]=639; xy[3]=18;
  vsf_interior(handle,0);
  vsl_color(handle,0);
  v_bar(handle,xy);         /* weiûe Leiste an oberen Bildschirmrand zeichen */
  vsl_color(handle,1);
  v_gtext(handle,16,14,                           /* und mit Textbeschreiben */
"Druckprogramm fÅr öberweisungsformulare - programmiert von UHS-Soft MÑrz '87");

  tree=form_addr;                           /* Pointer auf Editfelder setzen */
  p_form[00]=(char ***)(OB_SPEC(EMPF_1));
  p_form[01]=(char ***)(OB_SPEC(EMPF_2));
  p_form[02]=(char ***)(OB_SPEC(BLZ));
  p_form[03]=(char ***)(OB_SPEC(KTO_EMPF));
  p_form[04]=(char ***)(OB_SPEC(BANK));
  p_form[05]=(char ***)(OB_SPEC(ZWECK_1));
  p_form[06]=(char ***)(OB_SPEC(ZWECK_2));
  p_form[07]=(char ***)(OB_SPEC(ZWECK_3));
  p_form[08]=(char ***)(OB_SPEC(BETRAG));
  p_form[09]=(char ***)(OB_SPEC(KTO_AUFT));
  p_form[10]=(char ***)(OB_SPEC(ANSCHR_1));
  p_form[11]=(char ***)(OB_SPEC(ANSCHR_2));
  p_form[12]=(char ***)(OB_SPEC(DATUM));
  for (k=0; k<13; k++)                          /* Editfelder mit Leerstring */
    sprintf(**p_form[k],"\0");                  /* vorbesetzen               */

  form_center(form_addr,&xd,&yd,&wd,&hd);           /* Dialogbox zentrieren  */
  form_dial(FMD_START,xd,yd,wd,hd);                 /* Dialogbox vorbereiten */
  form_dial(FMD_GROW,1,1,1,1,xd,yd,wd,hd);          /* wachsendes Rechteck   */
  objc_draw(form_addr,0,tiefe,0,19,639,399);        /* Dialogbox zeichen     */
  showmaus();

  do
  {
    knopf=form_do(form_addr,EMPF_1);                /* GEM verwaltet Dialog  */
    switch(knopf)                                   /* mit welchem Knopf     */
    {                                               /* wurde Box beendet ??? */
      case LOAD:
           laden();
           objc_change(form_addr,LOAD,0,xd,yd,wd,hd,SHADOWED,1);
           if (taste==1)                       /* wenn neue Texte vorhanden, */
             objc_draw(form_addr,5,tiefe,0,19,639,399);/* dann auch ausgeben */
           break;

      case SAVE:
           speichern();
           objc_change(form_addr,SAVE,0,xd,yd,wd,hd,SHADOWED,1);
           break;

      case PRINT:
           drucken();
           objc_change(form_addr,PRINT,0,xd,yd,wd,hd,SHADOWED,1);
           break;

      case QUIT:
          text="[3][Wollen Sie das Programm|wirklich beenden?][beenden|zurÅck]";
           taste=form_alert(1,text);
           if (taste==1)
           {
             form_dial(FMD_FINISH,1,1,1,1,xd,yd,wd,hd); /* Dialogbox beenden */
             form_dial(FMD_SHRINK,1,1,1,1,xd,yd,wd,hd); /* schrumpfendes Rec */
             v_clsvwk(handle);                   /* Arbeitsstation schlieûen */
             gemdos(0x0);                              /* zurÅch zum Desktop */
           }
           objc_change(form_addr,QUIT,0,xd,yd,wd,hd,SHADOWED,1);
           break;

      case DATE:
           akt_datum();
           objc_change(form_addr,DATE,0,xd,yd,wd,hd,NORMAL,1);
           objc_draw(form_addr,DATUM,tiefe,0,19,639,399);
           break;

    }                                                      /* end of switch  */
  } while(1);                                              /* Endlosschleife */
}                                                          /* end of main    */
