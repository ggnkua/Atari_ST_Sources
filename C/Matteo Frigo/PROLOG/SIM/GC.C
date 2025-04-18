#include "simdef.h"
#include "aux.h"

/* debugging macro definitions */
/*
#define DEBUG_MARK
#define DEBUG_COMPACT
*/
/* macros used by garbage collection */

#define MBIT           0x80000000    /* mark bit */
#define RBIT           0x40000000    /* relocation chain bit */

#define GET_NEXT(ptr)  ((LONG_PTR)(*(ptr) & 0x3ffffffc))
     /* return pointer from object pointed to by ptr (remove tag & mark) */

#define HEAP_PTR(ptr)  (!ISNUM(*(ptr)) && \
			GET_NEXT(ptr) >= heap_bottom && GET_NEXT(ptr) < hreg)
     /* is the object pointed to by ptr a pointer to the heap? */

#define ONHEAP(ptr)    ((ptr) >= heap_bottom && (ptr) < hreg)
     /* is ptr a pointer to the heap? */

#define MARKED(ptr)    (*(ptr) &  MBIT)
     /* is the object pointed to by ptr marked? */

#define MARK(ptr)      (*(ptr) |= MBIT)
     /* mark the object pointed to by ptr */

#define UNMARK(ptr)    (*(ptr) &= ~MBIT)
     /* unmark the object pointed to by ptr */

#define RMARKED(ptr)   (!ISNUM(*(ptr)) && (*(ptr) & RBIT))
     /* is the object pointed to by ptr marked as in a relocation chain? */


/*
 * Assumptions:
 *   1. breg points one past last choicepoint
 *   2. ereg points to first word in last environment
 *   3. local_bottom points two past actual bottom of local stack
 *   4. there are only environments and choicepoints on the local stack
 *   5. hreg points one past the last entry on the heap
 *   6. heap_bottom points to bottom of heap
 *   7. there are only value cells (FREE,CS,LIST,NUM) and buffers on the heap
 *   8. trreg points to last entry in trail
 *   9. trail_bottom points one past bottom of trail
 *  10. the trail can point to the heap
 *  11. buffers on the heap always have psc record right after psc_ptr word
 *  12. buffers on the heap have an extra word at the end (end_buf) which
 *      contains the psc_ptr ORed with CS_TAG
 *  13. pointers don't use bit 30, so it can be used as r-bit during compaction
 *      (r-bit not used for numbers - before checking r-bit, test for ISNUM)
 */


/*
 * During garbage collection, chains of environments and choicepoints are
 * followed to find active objects on the heap.  The pointers gc_ereg and
 * gc_breg, local to garbage collection, point to the environment or
 * choicepoint, respectively, currently being processed.  The values
 * generated by offsetting from gc_ereg and gc_breg are as follows:
 *
 *     gc_ereg     = saved ereg
 *     gc_ereg - 1 = saved cpreg
 *     gc_ereg - 2 = start saved variables
 *
 *     gc_breg + 2 = saved breg
 *     gc_breg + 3 = saved hreg
 *     gc_breg + 5 = saved cpreg
 *     gc_breg + 6 = saved ereg
 *     gc_breg + 7 = start saved registers
 */


/* global variables for garbage collection */

LONG gc_calls = 0;      /* number of times GC has been called */
LONG total_marked;      /* number of heap objects marked */
int  num_regs;          /* number of active registers */


/* find all accessible objects on the heap and squeeze out all the rest */

garbage_collection(from)
CHAR_PTR from;
{
   gc_calls++;
   printf("Performing garbage collection number %d; called from %s\n",
	  gc_calls, from);  fflush(stdout);

   total_marked = 0;

   /* get the number of active registers */

   num_regs = *(BYTE_PTR)((LONG)cpreg - 6);

#ifdef DEBUG_MARK
   printf("the number of active registers is %d\n", num_regs);
#endif

   push_registers();

   marking_phase();

#ifdef DEBUG_MARK
   dump_mem();
#endif

   compaction_phase();

   pop_registers();

#ifdef DEBUG_COMPACT
   dump_mem();
#endif

}


/* push the active registers onto the trail for inclusion during gc */

push_registers()
{
   int i;

   for (i = 1; i <= num_regs; i++)
      *(--trreg) = reg[i];
   if (trreg < tstack)             /* just check at end; if bad,   */
      quit("Trail overflow\n");    /*   we're going to quit anyway */
}


/* mark all objects on the heap that are accessible from active registers,
   the trail, environments, and choicepoints */

