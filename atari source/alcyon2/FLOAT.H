*****************************************************************************
*****************************************************************************
*****************************************************************************
		Important note:

		This package is owned by MARK WILLIAMS
		We have distribution rights.
		Anything that uses this must carry
		a MARK WILLIAMS copyright.

*****************************************************************************
*****************************************************************************
*****************************************************************************


** MWC bcd floating point.
** User program or library function header.
** Floating point numbers are composed of Sign bit, Exponent bits,
** and Digit bits. Single precision has 1 bit of Sign, 7 bits of
** Exponent, and 6 Digits of 4 bits each:
**	SEEE EEEE DDDD * 6
** Double precision has 1 bit of Sign, 11 bits of Exponent, and 13
** Digits of 4 bits each:
**	SEEE EEEE EEEE DDDD * 13
*/
		/* Implemented types */
typedef char Single[4];		/* returned in d0 */
typedef char Double[8];		/* returned [0-3] in d0, [4-7] in d1 */
typedef char Ascii[1+1+20+7+1];	/* pointer to static, non-reentrant memory
				 * location returned in d0 */
				/* Status and Mode register are also kept
				 * in static, non-reentrant memory location */
		/* Unimplemented types */
typedef char Quadword[8];	/* Would be an 8 byte unsigned integer */
typedef char Extend[10];	/* Would be internal register */

/*
** If the Exponent field is all zeros,
** the number is Tiny or Small:
**	Tiny has a fraction of zeros, and is effectively zero;
**	Small has a subnormal fraction, and is within 10^13 of Tiny.
** If the Exponent field is all ones,
** the number is Huge or Nany:
**	Huge has a fraction of zeros, and is effectively infinite;
**	Nany's have non-zero fractions,
**	and are not any representable floating point numbers.
** A nany with initial Digit 0xF is a signalling nany which would generate
**	a user level exception if such were implemented.  In the absence
**	of an invalid operand exception, signalling nany's are converted
**	to quiet nany's by decrementing their initial Digit.
** A nany with initial Digit 0xE is a quiet nany which is passed through
**	operations unchanged.  Many operations and functions create
**	quiet nany's as their results when given invalid operands.
*/
		/* First three fraction digits of quiet nany's */
#define NSIGNAL		0x0E01	/* Operation on signaling NaN */
#define NADDI		0x0E02	/* Add or sub cancels Huge */
#define NMULI		0x0E03	/* Multiply Tiny by Huge */
#define NDIVZZ		0x0E04	/* Divide Tiny by Tiny */
#define NDIVII		0x0E05	/* Divide Huge by Huge */
#define NREMZ		0x0E06	/* Remainder by Tiny */
#define NREMI		0x0E07	/* Remainder of Huge */
#define NSQRN		0x0E08	/* Square root of negative */
#define NBADT		0x0E09	/* Unrecognized text string conversion */
#define NCMPU		0x0E0A	/* Unordered comparison */
#define NLOGN		0x0E0B	/* Log of negative number */
#define NACOS		0x0E0C	/* Arc cosine or arc sine domain error */

/*
** Further details of results of operations may be obtained from
** the Status Register via SRget();  detailed analysis of an operand
** may be obtained from Stst() or Dtst();  Dcmp() provides an imperfect
** comparison between operands in that the Unordered condition is not
** detected.
*/
	/* Test conditions from SRget(), Stst(), or Dtst() */
#define SSIGN		0x8000	/* Negative */
#define SNORM		0x4000	/* Normal exponent range */
#define SBITS		0x2000	/* Non-zero fraction */
#define STINY		0x1000	/* Tiny, ie smallest, exponent */
#define SHUGE		0x0800	/* Huge, ie largest, exponent */
	/* Comparison condtitions from SRget() or Dcmp() */
#define SSMALLER	0x0400
#define SLARGER		0x0200
#define SEQUAL		0x0100
#define SUNORDER	0x0080
	/* Exception assertions from SRget() */
#define SOVER		0x0040	/* Overflow */
#define SUNDER		0x0020	/* Underflow */
#define SDIVIDE		0x0010	/* Divide by zero */
#define SINVALID	0x0008	/* Invalid operand */
#define SINEXACT	0x0004	/* Inexact result */
	/* Class macros applicable to SRget(), Dtst(), or Stst() */
