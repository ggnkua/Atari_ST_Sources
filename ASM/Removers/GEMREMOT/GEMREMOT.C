/*--------------------------------------------------------------------------*/
/*	File name:	GEMREMOT.C						Revision date:		*/
/*	Revised by:	Stabylo							Revision start:		*/
/*	Created by:	Stabylo							Creation date:		*/
/*--------------------------------------------------------------------------*/
/*	Purpose:	Test the GemRemote concept		*/
/*--------------------------------------------------------------------------*/
#include <aes.h>
#include <linea.h>
#include <tos.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
/*#include <linea.h>*/

#include "sting\transprt.h"


/*--------------------------------------------------------------------------*/
#define MOUSE_MOTION 0
#define BUTTON_PRESSED 1
#define BUTTON_RELEASED 2

/*--------------------------------------------------------------------------*/
void          gem_program (void);
long          get_sting_cookie (void);
int16         do_some_work (void);
/*--------------------------------------------------------------------------*/
typedef int  BOOLEAN;
/*--------------------------------------------------------------------------*/
DRV_LIST  *sting_drivers;
TPL       *tpl;
uint16    sent, received, min, ave, max, num_packets;
uint32    host;
char      alert[200];
char  not_there[] = "[1][ |  STinG is not loaded or enabled !   ][ Hmmm ]";
char  corrupted[] = "[1][ |  STinG structures corrupted !   ][ Oooops ]";
char  found_it[]  = "[3][ |  Driver \'%s\',|  by %s, found,   |  version %s.][ Okay ]";
char  no_module[] = "[1][ |  STinG Transport Driver not found !   ][ Grmbl ]";
char  takes[]     = "[3][ |  This will take a little more   | |    than %d seconds.][ Okay ]";
char  first[]     = "[3][  Ping Actions :| |    %u packets sent, %u received;   |    %ld %% lost.][ Okay ]";
char  second[]    = "[3][  Ping Time Statistics :   | |    Minimum %5ld ms|    Average %5ld ms|    Maximum %5ld ms][ Okay ]";
/*--------------------------------------------------------------------------*/
void  main() {
	appl_init();
	/*linea_init();*/

	gem_program();

	appl_exit();
}
/*------------------*/
/*	ends:	main	*/
/*--------------------------------------------------------------------------*/
void  gem_program() {
	sting_drivers = (DRV_LIST *) Supexec (get_sting_cookie);

	if (sting_drivers == 0L) {
		form_alert(1, not_there);
		return;
	}
	if (strcmp(sting_drivers->magic, MAGIC) != 0) {
		form_alert(1, corrupted);
		return;
	}

	tpl = (TPL *) (*sting_drivers->get_dftab) (TRANSPORT_DRIVER);

	if (tpl == (TPL *) NULL) {
		form_alert(1, no_module);
	} else {
		sprintf(alert, found_it, tpl->module, tpl->author, tpl->version);
		form_alert(1, alert);
		do_some_work();
	}
}
/*--------------------------*/
/*	ends:	gem_program		*/
/*--------------------------------------------------------------------------*/
long  get_sting_cookie() {
	long  *work;

	for (work = * (long **) 0x5a0L; *work != 0L; work += 2)
		if (*work == 'STiK')
			return (*++work);
	return (0L);
}
/*------------------------------*/
/*	ends:	get_sting_cookie	*/
/*--------------------------------------------------------------------------*/
int16  do_some_work() {
	uint32 remote_addr = (192 << 24) | (168 << 16) | (0 << 8) | (1);
	uint16 local_port = 4444;
	CAB cab;
	int16 conn_handle, ret;
	UDPIB info_block;
	uint16 received;
	NDB  *data_block;
	int16 size, dx, dy, button, type;
	CIB *conn_info;

#if 0
	cab.lport = local_port;
	cab.rport = 0;
	cab.rhost = remote_addr;
	cab.lhost = 0L;
	conn_handle = UDP_open((uint32) &cab, UDP_EXTEND);
#else
	conn_handle = UDP_open(0, local_port);
#endif
	
	if (conn_handle < 0) {
		/* E_UNREACHABLE or E_NOMEM */
		printf("Error: when opening connection.\n");
		return (-1);
	}
	printf("Socket opened at port %d.\n", local_port);

	/* request switch to DEFER mode */
	info_block.request = UDPI_defer;
	ret = UDP_info(conn_handle, &info_block);
	if (ret < 0) {
		printf("Error: when switching connection to defer mode.\n");
		return (-1);
	}
	printf("Socket swiched to defer mode.\n", local_port);
	
	received = 0;
	while (received < 100) {
		data_block = CNget_NDB (conn_handle);
		if (data_block && (data_block != (NDB *)E_LOCKED)) {
			if ((data_block->len >= 2) && ((size = * (int16 *) (data_block->ndata)) == data_block->len)) {
				++received;
				type = * (int16 *) (data_block->ndata + 2);
				switch(type) {
				case MOUSE_MOTION:
					dx = * (int16 *) (data_block->ndata + 4);
					dy = * (int16 *) (data_block->ndata + 6);
					printf("--> dx=%d dy=%d\n", dx, dy);
					break;
				case BUTTON_PRESSED:
					button = * (int16 *) (data_block->ndata + 4);
					printf("--> button pressed %d\n",button);
					break;
				case BUTTON_RELEASED:
					button = * (int16 *) (data_block->ndata + 4);
					printf("--> button released %d\n",button);
					break;					
				}
			
			} else {
				printf("Only %d bytes available\n", data_block->len);
			}
			KRfree(data_block->ptr);
			KRfree(data_block);
		} else if (!data_block) {
			/* No data available yet, or an error occured ! */
			conn_info = CNgetinfo(conn_handle);
			if (conn_info->status != 0) {
				printf("ICMP error type=%d code=%d\n", 
						((conn_info->status >> 8) & 0xff), 
						(conn_info->status & 0xff));
			}
			conn_info = NULL;
		}
		evnt_timer(10, 0);
	}
	ret = UDP_close(conn_handle);
	if (ret < 0) {
		printf("Error: when closing connection.\n");
		return (-1);
	}
	return (0);
}
/*--------------------------*/
/*	ends:	do_some_work	*/
/*--------------------------------------------------------------------------*/
/*--------------------------------------------------------------------------*/
/*	End of file:	GEMREMOT.C													*/
/*--------------------------------------------------------------------------*/
