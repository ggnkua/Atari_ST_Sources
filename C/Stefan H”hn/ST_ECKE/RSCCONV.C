/************************************************************************/
/*                                                                      */
/*                 Resource-Definitionsdatei-Konverter                  */
/*                    Version 1.0  Datum: 15.5.1990                     */
/*                             Stefan Hîhn                              */
/*         konvertiert: DEF->DFN, DFN->DEF, DEF->HRD, HRD->DEF          */
/*                      RSD entspricht DEF !                            */
/*                                                                      */
/************************************************************************/

#include <obdefs.h>
#include <gemdefs.h>
#include <osbind.h>
#include "defconv.h"

#define NONAME_GIVEN "[1][Sie haben keinen|Namen angegeben!][Abbruch]"
#define FILE_ERROR1  "[1][Datei gibt es nicht !!!][Abbruch]"
#define FILE_ERROR2  "[1][Datei gibt es schon !!!][Abbruch]"

typedef struct hrd_deader  /* Kopf der HRD-Datei */
{ 
    int  version;   /* Versionsnummer: im Moment 1 */
    char auto_name; /* 0=aus/1=ein */
    char language;  /* 1=C,2=Pascal,4=Modula2,8=Fortran,
                       16=Assembler,32=BASIC */
    char auto_pos;  /* 0=aus, 1=Halb-Pos. ein, 2=Voll-Pos. ein */
    char character; /* 0=Groû/Klein, 1=Groû, 2=Klein */
    char auto_size; /* 0=aus, 1=ein */
    char reserved;  
}HRD_HEADER;

char hrd_typ[]={5,0,1,0,2,3,4};   /* Umkodierung RCS1.x- in Wercs-Typ */
char def_typ[]={3,2,4,5,6,0};     /* Umkodierung Wercs- in RCS1.x-Typ */

OBJECT *tree;

main()
{
   int exit_obj, proc_ret, x,y,w,h, ret;
   char from_name[64], to_name[64], pname[64], fname[64], *srch="*.*";
   int  from_fd,       to_fd;
   GRECT box;

   appl_init();                     /* bei AES anmelden */
   graf_mouse(ARROW,0L);            /* Pfeil als Mausbild einschalten */
   
   fname[0]=pname[0]=0;             /* Namen auf Null setzen */

   rsrc_load("defconv.rsc");
   rsrc_gaddr(0,MAIN,&tree);
   form_center(tree,&x,&y,&w,&h);  /* Box zentrieren */
   form_dial(0,0,0,639,200);       /* Der Einfachheit halber. */
                                   /* Besser Koordinaten von VDI holen ! */
   form_dial(1,0,0,320,200,x,y,w,h); /* Box îffnen */
   objc_draw (tree,0, MAX_DEPTH,0, 0,639, 399);  /* Box zeichnen */
   exit_obj=form_do(tree,0);         /* Box bearbeiten */

   if (exit_obj!=ABBRUCH)          /* Solange bis Abbruch gedrÅckt wurde */
   {
      form_alert(0,"[1][Bitte wÑhlen Sie erst|die Quell- und dann| die Zieldatei!][OK]");
      ret=do_file(pname,fname,srch,from_name); /* Dateinamen einlesen */
      if (ret && from_name[0])                 /*wenn OK und Name!='' */
      {
         fname[0]=0;                           /* Namen lîschen */
         ret=do_file(pname,fname,srch,to_name);/* nÑchsten Namen holen */
         if (!ret || !to_name[0])              /* Falls Abbruch oder kein Name */
         {
            form_alert(0,NONAME_GIVEN);        /* Meldung ausgeben */
            exit(-1);
         }
      }
      else                        /* Abbruch oder kein Name */
      {
         form_alert(0,NONAME_GIVEN);
         exit(-1);
      }

      switch(exit_obj)   /* Welche Konvertierung */
      {
   
         case DEF2DFN: proc_ret=def2dfn(from_name, to_name);
                       break;

         case DFN2DEF: proc_ret=dfn2def(from_name, to_name);
                       break;

         case DEF2HRD: proc_ret=def2hrd(from_name, to_name);
                       break;

         case HRD2DEF: proc_ret=hrd2def(from_name, to_name);
                       break;
      }
   }
   form_dial(2,0,0,320,200,x,y,w,h);    /* Box schlieûen */
   form_dial(3,0,0,639,399);            /* Bildschirmbereich freigeben */
   tree[exit_obj].ob_state&=~SELECTED;  /* Bit zurÅcksetzen */

   appl_exit();

   return(proc_ret);
}

