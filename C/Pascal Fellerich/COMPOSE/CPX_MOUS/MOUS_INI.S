; cpxstart.asm
;=============================================================================
; Startup file for CPXs
;
; 'Save_vars' is the area to store your default variables.
; Add more dc.w's as necessary
;
; Assemble with Mad Mac
;
; For Mark Williams - Use  'cpx_init_'
; For Alcyon        - Use  '_cpx_init'
;
;  
;


	globl	    cpxstart
	globl	    save_vars
	globl	    cpx_init
	
	text

cpxstart:
	jmp  cpx_init


	data

save_vars:
	dc.w 1				; language (english)
	dc.w 1				; Automatic resolution adaptation

	dc.w 1				; bitmapped switches: on, L,R
	dc.w 0,29,133,93	; Polynomial
	dc.w 0				; Rotation
	dc.w 256			; Screen aspect ratio
	dc.w 100			; mouse resolution
	dc.w 72				; screen resolution

;extern struct safe {
;	short	language,				/* cpx sprache */
;			autodetect;				/* automatic resolution adaptation */
;	MSPEEDER_SETUP mouse;			/* Mausdaten */
;} save_vars;
*         typedef struct {
*             union {
*                 unsigned resvd    :13;
*                 unsigned lefthand :1;       /* Button map change!?        */
*                 unsigned unused   :1;       /* old feature, removed...    */
*                 unsigned activity :1;       /* Speeder ON/OFF             */
*             } switches;
*             short       polynomial[4];      /* speeder polynomial         */
*             short       rotation;           /* rotation in degrees        */
*             short       ratio;              /* X:Y ratio * 256!           */
*             short       mouse_rez;          /* M.resolution in dpi (130)  */
*             short       screen_rez;         /* screen rez in dpi   ( 72)  */
*         } MSPEEDER_SETUP;

	end
