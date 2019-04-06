********************************************************************
*                                                                  *
*                            MCC.ASM                               *
*                                                                  *
* This program is used in Appendix A of the manual to explain the  *
* MCC Assembler development cycle. It draws a circle, triangle and *
* a rectangle on the screen.                                       *
*                                                                  *
********************************************************************
*
* This program needs to be assembled and then linked with both
* ASMSTART.BIN and GEMLIB.BIN. See Appendix A for further details.
* Note that coordinates are given in Raster Coordinates (RC). The
* screen size depends upon the resolution. This is evaluated from
* the maximum indices in the intout array and the coordinates of
* the shapes to be drawn are set accordingly.

         TEXT

* We begin by defining some macros which will make the code (in the 
* main part of the program) more readable.

* Macro PUTS to output a string at the specified coordinates.
* Calling sequence:      PUTS

PUTS     MACRO
         move.l   string,-(a7)      ; string address
         move.l   logoy,-(a7)       ; y-coordinate
         move.l   logox,-(a7)       ; x-coordinate
         move.l   handle,-(a7)      ; (long) device handle
         jsr      v_gtext           ; write the text string
         lea.l    16(a7),a7         ; restore stack
         ENDM

* Macro PATTERN to set interior fill style
* Calling sequence:      PATTERN patternstyle

PATTERN  MACRO
         move.l   #\1,-(a7)         ; pattern style
         move.l   handle,-(a7)      ; (long) device handle
         jsr      vsf_interior      ; set interior style
         addq.l   #8,a7             ; restore stack
         ENDM

* Macro STYLE to set fill style index
* Calling sequence:      STYLE styleindex

STYLE    MACRO
         move.l   #\1,-(a7)         ; style index
         move.l   handle,-(a7)      ; (long) device handle
         jsr      vsf_style         ; set the style
         addq.l   #8,a7             ; restore stack
         ENDM

* Macro EFFECT to set text effects
* Calling sequence:      EFFECT texteffects

EFFECT   MACRO
         move.l   #\1,(a7)          ; text effects
         move.l   handle,-(a7)      ; (long) device handle
         jsr      vst_effects       ; set the effects
         addq.l   #4,a7             ; restore stack
         ENDM

* Having defined the macros, we now start the program. 

start    jsr      appl_init         ; call the initialise routine

* Get the device handle using a call to graf_handle

         pea      gr4               ; pass the address of a dummy variable
         pea      gr3               ; ditto
         pea      gr2               ; ditto
         pea      gr1               ; ditto
         jsr      graf_handle       ; call the routine
         lea.l    16(a7),a7         ; restore stack
         ext.l    d0                ; convert handle from word to long
         move.l   d0,handle         ; store returned (long) device handle

* Open (virtual) workstation

         pea      intout            ; stack address of input parameter array
         lea.l    handle,a0         ; get address of (long) device handle
         pea      2(a0)             ; stack address of (word) device handle
         pea      intin             ; stack address of output parameter array
         jsr      v_opnvwk          ; open the virtual workstation
         lea.l    12(a7),a7         ; restore stack

* Set up the variables according to the resolution

         lea.l    intout,a0         ; get address of output parameter array
         cmpi.w   #639,(a0)         ; is maximum x value = 639 ?
         bne      lowres            ; must be low resolution if not
medorhi
         move.l   #200,radius       ; set radius of circle (hi and med res)
         move.l   #200,xcentre      ; set centre of circle (x) (hi and med)
         move.l   #190,logox        ; set position of logo (x) (hi and med)
         lea.l    histring,a1       ; get address of logo string
         move.l   a1,string         ; set logo string (hi and med res)
         cmpi.w   #399,2(a0)        ; is maximum y value = 399 ?
         bne.s    medres            ; must be med resolution if not

hires                               ; High resolution (640 * 400)
         lea.l    hitri,a0          ; get high res triangle definition
         move.l   a0,triangle       ; set the variable used below
         lea.l    hibox,a0          ; get high res box definition
         move.l   a0,box            ; set the variable used below
         move.l   #50,height        ; set requested character height
         move.l   #200,ycentre      ; set centre of circle (y)
         move.l   #215,logoy        ; set position of logo (y)
         bra      clear             ; having set the variables, carry on

medres                              ; Medium resolution (640 * 200)
         lea.l    medtri,a0         ; get high med triangle definition
         move.l   a0,triangle       ; set the variable used below
         lea.l    medbox,a0         ; get med res box definition
         move.l   a0,box            ; set the variable used below
         move.l   #25,height        ; set requested character height
         move.l   #100,ycentre      ; set centre of circle (y)
         move.l   #108,logoy        ; set position of logo (y)
         bra.s    clear             ; having set the variables, carry on

