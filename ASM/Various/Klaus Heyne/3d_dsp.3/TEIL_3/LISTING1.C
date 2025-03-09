/*---------------------------------------------*/
/* DSP als Grafik-Koprozesser:                 */
/*                  3D-Grafik-Transformationen */
/* Host-Programm                               */
/*                  (c) 1995 by MAXON-Computer */
/*                  Autor: Klaus Heyne         */
/*---------------------------------------------*/
                                                 
#define POLYEXT 0         /* Compilerdirektive:  
       1=externe TC-Polyfill-Routine vorhanden */
#include <stdio.h>                               
#include <tos.h>                                 
#include <stdlib.h>                              
#include <stdio.h>                               
#include <aes.h>                                 
#include <vdi.h>                                 
#include <math.h>                                
                                                 
#define MAXP     2000   /* entspricht ungefÑhr */ 
#define MAXFL    2000  /* d. DSP Speicherplatz */
                                                 
void load_3D(char *name);        /* Funktions- */     
void init_3D(void);              /* prototypen */      
int user_action(void);                           
void draw_objc(void);                            
void switch_scr(void);                           
void make_sin(int mode);                         
                                                 
extern long vbl_init(void);      /* Assembler- */     
extern long vbl_exit(void);        /* Routinen */       
                                                 
void vdi_polyfill(struct polygon *pdb);          
void vdi_polyline(struct polygon *pdb);          
                                                 
   #if POLYEXT                                   
extern void polyfill(struct polygon *pdb);       
   #endif                                        
                           /* Funktionspointer */    
void (*poly_sub)(struct polygon *pdb);           
                          /* globale Variablen */    
int demo,demo_r,dir=2,move_val=0;                
int modecode,scancode,clr_val;                   
int clrflag,zeit,v_handle;                       
long *screen0,*screen1,*oldlog,scrsize;          
int oldcol[3];                                   
                                                 
                              /* DSP-Kommandos */       
char init_cmd[4] = { 0x00, 0x00, 0x01, 0 };      
char para_cmd[4] = { 0x00, 0x00, 0x02, 0 };      
char recv_cmd[4] = { 0x00, 0x01, 0x00, 0 };      
                                                 
char dsp_memo[5000];   /* DSP-Programmspeicher */
char dsp_file[16] = "3D_TC.LOD";               
                                                 
struct polygon         /* Definitionsblock fÅr */
   {                       /* polyfill-Routine */    
   int intern[5];                                
   int p_count;                 /* Eckenanzahl */      
   int ymin, ymax;                               
   unsigned int tc_color; /* 16 Bit True-Color */
   long *logbase;          /* aktuelle logbase */ 
   int linebyte;            /* Bytes pro Zeile */  
   int clip[4];                    /* Clipping */         
   int xy_array[48];       /* Koordinatenarray */ 
   int intbuff[32];         /* interner Puffer */  
   } PDB;                                        
                                                 
typedef struct        /* 3DX-Objektfile-Header */
   {                                             
   char _3dx[4];             /* Format-Kennung */     
   char form_1[6];             /* Format-Infos */       
   int form_2[3];                                
/* -------------------* Objektwelt-Konstanten: */
   int anzpkt;           /* Anzahl der Punkte, */
   int anzfla;                  /* FlÑchen und */       
   int anzobj;                      /* Objekte */           
   int unused1;                                  
   int zmax;          /* Clip fÅr 3. Dimension */
   int xmit, ymit;          /* Bildschirmmitte */    
   int p_size, f_size;  /* DatenlÑnge in words */
   int unused2[7];                               
/*---------------------* Objektwelt-Parameter: */
   int bbx, bby, bbz;    /* Beobachterposition */
   int xw, yw, zw;                /* u. Winkel */
   int projektz;          /* Lage Projektions- */
   int ebenez;           /* zentrum und -ebene */
   unsigned int litefak;    /* Licht-Schatten- */
   unsigned int liteoffs; /* Kontrastparameter */
   unsigned int backcol;   /* Hintergrundfarbe */
   int unused3[4];                               
   int doflag;         /* hier: Demo-Steuerung */
   } file_3DX;                                   
                                                 
             /* Wenn kein 3D-File geladen wird, 
                 ATARI-Logo als Default-Objekt */
