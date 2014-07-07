;
; This program originally available on the Motorola DSP bulletin board.
; It is provided under a DISCLAMER OF WARRANTY available from
; Motorola DSP Operation, 6501 Wm. Cannon Drive W., Austin, Tx., 78735.
; 
; Motorola Standard I/O Equates.
; 
; Last Update 25 Aug 87   Version 1.1   fixed M_OF
;
;************************************************************************
;
;	EQUATES for DSP56000 I/O registers and ports
;
;************************************************************************

;ioequ	ident   1,0

;------------------------------------------------------------------------
;
;	EQUATES for I/O Port Programming
;
;------------------------------------------------------------------------

;       Register Addresses

M_BCR	EQU	$FFFE	; Port A Bus Control Register
M_PBC	EQU	$FFE0	; Port B Control Register
M_PBDDR	EQU	$FFE2	; Port B Data Direction Register
M_PBD	EQU	$FFE4	; Port B Data Register
M_PCC	EQU	$FFE1	; Port C Control Register
M_PCDDR	EQU	$FFE3	; Port C Data Direction Register
M_PCD	EQU	$FFE5	; Port C Data Register


;------------------------------------------------------------------------
;
;	EQUATES for Host Interface
;
;------------------------------------------------------------------------

;       Register Addresses

M_HCR	EQU	$FFE8	; Host Control Register
M_HSR	EQU	$FFE9	; Host Status Register
M_HRX	EQU	$FFEB	; Host Receive Data Register
M_HTX	EQU	$FFEB	; Host Transmit Data Register

;       Host Control Register Bit Flags

M_HRIE	EQU	0	; Host Receive Interrupt Enable
B_HRIE	EQU	$01	;
M_HTIE	EQU	1	; Host Transmit Interrupt Enable
B_HTIE	EQU	$02	;
M_HCIE	EQU	2	; Host Command Interrupt Enable
B_HCIE	EQU	$04	;
M_HF2	EQU	3	; Host Flag 2
B_HF2	EQU	$08	;
M_HF3	EQU	4	; Host Flag 3
B_HF3	EQU	$10	;

;       Host Status Register Bit Flags

M_HRDF	EQU	0	; Host Receive Data Full
B_HRDF	EQU	$01	;
M_HTDE	EQU	1	; Host Transmit Data Empty
B_HTDE	EQU	$02	;
M_HCP	EQU	2	; Host Command Pending
B_HCP	EQU	$04	;
M_HF	EQU	$18	; Host Flag Mask
B_HF	EQU	$18	;
M_HF0	EQU	3	; Host Flag 0
B_HF0	EQU	$08	;
M_HF1	EQU	4	; Host Flag 1
B_HF1	EQU	$10	;
M_DMA	EQU	7	; DMA Status
B_DMA	EQU	$80	;

;------------------------------------------------------------------------
;
;	EQUATES for Serial Communications Interface (SCI)
;
;------------------------------------------------------------------------

;       Register Addresses

M_SRXL	EQU	$FFF4	; SCI Receive Data Register (low)
M_SRXM	EQU	$FFF5	; SCI Receive Data Register (middle)
M_SRXH	EQU	$FFF6	; SCI Receive Data Register (high)
M_STXL	EQU	$FFF4	; SCI Transmit Data Register (low)
M_STXM	EQU	$FFF5	; SCI Transmit Data Register (middle)
M_STXH	EQU	$FFF6	; SCI Transmit Data Register (high)
M_STXA	EQU	$FFF3	; SCI Transmit Data Address Register
M_SCR	EQU	$FFF0	; SCI Control Register
M_SSR	EQU	$FFF1	; SCI Status Register
M_SCCR	EQU	$FFF2	; SCI Clock Control Register

;       SCI Control Register Bit Flags

