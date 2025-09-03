#include <stdio.h>
#include <string.h>
#include <tos.h>
#include <aes.h>
#include <vdi.h>
#include "FONTEDIT.H"

/*----------------------------------------------------------
                      Variablentypen
----------------------------------------------------------*/                  
#define	    BYTE            unsigned char

/*----------------------------------------------------------
                  Konstanten / Macros
----------------------------------------------------------*/

#define	  FALSE 	0
#define   TRUE		!FALSE

#define   FONT_DAT  76 / 4              /* Nummer des Wortes im Fontheader
                                           das auf die Daten zeigt */
#define   GROSS     13                  /* Zeichensatz-Auswahl fÅr vst_heigt */ 
#define   MITTEL    6
#define   KLEIN     4
#define   CLEAR     77
#define   ALLES     99

#define   mouse_off graf_mouse(M_OFF,0L)           /* Maus ein- ausschalten */
#define   mouse_on  graf_mouse(M_ON,0L)


/*----------------------------------------------------------
           Definition der Assemblerroutinen
----------------------------------------------------------*/

extern   void   melde_font(void);
extern   long   *get_header(void);
           

/*----------------------------------------------------------
                  globale Variablen
----------------------------------------------------------*/

int  handle;                            /* Grafikhandle */

BYTE font_8_16[256*16];                 /* Fontdaten */
BYTE font_8_8[256*8];
BYTE font_6_6[192*6];
long head_8_16[22];                     /* Kopie der Fontheader im RAM */
long head_8_8[22];
long head_6_6[22];

long *zeig_header_6_6;                  /* Adr. des Zeigers auf den 6*6 Fontheader */

long *zeig_8_16;                        /* Adressen der Zeiger auf Fontdaten */
long *zeig_8_8;
long *zeig_6_6;  

BYTE *sys_8_16;                         /* Adressen der Systemfonts */
BYTE *sys_8_8;
BYTE *sys_6_6;

OBJECT *tree;                           /* Nummer des Hauptbaums */

int  anz_x,anz_y,ed_x,ed_y;             /* Koordinaten markanter Objekte */
int  show_x,show_y,asc_x,asc_y;

int  edit_it = 256;                     /* gerade editiertes Zeichen */

int  edit_flag = GROSS;                 /* Merker welcher Font editiert wird */
                                        /* Zwischenspeicher fÅr ein Zeichen */
int  rette[16] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
                                        /* MFDBs fÅr Copyraster */
MFDB mfdb_8_16  = {0,256*8,16,128,0,1,0,0,0};
MFDB mfdb_8_8   = {0,256*8,8,128,0,1,0,0,0};
MFDB mfdb_6_6   = {0,256*6,6,96,0,1,0,0,0};       
MFDB mfdb_rette = {0,16,16,1,0,1,0,0,0};
MFDB mfdb_bild  = {0,640,400,40,0,1,0,0,0};
                                               /* Mausform: Diskette */
MFORM  maus_disk = {0,0,1,0,1,                
                    0xFFFF,0xFFFF,0xFFFF,0xFFFF,
                    0xFFFF,0xFFFF,0xFFFF,0xFFFF,
                    0xFFFF,0xFFFF,0xFFFF,0xFFFF,
                    0xFFFF,0xFFFF,0xFFFF,0x7FFF,
                    0x0000,0x3FFC,0x500A,0x57CA,
                    0x500A,0x51CA,0x500A,0x5FFA,
                    0x4002,0x4002,0x4FF2,0x4B12,
                    0x4B12,0x2B12,0x1FFC,0x0000 };
                      
char name_8_16[13],name_8_8[13],name_6_6[13];   /* Namen der Fonts */
char path_name[100],akt_file[100];


/*##########################################################

                   Diverse  Hilfsprogramme
                          
##########################################################*/
/*----------------------------------------------------------
                   File auf Disk suchen
----------------------------------------------------------*/

int dfind(DTA *dtabuf,const char *fname,int attr)

{
	int ret_wert;
	DTA *old_dta;
	
	old_dta = Fgetdta();
	Fsetdta(dtabuf);
	
	ret_wert = (Fsfirst(fname,attr));
  Fsetdta(old_dta);

  return(ret_wert);
}   


/*----------------------------------------------------------
           Extension an Dateinamen hÑngen                   
----------------------------------------------------------*/

void strmfe(char *newname,const char *oldname,char *ext)

{
  char *pos;
  
	strcpy(newname,oldname);
  if ((pos = strrchr(newname,'.')) != NULL)  *pos = '\0';
  strcat(newname,".");
	strcat(newname,ext);
}			

/*----------------------------------------------------------
           Namen und Extension aus Pfad isolieren
----------------------------------------------------------*/

void strsfn(char *filename,char *node,char *ext)

{
	char	hilfsname[20],*pos;
	
	*ext = '\0'; *node = '\0';
	
	if ((pos = strrchr(filename,'\\')) == NULL) pos = filename - 1;
  pos++;
	strcpy(hilfsname,pos);
	if ((pos = strrchr(hilfsname,'.')) != NULL) 
	  {
	  	strcpy(ext,pos+1);
	  	*pos = '\0';
	  }
	strcpy(node,hilfsname);
}	 
	
/*----------------------------------------------------------
          Pfadnamen isolieren
----------------------------------------------------------*/

int stcgfp(char *path,const char *name)

{
	char	*pos;

	strcpy(path,name);

	if ((pos = strrchr(path,'\\')) != NULL)
	  *pos = '\0'; 
 	else
 	  *path = '\0';

 	return((int)strlen(path));
} 	

/*----------------------------------------------------------
            ZeichensÑtze ein- und ausschalten
----------------------------------------------------------*/


void on_8_16(void)
{
  *zeig_8_16 = (long)font_8_16;
  head_8_16[FONT_DAT] = (long)font_8_16;
  melde_font();
}

void on_8_8(void)
{
  *zeig_8_8 = (long)font_8_8;
  head_8_8[FONT_DAT] = (long)font_8_8;
  melde_font();
}

void on_6_6(void)
{
  *zeig_6_6 = (long)font_6_6;
  *zeig_header_6_6 = (long)head_6_6;
}

void off_8_16(void)
{
  *zeig_8_16 = (long)sys_8_16;
  head_8_16[FONT_DAT] = (long)sys_8_16;
  melde_font();
}

void off_8_8(void)
{
  *zeig_8_8 = (long)sys_8_8;
  head_8_8[FONT_DAT] = (long)sys_8_8;
  melde_font();
}

void off_6_6(void)
{  
  *zeig_6_6 = (long)sys_6_6;
  *zeig_header_6_6 = (long)head_6_6;
}

/*----------------------------------------------------------
      get_name(filename,name):

      liefert aus einem kompletten Filenamen (evt. mit Pfad)
      einen formatierten Filenamen mit Extension!

      Bsp.: C:\GEHT\DOCH.WAS    -> DOCH    .WAS
----------------------------------------------------------*/

void get_name(char *name,char *filename)

{
  char node[9],ext[4];

  strsfn(filename,node,ext);
  strcpy(name,node);
  while (strlen(name) < 8) strcat(name," ");
  strcat(name,".");
  strcat(name,ext);
  while (strlen(name) < 12) strcat(name," ");
}

/*----------------------------------------------------------
     show_edit:

     Hauptformular darstellen
----------------------------------------------------------*/

void show_edit(OBJECT *tree)

{
  int xpos,ypos,xwide,ywide;

  form_center(tree,&xpos,&ypos,&xwide,&ywide);
  form_dial(FMD_START,0,0,0,0,xpos,ypos,xwide,ywide);
  form_dial(FMD_GROW,20,15,40,20,xpos,ypos,xwide,ywide);
  objc_draw(tree,0,8,xpos,ypos,xwide,ywide);
}


/*----------------------------------------------------------
     close_edit:

     Hauptformular schliessen
----------------------------------------------------------*/

void close_edit(OBJECT *tree)