int def2dfn(from, to)   /* RCS 1.x/RSD -> RCS 2.x konvertieren */
char *from, *to;
{
   int fd1, fd2, i;
   long flen;
   char byte1, byte2, symbol[8];

   fd1=Fopen(from,0);                 /* Datei îffnen */
   if (fd1<0)                         /* Datei ist nicht zu îffnen */
   {
      form_alert(0,FILE_ERROR1);      /* Meldung ausgeben */
      return(-2); 
   }
   fd2=Fopen(to,0);                   /* Ausgabedatei îffnen */
   if (fd2>0)                         /* existiert bereits */
   {
      Fclose(fd1);                    /* dat janze abbrechen */
      Fclose(fd2);
      form_alert(0,FILE_ERROR2);
      return(-3);
   }
   fd2=Fcreate(to,0);                 /* Datei erzeugen */
   flen= Fseek(0L,fd1,2);  /* LÑnge ermitteln */
   Fseek(0L,fd1,0);        /* an den Anfangs setzen */
   i=flen;
   while(i>0)
   {
      Fread(fd1,1L,&byte1);    /* 2 Bytes lesen */
      Fread(fd1,1L,&byte2);
      Fwrite(fd2,1L,&byte2);   /* vertauscht schreibe */
      Fwrite(fd2,1L,&byte1);

      Fread(fd1,1L,&byte1);    /* 2 Bytes Åbergehen */
      Fread(fd1,1L,&byte2);

      Fread(fd1,1L,&byte1);    /* 2 Bytes lesen */
      Fread(fd1,1L,&byte2);
      Fwrite(fd2,1L,&byte2);   /* vertauscht schreiben */
      Fwrite(fd2,1L,&byte1);

      Fread(fd1,1L,&byte1);    /* 2 Bytes lesen */
      Fread(fd1,1L,&byte2);
      Fwrite(fd2,1L,&byte2);   /* vertauscht schreiben */
      Fwrite(fd2,1L,&byte1);

      Fread(fd1,8L,symbol);
      Fwrite(fd2,8L,symbol);
      i-=16;
   }
   Fclose(fd1);                     /* Dateien schlieûen */
   Fclose(fd2);
   return(0);
}

int dfn2def(from, to)  /* RCS 2.x -> RCS 1.x/RSD konvertieren */
char *from, *to;
{
   int fd1, fd2, i, null=0;
   long flen;
   char byte1, byte2, symbol[8];
    
   fd1=Fopen(from,0);  /* Datei zum Lesen îffnen */
   if (fd1<0)          /* Datei ist nicht zu îffnen */
   {                   /* Abbruch */
      form_alert(0,FILE_ERROR1);
      return(-2);
   }
   fd2=Fopen(to,0);    /* Datei  îffnen */
   if (fd2>0)          /* Datei gibt es schon */
   {                   /* Abbruch */
      Fclose(fd1);
      Fclose(fd2);
      form_alert(0,FILE_ERROR2);
      return(-3);
   }
   fd2=Fcreate(to,0);
   flen= Fseek(0L,fd1,2);  /* LÑnge ermitteln */
   Fseek(0L,fd1,0);        /* an den Anfangs setzen */
   i=flen;
   while(i>0)
   {
      Fread(fd1,1L,&byte1);    /* 2 Bytes lesen */
      Fread(fd1,1L,&byte2);
      Fwrite(fd2,1L,&byte2);   /* vertauscht schreiben */
      Fwrite(fd2,1L,&byte1);

      Fwrite(fd2,2L,&null);

      Fread(fd1,1L,&byte1);    /* 2 Bytes lesen */
      Fread(fd1,1L,&byte2);
      Fwrite(fd2,1L,&byte2);   /* vertauscht schreiben */
      Fwrite(fd2,1L,&byte1);

      Fread(fd1,1L,&byte1);    /* 2 Bytes lesen */
      Fread(fd1,1L,&byte2);
      Fwrite(fd2,1L,&byte2);   /* vertauscht schreiben */
      Fwrite(fd2,1L,&byte1);

      Fread(fd1,8L,symbol);
      Fwrite(fd2,8L,symbol);
      i-=14;
   }
   Fclose(fd1);
   Fclose(fd2); 
   return(0);
}

