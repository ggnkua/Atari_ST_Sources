;
; Dictionary routines from CheckUp Version 2.1
; by Keith Baines
; Assemble with Devpac 2.2 or later

; Checkup 1.00 29 April 1990
; 7 February 1991:  DCBs corrected for GenST 2.2
; 12 May 1991: Edited for new file formats and capital checking
; July 1992: Changed for TOS 2 compatability
; December 1994: Routines extracted and adapted for Ictari

endbit = 6
continuebit = 7

apostrophe = 2
a_code = 13
s_code = 32

	OPT	A+,O+

	OUTPUT  DICTNRYS.TOS


	;------------;
	; File names ;
	;------------;

	SECTION DATA
quick_dict	DC.B	"INDEX.DC2",0
main_dict	DC.B	"MAIN.DC2",0
	SECTION TEXT


	INCLUDE TOSCALLS.S
	INCLUDE FILEMACS.S

print	MACRO	text
	SECTION DATA
print\@	DC.B	\1,0
	SECTION TEXT
	PEA	print\@
	call_gemdos	9,6
	ENDM
	
crlf	MACRO
	MOVE.W	#13,-(A7)
	call_gemdos	2,4
	MOVE.W	#10,-(A7)
	call_gemdos	2,4
	ENDM

	********************
	* Code Starts Here *
	********************

	start_up	A0,mystack		Set stack & release memory

	BSR	banner		Announce program name etc.

	BSR	load_quick		Load the dictionary index
	TST.W	D0
	BEQ	no_index

	open	main_dict		Open main dictionary file
	TST.L	D0		OK ?
	BLT.W	no_main
	MOVE.W	D0,handle		Save file handle


main_loop	BSR	get_word		Get next word
	TST.W	D0		No word?
	BEQ.W	finished

	BSR	test_word		Check word
	TST.W	D0		OK ?
	BNE.W	found_ok
	print	<" Word not found",10,13,8>
	crlf
	BRA.S	main_loop

found_ok	print	<" ok",10,13>
	crlf
	BRA.S	main_loop

finished	close	handle		close main dictionary

exit	call_gemdos	0,2		and quit

no_index	print	<"Couldn't load index!">
	crlf
	BRA.S	exit

no_main	print	<"Couldn't open main dictionary!">
	crlf
	BRA.S	exit


	;---------------------------------------;
	; Check word has correct capitalisation ;
	;---------------------------------------;

check_caps	MOVE.B	dict_caps,D0
	CMP.B	#$60,D0
	BEQ.S	.ok
	
	MOVE.B	word_caps,D0
	CMP.B	#$60,D0
	BEQ.S	.bad
	
	CMP.B	dict_caps,D0
	BLT.S	.bad
.ok	MOVE.W	#-1,D0
	RTS
	
.bad	CLR.W	D0
	RTS


	;------------------------------------;
	; Check spelling of word in test_buf ;
	;------------------------------------;

test_word	BSR.S	search_index	In index ?
	MOVE.W	D1,index_ptr
	MOVE.B	D0,in_index
	BEQ.S	tw_skip
	
	BSR.S	check_caps
	TST.W	D0
	BEQ.S	tw_skip

	RTS			... Yes return TRUE

tw_skip	TST.B	in_index		In index but wrong case?
	BNE.S	.skip2

	MOVE.W	index_ptr,D0	Get index pointer back
	BSR	search_main		Search in main dictionary
	TST.W	D0		Found ?
	BEQ.S	.skip2		... No
	
	BSR.S	check_caps
	TST.W	D0
	BEQ.S	.skip2
	
	MOVE.W	#-1,D0		Return TRUE

.skip2	RTS


	
	;----------------------------------------;
	; Search for word in index               ;
	; If word is found:-                     ;
	;  D0.W=-1 and D1.W=index entry of word  ;
	; If word is not found:-                 ;
	;  D0.W=0 and D1.W=index entry for start ;
	;                  of main dictionary    ;
	;                  search                ;
	;                 =-1 if word is before  ;
	;                     first entry        ;
	;----------------------------------------;

search_index
	MOVE.L	i_start,A4		pointer to index
	MOVE.L	q_start,A5		pointer to common words
	CLR.L	D5		lower limit to search
	MOVE.L	i_length,D7		upper limit to search
	SUBQ.L	#2,D7
	
	CLR.L	D0
	MOVE.W	(A4,D5.L),D0	check first in index
	LEA	3(A5,D0.L),A1
	BSR	compare
	TST.B	D0
	BLT.S	.less
	BGT.S	.skip
	MOVE.W	D5,D1
	BRA.S	word_found

