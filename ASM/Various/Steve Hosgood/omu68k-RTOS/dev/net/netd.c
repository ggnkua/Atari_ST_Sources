/******************************************************************************
 *	Netd.c	Network driver
 ******************************************************************************
 *
 *	Netd.c driver software:
 *		netopen(), netclose(), netstrat() and netioctl().
 *		netread(), netwrite().
 *
 */

# include	"../../include/param.h"
# include	"../../include/buf.h"
# include	"netcmd.h"

static	struct	Netcmd netcmd;		/* Network command buffer */
static	struct	Netdata netdata;	/* Network data buffer */
static	int	iscmd;			/* There is a command */

/******************************************************************************
 *	Netopen()	Opens network device
 ******************************************************************************
 */

netopen(dev)
short dev;
{
	return 0;
}


/******************************************************************************
 *	Netclose()	Closes Network if not opened by someone else
 ******************************************************************************
 */
netclose(dev)
short dev;
{
	return 0;
}

/******************************************************************************
 *	netstrat()	-	Strategy for network read and write block
 ******************************************************************************
 */
netstrat(buf)
struct buf *buf;
{
	char	cmd;
	char	*p;

	/* Check if write if so write data to correct block */
	if(buf->b_flags & WRITE){
		buf->b_flags |= ABORT;
		return -1;
	}

	/* Else read data */
	else{
		netcmd.nc_cmd = CGETBLK;
		netcmd.nc_blk = buf->b_bno;
		iscmd = 1;

		wakeup((caddr_t)&netcmd);
		sleep((caddr_t)&netdata, PRIBIO);
		bytecp(netdata.nd_data, buf->b_buf, 512);
	}
	return 0;
}

netread(dev, buf, len)
int	dev;
char	*buf;
int	len;
{
	if(!iscmd) sleep((caddr_t)&netcmd, PRIBIO);
	bytecp(&netcmd, buf, sizeof(netcmd));
	iscmd = 0;
	return sizeof(netcmd);
}

netwrite(dev, buf, len)
int	dev;
char	*buf;
int	len;
{
	struct	Netdata *ndata;

	ndata = (struct Netdata *)buf;

	switch(ndata->nd_h.nc_cmd){
	case DGETBLK:
		bytecp(ndata, &netdata, sizeof(netdata));
		wakeup((caddr_t)&netdata);
		return len;
	}
	return -1;
}
