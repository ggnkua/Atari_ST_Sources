/*******************************************************************************
 *	Fdc.c	High level floppy disk driver
 *******************************************************************************
 *
 * Handler for Codata Format 5.25in Floppy Disks
 * as well as rpa type 5.25in disks (ie 10 sect
 * per surface vs 9
 *	the codata type floppy will be read from minor device
 *	numbers 0,1,2,3 and the ibm double sided 40 track will be assumed
 *	for minor device nos 4,5,6,7
 *	the minor device values of 4,5,6,7 are only used in this 
 *	file, values of 0 1 2 3 will be passed on to the select
 *	routine.
 * Robin Alston 5.85
 */

#include	"buffer.h"
#include	"flformat.h"
#include 	"numbers.h"
#include	<errno.h>
#include	"../../include/buf.h"
#include	<sys/ioctl.h>
#define		LAST_TRACK	(79)

int	nofdopen;		/* Total Number of devices open */
struct drive_info fdstatus[4];
struct fd_buffer fdb[NO_BUFS];	/* the track buffer */
short P_TRK, fdcerror;
struct buf tmpb;		/* used in the ioctl and full track buffering */
int	dtype;

/*
 *	this implements at the moment a simple track buffering scheme
 *	of NO_BUFS buffers. Buffers are write thru ie a write of one
 *	block will update the relevant buffer (if one exists) and
 *	will allways write to the disk as well
 */

fdopen(drive){

	/* If first open initialise bits */
	if(!nofdopen++){
		/* Init the buffering and device handler */
		ibuffers();
		fdcinit();
	}
	if(!fdstatus[drive & 0x3].d_nopen++){

		/* Sets drive type */
		if(drive & 0x04){
			fdstatus[drive & 0x3].d_type = DTYPE40 | DTYPEINTEL;
		}
		else fdstatus[drive & 0x3].d_type = DTYPE80;

		if(select(drive & 0x3) == ERROR){
			printf("Deverr: drive %d unavailiable\n", drive);
			return ERROR;
		}

		restor(0);
		fdstatus[drive & 0x3].d_curtrk = 0;
	}

	return NOERROR;
}

fdclose(drive){

	register short p = 0;

	nofdopen--;
	fdstatus[drive & 0x3].d_nopen--;

	if(fdstatus[drive & 0x3].d_nopen <= 0){
		fdstatus[drive & 0x3].d_nopen = 0;
		/* Release all system buffers */
		sync();
		while(p < NO_BUFS){
			/* release all the allocated buffers */
			if(fdb[p].d_minor == drive){
				/* When a real buffering scheme is worked
				 * out a buffer flush will go in here
				 */
#ifdef FULLBUFFERING 
				if(fdb[p].type & WRITTEN)
					/* Attempt to flush a dirty buffer
					 */
					if(flush1(p) == ERROR)
						/* Oh well it was a good try
						 * for the mo leave its state
						 * alone
						 */
						return ERROR;
#endif FULLBUFFERING 
				fdb[p].type = AVAILABLE;
				/* make it the oldest buffer */
				oldest(fdb[p].age);
			}
			p++;
		}
	}
	return NOERROR;
}

ibuffers(){
	/*
		init the buffering scheme
	 */

	register short p = 0;

	while(p < NO_BUFS){
		fdb[p].age = p;
		fdb[p++].type = AVAILABLE;
	}
}

fdstrat(buf)
struct buf *buf;
{
	register short blk, dev, p;
	int	err;

	blk = buf->b_bno;
	dev = buf->b_dev;

	/* verify track number and minor device no */

	if(blk > CD_B_MAX){
		deverr("block no. too large", 1, buf);
		buf->b_flags |= ABORT;
		return error(ENXIO);
	}

	if((dev < 0) || (dev > 7)){
		deverr("minor dev out of range", 1, buf);
		buf->b_flags |= ABORT;
		return error(ENXIO);
	}

	dtype = fdstatus[buf->b_dev & 0x3].d_type;

	/* Check if write if so put straight to disk */
	if(buf->b_flags & WRITE)
		err = write_1(buf);	/* copy to disk */

	else
		err = read_1(buf);	/* go get a buffer */

	/* Test if error occured if so report it and return -1 */
	if(err == ERROR){
		buf->b_flags |= ABORT;
		return error(EIO);
	}
	else return err;
}

write_1(b)
struct buf *b;{
	/*
		If no full buffering then
		write a buffer to the disk AND write thru the
		disk buffer if it has one for the relevant track
		If full buffering write into already existing buffer
		or first get one from a disk
	 */

