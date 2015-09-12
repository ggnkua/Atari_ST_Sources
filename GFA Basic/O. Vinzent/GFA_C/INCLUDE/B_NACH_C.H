/*                                                                  */     			
/* B_NACH_C.H         GFA-BASIC-KONVERTER NACH C - Headerfile       */
/* Copyright (C)-1989 O.Vinzent und Prof.Dr. H.-J.Patt, UniversitÑt */
/*                    des Saarlandes, GebÑude 8, D-6600 SaarbrÅcken */
/*                    GFA-Systemtechnik, D-4000 DÅsseldorf 11       */
/*                                                                  */
#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <math.h>
#include <tos.h>
#include <stdlib.h>
#include <vdi.h>
#include <aes.h>
#include <ext.h>
#include <linea.h>

#define C_HAR 256
extern void showm(void);
int MF;
#define pi M_PI
#define FALSE 0
#define TRUE -1
#define t_uopper() strupr()
#define trunc(x) (((x) > 0) ? (int)floor(x) : (int)ceil(x))
#define round(x,n) (((int)((x)*pow(10,(n))+0.5))/pow(10,(n)))
#define frac(x) ((x) - trunc(x))
#define m_ax(a,b) (((a) > (b)) ? (a): (b))
#define m_in(a,b) (((a) < (b)) ? (a): (b))
#define f_eof(a) feof(a)
#define odd(a) ((fmod(((int)(a)),2) == 0) ? 0 : -1)
#define even(a) ((fmod(((int)(a)),2) == 0) ? -1 : 0)
#define d_iv(a,b) (((a) < (b)) ? ceil((a)/(b)) :floor((a)/(b)))
#define bmove(a,b,c) memcpy(b,a,c)
#define locate(z,s) print_at(z,s)

