;ASS_MAC Version 1.10
;====================
;
;Assembler:     GFA, Version 1.5
;Versionsdatum: 13.10.1990
;
;Macros fÅr:    TOS030
;
;(C) 1989,90 by
;Martin Birn, Knoblochstraûe 51, D-7100 Heilbronn
;
;NÑhere Informationen enthÑlt die Datei LIESMICH.DOK.
;-------------------------------------------------------------------------------

                .TEXT 

;
;eine neue GEMDOS-Funktion...
;

                .MACRO MXALLOC size,mode
                move.w        \mode,-(sp)
                move.l        \size,-(sp)
                GEMDOS        68,10
                .ENDM 

;
;...und viele neue XBIOS-Funktionen
;

                .MACRO DMAREAD sector,count,buffer,devno
                move.w        \devno,-(sp)
                move.l        \buffer,-(sp)
                move.w        \count,-(sp)
                move.l        \sector,-(sp)
                XBIOS         42,16
                .ENDM 

                .MACRO DMAWRITE sector,count,buffer,devno
                move.w        \devno,-(sp)
                move.l        \buffer,-(sp)
                move.w        \count,-(sp)
                move.l        \sector,-(sp)
                XBIOS         43,16
                .ENDM 

                .MACRO BCONMAP devno
                move.w        \devno,-(sp)
                XBIOS         44,6
                .ENDM 

                .MACRO _ESETSHIFT mode
                move.w        \mode,-(sp)
                XBIOS         80,6
                .ENDM 

                .MACRO _EGETSHIFT
                XBIOS         81
                .ENDM 

                .MACRO _ESETBANK mode
                move.w        \mode,-(sp)
                XBIOS         82,6
                .ENDM 

                .MACRO _ESETCOLOR reg,val
                move.w        \val,-(sp)
                move.w        \reg,-(sp)
                XBIOS         83,8
                .ENDM 

                .MACRO _ESETPALETTE startreg,countreg,paddr
                move.l        \paddr,-(sp)
                move.w        \countreg,-(sp)
                move.w        \startreg,-(sp)
                XBIOS         84,12
                .ENDM 

                .MACRO _EGETPALETTE startreg,countreg,paddr
                move.l        \paddr,-(sp)
                move.w        \countreg,-(sp)
                move.w        \startreg,-(sp)
                XBIOS         85,12
                .ENDM 

                .MACRO _ESETGRAY flag
                move.w        \flag,-(sp)
                XBIOS         86,6
                .ENDM 

                .MACRO _ESETSMEAR flag
                move.w        \flag,-(sp)
                XBIOS         87,6
                .ENDM 

;
;noch eine neue Systemvariable
;

_p_cookies      = $5a0

                .END 