.less	MOVE.W	#-1,D1		Word before first in index
	BRA.S	word_not_found
	
.skip	CLR.L	D0
	MOVE.W	(A4,D7.L),D0	check last in index
	LEA	3(A5,D0.L),A1
	BSR	compare
	TST.B	D0
	BLT.S	find_loop		word is before last in index
	BGT.S	.more		word is after last in index
	MOVE.W	D7,D1		index position	
	BRA.S	word_found		search successful
	
.more	MOVE.W	D7,D1		return index position
	BRA.S	word_not_found	search failed
	
find_loop	MOVE.W	D7,D0		search by binary chop
	SUB.W	D5,D0
	CMP.W	#4,D0		have limits met ?
	BGE.S	.skip		... No - continue
	
	MOVE.W	D5,D1		... Yes - return index posn
	BRA.S	word_not_found	search failed
	
.skip	MOVE.W	D5,D6		next entry to test
	ADD.W	D7,D6
	ASR.W	#2,D6		middle = (top+bottom)/2
	ASL.W	#1,D6		and round down to be even
	
	CLR.L	D0
	MOVE.W	(A4,D6.L),D0	check new middle
	LEA	3(A5,D0.L),A1
	BSR	compare
	TST.B	D0
	BLT.S	.less
	BGT.S	.more
	
	MOVE.W	D6,D1		found - save position
	BRA.S	word_found		search succeeded

.less	MOVE.W	D6,D7		in lower half
	BRA.S	find_loop		new top = old middle

.more	MOVE.W	D6,D5		in upper half
	BRA.S	find_loop		new bottom = old middle


word_found	MOVE.W	(A4,D1.W),D0	get caps flags
	MOVE.B	(A5,D0.W),D0
	AND.B	#$60,D0
	MOVE.B	D0,dict_caps
	MOVE.W	#$FFFF,D0		return TRUE
	RTS

word_not_found
	CLR.W	D0		return FALSE
	RTS



	;------------------------------------;
	; Search for word in main dictionary ;
	; starting at index entry D0         ;
	; returns D0.W = $FFFF if found      ;
	; or D0.W = 0 if not found           ;
	;------------------------------------;

search_main	MOVE.W	D0,D7		Save index entry
	BSR.S	load_main		Read from file
	TST.W	main_buf_length	Data loaded ?
	BEQ.S	sm_not_found	... No - not found
	MOVE.W	D7,D0		Restore index

				; Initialise dictnry buffer
				; with index word
	MOVE.L	i_start,A0		pointer to index
	MOVE.L	q_start,A1		pointer to common words
	CLR.L	D1
	MOVE.W	(A0,D0.W),D1	entry required
	LEA	3(A1,D1.L),A0	data address
	LEA	dict_buf,A1		dictnry buffer address
	BSR	str_copy		copy into buffer

sm_loop	BSR	next_word		Get next word
	LEA	dict_buf,A1
	BSR	compare		Check word
	TST.B	D0
	BGT.S	sm_loop		before test word - continue
	BEQ.S	sm_found		after test word - not found

sm_not_found
	CLR.W	D0		return FALSE
	RTS

sm_found	MOVE.B	#$60,D0		mask to isolate caps flags
	AND.B	D0,dict_caps
	MOVE.W	#$FFFF,D0		return TRUE
	RTS



	;---------------------------------;
	; Load main dictionary buffer for ;
	; index entry D0                  ;
	;---------------------------------;

load_main	MOVE.L	D7,-(A7)		save D7
	CMP.W	#-1,D0		valid index ?
	BEQ.S	bad_buf		... no - quit

	CLR.W	main_buf_ptr	clear pointer

	MOVE.L	i_start,A0		get file position
	MOVE.L	q_start,A1
	CLR.L	D1
	MOVE.W	(A0,D0.W),D1
	CLR.W	D7		get 24 bit number
	MOVE.B	(A1,D1.L),D7	in separate bytes since
	ASL.L	#8,D7		may be at odd address
	MOVE.B	1(A1,D1.L),D7
	ASL.L	#8,D7
	MOVE.B	2(A1,D1.L),D7
	AND.L	#$1FFFFF,D7		mask off extra bits
	
	CLR.W	-(A7)		set file position
	MOVE.W	handle,-(A7)
	MOVE.L	D7,-(A7)
	call_gemdos	$42,10
	CMP.L	D0,D7		set OK ?
	BNE.S	bad_buf		... no
	
	f_read	handle,#main_dict_buf,#257	Read data
	TST.L	D0			Read OK ?
	BLT.S	bad_buf			... No
	
	SUBQ.L	#1,D0		allow for EOF marker

	MOVE.W	D0,main_buf_length	Save length read
	MOVE.L	(A7)+,D7		(256 except for last record)
	RTS
	
