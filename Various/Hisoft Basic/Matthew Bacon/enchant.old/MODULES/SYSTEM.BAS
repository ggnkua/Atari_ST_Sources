
' [SYSTEM.BAS]
' This source document is apart of the ENhanCed Hisoft ApplicatioN toolkiT (ENCHANT)
' Developed by Matthew Bacon & Paul Jones, ½ 1997-1999 Matthew Bacon & Paul Jones

FUNCTION scr_x
	scr_x=PEEKW(SYSTAB+40)
END FUNCTION


FUNCTION scr_y
	scr_y=PEEKW(SYSTAB+42)
END FUNCTION


FUNCTION scr_w
	scr_w=PEEKW(SYSTAB+44)+1
END FUNCTION


FUNCTION scr_h
	scr_h=PEEKW(SYSTAB+46)+1
END FUNCTION


SUB scr_xywh (x,y,w,h)
	x=PEEKW(SYSTAB+40)
	y=PEEKW(SYSTAB+42)
	w=PEEKW(SYSTAB+44)+1
	h=PEEKW(SYSTAB+46)+1
END SUB


FUNCTION scr_colors&
	scr_colors&=2^PEEKW(SYSTAB)
END FUNCTION


FUNCTION scr_planes
	scr_planes=PEEKW(SYSTAB)
END FUNCTION


FUNCTION cookie_cpu&
STATIC dummy,cpu&

dummy=GETCOOKIE ("_CPU",cpu&)
IF dummy=0 THEN
	cookie_cpu&=68000
ELSE
	cookie_cpu&=68000+cpu&
END IF
END FUNCTION


FUNCTION cookie_vshift$
STATIC dummy,vshift&

dummy=GETCOOKIE ("_VDO",vshift&)
IF dummy<>0 THEN
	IF HEX$(vshift&)="00000" THEN cookie_vshift$="ST"
	IF HEX$(vshift&)="10000" THEN cookie_vshift$="STe"
	IF HEX$(vshift&)="20000" THEN cookie_vshift$="TT030"
	IF HEX$(vshift&)="30000" THEN cookie_vshift$="Falcon030"
END IF
END FUNCTION


FUNCTION cookie_fpu$
STATIC dummy,fpu&

dummy=GETCOOKIE ("_FPU",fpu&)
IF dummy<>0 THEN
	IF HEX$(fpu&)="00000" THEN cookie_fpu$="No FPU installed"
	IF HEX$(fpu&)="10000" THEN cookie_fpu$="SFP004"
	IF HEX$(fpu&)="20000" THEN cookie_fpu$="68881 or 68882"
	IF HEX$(fpu&)="30000" THEN cookie_fpu$="68881 or 68882 & SFP004"
	IF HEX$(fpu&)="40000" THEN cookie_fpu$="68881"
	IF HEX$(fpu&)="50000" THEN cookie_fpu$="68881 & SFP004"
	IF HEX$(fpu&)="60000" THEN cookie_fpu$="68882"
	IF HEX$(fpu&)="70000" THEN cookie_fpu$="68882 & SFP004"
	IF HEX$(fpu&)="80000" THEN cookie_fpu$="68040 Internal"
	IF HEX$(fpu&)="90000" THEN cookie_fpu$="68040 Internal & SFP004"
END IF
END FUNCTION


FUNCTION cookie_fdc$
STATIC dummy,dummy$,fdc&

dummy=GETCOOKIE ("_FDC",fdc&)
IF dummy<>0 THEN
	dummy$=MID$(HEX$(fdc&),3,1)
	SELECT CASE dummy$
		CASE "F" : cookie_fdc$="360 Kb/720 Kb"
		CASE "1" : cookie_fdc$="1.44 Mb"
		CASE "2" : cookie_fdc$="2.88 Mb"
	END SELECT
END IF
END FUNCTION


FUNCTION cookie_machine$
STATIC dummy,mch&

