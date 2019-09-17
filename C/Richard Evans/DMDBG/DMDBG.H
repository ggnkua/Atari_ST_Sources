/****************************************************
** dmdbg.h :- Header file for dmdbg.c              **
**                                                 **
**            Based on ideas by Allen I. Hollub in **
**            'C+C++ Programming with Objects in C **
**            and C++'                             **
****************************************************/

#ifndef DMDBG_H
#define DMDBG_H

#include <stdio.h>
#include <stdlib.h>


typedef enum
{
    DMDBG_NO_ERROR = 0,
    DMDBG_MAGIC_FAIL,
    DMDBG_MEMFAIL,
    DMDBG_ODD_PTR,     
    DMDBG_NULL_PTR,    
    DMDBG_PTR_LBOUND,  
    DMDBG_INFOSTRUCT,  
    DMDBG_PTR_UROUT,  
    DMDBG_MALLOC_OK,   
    DMDBG_FREE_OK,

/*  User messages start here  */

/*   User messages end here   */

    DMDBG_NUM_MESSAGES
} DMDBGMSGVAL;    

typedef struct
{
    DMDBGMSGVAL  msg;
    long         line;
    char        *file;
    char        *func;
} DMDBGERRSTRCT;

typedef struct
{
    long    valid;
    long    line;
    size_t  size;
    size_t  count;
    char   *file;
} DMDBGINFSTRCT;

#ifdef DMDBG

  #define malloc(a) dmdbg_malloc((a), __FILE__, __LINE__)
  #define free(a)   dmdbg_free((void *)(a), __FILE__, __LINE__)
  #define P_ERR(a)  printf a
  #define CHK_PTR(a, b) dmdbg_chk_ptr((void *)(a), (b), __FILE__, __LINE__)

#else

  #define P_ERR(a)
  #define CHK_PTR(a, b)

#endif /* #ifdef DMDBG */


/* Function prototypes */

long dmdbg_inst_cback(long (*err_function)(DMDBGERRSTRCT *));
long dmdbg_inst_ptrchk(long (*chk_function)(void *, char *, char *, long));
long dmdbg_hndl_msg(DMDBGMSGVAL msg, char *func, char *file, long line);
long dmdbg_chk_ptr(void *ptr, char *func, char *file, long line);    
void dmdbg_free(void *ptr, char *file, long line);
void *dmdbg_malloc(size_t size, char *file, long line);
DMDBGINFSTRCT *dmdbg_get_infstrct(void);
size_t dmdbg_blk_rmn(void);

#endif /* #ifndef DMDBG_H */
