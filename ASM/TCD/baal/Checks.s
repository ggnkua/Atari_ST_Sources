;After we've got the data from the original disk into memory using
;secload.s then these are the offsets you need to modify in the data
;to crack the protection.
;The checksum comparison basically adds the value of the bytes used 
;in the routine being checked then compares the length with a 
;pre-calculated value.
;There are 2 ways to crack it. [1] Make the calculated length=the
;comparison length or [2] Make the calculated length=0 then ignore
;the check which is what i've done here.

;There are other checks made during the game for disk1 and 2 which
;also need removed if we are to use this with our filed version of the game.


;DEST=the load address of the main data (game sets it at $200)




;------	Put some instructions into D1 and D2 first of all ------;

;	D1=  NOP
;	D2=  SUB.W D0,D0 then NOP

CRACK	MOVE.W	#$4E71,D1	
	MOVE.L	#$90404E71,D2	
				
;----- Remove the 6 cartridge checks ------;
	
CART_CHECK	
	MOVE.W	D1,$1428+DEST	
	MOVE.W	D1,$1430+DEST	
	MOVE.W	D1,$14B8+DEST	
	MOVE.W	D1,$14C0+DEST	
	MOVE.W	D1,$190E+DEST	
	MOVE.W	D1,$1916+DEST	

;------ Remove the checksum checks ------;

CHECK_SUM
	MOVE.L	D2,$6AD8+DEST	
	MOVE.L	D2,$7922+DEST
	MOVE.L	D2,$8038+DEST

;------ Remove the checks made for disk1 ------;

CHK_DISK1	
	MOVE.L	D2,DEST+$13B4	
;	MOVE.L	D2,DEST+$1834
;	MOVE.W	D2,DEST+$1834+4
	MOVE.L	D2,DEST+$13E4
	MOVE.L	D2,DEST+$13E4+4
	MOVE.W	D2,DEST+$13E4+4+4
	MOVE.L	D2,DEST+$59CC
	MOVE.L	D2,DEST+$59CC+4

;------ Same goes for disk2 ------;

CHK_DISK2	
	MOVE.L	D2,DEST+$1324	
	MOVE.W	D2,DEST+$1324+4
	MOVE.L	D2,DEST+$5E06
	MOVE.L	D2,DEST+$5E06+4
	MOVE.L	D2,DEST+$5E9A
	MOVE.L	D2,DEST+$5E9A+4
	MOVE.L	D2,DEST+$811A
	MOVE.W	D2,DEST+$811A+4

;------ Remove the disk access when refuelling laser ------;

	MOVE.L	D2,DEST+$59D4	


;------ Remove the wait when changing disks ------;

REM_WAIT	
	MOVE.L	D2,DEST+$130E	
	MOVE.W	D2,DEST+$1316	

;------ Finally the trainer for infinite lives
;------ and the use of any weapon

ANY_WEAPON
	MOVE.W	D1,$8B78+DEST

INF_LIVES
	MOVE.W	D1,$37D6+DEST
;---------------------------------------------------;
