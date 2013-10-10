*	etude de la protecte de audio sculpture 
*	realisee par SHIZUKA 
*	pour le compte de TOKI
*
*	FOR YOUR EYES ONLY ....
*


* pour l'instant on etudie le boot
* apres le END , tu trouveras un memo sur le FDC
	 TEXT 
  BRA.S   debut
  SWAP    D1
  ADDQ.W  #1,D4 
  SUBQ.B  #3,-2139(A6)
  SUB.B   D0,D4 
  DC.B   $02,$02,$01,$00,$02,'p',$00,$D0
  DC.B   $02,$F9,$05,$00,$09,$00,$01,$00
  DS.W    1 
  MOVE.W  #$80,0.w
debut
  LEA     phrase_cryptee(PC),A0
  MOVE.W  #$15,D7 
  BSR.S   dummy_uncrypt 
  PEA     phrase_cryptee(PC) 
  MOVE.W  #9,-(A7)
*msg uniquement pour celui qui trace le boot
  NOP 
  ADDQ.W  #6,A7 
*remarque que -$79fc est une valeur centrale interessante
*permettant par offset de jouer sur toutes les variables
*au sommet , tout comme au bas de la memoire ....
 
* -$79fc vaut ffff8604 
* cette adresse a l'acces aux registres du fdc , registre de controle
  MOVEA.W #-$79FC,A6
  MOVE.L  #$70000,D7

*on deconnecte
  MOVE    #$2700,SR 
*on appelle la premiere routine generale
  BSR     main_rout 
*a premiere vue c'est l'adresse de chargement du prg
  JMP     $00070000 
dummy_uncrypt
  NEG.B   (A0)+ 
  DBF     D7,dummy_uncrypt
  RTS 
*4e71=nop et 4afc=illegal !!!
  MOVE.L  #$4E714AFC,D0 
L0002
  EOR.W   D0,(A0)+
  ADDQ.W  #1,D0 
  DBF     D7,L0002
main_rout:
  BSR     premiere_init 
  BSR     temporisation1 
  BSR     init_dma 
  MOVE.L  variable1(PC),$00050000 
  MOVE.L  variable1(PC),508(A6) 
  BSR     L000B 
  BSR     temporisation1 
  BSR     L0010 
  BSR     temporisation1 
  BSR     L0011 
  BSR     L0004 
  SF      $43E.w
* la cession de boot est finie , on passe a la suite
  RTS 
L0004
* $ffff8606 = registre de donnees
* selection du regitre de donnees
  MOVE.W  #$86,2(A6)
* $ffff8604 = registre de controle
  MOVE.W  #1,(A6) 
* $ffff8606 = registre de donnees
* on selectionne le command register
  MOVE.W  #$80,2(A6)
* $ffff8604 = registre de controle
  MOVE.W  #$10,(A6) 
  BSR     L000D 
  RTS 
premiere_init
* -$7dc0 vaut : $ffff8240
* on modifie la palette
  MOVEA.W #-$7DC0,A0
  MOVEQ   #$F,D1
init0
  MOVE.W  #7,(A0)+
  DBF     D1,init0
* -$7da0 vaut : $ffff8260
* on passe en moyenne resolution
  MOVE.B  #2,-$7DA0.w 
* -$7df6 vaut : $ffff820a
* on passe en synchro externe
  MOVE.B  #1,-$7DF6.w 
* on bloque la routine vbl
  ST      $43E.w
  MOVEQ   #0,D1 
*on teste si le systeme est initialise a partir du drive a
  TST.W   $446.w
  BEQ.S   L0007 
*si non
  LEA     variable0(PC),A0
  LEA     variable1(PC),A1
  MOVE.W  #3,(A0) 
  MOVE.L  #$E0E0303,(A1)
  RTS 
L0007
*si oui
  LEA     variable0(PC),A0
  LEA     variable1(PC),A1
  MOVE.W  #5,(A0) 
  MOVE.L  #$E0E0505,(A1)
  RTS 
temporisation1
  MOVEQ   #$28,D6 
temporisation2
  DBF     D6,temporisation2
  RTS 
init_dma
* \508 +$ffff8604 = $ffff8800 
* lecture du port b du processeur sonore
  MOVE.L  508(A6),D2
* on active le mode dma  
* on selectionne le command register
  MOVE.W  #$86,2(A6)
*lecture registre fdc/dma
  MOVE.W  (A6),D0 
*ecriture
  MOVE.W  #1,(A6)
*activer mode dma
*selection du sector register 
  MOVE.W  #$84,2(A6)
*acces au registre dma fdc
  MOVE.W  #2,(A6) 
  MOVE.W  variable0(PC),D1
  RTS 
L000B
  BSR.S   L0012 
* on selectionne le command register
  MOVE.W  #$80,2(A6)
  MOVE.W  #$10,(A6) 
  BSR     L000D 
  BNE.S   L000C 
  RTS 
L000C
* -$7dc0 vaut :$ffff8240 ( la palette )
  MOVE.W  #7,-$7DC0.w 
  BRA.S   L000C 
L000D
 MOVE.L  #$80000,D6
suivi_execution_commande
* -$5ff vaut : $fffffa01
* on teste si la commande est finie 
  BTST    #5,-$5FF.w
  BEQ.S   la_commande_est_finie 
  SUBQ.L  #1,D6 
  BNE.S   suivi_execution_commande 
  CMPA.W  #0,A7 
  RTS 
la_commande_est_finie
  MOVE    #4,CCR
  RTS 
L0010
  MOVE.B  D7,9(A6)
  LSR.L   #8,D7 
  MOVE.B  D7,7(A6)
  LSR.W   #8,D7 
  MOVE.B  D7,5(A6)
  MOVE.W  #$90,2(A6)
  MOVE.W  #$190,2(A6) 
  MOVE.W  #$90,2(A6)
  MOVE.W  #1,(A6) 
  RTS 
