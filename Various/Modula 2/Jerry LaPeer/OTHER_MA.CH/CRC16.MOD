IMPLEMENTATION MODULE CRC;


VAR CRCtable: ARRAY[0..256] OF CARDINAL;


PROCEDURE Compute(Ch: CHAR);
(*
 * Compute the next cycle of the CRC-16 calculation.
 *)
BEGIN
    (*
     * Result := CRCtable[(Ch XOR Result) AND 0FFH] XOR (Result SHR 8)
     *)

    Result := CARDINAL(
	BITSET(CRCtable[CARDINAL(BITSET(ORD(Ch))/BITSET(Result)) MOD 256])
	    /BITSET(Result DIV 256));
END Compute;


BEGIN
    CRCtable[0] := 00000H;
    CRCtable[1] := 0C0C1H;
    CRCtable[2] := 0C181H;
    CRCtable[3] := 00140H;
    CRCtable[4] := 0C301H;
    CRCtable[5] := 003C0H;
    CRCtable[6] := 00280H;
    CRCtable[7] := 0C241H;

    CRCtable[8] := 0C601H;
    CRCtable[9] := 006C0H;
    CRCtable[10] := 00780H;
    CRCtable[11] := 0C741H;
    CRCtable[12] := 00500H;
    CRCtable[13] := 0C5C1H;
    CRCtable[14] := 0C481H;
    CRCtable[15] := 00440H;

    CRCtable[16] := 0CC01H;
    CRCtable[17] := 00CC0H;
    CRCtable[18] := 00D80H;
    CRCtable[19] := 0CD41H;
    CRCtable[20] := 00F00H;
    CRCtable[21] := 0CFC1H;
    CRCtable[22] := 0CE81H;
    CRCtable[23] := 00E40H;

    CRCtable[24] := 00A00H;
    CRCtable[25] := 0CAC1H;
    CRCtable[26] := 0CB81H;
    CRCtable[27] := 00B40H;
    CRCtable[28] := 0C901H;
    CRCtable[29] := 009C0H;
    CRCtable[30] := 00880H;
    CRCtable[31] := 0C841H;

    CRCtable[32] := 0D801H;
    CRCtable[33] := 018C0H;
    CRCtable[34] := 01980H;
    CRCtable[35] := 0D941H;
    CRCtable[36] := 01B00H;
    CRCtable[37] := 0DBC1H;
    CRCtable[38] := 0DA81H;
    CRCtable[39] := 01A40H;

    CRCtable[40] := 01E00H;
    CRCtable[41] := 0DEC1H;
    CRCtable[42] := 0DF81H;
    CRCtable[43] := 01F40H;
    CRCtable[44] := 0DD01H;
    CRCtable[45] := 01DC0H;
    CRCtable[46] := 01C80H;
    CRCtable[47] := 0DC41H;

    CRCtable[48] := 01400H;
    CRCtable[49] := 0D4C1H;
    CRCtable[50] := 0D581H;
    CRCtable[51] := 01540H;
    CRCtable[52] := 0D701H;
    CRCtable[53] := 017C0H;
    CRCtable[54] := 01680H;
    CRCtable[55] := 0D641H;

    CRCtable[56] := 0D201H;
    CRCtable[57] := 012C0H;
    CRCtable[58] := 01380H;
    CRCtable[59] := 0D341H;
    CRCtable[60] := 01100H;
    CRCtable[61] := 0D1C1H;
    CRCtable[62] := 0D081H;
    CRCtable[63] := 01040H;

    CRCtable[64] := 0F001H;
    CRCtable[65] := 030C0H;
    CRCtable[66] := 03180H;
    CRCtable[67] := 0F141H;
    CRCtable[68] := 03300H;
    CRCtable[69] := 0F3C1H;
    CRCtable[70] := 0F281H;
    CRCtable[71] := 03240H;

    CRCtable[72] := 03600H;
    CRCtable[73] := 0F6C1H;
    CRCtable[74] := 0F781H;
    CRCtable[75] := 03740H;
    CRCtable[76] := 0F501H;
    CRCtable[77] := 035C0H;
    CRCtable[78] := 03480H;
    CRCtable[79] := 0F441H;

    CRCtable[80] := 03C00H;
    CRCtable[81] := 0FCC1H;
    CRCtable[82] := 0FD81H;
    CRCtable[83] := 03D40H;
    CRCtable[84] := 0FF01H;
    CRCtable[85] := 03FC0H;
    CRCtable[86] := 03E80H;
    CRCtable[87] := 0FE41H;

    CRCtable[88] := 0FA01H;
    CRCtable[89] := 03AC0H;
    CRCtable[90] := 03B80H;
    CRCtable[91] := 0FB41H;
    CRCtable[92] := 03900H;
    CRCtable[93] := 0F9C1H;
    CRCtable[94] := 0F881H;
    CRCtable[95] := 03840H;

    CRCtable[96] := 02800H;
    CRCtable[97] := 0E8C1H;
    CRCtable[98] := 0E981H;
    CRCtable[99] := 02940H;
    CRCtable[100] := 0EB01H;
    CRCtable[101] := 02BC0H;
    CRCtable[102] := 02A80H;
    CRCtable[103] := 0EA41H;

    CRCtable[104] := 0EE01H;
    CRCtable[105] := 02EC0H;
    CRCtable[106] := 02F80H;
    CRCtable[107] := 0EF41H;
    CRCtable[108] := 02D00H;
    CRCtable[109] := 0EDC1H;
    CRCtable[110] := 0EC81H;
    CRCtable[111] := 02C40H;

    CRCtable[112] := 0E401H;
    CRCtable[113] := 024C0H;
    CRCtable[114] := 02580H;
    CRCtable[115] := 0E541H;
    CRCtable[116] := 02700H;
    CRCtable[117] := 0E7C1H;
    CRCtable[118] := 0E681H;
    CRCtable[119] := 02640H;

    CRCtable[120] := 02200H;
    CRCtable[121] := 0E2C1H;
    CRCtable[122] := 0E381H;
    CRCtable[123] := 02340H;
    CRCtable[124] := 0E101H;
    CRCtable[125] := 021C0H;
    CRCtable[126] := 02080H;
    CRCtable[127] := 0E041H;

    CRCtable[128] := 0A001H;
    CRCtable[129] := 060C0H;
    CRCtable[130] := 06180H;
    CRCtable[131] := 0A141H;
    CRCtable[132] := 06300H;
    CRCtable[133] := 0A3C1H;
    CRCtable[134] := 0A281H;
    CRCtable[135] := 06240H;

    CRCtable[136] := 06600H;
    CRCtable[137] := 0A6C1H;
    CRCtable[138] := 0A781H;
    CRCtable[139] := 06740H;
    CRCtable[140] := 0A501H;
    CRCtable[141] := 065C0H;
    CRCtable[142] := 06480H;
    CRCtable[143] := 0A441H;

    CRCtable[144] := 06C00H;
    CRCtable[145] := 0ACC1H;
    CRCtable[146] := 0AD81H;
    CRCtable[147] := 06D40H;
    CRCtable[148] := 0AF01H;
    CRCtable[149] := 06FC0H;
    CRCtable[150] := 06E80H;
    CRCtable[151] := 0AE41H;

    CRCtable[152] := 0AA01H;
    CRCtable[153] := 06AC0H;
    CRCtable[154] := 06B80H;
    CRCtable[155] := 0AB41H;
    CRCtable[156] := 06900H;
    CRCtable[157] := 0A9C1H;
    CRCtable[158] := 0A881H;
    CRCtable[159] := 06840H;

    CRCtable[160] := 07800H;
    CRCtable[161] := 0B8C1H;
    CRCtable[162] := 0B981H;
    CRCtable[163] := 07940H;
    CRCtable[164] := 0BB01H;
    CRCtable[165] := 07BC0H;
    CRCtable[166] := 07A80H;
    CRCtable[167] := 0BA41H;

    CRCtable[168] := 0BE01H;
    CRCtable[169] := 07EC0H;
    CRCtable[170] := 07F80H;
    CRCtable[171] := 0BF41H;
    CRCtable[172] := 07D00H;
    CRCtable[173] := 0BDC1H;
    CRCtable[174] := 0BC81H;
    CRCtable[175] := 07C40H;

    CRCtable[176] := 0B401H;
    CRCtable[177] := 074C0H;
    CRCtable[178] := 07580H;
    CRCtable[179] := 0B541H;
    CRCtable[180] := 07700H;
    CRCtable[181] := 0B7C1H;
    CRCtable[182] := 0B681H;
    CRCtable[183] := 07640H;

    CRCtable[184] := 07200H;
    CRCtable[185] := 0B2C1H;
    CRCtable[186] := 0B381H;
    CRCtable[187] := 07340H;
    CRCtable[188] := 0B101H;
    CRCtable[189] := 071C0H;
    CRCtable[190] := 07080H;
    CRCtable[191] := 0B041H;

    CRCtable[192] := 05000H;
    CRCtable[193] := 090C1H;
    CRCtable[194] := 09181H;
    CRCtable[195] := 05140H;
    CRCtable[196] := 09301H;
    CRCtable[197] := 053C0H;
    CRCtable[198] := 05280H;
    CRCtable[199] := 09241H;

    CRCtable[200] := 09601H;
    CRCtable[201] := 056C0H;
    CRCtable[202] := 05780H;
    CRCtable[203] := 09741H;
    CRCtable[204] := 05500H;
    CRCtable[205] := 095C1H;
    CRCtable[206] := 09481H;
    CRCtable[207] := 05440H;

    CRCtable[208] := 09C01H;
    CRCtable[209] := 05CC0H;
    CRCtable[210] := 05D80H;
    CRCtable[211] := 09D41H;
    CRCtable[212] := 05F00H;
    CRCtable[213] := 09FC1H;
    CRCtable[214] := 09E81H;
    CRCtable[215] := 05E40H;

    CRCtable[216] := 05A00H;
    CRCtable[217] := 09AC1H;
    CRCtable[218] := 09B81H;
    CRCtable[219] := 05B40H;
    CRCtable[220] := 09901H;
    CRCtable[221] := 059C0H;
    CRCtable[222] := 05880H;
    CRCtable[223] := 09841H;

    CRCtable[224] := 08801H;
    CRCtable[225] := 048C0H;
    CRCtable[226] := 04980H;
    CRCtable[227] := 08941H;
    CRCtable[228] := 04B00H;
    CRCtable[229] := 08BC1H;
    CRCtable[230] := 08A81H;
    CRCtable[231] := 04A40H;

    CRCtable[232] := 04E00H;
    CRCtable[233] := 08EC1H;
    CRCtable[234] := 08F81H;
    CRCtable[235] := 04F40H;
    CRCtable[236] := 08D01H;
    CRCtable[237] := 04DC0H;
    CRCtable[238] := 04C80H;
    CRCtable[239] := 08C41H;

    CRCtable[240] := 04400H;
    CRCtable[241] := 084C1H;
    CRCtable[242] := 08581H;
    CRCtable[243] := 04540H;
    CRCtable[244] := 08701H;
    CRCtable[245] := 047C0H;
    CRCtable[246] := 04680H;
    CRCtable[247] := 08641H;

    CRCtable[248] := 08201H;
    CRCtable[249] := 042C0H;
    CRCtable[250] := 04380H;
    CRCtable[251] := 08341H;
    CRCtable[252] := 04100H;
    CRCtable[253] := 081C1H;
    CRCtable[254] := 08081H;
    CRCtable[255] := 04040H;

END CRC.
