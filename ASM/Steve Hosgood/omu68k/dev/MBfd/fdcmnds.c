/******************************************************************************
 *	Fdcmnds.c	Contains lower level floppy disk drivers
 ******************************************************************************
 */
# include "1772.h"

/* Floppy control address */
# define	FDC	((struct Fdc *)0xF4000)

/* Drive select address - 16 bit address lower byte only write to DRIVE_SET
 *	to set a bit and DRIVE_RESET to clear a bit
 *	For Micro Box these are in the ACIA Chip
 */
# define	DRIVE_SET	((short *)0xFF01C)
# define	DRIVE_RESET	((short *)0xFF01E)

# define	DRIVE_BITS	0xE0	/* Drive bits */
# define	DRIVE_1		0x80	/* Drive one */
# define	SDEN		0x40	/* Single density enable */
# define	SIDE_0		0x20	/* Side 0 */

char status;		/* Holds state of fd status port (drive,side etc) */

/*
 *	fdcinit()	Initialise drive bits
 */
fdcinit(){
	status = 0;
	set(SIDE_0);
}

/*
 *	Set()		Sets required status info
 */
set(state)
short	state;
{
	*DRIVE_SET = ~state & DRIVE_BITS;
	*DRIVE_RESET = state & DRIVE_BITS;
	status = state;
}

/*
 *	Select()	Selects drive if not alreay selected via status varible
 */
select(drive)
char drive;
{
	/* Only drives 0 and 1 */
	if((drive > 1) || (drive < 0)) return -1;

	if(!drive && (status & DRIVE_1)){
		set(status & ~DRIVE_1);
		delay(1200);		/* delay 120ms after sel */
	}
	else{
		if(drive && !(status & DRIVE_1)){
			set(status | DRIVE_1);
			delay(1200);		/* delay 120ms after sel */
		}
	}
	return 0;
}

/*
 *	Side()	Changes side of disk if incorrect ( via status varible )
 */
side(no)
char	no;
{
	if(no){
		if(status & SIDE_0){
			set(status &= ~SIDE_0);
			delay(10);	/* 100 micro s delay after selection */
		}
	}
	else{
		if(!(status & SIDE_0)){
			set(status |= SIDE_0);
			delay(10);	/* 100 micro s delay after selection */
		}
	}
	return 0;
}


/*
 *	TYPE I COMMANDS FOR THE 2772
 *	ALL RETURN THE CONTENTS OF
 *	THE STATUS REGISTER
 */

/*
 *	Restor()	Restores drive to track 0
 */
restor(flags)
short	flags;
{
	motoron();

	/* wait for any other cmnd */
	while(FDC->csr & BUSY);
	FDC->csr = (RESTORE | flags ); /* send restor motor on */
	return (wait_fin() & ONE_ERR);
}

/*
 *	Motor()	Motor on/off routines
 */
motoron(){
}
motoroff(){
}

/*
 *	Track_no()	Gets present track no
 */
get_track(){
	return FDC->track;
}

/*
 *	Set_track()	Sets track no
 */
set_track(trackno)
register short trackno;
{
	FDC->track=trackno;
	return trackno;
}

/*
 *	Seek()	Seeks track specified if flag = VERIFY verifies position
 */
ver_seek(track)
short track;
{
	/* Seek with verify and error return */
	return(seek(track,VERIFY));
}

raw_seek(track)
short track;
{
	/* Seek with no verify, no error return */
	seek(track,NO_FLAGS);
}

seek(track,flags)
short	track, flags;
{
	short intlevel;

#ifdef TFLOPPY
printf("Seeking %d\n",track);
#endif

	motoron();

	/* wait for any other cmnd */
	while(FDC->csr & BUSY);
	intlevel = spl6();
	FDC->data = track;	/* set track reg */
	FDC->csr = SEEK;	/* send seek */
	splx(intlevel);
	wait_fin();

	while(FDC->csr & BUSY);
	intlevel = spl6();
	FDC->data = track;		/* set track reg */
	FDC->csr = (SEEK |flags);	/* send seek */
	splx(intlevel);
	return (wait_fin() & ONE_ERR);
}

wait_fin(){
	int	err;

	/* wait for finish */
	while ((err = FDC->csr) & BUSY);
	return	err;		/* return status */
}

/*
 *	TYPE II COMMANDS FOR THE 2791
 *	ALL RETURN THE CONTENTS OF
 *	THE STATUS REGISTER
 */

/*
 *	Read_sect()	Read of sectors to buffer
 */
read_sect(buf, start_sect, sect_count, flags)
char	*buf;
short	start_sect, sect_count, flags;
{
	register short	byte_count, error;
	short intlevel;

#ifdef TFLOPPY
printf("Read sector %d\n",start_sect);
printf("Read flags %d\n",flags);
#endif

	motoron();

	/* wait till rdy */
	while(FDC->csr & BUSY);
	intlevel = spl6();
	FDC->sector = start_sect;	/* set up first sector address */
	if ( sect_count != 1)
		flags = flags | MULTI_RECORD;
	byte_count = sect_count * SECTLENGTH;
	FDC->csr = (READSECTOR | flags);
	/* do until all done or interrupts out of its own accord */
	error = r_sectc(buf,byte_count) & READ_ERR;
	splx(intlevel);

#ifdef TFLOPPY
printf("Error returned %x\n",error);
printf("Track %d\n",FDC->track);
#endif

	if(!error){
		/* if error does not exist then terminate the command */
		force_intr(TERMINATE);

#ifdef TFLOPPY
printf("Force int error %x\n\r",error);
#endif

	}
	else{
		/* otherwise return the error */
		error =  wait_fin();
	}
	return (error & READ_ERR);
}

