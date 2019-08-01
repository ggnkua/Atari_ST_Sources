;----------------------------------------------------------------------------
;File name:	RA_GS.I				Revision date:	1999.11.09
;Creator:	Ulf Ronald Andersson		Creation date:	1999.11.06
;(c)1998 by:	Ulf Ronald Andersson		All rights reserved
;Released as:	FREEWARE			(commercial sales forbidden!)
;----------------------------------------------------------------------------
;Purpose:	Symbol & Macro library for GEMScript operations
;----------------------------------------------------------------------------
;	Condition ensures inclusion once per pass only
;
	ifnd	RA_GS_defined
RA_GS_defined	set	1
;----------------------------------------------------------------------------
	include	RA_SYS.I
;----------------------------------------------------------------------------
;	Library macros:
;-------------------------------------
;int16	GS_REPLY(int16 *msg);		;sends GS_REPLY and defines partner
;int16	take_GS_COMMAND(int16 *msg);	;sets GP_Rx_command in partner struct
;int32	GS_ACK(int16 part_index);	;sends GS_ACK using partner struct
;int16	take_GS_QUIT(int16 *msg);	;undefines partner at partner request
;int32	GS_QUIT(int16 part_index);	;undefines partner at our request
;int16	GS_find_partner(int16 ap_id);	;finds partner index (also its struct)
;int16	GS_parse_parm(char *cmd, char **argv, int16 max_argc);;fixes argc,argv
;int32	GS_get_l(char *string);		;convert string to long value
;int32	GS_get_w(char *string);		;convert string to word value
;int32	GS_get_b(char *string);		;convert string to byte value
;int32	GS_put_l(long num,char *buf);	;convert long value to string
;int32	GS_put_w(long num,char *buf);	;convert word value to string
;GS_gen_data				;creates partner struct array
;-------------------------------------
;NB:	Use "make GS_links" to include all referred code modules.
;----------------------------------------------------------------------------
;	Message event codes  (for m[0] of message)
;-------------------------------------
GS_REQUEST	= $1350	;m[3].m[4] -> GS_INFO  m[7]=GS_ID
GS_REPLY	= $1351	;m[3].m[4] -> GS_INFO  m[6]=errcode  m[7]=GS_ID
GS_COMMAND	= $1352	;m[3].m[4] -> command  m[7]=GS_ID
GS_ACK		= $1353	;m[3].m[4] -> command  m[5].m[6] -> result  m[7]=errcode
GS_QUIT		= $1354	;m[7] = GS_ID
;-------------------------------------
GS_OPENMACRO	= $1355	;m[3].m[4] -> filename
GS_MACRO	= $1356	;m[3].m[4]=NULL or->OPENMACRO_m[0]  m[5]=ID/handle  m[6]=errcode
GS_WRITE	= $1357	;m[3].m[4] -> command  m[5] = ID/handle from GS_MACRO
GS_CLOSEMACRO	= $1358	;m[5] = ID/handle from GS_MACRO
;-------------------------------------
;Note that wherever used above 'GS_ID' refers to that ID used by GS_REQUEST
;in starting communication to/from a partner. Thus it is only for GS_REQUEST
;that this value should be set to a random code.  Other commands must use
;the same value as the GS_REQUEST did, regardless of whether that was sent
;to or received from the partner APP.
;----------------------------------------------------------------------------
;	GS_ACK	errcodes
;-------------------------------------
GSACK_OK	=	0	;Command was, or will be, executed
GSACK_UNKNOWN	=	1	;Command is unknown
GSACK_ERROR	=	2	;Command could not be executed (or failed)
;-------------------------------------
;GS_ACK is sent both in response to GS_COMMAND and GS_WRITE, but in latter
;case the result will always be NULL and GSACK_ERROR will not be used.
;If used, however, or if GSACK_UNKNOWN occurs, the sender of GS_WRITE should
;break off the macro recording.
;----------------------------------------------------------------------------
;	GS_INFO rules of operation
;-------------------------------------
;The struct must be allocated in global memory by Mxalloc, and no APP may
;modify the struct belonging to any other APP. The struct must be available
;at all times while working with GEMScript commands, and should be allocated
;before use in GS_REQUEST/GS_REPLY messages, and must remain valid until the
;comminication is ended by GS_QUIT, when the RAM may finally be released.
;----------------------------------------------------------------------------
;	GS_INFO	structure declarations
;-------------------------------------
	struct	GS_INFO
	uint32	GI_len;		;length of structure in bytes  currently = 12
	uint16	GI_version;	;version of protocol  currently = $0100 == 1.0
	uint16	GI_msgs;	;bitmap of supported GSM_ message bits
	uint32	GI_ext;		;script file extension  normally ".SIC" or 0
	d_end	GS_INFO
;-------
GS_VERSION	=	$0100
;-------------------------------------
;	GSM_ message bits
;-------------------------------------
b_GSM_COMMAND	=	0	;knows GS_COMMAND
b_GSM_MACRO	=	1	;knows OPENMACRO, WRITE, CLOSEMACRO, sends MACRO
b_GSM_WRITE	=	2	;sends OPENMACRO, WRITE, CLOSEMACRO, knows MACRO
;-------------------------------------
GSM_COMMAND	=	1<<b_GSM_COMMAND
GSM_MACRO	=	1<<b_GSM_MACRO
GSM_WRITE	=	1<<b_GSM_WRITE
;----------------------------------------------------------------------------
;	GS_PART structure
;-------------------------------------
	struct	GS_PART
	uint8	GP_appd,sizeof_GP_APPD	;APP defined structure part
	int16	GP_used_f	;bit 15 flags used entry  (for TAS)
	int16	GP_ap_id	;application id of partner
	uint16	GP_GS_ID	;GS_ID used in communication with partner
	struc_p	GP_GS_INFO	;-> GS_INFO struct of partner
	char_p	GP_Rx_command	;-> command received from partner
	int16	GP_Rx_argc		;argc of Rx_command, incl function name
	char_p	GP_Rx_argv,MAX_ARG	;argv of Rx_command, incl function name
	char_p	GP_Tx_result	;-> result sent (or to be sent) to partner
	int16	GP_Tx_errcode	;errcode sent (or to be sent) with result
	char_p	GP_Tx_command	;-> command sent to partner
	int16	GP_Tx_argc		;argc of Tx_command, incl function name
	char_p	GP_Tx_argv,MAX_ARG	;argv of Tx_command, incl function name
	char_p	GP_Rx_result	;-> result received from partner
	int16	GP_Rx_errcode	;errcode received from partner (with result)
	int16	GP_Tx_msg,8	;GEM message buffer for sending to partner
	d_end	GS_PART
;----------------------------------------------------------------------------
;	Macro definitions
;----------------------------------------------------------------------------
GS_links	MACRO
;-------
		_unidef	GS_REPLY
		_unidef	take_GS_COMMAND
		_unidef	GS_ACK
		_unidef	take_GS_QUIT
		_unidef	GS_QUIT
		_unidef	GS_find_partner
		_unidef	GS_parse_parm
		_unidef	GS_get_l,GS_get_w,GS_get_b
		_unidef	GS_put_l,GS_put_w,GS_put_b
		_unidef	GS_gen_data