int def2hrd(from, to)  /* RCS 1.x/RSD -> Wercs konvertieren */
char *from, *to;
{
   int fd1, fd2, i, file_pointer, null=0, wort;
   long flen;
   char byte1, byte2, byte3, byte4, symbol[9];
   HRD_HEADER head;

   fd1=Fopen(from,0);  /* Datei îffnen */
   if (fd1<0)          /* Datei geht nicht zu îffnen */
   {                   /* Abbruch */
      form_alert(0,FILE_ERROR1);
      return(-2);
   }
   fd2=Fopen(to,0);    /* Datei îffnen */
   if (fd2>0)          /* Datei gibt es schon */
   {                   /* Abbruch */
      Fclose(fd1);
      Fclose(fd2);
      form_alert(0,FILE_ERROR2);
      return(-3);
   }
   fd2=Fcreate(to,0);        /*  Schreibdatei erzeugen */
   head.version=1;           /*  Versionsnummer ist momentan 1 */
   head.auto_name=0;         /*  keine automatische Namensgebung */

   flen= Fseek(0L,fd1,2);    /* LÑnge ermitteln */
   Fseek(0L,fd1,0);          /* an den Anfangs setzen */

   Fread(fd1,2L,&wort);      /*  Anzahl der DatensÑtze wird bei */
                             /*  HRD-Format nicht verwendet */
   Fread(fd1,2L,&wort);      /*  Sprachflags in DEF in einem Wort */
   head.language=(char)wort; /*  bei HRD in einem Byte */
   head.auto_pos=2;          /*  Zeichenausrichtung einschalten */
   head.character=1;         /*  Namensgebung in Groûschrift */
   head.auto_size=0;         /*  keine automatische GrîûenÑnderung */
   head.reserved=0;          
   
   Fwrite(fd2,(long)sizeof(head),&head); /* Header schreiben */

   Fread(fd1, 1L, &byte1); /* Index des Objektbaumes bei Objekten */
   Fread(fd1, 1L, &byte2); /* Index des Baumes oder Objekts (Byte)*/
   Fread(fd1, 1L, &byte3); /* 0=Baum, 1=Objekt */
   Fread(fd1, 1L, &byte4); /* Typ des Objekts */

   Fwrite(fd2,1L,&hrd_typ[byte4]); /* Typ umkodieren */
   Fwrite(fd2,1L,&null);           /* reserviertes Byte auf Null setzen */
   wort=byte1;                     /* Index des Baums war Byte und wird */
   Fwrite(fd2,2L,&wort);           /* jetzt als Wort geschrieben */
   wort=byte2;                     /* Index des Objekts war Byte und wird */
   Fwrite(fd2,2L,&wort);           /* jetzt als Wort geschrieben */

   Fread(fd1,8L,symbol);           /* Namen lesen */
   i=0;                            /* ZÑhler lîschen */          
   symbol[8]=0;                    /* letzter Buchstabe ist 'Stringende' */
   do
   {
      Fwrite(fd2,1L,&symbol[i]);   /* Buchstaben schreiben */
   }while(symbol[i++]);            /* Bis Null erreicht */

   file_pointer=flen-16;           /* 1 Record ist ja schon gelesen */

   while(file_pointer>0)           /* Bis alles gelesen worden ist */
   {
      Fread(fd1,4L,symbol);        /* 4 Bytes Åberspringen */
      Fread(fd1, 1L, &byte1); /* Index des Objektbaumes bei Objekten */
      Fread(fd1, 1L, &byte2); /* Index des Baumes oder Objekts (Byte)*/
      Fread(fd1, 1L, &byte3); /* 0=Baum, 1=Objekt */
      Fread(fd1, 1L, &byte4); /* Typ des Objekts */
   
      Fwrite(fd2,1L,&hrd_typ[byte4]); /* Typ umkodieren */
      Fwrite(fd2,1L,&null);           /* reserviertes Byte auf Null setzen */
      wort=byte1;                     /* Index des Baums war Byte und wird */
      Fwrite(fd2,2L,&wort);           /* jetzt als Wort geschrieben */
      wort=byte2;                     /* Index des Objekts war Byte und wird */
      Fwrite(fd2,2L,&wort);           /* jetzt als Wort geschrieben */
   
      Fread(fd1,8L,symbol);           /* Namen lesen */
      i=0;                            /* ZÑhler lîschen */          
      symbol[8]=0;                    /* letzter Buchstabe ist 'Stringende' */
      do
      {
         Fwrite(fd2,1L,&symbol[i]);   /* Buchstaben schreiben */
      }while(symbol[i++]);            /* Bis Null erreicht */

      file_pointer-=16;               /* minus 1 Datensatz */
   }
   byte1=6;                           /* Heiût 'Dateiende' */
   Fwrite(fd2,1L,&byte1);             /* schreiben */
   for (i=0; i<6; i++)                /* Datensatz mit Nullen */
      Fwrite(fd2,1L,&null);           /* auffÅllen */
   Fclose(fd1);                       /* DEF-Datei schlieûen */
   Fclose(fd2);                       /* HRD-Datei schlieûen */
   return(0);
}

