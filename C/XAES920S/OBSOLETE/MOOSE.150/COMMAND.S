*** Moose Device Command Interpreter **************************************

	SECTION TEXT


** Command Interpreter ****************************************************

* This is called by the write function of the device driver and acts as a
* top level call.

* All the command interpreters find the command at A0, the size of the
* write in D0 and the global variables on A6. No registers need to be
* saved although on return, D0.L should hold the size of the write for
* success (leave it as it is), or 0 for an error.

handle_commands
	cmpi.w	#RECT_COM,(a0)
	beq	rect_command

	cmpi.w	#INIT_COM,(a0)
	beq	init_moose

	cmpi.w	#DCLK_COM,(a0)
	beq	dclk_command

	moveq	#0,d0		Bad command - ignored
	rts


** INIT_COM: Initialise Moose *********************************************

* The INIT_COM command is used to activate the moose device. Once active,
* the moose cannot be shut down and will ignore all further INIT_COM
* commands unless it needs reinstalling (eg: after the VDI opens a physical
* screen workstation).

init_moose
	tst.l	IKBD_table(a6)
	beq	.ok			Definitely not installed

	move.l	IKBD_table(a6),a1
	cmpi.l	#IKBD_handler,16(a1)
	beq	.return			Already installed
.ok

** Get the IKBD table

	move.l	INIT_COM_IKBD(a0),a1
	move.l	a1,IKBD_table(a6)


** Patch our moose vector into the IKBD table

	move.l	16(a1),old_IKBD_handler(a6)

	pea	IKBD_handler(pc)
	move.l	(a7)+,16(a1)

.return	rts


** RECT_COM: Rectangle Command ********************************************

* !!TODO!!

* This handles requests to add or remove a rectangle from the watch list.

rect_command
	clr.l	d0
	rts


** DCLK_COM: Change Double Click Time Command *****************************

* This command allows XaAES to change the double click time.
* If you set the dc_time to 0, then that will prevent the Moose from
* sending any more button packets (if there are packets pending, they
* can still be read, i.e., Moose will not flush the mouse data.

* There is an upper bound placed on the dc_time. It may not be longer
* than MAX_DC_TIME (defined in MOOSE.I). If you try to set it to more than
* MAX_DC_TIME, then it is 'clipped' to MAX_DC_TIME.

dclk_command
	move.w	DCLK_COM_TIME(a0),d1
	cmpi.w	#MAX_DC_TIME,d1
	ble.s	.okay
	move.w	#MAX_DC_TIME,d1
.okay	move.w	d1,dc_time(a6)
	rts


***************************************************************************

