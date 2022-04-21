;*****************************************************************
;*******             INTERFACE FDC/BASIC                  ********
;*****************************************************************

;Hardware-Register

dmamode   = $ff8606
dmascnt   = $ff8604
dmalow    = $ff860d
dmamid    = $ff860b
dmahigh   = $ff8609
giselect  = $ff8800
giwrite   = $ff8802
mfp       = $fffa01

;Mots de contr“le pour le contr“leur DMA (sens des donn‚es DMA => READ) 

srcmd = $80  ; S‚lection du Command-Register
srtrk = $82  ; S‚lection du Track-Register 
srsec = $84  ; S‚lection du Sector-Register
srdat = $86  ; S‚lection du Data-Register
srcnt = $90  ; S‚lection du DMA-Sectorcount-Register

;Mots de contr“le pour le contr“leur DMA (sesn des donn‚es DMA => WRITE)

swcmd = $180 ; signification comme pour => READ
swtrk = $182
swsec = $184
swdat = $186
swcnt = $190

;*****************************************************************
 even
st:
 bra.s run   ; vers d‚but du programme

;************************ Mots de commande *************************

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

;*******************  ParamŠtres de saisie ***********************

prm:   dc.w 00 ; Num‚ro de fonction
       dc.w 00 ; Num‚ro de lecteur
       dc.w 00 ; Num‚ro de piste
       dc.w 00 ; Num‚ro de secteur
       dc.w 00 ; Nombre d'octets … transf‚rer
       dc.w 00 ; Nombre de champ d'ID … lire
       dc.w 00 ; FDC-Status
       dc.w 00 ; DMA-Status
       dc.w 00 ; Timeout? (1=timeout)
       dc.w 00 ; Nombre d'octets transf‚r‚s
       dc.l 00 ; DMA-Start-Adress
       dc.l 00 ; DMA-End-Adress
       dc.l 00 ; Adresse du tampon de piste 
       dc.l 00 ; Adresse du tampon de secteur 
       dc.l 00 ; Adresse du tampon d'ID
       dc.l 00 ; Adresse du tampon d'‚tat de l'ID

;****************    C'est parti !    ***************** 

run:

 tst.w 4(sp)               ; Des paramŠtres ont-ils ‚t‚ donn‚s ?
 bne exit                  ; Oui, retour au BASIC

;Comme on n'a le droit d'adresser la source que relativement au PC, nous 
;prenons A3 comme compteur de programme.

 lea st(pc),a3             ; Program-Start dans Adress-Reg.3
 movem.l d0-d7/a0-a6,savreg-st(a3) ; sauvegarde des Registres 

;*******************  Set Supervisor-Mode  ***********************

 clr.l -(sp)               ; Userstack => Superv.Stack
 move.w #$20,-(sp)         ; Command => Super
 trap #1
 addq.l #6,sp              ; Correction de la pile
 move.l d0,savstack-st(a3) ; sauvegarde de l'ancien Stackpointer 

;*** Suppression de certains Flags et calcul  de l'adresse absolue de *** 
;*** la fonction d‚sir‚e                                       ***

 lea prm-st(a3),a5         ; pointeur sur Parameter-Block

 move.w #1,$43e            ; m‚morisation du Floppy-VBL 
 move.w #0,16(a5)          ; Effacer Timeout-Flag 
 move.w #0,dma-st(a3)      ; Effacer DMA-Flag 
 move.w #0,vblflag-st(a3)  ; Effacer VBL-flag de retour 

 move.w 0(a5),d0           ; R‚cup‚ration du num‚ro de fonction 
 and.l #$0f,d0             ; Il n'y a que 16 fonctions (0-15)
 lsl.l #2,d0               ; fois 4 = functab-Offset

 lea functab-st(a3),a4     ; func-Table-Adress
 move.l 0(a4,d0),d0        ; Adresse de d‚part relative de la routine

 jsr 0(a3,d0)              ; +Programstart=Adr. abs. de la routine

 tst.w vblflag-st(a3)      ; Activtion du VBL (aprŠs d‚selection)?
 beq letoff                ; non
 move.w #0,$43e            ; activation

