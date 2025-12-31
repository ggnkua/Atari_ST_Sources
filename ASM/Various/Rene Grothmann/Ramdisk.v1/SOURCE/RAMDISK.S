          .LIST 

; RAM-Disk als Default mit zunÑchst fester Grîûe von 128 KByte installiert
; auf D:.

gemdos    = 1
xbios     = 14
bios      = 13

ptermres  = $31
superexec           = 38
malloc    = 72
mfree     = 73
cconws    = 9
cconin    = 1
cconrs    = 10
mshrink   = 74
fcreate   = 60
fopen     = 61
fclose    = 62
fread     = 63
fwrite    = 64
fsetdta   = 26
fsfirst   = 78
fsnext    = 79
dsetdrv   = 14
dsetpath  = 59

kbshift   = 11

drvbits   = $4c2
hdvbpb    = $472
hdvrw     = $476
hdvmed    = $47e

resvalid  = $426
resvector           = $42a
phystop   = $42e

buserror  = 8

magic1    = $15051956

EOF       = -1
EOLN      = -2

          .TEXT 

; ***** Defaultparameter *****

          bra       start
          .DC.b 'xbrarram'
rdsizef:  .DC.w 128 ; Defaultgroesse
rdnumf:   .DC.w 3   ; Defaultlaufwerk
rdreset:  .DC.w 1   ; Defaultmaessig resetfest
paramflag:          
          .DC.w 0
inffile:  .DC.b 'RAMDISK.INF',0,0,0,0,0
          .EVEN 
magic2:   .DC.l $11021959
protect:  .DC.l 0
reset:    .DC.w 0
printflag:          .DC.w 1

; ***** Programmstart *****

; Speicherbedarf ausrechnen
start:    
          movea.l   4(sp),a5
          move.l    12(a5),d6
          add.l     20(a5),d6
          add.l     28(a5),d6
          addi.l    #$500,d6
          move.l    d6,size

          movea.l   #stack,sp

          move.l    #meldstr,d0
          bsr       print

; Berechne Defaultwerte fÅr Ramdisk
          move.w    rdsizef,rdsize
          move.w    rdnumf,rdnum
          move.w    rdnum,d0
          moveq.l   #1,d1
          lsl.l     d0,d1
          move.l    d1,rdbit
          move.w    rdreset,resetflag

; Speicherplatz freigeben
          move.l    d6,-(sp)
          move.l    a5,-(sp)
          clr.w     -(sp)
          move.w    #mshrink,-(sp)
          trap      #gemdos
          lea.l     12(sp),sp

; Testen, ob Ramdisk schon hinter phystop initialisiert wurde
          pea       testram
          move.w    #superexec,-(sp)
          trap      #xbios
          addq.l    #6,sp
          tst.w     sucheflag
          bne       initdone

; Bei rechter Shifttaste Parameter einlesen
          tst.w     paramflag
          bne       doparam
          move.w    #-1,-(sp)
          move.w    #kbshift,-(sp)
          trap      #bios
          addq.l    #4,sp
          btst      #0,d0
          beq       noparam
doparam:  
          bsr       param
          bra       noinf
noparam:  

; Eventuell Parameter von RAMDISK.INF einlesen
          bsr       getinf
noinf:    

; Bei Groesse 0 nichts tun
          tst.w     rdsize
          beq       quit

; Speicherplatz besorgen
          bsr       getstart
          tst.l     d0
          beq       error

; in Supervisormodus Vektoren verbiegen
initdone: 
          move.l    adrinstall,-(sp)
          move.w    #superexec,-(sp)
          trap      #xbios
          addq.l    #6,sp

; Evtl. Dateien auf Ramdisk kopieren
          tst.w     infflag
          beq       nocopy
          bsr       copy

; Evtl. RAMDISK.INF schliessen
          bsr       closeinf
nocopy:   

; Resident halten
          tst.w     sucheflag ; Ramdisk hinter Phystop?
          bne       rdest
          tst.w     resetflag ; Ramdisk resetfest?
          beq       rescont
          pea       resinst
          move.w    #superexec,-(sp)
          trap      #xbios
          addq.l    #6,sp
          tst.w     reset
          bne       doreset
rescont:  
          clr.w     -(sp)
          move.l    size,-(sp)
          move.w    #ptermres,-(sp)
          trap      #gemdos

