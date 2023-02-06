#include <stdio.h>
#include <unistd.h>
#include <osbind.h>

#define CR_MASK (ACIA_CONTROL_CDSB_CLOCKDIVIDE_64 | ACIA_CONTROL_WSB_8n1)
#define CR_SETTINGS (CR_MASK | ACIA_CONTROL_TCB_RTS_LO_TX_INTERRUPT_DISABLED_BREAK)
#define CR_SETTINGS_RXINT (CR_SETTINGS | ACIA_CONTROL_RX_INTERRUPT_ENABLED)
#define ACIA_STATUS_RDRF (0x01)
#define ACIA_STATUS_TDRE (0x02)
#define ACIA_STATUS_DCD (0x04)
#define ACIA_STATUS_CTS (0x08)
#define ACIA_STATUS_FE (0x10)
#define ACIA_STATUS_OVRN (0x20)
#define ACIA_STATUS_PE (0x40)
#define ACIA_STATUS_IRQ (0x80)
#define ACIA_CONTROL_CDSB_CLOCKDIVIDE_1 (0x00)
#define ACIA_CONTROL_CDSB_CLOCKDIVIDE_16 (0x01)
#define ACIA_CONTROL_CDSB_MASTER_RESET (0x03)
#define ACIA_CONTROL_WSB_7e2 (0x00 << 2)
#define ACIA_CONTROL_WSB_7o2 (0x01 << 2)
#define ACIA_CONTROL_WSB_7e1 (0x02 << 2)
#define ACIA_CONTROL_WSB_7o1 (0x03 << 2)
#define ACIA_CONTROL_WSB_8n2 (0x04 << 2)
#define ACIA_CONTROL_WSB_8e1 (0x06 << 2)
#define ACIA_CONTROL_WSB_8o1 (0x07 << 2)
#define ACIA_CONTROL_TCB_RTS_HI_TX_INTERRUPT_DISABLED (0x00 << 5)
#define ACIA_CONTROL_TCB_RTS_LO_TX_INTERRUPT_ENABLED (0x01 << 5)
#define ACIA_CONTROL_TCB_RTS_HI_TX_INTERRUPT_DISABLED (0x02 << 5)
#define ACIA_CONTROL_TCB_RTS_LO_TX_INTERRUPT_DISABLED_BREAK (0x03 << 5)
#define ACIA_CONTROL_RX_INTERRUPT_ENABLED (0x01 << 7)
#define ACIA_CONTROL_TCB_RTS_LO_TX_INTERRUPT_DISABLED_BREAK (0x03 << 5)
#define ACIA_CONTROL_CDSB_CLOCKDIVIDE_64 (0x02)
#define ACIA_CONTROL_WSB_8n1 (0x05 << 2)

#define ALPHA_A 0x1E
#define ALPHA_B 0x30
#define ALPHA_C 0x2E
#define ALPHA_D 0x20
#define ALPHA_E 0x12
#define ALPHA_F 0x21
#define ALPHA_G 0x22
#define ALPHA_H 0x23
#define ALPHA_I 0x17
#define ALPHA_J 0x24
#define ALPHA_K 0x25
#define ALPHA_L 0x26
#define ALPHA_M 0x32
#define ALPHA_N 0x31
#define ALPHA_O 0x18
#define ALPHA_P 0x19
#define ALPHA_Q 0x10
#define ALPHA_R 0x13
#define ALPHA_S 0x1F
#define ALPHA_T 0x14
#define ALPHA_Y 0x16
#define ALPHA_V 0x2F
#define ALPHA_W 0x11
#define ALPHA_X 0x2D
#define ALPHA_Y 0x15
#define ALPHA_Z 0x2C
#define NUMERIC_1 0x02
#define NUMERIC_2 0x03
#define NUMERIC_3 0x04
#define NUMERIC_4 0x05
#define NUMERIC_5 0x06
#define NUMERIC_6 0x07
#define NUMERIC_7 0x08
#define NUMERIC_8 0x09
#define NUMERIC_9 0x0A
#define NUMERIC_0 0x0B
#define SPACE 0x39
#define ESC 0x01
#define BS 0x0E
#define DELETE 0x53
#define RETURN 0x1C
#define TAB 0x0F
#define HELP 0x62
#define UNDO 0x61
#define INSERT 0x52
#define CLR_HOME 0x47
#define UP_ARROW 0x48
#define DN_ARROW 0x50
#define LFT_ARROW 0x4B
#define RT_ARROW 0x4D
#define NUM_PAD_0 0x70
#define NUM_PAD_1 0x6D
#define NUM_PAD_2 0x6E
#define NUM_PAD_3 0x6F
#define NUM_PAD_4 0x6A
#define NUM_PAD_5 0x6B
#define NUM_PAD_6 0x6C
#define NUM_PAD_7 0x67
#define NUM_PAD_8 0x68
#define NUM_PAD_9 0x69
#define F1 0x3B
#define F2 0x3C
#define F3 0x3D
#define F4 0x3E
#define F5 0x3F
#define F6 0x40
#define F7 0x41
#define F8 0x42
#define F9 0x43
#define F10 0x44

