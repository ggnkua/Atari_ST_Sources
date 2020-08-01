/*
 * osbind.h	bindings for OS traps
 *
 *		++jrb bammi@cadence.com
 */

/*
 * majorly re-hacked for gcc-1.36 and probably beyond
 * all inlines changed to #defines, beacuse gcc is not
 * handling clobbered reggies correctly when -mshort.
 * We now use the Statement Exprs feature of GnuC
 *
 * 10/12/89
 *	changed all "g" constraints to "r" that will force
 *	all operands to be evaluated (or lea calculated)
 *	before the __asm__. This is necessary because
 *	if we had the (looser) "g" constraint, then sometimes
 *	we are in the situation where stuff is in the stack,
 *	and we are modifying the stack under Gcc (but eventually
 *	restoring it before the end of the __asm__), and it does
 *	not know about it (i believe there is no way to tell it
 *	this either, but you can hardly expect that). by forcing
 *	the stricter "r" constraint, we force the eval before using
 *	the val (or lea as the case may be) and we dont get into
 *	trouble.
 *	(thanks to ers for finding this problem!)
 *	[one side effect of this is that we may(depending on the
 *	  situation) actually end up with better code when the
 *	values are already in reggies, or that value is used
 *	later on (note that Gnu's reggie allocation notices the
 *	clobbered reggie, and does'nt put the value/or uses
 *	them from those reggies, nice huh!)
 *
 *  28/2/90
 *	another major re-hack:
 *	-- the basic reason: there was just no reliable
 *	way to get the definitions (inline or not does'nt matter) to
 *	fully evaluate the args before we changed the sp from under it.
 *	(if -fomit-frame-pointer is *not* used, then most of the time
 *	 we dont need to do this, as things will just reference off of
 *	 a6, but this is not true all of the time).
 *	my solution was to use local vars in the body of the statement
 *	exprs, and initialize them from the args of the statement expr block.
 *	to force the evaluation of the args before we change sp from
 *	under gcc's feet, we make the local vars volatile. we use a
 *	slight code optimization heuristic: if there are more than 4
 *	args, only then we make the local volatile, and relax
 *	the "r" constraint to "g". otherwise, we dont put the volatile
 *	and force the evaluation by putting the "r" constaint. this
 *	produces better code in most sitiations (when !__NO_INLINE__
 *	especially), as either the args are already in a register or
 *	there is good chance they will soon be reused, and in that
 *	case it will already be in a register.
 *      it may (the local vars, especially when no volatile)
 *	look like overhead, but in 99% of the situations gcc will just
 *	optimize that assignment right out. besides, this makes
 *	these defines totally safe (from re-evaluation of the macro args).
 *
 *	-- as suggested by andreas schwab (thanks!)
 *	 (schwab@ls5.informatik.uni-dortmund.de) all the retvalues are now
 *	 local register vals (see the extentions section in the info file)
 *	 this really worked out great as all the silly "movl d0,%0" at
 *	 the end of each def can now be removed, and the value of
 *	 retvalue ends up in the correct register. it avoids all the
 *	 silly "mov d0,[d|a]n" type sequences from being generated. a real win.
 *	 (note in the outputs "=r"(retvalue) still has to be specified,
 *	 otherwise in certain situations you end up loosing the return
 *	 value in d0, as gcc sees no output, and correctly assumes that the
 *	 asm returns no value).
 *
 *	-- all the n's (the function #'s for the traps) are now given
 *	the more relaxed "g". This again results in better code, as
 *	it is always a constant, and gcc turns the movw %1,sp@- into
 *	a movw #n,sp@-. we could have given them a "i" constraint too,
 *	but "g" gives gcc more breathing room, and it does the right
 *	thing. note: the n's still need to have "r" constraints in the
 *	non-inline form (function form), as they are no longer constants
 *	in the function, but a normal arg on the stack frame, and hence
 *	we need to force evaluation before we change sp. (see osbind.c)
 *
 *	-- straps.cpp and traps.c are history. we dont need no stinking
 *	non-reentrant bindings (straps) or incorrect ones (traps.c :-)
 *
 * 03/15/92 ++jrb
 *	-- another re-hack needed for gcc-2.0: the optimization that we
 *      used earlier for traps with more than 4 args, making them volatile
 *	and using "g" constraints no longer works, because gcc has become
 *	so smart! we now remove the volatile, and give "r" constraints
 *	(just like traps with <= 4 args). that way the args are evaled
 *	before we change the stack under gcc, and at appropriate times
 *	put into reggies and pushed (or as in most cases, they are evaled
 *	straight into reggies and pushed -- and in even more common cases
 *	they are already in reggies, and they are just pushed). not doing
 *	this with -fomit-frame-pointer was causing the temps (from evaluing
 *	the args) to be created on the stack, but when we changed sp
 *	from under gccs feet, the offsets  to the temps ended up being wrong.
 *
 * 10/28/93 ++jrb
 *	relax the constraints on the inputs of trap_14_wwwwwww (only
 *	Rsconf maps to this)  to "g" from "r", as these many "r" 's
 *	give gcc 2.>3.X heartaches (understandably). note this is ok
 *	since these args will never be expressions, and we never
 *	have to constrain hard enough to force eval before we change
 *	sp from underneath gcc.
 *
 */

#ifndef _OSBIND_H
#define _OSBIND_H

#ifndef _COMPILER_H
#include <compiler.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifndef _OSTRUCT_H
#include <ostruct.h>
#endif

#ifdef __TURBOC__

/* we supply a library of bindings for TurboC / PureC */

long    gemdos( short, ... );
long    bios( short, ... );
long    xbios( short, ... );

/* Gemdos prototypes */

void    Pterm0( void );
long    Cconin( void );
void    Cconout( int c );
int     Cauxin( void );
void    Cauxout( int c );
int     Cprnout( int c );
long    Crawio( int w );
long    Crawcin( void );
long    Cnecin( void );
int     Cconws( const char *buf );
void    Cconrs( LINE *buf );
int     Cconis( void );
long    Dsetdrv( int drv );
int     Cconos( void );
int     Cprnos( void );
int     Cauxis( void );
int     Cauxos( void );
int     Dgetdrv( void );
void    Fsetdta( _DTA *buf );
long    Super( void *stack );
unsigned int  Tgetdate( void );
unsigned int  Tsetdate( unsigned int date );
unsigned int  Tgettime( void );
unsigned int  Tsettime( unsigned int time );
_DTA    *Fgetdta( void );
int     Sversion( void );
void    Ptermres( long keepcnt, int retcode );
int     Dfree( _DISKINFO *buf, int driveno );
int     Dcreate( const char *path );
int     Ddelete( const char *path );
int     Dsetpath( const char *path );
long    Fcreate( const char *filename, int attr );
long    Fopen( const char *filename, int mode );
int     Fclose( int handle );
long    Fread( int handle, long count, void *buf );
long    Fwrite( int handle, long count, void *buf );
int     Fdelete( const char *filename );
long    Fseek( long offset, int handle, int seekmode );
int     Fattrib( const char *filename, int wflag, int attrib );
long    Fdup( int handle );
long    Fforce( int stch, int nonstdh );
int     Dgetpath( char *path, int driveno );
void    *Malloc( long number );
int     Mfree( void *block );
int     Mshrink( int zero, void *ptr, long size );
#define Mshrink(ptr, size) Mshrink(0, ptr, size)
long    Pexec( int mode, char *ptr1, void *ptr2, void *ptr3 );
void    Pterm( int retcode );
int     Fsfirst( const char *filename, int attr );
int     Fsnext( void );
int     Frename( int zero, const char *oldname, const char *newname );
int     Fdatime( _DOSTIME *timeptr, int handle, int wflag );

/* GEMDOS extensions */

void    *Mxalloc( long number, int mode );
long    Maddalt( void *start, long size );

/* Network Gemdos Extension */

long	Flock( int handle, int mode, long start, long length );

/* BIOS */

void    Getmpb( _MPB *ptr );
int     Bconstat( int dev );
long    Bconin( int dev );
long    Bconout( int dev, int c );
long    Rwabs( int rwflag, void *buf, int cnt, int recnr, int dev );
void    (*Setexc( int number, void (*exchdlr)() )) ();
#define Setexc(number, exchdlr)	Setexc(number, (void(*)())(exchdlr))
long    Tickcal( void );
_BPB    *Getbpb( int dev );
long    Bcostat( int dev );
long    Mediach( int dev );
long    Drvmap( void );
long    Kbshift( int mode );
#define Getshift() Kbshift(-1)

/* XBios */

void    Initmous( int type, _PARAM *par, void (*mousevec)() );
#define Initmous(type, par, mousevec) Initmous(type, par, (void(*)()) mousevec)
void    *Ssbrk( int count );
void    *Physbase( void );
void    *Logbase( void );
int     Getrez( void );
void    Setscreen( void *laddr, void *paddr, int rez );
void    Setpalette( void *pallptr );
int     Setcolor( int colornum, int color );
int     Floprd( void *buf, long filler, int devno, int sectno,
               int trackno, int sideno, int count );
int     Flopwr( void *buf, long filler, int devno, int sectno,
               int trackno, int sideno, int count );
int     Flopfmt( void *buf, long filler, int devno, int spt, int trackno,
                int sideno, int interlv, long magic, int virgin );
void    Midiws( int cnt, void *ptr );
void    Mfpint( int erno, void (*vector)() );
_IOREC   *Iorec( int dev );
long    Rsconf( int baud, int ctr, int ucr, int rsr, int tsr, int scr );
_KEYTAB  *Keytbl( void *unshift, void *shift, void *capslock );
long    Random( void );
void    Protobt( void *buf, long serialno, int disktype, int execflag );
int     Flopver( void *buf, long filler, int devno, int sectno,
                int trackno, int sideno, int count );
void    Scrdmp( void );
int     Cursconf( int func, int rate );
void    Settime( unsigned long time );
unsigned long  Gettime( void );
void    Bioskeys( void );
void    Ikbdws( int count, void *ptr );
void    Jdisint( int number );
void    Jenabint( int number );
char    Giaccess( char data, int regno );
void    Offgibit( int bitno );
void    Ongibit( int bitno );
void    Xbtimer( int timer, int control, int data, void (*vector)() );
void    *Dosound( void *buf );
int     Setprt( int config );
_KBDVECS *Kbdvbase( void );
int     Kbrate( int initial, int repeat );
void    Prtblk( _PBDEF *par );
void    Vsync( void );
long    Supexec( long (*func)() );
#define Supexec(func) Supexec((long (*) ()) func)
void    Puntaes( void );
int     Floprate( int devno, int newrate );
int     Blitmode( int mode );

/* TOS030 XBios */
int     DMAread( long sector, int count, void *buffer, int devno );
int     DMAwrite( long sector, int count, void *buffer, int devno );
int     NVMaccess( int opcode, int start, int count, void *buffer );
long    Bconmap( int devno );
int     Esetshift( int shftMode );
#define EsetShift Esetshift
int     Egetshift( void );
#define EgetShift Egetshift
int     EsetBank( int bankNum );
int     EsetColor( int colorNum, int color );
void    EsetPalette( int colorNum, int count, int *palettePtr );
void    EgetPalette( int colorNum, int count, int *palettePtr );
int     EsetGray( int swtch );
int     EsetSmear( int swtch );

