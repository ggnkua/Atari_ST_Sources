

		Include "_Equ.s"

		IFND	VDemo
VDemo		equ 	0
		ENDC
	
		SECTION DATA_F

*-----------------------------------------------------------------
*	 **  *    * **** ****    ***    **  **** ***  ***
* 	*  * **  ** *  * *       *  *  *  * *     *  *
* 	**** * ** * *  * ****    ****  **** ****  *  *
* 	*  * *    * *  *    *    *   * *  *    *  *  *  
* 	*  * *    * **** ****    ****  *  * **** ***  ***
*-----------------------------------------------------------------
*	POINTEURS SUR DONNEES
*-----------------------------------------------------------------
Mixed:		equ %0100000000000000
Fixed:		equ %0010000000000000
Keys:		equ %0001000000000000
Empty:		equ %0000100000000000
***************
		dc.l DataLong
***************
ZZ:		
*************** Pointadataeurs sur messages
AEdMem:		dc.w _EdMem-ZZ+DataLong,$0001
AEdOm:		dc.w _EdOm-ZZ+DataLong,$0001
AEdTop:		dc.w _EdTop-ZZ+DataLong,$0001
AEdBot:		dc.w _EdBot-ZZ+DataLong,$0001
AEdLLong:	dc.w _EdLLong-ZZ+DataLong,$0001
AEdTest:	dc.w _EdTest-ZZ+DataLong,$0001
AEdNoE:		dc.w _EdNoE-ZZ+DataLong,$0001
AEdInd:		dc.w _EdInd-ZZ+DataLong,$0001
ANoFold		dc.w _NoFold-ZZ+DataLong,$0001
ANMark		dc.w _NMark-ZZ+DataLong,$0001
AWBloc		dc.w _WBloc-ZZ+DataLong,$0001
ANFound		dc.w _NFound-ZZ+DataLong,$0001
ASching		dc.w _Sching-ZZ+DataLong,$0001
AMPAmos		dc.w _MPAmos-ZZ+DataLong,$0001
AMPlace		dc.w _MPlace-ZZ+DataLong,$0001
AAvNoProg	dc.w _AvNoProg-ZZ+DataLong,$0001
AMesNotD:	dc.w _MesNotD-ZZ+DataLong,$0001
ACloClo:	dc.w _CloClo-ZZ+DataLong,$0001
AEdDemo:	dc.w _EdDemo-ZZ+DataLong,$0001

AVIlD:		dc.w _VIlD-ZZ+DataLong,$0002
AVSynt:		dc.w _VSynt-ZZ+DataLong,$0002
AVLong:		dc.w _VLong-ZZ+DataLong,$0002
AVType:		dc.w _VType-ZZ+DataLong,$0002
AVOut:		dc.w _VOut-ZZ+DataLong,$0002
AVVNm:		dc.w _VVNm-ZZ+DataLong,$0002
AVNmO:		dc.w _VNmO-ZZ+DataLong,$0002
AVNDim:		dc.w _VNDim-ZZ+DataLong,$0002
AVLbl2:		dc.w _VLbl2-ZZ+DataLong,$0002
AVUnd:		dc.w _VUnd-ZZ+DataLong,$0002
AVAlD:		dc.w _VAlD-ZZ+DataLong,$0002
AVFoN:		dc.w _VFoN-ZZ+DataLong,$0002
AVNFo:		dc.w _VNFo-ZZ+DataLong,$0002
AVRUn:		dc.w _VRun-ZZ+DataLong,$0002
AVUnR:		dc.w _VUnR-ZZ+DataLong,$0002
AVWWn:		dc.w _VWWn-ZZ+DataLong,$0002
AVWnW:		dc.w _VWnW-ZZ+DataLong,$0002
AVDoL:		dc.w _VDoL-ZZ+DataLong,$0002
AVLDo:		dc.w _VLDo-ZZ+DataLong,$0002
AVCrs:		dc.w _VCrs-ZZ+DataLong,$0002
AVNoL:		dc.w _VNoL-ZZ+DataLong,$0002
AVEIf:		dc.w _VEIf-ZZ+DataLong,$0002
AVElE:		dc.w _VElE-ZZ+DataLong,$0002
AVElI:		dc.w _VElI-ZZ+DataLong,$0002
AVIfE:		dc.w _VIfE-ZZ+DataLong,$0002
AVNoT:		dc.w _VNoT-ZZ+DataLong,$0002
AVPDeb:		dc.w _VPDeb-ZZ+DataLong,$0002
AVPOp:		dc.w _VPOp-ZZ+DataLong,$0002
AVPNo:		dc.w _VPNo-ZZ+DataLong,$0002
AVIlP:		dc.w _VIlP-ZZ+DataLong,$0002
AVPRTy:		dc.w _VPRTy-ZZ+DataLong,$0002
AVUndP:		dc.w _VUndP-ZZ+DataLong,$0002
AVShP:		dc.w _VShP-ZZ+DataLong,$0002
AVAlG:		dc.w _VAlG-ZZ+DataLong,$0002
AVPaG:		dc.w _VPaG-ZZ+DataLong,$0002
AVShal:		dc.w _VShal-ZZ+DataLong,$0002
AVNoPa:		dc.w _VNoPa-ZZ+DataLong,$0002
AVPaGo:		dc.w _VPaGo-ZZ+DataLong,$0002
AVVTo:		dc.w _VVTo-ZZ+DataLong,$0002
AVDal:		dc.w _VDal-ZZ+DataLong,$0002
AVNoB:		dc.w _VNoB-ZZ+DataLong,$0002
AVExN:		dc.w _VExN-ZZ+DataLong,$0002
AVNFn:		dc.w _VNFn-ZZ+DataLong,$0002
AExtNot:	dc.w _ExtNot-ZZ+DataLong,$0000

AMErreur:	dc.w _MErreur-ZZ+DataLong,$8003
ARedo:		dc.w _Redo-ZZ+DataLong,$0003+Mixed

AExtNames:	dc.w _ExtNames-ZZ+DataLong,$8004

ASelDrv:	dc.w _SelDrv-ZZ+DataLong,$0020
ANmPrt:		dc.w _NmPrt-ZZ+DataLong,$0005
ANmSer:		dc.w _NmSer-ZZ+DataLong,$0005

