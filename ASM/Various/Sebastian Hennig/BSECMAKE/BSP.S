; ----------------------------------------------------------------------------
;
;               Rahmen fr ein Bootsektor-Programm
;               Fr den TurboASS-Assembler
;
;               Mu "roh" assembliert werden, d.h.
;               - ohne Symboltabelle
;               - ohne Reloctabelle
;               - kurz : Die reinen Bin„rdaten
;
; ----------------------------------------------------------------------------

                default 4               ;'absolut' assemblieren
                output 'SEKTOR.BIN'     ;Ausgabedatei

begin:          bra.s   main            ;Wichtig !
                ds.b 28                 ;Nicht ver„ndern !

;            ----------

main:

;               ...
;
;               Hier eigene Routine
;               einbauen
;               ...

                rts                     ;Rckkehr zum TOS

;            ----------

free            set *-begin             ;Free enth„lt nach dem assemblieren
;                                       ;die Gr”e des verbleibenden
;                                       ;Speichers im Bootsektor.

                ds.b 512-free           ;Auf 512 Bytes auffllen
                end
