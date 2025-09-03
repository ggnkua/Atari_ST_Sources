          .GLOBL emul,drivenum,size,readonly
          .GLOBL althelp,instal,remov,infos,clear,overhead

          .TEXT 

          bra     instal

          .DC.b "xbradrvi"
emul:     .DC.w 0
drivenum: .DC.w 8
size:     .DC.w $100
readonly: .DC.w 1
instalit: .DC.w 1
althelp:  .DC.w 1
overhead: .DC.w $110

drives    equ $4c2
bpb       equ $472
rw        equ $476
med       equ $47e
dumpvec   equ $502

instal:   
;** compute drivebit ***
          move.w    drivenum,d0
          move.l    #1,d1
          asl.l     d0,d1
          move.l    d1,drivebit
;** compute infosize ***
          move.l    infos,d0
          move.w    size,d1
          ext.l     d1
          asl.l     #2,d1
          add.l     d1,d0
          move.l    d0,infosend
          move.l    d0,buffer

          move.l    #setvec,-(sp)
          move.w    #$26,-(sp)
          trap      #14       ; Supervisormodus
          addq.l    #6,sp

;** clear buffer ***
          jsr       clear
          move.w    instflag,d0
          rts       

;******* Pointer installation **********

setvec:   
          movea.l   bpb,a0
          move.l    kenner,d0
          cmp.l     -8(a0),d0 ; schon installiert ?
          bne       notinstalled
          move.l    kenner+4,d0
          cmp.l     -4(a0),d0
          beq       installed
notinstalled:
          move.l    $4c2,d0
          or.l      drivebit,d0
          move.l    d0,drives ; install my disk
          move.l    bpb,oldbpb
          move.l    rw,oldrw
          move.l    med,oldmed
          move.l    #newbpb,bpb
          move.l    #newrw,rw
          move.l    #newmed,med
          tst.w     althelp
          beq       noalthelp
          move.l    dumpvec,olddump
          move.l    #hardcopy,dumpvec
noalthelp:          
          move.w    #-1,instflag
          rts       
installed:          
          clr.w     instflag
          rts       

;******* remove drive *********

remov:    
          move.l    #remvec,-(sp)
          move.w    #$26,-(sp)
          trap      #14       ; Supervisormodus
          addq.l    #6,sp

          move.w    instflag,d0
          rts       

remvec:   
          cmpi.l    #newbpb,bpb
          bne       rem1
          move.l    oldbpb,bpb
rem1:     
          clr.w     instflag
          cmpi.l    #newrw,rw
          bne       rem2
          move.w    #1,instflag
          move.l    oldrw,rw
rem2:     
          cmpi.l    #newmed,med
          bne       rem3
          move.l    oldmed,med
rem3:     
          cmpi.l    #hardcopy,dumpvec
          bne       rem4
          move.l    olddump,dumpvec
rem4:
		  move.l    drivebit,d0
		  eor.l     #-1,d0
		  and.l     drives,d0
		  move.l    d0,drives
          rts       

;****** New Bios Parameter Block Routine ********

          .DC.b "xbradrvi"
oldbpb:   .DC.l 1
newbpb:             ; Routine to transfer bios Parameter Block
          move.w    drivenum,d0
          cmp.w     4(sp),d0  		; My Drive ?
          bne       endbpb
          move.w    emul,4(sp)      ; Change to cached Drive !
          addi.w    #1,count		; count drive acces
          jsr		checkcount
endbpb:   
          movea.l   oldbpb,a0
          jmp       (a0)

;****** New Read/Write Routine ***********

kenner:   .DC.b "xbradrvi"
oldrw:    .DC.l 1
newrw:              ; Routine to read or write sector
          move.w    drivenum,d0
          cmp.w     14(sp),d0 ; my drive ?
          bne       notmine
          move.w    4(sp),d0
          btst      #0,d0     ; write ?
          bne       write
          move.w    10(sp),number
          move.w    12(sp),sector
          move.l    6(sp),destination
;** see if we have that sector already ***
lookup:   
          tst.w     number
          beq       endr
          bmi       endr
          movea.l   infos,a0
          move.w    sector,d0
search:   
          cmpi.w    #-1,(a0)
          beq       endsearch ; not found
          cmp.w     (a0),d0
          beq       found     ; found
          addq.l    #4,a0
          cmpa.l    infosend,a0
          bne       search
          bra       endsearch ; not found
found:    
          move.w    count,2(a0)
          addi.w    #1,count
          bsr       checkcount
;** copy it to destination ***
          move.l    a0,d0
          sub.l     infos,d0
          asl.l     #7,d0
          add.l     buffer,d0
          movea.l   d0,a0     ; a0 is addres of buffer
          movea.l   destination,a1
          move.w    #(512-1),d0
copyto:   
          move.b    (a0)+,(a1)+
          dbf       d0,copyto
          subi.w    #1,number
          addi.w    #1,sector
          addi.l    #512,destination
          bra       lookup    ; look if we have one more sector
;** we have no more sector ***
endsearch:          
;** read from disc ***
          move.w    number,10(sp)
          beq       ret       ; all sectors tranferred
          bmi       ret
          move.w    sector,12(sp)
          move.l    destination,6(sp)
          move.w    emul,14(sp)
          movea.l   oldrw,a0
          move.l    (sp)+,return
          jsr       (a0)
          tst.w 	d0
          beq		store
          move.l	return,-(sp)
          rts
