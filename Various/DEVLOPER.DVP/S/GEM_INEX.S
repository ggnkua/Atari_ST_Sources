;
; Fichier include pour l'AES et le VDI
; Assembleur		GEM_INEX.S
;

;Ce fichier peut àtre utilisÇ dans vos applications avec
;Include. Cette instruction doit àtre la premiäre de votre
;texte source en assembleur


;GEM_INIT est chargÇ däs le lancement. Il libäre l'espace
;mÇmoire inutilisÇ et met en place les sous-programmes pour
;les appels AES et VDI. De plus, les tableaux de paramätres
;GEM sont crÇÇs.

               INCLUDE 'GEM_INIT.S'

;Apräs l'initialisation, un jump main se trouve dans le fichier
;Include. Cette Çtiquette doit àtre placÇe par le programmeur
;au dÇbut de l'application. La premiäre action sera un appel
;du sous-programme gem_init.


               SECTION TEXT 

gem_init:                 ;Appeler avant le premier call du GEM

;Annonce AES (appl_init):

               move.w     #10,control   ;appl_init (AES)
               clr.w      control+2
               move.w     #1,control+4
               clr.w      control+6
               clr.w      control+8
               jsr        aes
               move.w     int_out,ap_id ;Stocker l'identification dans ap_id

;Annoncer l'Çcran comme station de travail (VDI):

               moveq.l    #18,d0        ;prÇparer intin
               lea.l      intin,a0
gi_lp:         move.w     #1,0(a0,d0.w) ;Mettre l'ÇlÇment Ö 1
               subq.w     #2,d0         ;êlÇment prÇcÇdent
               bpl.s      gi_lp         ;Fin?
               move.w     #2,20(a0)     ;Drapeau de coordonnÇes (toujours 2)

               move.w     #100,contrl   ;v_opnvwk (VDI)
               clr.w      contrl+2
               move.w     #12,contrl+4
               move.w     #11,contrl+6
               move.w     #45,contrl+8
               jsr        vdi
               move.w     contrl+12,handle        ;Handle graphique VDI

               move.w     intout,x_max  ;Stocker la rÇsolution
               move.w     intout+2,y_max
               rts        


gem_exit:                 ;Appeler avant de quitter le programme

               move.w     #101,contrl   ;v_clsvwk (VDI)
               clr.w      contrl+2
               clr.w      contrl+4
               clr.w      contrl+6
               clr.w      contrl+8
               move.w     handle,contrl+12
               jsr        vdi

               move.w     #19,control   ;appl_exit (AES)
               clr.w      control+2
               move.w     #1,control+4
               clr.w      control+6
               clr.w      control+8
               jsr        aes
               rts        


               SECTION BSS 

ap_id:         DS.w 1    ;ap_id, retournÇ par appl_init

handle:        DS.w 1    ;Handle graphique VDI

x_max:         DS.w 1    ;RÇsolution de l'Çcran, obtenue
y_max:         DS.w 1    ;par v_opnvwk
