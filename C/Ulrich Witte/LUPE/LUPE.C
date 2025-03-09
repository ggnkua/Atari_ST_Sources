/*---------------------------------------*/
/*                                       */
/*          Echtzeitlupe in C            */
/*     programmiert von Ulrich Witte     */
/*              mit PURE-C               */
/*                                       */
/*       (c) 1992 MAXON Computer         */
/*                                       */
/*---------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <tos.h>
#include <aes.h>
#include <vdi.h>

#define min(a, b) (((a) < (b)) ? (a) : (b))
#define max(a, b) (((a) > (b)) ? (a) : (b))

#define FALSE 0
#define TRUE 1

#define BREITE 32
#define HOEHE 32

typedef unsigned char byte;/* Spart Tipparbeit */

           /* Globale Variablen  */

unsigned maske2[] = {3,12,48,192,768,
                     3072,12288,49152U};
unsigned long maske4[] = {0x0000000f,
                          0x000000f0,
                          0x00000f00,
                          0x0000f000,
                          0x000f0000,
                          0x00f00000,
                          0x0f000000,
                          0xf0000000};
/*
unsigned long maske8[] = {0x00000000,0x000000ff,
                          0x00000000,0x0000ff00,
                          0x00000000,0x00ff0000,
                          0x00000000,0xff000000,
                          0x000000ff,0x00000000,
                          0x0000ff00,0x00000000,
                          0x00ff0000,0x00000000,
                          0xff000000,0x00000000};
*/
unsigned long maske8[] = {0x00000000,0x0000007f,
                          0x00000000,0x00007f00,
                          0x00000000,0x007f0000,
                          0x00000000,0x7f000000,
                          0x0000007f,0x00000000,
                          0x00007f00,0x00000000,
                          0x007f0000,0x00000000,
                          0x7f000000,0x00000000};
                          
MFDB bildschirm,bild,lupe1,lupe2;
int aes_handle,vdi_handle,work_out[57],
    work_out_ext[57];
unsigned zweifach[256];
unsigned long vierfach[256];
unsigned long achtfach[512];
int cw,ch,zw,zh;

            /*    Prototypen   */

void tabellen_init(void);
int init_mfdb(MFDB *block,int breite,int hoehe,
              int flag);
int open_work(MFDB *form);
int main(void);
void lupe(MFDB *quelle, MFDB *ziel,
          int qx, int qy, int qw, int qh,
          int zx, int zy, int faktor);
void sublupe2(byte *src, unsigned *dst,
              int bytes, int lines);
void sublupe4(byte *src, unsigned long *dst,
              int bytes, int lines);
void sublupe8(byte *src, unsigned long *dst, 
              int bytes, int lines);
void nothing(byte *src, void *dst, int bytes,
             int lines);
int align(int x,int n);

int main(void)
{
  int i;
  int mx,my,mk;

  appl_init();
  vdi_handle = open_work(&bildschirm);
  init_mfdb(&bild,639,399,0);
  init_mfdb(&lupe1,work_out[0],work_out[1],0);
  init_mfdb(&lupe2,work_out[0],work_out[1],0);
    /* Das Bild muû 'DESK.DOO' heiûen, */
    /* wenn keins da ist wird eben weiû */
    /* vergrîûert (sieht man nur nicht viel) */
  i = Fopen("DESK.DOO",0);
  if (i >= 0)
  {
    Fread(i,32000L,bild.fd_addr);
    Fclose(i);
  }
  tabellen_init();
  graf_mouse(M_OFF,0);  /* Maus verstecken */
  do
  {
    graf_mkstate(&mx,&my,&mk,&i);
    lupe(&bild,&bildschirm,
        min(mx,639 - BREITE),min(my,399 - HOEHE),
        BREITE,HOEHE,0,50,2);
    lupe(&bild,&bildschirm,
        min(mx,639 - BREITE),min(my,399 - HOEHE),
        BREITE,HOEHE,128,50,4);
    lupe(&bild,&bildschirm,
        min(mx,639 - BREITE),min(my,399 - HOEHE),
        BREITE,HOEHE,320,50,8);
  } while(!(mk & 2));
  graf_mouse(M_ON,0);    /* Maus wieder an */
  v_clsvwk(vdi_handle);  /* und abmelden */
  appl_exit();
  return 0;
}

/*-------------------------------------------
  Funktion tabellen_init
  
  Aufgabe: Erstellt die Vergrîûerungstabellen
           fÅr 2, 4 und 8-fache Vergrîûerung
  
  Eingabe: nichts
  
  Ausgabe: nichts
  
  Besonderes: nichts
--------------------------------------------*/
  
