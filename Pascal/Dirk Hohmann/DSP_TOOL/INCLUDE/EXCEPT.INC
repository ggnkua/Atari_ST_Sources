;*********  Teil aus IOEQU.INC ************

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
