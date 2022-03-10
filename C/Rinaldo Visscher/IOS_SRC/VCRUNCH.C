/*********************************************************************

					IOS - messagebase compacter
					
	Program : IOSmail
    Source  : free
	Author  : Rinaldo Visscher
	Date    : 1991
	
	Crunch the messagebase.
**********************************************************************/

#include <string.h>
#include <stdlib.h>
#include <ext.h>
#include <tos.h>
#include <time.h>
#include <stdio.h>
#include "portab.h"

#include "defs.h"
#include "ioslib.h"
#include "modules.h"
#include "lang.h"

#include "vars.h"

_filebuf	b_hdrrd;
_filebuf	b_hdrwr;
_filebuf	b_bodwr;
_filebuf	b_renum;
_filebuf	b_arbbs;

BOOLEAN check_deleted(VOID);

MLOCAL WORD	LedLstRd;
MLOCAL WORD	Deleted;
MLOCAL WORD	MSGSread;

LONG lmin(register LONG g1, register LONG g2)
{
	if (g1<g2) { return g1; }
	return g2;
} /* lmin */

WORD min(register WORD g1, register WORD g2)
{
	return g1<g2 ? g1 : g2;
} /* min */

LONG lmax(register LONG g1, register LONG g2)
{
	return g1>g2 ? g1 : g2;
} /* lmin */

VOID OpenLastRead(VOID)
{
	struct stat statbuf;
	BYTE tmp[80];
	
	if (doQbbslr) {					/* if we want to update .BBS	*/
		sprintf(tmp, "%sLASTREAD.BBS", Qbbslr);
		if (stat(tmp, &statbuf) < 0) {
			doQbbslr = FALSE;
		} else {
			g_users = (WORD)(statbuf.st_size / LBBSRECSIZE);
			if (g_users > 0) {
				if ((F_LSTBBS = Fopen(tmp, FO_RW)) < 0) {
					doQbbslr = FALSE;
				}
			}
		}
	}
} /* OpenLastRead */

VOID SetLastReadPtr (WORD area, WORD value)
{
	LONG pos;

	if (LRD==NULL) return;
	
	pos = (LONG) (sizeof(WORD) * (area+g_lsttype));
	
	/* to correct positition */
	fseek(LRD,pos,0);
	
	fwrite((BYTE *)&value, sizeof(WORD), 1,LRD);
	
	giveTIMEslice();
	
	if (/*area == mailarea &&*/ g_lsttype == 2) {
	
		/* this we do just if we are using LED's interpretation of the	*/
		/* lastread.ced file. See developmnt document					*/
		
		pos = (LONG) (sizeof(WORD) * 1);
		
		/* to correct positition */
		
		fseek(LRD,pos,0);
		fwrite((BYTE *)&value, sizeof(WORD), 1,LRD);
		giveTIMEslice();
	}
} /* SetLastReadPtr */

WORD GetLastReadPtr (WORD Area)
{
	LONG pos;
	WORD i,n;
	if (LRD==NULL) { return 0; }	/* File isn't open...				*/
	
	fseek(LRD,0L,2);
	
	/* if we have a typ 2 lastread.ced (LED) and this is the mailarea,	*/
	/* we have to read integer number 1 from the file. [0..??]			*/
	
	pos = g_lsttype != 2 ? (LONG) (sizeof(WORD) * (Area+g_lsttype)) : sizeof(WORD) * 1;
	if (pos>ftell(LRD)) {			/* to prevent reading byond eof		*/
		n = (WORD)(pos-ftell(LRD))/2;
		for (i=0; i<n; i++) {
			putc (0, LRD);
			putc (0, LRD);
			putc (0, LRD);
			putc (0, LRD);
			giveTIMEslice();
		}
		return 0;
	}
	fseek(LRD,pos,0);
	fread((BYTE *)&i, sizeof(WORD), 1, LRD);
	giveTIMEslice();
	return i;
} /* GetLastReadPtr */