{
  int xpos,ypos,xwide,ywide;

  form_center(tree,&xpos,&ypos,&xwide,&ywide);
  form_dial(FMD_SHRINK,20,15,40,20,xpos,ypos,xwide,ywide);
  form_dial(FMD_FINISH,0,0,0,0,xpos,ypos,xwide,ywide);
}


/*----------------------------------------------------------
     show_alert:

     Alertbox darstellen
----------------------------------------------------------*/

int show_alert(int  index,int  button)

{
  OBJECT *string;
  
  graf_mouse(0,&maus_disk);

  rsrc_gaddr(R_STRING,index,&string);
  return (form_alert(button,(char *)string));
}


/*----------------------------------------------------------
     use_name(name):

     trÑgt den Fontnamen im Boxtext ein.
----------------------------------------------------------*/

void use_name(int  font)

{
  OBJECT *adr;
  char   *text;
  OBJECT *get_adr(long baum, int  obj);  

  adr  = get_adr((long)tree,FONTNAME);
  text = (char*)(((TEDINFO*)(adr->ob_spec.index))->te_ptext) + 6;
  switch (font)
    {
      case GROSS:  strcpy(text,name_8_16);
                   break;
      case MITTEL: strcpy(text,name_8_8);
                   break;
      case KLEIN:  strcpy(text,name_6_6);
                   break;
    }
}


/*----------------------------------------------------------
     get_adr(baum,obj):
    
     berechnet die Adresse eines Objektes
----------------------------------------------------------*/

OBJECT *get_adr(long baum,int  obj)

{
   return ((OBJECT*) (baum + 24 * obj));
}
 

/*----------------------------------------------------------
     get_status(baum,obj):

     bestimmt den Status eines Objektes
----------------------------------------------------------*/

unsigned short get_status(long baum,int  obj)

{
  OBJECT *adr;

  adr = get_adr(baum,obj);
  return ((*adr).ob_state);
}

/*----------------------------------------------------------
     edit_status(mode):

     Enabled oder disabled die Edit-Knîpfe
----------------------------------------------------------*/

void edit_status(int  mode)

{
  objc_change(tree,INVERS  ,0,0,0,640,400,mode | OUTLINED,1);
  objc_change(tree,ESPIEGEL,0,0,0,640,400,mode | OUTLINED,1);
  objc_change(tree,ASPIEGEL,0,0,0,640,400,mode | OUTLINED,1);
  objc_change(tree,CLR     ,0,0,0,640,400,mode | OUTLINED,1);
  objc_change(tree,FILL    ,0,0,0,640,400,mode | OUTLINED,1);
  objc_change(tree,LIGHT   ,0,0,0,640,400,mode | OUTLINED,1);
  objc_change(tree,HOCH    ,0,0,0,640,400,mode,1);
  objc_change(tree,LINKS   ,0,0,0,640,400,mode,1);
  objc_change(tree,RECHTS  ,0,0,0,640,400,mode,1);
  objc_change(tree,RUNTER  ,0,0,0,640,400,mode,1);
  objc_change(tree,OK      ,0,0,0,640,400,NORMAL,1);
  objc_change(tree,OK      ,0,0,0,640,400,mode,1);
  objc_change(tree,UNDO    ,0,0,0,640,400,NORMAL,1);
  objc_change(tree,UNDO    ,0,0,0,640,400,mode,1);

  if((mode == NORMAL) && (edit_flag != GROSS))
     objc_change(tree,DREHE,0,0,0,640,400,NORMAL | OUTLINED,1);
  else 
     objc_change(tree,DREHE,0,0,0,640,400,DISABLED | OUTLINED,1);

}


/*##########################################################
     Hier folgen die Routinen um die Zeichen der ver-
     schiedenen ZeichensÑtze auf dem Bildschim darzu-
     stellen.
##########################################################*/

/*----------------------------------------------------------
     print_char(asc,xpos,ypos,font):

     Zeichnet das ASCII-Zeichen 'asc' an der Stelle xpos, 
     ypos auf dem Bildschirm. Dabei bestimmt 'font' den zu
     benutzenden FONT.

     13 = 8*16, 6 = 8*8 , 4 = 6*6
----------------------------------------------------------*/

void print_char(int  asc,int  xpos,int  ypos,int  font)

{
  int  dummy;
  char text[2];

  vst_height(handle,font,&dummy,&dummy,&dummy,&dummy);
  
  switch (font)
  {
     case GROSS:  on_8_16();
                  ypos += 13;          /* alle Fonts mittig im 8*16 Feld */
                  break;               /* zentrieren                     */
     case MITTEL: on_8_8();
                  ypos += 11;
                  break;
     case KLEIN:  on_6_6();
                  ypos += 10;
                  xpos += 2;
  }


  text[0] = (char) asc;
  text[1] = (char) 0;
  v_gtext(handle,xpos,ypos,text);
  off_8_16(); off_8_8(); off_6_6();
} 


/*----------------------------------------------------------
     zeig_char(asc,font):

     Zeigt das ASCII-Zeichen 'asc' an der entsprechenden
     Stelle im Anzeige-Feld.
----------------------------------------------------------*/

void zeig_char(int  asc,int  font)

{
  print_char(asc,anz_x + (asc / 16) * 16,anz_y + (asc % 16) * 16,font);
}



/*----------------------------------------------------------
     zeig_an(font):
  
     Zeigt alle Zeichen eines Fonts im Anzeige Feld an.
----------------------------------------------------------*/

void zeig_an(int  font)

{
  int i,coords[4];

  mouse_off;                                 /* Anzeigefeld lîschen */
  coords[0] = anz_x;
  coords[1] = anz_y;
  coords[2] = anz_x + 16 * 16 - 9;
  coords[3] = anz_y + 16 * 16 - 1; 
  vsf_color(handle,0);                       /* FÅllfarbe weiss */                                    
  vr_recfl(handle,coords);

  for (i=0 ; i <= 255 ; zeig_char(i++,font));
  mouse_on; 
}

/*##########################################################
 
        Die folgenden Routinen bewerkstelligen die
        Anzeigen im Editfeld und dem kleinen Feld

##########################################################*/

/*----------------------------------------------------------
 
     show_raster(font):

     zeichnet das Editierraster ins Editfeld
----------------------------------------------------------*/

void show_raster(int  font)

{
  int coords[4],i;
  
  mouse_off;
  coords[0] = ed_x;                        /* Feld lîschen */
  coords[1] = ed_y;
  coords[2] = ed_x + 8*8;
  coords[3] = ed_y + 8*16;
  vsf_color(handle,0);                     /* FÅllfarbe weiss */ 
  vr_recfl(handle,coords);

  switch (font)
  {
    case GROSS:   for(i=0 ; i < 9 ; i++)
                    {
                      coords[0] = coords[2] = ed_x + 8 * i;
                      coords[1] = ed_y;
                      coords[3] = ed_y + 8 * 16;
                      v_pline(handle,2,coords);
                    }
                  for(i=0 ; i < 17 ; i++)
                    {
                      coords[1] = coords[3] = ed_y + 8 * i;
                      coords[0] = ed_x;
                      coords[2] = ed_x + 8 * 8;
                      v_pline(handle,2,coords);
                    }
                  break;

    case MITTEL:  for(i=0 ; i < 9 ; i++)
                    {
                      coords[0] = coords[2] = ed_x + 8 * i;
                      coords[1] = ed_y + 4 * 8;
                      coords[3] = ed_y + 12 * 8;
                      v_pline(handle,2,coords);
                    }
                  for(i=0 ; i < 9 ; i++)
                    {
                      coords[1] = coords[3] = ed_y + 8 * (i + 4);
                      coords[0] = ed_x;
                      coords[2] = ed_x + 8 * 8;
                      v_pline(handle,2,coords);
                    }
                  break;

    case KLEIN:   for(i=0 ; i < 7 ; i++)
                    {
                      coords[0] = coords[2] = ed_x + 8 * (i + 1);
                      coords[1] = ed_y +5 * 8;
                      coords[3] = ed_y + 11 * 8;
                      v_pline(handle,2,coords);
                    }
                  for(i=0 ; i < 7 ; i++)
                    {
                      coords[1] = coords[3] = ed_y + 8 * (i + 5);
                      coords[0] = ed_x + 8;
                      coords[2] = ed_x + 7 * 8;
                      v_pline(handle,2,coords);
                    }
                  break;
  }
  mouse_on;
}


