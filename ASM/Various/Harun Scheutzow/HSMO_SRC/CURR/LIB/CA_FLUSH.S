;INCLUDE-File for GEN-Assembler
;Cache Flush
;Include it at the position where to place the subroutine.
;Call subroutine directly from supervisormode or by macro from usermode.


user_cache_flush	MACRO
;Perform cache flush from user mode
	pea	ca_flush	;subroutine address
	move.w	#38,-(sp)
	trap	#14	;XBIOS Supexec
	addq.l	#6,sp
	ENDM


ca_flush:
;Callable only from supervisormode.
;Writes data caches back and invalidates instruction cache.
;Useful after code modifications.
;Not fast, but correct and ROM-able.
;in:   /
;out:  /
;kill: /
          move.l    d0,-(sp)
          move.l    a0,-(sp)
          move.l    $5a0,d0          ;Cookie Jar Zeiger
          beq.s     .ende            ;kein Cookie Jar -> keine Cachebehandlung
          movea.l   d0,a0
.such:    
          move.l    (a0),d0          ;Cookie-Name
          beq.s     .ende            ;Ende des Cookie Jar
          addq.l    #8,a0            ;vorsorglich nÑchster Cookie
          cmpi.l    #'_CPU',d0
          bne       .such
          move.w    -(a0),d0         ;_CPU-Cookie Wert Lowword
          cmpi.w    #20,d0
          bcs.s     .ende            ;<68020: kein CPU-Cache
          cmpi.w    #40,d0
          bcc.s     .vierzig         ;>=68040
;68020, 68030
          DC.w $4e7a,$0002          ;movec cacr,d0
          ori.w     #$0808,d0        ;clear data- and instructioncache
          DC.w $4e7b,$0002          ;movec d0,cacr
          bra.s     .ende
.vierzig: 
;68040, 68060  (zwei getrennte Befehle wegen alter 68040er Serien)
          DC.w $f478                ;cpusha dc  Datencache zurÅckschreiben
          DC.w $f498                ;cinva ic  Instructioncache lîschen
          nop       
.ende:    
          movea.l   (sp)+,a0
          move.l    (sp)+,d0
          rts       

