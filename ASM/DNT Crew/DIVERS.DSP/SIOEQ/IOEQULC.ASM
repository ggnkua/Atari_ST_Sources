;
; This program originally available on the Motorola DSP bulletin board.
; It is provided under a DISCLAMER OF WARRANTY available from
; Motorola DSP Operation, 6501 Wm. Cannon Drive W., Austin, Tx., 78735.
; 
; Motorola Standard I/O Equates (lower case).
; 
; Last Update 25 Aug 87   Version 1.1  (fixed m_of)
;
;************************************************************************
;
;       EQUATES for DSP56000 I/O registers and ports
;
;************************************************************************

;ioequlc	ident	1,0

;------------------------------------------------------------------------
;
;	EQUATES for I/O Port Programming
;
;------------------------------------------------------------------------

;       Register Addresses

m_bcr	EQU	$FFFE	; Port A Bus Control Register
m_pbc	EQU	$FFE0	; Port B Control Register
m_pbddr	EQU	$FFE2	; Port B Data Direction Register
m_pbd	EQU	$FFE4	; Port B Data Register
m_pcc	EQU	$FFE1	; Port C Control Register
m_pcddr	EQU	$FFE3	; Port C Data Direction Register
m_pcd	EQU	$FFE5	; Port C Data Register


;------------------------------------------------------------------------
;
;	EQUATES for Host Interface
;
;------------------------------------------------------------------------

;       Register Addresses

m_hcr	EQU	$FFE8	; Host Control Register
m_hsr	EQU	$FFE9	; Host Status Register
m_hrx	EQU	$FFEB	; Host Receive Data Register
m_htx	EQU	$FFEB	; Host Transmit Data Register

;       Host Control Register Bit Flags

m_hrie	EQU	0	; Host Receive Interrupt Enable
b_hrie	EQU	$01	;
m_htie	EQU	1	; Host Transmit Interrupt Enable
b_htie	EQU	$02	;
m_hcie	EQU	2	; Host Command Interrupt Enable
b_hcie	EQU	$04	;
m_hf2	EQU	3	; Host Flag 2
b_hf2	EQU	$08	;
m_hf3	EQU	4	; Host Flag 3
b_hf3	EQU	$10	;

;       Host Status Register Bit Flags

m_hrdf	EQU	0	; Host Receive Data Full
b_hrdf	EQU	$01	;
m_htde	EQU	1	; Host Transmit Data Empty
b_htde	EQU	$02	;
m_hcp	EQU	2	; Host Command Pending
b_hcp	EQU	$04	;
m_hf	EQU	$18	; Host Flag Mask
b_hf	EQU	$18	;
m_hf0	EQU	3	; Host Flag 0
b_hf0	EQU	$08	;
m_hf1	EQU	4	; Host Flag 1
b_hf1	EQU	$10	;
m_dma	EQU	7	; DMA Status
b_dma	EQU	$80	;

;------------------------------------------------------------------------
;
;	EQUATES for Serial Communications Interface (SCI)
;
;------------------------------------------------------------------------

;       Register Addresses

m_srxl	EQU	$FFF4	; SCI Receive Data Register (low)
m_srxm	EQU	$FFF5	; SCI Receive Data Register (middle)
m_srxh	EQU	$FFF6	; SCI Receive Data Register (high)
m_stxl	EQU	$FFF4	; SCI Transmit Data Register (low)
m_stxm	EQU	$FFF5	; SCI Transmit Data Register (middle)
m_stxh	EQU	$FFF6	; SCI Transmit Data Register (high)
m_stxa	EQU	$FFF3	; SCI Transmit Data Address Register
m_scr	EQU	$FFF0	; SCI Control Register
m_ssr	EQU	$FFF1	; SCI Status Register
m_sccr	EQU	$FFF2	; SCI Clock Control Register

;       SCI Control Register Bit Flags

