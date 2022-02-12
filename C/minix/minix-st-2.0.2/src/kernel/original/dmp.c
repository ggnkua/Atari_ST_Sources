/* This file contains some dumping routines for debugging. */

#include "kernel.h"
#include <minix/com.h>
#include "proc.h"

char *vargv;

FORWARD _PROTOTYPE(char *proc_name, (int proc_nr));

/*===========================================================================*
 *				p_dmp    				     *
 *===========================================================================*/
#if (CHIP == INTEL)
PUBLIC void p_dmp()
{
/* Proc table dump */

  register struct proc *rp;
  static struct proc *oldrp = BEG_PROC_ADDR;
  int n = 0;
  phys_clicks text, data, size;
  int proc_nr;

  printf("\n--pid --pc- ---sp- flag -user --sys-- -text- -data- -size- -recv- command\n");

  for (rp = oldrp; rp < END_PROC_ADDR; rp++) {
	proc_nr = proc_number(rp);
	if (rp->p_flags & P_SLOT_FREE) continue;
	if (++n > 20) break;
	text = rp->p_map[T].mem_phys;
	data = rp->p_map[D].mem_phys;
	size = rp->p_map[T].mem_len
		+ ((rp->p_map[S].mem_phys + rp->p_map[S].mem_len) - data);
	printf("%5d %5lx %6lx %2x %7U %7U %5uK %5uK %5uK ",
	       proc_nr < 0 ? proc_nr : rp->p_pid,
	       (unsigned long) rp->p_reg.pc,
	       (unsigned long) rp->p_reg.sp,
	       rp->p_flags,
	       rp->user_time, rp->sys_time,
	       click_to_round_k(text), click_to_round_k(data),
	       click_to_round_k(size));
	if (rp->p_flags & RECEIVING) {
		printf("%-7.7s", proc_name(rp->p_getfrom));
	} else
	if (rp->p_flags & SENDING) {
		printf("S:%-5.5s", proc_name(rp->p_sendto));
	} else
	if (rp->p_flags == 0) {
		printf("       ");
	}
	printf("%s\n", rp->p_name);
  }
  if (rp == END_PROC_ADDR) rp = BEG_PROC_ADDR; else printf("--more--\r");
  oldrp = rp;
}
#endif				/* (CHIP == INTEL) */

/*===========================================================================*
 *				map_dmp    				     *
 *===========================================================================*/
#if (SHADOWING == 0)
PUBLIC void map_dmp()
{
  register struct proc *rp;
  static struct proc *oldrp = cproc_addr(HARDWARE);
  int n = 0;
  phys_clicks size;

  printf("\nPROC NAME-  -----TEXT-----  -----DATA-----  ----STACK-----  -SIZE-\n");
  for (rp = oldrp; rp < END_PROC_ADDR; rp++) {
	if (rp->p_flags & P_SLOT_FREE) continue;
	if (++n > 20) break;
	size = rp->p_map[T].mem_len
		+ ((rp->p_map[S].mem_phys + rp->p_map[S].mem_len)
						- rp->p_map[D].mem_phys);
	printf("%3d %-6.6s  %4x %4x %4x  %4x %4x %4x  %4x %4x %4x  %5uK\n",
	       proc_number(rp),
	       rp->p_name,
	       rp->p_map[T].mem_vir, rp->p_map[T].mem_phys, rp->p_map[T].mem_len,
	       rp->p_map[D].mem_vir, rp->p_map[D].mem_phys, rp->p_map[D].mem_len,
	       rp->p_map[S].mem_vir, rp->p_map[S].mem_phys, rp->p_map[S].mem_len,
	       click_to_round_k(size));
  }
  if (rp == END_PROC_ADDR) rp = cproc_addr(HARDWARE); else printf("--more--\r");
  oldrp = rp;
}

#else

PUBLIC void map_dmp()
{
  register struct proc *rp;
  static struct proc *oldrp = cproc_addr(HARDWARE);
  int n = 0;
  vir_clicks base, limit;

  printf("\nPROC NAME-  --TEXT---  --DATA---  --STACK-- SHADOW FLIP P BASE  SIZE\n");
  for (rp = oldrp; rp < END_PROC_ADDR; rp++) {
	if (rp->p_flags & P_SLOT_FREE) continue;
	if (++n > 20) break;
	base = rp->p_map[T].mem_phys;
	limit = rp->p_map[S].mem_phys + rp->p_map[S].mem_len;
	printf("%3d %-6.6s  %4x %4x  %4x %4x  %4x %4x   %4x %4d %d %4uK\n",
	       proc_number(rp),
	       rp->p_name,
	       rp->p_map[T].mem_phys, rp->p_map[T].mem_len,
	       rp->p_map[D].mem_phys, rp->p_map[D].mem_len,
	       rp->p_map[S].mem_phys, rp->p_map[S].mem_len,
	       rp->p_shadow, rp->p_nflips, rp->p_physio,
	       click_to_round_k(base), click_to_round_k(limit));
  }
  if (rp == END_PROC_ADDR) rp = cproc_addr(HARDWARE); else printf("--more--\r");
  oldrp = rp;
}

