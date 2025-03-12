/************************************************
  
   Programm Bildverbieger
   
   entwickelt von Thomas Schweitzer Oktober '90
   mit Turbo C 2.0
   
   Copyright by Maxon Computer GmbH
   
************************************************/

#include <tos.h>                                 
#include <stdio.h>
#include <stdlib.h>
#include <linea.h>
#include <ext.h>
#include <string.h>
#include <vdi.h>

#define duenn 0  /* Linienzeichenmodi */
#define dick  1
#define MAXPTS 2100 /* Max. LÑnge einer Linie */

#define BITMOVE 12 
        /* Genauigkeit der Intergerarithmetik */
        
#define ABS(x) (((x)<0) ? -(x) : (x))
#define max(x,y) (((x)<(y)) ? (y) : (x))

typedef enum 
 {FALSE,
  TRUE  }
boolean;

int line(int x1, int y1, int x2, int y2, 
         void (*action)(int,int,int),int mode);
void verform(int x0, int y0,
             int x1, int y1, int x2, int y2,
             int x3, int y3, int x4, int y4,
             int x5, int y5, int x6, int y6);
           
void list1(int x,int y, int dummy);              
void list2(int x,int y, int dummy);

int  get_pix(int x,int y,void *logbase);
void plot ( int x, int y, int col);

void makelist(int len, int x, 
              int y0, int y1, int y2);

size_t BildLaden(void *base, char *Name);
void getSource(int *x1,int *y1,int *x2,int *y2);
void getDest  (int *x3,int *y3,int *x4,int *y4,
               int *x5,int *y5,int *x6,int *y6);

void mymain (void);
void close_vwork( void );
void *ZweiterSchirm (void);
boolean open_vwork( void );

int z,    /* PunktezÑhler in list1 und list2 */
    ylist[2][MAXPTS],
    xlist[2][MAXPTS];

char colors[MAXPTS];
     
int  PDBitmove;
    
void *GemScreen,
     *Original,  /* Bildschirmadressen */
     *Arbeit;

boolean transparent = TRUE;

void main( void )
{
   if ( open_vwork( ) == TRUE ) {
     mymain( );

     close_vwork( );
     exit ( 0 ); }
   else {
     fprintf(stderr,"Fehler bei der"
                    "Programminitialisierung!" );
      exit ( -1 );
   }
}

/************************************************

 boolean open_vwork( void )

 ôffnet die Arbeitsstation und initialisiert 
 dabei folgende Variablen

 int MAXX        Auflîsung in x-Richtung
 int MAXY        Auflîsung in y-Richtung
 int BytesZeile  Bytes pro Bildschirmzeile 
 int Planes      Anzahl der Farbebenen
 int Colors      Anzahl der Farben

 size_t PICLEN   BildlÑnge in Bytes
 size_t LPICLEN  BildlÑnge in Langworten
       
 int work_in[12]
 int work_out[57] VDI-Arbeitsfelder

 int handle      Bildschirmhandle
 int phys_handle Bildschirmhandle

 int gl_hchar    
     gl_wchar
     gl_hbox
     gl_wbox     Hîhe und Breite der Systemfonts
 int gl_apid     Applikationsnummer

 -> nix
 <- kein Fehler  TRUE
 <- Fehler       FALSE

************************************************/

int MAXX,MAXY,
    BytesZeile, /* Bytes pro Bildschirmzeile */
    Planes,     /* Anzahl der Farbebenen     */
    Colors;     /* Anzahl der Farben         */

size_t PICLEN,  /* BildlÑnge in Bytes        */
       LPICLEN; /* BildlÑnge in Langworten   */
       
int work_in[12],
    work_out[57];

int handle,
    phys_handle;

int gl_hchar,
    gl_wchar,
    gl_hbox,
    gl_wbox,
    gl_apid;

