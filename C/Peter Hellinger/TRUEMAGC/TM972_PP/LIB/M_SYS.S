; +---------------------------------------------------------------------
; |  Exported symbols
; +---------------------------------------------------------------------

        .EXPORT RunMagic
        .IMPORT MagicBase

        MC68000        


RunMagic:       MOVE.L #0, -(sp)
                MOVE.L MagicBase, -(sp)
                MOVE.L #0, -(sp)
                MOVE.W #4, -(sp)
                MOVE.w #$4B, -(sp)
                TRAP #1
                LEA $10(sp), sp
                RTS