;  Beispielprogramm fÅr die
;  DSP-Host Schnittstelle
;
;  Liest ein Wort und shiftet es nach rechts
;  (Hf0 = 0) oder nach links (Hf0 = 1) und
;  sendet das Ergebnis zurÅck


; DSP IO-Adressen

PBC	equ	$ffe0
HCR equ $ffe8  ; Bit 3 und 4 sind Hf2 und Hf3
HSR	equ	$ffe9  ; Bit 3 und 4 sind Hf0 und Hf1
HTX	equ	$ffeb

      org   P:$0
      jmp   start

      org   P:$40

start movep #1,X:PBC        ; selektiere Host

      jclr  #0,X:HSR,start  ; warte auf Eingabe
      move	X:HTX,A1        ; hole DSP-Wort
      jclr  #3,X:HSR,right  ; Hf0 gesetzt ?
      lsl	A               ; shifte links
      jmp   xmit
right lsr   A               ; sonst nach rechts
xmit  jclr	#1,X:HSR,xmit   ; frei zum senden ?
      move	A1,X:HTX        ; sende Ergebnis
      jmp	start

      end