int hrd2def(from, to)  /* RCS 1.x/RSD -> Wercs konvertieren */
char *from, *to;
{
   int fd1, fd2, i, no_recs, null=0, wort1, wort2;
   long flen, langnull=0;
   char byte1, byte2, symbol[9];
   HRD_HEADER head;

   fd1=Fopen(from,0);  /* Datei zum Lesen îffnen */
   if (fd1<0)          /* keine Datei gefunden */
   {                   /* -> Abbruch */
      form_alert(0,FILE_ERROR1);  
      return(-2);       
   }
   fd2=Fopen(to,0);    /* Datei zum Schreiben îffnen */
   if (fd2>0)          /* Datei gibt es schon */
   {                   /* Abbruch */
      Fclose(fd1);
      Fclose(fd2);
      form_alert(0,FILE_ERROR2);
      return(-3);
   }
   fd2=Fcreate(to,0);
   head.version=1;           /*  Versionsnummer ist momentan 1 */
   head.auto_name=0;         /*  keine automatische Namensgebung */

   flen= Fseek(0L,fd1,2);    /* LÑnge ermitteln */
   Fseek(0L,fd1,0);          /* an den Anfangs setzen */

   Fread(fd1,(long)sizeof(head),&head);  /* Header lesen */
   wort1=0;
   Fwrite(fd2,2L,&wort1);    /* Anzahl der Records erstmal null */
   wort1=(int)head.language; /* Sprachenflags, vorher Byte, nun Wort */
   Fwrite(fd2,2L,&wort1);
   Fread(fd1,1L,&byte1);     /* Typ lesen */
   Fread(fd1,1L,&byte2);     /* unwichtiges Byte */
   Fread(fd1,2L,&wort1);     /* Nummer des Baums, bei Wercs Wort */
   Fread(fd1,2L,&wort2);     /* Objektnummer, bei Wercs Wort */
   
   for(i=0; i<8; i++)        /* ganzen Namen */
       symbol[i]=0;          /* auf Null setzen */
   i=0;
   do
       Fread(fd1,1L,&symbol[i]); /* Buchstabe lesen */
   while(symbol[i++]!=0);        /* bis Nullbyte kommt */

   if (byte1!=5)             /* Wenn Typ kein, sondern Baum */
      byte2=(char)wort1;     /* Nummer des Baums, bei RCS1.x Byte */
   else
      byte2=0;
   Fwrite(fd2,1L,&byte2);    /* schreiben */
   byte2=(char)wort2;        /* Objektnummer, bei RCS1.x Byte */
   Fwrite(fd2,1L,&byte2);    /* schreiben */
   byte2=(byte1==5);         /* Typ(HRD) =5 entspricht Objekt =1 */
   Fwrite(fd2,1L,&byte2);    /* schreiben */
   Fwrite(fd2,1L,&def_typ[byte1]); /* umkodierten Typ schreiben */
   Fwrite(fd2,8L,symbol);    /* Name schreiben */   

   no_recs=1;                   /* Anzahl der Records */
   while(1)                 
   {
      Fread(fd1,1L,&byte1);     /* Typ lesen */
      if (byte1==6)             /* Wenn Typ(HRD)=6=Dateieende, */
         break;                 /* dann raus aus der While-Schleife */  
      Fread(fd1,1L,&byte2);     /* unwichtiges Byte */
      Fread(fd1,2L,&wort1);     /* Nummer des Baums, bei Wercs Wort */
      Fread(fd1,2L,&wort2);     /* Objektnummer, bei Wercs Wort */
      
      for(i=0; i<8; i++)        /* ganzen Namen */
          symbol[i]=0;          /* auf Null setzen */
      i=0;
      do
          Fread(fd1,1L,&symbol[i]); /* Buchstabe lesen */
      while(symbol[i++]!=0);        /* bis Nullbyte kommt */

      Fwrite(fd2,4L,&langnull); /* Vier Nullen schreiben */
      if (byte1!=5)             /* wenn es ein Baum ist */
          byte2=(char)wort1;    /* Nummer des Baums, bei RCS1.x Byte */
      else
          byte2=0;              /* Andernfalls auf Null setzen */
      Fwrite(fd2,1L,&byte2);    /* schreiben */
      byte2=(char)wort2;        /* Objektnummer, bei RCS1.x Byte */
      Fwrite(fd2,1L,&byte2);    /* schreiben */
      byte2=(byte1==5);         /* Typ(HRD) =5 entspricht Objekt=1 */
      Fwrite(fd2,1L,&byte2);    /* schreiben */
      Fwrite(fd2,1L,&def_typ[byte1]); /* umkodierten Typ schreiben */
      Fwrite(fd2,8L,symbol);    /* Name schreiben */   
      no_recs++;
   }
   Fseek(0L,fd2,0);          /* wieder an den Anfangs setzen */
   Fwrite(fd2,2L,&no_recs);  /* Anzahl der Records schreiben */

   Fclose(fd1);                       /* DEF-Datei schlieûen */
   Fclose(fd2);                       /* HRD-Datei schlieûen */
   return(0);
}

