#include "kernel.h"
#include "proc.h"
#include "proto.h"

#if (SHADOWING == 0)
/*
	code needed to deal with m68030 PMMU
*/

#include "pmmu.h"

/*
	concept -
	the kernel runs in a mapping that looks like the physical layout
	to make sure all the drivers work, this way we don't have to set
	things up and do any magic before we run the kerne code.

	all user processes have a virtual address space and don't allow
	access to any of the devices.
	pages are 1 click in size and the mmu maps up to 2 ** 15 clicks in tib
	so the virtual adress space is limited to 32k clicks.
	On an 68030 4k clicks are recommended, which results in a maximum 
	virtual address of 128 Mb. 
	When this is not enough either larger clicks can be used, or 
	the tia descriptor can be used as well.

	add	user			super
		_________		_________
	0	|	|		|	|
		| text	|		|phys-	|
		| +data	|		|memory	|
		|	|		|	|
		|	|		|	|
		|	|		|	|
		|	|		|	|
		|	|		|	|
		|	|		|	|
		|	|		|	|
		|	|		|	|
		|	|		|	|
		| stack	|		|	|
		|	|		|	|
	00ffffff---------		|	|
	        			|	|
					|	|
	        			|	|
					|	|
					|     	|
					|   	|
					|       |
	        			|	|
					|	|
	ffffffff			---------
	

*/

/* these are global pointers root pointers */
static struct _rpr crp,srp;
static struct _tc tc;

/* we need to alloc these dynamically */

/* each process has a root pointer */

static struct _rpr proc_crp[NR_TASKS+NR_PROCS];

static struct _ltd *proc_seg;

/* the odd fields of _segs are never used. 
   They canot be elimitated though because the root pointer should
   be aligned on a 16 byte boundary (lowest 4 address bits 0).
   Future versions might use the odd fields to double the address space.
   Currently the contents of the odd fields does not matter because the
   limit field in the crp prevents the use of these fields.
*/
static struct _ltd _segs[2*(NR_TASKS+NR_PROCS+1)];


/*
	root	tia		tib		offset
	----	---		---		-----
	crp ->	seg[0] ->	page[0] ->	physical page

	pages are CLICK_SHIFT bits
	tib is always 15 bits. tia uses the rest (32 - 15 - CLICK_SHIFT)
	tic and tid are not used
*/

/* from pmmus.s */
_PROTOTYPE(void _pmmu_load_tc , (struct _tc *tc)			);
_PROTOTYPE(void _pmmu_load_crp , (struct _rpr *rpr)			);
_PROTOTYPE(void _pmmu_load_srp , (struct _rpr *rpr)			);
_PROTOTYPE(void _pmmu_pflush , (void)					);

void
pmmuinit()
{
#ifdef BITFIELDS
	tc.enable = 0;	/* disable */
#else
	tc.ctrl = 0;
#endif
	_pmmu_load_tc(&tc);

#ifdef BITFIELDS
	crp.ul = 0;	/* upper range check */
	crp.limit = 0x7fff;	/* the whole range */
	crp.res1 = 0;
	crp.sg = 0;
	crp.res2 = 0;
	crp.dt = 1;	/* use as offset + limit */
#else
	crp.limit = 0x7fff;	/* the whole range */
	crp.dt = 1;	/* use as offset + limit */
#endif
	crp.ta = 0;	/* offset == 0 */
/*
printf("pmmuinit: about to load crp %lx\r\n",*(unsigned long *)&crp);
*/
	_pmmu_load_crp(&crp);

#ifdef BITFIELDS
	srp.ul = 0;
	srp.limit = 0x7fff;
	srp.res1 = 0;
	srp.sg = 0;
	srp.res2 = 0;
	srp.dt = 1;
#else
	srp.limit = 0x7fff;	/* the whole range */
	srp.dt = 1;	/* use as offset + limit */
#endif
	srp.ta = 0;
/*
printf("pmmuinit: about to load srp %lx\r\n",*(unsigned long *)&srp);
*/
	_pmmu_load_srp(&srp);

#ifdef BITFIELDS
	tc.enable = 1;
	tc.res1 = 0;
	tc.sre = 1;
	tc.fcl = 0;
	tc.ps = CLICK_SHIFT;
	tc.is = 0;
	tc.tia = 32 - 15 - CLICK_SHIFT;
	tc.tib = 15;
	tc.tic = 0;
	tc.tid = 0;
#else
	tc.ctrl = 0x8000 + 0x200 + (CLICK_SHIFT << 4);
	tc.ti = ((32 - 15 - CLICK_SHIFT) << 12) + 0xf00;
#endif
/*
printf("pmmuinit: about to load tc %lx\r\n",*(unsigned long *)&tc);
*/
	_pmmu_load_tc(&tc);

	proc_seg = (struct _ltd *)((((long)&_segs[1]) >> 4) << 4) ;
/*
printf("pmmuinit: _segs %lx proc_seg %lx\r\n",_segs,proc_seg);
*/

}