	register short p;

#ifdef TFLOPPY
printf("write_1: ");
printf("block: %d\n\r",b->b_bno);
#endif TFLOPPY

#ifdef FULLBUFFERING 
	/*
		may have to read the track then do a thru_write
	 */

	if(((p = inbuffers(b)) == NOTFOUND) && ((getfdisk(b,"pre-read") == ERROR) || ((p = inbuffers(b)) == NOTFOUND)))
		/*
			problems
		 */
		return ERROR;
	thru_write(b,p);
	return NOERROR;
#else
	if((p = inbuffers(b)) != NOTFOUND)
		thru_write(b,p);
	return puttdisk(b);
#endif FULLBUFFERING 
}


read_1(b)
struct buf *b;{
	/*
		attempt to obtain a buffer from track buffering,
		if failed then try and get a track from a disk itself
	 */

	register short p, offset;

	if(((p = inbuffers(b)) == NOTFOUND) && ((getfdisk(b,"read") == ERROR) || ((p = inbuffers(b)) == NOTFOUND))){
		b->b_flags |= ABORT;
		return ERROR;
	}

	offset = (b->b_bno - fdb[p].bstart) * SIZE;
#ifdef TFLOPPY
printf("read_1: block %d buffer %d offset %x\n\r",b->b_bno,p,offset);
#endif TFLOPPY
	bytecp((fdb[p].fdata + offset),b->b_buf,SIZE);
	return NOERROR;
}


inbuffers(b)
struct buf *b;{
	/*
	 * tells whether the buffer b is in the disk buffering (fdb)
	 * if so returns in which one eles returns NOTFOUND
	 */

	register short p = 0;

	while(p < NO_BUFS){
		/* wander thru the whole set of buffers */
		if((fdb[p].type != AVAILABLE) && INBUF(fdb[p],b)){
			/* found it, make it youngest too */
#ifdef TFLOPPY
printf("Found %d in buffer %d\n\r",b->b_bno,p);
#endif TFLOPPY
			youngest(fdb[p].age);
			return p;
		}
		else
			p++;
	}

#ifdef TFLOPPY
printf("%d not found in buffers\n\r",b->b_bno);
#endif TFLOPPY
	return NOTFOUND;
}

thru_write(b,p)
struct buf *b;
short p;{
	/*
	 *	writes the buffer b into the buffer fdb[p]
	 */

	register short offset;


	offset = (b->b_bno - fdb[p].bstart) * SIZE;
#ifdef TFLOPPY
printf("Write thru: block %d buffer %d offset %x\n\r",b->b_bno,p,offset);
#endif TFLOPPY
	bytecp(b->b_buf,fdb[p].fdata + offset,SIZE);	/* copy the buf */

	fdb[p].type |= WRITTEN;
	youngest(fdb[p].age);	/* make this buffer the youngest */
}

diskset(b,trackn)
struct buf *b;
short trackn;
{
	/*
		select disk side etc using info in b
		returns which sector this buffer should
		be on this disk track and also sets the
		global P_TRK to how many sectors per
		track surface there are on this device
		if trackn <> NOTATRACK then the seek will 
		be to that track else will seek to where
		the block should be
	 */

	register short p_trk, trk, blk;
	short sideno, drive, reps;
	struct drive_info *fds;
	int	rtrack;
	char	twostep;

	drive = b->b_dev;
	blk = b->b_bno;

	switch(drive){

	case 0: case 1: case 2: case 3:
		/* codata type */
		p_trk = CD_PERTRK;
		break;

	case 4: case 5: case 6: case 7:
		/* codata type */
		p_trk = CD_PERTRK;
		break;
	}

	trk = rtrack = (trackn == NOTATRACK)? (blk / p_trk) : trackn;

	/* Checks if single sided */
	if(!(fdstatus[drive & 0x3].d_type & DTYPESS)){
		sideno = (trk & 1)? ONE : ZERO;
		trk /= 2;
		rtrack /= 2;
	}
	else{
		sideno = ZERO;
	}

	/* Checks if 40 track */
	if(fdstatus[drive & 0x3].d_type & DTYPE40){
		trk *= 2;
		twostep = 1;
	}
	else twostep = 0;

#ifdef TFLOPPY
printf("diskset: blk %d, trk %d, rtrk %d, side %d, twostep %d\n",blk,trk,rtrack,sideno,twostep);
#endif TFLOPPY

	if(trk > LAST_TRACK){
		deverr("track number too big",1,b);
		b->b_flags |= ABORT;
		return ERROR;
	}

	/* select drive */
	if (select(drive & 0x3) == ERROR){
		deverr("drive not ready", 1, b);
		b->b_flags |= ABORT;
		return ERROR;
	}

	/* find current position */
	fds = &fdstatus[drive & 0x3];
	if ((set_track(fds->d_curtrk)) != trk){
		if(reps = doseek(trk, twostep)) {
			if (reps >= 10)
				b->b_flags |= ABORT;

			deverr("seek", reps, b);

			if (reps >= 10)
				return ERROR;
		}

		fds->d_curtrk = trk;
	}

	side(sideno);	/* get correct side */
	P_TRK = p_trk;
	set_track(rtrack);		/* Sets real track required 40/80 */
	return ((blk % p_trk) + 1);	/* return the sector number */
}