;-------
		ENDM	;GS_links
;----------------------------------------------------------------------------
;int16	GS_REPLY(int16 *message);
;------------------------------------
GS_REPLY	MACRO	message
;-------
	_uniref	GS_REPLY
	_uniref	GS_gen_data
	PUREC_func.\0	GS_REPLY,1,3,<\1>
;-------
	ENDM	;GS_REPLY
;------------------------------------
;entry:	a0 -> msg_buffer holding GS_REQUEST from future partner
;-------
;exit:	d0 =  partner index, or negative error code
;	a0 -> partner structure, if found/defined
;------------------------------------
GS_REPLY_code	MACRO
;-------
	clr.l	d0			;preclear d0 as errcode
	movem.l	d0/a0/a2,-(sp)		;push errcode d0, msg_p a0, entry a2
	clr.l	(sp)			;clear long errcode on stack
	GS_find_partner	1*2(a0)
	movea.l	4(sp),a1		;a1 = entry a0 -> GS_REQUEST msg  from stack
	exg	a0,a1			;a0 -> msg  a1 -> partner struct
	move.l	d0,d2			;d2 = index, or E_ERROR if not found
	bpl.s	.define_entry		;if partner found, go redefine entry
	addq	#1,GS_part_c		;increment partner count
	cmp	#MAX_GS_PARTS,GS_part_c	;do we lack room for another partner ?
	bls.s	.define_partner		;else go define new partner
.def_failure:
	subq	#1,GS_part_c		;restore original partner count
	move.l	#E_ERROR,(sp)		;patch errcode on stack
	lea	GS_REPLY_msg(pc),a2	;a2 -> non_partner reply message buffer
	bra.s	.done_partner
;-------
.define_partner:
	lea	GS_part_t_end,a1	;a1 -> end of GS_part_t
	moveq	#MAX_GS_PARTS-1,d2	;d2 =  dbra value for loop (last index)
.def_part_loop:
	lea	-sizeof_GS_PART(a1),a1	;a1 -> preceding partner entry
	tas	GP_used_f(a1)		;mark entry used, testing it first
	dbpl	d2,.def_part_loop	;loop until free found or all checked
	bmi.s	.def_failure		;if we get here, the system is sick !
.define_entry:
	move	1*2(a0),GP_ap_id(a1)	;copy partner ap_id from message
	move.l	3*2(a0),GP_GS_INFO(a1)	;copy partner GS_INFO from message
	move	7*2(a0),GP_GS_ID(a1)	;copy partner GS_ID from message
	clr.l	GP_Tx_command(a1)	;\
	clr.l	GP_Rx_result(a1)	; \/ Null all command
	clr.l	GP_Rx_command(a1)	; /\ and result pointers
	clr.l	GP_Tx_result(a1)	;/
	clr	GP_Rx_errcode(a1)	;\/ Clear both incoming
	clr	GP_Tx_errcode(a1)	;/\ and outgoing errcodes
	lea	GP_Tx_msg(a1),a2	;a2 -> Tx_msg buffer
.done_partner:
	move	#GS_REPLY,(a2)+		;m[0] = GS_REPLY constant
	move	global+4,(a2)+		;m[1] = own ap_id
	clr	(a2)+			;m[2] = 0
	move.l	#GS_REPLY_GS_INFO,(a2)+	;m[3].m[4] = own GS_INFO
	clr	(a2)+			;m[5] = 0
	move	2(sp),(a2)+		;m[6] = errcode from stack
	move	7*2(a0),(a2)+		;m[7] = GS_ID of other APP
	lea	-8*2(a2),a2		;a2 -> base of msg buffer again
	move	1*2(a0),d2		;d2 = ap_id of other APP
	tst	(sp)			;did we succeed in defining partner ?
	bmi.s	.keep_errcode		;if not, keep errcode as result value
	move	d2,2(sp)		;patch partner index result value on stack
.keep_errcode:
	move.l	a1,4(sp)		;patch -> partner struct result value on stack
	gem_aes	appl_write,d2,#16,(a2)
	movem.l	(sp)+,d0/a0/a2		;pull part_ix d0, struct_p a0, entry a2
	rts				;return result to caller
;-------
GS_REPLY_GS_INFO:
	dc.l	sizeof_GS_INFO
	dc.w	GS_VERSION
	dc.w	GSM_COMMAND
	dc.l	'.SIC'
;-------
GS_REPLY_msg:
	ds.w	8			;msg buffer for non_partner replies
;-------
	ENDM	;GS_REPLY_code
;----------------------------------------------------------------------------
;int16	take_GS_COMMAND(int16 *message);
;------------------------------------
take_GS_COMMAND	MACRO	message
;-------
	_uniref	take_GS_COMMAND
	_uniref	GS_gen_data
	PUREC_func.\0	take_GS_COMMAND,1,3,<\1>
;-------
	ENDM	;take_GS_COMMAND
;------------------------------------
;entry:	a0 -> msg_buffer holding GS_COMMAND from partner
;-------
;exit:	d0 =  partner index, or negative error code
;	a0 -> partner struct, if found
;	a1 -> msg_buffer holding GS_COMMAND from partner
;------------------------------------
take_GS_COMMAND_code	MACRO
;-------
	move.l	a0,-(sp)		;push entry a0 -> GS_COMMAND msg
	GS_find_partner	1*2(a0)
	movea.l	(sp)+,a1		;pull a1 = entry a0 -> GS_COMMAND msg
	bpl.s	.have_partner		;if partner found, go take the command
.bad_command:
	moveq	#E_ERROR,d0
	rts				;return E_ERROR flagged MI to caller
;-------
.have_partner:
	move	7*2(a1),d1			;d1 = GS_ID code of message
	cmp	GP_GS_ID(a0),d1			;is that GS_ID correct ?
	bne.s	.bad_command			;else refuse command
	move.l	3*2(a1),GP_Rx_command(a0)	;copy partner command from msg
	rts					;return index flagged PL to caller
	ENDM	;take_GS_COMMAND_code
;----------------------------------------------------------------------------
;int32	GS_ACK(int16 part_index);
;------------------------------------
GS_ACK	MACRO	message
;-------
	_uniref	GS_ACK
	_uniref	GS_gen_data
	PUREC_func	GS_ACK,1,1,<\1>
;-------
	ENDM	;GS_ACK
;------------------------------------
;entry:	d0 =  partner index
;-------
;exit:	d0 =  E_OK, or negative error code
;------------------------------------
GS_ACK_code	MACRO
;-------
	mulu	#sizeof_GS_PART,d0	;d0 = array offset for partner struct
	lea	GS_part_t,a0
	add	d0,a0			;a0 -> partner struct
	tst.b	GP_used_f(a0)		;is this struct free ?
	bmi.s	.found_partner		;else we have a partner here
	moveq	#E_ERROR,d0		;d0 = error as partner not present
	rts				;return to caller with error code