bad_buf	CLR.W	main_buf_length	Not read - length = 0
	MOVE.L	(A7)+,D7
	RTS	
	

	;--------------------------------------;
	; Get next word into dictionary buffer ;
	;--------------------------------------;


next_word	MOVE.W	main_buf_length,D2	end of record ?
	MOVE.W	main_buf_ptr,D0
	CMP.W	D2,D0
	BGE.S	end_of_buffer	... Yes
	
	LEA	main_dict_buf,A0	pointer to record
	LEA	dict_buf,A1		pointer to buffer
	MOVE.B	(A0,D0.W),D1	repeat letter count & flags
	MOVE.B	D1,dict_caps	save for caps flags
	AND.W	#$1F,D1		get repeat value
	BEQ.S	next_word1	
	LEA	(A1,D1.W),A1	clear previous end marker
	AND.B	#$3F,-1(A1)		*** changed for bit 6
	
next_word1	ADDQ.W	#1,D0		Next byte
	CMP.W	D2,D0		end of record ?
	BGE.S	end_of_buffer	... Yes
next_word2	MOVE.B	(A0,D0.W),D1	Get byte
	BCLR	#continuebit,D1
	BNE.S	use_ending3

	MOVE.B	D1,(A1)+		Copy to buffer
	BTST	#endbit,D1		End of word ?
	BEQ.S	next_word1		... No - loop again
	
	ADDQ.W	#1,D0		Pointer to next word
	MOVE.W	D0,main_buf_ptr	and save record position
	RTS

use_ending3	ADDQ.W	#1,D0
	MOVE.W	D0,main_buf_ptr	save ptr to next record

	AND.W	#$FF,D1
	ASL.W	#1,D1
	LEA	ends_index,A0
	MOVE.W	(A0,D1.W),D1
	LEA	(A0,D1.W),A0
	BRA.S	str_copy


end_of_buffer
	MOVE.B	#$7F,dict_buf	"word" > any real word
	MOVE.W	D0,main_buf_ptr	update pointer
	RTS

		


	
	;-----------------------------;
	; Copy string with end marker ;
	; from A0 to A1               ;
	; expand word endings         ;
	;-----------------------------;

str_copy	MOVE.B	(A0)+,D0
	BCLR	#continuebit,D0
	BNE.S	use_ending2

str_copy2	MOVE.B	D0,(A1)+
	BTST	#endbit,D0
	BEQ.S	str_copy
	RTS


use_ending2	AND.W	#$FF,D0
	ASL.W	#1,D0
	LEA	ends_index,A0
	MOVE.W	(A0,D0.W),D0
	LEA	(A0,D0.W),A0
	BRA.S	str_copy








	;--------------------------------------------------------;
	; Compare word in test_buf with word at A1               ;
	; Returns D0.B = 0 if equal                              ;
	; Returns D0.B = -1 if test_buf alphabetically before A1 ;
	; Returns D0.B = 1 if text_buf alphabetically after A1   ;
	;--------------------------------------------------------;

compare	LEA	test_buf,A0

compare1	MOVE.B	(A0)+,D0
compare2	MOVE.B	(A1)+,D1

	BCLR	#continuebit,D1
	BNE.S	use_ending

	BCLR	#endbit,D0
	BNE.S	end_0

	BCLR	#endbit,D1
	BNE.S	end_1
	CMP.B	D1,D0
	BEQ.S	compare1
	BLT.S	comp_in_order

comp_reverse
	MOVE.B	#1,D0		A0 after A1
	RTS

use_ending	AND.W	#$FF,D1
	ASL.W	#1,D1
	LEA	ends_index,A1
	MOVE.W	(A1,D1.W),D1
	LEA	(A1,D1.W),A1
	BRA.S	compare2
	

end_0	BCLR	#endbit,D1
	BNE.S	end_both
	CMP.B	D1,D0
	BGT.S	comp_reverse

comp_in_order
	MOVE.B	#-1,D0		A0 before A1
	RTS
	
end_1	CMP.B	D1,D0
	BLT.S	comp_in_order
	BRA.S	comp_reverse

end_both	CMP.B	D1,D0
	BGT.S	comp_reverse
	BLT.S	comp_in_order