boolean open_vwork( void )
{
  register int i;

   if (( gl_apid = appl_init() ) != -1 )
   {
      for ( i = 1; i < 10; work_in[i++] = 1 );
      work_in[10] = 2;
      phys_handle = graf_handle( &gl_wchar, 
                 &gl_hchar, &gl_wbox, &gl_hbox );
      work_in[0]  = handle = phys_handle;

      v_opnvwk( work_in, &handle, work_out );
      
      MAXX   = work_out[0];
      MAXY   = work_out[1];
      Colors = work_out[13];
      
      i      = Colors;
      Planes = 0;
      while (i != 1) {
       i /= 2;
       Planes++;
      }
      
      linea_init();
      BytesZeile = Vdiesc->bytes_lin;
      PICLEN     = ((size_t) BytesZeile *
                    (size_t) (MAXY+1));
      LPICLEN    = PICLEN >> 2;
      return ( TRUE );
   }
   else
      return ( FALSE );
} /* open_vwork */

void close_vwork( void )
/************************************************

 Schlieûen der Arbeitsstation
 -> nix
 <- nix

************************************************/
{
   v_clsvwk( handle );

   appl_exit( );
}

void mymain(void)
{
  char Pfad[40]    = "E:\\*.DOO",
       Pfadneu[54] = "\0",
       Name[14]    = "\0",
       *ptr_to_backslash;

  int button,
      x1,y1, /* Startrechteck links oben   */
      x2,y2, /*      "        rechts unten */
      x3,y3, /* Zielviereck links oben     */
      x4,y4, /* Zielviereck rechts oben    */
      x5,y5, /* Zielviereck rechts unten   */
      x6,y6; /* Zielviereck links unten    */

  /* Jetzt geht's erst richtig los */
  GemScreen = Physbase();
  if ((Original = ZweiterSchirm()) == NULL 
    ||(Arbeit   = ZweiterSchirm()) == NULL)
     form_alert(1,"[3][Zu wenig Speicher!]"
                  "[Sch...ade]");
  else {   
    PDBitmove = 3-Getrez();
    /* Doodlebild selektieren */
    fsel_input( Pfad, Name, &button);
    if (button == 1) {  /* OK */
      strcpy(Pfadneu,Pfad);
      ptr_to_backslash = strrchr(Pfadneu, '\\');
      strcpy(++ptr_to_backslash,Name);
      printf("\nLade %s...",Pfadneu);
      if (BildLaden(Original,Pfadneu) != 0){
    /* Bild laden und bis Tastendruck anzeigen */
        Setscreen(Original,Original,-1);
        getch();
        Setscreen(GemScreen,GemScreen,-1);
          
        do {
          /* Quellblock und ... */
          getSource(&x1,&y1,&x2,&y2);
          /* ... Zielviereck eingeben */
          getDest  (&x3,&y3,&x4,&y4,&x5,&y5,
                    &x6,&y6);
          
          /* auf Arbeitschirm verformen und ...*/
          Setscreen(Arbeit,Arbeit,-1);
          v_clrwk(handle);
          verform(0,0,     /* hier geht's rund */
                  x1,y1,x2,y2,
                  x3,y3,x4,y4,x5,y5,x6,y6);
          getch(); /* ... auf Taste warten */
           Setscreen(GemScreen,GemScreen,-1);
           v_clrwk(handle);
           puts("\nESC -> Ich mag nicht mehr, "
                "obwohl's so schîn war.\n"
                "sonstwas -> Wow! War ja super "
                "Nochmal bitte."); }
         while (getch() != 27);}
        /* solange Bilder kaputtmachen bis ESC 
           gedrÅckt */
      else puts("\nKonnte Bild nicht laden.");
    }
  }
  return;
} /* mymain */

void getSource(int *x1,int *y1,int *x2,int *y2)
{
  v_clrwk( handle );
  puts("\nHallo User, gib mal das Startrechteck "
       "ein.");
  printf("\nLinke obere Ecke (x,y)  : ");
  scanf("%d,%d",x1,y1);
  printf("\nRechte untere Ecke (x,y): ");
  scanf("%d,%d",x2,y2);
} /* end getSosse */
  
void getDest  (int *x3,int *y3,int *x4,int *y4,
               int *x5,int *y5,int *x6,int *y6)
{
  v_clrwk( handle );
  puts("\n Und jetzt das Zielviereck...");
  printf("\nLinke obere Ecke (x,y)  : ");
  scanf("%d,%d",x3,y3);
  printf("\nRechte obere Ecke (x,y) : ");
  scanf("%d,%d",x4,y4);
  printf("\nRechte untere Ecke (x,y): ");
  scanf("%d,%d",x5,y5);
  printf("\nLinke untere Ecke (x,y) : ");
  scanf("%d,%d",x6,y6);
  printf("\n Vielen Dank, ich stÅrze jetzt ab.");
  getch();
} /* end getDest */

