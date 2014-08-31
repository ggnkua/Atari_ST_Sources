;----------------------------------------------------------------------------
;File name:	MASQUE.S			Revision date:	1998.01.13
;Creator:	Ulf Ronald Andersson		Creation date:	1997.08.10
;(c)1997 by:	Ulf Ronald Andersson		All rights reserved
;Feedback to:	dlanor@oden.se			Released as FREEWARE
;----------------------------------------------------------------------------
;Required header declarations:
;
	.include	"uran\STRUCT.SH"	;PASM adapted structures
	.include	"uran\URAn_SYS.SH"	;Main system definitions
	.include	"uran\URAn_LA.SH"	;Line A variables etc
	.include	"uran\URAn_DOS.SH"	;GEMDOS, BIOS, XBIOS
	.include	"uran\URAn_JAR.SH"	;Cookie jar handling
;
	.include	"sting\PORT.SH"		;only used by modules
	.include	"sting\LAYER.SH"	;only used by servers
	.include	"sting\TRANSPRT.SH"	;used by servers/clients
	.include	"sting\TCP.SH"
	.include	"sting\UDP.SH"
	.include	"sting\NET_TCON.SH"	;handles network time conv.
	.include	"sting\DOMAIN.SH"	;handles domain name/ip conv.
;
;----------------------------------------------------------------------------
;
M_YEAR	equ	1998
M_MONTH	equ	1
M_DAY	equ	13
;
.MACRO	M_TITLE
	dc.b	'Masquerade'
.ENDM	M_TITLE
;
.MACRO	M_VERSION
	dc.b	'01.10'
.ENDM	M_VERSION
;
.MACRO	M_AUTHOR
	dc.b	'Ronald Andersson'
.ENDM	M_AUTHOR
;
;----------------------------------------------------------------------------
;
struct	masq_port
	d_s	masq_port_main,sizeof_prt_des	;as defined in PORT.SH
	struc_p	masq_port_ptr			;-> port to be masked
	uint32	masq_port_ip			;ip number for masking it
d_end	masq_port
;
struct	masq_entry
	struc_p	masq_next
	d_alias	masq_proto_port
	uint16	masq_protocol
	uint16	masq_local_port
	uint32	masq_local_ip
	uint16	masq_index
d_end	masq_entry
;
MASQ_POWER	equ	12		;bits in masq index (port offsets)
MASQ_TOTAL	equ	1<<MASQ_POWER	;same as LINUX (but different method)
MASQ_START	equ	61000		;same as LINUX
MASQ_LIMIT	equ	MASQ_START+MASQ_TOTAL
;
;----------------------------------------------------------------------------
struct	ICMP_HD
	uint8		ICMP_HD_type
	uint8		ICMP_HD_code
	uint16		ICMP_HD_checksum
	d_alias		ICMP_HD_id
	uint8		ICMP_HD_extra_1
	uint8		ICMP_HD_extra_2
	d_alias		ICMP_HD_seq
	uint8		ICMP_HD_extra_3
	uint8		ICMP_HD_extra_4
	d_alias		ICMP_data
d_end	ICMP_HD
;----------------------------------------------------------------------------
;Start of:	STX program
;----------------------------------------------------------------------------
;
	.text
;
;----------------------------------------------------------------------------
text_start:
;----------------------------------------------------------------------------
;
start:
	bra	start_1
;
;----------------------------------------------------------------------------
;Start of:	Resident STX data
;----------------------------------------------------------------------------
;
my_port:
	dc.l	port_name_s	;prt_des_name
	dc.w	L_MASQUE	;prt_des_type
	dc.w	0		;prt_des_active		Activation flag
	dc.l	0		;prt_des_flags
	dc.l	$0A00FF01	;prt_des_ip_addr	IP_number
	dc.l	-1		;prt_des_sub_mask
	dc.w	1500		;prt_des_mtu
	dc.w	1500		;prt_des_max_mtu
	dc.l	0		;prt_des_stat_sd_data
	dc.l	0		;prt_des_send		->Tx queue
	dc.l	0		;prt_des_stat_rcv_data
	dc.l	0		;prt_des_receive	->Rx queue
	dc.w	0		;prt_des_stat_dropped
	dc.l	my_driver	;prt_des_driver		->driver struct
	dc.l	0		;prt_des_next		->next port
;
;the port data is extended with 'Masque' specific data below
;
masq_port_p:
	dc.l	0		;masq_port_ptr	;port to be masked
dummy_IP:
	dc.l	$0A00FF00	;masq_port_ip	;ip number for masking it
;
;
my_driver:
	dc.l	my_set_state	;drv_des_set_state
	dc.l	my_send		;drv_des_send
	dc.l	my_receive	;drv_des_receive
	dc.l	driver_name_s	;drv_des_name
	dc.l	version_s	;drv_des_version
	dc.w	((M_YEAR-1980)<<9)|(M_MONTH<<5)|M_DAY
	dc.l	author_s	;drv_des_author
	dc.l	0		;drv_des_next		->next driver
basepage_p:
	dc.l	start-$100	;drv_des_basepage	->basepage of self
;
port_name_s:
driver_name_s:
	M_TITLE
	dc.b	NUL
	even
;
version_s:
	M_VERSION
	dc.b	NUL
	even
;
author_s:
	M_AUTHOR
	dc.b	NUL
	even
;
MASQ_PORT_vn_s:
	dc.b	'MASQ_PORT',NUL
	even
;
masq_port_name_p:		;char *masq_port_name_p;
	dc.l	0
;
masked_IP:			;uint32 masked_IP;
	dc.l	0
;
masq_root_p:			;struct masq_entry *masq_root_p;
	dc.l	0
masq_count:			;uint16	masq_count;
	dc.w	0
masq_time:			;uint32 masq_time;
	dc.l	0
;
masq_temp_2L:
masq_temp_0:
	dc.l	0
masq_temp_1:
	dc.l	0
;
active_f:			;uint16	active_f;
	dc.w	0
