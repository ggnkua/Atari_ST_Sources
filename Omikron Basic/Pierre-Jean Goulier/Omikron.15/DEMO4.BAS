 '
 ' Easy-Windows.
 ' Programme de d‚monstration No 4.
 '
 ' Un petit programme de d‚monstration sans pr‚tention juste pour montrer
 ' combien il est facile de programmer avec Easy-Windows !
 ' A vous de faire mieux (c'est pas compliqu‚ !)...
 '
 ' ½ P-Jean Goulier & Start Micro / 1994
 '
 ' Il importe d‚ja de savoir … qui on a s'adresse... ST, STE, Falcon ?
 ' Le Cookie-Jar est une adresse qui d‚crit la machine.
 '
 Cookie%L= LPEEK($5A0)
 '
 ' Si le Cookie est nul, c'est un STF !
 '
 IF Cookie%L=0 THEN
   Flag30%L=0
 ELSE
   '
   ' O— se trouve la description du CPU ?
   '
   WHILE MKIL$( LPEEK(Cookie%L))<>"_CPU"
     Cookie%L=Cookie%L+4
   WEND
   '
   ' Testons … pr‚sent si c'est un 68000 ou un 68030.
   '
   IF LPEEK(Cookie%L+4)=30 THEN Flag30%L=-1 ELSE Flag30%L=0
 ENDIF
 '
 ' Maintenant que l'on sait … quelle machine on s'adresse,
 ' on teste la r‚solution et on r‚serve la m‚moire qui s'impose.
 '
 IF Flag30%L THEN
   XBIOS (R%L,$58,-1): XBIOS (Size%L,$5B,R%L)
   IF FRE(0)<4*Size%L+30000 THEN
     MOUSEON
     FORM_ALERT (1,"[3][|M‚moire insuffisante...][Abandon]")
     IF COMPILER THEN SYSTEM ELSE EDIT
   ELSE
     CLEAR (4*Size%L+30000)
     XBIOS (R%L,$58,-1):Nb_Plans%L=2^(R%L AND 7)
   ENDIF
 ELSE
   IF FRE(0)<200000 THEN
     MOUSEON
     FORM_ALERT (1,"[3][|M‚moire insuffisante...][Abandon]")
     IF COMPILER THEN SYSTEM ELSE EDIT
   ELSE
     CLEAR 200000
     XBIOS (Rez%L,4):Nb_Plans%L=1 SHL (2-Rez%L)
   ENDIF
 ENDIF
 '
 '
 ' Initialisation de Easy-Windows.
 ' Chargement du fichier ressource.
 '
 Easy_Init:Init_Rsc
 Rsrc_Load("DEMO4.RSC",V%)
 IF V%<>1 THEN
   FORM_ALERT (1,"[2][|DEMO4.RSC absent...|Modifiez son chemin d'accŠs.][OK]")
   Easy_Exit: CLEAR $10000
   IF COMPILER THEN SYSTEM ELSE EDIT
 ENDIF
 '
 ' Affichage du menu.
 ' Ouverture d'une fenˆtre.
 ' Les handles des fenˆtres sont rang‚s dans un tableau (F%).
 ' Le nombre des fenˆtres est limit‚ … 4; tout le monde n'a pas
 ' un Mega STE 4 Mo, ou un Falcon 14 Mo !
 '
 Rsrc_Gaddr(0,Menu%,Menu_Addr%L):Menu_Bar(Menu_Addr%L)
 Win_Getwork(Desktop%L,Xdesk%L,Ydesk%L,Wdesk%L,Hdesk%L)
 DIM F%(4)
 Gwin_Open(F%(1),Xdesk%L,Ydesk%L,Wdesk%L,Hdesk%L,"SANS NOM","",G_All%L-G_Info%L)
 '
 ' Boucle des ‚vŠnements.
 '
 REPEAT
   Easy_Mesag(Opt%,X$,Mx%L,My%L,Mb%L,Shift%L):Win_Domessages(X$,"fermer")
   '
   ' Si bouton droit activ‚...
   '
   IF Mb%L=2 THEN
     Win_Mousepos(Fen%L,Mx%L,My%L,Xv%L,Yv%L)
     '
     ' Il faut que la fenˆtre soit active !
     '
     IF Fen%L=FN Win_Whichtop%L AND Fen%L<>0 THEN
       IF FN Menu_Checked%L(Main%) THEN Trace_Main(Fen%L,Mx%L,My%L,Xv%L,Yv%L)
       IF FN Menu_Checked%L(Boite%) THEN Trace_Boite(Fen%L,Mx%L,My%L,Xv%L,Yv%L)
       IF FN Menu_Checked%L(Cercle%) THEN Trace_Cercle(Fen%L,Mx%L,My%L,Xv%L,Yv%L)
       IF FN Menu_Checked%L(Remplir%) THEN Trace_Remplir(Fen%L,Mx%L,My%L,Xv%L,Yv%L)
     ENDIF
   ENDIF
   '
   ' Si bouton gauche + ALT...
   '
   IF Mb%L=1 AND Shift%L=8 THEN
     Win_Mousepos(Fen%L,Mx%L,My%L,Xv%L,Yv%L)
     IF Fen%L=FN Win_Whichtop%L AND Fen%L<>0 THEN
       '
       ' Lib‚ration de la m‚moire avant la capture d'un bloc.
       ' Il ne vaut mieux pas qu'ils s'entassent !
       '
       FRE (Block_Addr%L)
       Gwin_Mouseget_Block(Fen%L,Block_Addr%L,Block_Size%L)
     ENDIF
   ENDIF
   '
   ' Si bouton gauche + CTRL...
   '
   IF Mb%L=1 AND Shift%L=4 THEN
     Win_Mousepos(Fen%L,Mx%L,My%L,Xv%L,Yv%L)
     IF Fen%L=FN Win_Whichtop%L AND Fen%L<>0 THEN
       IF FN Menu_Checked%L(Opaque%) THEN M%L=3 ELSE M%L=7
       Gwin_Mouseput_Block(Fen%L,Block_Addr%L,M%L)
     ENDIF
   ENDIF
   '
   ' Test ds options du menu.
   '
   IF Opt%=Info% THEN Info
   IF Opt%=Ouvre% THEN Ouvre
   IF Opt%=Charge% THEN Charge
   IF Opt%=Sauve% THEN Sauve
   IF Opt%=Quitte% THEN Quitte
   IF Opt%=Aide% THEN Aide
   IF Opt%=Crayon% THEN Crayon
   IF Opt%=Gomme% THEN Gomme
   IF Opt%=Main% THEN Main
   IF Opt%=Boite% THEN Boite
   IF Opt%=Cercle% THEN Cercle
   IF Opt%=Remplir% THEN Remplir
   IF Opt%=Opaque% THEN Opaque
   IF Opt%=Trans% THEN Trans
   IF Opt%=Chargeblk% THEN Charge_Bloc
   IF Opt%=Sauveblk% THEN Sauve_Bloc
 UNTIL 0
 '