;-------
.found_partner:
	lea	GP_Tx_msg(a0),a1	;a1 -> Tx_msg buffer
	move	#GS_ACK,(a1)+		;m[0] = GS_ACK constant
	move	global+4,(a1)+		;m[1] = own ap_id
	clr	(a1)+			;m[2] = 0
	move.l	GP_Rx_command(a0),(a1)+	;m[3].m[4] -> received command
	move.l	GP_Tx_result(a0),(a1)+	;m[5].m[6] -> result to transmit
	move	GP_Tx_errcode(a0),(a1)+	;m[7] = GS_ID of partner
	lea	GP_Tx_msg(a0),a1	;a1 -> Tx_msg buffer
	move	GP_ap_id(a0),d2		;d2 = ap_id of partner
	gem_aes	appl_write,d2,#16,(a1)
	moveq	#E_OK,d0		;flag msg sent to legal partner
	rts				;return result to caller
;-------
	ENDM	;GS_ACK_code
;----------------------------------------------------------------------------
;int16	take_GS_QUIT(int16 *message);
;------------------------------------
take_GS_QUIT	MACRO	message
;-------
	_uniref	take_GS_QUIT
	_uniref	GS_gen_data
	PUREC_func.\0	take_GS_QUIT,1,3,<\1>
;-------
	ENDM	;take_GS_QUIT
;------------------------------------
;entry:	a0 -> msg_buffer holding GS_QUIT from partner
;-------
;exit:	d0 =  partner index, or negative error code
;	a0 -> msg_buffer holding GS_QUIT from partner
;	a1 -> partner struct
;------------------------------------
take_GS_QUIT_code	MACRO
;-------
	move.l	a0,-(sp)		;push entry a0 -> GS_COMMAND msg
	GS_find_partner	1*2(a0)
	movea.l	(sp)+,a1		;pull a1 = entry a0 -> GS_COMMAND msg
	exg	a0,a1			;a0 -> msg  a1 -> partner struct
	bpl.s	.have_partner		;if partner found, go take the command
.bad_command:
	moveq	#E_ERROR,d0
	rts				;return E_ERROR flagged MI to caller
;-------
.have_partner:
	move	7*2(a0),d1		;d1 = GS_ID of message
	cmp	GP_GS_ID(a1),d1		;is that GS_ID correct ?
	bne.s	.bad_command		;else refuse command
	sf	GP_used_f(a1)		;release partner entry
	subq	#1,GS_part_c		;decrement partner count
	rts				;return index flagged PL to caller
;-------
	ENDM	;take_GS_QUIT_code
;----------------------------------------------------------------------------
;int32	GS_QUIT(int16 part_index);
;------------------------------------
GS_QUIT	MACRO	message
;-------
	_uniref	GS_QUIT
	_uniref	GS_gen_data
	PUREC_func	GS_QUIT,1,1,<\1>
;-------
	ENDM	;GS_QUIT
;------------------------------------
;entry:	d0 =  partner index
;-------
;exit:	d0 =  E_OK, or negative error code
;------------------------------------
GS_QUIT_code	MACRO
;-------
	mulu	#sizeof_GS_PART,d0	;d0 = array offset for partner struct
	lea	GS_part_t,a0
	add	d0,a0			;a0 -> partner struct
	tst.b	(a0)			;is this struct already free ?
	bmi.s	.found_partner		;else we have a partner to quit
	moveq	#E_ERROR,d0		;d0 = error as partner not present
	rts				;return to caller with error code
;-------
.found_partner:
	lea	GP_Tx_msg(a0),a1	;a1 -> Tx_msg buffer
	move	#GS_QUIT,(a1)+		;m[0] = GS_QUIT constant
	move	global+4,(a1)+		;m[1] = own ap_id
	clr	(a1)+			;m[2] = 0
	clr.l	(a1)+			;m[3].m[4] = 0
	clr.l	(a1)+			;m[5].m[6] = 0
	move	GP_GS_ID(a0),(a1)+	;m[7] = GS_ID of partner
	lea	GP_Tx_msg(a0),a1	;a1 -> Tx_msg buffer
	move	GP_ap_id(a0),d2		;d2 = ap_id of partner
	sf	GP_used_f(a0)		;release partner entry
	subq	#1,GS_part_c		;decrement partner count
	gem_aes	appl_write,d2,#16,(a1)
	moveq	#E_OK,d0		;d0 = E_OK as result
	rts				;return result to caller
;-------
	ENDM	;GS_QUIT_code
;----------------------------------------------------------------------------
;int16	GS_find_partner(int16 ap_id);
;------------------------------------
GS_find_partner	MACRO	ap_id
;-------
	_uniref	GS_find_partner
	_uniref	GS_gen_data
	PUREC_func	GS_find_partner,1,1,<\1>
;-------
	ENDM	;GS_find_partner
;------------------------------------
;entry:	d0 = ap_id
;-------
;exit:	d0 =  partner index, or negative error code
;	a0 -> partner struct, or -> base of partner struct array
;------------------------------------
GS_find_partner_code	MACRO
;-------
	lea	GS_part_t_end,a0	;a0 -> end of GS_part_t
	moveq	#MAX_GS_PARTS-1,d1	;d1 =  dbra value for loop (last index)
.loop:
	lea	-sizeof_GS_PART(a0),a0	;a0 -> preceding partner entry
	tst.b	GP_used_f(a0)		;is this entry in use ?
	dbne	d1,.loop			;else loop to check more entries
	beq.s	.failure		;go fail if no used entry found
	cmp	GP_ap_id(a0),d0		;is the ap_id correct ?
	dbeq	d1,.loop		;loop unless partner found or all checked
	bne.s	.failure		;go fail if no matching entry found
	move.l	d1,d0			;d0 = partner index
	rts				;return partner index to caller
;-------
.failure:
	moveq	#E_ERROR,d0		;d0 = E_ERROR
	rts				;return E_ERROR to caller
;-------
	ENDM	;GS_find_partner_code
;----------------------------------------------------------------------------
;int16	GS_parse_parm(char *cmd, char **argv, int16 max_argc);
;------------------------------------
GS_parse_parm	MACRO	cmd,argv,argc
;-------
	_uniref	GS_parse_parm
	PUREC_func.\0	GS_parse_parm,3,$1F,<\1>,<\2>,<\3>
;-------
	ENDM	;GS_aes_redraw
;------------------------------------
;entry:	d0 =  max argc allowed
;	a0 -> command line
;	a1 -> argv array to be filled
;-------
;exit:	d0 =  argc result, negative if more present than allowed
;------------------------------------
GS_parse_parm_code	MACRO
;-------
	move	d0,d2	;d2 = argc limit
	clr.l	d1	;d1 = initial argc  (overflow flag in bit 31)
.new_parm:
	move.b	(a0)+,d0
	beq.s	.command_end
	cmp.b	#6,d0		;abnormal parm ?
	bhi.s	.normal_parm	;else go copy it as normal string
	cmp.b	#2,d0		;hex_enc parm code
	beq.s	.hex_enc_parm	;go get hex_enc_parm
	cmp.b	#1,d0		;empty parm code ?
	bne.s	.ignore_parm	;else go ignore unknown parm type
	moveq	#NULL,d0	;d0 = NULL for empty parm
	bra.s	.have_arg_d0	;go store arg in argv, counted in argc
;-------
.hex_enc_parm:
	move.l	a0,d0		;d0 -> found arg 1st char
	bra.s	.have_arg_d0	;go store arg in argv, counted in argc