M_WDS	EQU	$7	; Word Select Mask
B_WDS	EQU	$0007	;
M_WDS0	EQU	0	; Word Select 0
B_WDS0	EQU	$0001	;
M_WDS1	EQU	1	; Word Select 1
B_WDS1	EQU	$0002	;
M_WDS2	EQU	2	; Word Select 2
B_WDS2	EQU	$0004	;
M_SBK	EQU	4	; Send Break
B_SBK	EQU	$0010	;
M_WAKE	EQU	5	; Wake-up Mode Select
B_WAKE	EQU	$0020	;
M_RWI	EQU	6	; Receiver Wake-up Enable
B_RWI	EQU	$0040	;
M_WOMS	EQU	7	; Wired-OR Mode Select
B_WOMS	EQU	$0080	;
M_RE	EQU	8	; Receiver Enable
B_RE	EQU	$0100	;
M_TE	EQU	9	; Transmitter Enable
B_TE	EQU	$0200	;
M_ILIE	EQU	10	; Idle Line Interrupt Enable
B_ILIE	EQU	$0400	;
M_RIE	EQU	11	; Receive Interrupt Enable
B_RIE	EQU	$0800	;
M_TIE	EQU	12	; Transmit Interrupt Enable
B_TIE	EQU	$1000	;
M_TMIE	EQU	13	; Timer Interrupt Enable
B_TMIE	EQU	$2000	;

;       SCI Status Register Bit Flags

M_TRNE	EQU	0	; Transmitter Empty
B_TRNE	EQU	$01	;
M_TDRE	EQU	1	; Transmit Data Register Empty
B_TDRE	EQU	$02	;
M_RDRF	EQU	2	; Receive Data Register Full
B_RDRF	EQU	$04	;
M_IDLE	EQU	3	; Idle Line
B_IDLE	EQU	$08	;
M_OR	EQU	4	; Overrun Error
B_OR	EQU	$10	;
M_PE	EQU	5	; Parity Error
B_PE	EQU	$20	;
M_FE	EQU	6	; Framing Error
B_FE	EQU	$40	;
M_R8	EQU	7	; Received Bit 8
B_R8	EQU	$80	;

;       SCI Clock Control Register Bit Flags

M_CD	EQU	$FFF	; Clock Divider Mask
B_CD	EQU	$0FFF	;
M_COD	EQU	12	; Clock Out Divider
B_COD	EQU	$1000	;
M_SCP	EQU	13	; Clock Prescaler
B_SCP	EQU	$2000	;
M_RCM	EQU	14	; Receive Clock Source
B_RCM	EQU	$4000	;
M_TCM	EQU	15	; Transmit Clock Source
B_TCM	EQU	$8000	;

;------------------------------------------------------------------------
;
;	EQUATES for Synchronous Serial Interface (SSI)
;
;------------------------------------------------------------------------

;       Register Addresses

M_RX	EQU	$FFEF	; Serial Receive Data Register
M_TX	EQU	$FFEF	; Serial Transmit Data Register
M_CRA	EQU	$FFEC	; SSI Control Register A
M_CRB	EQU	$FFED	; SSI Control Register B
M_SR	EQU	$FFEE	; SSI Status Register
M_TSR	EQU	$FFEE	; SSI Time Slot Register

;       SSI Control Register A Bit Flags

M_PM	EQU	$00FF	; Prescale Modulus Select Mask
B_PM	EQU	$00FF	;
M_DC	EQU	$1F00	; Frame Rate Divider Control Mask
B_DC	EQU	$1F00	;
M_WL	EQU	$6000	; Word Length Control Mask
B_WL	EQU	$6000	;
M_WL0	EQU	13	; Word Length Control 0
B_WL0	EQU	$2000	;
M_WL1	EQU	14	; Word Length Control 1
B_WL1	EQU	$4000	;
M_PSR	EQU	15	; Prescaler Range
B_PSR	EQU	$8000	;

;       SSI Control Register B Bit Flags

