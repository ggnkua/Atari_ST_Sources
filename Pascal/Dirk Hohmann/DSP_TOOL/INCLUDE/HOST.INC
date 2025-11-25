;*********  Teil aus IOEQU.INC ************

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