;-------
.normal_parm:
	move.l	a0,d0		;d0 -> found arg 2nd char
	subq.l	#1,d0		;d0 -> found arg 1st char
.have_arg_d0:
	bsr.s	.set_new_arg	;use d0 as arg address in argv, counted in argc
.ignore_parm:
	move.b	(a0)+,d0	;check next byte of command
	bne.s	.ignore_parm	;loop until terminator found
	bra.s	.new_parm	;loop back to try next parameter
;-------
.command_end:
	clr.l	d0		;clear high bits of d0
	move	d1,d0		;d0 = resulting argc
	tst.l	d1		;test parm count overflow
	bpl.s	.exit		;if no overflow, just exit
	neg.l	d0		;negate argc at overflow
.exit:
	rts			;return to caller
;------------------------------------
.set_new_arg:
	cmp	d2,d1		;argc < limit
	bhs.s	.parm_overflow	;else go deal with overflow
	move.l	d0,(a1)+	;store arg ptr in argv array
	addq	#1,d1		;increment argc
	rts			;return to GS_parse_parm
;-------
.parm_overflow:
	bset	#31,d1		;set overflow bit in argc
	rts			;return to GS_parse_parm
;-------
	ENDM	;GS_parse_parm
;----------------------------------------------------------------------------
;int32	GS_get_l(char *string);
;------------------------------------
GS_get_l	MACRO	string
;-------
	_uniref	GS_get_l
	PUREC_func.\0	GS_get_l,1,3,<\1>
;-------
		ENDM	;GS_get_l
;------------------------------------
;entry:	a0 -> string
;-------
;exit	d0 =  long value
;	d1 =  E_OK flagged EQ|PL  or  E_PARAMETER flagged NE|MI
;------------------------------------
GS_get_l_code	MACRO
;-------
	clr	d2			;clear sign flag in d2
	clr.l	d0			;d0 = zero initial value
	move.b	(a0)+,d2		;d2 = next char
	beq.s	.err_number		;error if no number
	cmp.b	#'+',d2			;positive sign ?
	beq.s	.get_number		;if so, go get digits
	cmp.b	#'-',d2			;negative sign ?
	bne.s	.have_poss_digit	;if not, try possible digit
	bset	#15,d2			;set sign flag in d2
.get_number:
	move.b	(a0)+,d2		;d2 = next char
	beq.s	.err_number		;error if no number
.have_poss_digit:
	sub.b	#'0',d2			;(d2 = digit_value) high enough ?
	blt.s	.err_number		;error if no number
	cmp.b	#'9',d2			;digit_value too high ?
	bhi.s	.err_number		;error if no number
	move.b	d2,d0			;d0 = first digit value
	move.b	(a0)+,d2		;d2 = next char
	beq.s	.end_number		;end if no digit
.loop:
	sub.b	#'0',d2			;(d2 = digit_value) high enough ?
	blt.s	.end_number		;end if no digit
	cmp.b	#'9',d2			;digit_value too high ?
	bhi.s	.end_number		;end if no digit
	move.l	d0,d1			;d1 = old_value
	asl.l	#2,d1			;d0 = old_value*4
	add.l	d1,d0			;d0 = old_value*5
	add.l	d0,d0			;d0 = old_value*10
	clr.l	d1			;d1 = 0L
	move.b	d2,d1			;d1 = (long) digit_value
	add.l	d1,d0			;d0 = old_value*10+digit_value
	move.b	(a0)+,d2		;d2 = next char
	bne.s	.loop			;loop until no more digits
.end_number:
	tst	d2			;test sign flag
	beq.s	.exit			;exit if positive
	neg.l	d0			;else negate result
.exit:
	moveq	#E_OK,d1		;d1 = E_OK flagged EQ|PL
	rts
;-------
.err_number:
	moveq	#E_PARAMETER,d1		;d1 = E_PARAMETER flagged NE|MI
	rts
;-------
	ENDM	;GS_get_l_code
;----------------------------------------------------------------------------
;int32	GS_get_w(char *string);
;------------------------------------
GS_get_w	MACRO	string
;-------
	_uniref	GS_get_w
	PUREC_func.\0	GS_get_w,1,3,<\1>
;-------
		ENDM	;GS_get_w
;------------------------------------
;entry:	a0 -> string
;-------
;exit	d0 =  word value  (as long)
;	d1 =  E_OK flagged EQ|PL  or  E_PARAMETER flagged NE|MI
;------------------------------------
GS_get_w_code	MACRO
;-------
	clr.l	d2			;clear sign flag in d2
	clr.l	d0			;d0 = zero initial value
	move.b	(a0)+,d2		;d2 = next char
	beq.s	.err_number		;error if no number
	cmp.b	#'+',d2			;positive sign ?
	beq.s	.get_number		;if so, go get digits
	cmp.b	#'-',d2			;negative sign ?
	bne.s	.have_poss_digit	;if not, try possible digit
	bset	#31,d2			;set sign flag in d2
.get_number:
	move.b	(a0)+,d2		;d2 = next char
	beq.s	.err_number		;error if no number
.have_poss_digit:
	sub.b	#'0',d2			;(d2 = digit_value) high enough ?
	blt.s	.err_number		;error if no number
	cmp.b	#'9',d2			;digit_value too high ?
	bhi.s	.err_number		;error if no number
	move.b	d2,d0			;d0 = first digit value
	move.b	(a0)+,d2		;d2 = next char
	beq.s	.end_number		;end if no digit
.loop:
	sub.b	#'0',d2			;(d2 = digit_value) high enough ?
	blt.s	.end_number		;end if no digit
	cmp.b	#'9',d2			;digit_value too high ?
	bhi.s	.end_number		;end if no digit
	move	d0,d1			;d1 = old_value
	asl	#2,d1			;d0 = old_value*4
	add	d1,d0			;d0 = old_value*5
	add	d0,d0			;d0 = old_value*10
	add	d2,d0			;d0 = old_value*10+digit_value
	move.b	(a0)+,d2		;d2 = next char
	bne.s	.loop			;loop until no more digits
.end_number:
	tst.l	d2			;test sign flag
	beq.s	.exit			;exit if positive
	neg.l	d0			;else negate result
.exit:
	moveq	#E_OK,d1		;d1 = E_OK flagged EQ|PL
	rts
;-------
.err_number:
	moveq	#E_PARAMETER,d1		;d1 = E_PARAMETER flagged NE|MI
	rts
;-------
	ENDM	;GS_get_w_code
;----------------------------------------------------------------------------
;int32	GS_get_b(char *string);
;------------------------------------
GS_get_b	MACRO	string
;-------
	_uniref	GS_get_b
	PUREC_func.\0	GS_get_b,1,3,<\1>
;-------
		ENDM	;GS_get_b
