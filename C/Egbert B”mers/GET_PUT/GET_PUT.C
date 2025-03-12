/****************************************************/
/*                     GET_PUT.C                    */
/* Ein lauffÑhiges Programm das 2 Graphikroutinen   */
/* vorstellt die den C-Programmierern die Gfa-BASIC */
/* Graphikbefehle GET, PUT, SGET und SPUT zur       */
/* VerfÅgung stellt.      LÑuft in jeder Auflîsung. */
/*               Compiler: TURBO C                  */
/* Autor: Egbert Bîmers, Amsterdam.        Mai 1989 */
/****************************************************/

#include <aes.h>             /* diese erste drei    */
#include <vdi.h>             /* bitte               */      
#include <stdlib.h>          /* immer einbinden     */
#include <string.h>
#include <stdio.h>
 
typedef struct               /* eine  Struktur  -   */
{                            /* hierin werden       */
    int breite;              /* abgelegt:die Breite,*/
    int hoehe;               /* Hîhe d.einzulesenen */                    
    char *getbuf;            /* Rechtecks und seine */  
} IMAGE;                     /* Adresse im Speicher.*/
                     /* immer bevor Funktionsproto- */
                             /* typen zu definieren.*/
                      
/* ------------------------------------------------ */
/*           Funktionsprototypen                    */
/* ------------------------------------------------ */
int open_vwork(void);      /* Arbeitsstation îffnen */
void close_vwork(void);    /* und schlieûen         */
void graphik(void);        /* nur Demozwecke        */
void MFDB_init(void);            
void get_image(int ,int ,int ,int ,IMAGE * );    
void put_image(int ,int ,IMAGE * ,int );         
/* ------------------------------------------------ */
/*          Globale Variablen GEM                   */
/* ------------------------------------------------ */

int contrl[12],intin[128],intout[128],ptsin[128],
    ptsout[128];

int work_in[12],work_out[57];
int handle,gl_apid;
int gl_hchar,gl_wchar,gl_hbox,gl_wbox;

/* ------------------------------------------------ */
/* Globale Variablen fÅr "get_image" u. "put_image" */
/* -------------------------------------------------*/

MFDB schirm,getbuf;                  /* siehe Text. */
                             
IMAGE *bild,*torte,*desktop;        /* IMAGE-zeiger */

int Hires,Medres,Lowres;   /* Auflîsungsvariabelen. */
int pixhoehe;              /* Hîhe des Ausschnitts  */
int schirm_vertik;         /* Vertik.Aufl.Bildschirm*/                                  
int pxyar[8];                /* fÅr Koordinaten.    */
int mode;                    /* fÅr log.VerknÅpfung:*/
                /* Die meist gebrauchte sind:       */ 
                /* S_ONLY     3  Åberschreiben      */
                /* S_XOR_D    6  Grapm.3 Gfa-BASIC  */
                /* S_OR_D     7  transparent        */          
                /* NOTS_OR_D 13  invers transparent */

#define TRUE        1
#define FALSE       0

/****************************************************/