; Konnte Ramdisk nicht installieren
error:    
          move.l    #errormeld,-(sp)
          move.w    #cconws,-(sp)
          trap      #gemdos
          addq.l    #6,sp
          move.w    #cconin,-(sp)
          trap      #gemdos
          addq.l    #2,sp
          move.l    #notinststr,d0
          bsr       print

; Nicht resident halten
rdest:    
          move.l    #eststr,d0
          bsr       print
quit:     
          clr.w     -(sp)
          trap      #gemdos

; Reset auslîsen
doreset:  
          pea       knall
          move.w    #superexec,-(sp)
          trap      #xbios
knall:    
          movea.l   0,sp
          movea.l   4,a0
          jmp       (a0)

; ***** Installationsunterprogramm *****

; Resetvektor verbiegen
resinst:  
          move.l    resvalid,oldvalid
          move.l    resvector,oldvector
          move.l    #$31415926,resvalid
          move.l    #newvector,resvector
          rts       

; ***** Suche Ramdisk hinter phystop *****

testram:  
          move.l    buserror,oldbus
          move.l    #newbus,buserror
          move.l    phystop,d0
          andi.l    #$ffffff00,d0
          movea.l   d0,a0
suche:    
          cmpi.l    #magic1,(a0)
          bne       nicht1
          move.l    4(a0),d1
          cmp.l     magic2,d1
          beq       ja1
nicht1:   
          adda.l    #$100,a0
          move.l    a0,d0
          bpl       suche
busexit:  
          clr.w     sucheflag
          move.l    oldbus,buserror
          move.l    #install,adrinstall
          rts       

ja1:      
          move.l    oldbus,buserror
          move.w    #1,sucheflag
          move.l    a0,d0
          addi.l    #(install-rdrstart),d0
          move.l    d0,adrinstall
          rts       

newbus:   
          cmpa.l    2(sp),a0  ; zeigt bei 68000 auf error acces addres
          bne       l68010
          addq.l    #8,sp
          move.l    #busexit,2(sp)
l68010:   
          rte       

; ***** besorge Speicherplatz *****

getstart: 
          move.w    rdsize,d3
          mulu.w    #1024,d3
          move.l    d3,-(sp)
          move.w    #malloc,-(sp)
          trap      #gemdos
          addq.l    #6,sp
          move.l    d0,rdstart
          move.l    d0,d1
          beq       getstartdone
          add.l     d3,d1
          move.l    d1,rdend
          movea.l   rdstart,a0
rdclear:  
          clr.l     (a0)+
          cmp.l     a0,d1
          bgt.s     rdclear
getstartdone:       
          rts       

; ***** Ramdiskroutinen *****

rdrstart: 

kmagic1:  .DC.l magic1
kmagic2:  .DC.l 0

rdstart:  .DS.l 1
rdend:    .DS.l 1
drvnum:   .DS.w 1
rdbit:    .DS.l 1

install:  
; Drive anmelden
          move.l    drvbits,d0
          or.l      rdbit(pc),d0
          move.l    d0,drvbits

; Vektoren merken
          lea.l     oldbpb(pc),a0
          move.l    hdvbpb,(a0)
          lea.l     oldrw(pc),a0
          move.l    hdvrw,(a0)
          lea.l     oldmed(pc),a0
          move.l    hdvmed,(a0)

; neue Vektoren einsetzen
          lea.l     newbpb(pc),a0
          move.l    a0,hdvbpb
          lea.l     newrw(pc),a0
          move.l    a0,hdvrw
          lea.l     newmed(pc),a0
          move.l    a0,hdvmed
          rts       

          .DC.b 'xbrarram'
oldbpb:   .DS.l 1

newbpb:   
          move.w    4(sp),d0
          movea.l   oldbpb(pc),a0
          lea.l     rdbpb(pc),a1
          bra.s     chkdriv

          .DC.b 'xbrarram'
oldrw:    .DS.l 1

newrw:    
          move.w    14(sp),d0
          movea.l   oldrw(pc),a0
          lea.l     rdrw(pc),a1
          bra.s     chkdriv

          .DC.b 'xbrarram'
oldmed:   .DS.l 1

newmed:   
          move.w    4(sp),d0
          movea.l   oldmed(pc),a0
          lea.l     rdmed(pc),a1

chkdriv:  
          cmp.w     rdnum(pc),d0
          bne.s     olddisk
          jmp       (a1)
olddisk:  
          jmp       (a0)

rdrw:     
          move.w    10(sp),d1
          mulu.w    #$20,d1
          movea.l   6(sp),a0
          move.l    a0,d2
          movea.l   rdstart(pc),a1
          move.w    $c(sp),d0
          mulu.w    #$200,d0
          adda.l    d0,a1
          tst.w     4(sp)
          bne.s     rdwrite
          exg.l     a1,a0
          bra.s     dorw