dummy=GETCOOKIE ("_MCH",mch&)
IF dummy<>0 THEN
	IF HEX$(mch&)="00000" THEN cookie_machine$="ST"
	IF HEX$(mch&)="10000" THEN cookie_machine$="STe"
	IF HEX$(mch&)="10008" THEN cookie_machine$="ST Book"
	IF HEX$(mch&)="10010" THEN cookie_machine$="Mega STe"
	IF HEX$(mch&)="10016" THEN cookie_machine$="Mega STe"
	IF HEX$(mch&)="20000" THEN cookie_machine$="TT030"
	IF HEX$(mch&)="30000" THEN cookie_machine$="Falcon030"
ELSE
	cookie_machine$="ST"
END IF
END FUNCTION


SUB cookie_lang$ (lang_key$,lang_desk$)
STATIC dummy,lan&,keybrd

dummy=GETCOOKIE ("_AKP",lan&)
PRINT "lang:"+HEX$(lan&)
keybrd=0
DO
	IF lan&>255 THEN INCR keybrd : lan&=lan&-256
LOOP UNTIL lan&<256

SELECT CASE keybrd
	CASE 0 : lang_key$="USA"
	CASE 1 : lang_key$="Germany"
	CASE 2 : lang_key$="France"
	CASE 3 : lang_key$="United Kingdom"
	CASE 4 : lang_key$="Spain"
	CASE 5 : lang_key$="Italy"
	CASE 6 : lang_key$="Sweden"
	CASE 7 : lang_key$="Switzerland (French)"
	CASE 8 : lang_key$="Switzerland (German)"
	CASE 9 : lang_key$="Turkey"
	CASE 10 : lang_key$="Finland"
	CASE 11 : lang_key$="Norway"
	CASE 12 : lang_key$="Denmark"
	CASE 13 : lang_key$="Saudi Arabia"
	CASE 14 : lang_key$="Holland"
	CASE 15 : lang_key$="Czechoslovakia"
	CASE 16 : lang_key$="Hungary"
	CASE ELSE : lang_key$="Unknown"
END SELECT

SELECT CASE lan&
	CASE 0 : lang_desk$="USA"
	CASE 1 : lang_desk$="Germany"
	CASE 2 : lang_desk$="France"
	CASE 3 : lang_desk$="United Kingdom"
	CASE 4 : lang_desk$="Spain"
	CASE 5 : lang_desk$="Italy"
	CASE 6 : lang_desk$="Sweden"
	CASE 7 : lang_desk$="Switzerland (French)"
	CASE 8 : lang_desk$="Switzerland (German)"
	CASE 9 : lang_desk$="Turkey"
	CASE 10 : lang_desk$="Finland"
	CASE 11 : lang_desk$="Norway"
	CASE 12 : lang_desk$="Denmark"
	CASE 13 : lang_desk$="Saudi Arabia"
	CASE 14 : lang_desk$="Holland"
	CASE 15 : lang_desk$="Czechoslovakia"
	CASE 16 : lang_desk$="Hungary"
	CASE ELSE : lang_desk$="Unknown"
END SELECT
END SUB


FUNCTION cookie_fsmc$
STATIC dummy,fsmc&

dummy=GETCOOKIE ("FSMC",fsmc&)
IF dummy<>0 THEN
	cookie_fsmc$="SpeedoGDOS installed"
ELSE
	cookie_fsmc$="SpeedoGDOS NOT installed"
END IF
END FUNCTION


FUNCTION cookie_fsmc
STATIC dummy,fsmc&

dummy=GETCOOKIE ("FSMC",fsmc&)
IF dummy<>0 THEN
	cookie_fsmc=-1
ELSE
	cookie_fsmc=0
END IF
END FUNCTION


FUNCTION max_progs
STATIC dummy

dummy=PEEKW(PEEKL(GB+4)+2)
max_progs=dummy
END FUNCTION


FUNCTION cookie_tasking$
STATIC dummy,dum&

IF max_progs>1 THEN
	IF GETCOOKIE("MagX",dum&) THEN cookie_tasking$="MagiC Multitasking O/S" : EXIT FUNCTION
	IF GETCOOKIE("Gnva",dum&) THEN cookie_tasking$="Geneva Multitasking O/S" : EXIT FUNCTION
	IF GETCOOKIE("MINT",dum&) THEN cookie_tasking$="MultiTOS O/S (MINT)" : EXIT FUNCTION
