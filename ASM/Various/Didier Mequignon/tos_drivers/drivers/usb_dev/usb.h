/*
 * File:        usb.h
 * Purpose:     USB Header File
 */

#ifndef USB_H
#define USB_H

#include <string.h>
#include "config.h"
#include "../freertos/FreeRTOS.h"
#include "../freertos/task.h"
#include "../freertos/queue.h"
#include "../freertos/semphr.h"
#include "mcf548x.h"
#include "../../include/ramcf68k.h"

#ifndef int8
#define int8 char
#endif
#ifndef int16
#define int16 short
#endif
#ifndef int32
#define int32 long
#endif
#ifndef uint8
#define uint8 unsigned char
#endif
#ifndef uint16
#define uint16 unsigned short
#endif
#ifndef uint32
#define uint32 unsigned long
#endif
#ifndef vuint8
#define vuint8 volatile unsigned char
#endif
#ifndef vuint16
#define vuint16 volatile unsigned short
#endif
#ifndef vuint32
#define vuint32 volatile unsigned long
#endif
#ifndef BOOL
#define BOOL int
#endif
#ifndef NULL
#define NULL (void *)0
#endif
#ifndef FALSE
#define FALSE 0
#endif
#ifndef TRUE
#define TRUE 1
#endif

#include "descriptors.h"

#define Setexc(num, vect) \
   *(unsigned long *)(((num) * 4) + coldfire_vector_base) = (unsigned long)vect

extern void board_printf(const char *fmt, ...);
#define printf board_printf

extern void swp68l(uint32 *);

extern unsigned char __MBAR[];

/* 
 * This define is used to turn on debug prints in the USB driver.
 * Warning: Defining this may break the USB application.  The prints
 *          may take too long and cause to host to think we have become
 *          non-responsive.
 */
//#define USB_DEBUG_PRINT

/* Fifo mode: TRUE: Perf, FALSE: Flexibility */
#define FIFO_PERF TRUE

/* Interrupt level & priority */
#define INTC_LVL_USBORED 3
#define INTC_PRI_USBORED 6
#define INTC_LVL_USBCORE 3
#define INTC_PRI_USBCORE 5
#define INTC_LVL_USBGEN  3
#define INTC_PRI_USBGEN  4
#define INTC_LVL_USBEP6  3
#define INTC_PRI_USBEP6  3
#define INTC_LVL_USBEP5  3
#define INTC_PRI_USBEP5  2
#define INTC_LVL_USBEP4  3
#define INTC_PRI_USBEP4  1
#define INTC_LVL_USBEP3  3
#define INTC_PRI_USBEP3  0
#define INTC_LVL_USBEP2  5
#define INTC_PRI_USBEP2  6
#define INTC_LVL_USBEP1  5
#define INTC_PRI_USBEP1  5
#define INTC_LVL_USBEP0  5
#define INTC_PRI_USBEP0  4

/* Default size to malloc() when needed */
#define BUFFER_SIZE         2048

/* Total number of EPs in this USB core */
#define NUM_ENDPOINTS       7

/* Depth of the FIFOs in packet lengths (Must be at */
/* least 2 for non-isochronous endpoints) */
#define FIFO_DEPTH          2

/* Definitions for Device Config Change events */
#define CONFIGURATION_CHG   1
#define INTERFACE_CHG       2
#define ADDRESS_CHG         4
#define DESCRIPTOR_CHG      8

/* Definitions for Bus Change events */
#define SUSPEND             1
#define RESUME              2
#define ENABLE_WAKEUP       4
#define RESET               8

/* Definitions for Transfer Status */
#define SUCCESS							0
#define OVERFLOW_ERROR			1
#define MALLOC_ERROR				2
#define NOT_SUPPORTED_COMMAND		4
#define OTHER_ERROR					8
#define EMPTY               1
#define FULL                2
#define FIFOHI              3
#define FIFOLO              4

/* Definition for Device states and command completion codes*/
#define USB_CONFIGURED      0
#define USB_CMD_SUCCESS     0
#define USB_CMD_FAIL        1
#define USB_DEVICE_RESET    2
#define USB_EP_IS_FREE      0
#define USB_EP_IS_BUSY      1