#define is_any(S)	(((S)&(SNORM|SBITS))==(SNORM|SBITS))
#define is_nany(S)	(((S)&(SHUGE|SBITS))==(SHUGE|SBITS))
#define is_tiny(S)	(((S)&(STINY|SBITS))==(STINY))
#define is_huge(S)	(((S)&(SHUGE|SBITS))==(SHUGE))
#define is_small(S)	(((S)&(STINY|SBITS))==(STINY|SBITS))
#define is_neg(S)	(((S)&SSIGN)!=0)
	/* Comparison macros applicable to SRget() or Dcmp() */
#define is_gt(S)	(((S)&SLARGER)!=0)
#define is_ge(S)	(((S)&(SLARGER|SEQUAL))!=0)
#define is_lt(S)	(((S)&SSMALLER)!=0)
#define is_le(S)	(((S)&(SSMALLER|SEQUAL))!=0)
#define is_eq(S)	(((S)&SEQUAL)!=0)
#define is_ne(S)	(((S)&SEQUAL)!=0)
#define is_un(S)	(((S)&SUNORDER)!=0)
/*
** The operations may be controlled to some extent by the contents
** of the Mode Register which may be read and written with MRget().
** Infinity mode determines whether positive and negative infinities
** compare equal or different.
** The rounding mode determines one of four different algorithms for
** packing floating point numbers into fewer digits.
** If exception vectors were enabled, then the same bit positions which
** signal exceptions in the Status Register would enable the corresponding
** exception vector if set in the Mode Register.
*/
#define IMODE		0x8000	/* Affine infinities */
#define RMODE		0x6000	/* Rounding mode mask */
#define REVEN		0x0000	/* Round to nearest or even */
#define RPLUS		0x4000	/* Round to plus infinity */
#define RMINUS		0x2000	/* Round to minus infinity */
#define RZERO		0x6000	/* Truncate toward zero */

/*
** Synopses of entries:
**
** int SRget(srp) int *srp;			d0=SR, SR=*srp
** int MRget(mrp) int *mrp;			d0=MR, MR=*mrp
** int Stst(sp) Single *sp;			Return test bits of sp
** int Dtst(dp) Double *dp;			Return test bits of dp
** int Dcmp(dp1, dp2) Double *dp1, *dp2;	Return status of dp2 - dp1
** int IofD(dp) Double *dp;			Convert dp to int
** long LofD(dp) Double *dp;			Convert dp to long
** Single SofD(dp) Double *dp;			Convert dp to Single
** char *AofD(dp) Double *dp;			Convert dp to ascii
** Double Dneg(dp) Double *dp;			Negate dp
** Double Drnd(dp, ip) Double *dp; int *ip;	Round dp to ip digits
** Double DofA(cp) char *cp;			Convert ascii cp to Double
** Double DofI(ip) int *ip;			Convert int ip to Double
** Double DofL(lp) long *lp;			Convert long lp to Double
** Double DofS(sp) Single *sp;			Convert Single sp to Double
** Double Dadd(dp1, dp2) Double *dp1, *dp2;	Return dp2 + dp1
** Double Dsub(dp1, dp2) Double *dp1, *dp2;	Return dp2 - dp1
** Double Dmul(dp1, dp2) Double *dp1, *dp2;	Return dp2 * dp1
** Double Ddiv(dp1, dp2) Double *dp1, *dp2;	Return dp2 / dp1
** Double Drem(dp1, dp2) Double *dp1, *dp2;	Return dp2 rem dp1
** Double Dcos(dp) Double *dp;			Return cosine of dp
** Double Dsin(dp) Double *dp;			Return sine of dp
** Double Dtan(dp) Double *dp;			Return tangent of dp
** Double Dacos(dp) Double *dp;			Return arccosine of dp
** Double Dasin(dp) Double *dp;			Return arcsine of dp
** Double Datan(dp) Double *dp;			Return arctangent of dp
** Double Datan2(dp1, dp2) Double *dp1, *dp2;	Return angle of dp2, dp1
** Double Dexp(dp) Double *dp;			Return e to the dp power
** Double Dln(dp) Double *dp;			Return natural logarithm of dp
** Double Dtenexp(dp) Double *dp;		Return ten to the power dp
** Double Dlog(dp) Double *dp;			Return common logarithm of dp
** Double Dsqrt(dp) Double *dp;			Return square root of dp
** Double Dsrand(dp) Double *dp;		Set random seed to dp
** Double Drand()				Return next random number
*/


