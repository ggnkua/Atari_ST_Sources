jelma tutkii miss„ kuvaruuturam sijaitsee, ja tallettaa ruudun (ei
;hiirta) levylle. 
;Huom! Ohjelma k„ytt„„ vektoria $502 (scr_dump) joka k„y ainakin ROM
;versiolle. En ole varma toimiiko se levyversiolla.!!!
;************************************************************************
 
alter:    equ       $502


main:     bra       alustus        ;hyp„t„„n alustukseen

;**********************************************************************
;save on osa joka j„„ muistiin kun alustus on k„yty l„pi


save:     movem.l   d0-d7/a0-a6,-(sp) ;t„st„ alkaa talletusohjelma

save1:    bsr       keyin          ;haetaan n„pp„in
          cmp.b     #$20,d0        ;oliko v„lily”nti ?
          bne       load           ;ei, siis lataus
          
          move.w    #$0,-(sp)      ;luodaan tiedosto
          move.l    #nimi,-(sp)    ;nimen osoite                    
          move.w    #$3c,-(sp)     ;luodaan tiedosto
          trap      #1
          lea       8(sp),sp
          
          move.w    d0,handle      ;tiedoston kuvaaja
          
          clr.l     d5
          move.b    $ff8201,d5     ;haetaan ruudun osoite
          lsl.l     #8,d5
          or.b      $ff8203,d5
          lsl.l     #8,d5              

;*********************************************************************
; Kuvan talletus tapahtuu suorassa bitmapped-formaatissa.
; Muuttamalla t„m„n kohdan voi talletus tapahtua my”s esim
; Degasin tai Neocrohmen formaatissa (kuka ne sitten tiet„„kin?).

          move.l    #$ff8240,-(sp) ;talletetaan varit
          move.l    #32,-(sp)
          move.w    handle,-(sp)
          move.w    #$40,-(sp)
          trap      #1
          lea       12(sp),sp          

          move.l    d5,-(sp)       ;talletetaan kuva
          move.l    #32000,-(sp)   ;kuvaruudun pituus
          move.w    handle,-(sp)
          move.w    #$40,-(sp)
          trap      #1
          
          lea       12(sp),sp      ;korjataan pino

loppu:    move.w    handle,-(sp)   ;suljetaan tiedosto
          move.w    #$3e,-(sp)
          trap      #1
          lea       4(sp),sp

          lea       nimi,a0        ;seuraava nimi valmiiksi
          add.b     #1,5(a0)

error:    movem.l   (sp)+,d0-d7/a0-a6          
          rts

nimi:     dc.b      'RUUTU1.DOO',0

          even

handle:   blk.l     1

;**************************************************************************

keyin:    move.w    #$07,-(sp)
          trap      #1
          lea       2(sp),sp
          rts

;**************************************************************************

load:     lea       nimi2,a0       ;kuvan nimen osoite
          move.b    d0,5(a0)       ;muutetaan se oikeaksi

          move.w    #$0,-(sp)      ;avataan tiedosto
          move.l    #nimi2,-(sp)   ;nimen osoite                    
          move.w    #$3d,-(sp)     ;luodaan tiedosto
          trap      #1
          lea       8(sp),sp
          tst.w     d0
          bmi       error          

          move.w    d0,handle      ;tiedoston kuvaaja

;*********************************************************************
; Kuvan lataus tapahtuu suorassa bitmapped-formaatissa.
; Muuttamalla t„m„n kohdan voi lataus tapahtua my”s esim
; Degasin tai Neocrohmen formaatissa (kuka ne sitten tiet„„kin?).

          move.l    #$ff8240,-(sp) ;ladataan varit
          move.l    #32,-(sp)
          move.w    handle,-(sp)
          move.w    #$3f,-(sp)
          trap      #1
          lea       12(sp),sp          

          tst.l     d0
          bmi       error
          
          clr.l     d5
          move.b    $ff8201,d5     ;haetaan ruudun osoite
          lsl.l     #8,d5
          or.b      $ff8203,d5
          lsl.l     #8,d5              

          move.l    d5,-(sp)       ;ladataan kuva
          move.l    #32000,-(sp)   ;kuvaruudun pituus
          move.w    handle,-(sp)
          move.w    #$3f,-(sp)
          trap      #1
          
          lea       12(sp),sp      ;korjataan pino

          move.w    handle,-(sp)   ;suljetaan tiedosto
          move.w    #$3e,-(sp)
          trap      #1
          lea       4(sp),sp

          movem.l   (sp)+,d0-d7/a0-a6          
          rts

nimi2