;
sting_drivers:	ds.l	1	;DRV_LIST	*sting_drivers;
tpl:		ds.l	1	;TPL		*tpl;
stx:		ds.l	1	;STX		*stx;
;
;----------------------------------------------------------------------------
;End of:	Resident STX data
;----------------------------------------------------------------------------
;Start of:	Resident functions and subroutines
;----------------------------------------------------------------------------
;
my_send:
	link	a6,#0
	movem.l	d3-d5/a2-a5,-(sp)
	lea	my_port(pc),a5			;a5 -> my_port
	cmpa.l	8(a6),a5			;argument correct
	bne	.exit				;exit if argument incorrect
	tst	active_f			;are we active ?
	beq	.exit				;exit if we're not active
	move.l	masq_port_p(pc),a4		;a4 -> masq_port
	move.l	a4,d0				;is this valid
	ble	.exit				;exit if pointer not valid
	move.l	dummy_IP(PC),d4			;d4 = dummy_IP  (for masq_port)
	cmp.l	prt_des_ip_addr(a4),d4		;is port IP correctly masked
	beq.s	.port_IP_ok			;go keep masked port IP
	move.l	prt_des_ip_addr(a4),masked_IP	;store connection IP number
	move.l	d4,prt_des_ip_addr(a4)		;mask IP number of masq_port
.port_IP_ok:
	TIMER_now				;find work start time
	move.l	d0,masq_time			;store start time for future
	move.l	masked_IP(pc),d5		;d5 = masked_IP  (masqueing)
;
;The loop below is the main loop inside which all masking and unmasking
;of datagrams is made. The detail work is performed by some subroutines.
;
.send_loop:
	move.l	prt_des_send(a5),d3		;Tx queue empty ?
	ble	.exit				;if empty, just exit
;
	TIMER_elapsed	masq_time(pc)		;how long have we worked ?
	cmp.l	#50,d0				;50 ms or more ?
	bhs.s	.exit				;if so, exit
;
;The TIMER calls above ensures that we will not lock up the rest of
;the system even when traffic is intense on some high speed channel.
;
	move.l	d3,a3				;a3 -> Tx dgram of my_port
	move.l	IPDG_next(a3),prt_des_send(a5)	;unlink it from the chain
	clr.l	IPDG_next(a3)			;and cut link from it
	check_dgram_ttl	(a3)
	tst.l	d0
	bpl.s	.send_it
	addq	#1,prt_des_stat_dropped(a5)
	bra.s	.send_loop
;
.send_it:
	cmp.l	IPDG_hdr+IPHD_ip_dest(a3),d5	;packet from Internet ?
	bne.s	.not_masked			;if not, go mask it and send
;
;We come here for each incoming packet from Internet
;
	bsr	unmask_datagram			;unmask the datagram
	move.l	a0,d0				;dgram ok or dropped
	ble.s	.send_loop			;try another if this dropped
	lea	prt_des_receive(a5),a2		;a2 -> Rx queue of my_port
	bra.s	.recvgram_test			;go pass it to receiver
;
;The inner loop below adds datagram (a0) to reception queue of my_port
;
.recvgram_loop:
	lea	IPDG_next(a1),a2		;(a2) -> next dgram or is NULL
.recvgram_test:
	move.l	(a2),a1				;a1 -> old dgram or is NULL
	move.l	a1,d0				;at end of reception queue ?
	bne.s	.recvgram_loop			;loop back to pass old stuff
	move.l	a0,(a2)				;store new dgram at end of queue
	clr.l	d0
	move	IPDG_pkt_length(a0),d0
	add.l	d0,prt_des_stat_rcv_data(a5)	;count sent data
	bra.s	.send_loop			;loop back for more new stuff
;
;-------------------------------------
;We come here for each outgoing packet to the Internet
;
.not_masked:
	bsr	mask_datagram
	move.l	a0,d0				;dgram ok or dropped
	ble.s	.send_loop			;try another if this dropped
	lea	prt_des_send(a4),a2		;a2 -> Tx queue of masq_port
	bra.s	.sendgram_test
;
;The inner loop below adds datagram (a0) to transmission queue of masq_port
;
.sendgram_loop:
	lea	IPDG_next(a1),a2		;(a2) -> next dgram or is NULL
.sendgram_test:
	move.l	(a2),a1				;a1 -> old dgram or is NULL
	move.l	a1,d0
	bne.s	.sendgram_loop			;loop back to pass old stuff
	move.l	a0,(a2)				;store new dgram at end of chain
	clr.l	d0
	move	IPDG_pkt_length(a0),d0
	add.l	d0,prt_des_stat_sd_data(a5)	;count sent data
	bra	.send_loop			;loop back for more new stuff
;
.exit:
	movem.l	(sp)+,d3-d5/a2-a5
	unlk	a6
	rts
;
;end of my_send
;----------------------------------------------------------------------------
;
my_receive:
	rts
;
;end of my_receive  (That was easy...  :-)
;----------------------------------------------------------------------------
;
my_set_state:
	link	a6,#0
	movem.l	a2-a3,-(sp)
	clr.l	d0
	lea	my_port(pc),a0
	cmpa.l	8(a6),a0
	bne	.exit
	move	12(a6),d0		;d0 = new state
	beq.s	.passivate
.activate:
	tst	active_f
	bne	.done
	move.l	masq_port_p(pc),d0
	bgt.s	.have_port
	bsr	find_masq_port
	move.l	a0,masq_port_p
	ble.s	.done
	move.l	a0,d0
.have_port:
	move.l	d0,a0
	cmp	#L_INTERNAL,prt_des_type(a0)	;Internal port
	beq.s	.illegal_port
	cmp	#L_MASQUE,prt_des_type(a0)	;Masquerade port
	bne.s	.legal_port
.illegal_port:
	clr.l	d0
	bra.s	.exit
;
.legal_port:
	move.l	dummy_IP(pc),d0
	cmp.l	prt_des_ip_addr(a0),d0
	beq.s	.port_IP_ok
	move.l	prt_des_ip_addr(a0),masked_IP
	move.l	d0,prt_des_ip_addr(a0)
.port_IP_ok:
	st	active_f			;flag activation success
	bra.s	.done
;
.passivate:
	tst	active_f
	beq.s	.done
	move.l	masq_port_p(pc),a0
	move.l	a0,d0
	ble.s	.clear_masqing
	move.l	masked_IP(pc),prt_des_ip_addr(a0)
