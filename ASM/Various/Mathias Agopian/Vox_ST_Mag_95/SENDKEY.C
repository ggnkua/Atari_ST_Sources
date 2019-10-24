/* ecrit un mot dans le buffer clavier */

#include <tos.h>


void SendKey(int scan,int ascii)
{
	IOREC *ikbd=Iorec(1);
	(ikbd->ibuftl)+=4;
	if ((ikbd->ibuftl)>=(ikbd->ibufsiz))
		ikbd->ibuftl=0;
	*(long *)((long)(ikbd->ibuf)+(long)(ikbd->ibuftl))=((long)scan<<16)|ascii;
}