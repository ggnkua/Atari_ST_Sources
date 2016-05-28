
*-----------------------------------------------------------------
*	 **  *    * **** ****    ***    **  **** ***  ***
* 	*  * **  ** *  * *       *  *  *  * *     *  *
* 	**** * ** * *  * ****    ****  **** ****  *  *
* 	*  * *    * *  *    *    *   * *  *    *  *  *  
* 	*  * *    * **** ****    ****  *  * **** ***  ***
*-----------------------------------------------------------------
*	AMOS.ENV pointers
*-----------------------------------------------------------------
*	By Francois Lionet
*	
*	AMOS (c) 1990 Mandarin / Jawx
*-----------------------------------------------------------------
*	This file is public domain!
*-----------------------------------------------------------------

Mixed:		equ %0100000000000000
Fixed:		equ %0010000000000000
Keys:		equ %0001000000000000
FkTDef		equ 6

*************** Message pointers
AEdMem:		rs.w 2			*EdMem-ZZ,$0001
AEdOm:		rs.w 2			*EdOm-ZZ,$0001
AEdTop:		rs.w 2			*EdTop-ZZ,$0001
AEdBot:		rs.w 2			*EdBot-ZZ,$0001
AEdLLong:	rs.w 2			*EdLLong-ZZ,$0001
AEdTest:	rs.w 2			*EdTest-ZZ,$0001
AEdNoE:		rs.w 2			*EdNoE-ZZ,$0001
AEdInd:		rs.w 2			*EdInd-ZZ,$0001
ANoFold		rs.w 2			*NoFold-ZZ,$0001
ANMark		rs.w 2			*NMark-ZZ,$0001
AWBloc		rs.w 2			*WBloc-ZZ,$0001
ANFound		rs.w 2			*NFound-ZZ,$0001
ASching		rs.w 2			*Sching-ZZ,$0001
AMPAmos		rs.w 2			*MPAmos-ZZ,$0001
AMPlace		rs.w 2			*MPlace-ZZ,$0001
AAvNoProg	rs.w 2			*AvNoProg-ZZ,$0001
AMesNotD:	rs.w 2			*MesNotD-ZZ,$0001
ACloClo:	rs.w 2			*CloClo-ZZ,$0001
AEdDemo:	rs.w 2			*EdDemo-ZZ,$0001

AVIlD:		rs.w 2			*VIlD-ZZ,$0002
AVSynt:		rs.w 2			*VSynt-ZZ,$0002
AVLong:		rs.w 2			*VLong-ZZ,$0002
AVType:		rs.w 2			*VType-ZZ,$0002
AVOut:		rs.w 2			*VOut-ZZ,$0002
AVVNm:		rs.w 2			*VVNm-ZZ,$0002
AVNmO:		rs.w 2			*VNmO-ZZ,$0002
AVNDim:		rs.w 2			*VNDim-ZZ,$0002
AVLbl2:		rs.w 2			*VLbl2-ZZ,$0002
AVUnd:		rs.w 2			*VUnd-ZZ,$0002
AVAlD:		rs.w 2			*VAlD-ZZ,$0002
AVFoN:		rs.w 2			*VFoN-ZZ,$0002
AVNFo:		rs.w 2			*VNFo-ZZ,$0002
AVRUn:		rs.w 2			*VRun-ZZ,$0002
AVUnR:		rs.w 2			*VUnR-ZZ,$0002
AVWWn:		rs.w 2			*VWWn-ZZ,$0002
AVWnW:		rs.w 2			*VWnW-ZZ,$0002
AVDoL:		rs.w 2			*VDoL-ZZ,$0002
AVLDo:		rs.w 2			*VLDo-ZZ,$0002
AVCrs:		rs.w 2			*VCrs-ZZ,$0002
AVNoL:		rs.w 2			*VNoL-ZZ,$0002
AVEIf:		rs.w 2			*VEIf-ZZ,$0002
AVElE:		rs.w 2			*VElE-ZZ,$0002
AVElI:		rs.w 2			*VElI-ZZ,$0002
AVIfE:		rs.w 2			*VIfE-ZZ,$0002
AVNoT:		rs.w 2			*VNoT-ZZ,$0002
AVPDeb:		rs.w 2			*VPDeb-ZZ,$0002
AVPOp:		rs.w 2			*VPOp-ZZ,$0002
AVPNo:		rs.w 2			*VPNo-ZZ,$0002
AVIlP:		rs.w 2			*VIlP-ZZ,$0002
AVPRTy:		rs.w 2			*VPRTy-ZZ,$0002
AVUndP:		rs.w 2			*VUndP-ZZ,$0002
AVShP:		rs.w 2			*VShP-ZZ,$0002
AVAlG:		rs.w 2			*VAlG-ZZ,$0002
AVPaG:		rs.w 2			*VPaG-ZZ,$0002
AVShal:		rs.w 2			*VShal-ZZ,$0002
AVNoPa:		rs.w 2			*VNoPa-ZZ,$0002
AVPaGo:		rs.w 2			*VPaGo-ZZ,$0002
AVVTo:		rs.w 2			*VVTo-ZZ,$0002
AVDal:		rs.w 2			*VDal-ZZ,$0002
AVNoB:		rs.w 2			*VNoB-ZZ,$0002
AVExN:		rs.w 2			*VExN-ZZ,$0002
AVNFn:		rs.w 2			*VNFn-ZZ,$0002
AExtNot:	rs.w 2			*ExtNot-ZZ,$0000