AMesLd1:	dc.w _MesLd1-ZZ+DataLong,$0006+Empty
AMesLd2:	dc.w _MesLd2-ZZ+DataLong,$0006+Empty
AMesLd3:	dc.w _MesLd3-ZZ+DataLong,$0006+Empty
AMesMe1:	dc.w _MesMe1-ZZ+DataLong,$0006+Empty
AMesMe2:	dc.w _MesMe2-ZZ+DataLong,$0006+Empty
AMesLdA1:	dc.w _MesLdA1-ZZ+DataLong,$0006+Empty
AMesLdA2:	dc.w _MesLdA2-ZZ+DataLong,$0006+Empty
AMesLdA3:	dc.w _MesLdA3-ZZ+DataLong,$0006+Empty
AAvMe:		dc.w _AvMe-ZZ+DataLong,$0006+Empty
AAvLd:		dc.w _AvLd-ZZ+DataLong,$0006+Empty
AAvPrt:		dc.w _AvPrt-ZZ+DataLong,$0006+Empty
AMesSv1:	dc.w _MesSv1-ZZ+DataLong,$0006+Empty
AMesSv2:	dc.w _MesSv2-ZZ+DataLong,$0006+Empty
AMesSBl1:	dc.w _MesSBl1-ZZ+DataLong,$0006+Empty
AMesSBl2:	dc.w _MesSBl2-ZZ+DataLong,$0006+Empty
AMesSvA1:	dc.w _MesSvA1-ZZ+DataLong,$0006+Empty
AMesSvA2:	dc.w _MesSvA2-ZZ+DataLong,$0006+Empty
AMesSvA3:	dc.w _MesSvA3-ZZ+DataLong,$0006+Empty
AAvSv:		dc.w _AvSv-ZZ+DataLong,$0006+Empty
AAvSvA:		dc.w _AvSvA-ZZ+DataLong,$0006+Empty
AMesAc1:	dc.w _MesAc1-ZZ+DataLong,$0006+Empty
AMesAc2:	dc.w _MesAc2-ZZ+DataLong,$0006+Empty
AMesAc3:	dc.w _MesAc3-ZZ+DataLong,$0006+Empty
AMesAn1:	dc.w _MesAn1-ZZ+DataLong,$0006+Empty
AMesAn2:	dc.w _MesAn2-ZZ+DataLong,$0006+Empty
AMesAn3:	dc.w _MesAn3-ZZ+DataLong,$0006+Empty
AMesEd1:	dc.w _MesEd1-ZZ+DataLong,$0006+Empty
AMesEd2:	dc.w _MesEd2-ZZ+DataLong,$0006+Empty
AMesEd3:	dc.w _MesEd3-ZZ+DataLong,$0006+Empty
AMesRn1:	dc.w _MesRn1-ZZ+DataLong,$0006+Empty
AMesRn2:	dc.w _MesRn2-ZZ+DataLong,$0006+Empty
AMesRn3:	dc.w _MesRn3-ZZ+DataLong,$0006+Empty
AAvAccL:	dc.w _AvAccL-ZZ+DataLong,$0006+Empty

AEdPName:	dc.w _EdPName-ZZ+DataLong,$0001
AEdLName:	dc.w _EdLName-ZZ+DataLong,$0001
ASMark:		dc.w _SMark-ZZ+DataLong,$0001
AEdTSize:	dc.w _EdTSize-ZZ+DataLong,$0001
AEdTTab:	dc.w _EdTTab-ZZ+DataLong,$0001
ASchinp:	dc.w _Schinp-ZZ+DataLong,$0001
ARepinp:	dc.w _Repinp-ZZ+DataLong,$0001

AFsTxt:		dc.w _FsTxt-ZZ+DataLong,$800b+Fixed
AFaTxt:		dc.w _FaTxt-ZZ+DataLong,$800b+Fixed
AFsWait:	dc.w _FsWait-ZZ+DataLong,$000b
AFsDTit:	dc.w _FsDTit-ZZ+DataLong,$000b
AFsDirSet:	dc.w _FsDirSet-ZZ+DataLong,$000b

*************** Messages editeur
AConfYes:	dc.w _ConfYes-ZZ+DataLong,$0000
AConfNo:	dc.w _ConfNo-ZZ+DataLong,$0000
AConfConf:	dc.w _ConfConf-ZZ+DataLong,$0001
AConfSave:	dc.w _ConfSave-ZZ+DataLong,$0001
AConfText:	dc.w _ConfText-ZZ+DataLong,$0001
ADispText:	dc.w _DispText-ZZ+DataLong,$0001

AConfYN:	dc.w _ConfYN-ZZ+DataLong,$0000+Mixed
AConfYi:	dc.w _ConfYi-ZZ+DataLong,$0000+Mixed
AConfNi:	dc.w _ConfNi-ZZ+DataLong,$0000+Mixed

*************** Touches de fonction
AFkDef1:	dc.w _FkDef1-ZZ+DataLong,$0007+Mixed+Fixed
AFkDef2:	dc.w _FkDef2-ZZ+DataLong,$0007+Mixed+Fixed
AFkDef3:	dc.w _FkDef3-ZZ+DataLong,$0007+Mixed+Fixed
AFkDef4:	dc.w _FkDef4-ZZ+DataLong,$0007+Mixed+Fixed
AFkDef5:	dc.w _FkDef5-ZZ+DataLong,$0000
AFkIt0:		dc.w _FkIt0-ZZ+DataLong,$0007+Fixed
AFkIt1:		dc.w _FkIt1-ZZ+DataLong,$0007+Fixed
AFkLt0:		dc.w _FkLt0-ZZ+DataLong,$0007+Fixed
AFkLt1:		dc.w _FkLt1-ZZ+DataLong,$0007+Fixed

*************** Flash curseur
AEdFlCu:	dc.w _EdFlCu-ZZ+DataLong,$0000
AFolFl:		dc.w _FolFl-ZZ+DataLong,$0000

*************** Ecrans erreurs
AErrLine:	dc.w _ErrLine-ZZ+DataLong,$000a
AErrFin:	dc.w _ErrFin-ZZ+DataLong,$000a+Mixed
AFolI2:		dc.w _FolI2-ZZ+DataLong,$000a+Mixed

*************** Directory
ADirFilt:	dc.w _DirFilt-ZZ+DataLong,$0010
AChDir0:	dc.w _ChDir0-ZZ+DataLong,$000b+Mixed
AChDir1:	dc.w _ChDir1-ZZ+DataLong,$000b+Mixed
AChDir6:	dc.w _CHDir6-ZZ+DataLong,$000b+Mixed
AChDir3:	dc.w _ChDir3-ZZ+DataLong,$000b

*************** Ligne d'etat
AMrgMes		dc.w _MrgMes-ZZ+DataLong,$0001+Mixed+Fixed
* Caps
AEtCps0:	dc.w _EtCps0-ZZ+DataLong,$0001+Mixed+Fixed
AEtCps1:	dc.w _EtCps1-ZZ+DataLong,$0001+Mixed+Fixed
* Insert / OverW
AEtIns0:	dc.w _EtIns0-ZZ+DataLong,$0001+Mixed+Fixed
AEtIns1:	dc.w _EtIns1-ZZ+DataLong,$0001+Mixed+Fixed
* Line #
AEtY:		dc.w _EtY-ZZ+DataLong,$0001+Mixed+Fixed
AEtY1:		dc.w _EtY1-ZZ+DataLong,$0001+Mixed+Fixed
* Col#
AEtX:		dc.w _EtX-ZZ+DataLong,$0001+Mixed+Fixed
AEtX1:		dc.w _EtX1-ZZ+DataLong,$0001+Mixed+Fixed
* Free
AEtFr0:		dc.w _EtFr0-ZZ+DataLong,$0001+Mixed+Fixed
AEtFr1:		dc.w _EtFr1-ZZ+DataLong,$0001+Mixed+Fixed
* Chip
AEtCh0:		dc.w _EtCh0-ZZ+DataLong,$0001+Mixed+Fixed
AEtCh1:		dc.w _EtCh1-ZZ+DataLong,$0001+Mixed+Fixed
* Fast
AEtFs0:		dc.w _EtFs0-ZZ+DataLong,$0001+Mixed+Fixed
AEtFs1:		dc.w _EtFs1-ZZ+DataLong,$0001+Mixed+Fixed
* Editing
AEtNm1:		dc.w _EtNm1-ZZ+DataLong,$0001+Mixed+Fixed
AEtNm2:		dc.w _EtNm2-ZZ+DataLong,$0001+Mixed+Fixed

*************** TABLE DES FONCTIONS DE L'EDITEUR
AKFonc:		dc.w _KFonc-ZZ+DataLong,$000F+Keys

*************** HELP escape
AEscH1:		dc.w _EscH1-ZZ+DataLong,$000c+Mixed
AEscH2:		dc.w _EscH2-ZZ+DataLong,$800c+Fixed
	
*************** Touches de fonction ESC par defaut
AAmiDef:	dc.w _AmiDef-ZZ+DataLong,$800d+Empty

*************** Auto loaded acc
AAutoLd		dc.w _AutoLd-ZZ+DataLong,$8011+Empty