void tabellen_init(void)
{
  int i,j,k;

  for (i = 0 ; i < 256 ; i++) /* pro Buchstabe */
  {                           /* 8 Bits testen */
    for (j = 1, k = 0; j < 256 ; j *= 2, k++)  
    {
      if ((byte)i & j)        /* Bit gesetzt */
      {                       /* Stelle setzen */
        zweifach[i] |= maske2[k];
        vierfach[i] |= maske4[k];
        achtfach[i * 2] |= maske8[k * 2];
        achtfach[i * 2 + 1] |= maske8[k * 2 + 1];
      }
      else                /* Bit nicht gesetzt */
      {                   /* Stelle lîschen */
        zweifach[i] &= ~maske2[k];     
        vierfach[i] &= ~maske4[k];
        achtfach[i * 2] &= ~maske8[k * 2];
        achtfach[i * 2 + 1] &= ~maske8[k*2 + 1];
      }
    }
  }
}

/*-----------------------------------------------
    Funktion lupe
    
    Aufgabe:  Vorbereitung der Vergrîûerung
    
    Eingabe: -quelle: Zeiger auf Quellraster
             -ziel:   Zeiger auf Zielraster
             -qx,qy:   x, y - Koordinaten des 
              Quellausschnitts
             -qw,qh:  Breite, Hîhe des 
              Quellausschnitts
             -zx,zy:  x, y - Koordinaten des 
              Zielbreichs
             -faktor: Vergrîûerungsfaktor
              (derzeit 2,4,8)
    
    Ausgabe: nichts
    
    Besonderes: nichts 
-----------------------------------------------*/

void lupe(MFDB *quelle, MFDB *ziel,
          int qx, int qy, int qw, int qh, 
          int zx, int zy, int faktor)
{
  int xy[8];
  void (*vergroessern)() = nothing; 
     /* Dummyfunktion laden: */
     /* falls falscher Faktor Åbergeben wird */
     /* nur RTS statt Bomben! */
  
        /* Breite auf Wortgrenze bringen */
  qw = align(qw,16);       
        /* MFDB-Wortbreite korrigieren */
  lupe1.fd_wdwidth = (qw >> 4);
        /* Bitblit-Array fÅr Quellraster */
  xy[0] = xy[2] = qx;    
  xy[1] = xy[3] = qy;
  xy[4] = xy[5] = 0;
  xy[2] += (xy[6] = qw - 1);
  xy[3] += (xy[7] = qh - 1);
        /* und 'blitten' */
  vro_cpyfm(vdi_handle,3,xy,quelle,&lupe1); 
  switch (faktor)
  {  /* je Faktor entsprechende Funktion laden */
    case 2:
      vergroessern = sublupe2;
    break;
    case 4:
      vergroessern = sublupe4;
    break;
    case 8:
      vergroessern = sublupe8;
    break;
  }
  vergroessern(lupe1.fd_addr,lupe2.fd_addr,
               (qw >> 3),qh);  
     /* Wortbreite fÅr Zielraster setzen */
  lupe2.fd_wdwidth = (qw >> 4) * faktor; 
     /* Bitblit-Array fÅr Zielraster */
  xy[0] = xy[1] = 0;   
  xy[4] = xy[6] = zx;
  xy[5] = xy[7] = zy;
  xy[6] += (xy[2] = qw * faktor - 1);
  xy[7] += (xy[3] = qh * faktor - 1);
    /* Vergrîûerung ins Zielraster blitten */
  vro_cpyfm(vdi_handle,3,xy,&lupe2,ziel);
}

/*-----------------------------------------------
  Funktion sublupe2
  
  Aufgabe: Ausschnitt in x- und y-Richtung 
           von src nach dst zweifach vergrîûern
           
  Eingabe: -src: Quelladresse
           -dst: Zieladresse
           -bytes: Breite in Bytes
           -lines: Hîhe in Pixelzeilen
            
  Ausgabe: nichts
  
  Besonderes: nichts
-----------------------------------------------*/

void sublupe2(byte *src, unsigned *dst,
              int bytes, int lines)
{
  unsigned *nextline;
  int i,j,f;

  for (i = 0 ; i < lines ; i++)
  {
    nextline = dst;                
    for (j = 0 ; j < bytes ; j++)  
      *dst++ = zweifach[*src++];
    for (j = 0 ; j < bytes ; j++)
      *dst++ = *nextline++;
  }
}

/*-----------------------------------------------
  Funktion sublupe4
  
  Aufgabe: Ausschnitt in x- und y-Richtung 
           von src nach dst vierfach vergrîûern
           
  Eingabe: -src: Quelladresse
           -dst: Zieladresse
           -bytes: Breite in Bytes
           -lines: Hîhe in Pixelzeilen
            
  Ausgabe: nichts
  
  Besonderes: nichts
-----------------------------------------------*/

void sublupe4(byte *src, unsigned long *dst, int 
bytes, int lines)
{
  unsigned long *nextline;
  int i,j,k,f;
  
  for (i = 0 ; i < lines ; i++)
  {
    nextline = dst;  
    for (j = 0 ; j < bytes ; j++)
      *dst++ = vierfach[*src++];
    for (j = 0 ; j <= 2 ; j++)
    {     
      for (k = 0 ; k < bytes ; k++)
        *dst++ = *nextline++;
      nextline -= bytes;
    }
  }
}

