;*********  Teil aus IOEQU.INC ************

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
