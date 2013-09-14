
	globl	pix_dn_table,pix_0000,pix_null
	globl	pix_up_table,col_0000,col_null

pix_dn_table:

	dc.l	pix_0000,pix_0001,pix_0010,pix_0011
	dc.l	pix_0100,pix_0101,pix_0110,pix_0111
	dc.l	pix_1000,pix_1001,pix_1010,pix_1011
	dc.l	pix_1100,pix_1101,pix_1110,pix_1111


pix_up_table:

	dc.l	col_0000,col_0001,col_0010,col_0011
	dc.l	col_0100,col_0101,col_0110,col_0111
	dc.l	col_1000,col_1001,col_1010,col_1011
	dc.l	col_1100,col_1101,col_1110,col_1111



pix_null:

	add.w	#16,d1			; transparent fragment
	jmp	(a7)


pix_0000:
       
       	bclr.l	d1,d5			; plane 1
	bclr.l	d1,d6			; plane 3
	add.w	#16,d1
	bclr.l	d1,d5			; plane 0
	bclr.l	d1,d6			; plane 2

	jmp	(a7)


pix_0001:
       
       	bclr.l	d1,d5			; plane 1
	bclr.l	d1,d6			; plane 3
	add.w	#16,d1
	bset.l	d1,d5			; plane 0
	bclr.l	d1,d6			; plane 2
            
	jmp	(a7)

pix_0010:
       
       	bset.l	d1,d5			; plane 1
	bclr.l	d1,d6			; plane 3
	add.w	#16,d1
	bclr.l	d1,d5			; plane 0
	bclr.l	d1,d6			; plane 2

	jmp	(a7)


pix_0011:
       
       	bset.l	d1,d5			; plane 1
	bclr.l	d1,d6			; plane 3
	add.w	#16,d1
	bset.l	d1,d5			; plane 0
	bclr.l	d1,d6			; plane 2
            
	jmp	(a7)


pix_0100:
       
       	bclr.l	d1,d5			; plane 1
	bclr.l	d1,d6			; plane 3
	add.w	#16,d1
	bclr.l	d1,d5			; plane 0
	bset.l	d1,d6			; plane 2

	jmp	(a7)


pix_0101:
       
       	bclr.l	d1,d5			; plane 1
	bclr.l	d1,d6			; plane 3
	add.w	#16,d1
	bset.l	d1,d5			; plane 0
	bset.l	d1,d6			; plane 2
            
	jmp	(a7)

pix_0110:
       
       	bset.l	d1,d5			; plane 1
	bclr.l	d1,d6			; plane 3
	add.w	#16,d1
	bclr.l	d1,d5			; plane 0
	bset.l	d1,d6			; plane 2

	jmp	(a7)


pix_0111:
       
       	bset.l	d1,d5			; plane 1
	bclr.l	d1,d6			; plane 3
	add.w	#16,d1
	bset.l	d1,d5			; plane 0
	bset.l	d1,d6			; plane 2
            
	jmp	(a7)


pix_1000:
       
       	bclr.l	d1,d5			; plane 1
	bset.l	d1,d6			; plane 3
	add.w	#16,d1
	bclr.l	d1,d5			; plane 0
	bclr.l	d1,d6			; plane 2

	jmp	(a7)


pix_1001:
       
       	bclr.l	d1,d5			; plane 1
	bset.l	d1,d6			; plane 3
	add.w	#16,d1
	bset.l	d1,d5			; plane 0
	bclr.l	d1,d6			; plane 2
            
	jmp	(a7)

pix_1010:
       
       	bset.l	d1,d5			; plane 1
	bset.l	d1,d6			; plane 3
	add.w	#16,d1
	bclr.l	d1,d5			; plane 0
	bclr.l	d1,d6			; plane 2

	jmp	(a7)


pix_1011:
       
       	bset.l	d1,d5			; plane 1
	bset.l	d1,d6			; plane 3
	add.w	#16,d1
	bset.l	d1,d5			; plane 0
	bclr.l	d1,d6			; plane 2
            
	jmp	(a7)


pix_1100:
       
       	bclr.l	d1,d5			; plane 1
	bset.l	d1,d6			; plane 3
	add.w	#16,d1
	bclr.l	d1,d5			; plane 0
	bset.l	d1,d6			; plane 2

	jmp	(a7)


pix_1101:
       
       	bclr.l	d1,d5			; plane 1
	bset.l	d1,d6			; plane 3
	add.w	#16,d1
	bset.l	d1,d5			; plane 0
	bset.l	d1,d6			; plane 2
            
	jmp	(a7)