rdwrite:            ; Schreiben auf die Ramdisk
          asl.l     #4,d1
          move.l    a1,d0
          add.l     d1,d0
          asr.l     #4,d1
          cmp.l     rdend(pc),d0
          bgt.s     werror

dorw:     btst      #0,d2
          bne.s     odd
          subq.l    #1,d1

tlong:    
          move.l    (a0)+,(a1)+
          move.l    (a0)+,(a1)+
          move.l    (a0)+,(a1)+
          move.l    (a0)+,(a1)+
          dbf       d1,tlong

rdmed:    clr.l     d0
          rts       
werror:   move.w    #-10,d0
          rts       

odd:      asl.l     #2,d1
          subq.l    #1,d1
tbyte:    
          move.b    (a0)+,(a1)+
          move.b    (a0)+,(a1)+
          move.b    (a0)+,(a1)+
          move.b    (a0)+,(a1)+
          dbf       d1,tbyte
          bra       rdmed

rdbpb:    
          lea.l     rambpb(pc),a0
          move.l    a0,d0
          rts       

rambpb:   
          .DC.w $0200,$0002,$0400,$0007,$0005,$0006,$0012
rdsize:   .DC.w 128
          .DC.w $0001

rdnum:    .DC.w 3

rdrend:   

; ***** Resetroutinen *****

          .DC.b 'xbrarram'
oldvector:          .DS.l 1

newvector:          
          move.l    phystop,d0
          cmp.l     rdstart,d0
          ble       resetdone
          movea.l   d0,a1
          move.w    rdsize,d1
          mulu.w    #1024,d1
          sub.l     d1,d0     ; d0 is Start of Copy
          move.l    d0,d1
          subi.l    #(rdrend-rdrstart),d1
          sub.l     protect,d1
          andi.l    #$fffff000,d1
          move.l    d1,phystop
          move.l    magic2,kmagic2
          movea.l   rdend,a0
          move.l    a1,rdend
          move.l    d0,rdstart
rette:              ; Kopiere Ramdisk
          move.l    -(a0),-(a1)
          cmp.l     a1,d0
          blt.s     rette
          lea.l     rdrstart,a0
          movea.l   d1,a1
rette1:             ; Kopiere Ramdiskroutinen
          move.l    (a0)+,(a1)+
          cmpa.l    #rdrend,a0
          blt.s     rette1

resetdone:          
          move.l    oldvalid,resvalid
          move.l    oldvector,resvector
          cmpi.w    #$9bcd,(a6)         ; Vorschlag aus ST Profibuch
          beq       oldtos
          jmp       (a6)
oldtos:   
          jmp       $24(a6)

; ***** Parameter einlesen *****

param:    
; Lies Ramdiskgroesse
          move.l    #sizestr,-(sp)
          move.w    #cconws,-(sp)
          trap      #gemdos
          addq.l    #6,sp
          bsr       input
          bsr       getsize
          tst.w     rdsize
          beq       paramdone

; Lies Ramdiskbuchstabe
          move.l    #letterstr,-(sp)
          move.w    #cconws,-(sp)
          trap      #gemdos
          addq.l    #6,sp
          bsr       input
          bsr       getletter

; Frage, ob Ramdisk resetfest sein soll
          move.l    #resetstr,-(sp)
          move.w    #cconws,-(sp)
          trap      #gemdos
          addq.l    #6,sp
          bsr       input
          bsr       getreset

paramdone:          
          rts       

; Inputroutine
input:    
          movea.l   #line,a0
          move.b    #16,(a0)
          move.l    a0,-(sp)
          move.w    #cconrs,-(sp)
          trap      #gemdos
          addq.l    #6,sp
          rts       

; Soll Ramdisk resetfest sein?
getreset: 
          move.w    #1,resetflag        ; Defaultwert
          movea.l   #line,a0
          tst.b     1(a0)
          beq       getrdone
          cmpi.b    #'n',2(a0)
          beq       notreset
          cmpi.b    #'N',2(a0)
          bne       getrdone
notreset: 
          clr.w     resetflag
getrdone: 
          rts       

; Lies Groesse ein
getsize:  
          movea.l   #line,a0
          move.b    1(a0),d0
          ext.w     d0
          beq       getsdone
          clr.w     d1
          clr.w     d3
