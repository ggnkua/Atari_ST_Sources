/***********************************************************
** dmdbg.c :- A set of routines to aid in the development **
**            and debugging of memory allocation routines **
**                                                        **
**            Based on ideas by Allen I. Hollub in 'C+C++ **
**            Programming with Objects in C and C++'      **
***********************************************************/

#include <portab.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define DMDBG

#include "dmdbg.h"


/* Internal definitions */

#define INT_MAGIC_NUMBER1 (long)123456789
#define INT_MAGIC_NUMBER2 (long)987654321
#define INT_LOW_LIMIT     (size_t)0x7ff

#define INT_ASSERT_INFOSTRUCT(a) dmdbg_int_asrtinfstrct(__FILE__, __LINE__)


/* Prevent clash with redefined malloc and free routines */

#undef malloc
#undef free


/* Internal structures */

typedef struct
{
    long    magic1;
    size_t  size;
    char    *file;
    long    line;
    long    magic2;
} INTMEMHEADER;

typedef struct
{
    long          magic1;
    DMDBGINFSTRCT infstrct;
    long          magic2;
} INTINFOSTRUCT;

typedef struct
{
    long          magic1;
    DMDBGERRSTRCT errstruct;
    long          magic2;
} INTERRSTRUCT;

/* Declare and initialise INTINFOSTRUCT structure */

static INTINFOSTRUCT intinfostruct = 
{
    INT_MAGIC_NUMBER1,
    {FALSE, 0L, 0L, 0L, (char *)NULL},
    INT_MAGIC_NUMBER2
};

/* Declare and initialise INTERRSTRUCT structure */

static INTERRSTRUCT interrstruct = 
{
    INT_MAGIC_NUMBER1,
    {0L, 0L, (char *)NULL, (char *)NULL},
    INT_MAGIC_NUMBER2
};


/* Internal function prototypes */

static long dmdbg_int_defhndlr(DMDBGERRSTRCT *es);
static long dmdbg_int_chkptrodd(void *ptr, char *func, char *file, long line);    
static long dmdbg_int_chkptrnull(void *ptr, char *func, char *file, long line);    
static long dmdbg_int_chkptrbnds(void *ptr, char *func, char *file, long line);    
static long dmdbg_int_asrtinfstrct(char *file, long line);


/* Internal variable declarations */

static size_t blockcount = 0L;

static long (*err_ptr)(DMDBGERRSTRCT *)                = dmdbg_int_defhndlr;
static long (*check_ptr)(void *, char *, char *, long) = NULL;


/************************
** Routines begin here **
************************/

void *dmdbg_malloc(size_t size, char *file, long line)
{
        INTMEMHEADER *retval;
        
        /* Allow for INTMEMHEADER structure */

        retval = (INTMEMHEADER *)malloc(size + sizeof(INTMEMHEADER)); 
        
        if(retval == (INTMEMHEADER *)NULL)
        {
                dmdbg_hndl_msg(DMDBG_MEMFAIL, "dmdbg_malloc", file, line); 
                return (void *)retval;
        }        
            
        /* Place magic numbers and details in header */
        
        retval->magic1 = INT_MAGIC_NUMBER1; 
        retval->magic2 = INT_MAGIC_NUMBER2; 
        retval->size   = size;
        retval->line   = line;
        retval->file   = file;

        /* Update allocated block counter */

        blockcount++;
        
        /* Inform user of successful malloc */

        dmdbg_hndl_msg(DMDBG_MALLOC_OK, "dmdbg_malloc", file, line); 

        /* Advance pointer past header */
  
        return (void *)(++retval);
}


void dmdbg_free(void *ptr, char *file, long line)
{
        INTMEMHEADER *mptr;
        
        /* If INTINFOSTRUCT structure is valid, set details **
        ** validity to FALSE; this ensures that details     **
        ** will only be used when validity has been         **
        ** specifically set to TRUE.                        */

        if(INT_ASSERT_INFOSTRUCT())
        {
            intinfostruct.infstrct.valid = FALSE;
        }

        /* Make sure pointer is OK before continuing */

        if(!(dmdbg_chk_ptr(ptr, "dmdbg_free", file, line)))
        {
            return;
        }
        
        /* Point at INTMEMHEADER structure */

        mptr = --((INTMEMHEADER *)ptr);

        /* Check both magic numbers to make sure this **
        ** is a valid INTMEMHEADER structure          */                    

        if( (mptr->magic1 != INT_MAGIC_NUMBER1) ||
            (mptr->magic2 != INT_MAGIC_NUMBER2) )
        {
            /* Inform user of free() failure */
            
            dmdbg_hndl_msg(DMDBG_MAGIC_FAIL, "dmdbg_free", file, line);
            return;
        }
        
        /* Update allocated block counter */

        blockcount--;

        /* If INTINFOSTRUCT structure is valid **
        ** then set all details                */

        if(INT_ASSERT_INFOSTRUCT())
        {
            intinfostruct.infstrct.valid = TRUE;
            intinfostruct.infstrct.size  = mptr->size;
            intinfostruct.infstrct.line  = mptr->line;
            intinfostruct.infstrct.file  = mptr->file;
            intinfostruct.infstrct.count = blockcount;
        }
            
        /* Ensure that magic number entries are cleared, otherwise  **
        ** dmdbg_free would still consider a pointer to deallocated **
        ** memory as valid.                                         */

        mptr->magic1 = 0L;
        mptr->magic2 = 0L;

        free((void *)mptr);

        /* Inform user of successful free */

        dmdbg_hndl_msg(DMDBG_FREE_OK, "dmdbg_free", file, line);

        return;
}


