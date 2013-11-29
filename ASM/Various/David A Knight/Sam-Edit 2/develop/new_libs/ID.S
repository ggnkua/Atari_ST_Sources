	SECTION	text

idMachine
	get_cookie	'_MCH'

	move.l	d4,machine

	get_cookie	'_SND'

	move.l	d4,dmaSound

	get_cookie	'SAM'*256

	move.l	d4,samPresent

	rts

	SECTION	bss
samPresent	ds.b	4
machine	ds.b	4
dmaSound	ds.b	4
country	ds.b	2

; OS header
	rsreset
os_entry	rs.w	1
os_version	rs.w	1
reseth	rs.l	1
os_beg	rs.l	1
os_end	rs.l	1
os_rsvl	rs.l	1
os_magic	rs.l	1
os_date	rs.l	1
os_conf	rs.w	1
os_dosdate	rs.w	1
p_root	rs.l	1
p_kbshift	rs.l	1
p_run	rs.l	1
p_rsv2	rs.l	1