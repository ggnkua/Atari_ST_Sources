/*************************************************************
 
   Programm    :  DirBaum
   Version     :  1.0
   by LANTEC ComPro / R.Lanfermann
   (c) 1992 MAXON Computer
   -----------------------------------------------------
   Was tut es  :  Nicht-rekursives Durchsuchen des
                  Directorys
   -----------------------------------------------------
   Sprache     :  LASER C von Megamax
   
**************************************************************/               

#include<osbind.h>      

/*
 Dimensionen der Arrays vordefinieren. Bei umfangreicheren
 Dir's wird MAX_ANZ auf einen hîheren Wert festgelegt.
*/
  
#define MAX_ANZ 300     
#define SUCHOK  1       /* Knoten getestet            */
#define SUCHNOT 0       /* Knoten noch nicht getestet */

#define VERZEI  16      /* Attributmaske fÅr Ordner       */
#define ALLES   255     /* Attributmaske fÅr alle Dateien */

/* Strukur fÅr Fsfirst/Fsnext */

typedef struct _dda{
       char dda_gem[21];      /* reserviert fÅr GEM    */ 
       char dda_att;          /* Attribute der Dateien */          
       unsigned dda_time;     /* Erstellungszeit       */         
       unsigned dda_date;     /* Erstellungsdatum      */         
       long dda_size;         /* DateilÑnge            */        
       char dda_name[14];     /* Dateiname             */
       } DDA; 

/* 
   Zwischenstruktur fÅr die Verzeichnisstruktur
*/ 


typedef struct _zwi {
   char z_name[14];     /* Name des Ordners                   */
   int  z_vater;        /* Nummer des 'Vaters'                */
   int  z_tflag;        /* Testflag 1=Baum auf Sîhne getestet */
   }ZWI;
   
ZWI   _zwischen[MAX_ANZ];           
char  ord_pfade[MAX_ANZ][255];      

char such_str[255];              /* Suchstring             */
int  index_arr[MAX_ANZ];         /* Array der Verkettungen */

int dir_ebene;    /* Untersuchte Ebene                                */
char laufwerk;    /* drive als Char 'C'                               */
int frei_baum;    /* freier Baumeintrag                               */
int testflag;     /* Ist tst!= 0 dann ist alles geprÅft               */
int vater_ord;    /* Index fÅr 'vater-ordner'                         */
int kind_ord;     /* Index des nÑchsten Pfades der zu untersuchen ist */
int anzal_ord;    /* Anzahl der gefundenen Ordnerpfade                */


int aktdrv;       /* Nummer des Laufwerkes */
 
main()   
   {
   puts("Dateien auf welchem Laufwerk ? 0=a 1=b ...");
   scanf("%d",&aktdrv );
   laufwerk = aktdrv+'A';
   printf("Liste der Dateien von Drive %c\n",laufwerk);
   phase_1();
   gemdos(7);
   }


phase_1()
   {
   phase_2();  
   phase_3();
   }

         
phase_2() 
   {
   initialisiere();  /* Initialisierung der Strukturen         */
         
   dir_ebene =0;     /* Aktuelle Ebene ist Wurzelverzeichnis   */
   frei_baum =0;     /* Erster freier Eintrag ist Position 0   */
   vater_ord =0;     /* Es gibt kein Åbergeordnetes Verzeichn. */
   
   /* 
   Die Ordner der ersten Ebene finden. Im Beisp. werden dann die
   Ordner TEXTV und GRAPHIK gefunden werden.
   */
   
   strcpy( such_str, "A:\\*.*");
   strcpy( _zwischen[0].z_name , "A:" );
   _zwischen[0].z_name[0] = laufwerk;
   such_str[0] = laufwerk;
   
   get_directory(1);    
   
   /* Diesen Pfad z.B. A:\*.* als durchsucht gkennzeichnen */
   
   _zwischen[0].z_tflag = SUCHOK;
   
   /* NÑchsten freien Baumplatz suchen */
   
   frei_baum = get_frei_baum();

   kind_ord = 1;
   
   /* Solange weitersuchen, bis alles geprÅft wurde,
      das ist dann der Fall, wenn tst != 0 ist */
      
   do {
      /* Suchstring zusammensetzen */
      get_such_string( kind_ord );

      /* Freien Platz im Zwischenarray finden */
      frei_baum=get_frei_baum();       

      /* Knoten als getestet markieren */
      _zwischen[vater_ord].z_tflag = SUCHOK;
      
      /* Suche wird fortgesetzt */
      get_directory(frei_baum);     
      
      /* PrÅfung, ob alle Ordner gefunden wurden */
      get_test_erg();            
      
      /* NÑchste Ebene beginnen */
      get_kind_ord();            
      
      }while(testflag==0);       /* und weitermachen */
      
   }  


