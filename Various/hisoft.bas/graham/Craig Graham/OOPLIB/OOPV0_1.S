	opt	l+,c+

*
* Object Oriented Programming Library for HiSoft Basic.
* Version 0.1 - Only classes & attributes are available.
*
* See accompanying docs for details.
*
* This library was written using DevpacST, the HiSoft assembly language
* development system.
*
*===========================================================================

max_object_size	EQU	100	;100byte object size = 25 long ints
max_classes	EQU	20	;maximum numberof classes available
class_namesize	EQU	8	;8char class names
ct_entry	EQU	100	;100bytes per class table entry
				;<8char name><2byte blank><2byte attrib count><attrib names, 8bytes each>
ct_name		EQU	0
ct_null		EQU	8
ct_constructor	EQU	10
ct_attrib_count	EQU	14
ct_attribs	EQU	12
attrib_name_size	EQU	8	;Length of attribute names
ot_entry	EQU	10	;10bytes per object table entry
				;<2byte type><4byteaddress><6bytes unallocated>
ot_type		EQU	0
ot_address	EQU	2
os_type		EQU	0	;each object in the store has the type filled in here
os_attribs	EQU	2	;start of the attribute area of the object

* Malloc #size, variable
Malloc	macro
	move.l	\1,-(a7)
	move.w	#$48,-(a7)
	trap	#1
	addq.l	#6,a7
	move.l	d0,\2
	endm

* 8) print '<string>'
print	macro
	lea.l	x\@(pc),a0
	bsr	prnt
	bra	y\@
x\@	dc.b	\1,0
	cnop	0,2
y\@	nop
	endm

	include	library.h	the standard library include file

	library	OOP		library name

	xref	get_string	external references
	xref	get_array
	xref	make_string
	xref.l	gl_scratch	this is referenced off global!

	xdef	init_oop
	xdef	declare_objects
	xdef	class
	xdef	object
	xdef	delete_object
	xdef	o_iset
	xdef	o_iget
	xdef	flush_objects

	subdef	lng		init_oop	Initialise the OOP system
	subdef	lng		declare_objects	How many objects do we think we'll be using?
	subdef	str,str,lng	class		Define a new class
	fn_lng	str		object		Instantiate an object of a class & return a pointer to it
	subdef	lng		delete_object	Delete an object
	subdef	lng,str,lng	o_iset		Set the value of an attribute.
	fn_lng	lng,str		o_iget		Get the value of an attribute.
	subdef	lng		flush_objects	Flush the object store & retreive empty space

	option	'uv'		underlines & variable checks

	libstart		the code follows

	opt D+

*====================================================================================
* Initialise the OOP run-time system
*====================================================================================
init_oop:
	lea.l	this(pc),a0
	move.l	4(sp),(a0)	;Set the this global
	rts

*====================================================================================
* Set up the object store by allocating memory
*====================================================================================
declare_objects:
	Malloc	#ct_entry*max_classes,d2	;allocate entries in class table
	lea.l	class_table(pc),a0
	move.l	d2,(a0)
	move.l	d2,a0
	clr.l	(a0)
	lea.l	next_class(pc),a0		;initialise the next class pointer
	move.l	d2,(a0)

	cmp.l	#0,d2
	beq	declare_report_error

	move.l	4(sp),d1

	subq.l	#1,d1

	mulu	#ot_entry,d1			;allocate the object table

	lea.l	object_table_size(pc),a0	;store the max number of objects (size of object table)
	move.l	d1,(a0)

	add.l	#ot_entry,d1

	Malloc	d1,d2
	lea.l	ot_next(pc),a0			;first object goes at start of ot
	move.l	d2,(a0)
	lea.l	object_table(pc),a0		;set pointer to ot in variable area
	move.l	d2,(a0)
	move.l	d2,a0
	clr.l	(a0)				;set first ot entry = null
	
	cmp.l	#0,d2
	beq	declare_report_error

	mulu	#max_object_size,d1		;allocate object storage
	lea.l	object_store_size(pc),a0
	move.l	d1,(a0)
	Malloc	d1,d2
	lea.l	next_object(pc),a0		;first object at start of object store
	move.l	d2,(a0)
	lea.l	object_store(pc),a0
	move.l	d2,(a0)
	move.l	d2,a0
	clr.l	(a0)

	cmp.l	#0,d2
	beq	declare_report_error

	rts
