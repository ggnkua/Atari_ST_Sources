typedef union {
	int ival;			/* integer value */
	struct n n;			/* just like in struct sym */
	double dval;		/* floating point value */
	char *sval;			/* string */
	int cval;			/* character */
	char cond;			/* condition */
	struct regs {
		int r6, r5, r4, data_alu_accum, ctl_reg, funky_ctl_reg;
		int sdx, sdy, lsd, ab, xreg, yreg;
		int flags;
	} regs;
	struct ea {
		int mode;
		int ext;
		int pp;
	} ea;
} YYSTYPE;
#define	CHEX	258
#define	CDEC	259
#define	FRAC	260
#define	AREG	261
#define	BREG	262
#define	MREG	263
#define	NREG	264
#define	RREG	265
#define	XREG	266
#define	YREG	267
#define	OP	268
#define	OPA	269
#define	OPP	270
#define	OP_JCC	271
#define	OP_JSCC	272
#define	OP_TCC	273
#define	SYM	274
#define	STRING	275
#define	CHAR	276
#define	XMEM	277
#define	YMEM	278
#define	LMEM	279
#define	PMEM	280
#define	AAAA	281
#define	A10	282
#define	BBBB	283
#define	B10	284
#define	AABB	285
#define	BBAA	286
#define	XXXX	287
#define	YYYY	288
#define	SR	289
#define	MR	290
#define	CCR	291
#define	OMR	292
#define	SP	293
#define	SSH	294
#define	SSL	295
#define	LA	296
#define	LC	297
#define	EOL	298
#define	EOS	299
#define	LEXBAD	300
#define	OP_ABS	301
#define	OP_ADC	302
#define	OP_ADD	303
#define	OP_ADDL	304
#define	OP_ADDR	305
#define	OP_ASL	306
#define	OP_ASR	307
#define	OP_CLR	308
#define	OP_CMP	309
#define	OP_CMPM	310
#define	OP_DIV	311
#define	OP_MAC	312
#define	OP_MACR	313
#define	OP_MPY	314
#define	OP_MPYR	315
#define	OP_NEG	316
#define	OP_NORM	317
#define	OP_RND	318
#define	OP_SBC	319
#define	OP_SUB	320
#define	OP_SUBL	321
#define	OP_SUBR	322
#define	OP_TFR	323
#define	OP_TST	324
#define	OP_AND	325
#define	OP_ANDI	326
#define	OP_EOR	327
#define	OP_LSL	328
#define	OP_LSR	329
#define	OP_NOT	330
#define	OP_OR	331
#define	OP_ORI	332
#define	OP_ROL	333
#define	OP_ROR	334
#define	OP_BCLR	335
#define	OP_BSET	336
#define	OP_BCHG	337
#define	OP_BTST	338
#define	OP_DO	339
#define	OP_ENDDO	340
#define	OP_LUA	341
#define	OP_MOVE	342
#define	OP_MOVEC	343
#define	OP_MOVEM	344
#define	OP_MOVEP	345
#define	OP_ILLEGAL	346
#define	OP_INCLUDE	347
#define	OP_JMP	348
#define	OP_JCLR	349
#define	OP_JSET	350
#define	OP_JSR	351
#define	OP_JSCLR	352
#define	OP_JSSET	353
#define	OP_NOP	354
#define	OP_REP	355
#define	OP_RESET	356
#define	OP_RTI	357
#define	OP_RTS	358
#define	OP_STOP	359
#define	OP_SWI	360
#define	OP_WAIT	361
#define	OP_EQU	362
#define	OP_ORG	363
#define	OP_DC	364
#define	OP_DS	365
#define	OP_DSM	366
#define	OP_END	367
#define	OP_PAGE	368
#define	OP_PSECT	369
#define	OP_ALIGN	370
#define	OP_INT	371
#define	SHL	372
#define	SHR	373


extern YYSTYPE yylval;
