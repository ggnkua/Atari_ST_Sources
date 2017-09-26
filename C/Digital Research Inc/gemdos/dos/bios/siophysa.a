******************************************************************************
**
** siophysa.s -
**        ^---- Assembler support for
**    ^^^^----- physical level access to the MVME400
** ^^^--------- serial card (with its NEC 7201 MPSCC).
**
**              WHY THIS BIG OF A MODULE IN ASSEMBLER RATHER THAN C:
**              Because we support two different logical devices (AUX: on
**              channel A and MOUSE: on channel B) on this one physical
**              device, we need a logical level where the one interrupt from
**              this device can be split apart into the separate interrupts
**              that it actually represents for the two logical devices.
**              Since some of the 7201's capability is not actually in use,
**              those interrupts are stubbed out.  The init code should have
**              prevented those interrupts from occuring, but the stubs are
**              there just to be on the safe side.
**
**              A NOTE FOR FUTURE CONSIDERATION:
**              The MVME400 initialization that is done in SIOPHYSC.C would
**              probably be more maintainable if re-written in assembler and
**              moved into this source module.  Owing to bugs in the C
**              compiler used in this project development, the data structures
**              involved in representing the memory image of the MPSCC control
**              registers and the map of those registers is (at least to me)
**              more confusing than the corresponding assembler code would be.
**              ALSO:
**              We are not currently paying any attention to external status
**              (such as DCD and CTS).  This should be implemented later on.
**
** CREATED
** 23 sep 85 scc
**
** MODIFICATIONS
** 25 sep 85 scc        Modified _m400_isr to handle more of front end.
**
** 27 sep 85 scc        Deleted old '_tx1st:' code and modified 'a_tbe:' to
**                      function as new '_tx1st:' as well.
**
**  8 oct 85 scc        Modifed 'push' of bytes for passing parameters.
**
**  9 oct 85 scc        Modified handling of port A character transmission
**                      by adding a flag to indicate the state of 'transmit
**                      buffer empty' interrupt enable.
**
** 11 oct 85 scc	Modified 'tx1st', which needed to make the pair
**			'send character'+'set flag' atomic, by diabling
**			interrupts around the two instructions.
**
** NAMES
**      scc     Steven C. Cavender
**
******************************************************************************

******************************************************************************
**
** Global labels
**
******************************************************************************


	.xref   _m400_isr        * referenced in BIOSA.S
	.xref   _tx1st          * referenced in SIOCHR.C and SIOINT.C
	.xref   _tbeflag        * referenced in SIOCHR.C and SIOINT.C
	.xdef   rat_int         * defined in MOUSE.S
	.xdef   rat_err         * defined in MOUSE.S
	.xdef   _txint          * defined in SIOINT.C
	.xdef   _rxint          * defined in SIOINT.C
	.xdef   _erint          * defined in SIOINT.C

******************************************************************************
**
** Equates
**
******************************************************************************

m400    =       $F1C1C1         * base address of MVME400 ports

*                               * (scc = Serial Communications Controller)
scc_ad  =       $8              * Channel A data
scc_bd  =       $A              * Channel B data
scc_ac  =       $C              * Channel A control
scc_bc  =       $E              * Channel B control

rst_xsi =       %00010000       * Reset External/Status Interrupts
rst_txi =       %00101000       * Reset Pending Transmitter Interrupt
rst_err =       %00110000       * Error Reset
end_isr =       %00111000       * End of Interrupt

di	=	$0700		* Disable interrupts (raise fence to level 7)

	.text

******************************************************************************
**
**      _m400_isr -
**              Front end of the ISR for the MVME400's 7201 MPSCC.
**
******************************************************************************

_m400_isr:
	movem.l d0-d7/a0-a6,-(sp)       * save register context

	lea.l   m400,a5                 * set up pointer to MVME400 base
	clr.w   d0                      * pre-clear for displacement
	move.b  #2,scc_bc(a5)           * select SR2B
	move.b  scc_bc(a5),d0           * get interrupt vector [1]
	movea.l isr_tbl(pc,d0.w),a0     * pick up the specific ISR address
	jsr     (a0)                    * and call it

	move.b  #end_isr,m400+scc_ac    * tell chip we're done [2]

	movem.l (sp)+,d0-d7/a0-a6       * restore register context
	rte                             * and clear out

