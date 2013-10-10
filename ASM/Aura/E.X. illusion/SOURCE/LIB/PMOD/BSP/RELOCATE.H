    IFND    _RELOCATE
_RELOCATE   EQU     -1

RE_PRG      EQUR    a0

RELOCATE_P  MACRO
            lea     \1,RE_PRG
            bsr.w   RELOCATE
            ENDM

RELOCATE:   INLINE  "RELOCATE.INC"
    ENDIF