int line(int x1, int y1, int x2, int y2, 
         void (*action)(int,int,int),int mode)
/************************************************
 
 Linien mit dem Integer-Bresenham-Verfahren 
 zwischen den Punkte (x1,y1) und (x2,y2) zeichnen
 
 <action> ist eine dreistellige Funktion, die
 bei jedem zu zeichnenden Punkt aufgerufen wird.
 
 Bei mode = dick Åberlappen sich die Punkte an
 den Linienkanten, bei duenn logischerweise nicht

 Ergebnis: Anzahl der gesetzten Punkte.
  
************************************************/
{
  register int x,y;
 
  int dx,dy,
      xstep,ystep,
      abw, points;

  points = 1; /* LÑnge der Linie in Pixel */
  x = x1; y = y1; 
  xstep = ystep =1;
  
  dx = x2 - x1;
  
  if (dx == 0) xstep = 0;
  else if (dx < 0) {
    dx = -dx;
    xstep = -xstep;
  }
  
  dy = y2 - y1;
  
  if (dy == 0) ystep = 0;
  else if (dy < 0) {
    dy = -dy;
    ystep = -ystep;
  }

  abw = dx - dy;
  
  while ((x != x2) || (y != y2)) {
    points++;          /* schon wieder'n Punkt */
    (*action)(x,y,1);  /* jetzt gibt's ékschn  */
    if (abw >= 0) {
      x   += xstep;
      abw -= dy;
      if ((abw < 0) && mode) { /* mode == dick */
        points++;         /* öberlappende ..   */
        (*action)(x,y,1); /* ..Punkte setzen.  */  
      }
    }
    if (abw < 0) {
      y   += ystep;
      abw += dx;
    }
  } /* end while */
  (*action)(x,y,1);
  return points; /* der Kandidat erhÑlt 99 Gummi-
                    punkte */
} /* end line */

void verform(int x0, int y0, /* Offsets */
             int x1, int y1, int x2, int y2,
             /* Startrechteck */
             int x3, int y3, int x4, int y4,
             /* Zielviereck */
             int x5, int y5, int x6, int y6)
{
  int  pts_l1,pts_l2, /* LÑnge von Linie 1 u 2 */
       pos1,pos2,     /* KoordinatenzÑhler in  
                          Punktlisten */
       laengst,    /* LÑnge der lÑngsten Linie */
       oz;
  long step1,step2,/* Schrittweiten in den 
                      Punktlisten  * 2^BITMOVE */
       pos1g,pos2g,ozg,
       steporig;
  
  hide_mouse(); /* Schnell die Maus verstecken */   
  z = 0; pts_l1 = line(x3,y3,x4,y4,list1,duenn); 
  z = 0; pts_l2 = line(x6,y6,x5,y5,list2,duenn); 
                              
  laengst  = max(pts_l1,pts_l2);
  step1    = ((long) pts_l1 << BITMOVE) / 
             (long) laengst;
  step2    = ((long) pts_l2 << BITMOVE) / 
             (long) laengst;
  steporig = ((long) (ABS(x2-x1)+1) << BITMOVE) /
             (long) laengst;
  
  for (pos1 = pos2 = oz = 0,  
       ozg = pos1g = pos2g = 0L;
       (pos1 < pts_l1) && (pos2 < pts_l2) ; ){ 
   makelist(ABS(xlist[0][pos1]-xlist[1][pos2])+
            ABS(ylist[0][pos1]-ylist[1][pos2])+1,
            oz+x1+x0,y0,y1,y2);
    z = 0;
    line(xlist[0][pos1],ylist[0][pos1],
         xlist[1][pos2],ylist[1][pos2],
         plot,dick);
    pos1g += step1;
       /* genauer KoordinatenzÑhler */
    pos2g += step2;
    ozg   += steporig;
    pos1 = (int) (pos1g >> BITMOVE); 
       /* absoluter KoordinatenzÑhler */
    pos2 = (int) (pos2g >> BITMOVE);
    oz   = (int) (ozg >> BITMOVE);
    if (oz+x1+x0 > x2) {
      x0 = oz = 0;
      ozg = 0L;
    }
  }
  show_mouse(0); /* mit KÑse fÑngt man MÑuse */
} /* verform , war doch einfach, oder ? */