getsloop: 
          move.b    2(a0,d3.w),d2
          subi.b    #'0',d2
          bmi       getsend
          cmpi.b    #9,d2
          bgt       getsend
          ext.w     d2
          mulu.w    #10,d1
          add.w     d2,d1
          addi.w    #1,d3
          cmp.w     d3,d0
          bgt       getsloop
getsend:  
          move.w    d1,rdsize
getsdone: 
          rts       

; Lies Buchstaben
getletter:          
          movea.l   #line,a0
          tst.b     1(a0)
          beq       getldone
          move.b    2(a0),d0
          ext.w     d0
          cmpi.w    #'a',d0
          bge       getlsmall
          subi.w    #'A',d0
          bra       getlcont
getlsmall:          
          subi.w    #'a',d0
getlcont: 
          cmpi.w    #15,d0
          bgt       getldone
          cmpi.w    #2,d0
          blt       getldone
          move.w    d0,rdnum
          moveq.l   #1,d2
          lsl.l     d0,d2
          move.l    d2,rdbit
getldone: 
          rts       

; ***** Einlesen der RAMDISK.INF Datei *****

getinf:   
; Oeffnen
          move.w    #0,-(sp)  ; nur lesen
          pea       inffile
          move.w    #fopen,-(sp)
          trap      #gemdos
          addq.l    #8,sp
          tst.w     d0
          bmi       notexinf
          move.w    d0,infhandle
          move.l    #infstr,d0
          bsr       print
          move.w    #1,infflag
getiloop: 
          bsr       getline
          cmpi.l    #'SIZE',command
          bne       cont1
          bsr       getsize
          bra       getiloop
cont1:    
          cmpi.l    #'DISK',command
          bne       cont2
cont3:    
          bsr       getletter
          bra       getiloop
          cmpi.l    #'DISC',command
          beq       cont3
cont2:    
          cmpi.l    #'RESE',command
          bne       cont4
          bsr       getreset
          bra       getiloop
cont4:    
          cmpi.l    #'LOAD',command
          beq       getidone
          tst.l     command
          bne       getiloop
getidone: 
          rts       

notexinf: 
          clr.w     infflag
          rts       

; ***** Zeile von RAMDISK.INF einlesen *****
; Die Zeile soll das Format haben:
; KOMM = PARAMETER

getline:  
; Loesche zunaechst Kommando und Kommandoparameter
          clr.l     command
          clr.w     line      ; zweites Byte in line ist Zaehler
          move.l    #line,d0
          addq.l    #2,d0
          move.l    d0,nextpos
          move.l    #command,nextcom
blankloop:                    ; Ueberlies fuehrende Leerzeichen
          bsr       getone
          tst.w     d0
          bmi       skipline
          cmpi.w    #' ',d0
          beq       blankloop
commandloop:                  ; Lesen der ersten vier Buchstaben als Kommando
          tst.w     d0
          bmi       skipline  ; EOF oder EOLN
          movea.l   nextcom,a0
          move.b    d0,(a0)+
          move.l    a0,nextcom
          cmpa.l    #(command+4),a0
          bge       equloop
          bsr       getone
          bra       commandloop
equloop:            ; Lesen bis zum =
          bsr       getone
          tst.w     d0
          bmi       skipline  ; Zeile oder File nach Kommando zuende
          cmpi.w    #'=',d0
          bne       equloop
equloop1:           ; Ueberlesen von Leerzeichen
          bsr       getone
          tst.w     d0
          bmi       linedone  ; Keine Parameter
          cmpi.w    #' ',d0
          beq       equloop1
lineloop:           ; Einlesen der Kommandoparameter
          cmpi.w    #EOF,d0
          beq       linedone
          cmpi.w    #EOLN,d0
          beq       linedone
          movea.l   nextpos,a0
          move.b    d0,(a0)+
          move.l    a0,nextpos
          lea.l     line,a0
          addi.b    #1,1(a0)
          bsr       getone
          cmpi.b    #64,1(a0)
          blt       lineloop
skiprest:           ; Zeile war zu lang
          tst.w     d0
          bmi       linedone
          bsr       getone
          bra       skiprest
linedone: 
          movea.l   nextpos,a0
          clr.b     (a0)
          rts       
skipline: 
          cmpi.w    #EOLN,d0
          beq       getline
          clr.l     command
          rts       

