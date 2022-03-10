#include <stdio.h>
#include <string.h>

/*
**	Messageheader in local base
*/

typedef char BYTE;
typedef long LONG;
typedef unsigned int UWORD;

typedef struct
{
	char	from[36],
			to[36],
			topic[72],
			time[20];
	
	long	create,
			Mstart;
	
	UWORD	up,				/* unused					*/
			parent,
			flags,
			mailer[8],
			size,
			reads,
			cost,			/* Cost of message * 100	*/
			
			Ozone,
			Onet,
			Onode,
			Opoint,
			
			Dzone,
			Dnet,
			Dnode,
			Dpoint;
} MSGHEADER;

FILE *fp;

void main() {
	MSGHEADER Hdr;
	
	strcpy(Hdr.from , "test");
	strcpy(Hdr.to   , "test");
	strcpy(Hdr.topic , "test");
	Hdr.size = 0L;
	
	fp = fopen ("d:\msgs\200.hdr", "w");
	
	if (fp) {
		fwrite (&Hdr, sizeof (MSGHEADER), 1, fp);
		fclose (fp);
	}
}
