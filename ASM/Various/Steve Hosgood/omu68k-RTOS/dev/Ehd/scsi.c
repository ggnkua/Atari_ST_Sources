/*******************************************************************************
 *	Scsi.c		SCSI interface drivers
 *******************************************************************************
 */

# include	"68230.h"
# include	"scsi.h"

/* Parallel port's address */
# define	TIMEOUT	200000
# define	NOTIMEOUT	0

# define	PIAB	((struct Piat *)0x0E73800)

/* Port C SCSI control signals */
# define	SIBUSY	0x01	/* Busy signal */
# define	SICMD	0x02	/* Command signal */
# define	SIMSG	0x04	/* MSG bit */
# define	SIIN	0x08	/* Scsi input */
# define	SISEL	0x10	/* Scsi select */
# define	SIRESET	0x80	/* Scsi reset */

int	noerrs;

/*
 *	Si_init()	Initialises scsi port
 */
si_init(){
	int	c;

	/* Sets up Port B to Mode 0 Sub mode 0 with all lines input mode
	 * and no interupts enabled
	 */

	PIAB->h12en = FALSE;
	PIAB->h34en = FALSE;
	PIAB->pmode = 0;	/* Mode 0 */
	PIAB->h12en = FALSE;
	PIAB->h34en = FALSE;
	PIAB->h1sense = NEGTRUE;
	PIAB->h2sense = NEGTRUE;
	PIAB->h3sense = NEGTRUE;
	PIAB->h4sense = NEGTRUE;

	PIAB->dmapins = FALSE;
	PIAB->intpins = TRUE;
	PIAB->intpri = 0;

	PIAB->asubmode = 2;			/* Input not buffered */
	PIAB->h2control = H2INPUT;
	PIAB->h2inten = FALSE;
	PIAB->h1inten = FALSE;
	PIAB->h1status = FALSE;

	PIAB->bsubmode = 2;			/* Input not buffered */
	PIAB->h4control = H4OUTFALSE;
	PIAB->h4inten = FALSE;
	PIAB->h3inten = FALSE;
	PIAB->h3status = FALSE;

	PIAB->adir = INPUT;
	PIAB->bdir = INPUT;
	PIAB->cdir = INPUT;
	PIAB->adir |= (SISEL | SIRESET);	/* Sets A4 SEL as an output */
	
	PIAB->adata = ON;
	PIAB->bdata = OFF;

	PIAB->pintvect = 0;

	/* Resets SCSI bus */
	PIAB->adata &= ~SIRESET;
	delay(100);
	PIAB->adata |= SIRESET;
	delay(10);

	return 0;
}

/*
 *	Si_cmd()	Execute SCSI command with given data
 *			Perform error recoverey (retry command)
 */
si_cmd(cmd, dev, block, noblocks, data)
int	cmd, dev, block, noblocks;
char	*data;
{
	int	count, err;
	struct	Sidcb dcb;

	/* Sets up command device control block */
	dcb.opcode = cmd;
	dcb.hiblock = (block >> 16) & 0xFF;
	dcb.miblock = (block >> 8) & 0xFF;
	dcb.loblock = block & 0xFF;
	dcb.noblocks = noblocks;
	dcb.control = 0;

	/* Retry command */
	for(count = 0; count < 10; count++){
		if(!(err = si_docmd(dev, &dcb, data))) break;
		/* Recover scsi bus after error */
/*		hdmerr(); */
		si_init();	/* Initialise bus */
		hdrestore(dev);
	}

	/* If any errors print error message */
	if(count){
		/* If fatal error */
		if(count == 10){
			si_err("Fatal error\007 10 retries", err, dev, &dcb);
			return -1;
		}
		/* If recoverable error */
		else {
			si_err("Recovered",  err, dev, &dcb);
		}
	}
	return 0;
}

/*
 *	Si_docmd()	Do si cmd
 */
si_docmd(dev, dcb, data)
struct	Sidcb *dcb;
int	dev;
char	*data;
{
	int	err;
	long	spare;

	spare = 0;

	/* Select the drive */
	if(err = si_select(dev)) return err;

	/* Perform the comand */
	if(SICLASS(dcb->opcode) == 1){
		if(err = si_write(dcb, sizeof(struct Sidcb1))) return err;
	}
	else {
		if(err = si_write(dcb, sizeof(struct Sidcb))) return err;
	}

	/* Do command actions */
	switch(SICMDMASK(dcb->opcode)){
	case SIREAD_CAP:
		if(err = si_read(data, sizeof(struct Sicap), TIMEOUT)) return err;
		if(err = si_cmdend(TIMEOUT)) return err;
		break;
	case SIREQSENSE:
		if(err = si_read(data, dcb->noblocks, TIMEOUT)) return err;
		if(err = si_cmdend(TIMEOUT)) return err;
		break;
	case SIREAD:
		if(err = si_read(data, dcb->noblocks * 512, TIMEOUT)) return err;
		if(err = si_cmdend(TIMEOUT)) return err;
		break;
	case SIWRITE:
		if(err = si_write(data, dcb->noblocks * 512)) return err;
		if(err = si_cmdend(TIMEOUT)) return err;
		break;
	case SIFORMAT:
		if(dcb->hiblock == 0x18){
			if(err = si_write(&spare, 4)) return err;
		}
		if(err = si_cmdend(NOTIMEOUT)) return err;
		break;
	case SICERTIFY:
		if(err = si_cmdend(NOTIMEOUT)) return err;
		break;
	default:
		if(err = si_cmdend(TIMEOUT)) return err;
		break;
	}
	return 0;
}

