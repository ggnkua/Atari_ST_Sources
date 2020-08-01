     OFFSET

p_lowtpa:      DS.L      1    /* 0x00: Beginn TPA, des BP selbst           */
p_hitpa:       DS.L      1    /* 0x04: zeigt 1 Byte hinter TPA             */
p_tbase:       DS.L      1    /* 0x08: Beginn des TEXT - Segments          */
p_tlen:        DS.L      1    /* 0x0c: L„nge  des TEXT - Segments          */
p_dbase:       DS.L      1    /* 0x10: Beginn des DATA - Segments          */
p_dlen:        DS.L      1    /* 0x14: L„nge  des DATA - Segments          */
p_bbase:       DS.L      1    /* 0x18: Beginn des BSS  - Segments          */
p_blen:        DS.L      1    /* 0x1c: L„nge  des BSS  - Segments          */
p_dta:         DS.L      1    /* 0x20: Aktueller DTA- Puffer               */
p_parent:      DS.L      1    /* 0x24: Zeiger auf BP des Parent            */
p_procid:      DS.W      1
p_res1:        DS.W      1
p_env:         DS.L      1    /* 0x2c: Zeiger auf Environment              */
p_devx:        DS.B      6
p_res2:        DS.B      1
p_defdrv:      DS.B      1    /* 0x37: Default- Laufwerk                   */
p_res3:        DS.B      8
p_drvx:        DS.B     32
p_res4:        DS.B    $08
p_mem:         DS.L      1
p_context:     DS.L      1
p_mflags:      DS.L      1
p_mres3:       DS.L      1
p_mres4:       DS.L      1
p_reg:         DS.L      1
p_cmdlin:      DS.B    128    /* 0x80: Kommandozeile                       */

	TEXT