*************** Help.Acc
ANameHelp	dc.w _NameHelp-ZZ+DataLong,$0013+Empty
AHelpLoad	dc.w _HelpLoad-ZZ+DataLong,$0013+Empty
AHNof		dc.w _HNoF-ZZ+DataLong,$0013

* Pas touche!!!
*************** Entete du basic
AEntete:	dc.w _Entete-ZZ+DataLong,0
*************** Fenetre FK
AFkFond:	dc.w _FkFond-ZZ+DataLong,0 
*************** Fenetre edit
AEdClw:		dc.w _EdClw-ZZ+DataLong,0 
ASlDInit:	dc.w _SlDInit-ZZ+DataLong,0 
ASlBInit:	dc.w _SlBInit-ZZ+DataLong,0 
AEdDBloc	dc.w _EdDBloc-ZZ+DataLong,0 
AEdFBloc	dc.w _EdFBloc-ZZ+DataLong,0 
*************** Titre du basic
ATitle1:	dc.w _Title1-ZZ+DataLong,$000e+Mixed+Fixed+Empty
ATitle2:	dc.w _Title2-ZZ+DataLong,0 
*************** Suffixes
ASufBas:	dc.w _SufBas-ZZ+DataLong,0 
ASufBak:	dc.w _SufBak-ZZ+DataLong,0 
ASufAcc:	dc.w _SufAcc-ZZ+DataLong,0 
AAutoEx:	dc.w _AutoEx-ZZ+DataLong,0 
*************** Icone par defaut!
ADefIcon	dc.w _DefIcon-ZZ+DataLong,$0012 
*************** LOGO AMOS
ANMouse:	dc.w _NMouse-ZZ+DataLong,$0012 
ANFonte:	dc.w _NFonte-ZZ+DataLong,$0012
*************** CLAVIER PAR DEFAUT
AKyNom:		dc.w _KyNom-ZZ+DataLong,$0012 
*************** Divers
ACRet:		dc.w _CRet-ZZ+DataLong,0 
AChCuOn:	dc.w _ChCuOn-ZZ+DataLong,0 
AChCuOff:	dc.w _ChCuOff-ZZ+DataLong,0 
AChDir1a:	dc.w _ChDir1A-ZZ+DataLong,0 
AChDir2:	dc.w _ChDir2-ZZ+DataLong,0 
AChDir4: 	dc.w _ChDir4-ZZ+DataLong,0 
AChDir5:	dc.w _ChDir5-ZZ+DataLong,0 
* Couleur des inputs
AEtInp:		dc.w _EtInp-ZZ+DataLong,0 
* Effacement de la ligne 
AEtClw:		dc.w _EtClw-ZZ+DataLong,0 
AEtCuOf		dc.w _EtCuOf-ZZ+DataLong,0 
* Couleurs du message d'erreur
AEtAl:		dc.w _EtAl-ZZ+DataLong,0 
*************** Ecran par defaut
ADefEFl:	dc.w _DefEFl-ZZ+DataLong,0 
*************** Ecran erreurs
AErrIOn:	dc.w _ErrIOn-ZZ+DataLong,0 
AErrIOff:	dc.w _ErrIOff-ZZ+DataLong,0 
AErrIci:	dc.w _ErrIci-ZZ+DataLong,0 
AErrFl:		dc.w _ErrFl-ZZ+DataLong,0 
*************** Ecran Follow
AFolI1:		dc.w _FolI1-ZZ+DataLong,0 
AFolI3:		dc.w _FolI3-ZZ+DataLong,0 
AFolI4:		dc.w _FolI4-ZZ+DataLong,0 
AFolI5:		dc.w _FolI5-ZZ+DataLong,0 
***************	Initialise l'ecran ESC - repousse l'editeur
AEscI:		dc.w _EscI-ZZ+DataLong,0 
AEscOk:		dc.w _EscOk-ZZ+DataLong,0 
AEscI0:		dc.w _EscI0-ZZ+DataLong,0 
AEdELi:		dc.w _EdELi-ZZ+DataLong,0 
AEscH4:		dc.w _EscH4-ZZ+DataLong,0 
AEscH5:		dc.w _EscH5-ZZ+DataLong,0 
		dc.w -1,EndPar-ParaTrap


*-----------------------------------------------------------------
*		 **  *    * **** ****    ***    **  **** ***  ***
*	 	*  * **  ** *  * *       *  *  *  * *     *  *
*	 	**** * ** * *  * ****    ****  **** ****  *  *
*	 	*  * *    * *  *    *    *   * *  *    *  *  *  
*	 	*  * *    * **** ****    ****  *  * **** ***  ***
*-----------------------------------------------------------------
*		DONNEES DIVERSES
*-----------------------------------------------------------------

***********************************************************
*		PARAMETRES INITIALISATION ECRANS
ParaTrap:	dc.l 0			* 0 - Adresse actualisation
AdMouse:	dc.l 0			* 4 - Adresse souris
		dc.w 68			* 8 - Nombre de bobs
		dc.w 50			* 10- Position par defaut ecran!!
		dc.l 12000		* 12- Taille liste copper
		dc.l 32			* 16- Nombre lignes sprites

* Taille des buffers 
VNmMax:		dc.l 1024*4		* Buffer des noms de variable
TVDirect:	dc.w 42*6		* Variables mode direct
DefSize:	dc.l 32768		* Taille du buffer texte
Icons:		dc.w 0			* Faire des icons
* Positions ecrans
EdPosY:		dc.w 26+20+56
FkPosY:		dc.w 26+20
FsDWy:		dc.w 50+16
EdTyM0:		dc.w 22
EdTyM1:		dc.w 0
EdTyM2:		dc.w 0
* Directory
DirSize:	dc.w 30
DirMax:		dc.w 128
* Faire des back?
EdSvBak:	dc.w 1
PrtRet:		dc.w 1
* Vitesses ouvertures
FsDVApp:	dc.w 16
EdVScrol:	dc.w 24
		dc.w 0
* Palettes
EdPal:		dc.w $0,$459,$FFF,$000
FkPal:		dc.w $0,$0,$0,$0
FsPal:		dc.w $0,$0,$0,$0
EscPal:		dc.w $029,$029,$ECC,$000
ErrPal:		dc.w $920,$F30,$FFF,$FF0
FolPal		dc.w $155,$FFF,$FF0,$F40
EdColB:		dc.w $0	
*************** Autoclose workbench
AutoWB:		dc.w 1
*************** Donnees normalement invariables
InterFonc:	dc.b 0,0
InterEdit:	dc.b 0,0 
FsDWx:		dc.w 129+80
*************** Position fenetre ESC
EcYErr:		dc.w 26+250
EsWY:		dc.w 26+184
EsWTy:		dc.w 10*8
EsVY:		dc.w (22+1-10)*8		* EdTy
*************** Ecran par defaut
DefETx:		dc.w 320
DefETy:		dc.w 200
DefECo:		dc.w 4
DefECoN:	dc.w 16
DefEMo:		dc.w 0
DefEBa:		dc.w 0
DefEPa:		dc.w $000,$A40,$FFF,$000,$F00,$0F0,$00F,$666
		dc.w $555,$333,$733,$373,$773,$337,$737,$377
		dc.w 0,0,0,0,0,0,0,0
		dc.w 0,0,0,0,0,0,0,0

LRunData	ds.w 64

*************** Donnees supplementaires EZAMOS
Environs	dc.w 0	
		dc.w $000
		dc.w $000,$f34,$027,$ddd,$0df,$21c,$16f,$7df
		dc.w $000,$000,$027,$ddd,$dd0,$21c,$16f,$7df