void main()
{
  if(open_vwork() == TRUE) {                      
    #define max_breite  (640-Lowres*320)-lastw+1
    int x0,y0,x1,y1;
    int mousex,mousey,lastw,lasth,button,dum;
	int x,y;
	char *meldung[] = {
    "[0][ |  Desktop eingelesen.     |][ Ahh ]",
    "[0][ |  Torte auch...   |][ Hmm ]", 
    "[0][                  ][Ende|Weiter]",
    "[0][|  GrÅûe aus ...   |][ Amsterdam ]"             
    }; 
    /* fÅr jede IMAGE-Struktur Platz reservieren    */            
    bild = (IMAGE *) malloc(sizeof(IMAGE));       
    torte = (IMAGE *) malloc(sizeof(IMAGE));      
    desktop = (IMAGE *) malloc(sizeof(IMAGE));   

    MFDB_init();              /* MFDB-Struktur init.*/
    graf_mouse(M_OFF,0x0L);            /* Maus raus.*/
    x = 639-Lowres*320;                /* Nur fÅr   */
    y = 399-Lowres*200-Medres*200;     /* Demozwecke*/

    get_image(0,0,x,y,desktop); /* Desktop einlesen */
    form_alert(1 , meldung[0]);  
    graphik();            /* Demographik darstellen */
    get_image(0,0,x,y,torte);     /* Torte  einlesen*/
    form_alert(1 , meldung[1]);
    graf_mouse(THIN_CROSS,0);         /* Fadenkreuz */
    graf_mouse(M_ON,0);
 
    while(TRUE) {  
                                      /* Mausknopf? */          
       vq_mouse(handle,&button,&mousex,&mousey);      
       if( button == 1 ) {          
         dum = lastw = lasth = 0;
         evnt_timer(300,0);              /* bremsen */
          /*   Rechteck zeichnen mit  'Gummibox'    */
         graf_rubberbox(mousex,mousey,dum,dum,
                                    &lastw,&lasth); 
                                    
          /*     dies sind die Koordinaten...       */
         x0 = mousex; y0 = mousey; x1 = x0+lastw-1;
         y1 = y0+lasth-1;
         graf_mouse(M_OFF,0x0L);
         evnt_timer(300,0);
                               /* Bild abspeicheren */ 
         get_image(x0,y0,x1,y1,bild);          
                                /* Desktop 'PUT'ten */
         put_image(0,0,desktop,S_ONLY);        

         if( bild ->getbuf >0)  {   /* kein Fehler? */
            y = 12+Hires*7;       
            for(x=0; x<max_breite; x += lastw)      
              put_image(x,y,bild,S_ONLY);  

            free(bild -> getbuf);  /* Speicherplatz */
         }                       /* wieder freigeben*/

         button =0;
         graf_mouse(M_ON,0x0L);

         if( form_alert(1 , meldung[2]) == 1)
         break;               /* Ende: aus Schleife */

         graf_mouse(M_OFF,0);
         put_image(0,0,torte,S_ONLY);
         graf_mouse(M_ON,0);
         graf_mouse(THIN_CROSS,0);
       }           /* if */          
    }             /* while */                
      
   free(torte -> getbuf);      /* alle reserv.Platz */
   free(desktop -> getbuf);    /* wieder freigeben  */
   form_alert(1 , meldung[3]);
   close_vwork();
  }
  else
    printf("Fehler bei der Programminitialisierung");
  exit(0);
}

/* ------------------------------------------------ */
/*               open_vwork()                       */
/*          Arbeitsstation îffnen                   */
/* ------------------------------------------------ */

int open_vwork()
{
   register int i;
            /* anmelden bei AES */
   if((gl_apid = appl_init()) != -1)  {        
  
      for(i = 1; i < 10; work_in[i++] = 0);
      work_in[10] = 2;
      handle = graf_handle(&gl_wchar,&gl_hchar,
                                 &gl_wbox,&gl_hbox);
      work_in[0] = handle;           
      v_opnvwk(work_in, &handle, work_out);        
      return(TRUE);                /* hat geklappt  */
   }
   else
      return(FALSE);               /* oder nicht    */
}

/* ------------------------------------------------ */
/*               close_vwork()                      */
/*        Arbeitsstation wieder schlieûen           */
/* ------------------------------------------------ */

void close_vwork()

{
   v_clsvwk(handle);           /* Station schlieûen */
   appl_exit();                /* abmelden bei AES  */
}

/* ------------------------------------------------ */
/*             void graphik(void)                   */
/*  Routine die eine Torte auf dem Schirm darstellt */
/* ------------------------------------------------ */