marking_phase()
{
   mark_trail();                               /* active registers & trail */
   mark_environments(ereg, ENV_SIZE(cpreg));   /* active environments */
   mark_choicepoints(breg);                    /* choicepoints, and environs  */
                                               /* reachable from choicepoints */
}


/* move marked heap objects upwards over unmarked objects, and reset all 
   pointers to point to new locations */

compaction_phase()
{
   sweep_trail();
   sweep_environments(ereg, ENV_SIZE(cpreg));
   sweep_choicepoints(breg);
   compact_heap();
}


/* pop the corrected register values from the trail and update the registers */

pop_registers()
{
   int i;

   for (i = num_regs; i >= 1; i--)
      reg[i] = *trreg++;
}


/* mark all heap objects accessible from the trail (which includes the
   active general purpose registers) */

mark_trail()
{
   LONG_PTR trail_cell;

   for (trail_cell = trreg; trail_cell < trail_bottom; trail_cell++)
      if (HEAP_PTR(trail_cell)) {
         mark_variable(trail_cell);
         total_marked--;                       /* don't count trail cells */
      }
}


/* mark all heap objects accessible from a chain of environments */

mark_environments(gc_ereg, size)
LONG_PTR gc_ereg;
BYTE     size;
{
   LONG_PTR saved_var;

   while (size > 0) {                          /* no more environments */

      /* for each saved variable */

      for (saved_var = gc_ereg-size+1; saved_var < gc_ereg-1; saved_var++) {
         if (MARKED(saved_var))                /* we have already been here */
            return;
         else if (HEAP_PTR(saved_var)) {
            mark_variable(saved_var);
            total_marked--;                    /* don't count stack cells */
         }
      }
      size = ENV_SIZE((LONG_PTR)*(gc_ereg-1)); /* size = ENV_SIZE(cpreg) */
      gc_ereg = (LONG_PTR)*(gc_ereg);          /* link to prev environment */
   }
}


/* mark all heap objects accessible from each choicepoint & its chain
   of environments */

mark_choicepoints(gc_breg)
LONG_PTR gc_breg;
{
   LONG_PTR prev_top, saved_reg;
   BYTE     size;

   while (gc_breg != local_bottom-2) {         /* original value of breg */
      size = ENV_SIZE((LONG_PTR)*(gc_breg+5));
      mark_environments((LONG_PTR)*(gc_breg+6), size);

      /* find previous top of stack */

      if (*(gc_breg+2) < *(gc_breg+6))         /* breg < ereg ? */
         prev_top = (LONG_PTR)*(gc_breg+2);    /* prev_top = breg */
      else                                     /* prev_top = ereg - env_size */
         prev_top = (LONG_PTR)*(gc_breg+6) - size;

      /* for each saved register */

      for (saved_reg = gc_breg+7; saved_reg <= prev_top; saved_reg++)
         if (HEAP_PTR(saved_reg)) {
            mark_variable(saved_reg);
            total_marked--;                    /* don't count stack cells */
         }
      gc_breg = (LONG_PTR)*(gc_breg+2);        /* link to prev choicepoint */
   }
}


/* mark a heap object and all heap objects accessible from it */

mark_variable(current)
LONG_PTR current;
{
   LONG_PTR    next;
   PSC_REC_PTR psc_ptr;
   BYTE        arity, i;
   LONG        bufsiz;

   if (MARKED(current))
      return;
   MARK(current);
   total_marked++;
   next = GET_NEXT(current);

   switch (TAG(*current)) {
      case FREE:
         if (ONHEAP(next))
	    mark_variable(next);
         return;

      case CS:
         if (ISNIL(*current))                  /* last element in a list */
            return;
	 if (MARKED(next))
	    return;
         psc_ptr = (PSC_REC_PTR)*next;         /* *next == psc_ptr */

         if (IS_BUFF(psc_ptr)) {               /* buffer */
	    if (HEAP_PTR(next)) {              /* buffer is on heap */
	       bufsiz = BUFF_SIZE(psc_ptr);
	       MARK(next);                     /* mark the psc_ptr word */
	       MARK(next + bufsiz - 1);        /* mark the end_buff ptr */
	       /* add the number of words in the buffer into total_marked, */
	       /*   but don't actually mark them                           */
               total_marked += bufsiz;
	    }
            return;
         }

	 if ((arity=GET_ARITY(psc_ptr)) == 0)  /* constant */
	    return;
	                                       /* structure */
         for (i = 1; i <= arity; i++)
            if (ONHEAP(next + i))
	       mark_variable(next + i);
	 MARK(next);                           /* mark the psc_ptr word */
	 total_marked++;
         return;

      case LIST:
         if (ONHEAP(next))
	    mark_variable(next);
         if (ONHEAP(next + 1))
	    mark_variable(next + 1);
         return;

      case NUM:
         return;
   }
}