file_3DX ob =                                    
   {                            /* File-Header */        
      { "3DX " },                                
      { 0,1,0,0,3,1 },                           
      { 15,2,16 },                               
      81,74,1,0,-200,160,120,243,518,            
      { 0,0,0,0,0,0,0 },                         
      -441,80,493,0,40,0,-200,-400,              
      0x4000,0x4000,0x0000,                      
      { 0,0,0,0 }, 0                             
   };                                            
                                                 
int welt[MAXP*3] =         /* Welt-Koordinaten */   
   {                                             
   5792,-69,-32,-32,-69,-73,-36,-36,-73,-83,-48, 
   -48,-83,-99,-71,-71,-99,-120,-100,-100,-120,  
   -144,-133,-133,-144,-170,-170,-170,-170,-32,  
   -67,-32,-67,69,32,32,69,73,36,36,73,83,48,48, 
   83,99,71,71,99,120,100,100,120,144,133,133,   
   144,170,170,170,170,32,67,32,67,-24,24,24,-24,
   -24,24,24,-24,-24,24,-24,24,-24,24,-24,24,    
                                                 
   5792,168,168,168,168,138,126,126,138,108,     
   84,84,108,84,50,50,84,65,23,23,65,53,6,6,53,  
   48,0,0,48,252,252,252,252,168,168,168,168,138,
   126,126,138,108,84,84,108,84,50,50,84,65,23,  
   23,65,53,6,6,53,48,0,0,48,252,252,252,252,84, 
   84,0,0,84,84,0,0,168,168,168,168,252,252,252,
   252,
                                              
   5792,-30,-30,30,30,-30,-30,30,30,-30,         
   -30,30,30,-30,-30,30,30,-30,-30,30,30,-30,-30,
   30,30,-30,-30,30,30,30,30,-30,-30,-30,-30,30, 
   30,-30,-30,30,30,-30,-30,30,30,-30,-30,30,30, 
   -30,-30,30,30,-30,-30,30,30,-30,-30,30,30,30, 
   30,-30,-30,30,30,30,30,-30,-30,-30,-30,30,30, 
   -30,-30,30,30,-30,-30                         
   };                                            
                                                 
                            /* FlÑchenstruktur */
int wflach[MAXFL*10] =                           
 {                    /* RGB,Code|Ecken,Indize */
 0xFBCF,4,1,5,6,2,1,0xFBCF,4,2,6,7,3,2,          
 0xFBCF,4,3,7,8,4,3,0xFBCF,4,4,8,5,1,4,          
 0xFBCF,4,5,9,10,6,5,0xFBCF,4,6,10,11,7,6,       
 0xFBCF,4,7,11,12,8,7,0xFBCF,4,8,12,9,5,8,       
 0xFBCF,4,9,13,14,10,9,0xFBCF,4,10,14,15,11,10,  
 0xFBCF,4,11,15,16,12,11,0xFBCF,4,12,16,13,9,12, 
 0xFBCF,4,13,17,18,14,13,0xFBCF,4,14,18,19,15,14,
 0xFBCF,4,15,19,20,16,15,0xFBCF,4,16,20,17,13,16,
 0xFBCF,4,17,21,22,18,17,0xFBCF,4,18,22,23,19,18,
 0xFBCF,4,19,23,24,20,19,0xFBCF,4,20,24,21,17,20,
 0xFBCF,4,21,25,26,22,21,0xFBCF,4,22,26,27,23,22,
 0xFBCF,4,23,27,28,24,23,0xFBCF,4,24,28,25,21,24,
 0xFBCF,4,28,27,26,25,28,0xFBCF,4,29,3,4,30,29,  
 0xFBCF,4,2,31,32,1,2,0xFBCF,4,29,30,32,31,29,   
 0xFBCF,4,30,4,1,32,30,0xFBCF,4,3,29,31,2,3,     
 0x7D5F,4,33,34,38,37,33,0x7D5F,4,34,35,39,38,34,
 0x7D5F,4,35,36,40,39,35,0x7D5F,4,36,33,37,40,36,
 0x7D5F,4,37,38,42,41,37,0x7D5F,4,38,39,43,42,38,
 0x7D5F,4,39,40,44,43,39,0x7D5F,4,40,37,41,44,40,
 0x7D5F,4,41,42,46,45,41,0x7D5F,4,42,43,47,46,42,
 0x7D5F,4,43,44,48,47,43,0x7D5F,4,44,41,45,48,44,
 0x7D5F,4,45,46,50,49,45,0x7D5F,4,46,47,51,50,46,
 0x7D5F,4,47,48,52,51,47,0x7D5F,4,48,45,49,52,48,
 0x7D5F,4,49,50,54,53,49,0x7D5F,4,50,51,55,54,50,
 0x7D5F,4,51,52,56,55,51,0x7D5F,4,52,49,53,56,52,
 0x7D5F,4,53,54,58,57,53,0x7D5F,4,54,55,59,58,54,
 0x7D5F,4,55,56,60,59,55,0x7D5F,4,56,53,57,60,56,
 0x7D5F,4,60,57,58,59,60,0x7D5F,4,61,62,36,35,61,
 0x7D5F,4,34,33,64,63,34,0x7D5F,4,61,63,64,62,61,
 0x7D5F,4,62,64,33,36,62,0x7D5F,4,35,34,63,61,35,
 0x7FCF,4,65,66,67,68,65,0x7FCF,4,72,71,70,69,72,
 0x7FCF,4,66,70,71,67,66,0x7FCF,4,67,71,72,68,67,
 0x7FCF,4,68,72,69,65,68,0x7FCF,4,73,74,66,65,73,
 0x7FCF,4,69,70,76,75,69,0x7FCF,4,74,76,70,66,74,
 0x7FCF,4,65,69,75,73,65,0x7FCF,4,77,78,74,73,77,
 0x7FCF,4,75,76,80,79,75,0x7FCF,4,77,79,80,78,77,
 0x7FCF,4,78,80,76,74,78,0x7FCF,4,73,75,79,77,73 
 };                                              
                                                 