WORD Aopen(VOID)
{
	struct stat f;
	WORD driveno;
		
	sprintf(oldmsg,"%s.MSG",Areapath[g_curarea]);
	sprintf(newmsg,"%s.MTP",Areapath[g_curarea]);
	sprintf(oldhdr,"%s.HDR",Areapath[g_curarea]);
	sprintf(newhdr,"%s.HTP",Areapath[g_curarea]);

	HDR = MSG = newHDR = newMSG = -1;	/* all files still closed		*/

	if ((HDR=Fopen(oldhdr, FO_RW))<0) {
		HDR=Fcreate(oldhdr, NOATTRIB);
	}
	if (!stat(oldhdr, &f)) {
		g_hdr_fsize = f.st_size;
	}
	if (!stat(oldmsg, &f)) {
		g_bod_fsize = f.st_size;
	}
	
	if (!g_bod_fsize && g_hdr_fsize) {
		return (AR_MSGERR);
	}
	
	giveTIMEslice();
	
	/* compute number of hdrs in the file...							*/	
	
	g_nrhdrs = (WORD) (g_hdr_fsize / sizeof(MSGHEADER));
	
	/* Here the free diskspace is checked, whenever there seems to be 	*/
	/* to little of it. Initially, g_dfree contains only zero's.		*/
	/* In this way, diskspace checking is performed as little as possib	*/
	
	if (g_hdr_fsize + g_bod_fsize >= g_dfree[driveno = Dgetdrv()]) {
		g_dfree[driveno] = diskfree(driveno);
		if (g_hdr_fsize + g_bod_fsize >= g_dfree[driveno]) {
			Fclose(HDR);
			return AR_DISKFREE;
		}
	}
	if (g_nrhdrs < Areamin[g_curarea]) {
		if (check_deleted() == FALSE) {
			Fclose(HDR);
			return AR_TOSMALL;
		}
		lseek(HDR, 0L, SEEK_SET);
		return AR_OK;
	}
	if (g_nrhdrs > MAXMSGS) {
		return AR_TOBIG;
	}

	if (HDR < 0) {
		log_line(6,Logmessage[M__ERROR_OPENING_AREA]);
		clean_mess();
		return AR_IOERR;
	}
	return AR_OK;
} /* Aopen */

BOOLEAN check_deleted() {
	MSGHEADER g_hdr;
	WORD i = g_nrhdrs;
	
	while( i > 0) {
		Fread(HDR, sizeof (MSGHEADER), &g_hdr);
		if ((g_hdr.flags & DELETED)) return (TRUE);
		i--;
	}
	return (FALSE);
}

VOID clean_mess(VOID)
{
	Fclose(HDR);
	Fclose(MSG);
	giveTIMEslice();
	Fclose(newHDR);
	Fclose(newMSG);
	giveTIMEslice();
	unlink(newhdr);
	unlink(newmsg);
	giveTIMEslice();
} /* clean_mess */

VOID buf_init(_filebuf *bp, LONG bsize, LONG itemsize)
{
	bp->size = bsize;						/* it's size in bytes	*/
	bp->start = (BYTE *) malloc(bp->size);	/* allocate space		*/
	bp->curpos = bp->start;					/* current pos = start	*/
	bp->level = 0;							/* no items in buffer	*/
	bp->maxitem = (bp->size/itemsize);		/* max no. items in buf	*/
	
	if (bp->start == NULL || bp->maxitem == 0) {
		log_line(6,Logmessage[M__CANT_CREATE_BUFFER],bsize,itemsize);
		terminate(2);
	}
} /* buf_init */

VOID buf_free(_filebuf *bp)
{
	free(bp->start);
	bp->start = NULL;
} /* buf_free */

VOID up_lastbbs(WORD areanr, WORD highest)
{
	_filebuf b_lstbbs;
	WORD leftrec = g_users;	/* total no. of records to process			*/
	WORD chunckcnt;			/* no. of records in current chunck			*/
	WORD amount;				/* to temp. store chunckcnt					*/
	WORD *changep;			/* used to traverse buffer and change		*/
	LONG size;				/* compute buffersize, to please Mes-Dos...	*/

	size = lmin(coreleft()-4096L, g_users*LBBSRECSIZE);
#if SMALLBUF 
	size = lmin(size, SMBUFSIZE);
#endif
	buf_init(&b_lstbbs, size, LBBSRECSIZE);

	Fseek(0L, F_LSTBBS, 0);	/* rewind to beginning of file				*/
	while (leftrec > 0) {
		amount = chunckcnt = (WORD)lmin(b_lstbbs.maxitem, leftrec);
		Fread(F_LSTBBS,amount * LBBSRECSIZE,b_lstbbs.start);
		giveTIMEslice();
		changep = (WORD *)b_lstbbs.start;
		changep = &changep[areanr];
		while (chunckcnt > 0) {
			if (*changep > 0 && *changep <= g_nrhdrs) {
				*changep = g_newnum[*changep];
			} else {
				*changep = highest;
			}
			/* Now this was a nasty thing to find...					*/
			changep += (LBBSRECSIZE / sizeof(WORD));
			--chunckcnt;
		}
		/* rewind relative to current pos 								*/
		Fseek(-amount * LBBSRECSIZE, F_LSTBBS, 1);
		/* and write back again processed records						*/
		Fwrite(F_LSTBBS, amount * LBBSRECSIZE, b_lstbbs.start);
		giveTIMEslice();
		leftrec -= amount;
	} /* while leftrec > 0 */

} /* up_lastbbs */

