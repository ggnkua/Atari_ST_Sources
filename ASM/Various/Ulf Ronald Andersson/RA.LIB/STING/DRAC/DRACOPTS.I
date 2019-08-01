;----------------------------------------------------------------------------
; File name:	DRACOPTS.I			Revision date:	2000.07.17
; Author:	Ronald Andersson		Creation date:	2000.07.17
;----------------------------------------------------------------------------
; Purpose:	Define Draconis option data and structs for use in porting
;		Draconis based software to STinG assembly programs.
;----------------------------------------------------------------------------
; Credits:	Based largely on info in options.h by Frank Naumann.
;----------------------------------------------------------------------------
;	Condition ensures inclusion once per pass only
;
	ifnd	STinG_DRACOPTS_defined
STinG_DRACOPTS_defined	set	1
;----------------------------------------------------------------------------
	struct	DRAC_OPTS
	int32	DOPT_dcfg			;$000
	char	DOPT_provider,21		;$004
;-------  Connect options			offs 25 == $19
	char	DOPT_user,36			;$019
	char	DOPT_password,36		;$03D
	char	DOPT_phone_no,21		;$061
	char	DOPT_term_before		;$076
	char	DOPT_term_after			;$077
;-------  Modem configuration			offs 120 == $078
	char	DOPT_modem_init,50		;$078
	char	DOPT_modem_dial,50		;$0AA
	char	DOPT_modem_hangup,50		;$0DC
	char	DOPT_modem_cmdok,50		;$10E
	char	DOPT_modem_conmsg,50		;$140
	char	DOPT_modem_fail1,50		;$172
	char	DOPT_modem_fail2,50		;$1A4
;-------  RS232 settings			offs 470 == $1D6
	int16	DOPT_port			;$1D6
	int16	DOPT_baud			;$1D8
	int16	DOPT_parity			;$1DA
	int16	DOPT_bits			;$1DC
	int16	DOPT_stopbits			;$1DE
;-------  Protocol options			offs  480 == $1E0
	int32	DOPT_prot_cookie		;$1E0
	int16	DOPT_protocol			;$1E4
	char	DOPT_ip_compression		;$1E6
	char	DOPT_soft_compression		;$1E7
;-------  Gateway options			offs  488 == $1E8
	uint32	DOPT_nameserver1		;$1E8
	uint32	DOPT_nameserver2		;$1EC
	uint32	DOPT_target1			;$1F0
	uint32	DOPT_gateway1			;$1F4
	uint32	DOPT_target2			;$1F8
	uint32	DOPT_gateway2			;$1FC
	uint32	DOPT_target3			;$200
	uint32	DOPT_gateway3			;$204
	uint32	DOPT_std_gateway		;$208
	int16	DOPT_subnet1			;$20C
	int16	DOPT_subnet2			;$20E
	int16	DOPT_subnet3			;$210
	char	DOPT_default_gw			;$212
;-------  TCP options				offs  531 == $213
	char	DOPT_ip_assign			;$213
	uint32	DOPT_ip				;$214
	uint32	DOPT_subnet	   		;$218
	char	DOPT_host,21			;$21C
	char	DOPT_domain,21			;$231
;-------  Proxys				offs  582 == $246
	char	DOPT_http,41			;$246
	char	DOPT_http_port,5		;$26F
	char	DOPT_ftp,41			;$274
	char	DOPT_ftp_port,5			;$29D
	char	DOPT_gopher,41			;$2A2
	char	DOPT_gopher_port,5		;$2CB
	char	DOPT_secure,41			;$2D0
	char	DOPT_secure_port,5		;$2F9
	char	DOPT_exclude,3*47		;$2FE
;-------  Mail					offs  907 == $38b
	char	DOPT_email,43			;$38B
	char	DOPT_email2,43			;$3B6
	char	DOPT_mailpass,43		;$3E1
	char	DOPT_popuser,43			;$40C
	char	DOPT_popserver,43		;$437
	char	DOPT_smtpserver,43		;$462
;NB 1byte unused here due to odd offset		offs 1165 == $48D
;-------					offs 1166 == $48E
	int16	DOPT_timeout			;$48E
	char	DOPT_netlogon			;$490
	char	DOPT_force_enc			;$491
	char	DOPT_tonline			;$492
;NB 1byte unused here due to odd offset		offs 1171 == $493
	d_even
	d_end	DRAC_OPTS			;size 1172 == $494
;----------------------------------------------------------------------------
	endc	;STinG_DRACOPTS_defined
;----------------------------------------------------------------------------
; End of file:	DRACOPTS.I
;----------------------------------------------------------------------------
