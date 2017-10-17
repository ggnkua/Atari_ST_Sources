/*
 * File:        usb.c
 * Purpose:     Device Driver for the USB module of the MCF547x/8X
 */

#include "usb.h"

#ifdef USB_DEVICE
#ifdef NETWORK
#ifdef LWIP

/* Global Endpoint Status Structures */
USB_EP_STATE ep[NUM_ENDPOINTS];

/* Global USB Descriptor Data (application specific) */
extern USB_DEVICE_DESC Descriptors;
extern USB_DEVICE_DESC DescriptorsHS; 
extern uint8 string_desc[];

static vuint16 *pCurrentInterface;
static xQueueHandle queue_service;
static uint8 *buf_rx_int;
static uint32 hs; /* High-Speed */

#ifdef USB_DEBUG_PRINT
int debug_usb;
#endif

void usb_device_init(void)
{
	uint32 i, j, DescSize, StringSize;
	uint8 *pDevDesc;
	uint8 *pStrDesc;
	uint32 iDevDesc;
	/* Mask interrupts */
	int level = asm_set_ipl(7);
	hs = 0; /* Full-Speed */
	/* Perform a USB reset by setting USBCR[RST] */
	MCF_USB_USBCR |= MCF_USB_USBCR_RST;
	/* Point pCurrentInterface to IFR0 */
	pCurrentInterface = &MCF_USB_IFR0;
	/* Initialize Descriptor pointers and variables */
	pDevDesc = (uint8 *)usb_get_desc(-1, -1, -1, -1, -1, &iDevDesc);
	DescSize = usb_get_desc_size();
	/* Initialize Endpoint status structures */
	ep[0].ttype = CONTROL;
	ep[0].packet_size = ((USB_DEVICE_DESC *)pDevDesc)->bMaxPacketSize0;
	ep[0].fifo_length = (uint16)(ep[0].packet_size * 4);
	ep[0].buffer.start = NULL;
	ep[0].buffer.free = 0;
	ep[0].in_fifo_start = 0;
	ep[0].out_fifo_start = 0;
	ep[0].state = USB_DEVICE_RESET;
	ep[0].zlp = FALSE;
	for(i = 1; i < NUM_ENDPOINTS; i++)
	{
		ep[i].ttype = DISABLED;
		ep[i].packet_size = 0;
		ep[i].fifo_length = 0;
		ep[i].in_fifo_start = 0;
		ep[i].out_fifo_start = 0;
		ep[i].buffer.start = NULL;
		ep[i].buffer.position = 0;
		ep[i].buffer.length = 0;
		ep[i].buffer.free = 0;
		ep[i].state = USB_DEVICE_RESET;
		ep[i].zlp = FALSE;
	}
	/* Clear USBCR_RAMEN to allow access to descriptor RAM */
	MCF_USB_USBCR &= ~MCF_USB_USBCR_RAMEN;
	/* DRAMCR[DADR] = 0 */
	MCF_USB_DRAMCR = 0x00000000;
	/* Load the Descriptor RAM with the descriptors */
	for(i = 0; i < DescSize; MCF_USB_DRAMDR = (uint32)pDevDesc[i++]);
	/* Load string descriptors */
	MCF_USB_DRAMCR = usb_get_string_desc_base();
	pStrDesc = string_desc;
	for(i = 0; i < (NUM_STRING_DESC * NUM_LANGUAGES + 1); i++)
	{
		StringSize = (uint32)*pStrDesc;
		for(j = 0; j < StringSize; MCF_USB_DRAMDR = (uint32)*pStrDesc++, j++);
	}
	/* Program USBIMR */
	MCF_USB_USBIMR = ~(MCF_USB_USBIMR_RSTSTOP | MCF_USB_USBIMR_RES | MCF_USB_USBIMR_SUSP);
//	/* Configure the FIFO RAM for maximum flexibility */
#if (FIFO_PERF == TRUE)
	MCF_USB_USBCR |= MCF_USB_USBCR_RAMSPLIT;
#else
	MCF_USB_USBCR &= ~MCF_USB_USBCR_RAMSPLIT;
#endif
	/* Initialize EP0 FIFO */
	MCF_USB_EPFRCFGR(0) = MCF_USB_EPFRCFGR_BASE(0) | MCF_USB_EPFRCFGR_DEPTH(ep[0].fifo_length);
	MCF_USB_EPFCR(0) = 0x8C000000;
	MCF_USB_EPFAR(0) = 0x00000100;
	for(i = 1; i < NUM_ENDPOINTS; i++)
	{
		MCF_USB_EPFCR(i) = 0x8C000000;
		MCF_USB_EPFAR(i) = 0x00000000;
	}
	/* Program Endpoint Interrupt registers */
	MCF_USB_EPIMR(0) = ~MCF_USB_EPIMR_ERR;
	/* Set interrupt mask register for all other EPs */
	for(i = 1; i < NUM_ENDPOINTS; i++)
		MCF_USB_EPIMR(i) = MCF_USB_EPIMR_FU | MCF_USB_EPIMR_EMT | MCF_USB_EPIMR_ERR
		 | MCF_USB_EPIMR_FIFOHI | MCF_USB_EPIMR_FIFOLO | MCF_USB_EPIMR_EOF | MCF_USB_EPIMR_EOT;
	/* Flush EP0's FIFO */
	MCF_USB_EPSTAT(0) = MCF_USB_EPSTAT_DIR | MCF_USB_EPSTAT_FLUSH;
	/* Set STAT register for all other EPs */
	for(i = 1; i < NUM_ENDPOINTS; MCF_USB_EPSTAT(i++) = 0x00000000);
	buf_rx_int = (uint8 *)pvPortMalloc2(NUM_ENDPOINTS * BUFFER_SIZE);
	if(buf_rx_int != NULL)
	{
		/* Create service_queue */
		queue_service =	xQueueCreate(64, sizeof(uint32) * 3);
		if(queue_service != NULL)
		{
			/* Create service task */
			xTaskCreate(usb_service_task, "USBd", configMINIMAL_STACK_SIZE, NULL, 31, NULL);
			/* Initialize the USB-specific registers in the interrupt controller */
			usb_intc_init();
		}
	}
	/* Interrupts take over from here */
	asm_set_ipl(level);
}

/*
 * Initialize USB specific Interrupt Controller (INTC) settings
 */
void usb_intc_init(void)
{
	/* USB OR'ed */
	MCF_INTC_ICR24 = MCF_INTC_ICRn_IL(INTC_LVL_USBORED) | MCF_INTC_ICRn_IP(INTC_PRI_USBORED);
	/* USB Core */
	MCF_INTC_ICR23 = MCF_INTC_ICRn_IL(INTC_LVL_USBCORE) | MCF_INTC_ICRn_IP(INTC_PRI_USBCORE);
	/* USB General */
	MCF_INTC_ICR22 = MCF_INTC_ICRn_IL(INTC_LVL_USBGEN) | MCF_INTC_ICRn_IP(INTC_PRI_USBGEN);
	/* EP6 */
	MCF_INTC_ICR21 = MCF_INTC_ICRn_IL(INTC_LVL_USBEP6) | MCF_INTC_ICRn_IP(INTC_PRI_USBEP6);
	/* EP5 */
	MCF_INTC_ICR20 = MCF_INTC_ICRn_IL(INTC_LVL_USBEP5) | MCF_INTC_ICRn_IP(INTC_PRI_USBEP5);
	/* EP4 */
	MCF_INTC_ICR19 = MCF_INTC_ICRn_IL(INTC_LVL_USBEP4) | MCF_INTC_ICRn_IP(INTC_PRI_USBEP4);
	/* EP3 */
	MCF_INTC_ICR18 = MCF_INTC_ICRn_IL(INTC_LVL_USBEP3) | MCF_INTC_ICRn_IP(INTC_PRI_USBEP3);
	/* EP2 */
	MCF_INTC_ICR17 = MCF_INTC_ICRn_IL(INTC_LVL_USBEP2) | MCF_INTC_ICRn_IP(INTC_PRI_USBEP2);
	/* EP1 */
	MCF_INTC_ICR16 = MCF_INTC_ICRn_IL(INTC_LVL_USBEP1) | MCF_INTC_ICRn_IP(INTC_PRI_USBEP1);
	/* EP0 */
	MCF_INTC_ICR15 = MCF_INTC_ICRn_IL(INTC_LVL_USBEP0) | MCF_INTC_ICRn_IP(INTC_PRI_USBEP0);
	/* Unmask USB Interrupts */
	MCF_INTC_IMRL &= ~(0
	/*  | MCF_INTC_IMRL_INT_MASK24  - not enabling ORed interrupt */
	    | MCF_INTC_IMRL_INT_MASK23
	    | MCF_INTC_IMRL_INT_MASK22
	    | MCF_INTC_IMRL_INT_MASK21
	    | MCF_INTC_IMRL_INT_MASK20
	    | MCF_INTC_IMRL_INT_MASK19
	    | MCF_INTC_IMRL_INT_MASK18
	    | MCF_INTC_IMRL_INT_MASK17
	    | MCF_INTC_IMRL_INT_MASK16
	    | MCF_INTC_IMRL_INT_MASK15
	    | MCF_INTC_IMRL_MASKALL);
	/* Set the desired interrupt handler functions in the Vector Table */
	Setexc(64 + 15, usb_endpoint0_handler);
	Setexc(64 + 16, usb_endpoint1_handler);
	Setexc(64 + 17, usb_endpoint2_handler);
	Setexc(64 + 18, usb_endpoint3_handler);
	Setexc(64 + 19, usb_endpoint4_handler);
	Setexc(64 + 20, usb_endpoint5_handler);
	Setexc(64 + 21, usb_endpoint6_handler);
	Setexc(64 + 22, usb_general_int);
	Setexc(64 + 23, usb_core_int);
	Setexc(64 + 24, usb_or_handler_int);
}

