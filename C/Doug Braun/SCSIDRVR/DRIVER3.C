#include <dos.h>
#include "driver.h"
#include "scsi.h"


#define NUNITS 2

struct reqhdr far *request;

/* command dispatch table */
extern int (*(dispatch[]))();

#define max_command 16

char msg[100];

char *get_sense();

void dointr(req)
struct reqhdr far *req;
{
	static int x;

	request = req;

    x = request->command;
	if (x < 0 || x > max_command)
	{
	    request->status = 0x8103;
		return;
	}

	request->status = (*(dispatch[x]))();
	request->status |= 0x0100;
}


biosputs(s)
char *s;
{
	static char c;
	static int oldbp;

    while (*s)
	{
	    c = *s++;
		if (c == '\n')
		{
			oldbp = _BP;
			_AL = '\r';
			_AH = 0x0e;
			_BH = 0;
			geninterrupt(0x10);
			_BP = oldbp;
		}

		oldbp = _BP;
		_AL = c;
		_AH = 0x0e;
		_BH = 0;
		geninterrupt(0x10);
		_BP = oldbp;
	}
}

/* Following are the individual routines for each function */


badfun()
{
    return (0x8003);
}

nullfun()
{
    return (0);
}



/* This is returned by the initialization function */

struct bpb bpb_list[NUNITS];

struct bpb *bpb_array[NUNITS] = { &bpb_list[0], &bpb_list[1] };


static struct boot_sector init_buf;

init()
{
	extern char edata;
	static struct scsireq s;
	int j;
	static char cmd[6];


	sprintf(msg,
			"\nHard disk driver ver. 3 compiled %s %s installed at %X:0000\n",
			__DATE__, __TIME__, _CS);
	biosputs(msg);

	for (j=0; j < NUNITS; j++)
	{

	    cmd[0] = 0x08;
	    cmd[1] = (j&01) << 5;
	    cmd[2] = 0;
	    cmd[3] = 0;
	    cmd[4] = 1;
		cmd[5] = 0;

		s.busid = 1;
		s.dptr = (char far *)&init_buf;
		s.dlen = 512;
		s.cptr = (char far *)cmd;

		scsiop(&s);

		if (s.error == 0)
		{
		    *bpb_array[j] = init_buf.disk_bpb;
			sprintf(msg, "LUN %d, name %s with %u blocks online as %c:\n", j,
					init_buf.disk_name,
				    bpb_array[j]->nsectors,
					'A' + j + request->padding[0]);
			biosputs(msg);
		}
		else
		{
			sprintf(msg, "LUN %d is not available\n", j);
			biosputs(msg);
		    break;
		}
	}

	biosputs("\n");

	request->media = j;   /* # of drives  */
	request->address = (char far *)&edata;
	request->count = (unsigned)bpb_array;
	request->sector = (unsigned)_CS;
	return (0);
}


media_chk()
{
    request->address = (char far *)1;
	return (0);
}


build_bpb()
{
	request->count = (unsigned)(bpb_array[request->unit]);
	request->sector = (unsigned)_CS;
	return (0);
}



read()
{
	static struct scsireq s;
	int lun;
	static char cmd[6];

	/*
	sprintf(msg, "Read of %u sectors from %u to %Fp\n", request->count,
		request->sector, request->address);
	biosputs(msg);
	*/

	lun = request->unit;

    cmd[0] = 0x08;
    cmd[1] = (lun&01) << 5;
    cmd[2] = request->sector >> 8;
    cmd[3] = request->sector & 0xff;
    cmd[4] = request->count;
	cmd[5] = 0;

	s.busid = 1;
	s.dptr = (char far *)request->address;
	s.dlen = request->count * 512;
	s.cptr = (char far *)cmd;

	scsiop(&s);

	if (s.error != 0)
	{
		sprintf(msg, "Bad read of %u sectors from %u to %Fp\n", request->count,
			request->sector, request->address);
		biosputs(msg);
		sprintf(msg, "LUN %d. SCSI error code 0x%x.\n", lun, s.error);
		biosputs(msg);
	    perr(lun);
	}

    return (s.error? 0x8004 : 0);
}


write_vfy()
{
    return (write());
}

