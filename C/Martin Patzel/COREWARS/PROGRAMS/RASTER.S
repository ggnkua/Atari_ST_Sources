;
;       Rasterfahnder
;
;       sucht mit Schrittweite step den ganzen Speicher ab und versucht,
;       Programme zu suchen (<> DAT 0), diese werden dann mit DAT's
;       Åberschrieben.
;

        step    = 13            ; Rasterweite
        friend  = 19            ; geheime Kennzahl

;
;       falls der Rasterfahnder den folgenden JMP-Befehl findet, werden
;       dieser und die folgenden 9 DAT's mit DAT 0 Åberschrieben.
;       Die folgenden DAT's werden fÅr weitere Suchrunden des R-Fahnders
;       gebraucht (Schrittweite ist 13)
;
progstart:
        JMP     start

        DAT     friend          ; Freund/Feind-Kennung
        DAT     friend
        DAT     friend
        DAT     friend
        DAT     friend
        DAT     friend
        DAT     friend
        DAT     friend
        DAT     friend
        DAT     friend
        DAT     friend
        DAT     friend
        DAT     friend
        DAT     friend
        DAT     friend
        DAT     friend
        DAT     friend
        DAT     friend
        DAT     friend
        DAT     friend
        DAT     friend
        DAT     friend
friends DAT     friend
ptr     DAT     0                       ; Rasterfahnder
first   DAT     0                       ; Zur Untersuchung von @ptr
i       DAT     0                       ; SchleifenzÑhler
round   DAT     0                       ; RundenzÑhler

start:
init:
        MOV     #progend-ptr,ptr        ; @ptr hinter Programmende setzen
search:
        CMP     #0,@ptr                 ; DAT 0 Åbergehen!
        JMP     l1
        JMP     found                   ; kein DAT 0
l1:
        ADD     #step,ptr
        JMP     search
found:
        CMP     friends,@ptr            ; bei Freund/Feind Kennung gelandet?
        JMP     skip                    ; wenn ja: ptr neu aufsetzen
;
;       das was wir gefunden haben, wird jetzt etwas nÑher untersucht...
;
        MOV     ptr>,first              ; falls sich aufeinanderfolgende
        CMP     first,@ptr              ; Felder nicht unterscheiden:
        JMP     found                   ; in Einzelschritten weitergehen
        CMP     #0,@ptr
        JMP     l1                      ; war wohl nichts
;
;       jetzt haben wir was interessantes entdeckt, was
;       vielleicht ein Programm sein kînnte
;
        MOV     #10,i                   ; soviel zerstîren wir
destroy:
        MOV     #0,ptr>                 ; wir Åberschreiben's mit 0
        DJN     destroy,i
        JMP     search                  ; auf ein Neues...
;
;       damit unser Raster nicht immer dieselben Punkte erreicht,
;       setzen wir ptr fuer die nÑchste Runde etwas anders auf
;
skip:
        MOV     #progend-ptr,ptr
        ADD     #1,round
        CMP     #step,round             ; round=round % step
        MOV     #0,round
        ADD     round,ptr
        JMP     search
progend:

