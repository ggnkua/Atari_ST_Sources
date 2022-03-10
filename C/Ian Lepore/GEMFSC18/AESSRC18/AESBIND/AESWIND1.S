
;*========================================================================
;*
;* AESFAST GEM bindings.
;*
;*  Maintenance:
;*   02/10/89 v1.10: Added new function, 'wind_new', available only in
;*            TOS 1.4.
;*========================================================================

          .include  "aesfast.sh"
          
;*************************************************************************
;*
;* Window manager routines 1 of 2.
;*
;*************************************************************************

;-------------------------------------------------------------------------
; wind_create
; wind_open
; wind_close
; wind_delete
; wind_set
; wind_find
; wind_update
; wind_new        |v1.10: added
;-------------------------------------------------------------------------

_wind_create::
          AControl  100,5,1,0
          bra.s     wind_do
_wind_open::
          AControl  101,5,1,0
          bra.s     wind_do
_wind_close::
          AControl  102,1,1,0
          bra.s     wind_do
_wind_delete::
          AControl  103,1,1,0
          bra.s     wind_do 
_wind_set::
          AControl  105,6,1,0
          bra.s     wind_do
_wind_find::
          AControl  106,2,1,0
          bra.s     wind_do
_wind_update::
          AControl  107,1,1,0
          bra.s     wind_do
_wind_new::
          AControl  109,0,0,0           ; |1.10: added
wind_do:
          .cargs    #4,.intin
          lea       .intin(sp),a1
          ACall     RET2USER
          

;         end of code