;------------------------------------
;entry:	a0 -> string
;-------
;exit	d0 =  byte value  (as long)
;	d1 =  E_OK flagged EQ|PL  or  E_PARAMETER flagged NE|MI
;------------------------------------
GS_get_b_code	MACRO
;-------
	clr	d2			;clear sign flag in d2
	clr.l	d0			;d0 = zero initial value
	move.b	(a0)+,d2		;d2 = next char
	beq.s	.err_number		;error if no number
	cmp.b	#'+',d2			;positive sign ?
	beq.s	.get_number		;if so, go get digits
	cmp.b	#'-',d2			;negative sign ?
	bne.s	.have_poss_digit	;if not, try possible digit
	bset	#15,d2			;set sign flag in d2
.get_number:
	move.b	(a0)+,d2		;d2 = next char
	beq.s	.err_number		;error if no number
.have_poss_digit:
	sub.b	#'0',d2			;(d2 = digit_value) high enough ?
	blt.s	.err_number		;error if no number
	cmp.b	#'9',d2			;digit_value too high ?
	bhi.s	.err_number		;error if no number
	move.b	d2,d0			;d0 = first digit value
	move.b	(a0)+,d2		;d2 = next char
	beq.s	.end_number		;end if no digit
.loop:
	sub.b	#'0',d2			;(d2 = digit_value) high enough ?
	blt.s	.end_number		;end if no digit
	cmp.b	#'9',d2			;digit_value too high ?
	bhi.s	.end_number		;end if no digit
	move.b	d0,d1			;d1 = old_value
	asl.b	#2,d1			;d0 = old_value*4
	add.b	d1,d0			;d0 = old_value*5
	add.b	d0,d0			;d0 = old_value*10
	add.b	d2,d0			;d0 = old_value*10+digit_value
	move.b	(a0)+,d2		;d2 = next char
	bne.s	.loop			;loop until no more digits
.end_number:
	tst	d2			;test sign flag
	beq.s	.exit			;exit if positive
	neg.l	d0			;else negate result
.exit:
	moveq	#E_OK,d1		;d1 = E_OK flagged EQ|PL
	rts
;-------
.err_number:
	moveq	#E_PARAMETER,d1		;d1 = E_PARAMETER flagged NE|MI
	rts
;-------
	ENDM	;GS_get_b_code
;----------------------------------------------------------------------------
;int32	GS_put_l(char *string);
;------------------------------------
GS_put_l	MACRO	string
;-------
	_uniref	GS_put_l
	PUREC_func.\0	GS_put_l,2,$E,<\1>,<\2>
;-------
		ENDM	;GS_put_l
;------------------------------------
;entry:	a0 -> string
;-------
;exit	d0 =  byte value  (as long)
;	d1 =  E_OK flagged EQ|PL  or  E_PARAMETER flagged NE|MI
;------------------------------------
GS_put_l_code	MACRO
;-------
	tst.l	d0
	bpl.s	.done_sign
	neg.l	d0
	move.b	#'-',(a0)+
.done_sign:
	move.l	a0,a1		;a1 =  a0 -> room for first digit
	move.l	#2000000000,d2	;d2 =  2*10**9
	cmp.l	d2,d0		;d0 >= 2*10**9 ?
	blo.s	.dig_10_lt_2
	sub.l	d2,d0		;d0 -= 2*10**9 ?
	move.b	#'2',(a0)+	;store '2' as dig_10
	bra.s	.done_dig_10
;-------
.dig_10_lt_2:
	lsr.l	#1,d2		;d2 =  1*10**9
	cmp.l	d2,d0		;d0 >= 2*10**9 ?
	blo.s	.done_dig_10
	sub.l	d2,d0		;d0 -= 2*10**9 ?
	move.b	#'1',(a0)+	;store '1' as dig_10
	bra.s	.done_dig_10
;-------
.done_dig_10:
	clr	d1		;d1 = digit_value 0
	move.l	#800000000,d2	;d2 =  8*10**8
	cmp.l	d2,d0		;d0 >= 8*10**8
	blo.s	.dig_9_lt_8
	sub.l	d2,d0		;d0 -= 8*10**8
	addq	#8,d1		;d1 += 8
.dig_9_lt_8:
	lsr.l	#1,d2		;d2 =  4*10**8
	cmp.l	d2,d0		;d0 >= 4*10**8
	blo.s	.dig_9_lt_4
	sub.l	d2,d0		;d0 -= 4*10**8
	addq	#4,d1		;d1 += 4
.dig_9_lt_4:
	lsr.l	#1,d2		;d2 =  2*10**8
	cmp.l	d2,d0		;d0 >= 2*10**8
	blo.s	.dig_9_lt_2
	sub.l	d2,d0		;d0 -= 2*10**8
	addq	#2,d1		;d1 += 2
.dig_9_lt_2:
	lsr.l	#1,d2		;d2 =  1*10**8
	cmp.l	d2,d0		;d0 >= 1*10**8
	blo.s	.test_dig_9
	sub.l	d2,d0		;d0 -= 1*10**8
	addq	#1,d1		;d1 += 1
	bra.s	.stor_dig_9	;go store non_zero digit
;-------
.test_dig_9:
	tst	d1		;non_zero digit ?
	bne.s	.stor_dig_9	;then go store it
	cmp.l	a1,a0		;any preceding digit ?
	beq.s	.done_dig_9	;if not, just pass on
.stor_dig_9:
	add.b	#'0',d1		;d1 = ascii digit
	move.b	d1,(a0)+	;store d1 as dig_9
	clr	d1		;d1 = digit_value 0
.done_dig_9:
	move.l	#80000000,d2	;d2 =  8*10**7
	cmp.l	d2,d0		;d0 >= 8*10**7
	blo.s	.dig_8_lt_8
	sub.l	d2,d0		;d0 -= 8*10**7
	addq	#8,d1		;d1 += 8
.dig_8_lt_8:
	lsr.l	#1,d2		;d2 =  4*10**7
	cmp.l	d2,d0		;d0 >= 4*10**7
	blo.s	.dig_8_lt_4
	sub.l	d2,d0		;d0 -= 4*10**7
	addq	#4,d1		;d1 += 4
.dig_8_lt_4:
	lsr.l	#1,d2		;d2 =  2*10**7
	cmp.l	d2,d0		;d0 >= 2*10**7
	blo.s	.dig_8_lt_2
	sub.l	d2,d0		;d0 -= 2*10**7
	addq	#2,d1		;d1 += 2
.dig_8_lt_2:
	lsr.l	#1,d2		;d2 =  1*10**7
	cmp.l	d2,d0		;d0 >= 1*10**7
	blo.s	.test_dig_8
	sub.l	d2,d0		;d0 -= 1*10**7
	addq	#1,d1		;d1 += 1
	bra.s	.stor_dig_8	;go store non_zero digit
;-------
.test_dig_8:
	tst	d1		;non_zero digit ?
	bne.s	.stor_dig_8	;then go store it
	cmp.l	a1,a0		;any preceding digit ?
	beq.s	.done_dig_8	;if not, just pass on
.stor_dig_8:
	add.b	#'0',d1		;d1 = ascii digit
	move.b	d1,(a0)+	;store d1 as dig_8
	clr	d1		;d1 = digit_value 0
.done_dig_8:
	move.l	#8000000,d2	;d2 =  8*10**6
	cmp.l	d2,d0		;d0 >= 8*10**6
	blo.s	.dig_7_lt_8
	sub.l	d2,d0		;d0 -= 8*10**6
	addq	#8,d1		;d1 += 8
