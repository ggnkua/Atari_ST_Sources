
/* MMU handling for Mon */

#include "mon.h"
#include "regs.h"

/* this code is capable of working remotely, I guess */

/* slightly machine dependent */

/* in machine.c */
extern word FINDMEM(ulong where,word what,ulong offset);

typedef struct {
	long *where;
	long old;
	} olddcr;

#define MAXUNDOMMU	20
olddcr undo_mmulist[MAXUNDOMMU];
word undo_count;

static char *memtypelist[]={ "all", "st", "tt" };

extern word asm_mmu_init(word,olddcr*,word*);
extern word asm_mmu_reset(olddcr*,word);
extern word asm_wprotect(long,long,olddcr*,word*);
extern word asm_wclear(long,olddcr*,word*);

word mmu_init(char *p)
{
word memtype;

	if (test_mmu()==0)
		return ERRM_NOMMU;
	if (*p==' ')
		p++;
	if (*p==0)
		memtype=0;
	else
		memtype=cmp_token(&p,memtypelist,3);
	if (memtype<0)
		return ERRM_BADP;
	return asm_mmu_init(memtype,&undo_mmulist[undo_count],&undo_count);
}

word mmu_wprotect(char *p)
{
long start,end;
word err;

	if (test_mmu()==0)
		return ERRM_NOMMU;
	while (*p==' ')
		p++;
	if (err=get_expression(&p,EXPR_LONG,&start))
		return err;
	while (*p==' ')
		p++;
	if (*p==0)
		end=start+3;
	else
		if (err=get_expression(&p,EXPR_LONG,&end))
			return err;
	if (end<start)
		return ERRM_BADP;
	
	/* we have to check that it is RAM (protecting bus-errorable locs is *bad*) */
	if (FINDMEM(start,MEM_READ|MEM_WRITE,(ulong)end-start)==0)
		return ERRM_NOWRITE;

	return asm_wprotect(start,end,&undo_mmulist[undo_count],&undo_count);
}

/* end address only - must be found in table */
word mmu_wclear(char *p)
{
long start;
word err;
	if (test_mmu()==0)
		return ERRM_NOMMU;
	while (*p==' ')
		p++;
	if (err=get_expression(&p,EXPR_LONG,&start))
		return err;

	return asm_wclear(start,&undo_mmulist[undo_count],&undo_count);
}

/* also called during termination */
word mmu_reset(char *p)
{
word err;
	if (test_mmu()==0)
		return ERRM_NOMMU;
	err=asm_mmu_reset(&undo_mmulist[undo_count],undo_count);
	undo_count=0;
	return err;
}

word list_mmu(char *p)
{
extern long wplist[];
long *l;
word err;
char *d;
	l=wplist;
	while (*l)
		{
		d=linebuf;
		d=sprintlong(d,*l++,20);
		*d++=' '; *d++='-'; *d++=' ';
		d=sprintlong(d,*l++,20);
		*d++='\n'; *d=0;
		err=list_print(linebuf);
		if (err)
			return err;
		}
	return 0;
}
