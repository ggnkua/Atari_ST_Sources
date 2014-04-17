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
;       EQUATES for DSP56000 I/O registers and ports
;
;************************************************************************

ioequ   ident   1,0

;------------------------------------------------------------------------
;
;       EQUATES for I/O Port Programming
;
;------------------------------------------------------------------------

;       Register Addresses

M_BCR   EQU     $FFFE           ; Port A Bus Control Register
M_PBC   EQU     $FFE0           ; Port B Control Register
M_PBDDR EQU     $FFE2           ; Port B Data Direction Register
M_PBD   EQU     $FFE4           ; Port B Data Register
M_PCC   EQU     $FFE1           ; Port C Control Register
M_PCDDR EQU     $FFE3           ; Port C Data Direction Register
M_PCD   EQU     $FFE5           ; Port C Data Register


;------------------------------------------------------------------------
;
;       EQUATES for Host Interface
;
;------------------------------------------------------------------------

;       Register Addresses

M_HCR   EQU     $FFE8           ; Host Control Register
M_HSR   EQU     $FFE9           ; Host Status Register
M_HRX   EQU     $FFEB           ; Host Receive Data Register
M_HTX   EQU     $FFEB           ; Host Transmit Data Register

;       Host Control Register Bit Flags

M_HRIE  EQU     0               ; Host Receive Interrupt Enable
M_HTIE  EQU     1               ; Host Transmit Interrupt Enable
M_HCIE  EQU     2               ; Host Command Interrupt Enable
M_HF2   EQU     3               ; Host Flag 2
M_HF3   EQU     4               ; Host Flag 3

;       Host Status Register Bit Flags

M_HRDF  EQU     0               ; Host Receive Data Full
M_HTDE  EQU     1               ; Host Transmit Data Empty
M_HCP   EQU     2               ; Host Command Pending
M_HF    EQU     $18             ; Host Flag Mask
M_HF0   EQU     3               ; Host Flag 0
M_HF1   EQU     4               ; Host Flag 1
M_DMA   EQU     7               ; DMA Status

;------------------------------------------------------------------------
;
;       EQUATES for Serial Communications Interface (SCI)
;
;------------------------------------------------------------------------

;       Register Addresses

M_SRXL  EQU     $FFF4           ; SCI Receive Data Register (low)
M_SRXM  EQU     $FFF5           ; SCI Receive Data Register (middle)
M_SRXH  EQU     $FFF6           ; SCI Receive Data Register (high)
M_STXL  EQU     $FFF4           ; SCI Transmit Data Register (low)
M_STXM  EQU     $FFF5           ; SCI Transmit Data Register (middle)
M_STXH  EQU     $FFF6           ; SCI Transmit Data Register (high)
M_STXA  EQU     $FFF3           ; SCI Transmit Data Address Register
M_SCR   EQU     $FFF0           ; SCI Control Register
M_SSR   EQU     $FFF1           ; SCI Status Register
M_SCCR  EQU     $FFF2           ; SCI Clock Control Register

;       SCI Control Register Bit Flags

M_WDS   EQU     $3              ; Word Select Mask
M_WDS0  EQU     0               ; Word Select 0
M_WDS1  EQU     1               ; Word Select 1
M_WDS2  EQU     2               ; Word Select 2
M_SBK   EQU     4               ; Send Break
M_WAKE  EQU     5               ; Wake-up Mode Select
M_RWI   EQU     6               ; Receiver Wake-up Enable
M_WOMS  EQU     7               ; Wired-OR Mode Select
M_RE    EQU     8               ; Receiver Enable
M_TE    EQU     9               ; Transmitter Enable
M_ILIE  EQU     10              ; Idle Line Interrupt Enable
M_RIE   EQU     11              ; Receive Interrupt Enable
M_TIE   EQU     12              ; Transmit Interrupt Enable
M_TMIE  EQU     13              ; Timer Interrupt Enable

;       SCI Status Register Bit Flags

M_TRNE  EQU     0               ; Transmitter Empty
M_TDRE  EQU     1               ; Transmit Data Register Empty
M_RDRF  EQU     2               ; Receive Data Register Full
M_IDLE  EQU     3               ; Idle Line
M_OR    EQU     4               ; Overrun Error
M_PE    EQU     5               ; Parity Error
M_FE    EQU     6               ; Framing Error
M_R8    EQU     7               ; Received Bit 8

;       SCI Clock Control Register Bit Flags

