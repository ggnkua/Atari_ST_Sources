64000 DEF PROC Gem: PRINT : PRINT "GEMLIB 3.01": PRINT "Release 08.12.88": RETURN
64001 END 'GEM Library fÅr OMIKRON-BASIC. Version 3.00.
64002 'Copyright (C) Artur Sîdler, Pforzheim & Thomas Kemp, Birkenfeld
64003 '
64004 'AES
64005 '
64006 DEF PROC Appl_Init: LOCAL X%L,Y%L,W%L,H%L,I%L
64007    Patch_Basic $63,32,$6604,$6602:Patch_Basic $148,38,$6402,$6404
64008    DIM Ctrl%(12),Intin%(128),Addrout%L(1),Intout%(128),Ptsin%(1,128),Ptsout%(1,6),Addrin%L(3),Global%(15)
64009    Mn_Selected%L=10:Wm_Redraw%L=20:Wm_Topped%L=21:Wm_Closed%L=22:Wm_Fulled%L=23:Wm_Arrowed%L=24:Wm_Hslid%L=25
64010    Wm_Vslid%L=26:Wm_Sized%L=27:Wm_Moved%L=28:Wm_Newtop%L=29:Ac_Open%L=40:Ac_Close%L=41:Mu_Keybd%L=1:Mu_Button%L=2
64011    Mu_M1%L=4:Mu_M2%L=8:Mu_Mesag%L=16:Mu_Timer%L=32: PRINT "f";: IF Accessory%L=0 THEN Appl_Exit_Sub
64012    Graf_Handle(Ctrl%(6),W%L,H%L,0,0): MOUSEON : IF Accessory%L THEN EXIT
64013    MOUSEOFF : NDC :Vs_Ndc: MODE =1: FILL COLOR =1: OUTLINE ON : LINE COLOR =1: LINE STYLE =1
64014    LINE WIDTH = 1: TEXT COLOR =1: TEXT STYLE =0: TEXT ROTATION = 0: FILL STYLE =0,1:Graf_Mouse(0)
64015    FOR I%L=1 TO 100:Vst_Height(I%L,0,0,X%L,Y%L): IF X%L=W%L AND Y%L=H%L THEN TEXT HEIGHT =I%L: EXIT ENDIF NEXT I%L
64016    Wind_Get(0,4,X%L,Y%L,W%L,H%L): CLIP 0,0,W%L,Y%L+H%L: PBOX -1,-1,W%L+2,Y%L+1: FILL STYLE =1,1: CLIP X%L,Y%L,W%L,H%L
64017    PRINT "fHHY AOMIKRON.BASIC";:Form_Dial(0,X%L,Y%L,W%L,H%L):Form_Dial(3,X%L,Y%L,W%L,H%L): MOUSEON
64018    RETURN
64019 '
64020 DEF PROC Appl_Read(Intin%(1),R Text$,R Intout%(0))
64021    Intin%(0)=Global%(2):Text$= CHR$(0)*Intin%(1)
64022    Addrin%L(0)= LPEEK( VARPTR(Text$))+ LPEEK( SEGPTR +28)
64023    AES (11,Global%(15),Intin%(2),Addrin%L(1),Intout%(1),Addrout%L(0))
64024    RETURN
64025 '
64026 DEF PROC Appl_Write(Intin%(0),Text$,R Intout%(0)):Intin%(1)= LEN(Text$)
64027    Addrin%L(0)= LPEEK( VARPTR(Text$))+ LPEEK( SEGPTR +28)
64028    AES (12,Global%(15),Intin%(2),Addrin%L(1),Intout%(1),Addrout%L(0))
64029    RETURN
64030 '
64031 DEF PROC Appl_Find(Text$,R Intout%(0))
64032    Addrin%L(0)= MEMORY( LEFT$(Text$+ SPC(8),8))
64033    AES (13,Global%(15),Intin%(0),Addrin%L(1),Intout%(1),Addrout%L(0))
64034    FRE Addrin%L(0): RETURN
64035 '
64036 DEF PROC Appl_Tplay(Intin%(0),Intin%(1),Addrin%L(0))
64037    AES (14,Global%(15),Intin%(2),Addrin%L(1),Intout%(1),Addrout%L(0))
64038    RETURN
64039 '
64040 DEF PROC Appl_Trecord(Intin%(0),Addrin%L(0))
64041    AES (15,Global%(15),Intin%(1),Addrin%L(1),Intout%(1),Addrout%L(0))
64042    RETURN
64043 '
64044 DEF PROC Appl_Exit_Sub: LOCAL I%L
64045    FOR I%L=24 TO 28 STEP 2:Ctrl%(6)= WPEEK(FN Reserved%L(I%L)):V_Clsvwk: NEXT
64046    FOR I%L=18 TO 22 STEP 2:Ctrl%(6)= WPEEK(FN Reserved%L(I%L)):V_Clswk: NEXT
64047    FOR I%L=1 TO 10:Wind_Delete(I%L): NEXT
64048    Form_Dial(3,0,0,1,1)
64049    Wind_Update(0):Wind_Update(2)
64050    Vs_Ndc:Menu_Bar
64051    FOR I%L=6 TO 34 STEP 4
64052       IF I%L=10 THEN I%L=30
64053       Global%(5)= WPEEK(FN Reserved%L(I%L)):Global%(6)= WPEEK(FN Reserved%L(I%L+2)):Rsrc_Free
64054    NEXT I%L
64055    RETURN
64056 DEF PROC Appl_Exit
64057    MOUSEOFF :Appl_Exit_Sub: PRINT "HHeE";
64058    RETURN
64059 '
64060 DEF PROC Evnt_Keybd(R Intout%(0))
64061    AES (20,Global%(15),Intin%(0),Addrin%L(0),Intout%(1),Addrout%L(0))
64062    RETURN
64063 '
64064 DEF PROC Evnt_Button(Intin%(0),Intin%(1),Intin%(2),R Intout%(0),R Intout%(1),R Intout%(2),R Intout%(3),R Intout%(4))
64065    AES (21,Global%(15),Intin%(3),Addrin%L(0),Intout%(5),Addrout%L(0))
64066    RETURN
64067 '
64068 DEF PROC Evnt_Mouse(Intin%(0),Intin%(1),Intin%(2),Intin%(3),Intin%(4),R Intout%(1),R Intout%(2),R Intout%(3),R Intout%(4))
64069    AES (22,Global%(15),Intin%(5),Addrin%L(0),Intout%(5),Addrout%L(0))
64070    RETURN
64071 '
64072 DEF PROC Evnt_Mesag(R Text$):Text$= CHR$(0)*16
64073    Addrin%L(0)= LPEEK( VARPTR(Text$))+ LPEEK( SEGPTR +28)
64074    AES (23,Global%(15),Intin%(0),Addrin%L(1),Intout%(1),Addrout%L(0))
64075    IF CVI(Text$)=41 THEN LPOKE FN Reserved%L(10), LPEEK(FN Reserved%L(10)) AND 7 SHL 29: LPOKE FN Reserved%L(14), LPEEK(FN Reserved%L(14)) AND 7 SHL 29
64076    RETURN
64077 '
64078 DEF PROC Evnt_Timer(T%L):Intin%(0)= LOW(T%L):Intin%(1)= HIGH(T%L)
64079    AES (24,Global%(15),Intin%(2),Addrin%L(0),Intout%(1),Addrout%L(0))
64080    RETURN
64081 '
64082 DEF PROC Evnt_Multi(Intin%(0),Intin%(1),Intin%(2),Intin%(3),Intin%(4),Intin%(5),Intin%(6),Intin%(7),Intin%(8),Intin%(9),X%L,Y%L,W%L,H%L,T%L,R Text$,R Intout%(0),R Intout%(1),R Intout%(2),R Intout%(3),R Intout%(4),R Intout%(5),R Intout%(6))
64083    Intin%(10)=X%L:Intin%(11)=Y%L:Intin%(12)=W%L:Intin%(13)=H%L
64084    Intin%(14)= LOW(T%L):Intin%(15)= HIGH(T%L):Text$= CHR$(0)*16
64085    Addrin%L(0)= LPEEK( VARPTR(Text$))+ LPEEK( SEGPTR +28)
64086    AES (25,Global%(15),Intin%(16),Addrin%L(1),Intout%(7),Addrout%L(0))
64087    IF Intout%(0) AND Mu_Mesag%L THEN
64088       IF CVI(Text$)=41 THEN LPOKE FN Reserved%L(10), LPEEK(FN Reserved%L(10)) AND 7 SHL 29: LPOKE FN Reserved%L(14), LPEEK(FN Reserved%L(14)) AND 7 SHL 29
64089    ENDIF RETURN
64090 '
64091 DEF PROC Evnt_Dclick(Intin%(1),R Intout%(0)):Intin%(0)=Intout%(0)
64092    AES (26,Global%(15),Intin%(2),Addrin%L(0),Intout%(1),Addrout%L(0))
64093    RETURN
64094 '
64095 DEF PROC Menu_Bar(X%L)
64096    Menu_Bar%L=X%L:Addrin%L(0)=X%L:Intin%(0)=1
64097    BIT (6,(FN Reserved%L(14)))=1
64098    AES (30,Global%(15),Intin%(1),Addrin%L(1),Intout%(1),Addrout%L(0))
64099    RETURN
64100 DEF PROC Menu_Bar
64101    Intin%(0)=0:Addrin%L(0)=Menu_Bar%L
64102    IF FN Wind_Check%L(30,4) THEN
64103       BIT (6,(FN Reserved%L(14)))=0
64104       AES (30,Global%(15),Intin%(1),Addrin%L(1),Intout%(1),Addrout%L(0))
64105    ENDIF Menu_Bar%L=0: RETURN
64106 '
64107 DEF PROC Menu_Icheck(Intin%(0),Intin%(1)):Addrin%L(0)=Menu_Bar%L
64108    IF Menu_Bar%L THEN
64109       AES (31,Global%(15),Intin%(2),Addrin%L(1),Intout%(1),Addrout%L(0))
64110    ENDIF RETURN
64111 '
64112 DEF PROC Menu_Ienable(Intin%(0),Intin%(1)):Addrin%L(0)=Menu_Bar%L
64113    IF Menu_Bar%L THEN
64114       AES (32,Global%(15),Intin%(2),Addrin%L(1),Intout%(1),Addrout%L(0))
64115    ENDIF RETURN
64116 '
64117 DEF PROC Menu_Tnormal(Intin%(0),Intin%(1)):Addrin%L(0)=Menu_Bar%L
64118    IF Menu_Bar%L THEN
64119       AES (33,Global%(15),Intin%(2),Addrin%L(1),Intout%(1),Addrout%L(0))
64120    ENDIF RETURN
64121 '
64122 DEF PROC Menu_Text(Intin%(0),Text$):Addrin%L(0)=Menu_Bar%L
64123    Addrin%L(1)= LPEEK( VARPTR(Text$))+ LPEEK( SEGPTR +28)
64124    IF Menu_Bar%L THEN
64125       AES (34,Global%(15),Intin%(1),Addrin%L(2),Intout%(1),Addrout%L(0))
64126    ENDIF RETURN
64127 '
64128 DEF PROC Menu_Register(Text$,R Intout%(0))
64129    Addrin%L(0)= MEMORY(Text$):Intin%(0)=Global%(2)
64130    AES (35,Global%(15),Intin%(1),Addrin%L(1),Intout%(1),Addrout%L(0))
64131    RETURN
64132 '
64133 DEF PROC Objc_Add(Intin%(0),Intin%(1),Addrin%L(0))
64134    AES (40,Global%(15),Intin%(2),Addrin%L(1),Intout%(1),Addrout%L(0))
64135    RETURN
64136 '
64137 DEF PROC Objc_Delete(Intin%(0),Addrin%L(0))
64138    AES (41,Global%(15),Intin%(1),Addrin%L(1),Intout%(1),Addrout%L(0))
64139    RETURN
64140 '
64141 DEF PROC Objc_Draw(Intin%(0),Intin%(1),Intin%(2),Intin%(3),Intin%(4),Intin%(5),Addrin%L(0))
64142    AES (42,Global%(15),Intin%(6),Addrin%L(1),Intout%(1),Addrout%L(0))
64143    RETURN
64144 '
64145 DEF PROC Objc_Find(Intin%(0),Intin%(1),Intin%(2),Intin%(3),Addrin%L(0),R Intout%(0))
64146    AES (43,Global%(15),Intin%(4),Addrin%L(1),Intout%(1),Addrout%L(0))
64147    RETURN
64148 '
64149 DEF PROC Objc_Offset(Intin%(0),Addrin%L(0),R Intout%(1),R Intout%(2))
64150    AES (44,Global%(15),Intin%(1),Addrin%L(1),Intout%(3),Addrout%L(0))
64151    RETURN
64152 '
64153 DEF PROC Objc_Order(Intin%(0),Intin%(1),Addrin%L(0))
64154    AES (45,Global%(15),Intin%(2),Addrin%L(1),Intout%(1),Addrout%L(0))
64155    RETURN
64156 '
64157 DEF PROC Objc_Edit(Intin%(0),Intin%(1),R Intin%(2),Intin%(3),Addrin%L(0))
64158    AES (46,Global%(15),Intin%(6),Addrin%L(1),Intout%(2),Addrout%L(0))
64159    Intin%(2)=Intout%(1): RETURN
64160 '
64161 DEF PROC Objc_Change(Intin%(0),Intin%(6),Addrin%L(0))
64162    Intin%(1)=0:Intin%(7)=0
64163    AES (47,Global%(15),Intin%(8),Addrin%L(1),Intout%(1),Addrout%L(0))
64164    RETURN
64165 DEF PROC Objc_Change(Intin%(0),Intin%(6),Intin%(2),Intin%(3),Intin%(4),Intin%(5),Addrin%L(0))
64166    Intin%(1)=0:Intin%(7)=1
64167    AES (47,Global%(15),Intin%(8),Addrin%L(1),Intout%(1),Addrout%L(0))
64168    RETURN
64169 '
64170 DEF PROC Form_Do(Intin%(0),Addrin%L(0),R Intout%(0))
64171    AES (50,Global%(15),Intin%(1),Addrin%L(1),Intout%(1),Addrout%L(0))
64172    RETURN
64173 '
64174 DEF PROC Form_Dial(I%L,X%L,Y%L,W%L,H%L)
64175    Form_Dial(I%L,X%L+W%L SHR 1,Y%L+H%L SHR 1,1,1,X%L,Y%L,W%L,H%L): RETURN
64176 DEF PROC Form_Dial(X%L,Intin%(1),Intin%(2),Intin%(3),Intin%(4),Intin%(5),Intin%(6),Intin%(7),Intin%(8))
64177    Intin%(0)=X%L
64178    IF X%L=0 THEN IF FN Wind_Check%L(29,0) THEN EXIT ELSE BIT (5,(FN Reserved%L(10)))=1
64179    IF X%L=3 THEN IF FN Wind_Check%L(29,0) THEN BIT (5,(FN Reserved%L(10)))=0 ELSE EXIT
64180    AES (51,Global%(15),Intin%(9),Addrin%L(0),Intout%(1),Addrout%L(0))
64181    RETURN
64182 '
64183 DEF PROC Form_Alert(Intin%(0),Text$,R Intout%(0))
64184    Addrin%L(0)= MEMORY(Text$)
64185    AES (52,Global%(15),Intin%(1),Addrin%L(1),Intout%(1),Addrout%L(0))
64186    FRE Addrin%L(0): RETURN
64187 '
64188 DEF PROC Form_Error(Intin%(0))
64189    AES (53,Global%(15),Intin%(1),Addrin%L(0),Intout%(1),Addrout%L(0))
64190    RETURN
64191 '
64192 DEF PROC Form_Center(Addrin%L(0),R Intout%(1),R Intout%(2),R Intout%(3),R Intout%(4))
64193    AES (54,Global%(15),Intin%(0),Addrin%L(1),Intout%(5),Addrout%L(0))
64194    RETURN
64195 '
64196 DEF PROC Form_Keybd(Intin%(0),Intin%(1),Intin%(2),Addrin%L(0),R Intout%(0),R Intout%(1),R Intout%(2))
64197    AES (55,Global%(15),Intin%(3),Addrin%L(1),Intout%(3),Addrout%L(0))
64198    RETURN
64199 '
64200 DEF PROC Form_Button(Intin%(0),Intin%(1),Addrin%L(0),R Intout%(0))
64201    AES (56,Global%(15),Intin%(2),Addrin%L(1),Intout%(1),Addrout%L(0))
64202    RETURN
64203 '
64204 DEF PROC Graf_Rubberbox(Intin%(0),Intin%(1),Intin%(2),Intin%(3),R Intout%(1),R Intout%(2))
64205    AES (70,Global%(15),Intin%(4),Addrin%L(0),Intout%(3),Addrout%L(0))
64206    RETURN
64207 '
64208 DEF PROC Graf_Dragbox(Intin%(0),Intin%(1),Intin%(2),Intin%(3),Intin%(4),Intin%(5),Intin%(6),Intin%(7),R Intout%(1),R Intout%(2))
64209    AES (71,Global%(15),Intin%(8),Addrin%L(0),Intout%(3),Addrout%L(0))
64210    RETURN
64211 '
64212 DEF PROC Graf_Movebox(Intin%(0),Intin%(1),Intin%(2),Intin%(3),Intin%(4),Intin%(5))
64213    AES (72,Global%(15),Intin%(6),Addrin%L(0),Intout%(1),Addrout%L(0))
64214    RETURN
64215 '
64216 DEF PROC Graf_Growbox(Intin%(0),Intin%(1),Intin%(2),Intin%(3),Intin%(4),Intin%(5),Intin%(6),Intin%(7))
64217    AES (73,Global%(15),Intin%(8),Addrin%L(0),Intout%(1),Addrout%L(0))
64218    RETURN
64219 '
64220 DEF PROC Graf_Shrinkbox(Intin%(0),Intin%(1),Intin%(2),Intin%(3),Intin%(4),Intin%(5),Intin%(6),Intin%(7))
64221    AES (74,Global%(15),Intin%(8),Addrin%L(0),Intout%(1),Addrout%L(0))
64222    RETURN
64223 '
64224 DEF PROC Graf_Watchbox(Intin%(1),Intin%(2),Intin%(3),Addrin%L(0),R Intout%(0))
64225    AES (75,Global%(15),Intin%(4),Addrin%L(1),Intout%(1),Addrout%L(0))
64226    RETURN
64227 '
64228 DEF PROC Graf_Slidebox(Intin%(0),Intin%(1),Intin%(2),Addrin%L(0),R Intout%(0))
64229    AES (76,Global%(15),Intin%(3),Addrin%L(1),Intout%(1),Addrout%L(0))
64230    RETURN
64231 '
64232 DEF PROC Graf_Handle(R Intout%(0),R Intout%(1),R Intout%(2),R Intout%(3),R Intout%(4))
64233    AES (77,Global%(15),Intin%(0),Addrin%L(0),Intout%(5),Addrout%L(0))
64234    RETURN
64235 DEF PROC Graf_Handle(R Intout%(0))
64236    AES (77,Global%(15),Intin%(0),Addrin%L(0),Intout%(5),Addrout%L(0))
64237    RETURN
64238 '
64239 DEF PROC Graf_Mouse(X%L,Y%L,W%L,H%L,T%L): LOCAL I%L
64240    IF Graf_Mouse%L=0 THEN Graf_Mouse%L= MEMORY(74)
64241    T%L= LPEEK(T%L)+ LPEEK( SEGPTR +20):Intin%(0)=255
64242    WPOKE Graf_Mouse%L,X%L: WPOKE Graf_Mouse%L+2,Y%L: WPOKE Graf_Mouse%L+4,0
64243    WPOKE Graf_Mouse%L+6,W%L: WPOKE Graf_Mouse%L+8,H%L
64244    FOR I%L=0 TO 62 STEP 2: WPOKE Graf_Mouse%L+10+I%L, WPEEK(T%L+I%L): NEXT
64245    Addrin%L(0)=Graf_Mouse%L
64246    AES (78,Global%(15),Intin%(1),Addrin%L(1),Intout%(1),Addrout%L(0))
64247    RETURN
64248 DEF PROC Graf_Mouse(Intin%(0))
64249    AES (78,Global%(15),Intin%(1),Addrin%L(1),Intout%(1),Addrout%L(0))
64250    RETURN
64251 '
64252 DEF PROC Graf_Mkstate(R Intout%(1),R Intout%(2),R Intout%(3),R Intout%(4))
64253    AES (79,Global%(15),Intin%(0),Addrin%L(0),Intout%(5),Addrout%L(0))
64254    RETURN
64255 '
64256 DEF PROC Scrp_Read(R Text$)
64257    Addrin%L(0)= LPEEK( VARPTR(Text$))+ LPEEK( SEGPTR +28)
64258    AES (80,Global%(15),Intin%(0),Addrin%L(1),Intout%(1),Addrout%L(0))
64259    RETURN
64260 '
64261 DEF PROC Scrp_Write(Text$)
64262    Addrin%L(0)= LPEEK( VARPTR(Text$))+ LPEEK( SEGPTR +28)
64263    AES (81,Global%(15),Intin%(0),Addrin%L(1),Intout%(1),Addrout%L(0))
64264    RETURN
64265 '
64266 DEF PROC Fsel_Input(R Path$,R Text$,R Intout%(1)): LOCAL X%L
64267    Path$= LEFT$(Path$+ CHR$(0)*64,64):Text$= LEFT$(Text$+ CHR$(0)*13,13)
64268    X%L= VARPTR(Text$):Addrin%L(0)= LPEEK( VARPTR(Path$))+ LPEEK( SEGPTR +28)
64269    Addrin%L(1)= LPEEK(X%L)+ LPEEK( SEGPTR +28)
64270    AES (90,Global%(15),Intin%(0),Addrin%L(2),Intout%(2),Addrout%L(0))
64271    Text$= LEFT$(Text$, INSTR(Text$+ CHR$(0), CHR$(0))-1)
64272    Path$= LEFT$(Path$, INSTR(Path$+ CHR$(0), CHR$(0))-1): RETURN
64273 '
64274 DEF PROC Fsel_Exinput(R Path$,R Text$,Label$,R Intout%(1)): LOCAL X%L,Y%L,W%L,H%L,I%L,L%L,T%L
64275    IF WPEEK( LPEEK($4F2)+2)<$104 THEN
64276       IF PEEK($44C)=0 THEN X%L=0:Y%L=26:W%L=320:H%L=15
64277       IF PEEK($44C)=1 THEN X%L=157:Y%L=26:W%L=326:H%L=15
64278       IF PEEK($44C)=2 THEN X%L=157:Y%L=54:W%L=326:H%L=30
64279       L%L= LPEEK( SEGPTR -24):T%L= WPEEK(L%L): WPOKE L%L,0:L%L=Ctrl%(6):Graf_Handle(Ctrl%(6)):Vs_Clip
64280       MOUSEOFF :Vswr_Mode(1):Vsf_Perimeter(1):Vsf_Interior(0):Vsf_Color(1)
64281       Vqt_Extent(Label$,0,0,I%L,0,0,0,0,0):I%L=I%L+10: IF I%L>=W%L THEN X%L=X%L-(I%L+1-W%L) SHR 1:W%L=I%L+1
64282       V_Bar(X%L,Y%L-H%L,X%L+W%L-1,Y%L+4):V_Bar(X%L+3,Y%L-H%L+3,X%L+W%L-4,Y%L+1):V_Bar(X%L+4,Y%L-H%L+4,X%L+W%L-5,Y%L)
64283       V_Gtext(X%L+(W%L-I%L-1) SHR 1+5,Y%L-H%L\3+3,Label$): MOUSEON
64284       PROC Fsel_Input(Path$,Text$,Intout%(1))
64285       Form_Dial(0,X%L,Y%L-H%L,W%L,H%L):Form_Dial(3,X%L,Y%L-H%L,W%L,H%L):Ctrl%(6)=L%L: WPOKE LPEEK( SEGPTR -24),T%L
64286    ELSE
64287       Path$= LEFT$(Path$+ CHR$(0)*64,64):Text$= LEFT$(Text$+ CHR$(0)*13,13)
64288       X%L= VARPTR(Text$):Y%L= VARPTR(Label$)
64289       Addrin%L(0)= LPEEK( VARPTR(Path$))+ LPEEK( SEGPTR +28)
64290       Addrin%L(1)= LPEEK(X%L)+ LPEEK( SEGPTR +28)
64291       Addrin%L(2)= LPEEK(Y%L)+ LPEEK( SEGPTR +28)
64292       AES (91,Global%(15),Intin%(0),Addrin%L(3),Intout%(2),Addrout%L(0))
64293       Text$= LEFT$(Text$, INSTR(Text$+ CHR$(0), CHR$(0))-1)
64294       Path$= LEFT$(Path$, INSTR(Path$+ CHR$(0), CHR$(0))-1)
64295    ENDIF RETURN
64296 '
64297 DEF FN Wind_Check%L(W%L,H%L)
64298    IF W%L<1 THEN H%L=0 ELSE H%L= BIT(W%L, LPEEK(FN Reserved%L(10+H%L)))
64299    RETURN H%L
64300 '
64301 DEF PROC Wind_Create(Intin%(0),Intin%(1),Intin%(2),Intin%(3),Intin%(4),R Intout%(0))
64302    AES (100,Global%(15),Intin%(5),Addrin%L(0),Intout%(1),Addrout%L(0))
64303    IF Intout%(0)>0 THEN LPOKE FN Reserved%L(10), LPEEK(FN Reserved%L(10)) OR 1 SHL Intout%(0)
64304    RETURN
64305 '
64306 DEF PROC Wind_Open(W%L,Intin%(1),Intin%(2),Intin%(3),Intin%(4))
64307    IF W%L>0 THEN
64308       IF FN Wind_Check%L(W%L,4)=0 THEN
64309          LPOKE FN Reserved%L(14), LPEEK(FN Reserved%L(14)) OR 1 SHL W%L:Intin%(0)=W%L
64310          AES (101,Global%(15),Intin%(5),Addrin%L(0),Intout%(1),Addrout%L(0))
64311       ENDIF
64312    ENDIF RETURN
64313 '
64314 DEF PROC Wind_Close(W%L)
64315    IF FN Wind_Check%L(W%L,4) THEN
64316       LPOKE FN Reserved%L(14), LPEEK(FN Reserved%L(14)) XOR 1 SHL W%L:Intin%(0)=W%L
64317       AES (102,Global%(15),Intin%(1),Addrin%L(0),Intout%(1),Addrout%L(0))
64318    ENDIF RETURN
64319 '
64320 DEF PROC Wind_Delete(W%L):Wind_Close(W%L)
64321    IF FN Wind_Check%L(W%L,0) THEN
64322       LPOKE FN Reserved%L(10), LPEEK(FN Reserved%L(10)) XOR 1 SHL W%L:Intin%(0)=W%L
64323       AES (103,Global%(15),Intin%(1),Addrin%L(0),Intout%(1),Addrout%L(0))
64324    ENDIF RETURN
64325 '
64326 DEF PROC Wind_Get(Intin%(0),Intin%(1),R Intout%(1))
64327    IF FN Wind_Check%L(Intin%(0),0)=0 AND Intin%(1)<>10 THEN EXIT
64328    AES (104,Global%(15),Intin%(2),Addrin%L(0),Intout%(5),Addrout%L(0))
64329    RETURN
64330 DEF PROC Wind_Get(Intin%(0),Intin%(1),R Intout%(1),R Intout%(2),R Intout%(3),R Intout%(4))
64331    IF FN Wind_Check%L(Intin%(0),0)=0 AND Intin%(0) THEN EXIT
64332    AES (104,Global%(15),Intin%(2),Addrin%L(0),Intout%(5),Addrout%L(0))
64333    RETURN
64334 '
64335 DEF PROC Wind_Set(Intin%(0))
64336    IF FN Wind_Check%L(Intin%(0),4)=0 THEN EXIT
64337    Intin%(1)=10:Intin%(2)=Intin%(0)
64338    AES (105,Global%(15),Intin%(6),Addrin%L(0),Intout%(1),Addrout%L(0))
64339    RETURN
64340 DEF PROC Wind_Set(X%L,Intin%(4))
64341    Intin%(2)= HIGH(X%L):Intin%(3)= LOW(X%L):Intin%(0)=0:Intin%(1)=14
64342    AES (105,Global%(15),Intin%(6),Addrin%L(0),Intout%(1),Addrout%L(0))
64343    RETURN
64344 DEF PROC Wind_Set(Intin%(0),Intin%(1),Intin%(2))
64345    IF FN Wind_Check%L(Intin%(0),0)=0 THEN EXIT
64346    AES (105,Global%(15),Intin%(6),Addrin%L(0),Intout%(1),Addrout%L(0))
64347    RETURN
64348 DEF PROC Wind_Set(Intin%(0),Intin%(1),Text$,X%L): LOCAL I%L
64349    IF FN Wind_Check%L(Intin%(0),0)=0 THEN EXIT
64350    Intin%(2)= HIGH(X%L):Intin%(3)= LOW(X%L)
64351    FOR I%L=1 TO LEN(Text$): POKE X%L+I%L-1, ASC( MID$(Text$,I%L)): NEXT : POKE X%L+I%L-1,0
64352    AES (105,Global%(15),Intin%(6),Addrin%L(0),Intout%(1),Addrout%L(0))
64353    RETURN
64354 DEF PROC Wind_Set(Intin%(0),Intin%(2),Intin%(3),Intin%(4),Intin%(5))
64355    IF FN Wind_Check%L(Intin%(0),0)=0 THEN EXIT
64356    Intin%(1)=5
64357    AES (105,Global%(15),Intin%(6),Addrin%L(0),Intout%(1),Addrout%L(0))
64358    RETURN
64359 '
64360 DEF PROC Wind_Find(Intin%(0),Intin%(1),R Intout%(0))
64361    AES (106,Global%(15),Intin%(2),Addrin%L(0),Intout%(1),Addrout%L(0))
64362    RETURN
64363 '
64364 DEF PROC Wind_Update(X%L):Intin%(0)=X%L
64365    IF X%L=0 THEN IF FN Wind_Check%L(30,0)=0 THEN EXIT ELSE BIT (6,(FN Reserved%L(10)))=0
64366    IF X%L=1 THEN IF FN Wind_Check%L(30,0) THEN EXIT ELSE BIT (6,(FN Reserved%L(10)))=1
64367    IF X%L=2 THEN IF FN Wind_Check%L(31,0)=0 THEN EXIT ELSE BIT (7,(FN Reserved%L(10)))=0
64368    IF X%L=3 THEN IF FN Wind_Check%L(31,0) THEN EXIT ELSE BIT (7,(FN Reserved%L(10)))=1
64369    AES (107,Global%(15),Intin%(1),Addrin%L(0),Intout%(1),Addrout%L(0))
64370    RETURN
64371 '
64372 DEF PROC Wind_Calc(Intin%(0),Intin%(1),Intin%(2),Intin%(3),Intin%(4),Intin%(5),R Intout%(1),R Intout%(2),R Intout%(3),R Intout%(4))
64373    AES (108,Global%(15),Intin%(6),Addrin%L(0),Intout%(5),Addrout%L(0))
64374    RETURN
64375 '
64376 DEF PROC Wind_New: LOCAL I%L
64377    IF WPEEK( LPEEK($4F2)+2)<$104 THEN
64378       FOR I%L=1 TO 10:Wind_Delete(I%L): NEXT
64379       REPEAT
64380          Wind_Get(0,10,I%L)
64381          IF I%L>0 THEN
64382             LPOKE FN Reserved%L(14), LPEEK(FN Reserved%L(14)) XOR 1 SHL I%L
64383             LPOKE FN Reserved%L(10), LPEEK(FN Reserved%L(10)) XOR 1 SHL I%L
64384             Wind_Delete(I%L)
64385          ENDIF
64386       UNTIL I%L<=0
64387       Form_Dial(3,0,0,1,1)
64388       Wind_Update(0):Wind_Update(2)
64389    ELSE
64390       AES (109,Global%(15),Intin%(0),Addrin%L(0),Intout%(0),Addrout%L(0))
64391       LPOKE FN Reserved%L(10),0: LPOKE FN Reserved%L(14),0
64392    ENDIF RETURN
64393 '
64394 DEF FN Rsrc_Check%L(V%L)
64395    IF LPEEK(FN Reserved%L(6))=V%L THEN
64396       V%L=6 ELSE IF LPEEK(FN Reserved%L(30))=V%L THEN
64397       V%L=30 ELSE IF LPEEK(FN Reserved%L(34))=V%L THEN
64398       V%L=34 ELSE V%L=0 ENDIF ENDIF ENDIF RETURN V%L
64399 DEF PROC Rsrc_Load(Text$,R Intout%(0))
64400    IF FN Rsrc_Check%L(0)=0 THEN Intout%(0)=0: EXIT
64401    Rsrc_Free:Addrin%L(0)= MEMORY(Text$)
64402    AES (110,Global%(15),Intin%(0),Addrin%L(1),Intout%(1),Addrout%L(0))
64403    LPOKE FN Reserved%L(FN Rsrc_Check%L(0)),Global%(5) SHL 16 OR Global%(6) AND $FFFF: FRE Addrin%L(0)
64404    RETURN
64405 '
64406 DEF PROC Rsrc_Free: LOCAL X%L
64407    X%L=FN Rsrc_Check%L(Global%(5) SHL 16 OR Global%(6) AND $FFFF)
64408    IF X%L=0 THEN Intout%(0)=0: EXIT
64409    AES (111,Global%(15),Intin%(0),Addrin%L(0),Intout%(1),Addrout%L(0)): LPOKE FN Reserved%L(X%L),0
64410    RETURN
64411 '
64412 DEF PROC Rsrc_Gaddr(Intin%(0),Intin%(1),R Addrout%L(0))
64413    AES (112,Global%(15),Intin%(2),Addrin%L(0),Intout%(1),Addrout%L(1))
64414    RETURN
64415 '
64416 DEF PROC Rsrc_Saddr(Intin%(0),Intin%(1),Addrin%L(0))
64417    AES (113,Global%(15),Intin%(2),Addrin%L(1),Intout%(1),Addrout%L(0))
64418    RETURN
64419 '
64420 DEF PROC Rsrc_Obfix(Intin%(0),Addrin%L(0))
64421    AES (114,Global%(15),Intin%(1),Addrin%L(1),Intout%(1),Addrout%L(0))
64422    RETURN
64423 '
64424 DEF PROC Shel_Read(R Path$,R Text$): LOCAL X%L
64425    Path$= CHR$(0)*128:X%L= VARPTR(Path$):Text$= CHR$(0)*128
64426    Addrin%L(1)= LPEEK( VARPTR(Text$))+ LPEEK( SEGPTR +28)
64427    Addrin%L(0)= LPEEK(X%L)+ LPEEK( SEGPTR +28)
64428    AES (120,Global%(15),Intin%(0),Addrin%L(2),Intout%(1),Addrout%L(0))
64429    Text$= LEFT$(Text$, INSTR(Text$+ CHR$(0), CHR$(0))-1)
64430    Path$= LEFT$(Path$, INSTR(Path$+ CHR$(0), CHR$(0))-1)
64431    RETURN
64432 '
64433 DEF PROC Shel_Write(Intin%(0),Intin%(1),Intin%(2),Path$,Text$)
64434    Addrin%L(0)= VARPTR(Path$)
64435    Addrin%L(1)= MEMORY(Text$)
64436    AES (121,Global%(15),Intin%(3),Addrin%L(2),Intout%(1),Addrout%L(0)): FRE Addrin%L(0): FRE Addrin%L(1)
64437    RETURN
64438 '
64439 DEF PROC Shel_Get(R Text$)
64440    Intin%(0)= LEN(Text$):Addrin%L(0)= LPEEK( VARPTR(Text$))+ LPEEK( SEGPTR +28)
64441    AES (122,Global%(15),Intin%(1),Addrin%L(1),Intout%(1),Addrout%L(0))
64442    Text$= LEFT$(Text$, INSTR(Text$+ CHR$(0), CHR$(0))-1)
64443    RETURN
64444 '
64445 DEF PROC Shel_Put(Text$)
64446    Intin%(0)= LEN(Text$):Addrin%L(0)= LPEEK( VARPTR(Text$))+ LPEEK( SEGPTR +28)
64447    AES (123,Global%(15),Intin%(1),Addrin%L(1),Intout%(1),Addrout%L(0))
64448    RETURN
64449 '
64450 DEF PROC Shel_Find(R Text$,R Intout%(0))
64451    Text$= LEFT$(Text$+ CHR$(0)*128,128)
64452    Addrin%L(0)= LPEEK( VARPTR(Text$))+ LPEEK( SEGPTR +28)
64453    AES (124,Global%(15),Intin%(0),Addrin%L(1),Intout%(1),Addrout%L(0))
64454    RETURN
64455 '
64456 DEF PROC Shel_Envrn(Text$,R Path$): LOCAL X%L= MEMORY(Text$),Y%L,W%L,H%L
64457    IF WPEEK( LPEEK($4F2)+2)<$104 THEN
64458       ' TOS vor 1.04
64459       IF LPEEK( SEGPTR +20)=0 THEN Y%L=64 ELSE Y%L=-12
64460       W%L= LPEEK( LPEEK( SEGPTR +Y%L)+$2C)
64461       WHILE PEEK(W%L)
64462          H%L=-1:Y%L=X%L
64463          REPEAT
64464             H%L=H%L AND ( PEEK(Y%L)= PEEK(W%L))
64465             W%L=W%L+1:Y%L=Y%L+1
64466          UNTIL PEEK(W%L-1)= ASC("=") OR PEEK(W%L-1)=0
64467          IF PEEK(W%L-1)= ASC("=") AND H%L THEN H%L=W%L: EXIT
64468          WHILE PEEK(W%L-1):W%L=W%L+1: WEND
64469          H%L=0
64470       WEND
64471       FRE X%L
64472    ELSE
64473       Y%L= MEMORY(4):Addrin%L(1)=X%L:Addrin%L(1)=Y%L
64474       AES (125,Global%(15),Intin%(0),Addrin%L(2),Intout%(1),Addrout%L(0))
64475       FRE X%L:H%L= LPEEK(Y%L): FRE Y%L:Path$=""
64476    ENDIF
64477    Path$=""
64478    IF H%L THEN
64479       Y%L=H%L
64480       IF PEEK(H%L)=0 THEN H%L=H%L+1
64481       WHILE PEEK(H%L):Path$=Path$+ CHR$( PEEK(H%L)):H%L=H%L+1: WEND
64482       IF PEEK(Y%L)=0 AND RIGHT$(Path$,1)="=" THEN Path$=""
64483    ENDIF RETURN
64484 '
64485 'VDI
64486 '
64487 DEF PROC V_Pline(X%L)
64488    VDI (6,Ctrl%(12),Intin%(0),Ptsin%(0,X%L),Intout%(0),Ptsout%(0,0))
64489    RETURN
64490 '
64491 DEF PROC V_Pmarker(X%L)
64492    VDI (7,Ctrl%(12),Intin%(0),Ptsin%(0,X%L),Intout%(0),Ptsout%(0,0))
64493    RETURN
64494 '
64495 DEF PROC V_Gtext(Ptsin%(0,0),Ptsin%(1,0),Text$): LOCAL I%L
64496    FOR I%L=0 TO LEN(Text$)-1:Intin%(I%L)= ASC( MID$(Text$,I%L+1,1)): NEXT
64497    VDI (8,Ctrl%(12),Intin%(I%L),Ptsin%(0,1),Intout%(0),Ptsout%(0,0))
64498    RETURN
64499 '
64500 DEF PROC V_Fillarea(X%L)
64501    VDI (9,Ctrl%(12),Intin%(0),Ptsin%(0,X%L),Intout%(0),Ptsout%(0,0))
64502    RETURN
64503 '
64504 DEF PROC V_Cellarray(Ctrl%(7),Ctrl%(8),Ctrl%(9),Ctrl%(10),X%L,Ptsin%(0,0),Ptsin%(1,0),Ptsin%(0,1),Ptsin%(1,1))
64505    VDI (10,Ctrl%(12),Intin%(X%L),Ptsin%(0,2),Intout%(0),Ptsout%(0,0))
64506    RETURN
64507 '
64508 DEF PROC V_Bar(Ptsin%(0,0),Ptsin%(1,0),Ptsin%(0,1),Ptsin%(1,1))
64509    Ctrl%(5)=1
64510    VDI (11,Ctrl%(12),Intin%(0),Ptsin%(0,2),Intout%(0),Ptsout%(0,0))
64511    RETURN
64512 '
64513 DEF PROC V_Arc(Intin%(0),Intin%(1),Ptsin%(0,0),Ptsin%(1,0),Ptsin%(0,3))
64514    Ctrl%(5)=2:Ptsin%(0,1)=0:Ptsin%(1,1)=0:Ptsin%(0,2)=0
64515    Ptsin%(1,2)=0:Ptsin%(1,3)=0
64516    VDI ($800000B,Ctrl%(12),Intin%(2),Ptsin%(0,4),Intout%(0),Ptsout%(0,0))
64517    RETURN
64518 '
64519 DEF PROC V_Pieslice(Intin%(0),Intin%(1),Ptsin%(0,0),Ptsin%(1,0),Ptsin%(0,3))
64520    Ctrl%(5)=3:Ptsin%(0,1)=0:Ptsin%(1,1)=0:Ptsin%(0,2)=0
64521    Ptsin%(1,2)=0:Ptsin%(1,3)=0
64522    VDI ($800000B,Ctrl%(12),Intin%(2),Ptsin%(0,4),Intout%(0),Ptsout%(0,0))
64523    RETURN
64524 '
64525 DEF PROC V_Circle(Ptsin%(0,0),Ptsin%(1,0),Ptsin%(0,2))
64526    Ctrl%(5)=4:Ptsin%(0,1)=0:Ptsin%(1,1)=0:Ptsin%(1,2)=0
64527    VDI ($400000B,Ctrl%(12),Intin%(0),Ptsin%(0,3),Intout%(0),Ptsout%(0,0))
64528    RETURN
64529 '
64530 DEF PROC V_Ellipse(Ptsin%(0,0),Ptsin%(1,0),Ptsin%(0,1),Ptsin%(1,1))
64531    Ctrl%(5)=5
64532    VDI ($200000B,Ctrl%(12),Intin%(0),Ptsin%(0,2),Intout%(0),Ptsout%(0,0))
64533    RETURN
64534 '
64535 DEF PROC V_Ellarc(Ptsin%(0,0),Ptsin%(1,0),Ptsin%(0,1),Ptsin%(1,1),Intin%(0),Intin%(1))
64536    Ctrl%(5)=6
64537    VDI ($200000B,Ctrl%(12),Intin%(2),Ptsin%(0,2),Intout%(0),Ptsout%(0,0))
64538    RETURN
64539 '
64540 DEF PROC V_Ellpie(Ptsin%(0,0),Ptsin%(1,0),Ptsin%(0,1),Ptsin%(1,1),Intin%(0),Intin%(1))
64541    Ctrl%(5)=7
64542    VDI ($200000B,Ctrl%(12),Intin%(2),Ptsin%(0,2),Intout%(0),Ptsout%(0,0))
64543    RETURN
64544 '
64545 DEF PROC V_Rbox(Ptsin%(0,0),Ptsin%(1,0),Ptsin%(0,1),Ptsin%(1,1))
64546    Ctrl%(5)=8
64547    VDI (11,Ctrl%(12),Intin%(0),Ptsin%(0,2),Intout%(0),Ptsout%(0,0))
64548    RETURN
64549 '
64550 DEF PROC V_Rfbox(Ptsin%(0,0),Ptsin%(1,0),Ptsin%(0,1),Ptsin%(1,1))
64551    Ctrl%(5)=9
64552    VDI (11,Ctrl%(12),Intin%(0),Ptsin%(0,2),Intout%(0),Ptsout%(0,0))
64553    RETURN
64554 '
64555 DEF PROC V_Justified(Ptsin%(0,0),Ptsin%(1,0),Text$,Intin%(0),Intin%(1),Ptsin%(0,1))
64556    LOCAL I%L:Ctrl%(5)=10
64557    FOR I%L=1 TO LEN(Text$):Intin%(I%L+1)= ASC( MID$(Text$,I%L)): NEXT :Intin%(I%L+1)=0
64558    VDI ($200000B,Ctrl%(12),Intin%(I%L+2),Ptsin%(0,2),Intout%(0),Ptsout%(0,0))
64559    RETURN
64560 '
64561 DEF PROC Vst_Height(Ptsin%(1,0))
64562    VDI ($103000C,Ctrl%(12),Intin%(0),Ptsin%(0,1),Intout%(0),Ptsout%(0,2))
64563    RETURN
64564 DEF PROC Vst_Height(Ptsin%(1,0),R Ptsout%(0,0),R Ptsout%(1,0),R Ptsout%(0,1),R Ptsout%(1,1))
64565    VDI ($103000C,Ctrl%(12),Intin%(0),Ptsin%(0,1),Intout%(0),Ptsout%(0,2))
64566    RETURN
64567 '
64568 DEF PROC Vst_Rotation(Intin%(0))
64569    VDI (13,Ctrl%(12),Intin%(1),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
64570    RETURN
64571 '
64572 DEF PROC Vs_Color(Intin%(0),Intin%(1),Intin%(2),Intin%(3))
64573    VDI (14,Ctrl%(12),Intin%(4),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
64574    RETURN
64575 '
64576 DEF PROC Vst_Font(Intin%(0))
64577    VDI (21,Ctrl%(12),Intin%(1),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
64578    RETURN
64579 '
64580 DEF PROC Vsl_Type(Intin%(0))
64581    VDI (15,Ctrl%(12),Intin%(1),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
64582    RETURN
64583 '
64584 DEF PROC Vsl_Width(Ptsin%(0,0))
64585    VDI ($1010010,Ctrl%(12),Intin%(0),Ptsin%(0,1),Intout%(0),Ptsout%(0,0))
64586    RETURN
64587 '
64588 DEF PROC Vsl_Color(Intin%(0))
64589    VDI (17,Ctrl%(12),Intin%(1),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
64590    RETURN
64591 '
64592 DEF PROC Vsm_Type(Intin%(0))
64593    VDI (18,Ctrl%(12),Intin%(1),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
64594    RETURN
64595 '
64596 DEF PROC Vsm_Height(Ptsin%(1,0))
64597    Ptsin%(0,0)=0
64598    VDI ($1010013,Ctrl%(12),Intin%(0),Ptsin%(0,1),Intout%(0),Ptsout%(0,1))
64599    RETURN
64600 '
64601 DEF PROC Vsm_Color(Intin%(0))
64602    VDI (20,Ctrl%(12),Intin%(1),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
64603    RETURN
64604 '
64605 DEF PROC Vst_Color(Intin%(0))
64606    VDI (22,Ctrl%(12),Intin%(1),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
64607    RETURN
64608 '
64609 DEF PROC Vsf_Interior(Intin%(0))
64610    VDI (23,Ctrl%(12),Intin%(1),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
64611    RETURN
64612 '
64613 DEF PROC Vsf_Style(Intin%(0))
64614    VDI (24,Ctrl%(12),Intin%(1),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
64615    RETURN
64616 '
64617 DEF PROC Vsf_Color(Intin%(0))
64618    VDI (25,Ctrl%(12),Intin%(1),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
64619    RETURN
64620 '
64621 DEF PROC Vq_Color(Intin%(0),Intin%(1),R Intout%(0),R Intout%(1),R Intout%(2),R Intout%(3))
64622    VDI (26,Ctrl%(12),Intin%(2),Ptsin%(0,0),Intout%(4),Ptsout%(0,0))
64623    RETURN
64624 '
64625 DEF PROC Vrq_Locator(Ptsin%(0,0),Ptsin%(1,0),R Intout%(0),R Ptsout%(0,0),R Ptsout%(1,0))
64626    Vsin_Mode(1,1)
64627    VDI (28,Ctrl%(12),Intin%(0),Ptsin%(0,1),Intout%(1),Ptsout%(0,1))
64628    RETURN
64629 '
64630 DEF PROC Vsm_Locator(Ptsin%(0,0),Ptsin%(1,0),R X%L,R Intout%(0),R Ptsout%(0,0),R Ptsout%(1,0))
64631    Vsin_Mode(1,2)
64632    VDI (28,Ctrl%(12),Intin%(0),Ptsin%(0,1),Intout%(1),Ptsout%(0,1))
64633    X%L=Ctrl%(4)*2+Ctrl%(2)
64634    RETURN
64635 '
64636 DEF PROC Vrq_Valuator(Intin%(0),R Intout%(0),R Intout%(1))
64637    Vsin_Mode(2,1)
64638    VDI (29,Ctrl%(12),Intin%(1),Ptsin%(0,0),Intout%(2),Ptsout%(0,0))
64639    RETURN
64640 '
64641 DEF PROC Vsm_Valuator(Intin%(0),R X%L,R Intout%(0),R Intout%(1))
64642    Vsin_Mode(2,2)
64643    VDI (29,Ctrl%(12),Intin%(1),Ptsin%(0,0),Intout%(2),Ptsout%(0,0))
64644    X%L=Ctrl%(4)
64645    RETURN
64646 '
64647 DEF PROC Vrq_Choice(Intin%(0),R Intout%(0))
64648    Vsin_Mode(3,1)
64649    VDI (30,Ctrl%(12),Intin%(1),Ptsin%(0,0),Intout%(1),Ptsout%(0,0))
64650    RETURN
64651 '
64652 DEF PROC Vsm_Choice(R X%L,R Intout%(0))
64653    Vsin_Mode(3,2)
64654    VDI (30,Ctrl%(12),Intin%(1),Ptsin%(0,0),Intout%(1),Ptsout%(0,0))
64655    X%L=Ctrl%(4)
64656    RETURN
64657 '
64658 DEF PROC Vrq_String(Intin%(0),Intin%(1),Ptsin%(0,0),Ptsin%(1,0),R Text$): LOCAL X%L,I%L
64659    Vsin_Mode(4,1):X%L=Intin%(0)
64660    VDI (31,Ctrl%(12),Intin%(2),Ptsin%(0,1),Intout%(128),Ptsout%(0,0))
64661    Text$=""
64662    IF X%L<0 THEN
64663       FOR I%L=1 TO Ctrl%(4):Text$=Text$+ MKI$(Intout%(I%L-1)): NEXT
64664    ELSE
64665       FOR I%L=1 TO Ctrl%(4):Text$=Text$+ CHR$(Intout%(I%L-1)): NEXT
64666    ENDIF RETURN
64667 '
64668 DEF PROC Vsm_String(Intin%(0),Intin%(1),Ptsin%(0,0),Ptsin%(1,0),R Text$): LOCAL X%L,I%L
64669    Vsin_Mode(4,2):X%L=Intin%(0)
64670    VDI (31,Ctrl%(12),Intin%(2),Ptsin%(0,1),Intout%(128),Ptsout%(0,0))
64671    Text$=""
64672    IF X%L<0 THEN
64673       FOR I%L=1 TO Ctrl%(4):Text$=Text$+ MKI$(Intout%(I%L-1)): NEXT
64674    ELSE
64675       FOR I%L=1 TO Ctrl%(4):Text$=Text$+ CHR$(Intout%(I%L-1)): NEXT
64676    ENDIF RETURN
64677 '
64678 DEF PROC Vswr_Mode(Intin%(0))
64679    VDI (32,Ctrl%(12),Intin%(1),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
64680    RETURN
64681 '
64682 DEF PROC Vsin_Mode(Intin%(0),Intin%(1))
64683    VDI (33,Ctrl%(12),Intin%(2),Ptsin%(0,0),Intout%(1),Ptsout%(0,0))
64684    RETURN
64685 '
64686 DEF PROC Vql_Attributes(R Intout%(0),R Intout%(1),R Intout%(2),R Intout%(3),R Intout%(4),R Ptsout%(0,0),R Ptsout%(1,0))
64687    VDI ($10023,Ctrl%(12),Intin%(0),Ptsin%(0,0),Intout%(5),Ptsout%(0,1))
64688    RETURN
64689 '
64690 DEF PROC Vqm_Attributes(R Intout%(0),R Intout%(1),R Intout%(2),R Ptsout%(0,0),R Ptsout%(1,0))
64691    VDI ($10024,Ctrl%(12),Intin%(0),Ptsin%(0,0),Intout%(3),Ptsout%(0,1))
64692    RETURN
64693 '
64694 DEF PROC Vqf_Attributes(R Intout%(0),R Intout%(1),R Intout%(2),R Intout%(3),R Intout%(4))
64695    VDI (37,Ctrl%(12),Intin%(0),Ptsin%(0,0),Intout%(5),Ptsout%(0,0))
64696    RETURN
64697 '
64698 DEF PROC Vqt_Attributes(R Intout%(0),R Intout%(1),R Intout%(2),R Intout%(3),R Intout%(4),R Intout%(5),R Ptsout%(0,0),R Ptsout%(1,0),R Ptsout%(0,1),R Ptsout%(1,1))
64699    VDI ($30026,Ctrl%(12),Intin%(0),Ptsin%(0,0),Intout%(6),Ptsout%(0,2))
64700    RETURN
64701 '
64702 DEF PROC Vst_Alignment(Intin%(0),Intin%(1))
64703    VDI (39,Ctrl%(12),Intin%(2),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
64704    RETURN
64705 '
64706 DEF PROC V_Opnwk(X%L)
64707    V_Opnwk(X%L,1,1,1,1,1,1,1,1,1,2)
64708    RETURN
64709 DEF FN V_Opn_Check%L(V%L)
64710    IF WPEEK(FN Reserved%L(18))=V%L THEN
64711       V%L=18 ELSE IF WPEEK(FN Reserved%L(20))=V%L THEN
64712       V%L=20 ELSE IF WPEEK(FN Reserved%L(22))=V%L THEN
64713       V%L=22 ELSE V%L=0 ENDIF ENDIF ENDIF RETURN V%L
64714 DEF PROC V_Opnwk(Intin%(0),Intin%(1),Intin%(2),Intin%(3),Intin%(4),Intin%(5),Intin%(6),Intin%(7),Intin%(8),Intin%(9),Intin%(10))
64715    IF FN V_Opn_Check%L(0)=0 THEN Intout%(6)=0: EXIT
64716    VDI ($3F0001,Ctrl%(12),Intin%(11),Ptsin%(0,0),Intout%(45),Ptsout%(0,6))
64717    WPOKE FN Reserved%L(FN V_Opn_Check%L(0)),Ctrl%(6)
64718    RETURN
64719 '
64720 DEF PROC V_Clswk
64721    IF FN V_Opn_Check%L(Ctrl%(6))=0 THEN EXIT
64722    VDI (2,Ctrl%(12),Intin%(0),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
64723    WPOKE FN Reserved%L(FN V_Opn_Check%L(Ctrl%(6))),0
64724    RETURN
64725 '
64726 DEF PROC V_Opnvwk
64727    V_Opnvwk(1,1,1,1,1,1,1,1,1,1,2)
64728    RETURN
64729 DEF FN V_Opnv_Check%L(V%L)
64730    IF WPEEK(FN Reserved%L(24))=V%L THEN
64731       V%L=24 ELSE IF WPEEK(FN Reserved%L(26))=V%L THEN
64732       V%L=26 ELSE IF WPEEK(FN Reserved%L(28))=V%L THEN
64733       V%L=28 ELSE V%L=0 ENDIF ENDIF ENDIF RETURN V%L
64734 DEF PROC V_Opnvwk(Intin%(0),Intin%(1),Intin%(2),Intin%(3),Intin%(4),Intin%(5),Intin%(6),Intin%(7),Intin%(8),Intin%(9),Intin%(10))
64735    IF FN V_Opnv_Check%L(0)=0 THEN Intout%(6)=0: EXIT
64736    VDI ($3F0064,Ctrl%(12),Intin%(11),Ptsin%(0,0),Intout%(45),Ptsout%(0,6))
64737    WPOKE FN Reserved%L(FN V_Opnv_Check%L(0)),Ctrl%(6)
64738    RETURN
64739 '
64740 DEF PROC V_Clsvwk
64741    IF FN V_Opnv_Check%L(Ctrl%(6))=0 THEN EXIT
64742    VDI (101,Ctrl%(12),Intin%(0),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
64743    WPOKE FN Reserved%L(FN V_Opnv_Check%L(Ctrl%(6))),0
64744    RETURN
64745 '
64746 DEF PROC Vq_Extnd(Intin%(0))
64747    VDI ($3F0066,Ctrl%(12),Intin%(0),Ptsin%(0,0),Intout%(45),Ptsout%(0,6))
64748    RETURN
64749 '
64750 DEF PROC V_Contourfill(Ptsin%(0,0),Ptsin%(1,0),Intin%(0))
64751    VDI (103,Ctrl%(12),Intin%(1),Ptsin%(0,1),Intout%(0),Ptsout%(0,0))
64752    RETURN
64753 '
64754 DEF PROC Vsf_Perimeter(Intin%(0))
64755    VDI (104,Ctrl%(12),Intin%(1),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
64756    RETURN
64757 '
64758 DEF PROC V_Get_Pixel(Ptsin%(0,0),Ptsin%(1,0),R Intout%(0),R Intout%(1))
64759    VDI (105,Ctrl%(12),Intin%(0),Ptsin%(0,1),Intout%(2),Ptsout%(0,0))
64760    RETURN
64761 '
64762 DEF PROC Vst_Effects(Intin%(0))
64763    VDI (106,Ctrl%(12),Intin%(1),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
64764    RETURN
64765 '
64766 DEF PROC Vst_Point(Intin%(0))
64767    VDI ($3006B,Ctrl%(12),Intin%(1),Ptsin%(0,0),Intout%(0),Ptsout%(0,2))
64768    RETURN
64769 DEF PROC Vst_Point(Intin%(0),Ptsout%(0,0),Ptsout%(1,0),Ptsout%(0,1),Ptsout%(1,1))
64770    VDI ($3006B,Ctrl%(12),Intin%(1),Ptsin%(0,0),Intout%(0),Ptsout%(0,2))
64771    RETURN
64772 '
64773 DEF PROC Vsl_Ends(Intin%(0),Intin%(1))
64774    VDI (108,Ctrl%(12),Intin%(2),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
64775    RETURN
64776 '
64777 DEF PROC Vro_Cpyfm(X%L,Y%L,Intin%(0),Ptsin%(0,0),Ptsin%(1,0),Ptsin%(0,1),Ptsin%(1,1),Ptsin%(0,2),Ptsin%(1,2),Ptsin%(0,3),Ptsin%(1,3))
64778    Ctrl%(7)= HIGH(X%L):Ctrl%(8)= LOW(X%L):Ctrl%(9)= HIGH(Y%L):Ctrl%(10)= LOW(Y%L)
64779    VDI (109,Ctrl%(12),Intin%(1),Ptsin%(0,4),Intout%(0),Ptsout%(0,0))
64780    RETURN
64781 '
64782 DEF PROC Vr_Trnfm(X%L,Y%L)
64783    Ctrl%(7)= HIGH(X%L):Ctrl%(8)= LOW(X%L):Ctrl%(9)= HIGH(Y%L):Ctrl%(10)= LOW(Y%L)
64784    VDI (110,Ctrl%(12),Intin%(0),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
64785    RETURN
64786 '
64787 DEF PROC Vsc_Form(Intin%(0),Intin%(1),Intin%(2),Intin%(3),Intin%(4),Text$)
64788    LOCAL I%L: FOR I%L=0 TO 31:Intin%(I%L+5)= CVI( MID$(Text$,I%L*2+1)): NEXT
64789    VDI (111,Ctrl%(12),Intin%(37),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
64790    RETURN
64791 '
64792 DEF PROC Vsf_Udpat(X%L)
64793    VDI (112,Ctrl%(12),Intin%(X%L*16),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
64794    RETURN
64795 '
64796 DEF PROC Vex_Timv(R X%L,R Intout%(0))
64797    Ctrl%(7)= HIGH(X%L):Ctrl%(8)= LOW(X%L)
64798    VDI (118,Ctrl%(12),Intin%(0),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
64799    X%L=Ctrl%(9) SHL 16 OR Ctrl%(10) AND $FFFF
64800    RETURN
64801 '
64802 DEF PROC Vsl_Udsty(Intin%(0))
64803    VDI (113,Ctrl%(12),Intin%(1),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
64804    RETURN
64805 '
64806 DEF PROC V_Recfl(Ptsin%(0,0),Ptsin%(1,0),Ptsin%(0,1),Ptsin%(1,1))
64807    VDI (114,Ctrl%(12),Intin%(0),Ptsin%(0,2),Intout%(0),Ptsout%(0,0))
64808    RETURN
64809 '
64810 DEF PROC Vqin_Mode(Intin%(0),R Intout%(0))
64811    VDI (115,Ctrl%(12),Intin%(1),Ptsin%(0,0),Intout%(1),Ptsout%(0,0))
64812    RETURN
64813 '
64814 DEF PROC Vqt_Name(Intin%(0),R Intout%(0),R Text$)
64815    LOCAL I%L
64816    VDI (130,Ctrl%(12),Intin%(1),Ptsin%(0,0),Intout%(32),Ptsout%(0,0))
64817    Text$=""
64818    FOR I%L=1 TO 32:Text$=Text$+ CHR$(Intout%(I%L)): NEXT
64819    RETURN
64820 '
64821 DEF PROC Vqt_Fontinfo(R Intout%(0),R Intout%(1))
64822    VDI ($1F0083,Ctrl%(12),Intin%(0),Ptsin%(0,0),Intout%(2),Ptsout%(0,5))
64823    RETURN
64824 '
64825 DEF PROC Vq_Chcells(R Intout%(0),R Intout%(1))
64826    Ctrl%(5)=1
64827    VDI (5,Ctrl%(12),Intin%(0),Ptsin%(0,0),Intout%(2),Ptsout%(0,0))
64828    RETURN
64829 '
64830 DEF PROC V_Exit_Cur
64831    PRINT CHR$(27);"f"; CHR$(27);"E";: RETURN
64832 '
64833 DEF PROC V_Enter_Cur
64834    PRINT CHR$(27);"E"; CHR$(27);"e";: RETURN
64835 '
64836 DEF PROC V_Curup
64837    PRINT CHR$(27);"A";: RETURN
64838 '
64839 DEF PROC V_Curdown
64840    PRINT CHR$(27);"B";: RETURN
64841 '
64842 DEF PROC V_Curright
64843    PRINT CHR$(27);"C";: RETURN
64844 '
64845 DEF PROC V_Curleft
64846    PRINT CHR$(27);"D";: RETURN
64847 '
64848 DEF PROC V_Curhome
64849    PRINT CHR$(27);"H";: RETURN
64850 '
64851 DEF PROC V_Eeos
64852    PRINT CHR$(27);"J";: RETURN
64853 '
64854 DEF PROC V_Eeol
64855    PRINT CHR$(27);"K";: RETURN
64856 '
64857 DEF PROC V_Curaddress(Y%L,X%L)
64858    PRINT @(Y%L-1,X%L-1);: RETURN
64859 '
64860 DEF PROC V_Curtext(Text$)
64861    PRINT Text$;: RETURN
64862 '
64863 DEF PROC V_Rvon
64864    PRINT CHR$(27);"p";: RETURN
64865 '
64866 DEF PROC V_Rvoff
64867    PRINT CHR$(27);"q";: RETURN
64868 '
64869 DEF PROC Vq_Curaddress(R Y%L,R X%L)
64870    Y%L= CSRLIN :X%L= POS(0)+1: RETURN
64871 '
64872 DEF PROC Vq_Tabstatus(R Intout%(0))
64873    Ctrl%(5)=16
64874    VDI (5,Ctrl%(12),Intin%(0),Ptsin%(0,0),Intout%(1),Ptsout%(0,0))
64875    RETURN
64876 '
64877 DEF PROC V_Hardcopy
64878    HCOPY : RETURN
64879 '
64880 DEF PROC V_Dspcur(Ptsin%(0,0),Ptsin%(1,0))
64881    Ctrl%(5)=18
64882    VDI (5,Ctrl%(12),Intin%(0),Ptsin%(0,1),Intout%(0),Ptsout%(0,0))
64883    RETURN
64884 '
64885 DEF PROC V_Rmcur
64886    Ctrl%(5)=19
64887    VDI (5,Ctrl%(12),Intin%(0),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
64888    RETURN
64889 '
64890 DEF PROC V_Form_Adv
64891    Ctrl%(5)=20
64892    VDI (5,Ctrl%(12),Intin%(0),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
64893    RETURN
64894 '
64895 DEF PROC V_Output_Window(Ptsin%(0,0),Ptsin%(1,0),Ptsin%(0,1),Ptsin%(1,1))
64896    Ctrl%(5)=21
64897    VDI (5,Ctrl%(12),Intin%(0),Ptsin%(0,2),Intout%(0),Ptsout%(0,0))
64898    RETURN
64899 '
64900 DEF PROC V_Clear_Disp_List
64901    Ctrl%(5)=22
64902    VDI (5,Ctrl%(12),Intin%(0),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
64903    RETURN
64904 '
64905 DEF PROC V_Bit_Image(Text$,Intin%(0),Intin%(1),X%L,Ptsin%(0,0),Ptsin%(1,0),Ptsin%(0,1),Ptsin%(1,1))
64906    LOCAL I%L:Intin%(2)=0
64907    Ctrl%(5)=23
64908    IF LEN(Text$) THEN
64909       FOR I%L=1 TO LEN(Text$):Intin%(I%L+1)= ASC( MID$(Text$,I%L,1)): NEXT :Intin%(I%L+1)=0
64910    ENDIF
64911    VDI (5,Ctrl%(12),Intin%( LEN(Text$)+2),Ptsin%(0,X%L),Intout%(0),Ptsout%(0,0))
64912    RETURN
64913 '
64914 DEF PROC Vq_Scan(R Intout%(0),R Intout%(1),R Intout%(2),R Intout%(3),R Intout%(4))
64915    Ctrl%(5)=24
64916    VDI (5,Ctrl%(12),Intin%(0),Ptsin%(0,0),Intout%(5),Ptsout%(0,0))
64917    RETURN
64918 '
64919 DEF PROC V_Alpha_Text(Text$): LOCAL I%L,L%L= LEN(Text$)
64920    Ctrl%(5)=25: FOR I%L=1 TO L%L:Intin%(I%L-1)= ASC( MID$(Text$,I%L,1)): NEXT :Intin%(L%L)=0
64921    VDI (5,Ctrl%(12),Intin%(L%L+1),Ptsin%(0,0),Intout%(1),Ptsout%(0,0))
64922    RETURN
64923 '
64924 DEF PROC Vs_Palette(Intin%(0))
64925    Ctrl%(5)=60
64926    VDI (5,Ctrl%(12),Intin%(1),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
64927    RETURN
64928 '
64929 DEF PROC Vqp_Films(R Text$)
64930    Ctrl%(5)=91:Text$=""
64931    VDI (5,Ctrl%(12),Intin%(0),Ptsin%(0,0),Intout%(125),Ptsout%(0,0))
64932    FOR I%L=0 TO 124:Text$=Text$+ CHR$(Intout%(I%L)): NEXT
64933    RETURN
64934 '
64935 DEF PROC Vqp_State
64936    Ctrl%(5)=92
64937    VDI (5,Ctrl%(12),Intin%(0),Ptsin%(0,0),Intout%(21),Ptsout%(0,0))
64938    RETURN
64939 '
64940 DEF PROC Vsp_State
64941    Ctrl%(5)=93
64942    VDI (5,Ctrl%(12),Intin%(21),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
64943    RETURN
64944 '
64945 DEF PROC Vsp_Save
64946    Ctrl%(5)=94
64947    VDI (5,Ctrl%(12),Intin%(0),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
64948    RETURN
64949 '
64950 DEF PROC Vsp_Message
64951    Ctrl%(5)=95
64952    VDI (5,Ctrl%(12),Intin%(0),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
64953    RETURN
64954 '
64955 DEF PROC Vqp_Error(R Intout%(0))
64956    Ctrl%(5)=96
64957    VDI (5,Ctrl%(12),Intin%(0),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
64958    RETURN
64959 '
64960 DEF PROC V_Meta_Extents(Ptsin%(0,0),Ptsin%(1,0),Ptsin%(0,1),Ptsin%(1,1))
64961    Ctrl%(5)=98
64962    VDI (5,Ctrl%(12),Intin%(0),Ptsin%(0,2),Intout%(0),Ptsout%(0,0))
64963    RETURN
64964 '
64965 DEF PROC V_Write_Meta(X%L,Intin%(0),Y%L)
64966    Ctrl%(5)=99
64967    VDI (5,Ctrl%(12),Intin%(X%L+1),Ptsin%(0,Y%L),Intout%(0),Ptsout%(0,0))
64968    RETURN
64969 '
64970 DEF PROC Vm_Filename(Text$)
64971    LOCAL I%L:Intin%(0)=0
64972    IF LEN(Text$) THEN
64973       FOR I%L=1 TO LEN(Text$):Intin%(I%L-1)= ASC( MID$(Text$,I%L,1)): NEXT :Intin%(I%L+1)=0
64974    ENDIF
64975    Ctrl%(5)=100
64976    VDI (5,Ctrl%(12),Intin%( LEN(Text$)),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
64977    RETURN
64978 '
64979 DEF PROC Vs_Scanline(Intin%(0))
64980    Ctrl%(5)=101
64981    VDI (5,Ctrl%(12),Intin%(1),Ptsin%(0,0),Intout%(1),Ptsout%(0,0))
64982    RETURN
64983 '
64984 DEF PROC Vs_Sysfont(X%L)
64985    Ctrl%(5)=102:Intin%(0)= HIGH(X%L):Intin%(1)= LOW(X%L)
64986    VDI (5,Ctrl%(12),Intin%(2),Ptsin%(0,0),Intout%(1),Ptsout%(0,0))
64987    RETURN
64988 '
64989 DEF PROC Vqt_Extent(Text$,R Ptsout%(0,0),R Ptsout%(1,0),R Ptsout%(0,1),R Ptsout%(1,1),R Ptsout%(0,2),R Ptsout%(1,2),R Ptsout%(0,3),R Ptsout%(1,3))
64990    LOCAL I%L
64991    FOR I%L=1 TO LEN(Text$):Intin%(I%L-1)= ASC( MID$(Text$,I%L)): NEXT
64992    VDI ($F0074,Ctrl%(12),Intin%(I%L-1),Ptsin%(0,0),Intout%(4),Ptsout%(0,4))
64993    RETURN
64994 '
64995 DEF PROC Vqt_Width(Intin%(0),R Intout%(0),R Ptsout%(0,0),R Ptsout%(0,1),R Ptsout%(0,2))
64996    VDI ($70075,Ctrl%(12),Intin%(1),Ptsin%(0,0),Intout%(1),Ptsout%(0,3))
64997    RETURN
64998 '
64999 DEF PROC Vq_Cellarray(Ptsin%(0,0),Ptsin%(1,0),Ptsin%(0,1),Ptsin%(1,1),Ctrl%(7),Ctrl%(8),R X%L,R Y%L,R I%L)
65000    X%L=Ctrl%(7)*Ctrl%(8)
65001    VDI (27,Ctrl%(11),Intin%(0),Ptsin%(0,2),Intout%(X%L),Ptsout%(0,0))
65002    X%L=Ctrl%(9):Y%L=Ctrl%(10):I%L=Ctrl%(11)
65003    RETURN
65004 '
65005 DEF PROC Vrt_Cpyfm(X%L,Y%L,Intin%(0),Intin%(1),Intin%(2),Ptsin%(0,0),Ptsin%(1,0),Ptsin%(0,1),Ptsin%(1,1),Ptsin%(0,2),Ptsin%(1,2),Ptsin%(0,3),Ptsin%(1,3))
65006    Ctrl%(7)= HIGH(X%L):Ctrl%(8)= LOW(X%L):Ctrl%(9)= HIGH(Y%L):Ctrl%(10)= LOW(Y%L)
65007    VDI (121,Ctrl%(12),Intin%(3),Ptsin%(0,4),Intout%(0),Ptsout%(0,0))
65008    RETURN
65009 '
65010 DEF PROC V_Show_C:V_Show_C(0): RETURN
65011 DEF PROC V_Show_C(Intin%(0))
65012    VDI (122,Ctrl%(12),Intin%(1),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
65013    RETURN
65014 '
65015 DEF PROC V_Hide_C
65016    VDI (123,Ctrl%(12),Intin%(0),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
65017    RETURN
65018 '
65019 DEF PROC Vq_Mouse(R Intout%(0),R Ptsout%(0,0),R Ptsout%(1,0))
65020    VDI (124,Ctrl%(12),Intin%(0),Ptsin%(0,0),Intout%(1),Ptsout%(0,1))
65021    RETURN
65022 '
65023 DEF PROC Vex_Butv(R X%L)
65024    Ctrl%(7)= HIGH(X%L):Ctrl%(8)= LOW(X%L)
65025    VDI (125,Ctrl%(12),Intin%(0),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
65026    X%L=Ctrl%(9) SHL 16 OR Ctrl%(10) AND $FFFF
65027    RETURN
65028 '
65029 DEF PROC Vex_Motv(R X%L)
65030    Ctrl%(7)= HIGH(X%L):Ctrl%(8)= LOW(X%L)
65031    VDI (126,Ctrl%(12),Intin%(0),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
65032    X%L=Ctrl%(9) SHL 16 OR Ctrl%(10) AND $FFFF
65033    RETURN
65034 '
65035 DEF PROC Vex_Curv(R X%L)
65036    Ctrl%(7)= HIGH(X%L):Ctrl%(8)= LOW(X%L)
65037    VDI (127,Ctrl%(12),Intin%(0),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
65038    X%L=Ctrl%(9) SHL 16 OR Ctrl%(10) AND $FFFF
65039    RETURN
65040 '
65041 DEF PROC Vq_Key_S(R Intout%(0))
65042    VDI (128,Ctrl%(12),Intin%(0),Ptsin%(0,0),Intout%(1),Ptsout%(0,0))
65043    RETURN
65044 '
65045 DEF PROC Vs_Clip(Ptsin%(0,0),Ptsin%(1,0),Ptsin%(0,1),Ptsin%(1,1))
65046    Intin%(0)=1
65047    VDI (129,Ctrl%(12),Intin%(1),Ptsin%(0,4),Intout%(0),Ptsout%(0,0))
65048    RETURN
65049 '
65050 DEF PROC Vs_Clip:Intin%(0)=0
65051    VDI (129,Ctrl%(12),Intin%(1),Ptsin%(0,4),Intout%(0),Ptsout%(0,0))
65052    RETURN
65053 '
65054 DEF PROC V_Clrwk
65055    VDI (3,Ctrl%(12),Intin%(0),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
65056    RETURN
65057 '
65058 DEF PROC V_Updwk
65059    VDI (4,Ctrl%(12),Intin%(0),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
65060    RETURN
65061 '
65062 DEF PROC Vst_Load_Fonts(R X%L)
65063    Intin%(0)=X%L' RESERVED FOR FUTURE USE
65064    VDI (119,Ctrl%(12),Intin%(1),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
65065    X%L=Intout%(0)
65066    RETURN
65067 '
65068 DEF PROC Vst_Unload_Fonts(Intin%(0))
65069    VDI (120,Ctrl%(12),Intin%(1),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
65070    RETURN
65071 '
65072 DEF PROC Vs_Ndc
65073    WPOKE LPEEK( SEGPTR -24),0
65074    RETURN
65075 '
65076 DEF PROC Vs_Ndc(X%L,Y%L,W%L,H%L): LOCAL I%L
65077    I%L= LPEEK( SEGPTR -24): WPOKE I%L,$FFFF: WPOKE I%L+2,X%L: WPOKE I%L+4,Y%L: WPOKE I%L+6,W%L-X%L+1: WPOKE I%L+8,H%L-Y%L+1
65078    RETURN
65079 '
65080 ' Patchen von Fehlern in BASIC V 3.0 / 3.00  ( MEMORY_MOVEB / VS_NDC )
65081 '
65082 DEF PROC Patch_Basic(Nr%L,Offset%L,V_Old%L,V_New%L): LOCAL X%L
65083    IF LPEEK( SEGPTR +20)=0 THEN EXIT
65084    X%L= LPEEK( SEGPTR -36):X%L=X%L+ WPEEK(X%L+Nr%L*2)+Offset%L
65085    IF WPEEK(X%L)=V_Old%L THEN WPOKE X%L,V_New%L
65086    RETURN
65087 '
65088 ' Simulation der Funktion RESERVED fÅr OMIKRON.BASIC V3.0
65089 '
65090 DEF FN Reserved%L(X%L)= LPEEK( SEGPTR -28)+6+X%L