.clear_masqing:
	clr	active_f
	clr	masq_count
	lea	masq_root_p(pc),a0
	move.l	(a0),d0			;d0 -> masq entry or is NULL
	ble.s	.done
	clr.l	(a0)
.loop:					;loop start to release masq RAM
	move.l	d0,a3
	KRfree	(a3)			;release masq entry RAM
	move.l	masq_next(a3),d0
	bgt.s	.loop			;loop back to release all entries
.done:
	moveq	#1,d0
.exit:
	movem.l	(sp)+,a2-a3
	unlk	a6
	rts
;
;end of my_set_state
;----------------------------------------------------------------------------
;IP_DGRAM *mask_datagram(IP_DGRAM dgram);	/* returns NULL if dropped */
;
;NB: non-standard register assumptions:
;
;a5 -> my_port  a4 -> masq_port  a3 -> dgram  d5 = masking_IP
;
;This code is called for each outgoing packet (normally to Internet)
;
mask_datagram:
	move.l	a3,a0				;prep to return same dgram if ok
	cmp.l	IPDG_hdr+IPHD_ip_src(a3),d5	;already masked ?
	beq	mask_exit			;branch if insane ;-)
	move.l	IPDG_pkt_data(a3),a2		;a2 -> protocol packet
	clr	d3				;preclear bits 8-15 of d3
	move.b	IPDG_hdr+IPHD_protocol(a3),d3	;d3 = protocol
	cmp	#P_ICMP,d3
	beq.s	mask_ICMP
	cmp	#P_TCP,d3
	beq.s	mask_TCP
	cmp	#P_UDP,d3
	beq.s	mask_UDP
mask_failed:
mask_ICMP_errmsg:	;PATCH move label to implement outgoing error messages
mask_ICMP_reply:	;PATCH move label to implement outgoing ICMP replies
	IP_discard	(a3),#1
	addq		#1,prt_des_stat_dropped(a5)
	suba.l		a0,a0
	bra		mask_exit
;
mask_TCP:
	swap	d3				;d3 = protocol<<16
	move	tcph_src_port(a2),d3		;d3 = protocol.src_port
	bsr	mask_common			;try to mask the packet
	bmi.s	mask_failed			;exit with failure on error
	move	d0,tcph_src_port(a2)		;mask TCP source port
post_fix_TCP:
	move	IPDG_pkt_length(a3),d2		;arg d2 =  TCP packet length
	move.l	a2,a0				;arg a0 -> TCP packet header
	move.l	IPDG_hdr+IPHD_ip_dest(a3),d1	;arg d1 =  dest IP
	move.l	IPDG_hdr+IPHD_ip_src(a3),d0	;arg d0 =  src  IP
	bsr	make_TCP_checksum		;calculate TCP checksum
	move	d0,tcph_chksum(a2)		;patch TCP checksum
	bra.s	post_mask_IP			;go calc & patch IP checksum
;
mask_UDP:
	swap	d3				;d3 = protocol<<16
	move	UDP_hdr_source_port(a2),d3	;d3 = protocol.src_port
	bsr	mask_common			;try to mask the packet
	bmi.s	mask_failed			;exit with failure on error
	move	d0,UDP_hdr_source_port(a2)	;mask UDP source port
	move.l	a2,a0				;arg a0 -> UDP packet header
	move.l	IPDG_hdr+IPHD_ip_dest(a3),d1	;arg d1 =  dest IP
	move.l	IPDG_hdr+IPHD_ip_src(a3),d0	;arg d0 =  src  IP
	bsr	make_UDP_checksum		;calculate UDP checksum
	move	d0,UDP_hdr_checksum(a2)		;patch UDP checksum
post_mask_IP:
	move.l	a3,a0				;arg a0 -> masked datagram
	bsr	make_IP_check			;calculate IP checksum
	move	d0,IPDG_hdr+IPHD_hdr_chksum(a0)	;patch IP checksum
	rts
;
mask_ICMP:
	clr	d0				;preclear high bits
	move.b	ICMP_HD_type(a2),d0		;d0 = ICMP message type
	cmp	#max_ICMP_type,d0		;Unrecognized ?
	bhi.s	mask_failed			;strange type => error exit
	add	d0,d0				;make it a word index
	move	icmp_mask_t(pc,d0.w),d0		;get offset to function code
	jmp	icmp_mask_t(pc,d0.w)		;go mask dependent on ICMP type
;
icmp_mask_t:
	dc.w	mask_ICMP_reply-icmp_mask_t	;ICMP type  0
	dc.w	mask_failed-icmp_mask_t		;ICMP type  1
	dc.w	mask_failed-icmp_mask_t		;ICMP type  2
	dc.w	mask_ICMP_errmsg-icmp_mask_t	;ICMP type  3
;
	dc.w	mask_ICMP_errmsg-icmp_mask_t	;ICMP type  4
	dc.w	mask_ICMP_errmsg-icmp_mask_t	;ICMP type  5
	dc.w	mask_failed-icmp_mask_t		;ICMP type  6
	dc.w	mask_failed-icmp_mask_t		;ICMP type  7
;
	dc.w	mask_ICMP_request-icmp_mask_t	;ICMP type  8
	dc.w	mask_failed-icmp_mask_t		;ICMP type  9
	dc.w	mask_failed-icmp_mask_t		;ICMP type 10
	dc.w	mask_ICMP_errmsg-icmp_mask_t	;ICMP type 11
;
	dc.w	mask_ICMP_errmsg-icmp_mask_t	;ICMP type 12
	dc.w	mask_ICMP_request-icmp_mask_t	;ICMP type 13
	dc.w	mask_ICMP_reply-icmp_mask_t	;ICMP type 14
	dc.w	mask_ICMP_request-icmp_mask_t	;ICMP type 15
;
	dc.w	mask_ICMP_reply-icmp_mask_t	;ICMP type 16
	dc.w	mask_ICMP_request-icmp_mask_t	;ICMP type 17
	dc.w	mask_ICMP_reply-icmp_mask_t	;ICMP type 18