static void usb_read_fifo(uint32 epnum, uint8 *buffer, uint32 fifo_data)
{
	uint32 *buf = (uint32 *)buffer;
	uint32 i;
	switch(fifo_data)
	{
		case 128:
			*buf++ = MCF_USB_EPFDR_32(epnum);
			*buf++ = MCF_USB_EPFDR_32(epnum);
			*buf++ = MCF_USB_EPFDR_32(epnum);
			*buf++ = MCF_USB_EPFDR_32(epnum);
			*buf++ = MCF_USB_EPFDR_32(epnum);
			*buf++ = MCF_USB_EPFDR_32(epnum);
			*buf++ = MCF_USB_EPFDR_32(epnum);
			*buf++ = MCF_USB_EPFDR_32(epnum);
			*buf++ = MCF_USB_EPFDR_32(epnum);
			*buf++ = MCF_USB_EPFDR_32(epnum);
			*buf++ = MCF_USB_EPFDR_32(epnum);
			*buf++ = MCF_USB_EPFDR_32(epnum);
			*buf++ = MCF_USB_EPFDR_32(epnum);
			*buf++ = MCF_USB_EPFDR_32(epnum);
			*buf++ = MCF_USB_EPFDR_32(epnum);
			*buf++ = MCF_USB_EPFDR_32(epnum);
		case 64:
			*buf++ = MCF_USB_EPFDR_32(epnum);
			*buf++ = MCF_USB_EPFDR_32(epnum);
			*buf++ = MCF_USB_EPFDR_32(epnum);
			*buf++ = MCF_USB_EPFDR_32(epnum);
			*buf++ = MCF_USB_EPFDR_32(epnum);
			*buf++ = MCF_USB_EPFDR_32(epnum);
			*buf++ = MCF_USB_EPFDR_32(epnum);
			*buf++ = MCF_USB_EPFDR_32(epnum);
		case 32: 
			*buf++ = MCF_USB_EPFDR_32(epnum);
			*buf++ = MCF_USB_EPFDR_32(epnum);
			*buf++ = MCF_USB_EPFDR_32(epnum);
			*buf++ = MCF_USB_EPFDR_32(epnum);
		case 16:
			*buf++ = MCF_USB_EPFDR_32(epnum);
			*buf++ = MCF_USB_EPFDR_32(epnum);
		case 8:
			*buf++ = MCF_USB_EPFDR_32(epnum);
			*buf++ = MCF_USB_EPFDR_32(epnum);
			break;
		default:
			for(i = 0; i < fifo_data;)
			{
				if(fifo_data - i > 3)
				{
					*buf++ = MCF_USB_EPFDR_32(epnum);
					i += 4;
				}
				else
					buffer[i++] = MCF_USB_EPFDR_8(epnum);
			}
			break;
	}
}

void usb_or_handler_interrupt(void)
{
	asm volatile(
		"_usb_or_handler_int:\n\t"
		" lea -24(SP),SP\n\t"
		" movem.l D0-D2/A0-A2,(SP)\n\t"
		" jsr _usb_or_handler\n\t"
		" movem.l (SP),D0-D2/A0-A2\n\t"
		" lea 24(SP),SP\n\t"
		" rte\n\t" );
}

void usb_or_handler(void)
{
}

/* 
 * This handler services interrupts generated in USBISR
 */
void usb_general_int(void)
{
  portENTER_SWITCHING_ISR()
  portEXIT_SWITCHING_ISR(usb_general_isr());
}

portBASE_TYPE usb_general_isr(void)
{
	portBASE_TYPE xNeedSwitch = pdFALSE;
	uint32 i, msg[3];
	vuint32 event = MCF_USB_USBISR & ~MCF_USB_USBIMR;
	if(event & MCF_USB_USBISR_MSOF)
	{
#ifdef USB_DEBUG_PRINT
		printf("MSOF\r\n");
#endif
		MCF_USB_USBISR = MCF_USB_USBISR_MSOF;
	}
	if(event & MCF_USB_USBISR_SOF)
	{
#ifdef USB_DEBUG_PRINT
		printf("SOF\r\n");
#endif
		MCF_USB_USBISR = MCF_USB_USBISR_SOF;
	}
	if(event & MCF_USB_USBISR_RSTSTOP)
	{
		uint32 DescSize = usb_get_desc_size();
		uint32 old_hs = hs;
		uint8 *pDevDesc;
#ifdef USB_DEBUG_PRINT
//		printf("RSTSTOP\r\n");
#endif
		MCF_USB_USBISR = MCF_USB_USBISR_RSTSTOP;
		if(MCF_USB_SPEEDR == MCF_USB_SPEEDR_HS)
		{
			hs = 1; /* High-Speed */
			pDevDesc = (uint8 *)&DescriptorsHS;
		}
		else
		{
			hs = 0; /* Full-Speed */
			pDevDesc = (uint8 *)&Descriptors;
		}
		/* Program ACR registers */
		MCF_USB_EP0ACR = (uint8)ep[0].ttype;
		MCF_USB_EP0MPSR = (uint16)ep[0].packet_size;
		/* Activate EP0 */
		MCF_USB_EP0SR |= MCF_USB_EP0SR_ACTIVE;
		ep[0].state = USB_CONFIGURED;
		for(i = 1; i < NUM_ENDPOINTS; i++);
		{
			MCF_USB_EPINACR(i) = (uint8)ep[i].ttype;
			MCF_USB_EPOUTACR(i) = (uint8)BULK;
			MCF_USB_EPINMPSR(i) = (uint16)ep[i].packet_size;
			MCF_USB_EPOUTMPSR(i) = (uint16)ep[i].packet_size;
		}
		if(hs != old_hs) /* Speed change */
		{
			/* Clear USBCR_RAMEN to allow access to descriptor RAM */
			MCF_USB_USBCR &= ~MCF_USB_USBCR_RAMEN;
			/* DRAMCR[DADR] = 0 */
			MCF_USB_DRAMCR = 0x00000000;
			/* Reload the Descriptor RAM with the descriptors */
			for(i = 0; i < DescSize; MCF_USB_DRAMDR = (uint32)pDevDesc[i++]);
		}
		/* Program USBAIMR */
		MCF_USB_USBAIMR = (uint8)~(MCF_USB_USBAIMR_EPSTALLEN | MCF_USB_USBAIMR_EPHALTEN
		 | /* MCF_USB_USBAIMR_OUTEN | MCF_USB_USBAIMR_INEN | */ MCF_USB_USBAIMR_SETUPEN);
		/* Validate Descriptor RAM */
		MCF_USB_USBCR |= MCF_USB_USBCR_RAMEN;
		/* Send buschg message */
		msg[0] = BUSCHG_NOTICE;
		msg[1] = RESET;
		msg[2] = 0;
		xNeedSwitch = xQueueSendFromISR(queue_service, msg, xNeedSwitch);
	}
	if(event & MCF_USB_USBISR_UPDSOF)
	{
#ifdef USB_DEBUG_PRINT
		printf("UPDSOF\r\n");
#endif
		MCF_USB_USBISR = MCF_USB_USBISR_UPDSOF;
	}
	if(event & MCF_USB_USBISR_RES)
	{
#ifdef USB_DEBUG_PRINT
//		printf("RES\r\n");
#endif
		MCF_USB_USBISR = MCF_USB_USBISR_RES;
		/* Send buschg message */
		msg[0] = BUSCHG_NOTICE;
		msg[1] = RESUME;
		msg[2] = 0;
		xNeedSwitch = xQueueSendFromISR(queue_service, msg, xNeedSwitch);
	}
	if(event & MCF_USB_USBISR_SUSP)
	{
#ifdef USB_DEBUG_PRINT
//		printf("SUSP\r\n");
#endif
		MCF_USB_USBISR = MCF_USB_USBISR_SUSP;
		/* Send buschg message */
		msg[0] = BUSCHG_NOTICE;
		if(MCF_USB_CFGAR & MCF_USB_CFGAR_RMTWKEUP)
			msg[1] = SUSPEND | ENABLE_WAKEUP;
		else
			msg[1] = SUSPEND;
		msg[2] = 0;
		xNeedSwitch = xQueueSendFromISR(queue_service, msg, xNeedSwitch);
	}
	if(event & MCF_USB_USBISR_FTUNLCK)
	{
#ifdef USB_DEBUG_PRINT
		printf("FTUNLCK\r\n");
#endif
		MCF_USB_USBISR = MCF_USB_USBISR_FTUNLCK;
	}
	if(event & MCF_USB_USBISR_ISOERR)
	{
#ifdef USB_DEBUG_PRINT
		printf("ISOERR\r\n");
#endif
		MCF_USB_USBISR = MCF_USB_USBISR_ISOERR;
	}
	return(xNeedSwitch);
}

/* 
 * This handler services interrupts generated in the USB 2.0 Device 
 * Controller core (USBAISR)
 */
void usb_core_int(void)
{
  portENTER_SWITCHING_ISR()
  portEXIT_SWITCHING_ISR(usb_core_isr());
}