same	CLR.B	D0		A0 same as A1
	RTS
		
	




	;----------------------------------------------;
	;  Read a word from the keyboard and encode it ;
	;  If word input, returns with D0.L>0 and      ;
	;  encoded word in test_buf                    ;
	;  If no word (i.e. null) returns with D0.L=0  ;
	;----------------------------------------------;

get_word	print	<" Next word:">	read user input
	LEA	input_buffer,A0
	MOVE.B	#80,(A0)
	MOVE.B	#0,1(A0)
	MOVE.L	A0,-(A7)
	call_gemdos	10,6
	crlf

	LEA	input_buffer+2,A0	Start of input
	CLR.L	D7
	MOVE.B	-1(A0),D7		Length of input
	
	CLR.L	D0		Pointer to next character
	

	LEA	test_buf,A5		Buffer for current word
	CLR.W	D5		position in buffer
	
	LEA	tran_tab,A4		Character translation table
	LEA	caps_tab,A3		Capitals table

	CLR.W	D1		Make sure top byte = 0

get_next	CMP.L	D7,D0		End of buffer ?
	BGE.W	no_word

	MOVE.B	(A0,D0.L),D1
	
gn_skip2	ADDQ.L	#1,D0		Advance pointer
	MOVE.B	(A3,D1.W),D3	... get caps flag ...
	MOVE.B	(A4,D1.W),D1	... get char code
	CMP.W	#a_code,D1		Only alphas start words
	BLT.S	get_next		Not one so back to start

	SUBQ.L	#1,D0
	MOVE.L	D0,word_start	Save start of word
	MOVE.B	D3,word_caps	save 1st letter caps
	CLR.B	caps2		initialise all letter caps
	ADDQ.L	#1,D0
	
				; Loop while in word
.loop	MOVE.B	D1,(A5,D5.W)	Add character to buffer
	ADDQ.W	#1,D5		Increment pointer
	CMP.W	#40,D5		Buffer full ?
	BGE.S	got_word
		
	CMP.L	D7,D0		End of buffer ?
	BGE.S	got_word		Yes - so end of word

	MOVE.B	(A0,D0.L),D1	Next Character

	MOVE.B	(A3,D1.W),D3	... get caps flag ...
	MOVE.B	(A4,D1.W),D1	Is character alpha-num
	BEQ.S	got_word		No - end of word
	OR.B	D3,caps2		next letter caps
	ADDQ.L	#1,D0		Advance pointer
	BRA.S	.loop

got_word	TST.W	D5		Word completed - empty ?
	BEQ.S	no_word		Yes - return FALSE
	
	CMP.W	#1,D5		length > 1 ?
	BLE.S	.skip2

	CMP.B	#apostrophe,-1(A5,D5.W)	Check for ' endings
	BNE.S	.skip1
	SUBQ.W	#1,D5		... and remove

	BRA.S	got_word
	
.skip1	CMP.W	#2,D5		length > 2
	BLE.S	.skip2
	
	CMP.B	#s_code,-1(A5,D5.W)	Check for 'S endings
	BNE.S	.skip2
	CMP.B	#apostrophe,-2(A5,D5.W)
	BNE.S	.skip2
	SUBQ.W	#2,D5		... and remove
	BRA.S	got_word

.skip2	BSET	#endbit,-1(A5,D5)	set bit 7 to mark word end

	MOVE.B	word_caps,D3	combine caps bits
	SUBQ.B	#1,D3
	ASL.B	#2,D3
	OR.B	caps2,D3
	AND.W	#$FF,D3
	LEA	capscodes,A3
	MOVE.B	(A3,D3.W),word_caps
	
	RTS			(D0 = position after word)


no_word	CLR.L	D0		return 0
	RTS






	;------------------------------;
	; create buffer and load index ;
	; and common words.            ;
	;------------------------------;

load_quick	open	quick_dict		Open File
	TST.L	D0
	BLT.W	not_found

	MOVE.W	D0,handle

	CLR.W	i_length
	f_read	D0,#i_length+2,#2	Read index length
	CMP.L	#2,D0
	BNE.W	not_loaded
	
	MOVE.L	i_length,D0		Allocate index buffer
	BSR	get_mem
	TST.L	D0
	BEQ.W	not_loaded
	MOVE.L	D0,i_start
	
	f_read	handle,i_start,i_length		Read index
	CMP.L	i_length,D0
	BNE.S	not_loaded

	f_read	handle,#q_length,#4	Read string length
	CMP.L	#4,D0
	BNE.S	not_loaded
	
	MOVE.L	q_length,D0		Allocate string buffer
	BSR.S	get_mem
	TST.L	D0
	BEQ.S	not_loaded
	MOVE.L	D0,q_start

	f_read	handle,q_start,q_length		Read strings
	CMP.L	q_length,D0
	BNE.S	not_loaded
	
	close	handle		Close file and ...
	MOVE.W	#-1,D0		report OK
	RTS

