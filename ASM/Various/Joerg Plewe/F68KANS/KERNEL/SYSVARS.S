.DATA


*****************************************************************
*                >PART 'System tables and variables'

tablesize       EQU 10
table:          DS.L tablesize  ;table of segment pointers
*               SB
*               SB + $10000
*               SB + $20000
*               .
*               .
*               .
*               SB + (tablesize * $10000)

hello:          ASCIIL '*** F68KANS *** (C) 1988-1993 by J. Plewe ***'
                EVEN

*************************************************************************
*       system variables                                                *
*************************************************************************
mtable:
tcold:          DC.L (quit-sys-of) ;vector for cold
tsystop:        DS.L 1          ;highest possible address
tsysbot:        DS.L 1
tdatatop:       DS.L 1
tdatabot:       DS.L 1
tforthparas:    DC.L 0
bootsys:        DC.L 0          ;return to loader
saveret:        DC.L 0          ;SP of loader
bootuser:       DC.L (usertable-datas) ;
troot:          DS.L 1          ;pointer to table of devices
tfront_opt:     DC.L (noop-sys-of) ;for an optimizer
tend_opt:       DC.L (noop-sys-of) ;dto.
                EVEN


*                ENDPART
