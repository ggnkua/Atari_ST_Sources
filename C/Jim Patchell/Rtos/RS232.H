/***************************************************************************
**                                                                        **
** MultiTasking RS-232 Device Driver                                      **
**                                                                        **
**	Driver manages a queue between the RS232 Port and a TASK.             **
**                                                                        **
** GET:                                                                   **
**                                                                        **
**	When doing a GET, if the buffer is empty, the driver will suspend     **
** and do a reschedule.  When the data in the buffer exceeds a high       **
** water mark, the waiting task will be woken up.  Also, if a character   **
** is put into the buffer that matches the End Of Transmission character  **
** (EOT), The waiting task if any will also be woken up.                  **
**                                                                        **
** PUT:                                                                   **
**                                                                        **
**	When doing a PUT, if the buffer is full, the driver will suspend      **
** until the buffer is empty.  When the data buffer goes below the low    **
** water mark, the pending task will be woken up.                         **
***************************************************************************/

#ifndef RS232__H
#define RS232__H

/*
** hardware defines
*/

#define UART						(0xffe00001l)

#define MODE_REG_A					(UART + 0)
#define STATUS_REG_A				(UART + 1*2)
#define COMMAND_REG_A				(UART + 2*2)
#define DATA_REG_A					(UART + 3*2)

#define MODE_REG_B					(UART + 8*2)
#define STATUS_REG_B				(UART + 9*2)
#define COMMAND_REG_B				(UART + 10 *2)
#define DATA_REG_B					(UART + 11 * 2)

#define AUX_CONTROL_REG				(UART + 4*2)
#define INPUT_PORT_CHANGE_REG		(UART + 4*2)
#define INTERRUPT_STATUS_REG		(UART + 5*2)
#define INTERRUPT_MASK_REG			(UART + 5*2)
#define COUNTER_UPPER_REG			(UART + 6*2)
#define COUNTER_LOWER_REG			(UART + 7*2)
#define INTERRUPT_VECTOR_REG		(UART + 12*2)
#define INPUT_PORT_REG				(UART + 13*2)
#define OUTPUT_PORT_CONFIG			(UART + 13*2)
#define START_COUNTER				(UART + 14*2)
#define BIT_SET_COMMAND				(UART + 14*2)
#define STOP_COUNTER				(UART + 15*2)
#define BIT_RESET_COMMAND			(UART + 15*2)
#define OUTPUT_PORT					(UART + 14*2)
/*
** defines for port a UART
*/
#define TX_A_RDY_IRQ	0x01	/*	transmit ready interrupt mask	*/
#define RX_A_RDY_IRQ	0x02	/*	reciever ready interrupt mask	*/
#define DELTA_BREAK_A	0x04	/*	delta break a iqr mask	*/

#define TX_B_RDY_IRQ	0x10	/*	transmit ready interrupt mask	*/
#define RX_B_RDY_IRQ	0x20	/*	reciever ready interrupt mask	*/
#define DELTA_BREAK_B	0x40	/*	delta break a iqr mask	*/

#ifndef __IOREC__

#define TX_EMPTY 0x08

/*
** data structures used by device
*/

#ifdef RS232_BUILD

typedef struct {
	char *buffer;   /*	pointer to data buffer			4	*/
	int head;		/*	head index in buffer			2	*/
	int tail;		/*	tail index in buffer			2	*/
	int size;		/*	size of buffer					2	*/
	int nchars;		/*	number of characters in buffer	2	*/
	int high;		/*	high water mark					2	*/
	int low;		/*	low water mark					2	*/
	int eotchar;	/*	end of transmision character	2	*/
	int timeout;	/*	how long to wait for buffer		2	*/
	TSemaphore *IOEvent;	/*	semaphore controling IO			4	*/
	char *uartdata;	/*	address of uart data register	4	*/
	char *statusreg;/*	address of status register		4	*/
	char *bsreg;	/*	address of bit set register		4	*/
	char *brreg;	/*	address of bit reset register	4	*/
	char *modereg;	/*	address of mode register		4	*/
	char *cmdreg;	/*	address of command register		4	*/
	int putirqmsk;	/*	mask for put IMR reg			2	*/
	int getirqmsk;	/*	mask for get IRM reg			2	*/
	int dsrbit;		/*	bit mask for DSR line			2	*/
	Wait *WritersBlock;	/*	blocking semaphore for writing	4	*/
	char dummy[6];	/*	reserved data pads to 64 bytes		*/
}IO_REC;