portBASE_TYPE usb_core_isr(void)
{
	portBASE_TYPE xNeedSwitch = pdFALSE;
	uint32 msg[3];
	uint8 event, counter_event, epnum;
	/* Set the AppLock Bit */
	MCF_USB_USBCR |= MCF_USB_USBCR_APPLOCK;
	event = MCF_USB_USBAISR & ~MCF_USB_USBAIMR;
	epnum = (0xE & MCF_USB_EPINFO) >> 1;
	if(event & MCF_USB_USBAISR_SETUP)
	{
#ifdef USB_DEBUG_PRINT
//		printf("SETUP\r\n");
#endif
		/* 
		 * SET_FEATURE, CLEAR_FEATURE, GET_CONFIGURATION, GET_STATUS & SET_ADDRESS
		 * are automatically processed by the USB controller and do not require
		 * application intervention.  SET_CONFIGURATION, SET_DESCRIPTOR, GET_DESCRIPTOR,
		 * and SET_INTERFACE are dealt with here. 
		 */
		msg[0] = SETUP_SERVICE;
		/* Perform 32 bit read access for devices before data core XXX0632 */
		msg[1] = *(vuint32 *)&MCF_USB_BMRTR;   /* (bmRequestType << 24) + (bRequest << 16) + wValue */
		msg[2] = *(vuint32 *)&MCF_USB_WINDEXR; /* (wIndex << 16) + wLength */
		/* Clear the SETUP interrupt flag and EP0SR[INT] */
		MCF_USB_USBAISR &= ~MCF_USB_USBAISR_SETUP;
		/* Send service message */
		xNeedSwitch = xQueueSendFromISR(queue_service, msg, xNeedSwitch);
	}
	if(event & MCF_USB_USBAISR_IN)
	{
#ifdef USB_DEBUG_PRINT
//		printf("IN\r\n");
#endif
		/* Clear the interrupt */
		MCF_USB_USBAISR &= ~MCF_USB_USBAISR_IN;
	}
	if(event & MCF_USB_USBAISR_OUT)
	{
#ifdef USB_DEBUG_PRINT
		printf("OUT\r\n");
#endif
		MCF_USB_USBAISR &= ~MCF_USB_USBAISR_OUT;
	}
	if(event & MCF_USB_USBAISR_EPHALT)
	{
		/* IN EP */
		if(MCF_USB_EPINFO & MCF_USB_EPINFO_EPDIR)
		{
			/* SET_FEATURE(ENDPOINT_HALT) */
			if(MCF_USB_EPINSR(epnum) & MCF_USB_EPINSR_HALT)
			{
#ifdef USB_DEBUG_PRINT
//				printf("EP%d HALT\r\n", epnum);
#endif
				msg[2] = 1;
			}
			/* CLEAR_FEATURE(ENDPOINT_HALT) */
			else
			{
#ifdef USB_DEBUG_PRINT
//				printf("EP%d unHALT\r\n", epnum);
#endif
				msg[2] = 0;
			}
		}
		/* OUT EP */
		else
		{
			/* SET_FEATURE(ENDPOINT_HALT) */
			if(MCF_USB_EPOUTSR(epnum) & MCF_USB_EPOUTSR_HALT)
			{
#ifdef USB_DEBUG_PRINT
//				printf("EP%d HALT\r\n", epnum);
#endif
				msg[2] = 1;
			}
			/* CLEAR_FEATURE(ENDPOINT_HALT) */
			else
			{
#ifdef USB_DEBUG_PRINT
//				printf("EP%d unHALT\r\n", epnum);
#endif
				msg[2] = 0;
			}
		}
		MCF_USB_USBAISR &= ~MCF_USB_USBAISR_EPHALT;
		/* Send message */
		msg[0] = FEATURE_ENDPOINT;
		msg[1] = epnum;
		xNeedSwitch = xQueueSendFromISR(queue_service, msg, xNeedSwitch);
	}
	if(event & MCF_USB_USBAISR_TRANSERR)
	{
#ifdef USB_DEBUG_PRINT
		printf("TRANSERR\r\n");
#endif
		MCF_USB_USBAISR &= ~MCF_USB_USBAISR_TRANSERR;
	}
	if(event & MCF_USB_USBAISR_ACK)
	{
    int i;
#ifdef USB_DEBUG_PRINT
		printf("ACK\r\n");
#endif
		/* 
		 * This driver only turns on the ACK interrupt when it needs to 
		 * determine that a ZLP has been sent on a specific endpoint.
		 * Here we determine which endpoint the ACK is for and if a ZLP
		 * was just sent on that EP. If so, disable the TXZERO bit
		 * for that EP.
		 */
		switch(epnum)
		{
			case 0:
				if(ep[0].zlp && (MCF_USB_EP0SR & MCF_USB_EPINSR_TXZERO))
				{
					MCF_USB_EP0SR &= ~MCF_USB_EPINSR_TXZERO;
					ep[0].zlp = FALSE;
				}
				break;
			default:
				if(ep[epnum].zlp && (MCF_USB_EPINSR(epnum) & MCF_USB_EPINSR_TXZERO))
				{
					MCF_USB_EPINSR(epnum) &= ~MCF_USB_EPINSR_TXZERO;
					ep[epnum].zlp = FALSE;
				}
				break;
		}
		/* Mask further ACK interrupts if there are no ZLPs pending */
		for(i = 0; i < NUM_ENDPOINTS; i++)
		{
			if(ep[i].zlp)
				break;
		}
		if(i == NUM_ENDPOINTS)
			MCF_USB_USBAIMR |= MCF_USB_USBAIMR_ACKEN;
		/* Clear the interrupt event */
		MCF_USB_USBAISR &= ~MCF_USB_USBAISR_ACK;
	}
	if(event & MCF_USB_USBAISR_CTROVFL)
	{
		counter_event = MCF_USB_CNTOVR;
#ifdef USB_DEBUG_PRINT
		printf("CTROVFL\r\n");
#endif
		if(counter_event & MCF_USB_CNTOVR_TXPCNT)
		{
#ifdef USB_DEBUG_PRINT
			printf("CTROVFL-TXPCNT\r\n");
#endif
			MCF_USB_TXPCNT = 0x0001;
		}
		if(counter_event & MCF_USB_CNTOVR_FRMECNT)
		{
#ifdef USB_DEBUG_PRINT
			printf("CTROVFL-FRMECNT\r\n");
#endif
			MCF_USB_FRMECNT = 0x0001;
		}
		if(counter_event & MCF_USB_CNTOVR_PIDECNT)
		{
#ifdef USB_DEBUG_PRINT
			printf("CTROVFL-PIDECNT\r\n");
#endif
			MCF_USB_PIDECNT = 0x0001;
		}
		if(counter_event & MCF_USB_CNTOVR_BSECNT)
		{
#ifdef USB_DEBUG_PRINT
			printf("CTROVFL-BSECNT\r\n");
#endif
			MCF_USB_BSECNT = 0x0001;
		}
		if(counter_event & MCF_USB_CNTOVR_CRCECNT)
		{
#ifdef USB_DEBUG_PRINT
			printf("CTROVFL-CRCECNT\r\n");
#endif
			MCF_USB_CRCECNT = 0x0001;
		}
		if(counter_event & MCF_USB_CNTOVR_DPCNT)
		{
#ifdef USB_DEBUG_PRINT
			printf("CTROVFL-DPCNT\r\n");
#endif
			MCF_USB_DPCNT = 0x0001;
		}
		if(counter_event & MCF_USB_CNTOVR_PPCNT)
		{
#ifdef USB_DEBUG_PRINT
			printf("CTROVFL-PPCNT\r\n");
#endif
			MCF_USB_PPCNT = 0x0001;
		}
		/* Clear the interrupt */
		MCF_USB_USBAISR &= ~MCF_USB_USBAISR_CTROVFL;
	}
	if(event & MCF_USB_USBAISR_EPSTALL)
	{
#ifdef USB_DEBUG_PRINT
		printf("EPSTALL \r\n");
#endif
		/* 
		 * Make sure the PSTALL bit is cleared before proceeding.
		 * This bit is cleared by the next SETUP token. 
		 */
		while(MCF_USB_EP0SR & MCF_USB_EP0SR_PSTALL);
		MCF_USB_USBAISR &= ~MCF_USB_USBAISR_EPSTALL;
	}
	/* Clear AppLock */
	MCF_USB_USBCR &= ~MCF_USB_USBCR_APPLOCK;
	return(xNeedSwitch);
}

void usb_endpoint0_handler(void)
{
  portENTER_SWITCHING_ISR()
  portEXIT_SWITCHING_ISR(usb_endpoint_isr(0));
}

void usb_endpoint1_handler(void)
{
  portENTER_SWITCHING_ISR()
  portEXIT_SWITCHING_ISR(usb_endpoint_isr(1));
}

void usb_endpoint2_handler(void)
{
  portENTER_SWITCHING_ISR()
  portEXIT_SWITCHING_ISR(usb_endpoint_isr(2));
}

void usb_endpoint3_handler(void)
{
  portENTER_SWITCHING_ISR()
  portEXIT_SWITCHING_ISR(usb_endpoint_isr(3));
}

void usb_endpoint4_handler(void)
{
  portENTER_SWITCHING_ISR()
  portEXIT_SWITCHING_ISR(usb_endpoint_isr(4));
}

void usb_endpoint5_handler(void)
{
  portENTER_SWITCHING_ISR()
  portEXIT_SWITCHING_ISR(usb_endpoint_isr(5));
}

void usb_endpoint6_handler(void)
{
  portENTER_SWITCHING_ISR()
  portEXIT_SWITCHING_ISR(usb_endpoint_isr(6));
}

