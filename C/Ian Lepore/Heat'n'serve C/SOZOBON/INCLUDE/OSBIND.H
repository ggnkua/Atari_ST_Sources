#pragma idempotent

/************************************************************************
 * OSBINDS.H - Bindings and such for TOS.
 *
 *	08/22/91 - Added typecasting to every parameter and return value.
 *			   (Real prototypes would be better, but this helps a bit).
 *	09/15/91 - Changed return value casting on Malloc() from (void*) to
 *			   (long); I sorta forgot that Malloc(-1L) returns a long.
 *			   Also changed the return value casting on Fforce() from
 *			   (void) to (short); there's a typo in Atari's GEMREF.DOC.
 *			   Added Memavail().
 *	11/02/91 - Changed return value casting on Bconstat() and Bconin().
 *			   Both of these return a long, the HHG was wrong on them.
 *			   Also, removed unneeded recasts to (long) return values.
 *	11/17/91 - Changed definition of Mshrink() macro from Alcyon/Atari
 *			   style (3 parms, 1 is unused) to MWC/GNU style (2 parms).
 *	11/22/91 - Changed return value casting.  (Again!  I never realized
 *			   how innacurate Atari's GEMREF.DOC is).  It was Pexec()
 *			   that burned me this time -- it returns a short or a void*
 *			   depending on its parms.	Anyway, now only (void) retval
 *			   casts remain; anything that returns a value at all has 
 *			   no recast.  GEMDOS always returns a valid longword return
 *			   value anyway, so this is safe.
 ************************************************************************/

#ifndef OSBIND_H
#define OSBIND_H

extern long bios();
extern long xbios();
extern long gemdos();

/*	   BIOS  (trap13)	*/

#define Getmpb(a)					(void*) bios(0,  (void*)(a))
#define Bconstat(a) 						bios(1,  (short)(a))
#define Bconin(a)							bios(2,  (short)(a))
#define Bconout(a,b)				(void)	bios(3,  (short)(a), (short)(b))
#define Rwabs(a,b,c,d,e)					bios(4,  (short)(a), (void*)(b), (short)(c), (short)(d), (short)(e))
#define Setexc(a,b) 				(void*) bios(5,  (short)(a), (void*)(b))
#define Tickcal()							bios(6)
#define Getbpb(a)					(void*) bios(7,  (short)(a))
#define Bcostat(a)							bios(8,  (short)(a))
#define Mediach(a)							bios(9,  (short)(a))
#define Drvmap()							bios(10)
#define Getshift()							bios(11, (short)(-1))
#define Kbshift(a)							bios(11, (short)(a))

/*	   XBIOS	 (trap14)	*/

#define Initmous(a,b,c) 			(void)	xbios(0,  (short)(a), (void*)(b), (void*)(c))
#define Ssbrk(a)							xbios(1,  (short)(a))
#define Physbase()					(void*) xbios(2)
#define Logbase()					(void*) xbios(3)
#define Getrez()							xbios(4)
#define Setscreen(a,b,c)			(void)	xbios(5,  (void*)(a), (void*)(b), (short)(c))
#define Setpallete(a)				(void)	xbios(6,  (void*)(a))
#define Setcolor(a,b)						xbios(7,  (short)(a), (short)(b))
#define Floprd(a,b,c,d,e,f,g)				xbios(8,  (void*)(a), (long)(b),  (short)(c), (short)(d), (short)(e), (short)(f), (short)(g))
#define Flopwr(a,b,c,d,e,f,g)				xbios(9,  (void*)(a), (long)(b),  (short)(c), (short)(d), (short)(e), (short)(f), (short)(g))
#define Flopfmt(a,b,c,d,e,f,g,h,i)			xbios(10, (void*)(a), (lonh)(b),  (short)(c), (short)(d), (short)(e), (short)(f), (short)(g), (long)(h), (short)(i))
#define Midiws(a,b) 				(void)	xbios(12, (short)(a), (void*)(b))
#define Mfpint(a,b) 				(void)	xbios(13, (short)(a), (void*)(b))
#define Iorec(a)					(void*) xbios(14, (short)(a))
#define Rsconf(a,b,c,d,e,f) 		(void)	xbios(15, (short)(a), (short)(b), (short)(c), (short)(d), (short)(e), (short)(f))
#define Keytbl(a,b,c)				(void*) xbios(16, (void*)(a), (void*)(b), (void*)(c))
#define Random()							xbios(17)
#define Protobt(a,b,c,d)			(void)	xbios(18, (void*)(a), (long)(b),  (short)(c), (short)(d))
#define Flopver(a,b,c,d,e,f,g)				xbios(19, (void*)(a), (long)(b),  (short)(c), (short)(d), (short)(e), (short)(f), (short)(g))
#define Scrdmp()					(void)	xbios(20)
#define Cursconf(a,b)						xbios(21, (short)(a), (short)(b))
#define Settime(a)					(void)	xbios(22, (long)(a))
#define Gettime()							xbios(23)
#define Bioskeys()					(void)	xbios(24)
#define Ikbdws(a,b) 				(void)	xbios(25, (short)(a), (void*)(b))
#define Jdisint(a)					(void)	xbios(26, (short)(a))
#define Jenabint(a) 				(void)	xbios(27, (short)(a))
#define Giaccess(a,b)						xbios(28, (char)(a),  (unsigned short)(b))
#define Offgibit(a) 				(void)	xbios(29, (short)(a))
#define Ongibit(a)					(void)	xbios(30, (short)(a))
#define Xbtimer(a,b,c,d)			(void)	xbios(31, (short)(a), (short)(b), (short)(c), (void*)(d))
#define Dosound(a)					(void)	xbios(32, (void*)(a))
#define Setprt(a)							xbios(33, (short)(a))
#define Kbdvbase()					(void*) xbios(34)
#define Kbrate(a,b) 						xbios(35, (short)(a), (short)(b))
#define Prtblk()					(void)	xbios(36)
#define Vsync() 					(void)	xbios(37)
#define Supexec(a)							xbios(38, (void*)(a))