write()
{
	static struct scsireq s;
	int lun;
	static char cmd[6];

retry:

	/* 
	sprintf(msg, "Write of %u sectors from %u to %Fp\n", request->count,
		request->sector, request->address);
	biosputs(msg);
	*/

	lun = request->unit;

    cmd[0] = 0x0a;
    cmd[1] = (lun&01) << 5;
    cmd[2] = request->sector >> 8;
    cmd[3] = request->sector & 0xff;
    cmd[4] = request->count;
	cmd[5] = 0;

	s.busid = 1;
	s.dptr = (char far *)request->address;
	s.dlen = request->count * 512;
	s.cptr = (char far *)cmd;

	scsiop(&s);

	if (s.error != 0)
	{
		sprintf(msg, "Bad write of %u sectors from %u to %Fp\n", request->count,
			request->sector, request->address);
		biosputs(msg);
		sprintf(msg, "LUN %d. SCSI error code 0x%x.\n", lun, s.error);
		biosputs(msg);
	    if (perr(lun) == 0x12)
		    goto retry;
	}

    return (s.error? 0x8004 : 0);
}


int (*(dispatch[]))() = {
	init,
	media_chk,
	build_bpb,
	badfun,
	read,
	badfun,
	badfun,
	nullfun,
	write,
	write_vfy,
	badfun,
	nullfun,
	badfun,
	badfun,
	badfun,
	nullfun,
	badfun,
};


abort()
{
	biosputs("Driver aborted\n");
	for(;;);
}




char sensedata[10];

unsigned
logadr()
{
    int ladr,hadr;

    hadr = sensedata[2];
    ladr = sensedata[3];
    return ((hadr<<8)+(ladr&0xff));
}


perr(lun)
int lun;
{
    int code;
    unsigned phadr;

	getsense(lun);

    code = sensedata[0];

	biosputs("\nDISK ERROR\n");
    prerror(code & 0x7f);
    biosputs("\n");
    if (code & 0x80)
    {
        code &= 0x7f;
        sprintf(msg,  "Logical address: %x\n",logadr());
		biosputs(msg);
        if (code != 0x14 && code != 0x10)
        {
            phadr = xlate(lun, logadr());
            sprintf(msg,  "Physical address: %x\n",phadr);
			biosputs(msg);
        }
    }
    else
        biosputs("No address\n");

	return (code);
}



static char *errcodes[] = {

        "No error",
        "No index signal",
        "No seek complete",
        "Drive fault",
        "Drive not ready",
        0,
        "No track 00",
        0,
        0,
        0,
        0,
        0,
        "Write fault",
        0,
        0,
        0,
        "ID CRC error",
        "Uncorrectable data error",
        0,
        "Data address mark not found",
        "Record not found",
        "Seek error",
        0,
        0,
        "Corrected data error",
        0,
        "Format error",
        0,
        0,
        0,
        0,
        0,
        "Invalid command",
        "Illegal block address",
        "Command aborted",
        "Invalid parameters",
        0,
        "Controller error",
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0  };

static prerror(n)
int n;
{
    if (n<0 || n >= 48)
        biosputs("Invalid error code");
    else if (errcodes[n] == 0)
	{
        sprintf(msg, "Unknown error code %.2x",n);
		biosputs(msg);
	}
    else
	{
        sprintf(msg, "Error %.2x: %s",n,errcodes[n]);
		biosputs(msg);
	}
}


static xlate(lun,blk)
int lun;
unsigned blk;
{
    static char cmd[4];
    static char data[4];
	static struct scsireq s;

    cmd[0] = 0x0f;
    cmd[1] = (lun&01) << 5;
    cmd[2] = blk >> 8;
    cmd[3] = blk & 0xff;
    cmd[4] = cmd[5] = 0;


    s.busid = 1;
    s.cptr = (char far *)cmd;
    s.dptr = (char far *)data;
    s.dlen = 4;

	scsiop(&s);

    if (s.error != 0)
        return(-1);
    else
        return(data[2] * 256 + (data[3] & 0xff));

}


getsense(lun)
int lun;
{
    static char cmd[] = { 3, 0, 0, 0, 4, 0 };
	static struct scsireq s;

    cmd[1] = (lun&01) << 5;

    s.busid = 1;
    s.cptr = (char far *)cmd;
    s.dptr = (char far *)sensedata;
    s.dlen = 4;

	scsiop(&s);

    return (s.error);
}


int _realcvtvector;