#else /* !__TURBOC__ */

#ifdef __LATTICE__

/*
*
* GEMDOS inline bindings for Lattice C.
*
*/
void _vgv(int);
unsigned short _ugv(int);
int _igv(int);
long _lgv(int);
_DTA *_Dgv(int);

void _vgs(int,int);
void _vgL(int,_CCONLINE *);
void _vgD(int,_DTA *);
int _igs(int,int);
int _igu(int,unsigned short);
int _igp(int,void *);
int _igC(int,const char *);
long _lgs(int,int);
void *_pgl(int,long);
void *_pgp(int,void *);

void _vgls(int,long,int);
int _igss(int,int,int);
int _igcs(int,char *,int);
int _igCs(int,const char *,int);
int _igIs(int,_DISKINFO *,int);
int _igpl(int,void *,long);
long _lgCs(int,const char *,int);
void *_pgls(int,long,int);

short _sgCss(int,const char *,int,int);
int _igspl(int,int,void *,long);
int _igsCC(int,int,const char *,const char *);
long _lgspl(int,int,void *,long);
long _lgslp(int,int,long,void *);
long _lgslP(int,int,long,const void *);
long _lglss(int,long,int,int);
long _lgTss(int,_DOSTIME *,int,int);

int _igsCpp(int,int,const char *,void *,void *);
long _lgssll(int,int,int,long,long);

#pragma inline _vgv((short)) {register d2,a2; "4e41";}
#pragma inline _vgs((short),(short)) {register d2,a2; "4e41";}
#pragma inline _vgL((short),) {register d2,a2; "4e41";}
#pragma inline _vgD((short),) {register d2,a2; "4e41";}
#pragma inline d0=_igv((short)) {register d2,a2; "4e41";}
#pragma inline d0=_igs((short),(short)) {register d2,a2; "4e41";}
#pragma inline d0=_igu((short),) {register d2,a2; "4e41";}
#pragma inline d0=_igp((short),) {register d2,a2; "4e41";}
#pragma inline d0=_igC((short),) {register d2,a2; "4e41";}
#pragma inline d0=_ugv((short)) {register d2,a2; "4e41";}
#pragma inline d0=_lgv((short)) {register d2,a2; "4e41";}
#pragma inline d0=_lgs((short),(short)) {register d2,a2; "4e41";}
#pragma inline d0=_Dgv((short)) {register d2,a2; "4e41";}
#pragma inline d0=_pgl((short),) {register d2,a2; "4e41";}
#pragma inline d0=_pgp((short),) {register d2,a2; "4e41";}

#pragma inline d0=_igss((short),(short),(short)) {register d2,a2; "4e41";}
#pragma inline d0=_igcs((short),,(short)) {register d2,a2; "4e41";}
#pragma inline d0=_igCs((short),,(short)) {register d2,a2; "4e41";}
#pragma inline d0=_igIs((short),,(short)) {register d2,a2; "4e41";}
#pragma inline d0=_igpl((short),,) {register d2,a2; "4e41";}
#pragma inline d0=_lgCs((short),,(short)) {register d2,a2; "4e41";}

#pragma inline d0=_pgls((short),,(short)) {register d2,a2; "4e41";}

#pragma inline d0=_sgCss((short),,(short),(short)) {register d2,a2; "4e41";}
#pragma inline d0=_lgslp((short),(short),,) {register d2,a2; "4e41";}
#pragma inline d0=_lgslP((short),(short),,) {register d2,a2; "4e41";}
#pragma inline d0=_lgspl((short),(short),,) {register d2,a2; "4e41";}
#pragma inline d0=_lglss((short),,(short),(short)) {register d2,a2; "4e41";}
#pragma inline d0=_lgTss((short),,(short),(short)) {register d2,a2; "4e41";}
#pragma inline d0=_igsCC((short),(short),,) {register d2,a2; "4e41";}

#pragma inline d0=_igsCpp((short),(short),,,) {register d2,a2; "4e41";}


#define Pterm0()	_vgv(0)
#define Cconin()	_lgv(1)
#define Cconout(a)	_vgs(2,a)
#define Cauxin()	_igv(3)
#define Cauxout(a)	_vgs(4,a)
#define Cprnout(a)	_igs(5,a)
#define Crawio(a)	_lgs(6,a)
#define Crawcin()	_lgv(7)
#define Cnecin()	_lgv(8)
#define Cconws(a)	_igC(9,a)
#define Cconrs(a)	_vgL(10,a)
#define Cconis()	_igv(11)
#define Dsetdrv(a)	_lgs(14,a)
#define Cconos()	_igv(16)
#define Cprnos()	_igv(17)
#define Cauxis()	_igv(18)
#define Cauxos()	_igv(19)
#define Dgetdrv()	_igv(25)
#define Fsetdta(a)	_vgD(26,a)
#define Super(a)	_pgp(32,a)
#define Tgetdate()	_ugv(42)
#define Tsetdate(a)	_igu(43,a)
#define Tgettime()	_ugv(44)
#define Tsettime(a)	_igu(45,a)
#define Fgetdta()	_Dgv(47)
#define Sversion()	_Vgv(48)
#define Ptermres(a,b)	_vgls(49,a,b)
#define Dfree(a,b)	_igIs(54,a,b)
#define Dcreate(a)	_igC(57,a)
#define Ddelete(a)	_igC(58,a)
#define Dsetpath(a)	_igC(59,a)
#define Fcreate(a,b)	_lgCs(60,a,b)
#define Fopen(a,b)	_lgCs(61,a,b)
#define Fclose(a)	_igs(62,a)
#define Fread(a,b,c)	_lgslp(63,a,b,c)
#define Fwrite(a,b,c)	_lgslP(64,a,b,c)
#define Fdelete(a)	_igC(65,a)
#define Fseek(a,b,c)	_lglss(66,a,b,c)
#define Fattrib(a,b,c)	_sgCss(67,a,b,c)
#define Fdup(a)		_lgs(69,a)
#define Fforce(a,b)	_igss(70,a,b)
#define Dgetpath(a,b)	_igcs(71,a,b)
#define Malloc(a)	_pgl(72,a)
#define Mfree(a)	_igp(73,a)
#define Mshrink(a,b)	_lgspl(74,0,a,b)
#define Pexec(a,b,c,d)	_igsCpp(75,a,b,c,d)
#define Pterm(a)	_vgs(76,a)
#define Fsfirst(a,b)	_igCs(78,a,b)
#define Fsnext()	_igv(79)
#define Frename(a,b,c)	_igsCC(86,a,b,c)
#define Fdatime(a,b,c)	_lgTss(87,a,b,c)

#define Maddalt(a,b)	_igpl(20,a,b)
#define Mxalloc(a,b)	_pgls(68,a,b)

/*
*
* Network GEMDOS, don't know the function numbers yet.
*
*/
/*
#define Nversion() _lgv()
#define Frlock(a,b,c) _lgsll(,a,b,c)
#define Frunlock(a,b) _lgsl(,a,b)
#define Flock(a,b) _lgsl(,a,b)
#define Funlock(a) _lgs(,a)
#define Fflush(a) _lgs(,a)
#define Unlock() _lgC(,a)
#define Lock() _lgC(,a)
*/

/*
*
* BIOS inline bindings for Lattice.
*
*/
long _lbv(int);
unsigned long _Ubv(int);

void _vbM(int,_MPB *);
int _ibs(int,int);
long _lbs(int,int);
_BPB *_Bbs(int,int);

int _ibss(int,int,int);
void (*_FbsF(int,int,void (*)(void)))(void);

int _ibspsss(int,int,void *,int,int,int);
int _ibspssl(int,int,void *,int,int,long);


#pragma inline d0=_lbv((short)) {register d2,a2; "4e4d";}
#pragma inline d0=_Ubv((short)) {register d2,a2; "4e4d";}

#pragma inline _vbM((short),) {register d2,a2; "4e4d";}
#pragma inline d0=_ibs((short),(short)) {register d2,a2; "4e4d";}
#pragma inline d0=_lbs((short),(short)) {register d2,a2; "4e4d";}
#pragma inline d0=_Bbs((short),(short)) {register d2,a2; "4e4d";}

#pragma inline d0=_ibss((short),(short),(short)) {register d2,a2; "4e4d";}
#pragma inline d0=_FbsF((short),(short),) {register d2,a2; "4e4d";}

#pragma inline d0=_ibsss((short),,(short),(short),(short)) {register d2,a2; "4e4d";}
#pragma inline d0=_ibssl((short),,(short),(short),) {register d2,a2; "4e4d";}


#define Getmpb(a)	_vbM(0,a)
#define Bconstat(a)	_ibs(1,a)
#define Bconin(a)	_lbs(2,a)
#define Bconout(a,b)	_ibss(3,a,b)
#define Rwabs(a,b,c,d,e)	_ibspsss(4,a,b,c,d,e)
#define Setexc(a,b)	_FbsF(5,a,b)
#define Tickcal()	_lbv(6)
#define Getbpb(a)	_Bbs(7,a)
#define Bcostat(a)	_ibs(8,a)
#define Mediach(a)	_ibs(9,a)
#define Drvmap()	_Ubv(10)
#define Kbshift(a)	_lbs(11,a)
#define Lrwabs(a,b,c,d,e)	_ibspssl(12,a,b,c,d,e)

/*
*
* XBIOS inline bindings for Lattice.
*
*/
void _vxv(int);
short _sxv(int);
int _ixv(int);
long _lxv(int);
void *_pxv(int);
_DOSTIME _Txv(int);
_KBDVECS *_Vxv(int);

void _vxs(int,int);
void _vxr(int,unsigned short);
void _vxC(int,const char *);
void _vxT(int,_DOSTIME);
short _sxs(int,int);
short _sxQ(int,_PBDEF *);
int _ixs(int,int);
long _lxG(int,long (*)(void));
void *_pxs(int,int);
_IOREC *_Ixs(int,int);
long _Bxs(int,int);

void _vxsC(int,int,const char *);
void _vxsF(int,int,void (*)(void));
short _sxss(int,int,int);
int _ixss(int,int,int);

void _vxsMF(int,int,_PARAM *,void (*)(void));
void _vxpps(int,void *,void *,int);
void _vxssq(int,int,int,short *);
void _vxssQ(int,int,int,const short *);
_KEYTAB *_KxCCC(int,const char *,const char *,const char *);

void _vxplss(int,void *,long,int,int);
void _vxsssF(int,int,int,int,void (*)(void));
int _ixsssc(int,int,int,int,char *);
int _ixlsps(int,long,int,void *,int);
int _ixlsPs(int,long,int,const void *,int);

long _lxssssss(int,int,int,int,int,int,int);

short _sxplsssss(int,void *,long,int,int,int,int,int);
short _sxPlsssss(int,const void *,long,int,int,int,int,int);

short _sxprsssssls(int,void *,short *,int,int,int,int,int,long,int);


#pragma inline _vxv((short)) {register d2,a2; "4e4e";}
#pragma inline d0=_sxv((short)) {register d2,a2; "4e4e";}
#pragma inline d0=_ixv((short)) {register d2,a2; "4e4e";}
#pragma inline d0=_lxv((short)) {register d2,a2; "4e4e";}
#pragma inline d0=_pxv((short)) {register d2,a2; "4e4e";}
#pragma inline d0=_Txv((short)) {register d2,a2; "4e4e";}
#pragma inline d0=_Vxv((short)) {register d2,a2; "4e4e";}