icmp_mask_t_end:
max_ICMP_type	equ	((icmp_mask_t_end-icmp_mask_t)/2)-1
;
mask_ICMP_request:
	tst.b	ICMP_HD_code(a2)		;Code non_zero ?  (abnormal)
	bne	mask_failed			;weird code => error exit
	swap	d3				;d3 = protocol<<16
	move	ICMP_HD_id(a2),d3		;d3 = protocol.identifier
	bsr	mask_common			;try to mask the packet
	bmi	mask_failed			;exit with failure on error
	move	d0,ICMP_HD_id(a2)		;mask ICMP identifier
	move.l	a2,a0				;a0 -> protocol packet
	move	IPDG_pkt_length(a3),d0		;d0 -> protocol packet length
	bsr	make_ICMP_checksum		;calculate ICMP checksum
	move	d0,ICMP_HD_checksum(a2)		;patch ICMP checksum
	bra.s	post_mask_IP			;go calc & patch IP checksum
;
mask_exit:
	rts
;
;end of mask_datagram
;----------------------------------------------------------------------------
;IP_DGRAM *unmask_datagram(IP_DGRAM dgram);	/* returns NULL if dropped */
;
;NB: non-standard register assumptions:
;
;a5 -> my_port  a4 -> masq_port  a3 -> dgram  d5 = masking_IP
;
;This code is called for each incoming packet (normally from Internet)
;
unmask_datagram:
	move.l	IPDG_pkt_data(a3),a2		;a2 -> protocol packet
	clr	d3				;preclear bits 8-15 of d3
	move.b	IPDG_hdr+IPHD_protocol(a3),d3	;d3 = protocol
	cmp	#P_ICMP,d3
	beq	unmask_ICMP
	cmp	#P_TCP,d3
	beq.s	unmask_TCP
	cmp	#P_UDP,d3
	beq.s	unmask_UDP
unmask_failed:
unmask_ICMP_request:	;PATCH move label to implement incoming ICMP requests
	IP_discard	(a3),#1
	addq		#1,prt_des_stat_dropped(a5)
	suba.l		a0,a0			;null a0 to flag error
	bra		unmask_exit		;go return NULL
;
unmask_TCP:
	swap	d3				;d3 = protocol<<16
	move	tcph_dest_port(a2),d3		;d3 = protocol.dest_port
	bsr	unmask_common
	bmi.s	unmask_failed			;exit with failure on error
	move	d0,tcph_dest_port(a2)		;unmask TCP destination port
	move	IPDG_pkt_length(a3),d2		;arg d2 =  TCP packet length
	move.l	a2,a0				;arg a0 -> TCP packet header
	move.l	IPDG_hdr+IPHD_ip_dest(a3),d1	;arg d1 =  dest IP
	move.l	IPDG_hdr+IPHD_ip_src(a3),d0	;arg d0 =  src  IP
	bsr	make_TCP_checksum		;calculate TCP checksum
	move	d0,tcph_chksum(a2)		;patch TCP checksum
	bra.s	post_unmask_IP			;go calc & patch IP checksum
;
unmask_UDP:
	swap	d3				;d3 = protocol<<16
	move	UDP_hdr_dest_port(a2),d3	;d3 = protocol.dest_port
	bsr	unmask_common
	bmi.s	unmask_failed			;exit with failure on error
	move	d0,UDP_hdr_dest_port(a2)	;unmask UDP destination port
	move.l	a2,a0				;arg a0 -> UDP packet header
	move.l	IPDG_hdr+IPHD_ip_dest(a3),d1	;arg d1 =  dest IP
	move.l	IPDG_hdr+IPHD_ip_src(a3),d0	;arg d0 =  src  IP
	bsr	make_UDP_checksum		;calculate UDP checksum
	move	d0,UDP_hdr_checksum(a2)		;patch UDP checksum
post_unmask_IP:
	move.l	a3,a0				;arg a0 -> masked datagram
	bsr	make_IP_check			;calculate IP checksum
	move	d0,IPDG_hdr+IPHD_hdr_chksum(a0)	;patch IP checksum
	rts
;
unmask_ICMP:
	clr	d0				;preclear high bits
	move.b	ICMP_HD_type(a2),d0		;d0 = ICMP message type
	cmp	#max_ICMP_type,d0		;Unrecognized ?
	bhi.s	unmask_failed			;strange type => error exit
	add	d0,d0				;make it a word index
	move	icmp_unmask_t(pc,d0.w),d0	;get offset to function code
	jmp	icmp_unmask_t(pc,d0.w)		;go unmask dependent on ICMP type
;
icmp_unmask_t:
	dc.w	unmask_ICMP_reply-icmp_unmask_t	;ICMP type  0
	dc.w	unmask_failed-icmp_unmask_t		;ICMP type  1
	dc.w	unmask_failed-icmp_unmask_t		;ICMP type  2
	dc.w	unmask_ICMP_errmsg-icmp_unmask_t	;ICMP type  3
;
	dc.w	unmask_ICMP_errmsg-icmp_unmask_t	;ICMP type  4
	dc.w	unmask_ICMP_errmsg-icmp_unmask_t	;ICMP type  5
	dc.w	unmask_failed-icmp_unmask_t		;ICMP type  6
	dc.w	unmask_failed-icmp_unmask_t		;ICMP type  7
;
	dc.w	unmask_ICMP_request-icmp_unmask_t	;ICMP type  8
	dc.w	unmask_failed-icmp_unmask_t		;ICMP type  9
	dc.w	unmask_failed-icmp_unmask_t		;ICMP type 10
	dc.w	unmask_ICMP_errmsg-icmp_unmask_t	;ICMP type 11
;
	dc.w	unmask_ICMP_errmsg-icmp_unmask_t	;ICMP type 12
	dc.w	unmask_ICMP_request-icmp_unmask_t	;ICMP type 13
	dc.w	unmask_ICMP_reply-icmp_unmask_t		;ICMP type 14
	dc.w	unmask_ICMP_request-icmp_unmask_t	;ICMP type 15
;
	dc.w	unmask_ICMP_reply-icmp_unmask_t		;ICMP type 16
	dc.w	unmask_ICMP_request-icmp_unmask_t	;ICMP type 17
	dc.w	unmask_ICMP_reply-icmp_unmask_t		;ICMP type 18