getfdisk(b,errmsg)
struct buf *b;
char *errmsg;
{
	short p, reps;

	p = oldest(NO_BUFS - 1);	/* get LRU buffer */

#ifdef FULLBUFFERING 
	if(fdb[p].type & WRITTEN)
		/*
			attempt to write out a dirty buffer
		 */
		if(flush1(p) == ERROR)
			/*
				Oh heck, what do we do now, anything
				we do might f..k up the buffering scheme
				so for the mo do nowt.
			 */
			return ERROR;
		else
			/*
				mark this buffer as available, so no
				matter what happens it will be available
				in the worst case
			 */
			fdb[p].type = AVAILABLE;
#endif FULLBUFFERING 

	if(diskset(b,NOTATRACK) == ERROR)	/* sets the side. track and drive */
		return ERROR;

	reps = tr_read(fdb[p].fdata, P_TRK);	/* read the whole track */


	/* errors? */
	if (reps) {

		deverr(errmsg, reps, b);

		if (reps >= 10){
			b->b_flags |= ABORT;
			fdb[p].type = AVAILABLE;
			return ERROR;
		}
	}

	/* no fatal errors */
	youngest(fdb[p].age);	/* make this one the youngest */
	fdb[p].bstart = (b->b_bno / P_TRK) * P_TRK;
	fdb[p].bend = fdb[p].bstart + P_TRK - 1;
	fdb[p].type = READABLE;
	fdb[p].d_minor = b->b_dev;
	b->b_flags &= ~WRITE;
#ifdef TFLOPPY
printf("Read: block %d, buffer %d, start %d end %d\n\r",b->b_bno,p,fdb[p].bstart,fdb[p].bend);
#endif TFLOPPY
	return NOERROR;
}


puttdisk(b)
struct buf *b;{
	/*
		write the buffer to the disk
	 */

	register short p, reps, sect;

	if((sect = diskset(b,NOTATRACK)) == ERROR)
		return ERROR;

	reps = se_write(b->b_buf,sect);	/*  write the sector out */


	/* errors? */
	if (reps) {

		deverr("write", reps, b);

		if (reps >= 10){
			b->b_flags |= ABORT;
			return ERROR;
		}
	}

	/* no fatal errors */
	b->b_flags &= ~WRITE;
	return NOERROR;
}

se_write(b,s)
char *b;
short s;{
	/*
		writes one sector from b to sect s
		assumes that the disk side, track
		already correct
	 */

	register short count = 0,err;

	while(count < 10){
		if(err = write_sect(b,s,1,0)){
			fdcerror = err;
			count++;
		}
		else
			break;
	}

	return count;
}

tr_read(buffer,nsects)
char	*buffer;
short	nsects;
{
	/*
	 * reads a complete track starting at sector 1
	 * for nsects, assumes that drive selection and
	 * side selection are already performed
	 */
	short	cerr;

#ifdef EXBUF
	register short count = 0, sect, err = 0;
	char addr[20];

	while(count < 10){
		if(cerr = read_addr(addr)){
			err = cerr;
printf("Deverr: Read address error %x\n",cerr);
			count++;
		}
		else{
			sect = addr[2] + 1;		/* sector number */
			sect = (sect > nsects)? sect - nsects:sect;
			cerr = read_sect(buffer + (SIZE * (sect - 1)),sect,nsects - sect + 1,0);
			if(sect != 1)
				cerr |= read_sect(buffer,1,sect - 1,0);
			if(cerr){
				err = cerr;
				count++;
			}
			else
				break;
		}
	}
#else
	register short count = 0,err;

	while(count < 10){
		if(cerr = read_sect(buffer,1,nsects,0)){
			err = cerr;
			count++;
		}
		else
			break;
	}
#endif EXBUF

	if(err)
		fdcerror = err;
	return count;
}

