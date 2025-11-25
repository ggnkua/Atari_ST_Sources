;*********  Teil aus IOEQU.INC ************

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
