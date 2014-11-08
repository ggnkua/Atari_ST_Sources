#include <aes.h>
#include <vdi.h>
#include <memory.h>
#include <osbind.h>
#include "main.h"

/* Prototypes... */

	void	init_mfdb(void);
	void	close_mfdb(void);

/* Externals... */

	/* Procedures... */

		extern void clear_mfdb(MFDB *);

	/* Data... */

		extern MFDB		screen, work;
		extern short		work_out[57];
		extern short		extn_out[57];

void init_mfdb(void)
 	{
	size_t	block;

	screen.fd_addr=NULL;

 	work.fd_w=MAX_WID;
	work.fd_h=MAX_HGT;
	work.fd_wdwidth=(work.fd_w+15)>>4;
	work.fd_stand=0;
	work.fd_nplanes=extn_out[4];
	block=2*(size_t)work.fd_wdwidth*(size_t)work.fd_h*(size_t)work.fd_nplanes;
	work.fd_addr=malloc(block);
	clear_mfdb(&work);
	}

void close_mfdb(void)
	{
	free(work.fd_addr);
	}
