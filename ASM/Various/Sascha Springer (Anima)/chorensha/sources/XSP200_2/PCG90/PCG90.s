
	.globl		_pcg_roll90
	.globl		_bgpcg_roll90
	.globl		pcg_roll90
	.globl		bgpcg_roll90


	.include	doscall.mac
	.include	iocscall.mac


	.offset 0

par1_l	ds.b	2
par1_w	ds.b	1
par1_b	ds.b	1

par2_l	ds.b	2
par2_w	ds.b	1
par2_b	ds.b	1

par3_l	ds.b	2
par3_w	ds.b	1
par3_b	ds.b	1

par4_l	ds.b	2
par4_w	ds.b	1
par4_b	ds.b	1


	.text
	.even


*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■
*
*	書式：void	pcg_roll90( *pcg , lr ) ;
*
*	  IN : a0.l = *pcg
*	       d0.l = lr
*
*	  OUT: 無し
*
*	BREAK: 無し
*
*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■

_pcg_roll90:

A7ID	=	4+9*4			*   スタック上 return先アドレス  [ 4 byte ]
					* + 退避レジスタの全バイト数     [ 9*4 byte ]


	movea.l	4+par1_l(sp),a0		* a0.l = 回転するＰＣＧのアドレス
	move.l	4+par2_l(sp),d0		* d0.l = 回転方向
					* レジスタ退避前に読み出すのでオフセットに注意

*-------[ 初期化 ]
pcg_roll90:
	movem.l	d0-d3/d6-d7/a1-a3,-(sp)	* レジスタ退避

	lea.l	temp_pcg,a1		* a1.l = 生成したデータの一時書込み先

	tst.l	d0
	bmi.b	L90
	beq	EXIT


*-------[ 右回転 ]
R90:
	lea.l	(a0),a2
	lea.l	64(a1),a3
	bsr	ROLL_R

	lea.l	32(a0),a2
	lea.l	(a1),a3
	bsr	ROLL_R

	lea.l	64(a0),a2
	lea.l	96(a1),a3
	bsr	ROLL_R

	lea.l	96(a0),a2
	lea.l	32(a1),a3
	bsr	ROLL_R

	bra.b	@F


*-------[ 左回転 ]
L90:
	lea.l	(a0),a2
	lea.l	32(a1),a3
	bsr	ROLL_L

	lea.l	32(a0),a2
	lea.l	96(a1),a3
	bsr	ROLL_L

	lea.l	64(a0),a2
	lea.l	(a1),a3
	bsr	ROLL_L

	lea.l	96(a0),a2
	lea.l	64(a1),a3
	bsr	ROLL_L


*-------[ 一時書込み先よりコピー ]
@@:
	movem.l	(a1)+,d0-d3/d6-d7/a2-a3
	movem.l	d0-d3/d6-d7/a2-a3,(a0)
	movem.l	(a1)+,d0-d3/d6-d7/a2-a3
	movem.l	d0-d3/d6-d7/a2-a3,4*8(a0)
	movem.l	(a1)+,d0-d3/d6-d7/a2-a3
	movem.l	d0-d3/d6-d7/a2-a3,4*16(a0)
	movem.l	(a1)+,d0-d3/d6-d7/a2-a3
	movem.l	d0-d3/d6-d7/a2-a3,4*24(a0)


*-------[ 終了 ]
EXIT:
	movem.l	(sp)+,d0-d3/d6-d7/a1-a3	* レジスタ復活
	rts




*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■
*
*	書式：void	bgpcg_roll90( *pcg , lr ) ;
*
*	  IN : a0.l = *pcg
*	       d0.l = lr
*
*	  OUT: 無し
*
*	BREAK: 無し
*
*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■

_bgpcg_roll90:

A7ID	=	4+9*4			*   スタック上 return先アドレス  [ 4 byte ]
					* + 退避レジスタの全バイト数     [ 9*4 byte ]


	movea.l	4+par1_l(sp),a0		* a0.l = 回転するＰＣＧのアドレス
	move.l	4+par2_l(sp),d0		* d0.l = 回転方向
					* レジスタ退避前に読み出すのでオフセットに注意