ELSE
	cookie_tasking$="Standard TOS Single tasking"
END IF
END FUNCTION


FUNCTION cookie_sound (cookie_sound$)
STATIC dummy,snd&,dummy$

cookie_sound$="00000"
dummy=GETCOOKIE("_SND",snd&)
IF dummy<>0 THEN
	cookie_sound=-1
	IF (GETCOOKIE("_SND",snd&) AND 0)<>0 THEN MID$(cookie_sound$,1,1)="1"
	IF (GETCOOKIE("_SND",snd&) AND 1)<>0 THEN MID$(cookie_sound$,2,1)="1"
	IF (GETCOOKIE("_SND",snd&) AND 2)<>0 THEN MID$(cookie_sound$,3,1)="1"
	IF (GETCOOKIE("_SND",snd&) AND 3)<>0 THEN MID$(cookie_sound$,4,1)="1"
	IF (GETCOOKIE("_SND",snd&) AND 4)<>0 THEN MID$(cookie_sound$,5,1)="1"
ELSE
	cookie_sound=0
END IF
END FUNCTION


FUNCTION howmanydrives
STATIC dummy

dummy=SPEEKW(&h4A6)
howmanydrives=dummy
END FUNCTION


SUB set_howmanydrives(drives)
	IF drives>0 THEN SPOKEW &h4A6,drives
END SUB


FUNCTION tosversion$ (tosdate$)
STATIC dummy$,dummy&

dummy&=SPEEKL(&h4F2)
tosdate$=HEX$(SPEEKL(dummy&+24))
dummy$=HEX$(SPEEKL(dummy&+2))
tosversion$=LEFT$(dummy$,1)+"."+MID$(dummy$,2,2)
END FUNCTION


FUNCTION autoGEM
STATIC dummy

dummy=PEEKW(PEEKL(GB+4))
IF dummy=0 THEN
	autoGEM=-1
ELSE
	autoGEM=0
END IF
END FUNCTION


FUNCTION seekrate
STATIC dummy

dummy=SPEEKW(&h440)
seekrate=dummy
END FUNCTION


FUNCTION fverify
STATIC dummy

dummy=SPEEKW(&h444)
IF dummy=0 THEN
	fverify=0
ELSE
	fverify=-1
END IF
END FUNCTION


FUNCTION bootdev
STATIC dummy

dummy=SPEEKW(&h446)
bootdev=dummy
END FUNCTION


FUNCTION palmode
STATIC dummy

dummy=SPEEKW(&h448)
IF dummy=0 THEN
	palmode=60 'Hz
ELSE
	palmode=50 'Hz
END IF
END FUNCTION


SUB conterm (bell,click,key_repeat)
IF bell AND click AND key_repeat=1 THEN SPOKEB &h484,1111
IF bell AND key_repeat=1 THEN IF click=0 THEN SPOKEB &h484,1110
IF bell AND click=1 THEN IF key_repeat=0 THEN SPOKEB &h484,1101
IF key_repeat AND click=0 THEN IF bell=1 THEN SPOKEB &h484,1100
IF key_repeat AND click=1 THEN IF bell=0 THEN SPOKEB &h484,1011
IF bell AND click=0 THEN IF key_repeat=1 THEN SPOKEB &h484,1010
IF bell AND key_repeat=0 THEN IF click=1 THEN SPOKEB &h484,1001
IF bell AND click AND key_repeat=0 THEN SPOKEB &h484,1000
END SUB


FUNCTION appl_id
appl_id=PEEKW(PEEKL(GB+4)+ap_id)
END FUNCTION


SUB MultiTOS_name (name$)
STATIC mpos,id

id=appl_id
IF max_progs=-1 OR PEEKW(PEEKL(GB+4))>=&H410 THEN mpos=menu_register(id,name$)
END SUB

'[*END OF FILE*]