/*	   GEMDOS  (trap1)			*/

#define Pterm0()		(void)	gemdos(0x0)
#define Cconin()				gemdos(0x1)
#define Cconout(a)		(void)	gemdos(0x2,  (short)(a))
#define Cauxin()				gemdos(0x3)
#define Cauxout(a)		(void)	gemdos(0x4,  (short)(a))
#define Cprnout(a)		(void)	gemdos(0x5,  (short)(a))
#define Crawio(a)				gemdos(0x6,  (short)(a))
#define Crawcin()				gemdos(0x7)
#define Cnecin()				gemdos(0x8)
#define Cconws(a)		(void)	gemdos(0x9,  (char*)(a))
#define Cconrs(a)		(void)	gemdos(0x0a, (char*)(a))
#define Cconis()				gemdos(0x0b)
#define Dsetdrv(a)				gemdos(0x0e, (short)(a))
#define Cconos()				gemdos(0x10)
#define Cprnos()				gemdos(0x11)
#define Cauxis()				gemdos(0x12)
#define Cauxos()				gemdos(0x13)
#define Dgetdrv()				gemdos(0x19)
#define Fsetdta(a)		(void)	gemdos(0x1a, (void*)(a))
#define Super(a)		(void*) gemdos(0x20, (void*)(a))
#define Tgetdate()				gemdos(0x2a)
#define Tsetdate(a) 			gemdos(0x2b, (short)(a))
#define Tgettime()				gemdos(0x2c)
#define Tsettime(a) 			gemdos(0x2d, (short)(a))
#define Fgetdta()		(void*) gemdos(0x2f)
#define Sversion()				gemdos(0x30)
#define Ptermres(a,b)	(void)	gemdos(0x31, (long)(a),  (short)(b))
#define Dfree(a,b)		(void)	gemdos(0x36, (void*)(a), (short)(b))
#define Dcreate(a)				gemdos(0x39, (char*)(a))
#define Ddelete(a)				gemdos(0x3a, (char*)(a))
#define Dsetpath(a) 			gemdos(0x3b, (char*)(a))
#define Fcreate(a,b)			gemdos(0x3c, (char*)(a), (short)(b))
#define Fopen(a,b)				gemdos(0x3d, (char*)(a), (short)(b))
#define Fclose(a)				gemdos(0x3e, (short)(a))
#define Fread(a,b,c)			gemdos(0x3f, (short)(a), (long)(b),  (void*)(c))
#define Fwrite(a,b,c)			gemdos(0x40, (short)(a), (long)(b),  (void*)(c))
#define Fdelete(a)				gemdos(0x41, (char*)(a))
#define Fseek(a,b,c)			gemdos(0x42, (long)(a),  (short)(b), (short)(c))
#define Fattrib(a,b,c)			gemdos(0x43, (char*)(a), (short)(b), (short)(c))
#define Fdup(a) 				gemdos(0x45, (short)(a))
#define Fforce(a,b) 			gemdos(0x46, (short)(a), (short)(b))
#define Dgetpath(a,b)	(void)	gemdos(0x47, (char*)(a), (short)(b))
#define Malloc(a)				gemdos(0x48, (long)(a))
#define Memavail()				gemdos(0x48, -1L)
#define Mfree(a)				gemdos(0x49, (void*)(a))
#define Mshrink(a,b)			gemdos(0x4a, (short)0,	 (void*)(a), (long)(b))
#define Pexec(a,b,c,d)			gemdos(0x4b, (short)(a), (void*)(b), (void*)(c), (void*)(d))
#define Pterm(a)		(void)	gemdos(0x4c, (short)(a))
#define Fsfirst(a,b)			gemdos(0x4e, (char*)(a), (short)(b))
#define Fsnext()				gemdos(0x4f)
#define Frename(a,b,c)			gemdos(0x56, (short)(a), (char*)(b), (char*)(c))
#define Fdatime(a,b,c)	(void)	gemdos(0x57, (void*)(a), (short)(b), (short)(c))

/************************************************************************
 * Handy constants...
 ************************************************************************/

/*		Device names for Bcon functions */

#define BCON_PRT		0
#define BCON_AUX		1
#define BCON_CON		2
#define BCON_MIDI		3
#define BCON_KBD		4

/*		Bit mappings for Kbshift() */

#define KB_RSHIFT		0x01
#define KB_LSHIFT		0x02
#define KB_SHIFT		(KB_RSHIFT|KB_LSHIFT)
#define KB_CTRL 		0x04
#define KB_ALT			0x08
#define KB_CAPSLOCK 	0x10
#define KB_RMOUSE		0x20
#define KB_LMOUSE		0x40

/************************************************************************
 * typedefs for oft-used structures...
 ************************************************************************/

typedef struct fs_dta {
		 char  fs_filler[21];
		 char  fs_attr;
		 short fs_time;
		 short fs_date;
		 long  fs_size;
		 char  fs_name[13];
		 } FS_DTA, DTA;

typedef struct bpb {
		 short	b_recsiz, b_clsiz, b_clszb,
				b_rdlen,  b_fsiz,  b_fatrec,
				b_datrec, b_numcl, b_bflags;
		 } BPB;

#endif