lowres                              ; Low resolution (320 * 200)
         lea.l    lotri,a0          ; get low res triangle definition
         move.l   a0,triangle       ; set the variable used below
         lea.l    lobox,a0          ; get low res box definition
         move.l   a0,box            ; set the variable used below
         move.l   #25,height        ; set requested character height
         move.l   #100,radius       ; set radius of circle
         move.l   #100,xcentre      ; set centre of circle (x)
         move.l   #100,ycentre      ; set centre of circle (y)
         move.l   #95,logox         ; set position of logo (x)
         move.l   #108,logoy        ; set position of logo (y)
         lea.l    lostring,a0       ; get address of low res logo string 
         move.l   a0,string         ; set address of logo string

* Clear (virtual) workstation

clear
         move.l   handle,-(a7)      ; (long) device handle
         jsr      v_clrwk           ; clear the screen
         addq.l   #4,a7             ; restore stack

         PATTERN  2                 ; set pattern style

* Draw circle

         STYLE    9                 ; set fillstyle index

         move.l   radius,-(a7)      ; radius
         move.l   ycentre,-(a7)     ; y-centre
         move.l   xcentre,-(a7)     ; x-centre
         move.l   handle,-(a7)      ; (long) device handle
         jsr      v_circle          ; draw the circle
         lea.l    16(a7),a7         ; restore stack

* Draw triangle

         STYLE    11                ; set fill style index

         move.l   triangle,-(a7)    ; array of points
         move.l   #3,-(a7)          ; number of points
         move.l   handle,-(a7)      ; (long) device handle
         jsr      v_fillarea        ; fill the triangular area
         lea.l    12(a7),a7         ; restore stack

* Draw box filled in selected style

         STYLE    10

         move.l   box,-(a7)         ; coordinates of corners
         move.l   handle,-(a7)      ; (long) device handle
         jsr      v_rfbox           ; draw the rectangle         
         addq.l   #8,a7             ; restore stack

         pea      cellh             ; returned cell height
         pea      cellw             ; returned cell width
         pea      chh               ; returned character height
         pea      chw               ; returned character width
         move.l   height,-(a7)      ; requested height
         move.l   handle,-(a7)      ; (long) device handle
         jsr      vst_height        ; select character height
         lea.l    24(a7),a7         ; restore stack

* Output text

         EFFECT   1                 ; set thick characters

         PUTS                       ; output logo

         move.w   #1,-(a7)          ; wait for a key to be pressed
         trap     #1                ; with gemdos cconin function
         addq.l   #2,a7             ; restore stack

* Close (virtual) workstation

         move.l   handle,-(a7)      ; (long) device handle
         jsr      v_clsvwk          ; close (virtual) workstation
         addq.l   #4,a7             ; restore stack

* Finish off

         jsr      appl_exit         ; terminate application

         clr.w    -(a7)             ; call gemdos pterm 
         move.w   #$4c,-(a7)        ; with ok return code (0)
         trap     #1                ; dont return from this

         BSS

* Uninitialised data area

handle   DS.L     1                 ; long device handle
intout   DS.W     128               ; output parameter array
gr1      DS.W     1                 ; dummy variable for graf_handle
gr2      DS.W     1                 ; ditto
gr3      DS.W     1                 ; ditto
gr4      DS.W     1                 ; ditto
chh      DS.W     1                 ; text characteristics returned
chw      DS.W     1
cellw    DS.W     1
cellh    DS.W     1
box      DS.L     1                 ; address of rectangle data
triangle DS.L     1                 ; address of triangle data
logox    DS.L     1                 ; x coordinate of logo position
logoy    DS.L     1                 ; y coordinate of logo position
radius   DS.L     1                 ; radius of circle
xcentre  DS.L     1                 ; centre of circle (x)
ycentre  DS.L     1                 ; centre of circle (y)
height   DS.L     1                 ; requested character height
string   DS.L     1                 ; logo string to output

         DATA
                                       ; Data for HIGH resolution (640*400)
hibox    DC.W     150,150,500,250          ; array defining rectangular box
hitri    DC.W     600,50,450,380,100,300   ; array defining triangle

                                       ; Data for MEDIUM resolution (640*200)
medbox   DC.W     150,75,500,125           ; array defining rectangular box
medtri   DC.W     600,25,450,190,100,150   ; array defining triangle

                                       ; Data for LOW resolution (320*200)
lobox    DC.W     75,75,250,125            ; array defining rectangular box
lotri    DC.W     300,25,225,190,50,150    ; array defining triangle

* Initialised data arrays

intin    DC.W     1,1,1,1,1,1,1,1,1,1,2    ; intin input parameter array
histring DC.B     'M E T A C O M C O',0    ; text string (med and hi)
lostring DC.B     'METACOMCO',0            ; text string (lo)

* External references (to functions in GEMLIB.BIN)

         XREF     graf_handle,appl_init,v_opnvwk
         XREF     v_circle,v_clsvwk,appl_exit
         XREF     v_gtext,vst_height,vst_effects
         XREF     v_clrwk,vsf_interior,v_rfbox
         XREF     vsf_style,v_fillarea

         END