int *fladress[MAXFL];  /* FlÑchen-Zeiger-Array */
int fla_list[MAXFL*3+1]; /* Empfangs-Arrays f. */
int plot[MAXP*2+9];        /* DSP-Ausgabewerte */
                                                 
int *weltx, *welty, *weltz; /* Zeiger auf Welt-*/
int *xplot, *yplot;   /* und Schirmkoordinaten */
                      /* Zeiger auf Richtungs- */
int *move_abs[3];   /* komponenten f. Bewegung */
                                                 
long sintab[360];              /* Sinustabelle */                           
                                                 
void send_init(void)     /* DSP initialisieren */   
   {                 /* Objektweltdaten senden */
   Dsp_BlkHandShake(init_cmd,1L,NULL,0L);        
   Dsp_BlkUnpacked(sintab,360L,NULL,0L);         
   Dsp_BlkWords(&ob.anzpkt,16L,NULL,0L);         
   Dsp_BlkWords(wflach,(long)ob.f_size,NULL,0L); 
   Dsp_BlkWords(welt,(long)ob.p_size,NULL,0L);   
   }                                             
                                                 
void send_par(void)       /* DSP aktualisieren */    
   {                   /* Parameter Åbertragen */ 
   Dsp_BlkHandShake(para_cmd,1L,NULL,0L);        
   Dsp_BlkWords(&ob.bbx,16L,NULL,0L);            
   }                                             
                                                 
void recv_data(void) /* Daten v. DSP empfangen */
   {                                             
   Dsp_BlkHandShake(recv_cmd,1L,NULL,0L);        
   Dsp_BlkWords(NULL,0L,plot,                    
                     (long)ob.anzpkt*2+9);       
   Dsp_BlkWords(NULL,0L,fla_list,                
                     (long)ob.anzfla*3+1);       
   }                                             
                                                 
void gem_init(void)   /* GEM-Programm anmelden */ 
   {                                             
   int i;                                        
   int work_in[12], work_out[57];                
   int zb,zh,bb,bh;                              
                                                 
   appl_init();                                  
   v_handle=work_in[0] =                         
                   graf_handle(&zb,&zh,&bb,&bh); 
   for(i=0; i<10; i++) work_in[i]=1;             
   work_in[10]=2;                                
   v_opnvwk(work_in,&v_handle,work_out);         
                   /* Clipping-Daten speichern */ 
   PDB.clip[0] = PDB.clip[1] = 0;                
   PDB.clip[2] = work_out[0];                    
   PDB.clip[3] = work_out[1];                    
            /* Bytes/Zeile fÅr polyfill extern */ 
   PDB.linebyte = (work_out[0]+1)<<1;            
   v_hide_c(v_handle);             /* Maus aus */   
   }                                             
                                                 