not_loaded	close	handle		Close file and ...
not_found	CLR.W	D0		report failure
	RTS
	
	


	;------------------------------------;
	; Allocate memory. Call with D0=size ;
	; Returns D0=address or 0 if failed  ;
	;------------------------------------;

get_mem	ADDQ.L	#3,D0		force to even
	AND.L	#$FFFFFFFE,D0
	MOVE.L	D0,-(A7)
	call_gemdos	$48,6
	ADDQ.L	#1,D0
	AND.L	#$FFFFFFFE,D0	force even
	RTS


banner	print	<" Dictionary Demonstration Program",10,13>
	print	<" by Keith Baines, December 1994",10,13>
	print	<" for Ictari User Group",10,13>
	print	<" based on routines originally used",10,13>
	print	<" in CheckUp version 2.00",10,10,13>
	RTS


	SECTION DATA

	;-----------------------------;
	; Character translation table ;
	; for word-matching           ;
	;-----------------------------;

	EVEN
tran_tab	DCB.B	32,0
	DC.B	0,0,0,0,0,0,0,2		  !"#$%&'
	DCB.B	8,0			 ()*+,-./
	DC.B	3,4,5,6,7,8,9,10		 01234567
	DC.B	11,12,0,0,0,0,0,0		 89:;<=>?
	DC.B	0,13,14,15,16,17,18,19		 @ABCDEFG
	DC.B	20,21,22,23,24,25,27,28 	 HIJKLMNO
	DC.B	29,30,31,32,33,34,35,36 	 PQRSTUVW
	DC.B	37,38,39,0,0,0,0,0		 XYZ[\]^_
	DC.B	0,13,14,15,16,17,18,19		 `abcdefg
	DC.B	20,21,22,23,24,25,27,28 	 hijklmno
	DC.B	29,30,31,32,33,34,35,36 	 pqrstuvw
	DC.B	37,38,39,0,0,0,0,0		 xyz{|}~
	DC.B	15,34,17,13,13,13,13,15 	 ÄÅÇÉÑÖÜá
	DC.B	17,17,17,21,21,21,13,13 	 àâäãåçéè
	DC.B	17,0,0,28,28,28,34,34 		*** êëíìîïñó
	DC.B	38,28,34,0,0,0,0,0		 òôöõúùûü
	DC.B	13,21,28,34,27,27,13,28 	 †°¢£§•¶ß
	DCB.B	8,0
	DC.B	13,28,28,28,0,0,13,13 		*** ∞±≤≥¥µ∂∑
	DC.B	28,0,0,0,0,0,0,0		 ∏
	DC.B	0,0,0,0,0,0,0,0		*** ¿¡
	DCB.B	56,0

	EVEN


caps_tab
	DCB.B	32,0
	DCB.B	8,0		; !"#$%&'
	DCB.B	8,0		;()*+,-./
	DCB.B	8,0		;01234567
	DCB.B	8,0		;89:;<=>?
	DC.B	0,2,2,2,2,2,2,2	;@ABCDEFG
	DCB.B	8,2		;HIJKLMNO
	DCB.B	8,2		;PQRSTUVW
	DC.B	2,2,2,0,0,0,0,0	;XYZ[\]^_
	DC.B	0,1,1,1,1,1,1,1	;`abcdefg
	DCB.B	8,1		;hijklmno
	DCB.B	8,1		;pqrstuvw
	DC.B	1,1,1,0,0,0,0,0	;xyz{|}~
	DC.B	2,1,1,1,1,1,1,1	;ÄÅÇÉÑÖÜá
	DC.B	1,1,1,1,1,1,2,2	;àâäãåçéè
	DC.B	2,1,2,1,1,1,1,1	;êëíìîïñó
	DC.B	1,2,2,0,0,0,1,0	;òôöõúùûü
	DC.B	1,1,1,1,1,2,1,1	;†°¢£§•¶ß
	DCB.B	8,0
	DC.B	1,1,2,1,1,2,2,2	;∞±≤≥¥µ∂∑
	DC.B	2,0,0,0,0,0,0,0	;∏
	DC.B	1,2,0,0,0,0,0,0	;¿¡
	DCB.B	56,0

	EVEN