/* #define mouse(x,y,p) vq_mouse(HANDLE, (int)&p,(int)&x,(int)&y); */
extern int rc_intersect(int x1,int y1,int w1,int h1,int *x2,int *y2,int *w2,int *h2);
#define rc_intersect(x1,y1,w1,h1,x2,y2,w2,h2) HVA; A = x2; B = y2; C = w2; D = h2; HVA = rc_intersect(x1,y1,w1,h1,&A,&B,&C,&D); x2 = A;y2 = B; w2 = C; h2 = D
extern void	a_lert(int icon,char *bt, int db, char *text, int *back);
#define	a_lert(i,b,d,t,bu) a_lert(i,b,d,t,&A); bu = A;
#define mouse(x,y,p) { vq_mouse(HANDLE, &A, &B, &C); x = B; y = C; p = A; }
#define evnt_button(clicks,mask,state,mx,my,bu,kb) evnt_button(clicks,mask,state,&A,&B,&C,&D); mx = A;my = B;bu = C;kb = D
#define evnt_mouse(flags,ox,oy,owidth,oheight,mx,my,button,state) evnt_mouse(flags,ox,oy,owidth,oheight,&A,&B,&C,&D); mx = A;my = B;button = C;state = D
#define evnt_mesag(pbuff) HVA; if(!pbuff) {HP = (int *)(pbuff);} else {HP = M_BUFF;} HVA = evnt_mesag(HP)
#define evnt_multi(f,c,m,s,ms,mx,my,mh,mt,fs,m2x,m2y,m2w,m2h,buff,co,hic,mox,moy,mbu,oks,kr,br) HVA; I_NT = (int *)buff;HVA = evnt_multi(f,c,m,s,ms,mx,my,mh,mt,fs,m2x,m2y,m2w,m2h,I_NT,co,hic,&A,&B,&C,&D,&E,&F);mox=A;moy=B;mbu=C;oks=D;kr=E;br=F
#define evnt_timer(count) evnt_timer(count & 0xffff, count >> 16)
#define menu_bar(tree,show) HVA; HTREE = (OBJECT *)(tree);showm(); HVA = menu_bar(HTREE,(int)show)
#define menu_icheck(tree,item,flag) HVA; HTREE = (OBJECT *)(tree); HVA = menu_icheck(HTREE,(int)item,(int)flag)
#define menu_ienable(tree,item,flag) HVA; HTREE = (OBJECT *)(tree); HVA = menu_ienable(HTREE,(int)item,(int)flag)
#define menu_tnormal(tree,title,flag) HVA; HTREE = (OBJECT *)(tree); HVA = menu_tnormal(HTREE,(int)title,(int)flag)
#define menu_text(tree,item,new_text) HVA; HTREE = (OBJECT *)(tree); HVA = menu_text(HTREE,(int)item,new_text)
#define objc_add(tree,parent,child) HVA; HTREE = (OBJECT *)(tree); HVA = objc_add(HTREE,(int)parent,(int)child)
#define objc_delete(tree,del_obj) HVA; HTREE = (OBJECT *)(tree); HVA = objc_delete(HTREE,(int)parent,(int)del_obj)
#define objc_draw(tree,start_obj,depth,cx,cy,cw,ch) HVA; HTREE = (OBJECT *)(tree); HVA = objc_draw(HTREE,(int)start_obj,(int)depth,(int)cx,(int)cy,(int)cw,(int)ch)
#define objc_find(tree,start_obj,depth,fx,fy) HVA; HTREE = (OBJECT *)(tree); HVA = objc_find(HTREE,(int)start_obj,(int)depth,(int)fx,(int)fy)
#define objc_offset(tree,obj,depth,x_abs,y_abs) HVA; HTREE = (OBJECT *)(tree); HVA = objc_offset(HTREE,(int)obj,&A,&B); x_abs = A; y_abs = B
#define objc_order(tree,obj,new_pos) HVA; HTREE = (OBJECT *)(tree); HVA = objc_order(HTREE,(int)obj,(int)new_pos)
#define objc_edit(tree,obj,c,old_pos,flag,new_pos) HVA; HTREE = (OBJECT *)(tree); A = old_pos; HVA = objc_edit(HTREE,(int)obj,(int)c,&A,(int)flag); new_pos = A
#define objc_change(tree,obj,res,cx,cy,cw,ch,new_status,re_draw) HVA; HTREE = (OBJECT *)(tree); HVA = objc_change(HTREE,(int)obj,(int)res,(int)cx,(int)cy,(int)cw,(int)ch,(int)new_status,(int)re_draw)
#define form_do(tree,start_obj) HVA; showm();HTREE = (OBJECT *)(tree); HVA = form_do(HTREE,(int)start_obj); hidem()
#define form_center(tree,fx,fy,fw,fh) HVA; HTREE = (OBJECT *)(tree); HVA = form_center(HTREE,&A,&B,&C,&D); fx = A; fy = B; fw = C; fh = D
#define form_keybd(tree,obj,next_obj,char,new_obj,next_char) HVA; HTREE = (OBJECT *)(tree); HVA = form_keybd(HTREE,(int)obj,(int)next_obj,(int)char,&A,&B); next_obj = A; next_char = B
#define form_button(tree,obj,clicks,new_obj) HVA; HTREE = (OBJECT *)(tree); HVA = form_button(HTREE,(int)obj,(int)clicks,&A); new_obj = A
#define graf_rubberbox(rx,ry,min_w,min_h,last_w,last_h) HVA;showm();graf_rubberbox((int)rx,(int)ry,(int)min_w,(int)min_h,&A,&B); last_w = A; last_h = B;hidem()
#define graf_dragbox(iw,ih,ix,iy,rx,ry,rw,rh,last_ix,last_iy) HVA;showm();graf_dragbox((int)iw,(int)ih,(int)ix,(int)iy,(int)rx,(int)ry,(int)rw,(int)rh,&A,&B); last_ix = A; last_iy = B;hidem()
#define graf_watchbox(tree,obj,in_state,out_state) HVA;showm(); HTREE = (OBJECT *)(tree); HVA = graf_watchbox(HTREE,(int)obj,(int)in_state,(int)out_state);hidem()
#define graf_slidebox(tree,parent_obj,slider_obj,flag) HVA;showm(); HTREE = (OBJECT *)(tree); HVA = graf_slidebox(HTREE,(int)parent_obj,(int)slider_obj,(int)flag);hidem()
#define graf_handle(char_w,char_h,box_w,box_h) graf_handle(&A,&B,&C,&D); char_w = A; char_h = B; box_w = C; box_h = D
#define graf_mouse(m_form,muster_adr) HVA; M_FORM = (MFORM *)muster_adr; HVA = graf_mouse(m_form,M_FORM)
#define graf_mkstate(mx,my,m_state,k_state) HVA;showm();graf_mkstate(&A,&B,&C,&D); mx = A; my = B; m_state = C; k_state = D;hidem()
#define fsel_input(path,name,button) fsel_input(path,name,&A); button = A
#define wind_get(handle,field,w1,w2,w3,w4) wind_get((int)handle,(int)field,&A,&B,&C,&D); w1 = A; w2 = B; w3 = C; w4 = D
#define wind_calc(w_type,attr,ix,iy,iw,ih,ox,oy,ow,oh) wind_calc((int)w_type,(int)attr,(int)ix,(int)iy,(int)iw,(int)ih,&A,&B,&C,&D); ox = A; oy = B; ow = C; oh = D
#define wind_open(handle,init_x,init_y,init_w,init_h) hidem();wind_open(handle,init_x,init_y,init_w,init_h);showm()
#define wind_close(handle) hidem();wind_close(handle)

