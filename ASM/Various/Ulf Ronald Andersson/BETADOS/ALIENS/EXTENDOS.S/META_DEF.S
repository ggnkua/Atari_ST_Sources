;----------------------------------------------------------------------------
	RSRESET
meta1_drivemap	rs.l	1	;1 bit per physical Metados drive
meta1_version	rs.l	1	;-> name and version of Metados
meta1_reserved	rs.l	1
meta1_metainfo2	rs.l	1	;-> other structure
;
	RSRESET
meta2_version	rs.l	1	;version of Metados >= $0230
meta2_magic	rs.l	1	;constant '_MET'
meta2_log2phys	rs.l	1	;-> drive translation bytes  gemdos => Meta
;----------------------------------------------------------------------------
;	BOS_table structure
;
bos_next_p	= 0	;long -> next bos_table
bos_max_trace	= 4	;long = number of trace entries allowed
bos_drive	= 8	;word = physical drive letter
bos_xCSI_LUN_ID	= 10	;word = ('A'/'S' for ACSI/SCSI)<<8 + LUN<<4 + ID
bos_xCSI	= 10	;byte = 'A'/'S' for ACSI/SCSI
bos_LUN_ID	= 11	;byte = LUN<<4 + ID
bos_IF_2	= 12	;word = -1  (apparently always)
bos_func_t_p	= 14	;long -> table of Metados + FCTL function pointers
bos_SCSI_ACSI	= 18	;byte = 0 for SCSI I/F or CDAR 504 on ACSI, else 1
bos_title_s	= 28	;string = name and version of BOS driver
bos_table_size	= 60	;so string above is max 32 bytes long (incl NUL)
;----------------------------------------------------------------------------