AMErreur:	rs.w 2			*MErreur-ZZ,$8003
ARedo:		rs.w 2			*Redo-ZZ,$0003+Mixed

AExtNames:	rs.w 2			*ExtNames-ZZ,$8004

ASelDrv:	rs.w 2			*SelDrv-ZZ,$8005+Empty
ANmPrt:		rs.w 2			*NmPrt-ZZ,$0005
ANmSer:		rs.w 2			*NmSer-ZZ,$0005

AMesLd1:	rs.w 2			*MesLd1-ZZ,$0006+Empty
AMesLd2:	rs.w 2			*MesLd2-ZZ,$0006+Empty
AMesLd3:	rs.w 2			*MesLd3-ZZ,$0006+Empty
AMesMe1:	rs.w 2			*MesMe1-ZZ,$0006+Empty
AMesMe2:	rs.w 2			*MesMe2-ZZ,$0006+Empty
AMesLdA1:	rs.w 2			*MesLdA1-ZZ,$0006+Empty
AMesLdA2:	rs.w 2			*MesLdA2-ZZ,$0006+Empty
AMesLdA3:	rs.w 2			*MesLdA3-ZZ,$0006+Empty
AAvMe:		rs.w 2			*AvMe-ZZ,$0006+Empty
AAvLd:		rs.w 2			*AvLd-ZZ,$0006+Empty
AAvPrt:		rs.w 2			*AvPrt-ZZ,$0006+Empty
AMesSv1:	rs.w 2			*MesSv1-ZZ,$0006+Empty
AMesSv2:	rs.w 2			*MesSv2-ZZ,$0006+Empty
AMesSBl1:	rs.w 2			*MesSBl1-ZZ,$0006+Empty
AMesSBl2:	rs.w 2			*MesSBl2-ZZ,$0006+Empty
AMesSvA1:	rs.w 2			*MesSvA1-ZZ,$0006+Empty
AMesSvA2:	rs.w 2			*MesSvA2-ZZ,$0006+Empty
AMesSvA3:	rs.w 2			*MesSvA3-ZZ,$0006+Empty
AAvSv:		rs.w 2			*AvSv-ZZ,$0006+Empty
AAvSvA:		rs.w 2			*AvSvA-ZZ,$0006+Empty
AMesAc1:	rs.w 2			*MesAc1-ZZ,$0006+Empty
AMesAc2:	rs.w 2			*MesAc2-ZZ,$0006+Empty
AMesAc3:	rs.w 2			*MesAc3-ZZ,$0006+Empty
AMesAn1:	rs.w 2			*MesAn1-ZZ,$0006+Empty
AMesAn2:	rs.w 2			*MesAn2-ZZ,$0006+Empty
AMesAn3:	rs.w 2			*MesAn3-ZZ,$0006+Empty
AMesEd1:	rs.w 2			*MesEd1-ZZ,$0006+Empty
AMesEd2:	rs.w 2			*MesEd2-ZZ,$0006+Empty
AMesEd3:	rs.w 2			*MesEd3-ZZ,$0006+Empty
AMesRn1:	rs.w 2			*MesRn1-ZZ,$0006+Empty
AMesRn2:	rs.w 2			*MesRn2-ZZ,$0006+Empty
AMesRn3:	rs.w 2			*MesRn3-ZZ,$0006+Empty
AAvAccL:	rs.w 2			*AvAccL-ZZ,$0006+Empty