m_wds	EQU	$7	; Word Select Mask
b_wds	EQU	$0007	;
m_wds0	EQU	0	; Word Select 0
b_wds0	EQU	$0001	;
m_wds1	EQU	1	; Word Select 1
b_wds1	EQU	$0002	;
m_wds2	EQU	2	; Word Select 2
b_wds2	EQU	$0004	;
m_sbk	EQU	4	; Send Break
b_sbk	EQU	$0010	;
m_wake	EQU	5	; Wake-up Mode Select
b_wake	EQU	$0020	;
m_rwi	EQU	6	; Receiver Wake-up Enable
b_rwi	EQU	$0040	;
m_woms	EQU	7	; Wired-OR Mode Select
b_woms	EQU	$0080	;
m_re	EQU	8	; Receiver Enable
b_re	EQU	$0100	;
m_te	EQU	9	; Transmitter Enable
b_te	EQU	$0200	;
m_ilie	EQU	10	; Idle Line Interrupt Enable
b_ilie	EQU	$0400	;
m_rie	EQU	11	; Receive Interrupt Enable
b_rie	EQU	$0800	;
m_tie	EQU	12	; Transmit Interrupt Enable
b_tie	EQU	$1000	;
m_tmie	EQU	13	; Timer Interrupt Enable
b_tmie	EQU	$2000	;

;       SCI Status Register Bit Flags

m_trne	EQU	0	; Transmitter Empty
b_trne	EQU	$01	;
m_tdre	EQU	1	; Transmit Data Register Empty
b_tdre	EQU	$02	;
m_rdrf	EQU	2	; Receive Data Register Full
b_rdrf	EQU	$04	;
m_idle	EQU	3	; Idle Line
b_idle	EQU	$08	;
m_or	EQU	4	; Overrun Error
b_or	EQU	$10	;
m_pe	EQU	5	; Parity Error
b_pe	EQU	$20	;
m_fe	EQU	6	; Framing Error
b_fe	EQU	$40	;
m_r8	EQU	7	; Received Bit 8
b_r8	EQU	$80	;

;       SCI Clock Control Register Bit Flags

m_cd	EQU	$FFF	; Clock Divider Mask
b_cd	EQU	$0FFF	;
m_cod	EQU	12	; Clock Out Divider
b_cod	EQU	$1000	;
m_scp	EQU	13	; Clock Prescaler
b_scp	EQU	$2000	;
m_rcm	EQU	14	; Receive Clock Source
b_rcm	EQU	$4000	;
m_tcm	EQU	15	; Transmit Clock Source
b_tcm	EQU	$8000	;

;------------------------------------------------------------------------
;
;	EQUATES for Synchronous Serial Interface (SSI)
;
;------------------------------------------------------------------------

;       Register Addresses

m_rx	EQU	$FFEF	; Serial Receive Data Register
m_tx	EQU	$FFEF	; Serial Transmit Data Register
m_cra	EQU	$FFEC	; SSI Control Register A
m_crb	EQU	$FFED	; SSI Control Register B
m_sr	EQU	$FFEE	; SSI Status Register
m_tsr	EQU	$FFEE	; SSI Time Slot Register

;       SSI Control Register A Bit Flags

m_pm	EQU	$00FF	; Prescale Modulus Select Mask
b_pm	EQU	$00FF	;
m_dc	EQU	$1F00	; Frame Rate Divider Control Mask
b_dc	EQU	$1F00	;
m_wl	EQU	$6000	; Word Length Control Mask
b_wl	EQU	$6000	;
m_wl0	EQU	13	; Word Length Control 0
b_wl0	EQU	$2000	;
m_wl1	EQU	14	; Word Length Control 1
b_wl1	EQU	$4000	;
m_psr	EQU	15	; Prescaler Range
b_psr	EQU	$8000	;

;       SSI Control Register B Bit Flags

