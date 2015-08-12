*********************************
*				*
*  Relocating overlay loader    *
*        modified from		*
*  Function 59 -- Program Load	*
*				*
*        March 17, 1983		*
*				*
*  Modified for GEMDOS 1/9/86 MC*
* Does not load program root.	*
* Leaves base page and stack as	*
* set up by actual BDOS 59	*
*				*
*********************************

.globl  _loadr		* this routine is public

fread	= 63		* 3f, f_read gemdos func code
fseek	= 66		* 0x42, f_seek gemdos func code
bufsize = 128		* buffer size
hdsize	= 28		* file header size

* d0 always contains the return parameter from pgmld
* d1 is the return register from local subroutines
* a0 contains the pointer to the Load Parm Block passed to pgmld

* Return parameters in d0 are:
*	00 - function successful
*	01 - insufficient memory or bad header in file
*	02 - read error on file
*	03 - bad relocation information in file


* Entry point for Program Load routine
_loadr:
	clr.l	d0		* start with return parm cleared
    	move.l  (a0), filehd	* save file handle
	move.l	LoAdr(a0),cseg	* save load addr
	move.l	bufa(a0),d1
	move.l	d1,basepg
 	bsr	gethdr		* get header
	tst	d0
	bne	lddone		* if unsuccessful, return
	bsr	setaddr		* set up load addresses
	tst	d0
	bne	lddone		* if unsuccessful, return
	bsr	rdtxt		* read code and data text segments into mem
	tst	d0
	bne	lddone		* if unsuccessful, return
	move.l	tstart,d7
	cmp.l	cseg,d7
	bne	reloc		* do relocation if necessary
lddone:
	rts

* Subroutines

readseq:
* GEMDOS f_read  function
	move.l	d0,-(sp)	* save return parm
	move.l	a3, -(sp)	* buffer address
    	move.l	#bufsize, -(sp) * buffer size
    	move.w	filehd,	-(sp)	* file handle
	move.w	#fread, -(sp)	* read function
	trap	#1		* call gemdos
     	add.l	#12, sp		* pop parameters
	move.l	d0,d1		* return parm in d1, no. of bytes read
	move.l	(sp)+,d0
	rts

gethdr:
* Get header into buffer in data segment
  	move.l	d0, -(sp)	* save d0
    	pea.l	hdr		* read into addr of hdr
    	move.l	#hdsize,-(sp)	* no. of bytes in header
    	move.w	filehd,	-(sp)	* file handle
    	move.w	#fread, -(sp)	* f_read fun code
    	trap	#1
    	add.l	#12,	sp	* pop parameters
        move.l	d0,d1		* return parm in d1
    	move.l	(sp)+, d0
	cmp.l	#hdsize, d1	* read ok?
	bne	badhdr		* if no, return bad
	rts
badhdr:	moveq	#2,d0
	rts


setaddr:
* Set up load addresses for cseg, dseg, bss, basepg, and stack
	move.w	magic,d6
	cmpi.w	#$601a,d6
	bne	badadr		* if magic nmbr <> 601a, skip
	move.l	bpsize,symsize
	move.l	cseg,d7
	add.l	csize,d7
	addq.l	#1,d7
	bclr	#0,d7
	move.l	d7,dseg
	add.l	dsize,d7
	addq.l	#1,d7
	bclr	#0,d7
	move.l	d7,bseg
* cseg, dseg, bseg set up
	rts
badadr:	moveq.l	#1,d0
	rts

rdtxt:
* Read code and data text into memory
    	move.l	d0, -(sp)	* save d0
    	move.l	cseg, -(sp)	* address of memory
    	move.l	csize, -(sp)	* if csize > 64k, needs rewrite this part
    	move.w	filehd, -(sp)	* file handle
    	move.w	#fread, -(sp)	* f_read fun code
    	trap	#1
    	add.l	#12, sp		* pop parameters
    	move.l  d0, d1		* put return code in d1
    	move.l	(sp)+, d0
    	tst.l	d1		* return code in d1
    	blt	rdbad
    	cmp.l	csize, d1	* read ok?
    	bne	rdbad
