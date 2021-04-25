64000 END 'GEM Library fÅr OMIKRON-BASIC. Version 2.0.
64001 'Copyright (C) Artur Sîdler, Pforzheim & Thomas Kemp, Birkenfeld
64002 '
64003 'Zeile 64013: $f0,$f4,$f8 fÅr ACCESSORIES, $64,$6c,$7c fÅr APPLICATIONS
64004 'Zeile 64018: REMen fÅr ACCESSORIES
64005 '
64006 'SAVE SYSTEM LPEEK($EC)   ist fÅr MODUL-Interpreter angebracht.
64007 '--- und wenn dann nicht alles wieder lÑuft, freû' ich 'nen Besen.
64008 '
64009 'AES
64010 '
64011 DEF PROC Appl_Init: LOCAL X,Y,W,H: DIM Ctrl%(12),Intin%(128),Addrout(1)
64012    DIM Intout%(128),Ptsin%(1,128),Ptsout%(1,6),Addrin(3),Global%(15)
64013    Wi_Pok1=$64:Wi_Pok2=$6C:Wi_Pok3=$7C:Wi_Pok4=Wi_Pok2+8
64014    Mn_Selected=10:Wm_Redraw=20:Wm_Topped=21:Wm_Closed=22:Wm_Fulled=23:Wm_Arrowed=24
64015    Wm_Hslid=25:Wm_Vslid=26:Wm_Sized=27:Wm_Moved=28:Wm_Newtop=29:Ac_Open=40
64016    Ac_Close=41:Mu_Keybd=1:Mu_Button=2:Mu_M1=4:Mu_M2=8:Mu_Mesag=16:Mu_Timer=32
64017    Appl_Exit:Graf_Handle(Ctrl%(6)): PRINT CHR$(27);"H"; CHR$(27);"H"; CHR$(27);"E"; CHR$(27);"f"; TAB (32);"OMIKRON - BASIC";:Graf_Mouse(0):V_Show_C(0)
64018    Wind_Get(0,4,X,Y,W,H):Form_Dial(0,X,Y,W,H):Form_Dial(3,X,Y,W,H)
64019    RETURN
64020 '
64021 DEF PROC Appl_Read(Intin%(1),R Text$,R Intout%(0))
64022    Intin%(0)=Global%(2):Text$= CHR$(0)*Intin%(1)
64023    Addrin(0)= LPEEK( VARPTR(Text$))+ LPEEK( SEGPTR +28)
64024    AES (11,Global%(15),Intin%(2),Addrin(1),Intout%(1),Addrout(0))
64025    RETURN
64026 '
64027 DEF PROC Appl_Write(Intin%(0),Text$,R Intout%(0)):Intin%(1)= LEN(Text$)
64028    Addrin(0)= LPEEK( VARPTR(Text$))+ LPEEK( SEGPTR +28)
64029    AES (12,Global%(15),Intin%(2),Addrin(1),Intout%(1),Addrout(0))
64030    RETURN
64031 '
64032 DEF PROC Appl_Find(Text$,R Intout%(0))
64033    Text$= LEFT$(Text$+ SPC(8),8)+ CHR$(0)
64034    AES (13,Global%(15),Intin%(0),Addrin(1),Intout%(1),Addrout(0))
64035    RETURN
64036 '
64037 DEF PROC Appl_Tplay(Intin%(0),Intin%(1),Addrin(0))
64038    AES (14,Global%(15),Intin%(2),Addrin(1),Intout%(1),Addrout(0))
64039    RETURN
64040 '
64041 DEF PROC Appl_Trecord(Intin%(0),Addrin(0))
64042    AES (15,Global%(15),Intin%(1),Addrin(1),Intout%(1),Addrout(0))
64043    RETURN
64044 '
64045 DEF PROC Appl_Exit: LOCAL I
64046    FOR I=1 TO 10
64047       Wind_Delete(I)
64048    NEXT I
64049    Form_Dial(3,0,0,1,1):V_Clsvwk:Rsrc_Free
64050    Wind_Update(0):Wind_Update(2):Menu_Bar
64051    Graf_Handle(Ctrl%(6)):V_Hide_C: CLIP : PRINT CHR$(27);"H"; CHR$(27);"H"; CHR$(27);"e"; CHR$(27);"E";: RETURN 'CLIP  n i c h t  herausnehmen!!! (Anm. des Programmierers, er weiû warum!)
64052 '
64053 DEF PROC Evnt_Keybd(R Intout%(0))
64054    AES (20,Global%(15),Intin%(0),Addrin(0),Intout%(1),Addrout(0))
64055    RETURN
64056 '
64057 DEF PROC Evnt_Button(Intin%(0),Intin%(1),Intin%(2),R Intout%(0),R Intout%(1),R Intout%(2),R Intout%(3),R Intout%(4))
64058    AES (21,Global%(15),Intin%(3),Addrin(0),Intout%(5),Addrout(0))
64059    RETURN
64060 '
64061 DEF PROC Evnt_Mouse(Intin%(0),Intin%(1),Intin%(2),Intin%(3),Intin%(4),R Intout%(1),R Intout%(2),R Intout%(3),R Intout%(4))
64062    AES (22,Global%(15),Intin%(5),Addrin(0),Intout%(5),Addrout(0))
64063    RETURN
64064 '
64065 DEF PROC Evnt_Mesag(R Text$):Text$= CHR$(0)*16
64066    Addrin(0)= LPEEK( VARPTR(Text$))+ LPEEK( SEGPTR +28)
64067    AES (23,Global%(15),Intin%(0),Addrin(1),Intout%(1),Addrout(0))
64068    IF CVI(Text$)=41 THEN LPOKE Wi_Pok2, LPEEK(Wi_Pok2) AND 7 SHL 29: LPOKE Wi_Pok4, LPEEK(Wi_Pok4) AND 7 SHL 29
64069    RETURN
64070 '
64071 DEF PROC Evnt_Timer(T):Intin%(0)= LOW(T):Intin%(1)= HIGH(T)
64072    AES (24,Global%(15),Intin%(2),Addrin(0),Intout%(1),Addrout(0))
64073    RETURN
64074 '
64075 DEF PROC Evnt_Multi(Intin%(0),Intin%(1),Intin%(2),Intin%(3),Intin%(4),Intin%(5),Intin%(6),Intin%(7),Intin%(8),Intin%(9),X,Y,W,H,T,R Text$,R Intout%(0),R Intout%(1),R Intout%(2),R Intout%(3),R Intout%(4),R Intout%(5),R Intout%(6))
64076    Intin%(10)=X:Intin%(11)=Y:Intin%(12)=W:Intin%(13)=H
64077    Intin%(14)= LOW(T):Intin%(15)= HIGH(T):Text$= CHR$(0)*16
64078    Addrin(0)= LPEEK( VARPTR(Text$))+ LPEEK( SEGPTR +28)
64079    AES (25,Global%(15),Intin%(16),Addrin(1),Intout%(7),Addrout(0))
64080    IF Intout%(0) AND 16 THEN
64081       IF CVI(Text$)=41 THEN LPOKE Wi_Pok2, LPEEK(Wi_Pok2) AND 7 SHL 29: LPOKE Wi_Pok4, LPEEK(Wi_Pok4) AND 7 SHL 29
64082    ENDIF RETURN
64083 '
64084 DEF PROC Evnt_Dclick(Intin%(1),R Intout%(0)):Intin%(0)=Intout%(0)
64085    AES (26,Global%(15),Intin%(2),Addrin(0),Intout%(1),Addrout(0))
64086    RETURN
64087 '
64088 DEF PROC Menu_Bar(X)
64089    Menu_Bar:Menu_Bar=X:Addrin(0)=X:Intin%(0)=1
64090    LPOKE Wi_Pok4, LPEEK(Wi_Pok4) OR 1 SHL 30
64091    AES (30,Global%(15),Intin%(1),Addrin(1),Intout%(1),Addrout(0))
64092    RETURN
64094 DEF PROC Menu_Bar
64095    Intin%(0)=0:Addrin(0)=Menu_Bar
64096    IF FN Wind_Chek(30,8) THEN
64097       LPOKE Wi_Pok4, LPEEK(Wi_Pok4) XOR 1 SHL 30
64098       AES (30,Global%(15),Intin%(1),Addrin(1),Intout%(1),Addrout(0))
64099    ENDIF Menu_Bar=0: RETURN
64100 '
64101 DEF PROC Menu_Icheck(Intin%(0),Intin%(1)):Addrin(0)=Menu_Bar
64102    IF Menu_Bar THEN
64103       AES (31,Global%(15),Intin%(2),Addrin(1),Intout%(1),Addrout(0))
64104    ENDIF RETURN
64105 '
64106 DEF PROC Menu_Ienable(Intin%(0),Intin%(1)):Addrin(0)=Menu_Bar
64107    IF Menu_Bar THEN
64108       AES (32,Global%(15),Intin%(2),Addrin(1),Intout%(1),Addrout(0))
64109    ENDIF RETURN
64110 '
64111 DEF PROC Menu_Tnormal(Intin%(0),Intin%(1)):Addrin(0)=Menu_Bar
64112    IF Menu_Bar THEN
64113       AES (33,Global%(15),Intin%(2),Addrin(1),Intout%(1),Addrout(0))
64114    ENDIF RETURN
64115 '
64116 DEF PROC Menu_Text(Intin%(0),Text$):Addrin(0)=Menu_Bar
64117    Addrin(1)= LPEEK( VARPTR(Text$))+ LPEEK( SEGPTR +28)
64118    IF Menu_Bar THEN
64119       AES (34,Global%(15),Intin%(1),Addrin(2),Intout%(1),Addrout(0))
64120    ENDIF RETURN
64121 '
64122 DEF PROC Menu_Register(Text$,R Intout%(0))
64123    Addrin(0)= MEMORY(Text$):Intin%(0)=Global%(2)
64124    AES (35,Global%(15),Intin%(1),Addrin(1),Intout%(1),Addrout(0))
64125    RETURN
64126 '
64127 DEF PROC Objc_Add(Intin%(0),Intin%(1),Addrin(0))
64128    AES (40,Global%(15),Intin%(2),Addrin(1),Intout%(1),Addrout(0))
64129    RETURN
64130 '
64131 DEF PROC Objc_Delete(Intin%(0),Addrin(0))
64132    AES (41,Global%(15),Intin%(1),Addrin(1),Intout%(1),Addrout(0))
64133    RETURN
64134 '
64135 DEF PROC Objc_Draw(Intin%(0),Intin%(1),Intin%(2),Intin%(3),Intin%(4),Intin%(5),Addrin(0))
64136    AES (42,Global%(15),Intin%(6),Addrin(1),Intout%(1),Addrout(0))
64137    RETURN
64138 '
64139 DEF PROC Objc_Find(Intin%(0),Intin%(1),Intin%(2),Intin%(3),Addrin(0),R Intout%(0))
64140    AES (43,Global%(15),Intin%(4),Addrin(1),Intout%(1),Addrout(0))
64141    RETURN
64142 '
64143 DEF PROC Objc_Offset(Intin%(0),Addrin(0),R Intout%(1),R Intout%(2))
64144    AES (44,Global%(15),Intin%(1),Addrin(1),Intout%(3),Addrout(0))
64145    RETURN
64146 '
64147 DEF PROC Objc_Order(Intin%(0),Intin%(1),Addrin(0))
64148    AES (45,Global%(15),Intin%(2),Addrin(1),Intout%(1),Addrout(0))
64149    RETURN
64150 '
64151 DEF PROC Objc_Edit(Intin%(0),Intin%(1),R Intin%(2),Intin%(3),Addrin(0))
64152    AES (46,Global%(15),Intin%(6),Addrin(1),Intout%(2),Addrout(0))
64153    Intin%(2)=Intout%(1): RETURN
64154 '
64155 DEF PROC Objc_Change(Intin%(0),Intin%(6),Addrin(0))
64156    Intin%(1)=0:Intin%(7)=0
64157    AES (47,Global%(15),Intin%(8),Addrin(1),Intout%(1),Addrout(0))
64158    RETURN
64159 DEF PROC Objc_Change(Intin%(0),Intin%(6),Intin%(2),Intin%(3),Intin%(4),Intin%(5),Addrin(0))
64160    Intin%(1)=0:Intin%(7)=1
64161    AES (47,Global%(15),Intin%(8),Addrin(1),Intout%(1),Addrout(0))
64162    RETURN
64163 '
64164 DEF PROC Form_Do(Intin%(0),Addrin(0),R Intout%(0))
64165    AES (50,Global%(15),Intin%(1),Addrin(1),Intout%(1),Addrout(0))
64166    RETURN
64167 '
64168 DEF PROC Form_Dial(X,Intin%(5),Intin%(6),Intin%(7),Intin%(8))
64169    IF X=0 THEN IF FN Wind_Chek(29,0) THEN RETURN ELSE LPOKE Wi_Pok2, LPEEK(Wi_Pok2) OR 1 SHL 29
64170    IF X=3 THEN IF FN Wind_Chek(29,0) THEN LPOKE Wi_Pok2, LPEEK(Wi_Pok2) XOR 1 SHL 29 ELSE RETURN
64171    Intin%(1)=Intin%(5)+Intin%(7) SHR 1:Intin%(3)=1:Intin%(0)=X
64172    Intin%(2)=Intin%(6)+Intin%(8) SHR 1:Intin%(4)=1
64173    AES (51,Global%(15),Intin%(9),Addrin(0),Intout%(1),Addrout(0))
64174    RETURN
64175 '
64176 DEF PROC Form_Alert(Intin%(0),Text$,R Intout%(0)):Text$=Text$+ CHR$(0)
64177    Addrin(0)= LPEEK( VARPTR(Text$))+ LPEEK( SEGPTR +28)
64178    AES (52,Global%(15),Intin%(1),Addrin(1),Intout%(1),Addrout(0))
64179    RETURN
64180 '
64181 DEF PROC Form_Error(Intin%(0))
64182    AES (53,Global%(15),Intin%(1),Addrin(0),Intout%(1),Addrout(0))
64183    RETURN
64184 '
64185 DEF PROC Form_Center(Addrin(0),R Intout%(1),R Intout%(2),R Intout%(3),R Intout%(4))
64186    AES (54,Global%(15),Intin%(0),Addrin(1),Intout%(5),Addrout(0))
64187    RETURN
64188 '
64189 DEF PROC Graf_Rubberbox(Intin%(0),Intin%(1),Intin%(2),Intin%(3),R Intout%(1),R Intout%(2))
64190    AES (70,Global%(15),Intin%(4),Addrin(0),Intout%(3),Addrout(0))
64191    RETURN
64192 '
64193 DEF PROC Graf_Dragbox(Intin%(0),Intin%(1),Intin%(2),Intin%(3),Intin%(4),Intin%(5),Intin%(6),Intin%(7),R Intout%(1),R Intout%(2))
64194    AES (71,Global%(15),Intin%(8),Addrin(0),Intout%(3),Addrout(0))
64195    RETURN
64196 '
64197 DEF PROC Graf_Movebox(Intin%(0),Intin%(1),Intin%(2),Intin%(3),Intin%(4),Intin%(5))
64198    AES (72,Global%(15),Intin%(6),Addrin(0),Intout%(1),Addrout(0))
64199    RETURN
64200 '
64201 DEF PROC Graf_Growbox(Intin%(0),Intin%(1),Intin%(2),Intin%(3),Intin%(4),Intin%(5),Intin%(6),Intin%(7))
64202    AES (73,Global%(15),Intin%(8),Addrin(0),Intout%(1),Addrout(0))
64203    RETURN
64204 '
64205 DEF PROC Graf_Shrinkbox(Intin%(0),Intin%(1),Intin%(2),Intin%(3),Intin%(4),Intin%(5),Intin%(6),Intin%(7))
64206    AES (74,Global%(15),Intin%(8),Addrin(0),Intout%(1),Addrout(0))
64207    RETURN
64208 '
64209 DEF PROC Graf_Watchbox(Intin%(1),Intin%(2),Intin%(3),Addrin(0),R Intout%(0))
64210    AES (75,Global%(15),Intin%(4),Addrin(1),Intout%(1),Addrout(0))
64211    RETURN
64212 '
64213 DEF PROC Graf_Slidebox(Intin%(0),Intin%(1),Intin%(2),Addrin(0),R Intout%(0))
64214    AES (76,Global%(15),Intin%(3),Addrin(1),Intout%(1),Addrout(0))
64215    RETURN
64216 '
64217 IF TIMER THEN DEF PROC Graf_Handle(R Intout%(0),R Intout%(1),R Intout%(2),R Intout%(3),R Intout%(4)) ELSE DEF PROC Graf_Handle(R Intout%(0))
64218    AES (77,Global%(15),Intin%(0),Addrin(0),Intout%(5),Addrout(0))
64219    RETURN
64220 '
64221 DEF PROC Graf_Mouse(X,Y,W,H,T): LOCAL I
64222    IF Graf_Mouse=0 THEN Graf_Mouse= MEMORY(74)
64223    T= LPEEK(T)+ LPEEK( SEGPTR +20):Intin%(0)=255
64224    WPOKE Graf_Mouse,X: WPOKE Graf_Mouse+2,Y: WPOKE Graf_Mouse+4,0
64225    WPOKE Graf_Mouse+6,W: WPOKE Graf_Mouse+8,H
64226    FOR I=0 TO 62 STEP 2: WPOKE Graf_Mouse+10+I, WPEEK(T+I): NEXT
64227    Addrin(0)=Graf_Mouse
64228    AES (78,Global%(15),Intin%(1),Addrin(1),Intout%(1),Addrout(0))
64229    RETURN
64230 DEF PROC Graf_Mouse(Intin%(0))
64231    AES (78,Global%(15),Intin%(1),Addrin(1),Intout%(1),Addrout(0))
64232    RETURN
64233 '
64234 DEF PROC Graf_Mkstate(R Intout%(1),R Intout%(2),R Intout%(3),R Intout%(4))
64235    AES (79,Global%(15),Intin%(0),Addrin(0),Intout%(5),Addrout(0))
64236    RETURN
64237 '
64238 DEF PROC Scrp_Read(R Text$)
64239    Addrin(0)= LPEEK( VARPTR(Text$))+ LPEEK( SEGPTR +28)
64240    AES (80,Global%(15),Intin%(0),Addrin(1),Intout%(1),Addrout(0))
64241    RETURN
64242 '
64243 DEF PROC Scrp_Write(Text$)
64244    Addrin(0)= LPEEK( VARPTR(Text$))+ LPEEK( SEGPTR +28)
64245    AES (81,Global%(15),Intin%(0),Addrin(1),Intout%(1),Addrout(0))
64246    RETURN
64247 '
64248 DEF PROC Fsel_Input(R Path$,R Text$,R Intout%(1)): LOCAL X
64249    Path$= LEFT$(Path$+ CHR$(0)*64,64):Text$= LEFT$(Text$+ CHR$(0)*13,13)
64250    X= VARPTR(Text$):Addrin(0)= LPEEK( VARPTR(Path$))+ LPEEK( SEGPTR +28)
64251    Addrin(1)= LPEEK(X)+ LPEEK( SEGPTR +28)
64252    AES (90,Global%(15),Intin%(0),Addrin(2),Intout%(2),Addrout(0))
64253    Text$= LEFT$(Text$, INSTR(Text$+ CHR$(0), CHR$(0))-1)
64254    Path$= LEFT$(Path$, INSTR(Path$+ CHR$(0), CHR$(0))-1): RETURN
64255 '
64256 DEF FN Wind_Chek(W,H)
64257    IF LPEEK(Wi_Pok3) THEN LPOKE Wi_Pok2,0: LPOKE Wi_Pok4,0: LPOKE Wi_Pok3,0: LPOKE Wi_Pok1,0
64258    IF W<1 THEN RETURN 0
64259    RETURN BIT(W, LPEEK(Wi_Pok2+H))
64260 '
64261 DEF PROC Wind_Create(Intin%(0),Intin%(1),Intin%(2),Intin%(3),Intin%(4),R Intout%(0))
64262    AES (100,Global%(15),Intin%(5),Addrin(0),Intout%(1),Addrout(0))
64263    IF LPEEK(Wi_Pok3) THEN LPOKE Wi_Pok2,0: LPOKE Wi_Pok4,0: LPOKE Wi_Pok3,0: LPOKE Wi_Pok1,0
64264    IF Intout%(0)>0 THEN LPOKE Wi_Pok2, LPEEK(Wi_Pok2) OR 1 SHL Intout%(0)
64265    RETURN
64266 '
64267 DEF PROC Wind_Open(W,Intin%(1),Intin%(2),Intin%(3),Intin%(4))
64268    IF W>0 THEN
64269       IF FN Wind_Chek(W,8)=0 THEN
64270          LPOKE Wi_Pok4, LPEEK(Wi_Pok4) OR 1 SHL W:Intin%(0)=W
64271          AES (101,Global%(15),Intin%(5),Addrin(0),Intout%(1),Addrout(0))
64272       ENDIF
64273    ENDIF RETURN
64274 '
64275 DEF PROC Wind_Close(W)
64276    IF FN Wind_Chek(W,8) THEN
64277       LPOKE Wi_Pok4, LPEEK(Wi_Pok4) XOR 1 SHL W:Intin%(0)=W
64278       AES (102,Global%(15),Intin%(1),Addrin(0),Intout%(1),Addrout(0))
64279    ENDIF RETURN
64280 '
64281 DEF PROC Wind_Delete(W):Wind_Close(W)
64282    IF FN Wind_Chek(W,0) THEN
64283       LPOKE Wi_Pok2, LPEEK(Wi_Pok2) XOR 1 SHL W:Intin%(0)=W
64284       AES (103,Global%(15),Intin%(1),Addrin(0),Intout%(1),Addrout(0))
64285    ENDIF RETURN
64286 '
64287 DEF PROC Wind_Get(Intin%(0),Intin%(1),R Intout%(1))
64288    IF FN Wind_Chek(Intin%(0),0)=0 AND Intin%(1)<>10 THEN RETURN
64289    AES (104,Global%(15),Intin%(2),Addrin(0),Intout%(5),Addrout(0))
64290    RETURN
64291 DEF PROC Wind_Get(Intin%(0),Intin%(1),R Intout%(1),R Intout%(2),R Intout%(3),R Intout%(4))
64292    IF FN Wind_Chek(Intin%(0),0)=0 AND Intin%(0) THEN RETURN
64293    AES (104,Global%(15),Intin%(2),Addrin(0),Intout%(5),Addrout(0))
64294    RETURN
64295 '
64296 DEF PROC Wind_Set(Intin%(0))
64297    IF FN Wind_Chek(Intin%(0),8)=0 THEN RETURN
64298    Intin%(1)=10:Intin%(2)=Intin%(0)
64299    AES (105,Global%(15),Intin%(6),Addrin(0),Intout%(1),Addrout(0))
64300    RETURN
64301 DEF PROC Wind_Set(X,Intin%(4))
64302    Intin%(2)= HIGH(X):Intin%(3)= LOW(X):Intin%(0)=0:Intin%(1)=14
64303    AES (105,Global%(15),Intin%(6),Addrin(0),Intout%(1),Addrout(0))
64304    RETURN
64305 DEF PROC Wind_Set(Intin%(0),Intin%(1),Intin%(2))
64306    IF FN Wind_Chek(Intin%(0),0)=0 THEN RETURN
64307    AES (105,Global%(15),Intin%(6),Addrin(0),Intout%(1),Addrout(0))
64308    RETURN
64309 DEF PROC Wind_Set(Intin%(0),Intin%(1),Text$,X): LOCAL I
64310    IF FN Wind_Chek(Intin%(0),0)=0 THEN RETURN
64311    Intin%(2)= HIGH(X):Intin%(3)= LOW(X)
64312    FOR I=1 TO LEN(Text$): POKE X+I-1, ASC( MID$(Text$,I)): NEXT : POKE X+I-1,0
64313    AES (105,Global%(15),Intin%(6),Addrin(0),Intout%(1),Addrout(0))
64314    RETURN
64315 DEF PROC Wind_Set(Intin%(0),Intin%(2),Intin%(3),Intin%(4),Intin%(5))
64316    IF FN Wind_Chek(Intin%(0),0)=0 THEN RETURN
64317    Intin%(1)=5
64318    AES (105,Global%(15),Intin%(6),Addrin(0),Intout%(1),Addrout(0))
64319    RETURN
64320 '
64321 DEF PROC Wind_Find(Intin%(0),Intin%(1),R Intout%(0))
64322    AES (106,Global%(15),Intin%(2),Addrin(0),Intout%(1),Addrout(0))
64323    RETURN
64324 '
64325 DEF PROC Wind_Update(X):Intin%(0)=X
64326    IF X=0 THEN IF FN Wind_Chek(30,0)=0 THEN RETURN ELSE LPOKE Wi_Pok2, LPEEK(Wi_Pok2) XOR 1 SHL 30
64327    IF X=1 THEN IF FN Wind_Chek(30,0) THEN RETURN ELSE LPOKE Wi_Pok2, LPEEK(Wi_Pok2) XOR 1 SHL 30
64328    IF X=2 THEN IF FN Wind_Chek(31,0)=0 THEN RETURN ELSE LPOKE Wi_Pok2, LPEEK(Wi_Pok2) XOR 1 SHL 31
64329    IF X=3 THEN IF FN Wind_Chek(31,0) THEN RETURN ELSE LPOKE Wi_Pok2, LPEEK(Wi_Pok2) XOR 1 SHL 31
64330    AES (107,Global%(15),Intin%(1),Addrin(0),Intout%(1),Addrout(0))
64331    RETURN
64332 '
64333 DEF PROC Wind_Calc(Intin%(0),Intin%(1),Intin%(2),Intin%(3),Intin%(4),Intin%(5),R Intout%(1),R Intout%(2),R Intout%(3),R Intout%(4))
64334    AES (108,Global%(15),Intin%(6),Addrin(0),Intout%(5),Addrout(0))
64335    RETURN
64336 '
64337 DEF PROC Rsrc_Load(Text$,R Intout%(0)):Text$=Text$+ CHR$(0)
64338    Rsrc_Free:Addrin(0)= LPEEK( VARPTR(Text$))+ LPEEK( SEGPTR +28)
64339    AES (110,Global%(15),Intin%(0),Addrin(1),Intout%(1),Addrout(0))
64340    LPOKE Wi_Pok1,Global%(5) SHL 16 OR Global%(6)
64341    RETURN
64342 '
64343 DEF PROC Rsrc_Free
64344    IF LPEEK(Wi_Pok3) THEN LPOKE Wi_Pok2,0: LPOKE Wi_Pok4,0: LPOKE Wi_Pok3,0: LPOKE Wi_Pok1,0
64345    IF LPEEK(Wi_Pok1) THEN
64346       Global%(5)= WPEEK(Wi_Pok1):Global%(6)= LOW( LPEEK(Wi_Pok1)): LPOKE Wi_Pok1,0
64347       AES (111,Global%(15),Intin%(0),Addrin(0),Intout%(1),Addrout(0))
64348    ENDIF RETURN
64349 '
64350 DEF PROC Rsrc_Gaddr(Intin%(0),Intin%(1),R Addrout(0))
64351    AES (112,Global%(15),Intin%(2),Addrin(0),Intout%(1),Addrout(1))
64352    RETURN
64353 '
64354 DEF PROC Rsrc_Saddr(Intin%(0),Intin%(1),Addrin(0))
64355    AES (113,Global%(15),Intin%(2),Addrin(1),Intout%(1),Addrout(0))
64356    RETURN
64357 '
64358 DEF PROC Rsrc_Obfix(Intin%(0),Addrin(0))
64359    AES (114,Global%(15),Intin%(1),Addrin(1),Intout%(1),Addrout(0))
64360    RETURN
64361 '
64362 DEF PROC Shel_Read(R Path$,R Text$): LOCAL X
64363    Path$= CHR$(0)*128:X= VARPTR(Path$):Text$= CHR$(0)*128
64364    Addrin(1)= LPEEK( VARPTR(Text$))+ LPEEK( SEGPTR +28)
64365    Addrin(0)= LPEEK(X)+ LPEEK( SEGPTR +28)
64366    AES (120,Global%(15),Intin%(0),Addrin(2),Intout%(1),Addrout(0))
64367    Text$= LEFT$(Text$, INSTR(Text$+ CHR$(0), CHR$(0))-1)
64368    Path$= LEFT$(Path$, INSTR(Path$+ CHR$(0), CHR$(0))-1)
64369    RETURN
64370 '
64371 DEF PROC Shel_Write(Intin%(0),Intin%(1),Intin%(2),Path$,Text$): LOCAL X
64372    X= VARPTR(Path$)
64373    Addrin(1)= LPEEK( VARPTR(Text$))+ LPEEK( SEGPTR +28)
64374    Addrin(0)= LPEEK(X)+ LPEEK( SEGPTR +28)
64375    AES (121,Global%(15),Intin%(3),Addrin(2),Intout%(1),Addrout(0))
64376    RETURN
64377 '
64378 DEF PROC Shel_Get(R Text$)
64379    Intin%(0)= LEN(Text$):Addrin(0)= LPEEK( VARPTR(Text$))+ LPEEK( SEGPTR +28)
64380    AES (122,Global%(15),Intin%(1),Addrin(1),Intout%(1),Addrout(0))
64381    Text$= LEFT$(Text$, INSTR(Text$+ CHR$(0), CHR$(0))-1)
64382    RETURN
64383 '
64384 DEF PROC Shel_Put(Text$)
64385    Intin%(0)= LEN(Text$):Addrin(0)= LPEEK( VARPTR(Text$))+ LPEEK( SEGPTR +28)
64386    AES (123,Global%(15),Intin%(1),Addrin(1),Intout%(1),Addrout(0))
64387    RETURN
64388 '
64389 DEF PROC Shel_Find(R Text$,R Intout%(0))
64390    Text$= LEFT$(Text$+ CHR$(0)*128,128)
64391    Addrin(0)= LPEEK( VARPTR(Text$))+ LPEEK( SEGPTR +28)
64392    AES (124,Global%(15),Intin%(0),Addrin(1),Intout%(1),Addrout(0))
64393    RETURN
64394 '
64395 DEF PROC Shel_Envrn(Path$,R Text$): LOCAL X
64396    X= VARPTR(Path$)
64397    Addrin(1)= LPEEK( VARPTR(X)):X=0:Text$=""
64398    Addrin(0)= LPEEK( VARPTR(Path$))+ LPEEK( SEGPTR +28)
64399    AES (125,Global%(15),Intin%(0),Addrin(1),Intout%(1),Addrout(0))
64400    IF X THEN
64401       Path$= CHR$(0)*128: LPOKE VARPTR(Path$),X- LPEEK( SEGPTR +28)
64402       Text$= LEFT$(Path$, INSTR(Path$+ CHR$(0), CHR$(0))-1)
64403       Path$=""
64404    ENDIF : RETURN
64405 '
64406 'VDI
64407 '
64408 DEF PROC V_Pline(X)
64409    VDI (6,Ctrl%(12),Intin%(0),Ptsin%(0,X),Intout%(0),Ptsout%(0,0))
64410    RETURN
64411 '
64412 DEF PROC V_Pmarker(X)
64413    VDI (7,Ctrl%(12),Intin%(0),Ptsin%(0,X),Intout%(0),Ptsout%(0,0))
64414    RETURN
64415 '
64416 DEF PROC V_Gtext(Ptsin%(0,0),Ptsin%(1,0),Text$): LOCAL I
64417    FOR I=0 TO LEN(Text$)-1:Intin%(I)= ASC( MID$(Text$,I+1,1)): NEXT
64418    VDI (8,Ctrl%(12),Intin%(I),Ptsin%(0,1),Intout%(0),Ptsout%(0,0))
64419    RETURN
64420 '
64421 DEF PROC V_Fillarea(X)
64422    VDI (9,Ctrl%(12),Intin%(0),Ptsin%(0,X),Intout%(0),Ptsout%(0,0))
64423    RETURN
64424 '
64425 DEF PROC V_Cellarray(Ctrl%(7),Ctrl%(8),Ctrl%(9),Ctrl%(10),X,Ptsin%(0,0),Ptsin%(1,0),Ptsin%(0,1),Ptsin%(1,1))
64426    VDI (10,Ctrl%(12),Intin%(X),Ptsin%(0,2),Intout%(0),Ptsout%(0,0))
64427    RETURN
64428 '
64429 DEF PROC V_Bar(Ptsin%(0,0),Ptsin%(1,0),Ptsin%(0,1),Ptsin%(1,1))
64430    Ctrl%(5)=1
64431    VDI (11,Ctrl%(12),Intin%(0),Ptsin%(0,2),Intout%(0),Ptsout%(0,0))
64432    RETURN
64433 '
64434 DEF PROC V_Arc(Intin%(0),Intin%(1),Ptsin%(0,0),Ptsin%(1,0),Ptsin%(0,3))
64435    Ctrl%(5)=2:Ptsin%(0,1)=0:Ptsin%(1,1)=0:Ptsin%(0,2)=0
64436    Ptsin%(1,2)=0:Ptsin%(1,3)=0
64437    VDI (11,Ctrl%(12),Intin%(2),Ptsin%(0,4),Intout%(0),Ptsout%(0,0))
64438    RETURN
64439 '
64440 DEF PROC V_Pieslice(Intin%(0),Intin%(1),Ptsin%(0,0),Ptsin%(1,0),Ptsin%(0,3))
64441    Ctrl%(5)=3:Ptsin%(0,1)=0:Ptsin%(1,1)=0:Ptsin%(0,2)=0
64442    Ptsin%(1,2)=0:Ptsin%(1,3)=0
64443    VDI (11,Ctrl%(12),Intin%(2),Ptsin%(0,4),Intout%(0),Ptsout%(0,0))
64444    RETURN
64445 '
64446 DEF PROC V_Circle(Ptsin%(0,0),Ptsin%(1,0),Ptsin%(0,2))
64447    Ctrl%(5)=4:Ptsin%(0,1)=0:Ptsin%(1,1)=0:Ptsin%(1,2)=0
64448    VDI (11,Ctrl%(12),Intin%(0),Ptsin%(0,3),Intout%(0),Ptsout%(0,0))
64449    RETURN
64450 '
64451 DEF PROC V_Ellipse(Ptsin%(0,0),Ptsin%(1,0),Ptsin%(0,1),Ptsin%(1,1))
64452    Ctrl%(5)=5
64453    VDI (11,Ctrl%(12),Intin%(0),Ptsin%(0,2),Intout%(0),Ptsout%(0,0))
64454    RETURN
64455 '
64456 DEF PROC V_Ellarc(Ptsin%(0,0),Ptsin%(1,0),Ptsin%(0,1),Ptsin%(1,1),Intin%(0),Intin%(1))
64457    Ctrl%(5)=6
64458    VDI (11,Ctrl%(12),Intin%(2),Ptsin%(0,2),Intout%(0),Ptsout%(0,0))
64459    RETURN
64460 '
64461 DEF PROC V_Ellpie(Ptsin%(0,0),Ptsin%(1,0),Ptsin%(0,1),Ptsin%(1,1),Intin%(0),Intin%(1))
64462    Ctrl%(5)=7
64463    VDI (11,Ctrl%(12),Intin%(2),Ptsin%(0,2),Intout%(0),Ptsout%(0,0))
64464    RETURN
64465 '
64466 DEF PROC V_Rbox(Ptsin%(0,0),Ptsin%(1,0),Ptsin%(0,1),Ptsin%(1,1))
64467    Ctrl%(5)=8
64468    VDI (11,Ctrl%(12),Intin%(0),Ptsin%(0,2),Intout%(0),Ptsout%(0,0))
64469    RETURN
64470 '
64471 DEF PROC V_Rfbox(Ptsin%(0,0),Ptsin%(1,0),Ptsin%(0,1),Ptsin%(1,1))
64472    Ctrl%(5)=9
64473    VDI (11,Ctrl%(12),Intin%(0),Ptsin%(0,2),Intout%(0),Ptsout%(0,0))
64474    RETURN
64475 '
64476 DEF PROC V_Justified(Ptsin%(0,0),Ptsin%(1,0),Text$,Intin%(0),Intin%(1),Ptsin%(0,1))
64477    LOCAL I:Ctrl%(5)=10
64478    FOR I=1 TO LEN(Text$):Intin%(I+1)= ASC( MID$(Text$,I)): NEXT :Intin%(I+1)=0
64479    VDI (11,Ctrl%(12),Intin%(I+1),Ptsin%(0,2),Intout%(0),Ptsout%(0,0))
64480    RETURN
64481 '
64482 DEF PROC Vst_Height(Ptsin%(1,0))
64483    VDI (12,Ctrl%(12),Intin%(0),Ptsin%(0,1),Intout%(0),Ptsout%(0,2))
64484    RETURN
64485 DEF PROC Vst_Height(Ptsin%(1,0),R Ptsout%(0,0),R Ptsout%(1,0),R Ptsout%(0,1),R Ptsout%(1,1))
64486    VDI (12,Ctrl%(12),Intin%(0),Ptsin%(0,1),Intout%(0),Ptsout%(0,2))
64487    RETURN
64488 '
64489 DEF PROC Vst_Rotation(Intin%(0))
64490    VDI (13,Ctrl%(12),Intin%(1),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
64491    RETURN
64492 '
64493 DEF PROC Vs_Color(Intin%(0),Intin%(1),Intin%(2),Intin%(3))
64494    VDI (14,Ctrl%(12),Intin%(4),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
64495    RETURN
64496 '
64497 DEF PROC Vst_Font(Intin%(0))
64498    VDI (21,Ctrl%(12),Intin%(1),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
64499    RETURN
64500 '
64501 DEF PROC Vsl_Type(Intin%(0))
64502    VDI (15,Ctrl%(12),Intin%(1),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
64503    RETURN
64504 '
64505 DEF PROC Vsl_Width(Ptsin%(0,0))
64506    VDI (16,Ctrl%(12),Intin%(0),Ptsin%(0,1),Intout%(0),Ptsout%(0,0))
64507    RETURN
64508 '
64509 DEF PROC Vsl_Color(Intin%(0))
64510    VDI (17,Ctrl%(12),Intin%(1),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
64511    RETURN
64512 '
64513 DEF PROC Vsm_Type(Intin%(0))
64514    VDI (18,Ctrl%(12),Intin%(1),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
64515    RETURN
64516 '
64517 DEF PROC Vsm_Height(Ptsin%(1,0))
64518    Ptsin%(0,0)=0
64519    VDI (19,Ctrl%(12),Intin%(0),Ptsin%(0,1),Intout%(0),Ptsout%(0,0))
64520    RETURN
64521 '
64522 DEF PROC Vsm_Color(Intin%(0))
64523    VDI (20,Ctrl%(12),Intin%(1),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
64524    RETURN
64525 '
64526 DEF PROC Vst_Color(Intin%(0))
64527    VDI (22,Ctrl%(12),Intin%(1),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
64528    RETURN
64529 '
64530 DEF PROC Vsf_Interior(Intin%(0))
64531    VDI (23,Ctrl%(12),Intin%(1),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
64532    RETURN
64533 '
64534 DEF PROC Vsf_Style(Intin%(0))
64535    VDI (24,Ctrl%(12),Intin%(1),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
64536    RETURN
64537 '
64538 DEF PROC Vsf_Color(Intin%(0))
64539    VDI (25,Ctrl%(12),Intin%(1),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
64540    RETURN
64541 '
64542 DEF PROC Vq_Color(Intin%(0),Intin%(1),R Intout%(0),R Intout%(1),R Intout%(2),R Intout%(3))
64543    VDI (26,Ctrl%(12),Intin%(2),Ptsin%(0,0),Intout%(4),Ptsout%(0,0))
64544    RETURN
64545 '
64546 DEF PROC Vrq_Locator(Ptsin%(0,0),Ptsin%(1,0),R Intout%(0),R Ptsout%(0,0),R Ptsout%(1,0))
64547    Vsin_Mode(1,1)
64548    VDI (28,Ctrl%(12),Intin%(0),Ptsin%(0,1),Intout%(1),Ptsout%(0,1))
64549    RETURN
64550 '
64551 DEF PROC Vsm_Locator(Ptsin%(0,0),Ptsin%(1,0),R X,R Intout%(0),R Ptsout%(0,0),R Ptsout%(1,0))
64552    Vsin_Mode(1,2)
64553    VDI (28,Ctrl%(12),Intin%(0),Ptsin%(0,1),Intout%(1),Ptsout%(0,1))
64554    X=Ctrl%(4)*2+Ctrl%(2)
64555    RETURN
64556 '
64557 DEF PROC Vrq_Valuator(Intin%(0),R Intout%(0),R Intout%(1))
64558    Vsin_Mode(2,1)
64559    VDI (29,Ctrl%(12),Intin%(1),Ptsin%(0,0),Intout%(2),Ptsout%(0,0))
64560    RETURN
64561 '
64562 DEF PROC Vsm_Valuator(Intin%(0),R X,R Intout%(0),R Intout%(1))
64563    Vsin_Mode(2,2)
64564    VDI (29,Ctrl%(12),Intin%(1),Ptsin%(0,0),Intout%(2),Ptsout%(0,0))
64565    X=Ctrl%(4)
64566    RETURN
64567 '
64568 DEF PROC Vrq_Choice(Intin%(0),R Intout%(0))
64569    Vsin_Mode(3,1)
64570    VDI (30,Ctrl%(12),Intin%(1),Ptsin%(0,0),Intout%(1),Ptsout%(0,0))
64571    RETURN
64572 '
64573 DEF PROC Vsm_Choice(R X,R Intout%(0))
64574    Vsin_Mode(3,2)
64575    VDI (30,Ctrl%(12),Intin%(1),Ptsin%(0,0),Intout%(1),Ptsout%(0,0))
64576    X=Ctrl%(4)
64577    RETURN
64578 '
64579 DEF PROC Vrq_String(Intin%(0),Intin%(1),Ptsin%(0,0),Ptsin%(1,0),R Text$)
64580    Vsin_Mode(4,1)
64581    VDI (31,Ctrl%(12),Intin%(2),Ptsin%(0,1),Intout%(128),Ptsout%(0,0))
64582    LOCAL I:Text$=""
64583    FOR I=1 TO Ctrl%(4):Text$=Text$+ CHR$(Intout%(I-1)): NEXT
64584    RETURN
64585 '
64586 DEF PROC Vsm_String(Intin%(0),Intin%(1),Ptsin%(0,0),Ptsin%(1,0),R Text$)
64587    Vsin_Mode(4,2)
64588    VDI (31,Ctrl%(12),Intin%(2),Ptsin%(0,1),Intout%(128),Ptsout%(0,0))
64589    LOCAL I:Text$=""
64590    FOR I=1 TO Ctrl%(4):Text$=Text$+ CHR$(Intout%(I-1)): NEXT
64591    RETURN
64592 '
64593 DEF PROC Vswr_Mode(Intin%(0))
64594    VDI (32,Ctrl%(12),Intin%(1),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
64595    RETURN
64596 '
64597 DEF PROC Vsin_Mode(Intin%(0),Intin%(1))
64598    VDI (33,Ctrl%(12),Intin%(2),Ptsin%(0,0),Intout%(1),Ptsout%(0,0))
64599    RETURN
64600 '
64601 DEF PROC Vql_Attributes(R Intout%(0),R Intout%(1),R Intout%(2),R Intout%(3),R Intout%(4),R Ptsout%(0,0),R Ptsout%(1,0))
64602    VDI (35,Ctrl%(12),Intin%(0),Ptsin%(0,0),Intout%(5),Ptsout%(0,1))
64603    RETURN
64604 '
64605 DEF PROC Vqm_Attributes(R Intout%(0),R Intout%(1),R Intout%(2),R Ptsout%(0,0),R Ptsout%(1,0))
64606    VDI (36,Ctrl%(12),Intin%(0),Ptsin%(0,0),Intout%(3),Ptsout%(0,1))
64607    RETURN
64608 '
64609 DEF PROC Vqf_Attributes(R Intout%(0),R Intout%(1),R Intout%(2),R Intout%(3),R Intout%(4))
64610    VDI (37,Ctrl%(12),Intin%(0),Ptsin%(0,0),Intout%(5),Ptsout%(0,0))
64611    RETURN
64612 '
64613 DEF PROC Vqt_Attributes(R Intout%(0),R Intout%(1),R Intout%(2),R Intout%(3),R Intout%(4),R Intout%(5),R Ptsout%(0,0),R Ptsout%(1,0),R Ptsout%(0,1),R Ptsout%(1,1))
64614    VDI (38,Ctrl%(12),Intin%(0),Ptsin%(0,0),Intout%(6),Ptsout%(0,2))
64615    RETURN
64616 '
64617 DEF PROC Vst_Alignment(Intin%(0),Intin%(1))
64618    VDI (39,Ctrl%(12),Intin%(2),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
64619    RETURN
64620 '
64621 DEF PROC V_Opnvwk
64622    V_Opnvwk(1,1,1,1,1,1,1,1,1,1,2)
64623    RETURN
64624 DEF PROC V_Opnvwk(Intin%(0),Intin%(1),Intin%(2),Intin%(3),Intin%(4),Intin%(5),Intin%(6),Intin%(7),Intin%(8),Intin%(9),Intin%(10))
64625    VDI (100,Ctrl%(12),Intin%(11),Ptsin%(0,0),Intout%(45),Ptsout%(0,6))
64626    RETURN
64627 '
64628 DEF PROC V_Clsvwk
64629    VDI (101,Ctrl%(12),Intin%(0),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
64630    RETURN
64631 '
64632 DEF PROC Vq_Extnd(Intin%(0))
64633    VDI (102,Ctrl%(12),Intin%(0),Ptsin%(0,0),Intout%(45),Ptsout%(0,6))
64634    RETURN
64635 '
64636 DEF PROC V_Contourfill(Ptsin%(0,0),Ptsin%(1,0),Intin%(0))
64637    VDI (103,Ctrl%(12),Intin%(1),Ptsin%(0,1),Intout%(0),Ptsout%(0,0))
64638    RETURN
64639 '
64640 DEF PROC Vsf_Perimeter(Intin%(0))
64641    VDI (104,Ctrl%(12),Intin%(1),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
64642    RETURN
64643 '
64644 DEF PROC V_Get_Pixel(Ptsin%(0,0),Ptsin%(1,0),R Intout%(0),R Intout%(1))
64645    VDI (105,Ctrl%(12),Intin%(0),Ptsin%(0,1),Intout%(2),Ptsout%(0,0))
64646    RETURN
64647 '
64648 DEF PROC Vst_Effects(Intin%(0))
64649    VDI (106,Ctrl%(12),Intin%(1),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
64650    RETURN
64651 '
64652 DEF PROC Vst_Point(Intin%(0))
64653    VDI (107,Ctrl%(12),Intin%(1),Ptsin%(0,0),Intout%(0),Ptsout%(0,2))
64654    RETURN
64655 DEF PROC Vst_Point(Intin%(0),Ptsout%(0,0),Ptsout%(1,0),Ptsout%(0,1),Ptsout%(1,1))
64656    VDI (107,Ctrl%(12),Intin%(1),Ptsin%(0,0),Intout%(0),Ptsout%(0,2))
64657    RETURN
64658 '
64659 DEF PROC Vsl_Ends(Intin%(0),Intin%(1))
64660    VDI (108,Ctrl%(12),Intin%(2),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
64661    RETURN
64662 '
64663 DEF PROC Vro_Cpyfm(X,Y,Intin%(0),Ptsin%(0,0),Ptsin%(1,0),Ptsin%(0,1),Ptsin%(1,1),Ptsin%(0,2),Ptsin%(1,2),Ptsin%(0,3),Ptsin%(1,3))
64664    Ctrl%(7)= HIGH(X):Ctrl%(8)= LOW(X):Ctrl%(9)= HIGH(Y):Ctrl%(10)= LOW(Y)
64665    VDI (109,Ctrl%(12),Intin%(1),Ptsin%(0,4),Intout%(0),Ptsout%(0,0))
64666    RETURN
64667 '
64668 DEF PROC Vr_Trnfm(X,Y)
64669    Ctrl%(7)= HIGH(X):Ctrl%(8)= LOW(X):Ctrl%(9)= HIGH(Y):Ctrl%(10)= LOW(Y)
64670    VDI (110,Ctrl%(12),Intin%(0),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
64671    RETURN
64672 '
64673 DEF PROC Vsc_Form(Intin%(0),Intin%(1),Intin%(2),Intin%(3),Intin%(4),Text$)
64674    LOCAL I: FOR I=0 TO 31:Intin%(I+5)= CVI( MID$(Text$,I*2+1)): NEXT
64675    VDI (111,Ctrl%(12),Intin%(37),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
64676    RETURN
64677 '
64678 DEF PROC Vsf_Udpat(X)
64679    VDI (112,Ctrl%(12),Intin%(X*16),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
64680    RETURN
64681 '
64682 DEF PROC Vex_Timv(R X,R Intout%(0))
64683    Ctrl%(7)= HIGH(X):Ctrl%(8)= LOW(X)
64684    VDI (118,Ctrl%(12),Intin%(0),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
64685    X=Ctrl%(9) SHL 16 OR Ctrl%(10)
64686    RETURN
64687 '
64688 DEF PROC Vsl_Udsty(Intin%(0))
64689    VDI (113,Ctrl%(12),Intin%(1),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
64690    RETURN
64691 '
64692 DEF PROC V_Recfl(Ptsin%(0,0),Ptsin%(1,0),Ptsin%(0,1),Ptsin%(1,1))
64693    VDI (114,Ctrl%(12),Intin%(0),Ptsin%(0,2),Intout%(0),Ptsout%(0,0))
64694    RETURN
64695 '
64696 DEF PROC Vqin_Mode(Intin%(0),R Intout%(0))
64697    VDI (115,Ctrl%(12),Intin%(1),Ptsin%(0,0),Intout%(1),Ptsout%(0,0))
64698    RETURN
64699 '
64700 DEF PROC Vqt_Name(Intin%(0),R Intout%(0),R Text$)
64701    LOCAL I
64702    VDI (130,Ctrl%(12),Intin%(1),Ptsin%(0,0),Intout%(32),Ptsout%(0,0))
64703    Text$=""
64704    FOR I=1 TO 32:Text$=Text$+ CHR$(Intout%(I)): NEXT
64705    RETURN
64706 '
64707 DEF PROC Vqt_Fontinfo(R Intout%(0),R Intout%(1))
64708    VDI (131,Ctrl%(12),Intin%(0),Ptsin%(0,0),Intout%(2),Ptsout%(0,5))
64709    RETURN
64710 '
64711 DEF PROC Vq_Chcells(R Intout%(0),R Intout%(1))
64712    Ctrl%(5)=1
64713    VDI (5,Ctrl%(12),Intin%(0),Ptsin%(0,0),Intout%(2),Ptsout%(0,0))
64714    RETURN
64715 '
64716 DEF PROC V_Exit_Cur
64717    PRINT CHR$(27);"f"; CHR$(27);"E";: RETURN
64718 '
64719 DEF PROC V_Enter_Cur
64720    PRINT CHR$(27);"E"; CHR$(27);"e";: RETURN
64721 '
64722 DEF PROC V_Curup
64723    PRINT CHR$(27);"A";: RETURN
64724 '
64725 DEF PROC V_Curdown
64726    PRINT CHR$(27);"B";: RETURN
64727 '
64728 DEF PROC V_Curright
64729    PRINT CHR$(27);"C";: RETURN
64730 '
64731 DEF PROC V_Curleft
64732    PRINT CHR$(27);"D";: RETURN
64733 '
64734 DEF PROC V_Curhome
64735    PRINT CHR$(27);"H";: RETURN
64736 '
64737 DEF PROC V_Eeos
64738    PRINT CHR$(27);"J";: RETURN
64739 '
64740 DEF PROC V_Eeol
64741    PRINT CHR$(27);"K";: RETURN
64742 '
64743 DEF PROC V_Curaddress(Y,X)
64744    PRINT @(Y-1,X-1);: RETURN
64745 '
64746 DEF PROC V_Curtext(Text$)
64747    PRINT Text$;: RETURN
64748 '
64749 DEF PROC V_Rvon
64750    PRINT CHR$(27);"p";: RETURN
64751 '
64752 DEF PROC V_Rvoff
64753    PRINT CHR$(27);"q";: RETURN
64754 '
64755 DEF PROC Vq_Curaddress(R Y,R X)
64756    Y= CSRLIN :X= POS(0)+1: RETURN
64757 '
64758 DEF PROC Vq_Tabstatus(R Intout%(0))
64759    Ctrl%(5)=16
64760    VDI (5,Ctrl%(12),Intin%(0),Ptsin%(0,0),Intout%(1),Ptsout%(0,0))
64761    RETURN
64762 '
64763 DEF PROC V_Hardcopy
64764    XBIOS (,20): RETURN
64765 '
64766 DEF PROC V_Dspcur(Ptsin%(0,0),Ptsin%(1,0))
64767    Ctrl%(5)=18
64768    VDI (5,Ctrl%(12),Intin%(0),Ptsin%(0,1),Intout%(0),Ptsout%(0,0))
64769    RETURN
64770 '
64771 DEF PROC V_Rmcur
64772    Ctrl%(5)=19
64773    VDI (5,Ctrl%(12),Intin%(0),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
64774    RETURN
64775 '
64776 DEF PROC V_Form_Adv
64777    Ctrl%(5)=20
64778    VDI (5,Ctrl%(12),Intin%(0),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
64779    RETURN
64780 '
64781 DEF PROC V_Output_Window(Ptsin%(0,0),Ptsin%(1,0),Ptsin%(0,1),Ptsin%(1,1))
64782    Ctrl%(5)=21
64783    VDI (5,Ctrl%(12),Intin%(0),Ptsin%(0,2),Intout%(0),Ptsout%(0,0))
64784    RETURN
64785 '
64786 DEF PROC V_Clear_Disp_List
64787    Ctrl%(5)=22
64788    VDI (5,Ctrl%(12),Intin%(0),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
64789    RETURN
64790 '
64791 DEF PROC V_Bit_Image(Text$,Intin%(0),Intin%(1),X,Ptsin%(0,0),Ptsin%(1,0),Ptsin%(0,1),Ptsin%(1,1))
64792    LOCAL I:Intin%(2)=0
64793    Ctrl%(5)=23
64794    IF LEN(Text$) THEN
64795       FOR I=1 TO LEN(Text$):Intin%(I+1)= ASC( MID$(Text$,I,1)): NEXT :Intin%(I+1)=0
64796    ENDIF
64797    VDI (5,Ctrl%(12),Intin%( LEN(Text$)+2),Ptsin%(0,X),Intout%(0),Ptsout%(0,0))
64798    RETURN
64799 '
64800 DEF PROC Vs_Palette(Intin%(0))
64801    Ctrl%(5)=60
64802    VDI (5,Ctrl%(12),Intin%(1),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
64803    RETURN
64804 '
64805 DEF PROC Vqp_Films(R Text$)
64806    Ctrl%(5)=91:Text$=""
64807    VDI (5,Ctrl%(12),Intin%(0),Ptsin%(0,0),Intout%(125),Ptsout%(0,0))
64808    FOR I=0 TO 124:Text$=Text$+ CHR$(Intout%(I)): NEXT
64809    RETURN
64810 '
64811 DEF PROC Vqp_State
64812    Ctrl%(5)=92
64813    VDI (5,Ctrl%(12),Intin%(0),Ptsin%(0,0),Intout%(21),Ptsout%(0,0))
64814    RETURN
64815 '
64816 DEF PROC Vsp_Style
64817    Ctrl%(5)=93
64818    VDI (5,Ctrl%(12),Intin%(21),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
64819    RETURN
64820 '
64821 DEF PROC Vsp_Save
64822    Ctrl%(5)=94
64823    VDI (5,Ctrl%(12),Intin%(0),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
64824    RETURN
64825 '
64826 DEF PROC Vsp_Message
64827    Ctrl%(5)=95
64828    VDI (5,Ctrl%(12),Intin%(0),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
64829    RETURN
64830 '
64831 DEF PROC Vqp_Error(R Intout%(0))
64832    Ctrl%(5)=96
64833    VDI (5,Ctrl%(12),Intin%(0),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
64834    RETURN
64835 '
64836 DEF PROC V_Meta_Extents(Ptsin%(0,0),Ptsin%(1,0),Ptsin%(0,1),Ptsin%(1,1))
64837    Ctrl%(5)=98
64838    VDI (5,Ctrl%(12),Intin%(0),Ptsin%(0,2),Intout%(0),Ptsout%(0,0))
64839    RETURN
64840 '
64841 DEF PROC V_Write_Meta(X,Intin%(0),Y)
64842    Ctrl%(5)=99
64843    VDI (5,Ctrl%(12),Intin%(X+1),Ptsin%(0,Y),Intout%(0),Ptsout%(0,0))
64844    RETURN
64845 '
64846 DEF PROC Vm_Filename(Text$)
64847    LOCAL I:Intin%(0)=0
64848    IF LEN(Text$) THEN
64849       FOR I=1 TO LEN(Text$):Intin%(I-1)= ASC( MID$(Text$,I,1)): NEXT :Intin%(I+1)=0
64850    ENDIF
64851    Ctrl%(5)=100
64852    VDI (5,Ctrl%(12),Intin%( LEN(Text$)),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
64853    RETURN
64854 '
64855 DEF PROC Vqt_Extent(Text$,R Ptsout%(0,0),R Ptsout%(1,0),R Ptsout%(0,1),R Ptsout%(1,1),R Ptsout%(0,2),R Ptsout%(1,2),R Ptsout%(0,3),R Ptsout%(1,3))
64856    LOCAL I
64857    FOR I=1 TO LEN(Text$):Intin%(I-1)= ASC( MID$(Text$,I)): NEXT
64858    VDI (116,Ctrl%(12),Intin%(I-1),Ptsin%(0,0),Intout%(4),Ptsout%(0,0))
64859    RETURN
64860 '
64861 DEF PROC Vqt_Width(Intin%(0),R Intout%(0),R Ptsout%(0,0),R Ptsout%(0,1),R Ptsout%(0,2))
64862    VDI (117,Ctrl%(12),Intin%(1),Ptsin%(0,0),Intout%(1),Ptsout%(0,3))
64863    RETURN
64864 '
64865 DEF PROC Vq_Cellarray(Ptsin%(0,0),Ptsin%(1,0),Ptsin%(0,1),Ptsin%(1,1),Ctrl%(7),Ctrl%(8),R X,R Y,R I)
64866    X=Ctrl%(7)*Ctrl%(8)
64867    VDI (27,Ctrl%(11),Intin%(0),Ptsin%(0,2),Intout%(X),Ptsout%(0,0))
64868    X=Ctrl%(9):Y=Ctrl%(10):I=Ctrl%(11)
64869    RETURN
64870 '
64871 DEF PROC Vrt_Cpyfm(X,Y,Intin%(0),Intin%(1),Intin%(2),Ptsin%(0,0),Ptsin%(1,0),Ptsin%(0,1),Ptsin%(1,1),Ptsin%(0,2),Ptsin%(1,2),Ptsin%(0,3),Ptsin%(1,3))
64872    Ctrl%(7)= HIGH(X):Ctrl%(8)= LOW(X):Ctrl%(9)= HIGH(Y):Ctrl%(10)= LOW(Y)
64873    VDI (121,Ctrl%(12),Intin%(3),Ptsin%(0,4),Intout%(0),Ptsout%(0,0))
64874    RETURN
64875 '
64876 IF TIMER THEN DEF PROC V_Show_C(Intin%(0)) ELSE DEF PROC V_Show_C:Intin%(0)=0
64877    VDI (122,Ctrl%(12),Intin%(1),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
64878    RETURN
64879 '
64880 DEF PROC V_Hide_C
64881    VDI (123,Ctrl%(12),Intin%(0),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
64882    RETURN
64883 '
64884 DEF PROC Vq_Mouse(R Intout%(0),R Ptsout%(0,0),R Ptsout%(1,0))
64885    VDI (124,Ctrl%(12),Intin%(0),Ptsin%(0,0),Intout%(1),Ptsout%(0,1))
64886    RETURN
64887 '
64888 DEF PROC Vex_Butv(R X)
64889    Ctrl%(7)= HIGH(X):Ctrl%(8)= LOW(X)
64890    VDI (125,Ctrl%(12),Intin%(0),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
64891    X=Ctrl%(9) SHL 16 OR Ctrl%(10)
64892    RETURN
64893 '
64894 DEF PROC Vex_Motv(R X)
64895    Ctrl%(7)= HIGH(X):Ctrl%(8)= LOW(X)
64896    VDI (126,Ctrl%(12),Intin%(0),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
64897    X=Ctrl%(9) SHL 16 OR Ctrl%(10)
64898    RETURN
64899 '
64900 DEF PROC Vex_Curv(R X)
64901    Ctrl%(7)= HIGH(X):Ctrl%(8)= LOW(X)
64902    VDI (127,Ctrl%(12),Intin%(0),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
64903    X=Ctrl%(9) SHL 16 OR Ctrl%(10)
64904    RETURN
64905 '
64906 DEF PROC Vq_Key_S(R Intout%(0))
64907    VDI (128,Ctrl%(12),Intin%(0),Ptsin%(0,0),Intout%(1),Ptsout%(0,0))
64908    RETURN
64909 '
64910 DEF PROC Vs_Clip(Ptsin%(0,0),Ptsin%(1,0),Ptsin%(0,1),Ptsin%(1,1))
64911    Intin%(0)=1
64912    VDI (129,Ctrl%(12),Intin%(1),Ptsin%(0,4),Intout%(0),Ptsout%(0,0))
64913    RETURN
64914 '
64915 DEF PROC Vs_Clip:Intin%(0)=0
64916    VDI (129,Ctrl%(12),Intin%(1),Ptsin%(0,4),Intout%(0),Ptsout%(0,0))
64917    RETURN
64918 '
64919 DEF PROC V_Clrwk
64920    VDI (3,Ctrl%(12),Intin%(0),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
64921    RETURN
64922 '
64923 DEF PROC V_Updwk
64924    VDI (4,Ctrl%(12),Intin%(0),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
64925    RETURN
64926 '
64927 DEF PROC Vst_Load_Fonts(R X)
64928    Intin%(0)=X'RESERVED FOR	FUTURE USE
64929    VDI (119,Ctrl%(12),Intin%(1),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
64930    X=Intout%(0)
64931    RETURN
64932 '
64933 DEF PROC Vst_Unload_Fonts(Intin%(0))
64934    VDI (120,Ctrl%(12),Intin%(1),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
64935    RETURN
64936 '
