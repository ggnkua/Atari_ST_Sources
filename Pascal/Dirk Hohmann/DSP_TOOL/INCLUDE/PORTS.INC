;*********  Teil aus IOEQU.INC ************

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