L0011
* on selectionne le command register
  MOVE.W  #$80,2(A6)
  MOVE.W  #$80,(A6) 
  BSR     temporisation1 
  BSR.S   L000D 
  BNE.S   L000C 
  RTS 
L0012
  ROL.L   #8,D2 
  ANDI.W  #7,D2 
  CMP.B   D1,D2 
  BEQ.S   L0013 
  MOVEQ   #1,D0 
L0013
  ANDI.W  #$F,D0
  SUBQ.W  #1,D0 
  ADD.W   D0,(A6) 
  MOVEQ   #5,D1 
  RTS 
variable1 DS.W    2 
variable0
  DS.W    0 
phrase_cryptee
  DC.B   $B0,$94,$9B,$9F,$8D,$9B,$E0,$9C
  DC.B   $91,$E0,$B2,$B1,$AC,$E0,$9D,$8E
  DC.B   $9F,$9D,$95,$D2,$D2,$D2,$02,$00
  DS.W    17
  DC.B   $1D,'R'
	 END
*****************************************************************
*******                    MEMO FDC                      ********
*****************************************************************
*Hardware-Register
dmamode   = $ff8606
dmascnt   = $ff8604
dmalow    = $ff860d
dmamid    = $ff860b
dmahigh   = $ff8609
giselect  = $ff8800
giwrite   = $ff8802
mfp       = $fffa01
*Mots de contrìle pour le contrìleur DMA (sens des donnÇes DMA => READ) 
srcmd = $80  ; SÇlection du Command-Register
srtrk = $82  ; SÇlection du Track-Register 
srsec = $84  ; SÇlection du Sector-Register
srdat = $86  ; SÇlection du Data-Register
srcnt = $90  ; SÇlection du DMA-Sectorcount-Register
*Mots de contrìle pour le contrìleur DMA (sesn des donnÇes DMA => WRITE)
swcmd = $180 ; signification comme pour => READ
swtrk = $182
swsec = $184
swdat = $186
swcnt = $190
*****************************************************************
 even
st:
 bra.s run   ; vers dÇbut du programme
************************ Mots de commande *************************
rest:  dc.w $01 ; Restore      MO, 3ms Step-Rate
see:   dc.w $11 ; Seek         MO, 3ms Step-Rate
stp:   dc.w $31 ; Step         MO, 3ms Step-Rate, Update Trackreg.
stpi:  dc.w $51 ; Step-in      MO, 3ms Step-Rate, Update Trackreg.
stpo:  dc.w $71 ; Step-out     MO, 3ms Step-Rate, Update Trackreg.
rsec:  dc.w $90 ; Read-Sector  MO, multiple
wsec:  dc.w $b0 ; Write-Sector MO, multiple, Write-Precompensation
radr:  dc.w $c0 ; Read-Address MO,
rtrk:  dc.w $e0 ; Read-Track   MO,
wtrk:  dc.w $f0 ; Write-Track  MO, Write-Precompensation
forc:  dc.w $d0 ; Force-Interrupt
*******************  Paramätres de saisie ***********************
prm:   dc.w 00 ; NumÇro de fonction
       dc.w 00 ; NumÇro de lecteur
       dc.w 00 ; NumÇro de piste
       dc.w 00 ; NumÇro de secteur
       dc.w 00 ; Nombre d'octets Ö transfÇrer
       dc.w 00 ; Nombre de champ d'ID Ö lire
       dc.w 00 ; FDC-Status
       dc.w 00 ; DMA-Status
       dc.w 00 ; Timeout? (1=timeout)
       dc.w 00 ; Nombre d'octets transfÇrÇs
       dc.l 00 ; DMA-Start-Adress
       dc.l 00 ; DMA-End-Adress
       dc.l 00 ; Adresse du tampon de piste 
       dc.l 00 ; Adresse du tampon de secteur 
       dc.l 00 ; Adresse du tampon d'ID
       dc.l 00 ; Adresse du tampon d'Çtat de l'ID
****************    C'est parti !    ***************** 
run:
 tst.w 4(sp)               ; Des paramätres ont-ils ÇtÇ donnÇs ?
 bne exit                  ; Oui, retour au BASIC
*Comme on n'a le droit d'adresser la source que relativement au PC, nous 
*prenons A3 comme compteur de programme.
 lea st(pc),a3             ; Program-Start dans Adress-Reg.3
 movem.l d0-d7/a0-a6,savreg-st(a3) ; sauvegarde des Registres 
*******************  Set Supervisor-Mode  ***********************
 clr.l -(sp)               ; Userstack => Superv.Stack
 move.w #$20,-(sp)         ; Command => Super
 trap #1
 addq.l #6,sp              ; Correction de la pile
 move.l d0,savstack-st(a3) ; sauvegarde de l'ancien Stackpointer 
*** Suppression de certains Flags et calcul  de l'adresse absolue de *** 
*** la fonction dÇsirÇe                                       ***
 lea prm-st(a3),a5         ; pointeur sur Parameter-Block
 move.w #1,$43e            ; mÇmorisation du Floppy-VBL 
 move.w #0,16(a5)          ; Effacer Timeout-Flag 
 move.w #0,dma-st(a3)      ; Effacer DMA-Flag 
 move.w #0,vblflag-st(a3)  ; Effacer VBL-flag de retour 
 move.w 0(a5),d0           ; RÇcupÇration du numÇro de fonction 
 and.l #$0f,d0             ; Il n'y a que 16 fonctions (0-15)
 lsl.l #2,d0               ; fois 4 = functab-Offset
 lea functab-st(a3),a4     ; func-Table-Adress
 move.l 0(a4,d0),d0        ; Adresse de dÇpart relative de la routine
 jsr 0(a3,d0)              ; +Programstart=Adr. abs. de la routine
 tst.w vblflag-st(a3)      ; Activtion du VBL (apräs dÇselection)?
 beq letoff                ; non
 move.w #0,$43e            ; activation
