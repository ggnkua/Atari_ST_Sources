/******************************************************************************
 *	Fdcmnds.c	Low level floppy drive commands for Eltec kit
 ******************************************************************************
 */
#include "floppy.h"
#include "buffer.h"

extern	int	dtype;

char status;

/*
 *	Fdcinit()	Initialise floppy disk hardware
 */
fdcinit(){
}

/*
 *	Select() Selects drive if not alreay selected (via status varible)
 */
select(drive)
char drive;
{
	register char mask;

	status |= FIVE_SEL;
	status &= ~(SDEN);

	/* Special for high density checking */
/*	if(drive == 3){
		status &= ~FIVE_SEL;
		FDC_PORT->bits = status;
		drive = 1;
	}
 */

	mask = 1<<drive;
	if((status & 0x0F)!= mask){
		status &= 0xf0;		/* deselect all */
		status |= mask;
		delay(120);	/* wait 1200 micro s before deselecting */
		FDC_PORT->bits = status;
		delay(1200);		/* delay 120ms after sel */
	}
	return 0;
}

/*
 *	Side()	Changes side of disk if incorrect ( via status varible )
 */
side(no)
char	no;
{
	register char set;

	set=0;
	if (no == SIDE_ZERO){
		if(status & SIDE_ONE){
			status &= ~SIDE_ONE;
			set++;
		}
	}
	else{
		if(!(status & SIDE_ONE)){
			status |= SIDE_ONE;
			set++;
		}
	}
	if(set){
		delay(100);	/* 1000 micro s delay before selection */
		FDC_PORT->bits = status;
		delay(10);		/* 100 micro s delay after selection */
	}
	return 0;
}


/*
 *	TYPE I COMMANDS FOR THE 2791
 *	ALL RETURN THE CONTENTS OF
 *	THE STATUS REGISTER
 */


/*
 *	Restor()	Restores drive to track 0
 */
restor(flags)
short	flags;{

	motoron();
	/* Switches FDC controller to high speed for seek */
	FDC_PORT->bits = status & ~FIVE_SEL;
	while(FDC_PORT->csr & BUSY);	/* wait for any other cmnd */
	FDC_PORT->csr = (RESTORE | flags|LOAD_HEAD); /* send restor */
	wait_fin();
	FDC_PORT->bits = status;	/* Resets to normal speed */
	return;
}

/*
 *	MOTOR	Motor on/off routines
 */

motoron(){
	if(!(status&MOTOR_ON)){
		status|=MOTOR_ON;
		FDC_PORT->bits=status;
		delay(120000);
	}
	/* Sets machine tick count to indicate motor has been switched on */
	mach_fdon();
}
motoroff(){
	status&= ~MOTOR_ON;
	FDC_PORT->bits=status;
}

/*
 *	Get_track()	Gets present track no
 */

get_track(){
	return FDC_PORT->track;
}

/*
 *	Set_track()	Sets track no
 */

set_track(trackno)
register short trackno;
{
	FDC_PORT->track=trackno;
	return trackno;
}

/*
 *	Set_status()	Sets status
 */

set_status(stat)
register char stat;
{
	FDC_PORT->bits=stat;
}
get_status(){

	return(status);
}

/*
 *	Seek()	Seeks track specified if flag = VERIFY verifies position
 */

/*
 *	seek with verify and error return
 */
ver_seek(track)
short track;
{
	return(seek(track,VERIFY) & SK_ERR);
}

/*
 *	seek with no verify, no error return
 */
raw_seek(track)
short track;
{
	return(seek(track,NO_FLAGS) & SK_ERR);
}

seek(track,flags)
short	track, flags;
{
	short intlevel;

#ifdef TFLOPPY
printf("Seeking %d\n",track);
#endif

	motoron();
	/* Switches FDC controller to high speed for seek */
	FDC_PORT->bits = status & ~FIVE_SEL;

	while(FDC_PORT->csr & BUSY);	/* wait for any other cmnd */
	intlevel = spl6();
	FDC_PORT->data = track;	/* set track reg */
	FDC_PORT->csr = (SEEK |LOAD_HEAD);	/* send seek */
	splx(intlevel);
	wait_fin();

	while((FDC_PORT->csr &BUSY)||(FDC_PORT->csr&NOT_RDY));
	FDC_PORT->bits = status;		/* Returns to normal mode */
	intlevel = spl6();
	FDC_PORT->data = track;	/* set track reg */
	FDC_PORT->csr = (SEEK |flags|LOAD_HEAD);	/* send seek */
	splx(intlevel);
	return wait_fin();
}

wait_fin(){
	int count=0;

	while (!(FDC_PORT->bits & INT_REQ));	/* wait for finish */
	return	FDC_PORT->csr;		/* return status */
}

/*
 *	TYPE II COMMANDS FOR THE 2791
 *	ALL RETURN THE CONTENTS OF
 *	THE STATUS REGISTER
 */