pix_1110:
       
       	bset.l	d1,d5			; plane 1
	bset.l	d1,d6			; plane 3
	add.w	#16,d1
	bclr.l	d1,d5			; plane 0
	bset.l	d1,d6			; plane 2

	jmp	(a7)


pix_1111:
       
       	bset.l	d1,d5			; plane 1
	bset.l	d1,d6			; plane 3
	add.w	#16,d1
	bset.l	d1,d5			; plane 0
	bset.l	d1,d6			; plane 2
            
	jmp	(a7)




col_null:

	subq.w	#1,d1			; d1 -> next dst pixel
	bge.s	c_null			; check for word fault

	moveq.l	#15,d1			; d1 -> hi bit of next longword
	move.l	d5,(a1)+		; replace old dst longword
	move.l	d6,(a1)+
	move.l	(a1),d5			; d5 <- next dst longword (p0 & p1)
	move.l	4(a1),d6		; d6 <- next dst longword (p2 & p3)

c_null:	add.w	a2,d2			; cy:1 => time for next src pixel
	bcc.s	col_null

	jmp	(a7)



col_0000:

	bclr.l	d1,d5			; plane 1
	bclr.l	d1,d6			; plane 3
	add.w	#16,d1
	bclr.l	d1,d5			; plane 0
	bclr.l	d1,d6			; plane 2

	sub.w	#17,d1			; d1 -> next dst pixel
	bge.s	c_0000			; check for word fault

	moveq.l	#15,d1			; d1 -> hi bit of next longword
	move.l	d5,(a1)+		; replace old dst longword
	move.l	d6,(a1)+
	move.l	(a1),d5			; d5 <- next dst longword (p0 & p1)
	move.l	4(a1),d6		; d6 <- next dst longword (p2 & p3)

c_0000:	add.w	a2,d2			; cy:1 => time for next src pixel
	bcc.s	col_0000

	jmp	(a7)




col_0001:

	bclr.l	d1,d5			; plane 1
	bclr.l	d1,d6			; plane 3
	add.w	#16,d1
	bset.l	d1,d5			; plane 0
	bclr.l	d1,d6			; plane 2

	sub.w	#17,d1			; d1 -> next dst pixel (lo word)
	bge.s	c_0001

	moveq.l	#15,d1			; d1 -> hi bit of next longword
	move.l	d5,(a1)+		; replace old dst longword
	move.l	d6,(a1)+
	move.l	(a1),d5			; d5 <- next dst longword (p0 & p1)
	move.l	4(a1),d6		; d6 <- next dst longword (p2 & p3)

c_0001:	add.w	a2,d2			; cy:1 => time for next src pixel
	bcc.s	col_0001

	jmp	(a7)




col_0010:
       
       	bset.l	d1,d5			; plane 1
	bclr.l	d1,d6			; plane 3
	add.w	#16,d1
	bclr.l	d1,d5			; plane 0
	bclr.l	d1,d6			; plane 2

      	sub.w  	#17,d1	  		; d1 -> next dst pixel
      	bge.s	c_0010	  		; check for word fault
                     
      	moveq.l	#15,d1			; d1 -> hi bit of next longword
      	move.l	d5,(a1)+		; replace old dst longword
      	move.l	d6,(a1)+
      	move.l	(a1),d5			; d5 <- next dst longword (p0 & p1)
      	move.l	4(a1),d6		; d6 <- next dst longword (p2 & p3)
                     
c_0010:	add.w	a2,d2			; cy:1 => time for next src pixel
       	bcc.s	col_0010
      
	jmp	(a7)
      


      
col_0011:
       
       	bset.l	d1,d5			; plane 1
	bclr.l	d1,d6			; plane 3
	add.w	#16,d1
	bset.l	d1,d5			; plane 0
	bclr.l	d1,d6			; plane 2

	sub.w	#17,d1			; d1 -> next dst pixel (lo word)
	bge.s	c_0011

	moveq.l	#15,d1			; d1 -> hi bit of next longword
	move.l	d5,(a1)+		; replace old dst longword
	move.l	d6,(a1)+
	move.l	(a1),d5			; d5 <- next dst longword (p0 & p1)
	move.l	4(a1),d6		; d6 <- next dst longword (p2 & p3)

c_0011:	add.w	a2,d2			; cy:1 => time for next src pixel
	bcc.s	col_0011

	jmp	(a7)




col_0100:

	bclr.l	d1,d5			; plane 1
	bclr.l	d1,d6			; plane 3
	add.w	#16,d1
	bclr.l	d1,d5			; plane 0
	bset.l	d1,d6			; plane 2

	sub.w	#17,d1			; d1 -> next dst pixel
	bge.s	c_0100			; check for word fault

	moveq.l	#15,d1			; d1 -> hi bit of next longword
	move.l	d5,(a1)+		; replace old dst longword
	move.l	d6,(a1)+
	move.l	(a1),d5			; d5 <- next dst longword (p0 & p1)
	move.l	4(a1),d6		; d6 <- next dst longword (p2 & p3)