-Fermer
   F%L=FN Win_Whichtop%L
   FORM_ALERT (1,"[3][|Voulez-vous vraiment fermer|la fenˆtre No"+ STR$(F%L)+" ?][Oui|Non]",Choix%)
   IF Choix%=1 THEN
     Win_Close(F%L)
     '
     ' On libŠre le handle de la fenˆtre ferm‚e pour contr“ler
     ' combien il y a de fenˆtres ouvertes...
     '
     I%=0: REPEAT :I%=I%+1: UNTIL I%=F%L:F%(I%)=0
     Menu_Ienable(Ouvre%,1)
   ENDIF
 RETURN
 '
 DEF PROC Info
   FORM_ALERT (1,"[3][|Programme de d‚monstration|qui utilise EASY-WINDOWS.|½ P-Jean Goulier / 1993][OK]")
 RETURN
 '
 DEF PROC Ouvre
   LOCAL I%=0
   '
   ' On cherche le premier handle disponible pour contr“ler
   ' combien il y a de fenˆtres ouvertes...
   '
   REPEAT :I%=I%+1: UNTIL F%(I%)=0
   '
   ' S'il y en a 4, on d‚sactive l'option d'ouverture.
   '
   IF I%=4 THEN Menu_Ienable(Ouvre%,0)
   Gwin_Open(F%(I%),Xdesk%L+(30*(I%-1)),Ydesk%L+(15*(I%-1)),Wdesk%L-(60*(I%-1)),Hdesk%L-(30*(I%-1)),"SANS NOM","",G_All%L-G_Info%L)
 RETURN
 '
 DEF PROC Charge
   F%L=FN Win_Whichtop%L
   '
   ' Si c'est le bureau qui est actif => pas de fenˆtre ouverte.
   ' Donc, on en ouvre une !
   '
   IF F%L=0 THEN Ouvre:F%L=FN Win_Whichtop%L:Win_Redraw(F%L)
   Nom$="":Index$="*.PIC"
   Easy_Fsel(Nom$,Index$,"Chargez une image",Cancel%L)
   IF NOT Cancel%L THEN
     Gwin_Activate(F%L)
     MOUSEOFF : BLOAD Nom$: MOUSEON
     Gwin_Disactivate
     Win_Redraw(F%L):Win_Title(F%L,Nom$)
   ENDIF
 RETURN
 '
 DEF PROC Sauve
   F%L=FN Win_Whichtop%L: IF F%L=0 THEN EXIT
   Nom$="":Index$="*.PIC"
   Easy_Fsel(Nom$,Index$,"Sauvez une image",Cancel%L)
   IF NOT Cancel%L THEN
     Change_Ext(Nom$,".PIC")
     Gwin_Activate(F%L)
     MOUSEOFF : BSAVE Nom$: MOUSEON
     Gwin_Disactivate:Win_Title(F%L,Nom$)
   ENDIF
 RETURN
 '
 DEF PROC Quitte
   FORM_ALERT (1,"[3][|D‚sirez-vous vraiment|quitter le programme ?][Oui|Non]",Choix%)
   IF Choix%=1 THEN
     Easy_Exit: CLEAR $10000
     IF COMPILER THEN SYSTEM ELSE EDIT
   ENDIF
 RETURN
 '
 DEF PROC Aide
   FORM_ALERT (1,"[1][|Clic D : Dessiner.|ALT+Clic G : Couper bloc.|CTRL+Clic G : Poser bloc.][OK]")
 RETURN
 '
 ' Le reste est une bˆte histoire de "cochage" d'options !
 '
 DEF PROC Crayon
   Menu_Icheck(Crayon%,1):Menu_Icheck(Gomme%,0)
 RETURN
 '
 DEF PROC Gomme
   Menu_Icheck(Crayon%,0):Menu_Icheck(Gomme%,1)
 RETURN
 '
 DEF PROC Main
   LOCAL I%
   Menu_Icheck(Main%,1)
   FOR I%=Boite% TO Remplir%:Menu_Icheck(I%,0): NEXT I%
 RETURN
 '
 DEF PROC Boite
   LOCAL I%
   Menu_Icheck(Boite%,1)
   FOR I%=Main% TO Remplir%
     IF I%<>Boite% THEN Menu_Icheck(I%,0)
   NEXT I%
 RETURN
 '
 DEF PROC Cercle
   LOCAL I%
   Menu_Icheck(Cercle%,1)
   FOR I%=Main% TO Remplir%
     IF I%<>Cercle% THEN Menu_Icheck(I%,0)
   NEXT I%
 RETURN
 '
 DEF PROC Remplir
   LOCAL I%
   Menu_Icheck(Remplir%,1)
   FOR I%=Main% TO Cercle%:Menu_Icheck(I%,0): NEXT I%
 RETURN
 '
 DEF PROC Opaque
   Menu_Icheck(Opaque%,1):Menu_Icheck(Trans%,0)
 RETURN
 '
 DEF PROC Trans
   Menu_Icheck(Opaque%,0):Menu_Icheck(Trans%,1)
 RETURN
 '
 DEF PROC Charge_Bloc
   Nom$="":Index$="*.BLK"
   Easy_Fsel(Nom$,Index$,"Chargez un bloc Bit-Map",Cancel%L)
   IF NOT Cancel%L THEN
     '
     ' On libŠre la m‚moire du bloc pr‚c‚dent (‚ventuellement)
     ' et on cherche la taille du nouveau bloc.
     '
     FRE (Block_Addr%L)
     OPEN "I",16,Nom$:Block_Addr%L= MEMORY( LOF(16)): CLOSE 16
     BLOAD Nom$,Block_Addr%L
     '
     ' Test si le nombre de plans correspond.
     '
     IF WPEEK(Block_Addr%L)<>Nb_Plans%L*2 THEN
       FORM_ALERT (1,"[2][|Mauvaise r‚solution !][Abandon]")
       FRE (Block_Addr%L):Block_Addr%L=0
     ENDIF
   ENDIF
 RETURN
 '
 DEF PROC Sauve_Bloc
   '
   ' Si l'adresse est nulle, il n'y a rien … sauver...
   '
   IF Block_Addr%L=0 THEN EXIT
   Nom$="":Index$="*.BLK"
   Easy_Fsel(Nom$,Index$,"Sauvez un bloc Bit-Map",Cancel%L)
   IF NOT Cancel%L THEN
     Change_Ext(Nom$,".BLK")
     BSAVE Nom$,Block_Addr%L,Block_Size%L
   ENDIF
 RETURN
 '
 ' Dans toutes les fonction de tra‡age, il faut dessiner dans l'espace virtuel
 ' de la fenˆtre graphique (Xv et Yv donn‚es par Win_Mousepos) et sur l'‚cran
 ' physique pour avoir un r‚sultat imm‚diat … l'‚cran (sans quoi, il faudrait
 ' attendre le redessin de la fenˆtre pour voir ce que l'on a trac‚ !)
 ' Pour que l'affichage "en direct" soit r‚aliste, il faut le clipper aux
 ' bornes int‚rieures de la fenˆtre obtenues par Win_Getwork.
 '
 DEF PROC Trace_Main(Fen%L,Mx%L,My%L,Xv%L,Yv%L)
   LOCAL Xi%L,Yi%L,Wi%L,Hi%L:Win_Getwork(Fen%L,Xi%L,Yi%L,Wi%L,Hi%L)
   Gwin_Activate(Fen%L)
   IF FN Menu_Checked%L(Crayon%) THEN
     OUTLINE ON : FILL STYLE =1,1
   ELSE
     OUTLINE OFF : FILL STYLE =0,0
   ENDIF
   MOUSEOFF : PBOX Xv%L,Yv%L,3,3: MOUSEON
   Gwin_Disactivate
   CLIP Xi%L,Yi%L,Wi%L,Hi%L: MOUSEOFF : PBOX Mx%L,My%L,3,3: MOUSEON
 RETURN
 '
 DEF PROC Trace_Boite(Fen%L,Mx%L,My%L,Xv%L,Yv%L)
   LOCAL X%L,Y%L,W%L,H%L,Xi%L,Yi%L,Wi%L,Hi%L:Win_Getwork(Fen%L,Xi%L,Yi%L,Wi%L,Hi%L)
   MODE =3
   WHILE MOUSEBUT : WEND
   REPEAT
     MOUSEOFF
     X%L= MOUSEX :Y%L= MOUSEY
     W%L= ABS(X%L-Mx%L):H%L= ABS(Y%L-My%L)
     BOX Mx%L,My%L,W%L,H%L: BOX Mx%L,My%L,W%L,H%L
     MOUSEON
   UNTIL MOUSEBUT
   MODE =1: FILL STYLE =0,0
   IF FN Menu_Checked%L(Crayon%) THEN OUTLINE ON ELSE OUTLINE OFF
   Gwin_Activate(Fen%L)
   MOUSEOFF : PBOX Xv%L,Yv%L,W%L,H%L: MOUSEON
   Gwin_Disactivate
   CLIP Xi%L,Yi%L,Wi%L,Hi%L: MOUSEOFF : PBOX Mx%L,My%L,W%L,H%L: MOUSEON
   WHILE MOUSEBUT =2: WEND
 RETURN
 '
 DEF PROC Trace_Cercle(Fen%L,Mx%L,My%L,Xv%L,Yv%L)
   LOCAL X%L,Y%L,W%L,H%L,Xi%L,Yi%L,Wi%L,Hi%L:Win_Getwork(Fen%L,Xi%L,Yi%L,Wi%L,Hi%L)
   MODE =3: WHILE MOUSEBUT : WEND
   CLIP Xi%L,Yi%L,Wi%L,Hi%L
   REPEAT
     MOUSEOFF
     X%L= MOUSEX :Y%L= MOUSEY :R%L= ABS(X%L-Mx%L)
     CIRCLE Mx%L,My%L,R%L: CIRCLE Mx%L,My%L,R%L
     MOUSEON
   UNTIL MOUSEBUT
   MODE =1: FILL STYLE =0,0
   IF FN Menu_Checked%L(Crayon%) THEN OUTLINE ON ELSE OUTLINE OFF
   Gwin_Activate(Fen%L)
   MOUSEOFF : PCIRCLE Xv%L,Yv%L,R%L: MOUSEON
   Gwin_Disactivate
   CLIP Xi%L,Yi%L,Wi%L,Hi%L: MOUSEOFF : PCIRCLE Mx%L,My%L,R%L: MOUSEON
   WHILE MOUSEBUT =2: WEND
 RETURN
 '
 DEF PROC Trace_Remplir(Fen%L,Mx%L,My%L,Xv%L,Yv%L)
   LOCAL Xi%L,Yi%L,Wi%L,Hi%L:Win_Getwork(Fen%L,Xi%L,Yi%L,Wi%L,Hi%L)
   IF FN Menu_Checked%L(Crayon%) THEN FILL STYLE =1,1 ELSE FILL STYLE =0,0
   Gwin_Activate(Fen%L)
   IF Nb_Plans%L=1 THEN FILL STYLE = RND(2)+2, RND(23)+1
   IF Nb_Plans%L=2 THEN FILL COLOR = RND(3)+1
   IF Nb_Plans%L>2 THEN FILL COLOR = RND(13)+2
   MOUSEOFF : FILL Xv%L,Yv%L,-1: MOUSEON
   Gwin_Disactivate
   CLIP Xi%L,Yi%L,Wi%L,Hi%L
   MOUSEOFF : FILL Mx%L,My%L,-1: MOUSEON
   FILL STYLE =0,0: FILL COLOR =1
   WHILE MOUSEBUT =2: WEND
 RETURN
 '
 ' Cette fonction renvoie la valeur TRUE (-1) si l'option du menu
 ' envoy‚e comme paramŠtre est coch‚e (Checked).
 '
 DEF FN Menu_Checked%L(Index%)= BIT(2, WPEEK(Menu_Addr%L+Index%*24+10))
 '
 DEF PROC Init_Rsc
   Menu%=0' Arbre menu
   Info%=8'  STRING dans l'arbre MENU
   Ouvre%=17'  STRING dans l'arbre MENU
   Charge%=19'  STRING dans l'arbre MENU
   Sauve%=20'  STRING dans l'arbre MENU
   Chargeblk%=22'  STRING dans l'arbre MENU
   Sauveblk%=23'  STRING dans l'arbre MENU
   Quitte%=25'  STRING dans l'arbre MENU
   Aide%=27'  STRING dans l'arbre MENU
   Crayon%=29'  STRING dans l'arbre MENU
   Gomme%=30'  STRING dans l'arbre MENU
   Opaque%=32'  STRING dans l'arbre MENU
   Trans%=33'  STRING dans l'arbre MENU
   Main%=35'  STRING dans l'arbre MENU
   Boite%=36'  STRING dans l'arbre MENU
   Cercle%=37'  STRING dans l'arbre MENU
   Remplir%=38'  STRING dans l'arbre MENU
 RETURN