/*----------------------------------------------------------
     point(x,y):

     testet ob der Punkt x,y im 'rette' Buffer gesetzt ist 
----------------------------------------------------------*/

int  point(int  x,int  y)

{
  return((int )(((rette[y] << x) & 0x8000) == 0x8000));
}

/*----------------------------------------------------------
     set(x,y):

     setzt (art = 1) oder lîscht (art = 0) ein Punkt im 
     'rette' Buffer
----------------------------------------------------------*/

void set(int  x,int  y,int  art)

{
  rette[y] = (art == 0) ? rette[y] & ~(0x8000 >> x) 
                        : rette[y] |  (0x8000 >> x);
}





/*----------------------------------------------------------
     platsch(x,y,art,font)
     
     setzt oder lîscht einen Punkt in der Vergrîsserung
     art = 1 setzen / art = 0 loeschen
----------------------------------------------------------*/

void platsch(int  x,int  y,int  art,int  font)

{
  int  coords[4];

  
  switch (font)                       /* Koordinaten korrigieren */
  {
    case MITTEL: y += 4;
                 break;
                 
    case KLEIN:  x++;
                 y += 5;
                 break;
  }
  
  vsf_color(handle,art);              /* setzen oder lîschen wÑhlen */
  
  coords[0] = (ed_x + 1) + 8 * x;     /* Koordinaten fÅr Rechteck */
  coords[1] = (ed_y + 1) + 8 * y;
  coords[2] = coords[0] + 6;
  coords[3] = coords[1] + 6;
  mouse_off;
  vr_recfl(handle,coords);
  mouse_on;
}  
   


/*----------------------------------------------------------
     paint(asc,font):
     
     Stellt ein ASCII-Zeichen in der Vergrîûerung da
----------------------------------------------------------*/

void paint(int  asc,int  font)

{
  int  x,y,max_x,max_y;

  show_raster(font);
  
  if (asc < 256)
    {
      switch (font)
        {
          case GROSS:   max_x = 8;
                        max_y = 16;
                        break;
          case MITTEL:  max_x = max_y = 8;
                        break;
          case KLEIN:   max_x = max_y = 6;
                        break;
        }

      for (y=0 ; y < max_y; y++)
        for (x=0 ; x < max_x ; x++)
          if (point(x,y)) platsch(x,y,1,font);
    }
}             


/*----------------------------------------------------------
     show_org(font);

     zeigt ein Zeichen im kleinen Anzeigefenster
     font = CLEAR  --> Feld lîschen
----------------------------------------------------------*/

void show_org(int  font)

{
  int  coords[8],i;

  mouse_off;

  if (font == CLEAR)
    {
      for (i=0; i < 16; rette[i++] = 0);
      font = GROSS;
    } 


  coords[0] = coords[1] = 0;              /* Koordinaten fÅr Copyraster */
  
  switch (font)
   {
     case GROSS:  coords[2] = 7;
                  coords[3] = 15;
                  coords[4] = show_x;
                  coords[5] = show_y;
                  coords[6] = show_x + 7;
                  coords[7] = show_y + 15;
                  break;
     case MITTEL: coords[2] = 7;
                  coords[3] = 7;
                  coords[4] = show_x;
                  coords[5] = show_y + 4;
                  coords[6] = show_x + 7;
                  coords[7] = show_y + 11;
                  break;
     case KLEIN:  coords[2] = 5;
                  coords[3] = 5;
                  coords[4] = show_x + 1;
                  coords[5] = show_y + 5;
                  coords[6] = show_x + 6;
                  coords[7] = show_y + 10;
                  break;
   } 
  
  mfdb_bild.fd_addr = Physbase();
  vro_cpyfm(handle,3,coords,&mfdb_rette,&mfdb_bild);

  mouse_on;
}

  
/*----------------------------------------------------------
     type_asc(asc):

     gibt die Nummer asc im kleinen Anzeigefeld aus
     asc = 256 -> Feld lîschen
----------------------------------------------------------*/

void type_asc(int  asc)

{
  int  dummy;
  char text[3];
  
  mouse_off;
  vst_height(handle,6,&dummy,&dummy,&dummy,&dummy);
  if (asc < 256)
  {
    text[0] = ((asc / 16) < 10) ? (char)(asc/16+0x30) : (char)(asc/16+0x37); 
    text[1] = ((asc % 16) < 10) ? (char)(asc%16+0x30) : (char)(asc%16+0x37);
  }
  else
   text[0] = text[1] = ' ';

  text[2] = (char)0;

  v_gtext(handle,asc_x,asc_y,text);
  mouse_on;
}

/*----------------------------------------------------------
     show_all(asc,font):

     erzeugt alle Anzeigen im Formular
----------------------------------------------------------*/

void show_all(int  asc,int  font)

{
  void zeig_an(),paint(),show_org(),type_asc();

  paint(asc,font);
  type_asc(asc);
  if (asc == 256) show_org(CLEAR);
  else show_org(font);
}


/*----------------------------------------------------------
     buffer(asc,font);
     
     öbertrÑgt Zeichen in den 'rette' Buffer
----------------------------------------------------------*/

void buffer(int  asc,int  font)

{
  int  coords[8];
  
  coords[4] = coords[5] = 0;

  switch(font)
   {
     case GROSS:  coords[0] = asc * 8;
                  coords[1] = 0;
                  coords[2] = coords[0] + 7;
                  coords[3] = 15;
                  coords[6] = 7;
                  coords[7] = 15;
                  vro_cpyfm(handle,3,coords,&mfdb_8_16,&mfdb_rette);
                  break;
      
     case MITTEL: coords[0] = asc * 8;
                  coords[1] = 0;
                  coords[2] = coords[0] + 7;
                  coords[3] = 7;
                  coords[6] = 7;
                  coords[7] = 7;
                  vro_cpyfm(handle,3,coords,&mfdb_8_8,&mfdb_rette);
                  break;
 
     case KLEIN:  coords[0] = asc * 6;
                  coords[1] = 0;
                  coords[2] = coords[0] + 5;
                  coords[3] = 5;
                  coords[6] = 5;
                  coords[7] = 5;
                  vro_cpyfm(handle,3,coords,&mfdb_6_6,&mfdb_rette);
                  break;
   }
}


/*----------------------------------------------------------
     ent_buffer(asc,font);
     
     öbertrÑgt Zeichen aus dem 'rette' Buffer in den Font
----------------------------------------------------------*/

void ent_buffer(int  asc,int  font)

{
  int  coords[8];
  
  coords[0] = coords[1] = 0;

  switch(font)
   {
     case GROSS:  coords[2] = 7;
                  coords[3] = 15;
                  coords[4] = asc * 8;
                  coords[5] = 0;
                  coords[6] = coords[4] + 7;
                  coords[7] = 15;
                  vro_cpyfm(handle,3,coords,&mfdb_rette,&mfdb_8_16);
                  break;
      
     case MITTEL: coords[2] = 7;
                  coords[3] = 7;
                  coords[4] = asc * 8;
                  coords[5] = 0;
                  coords[6] = coords[4] + 7;
                  coords[7] = 7;
                  vro_cpyfm(handle,3,coords,&mfdb_rette,&mfdb_8_8);
                  break;
 
     case KLEIN:  coords[2] = 5;
                  coords[3] = 5;
                  coords[4] = asc * 6;
                  coords[5] = 0;
                  coords[6] = coords[4] + 5;
                  coords[7] = 5;
                  vro_cpyfm(handle,3,coords,&mfdb_rette,&mfdb_6_6);
                  break;
   }
}


 
/*##########################################################

      Unterprogramme fÅr die Programminitialisierung

##########################################################*/

