/* ----------------------------------------------------------------------- */
/* J-Source Version 7 - COPYRIGHT 1993 Iverson Software Inc.               */
/* 33 Major Street, Toronto, Ontario, Canada, M5S 2K9, (416) 925 6096      */
/*                                                                         */
/* J-Source is provided "as is" without warranty of any kind.              */
/*                                                                         */
/* J-Source Version 7 license agreement:  You may use, copy, and           */
/* modify the source.  You have a non-exclusive, royalty-free right        */
/* to redistribute source and executable files.                            */
/* ----------------------------------------------------------------------- */
/*                                                                         */
/* Character Definitions                                                   */


#define CX         0            /* other                                   */
#define CS         1            /* space or tab                            */
#define CA         2            /* letter                                  */
#define CN         3            /* N (capital N)                           */
#define CB         4            /* B (capital B)                           */
#define C9         5            /* digit or sign (underscore)              */
#define CD         6            /* dot                                     */
#define CC         7            /* colon                                   */
#define CQ         8            /* quote                                   */

#if (SYS & SYS_MACINTOSH)
#define CHome      1            /*   1 001 01                              */
#define CEnter     3            /*   3 003 03                              */
#define CEnd       4            /*   4 004 04                              */
#define CHelp      5            /*   5 005 05                              */
#define CDelete    8            /*   8 010 08                              */
#define CTab       9            /*   9 011 09                              */
#define CPageUp    11           /*  11 013 0b                              */
#define CPageDown  12           /*  12 014 0c                              */
#define CReturn    13           /*  13 015 0d                              */
#define CFunction  16           /*  16 020 10                              */
#define CEscClear  27           /*  27 033 1b                              */
#define CEsc       27           /*  27 033 1b                              */
#define CClear     27           /*  27 033 1b                              */
#define CLeft      28           /*  28 034 1c                              */
#define CRight     29           /*  29 035 1d                              */
#define CUp        30           /*  30 036 1e                              */
#define CDown      31           /*  31 037 1f                              */
#endif

#if (SYS & SYS_MACINTOSH)
#define CNL        '\r'         /*  13 015 0d     new line                 */
#else
#define CNL        '\n'         /*  10 012 0a     new line                 */
#endif

#if (SYS & SYS_PCWIN)
#define COFF       '\376'       /* 254 376 fe     JWin mapping             */
#else
#define COFF       '\004'       /*   4 004 04     ctrl d                   */
#endif

#define CESC1      '.'          /*  46 056 2e     1st escape char          */
#define CESC2      ':'          /*  58 072 3a     2nd escape char          */