#define rsrc_gaddr(type,index,adr) rsrc_gaddr((int)type,(int)index,&HTREE); adr = (long)HTREE
#define rsrc_saddr(type,index,adr) HVA; V_OID = (void *)adr; HVA = rsrc_saddr((int)type,(int)index,V_OID)
#define rsrc_obfix(tree,obj)  HVA; HTREE = (OBJECT *)(tree); HVA = rsrc_obfix(HTREE,(int)obj)
#define shel_envrn(adr,such) HVA; P_P = (char **)adr; HVA = shel_envrn(P_P,such); adr = (char *)P_P
#define vqt_extent(text,x1,y1,x2,y2,x3,y3,x4,y4) E_XTENT[0]=x1;E_XTENT[1]=y1;E_XTENT[2]=x2;E_XTENT[3]=y2;E_XTENT[4]=x3;E_XTENT[5]=y3;E_XTENT[6]=x4;E_XTENT[7]=y4; vqt_extent(handle,text,E_XTENT)
#define ob_next(tree,obj) (int)(((OBJECT *)(tree))[(obj)].ob_next)
#define ob_head(tree,obj) (int)(((OBJECT *)(tree))[(obj)].ob_head)
#define ob_tail(tree,obj) (int)(((OBJECT *)(tree))[(obj)].ob_tail)
#define ob_type(tree,obj) (int)(((OBJECT *)(tree))[(obj)].ob_type)
#define ob_flags(tree,obj) (int)(((OBJECT *)(tree))[(obj)].ob_flags)
#define ob_state(tree,obj) (int)(((OBJECT *)(tree))[(obj)].ob_state)
#define ob_x(tree,obj) (int)(((OBJECT *)(tree))[(obj)].ob_x)
#define ob_y(tree,obj) (int)(((OBJECT *)(tree))[(obj)].ob_y)
#define ob_w(tree,obj) (int)(((OBJECT *)(tree))[(obj)].ob_w)
#define ob_h(tree,obj) (int)(((OBJECT *)(tree))[(obj)].ob_h)
#define ob_adr(tree,obj) (long)(&((OBJECT *)(tree))[(obj)]))

#define mkdir(a) (void ) gemdos(57,a);
#define rmdir(a) (void) gemdos(58,a);
#define kill(a) remove(a);
#define name(a,b) rename(a,b);
#define vsync() Vsync();
#define X_OR !=
#define malloc(a) Malloc(a)
#define rad(a) ((a)*0.01745329251994)
#define deg(a) ((a)*57.29577951308)
#define sinq(x) sin(x)

/* BIT-Operatoren */
#define eqv(a,b) (~((a) ^ (b)))
#define imp(a,b) (~(a) | (b))
#define bclr(x,y) ((x) & ~(1 << y))
#define bchg(x,y) (btst(x,y) ? bclr(x,y) : bset(x,y))
#define bset(x,y) ((x) | (1 << y))
#define btst(x,y) (long)(-(!((x) & (1 << y))))