tr_write(buffer,nsects)
char *buffer;
short nsects;{

	/*
	 * writes a complete track starting at sector 1
	 * for nsects, assumes that drive selection and
	 * side selection are already performed
	 */
	short	cerr;

#ifdef EXBUF
	register short count = 0, sect, err = 0;
	char addr[20];

	while(count < 10){
		if(cerr = read_addr(addr)){
			err = cerr;
			count++;
		}
		else{
			sect = addr[2] + 1;		/* sector number */
			sect = (sect > nsects)? sect - nsects:sect;
			cerr = write_sect(buffer + (SIZE * (sect - 1)),sect,nsects - sect + 1,0);
			if(sect != 1)
				cerr |= write_sect(buffer,1,sect - 1,0);
			if(cerr){
				err = cerr;
				count++;
			}
			else
				break;
		}
	}
#else
	register count = 0,err;

	while(count < 10){
		if(cerr = write_sect(buffer,1,nsects,0)){
			err = cerr;
			count++;
		}
		else
			break;
	}
#endif EXBUF
	if(err)
		fdcerror = err;
	return count;
}

oldest(aged)
short aged;{
	/*
	 *	makes the buffer age aged to become
	 *	the oldest and adjust all the buffers
	 *	that were older than it to become 1
	 *	younger returns the array index of the oldest
	 */

	register short p = 0, newone;

	while(p < NO_BUFS){
		if(fdb[p].age >= aged){
			if(fdb[p].age == aged){
				newone = p;
				fdb[p].age = NO_BUFS;
			}
			fdb[p].age--;
		}
		p++;
	}

	return newone;
}

youngest(aged)
short aged;{
	/*
	 *	makes the buffer age aged to become
	 *	the youngest and adjust all the buffers
	 *	that were younger than it to become 1
	 *	older returns the array index of the youngest
	 */

	register short p = 0, newone;

	while(p < NO_BUFS){
		if(fdb[p].age <= aged){
			if(fdb[p].age == aged){
				newone = p;
				fdb[p].age = -1;
			}
			fdb[p].age++;
		}
		p++;
	}

	return newone;
}

/*
 * Deverr - general error message
 */
deverr(str, count, buf)
char *str;
struct buf *buf;
{

	printf("\n\rDeverr: ");
	if (count >= 10)
		printf("Fatal\007 ");
	else if (count > 1)
		printf("%d of ", count);

	printf("%s at blk %d on %d, FDC error: %x\n", str, buf->b_bno, buf->b_dev,fdcerror);
	return;
}

doseek(trk, twostep)
int	trk;
char	twostep;
{
	register short count = 0,err;

	if(twostep){
		while((err = raw_seek(trk)) && count < 10){
			restor(0);
			fdcerror = err;
			count++;
		}
	}
	else {
		while((err = ver_seek(trk)) && count < 10){
			restor(0);
			fdcerror = err;
			count++;
		}
	}

	return count;
}

/*
 *	ioctl for floppies, allows reading and writing of
 *	tracks (for formatting or weird disk reads) and
 *	reading of address fields (God knows what to use that for!)
 */
fdioctl(dev,req,args)
int dev,req;
struct fdcntrl *args;
{
	int (*func)();
	register char *emsg;
	register short reps;
	register struct drive_info *fds;
	int	track;

	int	write_track(), read_track(), read_addr();


	dtype = fdstatus[dev & 0x3].d_type;

	tmpb.b_bno = -1;	/* allows us to use deverr for error reports */
	tmpb.b_dev = dev;	/*	"	"	"	" */

	/* select dev */
	if (select(dev & 0x3) == ERROR){
		deverr("dev not ready", 1, &tmpb);
		return ERROR;
	}


	switch(req){

	default:
		/* simply return when an uknown ioctl appears */
		printf("\n\rUNKNOW Ioctl for floppy, %x\n\r",req);
		return NOERROR;

#ifdef FULLBUFFERING 
	case TIOCFLUSH:
		/*
			flush all buffers that are dirty on this 
			device and make them available
		 */
		return flushall(dev);
		/* NOTREACHED */
		break;
#else
	case TIOCFLUSH:
		return 0;
#endif FULLBUFFERING 

	case WRITETRACK:
		func = write_track;
		emsg = "write track:";
		break;

	case READTRACK:
		func = read_track;
		emsg = "read track:";
		break;

	case READADDR:
		func = read_addr;
		emsg = "read addr:";
		break;

	case MULTIREAD:
		func = tr_read;
		emsg = "mutli read";
		break;

	case MULTIWRITE:
		func = tr_write;
		emsg = "multi write";
		break;

	case WRITESECT:
		func = write_sect;
		emsg = "Write sect";
		break;

	case READSECT:
		func = read_sect;
		emsg = "Read sect";
		break;

	}