#pragma inline _vxs((short),(short)) {register d2,a2; "4e4e";}
#pragma inline _vxr((short),) {register d2,a2; "4e4e";}
#pragma inline _vxC((short),) {register d2,a2; "4e4e";}
#pragma inline _vxT((short),) {register d2,a2; "4e4e";}
#pragma inline d0=_sxs((short),(short)) {register d2,a2; "4e4e";}
#pragma inline d0=_sxQ((short),) {register d2,a2; "4e4e";}
#pragma inline d0=_ixs((short),(short)) {register d2,a2; "4e4e";}
#pragma inline d0=_lxG((short),) {register d2,a2; "4e4e";}
#pragma inline d0=_pxs((short),(short)) {register d2,a2; "4e4e";}
#pragma inline d0=_Ixs((short),(short)) {register d2,a2; "4e4e";}
#pragma inline d0=_Bxs((short),(short)) {register d2,a2; "4e4e";}

#pragma inline _vxsC((short),(short),) {register d2,a2; "4e4e";}
#pragma inline _vxsF((short),(short),) {register d2,a2; "4e4e";}
#pragma inline d0=_sxss((short),(short),(short)) {register d2,a2; "4e4e";}
#pragma inline d0=_ixss((short),(short),(short)) {register d2,a2; "4e4e";}

#pragma inline _vxsMF((short),(short),,) {register d2,a2; "4e4e";}
#pragma inline _vxpps((short),,,(short)) {register d2,a2; "4e4e";}
#pragma inline _vxssq((short),(short),(short),) {register d2,a2; "4e4e";}
#pragma inline _vxssQ((short),(short),(short),) {register d2,a2; "4e4e";}
#pragma inline d0=_KxCCC((short),,,) {register d2,a2; "4e4e";}

#pragma inline _vxplss((short),,,(short),(short)) {register d2,a2; "4e4e";}
#pragma inline _vxsssF((short),(short),(short),(short),) {register d2,a2; "4e4e";}
#pragma inline d0=_ixsssc((short),(short),(short),(short),) {register d2,a2; "4e4e";}
#pragma inline d0=_ixlsps((short),,(short),,(short)) {register d2,a2; "4e4e";}
#pragma inline d0=_ixlsPs((short),,(short),,(short)) {register d2,a2; "4e4e";}

#pragma inline d0=_lxssssss((short),(short),(short),(short),(short),(short),(short)) {register d2,a2; "4e4e";}

#pragma inline d0=_sxplsssss((short),,,(short),(short),(short),(short),(short)) {register d2,a2; "4e4e";}
#pragma inline d0=_sxPlsssss((short),,,(short),(short),(short),(short),(short)) {register d2,a2; "4e4e";}

#pragma inline d0=_sxprsssssls((short),,,(short),(short),(short),(short),(short),,(short)) {register d2,a2; "4e4e";}


#define Initmous(a,b,c)	_vxsMF(0,a,b,c)
#define Ssbrk(a)	_pxs(1,a)
#define Physbase()	_pxv(2)
#define Logbase()	_pxv(3)
#define Getrez()	_sxv(4)
#define Setscreen(a,b,c)	_vxpps(5,a,b,c)
#define Setpallete(a)	_vxr(6,a)
#define setcolor(a,b)	_sxss(7,a,b)
#define Floprd(a,b,c,d,e,f,g)	_sxplsssss(8,a,b,c,d,e,f,g)
#define Flopwr(a,b,c,d,e,f,g)	_sxPlsssss(9,a,b,c,d,e,f,g)
#define Flopfmt(a,b,c,d,e,f,g,h,i)	_sxprsssssls(10,a,b,c,d,e,f,g,h,i)
#define Midiws(a,b)	_vxsC(12,a,b)
#define Mfpint(a,b)	_vxsF(13,a,b)
#define Iorec(a)	_Ixs(14,a)
#define Rsconf(a,b,c,d,e,f)	_lxssssss(15,a,b,c,d,e,f)
#define Keytbl(a,b,c)	_KxCCC(16,a,b,c)
#define Random()	_lxv(17)
#define Protobt(a,b,c,d)	_vxplss(18,a,b,c,d)
#define Flopver(a,b,c,d,e,f,g)	_sxplsssss(19,a,b,c,d,e,f,g)
#define Scrdmp()	_vxv(20)
#define Cursconf(a,b)	_sxss(21,a,b)
#define Settime(a)	_vxT(22,a)
#define Gettime()	_Txv(23)
#define Bioskeys()	_vxv(24)
#define Ikbdws(a,b)	_vxsC(25,a,b)
#define Jdisint(a)	_vxs(26,a)
#define Jenabint(a)	_vxs(27,a)
#define Giaccess(a,b)	_sxss(28,a,b)
#define Offgibit(a)	_vxs(29,a)
#define Ongibit(a)	_vxs(30,a)
#define Xbtimer(a,b,c,d)	_vxsssF(31,a,b,c,d)
#define Dosound(a)	_vxC(32,a)
#define Setprt(a)	_sxs(33,a)
#define Kbdvbase()	_Vxv(34)
#define Kbrate(a,b)	_sxss(35,a,b)
#define Prtblk(a)	_sxQ(36,a)
#define Vsync()	_vxv(37)
#define Supexec(a)	_lxG(38,a)
#define Puntaes()	_vxv(39)

#define Blitmode(a)	_sxs(64,a)

#define Floprate(a,b)	_sxss(41,a,b)

#define DMAread(a,b,c,d)	_ixlsps(42,a,b,c,d)
#define DMAwrite(a,b,c,d)	_ixlsPs(43,a,b,c,d)
#define Bconmap(a)	_Bxs(44,a)
#define NVMaccess(a,b,c,d)	_ixsssc(46,a,b,c,d)

#define EsetShift(a)	_ixs(80,a)
#define EgetShift()	_ixv(81)
#define EsetBank(a)	_ixs(82,a)
#define EsetColor(a,b)	_ixss(83,a,b)
#define EsetPalette(a,b,c)	_vxssQ(84,a,b,c)
#define EgetPalette(a,b,c)	_vxssq(85,a,b,c)
#define EsetGray(a)	_ixs(86,a)
#define EsetSmear(a)	_ixs(87,a)

#else /* !__LATTICE__ */

/* want to skip all the gory details of GNU C inlines??
   search for the string "DEFINITIONS" */

#ifdef __GNUC_INLINE__
/*
 * GNU C (pseudo inline) Statement Exprs for traps
 *
 */

#if __GNUC__ > 2 || __GNUC_MINOR__ > 5
#define AND_MEMORY , "memory"
#else
#define AND_MEMORY
#define __extension__
#endif

#define trap_1_w(n)							\
__extension__								\
({									\
	register long retvalue __asm__("d0");				\
	    								\
	__asm__ volatile						\
	("\
		movw    %1,sp@-; \
		trap    #1;	\
		addqw   #2,sp "						\
	: "=r"(retvalue)			/* outputs */		\
	: "g"(n)				/* inputs  */		\
	: "d0", "d1", "d2", "a0", "a1", "a2"    /* clobbered regs */	\
	  AND_MEMORY							\
	);								\
	retvalue;							\
})

#define trap_1_ww(n, a)							\
__extension__								\
({									\
	register long retvalue __asm__("d0");				\
	short _a = (short)(a);						\
	    								\
	__asm__ volatile						\
	("\
		movw	%2,sp@-; \
		movw    %1,sp@-; \
		trap    #1;	\
		addqw   #4,sp "						\
	: "=r"(retvalue)			/* outputs */		\
	: "g"(n), "r"(_a)			/* inputs  */		\
	: "d0", "d1", "d2", "a0", "a1", "a2"    /* clobbered regs */	\
	  AND_MEMORY							\
	);								\
	retvalue;							\
})

#define trap_1_wl(n, a)							\
__extension__								\
({									\
	register long retvalue __asm__("d0");				\
	long  _a = (long) (a);						\
	    								\
	__asm__ volatile						\
	("\
		movl	%2,sp@-; \
		movw    %1,sp@-; \
		trap    #1;	\
		addqw   #6,sp "						\
	: "=r"(retvalue)			/* outputs */		\
	: "g"(n), "r"(_a)			/* inputs  */		\
	: "d0", "d1", "d2", "a0", "a1", "a2"    /* clobbered regs */	\
	  AND_MEMORY							\
	);								\
	retvalue;							\
})

#define trap_1_wlw(n, a, b)						\
__extension__								\
({									\
	register long retvalue __asm__("d0");				\
	long  _a = (long) (a);						\
	short _b = (short)(b);						\
	    								\
	__asm__ volatile						\
	("\
		movw    %3,sp@-; \
		movl    %2,sp@-; \
		movw    %1,sp@-; \
		trap    #1;	\
		addqw   #8,sp "						\
	: "=r"(retvalue)			/* outputs */		\
	: "g"(n), "r"(_a), "r"(_b)		/* inputs  */		\
	: "d0", "d1", "d2", "a0", "a1", "a2"    /* clobbered regs */	\
	  AND_MEMORY							\
	);								\
	retvalue;							\
})

#define trap_1_wwll(n, a, b, c)						\
__extension__								\
({									\
	register long retvalue __asm__("d0");				\
	short _a = (short)(a);						\
	long  _b = (long) (b);						\
	long  _c = (long) (c);						\
	    								\
	__asm__ volatile						\
	("\
		movl    %4,sp@-; \
		movl    %3,sp@-; \
		movw    %2,sp@-; \
		movw    %1,sp@-; \
		trap    #1;	\
		lea	sp@(12),sp "					\
	: "=r"(retvalue)			/* outputs */		\
	: "g"(n), "r"(_a), "r"(_b), "r"(_c)     /* inputs  */		\
	: "d0", "d1", "d2", "a0", "a1", "a2"    /* clobbered regs */	\
	  AND_MEMORY							\
	);								\
	retvalue;							\
})

#define trap_1_wlww(n, a, b, c)						\
__extension__								\
({									\
	register long retvalue __asm__("d0");				\
	long  _a = (long) (a);						\
	short _b = (short)(b);						\
	short _c = (short)(c);						\
	    								\
	__asm__ volatile						\
	("\
		movw    %4,sp@-; \
		movw    %3,sp@-; \
		movl    %2,sp@-; \
		movw    %1,sp@-; \
		trap    #1;	\
		lea	sp@(10),sp "					\
	: "=r"(retvalue)			/* outputs */		\
	: "g"(n), "r"(_a), "r"(_b), "r"(_c)     /* inputs  */		\
	: "d0", "d1", "d2", "a0", "a1", "a2"    /* clobbered regs */	\
	  AND_MEMORY							\
	);								\
	retvalue;							\
})

#define trap_1_www(n, a, b)						\
__extension__								\
({									\
	register long retvalue __asm__("d0");				\
	short _a = (short)(a);						\
	short _b = (short)(b);						\
	    								\
	__asm__ volatile						\
	("\
		movw    %3,sp@-; \
		movw    %2,sp@-; \
		movw    %1,sp@-; \
		trap    #1;	\
		addqw   #6,sp "						\
	: "=r"(retvalue)			/* outputs */		\
	: "g"(n), "r"(_a), "r"(_b)		/* inputs  */		\
	: "d0", "d1", "d2", "a0", "a1", "a2"    /* clobbered regs */	\
	  AND_MEMORY							\
	);								\
	retvalue;							\
})