letoff:
******************  Retour en User-Mode  ********************  
 move.l savstack-st(a3),d0 ; RÇcupÇration de l'ancien Stackpointer
 move.l d0,-(a7)           ; Saisie de l'Çncien Stackpointer
 move.w #$20,-(sp)         ; Command => Super
 trap #1
 addq.l #6,sp              ; Correction de la pile 
 movem.l savreg-st(a3),d0-d7/a0-a6 ; RecupÇration du registre 
exit:
 rts                       ; retour au  BASIC 
* Voila ! Maintenant, vos avez (seulement) les routines 
***********************  Restore FDC ****************************
restore:
 move.w #srcmd,dmamode     ; SÇlection du Command-Reg. 
 move.w rest-st(a3),d7     ; Command => Restore
 bsr wrt1772               ; Envoi de la commande 
 bsr fdcwait               ; Attente jusqu'Ö ce que FDC soit pràt 
 rts
***********************  SEEK TRACK  ****************************
seek:
 move.w #srdat,dmamode     ; SÇlection du registre de donnÇes 
 move.w 4(a5),d7           ; Tracknr. dans d7
 bsr wrt1772               ; Ecrire Tracknr. 
 move.w #srcmd,dmamode     ; SÇlection du Command-Reg.
 move.w see-st(a3),d7      ; Command => Seek
 bsr wrt1772               ; Ecrire commande 
 bsr fdcwait               ; Attente jusqu'Ö ce que FDC soit pràt 
 rts
************************  Step  *********************************
step:
 move.w #srcmd,dmamode     ; SÇlection du FDC-Commandreg. 
 move.w stp-st(a3),d7      ; Command => Step
 bsr wrt1772               ; Ecrire commande 
 bsr fdcwait               ; Attente jusqu'Ö ce que FDC soit pràt
 rts
*************************  Step in  *****************************                            
stepin:
 move.w #srcmd,dmamode     ; SÇlection du FDC-Commandreg. 
 move.w stpi-st(a3),d7     ; Command => Step in
 bsr wrt1772               ; Ecrire commande 
 bsr fdcwait               ; Attente jusqu'Ö ce que FDC soit pràt 
 rts
************************  Step out  *****************************
stepout:
 move.w #srcmd,dmamode     ; SÇlection du FDC-Commandreg. 
 move.w stpo-st(a3),d7     ; Command => Step out 
 bsr wrt1772               ; Ecrire commande 
 bsr fdcwait               ; Attente jusqu'Ö ce que FDC soit pràt 
 rts
***********************  Force Interrupt  ***********************
Force:
 move.w forc-st(a3),d7     ; Command => Force Interrupt
 bsr wrt1772               ; Ecrire commande 
 move.w #$100,d7           ; Boucle de temporisation 
wtfrc:
 dbra d7,wtfrc
 rts
*********************  READ SECTOR(S)  **************************
readsector:
 move.l 32(a5),d7          ; DMA-Adress sur tampon de secteur
 bsr setdma
 move.w #1,dma-st(a3)      ; Positionner DMA-Flag 
 move.w #srcnt,dmamode     ; DMA-R/W toggel (Flip/Flop)
 move.w #swcnt,dmamode
 move.w #srcnt,dmamode     ; SÇlection du DMA-Sectorcount 
 move.w #$0c,d7            ; Charger avec  12  (Correspond Ö  6ko)
 bsr wrt1772               ; Charger DMA-Scnt 
 move.w #srsec,dmamode     ; SÇlectionner Sector-Reg. 
 move.w 6(a5),d7           ; Sektor-Nr. dans d7
 bsr wrt1772               ; Ecrire Sektor-Nr. 
 move.w #srcmd,dmamode     ; SÇlection du Command-Reg. 
 move.w rsec-st(a3),d7     ; Command => Read multiple Sectors
 bsr wrt1772               ; Ecrire commande 
 bsr fdcwait               ; attente jusqu'Ö ce que FDC soit pràt 
 bsr readstat              ; Lire Çtat et nbr d'octets 
 rts
**********************  Read Address  ***************************
readaddress:
 move.l 40(a5),a4          ; Charger adresse du tampon d'Çtat 
 move.l 36(a5),d7          ; DMA-Adress sur tampon de champ d'ID 
 bsr setdma
 move.w #srcnt,dmamode     ; DMA-R/W toggel
 move.w #swcnt,dmamode
 move.w #srcnt,dmamode     ; SÇlection du DMA-Sectorcount 
 move.w #$01,d7            ; Charger avec  1  (Correspond Ö  512 octets)
 bsr wrt1772
 move.w #srcmd,dmamode     ; SÇlection du FDC-Commandreg. 
 move.w 10(a5),d4          ; #ID-Felder dans D4
 and.w  #$7f,d4            ; Mais au  max. 128
idloop:
 move.w radr-st(a3),d7     ; Command => Read Address
 bsr wrt1772               ; Ecrire commande 
 bsr fdcwait               ; attente jusqu'Ö ce FDC soit pràt
 move.b d0,(a4)+           ; Mettre l'Çtat dans le tampon 
 tst.w 16(a5)              ; Timeout ?
 dbne d4,idloop            ; non, lire chemp suivant
 bsr readstat              ; Lire Çtat et nombre d'octets 
 rts
***********************  READ TRACK  ****************************
readtrack:
 move.l 28(a5),d7          ; DMA-Adress sur Track-Buffer
 bsr setdma
 move.w #1,dma-st(a3)      ; Positionner DMA-Flag 
 move.w #srcnt,dmamode     ; DMA-R/W toggel
 move.w #swcnt,dmamode
 move.w #srcnt,dmamode     ; SÇlection DMA-Sectorcount 
 move.w #$0e,d7            ; charger avec 14 (correspond Ö  7ko)
 bsr wrt1772
 move.w #srcmd,dmamode     ; SÇlection du Command-Reg. 
 move.w rtrk-st(a3),d7     ; Command => Read Track
 bsr wrt1772               ; Ecrire commande 
 bsr fdcwait               ; Attente jusqu'Ö ce que FDc soit pràt 
 bsr readstat              ; Lire l'Çtat et le nombre d'octets 
 rts