void graphik(void)
{   
    int i, farbe;
    /* AuflîsungsabhÑng. Korrekturvariabelen f. Demo*/
    int x_korr = Lowres*320;    
    int y_korr = (Lowres || Medres)*200;     
    int x           = (640-x_korr)/2; /* Mittelpunkt*/
    int y           = (400-y_korr)/2; /* d.Schirmes */
    int radius      = 170-85*Lowres;
    vswr_mode(handle, MD_REPLACE);    /* Åberschreib*/
    vsf_color(handle, BLACK);         /* FÅllfarbe  */
    vsf_interior(handle, 3);          /* FÅlltyp    */

    for(i=0, farbe=1; i<3600; i += 450, farbe ++) {
    vsf_style(handle, (i+450)/450);
    if(Lowres | Medres)  {            /* Farbbetrieb*/
      if((farbe % 4) ==0)             /* farbe MOD 4*/
        farbe = 1;
      vsf_color(handle, farbe);       /* FÅllfarbe  */
    }
    v_pie(handle, x, y, radius, i, i+400); /*Torte! */
    }
    vst_color(handle, BLACK);
    vswr_mode(handle, MD_TRANS);          
    if(Hires)
      y = 390;
    else
      y = 190;
    v_gtext(handle, x-135, y,
           "Bitte zeichnen Sie eine <Rubberbox>");
}

/****************************************************/
/*                  MFDB_init-routine               */
/* lÑût die MFDB-Struktur 'schirm' automatisch      */
/* AuflîsungsabhÑngig ausfÅllen weil der Adresse-   */
/* Mitglied gleich 0 ist. In der Struktur 'getbuf'  */
/* (Puffer fÅr GET) kann nun nur die Anzahl der Bit-*/
/* Ebenen geschrieben werden. Diese Routine bitte   */
/* aufrufen bevor "get_image" oder "put_image".     */
/****************************************************/
 
void MFDB_init()
{                               
 schirm.fd_addr =  0;    /* Startadresse des Bild-  */
                         /* schirms. (= Flag)       */                   

 schirm_vertik  = work_out[1];      /* y-Auflîsung  */

    /* Information Åber Anzahl der Bit-Ebenen ( =   */
    /* Anzahl Bits pro Pixel(farbe)) wird bei VDI   */
    /* eingeholt. Die >>erweiterte<< Information    */
    /* wird nach Aufruf der Funktion 'vq_extend'    */
    /* in work_out[4] geschrieben.                  */ 

 vq_extnd(handle, 1, work_out);
 getbuf.fd_nplanes = schirm.fd_nplanes = work_out[4];   

 /* Die aktuele Auflîsung lÑût sich so herleiten*/    
  switch(work_out[4]) {
    case 4: Lowres = TRUE; break;
    case 2: Medres = TRUE; break;
    case 1: Hires = TRUE; 
  }             
}

/****************************************************/
/*             get_image - Routine                  */
/* Diese Routine liest ein Bildschirmrechteck ein   */
/* in einen Speicherbereich der via "malloc" belegt */
/* wird. Die Routine braucht als Parameter die Eck- */
/* punkte des Quellrechtecks und einen Zeiger auf   */
/*               eine IMAGE-Struktur.               */
/****************************************************/

void get_image(int x0,int y0,int x1,int y1,
                                    IMAGE *g_image)

