* DEGAS FORMAT SCREEN SAVER, any resolution.

* DEGAS_SV.S

* Please note there is no file error checking


* set up a couple of registers first

          move.l    #pic_head+2,a3     ; place buffer address in a3
          move.l    #0,d3              ; counter

* now get contents of palette

read_again
          move      #-1,-(sp)      ; read contents, don't set
          move      d3,-(sp)       ; counter from 0 to 15
          move      #7,-(sp)       ; setcolor() function
          trap      #14            ; XBIOS
          addq.l    #6,sp          ; correct stack

          move      d0,(a3)+       ; place contents of d0 in palette_buffer
          add       #1,d3          ; increment counter
          cmpi.b    #17,d3         ; have we got to end of loop
          bne       read_again     ; no do again, Branch Not Equal 
* to 17

* get screen address and place in 'screen_address' holder
          move      #3,-(sp)       
          trap      #14
          add.l     #2,sp
          move.l    d0,screen_address

*** Now lets do it! ***

* create file  
          move      #0,-(sp)            ; read/write status
          move.l    #file_name,-(sp)    ; address of filename
          move      #$3C,-(sp)          ; create file
          trap      #1                  ; GEMDOS
          addq.l    #8,sp               ; correct stack
          move      d0,handle           ; get handle in 'handle'

* get current screen res

          move      #4,-(sp)            ; getrez() 
          trap      #14                 ; XBIOS
          addq.l    #2,sp               ; correct stack
* res returned in d0

* write  palette file
          move    d0,pic_head              ; place res in buffer
          move.l  #pic_head,-(sp)          ; address of buffer
          move.l  #34,-(sp)                ; number of bytes to save
          move.w  handle,-(sp)             ; file handle
          move.w  #$40,-(sp)               ; save data
          trap    #1                       ; GEMDOS
          add.l   #12,sp                   ; correct stack


* write 32K screen bit image
          move.l  screen_address,-(sp)   ; address of buffer
          move.l  #32000,-(sp)           ; 32K of RAM to save
          move.w  handle,-(sp)           ; file handle
          move.w  #$40,-(sp)             ; save data
          trap    #1                     ; GEMDOS
          add.l   #12,sp                 ; correct stack

* close file
          move    handle,(sp)            ; file handle
          move    #$3e,-(sp)             ; close file function 
          trap    #1                     ; GEMDOS
          add     #4,sp                  ; correct stack

exit
          move.w  #20,-(sp)              ; any value
          move.w  #$4c,-(sp)             ; pterm, exit properly
          trap    #1                     ; GEMDOS
 


handle          ds.w    1
		even
file_name       dc.b    'A:\PIC.PI3',0    ; place name and path 
                                          ; of your file here

screen_address  ds.l 1 
palette_buffer  ds.w 17
		even
pic_head        ds.b 34