*********************  WRITE SECTOR(S)  *************************
writesector:
 move.l 32(a5),d7          ; DMA-Adress sur Sector-Buffer
 bsr setdma
 move.w #1,dma-st(a3)      ; Positionner DMA-Flag 
 move.w #swcnt,dmamode     ; DMA-R/W toggel
 move.w #srcnt,dmamode
 move.w #swcnt,dmamode     ; SÇlection du DMA-Sectorcount 
 move.w #$0c,d7            ; charger avec 12  (correspond Ö  6ko)
 bsr wrt1772               ; Ecrire DMA-Scnt 
 move.w #swsec,dmamode     ; SÇlectionner Sector-Reg. 
 move.w 6(a5),d7           ; Sektornr. dans d7
 bsr wrt1772               ; Ecrire Sektor-Reg. 
 move.w #swcmd,dmamode     ; SÇlectionner Command-Reg. 
 move.w wsec-st(a3),d7     ; Command => Write multiple Sectors
 bsr wrt1772               ; Ecrire commande 
 bsr fdcwait               ; Attente jusqu'Ö ce que FDC soit pràt
 bsr readstat              ; Lire l'Çtat et le nombre d'octets 
 rts
**********************  WRITE TRACK  ****************************
writetrack:
 move.l 28(a5),d7          ; DMA-Adress sur Track-Buffer
 bsr setdma
 move.w #1,dma-st(a3)      ; Positionner DMA-Flag 
 move.w #swcnt,dmamode     ; DMA-R/W toggel
 move.w #srcnt,dmamode
 move.w #swcnt,dmamode     ; SÇlectionner DMA-Sectorcount 
 move.w #$0e,d7            ; Charger avec 14 (correspond Ö 7ko)
 bsr wrt1772               ; Ecrire DMA-Scnt 
 move.w #swcmd,dmamode     ; SÇlectionner Command-Reg. 
 move.w wtrk-st(a3),d7     ; Command => Write Track
 bsr wrt1772               ; Ecrire commande 
 bsr fdcwait               ; attente jusqu'Ö ce que FDC soit pràt
 bsr readstat              ; Lire l'Çtat et le nombre d'octets 
 rts
*****************************************************************
*****************************************************************
*C'Çtaient les routines appelant les commandes du WD 1772 
*Voici d'autre sous-routines qui sont appelÇes partiellement par 
*la routine principale et partiellement par le BASIC (p.ex. setdrive)
*****************  Lecture du Sector-Register   ***********************
rsecreg:
 move.w #srsec,dmamode     ; SÇlection du  Sector-Reg. 
 bsr read1772              ; et lecture 
 and.w #$ff,d0             ; Seulement octets faibles 
 move.w d0,6(a5)           ; dans le FDC-Array
 move.w #srcmd,dmamode     ; SÇlection du Command-Reg. 
 rts
*******************  Lecture du Track-Register   **********************
rtrkreg:
 move.w #srtrk,dmamode     ; SÇlection du track-Reg. 
 bsr read1772              ; et lecture 
 and.w #$ff,d0             ; Seulement octets faibles
 move.w d0,4(a5)           ; dans  FDC-Array
 move.w #srcmd,dmamode     ; SÇlection du Command-Reg. 
 rts
*********************  Lecture du Status-Reg.   ***********************
rstareg:
 move.w #srcmd,dmamode     ; SÇlection du Status-Reg. 
 bsr read1772              ; et lecture 
 and.w #$ff,d0             ; Etat dans les octets faibles 
 move.w d0,12(a5)          ; dans le  FDC-Array
 rts
********************  Ecriture du Track-Reg.   **********************
wtrkreg:
 move.w #srtrk,dmamode     ; SÇlection du track-Reg. 
 move.w 4(a5),d7           ; RÇcupÇrer n¯ de piste 
 and.w #$ff,d7
 bsr wrt1772               ; et Çcrire
 move.w #srcmd,dmamode     ; SÇlection du Command-Reg. 
 rts
********************  Set DMA-Transfer Adress  *****************
setdma:
 move.l d7,20(a5)          ; Mettre Start-Adress dans FDC-Array 
 move.b d7,dmalow          ; Ecrire d'abord  Low-Byte
 lsr.l #8,d7
 move.b d7,dmamid          ; puis Mid-Byte
 lsr.l #8,d7
 move.b d7,dmahigh         ; et enfin  High-Byte
 move.l 20(a5),d7          ; RÇcupÇration de la Start-Adress
 clr.l d6
 move.w 8(a5),d6           ; Nombre d'octets Ö transfÇrer
 add.l d6,d7               ; Addition des deux
 move.l d7,24(a5)          ; =Adresse de fin attendue
 rts
*** Lecture du DMA-Status; calcul des octets Ö transfÇrer  ***
readstat:
 move.w dmamode,d0         ; Lecture du DMA-Status 
 and.w #$7,d0              ; Prendre seulement les 3 bits infÇrieurs 
 move.w d0,14(a5)          ; ert apräs fdcout
 clr.l d1                  ; Lecture de la DMA-Endadress
 move.b dmahigh,d1    
 lsl.l #8,d1
 move.b dmamid,d1
 lsl.l #8,d1
 move.b dmalow,d1
 move.l d1,24(a5)          ; End-Adress dans Array
 sub.l 20(a5),d1           ; End-Adr. moins Start-Adr.
 move.w d1,18(a5)          ; =Nombre d'octets 
 rts
*****************    Ecriture du FDC-Register    *******************
wrt1772:
 bsr wait
 move.w d7,dmascnt       ; Ecrire FDC-Reg. ou DMA-Sectorcount 
 bsr wait
 rts
*****************     Lecture du FDC-Register      ********************
read1772:
 bsr wait
 move.w dmascnt,d0        ; Lire FDC-Reg. ou DMA-Sectorcount 
 bsr wait
 rts