;		dc.w $000
;		dc.w $000,$efe,$482,$fff,$000,$363,$585,$7a7
;		dc.w $000,$000,$482,$fff,$f22,$363,$585,$7a7
		dc.w $000
		dc.w $000,$efe,$3ba,$fff,$000,$065,$287,$4a9
		dc.w $000,$000,$3ba,$ddd,$f22,$065,$287,$4a9
		dc.w $000
		dc.w $000,$efe,$7b9,$fff,$000,$264,$486,$6a8
		dc.w $000,$000,$7b9,$fff,$f72,$264,$486,$6a8
		dc.w $000
		dc.w $000,$efe,$a93,$efd,$000,$242,$484,$9b5
		dc.w $000,$000,$a93,$efd,$f10,$242,$484,$9b5
		dc.w $000
		dc.w $000,$efe,$b51,$fff,$000,$951,$c73,$e95
		dc.w $000,$000,$b51,$fff,$fb2,$951,$c73,$e95
		dc.w $000
		dc.w $000,$efe,$c50,$feb,$000,$941,$c62,$f93
		dc.w $000,$000,$c50,$feb,$1ca,$941,$c62,$f93
		dc.w $000
		dc.w $000,$efe,$d48,$fff,$000,$624,$d36,$e58
		dc.w $000,$000,$d48,$fff,$f22,$624,$d36,$e58
* Super bleu, par moimoimoi
		dc.w $000
		dc.w $000,$224,$bbc,$356,$352,$356,$58a,$7bf
		dc.w $000,$000,$035,$bbc,$d30,$356,$58a,$7bf

* Nouveaux messages pour l'éditeur
		dc.b "Block cut and stored in cut buffer.",0	
		dc.b "Block stored in buffer.",0
		dc.b "Beginning of block set.",0
		dc.b "End of block set.",0
		dc.b "Block moved.",0
		dc.b "Block pasted.",0
		dc.b "All text marked as block.",0
		dc.l 0

		Even
EndPar:


*-----------------------------------------------------------------
*	 **  *    * **** ****    ***    **  **** ***  ***
* 	*  * **  ** *  * *       *  *  *  * *     *  *
* 	**** * ** * *  * ****    ****  **** ****  *  *
* 	*  * *    * *  *    *    *   * *  *    *  *  *  
* 	*  * *    * **** ****    ****  *  * **** ***  ***
*-----------------------------------------------------------------
*	CHAINES DE CARACTERES MODIFIABLES
*-----------------------------------------------------------------

*************** Messages sous editeur
_EdMem:		dc.b "Out of buffer space",0
_EdOm:		dc.b "Out of memory",0
_EdTop:		dc.b "Top of text",0
_EdBot:		dc.b "Bottom of text",0
_EdLLong:	dc.b "Line too long",0
_EdTest:	dc.b "...TESTING...",0
_EdNoE:		dc.b "No errors",0
_EdInd:		dc.b "...INDENTING...",0
_NoFold		dc.b "Not a procedure",0
_NMark		dc.b "Not marked",0
_WBloc		dc.b "What block?",0
_NFound		dc.b "Not found",0
_Sching		dc.b "...SEARCHING...",0
		IFEQ	VDemo
_MPAmos		dc.b "This is not an AMOS program!",0
		ENDC
		IFNE	VDemo
_MPAmos		dc.b "Demo version! Buy the original from Europress Software Ltd soon...",0
		ENDC
_MPlace		dc.b "Text buffer too small for this program",0
_AvNoProg	dc.b "No programs in memory",0
_MesNotD:	dc.b "Not done.",0
_CloClo:	dc.b 0
_EdDemo:	dc.b "Demo version! Buy the original from Europress Software Ltd soon...",0

******* Messages apres RUN
_VIlD:		dc.b "Illegal direct mode",0
_VSynt:		dc.b "Syntax error",0
_VLong:		dc.b "Structure too long",0
_VType:		dc.b "Type mismatch error",0
_VOut:		dc.b "Out of memory",0
_VVNm:		dc.b "Variable buffer too small",0
_VNmO:		dc.b "Variable name's buffer too small",0
_VNDim:		dc.b "Array not dimensioned",0
_VLbl2:		dc.b "Label defined twice",0
_VUnd:		dc.b "Undefined label",0
_VAlD:		dc.b "Array already dimensioned",0
_VFoN:		dc.b "FOR without matching NEXT",0
_VNFo:		dc.b "NEXT without FOR",0
_VRUn:		dc.b "REPEAT without matching UNTIL",0
_VUnR:		dc.b "UNTIL without REPEAT",0
_VWWn:		dc.b "WHILE without matching WEND",0
_VWnW:		dc.b "WEND without WHILE",0
_VDoL:		dc.b "DO without LOOP",0
_VLDo:		dc.b "LOOP without DO",0
_VCrs:		dc.b "Bad structure",0
_VNoL:		dc.b "Not enough loops to exit",0
_VEIf:		dc.b "ENDIF without IF",0
_VElE:		dc.b "ELSE without ENDIF",0
_VElI:		dc.b "ELSE without IF",0
_VIfE:		dc.b "IF without ENDIF",0
_VNoT:		dc.b "No THEN in a structured test",0
_VPDeb:		dc.b "Procedure's limits must be alone on a line",0
_VPOp:		dc.b "Procedure not closed",0
_VPNo:		dc.b "Procedure not opened",0
_VIlP:		dc.b "Illegal number of parameters",0
*_VPTy:		dc.b 0
_VPRTy:		dc.b "Return parameter's type not the same as procedure's type",0
_VUndP:		dc.b "Undefined procedure",0
_VShP:		dc.b "This instruction must be used within a procedure",0
_VAlG:		dc.b "This variable is already defined as SHARED",0
_VPaG:		dc.b "This array is not defined in the main program",0
_VShal:		dc.b "Shared must be alone on a line",0
_VNoPa:		dc.b "Use empty brakets when defining a shared array",0
_VPaGo:		dc.b "No jumps allowed into the middle of a loop!",0
_VVTo:		dc.b "Too many direct-mode variables",0
_VDal:		dc.b "This instruction must be alone on a line",0
_VNoB:		dc.b "Variable buffer can't be changed in the middle of a program!",0
_VExN:		dc.b "Extension not loaded",0
_VNFn:		dc.b "User function not defined",0
_ExtNot:	dc.b "Extension "
		dc.b " "+$80,0
_MErreur:
******* Messages d'erreur RUN-TIME
* 0-19 FATALS
	dc.b "Out of stack space",0			-0-
	dc.b "RETURN without GOSUB",0			-1-
	dc.b "POP without GOSUB",0			-2-
	dc.b "Error not resumed",0			-3-
	dc.b "Can't resume to a label",0		-4-	
	dc.b "No ON ERROR PROC before this instruction",0	-5-
	dc.b "Resume label not defined",0		-6-
	dc.b "Resume without error",0			-7-
	dc.b "Error procedure must RESUME to end",0	-8-
	dc.b "Program interrupted",0			-9-
* NbEnd	equ 10
	dc.b "End of program",0				-10-
	dc.b "Out of variable space",0			-11-
	dc.b "Can't follow: editor is closed",0		-12-
	dc.b "No follow in a FOLDED procedure",0	-13-
	dc.b "Can't close editor: FOLLOW mode on!",0	-14-
	dc.b "User function not defined",0		-15-
	dc.b "Illegal user function call",0 		-16-
	dc.b "Illegal direct mode",0			-17-
	dc.b "Instruction not available in Easy-AMOS",0	-18-
	dc.b 0						-19-