icmp_unmask_t_end:
tst_max_ICMP_type	equ	((icmp_unmask_t_end-icmp_unmask_t)/2)-1
;
	.IF	(tst_max_ICMP_type-max_ICMP_type)
	.ERROR	"ICMP mask & unmask tables differ in size !!!"
	.ENDIF
;
unmask_ICMP_errmsg:
	lea	ICMP_data(a2),a1	;a1-> IP header of erring packet
	move.b	IPHD_verlen_f(a1),d0	;d0 = IP header byte with header length
	and	#amask_IPHD_f_hd_len,d0	;d0 = header length in longwords
	asl	#2,d0			;d0 = header length in bytes
	lea	(a1,d0.w),a0		;a0-> high level header of erring packet
	move.b	IPHD_protocol(a1),d3	;d3 = protocol of erring packet
	cmp	#P_TCP,d3
	beq.s	unmask_TCP_errmsg
	cmp	#P_UDP,d3
	beq.s	unmask_UDP_errmsg
	bra	unmask_failed		;return with error on strange protocols
;
unmask_TCP_errmsg:
	swap	d3			;d3 = protocol<<16
	move	tcph_src_port(a0),d3	;d3 = protocol.local_port
	bsr	unmask_common		;try to unmask the packet
	bmi	unmask_failed		;exit with failure on error
	lea	ICMP_data(a2),a1	;a1-> IP header of erring packet
	move.b	IPHD_verlen_f(a1),d1	;d1 = IP header byte with header length
	and	#amask_IPHD_f_hd_len,d1	;d1 = header length in longwords
	asl	#2,d1			;d1 = header length in bytes
	lea	(a1,d1.w),a0		;a0-> high level header of erring packet
	move	d0,tcph_src_port(a0)	;unmask local port of erring packet
	bra	post_unmask_errmsg	;fix err IP, ICMP, main IP checksums
;
unmask_UDP_errmsg:
	swap	d3				;d3 = protocol<<16
	move	UDP_hdr_source_port(a0),d3	;d3 = protocol.local_port
	bsr	unmask_common			;try to unmask the packet
	bmi	unmask_failed		;exit with failure on error
	lea	ICMP_data(a2),a1	;a1-> IP header of erring packet
	move.b	IPHD_verlen_f(a1),d1	;d1 = IP header byte with header length
	and	#amask_IPHD_f_hd_len,d1	;d1 = header length in longwords
	asl	#2,d1			;d1 = header length in bytes
	lea	(a1,d1.w),a0		;a0-> high level header of erring packet
	move	d0,UDP_hdr_source_port(a0)	;unmask local port of erring pkt
	clr	UDP_hdr_checksum(a0)	;invalidate UDP checksum
post_unmask_errmsg:
	move.l	IPDG_hdr+IPHD_ip_dest(a3),IPHD_ip_src(a1)	;loc IP in msg
	move.l	a1,a0			;a0-> IP header
	clr.l	d0			;d0=0 as start_value
	bsr	calc_checksum		;calc checksum of erring IP header
	move	d0,IPHD_hdr_chksum(a0)	;patch IP checksum of erring packet
;
	move.l	a2,a0			;a0 -> protocol packet
	move	IPDG_pkt_length(a3),d0	;d0 -> protocol packet length
	bsr	make_ICMP_checksum	;calculate ICMP checksum
	move	d0,ICMP_HD_checksum(a2)	;patch ICMP checksum
;
	bra	post_unmask_IP		;go calc & patch main IP checksum
;
unmask_ICMP_reply:
	tst.b	ICMP_HD_code(a2)		;Code non_zero ?  (abnormal)
	bne	mask_failed			;weird code => error exit
	swap	d3				;d3 = protocol<<16
	move	ICMP_HD_id(a2),d3		;d3 = protocol.identifier
	bsr	unmask_common			;try to unmask the packet
	bmi	unmask_failed			;exit with failure on error
	move	d0,ICMP_HD_id(a2)		;unmask ICMP identifier
	move.l	a2,a0				;a0 -> protocol packet
	move	IPDG_pkt_length(a3),d0		;d0 -> protocol packet length
	bsr	make_ICMP_checksum		;calculate ICMP checksum
	move	d0,ICMP_HD_checksum(a2)		;patch ICMP checksum
	bra	post_unmask_IP			;go calc & patch IP checksum
;
unmask_exit:
	rts					;return result to caller
;
;end of unmask_datagram
;----------------------------------------------------------------------------
;uint16	mask_common();
;
;NB: non-standard register assumptions:
;
;a5 -> my_port  a4 -> masq_port  a3 -> dgram
;d5 = masked_IP  d4 = dummy_IP  d3 = protocol.source_port
;
mask_common:
	move.l		IPDG_hdr+IPHD_ip_src(a3),d2	;d2 =  src  IP
	cmp.l		d2,d4				;'outer' machine ?
	bne.s		mask_nonlocal			;else mask others
mask_local:
	move.l		d5,IPDG_hdr+IPHD_ip_src(a3)	;mask src IP
	move		d3,d0				;keep port number
	and.l		#$FFFF,d0		;return positive on success
	rts
;
mask_nonlocal:
	move.l		masq_root_p(pc),a0		;a0 -> root
	lea		masq_root_p-masq_next(pc),a1	;trick !
	tst		masq_count
	bne.s		mask_search
mask_allocate:
	KRmalloc	#sizeof_masq_entry	;allocate masq entry
	tst.l		d0
	ble.s		mask_emergency		;emergency on allocation failure
	move.l		d0,a0			;a0 -> new entry
	move		masq_count(pc),masq_index(a0)
	addq		#1,masq_count
mask_linkup:
	lea		masq_root_p(pc),a1	;(a1) -> recent entry or is NULL
	move.l		(a1),masq_next(a0)	;link new entry as root of chain
	move.l		a0,(a1)			;store new entry as root
	move.l		d3,masq_proto_port(a0)
	move.l		IPDG_hdr+IPHD_ip_src(a3),masq_local_ip(a0)
	bra.s		mask_ok
