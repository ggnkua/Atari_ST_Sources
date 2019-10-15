#ifndef PIONIER
  #define PIONIER
#endif
/***********************************************************************/
/*                                                                     */          
/* B_NACH_C.H    BASIC-KONVERTER NACH C, Version 2.0  - HEADERFILE     */
/*                     (Pionier)                                       */
/*                                                                     */
/*               (C) - 1990/91 CICERO-Software, Telefon 06803-2834     */
/*                                                                     */
/***********************************************************************/

#include <portab.h>
#include <stdlib.h>
#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <math.h>
#include <ext.h>
#include <time.h>
#include <vdi.h>
#include <aes.h>
#include <tos.h>
#include <linea.h>
#include <signal.h>
#include <setjmp.h>

/* Globale Schalter - kînnen auch durch entsprechende Makefiles
   gesetzt werden */

/*
#define FLT
#define GEM
#define ERROR
*/
#define C_HAR  265         /* Maximale Stringgrîûe+8+1 : 256 Byte */
#define M_AXSP 65536L      /* Max. temp. Stringbuffer  : 64 KByte */

extern unsigned long MAXS; /* Longinteger Stringbuffer   (intern) */
extern unsigned long SMAX; /* Longinteger Speicherliste  (intern) */

extern char **SPEICHER;         /* Liste benutzter Speicherbereiche   */

extern void B_showm(void), B_hidem(void), B_dummy(void);

extern int DN;									/* DEFNUM-Variable				 */
extern int MF,MO;               /* Mouse-Variablen         */
extern int WF;                  /* Window-Flag             */
extern int POS,LPOS;            /* Positionen              */
extern int HTAB,VTAB,HT,VT;     /* Tabs                    */
extern int MZ,MS;               /* Max.Zeilen-/Spaltenzahl */ 
extern int VF,HF;               /* Buchstabenzelle         */
extern int HANDLE,OLDHANDLE;    /* Integer fÅr Handle      */
extern int AP_ID;								/* Applikationsnr des Prgs */
extern int B_WORK_OUT[];        /* Interne Workstation     */
int HANDLE2,*W_in,*W_out;       /* User-Workstation        */
int HFL;                        /* Hidden-Mouse-Flag       */
extern int BDF, ONBREAK, ERR;   /* Fehlervariablen         */
extern void (*Errorf)(void);    /* Fehlerroutine           */
extern unsigned char KEY_P;     /* KEYPRESS-Parameter      */  
extern char C_har[];            /* Feld fÅr INKEY          */
extern char KEY[20][32];        /* Funktionstasten-Buffer  */
unsigned char JOY0,JOY1;        /* Joystick-Koordinaten    */

/* GEM VDI - AES Parameter */

extern int PXYARRAY[];          /* Array fÅr Clipping  */
extern int Contrl[];            /* Control-Feld        */
extern int Intin[];             /* Intin-Feld          */
extern int Ptsin[];             /* Ptsin-Feld          */
extern int Intout[];            /* Intout-Feld         */
extern int Ptsout[];            /* Ptsout-Feld         */

typedef void (*PF)(void);       /* void - Pointerfeld  */
extern int OX,OY;               /* Grafik-Offset       */
extern void *Adr;               /* Adresse fÅr Super() */

/* FUNKTIONEN */

#define B_frac(x)      ((x) - B_trunc(x))
#define B_bmove(a,b,c) (B_hidem(),memcpy((void *)(b),(void *)(a),(long)c))
#define B_locate(s,z)  (VTAB = !(z) && !WF ? MZ : (int)(z),HTAB = !(s) && !WF ? MS : (int)(s))
#define B_cint(x)      ((long)(x))
#define B_cfloat(n)    ((double)(n))

/* GEM */

extern void B_alert(int icon,char *bt, int db, char *text, int *back);
extern void B_fileselect(char * ext, char *pfad, char *vor, char *back);

#define B_alert(i,b,d,t,bu)																					\
 (HFL=0,B_showm(),B_alert(i,b,d,t,&A), bu = A,B_hidem())
#define B_fileselect(ext,pfad,vor,back)															\
 (HFL=0,B_showm(),B_fileselect(ext,pfad,vor,back),B_hidem())
#define B_mouse(x,y,p)																							\
 (B_showm(), vq_mouse(HANDLE, &A, &B, &C), x = B - OX, y = C - OY, p = A)