* 20- Messages normaux
	dc.b "Division by zero",0			-20-
	dc.b "String too long",0			-21-
	dc.b "Syntax error",0				-22-
	dc.b "Illegal function call",0			-23-
	dc.b "Out of memory",0				-24-
	dc.b "Address error",0				-25-
	dc.b 0						-26- Out of fast
	dc.b "Non dimensioned array",0			-27-
	dc.b "Array already dimensioned",0		-28-
	dc.b "Overflow",0				-29-
	dc.b "Bad IFF format",0				-30-
	dc.b "IFF compression not recognised",0		-31-
	dc.b "Can't fit picture in current screen",0	-32-
	dc.b "Out of data",0				-33-
	dc.b "Type mismatch",0				-34-
	dc.b "Bank already reserved",0			-35-
	dc.b "Bank not reserved",0			-36-
	dc.b "Fonts not examined",0			-37-
	dc.b "Menu not opened",0			-38-
	dc.b "Menu item not defined",0			-39-
	dc.b "Label not defined",0			-40-
	dc.b "No data after this label",0		-41-
	dc.b "Program not found",0			-42-
	dc.b "No programs below current program",0	-43-
	dc.b "Font not available",0			-44-
* Messages d'erreur ecrans/fenetres
*EcEBase	equ 45
	dc.b 0						-45- Out of mem screen
	dc.b "Block not defined",0			-46-
	dc.b "Screen not opened",0			-47-
	dc.b "Illegal screen parameter",0		-48-
	dc.b "Illegal number of colours",0		-49-
	dc.b "Valid screen numbers range 0 to 7",0	-50-
	dc.b "Too many colours in flash",0				-51-
	dc.b "Flash declaration error",0		-52-
	dc.b "Shift declaration error",0		-53-
	dc.b "Window not opened",0			-54-
	dc.b "Window already opened",0			-55-
	dc.b "Window too small",0			-56-
	dc.b "Window too large",0			-57-
	dc.b 0						-58- Char set
	dc.b "Bordered windows not on edge of screen",0	-59-
	dc.b "Illegal window parameter",0		-60-
	dc.b 0						-61- Out of mem window
	dc.b "Window 0 can't be closed",0		-62-
	dc.b "This window has no border",0		-63-
	dc.b 0						-64- Cant create blck
	dc.b "Block not found",0			-65-
	dc.b "Illegal block parameters",0		-66-
	dc.b "Screens can't be animated",0 		-67-
	dc.b "Bob not defined",0			-68-
	dc.b "Screen already in double buffering",0	-69-
	dc.b "Can't set dual playfield",0		-70-
	dc.b "Screen not in dual playfield mode",0	-71-
	dc.b "Scrolling zone not defined",0		-72-
	dc.b "No zones defined",0			-73-
	dc.b "Icon not defined",0			-74-
	dc.b "Rainbow not defined",0			-75-
	dc.b "Copper not disabled",0			-76-
	dc.b "Copper list too long",0			-77-
	dc.b "Illegal copper parameter",0		-78-
* Messages d'erreur disque
*DEBase	equ EcEBase+35-1
	dc.b "File already exists",0			-79-
	dc.b "Directory not found",0			-80-
	dc.b "File not found",0				-81-
	dc.b "Illegal file name",0			-82-
	dc.b "Disc is not validated",0			-83-
	dc.b "Disc is write protected",0		-84-
	dc.b "Directory not empty",0			-85-
	dc.b "Device not available",0			-86-
	dc.b 0						-87-
	dc.b "Disc full",0				-88-
	dc.b "File is protected against deletion",0	-89-
	dc.b "File is write protected",0		-90-
	dc.b "File is protected against reading",0	-91-
	dc.b "Not an AmigaDOS disc",0			-92-
	dc.b "No disc in drive",0			-93-
	dc.b "I/O error",0				-94-
	dc.b "File format not recognised",0		-95-
	dc.b "File already opened",0			-96-
	dc.b "File not opened",0			-97-
	dc.b "File type mismatch",0			-98-
	dc.b "Input too long",0				-99-
	dc.b "End of file",0				-100-
	dc.b 0						-101-
	dc.b 0						-102-
	dc.b 0						-103-	
* Message d'erreur sprites/souris
*SpEBase equ DEBase+25
	dc.b 0								-104- Heap space sprite
	dc.b "Sprite error",0						-105-
	dc.b 0								-106- Heap space anim
	dc.b "Syntax error in animation string",0			-107-
	dc.b "Next without For in animation string",0			-108-
	dc.b "Label not defined in animation string",0			-109-	
	dc.b "Jump To/Within autotest in animation string",0		-110-
	dc.b "Autotest already opened",0				-111-
	dc.b "Instruction only valid in autotest",0			-112-
	dc.b "Animation string too long",0				-113-
	dc.b "Label already defined in animation string",0		-114-
	dc.b "Illegal instruction during autotest",0			-115-
	dc.b "Amal bank not reserved",0					-116-
	dc.b 0,0,0,0,0,0,0,0					
	dc.b -1

*************** Input
_Redo:		dc.b 13,10,"Please redo from start",13,10,0

*************** 26 EXTENSIONS A CHARGER
_ExtNames:	dc.b 0
		dc.b 0
		dc.b 0
		dc.b 0
		dc.b 0,0,0,0,0,0
		dc.b 0,0,0,0,0,0,0,0,0,0
		dc.b 0,0,0,0,0,0
		dc.b -1

*************** DRIVES RECONNUS
_SelDrv:	dc.b 0
_NmPrt:		dc.b "Prt:",0
_NmSer:		dc.b "Aux:",0

*************** Differents messages
_MesLd1:	dc.b "LOAD an AMOS program",0
_MesLd2:	dc.b 0
_MesLd3:	dc.b "*.AMOS",0
_MesMe1:	dc.b "MERGE an AMOS program",0
_MesMe2:	dc.b 0
_MesLdA1:	dc.b "MERGE an Ascii file",0
_MesLdA2:	dc.b 0
_MesLdA3:	dc.b "*.ASC",0
_AvMe:		dc.b "Merging",0
_AvLd:		dc.b "Loading",0
_AvPrt:		dc.b "Printing part of",0
_MesSv1:	dc.b "SAVE an AMOS program",0
_MesSv2:	dc.b 0
_MesSBl1:	dc.b "SAVE an AMOS block",0
_MesSBl2:	dc.b 0
_MesSvA1:	dc.b "Save an ASCII program",0
_MesSvA2:	dc.b 0
_MesSvA3:	dc.b "*.ASC",0
_AvSv:		dc.b "Saving",0
_AvSvA:		dc.b "Saving as Ascii",0	
_MesAc1:	dc.b "RUN a program as an accessory",0
_MesAc2:	dc.b "Please choose program to run",0
_MesAc3:	dc.b "*.AMOS",0
_MesAn1:	dc.b "Loaded AMOS programs",0
_MesAn2:	dc.b "Please choose program to ERASE",0
_MesAn3:	dc.b "**",0
_MesEd1:	dc.b "Loaded AMOS programs",0
_MesEd2:	dc.b "Please choose program to EDIT",0
_MesEd3:	dc.b "**",0
_MesRn1:	dc.b "Loaded AMOS programs",0
_MesRn2:	dc.b "Please choose program to RUN",0
_MesRn3:	dc.b "**",0
_AvAccL:	dc.b "Looking for accessories (.Acc)",0

_EdPName:	dc.b "Please enter program's name: ",0
_EdLName:	dc.b "Load a program. Enter file name: ",0
_SMark:		dc.b "Enter mark number (0-9): ",0
_EdTSize:	dc.b "Enter new text buffer's size: ",0
_EdTTab:	dc.b "Enter new tab value: ",0
_Schinp:	dc.b "Enter string to search: ",0
_Repinp:	dc.b "Enter string to replace with: ",0