letoff:

;******************  Retour en User-Mode  ********************  

 move.l savstack-st(a3),d0 ; R‚cup‚ration de l'ancien Stackpointer
 move.l d0,-(a7)           ; Saisie de l'‚ncien Stackpointer
 move.w #$20,-(sp)         ; Command => Super
 trap #1
 addq.l #6,sp              ; Correction de la pile 

 movem.l savreg-st(a3),d0-d7/a0-a6 ; Recup‚ration du registre 

exit:
 rts                       ; retour au  BASIC 


; Voila ! Maintenant, vos avez (seulement) les routines 


;***********************  Restore FDC ****************************

restore:

 move.w #srcmd,dmamode     ; S‚lection du Command-Reg. 
 move.w rest-st(a3),d7     ; Command => Restore
 bsr wrt1772               ; Envoi de la commande 
 bsr fdcwait               ; Attente jusqu'… ce que FDC soit prˆt 
 rts
 
;***********************  SEEK TRACK  ****************************

seek:

 move.w #srdat,dmamode     ; S‚lection du registre de donn‚es 
 move.w 4(a5),d7           ; Tracknr. dans d7
 bsr wrt1772               ; Ecrire Tracknr. 
 move.w #srcmd,dmamode     ; S‚lection du Command-Reg.
 move.w see-st(a3),d7      ; Command => Seek
 bsr wrt1772               ; Ecrire commande 
 bsr fdcwait               ; Attente jusqu'… ce que FDC soit prˆt 
 rts

;************************  Step  *********************************

step:

 move.w #srcmd,dmamode     ; S‚lection du FDC-Commandreg. 
 move.w stp-st(a3),d7      ; Command => Step
 bsr wrt1772               ; Ecrire commande 
 bsr fdcwait               ; Attente jusqu'… ce que FDC soit prˆt
 rts

;*************************  Step in  *****************************                            

stepin:

 move.w #srcmd,dmamode     ; S‚lection du FDC-Commandreg. 
 move.w stpi-st(a3),d7     ; Command => Step in
 bsr wrt1772               ; Ecrire commande 
 bsr fdcwait               ; Attente jusqu'… ce que FDC soit prˆt 
 rts

;************************  Step out  *****************************

stepout:

 move.w #srcmd,dmamode     ; S‚lection du FDC-Commandreg. 
 move.w stpo-st(a3),d7     ; Command => Step out 
 bsr wrt1772               ; Ecrire commande 
 bsr fdcwait               ; Attente jusqu'… ce que FDC soit prˆt 
 rts

;***********************  Force Interrupt  ***********************

Force:

 move.w forc-st(a3),d7     ; Command => Force Interrupt
 bsr wrt1772               ; Ecrire commande 
 move.w #$100,d7           ; Boucle de temporisation 
wtfrc:
 dbra d7,wtfrc
 rts

;*********************  READ SECTOR(S)  **************************

readsector:

 move.l 32(a5),d7          ; DMA-Adress sur tampon de secteur
 bsr setdma
 move.w #1,dma-st(a3)      ; Positionner DMA-Flag 
 move.w #srcnt,dmamode     ; DMA-R/W toggel (Flip/Flop)
 move.w #swcnt,dmamode
 move.w #srcnt,dmamode     ; S‚lection du DMA-Sectorcount 
 move.w #$0c,d7            ; Charger avec  12  (Correspond …  6ko)
 bsr wrt1772               ; Charger DMA-Scnt 

 move.w #srsec,dmamode     ; S‚lectionner Sector-Reg. 
 move.w 6(a5),d7           ; Sektor-Nr. dans d7
 bsr wrt1772               ; Ecrire Sektor-Nr. 

 move.w #srcmd,dmamode     ; S‚lection du Command-Reg. 
 move.w rsec-st(a3),d7     ; Command => Read multiple Sectors
 bsr wrt1772               ; Ecrire commande 

 bsr fdcwait               ; attente jusqu'… ce que FDC soit prˆt 
 bsr readstat              ; Lire ‚tat et nbr d'octets 
 rts