#endif

#if (CHIP == M68000)
FORWARD _PROTOTYPE(void mem_dmp, (char *adr, int len));

/*===========================================================================*
 *				p_dmp    				     *
 *===========================================================================*/
PUBLIC void p_dmp()
{
/* Proc table dump */

  register struct proc *rp;
  static struct proc *oldrp = BEG_PROC_ADDR;
  int n = 0;
  vir_clicks base, limit;

  printf(
         "\nproc pid     pc     sp  splow flag  user    sys   recv   command\n");

  for (rp = oldrp; rp < END_PROC_ADDR; rp++) {
	if (rp->p_flags & P_SLOT_FREE) continue;
	if (++n > 20) break;
	base = rp->p_map[T].mem_phys;
	limit = rp->p_map[S].mem_phys + rp->p_map[S].mem_len;
	printf("%4u %4u %6lx %6lx %6lx %4x %5U %6U   ",
	       proc_number(rp),
	       rp->p_pid,
	       (unsigned long) rp->p_reg.pc,
	       (unsigned long) rp->p_reg.sp,
	       (unsigned long) rp->p_splow,
	       rp->p_flags,
	       rp->user_time, rp->sys_time);
	if (rp->p_flags & RECEIVING) {
		printf("%-7.7s", proc_name(rp->p_getfrom));
	} else
	if (rp->p_flags & SENDING) {
		printf("S:%-5.5s", proc_name(rp->p_sendto));
	} else
	if (rp->p_flags == 0) {
		printf("       ");
	}
	printf("%s\n", rp->p_name);
  }
  if (rp == END_PROC_ADDR) rp = BEG_PROC_ADDR; else printf("--more--\r");
  oldrp = rp;
}


/*===========================================================================*
 *				reg_dmp    				     *
 *===========================================================================*/
PUBLIC void reg_dmp(rp)
struct proc *rp;
{
  register int i;
  static char *regs[NR_REGS] = {
		    "d0", "d1", "d2", "d3", "d4", "d5", "d6", "d7",
		    "a0", "a1", "a2", "a3", "a4", "a5", "a6"
  };
  reg_t *regptr = (reg_t *) & rp->p_reg;

  printf("reg = %08lx, ", rp);
  printf("ksp = %08lx\n", (long) &rp + sizeof(rp));
  printf(" pc = %08lx, ", rp->p_reg.pc);
  printf(" sr =     %04x, ", rp->p_reg.psw);
  printf("trp =       %2x\n", rp->p_trap);
  for (i = 0; i < NR_REGS; i++) 
	printf("%3s = %08lx%s",regs[i], *regptr++, (i&3) == 3 ? "\n" : ", ");
  printf(" a7 = %08lx\n", rp->p_reg.sp);
#if (SHADOWING == 1)
    mem_dmp((char *) (((long) rp->p_reg.pc & ~31L) - 96), 128);
    mem_dmp((char *) (((long) rp->p_reg.sp & ~31L) - 32), 256);
#else
    mem_dmp((char *) (((long) rp->p_reg.pc & ~31L) - 96 +
			((long)rp->p_map[T].mem_phys<<CLICK_SHIFT)), 128);
    mem_dmp((char *) (((long) rp->p_reg.sp & ~31L) - 32 +
			((long)rp->p_map[S].mem_phys<<CLICK_SHIFT)), 256);
#endif
}


/*===========================================================================*
 *				mem_dmp    				     *
 *===========================================================================*/
PRIVATE void mem_dmp(adr, len)
char *adr;
int len;
{
  register i;
  register long *p;

  for (i = 0, p = (long *) adr; i < len; i += 4) {
#if (CHIP == M68000)
	if ((i & 31) == 0) printf("\n%lX:", p);
	printf(" %8lX", *p++);
#else
	if ((i & 31) == 0) printf("\n%X:", p);
	printf(" %8X", *p++);
#endif /* (CHIP == M68000) */
  }
  printf("\n");
}

#endif				/* (CHIP == M68000) */


/*===========================================================================*
 *				proc_name    				     *
 *===========================================================================*/
PRIVATE char *proc_name(proc_nr)
int proc_nr;
{
  if (proc_nr == ANY) return "ANY";
  return proc_addr(proc_nr)->p_name;
}