_FsTxt:		dc.b " Discs  ",0
		dc.b " Parent ",0
		dc.b "   Ok   ",0
		dc.b "  Quit  ",0
		dc.b "  Sort  ",0
		dc.b 147,148,0
		dc.b 149,150,0
		dc.b 0,0,0,0	
		dc.b -1
_FaTxt:		dc.b 0
		dc.b "  All   ",0
		dc.b "   Ok   ",0
		dc.b "  Quit  ",0
		dc.b "  Sort  ",0
		dc.b 147,148,0
		dc.b 149,150,0
		dc.b 0,0,0,0	
		dc.b -1
_FsWait:	dc.b "Reading directory",0
_FsDTit:	dc.b "File selector",0
_FsDirSet:	dc.b "Directory changed!",0

*************** Messages editeur
_ConfYes:	dc.b "Y",0
_ConfNo:	dc.b "N",0
_ConfConf:	dc.b "Please confirm",0
_ConfSave:	dc.b "Current program is not saved. Save it?",0
_ConfText:	dc.b "Can't fit program into editor buffer. Change buffer size?",0
_DispText:	dc.b "Size of the program : ",0

_ConfYN:	dc.b 27,"P2 (",27,"P2",27,"I",0
_ConfYi:	dc.b "0",27,"Z0 Yes ",27,"Z1",27,"P2or",27,"P2",27,"I",0
_ConfNi:	dc.b "0",27,"Z0 No ",27,"Z2",27,"P2)",27,"P2",0

_EdFlCu:	dc.b "(000,2)(440,2)(880,2)(bb0,2)(dd0,2)(ee0,2)(ff2,2)(ff8,2)"
		dc.b "(ffc,2)(fff,2)(aaf,2)(88c,2)(66a,2)(226,2)(004,2)(001,2)",0
_FolFl:		dc.b 0

*************** Touches de fonction
_FkDef1:	dc.b 27,"B2",27,"P3"
		dc.b 27,"I0",27,"X",68+12*0,27,"Y1",27,"Z0","    Run    ",27,"Z",48+1
		dc.b 27,"I0",27,"X",68+12*1,27,"Y1",27,"Z0","    Test   ",27,"Z",48+2
		dc.b 27,"I0",27,"X",68+12*2,27,"Y1",27,"Z0","   Indent  ",27,"Z",48+3
		dc.b 27,"I0",27,"X",68+12*3,27,"Y1",27,"Z0","Blocks Menu",27,"Z",48+4
		dc.b 27,"I0",27,"X",68+12*4,27,"Y1",27,"Z0","Search Menu",27,"Z",48+5
		dc.b 27,"I0",27,"X",68+12*0,27,"Y3",27,"Z0","   Tutor   ",27,"Z",48+6
		dc.b 27,"I0",27,"X",68+12*1,27,"Y3",27,"Z0","   Help    ",27,"Z",48+7
		dc.b 27,"I0",27,"X",68+12*2,27,"Y3",27,"Z0","   Insert  ",27,"Z",48+8
		dc.b 27,"I0",27,"X",68+12*3,27,"Y3",27,"Z0","Fold/Unfold",27,"Z",48+9
		dc.b 27,"I0",27,"X",68+12*4,27,"Y3",27,"Z0","Line Insert",27,"Z",48+10
		dc.b 27,"I0",0
_FkDef2:	dc.b 27,"B2",27,"P3"
		dc.b 27,"I0",27,"X",68+12*0,27,"Y1",27,"Z0","   Load    ",27,"Z",48+1
		dc.b 27,"I0",27,"X",68+12*1,27,"Y1",27,"Z0","   Save    ",27,"Z",48+2
		dc.b 27,"I0",27,"X",68+12*2,27,"Y1",27,"Z0","  Save As  ",27,"Z",48+3
		dc.b 27,"I0",27,"X",68+12*3,27,"Y1",27,"Z0","   Merge   ",27,"Z",48+4
		dc.b 27,"I0",27,"X",68+12*4,27,"Y1",27,"Z0","Merge Ascii",27,"Z",48+5
		dc.b 27,"I0",27,"X",68+12*0,27,"Y3",27,"Z0","Environment",27,"Z",48+6
		dc.b 27,"I0",27,"X",68+12*1,27,"Y3",27,"Z0","Bob Editor ",27,"Z",48+7
		dc.b 27,"I0",27,"X",68+12*2,27,"Y3",27,"Z0"," Easy Disc ",27,"Z",48+8
		dc.b 27,"I0",27,"X",68+12*3,27,"Y3",27,"Z0","    New    ",27,"Z",48+9
		dc.b 27,"I0",27,"X",68+12*4,27,"Y3",27,"Z0","   Quit    ",27,"Z",48+10
		dc.b 27,"I0",0
_FkDef3:	dc.b 27,"B2",27,"P3"
		dc.b 27,"I0",27,"X",68+12*0,27,"Y1",27,"Z0","Block Start",27,"Z",48+1
		dc.b 27,"I0",27,"X",68+12*1,27,"Y1",27,"Z0","Block   Cut",27,"Z",48+2
		dc.b 27,"I0",27,"X",68+12*2,27,"Y1",27,"Z0","Block  Move",27,"Z",48+3
		dc.b 27,"I0",27,"X",68+12*3,27,"Y1",27,"Z0","Block  Hide",27,"Z",48+4
		dc.b 27,"I0",27,"X",68+12*4,27,"Y1",27,"Z0","Save  Ascii",27,"Z",48+5
		dc.b 27,"I0",27,"X",68+12*0,27,"Y3",27,"Z0","Block   End",27,"Z",48+6
		dc.b 27,"I0",27,"X",68+12*1,27,"Y3",27,"Z0","Block Paste",27,"Z",48+7
		dc.b 27,"I0",27,"X",68+12*2,27,"Y3",27,"Z0","Block Store",27,"Z",48+8
		dc.b 27,"I0",27,"X",68+12*3,27,"Y3",27,"Z0","Block  Save",27,"Z",48+9
		dc.b 27,"I0",27,"X",68+12*4,27,"Y3",27,"Z0","Block Print",27,"Z",48+10
		dc.b 27,"I0",0
_FkDef4:	dc.b 27,"B2",27,"P3"
		dc.b 27,"I0",27,"X",68+12*0,27,"Y1",27,"Z0","   Find    ",27,"Z",48+1
		dc.b 27,"I0",27,"X",68+12*1,27,"Y1",27,"Z0"," Find Next ",27,"Z",48+2
		dc.b 27,"I0",27,"X",68+12*2,27,"Y1",27,"Z0"," Find Top  ",27,"Z",48+3
		dc.b 27,"I0",27,"X",68+12*3,27,"Y1",27,"Z0","  Replace  ",27,"Z",48+4
		dc.b 27,"I0",27,"X",68+12*4,27,"Y1",27,"Z0","Replace All",27,"Z",48+5
		dc.b 27,"I0",27,"X",68+12*0,27,"Y3",27,"Z0","           ",27,"Z",48+6
		dc.b 27,"I0",27,"X",68+12*1,27,"Y3",27,"Z0"," Open  All ",27,"Z",48+7
		dc.b 27,"I0",27,"X",68+12*2,27,"Y3",27,"Z0"," Close All ",27,"Z",48+8
		dc.b 27,"I0",27,"X",68+12*3,27,"Y3",27,"Z0","Set Text B.",27,"Z",48+9
		dc.b 27,"I0",27,"X",68+12*4,27,"Y3",27,"Z0","  Set Tab  ",27,"Z",48+10
		dc.b 27,"I0",0