portBASE_TYPE usb_endpoint_isr(uint32 epnum)
{
	portBASE_TYPE xNeedSwitch = pdFALSE;
	uint32 msg[3];
	vuint32 event = MCF_USB_EPISR(epnum) & ~MCF_USB_EPIMR(epnum);
	if(event & (MCF_USB_EPISR_FU | MCF_USB_EPISR_EMT | MCF_USB_EPISR_ERR
	 | MCF_USB_EPISR_FIFOHI | MCF_USB_EPISR_FIFOLO))
	{
		vuint32 subevent = MCF_USB_EPFSR(epnum);
#ifdef USB_DEBUG_PRINT
//		printf("EP%d-FIFO\r\n",epnum);
#endif
		if(event & (MCF_USB_EPISR_FU | MCF_USB_EPISR_EMT
		  | MCF_USB_EPISR_FIFOHI | MCF_USB_EPISR_FIFOLO))
		{
			/* Send message */
			msg[0] = FIFO_EVENT;
			msg[1] = epnum;
			msg[2] = event;
			if(event & MCF_USB_EPISR_FU)
			{
#ifdef USB_DEBUG_PRINT
//				printf("EP%d-FU\r\n",epnum);
#endif
				MCF_USB_EPISR(epnum) = MCF_USB_EPISR_FU;
			}
			if(event & MCF_USB_EPISR_EMT)
			{
#ifdef USB_DEBUG_PRINT
//				printf("EP%d-EMT\r\n",epnum);
#endif
				MCF_USB_EPISR(epnum) = MCF_USB_EPISR_EMT;
			}
			if(event & MCF_USB_EPISR_FIFOHI)
			{
#ifdef USB_DEBUG_PRINT
//				printf("EP%d-FIFOHI\r\n",epnum);
#endif
				MCF_USB_EPISR(epnum) = MCF_USB_EPISR_FIFOHI;
			}
			if(event & MCF_USB_EPISR_FIFOLO)
			{
#ifdef USB_DEBUG_PRINT
//				printf("EP%d-FIFOLO\r\n",epnum);
#endif
				MCF_USB_EPISR(epnum) = MCF_USB_EPISR_FIFOLO;
			}			
//			xNeedSwitch = xQueueSendFromISR(queue_service, msg, xNeedSwitch);
		}
		if(event & MCF_USB_EPISR_ERR)
		{
#ifdef USB_DEBUG_PRINT
			printf("EP%d-ERR 0x%04x 0x%04x\r\n",epnum,event,subevent);
#endif
			if(subevent & MCF_USB_EPFSR_IP)
			{
#ifdef USB_DEBUG_PRINT
				printf("EP%d-IP\r\n",epnum);
#endif
				MCF_USB_EPFSR(epnum) = MCF_USB_EPFSR_IP;
			}
			if(subevent & MCF_USB_EPFSR_TXW)
			{
#ifdef USB_DEBUG_PRINT
				printf("EP%d-TXW\r\n",epnum);
#endif
				MCF_USB_EPFSR(epnum) = MCF_USB_EPFSR_TXW;
			}
			if(subevent & MCF_USB_EPFSR_FAE)
			{
#ifdef USB_DEBUG_PRINT
				printf("EP%d-FAE\r\n",epnum);
#endif
 	    	MCF_USB_EPFSR(epnum) = MCF_USB_EPFSR_FAE;
			}
			if(subevent & MCF_USB_EPFSR_RXW)
			{
#ifdef USB_DEBUG_PRINT
				printf("EP%d-RXW\r\n",epnum);
#endif
				MCF_USB_EPFSR(epnum) = MCF_USB_EPFSR_RXW;
			}
			if(subevent & MCF_USB_EPFSR_UF)
			{
#ifdef USB_DEBUG_PRINT
				printf("EP%d-UF\r\n",epnum);
#endif
				MCF_USB_EPFSR(epnum) = MCF_USB_EPFSR_UF;
			}
			if(subevent & MCF_USB_EPFSR_OF)
			{
#ifdef USB_DEBUG_PRINT
				printf("EP%d-OF\r\n",epnum);
#endif
				MCF_USB_EPFSR(epnum) = MCF_USB_EPFSR_OF;
			}
			MCF_USB_EPISR(epnum) = MCF_USB_EPISR_ERR;
		}
	}
	if(event & MCF_USB_EPISR_EOF)
	{
#ifdef USB_DEBUG_PRINT
//		printf("EP%d-EOF\r\n",epnum);
#endif  
		/* Clear the EOF interrupt */
		MCF_USB_EPISR(epnum) = MCF_USB_EPISR_EOF;
		/* Send service message */
		if(MCF_USB_EPSTAT(epnum) & MCF_USB_EPSTAT_DIR)
		{
#if 0
			if((ep[epnum].buffer.position >= ep[epnum].buffer.length)
			 && (ep[epnum].buffer.free == FALSE))
				/* Transfer is complete */
			{
				if((epnum == 0) && ep[0].zlp)
				{
					/* Enable the USB device controller to send a ZLP */
					MCF_USB_EPINSR(epnum) |= MCF_USB_EPINSR_TXZERO;
					/* 
					 * TXZERO is automatically cleared by hardware for EP0
					 * The ZLP flag can be cleared immediately
					 */
					ep[0].zlp = FALSE;
				}
				else if(ep[epnum].zlp)
				{
					/* Enable the USB device controller to send a ZLP */
					MCF_USB_EPINSR(epnum) |= MCF_USB_EPINSR_TXZERO;
					/* Enable the ACK interrupt so we'll know when to turn it off */
					MCF_USB_USBAISR &= ~MCF_USB_USBAISR_ACK;
					MCF_USB_USBAIMR &= ~MCF_USB_USBAIMR_ACKEN;
				}
				/* Call the Tx Handler */
				usb_ep_tx_done(epnum);
				ep[epnum].buffer.start = NULL;
				ep[epnum].buffer.length = 0;
				ep[epnum].buffer.position = 0;
				ep[epnum].buffer.free = 0;
				usb_endpoint(epnum, NULL, 0);
			}
			else
#endif
			{
				msg[0] = IN_SERVICE_EOF;  /* IN Endpoint */
				msg[1] = epnum;
				msg[2] = 0;
				xNeedSwitch = xQueueSendFromISR(queue_service, msg, xNeedSwitch);
			}
		}
		else /* OUT Endpoint */
		{
			/* Read the Data Present register */
			uint32 fifo_data = (MCF_USB_EPSTAT(epnum) & 0x0FFF0000) >> 16;
			if(ep[epnum].buffer.start == NULL)
			{
				/* There is no existing buffer -- allocate one now */
				ep[epnum].buffer.start = &buf_rx_int[epnum * BUFFER_SIZE];
				ep[epnum].buffer.free = FALSE;
				ep[epnum].buffer.length = BUFFER_SIZE;
				ep[epnum].buffer.position = 0;
			}
			if((ep[epnum].buffer.position + fifo_data) <= ep[epnum].buffer.length)
			{
				/* Read the data from the FIFO into the buffer */
				usb_read_fifo(epnum, &ep[epnum].buffer.start[ep[epnum].buffer.position], fifo_data);
				/* Increment buffer position */
				ep[epnum].buffer.position += fifo_data;
				if(ep[epnum].buffer.position == ep[epnum].buffer.length)
				{
					msg[0] = OUT_SERVICE_EOF; /* OUT Endpoint */
					msg[1] = epnum;
					msg[2] = ep[epnum].buffer.position;
					xNeedSwitch = xQueueSendFromISR(queue_service, msg, xNeedSwitch);
				}
			}
		}
	}
	if(event & MCF_USB_EPISR_EOT)
  {
#ifdef USB_DEBUG_PRINT
//		printf("EP%d-EOT\r\n",epnum);
#endif
		/* The current transfer is complete */
		/* Clear the EOT Interrupt bits */
		MCF_USB_EPISR(epnum) = MCF_USB_EPISR_EOT;
		/* Send service message */
		msg[0] = OUT_SERVICE_EOT;
		msg[1] = epnum;
		msg[2] = 0;
		xNeedSwitch = xQueueSendFromISR(queue_service, msg, xNeedSwitch);
	}
	return(xNeedSwitch);
}