/* insert a cell which points to a heap object into relocation chain of that
   object */

into_relocation_chain(current, next)
LONG_PTR current, next;
{
   LONG current_tag;

   current_tag = TAG(*current);
   *current = (*current & MBIT) | (*next & ~MBIT);
   *next = (*next & MBIT) | RBIT | (LONG)current | current_tag;
} 


/* insert trail cells which point to heap objects into relocation chains */

sweep_trail()
{
   LONG_PTR trail_cell;

   for (trail_cell = trreg; trail_cell < trail_bottom; trail_cell++)
      if (HEAP_PTR(trail_cell)) {
	 UNMARK(trail_cell);
         into_relocation_chain(trail_cell, GET_NEXT(trail_cell));
      }
}


/* insert cells of a chain of environments which point to heap objects
   into relocation chains */

sweep_environments(gc_ereg, size)
LONG_PTR gc_ereg;
BYTE     size;
{
   LONG_PTR saved_var;

   while (size > 0) {

      /* for each saved variable */

      for (saved_var = gc_ereg-size+1; saved_var < gc_ereg-1; saved_var++) {
         if (HEAP_PTR(saved_var)) {
            if (!MARKED(saved_var))
	       return;                         /* we have already been here */
            else {
               UNMARK(saved_var);
               into_relocation_chain(saved_var, GET_NEXT(saved_var));
            }
         }
      }
      size = ENV_SIZE((LONG_PTR)*(gc_ereg-1)); /* size = ENV_SIZE(cpreg) */
      gc_ereg = (LONG_PTR)*(gc_ereg);          /* link to prev environment */
   }
}


/* insert cells of each choicepoint & its chain of environments which point to
   heap objects into relocation chains */

sweep_choicepoints(gc_breg)
LONG_PTR gc_breg;
{
   LONG_PTR prev_top, saved_reg, hptr;
   BYTE     size;

   while (gc_breg != local_bottom-2) {        /* original value of breg */
      size = ENV_SIZE((LONG_PTR)*(gc_breg+5));
      sweep_environments((LONG_PTR)*(gc_breg+6), size);

      /* find previous top of stack */

      if (*(gc_breg+2) < *(gc_breg+6))        /* breg < ereg ? */
	 prev_top = (LONG_PTR)*(gc_breg+2);   /* prev_top = breg */
      else                                    /* prev_top = ereg - env_size */
	 prev_top = (LONG_PTR)*(gc_breg+6) - size;
      
      /* for each saved register */

      for (saved_reg = gc_breg+7; saved_reg <= prev_top; saved_reg++) {
         if (HEAP_PTR(saved_reg)) {
            UNMARK(saved_reg);
            into_relocation_chain(saved_reg, GET_NEXT(saved_reg));
         }
      }

      /* if the word pointed to by saved hreg is not marked, find  */
      /*   the first word above it that is marked, and point to it */

      hptr = (LONG_PTR)*(gc_breg+3);          /* word ptd to by saved hreg */
      while (!MARKED(hptr) && hptr < hreg)
         hptr++;
      *(gc_breg+3) = (LONG)hptr;              /* point to marked word */
      if (hptr == hreg) {                     /* no more marked words; */
	 *hptr = 0x80000002;                  /*   create one          */
	 hreg++;
	 total_marked++;
      }
      into_relocation_chain(gc_breg+3, hptr); /* insert into relocation chain */

      gc_breg = (LONG_PTR)*(gc_breg+2);       /* link to prev choicepoint */
   }
}




/* move marked objects on the heap upwards over unmarked objects, and reset
   all pointers to point to new locations */