declare_report_error:
	print	'OOP_error[1]-unable_to_allocate_object_storage.'
	rts

*====================================================================================
* Create a new class
*====================================================================================
class:
	move.l	12(sp),a0		;pointer to class name
	bsr	get_string		;D4 contains length of attributes string
	move.l	a1,d1

	lea.l	next_class(pc),a0
	move.l	(a0),a1			;location of next class table entry
	move.l	d1,a0
	move.w	#0,ct_null(a1)		;null entry in table

	cmp.l	#class_namesize,d4	;8char class names
	blt	cn_oksize
	move.l	#class_namesize,d4

cn_oksize:
	subq.w	#1,d4
cn_to_table_loop:			;copy class_name into class table
	move.b	(a0)+,(a1)+
	dbf	d4,cn_to_table_loop
	move.b	#0,(a1)			;zero terminate the string
;get the attributes now
	move.l	8(sp),a0		;pointer to class attributes
	bsr	get_string		;D4 contains length of attributes string
	move.l	a1,d1

	lea.l	next_class(pc),a0
	move.l	(a0),a1			;location of next class table entry

	add.l	#ct_attribs,a1
	move.l	d1,a0

	move.w	#0,d5			;d5=#attributes
copy_attribs:
	bsr	get_this_attrib

	cmp.w	#0,d4
	bne	copy_attribs

	move.b	#0,(a1)			;zero terminate the string

	lea.l	next_class(pc),a1
	move.l	d1,a0
	move.w	d5,ct_attrib_count(a0)

	move.l	4(sp),ct_constructor(a0)	;fill in default constructor field

	move.l	(a1),a0

	lea.l	next_class(pc),a1
	move.l	(a1),a0
	add.l	#ct_attribs,a0

	lea.l	next_class(pc),a1	;Update next class pointer to next slot in ct
	move.l	(a1),d1

	add.l	#ct_entry,d1
	move.l	d1,(a1)

	rts

get_this_attrib:
	addq.w	#1,d5			;increment attribute count
	move.w	#0,d0
attr_to_table:				;copy an attribute accross
	move.b	(a0)+,(a1)+
	addq.w	#1,d0			;increment number of chars in current attrib
	subq.w	#1,d4			;decrement number of chars remaining in attrib list

	cmp.w	#0,d4			;ahh. end of attributes list
	ble	attr_pad

	cmp.b	#',',(a0)		;comma seperator, begin a new attrib.
	bne	xxx_1

	add.l	#1,a0			;skip the comma
	subq.w	#1,d4			;account for comma in string length count
	bra	attr_pad		;jump to pad out

xxx_1:
	cmp.b	#attrib_name_size,d0	;got max chars - so we're clipping
	bne	gta_loop		; else continue to get more

	bra	gta_end			;got a full attrib name

attr_pad:
	cmp.b	#attrib_name_size,d0	;got max chars - so we're clipping
	beq	gta_end			;if not, pad with spaces
	move.b	#' ',(a1)+
	addq.w	#1,d0
	bra	attr_pad

gta_loop:
	bra	attr_to_table
gta_end:
	rts

*====================================================================================
* Create an object of a class
*====================================================================================
object:
	move.l	4(sp),a0		;pointer to class attributes
	bsr	get_string		;D4 contains length of attributes string

	clr.l	d0			;d2=number of characters matched

	movem.l	a3-a6,-(sp)

	move.l	a1,a4			;keep a copy of class name

	move.w	#1,d5			;class id

	lea.l	class_table(pc),a3
	move.l	(a3),a0			;a0 points to start of class table
find_class:
	cmp.l	d0,d4			;have we found the target in the ct ?
	beq	end_of_target

	move.b	(a1,d0),d1		;get char from target
	move.b	(a0,d0),d2		;get char from ct

	addq.w	#1,d0
	cmp.w	#class_namesize+1,d0	;exceeded class name field - must be this class
	beq	got_class

	cmp.b	d1,d2			;still matches so continue loop
	beq	find_class
fc_not_this_one:
	add.l	#ct_entry,a0		;next class table entry
	cmp.b	#0,(a0)			;end of table ?
	beq	class_not_found		;bum out
	addq.w	#1,d5			;next class id
	clr.w	d0
	bra	find_class

