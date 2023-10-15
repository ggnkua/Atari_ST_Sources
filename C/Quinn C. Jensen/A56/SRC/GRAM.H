
typedef union  {
	int ival;	/* integer value */
	struct n n;	/* just like in struct sym */
	double dval;	/* floating point value */
	char *sval;	/* string */
	int cval;	/* character */
	char cond;	/* condition */
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
extern YYSTYPE yylval;
# define CHEX 257
# define CDEC 258
# define FRAC 259
# define AREG 260
# define BREG 261
# define MREG 262
# define NREG 263
# define RREG 264
# define XREG 265
# define YREG 266
# define OP 267
# define OPA 268
# define OPP 269
# define OP_JCC 270
# define OP_JSCC 271
# define OP_TCC 272
# define SYM 273
# define STRING 274
# define CHAR 275
# define COMMENT 276
# define XMEM 277
# define YMEM 278
# define LMEM 279
# define PMEM 280
# define AAAA 281
# define A10 282
# define BBBB 283
# define B10 284
# define AABB 285
# define BBAA 286
# define XXXX 287
# define YYYY 288
# define SR 289
# define MR 290
# define CCR 291
# define OMR 292
# define SP 293
# define SSH 294
# define SSL 295
# define LA 296
# define LC 297
# define EOL 298
# define EOS 299
# define OP_ABS 300
# define OP_ADC 301
# define OP_ADD 302
# define OP_ADDL 303
# define OP_ADDR 304
# define OP_ASL 305
# define OP_ASR 306
# define OP_CLR 307
# define OP_CMP 308
# define OP_CMPM 309
# define OP_DIV 310
# define OP_MAC 311
# define OP_MACR 312
# define OP_MPY 313
# define OP_MPYR 314
# define OP_NEG 315
# define OP_NORM 316
# define OP_RND 317
# define OP_SBC 318
# define OP_SUB 319
# define OP_SUBL 320
# define OP_SUBR 321
# define OP_TFR 322
# define OP_TST 323
# define OP_AND 324
# define OP_ANDI 325
# define OP_EOR 326
# define OP_LSL 327
# define OP_LSR 328
# define OP_NOT 329
# define OP_OR 330
# define OP_ORI 331
# define OP_ROL 332
# define OP_ROR 333
# define OP_BCLR 334
# define OP_BSET 335
# define OP_BCHG 336
# define OP_BTST 337
# define OP_DO 338
# define OP_ENDDO 339
# define OP_LUA 340
# define OP_MOVE 341
# define OP_MOVEC 342
# define OP_MOVEM 343
# define OP_MOVEP 344
# define OP_ILLEGAL 345
# define OP_INCLUDE 346
# define OP_JMP 347
# define OP_JCLR 348
# define OP_JSET 349
# define OP_JSR 350
# define OP_JSCLR 351
# define OP_JSSET 352
# define OP_NOP 353
# define OP_REP 354
# define OP_RESET 355
# define OP_RTI 356
# define OP_RTS 357
# define OP_STOP 358
# define OP_SWI 359
# define OP_WAIT 360
# define OP_EQU 361
# define OP_ORG 362
# define OP_DC 363
# define OP_END 364
# define OP_PAGE 365
# define OP_PSECT 366
# define OP_ALIGN 367
# define SHL 368
# define SHR 369
