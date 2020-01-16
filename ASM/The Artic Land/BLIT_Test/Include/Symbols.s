; Symbols for HW and functions
; The Arctic Land (T.AL) 2019
; Contact: uko.tal@gmail.com or uko at http://www.atari-forum.com

; Hardware
; Exceptions vectors
HW_SYS_HBL_VEC	equ $68
HW_SYS_VBL_VEC	equ $70
HW_SYS_BERR_VEC	equ $8
HW_SYS_TIMA_VEC	equ $134
HW_SYS_TIMB_VEC	equ $120
HW_SYS_TIMC_VEC	equ $114
HW_SYS_TIMD_VEC	equ $110

; System variables
HW_SYS_FRCLOCK	equ $466	; Counter for vblank interrupts

;Screen Display
HW_ST_PAL_ADR	equ $FFFF8240
HW_SHIFTER_ADR	equ $FFFF8200

; MFP
HW_MFP_ADR	equ $FFFFFA00
HW_TIMB_HBL_CTL	equ $8

; BLITTER
HW_BLT_ADR	equ $FFFF8A00
HW_BLT_HTONE_O	equ $0
HW_BLT_SXINC_O	equ $20
HW_BLT_SYINC_O	equ $22
HW_BLT_SADR_O	equ $24
HW_BLT_LMASK_O	equ $28
HW_BLT_MMASK_O	equ $2A
HW_BLT_RMASK_O	equ $2C
HW_BLT_DXINC_O	equ $2E
HW_BLT_DYINC_O	equ $30
HW_BLT_DADR_O	equ $32
HW_BLT_XCOUNT_O	equ $36
HW_BLT_YCOUNT_O	equ $38
HW_BLT_HOP_O	equ $3A
HW_BLT_LOP_O	equ $3B
HW_BLT_CTL_O	equ $3C
HW_BLT_SKEW_O	equ $3D
	
; STE DMA Sound
HW_SND_ADR	equ $FFFF8900 
HW_SND_ENABLE_O	equ $1
HW_SND_H_SADR_O	equ $3
HW_SND_M_SADR_O	equ $5
HW_SND_L_SADR_O	equ $7
HW_SND_H_CADR_O	equ $9
HW_SND_M_CADR_O	equ $B
HW_SND_L_CADR_O	equ $D
HW_SND_H_EADR_O	equ $F
HW_SND_M_EADR_O	equ $11
HW_SND_L_EADR_O	equ $13
HW_SND_MODFRQ_O	equ $21
	

; MC6850 Asynchonous Communications Interface Adaptor
HW_ACIA_KBD_CTL	equ $FFFFFC00
HW_ACIA_KBD_DAT	equ $FFFFFC02

; Functions
GEMDOS_CCONWS	equ $9

XBIOS_PHYSBASE	equ $2
XBIOS_LOGBASE	equ $3
XBIOS_GETREZ	equ $4
XBIOS_SETSCREEN	equ $5
XBIOS_SUPEXEC	equ $26

; Other constants
SCRLINE_LEN	equ 160