c_0100:	add.w	a2,d2			; cy:1 => time for next src pixel
	bcc.s	col_0100

	jmp	(a7)




col_0101:

	bclr.l	d1,d5			; plane 1
	bclr.l	d1,d6			; plane 3
	add.w	#16,d1
	bset.l	d1,d5			; plane 0
	bset.l	d1,d6			; plane 2

	sub.w	#17,d1			; d1 -> next dst pixel (lo word)
	bge.s	c_0101

	moveq.l	#15,d1			; d1 -> hi bit of next longword
	move.l	d5,(a1)+		; replace old dst longword
	move.l	d6,(a1)+
	move.l	(a1),d5			; d5 <- next dst longword (p0 & p1)
	move.l	4(a1),d6		; d6 <- next dst longword (p2 & p3)

c_0101:	add.w	a2,d2			; cy:1 => time for next src pixel
	bcc.s	col_0101

	jmp	(a7)




col_0110:
       
       	bset.l	d1,d5			; plane 1
	bclr.l	d1,d6			; plane 3
	add.w	#16,d1
	bclr.l	d1,d5			; plane 0
	bset.l	d1,d6			; plane 2

      	sub.w  	#17,d1	  		; d1 -> next dst pixel
      	bge.s	c_0110	  		; check for word fault
                     
      	moveq.l	#15,d1			; d1 -> hi bit of next longword
      	move.l	d5,(a1)+		; replace old dst longword
      	move.l	d6,(a1)+
      	move.l	(a1),d5			; d5 <- next dst longword (p0 & p1)
      	move.l	4(a1),d6		; d6 <- next dst longword (p2 & p3)
                     
c_0110:	add.w	a2,d2			; cy:1 => time for next src pixel
       	bcc.s	col_0110
      
	jmp	(a7)
      


      
col_0111:
       
       	bset.l	d1,d5			; plane 1
	bclr.l	d1,d6			; plane 3
	add.w	#16,d1
	bset.l	d1,d5			; plane 0
	bset.l	d1,d6			; plane 2

	sub.w	#17,d1			; d1 -> next dst pixel (lo word)
	bge.s	c_0111

	moveq.l	#15,d1			; d1 -> hi bit of next longword
	move.l	d5,(a1)+		; replace old dst longword
	move.l	d6,(a1)+
	move.l	(a1),d5			; d5 <- next dst longword (p0 & p1)
	move.l	4(a1),d6		; d6 <- next dst longword (p2 & p3)

c_0111:	add.w	a2,d2			; cy:1 => time for next src pixel
	bcc.s	col_0111

	jmp	(a7)




col_1000:

	bclr.l	d1,d5			; plane 1
	bset.l	d1,d6			; plane 3
	add.w	#16,d1
	bclr.l	d1,d5			; plane 0
	bclr.l	d1,d6			; plane 2

	sub.w	#17,d1			; d1 -> next dst pixel
	bge.s	c_1000			; check for word fault

	moveq.l	#15,d1			; d1 -> hi bit of next longword
	move.l	d5,(a1)+		; replace old dst longword
	move.l	d6,(a1)+
	move.l	(a1),d5			; d5 <- next dst longword (p0 & p1)
	move.l	4(a1),d6		; d6 <- next dst longword (p2 & p3)

c_1000:	add.w	a2,d2			; cy:1 => time for next src pixel
	bcc.s	col_1000

	jmp	(a7)




col_1001:

	bclr.l	d1,d5			; plane 1
	bset.l	d1,d6			; plane 3
	add.w	#16,d1
	bset.l	d1,d5			; plane 0
	bclr.l	d1,d6			; plane 2

	sub.w	#17,d1			; d1 -> next dst pixel (lo word)
	bge.s	c_1001

	moveq.l	#15,d1			; d1 -> hi bit of next longword
	move.l	d5,(a1)+		; replace old dst longword
	move.l	d6,(a1)+
	move.l	(a1),d5			; d5 <- next dst longword (p0 & p1)
	move.l	4(a1),d6		; d6 <- next dst longword (p2 & p3)

c_1001:	add.w	a2,d2			; cy:1 => time for next src pixel
	bcc.s	col_1001

	jmp	(a7)