AEdPName:	rs.w 2			*EdPName-ZZ,$0001
AEdLName:	rs.w 2
ASMark:		rs.w 2			*SMark-ZZ,$0001
AEdTSize:	rs.w 2			*EdTSize-ZZ,$0001
AEdTTab:	rs.w 2			*EdTTab-ZZ,$0001
ASchinp:	rs.w 2			*Schinp-ZZ,$0001
ARepinp:	rs.w 2			*Repinp-ZZ,$0001

AFsTxt:		rs.w 2			*FsTxt-ZZ,$8006+Mixed+Fixed
AFaTxt:		rs.w 2			*FaTxt-ZZ,$8006+Mixed+Fixed
AFsWait:	rs.w 2			*FsWait-ZZ,$0006
AFsDTit:	rs.w 2			*FsDTit-ZZ,$0006
AFsDirSet:	rs.w 2			*FsDirSet-ZZ,$0006

*************** Editor messages
AConfYes:	rs.w 2			*ConfYes-ZZ,$0001
AConfNo:	rs.w 2			*ConfNo-ZZ,$0001
AConfConf:	rs.w 2			*ConfConf-ZZ,$0001
AConfSave:	rs.w 2			*ConfSave-ZZ,$0001
AConfText:	rs.w 2			*ConfText-ZZ,$0001
ADispText:	rs.w 2			*DispText-ZZ,$0001

AConfYN:	rs.w 2			*ConfYN-ZZ,$0001+Mixed
AConfYi:	rs.w 2			*ConfYi-ZZ,$0001+Mixed
AConfNi:	rs.w 2			*ConfNi-ZZ,$0001+Mixed

*************** Function key
AFkDef1:	rs.w 2			*FkDef1-ZZ,$0000
AFkDef2:	rs.w 2			*FkDef2-ZZ,$0000
AFkDef3:	rs.w 2			*FkDef3-ZZ,$0000
AFkDef4:	rs.w 2			*FkDef4-ZZ,$0000
AFkDef5:	rs.w 2			*FkDef5-ZZ,$0000
AFkIt0:		rs.w 2			*FkIt0-ZZ,$0007+Fixed
AFkIt1:		rs.w 2			*FkIt1-ZZ,$0007+Fixed
AFkLt0:		rs.w 2			*FkLt0-ZZ,$0007+Fixed
AFkLt1:		rs.w 2			*FkLt1-ZZ,$0007+Fixed

*************** Cursor flash
AEdFlCu:	rs.w 2			*EdFlCu-ZZ,$0000
AFolFl:		rs.w 2			*FolFl-ZZ,$0000

*************** Error screen 
AErrLine:	rs.w 2			*ErrLine-ZZ,$000a
AErrFin:	rs.w 2			*ErrFin-ZZ,$000a+Mixed
AFolI2:		rs.w 2			*FolI2-ZZ,$000a+Mixed

