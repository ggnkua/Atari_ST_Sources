;nette Druckroutine, wird mit bsr oder jsr aufgerufen und druckt
;den nullterminierten String direkt hinter dem (b/j)sr, kehrt dahinter zurck
;Bercksichtigt natrlich, da 68000 Befehle nur von geraden Adressen frit
;kill: D0-D2, A0-A2
prints:   
          move.l    (sp),-(sp)
          move.w    #9,-(sp)
          trap      #1               ;GEMDOS Cconws
          addq.l    #6,sp
          movea.l   (sp)+,a0
.weiter:  tst.b     (a0)+
          sne       d0               ;0 wenn 0, $FF sonst
          and.b     (a0)+,d0         ;ein Byte aus dem WORD =0 --> Stringende
          bne       .weiter
          jmp       (a0)