/* WORKSTATION */

extern int B_open_workstation(void);

/* VDI - BITBLT ( vro_cpyfm() ) */

extern MFDB srcmfdb, destmfdb;


/* IN - OUTPUT */

#define B_chdir(a)        chdir(a)
#define B_kill(a)         remove(a)
#define B_name(a,b)       rename(a,b)

#define MALLOC(a)         (long) Malloc((long)(a))
#define MFREE(a)          Mfree((char *)(a))
#define MSHRINK(y,z)      Mshrink(0,(char *)(y),(z))

/* PEEK - POKE */

extern long ADR,B_Peek(void),B_Dpeek(void),B_Lpeek(void),B_Poke(void),B_Dpoke(void),B_Lpoke(void);
extern unsigned char B_cdata;
extern unsigned int  B_idata;
extern long B_ldata;

#define B_poke(x,y)   *(unsigned char *)(x) = ((unsigned char)(y))
#define B_dpoke(x,y)  *(unsigned int  *)(x) = ((unsigned int)(y))
#define B_lpoke(x,y)  *(long *)(x) = ((long)(y))
#define B_spoke(x,y)  (ADR = (long)(x),B_cdata = (y),Supexec(B_Poke))
#define B_sdpoke(x,y) (ADR = (long)(x),B_idata = (y),Supexec(B_Dpoke))
#define B_slpoke(x,y) (ADR = (long)(x),B_ldata = (y),Supexec(B_Lpoke))
#define B_peek(x)     (ADR = (long)(x), (unsigned char )Supexec(B_Peek))
#define B_dpeek(x)    (ADR = (long)(x), (unsigned int  )Supexec(B_Dpeek))
#define B_lpeek(x)    (ADR = (long)(x), (long )Supexec(B_Lpeek))


extern char *TEMP,*TEMPR[80],*TEMPA;
extern int  DUMMY,GM,OB;
extern unsigned long SP,BSP,ZL;         /* Indizes Speicherreservierung */
extern int A,B,C,D,E,F,G;               /* TemporÑre Integer            */
extern long TL1,TL2,TL3,TL4;            /* TemporÑre Long-Integer       */
extern int EMF;                         /* Integer fÅr ON MENU ...      */
extern int W_H[];                       /* Integerfeld fÅr Windows      */
extern long DAZ;                        /* Data-Zeilen                  */ 
extern void *HP,*HP2,*HP3;              /* Interne Hilfspointer         */

extern int *I_NT,*HPI;                  
extern char **P_P;                      
char  *P_;
extern FILE *FP[],*STDPRN;
extern char *HVP[];
extern int  HVA,HV[];                   /* Hilfsvariablen */
extern int  P_ARRAY[];                  /* Fensterkoordinaten */
extern OBJECT *HTREE,*M_tree;
extern MFORM *M_FORM;

/* GRAFIK */

extern void B_cls(void);
extern void B_boundary(int mode);
extern void B_deftext(int x, int y, int c, int d,int font);
extern void B_defline(long x, int y, int c, int d);
extern void B_defmark(int x, int y, int c);
extern void B_deffill(int x, int y, int d), B_fdeffill(int a,char *c);
extern void B_color(int a);
extern void B_setcolor(int r_egister, int mwert);
extern void B_graphmode(int mode);
extern void B_fdefmouse(int *a), B_defmouse(int a);
extern void B_draw(int xa, int ya, int xe, int ye);
extern void B_box(int x, int y, int c, int d);
extern void B_circle(int x, int y, int r,int w1,int w2);
extern void B_pcircle(int x, int y, int r,int w1,int w2);
extern void B_ellipse(int x, int y, int xr, int yr,int w1,int w2);
extern void B_pellipse(int x, int y, int xr, int yr,int w1,int w2);
extern void B_drawa(int mode, int xa, int ya);
extern void B_rbox(int x, int y, int c, int d);
extern void B_pbox(int x, int y, int c, int d);
extern void B_prbox(int x, int y, int c, int d);
extern void B_line(int xa, int ya,int xe,int ye);