;**********************  Read Address  ***************************

readaddress:

 move.l 40(a5),a4          ; Charger adresse du tampon d'‚tat 
 move.l 36(a5),d7          ; DMA-Adress sur tampon de champ d'ID 
 bsr setdma
 move.w #srcnt,dmamode     ; DMA-R/W toggel
 move.w #swcnt,dmamode
 move.w #srcnt,dmamode     ; S‚lection du DMA-Sectorcount 
 move.w #$01,d7            ; Charger avec  1  (Correspond …  512 octets)
 bsr wrt1772
 move.w #srcmd,dmamode     ; S‚lection du FDC-Commandreg. 
 move.w 10(a5),d4          ; #ID-Felder dans D4
 and.w  #$7f,d4            ; Mais au  max. 128

idloop:
 move.w radr-st(a3),d7     ; Command => Read Address
 bsr wrt1772               ; Ecrire commande 
 bsr fdcwait               ; attente jusqu'… ce FDC soit prˆt
 move.b d0,(a4)+           ; Mettre l'‚tat dans le tampon 
 tst.w 16(a5)              ; Timeout ?
 dbne d4,idloop            ; non, lire chemp suivant
 bsr readstat              ; Lire ‚tat et nombre d'octets 
 rts

;***********************  READ TRACK  ****************************

readtrack:

 move.l 28(a5),d7          ; DMA-Adress sur Track-Buffer
 bsr setdma
 move.w #1,dma-st(a3)      ; Positionner DMA-Flag 
 move.w #srcnt,dmamode     ; DMA-R/W toggel
 move.w #swcnt,dmamode
 move.w #srcnt,dmamode     ; S‚lection DMA-Sectorcount 
 move.w #$0e,d7            ; charger avec 14 (correspond …  7ko)
 bsr wrt1772
 move.w #srcmd,dmamode     ; S‚lection du Command-Reg. 
 move.w rtrk-st(a3),d7     ; Command => Read Track
 bsr wrt1772               ; Ecrire commande 
 bsr fdcwait               ; Attente jusqu'… ce que FDc soit prˆt 
 bsr readstat              ; Lire l'‚tat et le nombre d'octets 
 rts

;*********************  WRITE SECTOR(S)  *************************

writesector:

 move.l 32(a5),d7          ; DMA-Adress sur Sector-Buffer
 bsr setdma
 move.w #1,dma-st(a3)      ; Positionner DMA-Flag 
 move.w #swcnt,dmamode     ; DMA-R/W toggel
 move.w #srcnt,dmamode
 move.w #swcnt,dmamode     ; S‚lection du DMA-Sectorcount 
 move.w #$0c,d7            ; charger avec 12  (correspond …  6ko)
 bsr wrt1772               ; Ecrire DMA-Scnt 
 move.w #swsec,dmamode     ; S‚lectionner Sector-Reg. 
 move.w 6(a5),d7           ; Sektornr. dans d7
 bsr wrt1772               ; Ecrire Sektor-Reg. 

 move.w #swcmd,dmamode     ; S‚lectionner Command-Reg. 
 move.w wsec-st(a3),d7     ; Command => Write multiple Sectors
 bsr wrt1772               ; Ecrire commande 
 bsr fdcwait               ; Attente jusqu'… ce que FDC soit prˆt
 bsr readstat              ; Lire l'‚tat et le nombre d'octets 
 rts

;**********************  WRITE TRACK  ****************************

