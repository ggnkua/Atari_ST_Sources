************************************** 
* 	     ReBooter!		     *
* 	  ST User Oct. 1988          *
*  Loads Accessories from Drive B:   *
*  	  By Julia Forester          *
* To be assembled as 'REBOOTER.PRG'  *
* Place program in the AUTO-folder   *
* on the boot disc or run it from    *
* the desktop. Caution!! Some desk   *
* accessories and AUTO programs will *
* not run properly from drive B.     *
**************************************

start   pea boot(pc)		Start
 	move.w #38,-(sp) 	Xbios SUPERX
 	trap #14 		Call Xbios
 	adda.l #6,sp 		Tidy stack
 	move.w #0,-(sp) 	Return to parent
 	trap #1 		Call Bdos
 	adda.l #2,sp 		Tidy stack
boot 	move.b #1,$447 		Set drive B:
 	rts 			as boot devise
 