M_CD    EQU     $FFF            ; Clock Divider Mask
M_COD   EQU     12              ; Clock Out Divider
M_SCP   EQU     13              ; Clock Prescaler
M_RCM   EQU     14              ; Receive Clock Source
M_TCM   EQU     15              ; Transmit Clock Source

;------------------------------------------------------------------------
;
;       EQUATES for Synchronous Serial Interface (SSI)
;
;------------------------------------------------------------------------

;       Register Addresses

M_RX    EQU     $FFEF           ; Serial Receive Data Register
M_TX    EQU     $FFEF           ; Serial Transmit Data Register
M_CRA   EQU     $FFEC           ; SSI Control Register A
M_CRB   EQU     $FFED           ; SSI Control Register B
M_SR    EQU     $FFEE           ; SSI Status Register
M_TSR   EQU     $FFEE           ; SSI Time Slot Register

;       SSI Control Register A Bit Flags

M_PM    EQU     $FF             ; Prescale Modulus Select Mask
M_DC    EQU     $1F00           ; Frame Rate Divider Control Mask
M_WL    EQU     $6000           ; Word Length Control Mask
M_WL0   EQU     13              ; Word Length Control 0
M_WL1   EQU     14              ; Word Length Control 1
M_PSR   EQU     15              ; Prescaler Range

;       SSI Control Register B Bit Flags

M_OF    EQU     $3              ; Serial Output Flag Mask
M_OF0   EQU     0               ; Serial Output Flag 0
M_OF1   EQU     1               ; Serial Output Flag 1
M_SCD   EQU     $1C             ; Serial Control Direction Mask
M_SCD0  EQU     2               ; Serial Control 0 Direction
M_SCD1  EQU     3               ; Serial Control 1 Direction
M_SCD2  EQU     4               ; Serial Control 2 Direction
M_SCKD  EQU     5               ; Clock Source Direction
M_FSL   EQU     8               ; Frame Sync Length
M_SYN   EQU     9               ; Sync/Async Control
M_GCK   EQU     10              ; Gated Clock Control
M_MOD   EQU     11              ; Mode Select
M_STE   EQU     12              ; SSI Transmit Enable
M_SRE   EQU     13              ; SSI Receive Enable
M_STIE  EQU     14              ; SSI Transmit Interrupt Enable
M_SRIE  EQU     15              ; SSI Receive Interrupt Enable

;       SSI Status Register Bit Flags

M_IF    EQU     $2              ; Serial Input Flag Mask
M_IF0   EQU     0               ; Serial Input Flag 0
M_IF1   EQU     1               ; Serial Input Flag 1
M_TFS   EQU     2               ; Transmit Frame Sync
M_RFS   EQU     3               ; Receive Frame Sync
M_TUE   EQU     4               ; Transmitter Underrun Error
M_ROE   EQU     5               ; Receiver Overrun Error
M_TDE   EQU     6               ; Transmit Data Register Empty
M_RDF   EQU     7               ; Receive Data Register Full

;------------------------------------------------------------------------
;
;       EQUATES for Exception Processing
;
;------------------------------------------------------------------------

;       Register Addresses

M_IPR   EQU     $FFFF           ; Interrupt Priority Register

;       Interrupt Priority Register Bit Flags

M_IAL   EQU     $7              ; IRQA Mode Mask
M_IAL0  EQU     0               ; IRQA Mode Interrupt Priority Level (low)
M_IAL1  EQU     1               ; IRQA Mode Interrupt Priority Level (high)
M_IAL2  EQU     2               ; IRQA Mode Trigger Mode
M_IBL   EQU     $38             ; IRQB Mode Mask
M_IBL0  EQU     3               ; IRQB Mode Interrupt Priority Level (low)
M_IBL1  EQU     4               ; IRQB Mode Interrupt Priority Level (high)
M_IBL2  EQU     5               ; IRQB Mode Trigger Mode
M_HPL   EQU     $C00            ; Host Interrupt Priority Level Mask
M_HPL0  EQU     10              ; Host Interrupt Priority Level Mask (low)
M_HPL1  EQU     11              ; Host Interrupt Priority Level Mask (high)
M_SSL   EQU     $3000           ; SSI Interrupt Priority Level Mask
M_SSL0  EQU     12              ; SSI Interrupt Priority Level Mask (low)
M_SSL1  EQU     13              ; SSI Interrupt Priority Level Mask (high)
M_SCL   EQU     $C000           ; SCI Interrupt Priority Level Mask
M_SCL0  EQU     14              ; SCI Interrupt Priority Level Mask (low)
M_SCL1  EQU     15              ; SCI Interrupt Priority Level Mask (high)