****************    Attente jusqu'Ö ce que FDC soit pràt *****************
fdcwait:
 move.l #$180,d5           ; Attendre un peu jusqu'Ö ce Busy soit positionnÇ
litlwt:
 dbra d5,litlwt
 move.l #$40000,d5         ; d5 sert de compteur Timeout
 cmp.w #$9,0(a5)           ; Commande READ-ADDRESS?
 bne readmfp
 move.l #$28000,d5         ; Oui, timeout plus court
readmfp:
 btst #5,mfp               ; Commande finie ?
 beq fdcready              ; oui
 subq.l #1,d5              ; non, DÇcrÇmenter compteur Timeout
 beq timeout               ; Si arrivÇ Ö la fin
 tst.w dma-st(a3)          ; Commande de transfert de donnÇes ?
 beq readmfp               ; non, Continuer le test
 move.b dmahigh,temp+1-st(a3)  ; C'est la  DMA-Endadress attendue
 move.b dmamid,temp+2-st(a3)   ; dÇjÖ atteinte ?
 move.b dmalow,temp+3-st(a3)
 move.l temp-st(a3),d7
 cmp.l 24(a5),d7
 blt readmfp               ; non, continuer Ö tester
 bsr force                 ; Si oui, interrompre la commande
 move.w #0,dma-st(a3)      ; Effacer dma-Flag 
 bra fdcready              ; et quitter normalement la routine
timeout:
 move.w dmascnt,d0         ; Lire l'Çtat avant l'interruption
 and.w #$ff,d0             ; Masquer l'octet de poids fort
 move.w d0,12(a5)          ; Et mettre dans l'Array
 bsr force                 ; Arräter la commande
 move.w #1,16(a5)          ; Positionner Timeoutflag 
 rts
fdcready:
 move.w dmascnt,d0         ; Lire l'Çtat
 and.w #$ff,d0             ; Masquer l'octet de poids fort
 move.w d0,12(a5)          ; et mettre dans le FDC-Array
 rts
************  Attendre jusqu'Ö ce que le moteur soit arrätÇ ************
motoroff:
 move.w #srcmd,dmamode     ; SÇlection du Statusreg. 
test:
 bsr read1772              ; et lecture
 btst #7,d0                ; Motor-on positionnÇ
 bne test                  ; oui, continuer l'attente
 rts
*************************    Wait   *****************************
wait:
 move.w sr,-(a7)           ; Sauvegarder Status 
 move.w #$20,d5            ; d5 sert de compteur
wt2:
 dbf d5,wt2
 move.w (a7)+,sr           ; RÇcupÇrer Status 
 rts
*****************  SÇlection du lecteur et de la piste  ****************
setdrive:
 clr.l d7
 move.w 2(a5),d7           ; RÇcupÇrer Drive-Nr.
 bne set
 bsr motoroff              ; Si 0, d'abord dÇselectionner quand motor OFF
 move.w #1,vblflag-st(a3)  ; Positionner flag de retour de VBL
set:
 eor.b #7,d7               ; Inverser les Bits pour le  Hardware 
 and.b #7,d7               ; Seuls les 3 Low-Bits sont modifiÇs
 move.w sr,-(a7)           ; Sauvegarder Status 
 or.w #$700,sr             ; DÇsactiver Interruptions
 move.b #$e,giselect       ; SÇlectionner Port A du Sound-Chips 
 move.b giselect,d0        ; Lire Port A 
 and.b  #$f8,d0            ; Effacer Bits 0-2 
 or.b   d0,d7              ; Positionner nouveaux bits 
 move.b d7,giwrite         ; Et Çcrire sur  Port A 
 move.w (a7)+,sr           ; restore Status
 rts
 even
savreg:   blk.l 16,0
savprm:   dc.l 0
savstack: dc.l 0
vblflag:  dc.w 0
dma:      dc.w 0
temp:     dc.l 0
functab:  dc.l restore-st,seek-st
          dc.l step-st,stepin-st
          dc.l stepout-st,readsector-st
          dc.l writesector-st,readtrack-st
          dc.l writetrack-st,readaddress-st
          dc.l force-st,setdrive-st
          dc.l rsecreg-st,rtrkreg-st
          dc.l rstareg-st,wtrkreg-st
 even
-----------------------------------------------------------------------
------------------------------------------------------------------------
mfp    = $fffffa01        ; Adresse des MFP68901 fÅrs Polling
daccess= $ffff8604        ; DMA-Controller, FDC-Zugriff oder SektorzÑhler
dmodus = $ffff8606        ; DMA-Controller, Modus einstellen
dlow   = $ffff860d        ; DMA-Controller, öbertragungsstart Lowbyte
dmid   = $ffff860b        ; DMA-Controller, Åbertragungsstart Midbyte
dhigh  = $ffff8609        ; DMA-Controller, Åbertragungsstart Highbyte
time   = $40000           ; Timeout-Konstante
snd    = $ffff8800        ; Soundchip
sndwrt = $ffff8802        ; Output-Register
*************************
* Der Sprung ins Ungewisse
*************************
start:
   bra.s main             ; Sprung zum Programmanfang
