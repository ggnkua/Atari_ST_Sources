/*  sioque.c - queue management for sio drivers				*/

#include	"portab.h"
#include	"io.h"
#include	"sio.h"

/*
**  snq -
**	store a char in the que
*/

VOID	snq( ch , qptr )
	QSTRUCT	*qptr;
	BYTE ch;
{
    qptr -> data[(qptr -> rear)++] = ch ;

    if ((qptr -> rear) == QSIZE)
	qptr -> rear = 0;

    qptr -> qcnt++ ;
}

/*
**  sdq -
**	fetch a char from the queue
*/

BYTE	sdq(qptr)
	QSTRUCT	*qptr;
{
    WORD q2;

    qptr -> qcnt-- ;
    q2 = qptr -> front++ ;

    if ((qptr -> front) == QSIZE)
	 qptr -> front = 0;

    return(qptr -> data[q2]);
}