WORD msgok(MSGHEADER *hp, WORD area)
{
	register LONG age;

	giveTIMEslice();

	g_curtime = time (NULL);
	if (hp->flags & DELETED) {
		g_amhdr--;
		return (MSGDELETE);
	}
	
	if ((hp->flags & KILLSEND) && (hp->flags & SENT)) {
		g_amhdr--;
		return (MSGDELETE);
	}

	if (Areakeep[g_curarea] == KEEPMSGS) {
		g_amhdr--;
		return (MSGOK);
	}
		
	age = (g_curtime - hp->create) / SECSDAY;
	
	if (Areaday[area] < age) {
		g_amhdr--;
		return (MSGDELETE);
	}
	
	if (g_amhdr > maxmsgs) {
		g_amhdr --;
		return (MSGDELETE);
	}
	
	return (MSGOK);
} /* msgok */

WORD cleanEcho(VOID)
{
	WORD curdeleted;
	WORD resthdrs;
	WORD writhdrs;				/* totaal aantal weggeschreven hdrs 	*/
	WORD oldno		= 0;
	WORD newno		= 0;
	WORD error 		= FALSE;
	WORD hloop;
	WORD i;						/* loopvar for removing 0's 			*/
	WORD curmax;					/* hold highest log_line number			*/
	WORD from_hdr;
	LONG readfrom	= FLAG;
	LONG readto		= FLAG;
	LONG amount;
	LONG spaceleft;
	LONG onepart;
	LONG size;			/* to compute buffer size into...				*/
	MSGHEADER *chp;
	MSGHEADER *whp;
	
	if (!g_hdr_fsize) return (0); 
	
	g_amhdr = g_nrhdrs;
	
	g_newnum = (WORD *)calloc(g_nrhdrs, sizeof(WORD));

	onepart	= ((coreleft() / TOTPART) / 2048 * 2048);	/* dividable by 2K		*/ 
	
	size = lmin(onepart * BODWRPART, g_bod_fsize);
#if SMALLBUF
	size = lmin(size,SMBUFSIZE);
#endif
	if (!size) return (0);
	
	buf_init(&b_bodwr, size, 1L);

	/* onepart is recomputed, because maybe the above SMALLBUF thin
	   caused the biggest buffer b_bodwr to be truncated, in wich case
	   there is aditional memory for the hdr buffers. Get it?			*/
	   
	onepart	= ((coreleft() / TOTPART) / 2048 * 2048);	/* dividable by 2K		*/ 
	
	size = lmin(onepart * HDRRDPART, g_hdr_fsize);
#if SMALLBUF
	size = lmin(size, SMBUFSIZE);
#endif
	buf_init(&b_hdrrd, size, sizeof(MSGHEADER));
	
	size = lmin(onepart * HDRWRPART, g_hdr_fsize);
#if SMALLBUF
	size = lmin(size,SMBUFSIZE);
#endif
	buf_init(&b_hdrwr,size,sizeof(MSGHEADER));

	g_offset = 0L;
	whp = (MSGHEADER *)(b_hdrwr.start);
	resthdrs = g_nrhdrs;	/* yet to process, g_nrhdrs set in Aopen	*/
	writhdrs = 0;			/* none written yet							*/
	
	while (resthdrs > 0) {
		if (b_hdrrd.level == 0) {	/* no hdrs left in input buffer		*/
			b_hdrrd.level = min((WORD)b_hdrrd.maxitem,resthdrs);
			Fread(HDR,b_hdrrd.level*sizeof(MSGHEADER),b_hdrrd.start);
			giveTIMEslice();
			chp = (MSGHEADER *)(b_hdrrd.start);
		}
		
		/* At this point, chp points to the hdr next to be processed in memory.	*/
		
		--resthdrs;				/* processing this one					*/
		--b_hdrrd.level;		/* this is where it came from			*/
		
		if (msgok(chp,g_curarea)) {
			if (b_hdrwr.level == b_hdrwr.maxitem) { /* hdr output full	*/
				if (newHDR < 0 &&
				   (newHDR=Fcreate(newhdr, NOATTRIB)) < 0) {
					log_line(6,Logmessage[M__CANT_OPEN_HEADER],newhdr);
					goto CE_ERROR;	/* at the end of this function		*/
				}
				writhdrs += (WORD)b_hdrwr.level;	/* look at renumbering!	*/
				Fwrite(newHDR,b_hdrwr.level*sizeof(MSGHEADER),b_hdrwr.start);
				giveTIMEslice();
				whp = (MSGHEADER *)(b_hdrwr.start);
				b_hdrwr.level = 0;	/* empty now	*/
			} else {
				if(b_hdrwr.level > b_hdrwr.maxitem) {
					log_line(6,Logmessage[M__HEADER_OVERFLOW]);
				
					clean_mess();
					terminate(10);
				}
			}
			
			/* now we are sure there is space in the output buffer		*/
			
			memcpy(whp,chp,sizeof(MSGHEADER));		/* copy it			*/
			whp->Mstart = g_offset;					/* in new file		*/
			++whp;				/* next hdr copied here	...				*/
			++b_hdrwr.level;	/* and another 1 added to outputbuffer	*/
			g_offset += chp->size;
			if (readfrom == FLAG) {	/* only the first time per area		*/
				readfrom = chp->Mstart;
				readto = chp->Mstart + chp->size;	/* TO, not including!	*/
			} else {
				if (readto == chp->Mstart) {
					readto += chp->size;	/* for a continues chunk	*/
				} else {
					if(MSG < 0 && 
					  (MSG = Fopen(oldmsg, FO_RW)) < 0 &&
					  (MSG = Fcreate(oldmsg, NOATTRIB)) < 0) {
						log_line(6,Logmessage[M__CANT_OPEN_HEADER],newhdr);
						goto CE_ERROR;	/* at the end of this function	*/
					}
					Fseek(readfrom,MSG,0);
					giveTIMEslice();
					
					/* this while reads the from-to chunck of the file,	*/
					/* and only writes out the buffer if verry little 	*/
					/* free space remains in it. So it is possible that	*/
					/* this while reads only 1 log_line body, and writes	*/
					/* nothing at all. body remains in mem buffer		*/
					
					while (readfrom != readto) {
					
						/* is it possible to compare these things????	*/
						
						spaceleft = b_bodwr.size - (b_bodwr.curpos - b_bodwr.start);
						amount = lmin(spaceleft,readto - readfrom);
						Fread(MSG,amount,b_bodwr.curpos);
						giveTIMEslice();
						b_bodwr.curpos += amount;
						readfrom += amount;
						spaceleft = b_bodwr.size - (b_bodwr.curpos - b_bodwr.start);
						if (spaceleft < 10*1024 ) {
							if(newMSG < 0 &&
 							  (newMSG = Fcreate(newmsg, NOATTRIB)) < 0) {
								log_line(6,Logmessage[M__CANT_OPEN_AREA]
											,newmsg);
								goto CE_ERROR;	/* at the end of this function	*/
							}
							Fwrite(newMSG,b_bodwr.curpos - b_bodwr.start,b_bodwr.start);
							giveTIMEslice();
							b_bodwr.curpos = b_bodwr.start;
						}
					}
					readfrom = chp->Mstart;
					readto = readfrom + chp->size;				
				}
			}
			g_newnum[oldno] = newno;	/* for renumbering	*/
			++newno;	
		} /* if msgok */
		++oldno;
		++chp;

		if (MSGSread <= LedLstRd) {
			Deleted ++;
			MSGSread++;
		}

	} /* while resthdrs > 0	*/

	if ((curdeleted = (oldno -newno)) > 0 && !error) {
	
		/* we only need to write buffers to files if there has been a	*/
		/* change in the log_line base.									*/
		
		if (MSG < 0 && 
		   (MSG = Fopen(oldmsg, FO_RW)) < 0 &&
		   ((MSG = Fcreate(oldmsg, NOATTRIB)) < 0)) {
			log_line(6,Logmessage[M__CANT_OPEN_HEADER],newhdr);
			goto CE_ERROR;	/* at the end of this function	*/
		}
		giveTIMEslice();
		
		if (newMSG < 0 &&
	 	   ((newMSG = Fcreate(newmsg, NOATTRIB)) < 0)) {
			log_line(6,Logmessage[M__CANT_OPEN_AREA],newmsg);
			goto CE_ERROR;	/* at the end of this function	*/
		}
		Fseek(readfrom,MSG,0);
		while (readfrom != readto) {
			/* is it possible to compare these things????	*/
			spaceleft = b_bodwr.size - (b_bodwr.curpos - b_bodwr.start);
			amount = lmin(spaceleft,readto - readfrom);
			Fread(MSG,amount,b_bodwr.curpos);
			giveTIMEslice();
			b_bodwr.curpos += amount;
			readfrom += amount;
			if (b_bodwr.curpos != b_bodwr.start) {
				Fwrite(newMSG,b_bodwr.curpos - b_bodwr.start,b_bodwr.start);
				giveTIMEslice();
				b_bodwr.curpos = b_bodwr.start;
			}
		}
		if (b_bodwr.curpos != b_bodwr.start) {
			Fwrite(newMSG,b_bodwr.curpos - b_bodwr.start,b_bodwr.start);
			giveTIMEslice();
			b_bodwr.curpos = b_bodwr.start;
		}
		
		/* and now... for the renumbering!								*/	
		/* First we steal the memory from the no longer used buffer		*/
		/* b_bodwr, by first freeing WORD, and then it is reclaimed by	*/
		/* buf_init.													*/ 
		
		size = b_bodwr.size;
		buf_free(&b_bodwr);
		
		if (!size) return (0);
		
		buf_init(&b_renum,size,1L);
		
		/* First we handle the hdrs already written to the newHDR file	*/
		/* (if any exist)												*/
		
		if (writhdrs > 0) {
			Fseek(0L,newHDR,0);		/* to begin of file					*/
			from_hdr = 0;
			while (from_hdr < writhdrs) {
				amount = lmin(writhdrs - from_hdr, b_renum.maxitem);
				Fread(newHDR,amount * sizeof(MSGHEADER),b_renum.start);
				giveTIMEslice();
				chp = (MSGHEADER *)b_renum.start;
				for (hloop = (WORD)amount; hloop > 0; --hloop) {
					if (chp->parent != 0) {
						chp->parent = g_newnum[chp->parent];
					}
					++chp;
				}
				Fseek(-amount * sizeof(MSGHEADER),newHDR,1);
				Fwrite(newHDR,amount * sizeof(MSGHEADER),b_renum.start);
				giveTIMEslice();
				from_hdr += (WORD)amount;
			}
		}
		
		/* and then the hdrs in the original hdr output buffer			*/
		
		if (b_hdrwr.level >= 0) { /* buffer contains some hdrs */
			if (newHDR < 0 &&
			   (newHDR=Fcreate(newhdr, NOATTRIB)) < 0) {
				log_line(6,Logmessage[M__CANT_OPEN_HEADER],newhdr);
				goto CE_ERROR;	/* at the end of this function	*/
			}
			chp = (MSGHEADER *)b_hdrwr.start;
			for (hloop = (WORD)b_hdrwr.level; hloop > 0; --hloop) {
				if (chp->parent != 0) {
					chp->parent = g_newnum[chp->parent];
				}
				++chp;
			}
			Fwrite(newHDR,b_hdrwr.level*sizeof(MSGHEADER),b_hdrwr.start);
			giveTIMEslice();

			/* no need to reinit .level or  whp...		*/
		}
		buf_free(&b_renum);		/* This frees also the memory used for	*/
		buf_free(&b_hdrwr);		/* the actual buffer. We need it later	*/
		buf_free(&b_hdrrd);		/* in up_lastbbs						*/
		
		/* first we process the g_newnum array, to get some 0's out.		*/
		/* the next piece of code changes the row 0 0 1 0 2 3 4 0 0 5 6 0	*/
		/* into the row                           0 0 1 1 2 3 4 4 4 5 6 6	*/
		/* so that if a log_line is deleted you get the last valid log_line	*/
		/* before the deleted one as the log_line you last read.			*/
		
		for (i=curmax=0; i<g_nrhdrs; ++i) {
			if (g_newnum[i] == 0) {
				g_newnum[i] = curmax;
			} else {
				curmax = g_newnum[i];
			}
		}
		SetLastReadPtr(g_curarea,g_newnum[GetLastReadPtr(g_curarea)]);
		if (doQbbslr) {
			up_lastbbs(g_curarea,curmax);
		}
	} else {
		buf_free(&b_bodwr);	
		buf_free(&b_hdrwr);	
		buf_free(&b_hdrrd);	
	}
	free(g_newnum);
	return curdeleted ;	/* if 0 messages are deleted, original files	*/
						/* are kept by Aclose...						*/
						/* This is the normal end of the function!!!	*/
						
CE_ERROR:	/* A file io error has occured. This can happen at 6 		*/
			/* clearly marked places *in*this*function*. A goto is used */
			/* to bail out in those rare cases...						*/
	buf_free(&b_bodwr);	
	buf_free(&b_hdrwr);	
	buf_free(&b_hdrrd);	
	free(g_newnum);
	return 0;	/* causes original files left untouched, files will be	*/						
				/* closed by Aclose in a minute...						*/
} /* cleanEcho */