void gem_exit(void)   /* GEM-Programm abmelden */ 
   {                                             
   v_show_c(v_handle,0);                         
   v_clsvwk(v_handle);                           
   appl_exit();                                  
   }                                             
                                                 
int graf_init(void)   /* Grafik initialisieren */ 
   {                                             
   long scr;                                     
                                                 
/* Video-Modus erfragen (nur True-Color) */      
   if (((modecode = setmode(-1)) & 7) !=4)       
      return(-1);                                
                                                 
/* Video-RAM-Grîûe erfragen und                  
   zweiten Bildschirm anlegen */                 
   scrsize = xbios(91,modecode);                 
   if ((scr = Malloc(scrsize+256)) <= 0)         
      return(-1);                                
   screen1 = (scr+256) & 0x7FFFFF00;             
   oldlog = screen0 = Logbase();                 
   switch_scr();                                 
                                                 
/* VBL-Routine installieren */                   
   if (Supexec(vbl_init))                        
      return(-1);                                
                                                 
/* VDI-Grundeinstellungen. Es wird immer mit der 
   VDI-Farbe Nr. 253 gearbeitet. Der gewÅnschte  
   Farbton wird vor dem Zeichnen durch Setzen der
   Palette mit "vs_color" eingestellt */         
   vq_color(v_handle,253,1,oldcol);              
   vsf_color(v_handle,253);       /* FÅll- und */   
   vsl_color(v_handle,253);     /* Linienfarbe */  
   vsf_perimeter(v_handle,0); /* Umrandung aus */
   vs_clip(v_handle,1,PDB.clip);   /* Clipping */  
                                                 
/* Default-Zeichenfunktion v_fillarea des VDI */ 
   poly_sub=vdi_polyfill;                        
   return(0);                                    
   }                                             
                                                 
void graf_exit(void)                             
   {                                             
   Supexec(vbl_exit);                            
   Setscreen(oldlog,oldlog,-1);                  
   vs_color(v_handle,253,oldcol);                
   }                                             
                                                 
/* Hauptprogramm mit Kommandozeilenauswertung */ 
                                                 
int main(int argc,char **argv)                   
   {                                             
   int ende = 0;                                 
   int ability, len;                             
                                                 
   gem_init();                                   
   if (graf_init())                              
      {                                          
      form_alert(1,"[3][ |Fehler bei Grafik-"    
                   "|Installierung! ][ EXIT ]"); 
      gem_exit();                                
      return(1);                                 
      }                                          
   if (Dsp_Lock())                               
      {                                          
      form_alert(1,"[3][ |DSP ist gesperrt! ]"   
                   "[ EXIT ]");                  
      gem_exit();                                
      return(1);                                 
      }                                          
                                                 
/* Sinustabelle fÅr DSP erstellen */             
   make_sin(1);                                  
                                                 
/* DSP-Programm laden und starten */             
   ability = Dsp_RequestUniqueAbility();         
   len = Dsp_LodToBinary(dsp_file,dsp_memo);     
   Dsp_ExecProg(dsp_memo,len,ability);           
                                                 
/* Kommandozeile als Filename interpretieren */  
   if (argc==2)                                  
      load_3D(*(argv+1));                        
                                                 
/* Daten initialisieren und zum DSP senden */    
   init_3D();                                    
   send_init();                                  
   send_par();                                   
                                                 
   make_sin(0);     /* Sin-Tabelle skalieren */  
                                                 
/* Hauptschleife bis Programm-Abbruch [Q] */     
   do                                            
      {                                          
      while (Dsp_Hf2());       /* DSP fertig ? */   
      recv_data();            /* Daten abholen */  
      ende = user_action();  /* Benutzeraktion */ 
      send_par();            /* Parameter->DSP */ 
      draw_objc();         /* Objekte zeichnen */ 
      } while(!ende);                            
                                                 
/* Alles abmelden und Programm verlassen */      
   graf_exit();                                  
   Dsp_Unlock();                                 
   gem_exit();                                   
   return(0);                                    
   }                                             
                                                 
/* Objektwelt zeichnen */                        
                                                 
