#include <stdio.h>
#include "bm.h"
#include "Extern.h"
MatchFound(Desc, BuffPos, Buffer, BuffEnd)
struct PattDesc *Desc; /* state info about search for one string */
int BuffPos; /* offset of first char of buffer into the file being searched */
char *Buffer, /* pointer to the first character in the buffer */
	*BuffEnd; /* pointer to the last character in the buffer */
{
	char *MLineBegin, *MLineEnd;
	Desc->Success = 0;
	/* Start points to first character after a successful match */
	MLineBegin = MLineEnd = Desc->Start - 1;
	while(MLineBegin >=Buffer && *MLineBegin != '\n') --MLineBegin;
	++MLineBegin;
	while( MLineEnd <= BuffEnd && *MLineEnd != '\n') ++MLineEnd;
	if (MLineEnd > BuffEnd) --MLineEnd;
	/* fixed 25jun85 pdbain. suppress multiple matches of the same
	* pattern on one line */
	Desc->Start = MLineEnd + 1;
	/* check if exact match; TOS has \r in text line, hence -1 */
	if (xFlag && !( Desc->PatLen == (*MLineEnd != '\n' ? ((MLineEnd -
	MLineBegin) + 1) : (MLineEnd - MLineBegin)-1)))
		return(0); /* failure */
	if (sFlag) return(1);
	if (cFlag) {
		++MatchCount;
		return(1);
	} /* if */
	PrintLine(BuffPos+(Desc->Start-Buffer),MLineBegin,MLineEnd);
	return(1);
} /* MatchFound */
