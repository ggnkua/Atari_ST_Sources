;----------------------------------------------------------------------------
; File name:	TCP.I				Revision date:	1998.09.08
; Authors:	P.Rottengatter & R.Andersson	Creation date:	1997.03.26
;----------------------------------------------------------------------------
; Purpose:	High level StinG TCP protocol
;		Header file included in assembly
;----------------------------------------------------------------------------
	include	sting\TRANSPRT.I
	include	sting\LAYER.I
;----------------------------------------------------------------------------
;	State Categories
;
C_DEFAULT	=	0	; Default for invalid states
C_CLSD		=	1	; We've closed. Nothing can be done
C_LISTEN	=	2	; TLISTEN state
C_READY		=	3	; Ready to receive data
C_FIN		=	4	; Nothing to receive anyore (FIN rec'vd)
;----------------------------------------------------------------------------
;	TCP header and chain link structure.
;
	struct	tcph
	uint16	tcph_src_port		; Port number of sender
	uint16	tcph_dest_port		; Port number of receiver
	uint32	tcph_sequence		; Sequence number
	uint32	tcph_acknowledge	; Acknowledgement number
;
	d_field	tcph_f_,16
	d_bits	tcph_f_offset,4		; Data offset (header length)
	d_bits	tcph_f_resvd,6		; Reserved
	d_bits	tcph_f_urgent,1		; Flag for urgent data present
	d_bits	tcph_f_ack,1		; Flag for acknowledgement segment
	d_bits	tcph_f_push,1		; Flag for push function
	d_bits	tcph_f_reset,1		; Flag for resetting connection
	d_bits	tcph_f_sync,1		; Flag for synchronizing sequence numbers
	d_bits	tcph_f_fin,1		; Flag for no more data from sender
;
	uint16	tcph_window		; Receive window
	uint16	tcph_chksum		; Checksum of all header, options and data
	uint16	tcph_urg_ptr		; First byte following urgent data
	d_end	tcph
;
;----------------------------------------------------------------------------
;	Values for various variables in CONNEC.
;
R_NORMAL	=	0	; Normally closing connection
R_RESET		=	1	; Connection closing due to RST received
R_TIMEOUT	=	2	; Timeout while closing connection
R_NETWORK	=	3	; Connect attempt failed (network problem)
;
;
; CONNEC.flag weighted bit values
;
FORCE		=	1	; Flag forcing emission of a TCP segment
RETRAN		=	2	; Flag indicating this is a retransmission
;
;----------------------------------------------------------------------------
;	TCP re-sequencing structure.
;
	struct	resequ
	struc_p	resequ_next	; Link to next segment in chain
	uint8	resequ_tos	; TOS used by this segment to travel
	struc_p	resequ_hdr	; Pointer to TCP header data
	uint8_p	resequ_data	; Pointer to data in this segment
	uint16	resequ_data_len	; Amount of data in this segment
	d_end	resequ
;
;----------------------------------------------------------------------------
;	TCP connection structure.
;
	struct	conn
	uint32	conn_remote_IP_address	; Foreign socket IP address
	uint16	conn_remote_port	; Foreign socket port number
	uint32	conn_local_IP_address	; Local socket IP address
	uint16	conn_local_port		; Local socket port number
	uint8	conn_state		; TCP state of the connection
	uint8	conn_flags		; Various flags (FORCE, RETRAN)
	uint16	conn_mss		; Maximum Segment Size
	uint16	conn_mtu		; Maximum Transmission Unit	(for IP)
	int16	conn_tos		; Type Of Service		(for IP)
	int16	conn_ttl		; Time To Live			(for IP)
	struc_p	conn_info		; Connection information link
	int16	conn_reason		; Reason for closing	(in TCLOSED)
	int16	conn_net_error		; Error to be reported with next call
; Structure containing SEND info:
	uint32	conn_send_next		; Next new sequence number to send
	uint32	conn_send_ptr		; Sequence number in transmission
	uint32	conn_send_unack		; First unacknowledged sequence
	uint16	conn_send_window	; Actual size of send window
	uint32	conn_send_lwup_seq	; Sequence of last window update
	uint32	conn_send_lwup_ack	; Acknowledge of last window update
	int16	conn_send_total		; Total real data in queue
	int16	conn_send_bufflen	; Maximum amount of data in queue
	int16	conn_send_count		; Data (with flags) in queue
	uint32	conn_send_ini_sequ	; Initial sequence number
	struc_p	conn_send_queue		; Send queue
; End of SEND info
; Structure containing RECEIVE info:
	uint32	conn_recve_next		; Next acceptable sequence number
	uint16	conn_recve_window	; Actual size of receive window
	uint32	conn_recve_lst_nxt	; Seqnum of last window sent			*/
	uint16	conn_recve_lst_win	; Last window size reported
	struc_p	conn_recve_reseq	; Segment queue for resequencing
	int16	conn_recve_count	; Real data in queue
	struc_p	conn_recve_queue	; Receive queue
; End of RECEIVE info
; Struct. for retransmission timer:
	uint32	conn_rtrn_start		; Starting time
	uint32	conn_rtrn_timeout	; Timeout (ms)
	uint8	conn_rtrn_mode		; Mode flag : Running / Stopped
	uint8	conn_rtrn_backoff	; Retransmission backoff counter
; End of retransmission timer info
; Structure for round trip timer:
	uint32	conn_rtrp_start		; Starting time
	uint8	conn_rtrp_mode		; Mode flag : Running / Stopped
	uint32	conn_rtrp_smooth	; Smoothed round trip time
	uint32	conn_rtrp_sequ		; Sequence number being timed
; End of round trip timer info
	int16	conn_sema		; Semaphore for locking structures
	struc_p	conn_pending		; Pending IP datagrams
	struc_p	conn_next		; Link to next connection in chain
	d_end	conn
;
;----------------------------------------------------------------------------
;	STX internal structure for all protocol relevant information.
;
	struct	TCP_CONF
	char	TCP_CONF_generic,sizeof_LAYER	; Standard layer structure
	uint16	TCP_CONF_mss			; Maximum segment size
	uint16	TCP_CONF_rcv_window		; TCP receive window
	uint16	TCP_CONF_def_rtt		; Initial Round Trip Time in ms
	int16	TCP_CONF_def_ttl		; Default value for IP TTL
	int16	TCP_CONF_max_slt		; Estimated maximum segment lifetime
	uint16	TCP_CONF_con_out		; Outgoing connection attempts
	uint16	TCP_CONF_con_in			; Incoming connection attempts
	uint16	TCP_CONF_resets			; Counting sent resets
	d_end	TCP_CONF
;
;----------------------------------------------------------------------------
; End of file:	TCP.SH
;----------------------------------------------------------------------------