void draw_objc(void)                             
   {                                             
   int *f_list=fla_list;                         
   int *x_ptr=xplot;                             
   int *y_ptr=yplot;                             
   int *f_ptr, *pxy;                             
   int i, x, y, r, p_index, p_anz, f_code;       
                                                 
/* akt. Logbase in Polygon-Definitionsblock */   
   PDB.logbase = screen1;                        
                                                 
/* Warten, bis Bildschirm gelîscht ist */        
   while (clrflag);                              
                                                 
/* FÅr jede sichtbare FlÑche PDB belegen */      
   i=*f_list++;                                  
   while(i>0)                                    
      {                                          
      f_list++;                                  
      PDB.tc_color=*f_list++;      /* Farbwert */    
                                                 
/* Zeiger auf FlÑchenstruktur Åber Index holen */
      f_ptr=fladress[*f_list++];                 
      f_ptr++;                                   
                                                 
/* Code und Eckenanzahl aus FlÑchenstruktur */   
      f_code = *f_ptr++;                         
      p_anz=f_code & 0xF;       /* Eckenanzahl */     
      PDB.p_count=p_anz;                         
      pxy=PDB.xy_array;                          
                                                 
/* öber die Punktindize der FlÑchenstruktur die  
   Bildschirmkoordinaten holen, ins Koordinaten- 
   array Åbertragen und das Polygon zeichnen */  
      while(p_anz>=0)                            
         {                                       
         p_index = *f_ptr++;                     
         *pxy++ = *(x_ptr + p_index);            
         *pxy++ = *(y_ptr + p_index);            
         p_anz--;                                
         }                                       
      if (f_code & 0x10)                         
         vdi_polyline(&PDB);                     
      else                                       
         (*poly_sub)(&PDB);                      
      i--;                /* nÑchste FlÑche... */
      }                                          
/* Bildschirmseiten wechseln */                  
   switch_scr();                                 
   }                                             
                                                 
/* Aus 16-Bit-Falcon-True-Color RGB-Komponenten  
   extrahieren, ins VDI-Format umrechnen         
   und Palette setzen */                         
void set_color(unsigned int tc)                  
   {                                             
   int rgb[3];                                   
                                                 
   rgb[0] = (tc >> 6) & 0x3E0;                   
   rgb[1] = (tc >> 1) & 0x3E0;                   
   rgb[2] = (tc & 0x1F) << 5;                    
   vs_color(v_handle,253,rgb);                   
   }                                             
                                                 
/* Polygon-Routinen des VDI */                   
                                                 
void vdi_polyline(struct polygon *pdb)           
   {                                             
   set_color(pdb->tc_color);                     
   v_pline(v_handle,                             
              pdb->p_count+1,pdb->xy_array);     
   }                                             
                                                 
void vdi_polyfill(struct polygon *pdb)           
   {                                             
   set_color(pdb->tc_color);                     
   v_fillarea(v_handle,                          
              pdb->p_count+1,pdb->xy_array);     
   }                                             
                                                 
/* Rotationsdemos initialisieren */              
                                                 
void demo_init(int demo)                         
   {                                             
   long bx = (long)ob.bbx;                       
   long by = (long)ob.bby;                       
   long bz = (long)ob.bbz;                       
                                                 
   if (demo & 1)                                 
      demo_r=(int)(sqrt(bx*bx+bz*bz));           
   else                                          
      {                                          
      demo_r=(int)(sqrt(bx*bx+by*by+bz*bz));     
      ob.bbx = ob.bby = ob.xw = ob.yw = 0;       
      ob.bbz = demo_r;                           
      }                                          
   }                                             
                                                 
/* Rotationsdemos in Gang halten */              
                                                 
void make_demo(int demo)                         
   {                                             
   register int a;                               
                                                 
   if (demo & 1)                                 
      {                                          
      a = ob.yw-1;                               
      ob.yw = (a<0) ? a+360 : a;                 
      ob.bbx=(int)(-(sintab[ob.yw]*demo_r)>>14); 
      a = (ob.yw>=270) ? ob.yw-270 : ob.yw+90;   
      ob.bbz=(int)((sintab[a]*demo_r)>>14);      
      }                                          
   if (demo & 2)                                 
      {                                          
      a = ob.xw+1;                               
      ob.xw = (a>=360) ? a-360 : a;              
      ob.bby=(int)((sintab[ob.xw]*demo_r)>>14);  
      a = (ob.xw>=270) ? ob.xw-270 : ob.xw+90;   
      ob.bbz=(int)((sintab[a]*demo_r)>>14);      
      }                                          
   if (demo & 4)                                 
      {                                          
      a = ob.zw+3;                               
      ob.zw = (a>=360) ? a-360 : a;              
      }                                          
   }                                             
                                                 
