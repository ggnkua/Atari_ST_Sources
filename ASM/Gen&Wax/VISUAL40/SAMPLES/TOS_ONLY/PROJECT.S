	output d:\assemble\visual40\samples\tos_only\project.tos

OPT_DEBUG

	lea objet_application,a1

	include project.def
	include visual40.s
	include project.obj

	comment HEAD=7
	section TEXT

;---------------------------------------------------------------------------
	; Exemple de programme Visual Assembleur 4.0
	; Propri‚t‚ : fonctionne en TOS sans le GEM !
;---------------------------------------------------------------------------

my_inits:	save.l a0
	CCONWS msg
	load.l a0
	CCONWS (a0)
	CCONWS rc_lf
	CRAWCIN
	rts

	section DATA

msg:	dc.b 'Command line was : ',0
rc_lf:	dc.b rc,lf,0

 END