/*-----------------------------------------------
  Funktion sublupe8
  
  Aufgabe: Ausschnitt in x- und y-Richtung 
           von src nach dst achtfach vergrîûern
           
  Eingabe: -src: Quelladresse
           -dst: Zieladresse
           -bytes: Breite in Bytes
           -lines: Hîhe in Pixelzeilen
            
  Ausgabe: nichts
  
  Besonderes: nichts
-----------------------------------------------*/

void sublupe8(byte *src, unsigned long *dst, int 
bytes, int lines)
{
  unsigned long *nextline,*ptr;
  int i,j,k;
  int offset = bytes * 2;
  
  for (i = 0 ; i < lines ; i++)
  {
    nextline = dst;
    for (j = 0 ; j < bytes ; j++)
    {
      ptr = &achtfach[(unsigned)(*src++) * 2];  
      *dst++ = *ptr++;                          
      *dst++ = *ptr;
    }
    for (j = 0 ; j <= 5 ; j++)
    {                                   
      for (k = 0 ; k < bytes ; k++) 
      {
        *dst++ = *nextline++;
        *dst++ = *nextline++;
      }
      nextline -= offset;
    }
    for (k = 0 ; k < bytes ; k++) 
    {
      *dst++ = 0L;     /* weiûes Gitter */
      *dst++ = 0L;
    }
  }
}

/*---------------------------------------
    Funktion align
    
    Aufgabe:  x auf den nÑchsten durch
              n teilbaren Wert setzen
              
    Eingabe: - x: zu setzender Wert
              - n: Teiler
    
    Ausgabe: - x auf den nÑchsten durch n
               teilbaren Wert gesetzt
      
    Besonderes: nichts
---------------------------------------*/    

int align(int x,int n)
{
   x += (n >> 1) - 1;  
   x = n * (x / n);
   return x;
}       

/*------------------------------------
  Funktion nothing
  
  Aufgabe: Dummy-Funktion
------------------------------------*/  

void nothing(byte *src, void *dst, int bytes,
             int lines)
{
  return;
}

/*------------------------------------------
  Funktion open_work               
                                   
  Aufgabe: GEM-Initialisierung,    
           erweiterte Workstation-Info      
           holen                              
                                   
  Eingabe: -form: Zeiger auf MFBD-Strukur,      
            die auf Bildschirm gesetzt wird     
                                   
  Ausgabe: vdi_handle              
                                   
  Besonderes:  Programmabbruch, falls keine     
               Workstation geîffnet
               werden kann 
------------------------------------------*/  

int open_work(MFDB *form)
{
  int x;
  int work_in[11];
  int vdi_handle;

  for(x = 0; x < 10; work_in[x++] = 1)
    ;
  work_in[10] = 2;

  aes_handle = graf_handle(&zw,&zh,&cw,&ch);
  vdi_handle = work_in[0] = aes_handle;
  v_opnvwk(work_in, &vdi_handle, work_out);

  if (vdi_handle == 0) /* keine Workstation */
  {
    Cconws("\033E Error: GEM-Initialisierung"
           "nicht mîglich!");
    Bconin(2);
    exit(1);
  }
  form->fd_addr = NULL;
    /* erweiterte  Parameter fÅr Farbebenen */
  vq_extnd(vdi_handle,1,work_out_ext);
  return vdi_handle;    /* alles OK */
}

/*-------------------------------------------
  Funktion init_mfdb               
                                   
  Aufgabe:  fÅllt eine MFDB-Struktur     
                                   
  Eingabe: -block: Zeiger auf MFDB-Strukur, die  
            gefÅllt wird                    
           -breite: Rasterbreite in Pixel        
   
           -hoehe: Rasterhîhe in Pixel           
  
           -flag: TRUE = Rasteradresse auf  
            durch 256 teilbare Adresse setzen
            (fÅr Setscreen)                      
                                   
  Ausgabe: 1 = ok, 0 = Fehler      
                                   
  Besonderes: nichts               
-------------------------------------------*/

int init_mfdb(MFDB *block,int breite,int hoehe,
              int flag)
{
  int farbebenen = work_out_ext[4];
  
  hoehe++;
  if(breite & 0xf) 
     breite += (0x10 - breite & 0xf);
  block->fd_addr = 
     (char *)malloc((flag ? 256L : 0L) +
     ((long)hoehe * (long)(breite >> 3) *
     (long)farbebenen));
  if (block->fd_addr == NULL)
      return FALSE;  
       /* evtl. Adresse anpassen */
  if (flag)     
    if ((long)block->fd_addr & 0xff)
      (long)block->fd_addr += 
      (0x100 - (long)block->fd_addr & 0xff);
  block->fd_w = breite;
  block->fd_h = hoehe;
  block->fd_wdwidth = breite >> 4;
  block->fd_stand = 0;
  block->fd_nplanes = farbebenen;
  return TRUE;
}