#define trap_1_wll(n, a, b)						\
__extension__								\
({									\
	register long retvalue __asm__("d0");				\
	long  _a = (long) (a);						\
	long  _b = (long) (b);						\
	    								\
	__asm__ volatile						\
	("\
		movl    %3,sp@-; \
		movl    %2,sp@-; \
		movw    %1,sp@-; \
		trap    #1;	\
		lea	sp@(10),sp "					\
	: "=r"(retvalue)			/* outputs */		\
	: "g"(n), "r"(_a), "r"(_b)		/* inputs  */		\
	: "d0", "d1", "d2", "a0", "a1", "a2"    /* clobbered regs */	\
	  AND_MEMORY							\
	);								\
	retvalue;							\
})

#if __GNUC__ > 1
#define trap_1_wwlll(n, a, b, c, d)					\
__extension__								\
({									\
	register long retvalue __asm__("d0");				\
	short _a = (short)(a);			\
	long  _b = (long) (b);			\
	long  _c = (long) (c);			\
	long  _d = (long) (d);			\
	    								\
	__asm__ volatile						\
	("\
		movl    %5,sp@-; \
		movl    %4,sp@-; \
		movl    %3,sp@-; \
		movw    %2,sp@-; \
		movw    %1,sp@-; \
		trap    #1;	\
		lea	sp@(16),sp "					\
	: "=r"(retvalue)			/* outputs */		\
	: "g"(n), "r"(_a), "r"(_b), "r"(_c), "r"(_d) /* inputs  */	\
	: "d0", "d1", "d2", "a0", "a1", "a2", "memory"			\
	);								\
	retvalue;							\
})

#define trap_1_wwwll(n, a, b, c, d)					\
__extension__								\
({									\
	register long retvalue __asm__("d0");				\
	short _a = (short)(a);						\
	short _b = (short)(b);						\
	long  _c = (long) (c);						\
	long  _d = (long) (d);						\
	    								\
	__asm__ volatile						\
	("\
		movl    %5,sp@-; \
		movl    %4,sp@-; \
		movw    %3,sp@-; \
		movw    %2,sp@-; \
		movw    %1,sp@-; \
		trap    #1;	\
		lea	sp@(14),sp "					\
	: "=r"(retvalue)			/* outputs */		\
	: "g"(n), "r"(_a), "r"(_b), "r"(_c), "r"(_d) /* inputs  */	\
	: "d0", "d1", "d2", "a0", "a1", "a2", "memory"			\
	);								\
	retvalue;							\
})
#else
#define trap_1_wwlll(n, a, b, c, d)					\
({									\
	register long retvalue __asm__("d0");				\
	short _a = (short)(a);			\
	long  _b = (long) (b);			\
	long  _c = (long) (c);			\
	long  _d = (long) (d);			\
	    								\
	__asm__ volatile						\
	("\
		movl    %4,sp@-; \
		movl    %3,sp@-; \
		movl    %2,sp@-; \
		movw    %1,sp@-; \
		movw    %0,sp@- "					\
	:					     /* outputs */	\
	: "g"(n), "r"(_a), "r"(_b), "r"(_c), "r"(_d) /* inputs  */	\
        );								\
  /* no more than 5 operand allowed in asm() -- therefore the split */  \
									\
	__asm__ volatile						\
	("\
		trap    #1;	\
		lea	sp@(16),sp "					\
	: "=r"(retvalue)			/* outputs */		\
	:					/* inputs  */		\
	: "d0", "d1", "d2", "a0", "a1", "a2"    /* clobbered regs */	\
	);								\
	retvalue;							\
})

#define trap_1_wwwll(n, a, b, c, d)					\
({									\
	register long retvalue __asm__("d0");				\
	short _a = (short)(a);						\
	short _b = (short)(b);						\
	long  _c = (long) (c);						\
	long  _d = (long) (d);						\
	    								\
	__asm__ volatile						\
	("\
		movl    %4,sp@-; \
		movl    %3,sp@-; \
		movw    %2,sp@-; \
		movw    %1,sp@-; \
		movw    %0,sp@- "					\
	:					     /* outputs */	\
	: "g"(n), "r"(_a), "r"(_b), "r"(_c), "r"(_d) /* inputs  */	\
        );								\
									\
	__asm__ volatile						\
	("\
		trap    #1;	\
		lea	sp@(14),sp "					\
	: "=r"(retvalue)			/* outputs */		\
	:					/* inputs  */		\
	: "d0", "d1", "d2", "a0", "a1", "a2"    /* clobbered regs */	\
	);								\
	retvalue;							\
})
#endif

#define trap_13_wl(n, a)						\
__extension__								\
({									\
	register long retvalue __asm__("d0");				\
	long  _a = (long) (a);						\
	    								\
	__asm__ volatile						\
	("\
		movl	%2,sp@-; \
		movw    %1,sp@-; \
		trap    #13;	\
		addqw   #6,sp "						\
	: "=r"(retvalue)			/* outputs */		\
	: "g"(n), "r"(_a)			/* inputs  */		\
	: "d0", "d1", "d2", "a0", "a1", "a2"    /* clobbered regs */	\
	  AND_MEMORY							\
	);								\
	retvalue;							\
})

#define trap_13_w(n)							\
__extension__								\
({									\
	register long retvalue __asm__("d0");				\
	    								\
	__asm__ volatile						\
	("\
		movw    %1,sp@-; \
		trap    #13;	\
		addqw   #2,sp "						\
	: "=r"(retvalue)			/* outputs */		\
	: "g"(n)				/* inputs  */		\
	: "d0", "d1", "d2", "a0", "a1", "a2"    /* clobbered regs */	\
	  AND_MEMORY							\
	);								\
	retvalue;							\
})

#define trap_13_ww(n, a)						\
__extension__								\
({									\
	register long retvalue __asm__("d0");				\
	short _a = (short)(a);						\
	    								\
	__asm__ volatile						\
	("\
		movw	%2,sp@-; \
		movw    %1,sp@-; \
		trap    #13;	\
		addqw   #4,sp "						\
	: "=r"(retvalue)			/* outputs */		\
	: "g"(n), "r"(_a)			/* inputs  */		\
	: "d0", "d1", "d2", "a0", "a1", "a2"    /* clobbered regs */	\
	  AND_MEMORY							\
	);								\
	retvalue;							\
})

#define trap_13_www(n, a, b)						\
__extension__								\
({									\
	register long retvalue __asm__("d0");				\
	short _a = (short)(a);						\
	short _b = (short)(b);						\
	    								\
	__asm__ volatile						\
	("\
		movw    %3,sp@-; \
		movw	%2,sp@-; \
		movw    %1,sp@-; \
		trap    #13;	\
		addqw   #6,sp "						\
	: "=r"(retvalue)			/* outputs */		\
	: "g"(n), "r"(_a), "r"(_b)		/* inputs  */		\
	: "d0", "d1", "d2", "a0", "a1", "a2"    /* clobbered regs */	\
	  AND_MEMORY							\
	);								\
	retvalue;							\
})

#if __GNUC__ > 1
#define trap_13_wwlwww(n, a, b, c, d, e)				\
__extension__								\
({									\
	register long retvalue __asm__("d0");				\
	short _a = (short)(a);			\
	long  _b = (long) (b);			\
	short _c = (short)(c);			\
	short _d = (short)(d);			\
	short _e = (short)(e);			\
	    								\
	__asm__ volatile						\
	("\
		movw    %6,sp@-; \
		movw    %5,sp@-; \
		movw    %4,sp@-; \
		movl    %3,sp@-; \
		movw    %2,sp@-; \
		movw    %1,sp@-; \
		trap    #13;	\
		lea	sp@(14),sp "					\
	: "=r"(retvalue)			/* outputs */		\
	: "g"(n),							\
	  "r"(_a), "r"(_b), "r"(_c), "r"(_d), "r"(_e) /* inputs  */	\
	: "d0", "d1", "d2", "a0", "a1", "a2", "memory"			\
	);								\
	retvalue;							\
})
#else
#define trap_13_wwlwww(n, a, b, c, d, e)				\
({									\
	register long retvalue __asm__("d0");				\
	short _a = (short)(a);			\
	long  _b = (long) (b);			\
	short _c = (short)(c);			\
	short _d = (short)(d);			\
	short _e = (short)(e);			\
	    								\
	__asm__ volatile						\
	("\
		movw    %4,sp@-; \
		movw    %3,sp@-; \
		movw    %2,sp@-; \
		movl    %1,sp@-; \
		movw    %0,sp@-	"					\
	:					      /* outputs */	\
	: "r"(_a), "r"(_b), "r"(_c), "r"(_d), "r"(_e) /* inputs  */	\
	);								\
									\
	__asm__ volatile						\
	("\
		movw    %1,sp@-; \
		trap    #13;	\
		lea	sp@(14),sp "					\
	: "=r"(retvalue)			/* outputs */		\
	: "g"(n)				/* inputs  */		\
	: "d0", "d1", "d2", "a0", "a1", "a2"    /* clobbered regs */	\
	);								\
	retvalue;							\
})
#endif

#define trap_13_wwl(n, a, b)						\
__extension__								\
({									\
	register long retvalue __asm__("d0");				\
	short _a = (short)(a);						\
	long  _b = (long) (b);						\
	    								\
	__asm__ volatile						\
	("\
		movl    %3,sp@-; \
		movw    %2,sp@-; \
		movw    %1,sp@-; \
		trap    #13;	\
		addqw   #8,sp "						\
	: "=r"(retvalue)			/* outputs */		\
	: "g"(n), "r"(_a), "r"(_b)		/* inputs  */		\
	: "d0", "d1", "d2", "a0", "a1", "a2"    /* clobbered regs */	\
	  AND_MEMORY							\
	);								\
	retvalue;							\
})

#define trap_14_wwl(n, a, b)						\
__extension__								\
({									\
	register long retvalue __asm__("d0");				\
	short _a = (short)(a);						\
	long  _b = (long) (b);						\
	    								\
	__asm__ volatile						\
	("\
		movl    %3,sp@-; \
		movw    %2,sp@-; \
		movw    %1,sp@-; \
		trap    #14;	\
		addqw   #8,sp "						\
	: "=r"(retvalue)			/* outputs */		\
	: "g"(n), "r"(_a), "r"(_b)              /* inputs  */		\
	: "d0", "d1", "d2", "a0", "a1", "a2"    /* clobbered regs */	\
	  AND_MEMORY							\
	);								\
	retvalue;							\
})

#define trap_14_wwll(n, a, b, c)					\
__extension__								\
({									\
	register long retvalue __asm__("d0");				\
	short _a = (short)(a);						\
	long  _b = (long) (b);						\
	long  _c = (long) (c);						\
	    								\
	__asm__ volatile						\
	("\
		movl    %4,sp@-; \
		movl    %3,sp@-; \
		movw    %2,sp@-; \
		movw    %1,sp@-; \
		trap    #14;	\
		lea	sp@(12),sp "					\
	: "=r"(retvalue)			/* outputs */		\
	: "g"(n), "r"(_a), "r"(_b), "r"(_c)     /* inputs  */		\
	: "d0", "d1", "d2", "a0", "a1", "a2"    /* clobbered regs */	\
	  AND_MEMORY							\
	);								\
	retvalue;							\
})