/*----------------------------------------------------------
     init_font:

     Bestimmt die Adressen der Zeiger auf die Fontdaten
----------------------------------------------------------*/

int init_font(void)
{
  long *version = (long*)0xFC0018L;     /* Zeiger auf Versionnummer TOS */
  long *header;                         /* Adr. der Headers im ROM */
  long *header_tab;                     /* Adr. der Fontheadertabelle */
  int  i,tos_version;

  tos_version = TRUE;  

  if (*version == 0x02061986L)          /* 520ST oder 1040ST ? */
  { 
    zeig_header_6_6 = (long*)0x2772;    /* Adr. des Zeigers auf Header 6*6 */ 
    zeig_8_16       = (long*)0x607E;    /* Adr. des Zeigers auf Daten 8*16 Font */
    zeig_8_8        = (long*)0x41A8;    /* Adr. des Zeigers auf Daten 8*8 Font */
  }
  else if(*version == 0x04221987L)      /* Blitter Tos ? */
  {
    zeig_header_6_6 = (long*)0x27D2;
    zeig_8_16       = (long*)0x8820; 
    zeig_8_8        = (long*)0x694A;
  }
  else if((*version & 0xFFFFL) == 0x1989L)      /* Tos 1.4 ? */
  {
    zeig_header_6_6 = (long*)0x2914;
    zeig_8_16       = (long*)0x5672; 
    zeig_8_8        = (long*)0x5316;
  }   
  else tos_version = FALSE;
 
  if (tos_version)
  {
    header_tab = get_header();          /* LINEA - Aufruf, Zeiger auf Tabelle */
                                        /* der Fontheader erfragen */
                                        
                                        /* alle Header ins RAM kopieren */

    header = (long*) *header_tab;       /* 6*6 Header ins RAM */
    for (i=0 ; i < 22 ; head_6_6[i] = header[i],i++);

    header = (long*) *(header_tab+1);   /* 8*8 Header ins RAM */
    for (i=0 ; i < 22 ; head_8_8[i] = header[i],i++);

    header = (long*) *(header_tab+2) ;  /* 8*16 Header ins RAM */
    for (i=0 ; i < 22 ; head_8_16[i] = header[i],i++);

    *zeig_header_6_6 = (long) head_6_6; /* Zeiger auf 6*6 Header zeigt nun
                                           auf Header im RAM */
    zeig_6_6  = head_6_6+FONT_DAT;      /* Adr. des Zeigers auf Daten 6*6 Font */

    sys_8_16  = (BYTE*) head_8_16[FONT_DAT];  /* Adr. des 8*16 Systemfont */
    sys_8_8   = (BYTE*) head_8_8[FONT_DAT];   /* Adr. des 8*8 Systemfont */
    sys_6_6   = (BYTE*) head_6_6[FONT_DAT];   /* Adr. des 6*6 Systemfont */ 

  }

                                        /* MFDBs vorbelegen */

  mfdb_8_16.fd_addr  = font_8_16;  /* 8*16 Font */

  mfdb_8_8.fd_addr   = font_8_8;   /* 8*8 Font */

  mfdb_6_6.fd_addr   = font_6_6;   /* 6*6 Font */

  mfdb_rette.fd_addr = rette;      /* Zwischenspeicher */



return(tos_version);
}


/*----------------------------------------------------------
     load_font();

     ZeichensÑtze aus DEFAULT.FNT lesen und aktivieren. 
     Wenn nicht vorhanden Systemfonts laden.
----------------------------------------------------------*/

void load_font(void)

{
   int  i,anzahl;
   BYTE fonts;
   int  file_handle;
   DTA  finfo;
 

   fonts = FALSE;                   /* Merker keine Fonts galaden */
                                    /* Versuch DEFAULT.FNT zu laden */
   if (dfind(&finfo,"DEFAULT.FNT",0) == 0)
     if (finfo.d_length == 7296)
      {
       if ((file_handle = Fopen("DEFAULT.FNT",O_RDONLY)) >= 0)
         { 
           anzahl = (int)Fread(file_handle,7296L,font_8_16);
           if (anzahl != 7296) show_alert(DERROR,1);
           else { fonts = TRUE;
                  strcpy(name_8_16,"DEFAULT .F16");
                  strcpy(name_8_8,"DEFAULT .FN8");
                  strcpy(name_6_6,"DEFAULT .FN6");
                  objc_change(tree,USE816,0,0,0,640,400,SELECTED,0);
                  objc_change(tree,USE88,0,0,0,640,400,SELECTED,0);
                  objc_change(tree,USE66,0,0,0,640,400,SELECTED,0);
                  on_8_16(); on_8_8(); on_6_6(); 
                }
         }
       Fclose (file_handle);
      }

   if (fonts == FALSE)
     {
       for (i=0 ; i < 256*16 ; font_8_16[i] = sys_8_16[i],i++);  
       strcpy(name_8_16,"SYSTEM  .F16"); 
     
       for (i=0 ; i < 256*8 ; font_8_8[i] = sys_8_8[i],i++);   
       strcpy(name_8_8,"SYSTEM  .FN8");  
     
       for (i=0 ; i < 192*6 ; font_6_6[i] = sys_6_6[i],i++);   
       strcpy(name_6_6,"SYSTEM  .FN6");   
     }


   edit_flag = GROSS;                 /* erstmal grossen FONT editieren */

   use_name(GROSS);                   /* Fontanamen eintragen */
}
                 


/*----------------------------------------------------------
     init_coords():

     Koordinaten der EDIT-Objekte bestimmen
----------------------------------------------------------*/

void init_coords(void)

{
  objc_offset(tree,ANZEIGE,&anz_x,&anz_y); /* Koordinaten fÅr Ausgabe im */
  anz_x += 8;                              /* Anzeigefeld */

  objc_offset(tree,EDITFELD,&ed_x,&ed_y);  /* Koordinaten des Editfeldes */
  ed_x += 4 ; ed_y += 4;

  objc_offset(tree,SHOW,&show_x,&show_y);  /* Koordinaten des kleinen    */
  show_x += 6 ; show_y += 7;               /* Anzeigefeldes              */

  objc_offset(tree,ASCII,&asc_x,&asc_y);   /* Koor. der ASCII-Num. Anz.  */
  asc_x +=5; asc_y += 9;
}
/*##########################################################

    Hilfsprogramme fÅr die Auswertung der Buttons

##########################################################*/

/*----------------------------------------------------------
     ok_edit():

     Editiertes Zeichen Åbernehmen
----------------------------------------------------------*/

void ok_edit(void)

{
 
/*  graf_shrinkbox(ed_x + 28,ed_y + 56,8,16,ed_x,ed_y,65,129); */
  graf_movebox(8,16,ed_x + 28,ed_y + 56,anz_x + (edit_it / 16) * 16,
               anz_y + (edit_it % 16) * 16);
  ent_buffer(edit_it,edit_flag);
  mouse_off;
  zeig_char(edit_it,edit_flag);
  mouse_on;
  edit_it = 256;
  show_all(256,edit_flag);
  edit_status(DISABLED);
}

/*----------------------------------------------------------
     undo_edit():

     Editiertes Zeichen verwerfen
----------------------------------------------------------*/

void undo_edit(void)

{
  edit_it = 256; 
  show_all(256,edit_flag);
  edit_status(DISABLED);
}


/*----------------------------------------------------------
     get_asc(x,y):

     Zeichen auf das die Maus in der Anzeige zeigt bestimmen
     256: Maus zeigt auf kein Zeichen
     nach *x,*y wird die Koorinate des Zeichens auf dem
     Bildschirm Åbergeben
----------------------------------------------------------*/

int  get_asc(int  *x,int  *y)