/*
 *	Si_select()	Select the given device.
 */
si_select(dev)
int	dev;
{
	int	count, sidev;

	sidev = 1 << dev;

	count = SCSI_SELTIMEOUT;
	/* Wait till SCSI is not Busy */
	while(!(PIAB->adata & SIBUSY))
		if(count-- < 0) return SIERR_BUSY;

	/* Puts device address on data bus */
	PIAB->bdata = sidev;
	PIAB->bdir = OUTPUT;
	PIAB->adata &= ~SISEL;

	/* Wait for busy to be pulled low (active) */
	count = SCSI_SELTIMEOUT;
	while(PIAB->adata & SIBUSY){
		if(count-- < 0){
			PIAB->adata |= SISEL;
			PIAB->bdir = INPUT;
			return SIERR_NDEV;
		}
	}
	PIAB->adata |= SISEL;
delay(1);
	PIAB->bdata = OFF;
	PIAB->bdir = INPUT;
	return 0;
}


/*
 *	Si_cmdend()	Wait till end of scsi comand and return errors.
 */
si_cmdend(timeout)
int	timeout;
{
	char	status[2];
	int	err,c;

	status[0] = -1;
	/* Gets status and message byte */
	if(err = si_read(status, 2, timeout)) return err;
	else return status[0];
}

/*
 *	Si_write()	Transmitt data/commands onto SCSI
 */
si_write(sidata, nobytes)
char	*sidata;
int	nobytes;
{
	int	err, intmask;

	PIAB->bdir = OUTPUT;
/*	intmask = spl7(); */
	err = hdmwrite(sidata, nobytes);
/*	splx(intmask); */

/*	while(nobytes--){
		while(PIAB->h3level);
		PIAB->bdata = *sidata++;
		PIAB->h4control = H4OUTTRUE;
		while(!PIAB->h3level);
		PIAB->h4control = H4OUTFALSE;
	}
 */
	PIAB->bdir = INPUT;
	return err;
}

/*
 *	Si_read()	Recieve data/commands from SCSI
 */
si_read(sidata, nobytes, timeout)
char	*sidata;
int	nobytes;
{
	int	err, intmask;

	PIAB->bdir = INPUT;
/*	intmask = spl7(); */
	err = hdmread(sidata, nobytes, timeout);
/*	splx(intmask); */
	return err;

/*	while(nobytes--){
		while(PIAB->h3level);
		*sidata++ = PIAB->bdata;
		PIAB->h4control = H4OUTTRUE;
		while(!PIAB->h3level);
		PIAB->h4control = H4OUTFALSE;
	}
	return 0;
 */
}

/*
 *	Si_err()	SCSI error recovery
 */
si_err(str, err, dev, dcb)
char	*str;
int	err, dev;
struct	Sidcb *dcb;
{
	int	block;
	struct	Sierr error;
	struct	Sidcb ndcb;

	block = ((dcb->hiblock << 16) & 0xFF0000) + ((dcb->miblock << 8) & 0xFF00) + (dcb->loblock & 0xFF);
	printf("HD error: %s device %d block %d cmd %x error %d\n\r",
		str, dev, block, dcb->opcode, err);

	/* Get error info from drive */
	ndcb.opcode = SIREQSENSE;
	ndcb.hiblock = 0;
	ndcb.miblock = 0;
	ndcb.loblock = 0;
	ndcb.noblocks = 18;
	ndcb.control = 0;
	if(si_docmd(dev, &ndcb, &error)){ 
		printf("Fatal\007 error on dev %d Unable to check err\n\r",dev);
		return -1;
	}
	printf("HD errors sense %x error code %x\n\r",error.sensekey,
		error.errcode);
	return 0;
}

si_test(){
	int	c;

	printf("Data %x Control %x H3 %d H4 %d\n\r",PIAB->bdata,PIAB->adata,PIAB->h3level,PIAB->h4level);
	hddelay(20000);
}
hddelay(d)
int	d;
{
	while(d--);
}
hdbip(){
	int	c;

	PIAB->bdir = OUTPUT;
	PIAB->bdata = 0x80;
	PIAB->adata &= ~SISEL;
	for(c =0; c < 100; c++);
	PIAB->adata |= SISEL;
	PIAB->bdir = INPUT;
}

prbytes(n)
int	n;
{
	printf("Nbytes left %d\n",n);
}
