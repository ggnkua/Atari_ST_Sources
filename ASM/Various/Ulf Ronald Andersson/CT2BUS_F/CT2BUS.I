;----------------------------------------------------------------------------
		rsreset
CT2BUS_id_0	rs.l	1
CT2BUS_id_1	rs.l	1
CT2BUS_TC	rs.l	1
CT2BUS_TT0	rs.l	1
CT2BUS_TT1	rs.l	1
CT2BUS_CRP	rs.l	2
sizeof_CT2BUS	rs.l	0
;----------------------------------------------------------------------------
def_CT2BUS	MACRO
		dc.l	'CT2B','US12'
TC_active:	dc.l	$80B08D00		;active value for tc
TT0_active:	dc.l	0			;TT0 passive
TT1_active:	dc.l	0			;TT1 passive
CRP_fixval:	dc.l	$80000002,PMMU_map	;active value for crp
		ENDM
;----------------------------------------------------------------------------
