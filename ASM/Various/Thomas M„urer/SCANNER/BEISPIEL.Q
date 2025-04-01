 ; Programm zum probeweisen Einlesen und 
 ; Abbilden der Daten auf einen SM 124
 ; vom Handscanner Marstek M 105
 ;
 ; Assembler: Profimat (Data Becker),
 ;            relozierbar zu assemblieren.
 ;            Nicht ausdrÅcklich mit einem Ex-
 ;            tender versehene Operatoren be-
 ;            ziehen sich auf den Datentyp 
 ;            "Wort".  
 ;
 ; Autor: Thomas MÑurer, Duisburger
 ; Str. 296, W-42 OB 1
 ;
 ; Stand: 2.2.1992

         text

         ; Auflîsung eingeben

eingabe  pea    info(pc)   ; GEMDOS-PRINT-LINE
         move   #9,-(sp)               
         trap   #1                    
         addq.l #6,sp
         move   #1,-(sp)   ; CONIN
         trap   #1
         addq.l #2,sp
         cmpi.b #'1',d0    ; öberprÅfung auf
         bcs    eingabe    ; BereichsÅberschrei-
         cmpi.b #'5',d0    ; tung bei der Ein-
         bcc    eingabe    ; gabe.
         andi   #$f,d0     ; Zahlwert maskieren
         move   d0,d7      ; und sichern.

         lea    jtable(pc),a0 ; Anzahl der    
         subq   #1,d0         ; Schrottbytes in 
         move.b 0(a0,d0),d0   ; einem Datenpaket
         move   d0,datajump   ; aus Tabelle, ab-
                              ; hÑngig von der
                              ; Auflîsung.

         pea    meld(pc)   ; Meldung ausgeben           
         move   #9,-(sp)   ; GEMDOS
         trap   #1         ; PRINT-
         addq.l #6,sp      ; LINE
         clr.l  -(sp)      ; Supervisormodus
         move   #$20,-(sp) ; modus einschalten
         trap   #1                         
         addq.l #6,sp
         move.l d0,ssp_save
         move   sr,save_sr ; SR retten 
         ori    #$700,sr   ; Interrupts aus,
                           ; die wÅrden hier nur 
                           ; stîren.

 ; Register vorbesetzen:

 ; A6    : Scanner CR
 ; A5    : Scanner Read data/status
 ; A4    : Schreibzeiger VRAM
 ; d1    : 8, fÅr NOT BUSY

         lea    $fb3000,a6
         lea    $fafffe,a5
         moveq  #8,d1
         move.l $44e,a4    ; logical screenbase
         move   #80,d3     ; Bildschirm-Byte-
                           ; breite des SW-
                           ; Monitors.
         moveq  #51,d0     ; Scanline-Breite
                           ; Breite in Bytes bei
                           ; 100 dpi.
         mulu   d7,d0      ; * Auflîsung / 100
                           ; = verwertbarer An-
                           ; teil der Scanline
                           ; in Bytes.
         cmpi   #81,d0     ; Mehr als 80 Bytes/
         bcs.s  ok         ; Scanline sind nicht
         moveq  #80,d0     ; darstellbar.
ok       sub    d0,d3      ; -gewÅnschte Breite
                           ;  des Bildes (Bytes)
                           ; = Differenz zum 
                           ;   nÑchsten Zeilen-
                           ;   anfang.

         subq   #1,d0      ; fÅr DBRA
         move   d0,b_breite
         move   #399,line_num  ; 400 Zeilen

         move   $fb2000,d0 ; Scanner ein,
                           ; d0: Schrott.
         move   line_num,d6 ; Anzahl der zu 
                            ; scannenden Linien.

         ; Es folgen nun die elementaren
         ; Lesestrukturen
 
cr       move   (a6),d0    ; CR auf Scanner aus- 
                           ; geben, d0: Schrott.
first_rd move   (a5),d0    ; Das erste Datenbyte
         btst   d1,d0      ; der jeweiligen Scan-
         beq    first_rd   ; line ist Schrott.
         moveq  #20,d4     ; Scanner muû sich 
first_wt dbra   d4,first_wt ; erst einmal "beru-
                           ;  higen".
         move   b_breite,d7 ; Bytebreite der 
                           ; Scanline exclusive
                           ; Schrottbytes   
waitbusy move   datajump(pc),d4 ; Anzahl der
                           ; Schrottbytes in  
                           ; jedem Datenpaket
tstbusy  move   (a5),d0    ; Datenregister
         btst   d1,d0
         beq    tstbusy    ; Scanner busy
         dbra   d4,tstbusy ; war Schrott, also
                           ; noch einmal   
         not    d0 ; verwertbares Byte des Daten-
                   ; pakets invertieren, da Weiû 
                   ; vom Scanner einem gesetzten 
                   ; Bit entspricht, bei Atari 
                   ; dies aber einen schwarzen 
                   ; Punkt erzeugt.
         move.b d0,(a4)+ ; Ab in den Bildschirm
         dbra   d7,waitbusy ; NÑchstes Datenpaket
         adda   d3,a4 ; Differenz zur nÑchsten
                      ; Bildschirmzeile ergÑnzen.
wait_le  btst   #1,(a5)    ; Warten auf das Ende
         beq    wait_le    ; der Scannerzeile.
         dbra   d6,cr      ; zur nÑchsten Zeile



         move   $fb0000,d0 ; Scanner aus.
         move   save_sr(pc),sr ; Statusregister 
                               ; restaurieren
         move.l ssp_save(pc),-(sp)  ; Supervisor-
         move   #$20,-(sp)          ; modus
         trap   #1                  ; ausschalten
         addq.l #6,sp
         clr    -(sp)          ; GEMDOS TERM
         trap   #1

         data
info     dc.b  $1b,'E' ; clear screen
         dc.b  'Scannen mit Marstek M 105 in '
         dc.b  'allen 4 Auflîsungsstufen',$d,$a
         dc.b  '-------------------------------'
         dc.b  '----------------------',$d,$a,$a
         dc.b  'Auflîsung eingeben:',$d,$a,$a
         dc.b  '    (1)00 dpi',$d,$a
         dc.b  '    (2)00 dpi',$d,$a
         dc.b  '    (3)00 dpi',$d,$a
         dc.b  '    (4)00 dpi',$d,$a,0
meld     dc.b  $1b,'E' ; clear screen
         dc.b  'Vor dem Scannen bitte die einge'
         dc.b  'stellte Auflîsung am Scanner '
         dc.b  'selbst ÅberprÅfen.',$d,$a
         dc.b  'Sie muû mit der gerade eingege'
         dc.b  'benen Åbereinstimmen.',$d,$a,$a
         dc.b  'Es kann losgehen!',0
jtable   dc.b   3,1,0,0

         bss
datajump ds.w  1 ; Anzahl der Schrottbytes je
                 ; Datenpaket
ssp_save ds.l  1 ; alter Stackpointer
save_sr  ds.w  1 ; altes Statusregister
b_breite ds.l  1 ; tatsÑchliche Bildbreite
line_num ds.l  1 ; Anzahl der Bildzeilen

         end