#define B_fdefmouse(a)         B_fdefmouse((int *)(a))
#define B_fillpxy(p,a,b,ox,oy) \
	for(HVA=0;HVA<(p);HVA++)     \
		{                          \
		B_PTSIN[2*HVA]   = ((int) (a)[HVA] + (int)ox + OX); \
		B_PTSIN[2*HVA+1] = ((int) (b)[HVA] + (int)oy + OY); \
		}
#define B_polyline(p,a,b,ox,oy)\
  B_fillpxy((p),(a),(b),(ox),(oy));B_hidem();v_pline(HANDLE,(p),B_PTSIN)
#define B_polymark(p,a,b,ox,oy)\
  B_fillpxy((p),(a),(b),(ox),(oy));B_hidem();v_pmarker(HANDLE,(p),B_PTSIN)
#define B_polyfill(p,a,b,ox,oy)\
  B_fillpxy((p),(a),(b),(ox),(oy));B_hidem();v_fillarea(HANDLE,(p),B_PTSIN)

extern void B_fill(int x,int y,int farbe), B_plot(int x, int y);
extern int  B_mousex(void), B_mousey(void), B_mousek(void), B_point(int x, int y);
extern void B_setmouse(int mx,int my,int mk);
extern void B_sprite(char *adr,int x,int y);

/* STRING */

#define Strpoint(a) (char *)((a)-8)

extern void B_srealloc(char **str,char arr[],unsigned int max_l);
extern char *B_lrealloc(char arr[],unsigned int max_l);
extern char *B_ncpy(char dest[], char *src,unsigned int len);
extern unsigned long Zeile;
extern unsigned int  B_strlen(char *a);
extern int   B_strcmp(int modus,char *a,char *b);
extern char *B_strcpy(char *dest,char *source);
extern char *B_nsprintf(char *z,char *form,unsigned int len);
extern char *B_xstrcpy(char *dest,char *source,char *concat);
extern char *B_left(char * a, int b);
extern char *B_right(char *a, int b);
extern char *B_string(int zahl, char *s);
extern char *B_strcat(char * a, char *b);
extern void B_sprintf(char *z,char *form, ...);

extern void B_printf(int x,int y,char *form, ...);
extern char *B_trim(char *a);
extern char *B_mid(char *a,int b,int c);
extern void B_midncpy(char a[], int start, int n,char t[]);
extern char *B_lset(char *a, char *b);
extern char *B_rset(char *a, char *b);
extern char *B_hex(long a,int n), *B_oct(long a,int n), *B_bin(long a,int n);
extern char *B_chr(unsigned char a), *B_space(int a);
extern char *B_strupr(char *str);
extern char *B_time(void);
extern void B_openk(char *art,int fp,char *file,int satz);
extern char *B_spc(int a), *B_date(void);
extern char *B_itoab(int a,int b,int c);
extern char *B_utoab(unsigned int a,int b,int c);
extern char *B_ltoab(long a,int b,int c);
extern char *B_lutoab(unsigned long a,int b,int c);
extern char *B_ftoab(double a,int b,int c);
extern char *B_dpath(int a);
extern long B_btol(char *s), B_atol(char *a);
extern int  B_atoi(char *a);
extern void B_dir(int mode, char *src,char *dest);
extern int B_instr(int a,char *b,char *c);
extern int B_rinstr(int a,char *b,char *c);
extern void B_text(int x,int y,int laenge,char *c);
extern void B_sput(char *a), B_settime(char *zeit,char *datum);
extern double B_val(char *a);
extern int B_valf(char *a);
#define B_files(mode,src,dest) B_dir(mode,src,dest)

/* VERSCHIEDENES */


#define B_vdibase()       (long)&VPBk
#define B_relseek(n, anz) (void) fseek((n), (anz), 1)
#define B_asc(c)          *((unsigned char *)c)
#define B_timer()         (unsigned long) clock()
#define B_loc(n)          (long) ftell((n))
#define B_err()           ERR
#define B_delay(x)        B_pause(50*(x))

extern void B_defnum(int mode), B_exit(int mode), B_init(int mode);
extern void B_openr(char *a,int fp,char *file,long anz);
extern const char *B_an(char *b);
extern long B_himem(void);
extern void B_free(size_t s);
extern void B_arrayfill(int typ, long f, double wert);
extern void *B_arrptr(char *a), B_bget(FILE *a,long b,long c);
extern void B_bput(FILE *a,long b,long c), B_stop(void);
extern void B_bsave(char *a,long b,long c), B_print_at(int a,int b);
extern void B_bload(char *a, long b);
extern void B_clear(void), B_clr(char *a);

