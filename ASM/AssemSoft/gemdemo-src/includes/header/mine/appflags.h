;===================================================
;==== Flag definition for "global_flags" (long) ====
;===================================================
	;Low word, LSB ---- global_flags+3(a6) ----
apterm = 0	;Bit 0 - 0 = Application not terminating | 1 = application is terminating.
		;This bit is used by the close windows routines to check if the application is
		;terminating, thus executing the routine pointed to by "win_apterm"
		;This bit is be set by the termination routine.

acclose = 1	;Bit 0 - 0 = No AC close | 1 = AC_CLOSE message received.
		;This bit is used to let different routines know that the application have
		;received an AC close message.

applmem = 2	;This flag shows if memory for the applications buffers and such is allocated.
		;If this flag is cleared, which will happend after an AC_CLOSE message, this
		;memory will have to be reallocated.
		;0 = Memory and buffers must be reallocated and set up, 1 = All is fine.
	
waitkids = 3	;If this bit is set, the application waits  for all child processes it started
		;to quit before exiting.
	
mntdomain = 4	;If this bit is set, the app is running in the MiNT domain

	;Low word, MSB ---- global_flags+2(a6) ----
now_term = 0	;Set this flag to make the application terminate when no windows are open.
use_kids = 1	;Set this flag to make this application create threads.

of_mode	= 2	;Set this flag to cause application not to open a new window on VA_START/VA_DRAGACCWIND and Drag&Drop sessions

	;High word, LSB --- global_flags+1(a6) ---
	
	;High work, MSB --- global_flags(a6) ---
;==================================================
;==== Flag definitions for "mtask_type" (long) ====
;==================================================
	;Low word, LSB ---- mtask_type+3(a6) ----
mint_f = 0	;If set, MiNT cookie was found during startup
magx_f = 1	;If set, MagiC cookie was found during startup
mgpc_f = 2	;If set; MagiCPC "MgPc" cookie was found during startup
mgmc_f = 3	;If set, MagiCMac "MgMc" cookie was found during startup


;====================================================
;==== Flag definitions for "dialog_flags" (Word) ====
;====================================================

	* low byte ---- dialog_flags+1(a6) ----
	*	Bit 0 - 0 = Centered Dialogs | 1 = Dialogs Near Mouse
	*	Bit 1 - 0 = Find objects X&Y coords | 1 = Objects X&Y coords prepared in OBJ_COORDS
	*	( mode 1 is used when I want to place the dialog somewhere, ignores Centered/Nearmouse bit)
	*	Bit 2 - 0 = Don't draw grow/shrink boxes | 1 = Draw grow/shrink boxes
	*	Bit 3 - 0 = Use d_mous_f and d_cord_f | 1 = take the coordinates directly from object tree
	*	
d_mous_f	= 0
d_cord_f	= 1
d_gsbx_f	= 2
d_objc_f	= 3
;====================================================
;==== Flag definitions for "slider_flags" (Word) ====
;====================================================
;Used by the Ddw_slids module - low byte used by  the routines.

	;High byte ---- slider_flags(a6) ----
s_real_f = 0	;If clear, No realtime slider action, "drag_slider" exits only when the mouse button is released with relative position.
	;If set, Realtime action, "drag_slider" exits with the relative position and carry set to indicate that mouse is still pressed, carry clear = mouse released, end of session.

s_fast_f = 1	;Fast Slider Update, loop mode flag.
	;If clear, After each slider setting, evnt_multi is called.
	;If set, The slider is continuesly updated until mouse button is released
	
s_rupd_f = 2	;Real time update of slider in loop mode. (only effective if Fast Slider Update is selected)
	;If clear, The sliders are updated when a change in it's position occurs
	;If set, The sliders are not updated until the mouse button is released.


