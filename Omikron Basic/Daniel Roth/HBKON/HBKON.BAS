0 ' HBKON
1 ' Umwandlung der .H-Dateien von Resource-Konstruktionsprogrammen
2 ' in Omikron-Basic-Blîcke
3 '
4 ' von Daniel Roth, (pd) 1988 sinccom software
5 ' BrÅcker Mauspfad 448
6 ' D-5000 Kîln 91
7 '
8 ON ERROR GOTO Fehler
9 Anfang
10 Dialog_Erzeugen
11 Dialog_Bearbeiten
12 Appl_Exit
13 END
14
15 DEF PROC Anfang
16  MOUSEOFF
17  Appl_Init
18  Vs_Clip(0,0,639,399):Vst_Color(1):Vswr_Mode(1)
19  LINE COLOR =1: DRAW 0,18 TO 639,18
20  V_Gtext(184,14,".H --> .OMK Konvertierungsprogramm")
21  MOUSEON
22  Mit%L=1
23  Pfadh$="\*.H":Pfado$="\*.OMK":Dateiname$=""
24 RETURN
25
26 DEF PROC Dialog_Erzeugen
27  LOCAL Text$,I%L
28  ' Indizes der Knîpfe
29  K_Mit%L=7
30  K_Ohne%L=9
31  K_Start%L=11
32  K_Ende%L=12
33  Dialog_Adr%L= MEMORY(5000)
34  DIM Text_Adr%L(10)
35  FOR I%L=0 TO 10
36   READ Text$
37   Text_Adr%L(I%L)= MEMORY(Text$)
38  NEXT I%L
39  Dx%L=120:Dy%L=60:Db%L=400:Dh%L=300
40  Obj_Add(Dialog_Adr%L,0,-1,1,12,20,0,0,65536+4496,Dx%L,Dy%L,Db%L,Dh%L)
41   Obj_Add(Dialog_Adr%L,1,2,-1,-1,28,0,0,Text_Adr%L(0),20,20,0,0)
42   Obj_Add(Dialog_Adr%L,2,3,-1,-1,28,0,0,Text_Adr%L(1),20,40,0,0)
43   Obj_Add(Dialog_Adr%L,3,4,-1,-1,28,0,0,Text_Adr%L(2),20,70,0,0)
44   Obj_Add(Dialog_Adr%L,4,5,-1,-1,28,0,0,Text_Adr%L(3),20,86,0,0)
45   Obj_Add(Dialog_Adr%L,5,6,-1,-1,28,0,0,Text_Adr%L(4),20,102,0,0)
46   Obj_Add(Dialog_Adr%L,6,11,7,10,25,0,0,0,20,120,370,16)
47    Obj_Add(Dialog_Adr%L,7,8,-1,-1,26,17,1,Text_Adr%L(5),0,0,40,16)
48    Obj_Add(Dialog_Adr%L,8,9,-1,-1,28,0,0,Text_Adr%L(6),45,8,0,0)
49    Obj_Add(Dialog_Adr%L,9,10,-1,-1,26,17,0,Text_Adr%L(7),80,0,40,16)
50    Obj_Add(Dialog_Adr%L,10,6,-1,-1,28,0,0,Text_Adr%L(8),125,8,0,0)
51   Obj_Add(Dialog_Adr%L,11,12,-1,-1,26,7,0,Text_Adr%L(9),60,200,60,16)
52   Obj_Add(Dialog_Adr%L,12,0,-1,-1,26,37,0,Text_Adr%L(10),130,200,60,16)
53  Rsrc_Saddr(1,0,Dialog_Adr%L)
54  DATA "von Daniel Roth, (pd) 1988  sinccom software"
55  DATA "    BrÅcker Mauspfad 448, D-5000 Kîln 91"
56  DATA "Dieses Programm konvertiert die .H-Dateien"
57  DATA "der gÑngigsten Resource-Konstruktionsprogramme"
58  DATA "in Omikron-Basic Dateien."
59  DATA "Mit","oder","ohne","öbernahme der Kommentarzeilen?"
60  DATA "Start!","Ende"
61 RETURN
62
63 DEF PROC Dialog_Bearbeiten
64  Form_Dial(0,Dx%L,Dy%L,Db%L,Dh%L)
65  Form_Dial(1,Dx%L,Dy%L,Db%L,Dh%L)
66  Objc_Draw(0,8,0,0,640,400,Dialog_Adr%L)
67  REPEAT
68   Form_Do(0,Dialog_Adr%L,Knopf%L)
69   Objc_Change(Knopf%L,0,Dialog_Adr%L)
70   Objc_State(K_Mit%L,Mit%L,Dialog_Adr%L)
71   IF Knopf%L=K_Start%L THEN
72    Vs_Clip(0,0,639,399):Vswr_Mode(1)
73    MOUSEOFF :V_Gtext(184,14,"    Bestimmen Sie die .H-Datei    "): MOUSEON
74    REPEAT
75     Taste%L=2
76     FILESELECT (Pfadh$,Dateiname$,Ok%L)
77     Objc_Draw(0,8,0,0,640,400,Dialog_Adr%L)
78     IF Ok%L THEN
79      Kmplth$=FN Pfadplusname$(Pfadh$,Dateiname$)
80      OPEN "I",1,Kmplth$
81      IF Fehler_Aufgetreten%L AND ERR =53 THEN
82       FORM_ALERT (1,"[1][Die Datei wurde|nicht gefunden][Nochmal|Abbruch]",Taste%L)
83       Fehler_Aufgetreten%L=0
84      ELSE
85       CLOSE
86       Vs_Clip(0,0,639,399):Vswr_Mode(1)
87       MOUSEOFF :V_Gtext(184,14,"   Bestimmen Sie die .OMK-Datei   "): MOUSEON
88       IF INSTR(Dateiname$,".H")=0 THEN
89        Dateiname$=Dateiname$+".H"
90       ELSE
91        Dateiname$= LEFT$(Dateiname$, INSTR(Dateiname$,"."))+"OMK"
92       ENDIF
93       FILESELECT (Pfado$,Dateiname$,Ok%L)
94       Objc_Draw(0,8,0,0,640,400,Dialog_Adr%L)
95       IF Ok%L THEN
96        Kmplto$=FN Pfadplusname$(Pfado$,Dateiname$)
97        FILL COLOR =0: PBOX 0,0,640,16
98        Graf_Mouse(2)
99        Vs_Clip(0,0,639,399):Vswr_Mode(1)
100        OPEN "I",1,Kmplth$
101        OPEN "O",2,Kmplto$
102        PRINT #2,"0 DEF PROC Rsc_init"
103        Zeile%L=1
104        WHILE NOT EOF(1)
105         LINE INPUT #1,Zeileh$
106         IF LEN(Zeileh$)<>0 THEN
107          MOUSEOFF :V_Gtext(0,14, LEFT$(Zeileh$+ SPACE$(80),80)): MOUSEON
108          Pos1%L= INSTR(Zeileh$,"#define")
109          Zeileo$= RIGHT$( STR$(Zeile%L), LEN( STR$(Zeile%L))-1)+" "
110          IF Pos1%L<>0 THEN
111           Zeileh$= RIGHT$(Zeileh$, LEN(Zeileh$)-7-Pos1%L)
112           Zeileo$=Zeileo$+ LEFT$(Zeileh$, INSTR(Zeileh$," ")-1)+"="
113           WHILE MID$(Zeileh$,Pos1%L,1)<>" " LET Pos1%L=Pos1%L+1 WEND
114           WHILE MID$(Zeileh$,Pos1%L,1)=" " LET Pos1%L=Pos1%L+1 WEND
115           Pos2%L=Pos1%L
116           WHILE ASC( MID$(Zeileh$+" ",Pos2%L,1))>47 AND ASC( MID$(Zeileh$+" ",Pos2%L,1))<58
117            Pos2%L=Pos2%L+1
118           WEND
119           Zeileo$=Zeileo$+ MID$(Zeileh$,Pos1%L,Pos2%L-Pos1%L)
120           IF Mit%L=1 THEN
121            Zeileh$= RIGHT$(Zeileh$, LEN(Zeileh$)-Pos2%L+1)
122           ENDIF
123          ENDIF
124          IF Mit%L=1 THEN
125           Pos1%L= INSTR(Zeileh$,"/*")
126           Pos2%L= INSTR(Zeileh$,"*/")
127           IF Pos1%L<>0 THEN
128            Zeileo$=Zeileo$+"'"+ MID$(Zeileh$,Pos1%L+2,Pos2%L-Pos1%L-2)
129           ENDIF
130          ENDIF
131          PRINT #2,Zeileo$
132          Zeile%L=Zeile%L+1
133         ENDIF
134        WEND
135        PRINT #2, RIGHT$( STR$(Zeile%L), LEN( STR$(Zeile%L))-1)+" RETURN"
136        CLOSE
137        Graf_Mouse(0)
138       ENDIF
139      ENDIF
140     ENDIF
141    UNTIL Taste%L=2
142    FILL COLOR =0: PBOX 0,0,640,16
143    Vs_Clip(0,0,639,399):Vswr_Mode(1)
144    MOUSEOFF :V_Gtext(184,14,".H --> .OMK Konvertierungsprogramm"): MOUSEON
145   ENDIF
146  UNTIL Knopf%L=K_Ende%L
147  Form_Dial(2,Dx%L,Dy%L,Db%L,Dh%L)
148  Form_Dial(3,Dx%L,Dy%L,Db%L,Dh%L)
149 RETURN
150
151 ' erzeugt aus Pfad- und Dateiname den kompletten Dateinamen
152 DEF FN Pfadplusname$(Pfad$,Name$)
153  LOCAL Kmplt$
154  Kmplt$= LEFT$(Pfad$, LEN(Pfad$)- INSTR( MIRROR$(Pfad$),"\")+1)+Name$+ CHR$(0)
155 RETURN (Kmplt$)
156
157 DEF PROC Obj_Add(Adr%L,Index%L,Ob_Next%,Ob_Head%,Ob_Tail%,Ob_Type%,Ob_Flags%,Ob_State%,Ob_Spec%L,Ob_X%,Ob_Y%,Ob_Width%,Ob_Height%)
158  Adr%L=Adr%L+Index%L*24
159  WPOKE Adr%L,Ob_Next%
160  WPOKE Adr%L+2,Ob_Head%
161  WPOKE Adr%L+4,Ob_Tail%
162  WPOKE Adr%L+6,Ob_Type%
163  WPOKE Adr%L+8,Ob_Flags%
164  WPOKE Adr%L+10,Ob_State%
165  LPOKE Adr%L+12,Ob_Spec%L
166  WPOKE Adr%L+16,Ob_X%
167  WPOKE Adr%L+18,Ob_Y%
168  WPOKE Adr%L+20,Ob_Width%
169  WPOKE Adr%L+22,Ob_Height%
170 RETURN
171
172 DEF PROC Objc_State(Index%L,R Status%L,Adresse%L)
173  Status%L= WPEEK(Adresse%L+24*Index%L+10)
174 RETURN
175 END
176-Fehler
177 Fehler_Aufgetreten%L=1
178 RESUME NEXT
179 '
180 END 'GEM Library fÅr OMIKRON-BASIC. Version 2.0. Auszug 01.03.88
181 'Copyright (C) Artur Sîdler, Pforzheim & Thomas Kemp, Birkenfeld
182 '
183 DEF PROC Appl_Init: LOCAL X%L,Y%L,W%L,H%L: DIM Ctrl%(12),Intin%(128),Addrout%L(1)
184    DIM Intout%(128),Ptsin%(1,128),Ptsout%(1,6),Addrin%L(3),Global%(15)
185    Wi_Pok1%L=$64:Wi_Pok2%L=$6C:Wi_Pok3%L=$7C:Wi_Pok4%L=Wi_Pok2%L+8
186    Mn_Selected%L=10:Wm_Redraw%L=20:Wm_Topped%L=21:Wm_Closed%L=22:Wm_Fulled%L=23:Wm_Arrowed%L=24
187    Wm_Hslid%L=25:Wm_Vslid%L=26:Wm_Sized%L=27:Wm_Moved%L=28:Wm_Newtop%L=29:Ac_Open%L=40
188    Ac_Close%L=41:Mu_Keybd%L=1:Mu_Button%L=2:Mu_M1%L=4:Mu_M2%L=8:Mu_Mesag%L=16:Mu_Timer%L=32
189    Appl_Exit:Graf_Handle(Ctrl%(6)): PRINT CHR$(27);"f";:Graf_Mouse(0):V_Show_C(0)
190    Wind_Get(0,4,X%L,Y%L,W%L,H%L):Form_Dial(0,X%L,Y%L,W%L,H%L):Form_Dial(3,X%L,Y%L,W%L,H%L)
191    RETURN
192 '
193 DEF PROC Appl_Exit: LOCAL I%L
194    FOR I%L=1 TO 10
195       Wind_Delete(I%L)
196    NEXT I%L
197    Form_Dial(3,0,0,1,1):V_Clsvwk:Rsrc_Free
198    Wind_Update(0):Wind_Update(2):Menu_Bar
199    Graf_Handle(Ctrl%(6)):V_Hide_C: CLIP : RETURN
200 '
201 DEF PROC Menu_Bar
202    Intin%(0)=0:Addrin%L(0)=Menu_Bar%L
203    IF FN Wind_Chek%L(30,8) THEN
204       LPOKE Wi_Pok4%L, LPEEK(Wi_Pok4%L) XOR 1 SHL 30
205       AES (30,Global%(15),Intin%(1),Addrin%L(1),Intout%(1),Addrout%L(0))
206    ENDIF Menu_Bar%L=0: RETURN
207 '
208 DEF PROC Objc_Draw(Intin%(0),Intin%(1),Intin%(2),Intin%(3),Intin%(4),Intin%(5),Addrin%L(0))
209    AES (42,Global%(15),Intin%(6),Addrin%L(1),Intout%(1),Addrout%L(0))
210    RETURN
211 '
212 DEF PROC Objc_Change(Intin%(0),Intin%(6),Addrin%L(0))
213    Intin%(1)=0:Intin%(7)=0
214    AES (47,Global%(15),Intin%(8),Addrin%L(1),Intout%(1),Addrout%L(0))
215    RETURN
216 '
217 DEF PROC Form_Do(Intin%(0),Addrin%L(0),R Intout%(0))
218    AES (50,Global%(15),Intin%(1),Addrin%L(1),Intout%(1),Addrout%L(0))
219    RETURN
220 '
221 DEF PROC Form_Dial(X%L,Intin%(5),Intin%(6),Intin%(7),Intin%(8))
222    IF X%L=0 THEN IF FN Wind_Chek%L(29,0) THEN RETURN ELSE LPOKE Wi_Pok2%L, LPEEK(Wi_Pok2%L) OR 1 SHL 29
223    IF X%L=3 THEN IF FN Wind_Chek%L(29,0) THEN LPOKE Wi_Pok2%L, LPEEK(Wi_Pok2%L) XOR 1 SHL 29 ELSE RETURN
224    Intin%(1)=Intin%(5)+Intin%(7) SHR 1:Intin%(3)=1:Intin%(0)=X%L
225    Intin%(2)=Intin%(6)+Intin%(8) SHR 1:Intin%(4)=1
226    AES (51,Global%(15),Intin%(9),Addrin%L(0),Intout%(1),Addrout%L(0))
227    RETURN
228 '
229 DEF PROC Graf_Handle(R Intout%(0))
230    AES (77,Global%(15),Intin%(0),Addrin%L(0),Intout%(5),Addrout%L(0))
231    RETURN
232 '
233 DEF PROC Graf_Mouse(Intin%(0))
234    AES (78,Global%(15),Intin%(1),Addrin%L(1),Intout%(1),Addrout%L(0))
235    RETURN
236 '
237 DEF FN Wind_Chek%L(W%L,H%L)
238    IF LPEEK(Wi_Pok3%L) THEN LPOKE Wi_Pok2%L,0: LPOKE Wi_Pok4%L,0: LPOKE Wi_Pok3%L,0: LPOKE Wi_Pok1%L,0
239    IF W%L<1 THEN RETURN 0
240    RETURN BIT(W%L, LPEEK(Wi_Pok2%L+H%L))
241 '
242 DEF PROC Wind_Close(W%L)
243    IF FN Wind_Chek%L(W%L,8) THEN
244       LPOKE Wi_Pok4%L, LPEEK(Wi_Pok4%L) XOR 1 SHL W%L:Intin%(0)=W%L
245       AES (102,Global%(15),Intin%(1),Addrin%L(0),Intout%(1),Addrout%L(0))
246    ENDIF RETURN
247 '
248 DEF PROC Wind_Delete(W%L):Wind_Close(W%L)
249    IF FN Wind_Chek%L(W%L,0) THEN
250       LPOKE Wi_Pok2%L, LPEEK(Wi_Pok2%L) XOR 1 SHL W%L:Intin%(0)=W%L
251       AES (103,Global%(15),Intin%(1),Addrin%L(0),Intout%(1),Addrout%L(0))
252    ENDIF RETURN
253 '
254 DEF PROC Wind_Get(Intin%(0),Intin%(1),R Intout%(1),R Intout%(2),R Intout%(3),R Intout%(4))
255    IF FN Wind_Chek%L(Intin%(0),0)=0 AND Intin%(0) THEN RETURN
256    AES (104,Global%(15),Intin%(2),Addrin%L(0),Intout%(5),Addrout%L(0))
257    RETURN
258 '
259 DEF PROC Wind_Update(X%L):Intin%(0)=X%L
260    IF X%L=0 THEN IF FN Wind_Chek%L(30,0)=0 THEN RETURN ELSE LPOKE Wi_Pok2%L, LPEEK(Wi_Pok2%L) XOR 1 SHL 30
261    IF X%L=1 THEN IF FN Wind_Chek%L(30,0) THEN RETURN ELSE LPOKE Wi_Pok2%L, LPEEK(Wi_Pok2%L) XOR 1 SHL 30
262    IF X%L=2 THEN IF FN Wind_Chek%L(31,0)=0 THEN RETURN ELSE LPOKE Wi_Pok2%L, LPEEK(Wi_Pok2%L) XOR 1 SHL 31
263    IF X%L=3 THEN IF FN Wind_Chek%L(31,0) THEN RETURN ELSE LPOKE Wi_Pok2%L, LPEEK(Wi_Pok2%L) XOR 1 SHL 31
264    AES (107,Global%(15),Intin%(1),Addrin%L(0),Intout%(1),Addrout%L(0))
265    RETURN
266 '
267 DEF PROC Rsrc_Free
268    IF LPEEK(Wi_Pok3%L) THEN LPOKE Wi_Pok2%L,0: LPOKE Wi_Pok4%L,0: LPOKE Wi_Pok3%L,0: LPOKE Wi_Pok1%L,0
269    IF LPEEK(Wi_Pok1%L) THEN
270       Global%(5)= WPEEK(Wi_Pok1%L):Global%(6)= LOW( LPEEK(Wi_Pok1%L)): LPOKE Wi_Pok1%L,0
271       AES (111,Global%(15),Intin%(0),Addrin%L(0),Intout%(1),Addrout%L(0))
272    ENDIF RETURN
273 '
274 DEF PROC Rsrc_Saddr(Intin%(0),Intin%(1),Addrin%L(0))
275    AES (113,Global%(15),Intin%(2),Addrin%L(1),Intout%(1),Addrout%L(0))
276    RETURN
277 '
278 'VDI
279 '
280 DEF PROC V_Gtext(Ptsin%(0,0),Ptsin%(1,0),Text$): LOCAL I%L
281    FOR I%L=0 TO LEN(Text$)-1:Intin%(I%L)= ASC( MID$(Text$,I%L+1,1)): NEXT
282    VDI (8,Ctrl%(12),Intin%(I%L),Ptsin%(0,1),Intout%(0),Ptsout%(0,0))
283    RETURN
284 '
285 DEF PROC Vst_Color(Intin%(0))
286    VDI (22,Ctrl%(12),Intin%(1),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
287    RETURN
288 '
289 DEF PROC Vswr_Mode(Intin%(0))
290    VDI (32,Ctrl%(12),Intin%(1),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
291    RETURN
292 '
293 DEF PROC V_Clsvwk
294    VDI (101,Ctrl%(12),Intin%(0),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
295    RETURN
296 '
297 DEF PROC V_Show_C(Intin%(0))
298    VDI (122,Ctrl%(12),Intin%(1),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
299    RETURN
300 '
301 DEF PROC V_Hide_C
302    VDI (123,Ctrl%(12),Intin%(0),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
303    RETURN
304 '
305 DEF PROC Vs_Clip(Ptsin%(0,0),Ptsin%(1,0),Ptsin%(0,1),Ptsin%(1,1))
306    Intin%(0)=1
307    VDI (129,Ctrl%(12),Intin%(1),Ptsin%(0,4),Intout%(0),Ptsout%(0,0))
308    RETURN
309 '