getone:             ; Buchstaben einlesen und zu Grossbuchstaben machen
          pea       puffer
          move.l    #1,-(sp)
          move.w    infhandle,-(sp)
          move.w    #fread,-(sp)
          trap      #gemdos
          lea.l     12(sp),sp
          tst.l     d0
          bmi       eof
          beq       eof
          move.b    puffer,d0
          ext.w     d0
          cmpi.w    #13,d0
          beq       eoln
          cmpi.w    #10,d0
          beq       blank
          cmpi.w    #'a',d0
          blt       getoneok
          cmpi.w    #'z',d0
          bgt       getoneok
          subi.w    #('a'-'A'),d0
getoneok: 
          rts       
eof:      
          move.w    #EOF,d0
          rts       
eoln:     
          move.w    #EOLN,d0
          rts       
blank:    
          move.w    #' ',d0
          rts       

; ***** Schliessen von RAMDISK.INF *****
closeinf: 
          tst.w     infflag
          beq       closedone
          move.w    infhandle,-(sp)
          move.w    #fclose,-(sp)
          trap      #gemdos
          addq.l    #4,sp
closedone:          
          rts       

; ***** Kopieren von Dateien *****

copy:     
; DTA setzen
          pea       dta
          move.w    #fsetdta,-(sp)
          trap      #gemdos
          addq.l    #6,sp
copyloop: 
          tst.l     command
          beq       copydone
          move.l    #kopstr,d0
          bsr       print
          tst.b     line+1
          beq       copycont
          cmpi.l    #'LOAD',command
          bne       copycont
; Setze Diskette und Pfad, speichere Filenamen
          bsr       setpath
; Suche File
          clr.w     -(sp)
          move.l    filename,-(sp)
          move.w    #fsfirst,-(sp)
          trap      #gemdos
          addq.l    #8,sp
          tst.w     d0
          bmi       notfound
; open file
loadit:   
          move.l    #dname,d0
          bsr       print
          move.l    #commastr,d0
          bsr       print
          move.w    #0,-(sp)
          move.l    #dname,-(sp)
          move.w    #fopen,-(sp)
          trap      #gemdos
          addq.l    #8,sp
          tst.w     d0
          bmi       copycont
          move.w    d0,copyhandle
; Besorge Speicherplatz in der LÑnge des Files
          move.l    dlaenge,-(sp)
          move.w    #malloc,-(sp)
          trap      #gemdos
          addq.l    #6,sp
          tst.l     d0
          beq       closeit
          move.l    d0,copyadr
; Lies File in Speicher
          move.l    copyadr,-(sp)
          move.l    dlaenge,-(sp)
          move.w    copyhandle,-(sp)
          move.w    #fread,-(sp)
          trap      #gemdos
          lea.l     12(sp),sp
; Schliesse File
closeit:  
          move.w    copyhandle,-(sp)
          move.w    #fclose,-(sp)
          trap      #gemdos
          addq.l    #4,sp
; Setze Drive auf Ramdisk
          move.w    rdnum,-(sp)
          move.w    #dsetdrv,-(sp)
          trap      #gemdos
          addq.l    #4,sp
; Oeffne Output Datei
          clr.w     -(sp)
          move.l    #dname,-(sp)
          move.w    #fcreate,-(sp)
          trap      #gemdos
          addq.l    #8,sp
          tst.w     d0
          bmi       copyerror
          move.w    d0,copyhandle
; Schreibe File auf Ramdisk
          move.l    copyadr,-(sp)
          move.l    dlaenge,-(sp)
          move.w    copyhandle,-(sp)
          move.w    #fwrite,-(sp)
          trap      #gemdos
          lea.l     12(sp),sp
          cmp.l     dlaenge,d0
          bne       copyerror
; Schliesse File wieder
          move.w    copyhandle,-(sp)
          move.w    #fclose,-(sp)
          trap      #gemdos
          addq.l    #4,sp
; Gib Speicher frei
          move.l    copyadr,-(sp)
          move.w    #mfree,-(sp)
          trap      #gemdos
          addq.l    #6,sp
; Setze Drive zurueck
          move.w    aktnum,-(sp)
          move.w    #dsetdrv,-(sp)
          trap      #gemdos
          addq.l    #4,sp
; Suche nach noch einem File mit gleicher Maske
          move.w    #fsnext,-(sp)
          trap      #gemdos
          addq.l    #2,sp
          tst.w     d0
          bge       loadit
copycont: 
          bsr       getline
          bra       copyloop
copydone: 
          rts       
notfound: 
          move.l    #notfstr,d0
          bsr       print
          bra       copycont
copyerror:          
          move.l    #copyestr,d0
          bsr       print
          rts       