col_1010:
       
       	bset.l	d1,d5			; plane 1
	bset.l	d1,d6			; plane 3
	add.w	#16,d1
	bclr.l	d1,d5			; plane 0
	bclr.l	d1,d6			; plane 2

      	sub.w  	#17,d1	  		; d1 -> next dst pixel
      	bge.s	c_1010	  		; check for word fault
                     
      	moveq.l	#15,d1			; d1 -> hi bit of next longword
      	move.l	d5,(a1)+		; replace old dst longword
      	move.l	d6,(a1)+
      	move.l	(a1),d5			; d5 <- next dst longword (p0 & p1)
      	move.l	4(a1),d6		; d6 <- next dst longword (p2 & p3)
                     
c_1010:	add.w	a2,d2			; cy:1 => time for next src pixel
       	bcc.s	col_1010
      
	jmp	(a7)
      

      
col_1011:
       
       	bset.l	d1,d5			; plane 1
	bset.l	d1,d6			; plane 3
	add.w	#16,d1
	bset.l	d1,d5			; plane 0
	bclr.l	d1,d6			; plane 2

	sub.w	#17,d1			; d1 -> next dst pixel (lo word)
	bge.s	c_1011

	moveq.l	#15,d1			; d1 -> hi bit of next longword
	move.l	d5,(a1)+		; replace old dst longword
	move.l	d6,(a1)+
	move.l	(a1),d5			; d5 <- next dst longword (p0 & p1)
	move.l	4(a1),d6		; d6 <- next dst longword (p2 & p3)

c_1011:	add.w	a2,d2			; cy:1 => time for next src pixel
	bcc.s	col_1011

	jmp	(a7)




col_1100:

	bclr.l	d1,d5			; plane 1
	bset.l	d1,d6			; plane 3
	add.w	#16,d1
	bclr.l	d1,d5			; plane 0
	bset.l	d1,d6			; plane 2

	sub.w	#17,d1			; d1 -> next dst pixel
	bge.s	c_1100			; check for word fault

	moveq.l	#15,d1			; d1 -> hi bit of next longword
	move.l	d5,(a1)+		; replace old dst longword
	move.l	d6,(a1)+
	move.l	(a1),d5			; d5 <- next dst longword (p0 & p1)
	move.l	4(a1),d6		; d6 <- next dst longword (p2 & p3)

c_1100:	add.w	a2,d2			; cy:1 => time for next src pixel
	bcc.s	col_1100

	jmp	(a7)



col_1101:

	bclr.l	d1,d5			; plane 1
	bset.l	d1,d6			; plane 3
	add.w	#16,d1
	bset.l	d1,d5			; plane 0
	bset.l	d1,d6			; plane 2

	sub.w	#17,d1			; d1 -> next dst pixel (lo word)
	bge.s	c_1101

	moveq.l	#15,d1			; d1 -> hi bit of next longword
	move.l	d5,(a1)+		; replace old dst longword
	move.l	d6,(a1)+
	move.l	(a1),d5			; d5 <- next dst longword (p0 & p1)
	move.l	4(a1),d6		; d6 <- next dst longword (p2 & p3)

c_1101:	add.w	a2,d2			; cy:1 => time for next src pixel
	bcc.s	col_1101

	jmp	(a7)




col_1110:
       
       	bset.l	d1,d5			; plane 1
	bset.l	d1,d6			; plane 3
	add.w	#16,d1
	bclr.l	d1,d5			; plane 0
	bset.l	d1,d6			; plane 2

      	sub.w  	#17,d1	  		; d1 -> next dst pixel
      	bge.s	c_1110	  		; check for word fault
                     
      	moveq.l	#15,d1			; d1 -> hi bit of next longword
      	move.l	d5,(a1)+		; replace old dst longword
      	move.l	d6,(a1)+
      	move.l	(a1),d5			; d5 <- next dst longword (p0 & p1)
      	move.l	4(a1),d6		; d6 <- next dst longword (p2 & p3)
                     
c_1110:	add.w	a2,d2			; cy:1 => time for next src pixel
       	bcc.s	col_1110
      
	jmp	(a7)

      
      
col_1111:
       
       	bset.l	d1,d5			; plane 1
	bset.l	d1,d6			; plane 3
	add.w	#16,d1
	bset.l	d1,d5			; plane 0
	bset.l	d1,d6			; plane 2

	sub.w	#17,d1			; d1 -> next dst pixel (lo word)
	bge.s	c_1111

	moveq.l	#15,d1			; d1 -> hi bit of next longword
	move.l	d5,(a1)+		; replace old dst longword
	move.l	d6,(a1)+
	move.l	(a1),d5			; d5 <- next dst longword (p0 & p1)
	move.l	4(a1),d6		; d6 <- next dst longword (p2 & p3)

c_1111:	add.w	a2,d2			; cy:1 => time for next src pixel
	bcc.s	col_1111

	jmp	(a7)