.dig_7_lt_8:
	lsr.l	#1,d2		;d2 =  4*10**6
	cmp.l	d2,d0		;d0 >= 4*10**6
	blo.s	.dig_7_lt_4
	sub.l	d2,d0		;d0 -= 4*10**6
	addq	#4,d1		;d1 += 4
.dig_7_lt_4:
	lsr.l	#1,d2		;d2 =  2*10**6
	cmp.l	d2,d0		;d0 >= 2*10**6
	blo.s	.dig_7_lt_2
	sub.l	d2,d0		;d0 -= 2*10**6
	addq	#2,d1		;d1 += 2
.dig_7_lt_2:
	lsr.l	#1,d2		;d2 =  1*10**6
	cmp.l	d2,d0		;d0 >= 1*10**6
	blo.s	.test_dig_7
	sub.l	d2,d0		;d0 -= 1*10**6
	addq	#1,d1		;d1 += 1
	bra.s	.stor_dig_7	;go store non_zero digit
;-------
.test_dig_7:
	tst	d1		;non_zero digit ?
	bne.s	.stor_dig_7	;then go store it
	cmp.l	a1,a0		;any preceding digit ?
	beq.s	.done_dig_7	;if not, just pass on
.stor_dig_7:
	add.b	#'0',d1		;d1 = ascii digit
	move.b	d1,(a0)+	;store d1 as dig_7
	clr	d1		;d1 = digit_value 0
.done_dig_7:
	move.l	#800000,d2	;d2 =  8*10**5
	cmp.l	d2,d0		;d0 >= 8*10**5
	blo.s	.dig_6_lt_8
	sub.l	d2,d0		;d0 -= 8*10**5
	addq	#8,d1		;d1 += 8
.dig_6_lt_8:
	lsr.l	#1,d2		;d2 =  4*10**5
	cmp.l	d2,d0		;d0 >= 4*10**5
	blo.s	.dig_6_lt_4
	sub.l	d2,d0		;d0 -= 4*10**5
	addq	#4,d1		;d1 += 4
.dig_6_lt_4:
	lsr.l	#1,d2		;d2 =  2*10**5
	cmp.l	d2,d0		;d0 >= 2*10**5
	blo.s	.dig_6_lt_2
	sub.l	d2,d0		;d0 -= 2*10**5
	addq	#2,d1		;d1 += 2
.dig_6_lt_2:
	lsr.l	#1,d2		;d2 =  1*10**5
	cmp.l	d2,d0		;d0 >= 1*10**5
	blo.s	.test_dig_6
	sub.l	d2,d0		;d0 -= 1*10**5
	addq	#1,d1		;d1 += 1
	bra.s	.stor_dig_6	;go store non_zero digit
;-------
.test_dig_6:
	tst	d1		;non_zero digit ?
	bne.s	.stor_dig_6	;then go store it
	cmp.l	a1,a0		;any preceding digit ?
	beq.s	.done_dig_6	;if not, just pass on
.stor_dig_6:
	add.b	#'0',d1		;d1 = ascii digit
	move.b	d1,(a0)+	;store d1 as dig_6
	clr	d1		;d1 = digit_value 0
.done_dig_6:
	move.l	#80000,d2	;d2 =  8*10**4
	cmp.l	d2,d0		;d0 >= 8*10**4
	blo.s	.dig_5_lt_8
	sub.l	d2,d0		;d0 -= 8*10**4
	addq	#8,d1		;d1 += 8
.dig_5_lt_8:
	move.l	#40000,d2
	cmp.l	d2,d0		;d0 >= 4*10**4
	blo.s	.dig_5_lt_4
	sub.l	d2,d0		;d0 -= 4*10**4
	addq	#4,d1		;d1 += 4
.dig_5_lt_4:
	cmp	#20000,d0	;d0 >= 2*10**4
	blo.s	.dig_5_lt_2
	sub	#20000,d0	;d0 -= 2*10**4
	addq	#2,d1		;d1 += 2
.dig_5_lt_2:
	cmp	#10000,d0	;d0 >= 1*10**4
	blo.s	.test_dig_5
	sub	#10000,d0	;d0 -= 1*10**4
	addq	#1,d1		;d1 += 1
	bra.s	.stor_dig_5	;go store non_zero digit
;-------
.test_dig_5:
	tst	d1		;non_zero digit ?
	bne.s	.stor_dig_5	;then go store it
	cmp.l	a1,a0		;any preceding digit ?
	beq.s	.done_dig_5	;if not, just pass on
.stor_dig_5:
	add.b	#'0',d1		;d1 = ascii digit
	move.b	d1,(a0)+	;store d1 as dig_5
	clr	d1		;d1 = digit_value 0
.done_dig_5:
	cmp	#8000,d0	;d0 >= 8*10**3
	blo.s	.dig_4_lt_8
	sub	#8000,d0	;d0 -= 8*10**3
	addq	#8,d1		;d1 += 8
.dig_4_lt_8:
	cmp	#4000,d0	;d0 >= 4*10**3
	blo.s	.dig_4_lt_4
	sub	#4000,d0	;d0 -= 4*10**3
	addq	#4,d1		;d1 += 4
.dig_4_lt_4:
	cmp	#2000,d0	;d0 >= 2*10**3
	blo.s	.dig_4_lt_2
	sub	#2000,d0	;d0 -= 2*10**3
	addq	#2,d1		;d1 += 2
.dig_4_lt_2:
	cmp	#1000,d0	;d0 >= 1*10**3
	blo.s	.test_dig_4
	sub	#1000,d0	;d0 -= 1*10**3
	addq	#1,d1		;d1 += 1
	bra.s	.stor_dig_4	;go store non_zero digit
;-------
.test_dig_4:
	tst	d1		;non_zero digit ?
	bne.s	.stor_dig_4	;then go store it
	cmp.l	a1,a0		;any preceding digit ?
	beq.s	.done_dig_4	;if not, just pass on
.stor_dig_4:
	add.b	#'0',d1		;d1 = ascii digit
	move.b	d1,(a0)+	;store d1 as dig_4
	clr	d1		;d1 = digit_value 0
.done_dig_4:
	cmp	#800,d0		;d0 >= 8*10**2
	blo.s	.dig_3_lt_8
	sub	#800,d0		;d0 -= 8*10**2
	addq	#8,d1		;d1 += 8
.dig_3_lt_8:
	cmp	#400,d0		;d0 >= 4*10**2
	blo.s	.dig_3_lt_4
	sub	#400,d0		;d0 -= 4*10**2
	addq	#4,d1		;d1 += 4
.dig_3_lt_4:
	cmp	#200,d0		;d0 >= 2*10**2
	blo.s	.dig_3_lt_2
	sub	#200,d0		;d0 -= 2*10**2
	addq	#2,d1		;d1 += 2
.dig_3_lt_2:
	cmp	#100,d0		;d0 >= 1*10**2
	blo.s	.test_dig_3
	sub	#100,d0		;d0 -= 1*10**2
	addq	#1,d1		;d1 += 1
	bra.s	.stor_dig_3	;go store non_zero digit
