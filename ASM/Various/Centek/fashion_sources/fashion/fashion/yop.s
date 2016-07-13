**********************
*** Macro de JSRcc ***
**********************
jsrhi	macro	; adr
	bhi.s	__jsrhi_\@
	jsr\0	\1
__jsrhi_\@
	endm

jsrls	macro	; adr
	bls.s	__jsrls_\@
	jsr\0	\1
__jsrls_\@
	endm

jsrcc	macro	; adr
	bcc.s	__jsrcc_\@
	jsr\0	\1
__jsrcc_\@
	endm

jsrhs	macro	; adr
	bhs.s	__jsrhs_\@
	jsr\0	\1
__jsrhs_\@
	endm

jsrcs	macro	; adr
	bcs.s	__jsrcs_\@
	jsr\0	\1
__jsrcs_\@
	endm

jsrlo	macro	; adr
	blo.s	__jsrlo_\@
	jsr\0	\1
__jsrlo_\@
	endm

jsrne	macro	; adr
	bne.s	__jsrne_\@
	jsr\0	\1
__jsrne_\@
	endm

jsreq	macro	; adr
	beq.s	__jsreq_\@
	jsr\0	\1
__jsreq_\@
	endm

jsrvc	macro	; adr
	bvc.s	__jsrvc_\@
	jsr\0	\1
__jsrvc_\@
	endm

jsrvs	macro	; adr
	bvs.s	__jsrvs_\@
	jsr\0	\1
__jsrvs_\@
	endm

jsrpl	macro	; adr
	bpl.s	__jsrpl_\@
	jsr\0	\1
__jsrpl_\@
	endm

jsrmi	macro	; adr
	bmi.s	__jsrmi_\@
	jsr\0	\1
__jsrmi_\@
	endm

jsrge	macro	; adr
	bge.s	__jsrge_\@
	jsr\0	\1
__jsrge_\@
	endm

jsrlt	macro	; adr
	blt.s	__jsrlt_\@
	jsr\0	\1
__jsrlt_\@
	endm

jsrgt	macro	; adr
	bgt.s	__jsrgt_\@
	jsr\0	\1
__jsrgt_\@
	endm

jsrle	macro	; adr
	ble.s	__jsrle_\@
	jsr\0	\1
__jsrle_\@
	endm

**********************
*** Macro de BSRcc ***
**********************
bsrhi	macro	; adr
	bhi.s	__bsrhi_\@
	bsr\0	\1
__bsrhi_\@
	endm

bsrls	macro	; adr
	bls.s	__bsrls_\@
	bsr\0	\1
__bsrls_\@
	endm

bsrcc	macro	; adr
	bcc.s	__bsrcc_\@
	bsr\0	\1
__bsrcc_\@
	endm

bsrhs	macro	; adr
	bhs.s	__bsrhs_\@
	bsr\0	\1
__bsrhs_\@
	endm

bsrcs	macro	; adr
	bcs.s	__bsrcs_\@
	bsr\0	\1
__bsrcs_\@
	endm

bsrlo	macro	; adr
	blo.s	__bsrlo_\@
	bsr\0	\1
__bsrlo_\@
	endm

bsrne	macro	; adr
	bne.s	__bsrne_\@
	bsr\0	\1
__bsrne_\@
	endm

bsreq	macro	; adr
	beq.s	__bsreq_\@
	bsr\0	\1
__bsreq_\@
	endm

bsrvc	macro	; adr
	bvc.s	__bsrvc_\@
	bsr\0	\1
__bsrvc_\@
	endm

bsrvs	macro	; adr
	bvs.s	__bsrvs_\@
	bsr\0	\1
__bsrvs_\@
	endm

bsrpl	macro	; adr
	bpl.s	__bsrpl_\@
	bsr\0	\1
__bsrpl_\@
	endm

bsrmi	macro	; adr
	bmi.s	__bsrmi_\@
	bsr\0	\1
__bsrmi_\@
	endm

bsrge	macro	; adr
	bge.s	__bsrge_\@
	bsr\0	\1
__bsrge_\@
	endm

bsrlt	macro	; adr
	blt.s	__bsrlt_\@
	bsr\0	\1
__bsrlt_\@
	endm

bsrgt	macro	; adr
	bgt.s	__bsrgt_\@
	bsr\0	\1
__bsrgt_\@
	endm

bsrle	macro	; adr
	ble.s	__bsrle_\@
	bsr\0	\1
__bsrle_\@
	endm

