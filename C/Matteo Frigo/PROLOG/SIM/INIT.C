/************************************************************************
*									*
* The SB-Prolog System							*
* Copyright SUNY at Stony Brook, 1986; University of Arizona, 1987	*
*									*
************************************************************************/

/*-----------------------------------------------------------------
SB-Prolog is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY.  No author or distributor
accepts responsibility to anyone for the consequences of using it
or for whether it serves any particular purpose or works at all,
unless he says so in writing.  Refer to the SB-Prolog General Public
License for full details.

Everyone is granted permission to copy, modify and redistribute
SB-Prolog, but only under the conditions described in the
SB-Prolog General Public License.   A copy of this license is
supposed to have been given to you along with SB-Prolog so you
can know your rights and responsibilities.  It should be in a
file named COPYING.  Among other things, the copyright notice
and this notice must be preserved on all copies. 
------------------------------------------------------------------ */
/* init.c */

#include "sim.h"
#include "inst.h"
#include "aux.h"
#include <strings.h>

/* #define DEBUG */

LONG  maxmem    = 500000;  
LONG  maxpspace = 300000;
LONG  maxtrail;

WORD d_trace, d_hitrace;

extern char *_mymalloc(), *getenv();
extern LONG_PTR insert();

/****************************************************************************/

static BYTE perm = PERM;

init_simpath(path)
LONG *path;
{
    CHAR *ch;
    LONG_PTR temp;

   if ((ch = getenv("SIMPATH")) == NULL)
	quit("SB-Prolog: SIMPATH not defined: cannot proceed\n");
   temp = insert(ch, strlen(ch), 0, &perm);
   *path = ((LONG)temp) | CS_TAG;
}