/*
 *	Read_sect()	read of sectors to buffer
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

	while(FDC_PORT->csr & (BUSY |NOT_RDY));	/* wait till rdy */
	intlevel = spl6();
	FDC_PORT->sector = start_sect;	/* set up first sector address */
	if ( sect_count != 1)
		flags = flags | MULTI_RECORD;
	byte_count = sect_count * SECTLENGTH;
	FDC_PORT->csr = (READSECTOR | flags);

	/* do until all done or interrupts out of its own accord */
	error = r_sectc(buf,byte_count);

	splx(intlevel);

	force_intr(TERMINATE);

	if(dtype & DTYPEINTEL) swapbyte(buf, byte_count);

#ifdef TFLOPPY
printf("Error returned %x\n",error);
printf("Track %d\n",FDC_PORT->track);
#endif

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

	if(dtype & DTYPEINTEL) swapbyte(buf, byte_count);

	motoron();
	while(FDC_PORT->csr & (BUSY |NOT_RDY));	/* wait till rdy */
	intlevel = spl6();
	FDC_PORT->sector = start_sect;	/* set up first sector address */
	if ( sect_count != 1)
		flags = flags | MULTI_RECORD;
	byte_count = sect_count * SECTLENGTH;
	FDC_PORT->csr = (WRITESECTOR | flags);

	/* do until all done or interrupts out of its own accord */
	error = w_sectc(buf,byte_count);

	splx(intlevel);
	force_intr(TERMINATE);

	return (error & WRITE_ERR);
}

/*
 *	TYPE III COMMANDS FOR THE 2791
 *	ALL RETURN THE CONTENTS OF
 *	THE STATUS REGISTER
 */

/*
 *	Read_addr()	Reads track information from disk into buffer
 */
read_addr(buf)
char *buf;
{
	short intlevel, error;

	motoron();
	while(FDC_PORT->csr & (BUSY |NOT_RDY));	/* wait till rdy */
	intlevel = spl6();
	FDC_PORT->csr = (READADDRESS | DELAY_15) ;
	error = raw_read(buf);
	splx(intlevel);
	return (error & RAD_ERR);
}

/*
 *	Read_track()	Reads whole track into buffer
 */
read_track(buf)
char	*buf;
{
	short intlevel, error;
	short	tmp;

	motoron();
	while(FDC_PORT->csr & (BUSY |NOT_RDY));	/* wait till rdy */
	intlevel = spl6();

	FDC_PORT->csr = (READTRACK | DELAY_15) ;
	error = raw_read(buf);

	splx(intlevel);
	return (error & RRD_ERR);
}

/*
 *	Write_track()	Writes whole track to buffer
 */
write_track(buf)
char	*buf;
{
	short intlevel, error;

	motoron();
	while(FDC_PORT->csr & (BUSY |NOT_RDY));	/* wait till rdy */
	intlevel = spl6();
	FDC_PORT->csr = (WRITETRACK | DELAY_15) ;
	error = raw_write(buf);
	splx(intlevel);
	return (error & RWR_ERR);
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

	FDC_PORT->csr = (FORCEINTERRUPT | flags) ;	/* issue cmnd */
	while(loop-- != 0);			/* wait at least 16 us */
	if (flags & IMMEDIATE){
		FDC_PORT->csr = (FORCEINTERRUPT | TERMINATE) ;
		while(loop++ != DELAY_TIME);	/* wait at least 16 us */
	}
	return (int)FDC_PORT->csr;
}


delay(time){
	/* delay for time x 10 micro secs (approx) */

	for(;time > 0;time--);
}

/*
 *	Swapbyte()	Swaps bytes around in an array
 */
swapbyte(buf, num)
register char	*buf;
register int	num;
{
	register char	c;

	while(num -= 2){
		c = *buf;
		*buf = *(buf + 1);
		*(buf + 1) = c;
		buf += 2;
	}
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
 *		if( !(FDC_PORT->bits & NOT_DATA_REQ) ){
 *			*buf++ = FDC_PORT->data;
 *			count--;
 *		}
 *		if( !(FDC_PORT->bits & NOT_INT_REQ) ){
 *			error = FDC_PORT->csr;
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
 *		if( !(FDC_PORT->bits & NOT_DATA_REQ) ){
 *			FDC_PORT->data = *buf++;
 *			count--;
 *		}
 *		if( !(FDC_PORT->bits & NOT_INT_REQ) ){
 *			error = FDC_PORT->csr;
 *			break;
 *		}
 *	}while( (count >= 1) && !error);
 *	return error;
 *}
 *
 *
 *raw_read(buf)
 *char	*buf;{
 *	while(FDC_PORT->bits & NOT_INT_REQ)
 *		if ( !(FDC_PORT->bits & NOT_DATA_REQ) )
 *			*buf++ = FDC_PORT->data;	
 *}
 *
 *raw_write(buf)
 *char	*buf;{
 *	while(FDC_PORT->bits & NOT_INT_REQ)
 *		if( !(FDC_PORT->bits & NOT_DATA_REQ) )
 *			FDC_PORT->data = *buf++;	
 *}
 *
 *
 *
 */