;-------
.test_dig_3:
	tst	d1		;non_zero digit ?
	bne.s	.stor_dig_3	;then go store it
	cmp.l	a1,a0		;any preceding digit ?
	beq.s	.done_dig_3	;if not, just pass on
.stor_dig_3:
	add.b	#'0',d1		;d1 = ascii digit
	move.b	d1,(a0)+	;store d1 as dig_3
	clr	d1		;d1 = digit_value 0
.done_dig_3:
	cmp	#80,d0		;d0 >= 8*10**1
	blo.s	.dig_2_lt_8
	sub	#80,d0		;d0 -= 8*10**1
	addq	#8,d1		;d1 += 8
.dig_2_lt_8:
	cmp	#40,d0		;d0 >= 4*10**1
	blo.s	.dig_2_lt_4
	sub	#40,d0		;d0 -= 4*10**1
	addq	#4,d1		;d1 += 4
.dig_2_lt_4:
	cmp	#20,d0		;d0 >= 2*10**1
	blo.s	.dig_2_lt_2
	sub	#20,d0		;d0 -= 2*10**1
	addq	#2,d1		;d1 += 2
.dig_2_lt_2:
	cmp	#10,d0		;d0 >= 1*10**1
	blo.s	.test_dig_2
	sub	#10,d0		;d0 -= 1*10**1
	addq	#1,d1		;d1 += 1
	bra.s	.stor_dig_2	;go store non_zero digit
;-------
.test_dig_2:
	tst	d1		;non_zero digit ?
	bne.s	.stor_dig_2	;then go store it
	cmp.l	a1,a0		;any preceding digit ?
	beq.s	.done_dig_2	;if not, just pass on
.stor_dig_2:
	add.b	#'0',d1		;d1 = ascii digit
	move.b	d1,(a0)+	;store d1 as dig_2
	clr	d1		;d1 = digit_value 0
.done_dig_2:
	cmp	#8,d0		;d0 >= 8*10**0
	blo.s	.dig_1_lt_8
	subq	#8,d0		;d0 -= 8*10**0
	addq	#8,d1		;d1 += 8
.dig_1_lt_8:
	cmp	#4,d0		;d0 >= 4*10**0
	blo.s	.dig_1_lt_4
	subq	#4,d0		;d0 -= 4*10**0
	addq	#4,d1		;d1 += 4
.dig_1_lt_4:
	cmp	#2,d0		;d0 >= 2*10**0
	blo.s	.dig_1_lt_2
	subq	#2,d0		;d0 -= 2*10**0
	addq	#2,d1		;d1 += 2
.dig_1_lt_2:
	tst	d0		;d0 >  0*10**0
	beq.s	.stor_dig_1
	addq	#1,d1		;d1 += 1
.stor_dig_1:
	add.b	#'0',d1		;d1 = ascii digit
	move.b	d1,(a0)+	;store d1 as dig_1
.done_dig_1:
	clr.b	(a0)+		;terminate string
	clr.b	(a0)+		;terminate string list
	rts
;-------
	ENDM	;GS_put_l_code
;----------------------------------------------------------------------------
;int32	GS_put_w(char *string);
;------------------------------------
GS_put_w	MACRO	string
;-------
	_uniref	GS_put_w
	PUREC_func.\0	GS_put_w,2,$E,<\1>,<\2>
;-------
		ENDM	;GS_put_w
;------------------------------------
;entry:	a0 -> string
;-------
;exit	d0 =  byte value  (as long)
;	d1 =  E_OK flagged EQ|PL  or  E_PARAMETER flagged NE|MI
;------------------------------------
GS_put_w_code	MACRO
;-------
	tst.w	d0
	bpl.s	.done_sign
	neg.w	d0
	move.b	#'-',(a0)+
.done_sign:
	move.l	a0,a1		;a1 =  a0 -> room for first digit
	clr	d1		;d1 = digit_value 0
	cmp	#20000,d0	;d0 >= 2*10**4
	blo.s	.dig_5_lt_2
	sub	#20000,d0	;d0 -= 2*10**4
	addq	#2,d1		;d1 += 2
.dig_5_lt_2:
	cmp	#10000,d0	;d0 >= 1*10**4
	blo.s	.test_dig_5
	sub	#10000,d0	;d0 -= 1*10**4
	addq	#1,d1		;d1 += 1
	bra.s	.stor_dig_5	;go store non_zero digit
;-------
.test_dig_5:
	tst	d1		;non_zero digit ?
	beq.s	.done_dig_5	;if not, just pass on
.stor_dig_5:
	add.b	#'0',d1		;d1 = ascii digit
	move.b	d1,(a0)+	;store d1 as dig_5
	clr	d1		;d1 = digit_value 0
.done_dig_5:
	cmp	#8000,d0	;d0 >= 8*10**3
	blo.s	.dig_4_lt_8
	sub	#8000,d0	;d0 -= 8*10**3
	addq	#8,d1		;d1 += 8
.dig_4_lt_8:
	cmp	#4000,d0	;d0 >= 4*10**3
	blo.s	.dig_4_lt_4
	sub	#4000,d0	;d0 -= 4*10**3
	addq	#4,d1		;d1 += 4
.dig_4_lt_4:
	cmp	#2000,d0	;d0 >= 2*10**3
	blo.s	.dig_4_lt_2
	sub	#2000,d0	;d0 -= 2*10**3
	addq	#2,d1		;d1 += 2
.dig_4_lt_2:
	cmp	#1000,d0	;d0 >= 1*10**3
	blo.s	.test_dig_4
	sub	#1000,d0	;d0 -= 1*10**3
	addq	#1,d1		;d1 += 1
	bra.s	.stor_dig_4	;go store non_zero digit
;-------
.test_dig_4:
	tst	d1		;non_zero digit ?
	bne.s	.stor_dig_4	;then go store it
	cmp.l	a1,a0		;any preceding digit ?
	beq.s	.done_dig_4	;if not, just pass on
.stor_dig_4:
	add.b	#'0',d1		;d1 = ascii digit
	move.b	d1,(a0)+	;store d1 as dig_4
	clr	d1		;d1 = digit_value 0
.done_dig_4:
	cmp	#800,d0		;d0 >= 8*10**2
	blo.s	.dig_3_lt_8
	sub	#800,d0		;d0 -= 8*10**2
	addq	#8,d1		;d1 += 8
.dig_3_lt_8:
	cmp	#400,d0		;d0 >= 4*10**2
	blo.s	.dig_3_lt_4
	sub	#400,d0		;d0 -= 4*10**2
	addq	#4,d1		;d1 += 4
.dig_3_lt_4:
	cmp	#200,d0		;d0 >= 2*10**2
	blo.s	.dig_3_lt_2
	sub	#200,d0		;d0 -= 2*10**2
	addq	#2,d1		;d1 += 2
.dig_3_lt_2:
	cmp	#100,d0		;d0 >= 1*10**2
	blo.s	.test_dig_3
	sub	#100,d0		;d0 -= 1*10**2
	addq	#1,d1		;d1 += 1
	bra.s	.stor_dig_3	;go store non_zero digit
;-------
.test_dig_3:
	tst	d1		;non_zero digit ?
	bne.s	.stor_dig_3	;then go store it
	cmp.l	a1,a0		;any preceding digit ?
	beq.s	.done_dig_3	;if not, just pass on