;
mask_emergency:					;reached at allocation error
	cmp		#1,masq_count		;has it worked some times ?
	blo.s		mask_error		;abort if it just doesn't work
	movem.l		masq_temp_2L(pc),a0-a1	;restore regs from search end
	bra.s		mask_reallocate
	
mask_search_loop:
	move.l		masq_next(a0),d0
	beq.s		mask_not_found
	move.l		a0,a1			;a1 -> tested entry
	move.l		d0,a0			;a0 -> next entry
mask_search:
	cmp.l		masq_proto_port(a0),d3
	bne.s		mask_search_loop
	cmp.l		masq_local_ip(a0),d2
	bne.s		mask_search_loop
mask_found:
	move.l		masq_next(a0),masq_next(a1)	;unlink entry from queue
	move.l		masq_root_p(pc),masq_next(a0)	;link it to queue root
	move.l		a0,masq_root_p		;make this entry new root
	bra.s		mask_ok
;
mask_not_found:
	movem.l		a0-a1,masq_temp_2L	;save regs from search end
	cmp		#(1<<MASQ_POWER),masq_count	;room for more entries ?
	blo		mask_allocate		;if room, go allocate new entry
mask_reallocate:
	clr.l		masq_next(a1)		;unlink oldest entry from queue
	bra.s		mask_linkup		;go reuse it for new entry
;
mask_ok:
	move.l		d5,IPDG_hdr+IPHD_ip_src(a3)	;mask src IP
	move		masq_index(a0),d0
	add		#MASQ_START,d0		;d0 = masked source port
	and.l		#$FFFF,d0		;return positive on success
	rts
;
mask_error:
	moveq		#E_ERROR,d0		;return negative on failure
	rts
;
;end of mask_common
;----------------------------------------------------------------------------
;uint16	unmask_common();
;
;NB: non-standard register assumptions:
;
;a5 -> my_port  a4 -> masq_port  a3 -> dgram
;d5 = masking_IP  d4 = dummy_IP  d3 = protocol.dest_port
;
unmask_common:
	cmp	#MASQ_START,d3		;port below mask range ?
	blo.s	unmask_local		;then go unmask for 'outer' machine ?
	cmp	#MASQ_LIMIT,d3		;port above mask range ?
	blo.s	unmask_nonlocal		;else go unmask other machines
unmask_local:
	move.l	d4,IPDG_hdr+IPHD_ip_dest(a3)	;unmask dest IP
	move	d3,d0				;keep port number
	and.l	#$FFFF,d0		;return positive on success
	rts
;
unmask_nonlocal:
	tst	masq_count
	beq.s	unmask_error
	sub	#MASQ_START,d3
	blo.s	unmask_error
	cmp	masq_count,d3
	bhs.s	unmask_error
	lea	masq_root_p-masq_next(pc),a0	;trick !
unmask_search:
	move.l	masq_next(a0),d0
	beq.s	unmask_error
	move.l	a0,a1
	move.l	d0,a0
	cmp	masq_index(a0),d3
	bne.s	unmask_search
unmask_ok:
	move.l	masq_local_ip(a0),IPDG_hdr+IPHD_ip_dest(a3)	;unmask dest IP
	move	masq_local_port(a0),d0
	and.l	#$FFFF,d0		;return positive on success
	rts
;
unmask_error:
	moveq	#E_ERROR,d0		;return negative on failure
	rts
;
;end of unmask_common
;----------------------------------------------------------------------------
;Here follows eight checksum functions that share most of their code.
;All of these smash d1/d2/a0 and preserve all other regs except d0 (result).
;
;uint16	make_TCP_checksum (uint32 src, uint32 dest, uint16 *blk, uint16 len);
;uint16 make_UDP_checksum (uint32 src, uint32 dest, UDP_HDR *udp_packet);
;uint16	make_ICMP_checksum (uint16 *blk, uint16 len);
;	make_*_checksum calls preclear original checksum before calculation
;
;uint16	calc_TCP_checksum (uint32 src, uint32 dest, uint16 *blk, uint16 len);
;uint16 calc_UDP_checksum (uint32 src, uint32 dest, UDP_HDR *udp_packet);
;uint16	calc_ICMP_checksum (uint16 *blk, uint16 len);
;	calc_*_checksum calls do the same calculations without preclearing
;
;uint16	calc_proto_checksum (uint32 src, uint32 dest, uint16 *blk, uint32 proto_len);
;	calc_proto_checksum is used for UDP and TCP in the above functions
;
;uint16	calc_checksum(uint16 start_value, uint16 *blk, uint16 len);
;	calc_checksum calculates a block checksum regardless of protocol
;	it is used for the data block summing of the other seven functions
;
make_ICMP_checksum:
	clr	ICMP_HD_checksum(a0)	;clear checksum in block
calc_ICMP_checksum:
	move	d0,d1			;d1 = length	(for top bits)
	clr.l	d0			;preclear checksum accumulator
	bra.s	calc_checksum		;add this checksum to block checksum
;
make_UDP_checksum:
	clr	UDP_hdr_checksum(a0)	;clear checksum in packet
calc_UDP_checksum:
	move.l	#P_UDP<<16,d2		;d2 = protocol.zero
	move	UDP_hdr_length(a0),d2	;d2 = protocol.length
	bra.s	calc_proto_checksum
;
make_TCP_checksum:
	clr	tcph_chksum(a0)	;clear checksum in block
calc_TCP_checksum:
	swap	d2		;d2 = length.garbage
	move	#P_TCP,d2	;d2 = length.protocol
	swap	d2		;d2 = protocol.length
calc_proto_checksum:
	add	d0,d1		;X<<16+d1.lo = sum of low IP words
	clr	d0		;d0 = src_ip & 0xFFFF0000
	swap	d0		;d0 = src_ip.hi
	addx	d1,d0		;X<<16+d0.lo = sum of src_IP and dest_IP.lo
	clr	d1		;d1 = dest_ip & 0xFFFF0000
	swap	d1		;d1.lo = dest_ip.hi, d1.hi = 0
	addx.l	d1,d0		;d0 = checksum of both IPs
;
	clr.l	d1		;preclear top bits of d1
	move	d2,d1		;d1 = length
	add.l	d1,d0		;add length word to checksum
	clr	d2		;d2 = protocol.zero
	swap	d2		;d2 = protocol
	add.l	d2,d0		;add protocol word to checksum
