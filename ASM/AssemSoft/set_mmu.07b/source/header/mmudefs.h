
;Translate control register bit meanings
tc_dui_pos	= 1 	;Position of the default data cache UPA bits in the TC
tc_duo_pos	= 6 	;Position of the default inst cache UPA bits in the TC
tc_dci_pos	= 3 	;Position of the default inst cache mode in the TC
tc_dco_pos	= 8 	;Position of the default data cache mode in the TC

tc_dwo		= 5	;Default write protect (data cache)
tc_fitc		= 10	;1/2-Cache Mode (Instruction ATC)
tc_fotc		= 11	;1/2-Cache Mode (Data ATC)
tc_nai		= 12	;No Allocate Mode (Instruction ATC)
tc_nad		= 13	;No Allocate Mode (data ATC)
tc_pagesize	= 14	;Page size select (0 = 4Kb, 1 = 8Kb)
tc_enable	= 15	;Translation Enable (0 = disabled)

;Default cache mode definitions
tc_dco_wt	= %00<<tc_dco_pos
tc_dco_cb	= %01<<tc_dco_pos
tc_dco_p	= %10<<tc_dco_pos
tc_dco_i	= %11<<tc_dco_pos

tc_dci_wt	= %00<<tc_dci_pos
tc_dci_cb	= %01<<tc_dci_pos
tc_dci_p	= %10<<tc_dci_pos
tc_dci_i	= %11<<tc_dci_pos

;Transparent Translation Register definitions
ttr_enable	= 15
ttr_super_pos	= 13
ttr_u0		= 8
ttr_u1		= 9
ttr_cache_pos	= 5
ttr_wp		= 2


;Cache settings
c_writetrough 	= %00
c_copyback 	= %01
c_precise	= %10
c_imprecise	= %11

;Descriptor bit definitions
d_cache_pos	= 5	;Position of cache setting bits in descriptors
d_writeprotect	= 2
d_used		= 3
d_modified	= 4
d_super		= 7
d_u0		= 8
d_u1		= 9
d_global	= 10
d_ur0		= 11
d_ur1		= 12

msk_rootp_addr	= %11111111111111111111111000000000
msk_pnttab_addr	= %11111111111111111111111000000000
msk_8kpt_addr	= %11111111111111111111111110000000
msk_4kpt_addr	= %11111111111111111111111100000000
msk_8kpd_paddr	= %11111111111111111110000000000000
msk_4kpd_paddr	= %11111111111111111111000000000000
msk_pd_indirect	= %11111111111111111111111111111100

;Structure used to hold the contentns of the CPU registers.
	rsreset
cpur_urp	rs.l 1
cpur_srp	rs.l 1
cpur_tc		rs.l 1
cpur_itt0	rs.l 1
cpur_dtt0	rs.l 1
cpur_itt1	rs.l 1
cpur_dtt1	rs.l 1
cpur_sfc	rs.l 1
cpur_dfc	rs.l 1
cpur_cacr	rs.l 1
cpur_ssize	= __RS