capscodes	DC.B	0,0,96,96,32,32,64,96
	
	;--------------------;
	; Word endings table ;
	;--------------------;

ends_index
	DC.W	EndStr0-ends_index
	DC.W	EndStr1-ends_index
	DC.W	EndStr2-ends_index
	DC.W	EndStr3-ends_index
	DC.W	EndStr4-ends_index
	DC.W	EndStr5-ends_index
	DC.W	EndStr6-ends_index
	DC.W	EndStr7-ends_index
	DC.W	EndStr8-ends_index
	DC.W	EndStr9-ends_index
	DC.W	EndStr10-ends_index
	DC.W	EndStr11-ends_index
	DC.W	EndStr12-ends_index
	DC.W	EndStr13-ends_index
	DC.W	EndStr14-ends_index
	DC.W	EndStr15-ends_index
	DC.W	EndStr16-ends_index
	DC.W	EndStr17-ends_index
	DC.W	EndStr18-ends_index
	DC.W	EndStr19-ends_index
	DC.W	EndStr20-ends_index
	DC.W	EndStr21-ends_index
	DC.W	EndStr22-ends_index
	DC.W	EndStr23-ends_index
	DC.W	EndStr24-ends_index
	DC.W	EndStr25-ends_index
	DC.W	EndStr26-ends_index
	DC.W	EndStr27-ends_index
	DC.W	EndStr28-ends_index
	DC.W	EndStr29-ends_index
	DC.W	EndStr30-ends_index
	DC.W	EndStr31-ends_index
	DC.W	EndStr32-ends_index
	DC.W	EndStr33-ends_index
	DC.W	EndStr34-ends_index
	DC.W	EndStr35-ends_index
	DC.W	EndStr36-ends_index
	DC.W	EndStr37-ends_index
	DC.W	EndStr38-ends_index
	DC.W	EndStr39-ends_index
	DC.W	EndStr40-ends_index
	DC.W	EndStr41-ends_index
	DC.W	EndStr42-ends_index
	DC.W	EndStr43-ends_index
	DC.W	EndStr44-ends_index
	DC.W	EndStr45-ends_index
	DC.W	EndStr46-ends_index
	DC.W	EndStr47-ends_index
	DC.W	EndStr48-ends_index
	DC.W	EndStr49-ends_index
	DC.W	EndStr50-ends_index
	DC.W	EndStr51-ends_index
	DC.W	EndStr52-ends_index
	DC.W	EndStr53-ends_index
	DC.W	EndStr54-ends_index
	DC.W	EndStr55-ends_index
	DC.W	EndStr56-ends_index
	DC.W	EndStr57-ends_index
	DC.W	EndStr58-ends_index
	DC.W	EndStr59-ends_index
	DC.W	EndStr60-ends_index
	DC.W	EndStr61-ends_index
	DC.W	EndStr62-ends_index
	DC.W	EndStr63-ends_index
	DC.W	EndStr64-ends_index
	DC.W	EndStr65-ends_index
	DC.W	EndStr66-ends_index
	DC.W	EndStr67-ends_index
	DC.W	EndStr68-ends_index
	DC.W	EndStr69-ends_index
	DC.W	EndStr70-ends_index
	DC.W	EndStr71-ends_index
	DC.W	EndStr72-ends_index
	DC.W	EndStr73-ends_index
	DC.W	EndStr74-ends_index
	DC.W	EndStr75-ends_index
	DC.W	EndStr76-ends_index
	DC.W	EndStr77-ends_index
	DC.W	EndStr78-ends_index
	DC.W	EndStr79-ends_index
	DC.W	EndStr80-ends_index
	DC.W	EndStr81-ends_index
	DC.W	EndStr82-ends_index
	DC.W	EndStr83-ends_index
	DC.W	EndStr84-ends_index
	DC.W	EndStr85-ends_index
	DC.W	EndStr86-ends_index
	DC.W	EndStr87-ends_index
	DC.W	EndStr88-ends_index
	DC.W	EndStr89-ends_index
	DC.W	EndStr90-ends_index
	DC.W	EndStr91-ends_index
	DC.W	EndStr92-ends_index
	DC.W	EndStr93-ends_index
	DC.W	EndStr94-ends_index
	DC.W	EndStr95-ends_index
	DC.W	EndStr96-ends_index
	DC.W	EndStr97-ends_index
	DC.W	EndStr98-ends_index
	DC.W	EndStr99-ends_index
	DC.W	EndStr100-ends_index
	DC.W	EndStr101-ends_index
	DC.W	EndStr102-ends_index
	DC.W	EndStr103-ends_index
	DC.W	EndStr104-ends_index
	DC.W	EndStr105-ends_index
	DC.W	EndStr106-ends_index
	DC.W	EndStr107-ends_index
	DC.W	EndStr108-ends_index
	DC.W	EndStr109-ends_index
	DC.W	EndStr110-ends_index
	DC.W	EndStr111-ends_index
	DC.W	EndStr112-ends_index
	DC.W	EndStr113-ends_index
	DC.W	EndStr114-ends_index
	DC.W	EndStr115-ends_index
	DC.W	EndStr116-ends_index
	DC.W	EndStr117-ends_index
	DC.W	EndStr118-ends_index
	DC.W	EndStr119-ends_index
	DC.W	EndStr120-ends_index
	DC.W	EndStr121-ends_index
	DC.W	EndStr122-ends_index
	DC.W	EndStr123-ends_index
	DC.W	EndStr124-ends_index
	DC.W	EndStr125-ends_index
	DC.W	EndStr126-ends_index
	DC.W	EndStr127-ends_index