VOID Aclose(WORD changed)
{
	WORD ok;
	ok = (Fclose(newMSG) == 0);
	ok &= (Fclose(newHDR) == 0);
	giveTIMEslice();

	Fclose(HDR);
	Fclose(MSG);
	giveTIMEslice();

	if (!changed) { /* if no messages deleted, files not changed, so...	*/
		unlink(newmsg);
		unlink(newhdr);
		giveTIMEslice();
		return;
	}
	if (ok)	{ /* ok means files are allright, wouldn't you think so?	*/
		unlink(oldmsg);
		rename(newmsg,oldmsg);
		giveTIMEslice();
		unlink(oldhdr);
		rename(newhdr,oldhdr);
		giveTIMEslice();
	} else {
		unlink(newmsg);
		giveTIMEslice();
		unlink(newhdr);
		log_line(6,Logmessage[M__CANT_CLOSE_MSG]);
	}
	return;
} /* Aclose */

VOID deinitialize(VOID)
{
	if (SIZE != NULL) { fclose(SIZE); }
	if (LRD != NULL) { fclose(LRD); }
	giveTIMEslice();
	if (F_LSTBBS >= 0) {
		Fclose(F_LSTBBS);
		giveTIMEslice();
	}
	if (doled) {
		if (!doscanmail)
			write_lednew();
	}
} /* deinitialize */