*-------[ 初期化 ]
bgpcg_roll90:
	movem.l	d0-d3/d6-d7/a1-a3,-(sp)	* レジスタ退避

	lea.l	temp_pcg,a1		* a1.l = 生成したデータの一時書込み先
	lea.l	(a0),a2
	lea.l	(a1),a3

	tst.l	d0
	bmi.b	BG_L90
	beq.b	BG_EXIT


*-------[ 右回転 ]
BG_R90:
	bsr	ROLL_R
	bra.b	@F


*-------[ 左回転 ]
BG_L90:
	bsr	ROLL_L


*-------[ 一時書込み先よりコピー ]
@@:
	movem.l	(a1)+,d0-d3/d6-d7/a2-a3
	movem.l	d0-d3/d6-d7/a2-a3,(a0)


*-------[ 終了 ]
BG_EXIT:
	movem.l	(sp)+,d0-d3/d6-d7/a1-a3	* レジスタ復活
	rts




*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■
*
*	８＊８ドット範囲の右９０度回転
*
*	引数：a2.l = 読出し元 矩形左上端アドレス
*	　　　a3.l = 書込み先 矩形左上端アドレス
*
*	破壊：d0-d3/d6-d7/a2-a3
*
*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■

ROLL_R:
	lea.l	3(a3),a3
	moveq	#3,d7

ROLL_R_YLOOP:
		moveq	#3,d6

ROLL_R_XLOOP:
			move.b	(a2),d0		* d0.b = [0][1]
			move.b	4(a2),d1	* d1.b = [2][3]

			move.b	d0,d2
			lsr.b	#4,d2		* d2.b = [ ][0]
			move.b	d1,d3
			andi.b	#$F0,d3		* d3.b = [2][ ]
			or.b	d3,d2		* d2.b = [2][0]

			andi.b	#$0F,d0		* d0.b = [ ][1]
			lsl.b	#4,d1		* d1.b = [3][ ]
			or.b	d1,d0		* d0.b = [3][1]

			move.b	d2,(a3)		* [2][0] 転送
			move.b	d0,4(a3)	* [3][1] 転送

			lea.l	1(a2),a2
			lea.l	8(a3),a3

		dbra	d6,ROLL_R_XLOOP

		lea.l	4(a2),a2
		lea.l	-32-1(a3),a3

	dbra	d7,ROLL_R_YLOOP

	rts




*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■
*
*	８＊８ドット範囲の左９０度回転
*
*	引数：a2.l = 読出し元 矩形左上端アドレス
*	　　　a3.l = 書込み先 矩形左上端アドレス
*
*	破壊：d0-d3/d6-d7/a2-a3
*
*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■

ROLL_L:
	lea.l	24(a3),a3
	moveq	#3,d7

ROLL_L_YLOOP:
		moveq	#3,d6

ROLL_L_XLOOP:
			move.b	(a2),d0		* d0.b = [0][1]
			move.b	4(a2),d1	* d1.b = [2][3]

			move.b	d0,d2
			lsl.b	#4,d2		* d2.b = [1][ ]
			move.b	d1,d3
			andi.b	#$0F,d3		* d3.b = [ ][3]
			or.b	d3,d2		* d2.b = [1][3]

			andi.b	#$F0,d0		* d0.b = [0][ ]
			lsr.b	#4,d1		* d1.b = [ ][2]
			or.b	d1,d0		* d0.b = [0][2]

			move.b	d2,(a3)		* [1][3] 転送
			move.b	d0,4(a3)	* [0][2] 転送

			lea.l	1(a2),a2
			lea.l	-8(a3),a3

		dbra	d6,ROLL_L_XLOOP

		lea.l	4(a2),a2
		lea.l	32+1(a3),a3

	dbra	d7,ROLL_L_YLOOP

	rts




*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■
*
*	メモリ確保
*
*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■

	.bss
	.even

temp_pcg:	ds.b	128


