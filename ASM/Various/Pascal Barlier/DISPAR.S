
;         EFFET DE STORE VENITIEN VERTICAL
;
;         (c) Artipresse & P.Barlier 92

          .PATH 'D:\GFA68000\INCLUDE\'
          .INCLUDE 'ATARI.IS'

          .TEXT 

          .DC.w $a00a                   ; Efface la souris
          Physbase  ;                     Renvoie adresse �cran
          move.l    d0,d7               ; d7=Adresse de l'�cran

;     *** Premi�re partie: Disparition de l'�cran ***

          move.w    #15,d5              ; Boucle 16 fois
.bcl5a:   
          movea.l   d7,a0               ; a0=Adresse de l'�cran
          movea.l   #buffer,a1          ; a1=Adresse du buffer
          move.w    #3999,d0            ; Boucle 4000 fois
.bcl0a:   
          lsr.w     (a0)+               ;D�cale �cran 1 pixel droit
          roxr.w    (a1)+               ;Range pixel dans buffer
          lsr.w     (a0)+
          roxr.w    (a1)+
          lsr.w     (a0)+
          roxr.w    (a1)+
          lsr.w     (a0)+
          roxr.w    (a1)+

          dbra      d0,.bcl0a           ; Fin boucle 4000 fois
          dbra      d5,.bcl5a           ; Fin boucle 16 fois

;     *** Deuxi�me partie: R�apparition de l'�cran ***

          move.w    #15,d5              ; Boucle 16 fois
.bcl5b:   
          movea.l   #buffer,a0          ; a0=Adresse de l'�cran
          movea.l   d7,a1               ; a1=Adresse du buffer
          move.w    #3999,d0            ; Boucle 4000 fois
.bcl0b:   
          lsr.w     (a0)+               ;R�cup�re pixel dans buffer
          roxr.w    (a1)+               ;D�cale �cran en affichant
;                                         le pixel
          lsr.w     (a0)+
          roxr.w    (a1)+
          lsr.w     (a0)+
          roxr.w    (a1)+
          lsr.w     (a0)+
          roxr.w    (a1)+

          dbra      d0,.bcl0b           ; Fin de la boucle 4000 fois
          dbra      d5,.bcl5b           ; Fin de la boucle 16 fois

          Pterm     ;                     Fin du programme

          .BSS 

buffer:   .DS.w 16000                   ; 32000 octets pour �cran

          .END 