*************** Directory
ADirFilt:	rs.w 2			*DirFilt-ZZ,$0010
AChDir0:	rs.w 2			*ChDir0-ZZ,$000b+Mixed
AChDir1:	rs.w 2			*ChDir1-ZZ,$000b+Mixed
AChDir6:	rs.w 2			*CHDir6-ZZ,$000b+Mixed
AChDir3:	rs.w 2			*ChDir3-ZZ,$000b

*************** Info line
AMrgMes		rs.w 2			*MrgMes-ZZ,$0001+Mixed+Fixed
* Caps
AEtCps0:	rs.w 2			*EtCps0-ZZ,$0001+Mixed+Fixed
AEtCps1:	rs.w 2			*EtCps1-ZZ,$0001+Mixed+Fixed
* Insert / OverW
AEtIns0:	rs.w 2			*EtIns0-ZZ,$0001+Mixed+Fixed
AEtIns1:	rs.w 2			*EtIns1-ZZ,$0001+Mixed+Fixed
* Line #
AEtY:		rs.w 2			*EtY-ZZ,$0001+Mixed+Fixed
AEtY1:		rs.w 2			*EtY1-ZZ,$0001+Mixed+Fixed
* Col#
AEtX:		rs.w 2			*EtX-ZZ,$0001+Mixed+Fixed
AEtX1:		rs.w 2			*EtX1-ZZ,$0001+Mixed+Fixed
* Free
AEtFr0:		rs.w 2			*EtFr0-ZZ,$0001+Mixed+Fixed
AEtFr1:		rs.w 2			*EtFr1-ZZ,$0001+Mixed+Fixed
* Chip
AEtCh0:		rs.w 2			*EtCh0-ZZ,$0001+Mixed+Fixed
AEtCh1:		rs.w 2			*EtCh1-ZZ,$0001+Mixed+Fixed
* Fast
AEtFs0:		rs.w 2			*EtFs0-ZZ,$0001+Mixed+Fixed
AEtFs1:		rs.w 2			*EtFs1-ZZ,$0001+Mixed+Fixed
* Editing
AEtNm1:		rs.w 2			*EtNm1-ZZ,$0001+Mixed+Fixed
AEtNm2:		rs.w 2			*EtNm2-ZZ,$0001+Mixed+Fixed

*************** Editor functions
AKFonc:		rs.w 2			*KFonc-ZZ,$000F+Keys

*************** HELP escape
AEscH1:		rs.w 2			*EscH1-ZZ,$000c+Mixed
AEscH2:		rs.w 2			*EscH2-ZZ,$800c+Fixed
	
*************** Esc screen function keys
AAmiDef:	rs.w 2			*AmiDef-ZZ,$800d+Empty

*************** Auto loaded acc
AAutoLd		rs.w 2			*AutoLd-ZZ,$8011+Empty

*************** Help.Acc
ANameHelp	rs.w 2			*NameHelp-ZZ,$0013+Empty
AHelpLoad	rs.w 2			*HelpLoad-ZZ,$0013+Empty
AHNoF		rs.w 2

