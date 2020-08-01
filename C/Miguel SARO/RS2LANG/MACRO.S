
Bitblk:  MACRO
         dc.l    \1
         dc.w    \2,\3,\4,\5,\6
         ENDM

Iconblk: MACRO
         dc.l    \1,\2,\3
         dc.w    \4,\5,\6,\7,\8,\9
         dc.w    \a,\b,\c,\d,\e
         ENDM

Tedi:    MACRO
         dc.l    \1,\2,\3
         dc.w    \4,\5,\6,\7
         dc.w    \8,\9,\a,\b
         ENDM

Objet:   MACRO
         dc.w    \1,\2,\3,\4,\5,\6
         dc.l    \7
         dc.w    \8,\9,\a,\b
         ENDM

