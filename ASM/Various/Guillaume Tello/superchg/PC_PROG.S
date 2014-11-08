; ****************************************
; Exemple d'utilisation de SUPERCHARGER
; Passage d'un fichier texte en majuscules
; 1997 Guillaume Tello, gtello@wanadoo.fr
; ****************************************
;
; assembl‚ avec A86.COM en PC_PROG.BIN


     org 0000

lire_taille:            ; recoit un mot en deux octets

	; **** r‚pond … ENVOIE_OCTET ****
     mov ah,9           ; recoit un octet
     int 060
     mov bh,al          ; rang‚ dans l'octet fort de BX

	; **** r‚pond … ENVOIE_OCTET ****
     mov ah,9           ; recoit un autre octet
     int 060
     mov bl,al          ; rang‚ dans l'octet faible de BX

     cmp bx,0       		; Commande 0 = Retour en esclave
     jnz pas_fin

     mov ah,0
     int 060            ; bye bye, retour en esclave

pas_fin:
     cmp bx,1				; Commande 1 = Reset total
     jnz pas_reset

     mov ah,1
     int 060				; bye bye, reset total

pas_reset:					; sinon, BX est la taille du fichier

	; **** r‚pond … ENVOIE_DONNEES ****
     mov cx,bx          ; nombre d'octets … lire
     xor di,di
     mov dx,0400
     mov es,dx				; j'ai choisi la zone es:di=0400:0000
     xor si,si
     mov ds,dx				; pareil pour ds:si=0400:0000
     mov ah,4
     int 060            ; lit les donnees en es:di

     cld                ; di et si seront increment‚s avec lodsb/stosb
     xor ax,ax				; AX=0

boucle:
     lodsb    		      ; lit un caractŠre de ds:si, incr‚mente 'si'
     cmp ax,97          ; a minuscule
     jb pas_minus       ; en dessous...
     cmp ax,122         ; z minuscule
     jg pas_minus       ; au dessus
     sub al,32          ; d‚cale vers majuscule
pas_minus:
     stosb              ; range le caractŠre en es:di, incr‚mente 'di'
     loop boucle        ; boucle sur CX

	; **** r‚pond … RECOIT_DONNEES ****
     mov cx,bx          ; nombre d'octets
     xor si,si
     mov dx,0400
     mov ds,dx          ; retour … ds:si=0400:0000
     mov ah,5
     int 060				; renvoit le texte
     jmp lire_taille	   ; boucle infiniment