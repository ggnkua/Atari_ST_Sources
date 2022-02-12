#if (CHIP == M68000)
/* This file contains some dumping routines for debugging. */

#include "kernel.h"
#include <minix/callnr.h>
#include <minix/com.h>
#include "tty.h"
#include "proc.h"

void prname();
void mem_dmp();

#undef	NEEDED
#undef	TTYDMP

#define NSIZE 20
phys_bytes aout[NR_PROCS];	/* pointers to the program names */
char nbuff[NSIZE+1];
char *vargv;

/*===========================================================================*
 *				DEBUG routines here			     * 
 *===========================================================================*/
PUBLIC void p_dmp()
{
/* Proc table dump */

  register struct proc *rp;
  char *np;
  vir_clicks base, limit, first, last;
  phys_bytes ltmp, dst;
  int index;
  int i;
  char *cp;

  printf(
  "\r\nproc    pid     pc     sp  splow flag  user    sys  base  limit  recv   command\r\n");

  dst = umap(proc_addr(SYSTASK), D, (vir_bytes)nbuff, (vir_bytes)NSIZE);

  for (rp = &proc[0]; rp < &proc[NR_PROCS+NR_TASKS]; rp++)  {
	if (rp->p_flags & P_SLOT_FREE) continue;
	first = rp->p_map[T].mem_phys;
	last = rp->p_map[S].mem_phys + rp->p_map[S].mem_len;
	ltmp = ((long) first << CLICK_SHIFT) + 512L;
	base = (vir_clicks) (ltmp/1024L);
	ltmp = (((long) last << CLICK_SHIFT) + 512L);
	limit = (vir_clicks) (ltmp/1024L);
	prname((int)(rp - proc));
	printf(" %4d %6X %6X %6X %4x %5D %6D  %4dK %4dK  ",
		rp->p_pid, (long)rp->p_reg.pc,
		(long)rp->p_reg.sp, (long)rp->p_splow,
		rp->p_flags, rp->user_time, rp->sys_time,
		base, limit);
	if (rp->p_flags == 0)
		printf("      ");
	else
		prname(NR_TASKS + rp->p_getfrom);

	/* Fetch the command string from the user process. */
	index = (int)(rp - proc) - NR_TASKS;
	if (index > LOW_USER && aout[index] != 0) {
		phys_copy(aout[index], dst, (long) NSIZE);
		nbuff[NSIZE] = 0;
		for (np = &nbuff[0]; np < &nbuff[NSIZE]; np++)
			if (*np <= ' ' || *np >= 0177) *np = 0;
		if (index == LOW_USER + 1)
			cp = "/bin/sh";
		else
			cp = nbuff;
		for(i=0;i<100;i++) 
			if(cp[i] == '\0')
				break;
		if(i > 6)
			printf("\r\n\t");
		printf("%s", cp);
	}
	printf("\r\n");
  }
#ifdef NEEDED
  printf("\r\nproc    callq sendlk mesbuf from nready pend\r\n");
  for (rp = &proc[0]; rp < &proc[NR_PROCS+NR_TASKS]; rp++)  {
	if (rp->p_flags & P_SLOT_FREE) continue;
	prname((int)(rp - proc));
	printf(" %6X %6X %6X %4d %6X %4d\r\n",
		rp->p_callerq,
		rp->p_sendlink,
		rp->p_messbuf,
		rp->p_getfrom,
		rp->p_nextready,
		rp->p_pending
	);
  }
  for (index = 0; index < NQ; index++) {
	printf("q=%d: ", index);
	for (rp = rdy_head[index]; rp != NIL_PROC; rp = rp->p_nextready)
		printf(" %d", (int)(rp-proc));
	printf("\r\n");
  }
#endif NEEDED
  printf("\r\n");
}


PUBLIC void map_dmp()
{
  register struct proc *rp;
  vir_clicks base, limit, first, last;
  phys_bytes ltmp;

  printf("\r\nPROC   --TEXT---  --DATA---  --STACK-- SHADOW FLIP P BASE  SIZE\r\n");
  for (rp = &proc[NR_TASKS]; rp < &proc[NR_TASKS+NR_PROCS]; rp++)  {
	if (rp->p_flags & P_SLOT_FREE) continue;
	first = rp->p_map[T].mem_phys;
	last = rp->p_map[S].mem_phys + rp->p_map[S].mem_len;
	ltmp = ((long) first << CLICK_SHIFT) + 512L;
	base = (vir_clicks) (ltmp/1024L);
	ltmp = (((long) (last-first) << CLICK_SHIFT) + 512L);
	limit = (vir_clicks) (ltmp/1024L);
	prname((int)(rp-proc));
	printf(" %4x %4x  %4x %4x  %4x %4x   %4x %4d %d %4dK %4dK\r\n", 
	    rp->p_map[T].mem_phys, rp->p_map[T].mem_len,
	    rp->p_map[D].mem_phys, rp->p_map[D].mem_len,
	    rp->p_map[S].mem_phys, rp->p_map[S].mem_len,
	    rp->p_shadow, rp->p_nflips, rp->p_physio, base, limit);
  }
}