/* BIT-SHIFT-Operatoren */
#define shl(z,p) ((z) << ((p) & 31))
#define shr(z,p) ((z) >> ((p) & 31))
#define shlc(x,y) (((x) & 0xff) << (y))
#define shli(x,y) (((x) & 0xffff) << (y))
#define shrc(x,y) (((x) & 0xff) >> (y))
#define shri(x,y) (((x) & 0xffff) >> (y))
#define ror(z,p) (((((1 << ((p) & 31))-1) & (z)) << (32-((p) & 31))) | (((~((1 << ((p) & 31))-1) & (z)) >> ((p) & 31))))
#define rorc(z,p) (((((1 << ((p) & 7))-1) & ((z) & 7)) << (8-((p) & 7))) | (((~((1 << ((p) & 7))-1) & ((z) & 7)) >> ((p) & 7))))
#define rori(z,p) (((((1 << ((p) & 15))-1) & ((z) & 15)) << (16-((p) & 15))) | (((~((1 << ((p) & 15))-1) & ((z) & 15)) >> ((p) & 15))))
#define rol(z,p) (((((1 << (32-(p) & 31))-1) & (z)) << (((p) & 31))) | (((~((1 << (32-(p) & 31))-1) & (z)) >> (32-(p) & 31))))
#define rolc(z,p) (((((1 << (32-(p) & 7))-1) & ((z) & 7)) << (((p) & 7))) | (((~((1 << (32-(p) & 7))-1) & ((z) & 7)) >> (32-(p) & 7))))
#define roli(z,p) (((((1 << (32-(p) & 15))-1) & ((z) & 15)) << (((p) & 15))) | (((~((1 << (32-(p) & 15))-1) & ((z) & 15)) >> (32-(p) & 15))))

typedef struct bildsp
	{
	char *bild;
	int	xa,ya,xe,ye;
	} BILD;

GEMPARBLK  *GPBk;
char	*DATA_POINT[C_HAR];
extern	char *TEMP,*TEMPR[80],*TEMPA;
int	DUMMY,HANDLE,OLDHANDLE,SP,A,B,C,D,E,F,G;
long DAZ;
void *HP;
OBJECT *HTREE,**OB;
MFORM *M_FORM;
int E_XTENT[8],*I_NT;
char *V_OID;
char **P_P;
int M_BUFF[8];
FILE	*FP[10],*STDPRN;
char	*SPEICHER[256],*HVP[10];
int	HVA,GRAF,HV[256],ZL;
int *CONTRL, *INTIN, *INTOUT, *PTSIN, *PTSOUT;
int *GCONTRL, *GINTIN, *GINTOUT, *GPTSIN, *GPTSOUT,*GB;
void *ADDRIN,*ADDROUT;
int	pxyarray[4];void	wait(int a);
int	open_workstation(register	 MFDB *form);MFDB	source;

/* Graphik */
extern void	vdisys(int a),gemsys(int a),boundary(int mode);
extern void	vellpie(int x, int y, int xr, int yr, int begang, int endang);
extern void	draw(int xa, int ya, int xe, int ye),box(int x, int y, int c, int d);
extern void	circle(int x, int y, int r), g_raphmode(int mode);
extern void	pcircle(int x, int y, int r),deffill(int x, int y, int d);
extern void	ellipse(int x, int y, int xr, int yr),drawa(int mode, int xa, int ya);
extern void pellipse(int x, int y, int xr, int yr);
extern void	rbox(int x, int y, int c, int d),color(int a);
extern void	p_rbox(int x, int y, int c, int d);
extern void	deftext(int x, int y, int c, int d);
extern void	defline(int x, int y, int c, int d);
extern void	defmark(int x, int y, int c);
extern void	setmouse(char *a),hidem(void),hardcopy(void);
extern int	mousex(void), mousey(void), mousek(void),point(int x, int y);
extern void	line(int xa, int ya,int xe,int ye),pbox(int x, int y, int c, int d);
extern void	polyline(int p,double *a,double *b,int ofx,int ofy);
extern void	polyfill(int p,double *a,double *b,int ox, int oy);
extern void	polymark(int p,double *a,double *b,int ox, int oy),plot(int x, int y);
extern void	fill(int x,int y,int farbe),fdeffill(int a,char *c);
extern void	fdefmouse(int a);
extern void	fileselect(char *pfad, char *vor, char *back),defmouse(char *a);
extern void b_oundary(int mode),rc_copy(long sadr,int sx,int sy,int w,int h,long dadr,int dx,int dy,int mode);
/* Strings */
extern char	*left(char * a, int b),*string(int zahl,char zeichen);
extern char	*mstrcat(char * a, char *b),msprintf(char *z,char *form, ...);
extern char	*right(char *a, int b);
extern char	*mid(char *a, int b,int c);
extern char	*lset(char *a, char *b);
extern char	*rset(char *a, char *b);
extern char	*hex(long a,int n), *oct(long a,int n), *bin(long a,int n), *space(int a);
extern char	*chr(long a);
extern char *time(void);
extern char *sget(char *c);
extern BILD *get(int x1, int y1, int x2, int y2,char *c);
extern void put(int x1, int y1,char *c,int mode);
extern char	*t_oupper(char *a),*tab(long a);
extern char	*spc(int a), *date(void),*dir(int a),*dirr(char *a);
extern char *itoab(int a,int b,int c);
extern char *ltoab(long a,int b,int c),*ftoab(double a,int b,int c);
extern void	form_inp(int mode,int anzahl, char *b);
extern int	abs(int a),asc(char *a);
extern int	instr(int a,char *b,char *c);
extern int  rinstr(char *b,char *c);
extern void	text(int x,int y,int laenge,char *c);
extern void	sput(char *a), s_ettime(char *zeit,char *datum);
extern double val(char *a);
extern int valf(char *a);

