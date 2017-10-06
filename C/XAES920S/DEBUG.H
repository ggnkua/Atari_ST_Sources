/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#define MAX_NAMED_DIAG 130		/* HR */

typedef struct
{
	short point, pid;
}
debug_item;

struct debugger		/* HR: debugging catagories */
{
	debug_item
		  all,
		  appl,		/* includes client pool */
		  evnt,
		  multi,	/* evnt_multi only */
		  form,
		  fsel,
		  graf,
		  menu,
		  objc,
		  rsrc,
		  scrp,
		  shel,
		  wind,
		  widg,
		  mouse,
		  keybd,
		  sema,
		  rect,		/* rectangle checking */
		  pipe,		/* pipes & devices excl trap */
		  trap,		/* plain trap #2,AES commands */
		  kern,		/* Gemdos part of kernel */
		  a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z;

	char debug_path[200];					/* Path to dump debug info to */
	long debug_file;					/* File handle to dump debug stuff to */
	short bug_line, debug_lines;
};

extern long strtclk;
extern char *D_su,*D_sd,*D_sr,*D_cl,*D_fl,*D_flu;
long clock(void); int Pgetpid(void);
void show_bits(unsigned short bits, char *prf, char *t[], char *x);
void evnt_diag_output(void *pb, short pid, char *which);

#define NAES3D 1

#if USE_CALL_DIRECT
	#define File_Line display(D_flu,clock()-strtclk,Pgetpid(),__FILE__,__LINE__)
#else
	#define File_Line display(D_fl,__FILE__,__LINE__)
#endif
#define DIAGS(x) if (D.all.point >= 1) File_Line,display x
#define DIAG(x) DeBug x
#define IFDIAG(x) x

extern struct debugger D;			/* debugging catagories & data */

void DeBug(debug_item item, short pid, char *t, ...);

void display_env(char **env, int which);
char *pmsg(short m);

/* The semaphores are crucial, so have ample debugging features. */
#if 0
#define Sema_Up(id) {long r = Psemaphore(2,id,-1); if (r == -1) DIAGS(("Sema %c up:-1 for %d\n",(short)id,Pgetpid()));}
#define Sema_Dn(id) Psemaphore(3,id,0);
#elif DEBUG_SEMA
#define Sema_Up(id) {long r; DIAGS((D_su,(short)id)); \
						  r = Psemaphore(2,id,-1); \
						  if (r < 0) DIAGS((D_sr,r));}
#define Sema_Dn(id) {long r = Psemaphore(3,id,0); DIAGS((D_sd,(short)id,r));}
#else
#define Sema_Up(id) Psemaphore(2,id,-1)
#define Sema_Dn(id) Psemaphore(3,id,0)
#endif

#if DEBUG_CONTROL
#define CONTROL(a,b,c) {int *co = pb->contrl;\
						 if (co[1] != a || co[2] != b || co[3] != c)\
						 	display(D_cl,a,co[1],b,co[2],c,co[3]); }
#else
#define CONTROL(a,b,c)
#endif
