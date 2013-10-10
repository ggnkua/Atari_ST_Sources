; ***************************
; * Shadebob 65536 couleurs *
; *     sur Falcon 030      *
; ***************************
;
; By Dumbo - XXŠme siŠcle


          OUTPUT    "SHADEBOB.PRG"
          MC68030

          TEXT 

initecrv: 
          move.w    #31999,d0	; 32000 pts … effacer
          lea.l     ecrvir,a0	; a0 pointe sur l'‚cran virtuel
beffecv:  clr.w     (a0)+	; On efface
          dbra      d0,beffecv

          move.w    #3,-(sp)	; Cherche l'‚cran logique
          trap      #14
          move.l    d0,a0	; a0 = m‚moire ‚cran
          clr.l     d0
          addq.l    #2,sp
bouclea0:
          lea.l     traject,a4	; a4 pointe sur le pr‚calcul de la traj.
          move.w    (a4)+,d1	; Combien de coordonn‚es ?
bouclea1:
          move.l    (a4)+,d0
          move.w    d1,-(a7)
          bsr.s     affsbob
          move.w    (a7)+,d1
          dbra      d1,bouclea1
          bra.s     bouclea0

affsbob:  
; a0 = adresse ecran
; d0 = position ecran
          lea.l     masque,a1	; a1 = adresse masque
          move.w    (a1)+,d1	; d1 = compteur ligne
          lea.l     ecrvir,a2	; a2 = adresse ecran virtuel
          lea.l     palette,a3	; a3 =adresse palette
          move.l    d0,d2
          lsr.l     #1,d2	; d2 = position ecran virtuel
          move.l    d0,d3	; on sauve d0
          clr.l     d6
          clr.l     d7
affligne: 
          move.l    d3,d4	; sauve d3
          move.l    d2,d5	; sauve d2
          move.w    (a1)+,d6	; Prends l'offset
          add.l     d6,d5	; additionne
          add.l     d6,d4
          add.l     d6,d4
          move.w    (a1)+,d6	; Nombre de pixels par ligne

affpix:   
          move.b    (a2,d5.l),d7
          addq.b    #1,d7
          cmpi.b    #90,d7
          beq.s     retour0
suiter0: 
          move.b    d7,(a2,d5.l)
          lsl.b     #1,d7
          move.w    (a3,d7.w),(a0,d4.l)
          addq.l    #2,d4
          addq.l    #1,d5
          dbra      d6,affpix

          addi.l    #640,d3
          addi.l    #320,d2
          dbra      d1,affligne
          rts       

retour0:  
          clr.b     d7
          bra.s     suiter0


          DATA 

palette:  DC.w $f800,$f802,$f804,$f806,$f808,$f80a,$f80c,$f80e
          DC.w $f811,$f813,$f815,$f817,$f819,$f81b,$f81d,$f81f
          DC.w $e81f,$d81f,$c81f,$b81f,$a81f,$981f,$881f,$701f
          DC.w $601f,$501f,$401f,$301f,$201f,$101f,$001f,$009f
          DC.w $011f,$019f,$023f,$02bf,$033f,$03bf,$045f,$04df
          DC.w $055f,$05df,$067f,$06ff,$077f,$07ff,$07fd,$07fb
          DC.w $07f9,$07f7,$07f5,$07f3,$07f1,$07ee,$07ec,$07ea
          DC.w $07e8,$07e6,$07e4,$07e2,$07e0,$17e0,$27e0,$37e0
          DC.w $47e0,$57e0,$67e0,$77e0,$8fe0,$9fe0,$afe0,$bfe0
          DC.w $cfe0,$dfe0,$efe0,$ffe0,$ff60,$ffe0,$fe60,$fdc0
          DC.w $fd40,$fcc0,$fc40,$fba0,$fb20,$faa0,$fa20,$f980
          DC.w $f9c0,$f880

masque:   DC.w 47		; 48 lignes
          REPT 48
          DC.w 0,47		; offset, longueur de la ligne
          ENDR 
traject:  INCBIN    "A:\COURBE1.CRB"


          BSS 

ecrvir:   DS.b 64000