*************************
* Ein/Ausgabefeld zur ParameterÅbergabe
*************************
opcode:  .dc.w 0                ; Opcode des Controllerbefehls  2(a6)
track:   .dc.w 0                ; Tracknummer                   4(a6)
sector:  .dc.w 0                ; Sektornummer                  6(a6)
count:   .dc.w 0                ; in:zu Åbertragende Bytes/ID-Felder etc.
*                                 out:Åbertragene Bytes         8(a6)
buffer1: .dc.l 0                ; Adresse des ersten Puffers fÅr
*                                 Track-, Sektor-, ID-Daten    10(a6)
buffer2: .dc.l 0                ; Adresse des Reservepuffers   14(a6)
fst:     .dc.w 0                ; Status des Controllers       18(a6)
dst:     .dc.w 0                ; Status der DMA-öbertragung   20(a6)
dstart:  .dc.l 0                ; Start der DMA-öbertragung    22(a6)
dend:    .dc.l 0                ; Ende der DMA-öbertragung     26(a6)
timeout: .dc.w 0                ; Timeoutflag                  30(a6)
stk:     .dc.l 0                ; Puffer fÅr Stackpointer      32(a6)
dflag:   .dc.w 0                ; DMA-Flag                     36(a6)
laufwerk: .dc.w 8               ; Laufwerk+Seite/Extended Mode 38(a6)
parm:    .dc.l 0                ; Reservefeld fÅr Extended Mode 40(a6)
temp:    .dc.l 0                ; Reservefeld                  44(a6)
modus:   .dc.l 0                ; Modus-Langwort               48(a6)
*                               ; reserviert, auf 0 setzen!
***************************
* Hauptverteilerroutine
***************************
main:
   movem.l d0-d7/a0-a6,-(sp)    ; Register verschwinden lassen
   moveq.l #0,d0                ; Userstack wird Supervisorstack
   bsr.s super                  ; Supervisormodus an
   lea start(pc),a6             ; a6->Prg-Anfang
   move.l d0,32(a6)             ; Stackpointer retten
   st $43e                      ; Floppy-VBL sperren
   cmp.w #8,38(a6)              ; Extended Mode?
   bmi.s noextmode              ; nein
   bsr.s select                 ; zur Select-Routine
   bra.s main3                  ; und raus
noextmode:
   tst.w 38(a6)                 ; Laufwerk vorgegeben?
   bne.s main2                  ; wenn ja, dann weiter
   bsr.s deselect               ; sonst Laufwerke ausschalten
   bra.s main3                  ; und raus
main2:
   bsr.s select                 ; Laufwerk selektieren
   move.w opcode(pc),d6         ; FDC-Befehl holen
   clr.w 36(a6)                 ; DMA-Flag initialisieren
   clr.w 30(a6)                 ; Timeout-Flag initialisieren
   bsr analyze                  ; Befehl analysieren und ausfÅhren
main3:
   sf $43e                      ; Floppy-VBL wieder erlauben
   move.l 32(a6),d0             ; Stackpointer holen
   bsr.s super                  ; Supervisormodus aus (schaaade...)
   movem.l (sp)+,d0-d7/a0-a6    ; Register wieder holen
   rts                          ; und raus (ade!)
*****************************
* super: Schaltet vom Usermode
* in der Supervisormode und umgekehrt
* öbergabe des Stackpointers in d0
*****************************
super:
   move.l d0,-(sp)              ; Stackpointer auf Stack
   move.w #$20,-(sp)            ; SUPER
   trap #1                      ; im GEMDOS
   addq.l #6,sp                 ; Stack korrigieren
   rts
**********************
* deselect: Selektierroutine
**********************
deselect:
   move.w #$80,dmodus           ; Statusregister auswÑhlen
motor:
   move.w daccess,d1            ; Status lesen
   btst #7,d1                   ; lÑuft der Motor noch?
   bne.s motor                  ; ja, dann warten
select:
   move.w laufwerk(pc),d7       ; Laufwerksnummer holen
   cmp.b #8,d7                  ; Laufwerkscode grîûer als 7?
   bge extend                   ; ja, extended mode
   eor.b #7,d7                  ; Bits invertieren
   and.b #7,d7                  ; und ausmaskieren
   move.w sr,-(sp)              ; Status retten
   or.w #$700,sr                ; IRQs aus
   move.b #14,snd               ; Port A wÑhlen
   move.b snd,d0                ; Port A lesen
   and.b #$f8,d0                ; ausmaskieren
   or.b d0,d7                   ; neue Seite/neues Laufwerk setzen
   move.b d7,sndwrt             ; in Port A schreiben
   move.w (sp)+,sr              ; Status restaurieren
   rts                          ; und raus
******************************
* wrfdc: Byte in d7 an den Controller
* schicken
******************************
wrfdc:
   bsr.s waitl                  ; kurz warten
   move.w d7,daccess            ; d7 ins Access-Register des DMA-Chips
   bra.s waitl                  ; kurz warten
******************************
* rdfdc: Controller auslesen nach d7
******************************
rdfdc:
   bsr.s waitl                  ; kurz warten
   move.w daccess,d7
waitl:
   move.l d1,-(sp)              ; d1 retten
   moveq.l #25,d1               ; kurze Wartezeit
   bsr.s as_time_goes_by
   move.l (sp)+,d1
   rts
******************************
* as_time_goes_by: Warteschleife
* mit d1 DurchlÑufen
******************************
as_time_goes_by:
   dbf d1,as_time_goes_by       ; Looping (huiii...)
   rts                          ; back to the future
******************************
* warten_auf_godot : Wartet auf das IRQ-Signal
* des FDC
******************************
warten_auf_godot:
   move.l #time,d7              ; Konstante fÅr Timeout
   bsr.s waitl                  ; kurz warten
poll:
   btst #5,mfp                  ; IRQ am MFP?
   beq.s fix_und_fertig         ; jawoll, Kommando ist ausgefÅhrt
   subq.l #1,d7                 ; TimeoutzÑhler magert ab
   beq.s game_over              ; Sorry, zu lange gefackelt
   tst.w 36(a6)                 ; DMA aktiv?
   beq poll                     ; nein, zum Polling
   bsr.s getdma                 ; DMA-Adresse nach d0 holen
   sub.l dend(pc),d0            ; Endadresse abziehen
   bmi poll                     ; Noch nicht erreicht, weiter testen
fix_und_fertig:
   clr.w 36(a6)                 ; DMA-Flag lîschen
   move.w daccess,18(a6)        ; Controllerstatus retten
   bra resetfdc                 ; FDC-Reset auslîsen
