;----------------------------------------------------------------------------
; File name:	UDP.I				Revision date:	1998.09.08
; Authors:	P.Rottengatter & R.Andersson	Creation date:	1997.05.267
;----------------------------------------------------------------------------
; Purpose:	High level StinG UDP protocol
;		Header file included in assembly
;----------------------------------------------------------------------------
	include	sting\LAYER.I
;----------------------------------------------------------------------------
;	UDP header and chain link structure.
;
	struct	UDP_hdr
	uint16	UDP_hdr_source_port	;Source UDP port
	uint16	UDP_hdr_dest_port	;Destination UDP port
	uint16	UDP_hdr_length		;UDP length of data
	uint16	UDP_hdr_checksum	;UDP checksum
	d_end	UDP_hdr
;
	struct	UDP_blk
	struc_p	UDP_blk_next		;Link to next data block in chain
	uint16	UDP_blk_length		;Amount of data in this block
	uint16	UDP_blk_index		;Index to data start in this block
	d_end	UDP_blk
;----------------------------------------------------------------------------
;	UDP connection structure.
;
	struct	CONN
	uint32	CONN_remote_IP_address;	;Foreign socket IP address
	uint16	CONN_remote_port;	;Foreign socket port number
	uint32	CONN_local_IP_address;	;Local socket IP address
	uint16	CONN_local_port;	;Local socket port number
	int16	CONN_ttl;		;Time To Live		(for IP)
	uint32	CONN_total_data;	;Total real data in queue
	struc_p	CONN_info;		;Connection information CIB link
	struc_p	CONN_receive_queue;	;UDP_blk Receive queue
	struc_p	CONN_pending;		;UDP_hdr Pending IP datagrams
	int16	CONN_semaphore;		;Semaphore for locking structures
	struc_p	CONN_next;		;Link to next connection in chain
	d_end	CONN
;----------------------------------------------------------------------------
; End of file:	UDP.I
;----------------------------------------------------------------------------