M_OF	EQU	$3	; Serial Output Flag Mask
B_OF	EQU	$0003	;
M_OF0	EQU	0	; Serial Output Flag 0
B_OF0	EQU	$0001	;
M_OF1	EQU	1	; Serial Output Flag 1
B_OF1	EQU	$0002	;
M_SCD	EQU	$1C	; Serial Control Direction Mask
B_SCD	EQU	$001C	;
M_SCD0	EQU	2	; Serial Control 0 Direction
B_SCD0	EQU	$0004	;
M_SCD1	EQU	3	; Serial Control 1 Direction
B_SCD1	EQU	$0008	;
M_SCD2	EQU	4	; Serial Control 2 Direction
B_SCD2	EQU	$0010	;
M_SCKD	EQU	5	; Clock Source Direction
B_SCKD	EQU	$0020	;
M_FSL	EQU	8	; Frame Sync Length
B_FSL	EQU	$0100	;
M_SYN	EQU	9	; Sync/Async Control
B_SYN	EQU	$0200	;
M_GCK	EQU	10	; Gated Clock Control
B_GCK	EQU	$0400	;
M_MOD	EQU	11	; Mode Select
B_MOD	EQU	$0800	;
M_STE	EQU	12	; SSI Transmit Enable
B_STE	EQU	$1000	;
M_SRE	EQU	13	; SSI Receive Enable
B_SRE	EQU	$2000	;
M_STIE	EQU	14	; SSI Transmit Interrupt Enable
B_STIE	EQU	$4000	;
M_SRIE	EQU	15	; SSI Receive Interrupt Enable
B_SRIE	EQU	$8000	;

;       SSI Status Register Bit Flags

M_IF	EQU	$3	; Serial Input Flag Mask
B_IF	EQU	$03	;
M_IF0	EQU	0	; Serial Input Flag 0
B_IF0	EQU	$01	;
M_IF1	EQU	1	; Serial Input Flag 1
B_IF1	EQU	$02	;
M_TFS	EQU	2	; Transmit Frame Sync
B_TFS	EQU	$04	;
M_RFS	EQU	3	; Receive Frame Sync
B_RFS	EQU	$08	;
M_TUE	EQU	4	; Transmitter Underrun Error
B_TUE	EQU	$10	;
M_ROE	EQU	5	; Receiver Overrun Error
B_ROE	EQU	$20	;
M_TDE	EQU	6	; Transmit Data Register Empty
B_TDE	EQU	$40	;
M_RDF	EQU	7	; Receive Data Register Full
B_RDF	EQU	$80	;

;------------------------------------------------------------------------
;
;	EQUATES for Exception Processing
;
;------------------------------------------------------------------------

;       Register Addresses

M_IPR	EQU	$FFFF	; Interrupt Priority Register

;       Interrupt Priority Register Bit Flags

M_IAL	EQU	$7	; IRQA Mode Mask
B_IAL	EQU	$0007	;
M_IAL0	EQU	0	; IRQA Mode Interrupt Priority Level (low)
B_IAL0	EQU	$0001	;
M_IAL1	EQU	1	; IRQA Mode Interrupt Priority Level (high)
B_IAL1	EQU	$0002	;
M_IAL2	EQU	2	; IRQA Mode Trigger Mode
B_IAL2	EQU	$0004	;

M_IBL	EQU	$38	; IRQB Mode Mask
B_IBL	EQU	$0038	;
M_IBL0	EQU	3	; IRQB Mode Interrupt Priority Level (low)
B_IBL0	EQU	$0008	;
M_IBL1	EQU	4	; IRQB Mode Interrupt Priority Level (high)
B_IBL1	EQU	$0010	;
M_IBL2	EQU	5	; IRQB Mode Trigger Mode
B_IBL2	EQU	$0020	;

M_HPL	EQU	$C00	; Host Interrupt Priority Level Mask
B_HPL	EQU	$0C00	;
M_HPL0	EQU	10	; Host Interrupt Priority Level Mask (low)
B_HPL0	EQU	$0400	;
M_HPL1	EQU	11	; Host Interrupt Priority Level Mask (high)
B_HPL1	EQU	$0800	;

M_SSL	EQU	$3000	; SSI Interrupt Priority Level Mask
B_SSL	EQU	$3000	;
M_SSL0	EQU	12	; SSI Interrupt Priority Level Mask (low)
B_SSL0	EQU	$1000	;
M_SSL1	EQU	13	; SSI Interrupt Priority Level Mask (high)
B_SSL1	EQU	$2000	;

M_SCL	EQU	$C000	; SCI Interrupt Priority Level Mask
B_SCL	EQU	$C000	;
M_SCL0	EQU	14	; SCI Interrupt Priority Level Mask (low)
B_SCL0	EQU	$4000	;
M_SCL1	EQU	15	; SCI Interrupt Priority Level Mask (high)
B_SCL1	EQU	$8000	;
