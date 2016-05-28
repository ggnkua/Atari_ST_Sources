/* @(#)lhaconst.h, -dh- 23.05.1996
 */

#ifndef _LHACONST_H
#define _LHACONST_H

#include <limits.h>

#define FA_SELECTED	2
#define FA_DELETED	4
#define FA_DONE		8
#define FA_EDITED	16
#define FA_COMALLOC	32

#define _PC_CASE		6
#define	_PC_CASESENS	0
#define	_PC_CASECONV	1
#define	_PC_CASEINSENS	2

#define BUFFERSIZ	(24*1024L)
#define	FILEBUFSIZ	16384L

#define MAXBUFFER	(1L<<17)
#define MAXBUFFERL2	(1L<<19)

#define DICBIT		13
#define DICSIZ		(1U<<DICBIT)

#define MATCHBIT	8
#define MAXMATCH	256

#define THRESHOLD	2
#define PERC_FLAG	0x8000U
#define NC			(UCHAR_MAX+MAXMATCH+1-THRESHOLD)
#define CBIT		9
#define CODE_BIT	16

#define NP			(DICBIT+1)
#define NT			(CODE_BIT+3)

#define PBIT		4
#define TBIT		5

#if NT > NP
# define NPT NT
#else
# define NPT NP
#endif

#define MAX_HASH_VAL	(3*DICSIZ+((DICSIZ>>9)+1)*UCHAR_MAX)

#define MAXPATH		224
#define MAXCOMMENT	1024
#define MAXEXT		1024
#define MAX_PAT 	1024
#define MAX_EXCLD	128
#define MAX_ARC		512

#define N			4096
#define F			18
#define NIL 		N

#define UNKNOWNERR	0
#define INVCMDERR	1
#define MANYPATERR	2
#define NOARCNMERR	3
#define NOFNERR 	4
#define NOARCERR	5
#define RENAMEERR	6
#define MKTMPERR	7
#define DUPFNERR	8
#define TOOMANYERR	9
#define TOOLONGERR	10
#define NOFILEERR	11
#define MKFILEERR	12
#define RDERR		13
#define WTERR		14
#define MEMOVRERR	15
#define INVSWERR	16
#define CTRLBRK 	17
#define NOMATCHERR	18
#define COPYERR 	19
#define NOTLZH		20
#define OVERWT		21
#define MKDIR		22
#define MKDIRERR	23
#define CRCERR		24
#define RDONLY		25

#define EXTEND_GENERIC		0
#define EXTEND_UNIX			'U'
#define EXTEND_ATARI		'a'
#define EXTEND_MSDOS		'M'
#define EXTEND_MACOS		'm'
#define EXTEND_OS9			'9'
#define EXTEND_OS2			'2'
#define EXTEND_OS68K		'K'
#define EXTEND_OS386		'3'
#define EXTEND_HUMAN		'H'
#define EXTEND_CPM			'C'
#define EXTEND_FLEX			'F'
#define EXTEND_RUNSER		'R'
#define EXTEND_TOWNSOS		'T'
#define EXTEND_XOSK			'X'

#define	TEXT		(DICSIZ*2+MAXMATCH)
#define LEVEL		((DICSIZ+UCHAR_MAX+1+8)*sizeof(*level))
#define POSITION	((DICSIZ+UCHAR_MAX+1)*sizeof(*position))
#define PARENT		(DICSIZ*2*sizeof(*parent))
#define PREV		(DICSIZ*2*sizeof(*prev))
#define	NEXT		((MAX_HASH_VAL+1)*sizeof(*next))
#define ENCODE5		(TEXT+LEVEL+POSITION+PARENT+PREV+NEXT+128)

#ifndef SFX
# define LSON		((N+1)*sizeof(*lson))
# define RSON		((N+257)*sizeof(*rson))
# define DAD			((N+1)*sizeof(*dad))
# define ENCODE		(LSON+RSON+DAD+128)
#endif

#define FAULT		0
#define SUCCS		~FAULT

#define COM_ID		"-com-"

#define EXCLUDE		'!'
#define FILE_LIST	'@'
#define TEMPFILE	"LHA)(T)(."

#define MINHDR		20
#define HDRSIZ0		22
#define HDRSIZ1		25
#define HDRSIZ2		24

#define METHOD_TYPE_STRAGE 5


#endif