{  
  char *memory;               /* Zeiger fÅr "malloc"*/
  int anzahl_byte,pixbreite,pix;
                            /* Anzahl Pixel pro Byte*/
  pix = 8 / schirm.fd_nplanes;    
  graf_mouse(256,0x0L);                /* Maus aus  */

  pixbreite=((x1-x0)+16) & 0xFFF0; /* d. 16 teilbar */
  pixhoehe = y1-y0;        /* Pixelhîhe d.Rechtecks */
  
  if(pixbreite <=0  || pixhoehe <=0) 
    g_image ->getbuf = 0;     /* keine Bomben bitte */
  else {
    /* Bildschirmkoordinaten (= Quelle) und         */
    pxyar[0]=x0; pxyar[1]=y0; pxyar[2]=x1;
    pxyar[3]=y1;
    /* Zieleckpunkte (linksoben anfangen) eintragen */
    pxyar[4]=0; pxyar[5]=0; pxyar[6]=x1-x0;
    pxyar[7]=pixhoehe;

    /* Anzahl Bytes des Rechtecks ausrechnen        */
    anzahl_byte=(pixbreite / pix)*(pixhoehe + 1) + 8;   

    
    /*          RAM-Platz reservieren               */   
    memory = malloc(anzahl_byte*sizeof(char)); 
  
    if ( memory > 0 ) {   /* falls noch Platz gibt..*/

     g_image ->breite = x1-x0;  /* Breite in IMAGE  */ 
     g_image ->hoehe = pixhoehe;  /* eintragen,Hîhe */ 
     g_image ->getbuf = memory;   /* u. die Adresse */
                                  /*    des Bereichs*/  

     getbuf.fd_w = pixbreite;   /* Gleiche f. MFDB- */                 
     getbuf.fd_h = pixhoehe+1;  /*Struktur die Ziel-*/
     getbuf.fd_addr = memory;   /*raster beschreibt.*/    
     getbuf.fd_wdwidth = pixbreite/16;      
                      /* Rasterbreite in Worte dazu */

     /* die VDI-Pixelkopierroutine aufrufen:        */
     /*                   von: Schirm  nach: Puffer */  
     vro_cpyfm(handle, 3, pxyar, &schirm, &getbuf); 
    }
    else {            /* falls kein Platz mehr frei */ 
       form_alert(1,
           "[0][| Nicht genÅgend Speicher...|][OK]");
       g_image ->getbuf = 0;              /* Flag ! */
    }               /* else */
  }                 /* if */

  graf_mouse(257,0x0L);                  /* Maus an */
}

/****************************************************/
/*              put_image - Routine                 */
/* Schreibt das eingelesene Rechteck an beliebiger  */
/* Stelle wieder auf dem Bildschirm. Die Routine    */
/* braucht als Parameter die linken oberen Ecke des */         
/* Zielrechtecks, einen Zeiger auf eine IMAGE-Struk-*/
/* tur, und den Modus fÅr die logische VerknÅpfung  */
/*            des Quell- und Zielrasters.           */
/****************************************************/
   
void put_image(int x0,int y0,IMAGE *p_image,int mode)

{
  if((p_image ->getbuf >0) &&           /* kein Flag*/
     (y0 +pixhoehe <= schirm_vertik))   /* Clipping */  
   {
   graf_mouse(256,0x0L);   
             /* Array ausfÅllen */
   pxyar[0]=0;                 /* Quelle ist Puffer */
   pxyar[1]=0;               
   pxyar[2]= p_image ->breite;    /* Breite u.Hîhe  */  
   pxyar[3]= p_image ->hoehe;     /* in IMAGE-      */                                    
                                  /* Struktur lesen;*/
   pxyar[4]=x0;                /* Das Ziel liegt nun*/
   pxyar[5]=y0;                /* auf dem Schirm.   */ 
   pxyar[6]=x0+pxyar[2];       /* Hat gleiche Breite*/
   pxyar[7]=y0+pxyar[3];       /* und Hîhe.         */

   /* MFDB-Struktur, die jetzt Quelle des Kopier-   */
   /* verfahrens ist, ausfÅllen. Erster Mitglied:   */
   /* Zeiger auf Adresse des abgespeicht. Rechtecks */                 
   getbuf.fd_addr = p_image -> getbuf; 
   getbuf.fd_w = pxyar[2]+16;        /* dann Breite */  
   getbuf.fd_h = pxyar[3]+1;         /* und Hîhe.   */          
   getbuf.fd_wdwidth = getbuf.fd_w/16;  /*Breite in */
                                        /* Worte.   */
   /* die Pixelkopierroutine aufrufen: 
                      von: Puffer  nach: Schirm     */  
   vro_cpyfm(handle, mode, pxyar, &getbuf, &schirm); 

   graf_mouse(257,0x0L);                 /* Maus an */
  }
}

/****************************************************/