end_of_target:
	move.b	(a0,d0),d2		;end of target string. is next char in ct a 0?
	cmp.b	#0,d2			; if so then we have a match, 0 used as terminator
	bne	fc_not_this_one

got_class:
	lea.l	ot_next(pc),a0		;pointer to next free ot entry
	move.l	(a0),a1

	move.l	a1,d0

	lea.l	object_table_size(pc),a6	;get the size of the object table
	move.l	(a6),d1
	lea.l	object_table(pc),a6	;get the start of the object table
	add.l	(a6),d1			;end of ot in d1

	cmp.l	d1,a1			;is ot full? if so, we'll have to scan for a space.
	blt	rtn_scan_ot_for_space
	move.l	d1,(a0)			;flag ot_next as always being full
	bra	scan_ot_for_space

rtn_scan_ot_for_space:
	move.l	a1,d1			;calculate object store slot from
	lea.l	object_table(pc),a2	;object table slot.
	move.l	(a2),d2
	sub.l	d2,d1
	divu	#ot_entry,d1
	and.l	#$0000ffff,d1
	mulu	#max_object_size,d1
	lea.l	object_store(pc),a2
	move.l	(a2),a3
	adda.l	d1,a3

	move.w	d5,os_type(a3)		;tag object with it's type id

	move.w	d5,ot_type(a1)		;fill object type field in ot
	move.l	a3,ot_address(a1)	;fill in object address field in ot

	move.l	a1,tos			;return pointer to object table entry

	add.l	#max_object_size,a3	;update next_object
	lea.l	next_object(pc),a2	;pointer to next object
	move.l	a3,(a2)
	add.l	#ot_entry,a1		;update ot_next
	move.l	a1,(a0)

	movem.l	(sp)+,a3-a6
	rts

scan_ot_for_space:
	lea.l	object_table(pc),a6	;start scan at base of ot
	move.l	(a6),a1
scan_ot_loop:
	cmp.w	#0,ot_type(a1)		;is ot entry empty?
	beq	rtn_scan_ot_for_space

	cmp.l	a1,d1			;have we run out of ot space?
	blt	no_ot_space_left

	add.l	#ot_entry,a1		;check next slot
	bra	scan_ot_loop

no_ot_space_left:
	print	'OOP_error[2]-Object_Table_full_-_declare_more_object_space'
	move.l	#0,tos			;return 0 as error
	movem.l	(sp)+,a3-a6
	rts
	
class_not_found:
	print	'OOP_error[3]-Class_used_before_defined'
	move.l	#0,tos			;return 0 as error
	movem.l	(sp)+,a3-a6
	rts

*====================================================================================
* Declare an object of a class.
*====================================================================================
delete_object:
	move.l	4(sp),a0		;pointer to ot entry
	move.l	ot_address(a0),a1	;pointer to object store entry
	move.w	#0,ot_type(a0)		;mark object table entry as unused
	move.w	#0,os_type(a1)		;mark object as deleted (class id = 0)
	rts

*====================================================================================
* Set the value of an attribute in an object
*====================================================================================
o_iset:
	clr.l	d0
	move.l	4(sp),d7		;the long int value to set
	move.l	8(sp),a0
	bsr	get_string		;a1 points to name of attribute
	move.l	12(sp),a0		;get pointer to object
	move.w	ot_type(a0),d0		;get object type
	subq.w	#1,d0
	mulu.w	#ct_entry,d0		;offset to class table entry for this id

	lea.l	class_table(pc),a2
	add.l	(a2),d0			;class table address
	move.l	d0,a2			;pointer to class table entry

	move.l	ct_attrib_count(a2),d1	;d1=number of attributes available

	add.l	#ct_attribs,a2		;a2=pointer to start of attribute name area

	move.l	#0,d6			;d6=count of how many attribs we've looked at so far

sfind_attribute:
	move.w	#0,d2
sscan_along_attribute_name:
	move.b	(a2,d2),d3		;first char of attrib name
	move.b	(a1,d2),d5

	cmp.b	d2,d4			;have we reached end of parameter
	beq	smatched_the_param

	cmp.b	d3,d5			;names don't match
	bne	snext_name

	addq.w	#1,d2

	cmp.w	#attrib_name_size,d2
	beq	sgot_the_right_attribute

	bra	sscan_along_attribute_name