/* Service task */
#define BUSCHG_NOTICE       0
#define SETUP_SERVICE       1
#define IN_SERVICE_EOF      2
#define OUT_SERVICE_EOF     3
#define OUT_SERVICE_EOT     4
#define FEATURE_ENDPOINT    5
#define FIFO_EVENT          6

/* bRequest */
#define GET_STATUS          0
#define CLEAR_FEATURE       1
#define SET_FEATURE         3
#define SET_ADDRESS         5
#define GET_DESCRIPTOR      6
#define SET_DESCRIPTOR      7
#define GET_CONFIGURATION   8
#define SET_CONFIGURATION   9
#define GET_INTERFACE      10
#define SET_INTERFACE      11
#define SYNCH_FRAME        12

/* GET_DESCRIPTOR type */
#define TYPE_DEVICE_DESCRIPTOR           1
#define TYPE_CONFIGURATION_DESCRIPTOR    2
#define TYPE_STRING_DESCRIPTOR           3
#define TYPE_INTERFACE_DESCRIPTOR        4
#define TYPE_ENDPOINT_DESCRIPTOR         5
#define TYPE_DEVICE_QUALIFIER_DESCRIPTOR 6

/* Structure for storing IN and OUT transfer data */
typedef struct {
    uint8 *start;               /* Starting address for buffer */
    uint32 position;            /* Offset pointer within buffer */
    uint32 length;              /* Length of the buffer in bytes */
    uint32 free;                 /* Was this buffer malloc()ed? */
} USB_BUFFER;

/* USB Endpoint State Info */
typedef struct {
    uint32 fifo_length;     /* Length of FIFO */
    uint32 in_fifo_start;   /* Starting address of IN-FIFO */
    uint32 out_fifo_start;  /* Starting address of OUT-FIFO */
    uint32 packet_size;     /* Maximum Packet Size */
    uint8 ttype;            /* Transfer Type */
    uint8 dir;              /* Direction of transfer */
    uint8 state;            /* State of endpoint */
    uint8 zlp;              /* Send zero-legnth packet flag */
    USB_BUFFER buffer;      /* Data Buffer for IN and OUT transfers */
} USB_EP_STATE;

/********************************************************************
* Application Specific Function Prototypes
*********************************************************************/

/* The following functions must be defined by the application */
uint32 usb_endpoint(uint32, uint8 *, uint32);
void usb_vendreq_service(uint8, uint8, uint16, uint16, uint16);
void usb_ep_halt(uint32);
void usb_ep_unhalt(uint32 epnum);
void usb_devcfg_notice(uint8, uint8, uint32);
void usb_buschg_notice(uint32, uint32);
void usb_ep_tx_done(uint32);
void usb_ep_rx_done(uint32, uint8);
void usb_fifo_event(uint32, uint8);
uint32 usb_get_desc_size(void);

/********************************************************************
* Standardized Function Prototypes
*********************************************************************/

/* The following functions are provided in usb.c */
void usb_device_init(void);
void usb_intc_init(void);
portBASE_TYPE usb_core_isr(void);
portBASE_TYPE usb_general_isr(void);
portBASE_TYPE usb_endpoint_isr(uint32);
void usb_service_task(void *);
void usb_vendreq_done(int);
void usb_fifo_init(int);
uint32 usb_tx_data(uint32, uint8 *, uint32);
uint32 usb_rx_data(uint32, uint8 *, uint32);
uint32 usb_set_rx_buffer(uint32, uint32);
uint32 usb_ep_is_busy(uint32);
uint32 usb_ep_wait(uint32);
void usb_ep_stall(uint32 epnum);
uint8* usb_get_desc(int8, int8, int8, int8, int8, uint32 *);
uint8* usb_get_string_descriptor(uint8, uint16, uint16, uint32 *);
uint32 usb_get_string_desc_base(void);
void usb_sendZLP(uint32 epnum);

void usb_endpoint0_handler(void);
void usb_endpoint1_handler(void);
void usb_endpoint2_handler(void);
void usb_endpoint3_handler(void);
void usb_endpoint4_handler(void);
void usb_endpoint5_handler(void);
void usb_endpoint6_handler(void);
void usb_general_int(void);
void usb_core_int(void);
void usb_or_handler_int(void);

extern int asm_set_ipl(int level);

#endif /* USB_H */