/*
	set up a magic cookie that identifies our a map for this process,
	the magic cookie is a root pointer that will get loaded before
	the user runs, this routine gets called anytime the map changes
	as in a fork/exec/brk, stack extent etc.
*/

void
pmmu_init_proc(rp)
struct proc *rp;
{
        int si;
        int t;
        
	t = ((long)rp - (long)proc) / sizeof(struct proc);
	si = 2 * t;

	if(rp->p_map[T].mem_phys == rp->p_map[T].mem_vir){
		proc_seg[si].ta = 0;
		proc_seg[si].limit = 0x7fff;
	}else{
		proc_seg[si].limit =
			(rp->p_map[S].mem_phys + rp->p_map[S].mem_len)
				- rp->p_map[T].mem_phys;
		proc_seg[si].ta =
			(long)rp->p_map[T].mem_phys << (CLICK_SHIFT);
	}
#ifdef BITFIELDS
	proc_seg[si].ul = 0;
	proc_seg[si].ral = 7;
	proc_seg[si].wal = 7;
	proc_seg[si].sg = 0;
	proc_seg[si].s = 0;
	proc_seg[si].res1 = 0;
	proc_seg[si].u = 0;
	proc_seg[si].wp = 0;
	proc_seg[si].dt = 1;
#else
	proc_seg[si].ctrl = 0xfc01;
#endif

#ifdef BITFIELDS
	proc_crp[t].ul = 0;
	proc_crp[t].limit = 0;
	proc_crp[t].res1 = 0;
	proc_crp[t].sg = 0;
	proc_crp[t].res2 = 0;
	proc_crp[t].dt = 3;
#else
	proc_crp[t].limit = 0;
	proc_crp[t].dt = 3;
#endif
	proc_crp[t].ta = (long)&proc_seg[si];

	
	rp->p_crp = (char *) &proc_crp[t];	/* point to this entry */

/*
printf("pmmu_init(%d): crp %lx ta %lx seg %lx txt %x (%x) dat %x(%x) stk %x(%x) vir %x\r\n",
		t,rp->p_crp,
		((struct _rpr *)rp->p_crp)->ta << 4,&proc_seg[si],
		rp->p_map[T].mem_phys, rp->p_map[T].mem_len,
		rp->p_map[D].mem_phys, rp->p_map[D].mem_len,
		rp->p_map[S].mem_phys, rp->p_map[S].mem_len,
		rp->p_map[T].mem_vir
	);
*/

	pmmu_flush(rp);		/* probably not needed, just to make sure */
}

/* 
	using the magic cookie (crp) set up the map to run this task
*/
void
pmmu_restore(rp)
struct proc *rp;
{
/*
printf("mmu restore ");
if(rp->p_crp) printf("ok");
else printf("not ok");
printf(": crp %lx ta %lx txt %x (%x) dat %x(%x) stk %x(%x) vir %x\r\n",
		rp->p_crp,
		((struct _rpr *)rp->p_crp)->ta,
		rp->p_map[T].mem_phys, rp->p_map[T].mem_len,
		rp->p_map[D].mem_phys, rp->p_map[D].mem_len,
		rp->p_map[S].mem_phys, rp->p_map[S].mem_len,
		rp->p_map[T].mem_vir
	);
*/
	if(rp->p_crp)
		_pmmu_load_crp((struct _rpr *)rp->p_crp);
}

#if 0
void
pmmu_check(s)
char *s;
{
int t;
struct _rpr *r;
struct _ltd *d;
	for(t=0;t<(NR_TASKS+NR_PROCS);t++){
		if(proc[t].p_flags != P_SLOT_FREE && proc[t].p_crp){
			r = (struct _rpr *)proc[t].p_crp;
			if(r->limit != 0x7fff || r->ul != 0 ||
				r->dt != 1 || r->ta != 0)
printf("pmmu_check: %s: crp %lx ul: %x limit: %x dt: %x ta: %lx\r\n",
					s,r,r->ul,r->limit,r->dt,r->ta);
	d = (struct _ltd *) r->ta;
printf("pmmu_check: %s: ltd %lx ul: %x limit: %x dt: %x ta: %lx\r\n",
					s,d,d->ul,d->limit,d->dt,d->ta);
		}
	}
}
#endif

/*
	delete entry for this process, it's not needed anymore
*/
void
pmmu_delete(rp)
struct proc *rp;
{
/*printf("pmmu_delete: %lx\n",rp->p_crp);*/
	pmmu_flush(rp);
	rp->p_crp = (char *)0;
}

/*
	flush root pointer, when killing a child for example,
	or when changing the map for this process 
*/
void
pmmu_flush(rp)
struct proc *rp;
{
	if(rp->p_crp)
		_pmmu_pflush();
}

#endif