#define COUT       '\000'       /*   0 000 00     output line marker       */
#define C0         '\000'       /*   0 000 00                              */
#define C1         '\001'       /*   1 001 01                              */
#define CTAB       '\011'       /*   9 011 09     tab                      */
#define CLF        '\012'       /*  10 012 0a     line feed                */
#define CCR        '\015'       /*  13 015 0d     carriage return          */
#define CEOF       '\032'       /*  26 032 1a     DOS end-of-file          */
#define CBANG      '!'          /*  33 041 21                              */
#define CQQ        '\042'       /*  34 042 22     double quote             */
#define CPOUND     '#'          /*  35 043 23                              */
#define CDOLLAR    '$'          /*  36 044 24                              */
#define CDIV       '%'          /*  37 045 25                              */
#define CAMP       '&'          /*  38 046 26                              */
#define CQUOTE     '\047'       /*  39 047 27     single quote             */
#define CLPAR      '('          /*  40 050 28                              */
#define CRPAR      ')'          /*  41 051 29                              */
#define CSTAR      '*'          /*  42 052 2a                              */
#define CPLUS      '+'          /*  43 053 2b                              */
#define CCOMMA     ','          /*  44 054 2c                              */
#define CMINUS     '-'          /*  45 055 2d                              */
#define CDOT       '.'          /*  46 056 2e                              */
#define CSLASH     '/'          /*  47 057 2f                              */
#define CCOLON     ':'          /*  58 072 3a                              */
#define CSEMICO    ';'          /*  59 073 3b                              */
#define CRAZE      ';'          /*  59 073 3b                              */
#define CBOX       '<'          /*  60 074 3c                              */
#define CLT        '<'          /*  60 074 3c                              */
#define CEQ        '='          /*  61 075 3d                              */
#define COPE       '>'          /*  62 076 3e                              */
#define CGT        '>'          /*  62 076 3e                              */
#define CQUERY     '?'          /*  63 077 3f                              */
#define CAT        '@'          /*  64 100 40                              */
#define CLEFT      '['          /*  91 133 5b                              */
#define CBSLASH    '\134'       /*  92 134 5c \   backslash                */
#define CRIGHT     ']'          /*  93 135 5d                              */
#define CEXP       '^'          /*  94 136 5e                              */
#define CSIGN      '_'          /*  95 137 5f     minus sign               */
#define CINF       '_'          /*  95 137 5f     infinity                 */
#define CGRAVE     '`'          /*  96 140 60                              */
#define CLBRACE    '{'          /* 123 173 7b                              */
#define CSTILE     '|'          /* 124 174 7c                              */
#define CRBRACE    '}'          /* 125 175 7d                              */
#define CTILDE     '~'          /* 126 176 7e                              */
#define CASGN      '\200'       /* 128 200 80 =.                           */
#define CGASGN     '\201'       /* 129 201 81 =:                           */
#define CFLOOR     '\202'       /* 130 202 82 <.                           */
#define CMIN       '\202'       /* 130 202 82 <.                           */
#define CLE        '\203'       /* 131 203 83 <:                           */
#define CCEIL      '\204'       /* 132 204 84 >.                           */
#define CMAX       '\204'       /* 132 204 84 >.                           */
#define CGE        '\205'       /* 133 205 85 >:                           */
#define CUSDOT     '\206'       /* 134 206 86 _.                           */
#define CUSCO      '\207'       /* 135 207 87 _:                           */
#define CRECT      '\210'       /* 136 210 88 +.                           */
#define COR        '\210'       /* 136 210 88 +.                           */
#define CDOUBLE    '\211'       /* 137 211 89 +:                           */
#define CNOR       '\211'       /* 137 211 89 +:                           */
#define CPOLAR     '\212'       /* 138 212 8a *.                           */
#define CAND       '\212'       /* 138 212 8a *.                           */
#define CSQUARE    '\213'       /* 139 213 8b *:                           */
#define CNAND      '\213'       /* 139 213 8b *:                           */
#define CNOT       '\214'       /* 140 214 8c -.                           */
#define CHALVE     '\215'       /* 141 215 8d -:                           */
#define CMATCH     '\215'       /* 141 215 8d -:                           */
#define CDOMINO    '\216'       /* 142 216 8e %.                           */
#define CSQRT      '\217'       /* 143 217 8f %:                           */
#define CROOT      '\217'       /* 143 217 8f %:                           */
#define CLOG       '\220'       /* 144 220 90 ^.                           */
#define CPOWOP     '\221'       /* 145 221 91 ^:                           */
#define CGOTO      '\222'       /* 146 222 92 $.                           */
#define CSELF      '\223'       /* 147 223 93 $:                           */
#define CNUB       '\224'       /* 148 224 94 ~.                           */
#define CNE        '\225'       /* 149 225 95 ~:                           */
#define CREV       '\226'       /* 150 226 96 |.                           */
#define CROT       '\226'       /* 150 226 96 |.                           */
#define CCANT      '\227'       /* 151 227 97 |:                           */
#define CDOTDOT    '\230'       /* 152 230 98 ..                           */
#define CDOTCO     '\231'       /* 153 231 99 .:                           */
#define COBVERSE   '\232'       /* 154 232 9a :.                           */
#define CADVERSE   '\233'       /* 155 233 9b ::                           */
#define CCOMDOT    '\234'       /* 156 234 9c ,.                           */
#define CLAMIN     '\235'       /* 157 235 9d ,:                           */
#define CCUT       '\236'       /* 158 236 9e ;.                           */
#define CWORDS     '\237'       /* 159 237 9f ;:                           */
#define CBASE      '\240'       /* 160 240 a0 #.                           */
#define CABASE     '\241'       /* 161 241 a1 #:                           */
#define CATDOT     '\242'       /* 162 242 a2 @.                           */
#define CATCO      '\243'       /* 163 243 a3 @:                           */
#define CSLDOT     '\244'       /* 164 244 a4 /.                           */
#define CGRADE     '\245'       /* 165 245 a5 /:                           */
#define CBSDOT     '\246'       /* 166 246 a6 \.                           */
#define CDGRADE    '\247'       /* 167 247 a7 \:                           */
#define CLEV       '\250'       /* 168 250 a8 [.                           */
#define CLBKCO     '\251'       /* 169 251 a9 [:                           */
#define CDEX       '\252'       /* 170 252 aa ].                           */
#define CRBKCO     '\253'       /* 171 253 ab ]:                           */
#define CHEAD      '\254'       /* 172 254 ac {.                           */
#define CTAKE      '\254'       /* 172 254 ac {.                           */
#define CTAIL      '\255'       /* 173 255 ad {:                           */
#define CBEHEAD    '\256'       /* 174 256 ae }.                           */
#define CDROP      '\256'       /* 174 256 ae }.                           */
#define CCTAIL     '\257'       /* 175 257 af }:                           */
#define CGRDOT     '\260'       /* 176 260 b0 `.                           */
#define CGRCO      '\261'       /* 177 261 b1 `:                           */
#define CEXEC      '\262'       /* 178 262 b2 ".                           */
#define CTHORN     '\263'       /* 179 263 b3 ":                           */
#define CUNDER     '\264'       /* 180 264 b4 &.                           */
#define CAMPCO     '\265'       /* 181 265 b5 &:                           */
#define CFIT       '\266'       /* 182 266 b6 !.                           */
#define CIBEAM     '\267'       /* 183 267 b7 !:                           */
#define CQRYDOT    '\270'       /* 184 270 b8 ?.                           */
#define CQRYCO     '\271'       /* 185 271 b9 ?:                           */
#define CALP       '\300'       /* 192 300 c0 a.                           */
#define CATOMIC    '\301'       /* 193 301 c1 A.                           */
#define CBOOL      '\302'       /* 194 302 c2 b.                           */
#define CEIGEN     '\303'       /* 195 303 c3 c.                           */
#define CCYCLE     '\304'       /* 196 304 c4 C.                           */
#define CDDOT      '\305'       /* 197 305 c5 D.                           */
#define CEPS       '\306'       /* 198 306 c6 e.                           */
#define CEBAR      '\307'       /* 199 307 c7 E.                           */
#define CFIX       '\310'       /* 200 310 c8 f.                           */
#define CIOTA      '\311'       /* 201 311 c9 i.                           */
#define CJDOT      '\312'       /* 202 312 ca j.                           */
#define CCIRCLE    '\313'       /* 203 313 cb o.                           */
#define CPOLY      '\314'       /* 204 314 cc p.                           */
#define CRDOT      '\315'       /* 205 315 cd r.                           */
#define CTEXT      '\316'       /* 206 316 ce s.                           */
#define CTAYLOR    '\317'       /* 207 317 cf t.                           */
#define CTAYN      '\320'       /* 208 320 d0 T.                           */
#define CALPHA     '\321'       /* 209 321 d1 x.                           */
#define COMEGA     '\322'       /* 210 322 d2 y.                           */
#define CZERO      '\340'       /* 224 340 e0 0:                           */
#define CONE       '\341'       /* 225 341 e1 1:                           */
#define CTWO       '\342'       /* 226 342 e2 2:                           */
#define CTHREE     '\343'       /* 227 343 e3 3:                           */
#define CFOUR      '\344'       /* 228 344 e4 4:                           */
#define CFIVE      '\345'       /* 229 345 e5 5:                           */
#define CSIX       '\346'       /* 230 346 e6 6:                           */
#define CSEVEN     '\347'       /* 231 347 e7 7:                           */
#define CEIGHT     '\350'       /* 232 350 e8 8:                           */
#define CNINE      '\351'       /* 233 351 e9 9:                           */
#define CHOOK      '\352'       /* 234 352 ea                              */
#define CFORK      '\353'       /* 235 353 eb                              */
#define CADVF      '\354'       /* 236 354 ec     bonded conjunction       */
#define CHOOKO     '\355'       /* 237 355 ed                              */
#define CFORKO     '\356'       /* 238 356 ee                              */