/******************************************************************************
*******************************************************************************
			This program uses the BCD floating
			point.
			The original 'C' code is a comment
			following the code that calls the BCD
			package.

			The function 'getdob()' is included
			as 'C' included assembler and would
			be better as straight assembler.
*******************************************************************************
******************************************************************************/


#include <osbind.h>

int contrl[12], intin[256], ptsin[256], intout[256], ptsout[256];
double xinc[2],yinc[2],x[2],y[2],tempx[2],tempy[2];
double zx[2],zy[2],XMIN[2],XRANGE[2],YMIN[2],YRANGE[2];
double rx[2],ry[2],temp[2],temp1[2],four[2];
int zplane[320][200],count;
int ix,iy,handle,pxy[4],maxcnt;

#define F1 0x3b00
#define F2 0x3c00
#define MAXITR 256

main()
{
int dummy,i;
int width,height,keystate;	
int key,mx,my;

/* Set the system up to do GEM calls*/

appl_init();

/* Get the handle of the desktop */

handle=graf_handle(&dummy,&dummy,&dummy,&dummy);

/* Open the workstation. */

for (i=1; i<10; ++i)  intin[i] = 1;
intin[10] = 2;
v_opnvwk(intin, &handle, intout);

graf_mouse(256,&dummy);

readfull();

do
{
key=evnt_keybd();
if (key!=F1)
 {
if (key!=F2)
	{
	graf_mouse(257,&dummy);
	graf_mouse(0,&dummy);
	vsl_color(handle,1);
	evnt_button(1,1,1,&mx,&my,&dummy,&keystate);
	graf_rubberbox(mx,my,0,0,&width,&height);

	DofA("320."); getdob(temp1);
	Ddiv(temp1,XRANGE); getdob(temp1);
	DofI(&mx); getdob(temp);
	Dmul(temp1,temp); getdob(temp);
	Dadd(XMIN,temp); getdob(XMIN);
/*	XMIN = XMIN+mx*(XRANGE/320.);	*/

	DofA("200."); getdob(temp1);
	Ddiv(temp1,YRANGE); getdob(temp1);
	DofI(&my); getdob(temp);
	Dmul(temp1,temp); getdob(temp);
	Dadd(YMIN,temp); getdob(YMIN);
/*	YMIN = YMIN+my*(YRANGE/200.);	*/

	DofA("320."); getdob(temp1);
	DofI(&width); getdob(temp);
	Ddiv(temp1,temp); getdob(temp1);
	Dmul(temp1,XRANGE); getdob(XRANGE);
/*	XRANGE = XRANGE*(width/320.);	*/

	DofA("200."); getdob(temp1);
	DofI(&height); getdob(temp);
	Ddiv(temp1,temp); getdob(temp1);
	Dmul(temp1,YRANGE); getdob(YRANGE);
/*	YRANGE = YRANGE*(height/200.);	*/

	graf_mouse(256,&dummy);
	drawmand();
	}
else
	{
	readfull();
	}
 }
}
while (key!=F1);

graf_mouse(257,&dummy);

/* Close the workstation. */
 
v_clsvwk(handle);
 
 /* Release GEM calls */

appl_exit();

}

doit()
{
double junk[2];
count=0;
DofA("0."); getdob(zx);
DofA("0."); getdob(zy);
/*zx=0.; zy=0.;*/
do
	{
	Dmul(zx,zx); getdob(rx);
/*	rx=zx*zx;	*/
	Dmul(zy,zy); getdob(ry);
/*	ry=zy*zy;	*/
	Dsub(ry,rx); getdob(temp);
	Dadd(temp,x); getdob(tempx);
/*	tempx=rx-ry+x;	*/
	DofA("2."); getdob(temp);
	Dmul(temp,zx); getdob(temp);
	Dmul(temp,zy); getdob(temp);
	Dadd(temp,y); getdob(tempy);
/*	tempy=2.*zx*zy+y;	*/
	asm("move.l _tempx,_zx");
	asm("move.l _tempx+4,_zx+4");
	asm("move.l _tempy,_zy");
	asm("move.l _tempy+4,_zy+4");
/*	zx=tempx; zy=tempy;		*/
	Dadd(rx,ry); getdob(junk);
/*	junk=rx+ry;	*/
	DofA("4."); getdob(four);
	++count;
	}
while (((Dcmp(four,junk))!=0x0400)&&(count<maxcnt));
}


