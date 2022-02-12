#ifndef TYPE_H
#define TYPE_H

typedef _PROTOTYPE( void task_t, (void) );
typedef _PROTOTYPE( int (*rdwt_t), (message *m_ptr) );
typedef _PROTOTYPE( void (*watchdog_t), (void) );

struct tasktab {
  task_t *initial_pc;
  int stksize;
  char name[8];
};

struct memory {
  phys_clicks base;
  phys_clicks size;
};

/* Administration for clock polling. */
struct milli_state {
  unsigned long accum_count;	/* accumulated clock ticks */
  unsigned prev_count;		/* previous clock value */
};

#if (CHIP == INTEL)
typedef unsigned port_t;
typedef unsigned segm_t;
typedef unsigned reg_t;		/* machine register */

/* The stack frame layout is determined by the software, but for efficiency
 * it is laid out so the assembly code to use it is as simple as possible.
 * 80286 protected mode and all real modes use the same frame, built with
 * 16-bit registers.  Real mode lacks an automatic stack switch, so little
 * is lost by using the 286 frame for it.  The 386 frame differs only in
 * having 32-bit registers and more segment registers.  The same names are
 * used for the larger registers to avoid differences in the code.
 */
struct stackframe_s {           /* proc_ptr points here */
#if _WORD_SIZE == 4
  u16_t gs;                     /* last item pushed by save */
  u16_t fs;                     /*  ^ */
#endif
  u16_t es;                     /*  | */
  u16_t ds;                     /*  | */
  reg_t di;			/* di through cx are not accessed in C */
  reg_t si;			/* order is to match pusha/popa */
  reg_t fp;			/* bp */
  reg_t st;			/* hole for another copy of sp */
  reg_t bx;                     /*  | */
  reg_t dx;                     /*  | */
  reg_t cx;                     /*  | */
  reg_t retreg;			/* ax and above are all pushed by save */
  reg_t retadr;			/* return address for assembly code save() */
  reg_t pc;			/*  ^  last item pushed by interrupt */
  reg_t cs;                     /*  | */
  reg_t psw;                    /*  | */
  reg_t sp;                     /*  | */
  reg_t ss;                     /* these are pushed by CPU during interrupt */
};

struct segdesc_s {		/* segment descriptor for protected mode */
  u16_t limit_low;
  u16_t base_low;
  u8_t base_middle;
  u8_t access;			/* |P|DL|1|X|E|R|A| */
#if _WORD_SIZE == 4
  u8_t granularity;		/* |G|X|0|A|LIMT| */
  u8_t base_high;
#else
  u16_t reserved;
#endif
};

/* Registers used in an PC real mode call for BIOS or DOS services.  A
 * driver is called through the vector if the interrupt number is zero.
 */
union reg86 {
  struct l {
	u32_t	ef;			/* 32 bit flags (output only) */
	u32_t	vec;			/* Driver vector (input only) */
	u32_t	_ds_es[1];
	u32_t	eax;			/* 32 bit general registers */
	u32_t	ebx;
	u32_t	ecx;
	u32_t	edx;
	u32_t	esi;
	u32_t	edi;
	u32_t	ebp;
  } l;
  struct w {
	u16_t	f, _ef[1];		/* 16 bit flags (output only) */
	u16_t	off, seg;		/* Driver vector (input only) */
	u16_t	ds, es;			/* DS and ES real mode segment regs */
	u16_t	ax, _eax[1];		/* 16 bit general registers */
	u16_t	bx, _ebx[1];
	u16_t	cx, _ecx[1];
	u16_t	dx, _edx[1];
	u16_t	si, _esi[1];
	u16_t	di, _edi[1];
	u16_t	bp, _ebp[1];
  } w;
  struct b {
	u8_t	intno, _intno[3];	/* Interrupt number (input only) */
	u8_t	_vec[4];
	u8_t	_ds_es[4];
	u8_t	al, ah, _eax[2];	/* 8 bit general registers */
	u8_t	bl, bh, _ebx[2];
	u8_t	cl, ch, _ecx[2];
	u8_t	dl, dh, _edx[2];
	u8_t	_esi[4];
	u8_t	_edi[4];
	u8_t	_ebp[4];
  } b;
};

typedef _PROTOTYPE( int (*irq_handler_t), (int irq) );

#endif /* (CHIP == INTEL) */

#if (CHIP == M68000)
typedef _PROTOTYPE( void (*dmaint_t), (void) );

typedef u32_t reg_t;		/* machine register */

/* The name and fields of this struct were chosen for PC compatibility. */
struct stackframe_s {
  reg_t retreg;			/* d0 */
  reg_t d1;
  reg_t d2;
  reg_t d3;
  reg_t d4;
  reg_t d5;
  reg_t d6;
  reg_t d7;
  reg_t a0;
  reg_t a1;
  reg_t a2;
  reg_t a3;
  reg_t a4;
  reg_t a5;
  reg_t fp;			/* also known as a6 */
  reg_t sp;			/* also known as a7 */
  reg_t pc;
  u16_t psw;
  u16_t dummy;			/* make size multiple of reg_t for system.c */
};

struct fsave {
  struct cpu_state {
	u16_t i_format;
	u32_t i_addr;
	u16_t i_state[4];
  } cpu_state;
  struct state_frame {
	u8_t frame_type;
	u8_t frame_size;
	u16_t reserved;
	u8_t frame[212];
  } state_frame;
  struct fpp_model {
	u32_t fpcr;
	u32_t fpsr;
	u32_t fpiar;
	struct fpN {
		u32_t high;
		u32_t low;
		u32_t mid;
	} fpN[8];
  } fpp_model;
};
#endif /* (CHIP == M68000) */

#endif /* TYPE_H */