writetrack:

 move.l 28(a5),d7          ; DMA-Adress sur Track-Buffer
 bsr setdma
 move.w #1,dma-st(a3)      ; Positionner DMA-Flag 
 move.w #swcnt,dmamode     ; DMA-R/W toggel
 move.w #srcnt,dmamode
 move.w #swcnt,dmamode     ; S‚lectionner DMA-Sectorcount 
 move.w #$0e,d7            ; Charger avec 14 (correspond … 7ko)
 bsr wrt1772               ; Ecrire DMA-Scnt 
 move.w #swcmd,dmamode     ; S‚lectionner Command-Reg. 
 move.w wtrk-st(a3),d7     ; Command => Write Track
 bsr wrt1772               ; Ecrire commande 
 bsr fdcwait               ; attente jusqu'… ce que FDC soit prˆt
 bsr readstat              ; Lire l'‚tat et le nombre d'octets 
 rts

;*****************************************************************
;*****************************************************************

;C'‚taient les routines appelant les commandes du WD 1772 
;
;Voici d'autre sous-routines qui sont appel‚es partiellement par 
;la routine principale et partiellement par le BASIC (p.ex. setdrive)
;

;*****************  Lecture du Sector-Register   ***********************

rsecreg:

 move.w #srsec,dmamode     ; S‚lection du  Sector-Reg. 
 bsr read1772              ; et lecture 
 and.w #$ff,d0             ; Seulement octets faibles 
 move.w d0,6(a5)           ; dans le FDC-Array
 move.w #srcmd,dmamode     ; S‚lection du Command-Reg. 
 rts

;*******************  Lecture du Track-Register   **********************

rtrkreg:

 move.w #srtrk,dmamode     ; S‚lection du track-Reg. 
 bsr read1772              ; et lecture 
 and.w #$ff,d0             ; Seulement octets faibles
 move.w d0,4(a5)           ; dans  FDC-Array
 move.w #srcmd,dmamode     ; S‚lection du Command-Reg. 
 rts

;*********************  Lecture du Status-Reg.   ***********************

rstareg:

 move.w #srcmd,dmamode     ; S‚lection du Status-Reg. 
 bsr read1772              ; et lecture 
 and.w #$ff,d0             ; Etat dans les octets faibles 
 move.w d0,12(a5)          ; dans le  FDC-Array
 rts

;********************  Ecriture du Track-Reg.   **********************

wtrkreg:

 move.w #srtrk,dmamode     ; S‚lection du track-Reg. 
 move.w 4(a5),d7           ; R‚cup‚rer nø de piste 
 and.w #$ff,d7
 bsr wrt1772               ; et ‚crire
 move.w #srcmd,dmamode     ; S‚lection du Command-Reg. 
 rts

;********************  Set DMA-Transfer Adress  *****************

setdma:

 move.l d7,20(a5)          ; Mettre Start-Adress dans FDC-Array 
 move.b d7,dmalow          ; Ecrire d'abord  Low-Byte
 lsr.l #8,d7
 move.b d7,dmamid          ; puis Mid-Byte
 lsr.l #8,d7
 move.b d7,dmahigh         ; et enfin  High-Byte

 move.l 20(a5),d7          ; R‚cup‚ration de la Start-Adress
 clr.l d6
 move.w 8(a5),d6           ; Nombre d'octets … transf‚rer
 add.l d6,d7               ; Addition des deux
 move.l d7,24(a5)          ; =Adresse de fin attendue
 rts

;*** Lecture du DMA-Status; calcul des octets … transf‚rer  ***

readstat:

 move.w dmamode,d0         ; Lecture du DMA-Status 
 and.w #$7,d0              ; Prendre seulement les 3 bits inf‚rieurs 
 move.w d0,14(a5)          ; ert aprŠs fdcout

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

;*****************    Ecriture du FDC-Register    *******************

wrt1772:

 bsr wait
 move.w d7,dmascnt       ; Ecrire FDC-Reg. ou DMA-Sectorcount 
 bsr wait
 rts

;*****************     Lecture du FDC-Register      ********************