int get_pix(int x,int y,void *logbase)
/************************************************
 
 Ermittelt die Farbe des Punktes an (x,y) in dem
 Åber logbase referenzierten logischen Bildschirm
 Die Funktion arbeitet auflîsungsunabhÑngig.
 
 Ergebnis: Punktfarbe
 
************************************************/
{
  int i,
      res=0,
      dist = (Planes-1);
  int *adr;
  
  adr = (int *) ((char *) logbase + y *
         BytesZeile + ((x >> 4)<<PDBitmove));
  
  for ( i = 0; i < Planes; i++){
    res <<= 1;
    res += (*((int *)( adr + dist)) & 
             (1 << (15 - (x & 15))) ? 1 : 0);
    dist -= 1;
  }
  return res;
} /* end get_pix */

void plot ( int x, int y, int col)
/************************************************

 Setzt an (x,y) einen Punkt der Farbe colors[z],
 wenn
 - (x,y) innerhalb der Bildschirmgrenzen
 - transparent == TRUE und col != 0
 - transparent == FALSE (also deckend)
 - man ATARI-Fan ist.

 <col> ist hier nur ein Dummywert, der durch
 ein Element aus colors[] ersetzt wird.
 
 z und transparent sind global.
 
************************************************/
 
{
  int farbe = colors[z++];
  
  if (transparent) {
    if (farbe &&
        x>=0 && y>=0 && x<=MAXX && y<=MAXY) 
     put_pixel(x,y,farbe); }
  else
    if (x>=0 && y>=0 && x<=MAXX && y<=MAXY)
      put_pixel(x,y,farbe);
} /* end plot */

void list1(int x,int y, int dummy)
{
  xlist[0][z] = x; ylist[0][z++] = y;
} /* end (ganz schîn listig, nich' wahr?) */
 
void list2(int x,int y, int dummy)
{
  xlist[1][z] = x; ylist[1][z++] = y;
}
void makelist(int len,int x, int y0, int y1, 
              int y2)
/************************************************

 Abtasten einer Spalte (Koordinate x, zwischen y1
 und y2) im Quellbild und speichern der Farbwerte
 im <len>-grossen Feld colors, wobei nîtigenfalls
 gestreckt / gestaucht wird.
 
************************************************/
{
  int y,z;
  long stepy,yg;
  
  stepy = ((long) (ABS(y2-y1)+1L) << BITMOVE) / 
          (long) len;
  
  for (z = y = 0, yg = 0L; z<=len; z++) {
    colors[z] = (char) get_pix(x,y+y0+y1,
                               Original);
    yg += stepy;
    y = (int) (yg >> BITMOVE);
    if (y + y0 + y1 > y2) {y0 = y = 0;  yg = 0;}
  }
} /* end makelist */

void    *ZweiterSchirm (void)
/************************************************

 Adresse eines zweiten Bildschirms ermitteln und 
 einen PICLEN groûen Speicherbereich reservieren.

 -> nix
 <- Adresse des neuen Bildschirms bzw.
    NULL bei Fehler

************************************************/

{   
  void *base;
  
  if ((base = malloc( PICLEN+256 )) == NULL)
    return NULL;
  else return ((void *) ((((size_t) base ) +
                          256) & 0xffffff00L));
} /* end SonnenSchirm */

size_t BildLaden(void *base, char *Name)
{
/************************************************

 Laden des Bildes <Name> an die Adresse <base>.

  -> base  Basisadresse
  -> Name  Dateipfad und -name
  <- Fehler       0
  <- kein Fehler  DateilÑnge

************************************************/

  FILE *stream;
  size_t len;
  
  if ((stream = fopen(Name,"rb")) == NULL )
    return 0;
  else {
    len = filelength(fileno(stream)); 
    if (fread(base,1,len,stream) == len) {
      fclose(stream);
      return len;}
    else {
      fclose(stream);
      return 0;
    }
  }
} /* end BildGeschÑft */

/**** Das war's. Viel Spass noch damit!     ****/