#define BREAK_CODE(make_code) ((make_code) | 0x80)
#define RDR_FULL(ikbdstatus) ((ikbdstatus)&ACIA_STATUS_RDRF)

typedef unsigned char UINT8;
typedef UINT8 SCANCODE;

/* CONTROL REGISTER 6850: RIE | TC2 | TC1 | WS3 | WS2 | WS1 | CDS2 | CDS1 */
volatile UINT8 *const IKBD_control = 0xfffffc00;

/* STATUS REGISTER 6850: IRQ | PE | OVRN | PE | CTS | DCD | TxDRE | RxDRF 						     */
/* bit 7: interupt request: 			set to 1 when pin is activated 							  	 */
/* bit 6: Parity error: 				when parity of received word != parity bit 				 	 */
/* bit 5: overrun error: 				processor did not read previous input reset when rectified   */
/* bit 4: framing error: 				set when no stop bit is observed reset when rectified		 */
/* bit 3: state of clear: 				to send input pin											 */
/* bit 2: state of data carrier: 		detect input pin											 */
/* bit 1: transmitter data register:	is empty when flag = 1										 */
/* bit 0: receive data register: 		is full when flag = 1										 */

volatile const UINT8 *const IKBD_status = 0xfffffc00;
volatile const SCANCODE *const IKBD_RDR = 0xfffffc02;

SCANCODE read_scancode(void);

SCANCODE g_mouse_action;
SCANCODE g_mouse_delta_x;
SCANCODE g_mouse_delta_y;

int main(int argc, char *argv[])
{
	SCANCODE delta_x;
	SCANCODE delta_y;
	long old_ssp = Super(0);
	char *scancode_2_ascii = (char *)((Keytbl(-1, -1, -1))->unshift);
	SCANCODE volatile scan_code;

	*IKBD_control = CR_SETTINGS;

	while ((scan_code = read_scancode()) != BREAK_CODE(ESC))
	{
		switch (scan_code)
		{
		case 0xfa: /* left click */
			printf("left click\n");
			while (*IKBD_RDR == 0xfa)
				;
			printf("byte 2: %x\n", *IKBD_RDR);
			while (*IKBD_RDR == 0xfa)
				;
			printf("byte 3: %x\n", *IKBD_RDR);
			break;

		case 0xf9: /* right click */
			printf("right click\n");
			while (*IKBD_RDR == 0xfa)
				;
			printf("byte 2: %x\n", *IKBD_RDR);
			while (*IKBD_RDR == 0xfa)
				;
			printf("byte 3: %x\n", *IKBD_RDR);
			break;

		case 0xfb: /* both click */
			printf("both click\n");
			while (*IKBD_RDR == 0xfb)
				;
			break;

		case 0xf8: /* mouse move */
			printf("mouse move\n");
			while (*IKBD_RDR == 0xf8) /* busy wait */
				;
			printf("byte 2: %x\n", *IKBD_RDR);
			while (*IKBD_RDR == 0xf8) /* busy wait */
				;
			printf("byte 3: %x\n", *IKBD_RDR);
			break;
		default:
			printf("code 0x%x = %c\n", scan_code, scancode_2_ascii[scan_code]);
		}
	}

	*IKBD_control = CR_SETTINGS_RXINT;

	Super(old_ssp);

	return 0;
}

SCANCODE read_scancode(void)
{
	while (!RDR_FULL(*IKBD_status))
		;
	return *IKBD_RDR;
}