void usb_service_task(void *pvParameters)
{
	uint32 i, j, byte_counter, fifo_data, free_space, epnum, event;
	static uint32 msg[3];
	uint8 *buffer, *buffer_to_free;
	int packet_boundary;
	uint8 flags, config, interface, alt_setting;
	USB_DEVICE_DESC *pDevDesc;
	USB_DEVICE_QUALIFIER_DESC *pDevQualDesc;
	USB_CONFIG_DESC *pCfgDesc;
	USB_INTERFACE_DESC *pIfcDesc = NULL;
	USB_ENDPOINT_DESC *pEpDesc;
	STR_DESC *pStrDesc;
	uint32 iDevDesc, iCfgDesc, iIfcDesc, iEpDesc, iStrDesc, iDevQualDesc;
	uint8 bmRequestType, bRequest;
	uint16 wValue, wIndex, wLength;
	uint8 wValueUpper, wValueLower;
	uint32 CfgDescReqSize;
	if(pvParameters);
	while(1)
	{
wait_event_task:
		if(xQueueAltReceive(queue_service, msg, portMAX_DELAY) != pdTRUE)
			continue;
		switch(msg[0])
		{
			case BUSCHG_NOTICE:
				usb_buschg_notice(msg[1], hs);
#ifdef USB_DEBUG_PRINT
				printf("BUSCHG_NOTICE %s %s\r\n",
				 (msg[1] == RESET) ? "RESET" : (msg[1] == RESUME) ? "RESUME" : "SUSPEND",
				 (MCF_USB_SPEEDR == MCF_USB_SPEEDR_HS) ? "High-Speed" : (MCF_USB_SPEEDR == MCF_USB_SPEEDR_FS)	? "Full-Speed" : "");
#endif
				vTaskDelay(1); /* !? for some HOSTs */
				break;

			case SETUP_SERVICE:
				bmRequestType = (uint8)(msg[1] >> 24);
				bRequest = (uint8)(msg[1] >> 16);
				wValue = (uint16)msg[1];
				wIndex = (uint16)(msg[2] >> 16);
				wLength = (uint16)msg[2];
				wValueUpper = (uint8)(wValue >> 8);
				wValueLower = (uint8)wValue;
				config = interface = alt_setting = flags = 0;
#ifdef USB_DEBUG_PRINT
				if(debug_usb)
				printf("SETUP_SERVICE bmRequestType:%x, bRequest:%x, wValue:%x, wIndex:%x, wLength:%x\r\n",
				 bmRequestType, bRequest, wValue, wIndex, wLength);
#endif
				vTaskDelay(1); /* !? for some HOSTs */
				switch(bRequest)
				{
					case GET_DESCRIPTOR:
						switch(wValueUpper)
						{
							/* Device Descriptor (1) */
							case TYPE_DEVICE_DESCRIPTOR:
								pDevDesc = (USB_DEVICE_DESC *)usb_get_desc(-1, -1, -1, -1, -1, &iDevDesc);
								/* DADR = 0 for Device Descriptor */
								CfgDescReqSize = (uint32)pDevDesc->bLength;
								if(CfgDescReqSize > (uint32)wLength)
									CfgDescReqSize = (uint32)wLength;
								MCF_USB_DRAMCR = (CfgDescReqSize << 16) | iDevDesc;
								MCF_USB_DRAMCR |= MCF_USB_DRAMCR_START;
								break;
							/* Configuration Descriptor (2) */
							case TYPE_CONFIGURATION_DESCRIPTOR:
								pCfgDesc = (USB_CONFIG_DESC *)usb_get_desc(wValueLower, -1, -1, -1, -1, &iCfgDesc);
								CfgDescReqSize = ((uint32)pCfgDesc->wTotalLengthH << 8) | (uint32)pCfgDesc->wTotalLengthL;
								if(CfgDescReqSize > (uint32)wLength)
									CfgDescReqSize = (uint32)wLength;
								MCF_USB_DRAMCR = (CfgDescReqSize << 16) | iCfgDesc;
								MCF_USB_DRAMCR |= MCF_USB_DRAMCR_START;
								break;
							/* String Descriptor (3) */
							case TYPE_STRING_DESCRIPTOR:
								/* Make sure the index is within a defined range */
								if(wValueLower > NUM_STRING_DESC)
								{
									pStrDesc = (STR_DESC *)string_desc;
									MCF_USB_DRAMCR = ((uint32)pStrDesc->bLength << 16) | usb_get_string_desc_base();
								}
								else
								{
									pStrDesc = (STR_DESC *)usb_get_string_descriptor(wValueLower, wIndex, wLength, &iStrDesc);
									MCF_USB_DRAMCR = ((uint32)pStrDesc->bLength << 16) | (usb_get_string_desc_base() + iStrDesc);
								}
								MCF_USB_DRAMCR |= MCF_USB_DRAMCR_START;
								break;
							/* Interface Descriptor (4) */
							case TYPE_INTERFACE_DESCRIPTOR:
								pIfcDesc = (USB_INTERFACE_DESC *)usb_get_desc(MCF_USB_CFGR, -1,
								 wValueLower, (MCF_USB_IFR(wValueLower)&0x00FF), -1, &iIfcDesc);
								MCF_USB_DRAMCR = ((uint32)wLength << 16) | iIfcDesc;
								MCF_USB_DRAMCR |= MCF_USB_DRAMCR_START;
								break;
							/* Endpoint Descriptor (5) */
							case TYPE_ENDPOINT_DESCRIPTOR:
								pEpDesc = (USB_ENDPOINT_DESC *)usb_get_desc(MCF_USB_CFGR, -1,
								 ((*pCurrentInterface&0xFF00)>>8), (*pCurrentInterface&0x00FF), wValueLower, &iEpDesc);
								MCF_USB_DRAMCR = ((uint32)wLength << 16) | iEpDesc;
								MCF_USB_DRAMCR |= MCF_USB_DRAMCR_START;
								break;
							/* Device Qualifier Descriptor (6) */
							case TYPE_DEVICE_QUALIFIER_DESCRIPTOR:
								pDevQualDesc = (USB_DEVICE_QUALIFIER_DESC *)usb_get_desc(-1, 1, -1, -1, -1, &iDevQualDesc);
								MCF_USB_DRAMCR = ((uint32)wLength << 16) | iDevQualDesc;
								MCF_USB_DRAMCR |= MCF_USB_DRAMCR_START;
								break;
							default:
								/* All other GET_DESCRIPTOR types */
								usb_vendreq_service(bmRequestType, bRequest, wValue, wIndex, wLength);
								break;
						}
						break;
					case SET_DESCRIPTOR:
						flags |= DESCRIPTOR_CHG;
						break;
					case SET_CONFIGURATION:
						flags |= CONFIGURATION_CHG;
						break;				
					case SET_INTERFACE: /* or Device Class Specific */
						if(bmRequestType == 0x1)
							flags |= INTERFACE_CHG;
						else
							usb_vendreq_service(bmRequestType, bRequest, wValue, wIndex, wLength);
						break;
					default:
						/* Any other requests */
						usb_vendreq_service(bmRequestType, bRequest, wValue, wIndex, wLength);
						break;
				}
				/* Handle SET_DESCRIPTOR command */
				if(flags & DESCRIPTOR_CHG)
				{
					/* Set CCOMP and send ZLP for the next IN */
					MCF_USB_EP0SR |= (MCF_USB_EP0SR_TXZERO | MCF_USB_EP0SR_CCOMP);
					switch(wValueUpper)
					{
						case DEVICE:
							printf("SET_DESCRIPTOR - Device type\r\n");
							break;
						case CONFIGURATION:
							printf("SET_DESCRIPTOR - Config type\r\n");
							break;
						case INTERFACE:
							printf("SET_DESCRIPTOR - Interface type\r\n");
							break;
						case ENDPOINT:
							pEpDesc = (USB_ENDPOINT_DESC *)usb_get_desc(MCF_USB_CFGR, -1,
							 ((*pCurrentInterface&0xFF00)>>8), (*pCurrentInterface&0x00FF), wValueLower, &iEpDesc);
							/* Clear USBCR_RAMEN to allow access to descriptor RAM */
							MCF_USB_USBCR &= ~MCF_USB_USBCR_RAMEN;
							/* DRAMCR[DADR] */
							MCF_USB_DRAMCR = iEpDesc;
							/* Load the Descriptor RAM with the descriptors */
							for(i = 0; i < wLength; i++)
								MCF_USB_DRAMDR = MCF_USB_EPFDR_8(0);
							/* Re-enable descriptor RAM */
							MCF_USB_USBCR |= MCF_USB_USBCR_RAMEN;
							break;
						case DEVICE_QUALIFIER:
							printf("SET_DESCRIPTOR - DQ type\r\n");
							break;
						case STRING:
							printf("SET_DESCRIPTOR - String type\r\n");
							break;
						default:
							printf("Unhandled SET_DESCRIPTOR type.\r\n");
							break;
					}
					pEpDesc = (USB_ENDPOINT_DESC *)usb_get_desc(-1, -1, -1, -1, wValueLower, &iEpDesc);
				}
				/* Handle Interface and Configuration changes */
				if(flags & (INTERFACE_CHG | CONFIGURATION_CHG))
				{
					/* Lock out the core */
					 MCF_USB_USBCR |= MCF_USB_USBCR_APPLOCK;
					/* Start by marking all Endpoints as disabled and inactive (except EP0) */
					for(i = 1; i < NUM_ENDPOINTS; i++)
					{
						ep[i].ttype = DISABLED;
						if(ep[i].dir == IN)
							MCF_USB_EPINSR(i) &= ~MCF_USB_EPINSR_ACTIVE;
						else
							MCF_USB_EPOUTSR(i) &= ~MCF_USB_EPOUTSR_ACTIVE;
					}
					/* Okay to allow access by the core again */
					MCF_USB_USBCR &= ~MCF_USB_USBCR_APPLOCK;
					if(flags & CONFIGURATION_CHG)
					{
						config = wValueLower;
						/* Get pointer to active Configuration descriptor */
						pCfgDesc = (USB_CONFIG_DESC *)usb_get_desc(config, -1, -1, -1, -1, &iCfgDesc);
						/* If the requested configuration is valid, set the CFGR accordingly */
						if(!pCfgDesc)
						{
							printf("**ERROR: Requested Configuration is not valid.\r\n");
							goto wait_event_task;
						}
						else
							MCF_USB_CFGR = config;
						/* Point to the default interface descriptor */
						pIfcDesc = (USB_INTERFACE_DESC *)usb_get_desc(config, -1, 0, 0, -1, &iIfcDesc);
						/* Iterate through all the valid Interfaces in this configuration */
						for(i = 0; i < pCfgDesc->bNumInterfaces; i++)
							/* Configure IFRn registers */
							MCF_USB_IFR(i) = i << 8;
						/* Set pCurrentInterface to default interface (IFC #0) */
						pCurrentInterface = &MCF_USB_IFR0;
						interface = 0;
						alt_setting = *pCurrentInterface & 0x00FF;
					}
					else if(flags & INTERFACE_CHG)
					{
						config = MCF_USB_CFGR;
						/* Get pointer to active Configuration descriptor */
						pCfgDesc = (USB_CONFIG_DESC *)usb_get_desc(config, -1, -1, -1, -1, &iCfgDesc);
						/* If the requested configuration is valid, set the CFGR accordingly */
						if(!pCfgDesc)
						{
							printf("**ERROR: Requested Configuration is not valid.\r\n");
							goto wait_event_task;
						}
						/* Update the interface and set pCurrentInterface to the IFC/AltSet requested by the interface change */
						MCF_USB_IFUR = ((wIndex<<8) | (wValue));
						pCurrentInterface = &MCF_USB_IFR(wIndex);
						interface = (*pCurrentInterface & 0xFF00) >> 8;
						alt_setting = *pCurrentInterface & 0x00FF;
						/* Point to the default interface descriptor */
						pIfcDesc = (USB_INTERFACE_DESC *)usb_get_desc(config, -1, interface, alt_setting, -1, &iIfcDesc);
					}
					else
						printf("**ERROR: Invalid change type.\r\n");
					/* Iterate through all the valid Endpoints in this interface */
					/* 
					 * To do:
					 * All interfaces are active for the current configuration so all
					 * interface/alt-settings need to be iterated and all endpoints in
					 * those interfaces need to be enabled.
					 */
					for(i = 0; i < pIfcDesc->bNumEndpoints; i++)
					{
						/* Get pointer to valid endpoint descriptor */
						pEpDesc = (USB_ENDPOINT_DESC *)usb_get_desc(config, -1, interface, alt_setting, i+1, &iEpDesc);
						if(pEpDesc)
						{
							epnum = (uint32)pEpDesc->bEndpointAddress & 0x0F;
							/* See if this Endpoint is already active */
							if(MCF_USB_EPOUTSR(epnum) & MCF_USB_EPOUTSR_ACTIVE)
								goto wait_event_task;
							/* Set the new transfer type */
							ep[epnum].ttype = pEpDesc->bmAttributes;
							/* Set the current direction */
							ep[epnum].dir = pEpDesc->bEndpointAddress & 0x000000F0;
							/* Get the current packet size */
							ep[epnum].packet_size = (uint16)(pEpDesc->wMaxPacketSizeL | (pEpDesc->wMaxPacketSizeH << 8));
							/* No buffer allocated yet */
							ep[epnum].buffer.start = NULL;
							ep[epnum].buffer.position = 0;
							ep[epnum].buffer.length = 0;
							ep[epnum].buffer.free = FALSE;
							/* Set the FIFO length */
							ep[epnum].fifo_length = (uint16)(ep[epnum].packet_size * FIFO_DEPTH);		
							/* Enable EOF and EOT interrupts */
							MCF_USB_EPIMR(epnum) &= ~(MCF_USB_EPIMR_FU | MCF_USB_EPIMR_EMT | MCF_USB_EPIMR_ERR
							 | MCF_USB_EPIMR_FIFOHI | MCF_USB_EPIMR_FIFOLO | MCF_USB_EPIMR_EOF | MCF_USB_EPIMR_EOT);
							/* Configure Endpoint */
							MCF_USB_EPSTAT(epnum) |= MCF_USB_EPSTAT_RST;
							if(ep[epnum].dir == IN)
							{
								MCF_USB_EPINACR(epnum) = ep[epnum].ttype;
								MCF_USB_EPINIFR(epnum) = interface;
								MCF_USB_EPINMPSR(epnum) = MCF_USB_EPINMPSR_ADDTRANS(0) | ep[epnum].packet_size;
							}
							else
							{
								MCF_USB_EPOUTACR(epnum) = ep[epnum].ttype;
								MCF_USB_EPOUTIFR(epnum) = interface;
								MCF_USB_EPOUTMPSR(epnum) = MCF_USB_EPOUTMPSR_ADDTRANS(0) | ep[epnum].packet_size;
							}   
							MCF_USB_EPSTAT(epnum) = ep[epnum].dir;
							MCF_USB_EPFCR(epnum)  = MCF_USB_EPFCR_SHAD | MCF_USB_EPFCR_FRM | MCF_USB_EPFCR_GR(1);
							MCF_USB_EPFAR(epnum)  = ep[epnum].packet_size>>1;    /* Alarm */
						}
						/* Call application specific routine to notify of config/iface change */
						usb_devcfg_notice(flags, wValueLower, pIfcDesc->bAlternateSetting);
					}
					usb_fifo_init(FIFO_PERF);
					/* End of Control command, transmit zero length packet */
//					MCF_USB_EP0SR |= (MCF_USB_EPINSR_TXZERO | MCF_USB_EPINSR_CCOMP);
					MCF_USB_EP0SR |= MCF_USB_EPINSR_CCOMP;
					/* Activate Endpoints */
					for(i = 1; i < NUM_ENDPOINTS; i++)
					{
						if(ep[i].ttype != DISABLED)
						{
							ep[i].state = USB_CONFIGURED;
							if(ep[i].dir == IN)
							{
								if(ep[i].ttype == INTERRUPT)
									MCF_USB_EPINSR(i) = MCF_USB_EPINSR_INT | MCF_USB_EPINSR_ACTIVE;
				        else
									MCF_USB_EPINSR(i) = MCF_USB_EPINSR_ACTIVE;
							}
							else  /* OUT or CONTROL */
								MCF_USB_EPOUTSR(i) = MCF_USB_EPOUTSR_ACTIVE;
						}
					}
					/* Call application specific routine to notify of config/iface change */
					usb_devcfg_notice(flags, wValueLower, -1);
				}
				break;

			case IN_SERVICE_EOF:
				epnum	= msg[1];
#ifdef USB_DEBUG_PRINT
				if(debug_usb)
				printf("IN_SERVICE_EOF EP%d %d %d\r\n", epnum,
				 ep[epnum].buffer.position, ep[epnum].buffer.length);
#endif
				byte_counter = 0;
				packet_boundary = TRUE;
				/* Make sure the entire buffer has been written to the FIFO */
				if(ep[epnum].buffer.position < ep[epnum].buffer.length)
				{
					free_space = ep[epnum].fifo_length - ((MCF_USB_EPSTAT(epnum) & 0x0FFF0000) >> 16);
					for(i = ep[epnum].buffer.position, j = 0; j < free_space;)
					{
						/* Write from the buffer to the FIFO */
						if(((free_space - j) > 3) && ((i + 4) <= ep[epnum].buffer.length))
						{
							MCF_USB_EPFDR_32(epnum) = *(uint32 *)(&ep[epnum].buffer.start[i]);
							i += 4;
							j += 4;
							byte_counter += i;
							/* Next write to FDR is the EOF */
							if((byte_counter == (ep[epnum].packet_size - 4))
							 && (ep[epnum].buffer.length - i >= 4))
								MCF_USB_EPFCR(epnum) |= MCF_USB_EPFCR_WFR;
							/* Reset byte_counter */
							if(byte_counter == (uint32)ep[epnum].packet_size)
								byte_counter = 0;
						}
						else
						{
							MCF_USB_EPFDR_8(epnum) = ep[epnum].buffer.start[i++];
							j++;
							/* Next write to FDR is the EOF */
							if(i == (ep[epnum].buffer.length - 1))
							{
								MCF_USB_EPFCR(epnum) |= MCF_USB_EPFCR_WFR;
								packet_boundary = FALSE;
							}
						}
						if(i >= ep[epnum].buffer.length)
							break;
					}
					ep[epnum].buffer.position = i;
				}
				/* Transfer is complete */
				else
				{
					if((epnum == 0) && ep[0].zlp)
					{
						/* Enable the USB device controller to send a ZLP */
						MCF_USB_EPINSR(epnum) |= MCF_USB_EPINSR_TXZERO;
						/* 
						 * TXZERO is automatically cleared by hardware for EP0
						 * The ZLP flag can be cleared immediately
						 */
						ep[0].zlp = FALSE;
					}
					else if(ep[epnum].zlp)
					{
						/* Enable the USB device controller to send a ZLP */
						MCF_USB_EPINSR(epnum) |= MCF_USB_EPINSR_TXZERO;
						/* Enable the ACK interrupt so we'll know when to turn it off */
						MCF_USB_USBAISR &= ~MCF_USB_USBAISR_ACK;
						MCF_USB_USBAIMR &= ~MCF_USB_USBAIMR_ACKEN;
					}
					if((ep[epnum].buffer.start) && (ep[epnum].buffer.free == TRUE))
					{
						if(epnum == 0)
							usb_vendreq_done(SUCCESS);
						ep[epnum].buffer.free = FALSE;
						vPortFree2(ep[epnum].buffer.start);
					}
					/* Call the Tx Handler */
					usb_ep_tx_done(epnum);
					ep[epnum].buffer.start = NULL;
					ep[epnum].buffer.length = 0;
					ep[epnum].buffer.position = 0;
					ep[epnum].buffer.free = 0;
					fifo_data = usb_endpoint(epnum, NULL, 0);
#ifdef USB_DEBUG_PRINT
					if(debug_usb && fifo_data)
						printf(" %d bytes sent\r\n", fifo_data);
#endif
				}
				break;

			case OUT_SERVICE_EOT:
				epnum	= msg[1];
				/* Read the Data Present register */
				fifo_data =  (MCF_USB_EPSTAT(epnum) & 0x0FFF0000) >> 16;
#ifdef USB_DEBUG_PRINT
				if(debug_usb)
				printf("OUT_SERVICE_EOT EP%d, %d bytes read\r\n", epnum, fifo_data);
#endif
				if(!ep[epnum].buffer.start)
					break; /* Free from EOF */
				if((ep[epnum].buffer.position + fifo_data) <= ep[epnum].buffer.length)
				{
					/* Increment buffer position */
					ep[epnum].buffer.position += fifo_data;	
					/* Read the data from the FIFO into the buffer */
					usb_read_fifo(epnum, &ep[epnum].buffer.start[ep[epnum].buffer.position], fifo_data);
				}
			case OUT_SERVICE_EOF:
				epnum	= msg[1];
#ifdef USB_DEBUG_PRINT
				if(debug_usb && (msg[0] == OUT_SERVICE_EOF))
				printf("OUT_SERVICE_EOF EP%d, %d bytes read\r\n", epnum, msg[2]);
#endif
				buffer = ep[epnum].buffer.start;
				fifo_data = ep[epnum].buffer.position;
				if(ep[epnum].buffer.free == TRUE)
				{
					buffer_to_free = ep[epnum].buffer.start;
					ep[epnum].buffer.free = FALSE;
				}
				else
					buffer_to_free = NULL;
				ep[epnum].buffer.start = NULL;
				ep[epnum].buffer.length = 0;
				ep[epnum].buffer.position = 0;
				/* Handle data in buffer */
				usb_ep_rx_done(epnum, SUCCESS);
				i = usb_endpoint(epnum, buffer, fifo_data); /* can create a new buffer */
#ifdef USB_DEBUG_PRINT
				if(debug_usb && i)
					printf(" %d bytes sent\r\n", i);
#endif
				/* Free the buffer if it was malloc()ed */
				if(buffer_to_free)
				{
#ifdef USB_DEBUG_PRINT
					if(debug_usb)
					printf("OUT_SERVICE_%s EP%d free buffer size %d bytes\r\n",
					 (msg[0] == OUT_SERVICE_EOF) ? "EOF" : "EOT", epnum, fifo_data);
#endif
					vPortFree2(buffer_to_free);
				}
				break;

			case FEATURE_ENDPOINT:
				epnum = msg[1];
				if(msg[2])
				{
#ifdef USB_DEBUG_PRINT
					printf("EP%d HALT\r\n", epnum);
#endif
					usb_ep_halt(epnum);
				}
				else
				{
#ifdef USB_DEBUG_PRINT
					printf("EP%d unHALT\r\n", epnum);
#endif
					usb_ep_unhalt(epnum);
				}
				break;

			case FIFO_EVENT:
				epnum = msg[1];
				event = msg[2];
#ifdef USB_DEBUG_PRINT
				if(debug_usb)
				printf("FIFO_EVENT EP%d: ", epnum);
#endif
				if(event & MCF_USB_EPISR_FU)
				{
#ifdef USB_DEBUG_PRINT
				if(debug_usb)
				printf("FULL ");
#endif
					usb_fifo_event(epnum, FULL);
				}
				if(event & MCF_USB_EPISR_EMT)
				{
#ifdef USB_DEBUG_PRINT
				if(debug_usb)
				printf("EMPTY ");
#endif
					usb_fifo_event(epnum, EMPTY);
				}	
				if(event & MCF_USB_EPISR_FIFOHI)
				{
#ifdef USB_DEBUG_PRINT
				if(debug_usb)
				printf("FIFOHI ");
#endif
					usb_fifo_event(epnum, FIFOHI);
				}
				if(event & MCF_USB_EPISR_FIFOLO)
				{
#ifdef USB_DEBUG_PRINT
				if(debug_usb)
				printf("FIFOLO ");
#endif
					usb_fifo_event(epnum, FIFOLO);
				}
#ifdef USB_DEBUG_PRINT
				if(debug_usb)
				printf("\r\n");
#endif
				break;			
		}
	}
}

