*
* ASSEMBLER SOURCE einer Tastatur-umbelegungs-tabelle.
* (TurboAss!)
*
* Ω2/1992 by P. Fellerich
*
               output 'VIETNAM.CKB'

               default 6      ;'BASIC' == BINéR!

               >PART 'Header'
id:            dc.b "CKBD"    ;Kennung

               dxset 12,0     ;der eigene Name hat 12 chars
name:          dx.b 'Vietnam!'

unshift_offset:dc.w unshift-id ;  Start der UNSHIFT-Tabelle oder 0 wenn nicht da
shift_offset:  dc.w shift-id  ;   Start der Shift-Tabelle
caps_offset:   dc.w caps-id   ;   id, CapsLock
compose_offset:dc.w compose-id ;  Start der Compose-Tabelle

compose_mode:  dc.w %111      ; ON, MULTICHAR MODE, ORDER SENSITIVE

               endpart
               >PART 'Unshift translation table'
unshift:       dc.b $00,$1B,$31,$32,$33,$34,$35,$36
               dc.b $37,$38,$39,$30,$3C,$27,$08,$09
               dc.b $71,$77,$65,$72,$74,$7A,$75,$69
               dc.b $6F,$70,$7D,$2B,$0D,$00,$61,$73
               dc.b $64,$66,$67,$68,$6A,$6B,$6C,$7C
               dc.b $7B,$40,$00,$05,$79,$78,$63,$76
               dc.b $62,$6E,$6D,$2C,$2E,$2D,$00,$00
               dc.b $00,$20,$00,$00,$00,$00,$00,$00
               dc.b $00,$00,$00,$00,$00,$00,$00,$00
               dc.b $00,$00,$2D,$00,$00,$00,$2B,$00
               dc.b $00,$00,$00,$7F,$00,$00,$00,$00
               dc.b $00,$00,$00,$00,$00,$00,$00,$00
               dc.b $60,$00,$00,$28,$29,$2F,$2A,$37
               dc.b $38,$39,$34,$35,$36,$31,$32,$33
               dc.b $30,$2E,$0D,$00,$00,$00,$00,$00
               dc.b $00,$00,$00,$00,$00,$00,$00,$00
               endpart
               >PART 'Shift-translation table'
shift:         dc.b $00,$1B,$21,$22,$23,$24,$25,$26
               dc.b $2F,$28,$29,$3D,$3F,$3E,$08,$09
               dc.b $51,$57,$45,$52,$54,$5A,$55,$49
               dc.b $4F,$50,$5D,$2A,$0D,$00,$41,$53
               dc.b $44,$46,$47,$48,$4A,$4B,$4C,$5C
               dc.b $5B,$5E,$00,$0B,$59,$58,$43,$56
               dc.b $42,$4E,$4D,$3B,$3A,$5F,$00,$00
               dc.b $00,$20,$00,$00,$00,$00,$00,$00
               dc.b $00,$00,$00,$00,$00,$00,$00,$37
               dc.b $38,$00,$2D,$34,$00,$36,$2B,$00
               dc.b $32,$00,$30,$7F,$00,$00,$00,$00
               dc.b $00,$00,$00,$00,$00,$00,$00,$00
               dc.b $7E,$00,$00,$28,$29,$2F,$2A,$37
               dc.b $38,$39,$34,$35,$36,$31,$32,$33
               dc.b $30,$2E,$0D,$00,$00,$00,$00,$00
               dc.b $00,$00,$00,$00,$00,$00,$00,$00
               endpart
               >PART 'Capslock translation table'
caps:          dc.b $00,$1B,$31,$32,$33,$34,$35,$36
               dc.b $37,$38,$39,$30,$3C,$27,$08,$09
               dc.b $51,$57,$45,$52,$54,$5A,$55,$49
               dc.b $4F,$50,$5D,$2B,$0D,$00,$41,$53
               dc.b $44,$46,$47,$48,$4A,$4B,$4C,$5C
               dc.b $5B,$5E,$00,$0B,$59,$58,$43,$56
               dc.b $42,$4E,$4D,$2C,$2E,$2D,$00,$00
               dc.b $00,$20,$00,$00,$00,$00,$00,$00
               dc.b $00,$00,$00,$00,$00,$00,$00,$00
               dc.b $00,$00,$2D,$00,$00,$00,$2B,$00
               dc.b $00,$00,$00,$7F,$00,$00,$00,$00
               dc.b $00,$00,$00,$00,$00,$00,$00,$00
               dc.b $60,$00,$00,$28,$29,$2F,$2A,$37
               dc.b $38,$39,$34,$35,$36,$31,$32,$33
               dc.b $30,$2E,$0D,$00,$00,$00,$00,$00
               dc.b $00,$00,$00,$00,$00,$00,$00,$00
               endpart
               >PART 'Compose Character Tabelle'