#endif		//end of ifdef RS232_BUILD

#define __IOREC__
#endif

/*
** Parameters to tell what kind of STATUS
*/

#define RECEIVE_STAT	1		/*	get number of characters in recieve buff	*/
#define SEND_STAT		2		/*	get number of characters in transmit buff	*/

/*
** function codes for XIO call
*/

#define SET_BAUD_RATE		0x20
#define SEND_BREAK			0x21
#define WAIT_EMPTY			0x22
#define SET_MODE			0x23
#define SET_INPUT_BUFFER	0x24
#define SET_OUTPUT_BUFFER	0x25
#define MEM_PROTECT			0x26
#define SET_ERROR			0x27
#define SET_ACTIVE			0x28
#define READ_INPORT			0x29
#define RS232_SET_PARITY	0x2a
#define RS232_SET_BITS    	0x2b
#define RS232_SET_STOP		0x2c
#define RS232_GET_BAUD		0x2d
#define RS232_GET_PARITY	0x2e
#define RS232_GET_BITS		0x2f
#define RS232_GET_STOP      0x30
#define RS232_SET_PUTEOT	0x31
#define RS232_SET_RTIMEOUT	0x32
#define RS232_SET_GETEOT	0x33

/*
** buad rate defines
*/

#ifndef BAUD__RATES
#define BAUD__RATES

#define BAUDRATE_75	0x0
#define BAUDRATE_110	0x011
#define BAUDRATE_134	0x022	/*	actaully 134.5	*/
#define BAUDRATE_150	0x033
#define BAUDRATE_300	0x044
#define BAUDRATE_600	0x055
#define BAUDRATE_1200	0x066
#define	BAUDRATE_2000	0x077
#define BAUDRATE_2400	0x088
#define BAUDRATE_4800	0x099
#define BAUDRATE_1800	0x0aa
#define BAUDRATE_9600	0x0bb
#define BAUDRATE_19200	0x0cc

#define PARITY_NONE	0x10
#define PARITY_EVEN 0x00
#define PARITY_ODD	0x04
#define PARITY_MASK	0x1c

#define STOPBIT_1	7
#define STOPBIT_2	15

/* these are the defines to really talk to the machine with	*/
#define RS232_BAUDRATE_75		0
#define RS232_BAUDRATE_110		1
#define RS232_BAUDRATE_134		2	/*	actaully 134.5	*/
#define RS232_BAUDRATE_150		3
#define RS232_BAUDRATE_300		4
#define RS232_BAUDRATE_600		5
#define RS232_BAUDRATE_1200		6
#define RS232_BAUDRATE_1800		7
#define	RS232_BAUDRATE_2000		8
#define RS232_BAUDRATE_2400		9
#define RS232_BAUDRATE_4800		10
#define RS232_BAUDRATE_9600		11
#define RS232_BAUDRATE_19200	12

#define RS232_BAUDRATE_MAX		12

#define RS232_PARITY_NONE	0
#define RS232_PARITY_EVEN 	1
#define RS232_PARITY_ODD	2

#define RS232_PARITY_MAX	2

#define RS232_BITS_5	0
#define RS232_BITS_6	1
#define RS232_BITS_7    2
#define RS232_BITS_8	3

#define RS232_BITS_MAX	3

#define RS232_STOP_1	0
#define RS232_STOP_2	1

#define RS232_STOP_MAX	1

#endif

/*
** bit patterns for output port
*/
#define SET_ERROR_BIT	0x20
#define SET_ACTIVE_BIT	0x40
#define SET_PROTECT_BIT	0x80

/****************************************************
**
** Return Values sent back by RS-232 handler
**
****************************************************/

#define RS232_TIMEOUT	-20		//handler errors start at -20

#ifdef __cplusplus
extern "C" {
#endif

/*
** misc gloabals
*/
extern char acr_shad;

/* function prototypes	*/

#pragma function( calling)

extern long R_init(void);

#pragma function()


#ifdef __cplusplus
}
#endif

#endif	//end of RS232__H