/*
 *	Write_sect()	Write of sectors from buffer
 */
write_sect(buf, start_sect, sect_count, flags)
char	*buf;
short	start_sect, sect_count, flags;
{
	register short	byte_count, error;
	short intlevel;

	motoron();
	/* wait till rdy */
	while(FDC->csr & BUSY);
	intlevel = spl6();
	FDC->sector = start_sect;	/* set up first sector address */
	if ( sect_count != 1)
		flags = flags | MULTI_RECORD;
	byte_count = sect_count * SECTLENGTH;
	FDC->csr = (WRITESECTOR | flags);
	/* do until all done or interrupts out of its own accord */
	error = w_sectc(buf,byte_count) & WRITE_ERR;
	splx(intlevel);
	if(!error){
		/* if error does not exist then terminate the command */
		force_intr(TERMINATE);
	}
	else{
		/* otherwise return the error */
		error =  wait_fin();
	}
	return (error & WRITE_ERR);
}

/*
 *	TYPE III COMMANDS FOR THE 2791
 *	ALL RETURN THE CONTENTS OF
 *	THE STATUS REGISTER
 */

/*
 *	Read_sect()	Reads track information from disk into buffer
 */
read_addr(buf)
char *buf;
{
	short intlevel;
	int err;

	motoron();
	/* wait till rdy */
	while(FDC->csr & BUSY);
	intlevel = spl6();
	FDC->csr = (READADDRESS) ;
	raw_read(buf);
	splx(intlevel);
	return (FDC->csr & ONE_ERR);
}

/*
 *	Read_track()	Reads whole track into buffer
 */
read_track(buf)
char	*buf;
{
	int err;
	short intlevel;

	motoron();

	/* wait till rdy */
	while(FDC->csr & BUSY);
	intlevel = spl6();
	FDC->csr = (READTRACK) ;
	raw_read(buf);
	splx(intlevel);
	return (FDC->csr & ONE_ERR);
}

/*
 *	Write_track()	Writes whole track to buffer
 */
write_track(buf)
char	*buf;
{
	short intlevel;

	motoron();
	/* wait till rdy */
	while(FDC->csr & BUSY);
	intlevel = spl6();
	FDC->csr = (WRITETRACK) ;
	raw_write(buf);
	splx(intlevel);
	return (FDC->csr & ONE_ERR);
}


/*
 *	TYPE IV COMMAND FOR THE 2791
 *	RETURNS THE CONTENTS OF
 *	THE STATUS REGISTER
 */

force_intr(flags)
int	flags;
{
	char	loop;

	loop = DELAY_TIME;

	FDC->csr = (FORCEINTERRUPT | flags) ;	/* issue cmnd */
	while(loop-- != 0);			/* wait at least 16 us */
	if (flags & IMMEDIATE){
		FDC->csr = (FORCEINTERRUPT | TERMINATE) ;
		while(loop++ != DELAY_TIME);	/* wait at least 16 us */
	}
	return	FDC->csr & ONE_ERR;
}

/*
 *	Delay()		Noddy delay routine approx time on 68000 8Mhz
 */
delay(time)
int	time;
{
	/* delay for time x 10 micro secs (approx) */
	for(;time > 0;time--);
}

/*
 *	THESE ROUTINES ARE THE SOURCES OF THE HAND-OPTIMIZED
 *	.68K ROUTINES IN read_write.68k THEY ARE HERE FOR
 *	REFERENCE ONLY
 *
 *r_sect(buf,count)
 *char	*buf;
 *short	count;{
 *
 *	char	error;
 *
 *	error = 0;
 *	do{
 *		if( !(FDC->bits & NOT_DATA_REQ) ){
 *			*buf++ = FDC->data;
 *			count--;
 *		}
 *		if( !(FDC->bits & NOT_INT_REQ) ){
 *			error = FDC->csr;
 *			break;
 *		}
 *	}while( (count >= 1) && !error);
 *	return error;
 *}
 *
 *w_sect(buf,count)
 *char	*buf;
 *short	count;{
 *
 *	char	error;
 *
 *	error = 0;
 *	do{
 *		if( !(FDC->bits & NOT_DATA_REQ) ){
 *			FDC->data = *buf++;
 *			count--;
 *		}
 *		if( !(FDC->bits & NOT_INT_REQ) ){
 *			error = FDC->csr;
 *			break;
 *		}
 *	}while( (count >= 1) && !error);
 *	return error;
 *}
 *
 *
 *raw_read(buf)
 *char	*buf;{
 *	while(FDC->bits & NOT_INT_REQ)
 *		if ( !(FDC->bits & NOT_DATA_REQ) )
 *			*buf++ = FDC->data;	
 *}
 *
 *raw_write(buf)
 *char	*buf;{
 *	while(FDC->bits & NOT_INT_REQ)
 *		if( !(FDC->bits & NOT_DATA_REQ) )
 *			FDC->data = *buf++;	
 *}
 *
 *
 *
 */
