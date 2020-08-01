; ioequ.inc
; DSP 56000 I/O address and register equates
; This file came from Motorola's Dr. BuB DSP board

; Last Update 25 Aug 87   Version 1.1  (fixed m_of)
;
;************************************************************************
;
;       EQUATES for DSP56000 I/O registers and ports
;
;************************************************************************

;------------------------------------------------------------------------
;
;       EQUATES for I/O Port Programming
;
;------------------------------------------------------------------------

;       Register Addresses

m_bcr   EQU     $FFFE           ; Port A Bus Control Register
m_pbc   EQU     $FFE0           ; Port B Control Register
m_pbddr EQU     $FFE2           ; Port B Data Direction Register
m_pbd   EQU     $FFE4           ; Port B Data Register
m_pcc   EQU     $FFE1           ; Port C Control Register
m_pcddr EQU     $FFE3           ; Port C Data Direction Register
m_pcd   EQU     $FFE5           ; Port C Data Register


;------------------------------------------------------------------------
;
;       EQUATES for Host Interface
;
;------------------------------------------------------------------------

;       Register Addresses

m_hcr   EQU     $FFE8           ; Host Control Register
m_hsr   EQU     $FFE9           ; Host Status Register
m_hrx   EQU     $FFEB           ; Host Receive Data Register
m_htx   EQU     $FFEB           ; Host Transmit Data Register

;       Host Control Register Bit Flags

m_hrie  EQU     0               ; Host Receive Interrupt Enable
m_htie  EQU     1               ; Host Transmit Interrupt Enable
m_hcie  EQU     2               ; Host Command Interrupt Enable
m_hf2   EQU     3               ; Host Flag 2
m_hf3   EQU     4               ; Host Flag 3

;       Host Status Register Bit Flags

m_hrdf  EQU     0               ; Host Receive Data Full
m_htde  EQU     1               ; Host Transmit Data Empty
m_hcp   EQU     2               ; Host Command Pending
m_hf    EQU     $18             ; Host Flag Mask
m_hf0   EQU     3               ; Host Flag 0
m_hf1   EQU     4               ; Host Flag 1
m_dma   EQU     7               ; DMA Status

;------------------------------------------------------------------------
;
;       EQUATES for Serial Communications Interface (SCI)
;
;------------------------------------------------------------------------

;       Register Addresses

m_srxl  EQU     $FFF4           ; SCI Receive Data Register (low)
m_srxm  EQU     $FFF5           ; SCI Receive Data Register (middle)
m_srxh  EQU     $FFF6           ; SCI Receive Data Register (high)
m_stxl  EQU     $FFF4           ; SCI Transmit Data Register (low)
m_stxm  EQU     $FFF5           ; SCI Transmit Data Register (middle)
m_stxh  EQU     $FFF6           ; SCI Transmit Data Register (high)
m_stxa  EQU     $FFF3           ; SCI Transmit Data Address Register
m_scr   EQU     $FFF0           ; SCI Control Register
m_ssr   EQU     $FFF1           ; SCI Status Register
m_sccr  EQU     $FFF2           ; SCI Clock Control Register

;       SCI Control Register Bit Flags

m_wds   EQU     $3              ; Word Select Mask
m_wds0  EQU     0               ; Word Select 0
m_wds1  EQU     1               ; Word Select 1
m_wds2  EQU     2               ; Word Select 2
m_sbk   EQU     4               ; Send Break
m_wake  EQU     5               ; Wake-up Mode Select
m_rwi   EQU     6               ; Receiver Wake-up Enable
m_woms  EQU     7               ; Wired-OR Mode Select
m_re    EQU     8               ; Receiver Enable
m_te    EQU     9               ; Transmitter Enable
m_ilie  EQU     10              ; Idle Line Interrupt Enable
m_rie   EQU     11              ; Receive Interrupt Enable
m_tie   EQU     12              ; Transmit Interrupt Enable
m_tmie  EQU     13              ; Timer Interrupt Enable

;       SCI Status Register Bit Flags

m_trne  EQU     0               ; Transmitter Empty
m_tdre  EQU     1               ; Transmit Data Register Empty
m_rdrf  EQU     2               ; Receive Data Register Full
m_idle  EQU     3               ; Idle Line
m_or    EQU     4               ; Overrun Error
m_pe    EQU     5               ; Parity Error
m_fe    EQU     6               ; Framing Error
m_r8    EQU     7               ; Received Bit 8

;       SCI Clock Control Register Bit Flags

