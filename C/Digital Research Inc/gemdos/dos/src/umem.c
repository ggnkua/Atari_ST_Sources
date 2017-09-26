/*  umem.c - user memory management interface routines			*/
/*  xmalloc, xmfreblk, xsetblk						*/


/*
** NOTE:
**	mods with "SCC.XX.NN" are mods which try to merge fixes to a special
**	post 1.0 / pre 1.1 version.  The notation refers to a DRI internal
**	document (see SCC), which is a change log.  SCC refers to the
**	originator of the fix.  The XX refers to the module in which the
**	fix was originally made, fs.c (FS), sup.c (SUP), etc.  The NN is
**	the fix number to that module as indicated on the change log.  For
**	the most part, these numbers are meaningless, and serve only to 
**	correspond code to particular problems.
**
**  mods
**     date     who mod 		fix/change/note
**  ----------- --  ------------------	-------------------------------
**  06 May 1986 ktb M01.01.SCC.MEM.03	xmalloc(): amount < -1L.
*/

#ifndef	DBGUMEM
#define	DBGUMEM	0
#endif

#include	"gportab.h"
#include	"fs.h"
#include	"bios.h"
#include	"mem.h"
#include	"gemerror.h"


/*
**  xmalloc - 
**
**	Function 0x48	m_alloc
**
**	Last modified	SCC	3 Jun 85
*/

long	xmalloc(amount)
	long	amount;
{
	MD *m;

	/*  M01.01.SCC.MEM.03  */

	if(  amount < -1L  )
		return( 0 ) ;

	/*
	**  Round odd-value requests (except -1L) to next higher even number.
	*/

	if ((amount != -1L) && (amount & 1))
		amount++;

	/*
	**  Pass the request on to the internal routine.  If it was not able 
	**  to grant the request, then abort.
	*/

	if (!(m = ffit(amount,&pmd)))
		return(0);

	/*
	**  If the request was -1L, the internal routine returned the amount 
	**  of available memory, rather than a pointer to a memory descriptor.
	*/

	if (amount == -1L)
		return( (long) m );

	/*
	**  The internal routine returned a pointer to a memory descriptor.  
	**  Return its pointer to the start of the block.
	*/

	return(m->m_start);
}


/*
**  xmfree - 
**
**	Function 0x49	m_free
*/

long	xmfree(addr)
	long	addr;
{
	MD *p,**q;

	for (p = *(q = &pmd.mp_mal); p; p = *(q = &p->m_link))
		if (addr == p->m_start)
			break;

	if (!p)
		return(EIMBA);

	*q = p->m_link;
	freeit(p,&pmd);

	return(E_OK);
}

/*
**  xsetblk - 
**
**	Function 0x4A	m_shrink
**
**	Last modified	SCC	19 Apr 85
*/

long	xsetblk(n,blk,len)
	int	n ;			/*  dummy, not used 		*/
	char	*blk ;			/*  addr of block to free	*/
	long	len ;			/*  length of block to free	*/
{
	MD *m,*p;

	/*
	**  Traverse the list of memory descriptors looking for this block.
	*/

	for (p = pmd.mp_mal; p; p = p->m_link)
		if(  (long) blk == p->m_start  )
			break;

	/*
	**  If block address doesn't match any memory descriptor, then abort.
	*/

	if (!p)
		return(EIMBA);

	/*
	**  If the caller is not shrinking the block size, then abort.
	*/

	if (p->m_length < len)
		return(EGSBF);

	/*
	**  Always shrink to an even word length.
	*/

	if (len & 1)
		len++;

	/*
	**  Create a memory descriptor for the freed portion of memory.
	*/

	m = MGET(MD);
	/**************
	** what if 0? *
	**************/
#if	DBGUMEM
	if( m == 0 )
		panic("umem.c/xsetblk: Null Return From MGET\n") ;
#endif

	m->m_start = p->m_start + len;
	m->m_length = p->m_length - len;
	p->m_length = len;
	freeit(m,&pmd);

	return(E_OK);
}