#define trap_14_ww(n, a)						\
__extension__								\
({									\
	register long retvalue __asm__("d0");				\
	short _a = (short)(a);						\
	    								\
	__asm__ volatile						\
	("\
		movw    %2,sp@-; \
		movw    %1,sp@-; \
		trap    #14;	\
		addqw   #4,sp "						\
	: "=r"(retvalue)			/* outputs */		\
	: "g"(n), "r"(_a)			/* inputs  */		\
	: "d0", "d1", "d2", "a0", "a1", "a2"    /* clobbered regs */	\
	  AND_MEMORY							\
	);								\
	retvalue;							\
})

#define trap_14_w(n)							\
__extension__								\
({									\
	register long retvalue __asm__("d0");				\
	    								\
	__asm__ volatile						\
	("\
		movw    %1,sp@-; \
		trap    #14;	\
		addqw   #2,sp "						\
	: "=r"(retvalue)			/* outputs */		\
	: "g"(n)				/* inputs  */		\
	: "d0", "d1", "d2", "a0", "a1", "a2"    /* clobbered regs */	\
	  AND_MEMORY							\
	);								\
	retvalue;							\
})

#define trap_14_wllw(n, a, b, c)					\
__extension__								\
({									\
	register long retvalue __asm__("d0");				\
	long  _a = (long) (a);						\
	long  _b = (long) (b);						\
	short _c = (short)(c);						\
	    								\
	__asm__ volatile						\
	("\
		movw    %4,sp@-; \
		movl    %3,sp@-; \
		movl    %2,sp@-; \
		movw    %1,sp@-; \
		trap    #14;	\
		lea	sp@(12),sp "					\
	: "=r"(retvalue)			/* outputs */		\
	: "g"(n), "r"(_a), "r"(_b), "r"(_c)       /* inputs  */		\
	: "d0", "d1", "d2", "a0", "a1", "a2"    /* clobbered regs */	\
	  AND_MEMORY							\
	);								\
	retvalue;							\
})

#define trap_14_wl(n, a)						\
__extension__								\
({									\
	register long retvalue __asm__("d0");				\
	long  _a = (long) (a);						\
	    								\
	__asm__ volatile						\
	("\
		movl    %2,sp@-; \
		movw    %1,sp@-; \
		trap    #14;	\
		addqw   #6,sp "						\
	: "=r"(retvalue)			/* outputs */		\
	: "g"(n), "r"(_a)			/* inputs  */		\
	: "d0", "d1", "d2", "a0", "a1", "a2"    /* clobbered regs */	\
	  AND_MEMORY							\
	);								\
	retvalue;							\
})

#define trap_14_www(n, a, b)						\
__extension__								\
({									\
	register long retvalue __asm__("d0");				\
	short _a = (short)(a);						\
	short _b = (short)(b);						\
	    								\
	__asm__ volatile						\
	("\
		movw    %3,sp@-; \
		movw    %2,sp@-; \
		movw    %1,sp@-; \
		trap    #14;	\
		addqw   #6,sp "						\
	: "=r"(retvalue)			/* outputs */		\
	: "g"(n), "r"(_a), "r"(_b)		/* inputs  */		\
	: "d0", "d1", "d2", "a0", "a1", "a2"    /* clobbered regs */	\
	  AND_MEMORY							\
	);								\
	retvalue;							\
})

#if __GNUC__ > 1
#define trap_14_wllwwwww(n, a, b, c, d, e, f, g)			\
__extension__								\
({									\
	register long retvalue __asm__("d0");				\
	long  _a = (long) (a);						\
	long  _b = (long) (b);						\
	short _c = (short)(c);						\
	short _d = (short)(d);						\
	short _e = (short)(e);						\
	short _f = (short)(f);						\
	short _g = (short)(g);						\
	    								\
	__asm__ volatile						\
	("\
		movw    %8,sp@-; \
		movw    %7,sp@-; \
		movw    %6,sp@-; \
		movw    %5,sp@-; \
		movw    %4,sp@-; \
		movl    %3,sp@-; \
		movl    %2,sp@-; \
		movw    %1,sp@-; \
		trap    #14;	\
		lea	sp@(20),sp "					\
	: "=r"(retvalue)			/* outputs */		\
	: "g"(n), "r"(_a), "r"(_b),					\
	  "r"(_c), "r"(_d), "r"(_e), "r"(_f), "r"(_g) /* inputs  */	\
	: "d0", "d1", "d2", "a0", "a1", "a2", "memory"			\
	);								\
	retvalue;							\
})

#define trap_14_wllwwwwlw(n, a, b, c, d, e, f, g, h)			\
__extension__								\
({									\
	register long retvalue __asm__("d0");				\
	long  _a = (long) (a);						\
	long  _b = (long) (b);						\
	short _c = (short)(c);						\
	short _d = (short)(d);						\
	short _e = (short)(e);						\
	short _f = (short)(f);						\
	long  _g = (long) (g);						\
	short _h = (short)(h);						\
	    								\
	__asm__ volatile						\
	("\
		movw    %9,sp@-; \
		movl    %8,sp@-; \
		movw    %7,sp@-; \
		movw    %6,sp@-; \
		movw    %5,sp@-; \
		movw    %4,sp@-; \
		movl    %3,sp@-; \
		movl    %2,sp@-; \
		movw    %1,sp@-; \
		trap    #14;	\
		lea	sp@(24),sp "					\
	: "=r"(retvalue)			   /* outputs */	\
	: "g"(n), "r"(_a), "r"(_b), "r"(_c),				\
	  "r"(_d), "r"(_e), "r"(_f), "r"(_g), "r"(_h) /* inputs  */	\
	: "d0", "d1", "d2", "a0", "a1", "a2", "memory"			\
	);								\
	retvalue;							\
})

#define trap_14_wllwwwwwlw(n, a, b, c, d, e, f, g, h, i)		\
__extension__								\
({									\
	register long retvalue __asm__("d0");				\
	long  _a = (long) (a);						\
	long  _b = (long) (b);						\
	short _c = (short)(c);						\
	short _d = (short)(d);						\
	short _e = (short)(e);						\
	short _f = (short)(f);						\
	short _g = (short)(g);						\
	long  _h = (long) (h);						\
	short _i = (short)(i);						\
	    								\
	__asm__ volatile						\
	("\
		movw    %9,sp@-; \
		movl    %8,sp@-; \
		movw    %7,sp@-; \
		movw    %6,sp@-; \
		movw    %5,sp@-; \
		movw    %4,sp@-; \
		movw    %3,sp@-; \
		movl    %2,sp@-; \
		movl    %1,sp@-; \
                movw    %0,sp@- "					\
	:					      /* outputs */	\
	: "g"(n), "g"(_a), "g"(_b), "g"(_c), "g"(_d),			\
	  "g"(_e), "g"(_f), "g"(_g), "g"(_h), "g"(_i) /* inputs  */	\
	);								\
	    								\
	__asm__ volatile						\
	("\
		trap    #14;	\
		lea	sp@(26),sp "					\
	: "=r"(retvalue)			/* outputs */		\
	: 					/* inputs  */		\
	: "d0", "d1", "d2", "a0", "a1", "a2", "memory"			\
	);								\
	retvalue;							\
})


#define trap_14_wwwwwww(n, a, b, c, d, e, f)				\
__extension__								\
({									\
	register long retvalue __asm__("d0");				\
	short _a = (short)(a);						\
	short _b = (short)(b);						\
	short _c = (short)(c);						\
	short _d = (short)(d);						\
	short _e = (short)(e);						\
	short _f = (short)(f);						\
	    								\
	__asm__ volatile						\
	("\
		movw    %7,sp@-; \
		movw    %6,sp@-; \
		movw    %5,sp@-; \
		movw    %4,sp@-; \
		movw    %3,sp@-; \
		movw    %2,sp@-; \
		movw    %1,sp@-; \
		trap    #14;	\
		lea	sp@(14),sp "					\
	: "=r"(retvalue)			/* outputs */		\
	: "g"(n), "g"(_a),						\
	  "g"(_b), "g"(_c), "g"(_d), "g"(_e), "g"(_f)	/* inputs  */	\
	: "d0", "d1", "d2", "a0", "a1", "a2", "memory"			\
	);								\
	retvalue;							\
})
#else
#define trap_14_wllwwwww(n, a, b, c, d, e, f, g)			\
({									\
	register long retvalue __asm__("d0");				\
	long  _a = (long) (a);						\
	long  _b = (long) (b);						\
	short _c = (short)(c);						\
	short _d = (short)(d);						\
	short _e = (short)(e);						\
	short _f = (short)(f);						\
	short _g = (short)(g);						\
	    								\
	__asm__ volatile						\
	("\
		movw    %4,sp@-; \
		movw    %3,sp@-; \
		movw    %2,sp@-; \
		movw    %1,sp@-; \
		movw    %0,sp@-	"					\
	:					      /* outputs */	\
	: "r"(_c), "r"(_d), "r"(_e), "r"(_f), "r"(_g) /* inputs  */	\
	);								\
									\
	__asm__ volatile						\
	("\
		movl    %3,sp@-; \
		movl    %2,sp@-; \
		movw    %1,sp@-; \
		trap    #14;	\
		lea	sp@(20),sp "					\
	: "=r"(retvalue)			/* outputs */		\
	: "g"(n), "r"(_a), "r"(_b)		/* inputs  */		\
	: "d0", "d1", "d2", "a0", "a1", "a2"    /* clobbered regs */	\
	);								\
	retvalue;							\
})

#define trap_14_wllwwwwlw(n, a, b, c, d, e, f, g, h)			\
({									\
	register long retvalue __asm__("d0");				\
	long  _a = (long) (a);						\
	long  _b = (long) (b);						\
	short _c = (short)(c);						\
	short _d = (short)(d);						\
	short _e = (short)(e);						\
	short _f = (short)(f);						\
	long  _g = (long) (g);						\
	short _h = (short)(h);						\
	    								\
	__asm__ volatile						\
	("\
		movw    %4,sp@-; \
		movl    %3,sp@-; \
		movw    %2,sp@-; \
		movw    %1,sp@-; \
		movw    %0,sp@- "					\
	:					      /* outputs */	\
	: "r"(_d), "r"(_e), "r"(_f), "r"(_g), "r"(_h) /* inputs  */	\
	);								\
	    								\
	__asm__ volatile						\
	("\
		movw    %4,sp@-; \
		movl    %3,sp@-; \
		movl    %2,sp@-; \
		movw    %1,sp@-; \
		trap    #14;	\
		lea	sp@(24),sp "					\
	: "=r"(retvalue)			   /* outputs */	\
	: "g"(n), "r"(_a), "r"(_b), "r"(_c)        /* inputs  */	\
	: "d0", "d1", "d2", "a0", "a1", "a2"    /* clobbered regs */	\
	);								\
	retvalue;							\
})