_FkDef5:	dc.b 27,"B2",27,"P3"
		dc.b 27,"I0",27,"X",68+12*0,27,"Y1",27,"Z0","           ",27,"Z",48+1
		dc.b 27,"I0",27,"X",68+12*1,27,"Y1",27,"Z0","           ",27,"Z",48+2
		dc.b 27,"I0",27,"X",68+12*2,27,"Y1",27,"Z0","           ",27,"Z",48+3
		dc.b 27,"I0",27,"X",68+12*3,27,"Y1",27,"Z0","           ",27,"Z",48+4
		dc.b 27,"I0",27,"X",68+12*4,27,"Y1",27,"Z0","           ",27,"Z",48+5
		dc.b 27,"I0",27,"X",68+12*0,27,"Y3",27,"Z0","           ",27,"Z",48+6
		dc.b 27,"I0",27,"X",68+12*1,27,"Y3",27,"Z0","           ",27,"Z",48+7
		dc.b 27,"I0",27,"X",68+12*2,27,"Y3",27,"Z0","           ",27,"Z",48+8
		dc.b 27,"I0",27,"X",68+12*3,27,"Y3",27,"Z0","           ",27,"Z",48+9
		dc.b 27,"I0",27,"X",68+12*4,27,"Y3",27,"Z0","           ",27,"Z",48+10
		dc.b 27,"I0",0
*FkLong:		equ 26

*************** Insert / OverW
_FkIt0:		dc.b "  Insert   ",0
_FkIt1:		dc.b " Overwrite ",0
* Lower / upper
_FkLt0:		dc.b " Low <> Up ",0
_FkLt1:		dc.b " Low = Up  ",0

*************** Ecran Follow
_FolI2:		dc.b 0
		dc.b 0
*************** Directory
_DirFilt:	dc.b ".info/*.info/*.*.info",0
_ChDir0:	dc.b 13,10,"Directory of ",0
_ChDir1:	dc.b 13,10,"One moment please...",0
_ChDir6:	dc.b " total bytes listed.",13,10,0
_ChDir3:	dc.b "* ",0

*************** Ligne d'etat
_MrgMes		dc.b 27,"X1",27,"Y5"," Processing : ",0
* Caps
_EtCps0:	dc.b 27,"X4",27,"Y5",27,"B2"," ",0
_EtCps1:	dc.b 27,"X4",27,"Y5",27,"B2",27,"P3","C",0
* Insert / OverW
_EtIns0:	dc.b 27,"X2",27,"Y5",27,"P3",27,"B2","O",0
_EtIns1:	dc.b 27,"X2",27,"Y5",27,"P3",27,"B2","I",0
* Line #
_EtY:		dc.b 27,"X",48+6,27,"Y5",27,"B2",27,"P3","L:     ",27,"X",48+8,27,"P3",0
_EtY1:		dc.b "     ",0
* Col#
_EtX:		dc.b 27,"X",48+14,27,"Y5",27,"B2",27,"P3","C:   ",27,"X",48+16,27,"P3",0
_EtX1:		dc.b "   ",0
* Free
_EtFr0:		dc.b 27,"X",48+20,27,"Y5",27,"B2",27,"P3","Text:       ",27,"X",48+25,27,"P3",0
_EtFr1:		dc.b "        ",0
* Chip
_EtCh0:		dc.b 27,"X",48+32,27,"Y5",27,"B2",27,"P3","Chip:      ",27,"X",48+37,27,"P3",0
_EtCh1:		dc.b "      ",0
* Fast
_EtFs0:		dc.b 27,"X",48+44,27,"Y5",27,"B2",27,"P3","Fast:       ",27,"X",48+49,27,"P3",0
_EtFs1:		dc.b "       ",0
* Editing
_EtNm1:		dc.b 27,"X",48+57,27,"Y5",27,"B2",27,"P3","Edit: ",27,"P3",0
_EtNm2:		dc.b "               ",0

*************** HELP escape
_EscH1:		dc.b 13,31,31,31,31,31,31,31,31,30,30,30,30,30,30,30,30
		dc.b " ",27,"E0",27,"R0 ",27,"R",48+24
		dc.b 27,"B2",27,"P4"," --- Easy AMOS direct mode --- ",27,"B2",27,"P3"
		dc.b 10,13," ",0
_EscH2:		dc.b "F1: ",0
		dc.b "F2: ",0
		dc.b "F3: ",0
		dc.b "F4: ",0
		dc.b "F5: ",0
		dc.b "F6: ",0
		dc.b "F7: ",0
		dc.b "F8: ",0
		dc.b "F9: ",0
		dc.b "F10:",0
		dc.b "F11:",0
		dc.b "F12:",0
		dc.b "F13:",0
		dc.b "F14:",0
		dc.b "F15:",0
		dc.b "F16:",0
		dc.b "F17:",0
		dc.b "F18:",0
		dc.b "F19:",0
		dc.b "F20:",0
		dc.b -1
	
*************** Touches de fonction ESC par defaut
_AmiDef:	dc.b 'ListBank`',0
		dc.b 'Default`',0
		dc.b 'Dir`',0
		dc.b 'Dir$="',0
		dc.b 'Parent`',0
		dc.b 'Load Fsel$("*.Abk")',0
		dc.b 'Save Fsel$("*.Abk")',0
		dc.b 'LoadIff Fsel$("**")',0
		dc.b 'SaveIff Fsel$("**")',0
		dc.b '? Fsel$("**")`',0
		dc.b "Screen Close ",0
		dc.b "Screen Open ",0
		dc.b "CursOff : FlashOff`",0
		dc.b "Music Off",0
		dc.b "Bob Off`",0
		dc.b "Music 1`",0
		dc.b "Music Off`",0
		dc.b "Led Off`",0
		dc.b "Led On`",0
		dc.b "System",0
		dc.b -1

************** Accessoires autoload
_AutoLd		dc.b 0,0,0,0,0,0,0,0
		dc.b 0,0,0,0,0,0,0,0
		dc.b -1
************** Accessoire HELP
_NameHelp	dc.b "Bob_Editor.AMOS",0
_HelpLoad	dc.b "AMOS_Disc.AMOS",0
_HNoF		dc.b "Can't load desired program!",0