{
  int  mx,my,tasten,result;
  
  *x = *y = 0;

  vq_mouse(handle,&tasten,&mx,&my);     
                                        /* Maus im Anzeigefeld ? */
  if ((mx < anz_x) || (mx > anz_x + 16 * 16 - 8) ||
      (my < anz_y) || (my > anz_y + 16 * 16)) result = 256;
  else
    {
      mx -= anz_x; my -= anz_y;         /* Anzeigefeld in Nullpunkt ver. */
                                        /* Maus zwischen den Spalten ? */
      if (((mx /= 8) & 1) != 0) result = 256;
      else
       {
        result = (mx /= 2) * 16 + (my /= 16);  /* Maus steht richtig */
        *x = anz_x + mx * 16;
        *y = anz_y + my * 16;
       }
    }
  return(result);
}      

/*##########################################################

   Hier folgen die Unterprogramme, die die verschiedenen
                     BUTTONS auswerten
##########################################################*/

/*----------------------------------------------------------
     edit(font):
 
     Font auswÑhlen
----------------------------------------------------------*/

void edit(int  font)

{
 
  if (edit_it != 256) undo_edit();
  
  edit_flag = font;
  
  zeig_an(font);
  show_all(edit_it,edit_flag);                   /* Anzeigen lîschen */

  use_name(font);
  objc_draw(tree,FONTNAME,1,0,0,640,400);        /* Fontnamen neu malen */

  switch (font)                                  /* Knopf selecten */
   {
     case GROSS:  objc_change(tree,EDIT816,0,0,0,640,400,SELECTED,1);
                  objc_change(tree,EDIT88 ,0,0,0,640,400,NORMAL,1);
                  objc_change(tree,EDIT66 ,0,0,0,640,400,NORMAL,1);
                  break; 

     case MITTEL: objc_change(tree,EDIT816,0,0,0,640,400,NORMAL,1);
                  objc_change(tree,EDIT88 ,0,0,0,640,400,SELECTED,1);
                  objc_change(tree,EDIT66 ,0,0,0,640,400,NORMAL,1);
                  break;  
 
     case KLEIN:  objc_change(tree,EDIT816,0,0,0,640,400,NORMAL,1);
                  objc_change(tree,EDIT88 ,0,0,0,640,400,NORMAL,1);
                  objc_change(tree,EDIT66 ,0,0,0,640,400,SELECTED,1);
                  break;  
   }
}
    
/*----------------------------------------------------------
     edit_copy():

     Zeichen im Anzeigefenster editieren oder kopieren
----------------------------------------------------------*/

void edit_copy(void)

{
  int  asc1,asc2,x1,y1,x2,y2,x3,y3,coords[8];
  int  get_asc();

  if (edit_it == 256)  
   {
    if ((asc1 = get_asc(&x1,&y1)) == 256);   /* kein Zeichen -> fertig */
    else
      {
        graf_dragbox(8,16,x1,y1,anz_x,anz_y,31*8,16*16,&x3,&y3);
        if ((asc2 = get_asc(&x2,&y2)) == 256) 
          graf_movebox(8,16,x3,y3,x1,y1);    /* kein Zeichen -> Box zurÅck */
        else if (asc1 == asc2)               /* gleiches Zeichen -> editieren */
          {
            edit_it = asc1;
          
            graf_movebox(8,16,x1,y1,ed_x + 28,ed_y + 56);
            graf_growbox(ed_x + 28,ed_y + 56,8,16,ed_x,ed_y,65,129);
  
            buffer(asc1,edit_flag);          /* Zeichen in 'rette' Buffer */
 
            show_all(asc1,edit_flag);        /* und alles Anzeigen */

            edit_status(NORMAL);
          }
        else
          {                                  /* Zeichen kopieren */
            switch (edit_flag)
             {
               case GROSS:  coords[0] = asc1 * 8;
                            coords[1] = 0;
                            coords[2] = coords[0] + 7;
                            coords[3] = 15;
                            coords[4] = asc2 * 8;
                            coords[5] = 0;
                            coords[6] = coords[4] + 7;
                            coords[7] = 15;
                            vro_cpyfm(handle,3,coords,&mfdb_8_16,&mfdb_8_16);
                            break;
                            
               case MITTEL: coords[0] = asc1 * 8;
                            coords[1] = 0;
                            coords[2] = coords[0] + 7;
                            coords[3] = 7;
                            coords[4] = asc2 * 8;
                            coords[5] = 0;
                            coords[6] = coords[4] + 7;
                            coords[7] = 7;
                            vro_cpyfm(handle,3,coords,&mfdb_8_8,&mfdb_8_8);
                            break;

               case KLEIN:  coords[0] = asc1 * 6;
                            coords[1] = 0;
                            coords[2] = coords[0] + 5;
                            coords[3] = 5;
                            coords[4] = asc2 * 6;
                            coords[5] = 0;
                            coords[6] = coords[4] + 5;
                            coords[7] = 5;
                            vro_cpyfm(handle,3,coords,&mfdb_6_6,&mfdb_6_6);
                            break;

             }
            mouse_off;
            zeig_char(asc2,edit_flag);
            mouse_on;    
          }   
      }
    }
}      


/*----------------------------------------------------------
     load_system(font,button):

     Font ab Adresse rom_font der laenge "laenge" nach 
     ram_font kopieren und BUTTON normalisieren
----------------------------------------------------------*/

void load_system(int  font,int  button)

{
  int i;
  
  if (edit_it != 256) undo_edit();

  if (show_alert(SYSLOAD,2) == 2)
   {
    switch (font)
     {
       case GROSS:  for (i=0 ; i < 256*16 ; font_8_16[i] = sys_8_16[i],i++);
                    strcpy(name_8_16,"SYSTEM  .F16");
                    break;
       case MITTEL: for (i=0 ; i < 256*8  ; font_8_8[i]  = sys_8_8[i],i++);
                    strcpy(name_8_8,"SYSTEM  .FN8");
                    break;
       case KLEIN:  for (i=0 ; i < 192*6  ; font_6_6[i]  = sys_6_6[i],i++);
                    strcpy(name_6_6,"SYSTEM  .FN6");
                    break;
     }

    edit(font);                               /* Font Anzeigen */    
   }
  objc_change(tree,button,0,0,0,640,400,NORMAL,1);

}

/*----------------------------------------------------------
     load_system_all():
 
     Alle Systemfonts ins RAMs kopieren
----------------------------------------------------------*/

void load_all_system(void)

{
  int i;

  if (edit_it != 256) undo_edit();

  if (show_alert(SYSLOAD,2) == 2)
    {
      for (i=0 ; i < 256*16 ; font_8_16[i] = sys_8_16[i],i++);
      for (i=0 ; i < 256*8  ; font_8_8[i]  = sys_8_8[i],i++);
      for (i=0 ; i < 192*6  ; font_6_6[i]  = sys_6_6[i],i++);

      strcpy(name_8_16,"SYSTEM  .F16");
      strcpy(name_8_8,"SYSTEM  .FN8");
      strcpy(name_6_6,"SYSTEM  .FN6");

      edit(GROSS);
    }

  objc_change(tree,SYSALL,0,0,0,640,400,NORMAL,1);
}


/*----------------------------------------------------------
     use_change(mode,button):
   
     Alle oder keinen Font benutzen
----------------------------------------------------------*/

void use_change(int  mode,int  button)

{
  objc_change(tree,USE816,0,0,0,640,400,mode,1);
  objc_change(tree,USE88 ,0,0,0,640,400,mode,1);
  objc_change(tree,USE66 ,0,0,0,640,400,mode,1);

  objc_change(tree,button,0,0,0,640,400,NORMAL,1);
}

/*----------------------------------------------------------
     male():

     Setzen oder lîschen von Punktem mit der Maus
----------------------------------------------------------*/

void male(void)

