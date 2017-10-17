/*******************************************************************************
 *	Devbuf.c	Device track buffering system
 *******************************************************************************
 */

# include	"../../include/buf.h"
# include	"devbuf.h"

struct	Dbuf devbuf[NODEVBUFS];
struct	Dbuf *dbfirst;

initdevbuf(){
	dbfirst = devbuf;
}

struct Dbuf *
checkdevbuf(buf)
struct	buf *buf;
{
	struct	Dbuf *dbuf;

	dbuf = dbfirst;
	do{
		if(INBUF(dbuf, buf)) return dbuf;
	} while(dbuf = dbuf->next);
	return 0;
}

fromdevbuf(buf)
struct	buf *buf;
{
	struct	Dbuf *dbuf;

	dbuf = dbfirst;
	do{
		if(INBUF(dbuf, buf)){
			bytecp(&dbuf->data[SECTSIZE * (buf->b_bno - dbuf->bstart)],
					buf->b_buf, SECTSIZE);
			if(dbuf != dbfirst){
				if(dbuf->prev) dbuf->prev->next = dbuf->next;
				if(dbuf->next) dbuf->next->prev = dbuf->prev;
				dbuf->next = dbfirst;
				dbfirst = dbuf;
			}
			return 0;
		}
	} while(dbuf = dbuf->next);
	return -1;
}

struct Dbuf *
getdevbuf(){
	struct	Dbuf *dbuf, *dbufl;
	int	bno;

	/* Gets last block */
	dbufl = dbfirst;
	while(dbufl->next) dbufl = dbufl->next;

	/* See if free block exists */
	dbuf = devbuf;
	for(bno = 0; bno < NODEVBUFS; bno++){
		if(!dbuf->flags){
			/* Checks if dbuf is first one if not link it in */
			if(dbuf != dbfirst){
				dbuf->prev = dbufl;
				dbufl->next = dbuf;
				dbuf->next = 0;
			}
			break;
		}
		dbuf++;
	}

	/* If no free blocks get last one */
	if(bno == NODEVBUFS){
		dbuf = dbufl;
	}
	dbuf->flags = AVAILABLE;
	
	return dbuf;
}
