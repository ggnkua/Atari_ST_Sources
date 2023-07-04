
/* this is used when saving in history */
struct smallregs68k {
ulong pc,dregs[8],aregs[8],ssp;
uword sr;
ulong msp,isp;		/* 030 */
	};

/* these are the actual regs */
struct regs68k {
ulong pc,dregs[8],aregs[8],ssp;
uword sr;
ulong msp,isp;					/* 030 */ /* also 68000.IR (low word */
ulong vbr,sfc,dfc,cacr,caar;	/* 030 */
ulong crp[2],srp[2],tc,tt0,tt1;	/* 030 MMU */
uword mmusr;
	};

extern struct regs68k regs;		/* defined in proc.c */
extern char size_size[];
extern void get_fpu_reg(short,char*,long*,double*);
extern void get_fpu_cregs(long*);		/* CR, SR, IAR */