/* Verschiedene */
extern void	*arrptr(char *a),bget(FILE *a,long b,long c),bload(long a, void *b);
extern void	bput(FILE *a,long b,long c);
extern void	bsave(char *a,long b,long c),print_at(int a,int b);
extern void	exec(int a,char *b,char *c,char *d),clear(void);
extern long	dfree(int a),fre(int a),loc(FILE *a),lof(FILE *a),timer(void);
extern int	exist(char *a);
extern unsigned char	*inkey(void),inp(int a);
extern void	swap(void *a, void *b),pause(long a),relseek(FILE *a,int anz);
extern void seek(FILE *a,int anz),chdrive(int drive),super(int a);
extern void poke(long sp,char b),dpoke(long sp,int b),lpoke(long sp,long b);
extern void spoke(long sp,char b),sdpoke(long sp,int b),slpoke(long sp,long b);
extern char peek(long a);
extern int	dpeek(long a);
extern long lpeek(long a);
extern char byte(long a,char b,int fl);
extern unsigned int card(long a,unsigned int b, int fl);
extern int	i_nt(long a,int b,int fl);
extern long l_ong(long a, long b,int fl);
extern float single(long a, float b, int fl);
extern double f_loat(long b, double w, int fl),d_ouble(long b, double w, int fl);
extern char *c_har(long a, char *b, int fl);
#define c_har(a,b,fl) c_har((long)a,(char *)b,fl)
extern char *mki(int a),*mkl(long a),*mks(float a),*mkd(double a);
extern int cvi(unsigned char *a);
extern long cvl(unsigned char *a);
extern float cvs(unsigned char *a);
extern double cvd(unsigned char *a);
extern void f_ehler(int a),clip(int ofon,int x1,int y1,int x2,int y2,int ox,int oy,int mode);
extern long swapb(long a);
extern void stime(char *a),sdate(char *a),sp_test(void);

/* Mathe - Routinen */
extern double	atn(double a),cos(double a),sin(double a),exp(double a);
extern double	log(double a),log10(double a),rnd(int a),sqr(double a);
extern int	fix(double a),sgn(double a);
extern double max(int a, int b, ...),min(int a,int b, ...);
extern char *maxc(int a, int b, ...),*minc(int a,int b, ...);
extern void	defnum(int mode),r_aus(int mode),r_ein(int mode);
/* extern double d_iv(double a,double b); */
/* extern long imp(long a,long b),eqv(long a,long b); */
extern int sortu_bit(char *a,char *b),sortu_byte(char *a,char *b),sortu_int(int *a,int *b);
extern int sortu_long(long *a,long *b),sortu_doub(double *a,double *b);
extern int sortu_char(char **a,char **b),sortu_void(void **a,void **b);
extern int sortd_bit(char *a,char *b),sortd_byte(char *a,char *b),sortd_int(int *a,int *b);
extern int sortd_long(long *a,long *b),sortd_doub(double *a,double *b);
extern int sortd_char(char **a,char **b),sortd_void(void **a,void **b);
extern long btol(char *s),matoi(char *a),matol(char *a);
/* GEM - Routinen */
extern long ob_spec(long tree,int obj);