/***********************************
 * Hier wird nach weiteren Ordnern *
 * innerhalb eines Ordners gesucht *
 ***********************************/

get_directory( i )
int i;
   {
   DDA new_dta;
   Fsetdta( &new_dta );

   strcpy( ord_pfade[anzal_ord], such_str ); /* Diesen Ordner gibt es */
   anzal_ord++;                              /* also merken           */
   
   if( !Fsfirst( such_str, ALLES ) )         /* Ist in der Ebene noch was ? */
   do{
      if ( (new_dta.dda_att==VERZEI)&&(new_dta.dda_name[0]!='.') )   /* Ja */
         {
         strcpy( _zwischen[i].z_name , new_dta.dda_name );  /* EinfÅgen */
         _zwischen[i].z_vater = vater_ord;                  /* Und merken, wer der */
         i++;                                               /* Vater ist */
         }
      }
   while(!Fsnext());
   }
   
/*********************
 * Initialisiert die *
 * Baumstruktur      *
 *********************/ 
   
initialisiere()
   {
   register int i;
   for( i=0;i<MAX_ANZ;i++)
      {
      _zwischen[i].z_vater = -1;       /* Alle sind noch Waisen und */
      _zwischen[i].z_tflag = SUCHNOT;  /* noch nicht geprÅft    */
      ord_pfade[i][0] = '\0';          /* Strings werden gelîscht */
      }
   anzal_ord=0;  /* Es ist noch kein Ordner gefunden */
   }  
   
/************************
 * Suchet einen freien  *  
 * einen freien Eintrag *
 * und findet ihn       *
 ************************/
   
int get_frei_baum()
   {
   register int i;
   
   for(i=1;i<MAX_ANZ;i++)
      if( _zwischen[i].z_vater == -1 )  /* ist es noch ein Waise, dann */
         return i;                      /* ist der Platz noch frei     */
         
   terminate();  /* Abbruch bei Platzmangel */
   }     
   
   
/****************************
 * MÅssen wir noch suchen ? * 
 ****************************/
   
get_test_erg()
   {
   register int i;
   
   if ( dir_ebene < 0 )
      {
      testflag=1;
      return;
      }
      
   for(i=1;i<MAX_ANZ;i++)
      if ( _zwischen[i].z_tflag == SUCHNOT )  /* Da ist noch ein ungeprÅfter */
         {
         testflag=0;          /* also such gefÑlligst weiter */
         return;
         }
   testflag=1;    /* Super, alles schon untersucht */
   }        
   
/***********************
 * Der NÑchste bitte.  *
 ***********************/
   
get_kind_ord()
   {
   register int i;

   for(i=0;i<MAX_ANZ;i++)
      {
      if ( _zwischen[i].z_vater == dir_ebene && _zwischen[i].z_tflag == SUCHNOT )
         { 
         kind_ord=i;    /* Alle noch gleiche Ebene */
         return ;       /* Aber noch nicht untersucht. Dann mal los */
         }
      }  
      
   find_next_eben();  /* Alle Objekte eine Ebene untersucht, dann */
               /* eben die nÑchste Ebene anfangen */
   kind_ord=0;
   }     

/***************************
 * Welchen Pfad haben wir  *
 * denn nun zu testen      *
 ***************************/

get_such_string(i)
register int i;
   {
   register int j;

   /* Ebene 0 ist das Rootverzeichnis also z.b. C: 
      daher fÅgen wir \\ und den ersten Ordner und ein
      \\*.* an. ---> C:\\LASER\\*.*
   */   

   if ( dir_ebene == 0 )  
      {
      strcpy( such_str, _zwischen[0].z_name);
      strcat( such_str, "\\");
      strcat( such_str, _zwischen[i].z_name );
      strcat( such_str, "\\*.*");
      vater_ord=i;
      }
   else
   
   /* Die Hirarchie ist etwas verzwickter geworden
      die Folge der Ordner muû erst mal gefunden werden.
      das passiert in getfolge.
      Nach und nach wird dann der Pfad aufgebaut.
   */
      {
      get_ord_folge();        /* Verkettung ermitteln */
      strcpy( such_str, _zwischen[0].z_name);
      j=1;
      
      /* Nun werden alle Kinder,Enkel,Urenkel,Ururenkel....
         des Vaters angefÅgt */
      
      while( index_arr[j] != -1 ) 
         {
         strcat( such_str, "\\");
         strcat( such_str, _zwischen[(index_arr[j])].z_name);
         j++;
         }
      strcat(such_str,"\\*.*");
      }
         
   }
   