int do_file(fpath,fname,srch,fpn)
char *fpath,*fname,*srch,*fpn;
{
   char tpath[64];                      /* temporary path */
   char tname[64];                      /* temporary name */
   int i;
   int key;

   strcpy(tpath,fpath);                 /* alten Pfad retten */
   strcpy(tname,fname);                 /* alten Dateinamen retten */
   if(fpath[0] == '\0')                 /* wenn kein Pfad vorhanden */
      {                                 /* aktuellen Pfad erstellen */
      fpath[0] = Dgetdrv() + 'A';       /* Laufwerksbezeichnung holen */
      strcpy(&fpath[1],":");            /* Doppelpunkt anhÑngen */ 
      Dgetpath(fpn,Dgetdrv());          /* Pfad holen */
      strcat(fpath,fpn);                /* Pfad anhÑngen */
      strcat(fpath,"\\");               /* Backslash anhÑngen */
      }
   strcat(fpath,srch);                  /* Suchpfad anhÑngen */
   fsel_input(fpath,fname,&key);        /* Fileselektorbox aufrufen */
   if(key == 1)                         /* OK gedrÅckt */
      {                                 /* Pfad und Namen zusammenkopieren */
      i = strlen(fpath);                /* Ende des Gesamtpfades */
      while(fpath[i] != 0x5c)           /* RÅcksuchen bis Backslash */
          i--;                          /* also Anfang des Suchpfades */
      fpath[++i] = '\0';                /* abschneiden */
      strcpy(fpn,fpath);                /* Pfad kopieren */
      strcat(fpn,fname);                /* Namen anhÑngen */
      }
   else
      {
      strcpy(fpath,tpath);              /* Pfad wieder zurÅckkopieren */
      strcpy(fname,tname);              /* Namen zurÅckkopieren */
      strcpy(fpn,"\0");                 /* Gesamtpfad auf Null setzen */
      }
   return(key);                         /* Taste zurÅckgeben */
}
