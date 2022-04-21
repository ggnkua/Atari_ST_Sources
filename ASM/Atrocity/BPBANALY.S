     ;** BPB-Analysator  S.D. **

run:
     move.l  #prompt,d0
     bsr     pmsg        ;Afficher Prompt 
     bsr     getkey      ;saisie des lecteurs A-D
     cmp.b   #'q',d0     ;Quit ?
     beq     quit        ;oui => Desktop
     move    d0,d6       ;Sauvegarder caractŠre
     bsr     pcrlf       ;Afficher CR 

     sub.b   #'a',d6     ;Transformer valeur
     bmi     run         ;Mauvaise saisie
     cmp.b   #3,d6
     bgt     run         ;mauvaise saisie

     move    d6,-(sp)    ;Device-Nr.
     move    #7,-(sp)
     trap    #13         ;GETBPB-Function
     addq.l  #4,sp

     tst.l   d0
     beq     run         ;Erreur !
     move.l  d0,a5       ;Sauvegarder BPB-Adress

     bsr     pnext
     move.l  #bps,d0
     bsr     pline       ;"octets par secteur"

     bsr     pnext
     move.l  #spc,d0
     bsr     pline       ;"Secteurs par Cluster"

     bsr     pnext
     move.l  #bpc,d0
     bsr     pline       ;"Octets par Cluster"

     bsr     pnext
     move.l  #dirsec,d0
     bsr     pline       ;"Secteur-Directory"

     bsr     pnext
     move.l  #fatsec,d0
     bsr     pline       ;"Secteurs-FAT"

     bsr     pnext
     move.l  #fat2s,d0
     bsr     pline       ;"Start-Sector du 2. FAT"

     bsr     pnext
     move.l  #datsec,d0
     bsr     pline       ;"Start-Sector des donn‚es"

     bsr     pnext
     move.l  #datc,d0
     bsr     pline       ;"cluster de donn‚es"

     move    #'$',d0
     bsr     pchar       ;"$" Afficher
     move    #12,d0      ;R‚cup‚rer 12 Bit 
     btst    #0,(a5)     ;correct ?
     beq     bits12      ;oui
     move    #16,d0      ;sinon 16 Bit
bits12:
     bsr     phexbyt
     move.l  #fatbit,d0
     bsr     pline       ;"Bits par donn‚e FAT"

     bra     run         ;fini => red‚marrage

quit:                    ; Retour au Desktop
     clr     -(sp)
     trap    #1

getkey:                  ;Get Key -> D0
     move    #1,-(sp)
     trap    #1
     and.l   #$ff,d0
     addq.l  #2,sp
     rts

pline:                   ;Print Line/CR
     bsr     pmsg
pcrlf:                   ;Print CR,LF
     move    #10,d0
     bsr     pchar
     move    #13,d0
pchar:                   ;Print Character D0
     move    d0,-(sp)
     move    #2,-(sp)
     trap    #1
     addq.l  #4,sp
     rts

pmsg:                    ;Print Line (D0)
     move.l  d0,-(sp)
     move    #9,-(sp)
     trap    #1
     addq    #6,sp
     rts

pnext:                   ;R‚cup‚rer mot suivant et l'afficher
     move    #'$',d0
     bsr     pchar       ;Afficher "$" 
     move    (a5)+,d0
phexword:                ;Print Hex-Word D0
     moveq   #3,d1
     bra     phex1
phexbyt:                 ;Print Hex-Byte
     moveq   #1,d1
     rol.l   #8,d0
phex1:
     rol.l   #4,d0
     move.l  d0,-(sp)
     move.l  d1,-(sp)
     bsr     phexnib     ;Afficher un nibble (0-F) 
     move.l  (sp)+,d1
     move.l  (sp)+,d0
     dbra    d1,phex1
     rts

phexnib:
     and.l   #$7f,d6
     swap    d0
     and.l   #$0f,d0
     add.b   #$30,d0
     cmp.b   #$3a,d0
     bcs     phexn
     add.b   #7,d0
phexn:
     bra     pchar       ;Afficher Nibble 


prompt: dc.b "***  BPB-Analyseur  S.D.  ***",10,13
        dc.b "Saisissez le lecteur (a-d) ou",10,13
        dc.b "'q' pour Quitter : ",0
bps:    dc.b "  Bytes par Secteur",0
spc:    dc.b "  Secteurs par Cluster",0
bpc:    dc.b "  Bytes par Cluster",0
dirsec: dc.b "  Secteurs-Directory",0
fatsec: dc.b "  Secteurs-FAT",0
fat2s:  dc.b ": Start-Sector 2.FAT",0
datsec: dc.b ": Start-Sector des donn‚es",0
datc:   dc.b "  Cluster de donn‚es",0
fatbit: dc.b "    Bits par donn‚e de la FAT",10,13,0
