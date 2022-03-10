
;*========================================================================
;*
;* AESFAST Public Domain AES bindings.
;*
;*  Maintenance:
;*   02/10/89 v1.10 - Added more labels to items within global array.
;*========================================================================

;*************************************************************************
;*
;* Header file for AESFAST source code modules.  Offsets (structures)
;*  and macros can be found here. (Hey!  just like a C header...)
;*
;*  Also, if the symbol AES_ALLOCBSS is defined, we will actually 
;*  allocate storage in the BSS section for the AES control blocks, if
;*  the symbol is not defined, we just define the offsets but no storage.
;*
;*************************************************************************

          .globl    aesblock    ; Everybody (potentially at least)
          .globl    aes_call    ; uses these things, so we might
          .globl    aes_do      ; as well define them here.

FALSE     = 0                   ; Mundane
TRUE      = 1                   ; stuff.

RET2USER  = 0                   ; These are flags used by the ACall macro to
RET2HERE  = 1                   ; decide between calling aes_call or aes_do.

;-------------------------------------------------------------------------
; ACall macro.  Call the AES.  Depending on the value of the 'type' flag,
;  we generate a 'jsr aes_call' or a 'jmp aes_do'.
;-------------------------------------------------------------------------

.macro    ACall     type
          .if    \type
           jsr      aes_call
          .else
           jmp      aes_do
          .endif
.endm

;-------------------------------------------------------------------------
; AControl macro.  Load register d0 with the control array (byte) values.
;  By getting all the control values into a single register (except the
;  'addrout' count, which is always zero) we can load the entire control
;  array with a single 'movep.l' instruction in aes_call.
;-------------------------------------------------------------------------

.macro    AControl  fun,ini,adi,ino
          move.l    #( (\fun << 24) | (\ini << 16) | (\adi << 8) | \ino ),d0
.endm

;-------------------------------------------------------------------------
; Define the offsets within the AES block storage area.
;-------------------------------------------------------------------------

          .abs                          ; Offsets from 'aesblock'...

aespb     =         *                   ; 'aespb' MUST be first!...
pcontrl:  ds.l      1                   ;   Pointer to control array
pglobal:  ds.l      1                   ;   Pointer to global array
pintin:   ds.l      1                   ;   Pointer to intin array
pintout:  ds.l      1                   ;   Pointer to intout array
padrin:   ds.l      1                   ;   Pointer to adrin array
padrout:  ds.l      1                   ;   Pointer to adrout array

control   =         *                   ; Control array is next...
function: ds.w      1                   ;   Function code
sintin:   ds.w      1                   ;   size of intin
sintout:  ds.w      1                   ;   size of intout
sadrin:   ds.w      1                   ;   size of adrin
sadrout:  ds.w      1                   ;   size of adrout

global:   ds.w      15                  ; Global array, needs no further def.

SZ_AESBLK =         *                   ; Size of the aesblock storage.

;-------------------------------------------------------------------------
; If we are supposed to be allocating the BSS storage (eg, if we are
;  being included from AESCOMN), export the global labels and define
;  the necessary BSS storage.
;
;  |1.1:  Fully defined the global storage block and exported the labels
;         for all of it. Names were made up using 'gl_apid' as the example.
;         This change is primarily to support TOS 1.4, in which the AES
;         version becomes an important issue.
;-------------------------------------------------------------------------

          .globl    _gl_apid            ; Export this label for C programs.
          .globl    _global             ; Export this label for C programs.
          .globl    _aespb              ; Export this label for C programs.
          .globl    _aescontrol         ; |v1.1: added
          .globl    _gl_apversion       ; |v1.1: added
          .globl    _gl_apcount         ; |v1.1: added
          .globl    _gl_apid            ; |v1.1: added
          .globl    _gl_apprivate       ; |v1.1: added
          .globl    _gl_apptree         ; |v1.1: added
          .globl    _gl_ap1resv         ; |v1.1: added
          .globl    _gl_apprshdr        ; |v1.8: added
          .globl    _gl_ap2resv         ; |v1.8: added
          
          .if       ^^defined AES_ALLOCBSS
          .bss
aesblock:                               ; Integrated AES data block storage.
_aespb:        ds.l      6              ;   Room for aespb array.
_aescontrol:   ds.w      5              ;   Room for control array.
_global:                                ;   Global array...
_gl_apversion: ds.w      1              ;       AES version.
_gl_apcount:   ds.w      1              ;       AES max appl count.
_gl_apid:      ds.w      1              ;       Application id.
_gl_apprivate: ds.l      1              ;       Application-specific data.
_gl_apptree:   ds.l      1              ;       Pointer to head of RSC tree.
_gl_ap1resv:                            ;|v1.4: (Old name retained)
_gl_aprshdr:   ds.l      1              ;|v1.4: Pointer to rshdr struct.
_gl_ap2resv:   ds.l      3              ;       Rest of the global array.

          .endif ; ^^defined AES_ALLOCBSS

          .text                         ; Leave BSS mode...

;         end of code

