; DSP 56001 equates.

; I/O Port Programming
M_BCR   EQU     $FFFE           ; Port A Bus Control Register
M_PBC   EQU     $FFE0           ; Port B Control Register
M_PBDDR EQU     $FFE2           ; Port B Data Direction Register
M_PBD   EQU     $FFE4           ; Port B Data Register
M_PCC   EQU     $FFE1           ; Port C Control Register
M_PCDDR EQU     $FFE3           ; Port C Data Direction Register
M_PCD   EQU     $FFE5           ; Port C Data Register

; Host Interface
M_HCR   EQU     $FFE8           ; Host Control Register
M_HSR   EQU     $FFE9           ; Host Status Register
M_HRX   EQU     $FFEB           ; Host Receive Data Register
M_HTX   EQU     $FFEB           ; Host Transmit Data Register

; SSI, Synchronous Serial Interface
M_RX    EQU     $FFEF           ; Serial Receive Data Register
M_TX    EQU     $FFEF           ; Serial Transmit Data Register
M_CRA   EQU     $FFEC           ; SSI Control Register A
M_CRB   EQU     $FFED           ; SSI Control Register B
M_SR    EQU     $FFEE           ; SSI Status Register
M_TSR   EQU     $FFEE           ; SSI Time Slot Register

; Exception Processing
M_IPR   EQU     $FFFF           ; Interrupt Priority Register
