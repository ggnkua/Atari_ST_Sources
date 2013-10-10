100 LIBRARY Gem ,"gem.lib"
101 ' Application sous GEM: Impression de fichiers ASCII
102 ' OMIKRON-BASIC            LISTER.BAS
103 '
104 CLEAR 33000'   Restituer la m‚moire pour le fichier RSRC-LOAD
105 '
106 ' Constantes dans le fichier en-tˆte de ressource:
107 '
108 Commence%L=18
109 Fin%L=20
110 Format%L=23
111 Commande%L=22
112 Memoire%L=25
113 B_Commande%L=4
114 Sautp%L=1
115 Init%L=4
116 Crlf%L=3
117 Ex%L=5
118 Okk%L=6
119 Quitter%L=7
120 B_Form%L=3
121 B_Info%L=2
122 Un%L=2
123 Deux%L=3
124 F_Lignes%L=6
125 Marge%L=8
126 F_Car%L=7
127 Nomfi%L=1
128 B_Impr%L=1
129 B_Menus%L=0
130 Entete%L=2
131 Pages%L=5
132 Numlign%L=4
133 Abb%L=7
134 Ok%L=8
135 Info%L=8
136 Charger%L=17
137 '
138 DIM Lignes$(3000)'  €a devrait suffire...
139 '
140 Charge_Fich%L=0'    Initialise le drapeau
141 '
142 Tampon$= SPACE$(16)' Tampon d'‚vŠnements AES (8 mots)
143 '
144 ' Fonction d'accŠs au tampon:
145 '
146 DEF FN P%L(X%L)= CVI( MID$(Tampon$,X%L*2+1,2))
147 '
148 Appl_Init
149 V_Opnvwk
150 '
151 Charge_Parametrefich
152 '
153 Rsrc_Load("LISTER.RSC",Back%L)'  Charge fichier .RSC
154 IF Back%L=0 THEN
155   FORM_ALERT (1,"[3][Pas de fichier RSC!][Quitter]")
156   Appl_Exit
157   END
158 ENDIF
159 '
160 ' Lire les adresses des arbres objets:
161 '
162 Rsrc_Gaddr(0,B_Menus%L,Menus_Ptr%L)
163 Rsrc_Gaddr(0,B_Info%L,Info_Ptr%L)
164 Rsrc_Gaddr(0,B_Impr%L,Impr_Ptr%L)
165 Rsrc_Gaddr(0,B_Form%L,Form_Ptr%L)
166 Rsrc_Gaddr(0,B_Commande%L,Commande_Ptr%L)
167 '
168 ' Afficher la barre des menus:
169 '
170 Menu_Bar(Menus_Ptr%L)
171 '
172 Abandon%L=0
173 '
174 ' Boucle d'attente d'‚vŠnements:
175 '
176 REPEAT
177   Evnt_Mesag(Tampon$)'  Attendre un message AES
178   '
179   IF FN P%L(0)=10 THEN '   Mot 10=0  --> Option de menu cliqu‚e
180     Title%L=FN P%L(3)'       Stocke l'index du titre
181     '
182     IF FN P%L(4)=Info%L THEN Sub_Info
183     IF FN P%L(4)=Charger%L THEN Sub_Charger
184     IF FN P%L(4)=Commence%L THEN Sub_Commence
185     IF FN P%L(4)=Fin%L THEN Sub_Fin
186     IF FN P%L(4)=Commande%L THEN Sub_Commande
187     IF FN P%L(4)=Format%L THEN Sub_Format
188     IF FN P%L(4)=Memoire%L THEN Sub_Memoire
189     '
190     Menu_Tnormal(Title%L,1)'   Dessiner le titre du menu en vid‚o normale
191   ENDIF
192   '
193 UNTIL Abandon%L=1'   Retour si l'on n'a pas demand‚ de quitter
194 '
195 Rsrc_Free
196 V_Clsvwk
197 Appl_Exit
198 END
199 '
200 '
201 DEF PROC Sub_Fin
202   FORM_ALERT (1,"[2][Vraiment? Quitter le programme?][Oui|Non]",Back%L)
203   IF Back%L=1 THEN Abandon%L=1'  Lever drapeau pour programme principal
204 RETURN
205 '
206 '****************************************************************
207 '
208 DEF PROC Sub_Charger
209   Trace_On'    Permet un ON ERROR GOTO dans le compilateur...
210   '
211   ' Affichage d'une boŒte de s‚lection de fichiers:
212   '
213   Path$= STRING$(64,0)'    Faire de la place
214   Adr%L= LPEEK( VARPTR(Path$))+ LPEEK( SEGPTR +28)
215   GEMDOS (,$47, HIGH(Adr%L), LOW(Adr%L),0)'  Lire chemin du fichier
216   Path$= LEFT$(Path$, INSTR(Path$, CHR$(0))-1)' Supprimer octets nuls
217   '
218   GEMDOS (Lect_Courant%L,$19)'  indiquer le lecteur courant
219   Path$= CHR$( ASC("A")+Lect_Courant%L)+":"+Path$+"\*.*"
220   '
221   Default$=""
222   FILESELECT (Path$,Default$,Flag%L)
223   '
224   Nomfich$= LEFT$(Path$, LEN(Path$)- INSTR( MIRROR$(Path$)+"\","\"))+"\"+Default$
225   '
226   IF NOT (Flag%L=0 OR Default$="") THEN
227     ON ERROR GOTO 243'  L'EOF nous cause des problŠmes...
228     OPEN "I",1,Nomfich$'   Open for Input
229     I%L=-1
230     WHILE NOT EOF(1)
231       I%L=I%L+1
232       LINE INPUT #1,Lignes$(I%L)
233     WEND
234     Dern_Ligne%L=I%L
235     FOR I%L=Dern_Ligne%L+1 TO 3000:Lignes$(I%L)="": NEXT I%L
236     IF I%L>0 THEN Charge_Fich%L=1:Write_Text(Impr_Ptr%L,Entete%L,"")
237     CLOSE 1
238   ENDIF
239   '
240   Trace_Off'     Ne nous sert plus … rien
241 RETURN
242 '
243 I%L=I%L-1: RESUME NEXT '   Si erreur, EOF(1) est "true"
244 '
245 '
246 DEF PROC Trace_On: RETURN '    Proc‚dures leurres pour que le programme
247 DEF PROC Trace_Off: RETURN '   soit accept‚ par l'interpr‚teur
248 '
249 '
250 '****************************************************************
251 '
252 DEF PROC Sub_Commence
253   IF Charge_Fich%L=0 THEN
254     FORM_ALERT (1,"[1][Vous n'avez pas encore charg‚|de fichier!][Ah?]")
255     RETURN
256   ENDIF
257   '
258   Write_Text(Impr_Ptr%L,Nomfi%L,Nomfich$)
259   IF Parpage%L=1 THEN Select(Impr_Ptr%L,Pages%L) ELSE Deselect(Impr_Ptr%L,Pages%L)
260   IF Numeroslignes%L=1 THEN Select(Impr_Ptr%L,Numlign%L) ELSE Deselect(Impr_Ptr%L,Numlign%L)
261   Do_Dialog(Impr_Ptr%L,Entete%L,Back%L)
262   '
263   Read_Text(Impr_Ptr%L,Entete%L,Entete$)
264   '
265   IF Back%L=Ok%L THEN
266     Parpage%L=0:Numeroslignes%L=0
267     IF FN Selected%L(Impr_Ptr%L,Pages%L) THEN Parpage%L=1
268     IF FN Selected%L(Impr_Ptr%L,Numlign%L) THEN Numeroslignes%L=1
269     Impression
270   ENDIF
271   '
272 RETURN
273 '
274 '****************************************************************
275 '
276 DEF PROC Sub_Info
277   Do_Dialog(Info_Ptr%L,0,Dummy%L)
278 RETURN
279 '
280 '****************************************************************
281 '
282 DEF PROC Sub_Commande
283   USING "####"'   galement valable pour STR$(..)
284   A$=FN St_Str$(Sp1%L,Sp2%L,Sp3%L,Sp4%L)
285   Write_Text(Commande_Ptr%L,Sautp%L,A$)
286   A$=FN St_Str$(Crlf1%L,Crlf2%L,Crlf3%L,Crlf4%L)
287   Write_Text(Commande_Ptr%L,Crlf%L,A$)
288   A$=FN St_Str$(Init1%L,Init2%L,Init3%L,Init4%L)
289   Write_Text(Commande_Ptr%L,Init%L,A$)
290   A$=FN St_Str$(Ex1%L,Ex2%L,Ex3%L,Ex4%L)
291   Write_Text(Commande_Ptr%L,Ex%L,A$)
292   '
293   Do_Dialog(Commande_Ptr%L,Sautp%L,Back%L)
294   '
295   IF Back%L=Okk%L THEN
296     Read_Text(Commande_Ptr%L,Sautp%L,A$)
297     Lis(A$,Sp1%L,Sp2%L,Sp3%L,Sp4%L)
298     Read_Text(Commande_Ptr%L,Crlf%L,A$)
299     Lis(A$,Crlf1%L,Crlf2%L,Crlf3%L,Crlf4%L)
300     Read_Text(Commande_Ptr%L,Init%L,A$)
301     Lis(A$,Init1%L,Init2%L,Init3%L,Init4%L)
302     Read_Text(Commande_Ptr%L,Ex%L,A$)
303     Lis(A$,Ex1%L,Ex2%L,Ex3%L,Ex4%L)
304   ENDIF
305 RETURN
306 '
307 DEF FN St_Str$(X1%L,X2%L,X3%L,X4%L)
308   LOCAL A$:A$=""
309   IF X1%L>=0 THEN A$=A$+ RIGHT$( STR$(X1%L),3) ELSE RETURN A$
310   IF X2%L>=0 THEN A$=A$+ RIGHT$( STR$(X2%L),3) ELSE RETURN A$
311   IF X3%L>=0 THEN A$=A$+ RIGHT$( STR$(X3%L),3) ELSE RETURN A$
312   IF X4%L>=0 THEN A$=A$+ RIGHT$( STR$(X4%L),3)
313 RETURN A$
314 '
315 DEF PROC Lis(A$,R A%L,R B%L,R C%L,R D%L)
316   A%L=-1:B%L=-1:C%L=-1:D%L=-1
317   IF MID$(A$,1,3)<>"" THEN A%L= VAL( MID$(A$,1,3))
318   IF MID$(A$,4,3)<>"" THEN B%L= VAL( MID$(A$,4,3))
319   IF MID$(A$,7,3)<>"" THEN C%L= VAL( MID$(A$,7,3))
320   IF MID$(A$,10,3)<>"" THEN D%L= VAL( MID$(A$,10,3))
321 RETURN
322 '
323 '****************************************************************
324 '
325 DEF PROC Sub_Format
326   USING "####"
327   Write_Text(Form_Ptr%L,F_Lignes%L, RIGHT$( STR$(Lignes_Page%L),2))
328   Write_Text(Form_Ptr%L,F_Car%L, RIGHT$( STR$(Caract_Ligne%L),3))
329   Write_Text(Form_Ptr%L,Marge%L, RIGHT$( STR$(Largmarge%L),2))
330   '
331   Deselect(Form_Ptr%L,Un%L)'  Nombre de colonnes
332   Deselect(Form_Ptr%L,Deux%L)'  (Boutons de radio)
333   IF Colonne%L=1 THEN Select(Form_Ptr%L,Un%L) ELSE Select(Form_Ptr%L,Deux%L)
334   '
335   Do_Dialog(Form_Ptr%L,F_Lignes%L,Back%L)
336   '
337   IF FN Selected%L(Form_Ptr%L,Un%L) THEN Colonne%L=1 ELSE Colonne%L=2
338   '
339   Read_Text(Form_Ptr%L,F_Lignes%L,A$)
340   Lignes_Page%L= VAL(A$)
341   Read_Text(Form_Ptr%L,F_Car%L,A$)
342   Caract_Ligne%L= VAL(A$)
343   Read_Text(Form_Ptr%L,Marge%L,A$)
344   Largmarge%L= VAL(A$)
345 RETURN
346 '
347 '****************************************************************
348 '
349 DEF PROC Charge_Parametrefich
350   OPEN "I",1,"LISTER.PAR"
351   INPUT #1,Sp1%L,Sp2%L,Sp3%L,Sp4%L
352   INPUT #1,Crlf1%L,Crlf2%L,Crlf3%L,Crlf4%L
353   INPUT #1,Init1%L,Init2%L,Init3%L,Init4%L
354   INPUT #1,Ex1%L,Ex2%L,Ex3%L,Ex4%L
355   INPUT #1,Lignes_Page%L
356   INPUT #1,Caract_Ligne%L
357   INPUT #1,Largmarge%L
358   INPUT #1,Colonne%L
359   INPUT #1,Parpage%L
360   INPUT #1,Numeroslignes%L
361   CLOSE 1
362 RETURN
363 '
364 '
365 DEF PROC Sub_Memoire
366   OPEN "O",1,"LISTER.PAR"
367   WRITE #1,Sp1%L,Sp2%L,Sp3%L,Sp4%L
368   WRITE #1,Crlf1%L,Crlf2%L,Crlf3%L,Crlf4%L
369   WRITE #1,Init1%L,Init2%L,Init3%L,Init4%L
370   WRITE #1,Ex1%L,Ex2%L,Ex3%L,Ex4%L
371   WRITE #1,Lignes_Page%L
372   WRITE #1,Caract_Ligne%L
373   WRITE #1,Largmarge%L
374   WRITE #1,Colonne%L
375   WRITE #1,Parpage%L
376   WRITE #1,Numeroslignes%L
377   CLOSE 1
378 RETURN
379 '
380 '****************************************************************
381 '
382 DEF PROC Impression
383   WHILE 1=1'       boucle sans fin
384     BIOS (Back%L,8,0)'   Bcostat (Nr. 8):  Imprimante (0) prˆte?
385     IF Back%L<0 THEN EXIT '   Pas vraiment sans fin...
386     FORM_ALERT (1,"[3][Brancher l'imprimante|et la mettre ONLINE SVP!][Tout de suite, chef!]")
387   WEND
388   '
389   ' L'instruction suivante sert … imprimer correctement les tr‚mas
390   ' allemands sur les imprimantes compatibles EPSON. Si vous utilisez
391   ' une imprimante ATARI ou IBM, vous devez l'effacer:
392   '
393   '
394   MODE LPRINT "D"'    On imprime en allemand
395   '
396   ' Cette conversion automatique pouvant perturber le transfert
397   ' de codes de commande, nous ouvrons un canal r‚serv‚ …
398   ' l'imprimante:
399   '
400   OPEN "P",2
401   '
402   ' Envoi de la chaŒne d'initialisation:
403   '
404   PRINT #2,FN D_Code$(Init1%L,Init2%L,Init3%L,Init4%L);
405   '
406   Marge$= SPACE$(Largmarge%L)
407   Zs%L=Lignes_Page%L-4'   4 Lignes pour l'en-tˆte
408   Largeur_Act%L=Caract_Ligne%L-Marge%L
409   Largeur_Col%L=Largeur_Act%L
410   IF Colonne%L=2 THEN Largeur_Col%L=(Largeur_Act%L)\2
411   Crlf$=FN D_Code$(Crlf1%L,Crlf2%L,Crlf3%L,Crlf4%L)'  Nouvelle ligne
412   Sp$=FN D_Code$(Sp1%L,Sp2%L,Sp3%L,Sp4%L)'  Saut de page
413   '
414   FOR I%L=0 TO Dern_Ligne%L'    Boucle principale d'impression
415     '
416     IF (I%L MOD Zs%L=0) AND (Colonne%L=2) AND (I%L>0) THEN I%L=I%L+Zs%L
417     IF I%L>Dern_Ligne%L THEN EXIT
418     '
419     IF (I%L MOD (Zs%L*Colonne%L)=0) AND (Parpage%L=1) THEN ' Affiche en-tˆte
420       IF I%L>0 THEN PRINT #2,Sp$'   Saut de page … partir de la page 2
421       USING "":Np$="-"+ STR$(I%L\(Zs%L*Colonne%L)+1)+" -"
422       MODE "D"'   pour la date
423       A$= SPACE$((Largeur_Act%L- LEN(Entete$))\2- LEN(Np$))+Entete$
424       LPRINT Marge$;Np$;A$;: PRINT #2,Crlf$;
425       A$= DATE$ +", "+ TIME$ + SPACE$(Largeur_Act%L-18- LEN(Nomfich$))
426       A$=A$+Nomfich$: LPRINT Marge$;A$;: PRINT #2,Crlf$;
427       A$= STRING$(Largeur_Act%L,"-"): LPRINT Marge$;A$;: PRINT #2,Crlf$;
428       PRINT #2,Crlf$;'    Ligne vide
429     ENDIF
430     '
431     A$="": USING "#####"
432     IF Numeroslignes%L=1 THEN A$=A$+ STR$(I%L+1)+": "
433     A$=A$+Lignes$(I%L)
434     '
435     IF (Colonne%L=2) AND (Parpage%L=1) AND (I%L+Zs%L)<=Dern_Ligne%L THEN
436       IF LEN(A$)<Largeur_Col%L THEN A$=A$+ SPACE$(Largeur_Col%L- LEN(A$))
437       IF Numeroslignes%L=1 THEN A$=A$+ STR$(I%L+Zs%L+1)+": "
438       A$=A$+Lignes$(I%L+Zs%L)
439     ENDIF
440     '
441     LPRINT Marge$;A$;: PRINT #2,Crlf$;
442     '
443   NEXT I%L
444   '
445   ' Envoyer chaŒne de sortie:
446   '
447   PRINT #2,FN D_Code$(Ex1%L,Ex2%L,Ex3%L,Ex4%L);
448   '
449   CLOSE 2'     Fermer canal imprimante
450 RETURN
451 '
452 '
453 DEF FN D_Code$(A%L,B%L,C%L,D%L)
454   LOCAL A$
455   IF A%L>=0 THEN A$= CHR$(A%L) ELSE RETURN ""
456   IF B%L>=0 THEN A$=A$+ CHR$(B%L) ELSE RETURN A$
457   IF C%L>=0 THEN A$=A$+ CHR$(C%L) ELSE RETURN A$
458   IF D%L>=0 THEN A$=A$+ CHR$(D%L)
459 RETURN A$
460 '
461 '****************************************************************
462 '
463 DEF PROC Select(Arbre%L,Index%L)
464   WPOKE Arbre%L+24*Index%L+10, WPEEK(Arbre%L+24*Index%L+10) OR 1
465 RETURN
466 '
467 DEF PROC Deselect(Arbre%L,Index%L)
468   WPOKE Arbre%L+24*Index%L+10, WPEEK(Arbre%L+24*Index%L+10) AND -2
469 RETURN
470 '
471 DEF FN Selected%L(Arbre%L,Index%L)= WPEEK(Arbre%L+24*Index%L+10) AND 1
472 '
473 DEF PROC Write_Text(Arbre%L,Index%L,Text$)
474   LOCAL Adr%L,I%L,A$
475   Adr%L= LPEEK( LPEEK(Arbre%L+24*Index%L+12))
476   A$=Text$+ CHR$(0)
477   FOR I%L=1 TO LEN(A$)
478     POKE Adr%L+I%L-1, ASC( MID$(A$,I%L,1))
479   NEXT I%L
480 RETURN
481 '
482 DEF PROC Read_Text(Arbre%L,Index%L,R Text$)
483   LOCAL Adr%L,I%L,A$
484   Adr%L= LPEEK( LPEEK(Arbre%L+24*Index%L+12))
485   Text$="":I%L=0
486   WHILE PEEK(Adr%L+I%L)<>0
487     Text$=Text$+ CHR$( PEEK(Adr%L+I%L))
488     I%L=I%L+1
489   WEND
490 RETURN
491 '
492 DEF PROC Do_Dialog(Arbre%L,Start_Ed%L,R Ex_Button%L)
493   LOCAL X%L,Y%L,W%L,H%L
494   Form_Center(Arbre%L,X%L,Y%L,W%L,H%L)
495   Form_Dial(0,X%L,Y%L,W%L,H%L)
496   Form_Dial(1,X%L,Y%L,W%L,H%L)
497   Objc_Draw(0,12,X%L,Y%L,W%L,H%L,Arbre%L)
498   Form_Do(Start_Ed%L,Arbre%L,Ex_Button%L)
499   Deselect(Arbre%L,Ex_Button%L)
500   Form_Dial(2,X%L,Y%L,W%L,H%L)
501   Form_Dial(3,X%L,Y%L,W%L,H%L)
502 RETURN
