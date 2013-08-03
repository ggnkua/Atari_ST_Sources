/*  pgmld.c - program load						*/
/*  xpgmld								*/



/*
**  mods
**
**  25 Sep 86	scc	M01.01.0925.01	Items needing relocation were not being
**					relocated if the program being loaded had no
**					BSS (because the size of BSS determined how
**					many bytes of relocation info were read).
**
**  23 Oct 86	scc	M01.01.1023.01	Error returns from xread() and pgfix01() in
**					the 'FOREVER' loop in pgmld01() were not being
**					checked for and returned.
**
*/

#include	"gportab.h"
#include	"bdos.h"
#include	"fs.h"
#include	"bios.h"				/*  M01.01.02	*/
#include	"mem.h"
#include	"gemerror.h"
#include	"pghdr.h"


/*
**  xpgmld -
**
*/

ERROR	xpgmld( s , p )
	char	*s ;		/*  program name			*/
	PD	*p ;		/*  ptr to PD				*/
				/*  program space follows PD		*/
{
	ERROR		r ;
	FH		h ;
	WORD		magic ;
	ERROR		pgmld01() ;


	if(  (r = xopen( s , 0 )) < 0L  )	/*  open file for read	*/
		return( r ) ;

	h = (int) r ;				/*  get file handle	*/

	if( (r = xread( h, 2L, &magic)) < 0L )	/*  read magic nbr	*/
		return( r ) ;

	/*
	**  the following switch statement will allow us to call different
	**  strategies for loading different types of files
	*/

	switch( magic )
	{
		case 0x0601a:
			r = pgmld01( h , p ) ;
			break ;
		default:
			r = EPLFMT ;
	}

	xclose( h ) ;
	return( r ) ;
}



/*
**  lastcp - used to keep track of the code ptr betwee pgmld01 and pgfix01
*/

static BYTE	*lastcp ;


/*
**  pgmld01 - oldest known gemdos load format - very similar to cp/m 68k
**	load in the (open) program file with handle 'h' using load file
**	strategy like cp/m 68k.  Specifically:
**
**		read in program header and determine format parameters
**		seek past the symbol table to the start of the relo info
**  		read in the first offset (it's different than the rest in that 
**		  it is a longword instead of a byte).
**  		make the first adjustment
**  		until we run out of relocation info or we have an error
**			read in relocation info into the bss area
**			call pgfix01() to fix up the code using that info
**		zero out the bss
*/