void usb_vendreq_done(int success)
{
	if(success != SUCCESS)
		/* This sends a single STALL as the handshake */
		MCF_USB_EP0SR |= (MCF_USB_EP0SR_CCOMP | MCF_USB_EP0SR_PSTALL);
	else
		MCF_USB_EP0SR |= MCF_USB_EP0SR_CCOMP;
	if(MCF_USB_EP0SR & MCF_USB_EP0SR_PSTALL)
		printf("set STALL\r\n");
	if(MCF_USB_EP0SR & MCF_USB_EP0SR_HALT)
		printf("HALT set too\r\n");
}

void usb_sort_ep_array(USB_EP_STATE *list[], int n)
{
	/* Simple bubble sort function called by usb_fifo_init() */
	int i, pass, sorted;
	USB_EP_STATE *temp;
	pass = 1;
	do
	{
		sorted = 1;
		for(i = 0; i < n - pass; ++i)
		{
			if(list[i]->fifo_length < list[i+1]->fifo_length )
			{
				/* Exchange out-of-order pair */
				temp = list[i];
				list[i] = list[i + 1];
				list[i+1] = temp;
				sorted = 0;
			}
		}
		pass++;
	}
	while(!sorted);
}

void usb_make_power_of_two(uint32 *size)
{
	/* Called by usb_fifo_init() */
	int i, not_power_of_two = 0;
	uint32 new_size = *size;
	for(i = 0; new_size != 1; i++)
	{
		if(new_size & 0x0001)
			not_power_of_two = 1;
		new_size >>= 1;
	}
	new_size = 1 << (i + not_power_of_two);
	if(new_size > 1024)
		new_size = 1024;  
	*size = new_size;
}