************** TABLE DES FONCTIONS DE L'EDITEUR
_KFonc:		dc.b $80+$4C,$00,0			* Curseur HAUT
		dc.b $80+$4D,$00,0			* Curseur BAS
		dc.b $80+$4F,$00,0			* Curseur GAUCHE
		dc.b $80+$4E,$00,0			* Curseur DROITE
		dc.b $80+$4C,Shf,0			* Haut page
		dc.b $80+$4D,Shf,0			* Bas page
		dc.b $80+$4F,Shf,0			* Mot gauche
		dc.b $80+$4E,Shf,0			* Mot droite
		dc.b $80+$4C,Ctr,0			* Page UP
		dc.b $80+$4D,Ctr,0			* Page down
		dc.b $80+$4F,Ctr,0			* Debut ligne
		dc.b $80+$4E,Ctr,0			* Fin ligne
		dc.b $80+$4C,Ami,0			* Scrolling HAUT
		dc.b $80+$4D,Ami,0			* Scrolling BAS
		dc.b $80+$4F,Ami,0			* Scrolling GAUCHE
		dc.b $80+$4E,Ami,0			* Scrolling DROITE
		dc.b $80+$4C,Ctr+Shf,0			* Haut texte
		dc.b $80+$4D,Ctr+Shf,0			* Bas texte
		dc.b 13,$00,0				* Return
		dc.b $80+$41,0,0			* Backspace
		dc.b $80+$46,0,0			* Delete
		dc.b $80+$46,Shf,$80+$41,Shf,0		* Efface ligne
		dc.b "Y",Ctr,0				* Delete ligne
		dc.b $80+$42,0,0			* Tab
		dc.b $80+$42,Shf,0			* Del tab
		dc.b $80+$42,Ctr,0			* Fix tab
		dc.b $80+$5F,0,0			* Help
		dc.b $80+$45,0,0			* ESC
		dc.b "I",Ctr,0				* Insert ligne
		dc.b "Q",Ctr,0				* Delete-FIN ligne
		dc.b $80+$4C,Alt,0			* Previous label
		dc.b $80+$4D,Alt,0			* Next label 
		dc.b "L",Ami,0				* Load
		dc.b "S",Ami,0				* Save As
		dc.b "S",Ami+Shf,0			* Save
		dc.b $80+$5f,Shf,0			* Shift-Help
		dc.b 0				* Tourne programmes 
		dc.b 0				* Pousse courant
		dc.b $80+$0f,Ctr+Shf,0			* Set Marks
		dc.b $80+$1d,Ctr+Shf,0	
		dc.b $80+$1e,Ctr+Shf,0	
		dc.b $80+$1f,Ctr+Shf,0	
		dc.b $80+$2d,Ctr+Shf,0	
		dc.b $80+$2e,Ctr+Shf,0	
		dc.b $80+$2f,Ctr+Shf,0	
		dc.b $80+$3d,Ctr+Shf,0	
		dc.b $80+$3e,Ctr+Shf,0	
		dc.b $80+$3f,Ctr+Shf,0	
		dc.b $80+$0f,Ctr,0			* Goto Marks
		dc.b $80+$1d,Ctr,0	
		dc.b $80+$1e,Ctr,0	
		dc.b $80+$1f,Ctr,0	
		dc.b $80+$2d,Ctr,0	
		dc.b $80+$2e,Ctr,0	
		dc.b $80+$2f,Ctr,0	
		dc.b $80+$3d,Ctr,0	
		dc.b $80+$3e,Ctr,0	
		dc.b $80+$3f,Ctr,0	
		dc.b "B",Ctr,0				* Debut bloc
		dc.b "E",Ctr,0				* End
		dc.b "H",Ctr,0				* Hide
		dc.b "C",Ctr,0				* Cut
		dc.b "P",Ctr,0				* Paste
		dc.b "M",Ctr,0				* Move
		dc.b "U",Ctr,0				* Undo
		dc.b "F",Ctr,0				* Search
		dc.b "N",Ctr,0				* Next
		dc.b "R",Ctr,0				* Replace
		dc.b "A",Ctr,0				* Set All block
		dc.b "K",Ctr,0				* Recall alert
		dc.b "L",Shf+Ami,0			* Direct Load
		dc.b "S",Ctr,0				* Store bloc
		dc.b $FF,0

*************** Entete du basic
_Entete:	dc.b "AMOS Basic Ez101",0
*************** Fenetre FK
_FkFond:	dc.b 27,"C0",0
*************** Fenetre edit
_EdClw:		dc.b 27,"J7"
		dc.b 27,"B2",27,"P3",27,"D1",27,"V0",25
		dc.b 27,"J1",0
_SlDInit:	dc.b 0
_SlBInit:	dc.b 0
_EdDBloc	dc.b 27,"B3",27,"P2",0
_EdFBloc	dc.b 27,"B2",27,"P3",0

		IFEQ	VDemo
*************** Titre du basic
_Title1:	dc.b 27,"J7",27,"C0",27,"B5",27,"P7"
		dc.b 27,"X",48+22,27,"Y2",27,"E0",27,"M0"
		dc.b 27,"M1",27,"Y2            Easy-AMOS            "
		dc.b 27,"M1",27,"Y3            owned  by            "
		dc.b 27,"M1",27,"Y4USER-NAME                        "
		dc.b 27,"P0",27,"E2",27,"B2",27,"P3",0
_Title2:	dc.b 27,"B2",27,"P3",25,27,"C1",27,"J1",0
		ENDC
		IFNE	VDemo
*************** Titre du basic
_Title1:	dc.b 27,"J7",27,"C0",27,"B5",27,"P7"
		dc.b 27,"X",48+22,27,"Y2",27,"E0",27,"M0"
		dc.b 27,"M1",27,"Y2             Easy-AMOS           "
		dc.b 27,"M1",27,"Y3    Amiga Format Demo Version    "
		dc.b 27,"M1",27,"Y4                                 "
		dc.b 27,"M1",27,"Y5        By François Lionet       "
		dc.b 27,"M1",27,"Y6  © 1992 Europress Software Ltd. "
		dc.b 27,"P0",27,"E2",27,"B2",27,"P3",0
_Title2:	dc.b 27,"B2",27,"P3",25,27,"C1",27,"J1",0
		ENDC
*************** Suffixes
_SufBas:	dc.b ".AMOS",0
_SufBak:	dc.b ".Bak",0
_SufAcc:	dc.b "*.Acc",0
_AutoEx:	dc.b "AutoExec.AMOS",0
*************** Icone par defaut!
_DefIcon	dc.b "Easy_AMOS:"
_NMouse:	dc.b 0
_NFonte:	dc.b 0
_KyNom:		dc.b 0
*************** Divers
_CRet:		dc.b 13,10,0
_ChCuOn:	dc.b 27,"C1",0
_ChCuOff:	dc.b 27,"C0",0
_ChDir1a:	dc.b 26,13,0
_ChDir2:	dc.b " ",0
_ChDir4: 	dc.b "  ",0
_ChDir5:	dc.b " ",0
* Couleur des inputs
_EtInp:		dc.b 27,"P3",0 
* Effacement de la ligne 
_EtClw:		dc.b 27,"X1",27,"Y5",27,"B2",27,"Q",48+78,27,"B2",27,"P3",0
_EtCuOf		dc.b 27,"C0",0
* Couleurs du message d'erreur
_EtAl:		dc.b 27,"X1",27,"Y5",27,"B3",27,"Q",48+78,27,"P2",0
*************** Ecran par defaut
_DefEFl:	dc.b "(000,2)(440,2)(880,2)(bb0,2)(dd0,2)(ee0,2)(ff2,2)(ff8,2)"
		dc.b "(ffc,2)(fff,2)(aaf,2)(88c,2)(66a,2)(226,2)(004,2)(001,2)",0
*************** Ecran erreurs
_ErrIOn:	dc.b 27,"J7",27,"C0",27,"B0",25,27,"B1",26,27,"P3",0
_ErrIOff:	dc.b 27,"B0",27,"P3",13,10,0
_ErrIci:	dc.b 27,"P1",">>> ",27,"P2",0
_ErrLine:	dc.b " at line ",0
_ErrFin:	dc.b 27,"P3[ESCAPE]",27,"P2 to direct mode, "
		dc.b 27,"P3[SPACE]",27,"P2 to editor.",0
_ErrFl:		dc.b "(000,4)(300,4)(610,4)(910,4)(c20,4)(e20,4)(f30,4)"
		dc.b "(e20,4)(c20,4)(910,4)(610,4)(300,4)",0
*************** Ecran Follow
_FolI1:		dc.b 27,"C0",27,"B0",25,27,"B3",7,0
_FolI3:		dc.b 13,10,27,"P2- ",27,"P1",0
_FolI4:		dc.b " =",0
_FolI5:		dc.b 13,10,0
***************	Initialise l'ecran ESC - repousse l'editeur
_EscI:		dc.b 27,"J7",27,"D1",27,"B2",25,27,"P3",27,"X0",27,"Y",48-2,0
_EscOk:		dc.b 13,10,31,30,27,"B3",27,"P2","Easy AMOS>",27,"D1",27,"C1",27,"B2",27,"P3",0
_EscI0:		dc.b 27,"C0",0
_EdELi:		dc.b 27,"Q",48+80,0
_EscH4:		dc.b " ",0
_EscH5:		dc.b 29,27,"E2",13,10,10,0
		even

		END