readfull()
{
long bcount;
int fhandle;

v_clrwk(handle);

DofA("-2."); getdob(XMIN);
/*XMIN = (-2.);*/
DofA("3."); getdob(XRANGE);
/*XRANGE = 3.;*/
DofA("-1.3"); getdob(YMIN);
/*YMIN = (-1.3);*/
DofA("2.6"); getdob(YRANGE);
/*YRANGE = 2.6;*/
while ((fhandle=Fopen("fullmand",2))<0)
	{
	v_gtext(handle,0,20,"Put data disk in drive");
	v_gtext(handle,0,40,"then hit any key");
	evnt_keyb();
	}
bcount=64000;
bcount=bcount*2;
Fread(fhandle,bcount,zplane);
Fclose(fhandle);
maxcnt=0;
v_clrwk(handle);
for (iy=0;iy<200;++iy)
	{
	for (ix=0;ix<320;++ix)
		if (zplane[ix][iy]>maxcnt) maxcnt=zplane[ix][iy];
	}

for (iy=0;iy<200;++iy)
	{
	for (ix=0;ix<320;++ix)
		{
		count=zplane[ix][iy];
		pxy[0]=pxy[2]=ix;pxy[1]=pxy[3]=iy;
		vsl_color(handle,(count%14)+2);
		if (count==maxcnt) vsl_color(handle,1);
		v_pline(handle,2,pxy);
		}
	}
}


drawmand()
{
maxcnt=MAXITR;
v_clrwk(handle);

asm("move.l _YMIN,_y");
asm("move.l _YMIN+4,_y+4");
/*y=YMIN;*/

DofA("200."); getdob(temp);
Ddiv(temp,YRANGE); getdob(yinc);
/*yinc=YRANGE/200.;*/

DofA("320."); getdob(temp);
Ddiv(temp,XRANGE); getdob(xinc);
/*xinc=XRANGE/320.;*/

for (iy=0;iy<200;++iy)
	{
	Dadd(y,yinc); getdob(y);
/*	y=y+yinc;	*/
	asm("move.l _XMIN,_x");
	asm("move.l _XMIN+4,_x+4");
/*	x=XMIN; 	*/
	for (ix=0;ix<320;++ix)
		{
		Dadd(x,xinc); getdob(x);
/*		x=x+xinc;	*/
		doit();
		zplane[ix][iy]=count;
		pxy[0]=pxy[2]=ix;pxy[1]=pxy[3]=iy;
		vsl_color(handle,(count%14)+2);
		if (count==maxcnt) vsl_color(handle,1);
		v_pline(handle,2,pxy);
		}
	}
}

getdob()
{
asm("move.l 12(a7),a5");
asm("move.l d0,(a5)+");
asm("move.l d1,(a5)");
}


/******************************************************************************
			The following is the file needed
			patch the labels problem
******************************************************************************/
	.globl	_AofD
	.globl	_DofA
	.globl	_Dadd
	.globl	_Dcmp
	.globl 	_Ddiv
	.globl	_Dmul
	.globl	_Dsub
	.globl	_DofI
	.globl	_IofD
	.text
_AofD	jmp	AofD_
_DofA	jmp	DofA_
_Dadd	jmp	Dadd_
_Dcmp	jmp	Dcmp_
_Ddiv	jmp	Ddiv_
_Dmul	jmp	Dmul_
_Dsub	jmp	Dsub_
_DofI	jmp	DofI_
_IofD	jmp	IofD_

/*****************************************************************************
			Use this link file with the 
			supplied bcd.o,label.o.
			If you need more functions than
			in label you have the source
			(above)
******************************************************************************/

link68 [u,s] %1.68k=apstart,%1,vdibind,aesbind,label,bcd,osbind
rm %1.o
relmod %1.68K %1.PRG
rm %1.68K
wait

