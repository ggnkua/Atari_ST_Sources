;***************************************************************************
;*                                                                         *
;*                     Enable VME SYSFAIL Interrupt                        *
;*                                                                         *
;***************************************************************************

gemdos          EQU 1
buserrv         EQU 8
cconws          EQU 9
super           EQU 32

                TEXT
                clr.l   -(SP)
                move.w  #super,-(SP)
                trap    #gemdos
                move.l  buserrv,A0
                move.l  SP,A1
                lea     return(PC),A2
                move.l  A2,buserrv
                bset    #7,$FFFF8E01
return:         move.l  A1,SP
                move.l  A0,buserrv
                move.l  D0,-(SP)
                move.w  #super,-(SP)
                trap    #gemdos
                pea     message
                move.w  #cconws,-(SP)
                trap    #gemdos
                addq.l  #6,SP
                clr.w   -(sp)
                trap    #gemdos

                DATA
message:        dc.b   13,10,"VME-SYSFAIL NMI enabled.",13,10,0
                END
