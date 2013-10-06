

		text


; ---------------------------------------------------------
; 15.01.00/vk
; fuellt einen rechteckbereich mit einer farbe (softwareroutine).
; d0 = farbwert
; d1 = x1
; d2 = y1
; d3 = x2
; d4 = y2
mvdiSoftSolidrect 

		rts


; ---------------------------------------------------------
; 16.01.00/vk
; fuellt einen rechteckbereich mit einem monochromen pattern.
; hardwareroutine auf der grafikkarte.
; d0 = x1
; d1 = y1
; d2 = x2
; d3 = y2
; d4 = fgcolor
; d5 = bgcolor
; a6 = zeiger auf patterndata (arraydaten und arraygroesse)
mvdiSoftPatternrect

		rts