read1772:

 bsr wait
 move.w dmascnt,d0        ; Lire FDC-Reg. ou DMA-Sectorcount 
 bsr wait
 rts

;****************    Attente jusqu'… ce que FDC soit prˆt *****************

fdcwait:

 move.l #$180,d5           ; Attendre un peu jusqu'… ce Busy soit positionn‚
litlwt:
 dbra d5,litlwt

 move.l #$40000,d5         ; d5 sert de compteur Timeout
 cmp.w #$9,0(a5)           ; Commande READ-ADDRESS?
 bne readmfp
 move.l #$28000,d5         ; Oui, timeout plus court

readmfp:

 btst #5,mfp               ; Commande finie ?
 beq fdcready              ; oui

 subq.l #1,d5              ; non, D‚cr‚menter compteur Timeout
 beq timeout               ; Si arriv‚ … la fin

 tst.w dma-st(a3)          ; Commande de transfert de donn‚es ?
 beq readmfp               ; non, Continuer le test

 move.b dmahigh,temp+1-st(a3)  ; C'est la  DMA-Endadress attendue
 move.b dmamid,temp+2-st(a3)   ; d‚j… atteinte ?
 move.b dmalow,temp+3-st(a3)
 move.l temp-st(a3),d7
 cmp.l 24(a5),d7
 blt readmfp               ; non, continuer … tester

 bsr force                 ; Si oui, interrompre la commande
 move.w #0,dma-st(a3)      ; Effacer dma-Flag 
 bra fdcready              ; et quitter normalement la routine

timeout:

 move.w dmascnt,d0         ; Lire l'‚tat avant l'interruption
 and.w #$ff,d0             ; Masquer l'octet de poids fort
 move.w d0,12(a5)          ; Et mettre dans l'Array
 bsr force                 ; ArrŠter la commande
 move.w #1,16(a5)          ; Positionner Timeoutflag 
 rts

fdcready:

 move.w dmascnt,d0         ; Lire l'‚tat
 and.w #$ff,d0             ; Masquer l'octet de poids fort
 move.w d0,12(a5)          ; et mettre dans le FDC-Array
 rts

;************  Attendre jusqu'… ce que le moteur soit arrŠt‚ ************

motoroff:

 move.w #srcmd,dmamode     ; S‚lection du Statusreg. 
test:
 bsr read1772              ; et lecture
 btst #7,d0                ; Motor-on positionn‚
 bne test                  ; oui, continuer l'attente
 rts

;*************************    Wait   *****************************

wait:

 move.w sr,-(a7)           ; Sauvegarder Status 
 move.w #$20,d5            ; d5 sert de compteur
wt2:
 dbf d5,wt2
 move.w (a7)+,sr           ; R‚cup‚rer Status 
 rts

;*****************  S‚lection du lecteur et de la piste  ****************

setdrive:

 clr.l d7
 move.w 2(a5),d7           ; R‚cup‚rer Drive-Nr.
 bne set
 bsr motoroff              ; Si 0, d'abord d‚selectionner quand motor OFF
 move.w #1,vblflag-st(a3)  ; Positionner flag de retour de VBL
set:
 eor.b #7,d7               ; Inverser les Bits pour le  Hardware 
 and.b #7,d7               ; Seuls les 3 Low-Bits sont modifi‚s
 move.w sr,-(a7)           ; Sauvegarder Status 
 or.w #$700,sr             ; D‚sactiver Interruptions
 move.b #$e,giselect       ; S‚lectionner Port A du Sound-Chips 
 move.b giselect,d0        ; Lire Port A 
 and.b  #$f8,d0            ; Effacer Bits 0-2 
 or.b   d0,d7              ; Positionner nouveaux bits 
 move.b d7,giwrite         ; Et ‚crire sur  Port A 
 move.w (a7)+,sr           ; restore Status
 rts

;*****************************************************************
;*******************  Variables und Tableaux  ********************
;*****************************************************************

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

;***************************** FIN ******************************