PUBLIC void prname(i)
int i;
{
  if (i == ANY+NR_TASKS)
	printf("ANY   ");
  else if (i >= 0 && i <= NR_TASKS+2)
	printf("%s", tasktab[i].name);
  else
	printf("%4d  ", i-NR_TASKS);
}

PUBLIC void set_name(proc_nr, ptr)
int proc_nr;
char *ptr;
{
/* When an EXEC call is done, the kernel is told about the stack pointer.
 * It uses the stack pointer to find the command line, for dumping
 * purposes.
 */

  phys_bytes src, dst;

  if (ptr == (char *) 0) {
	aout[proc_nr] = (phys_bytes) 0;
	return;
  }

  src = umap(
	proc_addr(proc_nr),
	D,
	(vir_bytes)(ptr + sizeof(char *)),
	(vir_bytes)sizeof(char *)
  );
  if (src == 0)
	return;
  dst = umap(
	proc_addr(SYSTASK),
	D,
	(vir_bytes)&vargv,
	(vir_bytes)sizeof(char *)
  );
  phys_copy(src, dst, (phys_bytes)sizeof(char *));
  aout[proc_nr] = umap(
	proc_addr(proc_nr),
	D,
	(vir_bytes)vargv,
	(vir_bytes)NSIZE
  );
}

PUBLIC void reg_dmp(rp, dummy)
register struct proc *rp;
{
	register int i;
	static char *regs[NR_REGS] = {
		"d0", "d1", "d2", "d3", "d4", "d5", "d6", "d7",
		"a0", "a1", "a2", "a3", "a4", "a5", "a6"
	}; 
	reg_t *regptr = (reg_t *) &rp->p_reg;
	
	printf("reg = %08X, ", rp);
	printf("ksp = %08X\r\n", (long)&dummy);
	printf(" pc = %08X, ", rp->p_reg.pc);
	printf(" sr =     %04x, ", rp->p_reg.psw);
	printf("trp =       %2x\r\n", rp->p_trap);
	for (i = 0; i < NR_REGS; i++)
		printf("%3s = %08X%s",
			regs[i],
			*regptr++,
			(i&3) == 3 ? "\r\n" : ", "
		);
	printf(" a7 = %08X\r\n", rp->p_reg.sp);
	mem_dmp((char *)(((long)rp->p_reg.pc & ~31L) - 96), 128);
	mem_dmp((char *)(((long)rp->p_reg.sp & ~31L) - 32), 256);
}

PUBLIC void mem_dmp(adr, len)
char *adr;
{
	register i;
	register long *p;

	for (i = 0, p = (long *)adr; i < len; i += 4) {
		if ((i & 31) == 0)
			printf("\r\n%X:", p);
		printf(" %8X", *p++);
	}
	printf("\r\n");
}

#ifdef TTYDMP
PUBLIC void tty_dmp()
{
   struct tty_struct *tp;
   int i;

   printf("output_done = %d\r\n", output_done);
   printf("flush_flag = %d\r\n", flush_flag);

   printf("tty_buf_count = %d, tty_buf_max = %d\r\n",
	   tty_buf_count(tty_driver_buf), tty_buf_max(tty_driver_buf));

   for (i = 0; i < NR_CONS + NR_RS_LINES; i++)
   {
	tp = &tty_struct[i]; 
	printf("line %d; incount = %d, inleft = %d, outleft = %d\n",
 		i, tp->tty_incount, tp->tty_inleft, tp->tty_outleft);
	if (tp->tty_busy) printf("busy\r\n"); else printf("not busy\r\n");
	if (tp->tty_inhibited) printf("inhibited\r\n");
	else printf("not inhibited\r\n");
	if (tp->tty_waiting)
	    if (tp->tty_waiting == COMPLETED) printf("completed\r\n");
	    else printf("waiting\r\n");
	else printf("not waiting\r\n");
   }
}
#endif
#endif