******************************************************************************
**
** Jump table
**
******************************************************************************

isr_tbl:
	.dc.l   b_tbe                   * Channel B (MOUSE:) functions
	.dc.l   b_xsc
	.dc.l   b_rca
	.dc.l   b_src
	.dc.l   a_tbe                   * Channel A (AUX:) functions
	.dc.l   a_xsc
	.dc.l   a_rca
	.dc.l   a_src

******************************************************************************
**
** MOUSE: support routines
**
******************************************************************************

b_tbe:                                  * B Transmitter Buffer Empty
	move.b  #rst_txi,scc_bc(a5)     * disable TBE interrupts
	rts                             * we don't send characters to MOUSE:

b_xsc:                                  * B External/Status Change
	move.b  #rst_xsi,scc_bc(a5)     * reset interrupting condition
	rts                             * we don't check DCD or CTS for MOUSE:

b_rca:                                  * B Received Character Available
	clr.w   d0                      * pre-clear to promote to word
	move.b  scc_bd(a5),d0           * get the character
	move.w  d0,-(sp)                * push it
	jsr     rat_int
	addq.l  #2,sp                   * clean stack
	rts

b_src:                                  * B Special Receive Condition
	move.b  #1,scc_bc(a5)           * select SR1
	clr.w   d0                      * pre-clear to promote to word
	move.b  scc_bc(a5),d0           * get error status
	move.w  d0,-(sp)                * push it
	move.b  #rst_err,scc_bc(a5)     * reset error
	jsr     rat_err
	addq.l  #2,sp                   * clean stack
	rts

******************************************************************************
**
** AUX: support routines
**
******************************************************************************

a_tbe:                                  * A Transmitter Buffer Empty
	move.b  #rst_txi,m400+scc_ac    * turn off transmitter interrupt
	clr.w   _tbeflag                * and indicate TBE int now off

_tx1st:                                 * callable from C
	jsr     _txint                  * get character or empty status
	tst.l   d0                      * do we have a character?
	bmi     tbe_ret			* no, return

	move.w	sr,d1			* save the sr
	ori.w	#di,sr			* disable interrupts
	move.b  d0,m400+scc_ad          * yes, send the character
	move.w  #1,_tbeflag             * and indicate TBE int now on
	move.w	d1,sr			* re-enable interrupts
tbe_ret:
	rts

a_xsc:                                  * A External/Status Change
	move.b  #rst_xsi,scc_ac(a5)     * reset interrupting condition
	rts                             * we don't check DCD or CTS for AUX:

a_rca:                                  * A Received Character Available
	clr.w   d0                      * pre-clear to promote to word
	move.b  scc_ad(a5),d0           * get the character
	move.w  d0,-(sp)                * push it
	jsr     _rxint
	addq.l  #2,sp                   * clean stack
	rts

a_src:                                  * A Special Receive Condition
	move.b  #1,scc_ac(a5)           * select SR1
	clr.w   d0                      * pre-clear to promote to word
	move.b  scc_ac(a5),d0           * get error status
	move.w  d0,-(sp)                * push it
	move.b  #rst_err,scc_ac(a5)     * reset error
	jsr     _erint
	addq.l  #2,sp                   * clean stack
	rts


	.data

_tbeflag:
	.dc.w   0                       * TBE interrupt flag:  0 = off, 1 = on


******************************************************************************
**
** NOTES
**
**
**
** [1]
**      The 7201 must have been initialized to operate in the 'status affects
**      vector' mode where bits 2-4 are modified, so that we automatically
**      have a longword displacement when we read the vector.
**
** [2]
**      The direct address is specified here, rather than assuming that A5 was
**      left intact by the subroutines that we called.
**
******************************************************************************

	.end