* COMPOSE-Tabelle fÅr VIETCAL!
* ----------------------------
* erstellt 26.1.1992 @pf68030
*
compose:       dc.b "A1Ä",0
               dc.b "A2Å",0
               dc.b "A3Ç",0
               dc.b "A4É",0
               dc.b "A5Ñ",0
               dc.b "A6Ä",0
               dc.b "A7Å",0
               dc.b "A8Ç",0
               dc.b "A9É",0
               dc.b "A0Ñ",0
               dc.b "AAÖ",0
               dc.b "Ö1Ü",0
               dc.b "Ö2á",0
               dc.b "Ö3à",0
               dc.b "Ö4â",0
               dc.b "Ö5ä",0
               dc.b "Ö6Ü",0
               dc.b "Ö7á",0
               dc.b "Ö8à",0
               dc.b "Ö9â",0
               dc.b "Ö0ä",0
               dc.b "ASã",0
               dc.b "ã1å",0
               dc.b "ã2ç",0
               dc.b "ã3é",0
               dc.b "ã4è",0
               dc.b "ã5ê",0
               dc.b "ã6å",0
               dc.b "ã7ç",0
               dc.b "ã8é",0
               dc.b "ã9è",0
               dc.b "ã0ê",0
               dc.b "E1ë",0
               dc.b "E2í",0
               dc.b "E3ì",0
               dc.b "E4î",0
               dc.b "E5ï",0
               dc.b "E6ë",0
               dc.b "E7í",0
               dc.b "E8ì",0
               dc.b "E9î",0
               dc.b "E0ï",0
               dc.b "EEñ",0
               dc.b "ñ1ó",0
               dc.b "ñ2ò",0
               dc.b "ñ3ô",0
               dc.b "ñ4ö",0
               dc.b "ñ5õ",0
               dc.b "ñ6ó",0
               dc.b "ñ7ò",0
               dc.b "ñ8ô",0
               dc.b "ñ9ö",0
               dc.b "ñ0õ",0
               dc.b "I1ú",0
               dc.b "I2ù",0
               dc.b "I3û",0
               dc.b "I4ü",0
               dc.b "I5†",0
               dc.b "I6ú",0
               dc.b "I7ù",0
               dc.b "I8û",0
               dc.b "I9ü",0
               dc.b "I0†",0
               dc.b "O1°",0
               dc.b "O2¢",0
               dc.b "O3£",0
               dc.b "O4§",0
               dc.b "O5•",0
               dc.b "O6°",0
               dc.b "O7¢",0
               dc.b "O8£",0
               dc.b "O9§",0
               dc.b "O0•",0
               dc.b "OO¶",0
               dc.b "¶1ß",0
               dc.b "¶2®",0
               dc.b "¶3©",0
               dc.b "¶4™",0
               dc.b "¶5´",0
               dc.b "¶6ß",0
               dc.b "¶7®",0
               dc.b "¶8©",0
               dc.b "¶9™",0
               dc.b "¶0´",0
               dc.b "U1¨",0
               dc.b "U2≠",0
               dc.b "U3Æ",0
               dc.b "U4Ø",0
               dc.b "U5∞",0
               dc.b "U6¨",0
               dc.b "U7≠",0
               dc.b "U8Æ",0
               dc.b "U9Ø",0
               dc.b "U0∞",0
               dc.b "Y1±",0
               dc.b "Y2≤",0
               dc.b "Y3≥",0
               dc.b "Y4¥",0
               dc.b "Y5µ",0
               dc.b "Y6±",0
               dc.b "Y7≤",0
               dc.b "Y8≥",0
               dc.b "Y9¥",0
               dc.b "Y0µ",0
               dc.b "\1∂",0
               dc.b "\2∑",0
               dc.b "\3∏",0
               dc.b "\4π",0
               dc.b "\5∫",0
               dc.b "\6∂",0
               dc.b "\7∑",0
               dc.b "\8∏",0
               dc.b "\9π",0
               dc.b "\0∫",0
               dc.b "]1ª",0
               dc.b "]2º",0
               dc.b "]3Ω",0
               dc.b "]4æ",0
               dc.b "]5ø",0
               dc.b "]6ª",0
               dc.b "]7º",0
               dc.b "]8Ω",0
               dc.b "]9æ",0
               dc.b "]0ø",0
               dc.b "a1¿",0
               dc.b "a2¡",0
               dc.b "a3¬",0
               dc.b "a4√",0
               dc.b "a5ƒ",0
               dc.b "a6¿",0
               dc.b "a7¡",0
               dc.b "a8¬",0
               dc.b "a9√",0
               dc.b "a0ƒ",0
               dc.b "aa≈",0
               dc.b "≈1∆",0
               dc.b "≈2«",0
               dc.b "≈3»",0
               dc.b "≈4…",0
               dc.b "≈5 ",0
               dc.b "≈6∆",0
               dc.b "≈7«",0
               dc.b "≈8»",0
               dc.b "≈9…",0
               dc.b "≈0 ",0
               dc.b "asÀ",0
               dc.b "À1Ã",0
               dc.b "À2Õ",0
               dc.b "À3Œ",0
               dc.b "À4œ",0
               dc.b "À5–",0
               dc.b "À6Ã",0
               dc.b "À7Õ",0
               dc.b "À8Œ",0
               dc.b "À9œ",0
               dc.b "À0–",0
               dc.b "e1—",0
               dc.b "e2“",0
               dc.b "e3”",0
               dc.b "e4‘",0
               dc.b "e5’",0
               dc.b "e6—",0
               dc.b "e7“",0
               dc.b "e8”",0
               dc.b "e9‘",0
               dc.b "e0’",0
               dc.b "ee÷",0
               dc.b "÷1◊",0
               dc.b "÷2ÿ",0
               dc.b "÷3Ÿ",0
               dc.b "÷4⁄",0
               dc.b "÷5€",0
               dc.b "÷6◊",0
               dc.b "÷7ÿ",0
               dc.b "÷8Ÿ",0
               dc.b "÷9⁄",0
               dc.b "÷0€",0
               dc.b "i1‹",0
               dc.b "i2›",0
               dc.b "i3ﬁ",0
               dc.b "i4ﬂ",0
               dc.b "i5‡",0
               dc.b "i6‹",0
               dc.b "i7›",0
               dc.b "i8ﬁ",0
               dc.b "i9ﬂ",0
               dc.b "i0‡",0
               dc.b "o1·",0
               dc.b "o2‚",0
               dc.b "o3„",0
               dc.b "o4‰",0
               dc.b "o5Â",0
               dc.b "o6·",0
               dc.b "o7‚",0
               dc.b "o8„",0
               dc.b "o9‰",0
               dc.b "o0Â",0
               dc.b "ooÊ",0
               dc.b "Ê1Á",0
               dc.b "Ê2Ë",0
               dc.b "Ê3È",0
               dc.b "Ê4Í",0
               dc.b "Ê5Î",0
               dc.b "Ê6Á",0
               dc.b "Ê7Ë",0
               dc.b "Ê8È",0
               dc.b "Ê9Í",0
               dc.b "Ê0Î",0
               dc.b "u1Ï",0
               dc.b "u2Ì",0
               dc.b "u3Ó",0
               dc.b "u4Ô",0
               dc.b "u5",0
               dc.b "u6Ï",0
               dc.b "u7Ì",0
               dc.b "u8Ó",0
               dc.b "u9Ô",0
               dc.b "u0",0
               dc.b "y1Ò",0
               dc.b "y2Ú",0
               dc.b "y3Û",0
               dc.b "y4Ù",0
               dc.b "y5ı",0
               dc.b "y6Ò",0
               dc.b "y7Ú",0
               dc.b "y8Û",0
               dc.b "y9Ù",0
               dc.b "y0ı",0
               dc.b "|1ˆ",0
               dc.b "|2˜",0
               dc.b "|3¯",0
               dc.b "|4˘",0
               dc.b "|5˙",0
               dc.b "|6ˆ",0
               dc.b "|7˜",0
               dc.b "|8¯",0
               dc.b "|9˘",0
               dc.b "|0˙",0
               dc.b "}1˚",0
               dc.b "}2¸",0
               dc.b "}3˝",0
               dc.b "}4˛",0
               dc.b "}5ˇ",0
               dc.b "}6˚",0
               dc.b "}7¸",0
               dc.b "}8˝",0
               dc.b "}9˛",0
               dc.b "}0ˇ",0
               dc.l 0
;------------

               endpart
               end