extern void B_seek(FILE *a,long anz), B_chdrive(int drive), B_super(int a);
extern void B_pause(long a);
extern unsigned long B_dfree(int n), B_fre(int n);
extern unsigned long B_lof(FILE *a);
extern unsigned char B_fgetc(FILE *a);
extern int  B_fgeti(FILE *a);
extern long B_fgetl(FILE *a);
extern void B_fputc(unsigned char c,FILE *fp);
extern void B_fputi(int  c,FILE *fp);
extern void B_fputl(long c,FILE *fp);
#define B_fread(pointer,size,count,fp) (((HVA=fread(pointer,size,count,fp)) < count) ? (ERR=26,ungetc(HVA,fp),B_fehler(fp,0,3),0) : HVA)
#define B_fseek(fp,off,mode) (((HVA=fseek(fp,off,mode)) != 0) ? (ERR=-6,ungetc(HVA,fp),B_fehler(fp,1,-6),0) : HVA)

extern int  B_exist(char *a);
extern void B_fclose(int fp);
extern char *B_inkey(void);
extern unsigned char B_inp(int a);
extern int  B_inpi(int a);
extern long B_inpl(int a);
extern char *B_mki(unsigned int a);
extern char *B_mkl(unsigned long a);
extern char *B_mks(float a);
extern char *B_mkf(double a);
extern char *B_mkd(double a);
#define B_mki(a) B_mki((unsigned int)(a))
#define B_mkl(a) B_mkl((unsigned long)(a))
#define B_mks(a) B_mks((float)(a))
#define B_mkf(a) B_mkf((double)(a))
#define B_mkd(a) B_mkd((double)(a))
extern unsigned int B_cvi(unsigned char *a);
extern unsigned long B_cvl(unsigned char *a);
extern float B_cvs(unsigned char *a);
extern double B_cvf(unsigned char *a);
extern double B_cvd(unsigned char *a);
#define B_cvi(a) B_cvi((unsigned char *)(a))
#define B_cvl(a) B_cvl((unsigned char *)(a))
#define B_cvs(a) B_cvs((unsigned char *)(a))
#define B_cvf(a) B_cvf((unsigned char *)(a))
#define B_cvd(a) B_cvd((unsigned char *)(a))
extern void B_fehler(FILE *fp,int mode,int a);
extern void B_clip(int ofon,int x1,int y1,int x2,int y2,int ox,int oy,int mode);
extern void B_stime(char *a),B_sdate(char *a),B_sp_test(void);
extern void B_sound(int kan,int laut,int note,int oktave,int verz);
extern void B_wave(int stim,int huell,int form,int dauer,int verz);
extern long T_ausw(long h,long kb);
extern void B_out(long n);
extern char *B_errd(int nr);
extern void B_input(int mode,int komma,char *text,char *form, ...);
extern char *B_inputkr(int anz, FILE *kan);
extern char *B_input_S(int anz);
extern void B_error(int fehler);
extern int  B_fatal(void);
extern void B_stick(int port);
extern int  B_strig(int port);
extern unsigned char B_joystick(int port);

/* MATHEMATIK */

#define PI        M_PI
#define FALSE     0
#define TRUE      -1

#define B_rad(x)  ((x)*0.01745329251994)
#define B_deg(x)  ((x)*57.29577951308)
#define B_asin(x) asin(x)
#define B_acos(x) acos(x)

extern double B_atn(double x);
extern double B_rnd(int x), B_sqr(double x);
extern double B_trunc(double x);
extern double B_round(double x,int n);
extern char B_ugl(double a,double b);
extern int B_fix(double x), B_sgn(double x);

/* BIT-OPERATIONEN */

#define B_Logik(x)  (int)(!((int) (x)) ? 0 : -1)
#define B_and(x,y)  (((long)(x) & (long)(y)))
#define B_or(x,y)   (((long)(x) | (long)(y)))
#define B_xor(x,y)  (((long)(x) ^ (long)(y)))
#define B_eqv(x,y)  (~((long)(x) ^ (long)(y)))
#define B_imp(x,y)  (~(long)(x) | (long)(y))


/* END: HEADER-FILE B_NACH_C.H */