{
  int  breite,hoehe,null_x,null_y;
  int  status,mx,my;
  int  first,set_mode;

  if (edit_it < 256)
   {
     first = TRUE; set_mode = 1;  /* Setz-Modus vorbelegen */    

     switch (edit_flag)      /* je nach Font groesse Raster best.  */
      {
        case GROSS:  null_x = ed_x; null_y = ed_y;
                     breite = 8 * 8; hoehe = 16 * 8;
                     break;
        case MITTEL: null_x = ed_x; null_y = ed_y + 4 * 8;
                     breite = hoehe = 8 * 8;
                     break;
        case KLEIN:  null_x = ed_x + 8; null_y = ed_y + 5 * 8;
                     breite = hoehe = 6 * 8;
                     break;
      }
      
     do
      {                     /* Punkt bestimmen */
        vq_mouse(handle,&status,&mx,&my);    

        mx -= null_x; my -= null_y;
 
        if ((mx > 0) && (my > 0) && (mx < breite) && (my < hoehe))
         {
           mx /= 8; my /= 8;   /* mx und my sind die Koord. des Punktes */
                               /* Zeichenmodus bestimmen */
           if (first && point(mx,my)) set_mode = 0;
           first = FALSE;
                               /* Punkt setzen bzw. lîschen */
           set(mx,my,set_mode);
           platsch(mx,my,set_mode,edit_flag);
           show_org(edit_flag);
         }
       }
      while ((status & 3) != 0);
   }
}

/*----------------------------------------------------------
     show_it(button):

     nach einer Manipulation zeichen neu darstellen
----------------------------------------------------------*/

void show_it(int  button)

{
  show_org(edit_flag);
  paint(edit_it,edit_flag);
  objc_change(tree,button,0,0,0,640,400,NORMAL | OUTLINED,1);
}  


/*----------------------------------------------------------
     clr_fill(art,button;):

     Zeichen lîschen oder schwarz malen
----------------------------------------------------------*/

void clr_fill(int  art,int  button)

{
  int  i;

  for (i=0 ; i < 16 ; rette[i++] = art);
  show_it(button);
}

/*----------------------------------------------------------
     invers_it():

     Zeichen invertieren
----------------------------------------------------------*/

void invers_it(void)

{
  int  i;

  for (i=0; i < 16 ; rette[i] = ~rette[i],i++);
  show_it(INVERS);
}

/*----------------------------------------------------------
     kopf():

     Zeichen auf den Kopf stellen
----------------------------------------------------------*/

void kopf(void)

{
  int  i,help,ymax;

  switch (edit_flag)
   {
     case GROSS:  ymax = 15;
                  break;
     case MITTEL: ymax = 7;
                  break;
     case KLEIN:  ymax = 5;
                  break;
   }

  for (i=0 ; i <= ymax/2 ; i++)
   {
     help = rette[i];
     rette[i] = rette[ymax - i];
     rette[ymax - i] = help;
   }
  show_it(ASPIEGEL);
}

/*----------------------------------------------------------
     spiegel():

     Zeichen spiegeln
----------------------------------------------------------*/

void spiegel(void)

{
  int  xmax,x,y,schiebe;

  if (edit_flag != KLEIN) { xmax = 8; schiebe = 8;}
                     else { xmax = 6; schiebe = 10;}

  for (y=0; y < 16 ; y++)
    {
      for (x=0; x < xmax; x++)
        if (point(x,y)) set(15 - x,y,1); else set(15 - x,y,0);
      rette[y] = rette[y] << schiebe;
    }
  show_it(ESPIEGEL);
}

/*----------------------------------------------------------
     hell():

     Zeichen aufhellen
----------------------------------------------------------*/

void hell(void)

{
  int  y;
  
  for (y=0; y < 16; rette[y++] &= 0x5555,rette[y++] &= 0xAAAA);
  show_it(LIGHT);
}

/*----------------------------------------------------------
     turn_it():

     Zeichen drehen
----------------------------------------------------------*/
  
void turn_it(void)

{
  int  schiebe,x,y;

  if (edit_flag == MITTEL) schiebe = 8; else schiebe = 10;
 
  for (y=0 ; y < 8 ; y++)
    for (x=0; x < 8 ; x++) 
      if (point(x,y)) set(15-y,x,1); else set(15-y,x,0);

  for (y=0 ; y < 8 ; rette[y] = rette[y] << schiebe,y++);
  show_it(DREHE);
}

/*----------------------------------------------------------
    left(),right(),down(),up():

    Unterprogramme um ein Zeichen um ein Dot zu verschieben
----------------------------------------------------------*/

void up(void)

{
  int  y;

  for (y=0; y < 15 ; rette[y] = rette[y+1],y++);
  switch(edit_flag)
   {
     case GROSS:  rette[15] = 0; break;
     case MITTEL: rette[7]  = 0; break;
     case KLEIN:  rette[5]  = 0; break;
   }
  show_it(CLR);
}

void down(void)

{
  int  y;

  for (y=15; y > 0 ; rette[y] = rette[y-1],y--);
  rette[0] = 0;
  show_it(CLR);
}

void left(void)

{
  int  y,breite;

  if (edit_flag == KLEIN) breite = 5; else breite = 7;
  for (y=0; y < 16 ; rette[y] = rette[y] << 1,set(breite,y,0),y++);
  show_it(CLR);
}

void right(void)

{
  int  y;

  for (y=0; y < 16 ; rette[y] = rette[y] >> 1,set(0,y,0),y++);
  show_it(CLR);
}

/*##########################################################

     Unterprogramme fuer LOAD und SAVE der Fonts

##########################################################*/

/*==========================================================
     get_filename(path,file,button);

     erfragt einen Filename 
     
     path:        Pfadname mit Wildcards
     file:        Default Filename
     button:      0=Abbruch   1=OK

     RÅckgabe 0, wenn Fehler
==========================================================*/

int  get_filename(char *path,char *file,int *button)

{
  int  err;

  err = fsel_input(path,file,button);

  objc_draw(tree,0,8,0,0,640,400);
  show_all(edit_it,edit_flag);

  return(err);
}
  


/*==========================================================
     speicher(font,ext,name):

     font = KLEIN, GROSS, MITTEL oder ALLES
     ext  = "F16"  z.B.
     name = aktuelle Zeichensatzname

     Speichert einen oder alle Fonts auf Diskette ab
==========================================================*/

void speicher(int  font,char *ext,char *name)

{
  int  button,file_handle,err;
  int  anzahl;
  char such[6],file_name[13];

  strmfe(file_name,name,ext);
  strcpy(such,"*.");
  strcat(such,ext);
  
  strmfe(path_name,path_name,ext);

  err = get_filename(path_name,file_name,&button); 
  zeig_an(edit_flag);
  if (err == 0)
    show_alert(DERROR,1);
  else if (button == 1)
   {
     strmfe(file_name,file_name,ext);
     stcgfp(akt_file,path_name);
     strcat(akt_file,"\\");
     strcat(akt_file,file_name);
     
     graf_mouse(255,&maus_disk);

     if ((file_handle = Fcreate(akt_file,0)) < 0)
       show_alert(DERROR,1);
     else
       switch (font)
         {
           case GROSS:    anzahl = (int)Fwrite(file_handle,4096L,font_8_16);
                          if (anzahl != 4096) show_alert(DERROR,1);
                          else get_name(name_8_16,akt_file); 
                          break;
           case MITTEL:   anzahl = (int)Fwrite(file_handle,2048L,font_8_8);
                          if (anzahl != 2048) show_alert(DERROR,1);
                          else get_name(name_8_8,akt_file);
                          break;
           case KLEIN:    anzahl = (int)Fwrite(file_handle,1152L,font_6_6);
                          if (anzahl != 1152) show_alert(DERROR,1);
                          else get_name(name_6_6,akt_file);
                          break;
           case ALLES:    anzahl = (int)Fwrite(file_handle,7296L,font_8_16);
                          if (anzahl != 7296) show_alert(DERROR,1);
                          else
                            {
                              get_name(name_8_16,akt_file);
                              strmfe(name_8_16,name_8_16,"F16");
                              get_name(name_8_8,akt_file);
                              strmfe(name_8_8,name_8_8,"FN8");
                              get_name(name_6_6,akt_file);
                              strmfe(name_6_6,name_6_6,"FN6");
                            }
                          break;
         }
       Fclose(file_handle);
    } 
  objc_change(tree,SAVE816,0,0,0,640,400,NORMAL,1);
  objc_change(tree,SAVE88,0,0,0,640,400,NORMAL,1);
  objc_change(tree,SAVE66,0,0,0,640,400,NORMAL,1);
  objc_change(tree,SAVEALL,0,0,0,640,400,NORMAL,1);

  use_name(edit_flag);
  objc_draw(tree,FONTNAME,1,0,0,640,400); 
  graf_mouse(0,&maus_disk);
  
}