long dmdbg_inst_cback(long (*err_function)(DMDBGERRSTRCT *))
{
    /* Check function pointer for validity, N.B. NULL is valid */
    
    if( !(dmdbg_int_chkptrodd((void *)err_function, 
                "dmdbg_inst_cback", __FILE__, __LINE__)) || 
        !(dmdbg_int_chkptrbnds((void *)err_function, 
                "dmdbg_inst_cback", __FILE__, __LINE__)) )
    {
        return FALSE;
    }
    
    /* Set new error handling routine */

    err_ptr = err_function;
    return TRUE;
}
    

long dmdbg_inst_ptrchk(long (*chk_function)(void *, char *, char *, long))
{
    /* Check function pointer for validity, N.B. NULL is valid */
    
    if( !(dmdbg_int_chkptrodd((void *)chk_function, 
                "dmdbg_inst_ptrchk", __FILE__, __LINE__)) || 
        !(dmdbg_int_chkptrbnds((void *)chk_function, 
                "dmdbg_inst_ptrchk", __FILE__, __LINE__)) )
    {
        return FALSE;
    }
    
    /* Set new pointer checking routine */

    check_ptr = chk_function;
    return TRUE;
}


long dmdbg_chk_ptr(void *ptr, char *func, char *file, long line)    
{
    if(dmdbg_int_chkptrodd(ptr, func, file, line) == FALSE)
    {
        return FALSE;
    }
    
    if(dmdbg_int_chkptrnull(ptr, func, file, line) == FALSE)
    {
        return FALSE;
    }

    if(check_ptr)
    {
        if(check_ptr(ptr, func, file, line) == FALSE)
        {
            return FALSE;
        }
    }
        
    return dmdbg_int_chkptrbnds(ptr, func, file, line);
}


DMDBGINFSTRCT *dmdbg_get_infstrct(void)
{
    /* Ensure validity of INTINFOSTRUCT structure **
    ** before returning the address.              */

    if(INT_ASSERT_INFOSTRUCT())
    {
        return (DMDBGINFSTRCT *)&intinfostruct.infstrct;
    }
    
    return (DMDBGINFSTRCT *)NULL;
}    
          

static long dmdbg_int_asrtinfstrct(char *file, long line)
{
    /* Check structure for valid magic numbers */
    
    if( (intinfostruct.magic1 != INT_MAGIC_NUMBER1) ||
        (intinfostruct.magic2 != INT_MAGIC_NUMBER2) )
    {    
        /* Inform user of invalid structure */

        dmdbg_hndl_msg(DMDBG_INFOSTRUCT, "dmdbg_int_asrtinfstrct", file, line);        
        return FALSE;
    }
    
    return TRUE;
}


static long dmdbg_int_chkptrodd(void *ptr, char *func, char *file, long line)    
{
    if( (size_t)ptr & (size_t)1 )
    {
        /* Inform user of odd pointer */
        
        dmdbg_hndl_msg(DMDBG_ODD_PTR, func, file, line);     
        return FALSE;
    }
    
    return TRUE;
}


static long dmdbg_int_chkptrnull(void *ptr, char *func, char *file, long line)    
{
    if(ptr == (void *)NULL)
    {
        /* Inform user of NULL pointer */

        dmdbg_hndl_msg(DMDBG_NULL_PTR, func, file, line);     
        return FALSE;
    }
    
    return TRUE;
}


static long dmdbg_int_chkptrbnds(void *ptr, char *func, char *file, long line)    
{
    if( (ptr) && (size_t)ptr <= INT_LOW_LIMIT )
    {
        /* Inform user that pointer is below legal memory limit */

        dmdbg_hndl_msg(DMDBG_PTR_LBOUND, func, file, line);     
        return FALSE;
    }

    return TRUE;
}


long dmdbg_hndl_msg(DMDBGMSGVAL msg, char *func, char *file, long line)
{
    if(err_ptr != NULL)
    {
        /* Ensure validity of INTERRSTRUCT structure **
        ** before filling with message details       **
        **                                           **
        ** This is currently a redundant check.      */

        if( (interrstruct.magic1 == INT_MAGIC_NUMBER1) &&
            (interrstruct.magic2 == INT_MAGIC_NUMBER2) )
        {
            interrstruct.errstruct.msg  = msg;
            interrstruct.errstruct.file = file;
            interrstruct.errstruct.func = func;
            interrstruct.errstruct.line = line;

            /* Call error message handling routine, passing **
            ** address of valid INTERRSTRUCT structure      */

            return(err_ptr((DMDBGERRSTRCT *)&interrstruct.errstruct));
        }
    }
    
    return FALSE;
}
   

static long dmdbg_int_defhndlr(DMDBGERRSTRCT *es)
{
    printf("%s: error %d occured in %s at line %ld.\n", 
                  es->func, es->msg, es->file, es->line);
    return TRUE;
}


size_t dmdbg_blk_rmn(void)
{
    return blockcount;
}