smatched_the_param:
	cmp.w	#attrib_name_size,d4
	beq	sgot_the_right_attribute

	move.b	1(a2,d2),d3
	cmp.b	#' ',d3
	beq	sgot_the_right_attribute

snext_name:
	add.l	#attrib_name_size,a2
	addq.w	#1,d6
	cmp.w	d6,d1			;have we looked at all the attribs ?
	beq	attrib_not_found

	bra	sfind_attribute

sgot_the_right_attribute:
	lsl.l	#2,d6
	move.l	ot_address(a0),a1
	move.l	d7,os_attribs(a1,d6)
	rts

*====================================================================================
* Get an attribute value from an object
*====================================================================================
o_iget:
	clr.l	d0
	move.l	4(sp),a0
	bsr	get_string		;a1 points to name of attribute
	move.l	8(sp),a0		;get pointer to object
	move.w	ot_type(a0),d0		;get object type
	subq.w	#1,d0
	mulu.w	#ct_entry,d0		;offset to class table entry for this id

	lea.l	class_table(pc),a2
	add.l	(a2),d0			;class table address
	move.l	d0,a2			;pointer to class table entry

	move.l	ct_attrib_count(a2),d1	;d1=number of attributes available

	add.l	#ct_attribs,a2		;a2=pointer to start of attribute name area

	move.l	#0,d6			;d6=count of how many attribs we've looked at so far

find_attribute:
	move.w	#0,d2
scan_along_attribute_name:
	move.b	(a2,d2),d3		;first char of attrib name
	move.b	(a1,d2),d5

	cmp.b	d2,d4			;have we reached end of parameter
	beq	matched_the_param

	cmp.b	d3,d5			;names don't match
	bne	next_name

	addq.w	#1,d2

	cmp.w	#attrib_name_size,d2
	beq	got_the_right_attribute

	bra	scan_along_attribute_name

matched_the_param:
	cmp.w	#attrib_name_size,d4
	beq	got_the_right_attribute

	move.b	1(a2,d2),d3
	cmp.b	#' ',d3
	beq	got_the_right_attribute

next_name:
	add.l	#attrib_name_size,a2
	addq.w	#1,d6
	cmp.w	d6,d1			;have we looked at all the attribs ?
	beq	attrib_not_found

	bra	find_attribute

got_the_right_attribute:
	lsl.l	#2,d6
	move.l	ot_address(a0),a1
	move.l	os_attribs(a1,d6),tos
	rts

attrib_not_found:
	print	'OOP_error[4]-attrib_not_found'
	move.l	#0,tos
	rts

*====================================================================================
* Flush object store
*====================================================================================
flush_objects:
*	clr.l	d0
*	lea.l	object_store_size(pc),a0
*	move.l	(a0),d1
*
*	lea.l	object_store(pc),a0
*	move.l	(a0),a1
*	move.l	a1,a0
*
*	cmp.l	d0,d1			;have we looked at the whole object store?
*	blt	finished_flush
*
*flush_:
*	cmp.w	#0,os_type(a0)		;have we encountered an empty slot?
*	beq	flush_skip1
*	add.w	#max_object_size,d0	;yes, so skip it and continue
*	bra	flush_skip_blanks
*
*flush_skip1:
*	move.w	#(max_object_size/4)-1,d2
*flush_loop:
*	move.l	(a0,d0),(a0)+
*	dbra	d2,flush_loop
*
*finished_flush:
	print 'flushed_the_object_store'
	move.l	#0,tos
	rts

*print a string
prnt          movem.l a0-a3/d0-d5,-(a7)
               move.l a0,-(a7)
               move.w #9,-(a7)
               trap #1
               addq.l #6,a7
               movem.l (a7)+,a0-a3/d0-d5
               rts

object_table	dc.l	0	;pointer to the object table
object_table_size:		;the size of the object table in bytes
		dc.l	0
ot_next		dc.l	0	;pointer to next free entry in object table
object_store	dc.l	0	;pointer to the start of the first object store block
object_store_size:
		dc.l	0	;the size of the object store.
next_object:			;pointer to the next free object store entry
		dc.l	0
class_temp_name	dc.l	0	
class_temp_attribs:
		dc.l	0
class_table	dc.l	0	;pointer to the class definition table
next_class	dc.l	0	;pointer to the next free entry in the class definition table

this		dc.l	0	;pointer to the location of the current object when calling a service
				;this is the location of the this& variable
	END

 