***************************
* Timeout-Konstante ist abgelaufen
***************************
game_over:
   move.w #1,30(a6)             ; Timeout-Flag setzen
   bra.s fix_und_fertig         ; Status lesen, in fst ablegen und FDC-Reset
***************************
* status: Status und Bytezahl lesen
***************************
status:
   move.w d3,dmodus             ; SektorzÑhler selektieren
   move.w dmodus,20(a6)         ; DMA-Status lesen
   bsr.s getdma                 ; DMA-Adresse nach d0 holen
   move.l d0,26(a6)             ; Endadresse
   sub.l dstart(pc),d0          ; minus Start
   move.w d0,8(a6)              ; =Anzahl der Åbertragenen Bytes
   rts
****************************
* getdma: DMA-Adresse nach d0 lesen
****************************
getdma:
   moveq.l #0,d0                ; d0 lîschen
   move.b dhigh,d0              ; DMA-High holen
   lsl.l #8,d0                  ; um ein Byte schieben
   move.b dmid,d0               ; DMA-Mid
   lsl.l #8,d0                  ; um ein Byte schieben
   move.b dlow,d0               ; DMA-Low
   rts
****************************
* dma: dma setzen (Spiegelbild zu status)
****************************
dma:
   move.l d7,22(a6)             ; Startadresse ablegen
   move.b d7,dlow               ; Lowbyte
   lsr.l #8,d7                  ; um ein Byte schieben
   move.b d7,dmid               ; Midbyte
   lsr.l #8,d7                  ; um ein Byte schieben
   move.b d7,dhigh              ; Highbyte
   move.l dstart(pc),d7         ; Startadresse holen
   moveq.l #0,d0                ; d0 lîschen
   move.w count(pc),d0          ; Bytecounter nach d0
   add.l d0,d7                  ; Addieren
   move.l d7,26(a6)             ; Endadresse ablegen
   rts
*****************************
* analyze: Analysiert grob, welche Art von
* Befehl vorliegt
* und verteilt entsprechend
* in: d6.w Opcode
*****************************
analyze:
   move.w d6,d7                 ; Opcode retten
   move.w d6,d5                 ; gleich nochmal
   btst #7,d6                   ; Bit 7 testen
   bne.s typii                  ; kein Typ-I-Befehl
   and.b #$f0,d6                ; obere 4 Bits ausmaskieren
   cmp.b #16,d6                 ; SEEK-Befehl?
   beq such_hasso               ; jawoll
   bne step_dance               ; kein Seek, aber Typ-I
typii:
   btst #6,d6                   ; Bit 6 testen
   bne.s typiii                 ; kein Typ-II-Befehl
   btst #5,d6                   ; Bit 5 testen
   beq.s rdsector               ; gelîscht, also Read-Sector-Befehl
   bne.s wrsector               ; Write-Sector-Befehl
typiii:
   and.b #$f0,d6                ; obere 4 Bits ausmaskieren
   cmp.b #$c0,d6                ; Read Adress?
   beq rdadr                    ; jawoll
   cmp.b #$e0,d6                ; Read Track?
   beq.s rdtrk                  ; jawoll
   cmp.b #$f0,d6                ; Write Track?
   beq.s wrtrk                  ; jawoll
*                               * alles andere ist Force Interrupt
**************************
* irq: Unterbricht den Controller
**************************
irq:
   bsr wrfdc                    ; d7 an den Controller
   move.w #250,d1               ; 250 SchleifendurchlÑufe
   bra as_time_goes_by          ; kurz warten
resetfdc:
   move.b #$d0,d7               ; FORCE IRQ
   bra irq                      ; FDC zurÅcksetzen
*****************************
* rdsector: Liest einen Sektor oder
* gleich einen ganzen Haufen davon
*****************************
rdsector:
   bsr.s rdinit                 ; DMA initialisieren
   btst #4,d5                   ; Read Multiple?
   bne.s rdmultiple             ; jawoll
   clr.w 36(a6)                 ; DMA-Flag lîschen (???)
   move.w #1,d7                 ; 1 Sektor
   bsr wrfdc                    ; in DMA-SektorzÑhler schreiben
rdmultiple:
   move.w #$84,dmodus           ; Sektorregister
   move.w sector(pc),d7         ; Sektor schreiben
   bsr wrfdc                    ; d7 an FDC
exe1:
   move.w #$80,dmodus           ; Kommandoregister
exe:
   move.w d5,d7                 ; Kommando von d5 nach d7
   bsr wrfdc                    ; d7 an FDC
   bsr warten_auf_godot         ; Ende des Kommandos abwarten
   bra status                   ; Status lesen
*****************************
* rdtrk: Track lesen
*****************************
rdtrk:
   bsr.s rdinit                 ; DMA initialisieren
   bra exe1
*****************************
* wrsector: Sektor schreiben
*****************************
wrsector:
   bsr.s wrinit                 ; DMA initialisieren
   btst #4,d5                   ; Write multiple?
   bne.s wrmultiple             ; jawoll
   clr.w 36(a6)                 ; DMA-Flag lîschen (???)
   move.w #1,d7                 ; 1 Sektor
   bsr wrfdc                    ; in DMA-SektorzÑhler schreiben
wrmultiple:
   move.w #$184,dmodus          ; Sektorregister
   move.w sector(pc),d7         ; Sektor in d7
   bsr wrfdc                    ; an Controller
   bra.s wrtrack2               ; wann geht's weiter? Gleich geht's weiter!
*****************************
* wrtrk: Track schreiben
*****************************
wrtrk:
   bsr.s wrinit                 ; DMA initialisieren
wrtrack2:
   move.w #$180,dmodus          ; Kommandoregister
   bra.s exe                    ; Befehl ausfÅhren
*****************************
* rdinit: Bereitet DMA zum Lesen vor
*****************************
rdinit:
   bsr.s fillbuf                ; DMA-Adresse setzen
   bsr.s toggle                 ; DMA-Status lîschen
   bra.s wrinit2                ; Sektorregister