ERROR	pgmld01( h , pdptr )
	FH	h ;
	PD	*pdptr ;
{
	REG PGMHDR01	*hd ;			
	REG PGMINFO	*pi ;
	REG PD		*p ;
	PGMHDR01	hdr ;			
	PGMINFO		pinfo ;		
	BYTE		*cp ;
	LONG		relst ;
	LONG		flen ;
	ERROR		r ;
	ERROR		pgfix01() ;


	hd = & hdr ;
	pi = &pinfo ;
	p = pdptr ;
	relst = 0 ;

	/*
	**  read in the program header 
	*/

	if(   ( r = xread(h,(LONG)sizeof(PGMHDR01),&hdr) )  <  0L  )
		return( r ) ;

	/*
	**  calculate program load info
	*/

	flen = (pi->pi_tlen=hd->h01_tlen) + (pi->pi_dlen=hd->h01_dlen) ;
	pi->pi_blen = hd->h01_blen ;
	pi->pi_slen = hd->h01_slen ;
	pi->pi_tpalen = p->p_hitpa - p->p_lowtpa - sizeof(PD) ;
	pi->pi_tbase = (char *) (p+1) ;		/*  1st byte after PD	*/
	pi->pi_bbase = pi->pi_tbase + flen ;	
	pi->pi_dbase = pi->pi_tbase + pi->pi_tlen ;


	/*
	**  see if there is enough room to load in the file, then see if
	**  the requested bss space is larger than the space we have to offer
	*/

	if( flen > pi->pi_tpalen  ||  pi->pi_tpalen-flen < pi->pi_blen )
		return( ENSMEM ) ;

	/*
	**  initialize PD fields
	*/

	bmove( (char*)&pi->pi_tbase , (char*)&p->p_tbase , 6 * sizeof(long) ) ;

	/*  
	**  read in the program file (text and data)
	**  if there is an error reading in the file or if it is an abs
	**	file, then we are finished  
	*/

	if(  (r = xread(h,flen,pi->pi_tbase)) < 0  )
		return( r ) ;

	if( hd->h01_abs )
		return( SUCCESS ) ;	/*  do we need to clr bss here?	*/

	/*  
	**  if not an absolute format, position past the symbols and start the 
	**	reloc pointer  (flen is tlen + dlen).  NOTE that relst is 
	**	init'd to 0, so if the format is absolute, we will not drop
	**	into the fixup code.
	*/

	if( !hd->h01_abs )
	{
		/**********  should change hard coded 0x1c  ******************/
		if(  (r = xlseek(flen+pi->pi_slen+0x1c,h,0)) < 0L  )
			return( r ) ;

		if(  (r = xread( h , (long)sizeof(relst) , &relst ))  <  0L  )
			return( r ) ;
	}

	if( relst != 0 )
	{
		cp = pi->pi_tbase + relst ;

		/*  make sure we didn't wrap memory or overrun the bss  */

		if(  cp < pi->pi_tbase  ||  cp >= pi->pi_bbase  )
			return( EPLFMT ) ;

		*((long *)(cp)) += (long)pi->pi_tbase ;	/*  1st fixup     */

		lastcp = cp ;				/*  for pgfix01() */

		flen = p->p_hitpa - pi->pi_bbase;	/* M01.01.0925.01 */

		FOREVER
		{	/*  read in more relocation info  */
			if( (r = xread(h,flen,pi->pi_bbase)) <= 0 ) /* M01.01.0925.01 */
				break ;
			/*  do fixups using that info  */
			if(   (r = pgfix01( r , pi ))   <=   0   )
				break ;
		}

		if ( r < 0 )			/* M01.01.1023.01 */
			return( r );
	}

	/*  zero out the bss  */

	if( pi->pi_blen != 0 )
	{
		*pi->pi_bbase = 0 ;
		if( pi->pi_blen > 1 )
			lbmove(pi->pi_bbase, pi->pi_bbase+1, pi->pi_blen-1) ;

	}

	return( SUCCESS ) ;
}



/*
**  pgfix01 - do the next set of fixups
**
**  returns:
**	addr of last modified longword in code segment (cp)
**	0 if error or done
**	stat01:
**		>0: all offsets in bss used up, read in more
**		=0: offset of 0 encountered, no more fixups
**		<0: EPLFMT (load file format error)
*/


LONG	pgfix01( nrelbytes , pi )
	LONG	nrelbytes ;		/*  nbr of avail rel values	*/
	PGMINFO	*pi ;			/*  program info pointer	*/
{
	REG UBYTE	*cp ;		/*  code pointer		*/
	REG UBYTE	*rp ;		/*  relocation info pointer	*/
	REG LONG	n ;		/*  nbr of relocation bytes	*/
	REG UBYTE	*bbase ;	/*  base addr of bss segment	*/
	REG LONG	tbase ;		/*  base addr of text segment	*/

	cp = lastcp ;
	rp = pi->pi_bbase ;
	n = nrelbytes ;	
	tbase = (LONG) pi->pi_tbase ;
	bbase = pi->pi_bbase ;

	while( n--  &&  *rp != 0 )
	{
		if( *rp == 1 )
			cp += 0xfe ;
		else
		{
#if	COMPILER == ALCYON
			/*  get the byte at rp, don't sign ext, add to cp  */
			cp += 0x00ff & (long)(*rp) ;		/* [1]	*/
#else
			cp += *rp ;
#endif
			if(  cp >= bbase  )
			{
				return( EPLFMT ) ;
			}
			*( (long *)(cp) ) += tbase ;

		}
		++rp ;
	}

	lastcp = cp ;			/*  save code pointer		*/
	return(  ++n == 0  ? 1 : SUCCESS  ) ;
}

/*
** [1]	Alcyon manages to sign extend the byte into the long which is added to
**	cp.  It does this even though rp is delcared a pointer to an unsigned 
**	BYTE (char).  I think this is a bug, and shouldn't occur in other
**	compilers; but then, what do I know? - ktb
*/