#define trap_14_wllwwwwwlw(n, a, b, c, d, e, f, g, h, i)		\
({									\
	register long retvalue __asm__("d0");				\
	long  _a = (long) (a);						\
	long  _b = (long) (b);						\
	short _c = (short)(c);						\
	short _d = (short)(d);						\
	short _e = (short)(e);						\
	short _f = (short)(f);						\
	short _g = (short)(g);						\
	long  _h = (long) (h);						\
	short _i = (short)(i);						\
	    								\
	__asm__ volatile						\
	("\
		movw    %4,sp@-; \
		movl    %3,sp@-; \
		movw    %2,sp@-; \
		movw    %1,sp@-; \
		movw    %0,sp@- "					\
	:					      /* outputs */	\
	: "r"(_e), "r"(_f), "r"(_g), "r"(_h), "r"(_i) /* inputs  */	\
	);								\
									\
	__asm__ volatile						\
	("\
		movw    %4,sp@-; \
		movw    %3,sp@-; \
		movl    %2,sp@-; \
		movl    %1,sp@-; \
                movw    %0,sp@- "					\
	:					     /* outputs */	\
	: "g"(n), "r"(_a), "r"(_b), "r"(_c), "r"(_d) /* inputs  */	\
	);								\
	    								\
	__asm__ volatile						\
	("\
		trap    #14;	\
		lea	sp@(26),sp "					\
	: "=r"(retvalue)			/* outputs */		\
	: 					/* inputs  */		\
	: "d0", "d1", "d2", "a0", "a1", "a2"    /* clobbered regs */	\
	);								\
	retvalue;							\
})


#define trap_14_wwwwwww(n, a, b, c, d, e, f)				\
({									\
	register long retvalue __asm__("d0");				\
	short _a = (short)(a);						\
	short _b = (short)(b);						\
	short _c = (short)(c);						\
	short _d = (short)(d);						\
	short _e = (short)(e);						\
	short _f = (short)(f);						\
	    								\
	__asm__ volatile						\
	("\
		movw    %4,sp@-; \
		movw    %3,sp@-; \
		movw    %2,sp@-; \
		movw    %1,sp@-; \
		movw    %0,sp@- "					\
	:					        /* outputs */	\
	: "r"(_b), "r"(_c), "r"(_d), "r"(_e), "r"(_f)	/* inputs  */	\
	);								\
									\
	__asm__ volatile						\
	("\
		movw    %2,sp@-; \
		movw    %1,sp@-; \
		trap    #14;	\
		lea	sp@(14),sp "					\
	: "=r"(retvalue)			/* outputs */		\
	: "g"(n), "r"(_a)			/* inputs  */		\
	: "d0", "d1", "d2", "a0", "a1", "a2"    /* clobbered regs */	\
	);								\
	retvalue;							\
})
#endif

#define trap_14_wlll(n, a, b, c)					\
__extension__								\
({									\
	register long retvalue __asm__("d0");				\
	long  _a = (long) (a);						\
	long  _b = (long) (b);						\
	long  _c = (long) (c);						\
	    								\
	__asm__ volatile						\
	("\
		movl    %4,sp@-; \
		movl    %3,sp@-; \
		movl    %2,sp@-; \
		movw    %1,sp@-; \
		trap    #14;	\
		lea	sp@(14),sp "					\
	: "=r"(retvalue)			/* outputs */		\
	: "g"(n), "r"(_a), "r"(_b), "r"(_c)     /* inputs  */		\
	: "d0", "d1", "d2", "a0", "a1", "a2"    /* clobbered regs */	\
	  AND_MEMORY							\
	);								\
	retvalue;							\
})

#if __GNUC__ > 1
#define trap_14_wllww(n, a, b, c, d)					\
__extension__								\
({									\
	register long retvalue __asm__("d0");				\
	long  _a = (long) (a);						\
	long  _b = (long) (b);						\
	short _c = (short)(c);						\
	short _d = (short)(d);						\
	    								\
	__asm__ volatile						\
	("\
		movw    %5,sp@-; \
		movw    %4,sp@-; \
		movl    %3,sp@-; \
		movl    %2,sp@-; \
		movw    %1,sp@-; \
		trap    #14;	\
		lea	sp@(14),sp "					\
	: "=r"(retvalue)			/* outputs */		\
	: "g"(n),							\
	  "r"(_a), "r"(_b), "r"(_c), "r"(_d)    /* inputs  */		\
	: "d0", "d1", "d2", "a0", "a1", "a2", "memory"			\
	);								\
	retvalue;							\
})

#define trap_14_wwwwl(n, a, b, c, d)					\
__extension__								\
({									\
	register long retvalue __asm__("d0");				\
	short _a = (short)(a);						\
	short _b = (short)(b);						\
	short _c = (short)(c);						\
	long  _d = (long) (d);						\
	    								\
	__asm__ volatile						\
	("\
		movl    %5,sp@-; \
		movw    %4,sp@-; \
		movw    %3,sp@-; \
		movw    %2,sp@-; \
		movw    %1,sp@-; \
		trap    #14;	\
		lea	sp@(12),sp "					\
	: "=r"(retvalue)			/* outputs */		\
	: "g"(n),							\
	  "r"(_a), "r"(_b), "r"(_c), "r"(_d)        /* inputs  */	\
	: "d0", "d1", "d2", "a0", "a1", "a2", "memory"			\
	);								\
	retvalue;							\
})
#else
#define trap_14_wllww(n, a, b, c, d)					\
({									\
	register long retvalue __asm__("d0");				\
	long  _a = (long) (a);						\
	long  _b = (long) (b);						\
	short _c = (short)(c);						\
	short _d = (short)(d);						\
	    								\
	__asm__ volatile						\
	("\
		movw    %3,sp@-; \
		movw    %2,sp@-; \
		movl    %1,sp@-; \
		movl    %0,sp@- "					\
	:					/* outputs */		\
	: "r"(_a), "r"(_b), "r"(_c), "r"(_d)    /* inputs  */		\
	);								\
									\
	__asm__ volatile						\
	("\
		movw    %1,sp@-; \
		trap    #14;	\
		lea	sp@(14),sp "					\
	: "=r"(retvalue)			/* outputs */		\
	: "g"(n)				/* inputs  */		\
	: "d0", "d1", "d2", "a0", "a1", "a2"    /* clobbered regs */	\
	);								\
	retvalue;							\
})

#define trap_14_wwwwl(n, a, b, c, d)					\
({									\
	register long retvalue __asm__("d0");				\
	short _a = (short)(a);						\
	short _b = (short)(b);						\
	short _c = (short)(c);						\
	long  _d = (long) (d);						\
	    								\
	__asm__ volatile						\
	("\
		movl    %3,sp@-; \
		movw    %2,sp@-; \
		movw    %1,sp@-; \
		movw    %0,sp@- "					\
	:					    /* outputs */	\
	: "r"(_a), "r"(_b), "r"(_c), "r"(_d)        /* inputs  */	\
	);								\
									\
	__asm__ volatile						\
	("\
		movw    %1,sp@-; \
		trap    #14;	\
		lea	sp@(12),sp "					\
	: "=r"(retvalue)			/* outputs */		\
	: "g"(n)				/* inputs  */		\
	: "d0", "d1", "d2", "a0", "a1", "a2"    /* clobbered regs */	\
	);								\
	retvalue;							\
})
#endif

#define trap_14_wwwl(n, a, b, c)					\
__extension__								\
({									\
	register long retvalue __asm__("d0");				\
	short _a = (short)(a);						\
	short _b = (short)(b);						\
	long  _c = (long)(c);						\
	    								\
	__asm__ volatile						\
	("								\
		movl	%4,sp@-;					\
		movw    %3,sp@-;					\
		movw    %2,sp@-;					\
		movw    %1,sp@-;					\
		trap    #14;						\
		lea	sp@(10),sp "					\
	: "=r"(retvalue)			/* outputs */		\
	: "g"(n), "r"(_a), "r"(_b), "r"(_c)	/* inputs  */		\
	: "d0", "d1", "d2", "a0", "a1", "a2"    /* clobbered regs */	\
	  AND_MEMORY							\
	);								\
	retvalue;							\
})

#if __GNUC__ > 1
#define trap_14_wlwlw(n, a, b, c, d)					\
__extension__								\
({									\
	register long retvalue __asm__("d0");				\
	long  _a = (long) (a);						\
	short _b = (short)(b);						\
	long  _c = (long) (c);						\
	short _d = (short)(d);						\
	    								\
	__asm__ volatile						\
	("\
		movw    %5,sp@-; \
		movl    %4,sp@-; \
		movw    %3,sp@-; \
		movl    %2,sp@-; \
		movw    %1,sp@-; \
		trap    #14;	\
		lea	sp@(14),sp "					\
	: "=r"(retvalue)			/* outputs */		\
	: "g"(n),							\
	  "r"(_a), "r"(_b), "r"(_c), "r"(_d)    /* inputs  */		\
	: "d0", "d1", "d2", "a0", "a1", "a2", "memory"			\
	);								\
	retvalue;							\
})
#else
#define trap_14_wlwlw(n, a, b, c, d)					\
({									\
	register long retvalue __asm__("d0");				\
	long  _a = (long) (a);						\
	short _b = (short)(b);						\
	long  _c = (long) (c);						\
	short _d = (short)(d);						\
	    								\
	__asm__ volatile						\
	("\
		movw    %4,sp@-; \
		movl    %3,sp@-; \
		movw    %2,sp@-; \
		movl    %1,sp@-; \
		movw    %0,sp@-;" \
	:					/* outputs */		\
	: "g"(n), "r"(_a), "r"(_b), "r"(_c), "r"(_d) /* inputs  */	\
	);								\
									\
	__asm__ volatile						\
	("\
		trap    #14;	\
		lea	sp@(14),sp "					\
	: "=r"(retvalue)			/* outputs */		\
	:					/* inputs  */		\
	: "d0", "d1", "d2", "a0", "a1", "a2"    /* clobbered regs */	\
	);								\
	retvalue;							\
})
#endif

#else /* __GNUC_INLINE__ */

# ifndef __MSHORT__
#  define _TRAP_X_
# else
#  ifdef __GNUC__
#   ifndef __MINT__
#    define _TRAP_X_
#   endif
#  endif
# endif /* !__MSHORT__ */

# ifdef __C68__
#  define _TRAP_X_
#  /* name changes to accommodate c68's trapgen optimizer */
#  define trap_1_w		_trap_1_w
#  define trap_1_ww		_trap_1_ww
#  define trap_1_wl		_trap_1_wl
#  define trap_1_wlw		_trap_1_wlw
#  define trap_1_wwll		_trap_1_wwll
#  define trap_1_wlww		_trap_1_wlww
#  define trap_1_www		_trap_1_www
#  define trap_1_wll		_trap_1_wll
#  define trap_1_wwlll		_trap_1_wwlll
#  define trap_1_wwwll		_trap_1_wwwll
#  define trap_13_wl		_trap_13_wl
#  define trap_13_w		_trap_13_w
#  define trap_13_ww		_trap_13_ww
#  define trap_13_www		_trap_13_www
#  define trap_13_wwlwww	_trap_13_wwlwww
#  define trap_13_wwl		_trap_13_wwl
#  define trap_14_wwl		_trap_14_wwl
#  define trap_14_wwll		_trap_14_wwll
#  define trap_14_ww		_trap_14_ww
#  define trap_14_w		_trap_14_w
#  define trap_14_wllw		_trap_14_wllw
#  define trap_14_wl		_trap_14_wl
#  define trap_14_www		_trap_14_www
#  define trap_14_wllwwwww	_trap_14_wllwwwww
#  define trap_14_wllwwwwlw	_trap_14_wllwwwwlw
#  define trap_14_wllwwwwwlw	_trap_14_wllwwwwwlw
#  define trap_14_wwwwwww	_trap_14_wwwwwww
#  define trap_14_wlll		_trap_14_wlll
#  define trap_14_wllww		_trap_14_wllww
#  define trap_14_wwwwl		_trap_14_wwwwl
#  define trap_14_wwwl		_trap_14_wwwl
#  define trap_14_wlwlw		_trap_14_wlwlw
# endif /* __C68__ */

