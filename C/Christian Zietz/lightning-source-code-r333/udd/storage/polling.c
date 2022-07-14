/*
 * USB mass storage driver
 *
 * Copyright (C) 2019 by David Galvez
 *
 * This file is distributed under the GPL, version 2 or at your
 * option any later version.  See /COPYING.GPL for details.
 */

#ifndef TOSONLY
#include "mint/mint.h"
#endif
#include "../../global.h"
#include "../../usb.h"

#include "part.h"
#include "scsi.h"
#include "usb_storage.h"

#ifdef TOSONLY
struct xbra
{
	long	xbra;
	long	id;
	void	(*oldvec)();
};
#endif

/* Global variables */
short num_multilun_dev = 0;
static int polling_on = 0;

/* External declarations */
extern block_dev_desc_t usb_dev_desc[MAX_TOTAL_LUN_NUM];
extern struct mass_storage_dev mass_storage_dev[USB_MAX_STOR_DEV];;

extern long usb_test_unit_ready(ccb *srb, struct us_data *ss);
extern long poll_floppy_ready(ccb *srb, struct us_data *ss);
extern void usb_stor_eject(long device);
extern long usb_stor_get_info(struct usb_device *, struct us_data *, block_dev_desc_t *);
extern void part_init(long dev_num, block_dev_desc_t *stor_dev);
#ifdef TOSONLY
extern long *old_etv_timer_int;
extern void interrupt_storage (void);
extern int transfer_running;
#endif

extern int enable_flop_mediach; /* in storage_int.S */

/* Functions prototypes */
void init_polling(void);
void storage_int(void);
#ifndef TOSONLY
static void stor_poll_thread(void *dummy);
#endif

void storage_int(void)
{
	int i, r;
	ccb pccb;
#ifndef TOSONLY
	static int lock = 0;

	if (lock)
		return;

	lock = TRUE;
#else
	if (transfer_running)
		return;
#endif

	for (i = 0; i < MAX_TOTAL_LUN_NUM; i++) {
		if (usb_dev_desc[i].target == 0xff) {
			continue;
		}

		/* If the device has only one LUN and is not a floppy drive or floppy drive mediach is disabled we don't poll */
		if (mass_storage_dev[usb_dev_desc[i].usb_phydrv].total_lun <= 1 &&
			(!enable_flop_mediach ||
			mass_storage_dev[usb_dev_desc[i].usb_phydrv].usb_stor.subclass != US_SC_UFI))
			continue;

		pccb.lun = usb_dev_desc[i].lun;
		if (mass_storage_dev[usb_dev_desc[i].usb_phydrv].usb_stor.subclass == US_SC_UFI) {
			r = poll_floppy_ready(&pccb, &mass_storage_dev[usb_dev_desc[i].usb_phydrv].usb_stor);
			if (r > 0)
				continue;
		}
		else {
			r = usb_test_unit_ready(&pccb, &mass_storage_dev[usb_dev_desc[i].usb_phydrv].usb_stor);
		}
		if ((r) && (usb_dev_desc[i].ready)) { /* Card unplugged */
			if (!usb_dev_desc[i].sw_ejected)
				usb_stor_eject(i);
			usb_dev_desc[i].ready = 0;
			usb_dev_desc[i].sw_ejected = 0;
		}
		else if ((!r) && (!usb_dev_desc[i].ready)) { /* Card plugged */
			if (usb_stor_get_info(usb_dev_desc[i].priv, &mass_storage_dev[usb_dev_desc[i].usb_phydrv].usb_stor, &usb_dev_desc[i]) > 0)
				part_init(i, &usb_dev_desc[i]);

			ALERT(("USB Mass Storage Device (%d) LUN (%d) inserted %s",
				usb_dev_desc[i].usb_phydrv, usb_dev_desc[i].lun, usb_dev_desc[i].product));
		}
	}
#ifdef TOSONLY /* TOS driver code for uninstalling polling routine */
	{
		unsigned long first_etv_timer_int;
		unsigned long *tmp_etv_timer_int;
		struct xbra *tmp_xbra;

#define ETV_TIMER 0x400
#define XBRA 0x58425241
#define USTR 0x55535452

		/* If there is no devices with more than 1 LUN then uninstall polling routine */
		if (!num_multilun_dev) {
			first_etv_timer_int = (unsigned long) *(volatile unsigned long *) 0x400;
			tmp_xbra = (struct xbra *)(first_etv_timer_int - sizeof(struct xbra));

			if (!first_etv_timer_int || tmp_xbra->xbra != XBRA)
				return;

			if (tmp_xbra->xbra == XBRA && tmp_xbra->id == USTR) {
				*(volatile unsigned long *) ETV_TIMER = (unsigned long) tmp_xbra->oldvec;
				polling_on = 0;
				return;
			}

			tmp_etv_timer_int = (unsigned long *) tmp_xbra->oldvec;
			tmp_xbra = (struct xbra *)((long)tmp_xbra->oldvec - sizeof(struct xbra));
			while (tmp_xbra->xbra == XBRA) {
				if (tmp_xbra->id == USTR) {
					*tmp_etv_timer_int = (long)tmp_xbra->oldvec;
					polling_on = 0;
					break;
				}
				else {
					tmp_etv_timer_int = (unsigned long *) &tmp_xbra->oldvec;
					tmp_xbra = (struct xbra *)((long)tmp_xbra->oldvec - sizeof(struct xbra));
				}
			}
		}
	}
#else
	lock = FALSE;
#endif
}

#ifndef TOSONLY
static void
stor_poll(PROC *proc, long dummy)
{
	wake(WAIT_Q, (long)&stor_poll_thread);
}

static void
stor_poll_thread(void *dummy)
{
	/* This thread is only running while there are
	 * devices with more than 1 LUN connected
	 */
	while(num_multilun_dev)
	{
		storage_int();
		addtimeout(2000L, stor_poll);
		sleep(WAIT_Q, (long)&stor_poll_thread);
	}

	polling_on = 0;
	kthread_exit(0);
}
#endif

void init_polling(void)
{
	long r = 0;

	num_multilun_dev++;

	if (!polling_on) {
#ifndef TOSONLY
		r = kthread_create(get_curproc (), stor_poll_thread, NULL, NULL, "usbstor");
#else
		r = Super (0L);
		old_etv_timer_int = (void *) *(volatile unsigned long *) 0x400;
		*(volatile unsigned long *) 0x400 = (unsigned long) interrupt_storage;
		SuperToUser (r);
#endif
	}
#ifndef TOSONLY
	if (r) {
		DEBUG(("Failed to create storage polling thread"));
		return;
	}
	else
#endif
		polling_on = 1;
}