/*==========================================================
     lade(font,ext,laenge):

     font = KLEIN, MITTEL, GROSS oder ALLES
     ext  = "F16" z.B.
     laenge = DateilÑnge

     lÑdt einen oder alle Fonts von Diskette
===========================================================*/

void lade(int  font,char *ext,int  laenge)

{
  int  button,file_handle;
  int  anzahl;
  char file[14];
  DTA finfo;

  if (edit_it != 256) undo_edit();

  strmfe(path_name,path_name,ext);
  file[0] = '\0';

  if (get_filename(path_name,file,&button) == 0)
    {
      zeig_an(edit_flag);
      show_alert(DERROR,1);
    }
  else if (button == 1)
    {
      stcgfp(akt_file,path_name);
      strcat(akt_file,"\\");
      strcat(akt_file,file);
      
      graf_mouse(255,&maus_disk);
      
      if (dfind(&finfo,akt_file,0) != 0)
        {
          zeig_an(edit_flag);
          show_alert(NOTFOUND,1);
        }
      else if (finfo.d_length != laenge)
        {
          zeig_an(edit_flag);
          show_alert(NOTLANG,1);
        }    
      else if ((file_handle = Fopen(akt_file,O_RDONLY)) < 0)
        {
          zeig_an(edit_flag);
          show_alert(DERROR,1);
        }
      else
       switch (font)
        {
          case GROSS:      anzahl = (int)Fread(file_handle,(long)laenge,font_8_16);
                           if (anzahl != laenge)
                             {                             
                               zeig_an(edit_flag);
                               show_alert(DERROR,1);
                             }
                           else {  get_name(name_8_16,akt_file);  
                                   strmfe(name_8_16,name_8_16,ext);
                                   edit(GROSS);
                                }
                           break;
          case MITTEL:     anzahl = (int)Fread(file_handle,(long)laenge,font_8_8);
                           if (anzahl != laenge)
                             {
                               zeig_an(edit_flag);
                               show_alert(DERROR,1);
                             }
                           else {  get_name(name_8_8,akt_file);  
                                   strmfe(name_8_8,name_8_8,ext);
                                   edit(MITTEL);
                                }
                           break;
          case KLEIN:      anzahl = (int)Fread(file_handle,(long)laenge,font_6_6);
                           if (anzahl != laenge) 
                             {
                               zeig_an(edit_flag);       
                               show_alert(DERROR,1);
                             }
                           else {  get_name(name_6_6,akt_file);  
                                   strmfe(name_6_6,name_6_6,ext);
                                   edit(KLEIN);
                                }
                           break;
          case ALLES:      anzahl = (int)Fread(file_handle,(long)laenge,font_8_16);
                           if (anzahl != laenge)
                             {
                               zeig_an(edit_flag);
                               show_alert(DERROR,1);
                             }
                           else {  get_name(name_8_16,akt_file);  
                                   strmfe(name_8_16,name_8_16,"F16");
                                   get_name(name_8_8,akt_file);
                                   strmfe(name_8_8,name_8_8,"FN8");
                                   get_name(name_6_6,akt_file);
                                   strmfe(name_6_6,name_6_6,"FN6");
                                   edit(GROSS);
                                }
                           break;
        }
       Fclose (file_handle);
    }
  else zeig_an(edit_flag);

  objc_change(tree,LOAD816,0,0,0,640,400,NORMAL,1);
  objc_change(tree,LOAD88,0,0,0,640,400,NORMAL,1);
  objc_change(tree,LOAD66,0,0,0,640,400,NORMAL,1);
  objc_change(tree,LOADALL,0,0,0,640,400,NORMAL,1);

  graf_mouse(0,&maus_disk);
  
}
      
/*==========================================================
                 Beispieltext ausgeben
==========================================================*/
void zeige1_probe(void)

{
  int  coords[4],maus,dummy;
  char zeile1[25],zeile2[25],zeile3[25];

  vsf_color(handle,0);

  mouse_off;
  coords[0] = anz_x;
  coords[1] = anz_y;
  coords[2] = anz_x + 16 * 16 - 9;
  coords[3] = anz_y + 16 * 16 - 1;
  vr_recfl(handle,coords);

  strcpy(zeile1,"Dies ist ein Probetext!");
  strcpy(zeile2,"DIES IST EIN PROBETEXT!");
  strcpy(zeile3,"0123456789  !›$%&()=?*+");

  vst_height(handle,GROSS,&dummy,&dummy,&dummy,&dummy);
  v_gtext(handle,anz_x+44,anz_y+25,"Probetexte gefÑllig?");

  on_8_16(); on_8_8(); on_6_6();

  v_gtext(handle,anz_x+32,anz_y+66,zeile1);
  v_gtext(handle,anz_x+32,anz_y+82,zeile2);
  v_gtext(handle,anz_x+32,anz_y+98,zeile3);

  vst_height(handle,MITTEL,&dummy,&dummy,&dummy,&dummy);
  v_gtext(handle,anz_x+32,anz_y+140,zeile1);
  v_gtext(handle,anz_x+32,anz_y+148,zeile2);
  v_gtext(handle,anz_x+32,anz_y+156,zeile3);

  vst_height(handle,KLEIN,&dummy,&dummy,&dummy,&dummy);
  v_gtext(handle,anz_x+32,anz_y+200,zeile1);
  v_gtext(handle,anz_x+32,anz_y+206,zeile2);
  v_gtext(handle,anz_x+32,anz_y+212,zeile3);

  off_8_16(); off_8_8(); off_6_6();

  vst_height(handle,MITTEL,&dummy,&dummy,&dummy,&dummy);
  v_gtext(handle,anz_x+32,anz_y+240,"weiter mit Mausklick!");

  do
    vq_mouse(handle,&maus,&dummy,&dummy);
  while (maus != 0);
  do
    vq_mouse(handle,&maus,&dummy,&dummy);
  while (maus == 0);

  objc_change(tree,PROBE1,0,0,0,640,400,NORMAL,1);
  zeig_an(edit_flag);
  mouse_on;

  do
    vq_mouse(handle,&maus,&dummy,&dummy);
  while (maus != 0);
}

void zeige2_probe(void)