# ifdef __SOZOBON__
#  undef _TRAP_X_	/* just to be safe... */
# endif /* __SOZOBON__ */

# ifdef _TRAP_X_
/* if inlines are not allowed, then declare things external */
__EXTERN long trap_1_w __PROTO((short n));
__EXTERN long trap_1_ww __PROTO((short n, short a));
__EXTERN long trap_1_wl __PROTO((short n, long a));
__EXTERN long trap_1_wlw __PROTO((short n, long a, short b));
__EXTERN long trap_1_wwll __PROTO((short n, short a, long b, long c));
__EXTERN long trap_1_wlww __PROTO((short n, long a, short b, short c));
__EXTERN long trap_1_www __PROTO((short n, short a, short b));
__EXTERN long trap_1_wll __PROTO((short n, long a, long b));
__EXTERN long trap_1_wwlll __PROTO((short n, short a, long b, long c, long d));
__EXTERN long trap_1_wwwll __PROTO((short n, short a, short b, long c, long d));
__EXTERN long trap_13_wl __PROTO((short n, long a));
__EXTERN long trap_13_w __PROTO((short n));
__EXTERN long trap_13_ww __PROTO((short n, short a));
__EXTERN long trap_13_www __PROTO((short n, short a, short b));
__EXTERN long trap_13_wwlwww __PROTO((short n, short a, long b, short c, short d, short e));
__EXTERN long trap_13_wwl __PROTO((short n, short a, long b));
__EXTERN long trap_14_wwl __PROTO((short n, short a, long b));
__EXTERN long trap_14_wwll __PROTO((short n, short a, long b, long c));
__EXTERN long trap_14_ww __PROTO((short n, short a));
__EXTERN long trap_14_w __PROTO((short n));
__EXTERN long trap_14_wllw __PROTO((short n, long a, long b, short c));
__EXTERN long trap_14_wl __PROTO((short n, long a));
__EXTERN long trap_14_www __PROTO((short n, short a, short b));
__EXTERN long trap_14_wllwwwww __PROTO((short n, long a, long b, short c, short d, short e, short f, short g));
__EXTERN long trap_14_wllwwwwlw __PROTO((short n, long a, long b, short c, short d, short e, short f, long g, short h));
__EXTERN long trap_14_wllwwwwwlw __PROTO((short n, long a, long b, short c, short d, short e, short f, short g, long h, short i));
__EXTERN long trap_14_wwwwwww __PROTO((short n, short a, short b, short c, short d, short e, short f));
__EXTERN long trap_14_wlll __PROTO((short n, long a, long b, long c));
__EXTERN long trap_14_wllww __PROTO((short n, long a, long b, short c, short d));
__EXTERN long trap_14_wwwwl __PROTO((short n, short a, short b, short c, long d));
__EXTERN long trap_14_wwwl __PROTO((short n, short a, short b, long c));
__EXTERN long trap_14_wlwlw __PROTO((short n, long a, short b, long c, short d));

# else /* __TRAP_X__ */

__EXTERN long gemdos	__PROTO((short, ...));
__EXTERN long bios	__PROTO((short, ...));
__EXTERN long xbios	__PROTO((short, ...));
 
#define trap_1_w	gemdos
#define trap_1_ww	gemdos
#define trap_1_wl	gemdos
#define trap_1_wlw	gemdos
#define trap_1_www	gemdos
#define trap_1_wll	gemdos
#define trap_1_wwll	gemdos
#define trap_1_wlww	gemdos
#define trap_1_wwlll	gemdos
#define trap_1_wwwll	gemdos

#define trap_13_w	bios
#define trap_13_ww	bios
#define trap_13_wl	bios
#define trap_13_www	bios
#define trap_13_wwl	bios
#define trap_13_wwlwww	bios

#define trap_14_w	xbios
#define trap_14_ww	xbios
#define trap_14_wl	xbios
#define trap_14_www	xbios
#define trap_14_wwl	xbios
#define trap_14_wwll	xbios
#define trap_14_wllw	xbios
#define trap_14_wlll	xbios
#define trap_14_wwwl	xbios
#define trap_14_wwwwl	xbios
#define trap_14_wllww	xbios
#define trap_14_wwwwwww	xbios
#define trap_14_wllwwwww	xbios
#define trap_14_wllwwwwlw	xbios
#define trap_14_wllwwwwwlw	xbios
#define trap_14_wlwlw	xbios

# endif /* _TRAP_X_ */

#endif /* __GNUC_INLINE__ */


/* DEFINITIONS FOR OS FUNCTIONS */

/*
 *     GEMDOS  (trap1)
 */
#define	       Pterm0()					       	       \
       (void)trap_1_w((short)(0x00))
#define	       Cconin()						       \
       (long)trap_1_w((short)(0x01))
#define	       Cconout(c)					       \
       (void)trap_1_ww((short)(0x02),(short)(c))
#define	       Cauxin()						       \
       (long)trap_1_w((short)(0x03))
#define	       Cauxout(c)					       \
       (void)trap_1_ww((short)(0x04),(short)(c))
#define	       Cprnout(c)					       \
       (void)trap_1_ww((short)(0x05),(short)(c))
#define	       Crawio(data)					       \
       (long)trap_1_ww((short)(0x06),(short)(data))
#define	       Crawcin()					       \
       (long)trap_1_w((short)(0x07))
#define	       Cnecin()						       \
       (long)trap_1_w((short)(0x08))
#define	       Cconws(s)					       \
       (void)trap_1_wl((short)(0x09),(long)(s))
#define	       Cconrs(buf)					       \
       (void)trap_1_wl((short)(0x0A),(long)(buf))
#define	       Cconis()						       \
       (short)trap_1_w((short)(0x0B))
#define	       Dsetdrv(d)					       \
       (long)trap_1_ww((short)(0x0E),(short)(d))
#define	       Cconos()						       \
       (short)trap_1_w((short)(0x10))
#define	       Cprnos()						       \
       (short)trap_1_w((short)(0x11))
#define	       Cauxis()						       \
       (short)trap_1_w((short)(0x12))
#define	       Cauxos()						       \
       (short)trap_1_w((short)(0x13))
#define	       Dgetdrv()					       \
       (short)trap_1_w((short)(0x19))
#define	       Fsetdta(dta)					       \
       (void)trap_1_wl((short)(0x1A),(long)(dta))

/*
 * The next binding is not quite right if used in another than the usual ways:
 *	1. Super(1L) from either user or supervisor mode
 *	2. ret = Super(0L) from user mode and after this Super(ret) from
 *	   supervisor mode
 * We get the following situations (usp, ssp relative to the start of Super):
 *	Parameter	Userstack	Superstack	Calling Mode	ret
 *	   1L		   usp		   ssp		    user	 0L
 *	   1L		   usp		   ssp		 supervisor	-1L
 *	   0L		  usp-6		   usp		    user	ssp
 *	   0L		   ssp		  ssp-6		 supervisor   ssp-6
 *	  ptr		  usp-6		  ptr+6		    user	ssp
 *	  ptr		  usp+6		   ptr		 supervisor	 sr
 * The usual C-bindings are safe only because the "unlk a6" is compensating
 * the errors when you invoke this function. In this binding the "unlk a6" at
 * the end of the calling function compensates the error made in sequence 2
 * above (the usp is 6 to low after the first call which is not corrected by
 * the second call).
 */
#define	       Super(ptr)					       \
       (long)trap_1_wl((short)(0x20),(long)(ptr))
	/* Tos 1.4: Super(1L) : rets -1L if in super mode, 0L otherwise */
#define	       Tgetdate()					       \
       (short)trap_1_w((short)(0x2A))
#define	       Tsetdate(date)					       \
       (long)trap_1_ww((short)(0x2B),(short)(date))
#define	       Tgettime()					       \
       (short)trap_1_w((short)(0x2C))
#define	       Tsettime(time)					       \
       (long)trap_1_ww((short)(0x2D),(short)(time))
#define	       Fgetdta()					       \
       (_DTA *)trap_1_w((short)(0x2F))
#define	       Sversion()					       \
       (short)trap_1_w((short)(0x30))
#define	       Ptermres(save,rv)				       \
       (void)trap_1_wlw((short)(0x31),(long)(save),(short)(rv))
#define	       Dfree(buf,d)					       \
       (long)trap_1_wlw((short)(0x36),(long)(buf),(short)(d))
#define	       Dcreate(path)					       \
       (short)trap_1_wl((short)(0x39),(long)(path))
#define	       Ddelete(path)					       \
       (long)trap_1_wl((short)(0x3A),(long)(path))
#define	       Dsetpath(path)					       \
       (long)trap_1_wl((short)(0x3B),(long)(path))
#define	       Fcreate(fn,mode)					       \
       (long)trap_1_wlw((short)(0x3C),(long)(fn),(short)(mode))
#define	       Fopen(fn,mode)					       \
       (long)trap_1_wlw((short)(0x3D),(long)(fn),(short)(mode))
#define	       Fclose(handle)					       \
       (long)trap_1_ww((short)(0x3E),(short)(handle))
#define	       Fread(handle,cnt,buf)				       \
       (long)trap_1_wwll((short)(0x3F),(short)(handle),	       \
			 (long)(cnt),(long)(buf))
#define	       Fwrite(handle,cnt,buf)				       \
       (long)trap_1_wwll((short)(0x40),(short)(handle),	       \
			 (long)(cnt),(long)(buf))
#define	       Fdelete(fn)					       \
       (long)trap_1_wl((short)(0x41),(long)(fn))
#define	       Fseek(where,handle,how)				       \
       (long)trap_1_wlww((short)(0x42),(long)(where),	       \
			 (short)(handle),(short)(how))
#define	       Fattrib(fn,rwflag,attr)				       \
       (short)trap_1_wlww((short)(0x43),(long)(fn),	       \
			  (short)(rwflag),(short)(attr))
#define	       Fdup(handle)					       \
       (long)trap_1_ww((short)(0x45),(short)(handle))
#define	       Fforce(Hstd,Hnew)				       \
       (long)trap_1_www((short)(0x46),(short)(Hstd),(short)(Hnew))
#define	       Dgetpath(buf,d)					       \
       (long)trap_1_wlw((short)(0x47),(long)(buf),(short)(d))
#define	       Malloc(size)					       \
       (long)trap_1_wl((short)(0x48),(long)(size))
#define	       Mfree(ptr)					       \
       (long)trap_1_wl((short)(0x49),(long)(ptr))
