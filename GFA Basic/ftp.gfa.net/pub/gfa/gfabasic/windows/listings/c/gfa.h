/* header File for 'C' accessing GFA-BASIC */

#ifndef __GFA_HEADER__
#define __GFA_HEADER__
/* Type declarations */
typedef double	       GDBLE;
typedef long	       GLONG;
typedef int	       GWORD;
typedef unsigned char  GBYTE;
typedef char	       GBOOL;
typedef void far *     GSTRG;

typedef GDBLE far * GPDBLE;
typedef GLONG far * GPLONG;
typedef GWORD far * GPWORD;
typedef GBYTE far * GPBYTE;
typedef GBOOL far * GPBOOL;
typedef GSTRG far * GPSTRG;

/* Function declarations */
#define GPROC	 extern void   far pascal
#define GFUNCN	 extern GLONG  far pascal
#define GFUNCS	 extern GSTRG  far pascal   /* es:bx! (and dx:ax for 'C')*/
#define GFUNCD	 extern GDBLE  far pascal   /* $FUNC# */

/* Variable declarations */
#define GVDBLE	 extern GDBLE near pascal
#define GVLONG	 extern GLONG near pascal
#define GVWORD	 extern GWORD near pascal
#define GVBYTE	 extern GBYTE near pascal
#define GVBOOL	 extern GBOOL near pascal
#define GVSTRG	 extern GSTRG near pascal

/* Macros to get address and len of GFA-BASIC string */
#define G_ADR(strg)	      ((*(char far * far *)(strg)) + 6)
#define G_LEN(strg)	      (*((*(short far * far *)(strg)) + 2))

/* Function which needs to be called for every temporary string passed by
   GFA-BASIC to mark the string as free. It's not neccesary for
   string variables, but for string constants and result of string operations
*/
GPROC G_SKILL(GPSTRG strg);



/* Exported WindowsVariables: */
#ifdef _INC_WINDOWS
extern HDC  near pascal V_DCA;	   //Actual DeviceContext
extern HDC  near pascal V_DC[32];  //DeviceContexte of Windows
extern HWND near pascal V_WNDA;    //Actual WindowHandle
extern HWND near pascal V_WND[32]; //WindowsHandles
extern HWND near pascal V_DLG[32]; //DialogWindowHandles
#endif

/* Also accessable are _AX... */
struct	_lRegs
{
    long eax;
    long ebx;
    long ecx;
    long edx;
    long esi;
    long edi;
    long ebp;
    long esp;
    long eip;
    long efl;
};

struct _wRegs
{
    unsigned int ax,h_ax;
    unsigned int bx,h_bx;
    unsigned int cx,h_cx;
    unsigned int dx,h_dx;
    unsigned int si,h_si;
    unsigned int di,h_di;
    unsigned int bp,h_bp;
    unsigned int sp,h_sp;
    unsigned int ip,h_ip;
    unsigned int fl,h_fl;
    unsigned int cs;
    unsigned int ds;
    unsigned int es;
    unsigned int fs;
    unsigned int gs;
    unsigned int ss;
};

struct _bRegs
{
    unsigned char al, ah, h_al, h_ah;
    unsigned char bl, bh, h_bl, h_bh;
    unsigned char cl, ch, h_cl, h_ch;
    unsigned char dl, dh, h_dl, h_dh;
};

extern union _Regs
{
    struct _lRegs l;
    struct _wRegs x;
    struct _bRegs b;
} near pascal __REGS;

// BASIC _CX = 17
// 'C'	 __REGS.x.cx = 17;


/*
 How to access GFA-BASIC Variables from 'C'

 Names of Variables get a prefix in the ~GFA.OBJ file,
 because i% and i# are different variables, and have to be seperated.

 GFA-BASIC    'C'-Name
 xx#	      GVDBLE D_XX;
 xx%	      GVLONG L_XX;
 xx&	      GVWORD W_XX;
 xx|	      GVBYTE C_XX;
 xx!	      GVBOOL B_XX;
 xx$	      GVSTRG X_XX;

 Arrays are passed as near pointers to their descriptors, eight words.
 xx#()	      extern int near pascal * near D@XX;




 Parameters are passed from left to right, as the pascal keyword in 'C' does.
 x#   double
 x%   long
 x&   int
 x|   unsigned char
 x!   char
 x$   void far *
 VAR x#   double far *

 i.e.:	  PROCEDURE dummy(x%	 ,y#	 ,VAR z|  ,t!)
	  GPROC   P_DUMMY(GLONG x,GDBLE y,GPBYTE z,GPBOOL t)

Achtung: GFUNCS


*/

#endif /* __GFA_HEADER__ */