	switch(req){

	case READADDR: case READTRACK: case WRITETRACK:
		/*
			raw operator, possibly on a raw disk
			that has lost formatting info so
			seek with no verify etc
		 */

		/* find current position */
		fds = &fdstatus[dev & 0x3];

		/* Gets floppy drive track number */
		if(fds->d_type & DTYPE40) track = args->trackno * 2;
		else track = args->trackno;

		if ((set_track(fds->d_curtrk)) != track){

			/*
				raw_seek simply seeks from where ever
				it thinks the head is to the track specified
				no error checking, no verify so the head
				postion had better be right!
			 */
	
			raw_seek(track);
		}

		fds->d_curtrk = track;
		set_track(args->trackno);	/* Sets real track 40/80 */
			
		side(args->sideno);	/* side select */
		reps = raw_tr_op(args->buffer,func);
		break;

	case MULTIREAD: case MULTIWRITE:
		/*
			reads or writes the track as multiple
			sectors, disk MUST be formatted for 
			this to work
		 */

		/*
			setup the disk, because the diskset routine
			uses the track value to decide on which side
			as well, this kludge allows diskset to not
			only seek to the correct track but also
			do side selection too
		 */
		fds = &fdstatus[dev & 0x3];

		/* Gets floppy drive track number */
		if(fds->d_type & DTYPESS) track = args->trackno;
		else track = (args->trackno * 2) + args->sideno;

		fdcerror = reps = diskset(&tmpb, track);

		if(reps == ERROR)
			return ERROR;
		reps = (*func)(args->buffer,P_TRK);
		break;

	case READSECT: case WRITESECT:
		/*
			reads or writes the track as multiple
			sectors, disk MUST be formatted for 
			this to work
		 */

		/*
			setup the disk, because the diskset routine
			uses the track value to decide on which side
			as well, this kludge allows diskset to not
			only seek to the correct track but also
			do side selection too
		 */
		fds = &fdstatus[dev & 0x3];

		/* Gets floppy drive track number */
		if(fds->d_type & DTYPESS) track = args->trackno;
		else track = (args->trackno * 2) + args->sideno;

		fdcerror = reps = diskset(&tmpb, track);

		if(reps == ERROR)
			return ERROR;
		fdcerror = reps = (*func)(args->buffer,args->sect, 1, 0);
		break;

	}


	if(reps){
		deverr(emsg,reps,&tmpb);
		if(reps >= 10)
			return ERROR;
		else
			return NOERROR;
	}
	return 0;
}

raw_tr_op(b,fn)
char *b;
int (*fn)();{
	/*
		writes or reads a track/address field  with the data in b
	 */

	register short count = 0,err;

	while(count < 10){
		if(err = (*fn)(b)){
			fdcerror = err;
			count++;
		}
		else
			break;
	}

	return count;
}

#ifdef FULLBUFFERING 
flush1(p)
short p;{
	/*
		given a track buffer number p
		this flushes it to the correct disk if it
		can and does nowt else
	 */

	short reps;

	/*
		to be able to use diskset we set up a buffer
		with info from the track buffer we are flushing
	 */
	tmpb.b_dev = fdb[p].d_minor;
	tmpb.b_bno = fdb[p].bstart;

	if(diskset(&tmpb,NOTATRACK) == ERROR)
		return ERROR;
	else{
		mode = fdstatus[drive & 0x3].d_type;
		reps = tr_write(fdb[p].fdata,P_TRK);
		if(reps){
			deverr("track flush",reps,&tmpb);
			if(reps >= 10){
				/*
					at the mo do nothing
					with fatal track errors
				 */
				return ERROR;
			}
		}
		return NOERROR;
	}
			
}

flushall(dev)
int dev;{
	/*
		walk thru all the buffers flushing all
		those that are relevant to this device
		and are recently written
	 */

	register short p = 0;

	while(p < NO_BUFS){
		/* release all the allocated buffers */
		if((fdb[p].d_minor == dev) && (fdb[p].type & WRITTEN))
				/*
					attempt to flush a dirty buffer
				 */
				if(flush1(p) == ERROR)
					/*
						Oh well it was a good try
						for the mo leave its state
						alone
					 */
					return ERROR;
				else{
					/*
						succeeded in the flush
						now make it the oldest
						but leave it with a READABLE
						flag
					 */
					fdb[p].type &= ~WRITTEN;
					oldest(fdb[p].age);
				}
		p++;
	}

	return NOERROR;
}
#endif FULLBUFFERING 