{
  int  coords[4],maus,xk,yk,sx,sy,sanf,zeichen,dummy;
  char stext[2];

  objc_offset(tree,FONTNAME,&coords[0],&coords[1]);
  coords[0] += 3;
  coords[1] += 2;
  coords[2] = coords[0] + 20*8;
  coords[3] = coords[1] + 18;
  mouse_off;
  vsf_color(handle,0);
  vr_recfl(handle,coords);
  mouse_on;

  sx = sanf = coords[0] + 7; sy = coords[1] + 13; 

  vst_height(handle,MITTEL,&dummy,&dummy,&dummy,&dummy);
  mouse_off;
  v_gtext(handle,sx+4,sy+18,"Probetext eingeben");
  mouse_on;
      
  vst_height(handle,edit_flag,&dummy,&dummy,&dummy,&dummy);

  do
    vq_mouse(handle,&maus,&xk,&yk);
  while (maus != 0);

  do
    {
      mouse_off;
      v_gtext(handle,sx,sy,"_");
      mouse_on;

      do
        vq_mouse(handle,&maus,&xk,&yk);
      while (maus == 0);

      if ((zeichen = get_asc(&dummy,&dummy)) < 256)
        {
          if (zeichen == 0) 
            {
              vr_recfl(handle,coords);
              sx = sanf;
            }             
          else
            {  
              stext[0] = (char)zeichen;
              stext[1] = (char)0;
              mouse_off;
              on_8_16(); on_8_8(); on_6_6();
              v_gtext(handle,sx,sy,stext);
              off_8_16(); off_8_8(); off_6_6(); 
              mouse_on;
              if (edit_flag == KLEIN)
                sx += 6;
              else
                sx += 8;
              if (sx > sanf + 18*8) sx = sanf;
              do
                vq_mouse(handle,&maus,&xk,&yk);
              while (maus != 0);
            }
        } 
    }
  while((xk < coords[0]) || (xk > coords[2]) ||
        (yk < coords[1]) || (yk > coords[3]));
 
  objc_draw (tree,FONTNAME,1,0,0,640,400);
  coords[0] += 12; coords[1] += 22;
  coords[2] = coords[0] + 20*8; coords[3] = coords[1] + 10;
  mouse_off;
  vr_recfl(handle,coords);
  objc_change(tree,PROBE2,0,0,0,640,400,NORMAL,1);
  mouse_on;

  do
    vq_mouse(handle,&maus,&xk,&yk);
  while (maus != 0);

}


/*##########################################################
     do_edit:
     
     wertet Formular bei Accessorie-Aufruf aus
##########################################################*/

void do_edit(void)

{
  int  exit_but;
  

  off_8_16();                                /* alle User-Fonts aus */
  off_8_8();
  off_6_6();

  show_edit(tree);                           /* Formular darstellen */

  graf_mouse(0,&maus_disk);

  init_coords();                             /* Koordinaten bestimmen */

  zeig_an(edit_flag);
  show_all(edit_it,edit_flag);               /* Anzeigen darstellen */

  do
    {
      exit_but = form_do(tree,0) & 0x7FFF;   /* Button abfragen */
      switch (exit_but)
      {

        case ANZEIGE:  edit_copy();          /* Maus im Anzeigefeld */
                       break;

        case OK:       ok_edit();            /* Zeichen Åbernehmen */
                       break;
        case UNDO:     undo_edit();          /* Zeichen verwerfen */
                       break;
                                             /* Systemfonts Åbertragen */
        case SYS816:   load_system(GROSS,exit_but);
                       break;
        case SYS88:    load_system(MITTEL,exit_but);
                       break;
        case SYS66:    load_system(KLEIN,exit_but);
                       break;
        case SYSALL:   load_all_system();
                       break; 
                                             /* Aktivierung abfragen */
        case USEALL:   use_change(SELECTED,exit_but);
                       break;
        case USENONE:  use_change(NORMAL,exit_but);
                       break;

                                             /* Font auswÑhlen */
        case EDIT816:  if (edit_flag != GROSS) edit(GROSS); 
                       break;
        case EDIT88:   if (edit_flag != MITTEL) edit(MITTEL);
                       break;
        case EDIT66:   if (edit_flag != KLEIN) edit(KLEIN);
                       break;

        case EDITFELD: male();               /* Zeichen editieren */
                       break;
                       
        case CLR:      clr_fill(0,CLR);      /* Zeichen lîschen */
                       break;
        case FILL:     clr_fill(0xFFFF,FILL);   /* Zeichen schwarz */
                       break;
        case INVERS:   invers_it();          /* Zeichen invertieren */
                       break;
        case ASPIEGEL: kopf();               /* Zeichen auf den Kopf */
                       break;
        case ESPIEGEL: spiegel();            /* Zeichen spiegeln */
                       break;
        case LIGHT:    hell();               /* Zeichen aufhellen */
                       break;
        case DREHE:    turn_it();            /* Zeichen drehen */
                       break;
        case HOCH:     if (edit_it < 256) up();    /* Zeichen hoch */
                       break;
        case RUNTER:   if (edit_it < 256) down();  /* Zeichen runter */
                       break;
        case LINKS:    if (edit_it < 256) left();  /* Zeichen links */
                       break;
        case RECHTS:   if (edit_it < 256) right(); /* Zeichen rechts */
                       break; 

        case SAVE816:  speicher(GROSS,"F16",name_8_16);
                       break;
        case SAVE88:   speicher(MITTEL,"FN8",name_8_8);
                       break;
        case SAVE66:   speicher(KLEIN,"FN6",name_6_6);
                       break;
        case SAVEALL:  speicher(ALLES,"FNT",name_8_16);
                       break;

        case LOAD816:  lade(GROSS,"F16",4096);
                       break;
        case LOAD88:   lade(MITTEL,"FN8",2048);
                       break;
        case LOAD66:   lade(KLEIN,"FN6",1152);
                       break;
        case LOADALL:  lade(ALLES,"FNT",7296);
                       break;
      
        case PROBE1:   zeige1_probe();
                       break;
        case PROBE2:   zeige2_probe();
                       break;
        case DIRK:
        case DIRK1:
        case DIRK2:
        case DIRK3:
        case DIRK4:    form_alert(1,"[1][FontEdit ist von:| "
                                    "|Dirk Woitha|"
                                    "Hebbelstr. 11|5630 Remscheid 11]"
                                    "[ ach der ]");
                       break;
      }
      
    }
  while (exit_but != AUSGANG);

  if (get_status((long)tree,USE816) == SELECTED) on_8_16();
  if (get_status((long)tree,USE88)  == SELECTED) on_8_8(); 
  if (get_status((long)tree,USE66)  == SELECTED) on_6_6(); 

  close_edit(tree);                      /* Formular abbauen */
  objc_change(tree,AUSGANG,0,0,0,640,400,NORMAL | OUTLINED,0);
}        


/*##########################################################
     main:

     GEM, VDI und Accessorie anmelden und auf Event warten
##########################################################*/

void main()
{
  int  app_id,menu_id; 
  int  msg_buf[8];
  int  gr_1,gr_2,gr_3,gr_4;
  int  work_in[12],work_out[57];
  int  i;

/* -------- GEM initialisieren -------- */

  app_id = appl_init(); 

  handle = graf_handle(&gr_1,&gr_2,&gr_3,&gr_4);

  for (i=0; i<10; i++)  work_in[i] = 1;
  work_in[10] = 2;  

  v_opnvwk(work_in,&handle,work_out);

/* -------- Linienmuster setzen -------- */



  vsl_udsty(handle,0x5555);    
  vsl_type(handle,7);

/* -------- Resource laden -------- */  


  if (rsrc_load("FONTEDIT.RSC") == FALSE)
    {
      form_alert(1,"[3][Merke:| |Ohne Resource-File|kein FontEdit!][ WöRG ]");
      while(TRUE) evnt_mesag(msg_buf);
    }
 
/* -------- FONT-Daten initialisieren -------- */

  if (init_font() == FALSE)
    {
      show_alert (TOSVERS,1);
      while(TRUE) evnt_mesag(msg_buf);
    }

/* ------- Adresse des Hauptbaums bstimmen ------- */

  rsrc_gaddr(R_TREE,FONTEDIT,&tree);         

/* -------- Zeichensatz aus DEFAULT.FNT lesen ------ */

  load_font();

/* -------- Bei Farbe ist hier schluss ! -------- */

  if (Getrez() != 2)  while(TRUE) evnt_mesag(msg_buf);

/* -------- Accessorie anmelden -------- */

  menu_id = menu_register(app_id,"  +++ FontEdit +++");

/* -------- aktuelles Drive vorbelegen ----------*/
 
  path_name[0] = (char) (Dgetdrv() + 0x41);
  path_name[1] = '\0';
  strcat(path_name,":\\*.FNT");

/* -------- auf Event warten --------  */

  while(TRUE)
    {
      evnt_mesag(msg_buf);
      if(msg_buf[0] == AC_OPEN && msg_buf[4] == menu_id)
        {
          wind_update(BEG_MCTRL); 
          do_edit();
          wind_update(END_MCTRL);  
        }
    }
}     