fillbuf:
   move.l buffer1(pc),d7        ; Pufferadresse in d7
   bsr dma                      ; als DMA-Adresse
   move.w #1,36(a6)             ; DMA-Flag setzen
   rts
*****************************
* wrinit: DMA fÅr Schreiben vorbereiten
*****************************
wrinit:
   bsr fillbuf                  ; DMA-Adresse setzen
   move.w #$190,d3              ; d3 vorbereiten
   move.w d3,dmodus             ; Status lîschen
   move.w #$90,dmodus
   move.w d3,dmodus
wrinit2:
   move.w #31,d7                ; maximal 31 Blîcke
   bra wrfdc                    ; in DMA-Sektorregister schreiben
*****************************
* step_dance: einheitliche Routine fÅr step,
* step-in, step-out, restore
*****************************
step_dance:
   bra exe1                     ; Befehl ausfÅhren
*****************************
* such_hasso: Seek-Befehl
*****************************
such_hasso:
   move.w #$86,dmodus           ; Datenregister auswÑhlen
   move.w track(pc),d7          ; Tracknummer holen
   bsr wrfdc                    ; Byte in d7 an FDC
   bra exe1                     ; Befehl ausfÅhren
*****************************
* toggle: DMA-Status lîschen
*****************************
toggle:
   move.w #$90,d3               ; d3 vorbereiten
   move.w d3,dmodus             ; DMA-Status lîschen
   move.w #$190,dmodus
   move.w d3,dmodus             ; DMA-Sektorregister selektieren
   rts
*****************************
* rdadr: Adreûfeld lesen
*****************************
rdadr:
   clr.w 36(a6)                 ; DMA-Flag lîschen
   move.l buffer1(pc),d7        ; Adresse des Puffers holen
   move.l buffer2(pc),a3        ; Adresse des Reservepuffers
   bsr dma                      ; DMA initialisieren
   bsr toggle                   ; Status lîschen
   move.w #1,d7                 ; Maximal 1 Sektor
   bsr wrfdc                    ; d7 an FDC (DMA)
   move.w count(pc),d2          ; Wieviele ID-Felder?
   move.w sr,-(sp)              ; Status retten
   or.w #$700,sr                ; IRQs aus
   move.w #$80,dmodus           ; Kommandoregister
   move.w #4,d1                 ; 5mal (minus eins fÅr dbra)
umlauf:
   bsr.s sendirq
index:
   btst #5,mfp                  ; IRQ?
   bne index                    ; nein
   dbra d1,umlauf               ; weiter auf Touren bringen
   bsr.s sendirq
   moveq.l #0,d1                ; ZÑhler initialisieren
index2:
   addq.w #1,d1                 ; ZÑhler plus eins
   beq.s schluss                ; nur fÅr Timing
   btst #5,mfp
   bne index2
   move.w d1,(a3)+              ; Gesamt-Timer
nochnid:
   move.w d5,daccess            ; eigentliches Kommando schreiben
   subq.w #1,d1
   beq.s schluss
id:
   subq.w #1,d1                 ; ZÑhler kleiner
   beq.s schluss                ; gleich 0, dann Schluû
   btst #5,mfp
   bne id
   move.w daccess,(a3)+         ; Status schreiben
   move.w d1,(a3)+              ; ZÑhler schreiben
   subq.w #1,d1                 ; ZÑhler minus eins
   beq.s schluss                ; abgelaufen, dann Ende
   dbra d2,nochnid              ; noch ein Adreûfeld
schluss:
   bsr resetfdc                 ; FORCE IRQ
   move.w #2,d1                 ; Schleife dreimal durchlaufen
   move.l #0,(a3)+              ; Ende der gÅltigen Adreûfelder
emptydma:
   move.w #$c0,d7               ; Rd Adress
   bsr wrfdc                    ; an FDC schicken
emptylp:
   btst #5,mfp                  ; Kommando beendet?
   bne emptylp                  ; nein, warten
   move.l #0,(a3)+              ; Status und ZÑhler
   dbf d1,emptydma              ; nÑchster Dummy-Read
   bsr resetfdc                 ; FORCE IRQ
   move.w (sp)+,sr              ; Prozessorstatus holen
   bra status                   ; und zum Status
****************************
* sendirq: Schickt Indexirq, liest Status
****************************
sendirq:
   move.w #$D4,d7               ; Index-IRQ
   bsr wrfdc                    ; abschicken
   move.w daccess,d0            ; Status lesen und IRQ lîschen
   nop
   nop
   rts
********************************
* Extended-Teil
********************************
extend:
   lea main3(pc),a0             ; hier geht's spÑter weiter
   move.l a0,(sp)               ; auf den Stack damit
   cmp.b #8,d7                  ; Register lesen?
   beq.s regread                ; jawoll
   cmp.b #9,d7                  ; Register schreiben?
   beq.s regwrite               ; jawoll
   cmp.b #10,d7                 ; DMA-Status lesen?
   bne.s raus                   ; nein, dann ohne Ergebnis raus
**************************
* dmastatus: DMA-Status lesen
**************************
dmastatus:
   move.w #$90,dmodus           ; DMA-Sektorregister anwÑhlen
   move.w dmodus,44(a6)         ; DMA-Status nach temp retten
raus:
   rts                          ; raus hier
**************************
* regread: In parm angegebenes Register
* lesen und in temp ablegen
**************************
regread:
   move.w parm(pc),dmodus       ; Register wÑhlen
   bsr rdfdc                    ; FDC/DMA-Register lesen
   move.w d7,44(a6)             ; Registerinhalt in temp schreiben
   rts
***************************
* regwrite: In parm angegebenes Register
* mit dem Wert aus temp beschreiben
***************************
regwrite:
   move.w temp(pc),d7           ; Wert holen
   and.w #$ff,d7                ; nur unteres Byte beachten
   move.w parm(pc),dmodus       ; Register auswÑhlen
   bra wrfdc                    ; d7 zum FDC schicken