*************** Basic header
AEntete:	rs.w 2			*Entete-ZZ,0
*************** FK window
AFkFond:	rs.w 2			*FkFond-ZZ,0 
*************** Edit window
AEdClw:		rs.w 2			*EdClw-ZZ,0 
ASlDInit:	rs.w 2			*SlDInit-ZZ,0 
ASlBInit:	rs.w 2			*SlBInit-ZZ,0 
AEdDBloc	rs.w 2			*EdDBloc-ZZ,0 
AEdFBloc	rs.w 2			*EdFBloc-ZZ,0 
*************** Basic title
ATitle1:	rs.w 2			*Title1-ZZ,$000e+Mixed+Fixed+Empty
ATitle2:	rs.w 2			*Title2-ZZ,0 
*************** Suffix
ASufBas:	rs.w 2			*SufBas-ZZ,0 
ASufBak:	rs.w 2			*SufBak-ZZ,0 
ASufAcc:	rs.w 2			*SufAcc-ZZ,0 
AAutoEx:	rs.w 2			*AutoEx-ZZ,0 
*************** Default icon
ADefIcon	rs.w 2			*DefIcon-ZZ,$0012 
*************** AMOS Logo
ANMouse:	rs.w 2			*NMouse-ZZ,$0012 
ANFonte:	rs.w 2			*NFonte-ZZ,$0012
*************** Default Keyboard
AKyNom:		rs.w 2			*KyNom-ZZ,$00012 
*************** Diverse
ACRet:		rs.w 2			*CRet-ZZ,0 
AChCuOn:	rs.w 2			*ChCuOn-ZZ,0 
AChCuOff:	rs.w 2			*ChCuOff-ZZ,0 
AChDir1a:	rs.w 2			*ChDir1A-ZZ,0 
AChDir2:	rs.w 2			*ChDir2-ZZ,0 
AChDir4: 	rs.w 2			*ChDir4-ZZ,0 
AChDir5:	rs.w 2			*ChDir5-ZZ,0 
AEtInp:		rs.w 2			*EtInp-ZZ,0 
AEtClw:		rs.w 2			*EtClw-ZZ,0 
AEtCuOf		rs.w 2			*EtCuOf-ZZ,0 
AEtAl:		rs.w 2			*EtAl-ZZ,0 
ADefEFl:	rs.w 2			*DefEFl-ZZ,0 
AErrIOn:	rs.w 2			*ErrIOn-ZZ,0 
AErrIOff:	rs.w 2			*ErrIOff-ZZ,0 
AErrIci:	rs.w 2			*ErrIci-ZZ,0 
AErrFl:		rs.w 2			*ErrFl-ZZ,0 
AFolI1:		rs.w 2			*FolI1-ZZ,0 
AFolI3:		rs.w 2			*FolI3-ZZ,0 
AFolI4:		rs.w 2			*FolI4-ZZ,0 
AFolI5:		rs.w 2			*FolI5-ZZ,0 
AEscI:		rs.w 2			*EscI-ZZ,0 
AEscOk:		rs.w 2			*EscOk-ZZ,0 
AEscI0:		rs.w 2			*EscI0-ZZ,0 
AEdELi:		rs.w 2			*EdELi-ZZ,0 
AEscH4:		rs.w 2			*EscH4-ZZ,0 
AEscH5:		rs.w 2			*EscH5-ZZ,0 
		rs.w 2			*EndPar-ParaTrap


***********************************************************
*		AMOS PARAMETRES 
ParaTrap:	rs.l 1
AdMouse:	rs.l 1
		rs.l 1
		rs.l 1
		rs.l 1

VNmMax:		rs.l 1
TVDirect:	rs.w 1
DefSize:	rs.l 1
Icons:		rs.w 1
EdPosY:		rs.w 1
FkPosY:		rs.w 1
FsDWy:		rs.w 1
EdTyM0:		rs.w 1
EdTyM1:		rs.w 1
EdTyM2:		rs.w 1
DirSize:	rs.w 1
DirMax:		rs.w 1
EdSvBak:	rs.w 1
PrtRet:		rs.w 1
FsDVApp:	rs.w 1
EdVScrol:	rs.w 1
		rs.w 1
EdPal:		rs.w 4
FkPal:		rs.w 4
FsPal:		rs.w 4
EscPal:		rs.w 4
ErrPal:		rs.w 4
FolPal		rs.w 4
EdColB:		rs.w 1
AutoWB:		rs.w 1
InterFonc:	rs.w 1
InterEdit:	rs.w 1
FsDWx:		rs.w 1
EcYErr:		rs.w 1
EsWY:		rs.w 1
EsWTy:		rs.w 1
EsVY:		rs.w 1
DefETx:		rs.w 1
DefETy:		rs.w 1
DefECo:		rs.w 1
DefECoN:	rs.w 1
DefEMo:		rs.w 1
DefEBa:		rs.w 1
DefEPa:		rs.w 8
		rs.w 8
		rs.w 8
		rs.w 8
EndPar:
