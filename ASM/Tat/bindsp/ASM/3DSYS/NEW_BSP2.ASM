; BSPTREE.ASM
; BSP Tree-Walker for TDF demo
;  Ace self-entrant algorithm nicked from Foley + Van Dam
;  DSP code ideas from an old chat with Percy/Light
; Started 2/5/95
; New version to handle BSP between objects... 12/95

;---------------------------------------------------------
;
;
;	Walk_BSP_Tree
;
;
;---------------------------------------------------------
	;--------------
BSP_rts	macro
	move y:(r6)+,r0			;return address
	nop
	jmp (r0)
	endm
	;--------------
BSP_gosub macro addressto,addressret
	;tst a
	;jmi \addressret
	move #\addressret,r0
	move r0,y:-(r6)
	jmp \addressto
	endm
	;--------------
BSP_DisplayObject macro
	move #>1000,b
	add a,b
	move b1,x:(r3)+
	endm
	;--------------

Walk_BSP_Tree:
	move #BSP_stack,r6
	move #-1,m6			;set up stack
	clr a
	move #BSP_normals_buffer,r4

	move x:file_address,r0
	move r0,x0
	move #C_BSP,n0
	move #BSP_sorted_buffer,r3
	move y:(r0+n0),a		;get starting polygon
	tst a
	jeq  No_BSP_Tree
	add x0,a
	move a1,r1
	nop
	move (r1)+			;ignore number of polys
	move y:(r1)+,a

	BSP_gosub BSP_displayTree,BSP_ret5
BSP_ret5:
No_BSP_Tree:
	move #-1,a			;-1 as end flag
	move a1,x:(r3)+
	rts

;--------------------------------------------
; Call with: a = polygon number

BSP_displayTree:
	tst a
	jge _its_a_polygon
	BSP_DisplayObject
	BSP_rts

_its_a_polygon:
	move a1,n4
	asl a				;Look up in bsp table
	move a,n1			;2 entries per polygon
	nop
	lua (r1)+n1,r0			;r0 = address of in,out
	nop
	move r0,r2

_ok1:	move y:(r4+n4),b		;look up visibility (ie normals)
	tst b
	jpl BSP_root_not_visible
	;jmi BSP_root_not_visible

;if viewer in front of root (i.e. root is visible)

;BSP_displayTree(backchild)
;displayPolygon(root)
;BSP_displayTree(frontchild)
	move a,y:-(r6)
	move r2,y:-(r6)
	move (r2)+
	move y:(r2)+,a

	  BSP_gosub BSP_displayTree,BSP_ret1
BSP_ret1:
	move y:(r6)+,r2
	move y:(r6)+,a
	  ;BSP_DisplayObject		;CHANGE
	move y:(r2)+,a
	  BSP_gosub BSP_displayTree,BSP_ret2
BSP_ret2:
	jmp BSP_root_was_visible

;BSP_displayTree(frontchild)
;displayPolygon(root)
;BSP_displayTree(backchild)

BSP_root_not_visible:
	move a,y:-(r6)
	move r2,y:-(r6)
	move y:(r2)+,a
	  BSP_gosub BSP_displayTree,BSP_ret3
BSP_ret3:
	move y:(r6)+,r2
	move y:(r6)+,a
	  ;BSP_DisplayPolygon
	  ;BSP_DisplayObject		;CHANGE
	move (r2)+
	move y:(r2)+,a
	  BSP_gosub BSP_displayTree,BSP_ret4
BSP_ret4:

BSP_root_was_visible:
BSP_tree_empty:
	  BSP_rts

;--------------------------------------------
; In pseudocode:
	;if tree not empty
	  ;if viewer in front of root (i.e. root is visible)
	    ;BSP_displayTree(backchild)
	    ;displayPolygon(root)
	    ;BSP_displayTree(frontchild)
	  ;else
	    ;BSP_displayTree(frontchild)
	    ;displayPolygon(root)
	    ;BSP_displayTree(backchild)
	  ;end
	;end

rotate_BSP_normals:
	move x:file_address,r0
	move #>C_BSP,n0
	move r0,x0
	move y:(r0+n0),a	;r6 start of BSP tree
	add x0,a
	move a1,r6
	move #-1,m2
	move y:(r6)+,a		;number of polygons
	move (r6)+		;ignore start poly
	move a1,n6		;n6 number of points
	asl a
	move r6,x0
	add x0,a
	move a1,r6		;r6 now start of BSP polygon normals
	move r6,r5
	move r6,r4
	move #matrix,r2
	move #BSP_normals_buffer+0,r0
	;-------------------
	do n6,_spin
	  	   move	x:(r2)+,x0 y:(r4)+,y0
	  mpy y0,x0,a	x:(r2)+,x0 y:(r4)+,y0
	  mac y0,x0,a	x:(r2)+,x0 y:(r4)+,y0
	  macr y0,x0,a
	  move #matrix,r2
	  move a1,y:(r0)+
_spin:
	;-------------------
	move #-1,m1
	move #-1,m2
	rts


