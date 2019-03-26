
* Open the “path” file... 
	move.w	#0,-(sp)	; Open for Read 
	PEA	path	; Address of file path
	move.w	#61,-(sp)	; GEMDOS Function 61 ($3D) - open file
	TRAP	#1
	add.l	#8,sp	; Tidy up the stack
	tst.w	D0	; Open successful?
	BMI	error	; No... Branch to error routine 
	move.w	D0,handle	; File opened, store its handle	
* Read the file...
	PEA	data	; Address for 16 bytes storage area
	move.l	#16,-(sp)	; 16 bytes to read
	move.w	handle,-(sp)	; GEMDOS handle of file to read from
	move.w	#63,-(sp)	; GEMDOS Function 63 ($3F) - read file
	TRAP	#1
	add.l	#12,sp	; Tide the stack
	tst.w	D0	; Read successful?
	BMI	error	; No.. Branch to error routine 
	  :
	 code...
	  :
	RTS

handle	dc.w	0
data	ds.b	16
path	dc.b	"a:\mydata.dat",0