EndStr0	DC.B	21,77		;ia
EndStr1	DC.B	33,21,79		;tic
EndStr2	DC.B	21,79		;ic
EndStr3	DC.B	13,33,17,80 	;ated
EndStr4	DC.B	21,32,17,80 	;ised
EndStr5	DC.B	24,13,27,80 	;land
EndStr6	DC.B	13,31,80		;ard
EndStr7	DC.B	19,17,80		;ged
EndStr8	DC.B	21,17,80		;ied
EndStr9	DC.B	24,17,80		;led
EndStr10	DC.B	27,17,80		;ned
EndStr11	DC.B	29,17,80		;ped
EndStr12	DC.B	31,17,80		;red
EndStr13	DC.B	33,17,80		;ted
EndStr14	DC.B	17,80		;ed
EndStr15	DC.B	21,80		;id
EndStr16	DC.B	27,80		;nd
EndStr17	DC.B	17,31,13,33,81	;erate
EndStr18	DC.B	31,13,14,24,81	;rable
EndStr19	DC.B	33,13,14,24,81	;table
EndStr20	DC.B	34,24,13,33,81	;ulate
EndStr21	DC.B	13,14,24,81 	;able
EndStr22	DC.B	13,27,15,81 	;ance
EndStr23	DC.B	17,27,15,81 	;ence
EndStr24	DC.B	21,14,24,81 	;ible
EndStr25	DC.B	27,13,33,81 	;nate
EndStr26	DC.B	31,13,33,81 	;rate
EndStr27	DC.B	33,21,35,81 	;tive
EndStr28	DC.B	13,19,81		;age
EndStr29	DC.B	13,33,81		;ate
EndStr30	DC.B	14,24,81		;ble
EndStr31	DC.B	21,15,81		;ice
EndStr32	DC.B	21,16,81		;ide
EndStr33	DC.B	21,24,81		;ile
EndStr34	DC.B	21,27,81		;ine
EndStr35	DC.B	21,32,81		;ise
EndStr36	DC.B	27,15,81		;nce
EndStr37	DC.B	28,27,81		;one
EndStr38	DC.B	34,31,81		;ure
EndStr39	DC.B	15,81		;ce
EndStr40	DC.B	16,81		;de
EndStr41	DC.B	19,81		;ge
EndStr42	DC.B	23,81		;ke
EndStr43	DC.B	24,81		;le
EndStr44	DC.B	27,81		;ne
EndStr45	DC.B	31,81		;re
EndStr46	DC.B	32,81		;se
EndStr47	DC.B	33,81		;te
EndStr48	DC.B	35,81		;ve
EndStr49	DC.B	21,27,83		;ing
EndStr50	DC.B	27,83		;ng
EndStr51	DC.B	21,32,84		;ish
EndStr52	DC.B	15,84		;ch
EndStr53	DC.B	32,84		;sh
EndStr54	DC.B	33,84		;th
EndStr55	DC.B	28,15,87		;ock
EndStr56	DC.B	15,87		;ck
EndStr57	DC.B	28,24,28,19,21,15,13,88 ;ological
EndStr58	DC.B	21,15,13,88 	;ical
EndStr59	DC.B	18,34,88		;ful
EndStr60	DC.B	21,13,88		;ial
EndStr61	DC.B	27,13,88		;nal
EndStr62	DC.B	31,13,88		;ral
EndStr63	DC.B	13,88		;al
EndStr64	DC.B	17,88		;el
EndStr65	DC.B	21,88		;il
EndStr66	DC.B	24,88		;ll
EndStr67	DC.B	21,32,89		;ism
EndStr68	DC.B	21,34,89		;ium
EndStr69	DC.B	34,89		;um
EndStr70	DC.B	18,21,15,13,33,21,28,91 ;fication
EndStr71	DC.B	21,32,13,33,21,28,91	;isation
EndStr72	DC.B	31,13,33,21,28,91	;ration
EndStr73	DC.B	32,13,33,21,28,91	;sation
EndStr74	DC.B	13,33,21,28,91	;ation
EndStr75	DC.B	32,21,28,91 	;sion
EndStr76	DC.B	33,21,28,91 	;tion
EndStr77	DC.B	21,13,91		;ian
EndStr78	DC.B	21,28,91		;ion
EndStr79	DC.B	25,13,91		;man
EndStr80	DC.B	33,28,91		;ton
EndStr81	DC.B	13,91		;an
EndStr82	DC.B	17,91		;en
EndStr83	DC.B	21,91		;in
EndStr84	DC.B	28,91		;on
EndStr85	DC.B	20,21,93		;hip
EndStr86	DC.B	32,33,17,95 	;ster
EndStr87	DC.B	34,24,13,95 	;ular
EndStr88	DC.B	20,17,95		;her
EndStr89	DC.B	21,17,95		;ier
EndStr90	DC.B	33,17,95		;ter
EndStr91	DC.B	35,17,95		;ver
EndStr92	DC.B	13,95		;ar
EndStr93	DC.B	17,95		;er
EndStr94	DC.B	28,95		;or
EndStr95	DC.B	13,31,21,17,96	;aries
EndStr96	DC.B	21,27,17,32,96	;iness
EndStr97	DC.B	21,33,21,17,96	;ities
EndStr98	DC.B	21,28,34,96 	;ious
EndStr99	DC.B	24,17,32,96 	;less
EndStr100	DC.B	27,17,32,96 	;ness
EndStr101	DC.B	31,21,17,96 	;ries
EndStr102	DC.B	33,21,17,96 	;ties
EndStr103	DC.B	17,32,96		;ess
EndStr104	DC.B	21,17,96		;ies
EndStr105	DC.B	28,34,96		;ous
EndStr106	DC.B	17,96		;es
EndStr107	DC.B	34,96		;us
EndStr108	DC.B	21,19,20,97 	;ight
EndStr109	DC.B	25,17,27,97 	;ment
EndStr110	DC.B	13,27,97		;ant
EndStr111	DC.B	17,15,97		;ect
EndStr112	DC.B	17,27,97		;ent
EndStr113	DC.B	17,32,97		;est
EndStr114	DC.B	21,32,97		;ist
EndStr115	DC.B	17,97		;et
EndStr116	DC.B	27,97		;nt
EndStr117	DC.B	32,97		;st
EndStr118	DC.B	13,14,21,24,21,33,102	;ability
EndStr119	DC.B	21,14,21,24,21,33,102	;ibility
EndStr120	DC.B	13,24,24,102	;ally
EndStr121	DC.B	13,31,102		;ary
EndStr122	DC.B	21,24,102		;ily
EndStr123	DC.B	21,33,102		;ity
EndStr124	DC.B	36,13,102		;way
EndStr125	DC.B	24,102		;ly
EndStr126	DC.B	31,102		;ry
EndStr127	DC.B	33,102		;ty

	EVEN
dict_flag	DC.W	0

	SECTION BSS

current_word
	DS.B	32
	EVEN

index_ptr	DS.W	1
in_index	DS.B	1
dict_caps	DS.B	1
word_caps	DS.B	1
caps2	DS.B	1
	EVEN


word_length	DS.W	1
word_end	DS.W	1

word_start	DS.L	1
text_pointer
	DS.L	1
text_length	DS.L	1
text_start	DS.L	1

i_length	DS.L	1
i_start	DS.L	1

q_length	DS.L	1
q_start	DS.L	1

dict_buf	DS.B	40
	EVEN
test_buf	DS.B	40
	EVEN
main_buf_length
	DS.W	1
main_buf_ptr
	DS.W	1
main_dict_buf
	DS.B	280
	EVEN

handle	DS.W	1

input_buffer DS.B	84

	DS.L	400
mystack	EVEN