.stor_dig_3:
	add.b	#'0',d1		;d1 = ascii digit
	move.b	d1,(a0)+	;store d1 as dig_3
	clr	d1		;d1 = digit_value 0
.done_dig_3:
	cmp	#80,d0		;d0 >= 8*10**1
	blo.s	.dig_2_lt_8
	sub	#80,d0		;d0 -= 8*10**1
	addq	#8,d1		;d1 += 8
.dig_2_lt_8:
	cmp	#40,d0		;d0 >= 4*10**1
	blo.s	.dig_2_lt_4
	sub	#40,d0		;d0 -= 4*10**1
	addq	#4,d1		;d1 += 4
.dig_2_lt_4:
	cmp	#20,d0		;d0 >= 2*10**1
	blo.s	.dig_2_lt_2
	sub	#20,d0		;d0 -= 2*10**1
	addq	#2,d1		;d1 += 2
.dig_2_lt_2:
	cmp	#10,d0		;d0 >= 1*10**1
	blo.s	.test_dig_2
	sub	#10,d0		;d0 -= 1*10**1
	addq	#1,d1		;d1 += 1
	bra.s	.stor_dig_2	;go store non_zero digit
;-------
.test_dig_2:
	tst	d1		;non_zero digit ?
	bne.s	.stor_dig_2	;then go store it
	cmp.l	a1,a0		;any preceding digit ?
	beq.s	.done_dig_2	;if not, just pass on
.stor_dig_2:
	add.b	#'0',d1		;d1 = ascii digit
	move.b	d1,(a0)+	;store d1 as dig_2
	clr	d1		;d1 = digit_value 0
.done_dig_2:
	cmp	#8,d0		;d0 >= 8*10**0
	blo.s	.dig_1_lt_8
	subq	#8,d0		;d0 -= 8*10**0
	addq	#8,d1		;d1 += 8
.dig_1_lt_8:
	cmp	#4,d0		;d0 >= 4*10**0
	blo.s	.dig_1_lt_4
	subq	#4,d0		;d0 -= 4*10**0
	addq	#4,d1		;d1 += 4
.dig_1_lt_4:
	cmp	#2,d0		;d0 >= 2*10**0
	blo.s	.dig_1_lt_2
	subq	#2,d0		;d0 -= 2*10**0
	addq	#2,d1		;d1 += 2
.dig_1_lt_2:
	tst	d0		;d0 >  0*10**0
	beq.s	.stor_dig_1
	addq	#1,d1		;d1 += 1
.stor_dig_1:
	add.b	#'0',d1		;d1 = ascii digit
	move.b	d1,(a0)+	;store d1 as dig_1
.done_dig_1:
	clr.b	(a0)+		;terminate string
	clr.b	(a0)+		;terminate string list
	rts
;-------
	ENDM	;GS_put_w_code
;----------------------------------------------------------------------------
;int32	GS_put_b(char *string);
;------------------------------------
GS_put_b	MACRO	string
;-------
	_uniref	GS_put_b
	PUREC_func.\0	GS_put_b,2,$E,<\1>,<\2>
;-------
		ENDM	;GS_put_b
;------------------------------------
;entry:	a0 -> string
;-------
;exit	d0 =  byte value  (as long)
;	d1 =  E_OK flagged EQ|PL  or  E_PARAMETER flagged NE|MI
;------------------------------------
GS_put_b_code	MACRO
;-------
	tst.b	d0
	bpl.s	.done_sign
	neg.b	d0
	move.b	#'-',(a0)+
.done_sign:
	move.l	a0,a1		;a1 =  a0 -> room for first digit
	clr	d1		;d1 = digit_value 0
	cmp.b	#100,d0		;d0 >= 1*10**2
	blo.s	.done_dig_3
	sub.b	#100,d0		;d0 -= 1*10**2
	addq	#1,d1		;d1 += 1
	add.b	#'0',d1		;d1 = ascii digit
	move.b	d1,(a0)+	;store d1 as dig_3
	clr	d1		;d1 = digit_value 0
.done_dig_3:
	cmp.b	#80,d0		;d0 >= 8*10**1
	blo.s	.dig_2_lt_8
	sub.b	#80,d0		;d0 -= 8*10**1
	addq	#8,d1		;d1 += 8
.dig_2_lt_8:
	cmp.b	#40,d0		;d0 >= 4*10**1
	blo.s	.dig_2_lt_4
	sub.b	#40,d0		;d0 -= 4*10**1
	addq	#4,d1		;d1 += 4
.dig_2_lt_4:
	cmp.b	#20,d0		;d0 >= 2*10**1
	blo.s	.dig_2_lt_2
	sub.b	#20,d0		;d0 -= 2*10**1
	addq	#2,d1		;d1 += 2
.dig_2_lt_2:
	cmp.b	#10,d0		;d0 >= 1*10**1
	blo.s	.test_dig_2
	sub.b	#10,d0		;d0 -= 1*10**1
	addq	#1,d1		;d1 += 1
	bra.s	.stor_dig_2	;go store non_zero digit
;-------
.test_dig_2:
	tst	d1		;non_zero digit ?
	bne.s	.stor_dig_2	;then go store it
	cmp.l	a1,a0		;any preceding digit ?
	beq.s	.done_dig_2	;if not, just pass on
.stor_dig_2:
	add.b	#'0',d1		;d1 = ascii digit
	move.b	d1,(a0)+	;store d1 as dig_2
	clr	d1		;d1 = digit_value 0
.done_dig_2:
	cmp.b	#8,d0		;d0 >= 8*10**0
	blo.s	.dig_1_lt_8
	subq.b	#8,d0		;d0 -= 8*10**0
	addq	#8,d1		;d1 += 8
.dig_1_lt_8:
	cmp.b	#4,d0		;d0 >= 4*10**0
	blo.s	.dig_1_lt_4
	subq.b	#4,d0		;d0 -= 4*10**0
	addq	#4,d1		;d1 += 4
.dig_1_lt_4:
	cmp.b	#2,d0		;d0 >= 2*10**0
	blo.s	.dig_1_lt_2
	subq.b	#2,d0		;d0 -= 2*10**0
	addq	#2,d1		;d1 += 2
.dig_1_lt_2:
	tst	d0		;d0 >  0*10**0
	beq.s	.stor_dig_1
	addq	#1,d1		;d1 += 1
.stor_dig_1:
	add.b	#'0',d1		;d1 = ascii digit
	move.b	d1,(a0)+	;store d1 as dig_1
.done_dig_1:
	clr.b	(a0)+		;terminate string
	clr.b	(a0)+		;terminate string list
	rts
;-------
	ENDM	;GS_put_b_code
;----------------------------------------------------------------------------
GS_gen_data_code	MACRO
GS_part_c:	dc.w	0
GS_part_t:	ds.b	MAX_GS_PARTS*sizeof_GS_PART
GS_part_t_end:
	ENDM	;GS_gen_data_code
;----------------------------------------------------------------------------
	endc	;RA_GS_defined
;----------------------------------------------------------------------------
;End of file:	RA_GS.I
;----------------------------------------------------------------------------