; ***** Setze Pfad *****
; Der komplette Zugriffspfad liegt in line+2, Laenge in line+1
setpath:  
          move.b    line+1,d0
          ble       setpdone
; Evtl. Diskette setzen
          move.b    line+3,d0
          cmpi.b    #':',d0
          bne       nodisk
          move.b    line+2,d0
          subi.b    #'A',d0
          ext.w     d0
          move.w    d0,aktnum
          move.w    d0,-(sp)
          move.w    #dsetdrv,-(sp)
          trap      #gemdos
          addq.l    #4,sp
          bra       diskdone
nodisk:   
          clr.w     aktnum
          move.w    #0,-(sp)
          move.w    #dsetdrv,-(sp)
          trap      #gemdos
          addq.l    #4,sp
diskdone: 
          move.b    line+1,d0
          ext.w     d0
          ext.l     d0
          lea.l     line+2,a0
          adda.l    d0,a0
          movea.l   #(filenp+64),a1
          clr.w     -(a1)
setpnameloop:       
          move.b    -(a0),d0
          move.b    d0,-(a1)
          cmpi.b    #'\',d0
          beq       nameend
          cmpi.b    #':',d0
          beq       nameend
          cmpa.l    #(line+1),a0
          bgt       setpnameloop
nameend:  
          move.l    a1,d1
          addq.l    #1,d1
          move.l    d1,filename
          cmpa.l    #(line+1),a0
          beq       nopath
          cmpi.b    #'\',d0
          bne       nopath
          clr.b     1(a0)
          clr.b     2(a0)
          bra       path
nopath:   
          pea       defaultpath
          bra       path1
; Pfad setzen
path:     
          pea       line+2
path1:    
          move.w    #dsetpath,-(sp)
          trap      #gemdos
          addq.l    #6,sp
setpdone: 
          rts       


; ***** Gib String aus *****
print:    
          tst.w     printflag
          beq       noprint
          move.l    d0,-(sp)
          move.w    #cconws,-(sp)
          trap      #gemdos
          addq.l    #6,sp
noprint:  
          rts       


          .DATA 

errormeld:          
          .DC.b 13,10,'Ramdisk konnte nicht installiert werden.',13,10,0,0
          .EVEN 
sizestr:  
          .DC.b 13,10,'Grîûe (Kbyte): ',0,0
          .EVEN 
letterstr:          
          .DC.b 13,10,'Buchstabe (a,...):           ',0,0
          .EVEN 
resetstr: 
          .DC.b 13,10,'Reset resident (y/n):     ',0,0
          .EVEN 
meldstr:  
          .DC.b 13,10,'Ramdisk von R. Grothmann',0,0
          .EVEN 
notinststr:         
          .DC.b 13,10,'Ramdisk konnte nicht installiert werden',0,0
          .EVEN 
copystr:  
          .DC.b ' kopiert',0,0
          .EVEN 
crstr:    
          .DC.b 13,10,0,0
infstr:   
          .DC.b 13,10,'RAMDISK.INF gefunden',0,0
          .EVEN 
kopstr:   
          .DC.b 13,10,'LOAD = ',0,0
          .EVEN 
notfstr:  
          .DC.b ' nicht gefunden',0,0
          .EVEN 
copyestr: 
          .DC.b 13,10,'Copy Fehler !!!',0,0
          .EVEN 
commastr: 
          .DC.b ',',0,0
          .EVEN 
eststr:   
          .DC.b 13,10,'Ramdisk wiedergefunden.',0,0
          .EVEN 

defaultpath:        
          .DC.b '\',0,0
          .EVEN 

          .BSS 

dta:      .DS.b 21
dattrib:  .DS.b 1
dtime:    .DS.w 1
ddate:    .DS.w 1
dlaenge:  .DS.l 1
dname:    .DS.b 14

oldvalid: .DS.l 1
oldbus:   .DS.l 1
adrinstall:         .DS.l install

size:     .DS.l 1

flag:     .DS.w 1
sucheflag:          .DS.w 1
resetflag:          .DS.w 1
infflag:  .DS.w 1

infhandle:          .DS.w 1
copyhandle:         .DS.w 1

command:  .DS.l 1
line:     .DS.b 70
filenp:   .DS.b 70
puffer:   .DS.b 16
aktnum:   .DS.w 1

nextcom:  .DS.l 1
nextpos:  .DS.l 1

copyadr:  .DS.l 1
filename: .DS.l 1

          .DS.l $100
stack:    

          .END 

