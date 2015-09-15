********************************************************************
* Assemblerroutinen zum Aufruf der internen Routinen des Treibers: *
********************************************************************

	export GetSymbolName
	export GetSymbolValue
	export AddSymbolTable
	export RemoveSymbolTable
	export RemoveProgram

***************************************************************************
* Diese Funktion Åbergibt dem Treiber einen Symbolwert und erhÑlt dafÅr   *
* vom Treiber einen Zeiger auf den Symbolnamen sowie einen Zeiger auf die *
* Struktur, in der das Symbol gefunden wurde.                             *
***************************************************************************
    MODULE GetSymbolName
	move.l	A2,-(SP)		; A2 retten
	move.l	A1,-(SP)		; Zeiger auf Puffer fÅr Symbol-Zeiger retten
	move.l	8(A0),A0		; Zeiger auf "GetSymbolName" holen
	jsr		(A0)			; Symbolnamen ermitteln
	move.l	(SP)+,A2		; Zeiger auf Puffer fÅr Symbol-Zeiger
	move.l	A0,(A2)			; Symbol-Zeiger speichern
	move.l	8(SP),A2		; Zeiger auf Puffer fÅr Struktur-Zeiger
	move.l	A1,(A2)			; Struktur-Zeiger speichern
	move.l	(SP)+,A2		; A2 restaurieren
	rts
    ENDMOD

*******************************************************************************
* Diese Funktion ermittelt zu einem gegebenen Symbolnamen den zugehîrigen     *
* Symbolwert. Wenn ein Programmname angegeben wurde, so wird nur die ent-     *
* sprechende Struktur durchsucht, andernfalls werden alle Strukturen so lange *
* untersucht, bis entweder das Ende erreicht ist oder ein Treffer erfolgte.   *
*******************************************************************************
    MODULE GetSymbolValue
	move.l	A2,-(SP)		; A2 retten
	move.l	12(A0),A2		; Zeiger auf "GetSymbolValue" holen
	move.l	A1,A0			; Zeiger auf Symbolnamen nach A0
	move.l	8(SP),A1		; Zeiger auf Programmnamen nach A1
	jsr		(A2)			; Symbolwert ermitteln
	move.l	12(SP),A2		; Zeiger auf Puffer fÅr Symbol-Zeiger
	move.l	A0,(A2)			; Symbol-Zeiger speichern
	move.l	16(SP),A2		; Zeiger auf Puffer fÅr Struktur-Zeiger
	move.l	A1,(A2)			; Struktur-Zeiger speichern
	move.l	(SP)+,A2		; A2 restaurieren
	rts
    ENDMOD

********************************************************************************
* Diese Funktion ermîglicht das Nachladen einer Symboltabelle fÅr ein bereits  *
* im Speicher befindliches Programm. Hierzu wird der Pfadname auf das Programm *
* sowie die Adresse der Basepage des Programmes an den Treiber Åbergeben.      *
********************************************************************************
    MODULE AddSymbolTable
	move.l	A2,-(SP)		; A2 retten
	move.l	16(A0),A2		; Zeiger auf "AddSymbolTable" holen
	move.l	A1,A0			; Zeiger auf den Pfadnamen nach A0
	move.l	8(SP),A1		; Zeiger auf die Basepage nach A1
	jsr		(A2)			; Symboltabelle hinzufÅgen
	move.l	(SP)+,A2		; A2 restaurieren
	rts
    ENDMOD

******************************************************************************
* Diese Funktion entfernt eine Symboltabelle vorzeitig aus dem Speicher. Der *
* einzige öbergabeparameter muû dabei ein Zeiger auf den Programmnamen sein. *
******************************************************************************
    MODULE RemoveSymbolTable
	move.l	20(A0),A0		; Zeiger auf "RemoveSymbolTable" holen
	exg		A0,A1			; Register vertauschen
	jmp		(A1)			; Symboltabelle entfernen
    ENDMOD
