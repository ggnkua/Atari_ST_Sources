/* ---------------------------------------- */
/*           VARARGS  for MIPS/GNU CC       */
/*                                          */
/*                                          */
/*                                          */
/*                                          */
/* ---------------------------------------- */

/* WARNING: THIS depends heavily on in register parameter
   passing conventions of the MIPS.  This is compatible with MIPS
   programs, including printf; but differs from MIPS
   implementation. */

/*            PROLOGUE FOR VARARGS PROGRAMS:
	      
                                        ;;;; META COMMENTS
      .align 0
                                        ;;;; Purpose: identify varargs pgm
                                        ;;;; to codegen. I'd rather have a
					;;;; Flag in the compiler than this.

__vd_alist.0:
      .ascii "__%%VARARGS\0"
      .ent    zrintf
zrintf:
 #PROLOGUE
      add     $8,$0,$29
                                        ;;;; Leave extra space in frame
					;;;; to save f12 f14
      subu    $29,112 #temp=   76,saveregs=   32, sfo=   -4
 #    .mask   0xc0010000
      sw      $31,4($29)
      sw      $30,8($29)
                                        ;;;; Purpose:save stack size on stack
                                        ;;;; for easier retrieval
      addi    $9,$0,112       #Varargs suspicion
      sw      $9,-4($8)       #Varargs suspicion
                                        ;;;; save floating point registers
                                        ;;;; into extra stack space (in the
					;;;; varargs callee frame, NOT in the
					;;;; space saved by caller for register
					;;;; argument write back. Thus, we
					;;;; can write back both, and let the
					;;;; va_arg macro decide what is
					;;;; required.

      s.d     $f12,16($29)    #Varargs Suspicion
      s.d     $f14,24($29)    #Varargs Suspicion

      sw      $16,28($29)
 #    .fmask  0x0
      add     $30,$0,$8
 #END PROLOGUE
                                        ;;;; Write back of r4-r7 due to
					;;;; the va_dcl, va_start combination

      sw      $4,0($30)       #movsi $4 -> 0($30)
      sw      $5,4($30)       #movsi $5 -> 4($30)
      sw      $6,8($30)       #movsi $6 -> 8($30)
      sw      $7,12($30)      #movsi $7 -> 12($30)
  
*/

typedef struct 
{ int pnt;
  char *stack;
  double *fpregs;  
   } va_list  ;
				/* Used to push R4-R7 to stack  */
				/* and to access argument list on stack */
#define va_alist _va_alist, __va_alist,__vb_alist,__vc_alist

#define va_dcl int _va_alist, __va_alist,__vb_alist,__vc_alist; 


#define va_start(list) {\
       static char __vd_alist[16] = "__%%VARARGS";  /* Identify to codegen */\
       &__va_alist,&__vb_alist,&__vc_alist,         /* write back to stack */\
       (list).pnt = 0,                              /* start from first    */\
       (list).stack =  (char *) &_va_alist,         /* Access parameter list*/\
       (list).fpregs =  (double *)((list).stack -\
				   *(int *)((list).stack -4) +  16),       \
       (list).stack;}         

#define va_end(list)

				/* For argument passing convention see */
				/* both tm.h and Jerry Kane's book     */

#define va_arg(list,mode) (((mode *)\
              (((sizeof(mode) > 4) ?\
		    (((list).pnt == 0 )?(((list).pnt = -1),\
				       (list).stack = (char *)\
				                       (((int)((list).stack)\
						      + 2*8 - 1) & -8),\
				       (char *)((list).fpregs+1)\
				       )\
  		       :((list).pnt == -1) ?((list).pnt = 2,\
				       (list).stack = (char *)\
					              (((int)((list).stack)\
						      + 2*8 - 1) & -8),\
				       (char *)((list).fpregs+2) \
				       )\
  		              :(((list).pnt > 0 )?\
				((list).pnt =((list).pnt +1),\
                                                (list).stack =(char *)\
						   (((int)((list).stack)\
						      + 2*8 - 1) & -8) \
						):(char *)abort()))\
		:((list).pnt = (((list).pnt >=0) ? ((list).pnt +1)\
                                :((list).pnt == -1) ? 2 :3),\
		 (list).stack =  (char *)(((int)((list).stack)+ 2*4 - 1) & -4)\
		)\
		)))[-1])\
