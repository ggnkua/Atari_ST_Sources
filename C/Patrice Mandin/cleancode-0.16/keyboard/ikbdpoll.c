/*
	Atari keyboard manager, using IKBD (polling method)

	Copyright (C) 2002	Patrice Mandin

	This program is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 2 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to the Free Software
	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

#include <stdio.h>
#include <string.h>

#include <mint/osbind.h>

/*--- Defines ---*/

#define SCANCODE_ESC	0x01

/*--- ACIA plugged to IKBD ---*/

#define ACIA_BASE (0xfffffc00)
struct ACIA_INTERFACE {
	unsigned char control;	/* read=status, write=control */
	unsigned char dummy1;
	unsigned char data;
	unsigned char dummy2;
};
#define acia_interface ((*(volatile struct ACIA_INTERFACE *)ACIA_BASE))

#define ACIA_SR_RXFULL		0x00	/* Receive full */
#define ACIA_SR_TXEMPTY		0x01	/* Transmit empty */
#define ACIA_SR_CD			0x02	/* Carrier detect */
#define ACIA_SR_CTS			0x03	/* Clear to send */
#define ACIA_SR_FRAMEERR	0x04	/* Frame error */
#define ACIA_SR_OVERRUN		0x05	/* Overrun */
#define ACIA_SR_PARITYERR	0x06	/* Parity error */
#define ACIA_SR_INTERRUPT	0x07	/* Interrupt source */

/*--- Functions ---*/

int main(int argc, char **argv)
{
	void *oldstack;
	unsigned char scancode;

	/* Availability: all Atari machines, Hades, Medusa */

	/* Go to supervisor */
	oldstack=(void *)Super(NULL);

	/* We do not change the IKBD setup, which is report
     * relative mouse motion, and joystick on port 1
	 */

	/* Wait till ESC key pressed */
	scancode = 0;

	printf("Press ESC to quit\n");

	while (scancode != SCANCODE_ESC) {

		/* Wait till a byte is sent by the IKBD */
		while ((acia_interface.control & (1<<ACIA_SR_RXFULL))==0) {
		}

		/* FIXME: should filter mouse/joystick packets */

		/* Read byte sent */
		scancode = acia_interface.data;

		printf("Scancode=0x%02x\n", scancode);
	}

	/* Go back to user mode */
	Super(oldstack);
}
