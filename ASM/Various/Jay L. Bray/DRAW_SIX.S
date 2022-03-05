		 
Draw_Six:
	 moveq.l	#0,d0
	 moveq.l	#0,d3
	 move.l		(a7)+,d6
	 move.l		(a7)+,a4    ; String
	 move.w		(a7)+,B_Col ; Background Color
	 move.w		(a7)+,T_Col ; Text Color
	 move.w		(a7)+,d1    ; Y - Offset
	 move.w		(a7)+,Y_Pos ; y
	 move			Y_Pos,d0
	 mulu	 		#6,d0
	 add.w		d1,d0
	 move.w		d0,Y_Pos
	 move.w		(a7)+,d0	; x
	 mulu	 		#6,d0
	 addq.w		#1,d0
	 move.w		d0,X_Pos
	 move.w		(a7)+,d5
	 move.l		d6,-(a7)
	 dc.w	 		$a000
	 move.l		a0,a5
	 movea.l	(a1),a2       ; a2 holds first fontheader address
	 move.l		76(a2),84(a5) ; move font data address into line A
	 move.w		80(a2),88(a5) ; move font width value
	 move.w		52(a2),80(a5)
	 move.w		82(a2),82(a5)
	 move.w		#1,102(a5)
	 move.w		#1,68(a5)     ; set text for enlargment
	 move.w		#$8000,64(a5) ; must be set for a textblt ?
	 move.w		d5,36(a5)     ; Set WRITE MODE if flag = 0
	 move.b		(a4)+,d3      ; Length Of String...
	 subq.b		#2,d3
doit:
	 move.w		X_Pos,76(a5)  ; select screen x-loc
	 move.w		Y_Pos,78(a5)  ; select screen y-loc
	 move.w		T_Col,106(a5) ; Text Color
	 move.w		B_Col,114(a5) ; Background Color
	 clr.l		d2
	 move.b		(a4)+,d2
;	 cmp.b		#48,d2        ; >= '0'
;	 bcs.b		Not_Num
;	 cmp.b		#57,d2        ; <= '9'
;	 bhi.b		Not_Num
;	 sub.b		#32,d2
;Not_Num:
	 mulu	 		#6,d2
	 move.w		d2,72(a5)
	 dc.w	 		$a008			; Do a textblt operation
	 addq.w		#6,X_Pos
	 dbra	 		d3,doit
done:
	 rts
