#include <stdio.h>
#include <aes.h>
#include <vdi.h>
#include <tos.h>

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

  }

return(tos_version);
}


/*----------------------------------------------------------
     load_font();

     ZeichensÑtze aus DEFAULT.FNT lesen und aktivieren. 
----------------------------------------------------------*/

void load_font(void)

{
   int  anzahl;
   int  file_handle;
   DTA  finfo;

                                    /* Versuch DEFAULT.FNT zu laden */
   if (dfind(&finfo,"DEFAULT.FNT",0) == 0)
     if (finfo.d_length == 7296)
      {
       if ((file_handle = Fopen("DEFAULT.FNT",O_RDONLY)) >= 0)
         { 
           anzahl = (int)Fread(file_handle,7296L,font_8_16);  
           if (anzahl == 7296)
                {
                  on_8_16(); on_8_8(); on_6_6();  
                }
         }
       Fclose (file_handle);
      }  
}
                 

/*##########################################################
     main:

     GEM, VDI und Accessorie anmelden und auf Event warten
##########################################################*/

void main()
{
  int  msg_buf[8];
  int  gr_1,gr_2,gr_3,gr_4;
  int  work_in[12],work_out[57];
  int  i;

/* -------- GEM initialisieren -------- */

  handle = graf_handle(&gr_1,&gr_2,&gr_3,&gr_4);

  for (i=0; i<10; i++)  work_in[i] = 1;
  work_in[10] = 2;  

  v_opnvwk(work_in,&handle,work_out);

/* -------- FONT-Daten initialisieren -------- */

  if (init_font() == FALSE)
    {
      while(TRUE) evnt_mesag(msg_buf);
    }


/* -------- Zeichensatz aus DEFAULT.FNT lesen ------ */

  load_font();

/* -------- Das wars dann ! -------- */

  while(TRUE) evnt_mesag(msg_buf);

}     