void usb_fifo_init(int fPerfMode)
{
	USB_EP_STATE *pIN[NUM_ENDPOINTS];
	USB_EP_STATE *pOUT[NUM_ENDPOINTS];
	vuint8 nIN, nOUT, i;
	vuint32 INpos, OUTpos;
	/* Endpoint 0 is always present and bi-directional */
	pIN[0] = &ep[0];
	pOUT[0] = &ep[0];
	nIN = nOUT = 1;
	/* Sort the active endpoints by direction */
	for(i = 1; i < NUM_ENDPOINTS; i++)
	{
		if(ep[i].ttype != DISABLED)
		{
			if(ep[i].dir == IN)
				pIN[nIN++] = &ep[i];
			else
				pOUT[nOUT++] = &ep[i];
		}
	}
	/* Make sure FIFO size is a power of 2; if not, make it so */
	for(i = 0; i < nIN; i++)
		usb_make_power_of_two(&(pIN[i]->fifo_length));
	for(i = 0; i < nOUT; i++)
		usb_make_power_of_two(&(pOUT[i]->fifo_length));
	/* Calculate the FIFO address for each endpoint */
	if(fPerfMode)
	{
		INpos = 0;
		OUTpos = 0x800;
		for(i = 0; i < nIN; i++)
		{
			pIN[i]->in_fifo_start = INpos;
			INpos += pIN[i]->fifo_length;
		}
		for(i = 0; i < nOUT; i++)
		{
			pOUT[i]->out_fifo_start = OUTpos;
			OUTpos += pOUT[i]->fifo_length;
		}
	}
	else /* flexibility */
	{
		INpos = 0;
		for(i = 0; i < nIN; i++)
		{
			pIN[i]->in_fifo_start = INpos;
			INpos += pIN[i]->fifo_length;
		}
		OUTpos = INpos;
		for(i = 1; i < nOUT; i++)
		{
			pOUT[i]->out_fifo_start = OUTpos;
			OUTpos += pOUT[i]->fifo_length;
		}
	}
	/* Init FIFO configuration registers and flush FIFOs */
	MCF_USB_EPFRCFGR(0) = MCF_USB_EPFRCFGR_BASE(ep[0].in_fifo_start) | MCF_USB_EPFRCFGR_DEPTH(ep[0].fifo_length);
	MCF_USB_EPSTAT(0) |= MCF_USB_EPSTAT_FLUSH;
	for(i = 1; i < NUM_ENDPOINTS; i++)
	{
		if(ep[i].dir == IN)
			MCF_USB_EPFRCFGR(i) = MCF_USB_EPFRCFGR_BASE(ep[i].in_fifo_start) | MCF_USB_EPFRCFGR_DEPTH(ep[i].fifo_length);
		else
			MCF_USB_EPFRCFGR(i) = MCF_USB_EPFRCFGR_BASE(ep[i].out_fifo_start) | MCF_USB_EPFRCFGR_DEPTH(ep[i].fifo_length);
		MCF_USB_EPSTAT(i) |= MCF_USB_EPSTAT_FLUSH;
	}
}

uint32 usb_tx_data(uint32 epnum, uint8 *start, uint32 length)
{
	uint32 i, buffer_length;
	int byte_counter = 0;
	int packet_boundary = FALSE;
	uint32 imrl_saved, packet_size, num_packets;
	uint32 *buf;
	/* Check the bounds on epnum */
	if(epnum >= NUM_ENDPOINTS)
		return(USB_CMD_FAIL);
	/* Exit, if device is reset */
	if((epnum != 0) && (ep[epnum].state == USB_DEVICE_RESET))
		return(USB_DEVICE_RESET);
	/* Make sure the EP is not currently busy */
//	if(ep[epnum].buffer.start || 
//	 MCF_USB_EPSTAT(epnum) & MCF_USB_EPSTAT_BYTECNT(0xFFF))
//	return(USB_CMD_FAIL);
	/* Make sure there is data to send */
	if(!start)
		return(USB_CMD_FAIL);
	if(!length)
		return(USB_CMD_SUCCESS);
	/* Make sure this is an IN endpoint */
	if(epnum  && (ep[epnum].dir != IN))
//	if(epnum && !(MCF_USB_EPSTAT(epnum) & MCF_USB_EPSTAT_DIR))
		return(USB_CMD_FAIL);
	/* Make sure this EP is not HALTed */
	if(MCF_USB_EPINSR(epnum) & MCF_USB_EPINSR_HALT)
		return(USB_CMD_FAIL);
	/* Temporarily disable USB interrupts */
	imrl_saved = MCF_INTC_IMRL;
	MCF_INTC_IMRL |= (MCF_INTC_IMRL_INT_MASK24 | MCF_INTC_IMRL_INT_MASK23
	              | MCF_INTC_IMRL_INT_MASK22 | MCF_INTC_IMRL_INT_MASK21
	              | MCF_INTC_IMRL_INT_MASK20 | MCF_INTC_IMRL_INT_MASK19
	              | MCF_INTC_IMRL_INT_MASK18 | MCF_INTC_IMRL_INT_MASK17
	              | MCF_INTC_IMRL_INT_MASK16 | MCF_INTC_IMRL_INT_MASK15);
	/* Setup the EP Buffer structure */
	ep[epnum].buffer.start = start;
	ep[epnum].buffer.length = length;
	ep[epnum].buffer.position = 0;
	buf = (uint32 *)ep[epnum].buffer.start;
	buffer_length = ep[epnum].buffer.length; 
	packet_size = ep[epnum].packet_size;
	if(buffer_length > length)
		num_packets = length / packet_size;
	else
		num_packets = buffer_length / packet_size;	
	i = 0;
	if(num_packets && (packet_size <= 64))
	{
		for(i = 0; i < num_packets; i++)
		{
			switch(packet_size)
			{
				case 64:
					MCF_USB_EPFDR_32(epnum) = *buf++;
					MCF_USB_EPFDR_32(epnum) = *buf++;
					MCF_USB_EPFDR_32(epnum) = *buf++;
					MCF_USB_EPFDR_32(epnum) = *buf++;
					MCF_USB_EPFDR_32(epnum) = *buf++;
					MCF_USB_EPFDR_32(epnum) = *buf++;
					MCF_USB_EPFDR_32(epnum) = *buf++;
					MCF_USB_EPFDR_32(epnum) = *buf++;
				case 32:
					MCF_USB_EPFDR_32(epnum) = *buf++;
					MCF_USB_EPFDR_32(epnum) = *buf++;
					MCF_USB_EPFDR_32(epnum) = *buf++;
					MCF_USB_EPFDR_32(epnum) = *buf++;
				case 16:
					MCF_USB_EPFDR_32(epnum) = *buf++;
					MCF_USB_EPFDR_32(epnum) = *buf++;
				case 8:
					MCF_USB_EPFDR_32(epnum) = *buf++;
					/* Next write to FDR is the EOF */
					MCF_USB_EPFCR(epnum) |= MCF_USB_EPFCR_WFR;
					MCF_USB_EPFDR_32(epnum) = *buf++;
					break;		
			}
		}
		i *= packet_size;
		if(i < buffer_length)
			packet_boundary = TRUE;
	}
	while(i < length)
	{
		if((buffer_length - i) <= 4)
		{
			/* Next write to FDR is the EOF */
			if(i == (buffer_length - 1))
				MCF_USB_EPFCR(epnum) |= MCF_USB_EPFCR_WFR;
			MCF_USB_EPFDR_8(epnum) = ep[epnum].buffer.start[i++];
		}
		else
		{
			/* Next write to FDR is the EOF */
			if(byte_counter == (packet_size - 4))
				MCF_USB_EPFCR(epnum) |= MCF_USB_EPFCR_WFR;
			MCF_USB_EPFDR_32(epnum) = *buf++;
			i += 4;
			byte_counter += 4;
			/* Reset byte_counter */
			if(byte_counter == packet_size)
			{
				byte_counter = 0;
				packet_boundary = TRUE;
			}
		}
		if(i == buffer_length)
			break;
	}
	/* 
	 * If buffer is aligned to a packet boundary, a ZLP will be needed to
	 * terminate the transfer.
	 */
	if(packet_boundary)
		ep[epnum].zlp = TRUE;
	ep[epnum].buffer.position = i;
	/* Restore USB interrupts */
	MCF_INTC_IMRL = imrl_saved;
	return(USB_CMD_SUCCESS);
}