init_sim(argc, argv)
int  argc;
char *argv[];
{
   WORD     i, itmp; 
   LONG     tempint;
   LONG_PTR temp, insert();
   CHAR     c;
   CHAR_PTR charp;

   /* for debugging malloc on sun (include /usr/lib/debug/malloc.o in link)
    * malloc_debug(2);
   */

   for (i = 0; i < BUCKET_CHAIN; i++) {
      MAKE_FREE(LONG_PTR, hash_table[i][TEMP]);
      MAKE_FREE(LONG_PTR, hash_table[i][PERM]);
   }

   trace = hitrace = disassem = num_line = 0;
   trace_sta = d_trace = d_hitrace = call_intercept = 0;
   interrupt_code = 0;

   maxtrail = maxmem / 5;

   if (argc == 1)
      quit("Usage: sim [-Ttdns] [-m s_size] [-p p_size] [-b tr_size] [-ui num] bc_file ...\n");

   for (i = 1; i < argc; i++) {
      if (*argv[i] == '-') {
         charp = argv[i];
         while (c = *++charp) {
            switch (c) {
               case 't': trace = d_trace = 1;
                         break;
               case 'T': hitrace = d_hitrace = 1;
               case 's': trace_sta = 1;
                         call_intercept = 1;
                         break;
               case 'n': num_line = 1;
                         break;
               case 'd': disassem = 1;
                         break;
               case 'm': i++;
                         sscanf(argv[i], "%d", &maxmem);
                         maxtrail = maxmem / 5;
                         break;
               case 'p': i++;
                         sscanf(argv[i], "%d", &maxpspace);
                         break;
               case 'b': i++;
                         sscanf(argv[i], "%d", &maxtrail);
                         break;
               case 'u': i++;    /* skip user field on this pass */
                         charp++;
                         break;
               default : printf("Unknown option %c\n", c);
            }  /* switch */
         }  /* while */
      }  /* if */
   }  /* for */

   pspace = (LONG_PTR)(_mymalloc(maxpspace*sizeof(LONG)));
   if (!pspace)
      quit("Not enough core!\n");
   max_fence = (CHAR_PTR)(pspace + maxpspace);

   memory = (LONG_PTR)(_mymalloc(maxmem*sizeof(LONG)));
   if (!memory)
      quit("Not enough core!\n");

   tstack = (LONG_PTR)(_mymalloc(maxtrail*sizeof(LONG)));
   if (!tstack)
      quit("Not enough core!\n");

   heap_bottom  = memory;
   local_bottom = memory + maxmem;
   trail_bottom = tstack + maxtrail;

   breg  = ereg      = mlocaltop = local_bottom - 2;
   hreg  = mheaptop  = heap_bottom;
   trreg = mtrailtop = trail_bottom - 1;
   hbreg = heap_bottom - 1;
   trap_vector[0] = pspace;
   curr_fence     = (CHAR_PTR)pspace;

   /* install fail and halt instructions     */
   /* format is  opcode + pad  (word + word) */

   *((WORD_PTR)curr_fence) = fail;   curr_fence += sizeof(WORD);
   *((WORD_PTR)curr_fence) = 0;      curr_fence += sizeof(WORD);

   cpreg = (LONG_PTR)curr_fence;                /* halt on final success */
   *(local_bottom - 1) = (LONG)curr_fence;      /* halt on final failure */

   *((WORD_PTR)curr_fence) = halt;   curr_fence += sizeof(WORD);
   *((WORD_PTR)curr_fence) =    0;   curr_fence += sizeof(WORD);

   temp = insert("[]", 2, 0, &perm);
   nil_sym = (LONG)temp | CS_TAG;

   temp = insert(".", 1, 2, &perm);
   list_str = (LONG)temp | CS_TAG;
   list_psc = (PSC_REC_PTR)FOLLOW(temp);

   temp = insert(",", 1, 2, &perm);
   comma_psc = (PSC_REC_PTR)FOLLOW(temp);

   temp = insert("_$interrupt", 11, 2, &perm);
   interrupt_psc = (PSC_REC_PTR)FOLLOW(temp);
   trap_vector[1] = 0;
   inst_begin = 0;

   /* now strip off user parameters */
   for (i = 0; i < 10;  i++) 
      flags[i] = nil_sym;
   for (i = 1; i < argc; i++) {
      if (*argv[i] == '-') {
         charp = argv[i];
         while (c = *++charp) {
            switch (c) {
               case 'p':
               case 'b':
               case 'm': i++;
               case 't':
               case 'T':
               case 's':
               case 'n':
               case 'd': break;
               case 'u': itmp = *++charp - '0';
                         i++;  /* value; retrieved by flags(index+10,V) */
                         if (*argv[i] >= 48 && *argv[i] <= 57) {  /*num*/
                            sscanf(argv[i], "%d", &tempint);
                            flags[itmp] = MAKEINT(tempint);
                         } else {   /* make it a constant */
                            temp = insert(argv[i], strlen(argv[i]), 0, &perm);
                            flags[itmp] = (LONG)temp | CS_TAG;
                         }
                         break;
            }  /* switch */
         }  /* while */
      }  /* if */
   }  /* for */

#ifdef DEBUG
   printf("init_sys\n");
   printf("pspace       = %08x\n", pspace);
   printf("max_fence    = %08x\n", max_fence);
   printf("memory       = %08x\n", memory);
   printf("tstack       = %08x\n", tstack);
   printf("heap_bottom  = %08x\n", heap_bottom);
   printf("local_bottom = %08x\n", local_bottom);
   printf("trail_bottom = %08x\n", trail_bottom);
   printf("breg         = %08x\n", breg);
   printf("ereg         = %08x\n", ereg);
   printf("mlocaltop    = %08x\n", mlocaltop);
   printf("hreg         = %08x\n", hreg);
   printf("mheaptop     = %08x\n", mheaptop);
   printf("trreg        = %08x\n", trreg);
   printf("mtrailtop    = %08x\n", mtrailtop);
   printf("hbreg        = %08x\n", hbreg);
   printf("curr_fence   = %08x\n", curr_fence);
   printf("cpreg        = %08x\n", cpreg);
   printf("list_str     = %08x\n", list_str);
   printf("list_psc     = %08x\n", list_psc);
   printf("comma_psc    = %08x\n", comma_psc);
#endif

}  /* end of init_sym */

/******************************************************************************/

init_loading(argc, argv)
int  argc;
char *argv[];
{
   CHAR c;
   WORD i;
   WORD n = 0;  /* number of the initial loaded files */

   for (i = 1; i < argc; i++) {
      if (*argv[i] == '-') {
         c = *(argv[i] + 1);
         switch (c) {
            case 'u':
            case 'm':
            case 'p':
            case 'b': i++;
            default : break;
         }
      } else {
         int loaded_ok = loader(argv[i]);
         if (loaded_ok==10) {
            char errormsg[128];
            sprintf(errormsg, "File '%s' cannot be opened\n",argv[i]);
            quit(errormsg);
         } else if (loaded_ok)
                   quit("Error in loading initial files\n");
         n++;
      }
   }
   if (n == 0) 
      quit("No input file!\n");

}  /* end of init_loading */

/******************************************/
/* trick to get a 4-byte aligned malloc() */
char *_mymalloc(size)
int size;
{
	char *p;
	char *malloc();
	p=malloc(size+4);
	if (p==NULL) return NULL;
	return (char *)( (long) (p+4)&0xfffffffc );
}

