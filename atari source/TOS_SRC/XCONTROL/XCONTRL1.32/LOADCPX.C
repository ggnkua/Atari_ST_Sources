/* loadcpx.c
 */

#include <tos.h>
#include <stdlib.h>

#include "xstructs.h"

Prghead head;

typedef struct PseudoBP
{
	long	tbase,
		tlen,
		dbase,
		dlen,
		bbase,
		blen;
	char	code[1];
} PBP;

extern PBP *loadbuf;

void
clearbss( PBP *pbp )
{
	char *p, *end;

	p = (char *)(pbp->tbase + pbp->tlen + pbp->dlen);
	end = p + pbp->blen;
	while( p < end )
		*p++ =  0;
}

void
fixitup( PBP *pbp, unsigned char *fixbuf )
{
	char	*curpos;
	unsigned char fixup;
	long	firstfix;

	firstfix = *((long *)fixbuf)++;
	if( firstfix )
	{
		curpos = (char *)(pbp->tbase);
		curpos += firstfix;
		*(long *)curpos += pbp->tbase;

		fixup = *fixbuf++;
		while( fixup )
		{
			if( fixup == 1 )
			{
				curpos += 0xfe;
			}
			else
			{
				curpos += fixup;
				*(long *)curpos += pbp->tbase;
			}
			fixup = *fixbuf++;
		}
	}
}

long
loadcpx( const char *name )
{
	long		fixlen, ret, savepos;
	PBP		*pbp = (void *)0L;
	unsigned char	*fixbuf = (void *)0L;
	int		handle = 0;

	ret = Fopen( name, FO_READ );
	if( ret < 0 )
		goto loaderr;

	handle = (int)ret;
	if ( Fseek(sizeof(CPXHEAD), handle, 0) < 0 )
		goto loaderr;

	if ( (Fread(handle, sizeof(head), &head) != sizeof(head)) ||
	     (head.magic != 0x601a) )
		goto loaderr;

	pbp = loadbuf;
	if (!pbp)
	    pbp =  (struct PseudoBP *)
		malloc( sizeof(pbp) + head.tsize + head.dsize + head.bsize
			+ CPX_CHICKEN );
	if( !pbp )
		goto loaderr;

	ret = (long)(&pbp->code[0]);
	pbp->tbase = ret;
	pbp->tlen = head.tsize;
	ret += head.tsize;
	pbp->dbase = ret;
	pbp->dlen = head.dsize;
	ret += head.dsize;
	pbp->bbase = ret;
	pbp->blen = head.bsize;

	ret = Fread( handle, head.tsize + head.dsize, &pbp->code[0] );
	if( ret != head.tsize + head.dsize )
		goto loaderr;

	savepos = Fseek( head.ssize, handle, 1 );
	if( savepos < 0 )
		goto loaderr;
	ret = Fseek( 0L, handle, 2 );
	Fseek( savepos, handle, 0 );
	fixlen = ret - savepos;
	if( fixlen <= 0 )
		goto loaderr;
	fixbuf = (unsigned char *)malloc( fixlen + CPX_CHICKEN );
	if( !fixbuf )
		goto loaderr;
	ret = Fread( handle, fixlen, fixbuf );
	if( ret != fixlen )
		goto loaderr;
	Fclose( handle );
	fixitup( pbp, fixbuf );
	free( fixbuf );
	clearbss( pbp );
	return (long)pbp;

loaderr:
	if( handle )
		Fclose( handle );
	if( pbp )
		free( pbp );
	if( fixbuf )
		free( fixbuf );
	return 0L;
}
