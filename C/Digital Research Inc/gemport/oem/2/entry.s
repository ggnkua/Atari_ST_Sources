*********************************************************************************
*
* entry.s
*
* Steve Cavender
* 21 September 1984
*
* _GSX_ENTRY
*  This module is the front end of the GIOS for the screen driver
*
*********************************************************************************

	.xdef	local_pb
	.xdef	_CONTRL
	.xdef	_INTIN
	.xdef	_PTSIN
	.xdef	_INTOUT
	.xdef	_PTSOUT
	.xdef	_FLIP_Y
	.xdef	_SCREEN

ptsin_size      .equ   256      * max. # of elements allowed for PTSIN array
ptsin_max       .equ   ptsin_size/2 * max. # of coordinate pairs for PTSIN array
W_1             .equ   2        * byte offset to first element of an array 
W_3             .equ   6        * byte offset to third element of an array

	.bss
lcl_ptsin	.ds.w	ptsin_size

	.text

_GSX_ENTRY:

	movem.l	d1-d7/a0-a6,-(sp)	*Save the callers registers

*  Make a local copy of the array pointers in the user's parameter block.

	movea.l	d1,a2           * get address of user's parameter block
	lea	local_pb, a1    * get address of local storage area
	movea.l	(a2)+,a0	* copy address of user's CONTRL aray
	move.l	a0,(a1)+        * save address of user's CONTRL array
	move.l	(a2)+,(a1)+     * save address of user's INTIN  array
	lea	lcl_ptsin,a3	* local area used for PTSIN array address
	move.l	a3,(a1)+	* save address of local PTSIN array
	move.l	(a2)+,a4	* get address of user's PTSIN array
	move.l	(a2)+,(a1)+     * save address of user's INTOUT array
	move.l	(a2),(a1)       * save address of user's PTSOUT array
*
*  Save a copy of the user's CONTRL[1] and CONTRL[3] elements on the stack.
*  This routine or the SCREEN DRIVER may change these values.
*
        move.w  W_1(a0),d0      * get number of PTSIN entries from CONTRL[1]
        move.w  W_3(a0),d1      * get number of INTIN entries from CONTRL[3]

*
*  Validate the number of entries in user's PTSIN array.
*
	move.w	d0,-(sp)	* save number of PTSIN entries from CONTRL[1]
        beq.b   size_intin      * for number of vertices = 0
	bpl.b   size_ptsin	* for number of vertices > 0
	clr.w	W_1(a0)		* for number of vertices < 0
*				* set user's CONTRL[1] to 0
	bra.b	size_intin
size_ptsin:
        cmpi.w  #ptsin_max,d0   * # of user vertices > # of allowable vertices?
	ble.b	ptsin_ok	* for user vertices =< # of allowable vertices
        move.w  #ptsin_max,d0   * user vertices > # of allowable vertices
        move.w  d0,W_1(a0)      * put max # of vertices in user's CONTRL[1]
ptsin_ok:
        subq.l  #1,d0           * adjust coordinate count for loop 
save_ptsin:
        move.l  (a4)+,(a3)+     * save x,y coordinate pair
        dbra    d0,save_ptsin   * point to next x,y coordinate pair
*
*  Validate number of entries in user's INTIN array.
* 
size_intin:
        move.w  d1,-(sp)        * save number of INTIN entries from CONTRL[3]
	bpl.b	intin_ok	* for user entries > 0
        clr.w   W_3(a0)		* put 0 entries in user's CONTRL[3]

intin_ok:
*
*  Call SCREEN which contains all the C routines for the SCREEN DRIVER.
*
	jsr	_SCREEN
*
*  Restore user's CONTRL[1] and CONTRL[3] array elements from the stack.
*
	movea.l	_CONTRL,a0      * get address of user's CONTRL array
	move.w	(sp)+,W_3(a0)   * original # of INTIN entries to CONTRL[3]
        move.w  (sp)+,W_1(a0)   * original # of PTSIN entries to CONTRL[1]
*
	movem.l	(sp)+, d1-d7/a0-a6 * restore the caller's registers
	clr.l	d0
	move.w	_FLIP_Y,d0	* set d0 to indicate magnitude/coordinate 
	rts
	.end