/**********************
 * Wer ist der letzte *
 * Ableger des Vaters *
 **********************/   
   
such_vater()
   {
   register int i;
   for(i=0;i<MAX_ANZ;i++)
      if ( _zwischen[i].z_vater==dir_ebene && _zwischen[i].z_tflag==SUCHNOT )
         return i;
   return -1;
   }           


/*************************
 * Finden wir die folge- *
 * generation.           *
 *************************/
 
find_next_eben()
   {
   register int i;
   
   /*
      Ist der Vater nicht mehr in der aktuellen Ebene zu
      finden, dann haben wir die Folgegeneration schon
      gefunden. Gibt es keine Nachkommen mehr, dann ist
      die Ebene eben -1.
   */
      
   for(i=1;i<MAX_ANZ;i++)
      if( _zwischen[i].z_vater>dir_ebene )   
         {
         dir_ebene=_zwischen[i].z_vater;
         return;
         }
   dir_ebene=-1;
   }     
         

/*******************************
 * Stammbaum des zu prÅfenden  *
 * Kindes ermitteln            *
 *******************************/
         
get_ord_folge()
   {
   register int i,woher;
   
   /* Erst mal alles lîschen */
   
   for( i=0;i<MAX_ANZ;i++)
      index_arr[i]=-1;
   
   i=0;  
   woher=such_vater();     /* Wer ist denn das Kind ? */
   index_arr[i]= woher;    /* Aha, merken */
   vater_ord=woher;         /* Das Kind wird nun Vater */
   i++;
   
   /* 
      Hier verfolgen wir die Linie vom Kind aus
      bis zum Vater zurÅck. Sobald der Vater das
      Rootdir. ist, sind wir fertig.
   */ 
   
   while( woher > 0 )
      {
      index_arr[i]=_zwischen[woher].z_vater;
      woher=index_arr[i];
      i++;
      }
   
   /*
      Wir brauchen aber die Kette vom Vater bis zum Kinde, und
      nicht die Kette vom Kind zum Vater, daher wenden wir die
      Folge.
   */    
      
   dreh_folge();
   }
   
/********************
 * Stammbaum drehen *   
 * warum ? s.o.     *
 ********************/
   
dreh_folge()
   {
   int zfolg[MAX_ANZ];
   
   register int i,oft;
   
   for( i=0;i<MAX_ANZ;i++)
      zfolg[i]=-1;
   
   i=0;  
   while( index_arr[i] >= 0 )   /* Die alte Folge mal kopieren */
      {
      zfolg[i]=index_arr[i];
      i++;
      }
   oft=i;            /* Aha, soviele Objekte sind es */
   oft--;
   i=0;
   while ( oft >= 0 )
      {
      index_arr[oft]=zfolg[i];  /* Dann drehen */
      oft--;
      i++;
      }
   }
   
   
   
phase_3()
   {
   int i,z;
   long addi;

   if ( anzal_ord>=1 )
      anzal_ord--;

   for( i=0;i<anzal_ord;i++ )
      {
      strcpy(such_str,ord_pfade[i]);
      z=strlen(such_str);
      such_str[z-3]='\0';
      strcat( such_str , "*." );
      strcat( such_str , "*");
      get_files();
   }           
}
   
get_files()
   {
   DDA new_dta;

   Fsetdta(&new_dta);
   
   if(!Fsfirst(such_str,ALLES))
   do{
      if ( (new_dta.dda_name[0]!='.')&&(new_dta.dda_att != VERZEI ))
         {
         printf("Gefunden %s\n",(new_dta.dda_name));
         }
      }
   while(!Fsnext());
   }  


/*****************************
 * Der Platz reich nicht aus *
 * daher Abbruch             *
 *****************************/
 
terminate()
   {
   puts("Der Speicherplatz reicht leider nicht mehr");
   gemdos(7);
   Pterm0();
   } 