#define	       Mshrink(ptr,size)				       \
       (long)trap_1_wwll((short)(0x4A),(short)0,(long)(ptr),(long)(size))
#define	       Pexec(mode,prog,tail,env)		       \
       (long)trap_1_wwlll((short)(0x4B),(short)(mode),(long)(prog),   \
			   (long)(tail),(long)(env))
#define	       Pterm(rv)					       \
       (void)trap_1_ww((short)(0x4C),(short)(rv))
#define	       Fsfirst(filespec,attr)				       \
       (long)trap_1_wlw((short)(0x4E),(long)(filespec),(short)(attr))
#define	       Fsnext()						       \
       (long)trap_1_w((short)(0x4F))
#define	       Frename(zero,old,new)				       \
       (short)trap_1_wwll((short)(0x56),(short)(zero),	       \
			  (long)(old),(long)(new))
#define	       Fdatime(timeptr,handle,rwflag)			       \
       (long)trap_1_wlww((short)(0x57),(long)(timeptr),	       \
			 (short)(handle),(short)(rwflag))
#define	       Flock(handle,mode,start,length)			       \
       (long)trap_1_wwwll((short)(0x5C),(short)(handle),       \
			  (short)(mode),(long)(start),(long)(length))

/*
 *     BIOS    (trap13)
 */
#define Getmpb(ptr)					       \
       (void)trap_13_wl((short)(0x00),(long)(ptr))
#define	       Bconstat(dev)					       \
       (short)trap_13_ww((short)(0x01),(short)(dev))
#define	       Bconin(dev)					       \
       (long)trap_13_ww((short)(0x02),(short)(dev))
#define	       Bconout(dev,c)					       \
       (long)trap_13_www((short)(0x03),(short)(dev),(short)((c) & 0xFF))
/* since AHDI 3.1 there is a new call to Rwabs with one more parameter */
#define	       Rwabs(rwflag,buf,n,sector,d)			\
       (long)trap_13_wwlwww((short)(0x04),(short)(rwflag),(long)(buf), \
			     (short)(n),(short)(sector),(short)(d))
#define	       Setexc(vnum,vptr) 				      \
       (void (*) __PROTO((void)))trap_13_wwl((short)(0x05),(short)(vnum),(long)(vptr))
#define	       Tickcal()					       \
       (long)trap_13_w((short)(0x06))
#define	       Getbpb(d)					       \
       (void *)trap_13_ww((short)(0x07),(short)(d))
#define	       Bcostat(dev)					       \
       (short)trap_13_ww((short)(0x08),(short)(dev))
#define	       Mediach(dev)					       \
       (short)trap_13_ww((short)(0x09),(short)(dev))
#define	       Drvmap()						       \
       (long)trap_13_w((short)(0x0A))
#define	       Kbshift(data)					       \
       (long)trap_13_ww((short)(0x0B),(short)(data))
#define	       Getshift()					       \
	Kbshift(-1)


/*
 *     XBIOS   (trap14)
 */

#define	       Initmous(type,param,vptr)			       \
       (void)trap_14_wwll((short)(0x00),(short)(type),	       \
			  (long)(param),(long)(vptr))
#define Ssbrk(size)					       \
       (void *)trap_14_ww((short)(0x01),(short)(size))
#define	       Physbase()					       \
       (void *)trap_14_w((short)(0x02))
#define	       Logbase()					       \
       (void *)trap_14_w((short)(0x03))
#define	       Getrez()						       \
       (short)trap_14_w((short)(0x04))
#define	       Setscreen(lscrn,pscrn,rez)			       \
       (void)trap_14_wllw((short)(0x05),(long)(lscrn),(long)(pscrn), \
			  (short)(rez))
#define	       Setpalette(palptr)				       \
       (void)trap_14_wl((short)(0x06),(long)(palptr))
#define	       Setcolor(colornum,mixture)			       \
       (short)trap_14_www((short)(0x07),(short)(colornum),(short)(mixture))
#define	       Floprd(buf,x,d,sect,trk,side,n)			       \
       (short)trap_14_wllwwwww((short)(0x08),(long)(buf),(long)(x), \
	 (short)(d),(short)(sect),(short)(trk),(short)(side),(short)(n))
#define	       Flopwr(buf,x,d,sect,trk,side,n)			       \
       (short)trap_14_wllwwwww((short)(0x09),(long)(buf),(long)(x), \
	       (short)(d),(short)(sect),(short)(trk),(short)(side),(short)(n))
#define	       Flopfmt(buf,x,d,spt,t,sd,i,m,v)		       \
       (short)trap_14_wllwwwwwlw((short)(0x0A),(long)(buf),(long)(x), \
	  (short)(d),(short)(spt),(short)(t),(short)(sd),(short)(i),  \
	  (long)(m),(short)(v))
#define	       Midiws(cnt,ptr)					       \
       (void)trap_14_wwl((short)(0x0C),(short)(cnt),(long)(ptr))
#define	       Mfpint(vnum,vptr)				       \
       (void)trap_14_wwl((short)(0x0D),(short)(vnum),(long)(vptr))
#define	       Iorec(ioDEV)					       \
       (void *)trap_14_ww((short)(0x0E),(short)(ioDEV))
#define	       Rsconf(baud,flow,uc,rs,ts,sc)			       \
       (long)trap_14_wwwwwww((short)(0x0F),(short)(baud),(short)(flow), \
			  (short)(uc),(short)(rs),(short)(ts),(short)(sc))
	/* ret old val: MSB -> ucr:8, rsr:8, tsr:8, scr:8 <- LSB */
#define	       Keytbl(nrml,shft,caps)				       \
       (void *)trap_14_wlll((short)(0x10),(long)(nrml), \
			    (long)(shft),(long)(caps))
#define	       Random()						       \
       (long)trap_14_w((short)(0x11))
#define	       Protobt(buf,serial,dsktyp,exec)			       \
       (void)trap_14_wllww((short)(0x12),(long)(buf),(long)(serial), \
			   (short)(dsktyp),(short)(exec))
#define	       Flopver(buf,x,d,sect,trk,sd,n)			       \
       (short)trap_14_wllwwwww((short)(0x13),(long)(buf),(long)(x),(short)(d),\
	       (short)(sect),(short)(trk),(short)(sd),(short)(n))
#define	       Scrdmp()						       \
       (void)trap_14_w((short)(0x14))
#define	       Cursconf(rate,attr)				       \
       (short)trap_14_www((short)(0x15),(short)(rate),(short)(attr))
#define	       Settime(time)					       \
       (void)trap_14_wl((short)(0x16),(long)(time))
#define	       Gettime()					       \
       (long)trap_14_w((short)(0x17))
#define	       Bioskeys()					       \
       (void)trap_14_w((short)(0x18))
#define	       Ikbdws(len_minus1,ptr)				       \
       (void)trap_14_wwl((short)(0x19),(short)(len_minus1),(long)(ptr))
#define	       Jdisint(vnum)					       \
       (void)trap_14_ww((short)(0x1A),(short)(vnum))
#define	       Jenabint(vnum)					       \
       (void)trap_14_ww((short)(0x1B),(short)(vnum))
#define	       Giaccess(data,reg)				       \
       (short)trap_14_www((short)(0x1C),(short)(data),(short)(reg))
#define	       Offgibit(ormask)					       \
       (void)trap_14_ww((short)(0x1D),(short)(ormask))
#define	       Ongibit(andmask)					       \
       (void)trap_14_ww((short)(0x1E),(short)(andmask))
#define	       Xbtimer(timer,ctrl,data,vptr)			       \
       (void)trap_14_wwwwl((short)(0x1F),(short)(timer),(short)(ctrl), \
			   (short)(data),(long)(vptr))
#define	       Dosound(ptr)					       \
       (void)trap_14_wl((short)(0x20),(long)(ptr))
#define	       Setprt(config)					       \
       (short)trap_14_ww((short)(0x21),(short)(config))
#define	       Kbdvbase()					       \
       (_KBDVECS*)trap_14_w((short)(0x22))
#define	       Kbrate(delay,reprate)				       \
       (short)trap_14_www((short)(0x23),(short)(delay),(short)(reprate))
#define	       Prtblk(pblkptr)					       \
       (void)trap_14_wl((short)(0x24),(long)(pblkptr)) /* obsolete ? */
#define	       Vsync()						       \
       (void)trap_14_w((short)(0x25))
#define	       Supexec(funcptr)					       \
       (long)trap_14_wl((short)(0x26),(long)(funcptr))
#define	       Floprate(drive,rate)				       \
       (short)trap_14_www((short)(0x29),(short)(drive),(short)(rate))
#define	       Blitmode(flag)					       \
       (short)trap_14_ww((short)(0x40),(short)(flag))
/*
 * Flag:
 *  -1: get config
 * !-1: set config	previous config returned
 *	bit
 *	 0	0 blit mode soft	1 blit mode hardware
 *	 1	0 no blitter		1 blitter present
 *	2..14   reserved
 *	 15	must be zero on set/returned as zero
 * blitmode (bit 0) forced to soft if no blitter(bit 1 == 0).
 */

/*
 * extensions for TT TOS
 */

#define         Mxalloc(amt,flag)					\
	(long)trap_1_wlw((short)(0x44),(long)(amt),(short)(flag))
#define		Maddalt(start,size)					\
	(long)trap_1_wll((short)(0x14),(long)(start),(long)(size))

#define         EsetShift(mode)						\
	(void)trap_14_ww((short)(80),(short)mode)
#define         EgetShift()						\
	(short)trap_14_w((short)(81))
#define         EsetBank(bank)						\
	(short)trap_14_ww((short)(82),(short)bank)
#define         EsetColor(num,val)					\
	(short)trap_14_www((short)(83),(short)num,(short)val)
#define         EsetPalette(start,count,ptr)				\
	(void)trap_14_wwwl((short)(84),(short)start,(short)count,(long)ptr)
#define         EgetPalette(start,count,ptr)				\
	(void)trap_14_wwwl((short)(85),(short)start,(short)count,(long)ptr)
#define         EsetGray(mode)						\
	(short)trap_14_ww((short)(86),(short)mode)
#define         EsetSmear(mode)						\
	(short)trap_14_ww((short)(87),(short)mode)

#define		DMAread(sector,count,buffer,devno)			\
	(long)trap_14_wlwlw((short)0x2a,(long)sector,(short)count,(long)buffer, \
			    (short)devno)
#define		DMAwrite(sector,count,buffer,devno)			\
	(long)trap_14_wlwlw((short)0x2b,(long)sector,(short)count,(long)buffer, \
			(short)devno)
#define		Bconmap(dev)						\
	(long)trap_14_ww((short)0x2c,(short)(dev))
#define		NVMaccess(op,start,count,buf)				\
	(short)trap_14_wwwwl((short)0x2e,(short)op,(short)start,(short)count, \
			(long)buf)

/*  Wake-up call for ST BOOK -- takes date/time pair in DOS format. */

#define	       Waketime(w_date, w_time)					\
       (void)trap_14_www((short)(0x2f),(unsigned short)(w_date),	\
				       (unsigned short)(w_time))

#endif /* __LATTICE__ */
#endif /* __TURBOC__ */

#ifdef __cplusplus
}
#endif

#endif /* _OSBIND_H */