;
calc_checksum:
	and.l	#$FFFF,d1		;clear top bits of length count
	clr.l	d2			;clear top bits of temp reg
;
	ror.l	#1,d1			;d1 = length/2 + (length & 1)<<31
	beq.s	.summed_words		;skip if no full words to sum
	subq	#1,d1			;d1.lo is adapted for dbra counting
.loop:
	move	(a0)+,d2		;d2.lo = block word, d2.hi remains 0
	add.l	d2,d0			;add block word to checksum
	dbra	d1,.loop		;loop back to add all full words
.summed_words:
	tst.l	d1			;odd length ?
	bpl.s	.summed_all		;skip if no byte remains to be summed
	move.b	(a0)+,d2		;d2 = final byte
	asl	#8,d2			;d0 = final byte << 8
	add.l	d2,d0			;add padded final byte to checksum
.summed_all:
;
	move	d0,d2			;d2 = prel_checksum.lo
	clr	d0
	swap	d0			;d0 = prel_checksum.hi
	add	d2,d0			;X+d0.lo = checksum
	clr	d2
	addx	d2,d0			;d0 = final checksum folded to 16 bits
	not	d0			;invert these bits for return value
	rts				;return to caller
;
;end of calc_checksum and seven other related checksum functions
;----------------------------------------------------------------------------
;uint16 make_IP_check (IP_DGRAM *datagram);
;uint16 calc_IP_check (IP_DGRAM *datagram);
;
;make_IP_check clears the checksum in the IP header before calculation
;calc_IP_check just calculates a checksum including the old one in IP header
;	neither stores the new sum anywhere, they just return it to caller.
;	both smash d1/d2/a1 and preserve all other regs except d0 (result).
;
make_IP_check:
	clr	IPDG_hdr+IPHD_hdr_chksum(a0)
calc_IP_check:
	lea	IPDG_hdr(a0),a1			;a1 -> header
	move.l	(a1)+,d0			;check header bytes  0-3
	move.l	(a1)+,d1			;fetch header bytes  4-7
	add.l	d1,d0				;check header bytes  4-7
	move.l	(a1)+,d1			;fetch header bytes  8-11
	addx.l	d1,d0				;check header bytes  8-11
	move.l	(a1)+,d1			;fetch header bytes 12-15
	addx.l	d1,d0				;check header bytes 12-15
	move.l	(a1)+,d1			;fetch header bytes 16-19
	addx.l	d1,d0				;check header bytes 16-19
;
	move	IPDG_opt_length(a0),d2		;d2 = option bytes
	beq.s	.options_checked		;skip options if absent
	roxr	#1,d1				;save X bit in d1
	addq	#3,d2				;prep to round d2
	lsr	#2,d2				;d2 = option longs
	subq	#1,d2				;d2 = fixed for dbra
	roxl	#1,d1				;restore X bit from d1
	movea.l	IPDG_options(a0),a1		;a1 -> options
.option_loop:					;loop start
	move.l	(a1)+,d1				;fetch a long	
	addx.l	d1,d0					;check a long
	dbra	d2,.option_loop			;loop back for all option longs
;
.options_checked:
	move	d0,d1				;d1.lo = sum & 0xFFFF
	clr	d0				;d0.lo = 0  (X bit unaffected)
	swap	d0				;d0.hi = 0,  d0.lo = sum >> 16
	addx	d1,d0				;fold sum to 16 bits
	clr	d1				;d1.lo = 0  (X bit unaffected)
	addx	d1,d0				;add X bit (can give carry)
	addx	d1,d0				;do it again (no carry possible)
	not	d0				;invert the 16 bit checksum
	rts
;
;end of make_IP_check & calc_IP_check
;----------------------------------------------------------------------------
;char *find_masq_port();
;
find_masq_port:
	getvstr		MASQ_PORT_vn_s(pc)
	move.l		d0,a0
	move.l		d0,masq_port_name_p
	ble.s		.exit
	link		a6,#-4
	query_chains	-4(a6),0.w,0.w
	move.l		-4(a6),a0		;a0->ports
	unlk		a6
	bra.s		.test_port
;
.test_name:
	move.l		prt_des_name(a0),a1
	move.l		masq_port_name_p(pc),a2
	str_comp	a1,a2
	beq.s		.exit
	move.l		prt_des_next(a0),a0
.test_port:
	move.l		a0,d0
	bgt.s		.test_name
.exit:
	tst.l		d0
	rts
;
;end of find_masq_port
;----------------------------------------------------------------------------
;End of:	Resident functions and subroutines
;----------------------------------------------------------------------------
;	Resident library function code will be expanded here
;
	make	JAR_links
	make	TCON_links
	make	DOMAIN_links
;
;----------------------------------------------------------------------------
resident_end:	;all beyond this point will be released in going resident
resident_size	equ	resident_end-text_start+$100
;----------------------------------------------------------------------------
;Start of:	STX Non-resident initialization code with tests
;----------------------------------------------------------------------------
;
start_1:
	move.l		a0,d0
	sne		d7
	bne.s		.have_basepage
	move.l		4(sp),d0
.have_basepage:
	move.l		d0,a5
	lea		mystack(pc),sp
	move.l		a5,basepage_p
	tst.b		d7
	bne		.ACC_launch
	gemdos		Mshrink,#0,(a5),#initial_size
	lea		bp_arglen(a5),a0
	lea		STinG_Load_s(pc),a1
	str_comp	a0,a1
	bne		.bad_launch
;
	gemdos		Super,0.w
	move.l		d0,d4
	eval_cookie	#"STiK"
	move.l		d0,d3				;d3 = d0 -> DRV_LIST structure
	gemdos		Super|_ind,d4
;
	move.l		d3,sting_drivers		;sting_drivers -> DRV_LIST structure
	ble		.STiK_not_found
	move.l		d3,a3				;a3 -> DRV_LIST structure
	lea		DRV_LIST_magic(a3),a0
	lea		STiKmagic_s(pc),a1
	moveq		#10-1,d0