/* Beobachterposition weiterbewegen */           
                                                 
void move_bb(int move_val,int *move_dir,int *pbb)
   {                                             
   if (move_val == 1)                            
      {                                          
      *pbb++ += *move_dir++;                     
      *pbb++ += *move_dir++;                     
      *pbb += *move_dir;                         
      }                                          
   else if (move_val == -1)                      
         {                                       
         *pbb++ -= *move_dir++;                  
         *pbb++ -= *move_dir++;                  
         *pbb -= *move_dir;                      
         }                                       
   }                                             
                                                 
/* Tastatursteuerung:                            
    |Cursor|Ins|Clr|: Blickwinkel verÑndern      
   Zahlenblock |8|5|: Bewegung vor und zurÅck,   
               |4|6|: seitwÑrts,                 
               |7|9|: ab- und aufwÑrts           
                 |0|: Bewegung/Demo stoppen      
               |/|*|: Licht-Schatten-Kontrast    
               |(|)|: Brennpunkt verÑndern       
               |-|+|: Zoom                       
       |F 1|...|F 4|: Rotationsdemos             
               |F 5|: Licht-Rotation             
               |F 6|: Linien Polygone VDI        
               |F 7|: gefÅllte-Polygone VDI      
               |F 8|: gefÅllte-Polygone ASSEMBLER
             |Space|: Licht-Rotation stoppen     
         |Backspace|: Bildfrequenz ausgeben      
                 |Q|: Quit */                    
                                                 
int user_action(void)                            
   {                                             
   register int a;                               
   int exitflag=0;                               
   int len;                                      
   char freq_out[64];                            
                                                 
   if (demo)                                     
      make_demo(demo);                           
   else                                          
      move_bb(move_val, move_abs[dir], &ob.bbx); 
                                                 
   switch(scancode)                              
      {                                          
      case 0x48: a = ob.xw+1;                    
                 ob.xw=(a>=360) ? a-360 : a;     
                 break;                          
      case 0x50: a = ob.xw-1;                    
                 ob.xw=(a<0) ? a+360 : a;        
                 break;                          
      case 0x4D: a = ob.yw+1;                    
                 ob.yw=(a>=360) ? a-360 : a;     
                 break;                          
      case 0x4B: a = ob.yw-1;                    
                 ob.yw=(a<0) ? a+360 : a;        
                 break;                          
      case 0x52: a = ob.zw+1;                    
                 ob.zw=(a>=360) ? a-360 : a;     
                 break;                          
      case 0x47: a = ob.zw-1;                    
                 ob.zw=(a<0) ? a+360 : a;        
                 break;                          
      case 0x68: dir = 2; move_val = 1;          
                 break;                          
      case 0x6B: dir = 2; move_val = -1;         
                 break;                          
      case 0x6C: dir = 0; move_val = 1;          
                 break;                          
      case 0x6A: dir = 0; move_val = -1;         
                 break;                          
      case 0x69: dir = 1; move_val = 1;          
                 break;                          
      case 0x67: dir = 1; move_val = -1;         
                 break;                          
      case 0x70: move_val = demo = 0;            
                 break;                          
      case 0x63: ob.projektz-=20;                
                 break;                          
      case 0x64: ob.projektz+=20;                
                 break;                          
      case 0x4A: ob.ebenez+=20;                  
                 break;                          
      case 0x4E: ob.ebenez-=20;                  
                 break;                          
      case 0x65: a = ob.litefak - 0x100;         
                 ob.litefak=                     
                 (a<0x1000) ? 0x1000 : a;        
                 ob.liteoffs=0x8000-ob.litefak;  
                 break;                          
      case 0x66: a = ob.litefak + 0x100;         
                 ob.litefak=                     
                 (a>0x7F00) ? 0x7F00 : a;        
                 ob.liteoffs=0x8000-ob.litefak;  
                 break;                          
      case 0x3B: demo = 1;                       
                 demo_init(demo);                
                 break;                          
      case 0x3C: demo = 2;                       
                 demo_init(demo);                
                 break;                          
      case 0x3D: demo = 5;                       
                 demo_init(demo);                
                 break;                          
      case 0x3E: demo = 6;                       
                 demo_init(demo);                
                 break;                          
      case 0x3F: ob.doflag |= 0x10;              
                 break;                          
      case 0x40: poly_sub=vdi_polyline;          
                 break;                          
      case 0x41: poly_sub=vdi_polyfill;          
                 break;                          
#if POLYEXT                                      
      case 0x42: poly_sub=polyfill;              
                 break;                          
#endif                                           
      case 0x0E: if (zeit) zeit = 200/zeit;      
                 Setscreen(screen0,screen0,-1);  
           sprintf(freq_out,"[0][ Bildfrequenz:|"
           "%d Bilder/sec. ][ OK ]",zeit); 
                 form_alert(1,freq_out);         
                 Setscreen(screen1,screen0,-1);  
                 break;                          
      case 0x39: ob.doflag &= 0x6;               
                 break;                          
      case 0x10: exitflag = 1;                   
                 break;                          
      }                                          
   return ( exitflag );                          
   }                                             
                                                 