m_cd    EQU     $FFF            ; Clock Divider Mask
m_cod   EQU     12              ; Clock Out Divider
m_scp   EQU     13              ; Clock Prescaler
m_rcm   EQU     14              ; Receive Clock Source
m_tcm   EQU     15              ; Transmit Clock Source

;------------------------------------------------------------------------
;
;       EQUATES for Synchronous Serial Interface (SSI)
;
;------------------------------------------------------------------------

;       Register Addresses

m_rx    EQU     $FFEF           ; Serial Receive Data Register
m_tx    EQU     $FFEF           ; Serial Transmit Data Register
m_cra   EQU     $FFEC           ; SSI Control Register A
m_crb   EQU     $FFED           ; SSI Control Register B
m_sr    EQU     $FFEE           ; SSI Status Register
m_tsr   EQU     $FFEE           ; SSI Time Slot Register

;       SSI Control Register A Bit Flags

m_pm    EQU     $FF             ; Prescale Modulus Select Mask
m_dc    EQU     $1F00           ; Frame Rate Divider Control Mask
m_wl    EQU     $6000           ; Word Length Control Mask
m_wl0   EQU     13              ; Word Length Control 0
m_wl1   EQU     14              ; Word Length Control 1
m_psr   EQU     15              ; Prescaler Range

;       SSI Control Register B Bit Flags

m_of    EQU     $3              ; Serial Output Flag Mask
m_of0   EQU     0               ; Serial Output Flag 0
m_of1   EQU     1               ; Serial Output Flag 1
m_scd   EQU     $1C             ; Serial Control Direction Mask
m_scd0  EQU     2               ; Serial Control 0 Direction
m_scd1  EQU     3               ; Serial Control 1 Direction
m_scd2  EQU     4               ; Serial Control 2 Direction
m_sckd  EQU     5               ; Clock Source Direction
m_fsl   EQU     8               ; Frame Sync Length
m_syn   EQU     9               ; Sync/Async Control
m_gck   EQU     10              ; Gated Clock Control
m_mod   EQU     11              ; Mode Select
m_ste   EQU     12              ; SSI Transmit Enable
m_sre   EQU     13              ; SSI Receive Enable
m_stie  EQU     14              ; SSI Transmit Interrupt Enable
m_srie  EQU     15              ; SSI Receive Interrupt Enable

;       SSI Status Register Bit Flags

m_if    EQU     $2              ; Serial Input Flag Mask
m_if0   EQU     0               ; Serial Input Flag 0
m_if1   EQU     1               ; Serial Input Flag 1
m_tfs   EQU     2               ; Transmit Frame Sync
m_rfs   EQU     3               ; Receive Frame Sync
m_tue   EQU     4               ; Transmitter Underrun Error
m_roe   EQU     5               ; Receiver Overrun Error
m_tde   EQU     6               ; Transmit Data Register Empty
m_rdf   EQU     7               ; Receive Data Register Full

;------------------------------------------------------------------------
;
;       EQUATES for Exception Processing
;
;------------------------------------------------------------------------

;       Register Addresses

m_ipr   EQU     $FFFF           ; Interrupt Priority Register

;       Interrupt Priority Register Bit Flags

m_ial   EQU     $7              ; IRQA Mode Mask
m_ial0  EQU     0               ; IRQA Mode Interrupt Priority Level (low)
m_ial1  EQU     1               ; IRQA Mode Interrupt Priority Level (high)
m_ial2  EQU     2               ; IRQA Mode Trigger Mode
m_ibl   EQU     $38             ; IRQB Mode Mask
m_ibl0  EQU     3               ; IRQB Mode Interrupt Priority Level (low)
m_ibl1  EQU     4               ; IRQB Mode Interrupt Priority Level (high)
m_ibl2  EQU     5               ; IRQB Mode Trigger Mode
m_hpl   EQU     $C00            ; Host Interrupt Priority Level Mask
m_hpl0  EQU     10              ; Host Interrupt Priority Level Mask (low)
m_hpl1  EQU     11              ; Host Interrupt Priority Level Mask (high)
m_ssl   EQU     $3000           ; SSI Interrupt Priority Level Mask
m_ssl0  EQU     12              ; SSI Interrupt Priority Level Mask (low)
m_ssl1  EQU     13              ; SSI Interrupt Priority Level Mask (high)
m_scl   EQU     $C000           ; SCI Interrupt Priority Level Mask
m_scl0  EQU     14              ; SCI Interrupt Priority Level Mask (low)
m_scl1  EQU     15              ; SCI Interrupt Priority Level Mask (high)

