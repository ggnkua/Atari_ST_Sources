
/*******************************************************************************
 *	Scsi.c		SCSI interface drivers
 *******************************************************************************
 */

# include	"68230.h"
# include	"scsi.h"

/* Parallel port B's address */
# define	PIAB	((struct Piat *)0x0FF200)

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

	/* Sets up Port A to Mode 0 Sub mode 0 with all lines input mode
	 * and no interupts enabled
	 */
	PIAB->h12en = FALSE;
	PIAB->h34en = FALSE;
	PIAB->pmode = 0;	/* Mode 0 */
	PIAB->h12en = FALSE;
	PIAB->h34en = FALSE;
	PIAB->h1sense = NEGTRUE;
	PIAB->h2sense = POSTRUE;

	PIAB->dmapins = FALSE;
	PIAB->intpins = TRUE;
	PIAB->intpri = 0;

	PIAB->adir = INPUT;
	PIAB->bdir = INPUT;
	PIAB->cdir = INPUT;

	PIAB->cdata = ON;
	PIAB->cdir |= (SISEL | SIRESET);	/* Sets C4 SEL as an output */
	
	PIAB->pintvect = 0;

	PIAB->asubmode = 0;			/* Input not buffered */
	PIAB->h2control = H2ILHS;
	PIAB->h2inten = FALSE;
	PIAB->h1inten = FALSE;
	PIAB->h1status = FALSE;

	/* Resests SCSI bus */
	PIAB->cdata &= ~SIRESET;
	delay(100);
	PIAB->cdata |= SIRESET;

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

	/* Select the drive */
	if(err = si_select(dev)) return err;

	/* Perform the comand */
	if(err = si_write(dcb, sizeof(struct Sidcb))) return err;

	/* Do command actions */
	switch(dcb->opcode){
	case SIREQSENSE:
		if(err = si_read(data, dcb->noblocks)) return err;
		if(err = si_cmdend()) return err;
		break;
	case SIREAD:
		if(err = si_read(data, dcb->noblocks * 512)) return err;
		if(err = si_cmdend()) return err;
		break;
	case SIWRITE:
		if(err = si_write(data, dcb->noblocks * 512)) return err;
		if(err = si_cmdend()) return err;
		break;
	default:
		if(err = si_cmdend()) return err;
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
	while(!(PIAB->cdata & SIBUSY))
		if(count-- < 0) return SIERR_BUSY;

	/* Puts device address on data bus */
	PIAB->adir = OUTPUT;
	PIAB->adata = ~sidev;
	PIAB->cdata &= ~SISEL;

	/* Wait for busy to be pulled low (active) */
	count = SCSI_SELTIMEOUT;
	while(PIAB->cdata & SIBUSY){
		if(count-- < 0){
			PIAB->adir = INPUT;
			PIAB->cdata |= SISEL;
			return SIERR_NODEV;
		}
	}
	PIAB->adir = INPUT;
	PIAB->cdata |= SISEL;
	return 0;
}


/*
 *	Si_cmdend()	Wait till end of scsi comand and return errors.
 */
si_cmdend(){
	char	status[2];
	int	err;

	status[0] = -1;
	/* Gets status and message byte */
	si_read(status, 2);
	return status[0];
}

/*
 *	Si_write()	Transmitt data/commands onto SCSI
 */
si_write(sidata, nobytes)
char	*sidata;
int	nobytes;
{
	int	err;

	PIAB->adir = OUTPUT;
	PIAB->asubmode = 1;
	err = hdmwrite(sidata, nobytes);

/*	while(nobytes--){
		while(PIAB->h1level);
		PIAB->adata = ~(*sidata++);
		PIAB->h2control = H2OUTTRUE;
		while(!PIAB->h1level);
		PIAB->h2control = H2OUTFALSE;
	}
 */
	PIAB->asubmode = 0;
	PIAB->adir = INPUT;
	return err;
}

/*
 *	Si_read()	Recieve data/commands from SCSI
 */
si_read(sidata, nobytes)
char	*sidata;
int	nobytes;
{
	PIAB->adir = INPUT;
	PIAB->asubmode = 0;
	return hdmread(sidata, nobytes);

/*	while(nobytes--){
		while(PIAB->h1level);
		*sidata++ = ~PIAB->adata;
		PIAB->h2control = H2OUTTRUE;
		while(!PIAB->h1level);
		PIAB->h2control = H2OUTFALSE;
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

	printf("Data %x Control %x H1 %d H2 %d\n\r",PIAB->adata,PIAB->cdata,PIAB->h1level,PIAB->h2level);
	hddelay(20000);
}
hddelay(d)
int	d;
{
	while(d--);
}
