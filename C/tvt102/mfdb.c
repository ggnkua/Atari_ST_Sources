#include <aes.h>
#include <vdi.h>
#include <memory.h>
#include <osbind.h>
#include <string.h>
#include "main.h"

/* Prototypes... */

	void	init_mfdb(void);
	void	close_mfdb(void);
	void touch_mfdb(void);

/* Externals... */

	/* Procedures... */

		extern void clear_mfdb(MFDB *);

	/* Data... */

		extern MFDB		screen, work;
		extern short		work_out[57];
		extern short		extn_out[57];

		extern short 		chrwid,chrhgt;
		extern short nlines;

void init_mfdb(void)
 	{
	size_t	block;

	screen.fd_addr=NULL;

 	work.fd_w=MAX_WID;
	work.fd_h=nlines*chrhgt*2;
	work.fd_wdwidth=(work.fd_w+15)>>4;
	work.fd_stand=0;
	work.fd_nplanes=extn_out[4];
	block=2*(size_t)work.fd_wdwidth*(size_t)work.fd_h*(size_t)work.fd_nplanes;
	work.fd_addr=malloc(block);
	memset(work.fd_addr, 0, block);

/*
	clear_mfdb(&work);
*/
	}
void touch_mfdb(void)
	{
	size_t	block;

	screen.fd_addr=NULL;

 	work.fd_w=MAX_WID;
	work.fd_h=24*chrhgt*2;
	work.fd_wdwidth=(work.fd_w+15)>>4;
	work.fd_stand=0;
	work.fd_nplanes=extn_out[4];
	block=2*(size_t)work.fd_wdwidth*(size_t)work.fd_h*(size_t)work.fd_nplanes;
	Mfree(work.fd_addr);
	work.fd_addr=Malloc(block);
	memset(work.fd_addr, 0, block); 
	}


void close_mfdb(void)
	{
	free(work.fd_addr);
	}