;** Copy sectors from destination ***
store:    
          tst.w     number
          beq       ret
          bmi       ret
          movea.l   infos,a0
          move.l    a0,bestinfo
          move.w    2(a0),d0
;** look for free buffer and buffer with lowest count ***
searchfree:         
          cmpi.w    #-1,(a0)
          beq       freefound
          cmp.w     2(a0),d0
          blt       notbest
          move.w    2(a0),d0
          move.l    a0,bestinfo
notbest:  
          addq.l    #4,a0
          cmpa.l    infosend,a0
          bne       searchfree
          neg.w		d0
          add.w		count,d0
          cmp.w		overhead,d0
          bge		best1
          move.w	count,d0
          add.w		number,d0
          move.w	d0,count
		  bsr 		checkcount
		  bra		ret
best1:
          movea.l   bestinfo,a0
freefound:          
;** copy sector from destination
          move.w    sector,(a0)
          move.w    count,2(a0)
          addi.w    #1,count
          bsr       checkcount
          move.l    a0,d0
          sub.l     infos,d0
          asl.l     #7,d0
          add.l     buffer,d0
          movea.l   d0,a0     ; a0 is addres of buffer
          movea.l   destination,a1
          move.w    #(512-1),d0
copyfrom: 
          move.b    (a1)+,(a0)+
          dbf       d0,copyfrom
          subi.w    #1,number
          addi.w    #1,sector
          addi.l    #512,destination
          bra       store
ret:      
          movea.l   return,a0
          clr.l     d0
          jmp       (a0)
          
endr:     
          clr.l     d0
          rts       

;** write a sector to disc ***
write:    
          move.w    emul,14(sp)
          tst.w     readonly
          beq       dowrite
          jsr       clear
          move.l    #-13,d0
          rts       

;** not my disc ***
notmine:  
          move.w    14(sp),d0
          cmp.w     emul,d0
          bne       endrw
          move.w    4(sp),d0
          btst      #0,d0
          beq       endrw     ; reading
          jsr       clear     ; clear, if writing to emulated disc
          bra       endrw

;** do old read/write ***
endrw:    
          movea.l   oldrw,a0
          jmp       (a0)

;** write to a: and to cache simultanuously ***
dowrite:
          move.w    10(sp),number
          move.w    12(sp),sector
          move.l    6(sp),destination
;** lookup sectors in cache ***
searchcs:
          tst.w     number
          beq       endcs
          bmi       endcs
          movea.l   infos,a0
loopcs:
          cmpi.w    #-1,(a0)
          beq       notfoundcs ; cache end
          move.w    (a0),d0
          cmp.w     sector,d0
          beq       foundcs ; sector found
          addq.l    #4,a0
          cmpa.l    infosend,a0 ; cache end
          bne       loopcs
notfoundcs:
          addi.l    #512,destination
          addi.w    #1,sector
          subi.w    #1,number
          bra       searchcs
          
endcs:
          movea.l   oldrw,a0
          jmp       (a0)
          
;** sector found, write sector to cache ***
foundcs:
          move.l    a0,d0
          sub.l     infos,d0
          asl.l     #7,d0
          add.l     buffer,d0
          movea.l   d0,a0     ; a0 is addres of buffer
          movea.l   destination,a1
          move.w    #(512-1),d0
loopcs1:
          move.b    (a1)+,(a0)+
          dbf       d0,loopcs1
          bra       notfoundcs

;** clear buffer ***
clear:    
          movea.l   infos,a0
          tst.l		a0
          beq       endclr
          clr.w     count
loopclrw: 
          move.l    #-1,(a0)+
          cmpa.l    infosend,a0
          bne       loopclrw
endclr:   
          rts       

;** check count ***
checkcount:
		  tst.w 	count
		  bmi		overfl         
          cmpi.w    #30000,count
          ble       endcheck  ; no overflow
overfl:
          movem.l   d0/a0,-(sp)
          move.w    #15000,count
          movea.l   infos,a0
checkloop:          
          move.w    2(a0),d0
          asr.w     #1,d0
          move.w    d0,2(a0)
          addq.l    #4,a0
          cmpa.l    infosend,a0
          bne       checkloop
          movem.l   (sp)+,d0/a0
endcheck: 
          rts       

;***** Media Change Routine **************

          .DC.b "xbradrvi"
oldmed:   .DC.l 1
newmed:             ; Routine to indicate Media Change
          move.w    drivenum,d0
          cmp.w     4(sp),d0
          bne       domed
          tst.w		count
          beq		medchange
          clr.l		d0
          rts
medchange:
          move.l	#2,d0
          rts       
domed:    
          movea.l   oldmed,a0
          jmp       (a0)

;****** harcopy routine *******

          .DC.b "xbrardrv"
olddump:  .DC.l 1
hardcopy: 
          movea.l   infos,a0
          cmpi.w    #-1,(a0)
          beq       isclear
          jmp       clear
isclear:  
          movea.l   olddump,a0
          jmp       (a0)

;***** Data **********

          .EVEN 

infos:    .DC.l 1
infosend: .DC.l 1
buffer:   .DC.l 1
drivebit: .DC.l 1
instflag: .DC.w 1
number:   .DC.w 1
sector:   .DC.w 1
destination:        .DC.l 1
return:   .DC.l 1
count:    .DC.w 1
bestinfo: .DC.l 1

          .END 