compact_heap()
{
   LONG_PTR    dest, current, next;
   PSC_REC_PTR psc_ptr;
   LONG        i, bufsiz;

   /* upward phase - scan heap from high to low, setting marked upward ptrs */
   /* to point to what will be the new locations of the objects pointed to  */

   dest = heap_bottom + total_marked - 1;
   for (current = hreg - 1; current >= heap_bottom; current--) {
      if (MARKED(current)) {
         update_relocation_chain(current, dest);
         if (HEAP_PTR(current)) {
	    next = GET_NEXT(current);
	    if (TAG(*current) == CS &&           /* buffer; update its ptrs */
	        IS_BUFF((PSC_REC_PTR)next)) {
	       psc_ptr = (PSC_REC_PTR)next;
	       bufsiz = BUFF_SIZE(psc_ptr);
	       dest -= bufsiz - 1;               /* correct dest for size */
	       *current = (LONG)(dest + 1) | CS_TAG;
	       *(next + 1) = (GET_LENGTH(psc_ptr) == LONGBUFF) ?  /* name ptr */
	                     (LONG)(dest + 4) : (LONG)(dest + 3);
	       current -= bufsiz - 1;            /* correct current for size */
	    }
            else if (next < current)             /* push into reloc. chain */
               into_relocation_chain(current, next);
            else if (current == next)            /* cell pointing to itself */
               *current = (*current & MBIT) | (LONG)dest;    /* no tag */
         }
	 dest--;
      } else if (HEAP_PTR(current) && TAG(*current) == CS &&
                 IS_BUFF((PSC_REC_PTR)GET_NEXT(current))) {
	 /* unmarked buffer; update current to jump over buffer */
         current -= BUFF_SIZE((PSC_REC_PTR)GET_NEXT(current)) - 1;
      }
   }

   /* downward phase - scan heap from low to high, moving marked objects to  */
   /* their new locations & setting downward pointers to pt to new locations */

   dest = heap_bottom;
   for (current = heap_bottom; current < hreg; current++) {
      if (MARKED(current)) {
         update_relocation_chain(current, dest);
	 next = GET_NEXT(current);
	 if (HEAP_PTR(current) &&                /* buffer; move whole thing */
	     *current | ~MBIT == (LONG)(current + 1) &&
	     IS_BUFF((PSC_REC_PTR)next)) {
	    psc_ptr = (PSC_REC_PTR)next;
	    *current = (LONG)(dest + 1);
	    bufsiz = BUFF_SIZE(psc_ptr);
	    for (i = 1; i < bufsiz; i++)
	       *dest++ = *current++;
	    *dest = *current;
	 }
         else if (HEAP_PTR(current) &&           /* move current cell & push */
		  next > current) {              /*   into relocation chain  */
	    *dest = *current;
            into_relocation_chain(dest, next);
	 }
         else                                    /* just move current cell */
	    *dest = *current;
         UNMARK(dest);
	 dest++;
      } else if (HEAP_PTR(current) && *current == (LONG)(current + 1) &&
	         IS_BUFF((PSC_REC_PTR)GET_NEXT(current))) {
	 /* unmarked buffer; update current to jump over buffer */
	 current += BUFF_SIZE((PSC_REC_PTR)GET_NEXT(current)) - 1;
      }
   }
   hreg = dest;                                  /* reset hreg */
}


/* update a relocation chain to point all its cells to new location of object */

update_relocation_chain(current, dest)
LONG_PTR current, dest;
{
   LONG_PTR next;
   LONG     current_tag;

   while (RMARKED(current)) {
      current_tag = TAG(*current);
      next = GET_NEXT(current);
      *current = (*current & MBIT) | (*next & ~MBIT);
      *next = (*next & MBIT) | (LONG)dest | current_tag;
   }
}


/* dump memory for debugging purposes */

dump_mem()
{
   int      i;
   LONG_PTR ptr;

   printf("\n");
   printf("curr_fence   = %08x\n", curr_fence);
   printf("cpreg        = %08x\n", cpreg);
   printf("hreg         = %08x\n", hreg);
   printf("ereg         = %08x\n", ereg);
   printf("breg         = %08x\n", breg);
   printf("trreg        = %08x\n", trreg);
   printf("\n");
   printf("total_marked = %ld\n",  total_marked);
   printf("\n");
   for (i = 1; i <= num_regs; i++) 
      printf("reg[%d] = %08x\n", i, reg[i]);
   printf("heap:\n");
   for (ptr = heap_bottom; ptr <= hreg; ptr++)
      printf("  %08x -> %08x\n", ptr, *ptr);
   printf("local stack:\n");
   ptr = (breg < ereg) ? breg : ereg - ENV_SIZE(cpreg);
   for ( ; ptr <= local_bottom; ptr++) 
      printf("  %08x -> %08x\n", ptr, *ptr);
   printf("trail:\n");
   for (ptr = trreg; ptr <= trail_bottom; ptr++)
      printf("  %08x -> %08x\n", ptr, *ptr);
}