m_of	EQU	$3	; Serial Output Flag Mask
b_of	EQU	$0003	;
m_of0	EQU	0	; Serial Output Flag 0
b_of0	EQU	$0001	;
m_of1	EQU	1	; Serial Output Flag 1
b_of1	EQU	$0002	;
m_scd	EQU	$1C	; Serial Control Direction Mask
b_scd	EQU	$001C	;
m_scd0	EQU	2	; Serial Control 0 Direction
b_scd0	EQU	$0004	;
m_scd1	EQU	3	; Serial Control 1 Direction
b_scd1	EQU	$0008	;
m_scd2	EQU	4	; Serial Control 2 Direction
b_scd2	EQU	$0010	;
m_sckd	EQU	5	; Clock Source Direction
b_sckd	EQU	$0020	;
m_fsl	EQU	8	; Frame Sync Length
b_fsl	EQU	$0100	;
m_syn	EQU	9	; Sync/Async Control
b_syn	EQU	$0200	;
m_gck	EQU	10	; Gated Clock Control
b_gck	EQU	$0400	;
m_mod	EQU	11	; Mode Select
b_mod	EQU	$0800	;
m_ste	EQU	12	; SSI Transmit Enable
b_ste	EQU	$1000	;
m_sre	EQU	13	; SSI Receive Enable
b_sre	EQU	$2000	;
m_stie	EQU	14	; SSI Transmit Interrupt Enable
b_stie	EQU	$4000	;
m_srie	EQU	15	; SSI Receive Interrupt Enable
b_srie	EQU	$8000	;

;       SSI Status Register Bit Flags

m_if	EQU	$3	; Serial Input Flag Mask
b_if	EQU	$03	;
m_if0	EQU	0	; Serial Input Flag 0
b_if0	EQU	$01	;
m_if1	EQU	1	; Serial Input Flag 1
b_if1	EQU	$02	;
m_tfs	EQU	2	; Transmit Frame Sync
b_tfs	EQU	$04	;
m_rfs	EQU	3	; Receive Frame Sync
b_rfs	EQU	$08	;
m_tue	EQU	4	; Transmitter Underrun Error
b_tue	EQU	$10	;
m_roe	EQU	5	; Receiver Overrun Error
b_roe	EQU	$20	;
m_tde	EQU	6	; Transmit Data Register Empty
b_tde	EQU	$40	;
m_rdf	EQU	7	; Receive Data Register Full
b_rdf	EQU	$80	;

;------------------------------------------------------------------------
;
;	EQUATES for Exception Processing
;
;------------------------------------------------------------------------

;       Register Addresses

m_ipr	EQU	$FFFF	; Interrupt Priority Register

;       Interrupt Priority Register Bit Flags

m_ial	EQU	$7	; IRQA Mode Mask
b_ial	EQU	$0007	;
m_ial0	EQU	0	; IRQA Mode Interrupt Priority Level (low)
b_ial0	EQU	$0001	;
m_ial1	EQU	1	; IRQA Mode Interrupt Priority Level (high)
b_ial1	EQU	$0002	;
m_ial2	EQU	2	; IRQA Mode Trigger Mode
b_ial2	EQU	$0004	;
m_ibl	EQU	$38	; IRQB Mode Mask
b_ibl	EQU	$0038	;
m_ibl0	EQU	3	; IRQB Mode Interrupt Priority Level (low)
b_ibl0	EQU	$0008	;
m_ibl1	EQU	4	; IRQB Mode Interrupt Priority Level (high)
b_ibl1	EQU	$0010	;
m_ibl2	EQU	5	; IRQB Mode Trigger Mode
b_ibl2	EQU	$0020	;
m_hpl	EQU	$C00	; Host Interrupt Priority Level Mask
b_hpl	EQU	$0C00	;
m_hpl0	EQU	10	; Host Interrupt Priority Level Mask (low)
b_hpl0	EQU	$0400	;
m_hpl1	EQU	11	; Host Interrupt Priority Level Mask (high)
b_hpl1	EQU	$0800	;
m_ssl	EQU	$3000	; SSI Interrupt Priority Level Mask
b_ssl	EQU	$3000	;
m_ssl0	EQU	12	; SSI Interrupt Priority Level Mask (low)
b_ssl0	EQU	$1000	;
m_ssl1	EQU	13	; SSI Interrupt Priority Level Mask (high)
b_ssl1	EQU	$2000	;
m_scl	EQU	$C000	; SCI Interrupt Priority Level Mask
b_scl	EQU	$C000	;
m_scl0	EQU	14	; SCI Interrupt Priority Level Mask (low)
b_scl0	EQU	$4000	;
m_scl1	EQU	15	; SCI Interrupt Priority Level Mask (high)
b_scl1	EQU	$8000	;