.strcmp_loop:					;loop to test STiKmagic of DRV_LIST
	cmpm.b		(a0)+,(a1)+
	dbne		d0,.strcmp_loop
	bne		.STiK_not_valid
;
	move.l		DRV_LIST_get_dftab(a3),a0	;a0 -> get_dftab function
	pea		TRANSPORT_DRIVER_s		;-(sp) = "TRANSPORT_TCPIP"
	jsr		(a0)				;call get_dftab
	addq		#4,sp
	move.l		d0,tpl				;store pointer in 'tpl'
	ble		.driver_not_valid
;
	move.l		DRV_LIST_get_dftab(a3),a0	;a0 -> get_dftab function
	pea		MODULE_DRIVER_s			;-(sp) = "MODULE_LAYER"
	jsr		(a0)				;call get_dftab
	addq		#4,sp
	move.l		d0,stx				;store pointer in 'tpl'
	ble		.layer_not_valid
.install:
	link		a6,#-8
	query_chains	-8(a6),-4(a6),0.w
	movem.l		-8(a6),a3/a4			;a3->ports  a4->drivers
	unlk		a6
;
	move.l		a3,d0
	beq		.bad_port_list
.port_loop:
	move.l		d0,a3
	move.l		prt_des_next(a3),d0
	bne.s		.port_loop
;
	move.l		a4,d0
	beq		.bad_driver_list
.driver_loop:
	move.l		d0,a4
	move.l		drv_des_next(a4),d0
	bne.s		.driver_loop
;
.final_install:
	move.l		#my_port,prt_des_next(a3)
	move.l		#my_driver,drv_des_next(a4)
;
	gemdos		Ptermres,#resident_size,#0
;
;-------------------------------------
;
.ACC_launch:
	lea		ACC_launch_s(pc),a0
	bsr.s		report_error
.loop:
	bra.s		.loop
;
;-------------------------------------
;
.bad_launch:
	lea		bad_launch_s(pc),a0
	bra.s		.error_exit
;
;-------------------------------------
;
.bad_port_list:
	lea		bad_port_list_s(pc),a0
	bra.s		.error_exit
;
;-------------------------------------
;
.bad_driver_list:
	lea		bad_driver_list_s(pc),a0
	bra.s		.error_exit
;
;-------------------------------------
;
.STiK_not_found:
	lea		STiK_not_found_s,a0
	bra.s		.error_exit
;
;-------------------------------------
;
.STiK_not_valid:
	lea		STiK_not_valid_s,a0
	bra.s		.error_exit
;
;-------------------------------------
;
.driver_not_valid:
	lea		driver_not_valid_s,a0
	bra.s		.error_exit
;
;-------------------------------------
.layer_not_valid:
	lea		layer_not_valid_s(pc),a0
.error_exit:
	bsr.s		report_error
	gemdos		Pterm,#E_ERROR
;
;-------------------------------------
;
report_error:
	move.l		a0,-(sp)
	lea		error_title_s(pc),a0
	bsr.s		Cconws_sub
	move.l		(sp)+,a0
	bsr		Cconws_sub
	lea		error_tail_s(pc),a0
Cconws_sub:
	gemdos		Cconws,(a0)
	rts
;
;----------------------------------------------------------------------------
;End of:	STX Non-resident initialization code with tests
;----------------------------------------------------------------------------
;	Non-resident library function code will be expanded here
;
	make	JAR_links
	make	TCON_links
	make	DOMAIN_links
;
;----------------------------------------------------------------------------
;
text_limit:
text_size	= text_limit-text_start
	.data
data_start:
;
;----------------------------------------------------------------------------
;
STinG_Load_s:
	dc.b	10,'STinG_Load',NUL
STiKmagic_s:
	dc.b	'STiKmagic',NUL
TRANSPORT_DRIVER_s:
	dc.b	'TRANSPORT_TCPIP',NUL
MODULE_DRIVER_s:
	dc.b	'MODULE_LAYER',NUL
;
ACC_launch_s:
	dc.b	'This non-ACC, was launched as an ACC,',CR,LF
	dc.b	'so now you must reset the computer !',CR,LF
	dc.b	'I am looping forever to avoid damage',CR,LF
	dc.b	'that could occur if I try to exit !',CR,LF
	dc.b	NUL
;
bad_launch_s:	
	dc.b	'This STX should only be launched by',CR,LF
	dc.b	'STinG, or another TCP/IP stack with',CR,LF
	dc.b	'a compatible module interface !',CR,LF
	dc.b	NUL
;
bad_port_list_s:
	dc.b	'The list chain of STinG ports was',CR,LF
	dc.b	'not found...!',CR,LF
	dc.b	NUL
;
bad_driver_list_s:
	dc.b	'The list chain of STinG drivers was',CR,LF
	dc.b	'not found...!',CR,LF
	dc.b	NUL
;
STiK_not_found_s:
	dc.b	'There is no STiK cookie in the jar !',CR,LF
	dc.b	NUL
;
STiK_not_valid_s:
	dc.b	'The STiK cookie data is corrupt !',CR,LF
	dc.b	NUL
;
driver_not_valid_s:
	dc.b	'The main STinG driver is not valid !',CR,LF
	dc.b	NUL
;
layer_not_valid_s:
	dc.b	'The STinG module layer is not valid !',CR,LF
	dc.b	NUL
;
error_title_s:
	dc.b	BEL,CR,LF
	dc.b	'------------'
	dc.b	' '
	M_TITLE
	dc.b	' '
	M_VERSION
	dc.b	'------------',CR,LF
	dc.b	NUL
;
error_tail_s:
	dc.b	BEL,CR,LF,NUL
;
;----------------------------------------------------------------------------
data_limit:
data_size	equ	data_limit-data_start
	.bss
bss_start:
;----------------------------------------------------------------------------
;
		ds.l	200		;subroutine stack >= 100 longs
mystack:	ds.l	1		;top of subroutine stack
;
;----------------------------------------------------------------------------
bss_limit:
bss_size	equ	bss_limit-bss_start
;----------------------------------------------------------------------------
initial_size	equ	text_size+data_size+bss_size+$100
;----------------------------------------------------------------------------
		.end
;----------------------------------------------------------------------------
;End of file:	MASQUE.S
;----------------------------------------------------------------------------