/* 3DX-Objektfile laden */                       
                                                 
void load_3D(char *name)                         
   {                                             
   int f_handle;                                 
                                                 
   if ((f_handle=Fopen(name,0))>0)               
      {                                          
      Fread(f_handle,80L,&ob);                   
      Fread(f_handle,(long)ob.p_size*2,welt);    
      Fread(f_handle,(long)ob.f_size*2,wflach);  
      Fclose(f_handle);                          
      }                                          
   }                                             
                                                 
/* 3D-Objektwelt-Daten initialisieren */         
                                                 
void init_3D(void)                               
   {                                             
   int *pi;                                      
   int i, j, i2;                                 
   long k;                                       
                                                 
/* Zeiger auf jede FlÑche speichern */           
   pi = wflach;                                  
   for (i=0; i<ob.anzfla; i++)                   
      {                                          
      fladress[i] = pi;                          
      pi++;                                      
      j=(*pi++) & 0x0F;                          
      j++;                                       
      pi+=(long)(j);                             
      }                                          
                                                 
/* Zeiger auf Koordinatenarrays speichern */     
   k = (long)ob.anzpkt;                          
   pi = welt;                                    
   weltx = pi; pi += k;                          
   welty = pi; pi += k;                          
   weltz = pi; pi += k;                          
   pi = plot;                                    
   xplot = pi; pi += k;                          
   yplot = pi; pi += k;                          
   move_abs[0] = pi; pi += 3;                    
   move_abs[1] = pi; pi += 3;                    
   move_abs[2] = pi;                             
                                                 
   clr_val = ob.backcol; /* Lîsch-Word fÅr VBL */
   demo = 1;                 /* Demo 1 starten */
   demo_init(demo);                              
   ob.xmit = (PDB.clip[2]+1) >> 1;
   ob.ymit = (PDB.clip[3]+1) >> 1;
   }                                             
                                                 
void switch_scr(void)  /* Bildschirme tauschen */
   {                                             
   long *swap;                                   
                                                 
   swap=screen0; screen0=screen1; screen1=swap;  
   Setscreen(screen1,screen0,-1);                

/* Flag fÅr VBL-Routine setzen: Screen lîschen */
   clrflag = 1;                                  
   }                                             
                                                 
/* Sinustabelle fÅr DSP erstellen (mode = 1) oder
   fÅr internen Gebrauch skalieren (mode = 0) */ 
                                                 
void make_sin(int mode)                          
   {                                             
   int i;                                        
   double winc;                                  
                                                 
   if (mode)                                     
      {                                          
      for (i=0; i<360; i++)                      
         {                                       
         winc = (M_PI * i) / 180;  /* rad->deg */
         sintab[i]=(long)(sin(winc) * 0x800000L);
         }                                       
      sintab[90] = 0x7FFFFFL; /* +1->+0.999999 */
      }                                          
   else                                          
      {                                          
      for (i=0; i<360; i++)                      
         sintab[i] >>= 9;                      
      sintab[90] = 0x4000;                       
      }                                          
   }                                             