uint32 usb_rx_data(uint32 epnum, uint8 *start, uint32 length)
{
	int i, buffer_length;
	uint32 imrl_saved, packet_size;
	uint32 *buf;
	/* Check the bounds on epnum */
	if(epnum >= NUM_ENDPOINTS)
		return(USB_CMD_FAIL);
	/* Exit, if device is reset */
	if((epnum != 0) && (ep[epnum].state == USB_DEVICE_RESET))
		return(USB_DEVICE_RESET);
	/* Make sure there is data to send */
	if(!start)
		return(USB_CMD_FAIL);
	if(!length)
		return(USB_CMD_SUCCESS);
	/* Make sure this is an OUT endpoint */
	if(epnum  && (ep[epnum].dir != OUT))
//	if(epnum && (MCF_USB_EPSTAT(epnum) & MCF_USB_EPSTAT_DIR))
		return(USB_CMD_FAIL);
	/* Make sure this EP is not HALTed */
	if(MCF_USB_EPINSR(epnum) & MCF_USB_EPINSR_HALT)
		return(USB_CMD_FAIL);
	/* Temporarily disable USB interrupts */
	imrl_saved = MCF_INTC_IMRL;
	MCF_INTC_IMRL |= (MCF_INTC_IMRL_INT_MASK24 | MCF_INTC_IMRL_INT_MASK23
	              | MCF_INTC_IMRL_INT_MASK22 | MCF_INTC_IMRL_INT_MASK21
	              | MCF_INTC_IMRL_INT_MASK20 | MCF_INTC_IMRL_INT_MASK19
	              | MCF_INTC_IMRL_INT_MASK18 | MCF_INTC_IMRL_INT_MASK17
	              | MCF_INTC_IMRL_INT_MASK16 | MCF_INTC_IMRL_INT_MASK15);
	/* Setup the EP Buffer structure */
	ep[epnum].buffer.start = start;
	ep[epnum].buffer.length = length;
	ep[epnum].buffer.position = 0;
	buf = (uint32 *)ep[epnum].buffer.start;
	buffer_length = ep[epnum].buffer.length; 
	packet_size = ep[epnum].packet_size;
	i = 0;
	while(i < length)
	{
		if((buffer_length - i) <= 3)
			ep[epnum].buffer.start[i++] = MCF_USB_EPFDR_8(epnum);
		else
		{
			*buf++ = MCF_USB_EPFDR_32(epnum);
			i += 4;
		}
		if(i == buffer_length)
		{
			ep[epnum].buffer.start = NULL;
			ep[epnum].buffer.length = 0;
			ep[epnum].buffer.position = 0;		
			/* Notify client application about completion of transfer */
			usb_ep_rx_done(epnum, SUCCESS);
			break;
		}
	}
	if(i != buffer_length)
		ep[epnum].buffer.position = i;
	/* Restore USB interrupts */
	MCF_INTC_IMRL = imrl_saved;
	return(USB_CMD_SUCCESS);
}

uint32 usb_set_rx_buffer(uint32 epnum, uint32 size)
{
	if(size)
	{
		if(ep[epnum].buffer.start)
		{
#ifdef USB_DEBUG_PRINT
			printf("usb_set_rx_buffer not empty");
#endif		
			return(FALSE);
		}
		if(size <= BUFFER_SIZE)
		{
			ep[epnum].buffer.start = &buf_rx_int[epnum * BUFFER_SIZE];
			ep[epnum].buffer.free = FALSE;
			ep[epnum].buffer.length = size;
			ep[epnum].buffer.position = 0;
			return(TRUE);
		}
		ep[epnum].buffer.start = (uint8 *)pvPortMalloc2(size);
		if(ep[epnum].buffer.start)
		{
			ep[epnum].buffer.free = TRUE;
			ep[epnum].buffer.length = size;
			ep[epnum].buffer.position = 0;
			return(TRUE);
		}
#ifdef USB_DEBUG_PRINT
		printf("usb_set_rx_buffer out of memory");
#endif		
		return(FALSE);
	}
	return(TRUE);
}

uint8 *usb_get_desc(int8 config, int8 dev_qual, int8 iface, int8 setting, int8 ep, uint32 *DescPtr)
{
	/* Note:
	 * ep is the offset and not the physical endpoint number
	 * In order to get the config desc pointer, specify -1 for
	 * all other inputs except config
	 * In order to get the interface/alternate setting desc pointer,
	 * specify -1 for epNum
	 */
	/* 
	 * To do:
	 * This isn't exactly correct - An endpoint is not shared among
	 * interfaces within a single configuration unless the endpoint is
	 * used by alternate settings of the same interface.  This routine
	 * needs to allow for an EP descriptor search without specifing an
	 * interface.  All interfaces of a configuration are active all the 
	 * time (or, at least one alternate setting of all interfaces is 
	 * active at any given time).  So, the Host could request an EP 
	 * descriptor from any interface and this routine needs to be smart
	 * enough to pick out the EP from all the active interfaces and it
	 * must be aware of which alternate settings are in affect for each
	 * interface
	 */
	int i;
	uint8 *pDesc;
	if(hs)
		pDesc = (uint8 *)&DescriptorsHS;
	else
		pDesc = (uint8 *)&Descriptors;
	*DescPtr = 0;
	if(config != -1)
	{
		if(config > ((USB_DEVICE_DESC *)pDesc)->bNumConfigurations)
			return(0);
		/* Allow for non-standard desc between device and config desc */
		while(pDesc[1] != CONFIGURATION)
		{
			*DescPtr += (uint32)pDesc[0];
			pDesc += pDesc[0];
		}
		/* pDesc now points to the first Config descriptor */
		for(i = 1; i < config;)
		{
			*DescPtr += (uint32)pDesc[0];
			pDesc += pDesc[0];
			if(pDesc[1] == CONFIGURATION)
				i++;
		}
		/* pDesc now points to the correct Configuration descriptor */
		if((iface != -1) && (setting != -1))
		{
			if(iface >= ((USB_CONFIG_DESC *)pDesc)->bNumInterfaces)
				return(0);
			/* Allow for non-standard desc between config and iface desc */
			while(pDesc[1] != INTERFACE)
			{
				*DescPtr += (uint32)pDesc[0];
				pDesc += pDesc[0];
			}
			/* pDesc now points to first Interface descriptor */
			for(i = 0; i < iface;)
			{
				*DescPtr += (uint32)pDesc[0];
				pDesc += pDesc[0];
				if(pDesc[1] == INTERFACE && pDesc[3] == 0)
					i++;
			}
			/* pDesc now points to correct Interface descriptor */
			for(i = 0; i < setting;)
			{
				*DescPtr += (uint32)pDesc[0];
				pDesc += pDesc[0];
				if(pDesc[1] == INTERFACE)
				{
					if(pDesc[2] != iface)
						return(0);
					else
						i++;
				}
			}
			/* pDesc now points to correct Alternate Setting descriptor */
			if(ep != -1)
			{
				if(ep > pDesc[4])
					return(0);
				/* Allow for non-standard desc between iface and ep desc */
				while(pDesc[1] != ENDPOINT)
				{
					*DescPtr += (uint32)pDesc[0];
					pDesc += pDesc[0];
				}             
				/* pDesc now points to first Endpoint descriptor */
			  for(i = 1; i < ep;)
				{
					*DescPtr += (uint32)pDesc[0];
					pDesc += pDesc[0];
					if(pDesc[1] == ENDPOINT)
						i++;
				}
				/* pDesc now points to the correct Endpoint descriptor */
			}
		}
	}
	if(dev_qual != -1)
	{
		if(hs)
			pDesc = (uint8 *)&DescriptorsHS;
		else
			pDesc = (uint8 *)&Descriptors;
		*DescPtr = 0;
		while(pDesc[1] != DEVICE_QUALIFIER)
		{
			*DescPtr += (uint32)pDesc[0];
			pDesc += pDesc[0];
			if(*pDesc == (uint8)usb_get_desc_size())
				return(0);
		}
	}  
	return(pDesc);
}

uint8 *usb_get_string_descriptor(uint8 index, uint16 langage_id, uint16 wLength, uint32 *DescPtr)
{
	int i, found = FALSE;
	uint8 *pDesc = string_desc;
	if(wLength);
	*DescPtr = 0;
	for(i = 0; i < NUM_LANGUAGES; i++)
	{
		if((pDesc[(i * 2) + 2] == (langage_id & 0xFF))
		 && (pDesc[(i * 2) + 3] == ((langage_id >> 8) & 0xFF)))
		{
			found = TRUE;
			break;
		}
	}
	if(!found || !index)
		return(string_desc);
	index--;
	*DescPtr += (uint32)pDesc[0];
	pDesc += pDesc[0];
	i *= NUM_STRING_DESC;
	while(--i >= 0)
	{
		*DescPtr += (uint32)pDesc[0];
		pDesc += pDesc[0];
	}
	while(index)
	{
		*DescPtr += (uint32)pDesc[0];
		pDesc += pDesc[0];
		index--;
	}
	return(pDesc);	
}	

uint32 usb_get_string_desc_base(void)
{
	int i;
	uint8 *pDesc = string_desc;
	uint32 offset = (uint32)pDesc[0];
	pDesc += pDesc[0];
	for(i = 0; i < (NUM_STRING_DESC * NUM_LANGUAGES); i++)
	{
		offset += (uint32)pDesc[0];
		pDesc += pDesc[0];
	}
	return(1024 - offset); /* from the top of the descriptor core memory */
}

uint32 usb_ep_is_busy(uint32 epnum)
{
	/* See if the EP is currently busy */
	if(ep[epnum].buffer.start)
		return(USB_EP_IS_BUSY);
	else
	{
		/* Endpoint can be free because of RESET */
		if((epnum) && (ep[epnum].state == USB_DEVICE_RESET))
			return(USB_DEVICE_RESET);
		else
			return(USB_EP_IS_FREE);
	}
}

uint32 usb_ep_wait(uint32 epnum)
{
	while(1)
	{
		/* See if the EP is currently busy */
		if(ep[epnum].buffer.start == NULL)
		{
			/* Endpoint can be free because of RESET */
			if((epnum) && (ep[epnum].state == USB_DEVICE_RESET))
				return USB_DEVICE_RESET;		
			return USB_EP_IS_FREE;
		}
	}
}

void usb_ep_stall(uint32 epnum)
{
	if(!epnum)
		MCF_USB_EP0SR |= MCF_USB_EP0SR_PSTALL;
	else
	{
		if(ep[epnum].buffer.free == FALSE)
		{
			ep[epnum].buffer.start = NULL;
			ep[epnum].buffer.length = 0;
			ep[epnum].buffer.position = 0;
		}
		MCF_USB_EPSTAT(epnum) |= MCF_USB_EPSTAT_FLUSH;
		if(ep[epnum].dir == IN)	
			MCF_USB_EPINSR(epnum) |= MCF_USB_EPINSR_PSTALL;
		else
			MCF_USB_EPOUTSR(epnum) |= MCF_USB_EPOUTSR_PSTALL;
	}
#ifdef USB_DEBUG_PRINT
	printf("usb_ep_stall EP%d\r\n", epnum);
#endif
}

void usb_sendZLP(uint32 epnum)
{
	ep[epnum].zlp = TRUE;
}

#endif /* LWIP */
#endif /* NETWORK */
#endif /* USB_DEVICE */