* If it is ok, then start to read data into memory
    	move.l	d0, -(sp)	* save d0
    	move.l	dseg, -(sp)	* address of memory
    	move.l	dsize, -(sp)	* if csize > 64k, needs rewrite this part
    	move.w	filehd, -(sp)	* file handle
    	move.w	#fread, -(sp)	* f_read fun code
    	trap	#1
    	add.l	#12, sp		* pop parameters
    	move.l	d0, d1
    	move.l	(sp)+, d0
    	tst.l	d1		* return code in d1
    	blt	rdbad
    	cmp.l	dsize, d1	* read ok?
    	bne	rdbad
* If it is ok, clear the bss segment
    	move.l	bseg, a2
    	move.l	bsize, d2
    	beq	fin
loop1:	clr.b	(a2)+
    	subq.l	#1, d2
    	bne	loop1
fin:	rts

rdbad:	moveq.l	#2,d0		*need to do something here
	rts


reloc:
* skip past the symbol table by f_seek func
    	move.l	symsize, d5	
    	tst.l	d5		* any symbol table?
    	beq	reloc0
    	move.l	d0, -(sp)	* save d0
    	move.w	#1, -(sp)	* smode = 1, pointer move from current pos.
    	move.w	filehd, -(sp)	* file handle
    	move.l	symsize, -(sp)	* bytes to skip
    	move.w	#fseek, -(sp)	* f_seek fun code
    	trap	#1
    	add.l	#10, sp		* pop parameters
    	move.l	d0, d1
    	move.l	(sp)+, d0
    	tst.l 	d1
    	blt	rdbad

* we got past symbol table
reloc0:
	move.l	cseg,d5
	move.l	d5,a2		* relocate cseg first
	sub.l	tstart,d5	* d5 contains the relocation offset
*
* Modify addr references of code and data segments based on GEMDOS relocation
* information format:
*    a3 points to the buffer which store the relocation info;
*    d1 keeps the byte count processed in the buffer; when d1 becomes negative
*	more relocation info was read into buffer;
*    a2 points to the address to be modified;
*    d5 keeps the difference to be added to the content pointed by a2;

    	move.l basepg, a3		* a3 points to the buffer
    	bsr	readseq			* read relocation info into buffer
    	tst.l	d1			* if reads ok?
    	blt	rdbad			* no, goto rdbad
    	subq.l	#4, d1			* d1 loop count
    	tst.l	(a3)			* if there any reloc info?
    	beq	lddone			* no, done
    	adda.l	(a3)+, a2		* the offset to the text seg
    	bra	reloc2
readrel:
    	move.l basepg, a3		* a3 points to the buffer
    	bsr	readseq			* read relocation info into buffer
    	tst.l	d1			* if reads ok?
    	blt	rdbad			* no, goto rdbad
    	subq.l	#1, d1			* d1 loop count
reloc1:
    	clr.l	d3			* d3, relocation byte from buffer
    	move.b	(a3)+, d3		* get it from buffer
    	tst.b	d3			* if it is the end of rel info?
    	beq	lddone			* done
    	cmpi.b	#1, d3			* if it = 1?
    	beq	add254			* goto add254
    	andi.l	#255, d3		* 0xff & d3
    	adda.l	d3, a2			* add the offset 
reloc2:					* modify the code
    	move.l	(a2),d6	
    	add.l	d5, d6			* d5 contains the (cseg - tstart)
    	move.l	d6, (a2)		
count:
    	dbf	d1, reloc1		* if more in buffer, goto reloc1
    	bra 	readrel			* read more reloc info into buffer
add254:
    	adda.l	#254, a2		* add 254 to a2
    	bra 	count			* goto loop counter

    	.bss
* offsets from start of parameter block
LoAdr = 2
bufa = 6

hdr:
				* load file header is read into here
magic:		.ds.w	1
csize:		.ds.l	1
dsize:		.ds.l	1
bsize:		.ds.l	1
bpsize:		.ds.l	1	* symb tbl size is swapped with base page size
stksize:	.ds.l	1
tstart:		.ds.l	1
rlbflg:		.ds.w	1
dstart:		.ds.l	1
bstart:		.ds.l	1

cseg:		.ds.l	1
dseg:		.ds.l	1
bseg:		.ds.l	1
basepg:		.ds.l	1

symsize:	.ds.l	1
loop:		.ds.w	1
filehd:		.ds.w	1
	.end
