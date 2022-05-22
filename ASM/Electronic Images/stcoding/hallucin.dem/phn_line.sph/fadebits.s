		MOVE.L #currpal,fadein_cur_ptr
		MOVE.W #16,fadein_nocols
		ST fadeinflag
		MOVE #500,D7
.vbl_loop1	MOVE.W D7,-(SP)
		BSR Do_Update
		MOVE.W (SP)+,D7
		DBF D7,.vbl_loop1
		MOVE.L #pal,fadeout_pal_ptr
		MOVE.L #currpal,fadeout_cur_ptr
		MOVE.W #16,fadeout_nocols
		ST fadeoutflag

		MOVEQ #6,D7
.fade_outlp	MOVE.W D7,-(SP)
		BSR Do_Update
		MOVE.W (SP)+,D7
		DBF D7,.fade_outlp
		BSR FadeOutFloor
		BSR WaitVbl