LONG diskfree(WORD drvno)
{
	DISKINFO diskbuf;

	Dfree(&diskbuf,drvno+1);
	giveTIMEslice();
	return (diskbuf.b_free*diskbuf.b_clsiz*diskbuf.b_secsiz);
} /* diskfree */

VOID compactMSGbase(WORD mode)
{
	WORD areadeleted, haveareas, start, i;
	BOOLEAN Ok = FALSE;
	
	if (doimport && defcrunch == AFTERIMPORT) Ok = TRUE;
	if (doscanmail && defcrunch == AFTERSCAN) Ok = TRUE;
	if (defcrunch == CRUNCHALWAYS) Ok = TRUE;
	if (mode == CRUNCHSPECIALS) Ok = TRUE;
	
	if (Ok == FALSE) return;
	
	log_line(6,Logmessage[M__COMPACTING]);

	OpenLastRead();

	haveareas = msgareas;
	
	if (mode == CRUNCHSPECIALS)
		start = msgareas;
	else
		start = 0;
		
	if (strlen(mailarea)) {
		Areaname[haveareas] = strdup("FidoNETMAIL");
		Areapath[haveareas] = mailarea;
		Areamin [haveareas] = mailmin;
		Areakeep[haveareas] = mailkeep;
		Areaday[haveareas++] = maildays;
	}
	
	if (strlen(trasharea)) {
		Areaname[haveareas] = strdup ("TRASHAREA");
		Areapath[haveareas] = trasharea;
		Areamin [haveareas] = trashmin;
		Areakeep[haveareas] = trashkeep;
		Areaday[haveareas++] = trashdays;
	}
	
	if (strlen(privatebox)) {
		Areaname[haveareas] = strdup("PRIVATEMAIL");
		Areapath[haveareas] = privatebox;
		Areamin [haveareas] = pvtboxmin;
		Areakeep[haveareas] = pvtkeep;
		Areaday[haveareas++] = pvtboxdays;
	}

	if (strlen(dupearea)) {
		Areaname[haveareas] = strdup("DUPE_AREA");
		Areapath[haveareas] = dupearea;
		Areamin [haveareas] = dupemin;
		Areakeep[haveareas] = dupekeep;
		Areaday[haveareas++] = dupedays;
	}
	
	for (g_curarea = start; g_curarea < haveareas; g_curarea++) {
		if (Dareas[g_curarea] == 1) continue;

		Deleted = LedLstRd = MSGSread = 0;
		
		if (nled) {
			for (i = 0;	i < nled ; i++) {
				if (!stricmp (Areaname [ g_curarea], "privatemail")) {
					if (!stricmp (Lareaname[i], "privateboxarea") ||
						!strnicmp (Lareaname[i], "privatemail", 11)) {
						
						LedLstRd = Lledmsgs[i];
						break;
					}
				}
				
				if (!stricmp (Areaname [g_curarea], Lareaname [i])) {
					LedLstRd = Lledmsgs[i];
					break;
				}
			}
		}
		
		hprintf (S_AREA, "%s", Areaname[g_curarea]);

		switch (Aopen()) {
		case AR_OK		  :	/* printf("%4d",g_nrhdrs); */
							
							areadeleted = cleanEcho();	/* delete messages			*/
							g_totdel += areadeleted;
						
							if (doled) Update_LED(Deleted);
							
							hprintf (S_DELETED, "%d", g_totdel);
							
							g_totleft += g_nrhdrs - areadeleted;
							if (areadeleted != 0) {
								log_line(3,Logmessage[M__MSGS_DELETED],
								Areaname[g_curarea],areadeleted);
							} else {
								if (g_nrhdrs)
									log_line(3,Logmessage[M__NOTHING_DELETED],
									Areaname[g_curarea]);
								else
									log_line(3,Logmessage[M__EMPTY_AREA],
									Areaname[g_curarea]);
							}
							
							Aclose(areadeleted != 0);	/* close the current area   */
								
							break;
		case AR_TOSMALL	  :	if (g_nrhdrs > 0) {
								g_totleft += g_nrhdrs;
								log_line(3,Logmessage[M__MINIMUM_MSGS],
										Areaname[g_curarea],g_nrhdrs,Areamin[g_curarea]);
							} else {
								log_line(3,Logmessage[M__EMPTY_AREA],
								Areaname[g_curarea]);
							}
							break;
		case AR_TOBIG	  :	g_totleft += g_nrhdrs;
							log_line(4,Logmessage[M__MAXIMUM_MSGS],
									Areaname[g_curarea],g_nrhdrs,MAXMSGS);
							break;
		case AR_IOERR	  :	log_line(6,Logmessage[M__FILE_IO_ERROR]);
							break;
		case AR_DISKFREE  :	g_totleft += g_nrhdrs;
							log_line(6,Logmessage[M__NO_DISKSPACE],g_nrhdrs);
							break;
		case AR_MSGERR	  : log_line(6, Logmessage[M__BODY_ERROR]);
							break;
		default			  :	log_line(6,Logmessage[M__COMPILER_ERROR]);
		}
	}
	
	if(g_totleft || g_totdel)
		log_line(3,Logmessage[M__MSGS_RESUMEND], g_totdel, g_totleft);

	deinitialize();
}

VOID Update_LED(WORD deleted) {
	WORD i;
	
	if (!deleted) return;
	
	for (i=0; i < nled; i++) {
		if (!stricmp (Areaname [ g_curarea], "privatemail")) {
			if (!stricmp (Lareaname[i], "privateboxarea") ||
				!strnicmp (Lareaname[i], "privatemail", 11)) {
				
				Lledmsgs[i] -= deleted;
				break;
			}
		}

		if (!stricmp(Lareaname[i], Areaname[g_curarea])) {
			Lledmsgs[i] -= deleted;
			if (Lledmsgs[i] < 0) Lledmsgs[i] = 0;
			break;
		}
	}
}
