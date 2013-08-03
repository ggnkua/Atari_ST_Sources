; resource set indices for GERMAN
;
MENUE    equ 0 ; form/dialog
PATCH    equ 16 ; FBOXTEXT in MENUE
CONF     equ 17 ; FBOXTEXT in MENUE

INFO     equ 1 ; form/dialog
_VERSION equ 3 ; STRING in INFO

SCRPARAM equ 2 ; form/dialog
_BOX     equ 1 ; IBOX in SCRPARAM
_OFFSETX equ 2 ; FTEXT in SCRPARAM
_OFFSETY equ 3 ; FTEXT in SCRPARAM
_BREITE  equ 4 ; FTEXT in SCRPARAM
_LAENGE  equ 5 ; FTEXT in SCRPARAM
_HOEHE   equ 6 ; FTEXT in SCRPARAM
_SBREITE equ 7 ; FTEXT in SCRPARAM
_SHOEHE  equ 8 ; FTEXT in SCRPARAM
_PLANES  equ 9 ; FTEXT in SCRPARAM
_TITLE   equ 10 ; TEXT in SCRPARAM
_F_8_16  equ 12 ; BUTTON in SCRPARAM
_F_8_8   equ 13 ; BUTTON in SCRPARAM
_FONT16  equ 16 ; FBOXTEXT in SCRPARAM
_FONT8   equ 17 ; FBOXTEXT in SCRPARAM
_OFFSETX2 equ 20 ; FTEXT in SCRPARAM
_OFFSETY2 equ 21 ; FTEXT in SCRPARAM
_BREITE2 equ 22 ; FTEXT in SCRPARAM
_HOEHE2  equ 23 ; FTEXT in SCRPARAM
_PLANES2 equ 24 ; FTEXT in SCRPARAM
_SLENGTH equ 26 ; FTEXT in SCRPARAM
_ZLENGTH equ 27 ; FTEXT in SCRPARAM
_MLENGTH equ 28 ; FTEXT in SCRPARAM
_ST      equ 29 ; FBOXTEXT in SCRPARAM
_F030    equ 30 ; FBOXTEXT in SCRPARAM
_TT      equ 31 ; FBOXTEXT in SCRPARAM
_REGISTER equ 35 ; BUTTON in SCRPARAM
_PALETTE equ 36 ; BUTTON in SCRPARAM
_ABBRUCH1 equ 38 ; BUTTON in SCRPARAM
_SETZEN1 equ 39 ; BUTTON in SCRPARAM
_OK1     equ 40 ; BUTTON in SCRPARAM

FLAGBOX  equ 3 ; form/dialog
_FLAG11  equ 2 ; STRING in FLAGBOX
_PRIVILEG equ 8 ; STRING in FLAGBOX
_FLAG12  equ 17 ; STRING in FLAGBOX
_FLAG21  equ 18 ; STRING in FLAGBOX
_FLAG22  equ 33 ; STRING in FLAGBOX
_FLAG31  equ 34 ; STRING in FLAGBOX
_RESETFLAG equ 49 ; STRING in FLAGBOX
_BOX_1   equ 50 ; IBOX in FLAGBOX
_DEBUGGER equ 51 ; BUTTON in FLAGBOX
_ORIGINAL equ 52 ; BUTTON in FLAGBOX
_IGNORE  equ 53 ; BUTTON in FLAGBOX
_BOX_3   equ 54 ; BOX in FLAGBOX
_SR_EA   equ 55 ; BUTTON in FLAGBOX
_ALWAYS  equ 56 ; BUTTON in FLAGBOX
_CCR_EA  equ 57 ; BUTTON in FLAGBOX
_ONCEASEC equ 58 ; BUTTON in FLAGBOX
_BOX2    equ 59 ; IBOX in FLAGBOX
_AUSHAENG equ 60 ; BUTTON in FLAGBOX
_EINHAENG equ 61 ; BUTTON in FLAGBOX
_POS1ST  equ 62 ; BUTTON in FLAGBOX
_ABBRUCH2 equ 63 ; BUTTON in FLAGBOX
_SETZEN2 equ 64 ; BUTTON in FLAGBOX
_OK2     equ 65 ; BUTTON in FLAGBOX

CACHE    equ 4 ; form/dialog
_LENGTH  equ 2 ; STRING in CACHE
_LENGTH1 equ 3 ; STRING in CACHE
_LENGTH2 equ 4 ; STRING in CACHE
_ADD1    equ 5 ; FTEXT in CACHE
_ADD2    equ 6 ; FTEXT in CACHE
_HIST_KB equ 9 ; STRING in CACHE
_HIST_NR equ 10 ; STRING in CACHE
_HISTORY equ 11 ; FTEXT in CACHE
_ABBRUCH3 equ 13 ; BUTTON in CACHE
_SETZEN3 equ 14 ; BUTTON in CACHE
_OK3     equ 15 ; BUTTON in CACHE

KEYBOARD equ 5 ; form/dialog
_KEYS    equ 2 ; IBOX in KEYBOARD
K59      equ 3 ; BOXCHAR in KEYBOARD
K60      equ 4 ; BOXCHAR in KEYBOARD
K61      equ 5 ; BOXCHAR in KEYBOARD
K62      equ 6 ; BOXCHAR in KEYBOARD
K63      equ 7 ; BOXCHAR in KEYBOARD
K64      equ 8 ; BOXCHAR in KEYBOARD
K65      equ 9 ; BOXCHAR in KEYBOARD
K66      equ 10 ; BOXCHAR in KEYBOARD
K67      equ 11 ; BOXCHAR in KEYBOARD
K68      equ 12 ; BOXCHAR in KEYBOARD
K1       equ 13 ; BOXCHAR in KEYBOARD
K2       equ 14 ; BOXCHAR in KEYBOARD
K3       equ 15 ; BOXCHAR in KEYBOARD
K4       equ 16 ; BOXCHAR in KEYBOARD
K5       equ 17 ; BOXCHAR in KEYBOARD
K6       equ 18 ; BOXCHAR in KEYBOARD
K7       equ 19 ; BOXCHAR in KEYBOARD
K8       equ 20 ; BOXCHAR in KEYBOARD
K9       equ 21 ; BOXCHAR in KEYBOARD
K10      equ 22 ; BOXCHAR in KEYBOARD
K11      equ 23 ; BOXCHAR in KEYBOARD
K12      equ 24 ; BOXCHAR in KEYBOARD
K13      equ 25 ; BOXCHAR in KEYBOARD
K41      equ 26 ; BOXCHAR in KEYBOARD
K14      equ 27 ; BOXCHAR in KEYBOARD
K98      equ 28 ; BOXCHAR in KEYBOARD
K97      equ 29 ; BOXCHAR in KEYBOARD
K99      equ 30 ; BOXCHAR in KEYBOARD
K100     equ 31 ; BOXCHAR in KEYBOARD
K101     equ 32 ; BOXCHAR in KEYBOARD
K102     equ 33 ; BOXCHAR in KEYBOARD
K15      equ 34 ; BOXCHAR in KEYBOARD
K16      equ 35 ; BOXCHAR in KEYBOARD
K17      equ 36 ; BOXCHAR in KEYBOARD
K18      equ 37 ; BOXCHAR in KEYBOARD
K19      equ 38 ; BOXCHAR in KEYBOARD
K20      equ 39 ; BOXCHAR in KEYBOARD
K21      equ 40 ; BOXCHAR in KEYBOARD
K22      equ 41 ; BOXCHAR in KEYBOARD
K23      equ 42 ; BOXCHAR in KEYBOARD
K24      equ 43 ; BOXCHAR in KEYBOARD
K25      equ 44 ; BOXCHAR in KEYBOARD
K26      equ 45 ; BOXCHAR in KEYBOARD
K27      equ 46 ; BOXCHAR in KEYBOARD
K28      equ 47 ; BOXCHAR in KEYBOARD
K83      equ 48 ; BOXCHAR in KEYBOARD
K82      equ 49 ; BOXCHAR in KEYBOARD
K72      equ 50 ; BOXCHAR in KEYBOARD
K71      equ 51 ; BOXCHAR in KEYBOARD
K103     equ 52 ; BOXCHAR in KEYBOARD
K104     equ 53 ; BOXCHAR in KEYBOARD
K105     equ 54 ; BOXCHAR in KEYBOARD
K74      equ 55 ; BOXCHAR in KEYBOARD
K29      equ 56 ; BOXCHAR in KEYBOARD
K30      equ 57 ; BOXCHAR in KEYBOARD
K31      equ 58 ; BOXCHAR in KEYBOARD
K32      equ 59 ; BOXCHAR in KEYBOARD
K33      equ 60 ; BOXCHAR in KEYBOARD
K34      equ 61 ; BOXCHAR in KEYBOARD
K35      equ 62 ; BOXCHAR in KEYBOARD
K36      equ 63 ; BOXCHAR in KEYBOARD
K37      equ 64 ; BOXCHAR in KEYBOARD
K38      equ 65 ; BOXCHAR in KEYBOARD
K39      equ 66 ; BOXCHAR in KEYBOARD
K40      equ 67 ; BOXCHAR in KEYBOARD
K43      equ 68 ; BOXCHAR in KEYBOARD
K75      equ 69 ; BOXCHAR in KEYBOARD
K80      equ 70 ; BOXCHAR in KEYBOARD
K77      equ 71 ; BOXCHAR in KEYBOARD
K106     equ 72 ; BOXCHAR in KEYBOARD
K107     equ 73 ; BOXCHAR in KEYBOARD
K108     equ 74 ; BOXCHAR in KEYBOARD
K78      equ 75 ; BOXCHAR in KEYBOARD
K42      equ 76 ; BOXCHAR in KEYBOARD
K96      equ 77 ; BOXCHAR in KEYBOARD
K44      equ 78 ; BOXCHAR in KEYBOARD
K45      equ 79 ; BOXCHAR in KEYBOARD
K46      equ 80 ; BOXCHAR in KEYBOARD
K47      equ 81 ; BOXCHAR in KEYBOARD
K48      equ 82 ; BOXCHAR in KEYBOARD
K49      equ 83 ; BOXCHAR in KEYBOARD
K50      equ 84 ; BOXCHAR in KEYBOARD
K51      equ 85 ; BOXCHAR in KEYBOARD
K52      equ 86 ; BOXCHAR in KEYBOARD
K53      equ 87 ; BOXCHAR in KEYBOARD
K54      equ 88 ; BOXCHAR in KEYBOARD
K109     equ 89 ; BOXCHAR in KEYBOARD
K110     equ 90 ; BOXCHAR in KEYBOARD
K111     equ 91 ; BOXCHAR in KEYBOARD
K114     equ 92 ; BOXCHAR in KEYBOARD
M1       equ 93 ; BOXCHAR in KEYBOARD
M2       equ 94 ; BOXCHAR in KEYBOARD
K56      equ 95 ; BOXCHAR in KEYBOARD
K57      equ 96 ; BOXCHAR in KEYBOARD
K112     equ 97 ; BOXCHAR in KEYBOARD
K113     equ 98 ; BOXCHAR in KEYBOARD
_JUMPIN1 equ 99 ; BUTTON in KEYBOARD
_JUMPIN2 equ 100 ; BUTTON in KEYBOARD
_ABBRUCH4 equ 101 ; BUTTON in KEYBOARD
_SETZEN4 equ 102 ; BUTTON in KEYBOARD
_OK4     equ 103 ; BUTTON in KEYBOARD

SPEED    equ 6 ; form/dialog
SPEEDBOX equ 0 ; BOX in SPEED
_S1      equ 2 ; TEXT in SPEED
_S2      equ 3 ; TEXT in SPEED
_S3      equ 4 ; TEXT in SPEED
_S4      equ 5 ; TEXT in SPEED
_S5      equ 6 ; TEXT in SPEED
_S6      equ 7 ; TEXT in SPEED
_DOWN1   equ 8 ; BOXCHAR in SPEED
_DOWN2   equ 9 ; BOXCHAR in SPEED
_DOWN3   equ 10 ; BOXCHAR in SPEED
_DOWN4   equ 11 ; BOXCHAR in SPEED
_DOWN5   equ 12 ; BOXCHAR in SPEED
_DOWN6   equ 13 ; BOXCHAR in SPEED
_UP1     equ 14 ; BOXCHAR in SPEED
_UP2     equ 15 ; BOXCHAR in SPEED
_UP3     equ 16 ; BOXCHAR in SPEED
_UP4     equ 17 ; BOXCHAR in SPEED
_UP5     equ 18 ; BOXCHAR in SPEED
_UP6     equ 19 ; BOXCHAR in SPEED
_ABBRUCH5 equ 21 ; BUTTON in SPEED
_SETZEN5 equ 22 ; BUTTON in SPEED
_OK5     equ 23 ; BUTTON in SPEED

PRIORITA equ 7 ; form/dialog
_PLUS    equ 2 ; TEXT in PRIORITA
_MINUS   equ 3 ; TEXT in PRIORITA
_MULU    equ 4 ; TEXT in PRIORITA
_DIVU    equ 5 ; TEXT in PRIORITA
_ODER    equ 6 ; TEXT in PRIORITA
_AND     equ 7 ; TEXT in PRIORITA
_EOR     equ 8 ; TEXT in PRIORITA
_SHIFT   equ 9 ; TEXT in PRIORITA
_KOMPL1  equ 10 ; TEXT in PRIORITA
_KOMPL2  equ 11 ; TEXT in PRIORITA
_MODULO  equ 12 ; TEXT in PRIORITA
_POINTER equ 13 ; TEXT in PRIORITA
_KLAMMER equ 14 ; TEXT in PRIORITA
_UP      equ 16 ; BOXCHAR in PRIORITA
_DOWN    equ 17 ; BOXCHAR in PRIORITA
_ABBRUCH6 equ 18 ; BUTTON in PRIORITA
_SETZEN6 equ 19 ; BUTTON in PRIORITA
_OK6     equ 20 ; BUTTON in PRIORITA

USER     equ 8 ; form/dialog
_TRACE   equ 2 ; BUTTON in USER
_ENTER   equ 3 ; BUTTON in USER
_QUIT    equ 4 ; BUTTON in USER
_SWITCH1 equ 5 ; BUTTON in USER
_SWITCH2 equ 6 ; BUTTON in USER
_RESET   equ 7 ; BUTTON in USER
_TRACE_X equ 8 ; TEXT in USER
_ENTER_X equ 9 ; TEXT in USER
_QUIT_X  equ 10 ; TEXT in USER
_SWITCH1X equ 11 ; TEXT in USER
_SWITCH2X equ 12 ; TEXT in USER
_RESET_X equ 13 ; TEXT in USER
_OK7     equ 14 ; BUTTON in USER

PARAM    equ 9 ; form/dialog
_INSERT  equ 2 ; BUTTON in PARAM
_OVERWRIT equ 3 ; BUTTON in PARAM
_ALL     equ 6 ; BUTTON in PARAM
_TEILS   equ 7 ; BUTTON in PARAM
_NONE    equ 8 ; BUTTON in PARAM
_KREPEAT equ 11 ; FTEXT in PARAM
_KDELAY  equ 12 ; FTEXT in PARAM
_MREPEAT equ 13 ; FTEXT in PARAM
_MDELAY  equ 14 ; FTEXT in PARAM
_PARALLEL equ 17 ; FTEXT in PARAM
_RS232   equ 18 ; FTEXT in PARAM
_MIDI    equ 19 ; FTEXT in PARAM
_ABBRUCH8 equ 21 ; BUTTON in PARAM
_SETZEN8 equ 22 ; BUTTON in PARAM
_OK8     equ 23 ; BUTTON in PARAM
_CHEAT    equ 24 ; BUTTON in PARAM

KONFIG   equ 10 ; form/dialog
_SET1    equ 2 ; BUTTON in KONFIG
_SET2    equ 3 ; BUTTON in KONFIG
_SET3    equ 4 ; BUTTON in KONFIG
_SET4    equ 5 ; BUTTON in KONFIG
_SET5    equ 6 ; BUTTON in KONFIG
_SET6    equ 7 ; BUTTON in KONFIG
_SET7    equ 8 ; BUTTON in KONFIG
_ABBRUCH9 equ 10 ; BUTTON in KONFIG
_SETZEN9 equ 11 ; BUTTON in KONFIG
_OK9     equ 12 ; BUTTON in KONFIG


string_0:	dc.b 0
string_1:	dc.b "  Information        ^I ",0
string_2:	dc.b 0
string_3:	dc.b "------------------------",0
string_4:	dc.b 0
string_5:	dc.b "  Vektoren           ^V ",0
string_6:	dc.b 0
string_7:	dc.b 0
string_8:	dc.b "  Cache              ^C ",0
string_9:	dc.b 0
string_10:	dc.b 0
string_11:	dc.b "  Keyboard           ^K ",0
string_12:	dc.b 0
string_13:	dc.b 0
string_14:	dc.b "  Diverses           ^D ",0
string_15:	dc.b 0
string_16:	dc.b 0
string_17:	dc.b "  Bildschirm         ^B ",0
string_18:	dc.b 0
string_19:	dc.b 0
string_20:	dc.b "  PrioritÑten        ^P ",0
string_21:	dc.b 0
string_22:	dc.b 0
string_23:	dc.b "  Userroutinen       ^R ",0
string_24:	dc.b 0
string_25:	dc.b 0
string_26:	dc.b "  Beschleuniger      ^A ",0
string_27:	dc.b 0
string_28:	dc.b "------------------------",0
string_29:	dc.b 0
string_30:	dc.b "  Parameter laden    ^O ",0
string_31:	dc.b 0
string_32:	dc.b 0
string_33:	dc.b "  Parameter sichern  ^S ",0
string_34:	dc.b 0
string_35:	dc.b "------------------------",0
string_36:	dc.b 0
string_37:	dc.b "  Konfigurieren      ^E ",0
string_38:	dc.b 0
string_39:	dc.b 0
string_40:	dc.b "  Patchmodus         ^T ",0
string_41:	dc.b 0
string_42:	dc.b 0
string_43:	dc.b "  Peacebug 0         ^T ",0
string_44:	dc.b 0
string_45:	dc.b "Peacebug V00.00",0
string_46:	dc.b "written by:",0
string_47:	dc.b "Emanuel Mîcklin",0
string_48:	dc.b "Zschokkestrasse 7",0
string_49:	dc.b "CH-8037 ZÅrich",0
string_50:	dc.b "00000",0
string_51:	dc.b "Offset x:      _____",0
string_52:	dc.b "99999",0
string_53:	dc.b "00000",0
string_54:	dc.b "Offset y:      _____",0
string_55:	dc.b "99999",0
string_56:	dc.b "00000",0
string_57:	dc.b "Bild Breite:   _____",0
string_58:	dc.b "99999",0
string_59:	dc.b "00000",0
string_60:	dc.b "Zeilen LÑnge:  _____",0
string_61:	dc.b "99999",0
string_62:	dc.b "00000",0
string_63:	dc.b "Bild Hîhe:     _____",0
string_64:	dc.b "99999",0
string_65:	dc.b "00000",0
string_66:	dc.b "Screen Breite: _____",0
string_67:	dc.b "99999",0
string_68:	dc.b "00000",0
string_69:	dc.b "Screen Hîhe:   _____",0
string_70:	dc.b "99999",0
string_71:	dc.b "00000",0
string_72:	dc.b "Planes:        _____",0
string_73:	dc.b "99999",0
string_74:	dc.b " Einstellungen ",0
string_75:	dc.b 0
string_76:	dc.b 0
string_77:	dc.b "8*16",0
string_78:	dc.b "8*8",0
string_79:	dc.b " Font aktiv ",0
string_80:	dc.b 0
string_81:	dc.b 0
string_82:	dc.b 0
string_83:	dc.b "8*16",0
string_84:	dc.b 0
string_85:	dc.b 0
string_86:	dc.b "8*8",0
string_87:	dc.b 0
string_88:	dc.b " Font laden ",0
string_89:	dc.b 0
string_90:	dc.b 0
string_91:	dc.b "00000",0
string_92:	dc.b "Offset x:      _____",0
string_93:	dc.b "99999",0
string_94:	dc.b "00000",0
string_95:	dc.b "Offset y:      _____",0
string_96:	dc.b "99999",0
string_97:	dc.b "00000",0
string_98:	dc.b "Bild Breite:   _____",0
string_99:	dc.b "99999",0
string_100:	dc.b "00000",0
string_101:	dc.b "Bild Hîhe:     _____",0
string_102:	dc.b "99999",0
string_103:	dc.b "00000",0
string_104:	dc.b "Planes:        _____",0
string_105:	dc.b "99999",0
string_106:	dc.b "000000",0
string_107:	dc.b "Bildschirm:   ______",0
string_108:	dc.b "999999",0
string_109:	dc.b "000000",0
string_110:	dc.b "Zeichen:      ______",0
string_111:	dc.b "999999",0
string_112:	dc.b "000000",0
string_113:	dc.b "Maus:         ______",0
string_114:	dc.b "999999",0
string_115:	dc.b 0
string_116:	dc.b "ST",0
string_117:	dc.b 0
string_118:	dc.b 0
string_119:	dc.b "F030",0
string_120:	dc.b 0
string_121:	dc.b 0
string_122:	dc.b "TT",0
string_123:	dc.b 0
string_124:	dc.b " Puffer-Vorgaben ",0
string_125:	dc.b 0
string_126:	dc.b 0
string_127:	dc.b " Vorgaben ",0
string_128:	dc.b 0
string_129:	dc.b 0
string_130:	dc.b "Register",0
string_131:	dc.b "Palette",0
string_132:	dc.b " Umschalten ",0
string_133:	dc.b 0
string_134:	dc.b 0
string_135:	dc.b "Abbruch",0
string_136:	dc.b "Setzen",0
string_137:	dc.b "OK",0
string_138:	dc.b "Bus",0
string_139:	dc.b "Address",0
string_140:	dc.b "Illegal",0
string_141:	dc.b "Division",0
string_142:	dc.b "Chk",0
string_143:	dc.b "Trapv/cc",0
string_144:	dc.b "Privileg",0
string_145:	dc.b "Trace",0
string_146:	dc.b "Linea",0
string_147:	dc.b "Linef",0
string_148:	dc.b "CP_Protocol",0
string_149:	dc.b "Format",0
string_150:	dc.b "Uninit. I.",0
string_151:	dc.b "Spurious",0
string_152:	dc.b "VBL",0
string_153:	dc.b "NMI",0
string_154:	dc.b "Trap 0",0
string_155:	dc.b "GEMDOS",0
string_156:	dc.b "VDI",0
string_157:	dc.b "AES",0
string_158:	dc.b "Trap 3",0
string_159:	dc.b "Trap 4",0
string_160:	dc.b "Trap 5",0
string_161:	dc.b "Trap 6",0
string_162:	dc.b "Trap 7",0
string_163:	dc.b "Trap 8",0
string_164:	dc.b "Trap 9",0
string_165:	dc.b "Trap 10",0
string_166:	dc.b "Trap 11",0
string_167:	dc.b "Trap 12",0
string_168:	dc.b "BIOS",0
string_169:	dc.b "XBIOS",0
string_170:	dc.b "Trap 15",0
string_171:	dc.b "FPCP Branch",0
string_172:	dc.b "FPCP Inexact",0
string_173:	dc.b "FPCP Divide",0
string_174:	dc.b "FPCP Underf.",0
string_175:	dc.b "FPCP Operand",0
string_176:	dc.b "FPCP Overf.",0
string_177:	dc.b "FPCP NAN",0
string_178:	dc.b "PMMU Config",0
string_179:	dc.b "PMMU Illegal",0
string_180:	dc.b "PMMU Access",0
string_181:	dc.b "200HZ Timer",0
string_182:	dc.b "Keyboard",0
string_183:	dc.b "Ring Ind.",0
string_184:	dc.b "ETV_CRITIC",0
string_185:	dc.b "Reset",0
string_186:	dc.b "Debugger",0
string_187:	dc.b "Original",0
string_188:	dc.b "Ignorieren",0
string_189:	dc.b "SR,<ea>",0
string_190:	dc.b "Immer",0
string_191:	dc.b "CCR,<ea>",0
string_192:	dc.b "1mal/Sek.",0
string_193:	dc.b "aushÑngen",0
string_194:	dc.b "einhÑngen",0
string_195:	dc.b "1. Position",0
string_196:	dc.b "Abbruch",0
string_197:	dc.b "Setzen",0
string_198:	dc.b "OK",0
string_199:	dc.b " Exceptions ",0
string_200:	dc.b 0
string_201:	dc.b 0
string_202:	dc.b " Aktion ",0
string_203:	dc.b 0
string_204:	dc.b 0
string_205:	dc.b " VEKTOR ",0
string_206:	dc.b 0
string_207:	dc.b 0
string_208:	dc.b "LÑnge pro Eintrag: 99999",0
string_209:	dc.b "LÑnge Cache 1:     99999",0
string_210:	dc.b "LÑnge Cache 2:     99999",0
string_211:	dc.b "99999",0
string_212:	dc.b "Erweitern Cache 1: _____",0
string_213:	dc.b "99999",0
string_214:	dc.b "99999",0
string_215:	dc.b "Erweitern Cache 2: _____",0
string_216:	dc.b "99999",0
string_217:	dc.b " Cache ",0
string_218:	dc.b 0
string_219:	dc.b 0
string_220:	dc.b "HistorylÑnge:      99999",0
string_221:	dc.b "Aktuelle Anzahl:   99999",0
string_222:	dc.b "99999",0
string_223:	dc.b "Neue LÑnge:        _____",0
string_224:	dc.b "99999",0
string_225:	dc.b " History ",0
string_226:	dc.b 0
string_227:	dc.b 0
string_228:	dc.b "Abbruch",0
string_229:	dc.b "Setzen",0
string_230:	dc.b "OK",0
string_231:	dc.b "Einsprung 1",0
string_232:	dc.b "Einsprung 2",0
string_233:	dc.b "Abbruch",0
string_234:	dc.b "Setzen",0
string_235:	dc.b "OK",0
string_236:	dc.b "+ 999/128 * s^1",0
string_237:	dc.b 0
string_238:	dc.b 0
string_239:	dc.b "+ 999/128 * s^2",0
string_240:	dc.b 0
string_241:	dc.b 0
string_242:	dc.b "+ 999/128 * s^3",0
string_243:	dc.b 0
string_244:	dc.b 0
string_245:	dc.b "+ 999/128 * s^4",0
string_246:	dc.b 0
string_247:	dc.b 0
string_248:	dc.b "+ 999/128 * s^5",0
string_249:	dc.b 0
string_250:	dc.b 0
string_251:	dc.b "+ 999/128 * s^6",0
string_252:	dc.b 0
string_253:	dc.b 0
string_254:	dc.b " f(s)= ",0
string_255:	dc.b 0
string_256:	dc.b 0
string_257:	dc.b "Abbruch",0
string_258:	dc.b "Setzen",0
string_259:	dc.b "OK",0
string_260:	dc.b "Addition: 99999",0
string_261:	dc.b 0
string_262:	dc.b 0
string_263:	dc.b "Subtrak.: 99999",0
string_264:	dc.b 0
string_265:	dc.b 0
string_266:	dc.b "Multipl.: 99999",0
string_267:	dc.b 0
string_268:	dc.b 0
string_269:	dc.b "Division: 99999",0
string_270:	dc.b 0
string_271:	dc.b 0
string_272:	dc.b "Oder:     99999",0
string_273:	dc.b 0
string_274:	dc.b 0
string_275:	dc.b "And:      99999",0
string_276:	dc.b 0
string_277:	dc.b 0
string_278:	dc.b "Eor:      99999",0
string_279:	dc.b 0
string_280:	dc.b 0
string_281:	dc.b "Shiften:  99999",0
string_282:	dc.b 0
string_283:	dc.b 0
string_284:	dc.b "1er Kom.: 99999",0
string_285:	dc.b 0
string_286:	dc.b 0
string_287:	dc.b "2er Kom.: 99999",0
string_288:	dc.b 0
string_289:	dc.b 0
string_290:	dc.b "Modulo:   99999",0
string_291:	dc.b 0
string_292:	dc.b 0
string_293:	dc.b "Pointer:  99999",0
string_294:	dc.b 0
string_295:	dc.b 0
string_296:	dc.b "Klammer:  99999",0
string_297:	dc.b 0
string_298:	dc.b 0
string_299:	dc.b " PrioritÑten ",0
string_300:	dc.b 0
string_301:	dc.b 0
string_302:	dc.b "Abbruch",0
string_303:	dc.b "Setzen",0
string_304:	dc.b "OK",0
string_305:	dc.b "USER_TRACE",0
string_306:	dc.b "USER_ENTER",0
string_307:	dc.b "USER_QUIT",0
string_308:	dc.b "USER_SWITCH_ENTER",0
string_309:	dc.b "USER_SWITCH_QUIT",0
string_310:	dc.b "USER_RESET",0
string_311:	dc.b $22,"PBUG",$22,0
string_312:	dc.b 0
string_313:	dc.b 0
string_314:	dc.b $22,"PBUG",$22,0
string_315:	dc.b 0
string_316:	dc.b 0
string_317:	dc.b $22,"PBUG",$22,0
string_318:	dc.b 0
string_319:	dc.b 0
string_320:	dc.b $22,"PBUG",$22,0
string_321:	dc.b 0
string_322:	dc.b 0
string_323:	dc.b $22,"PBUG",$22,0
string_324:	dc.b 0
string_325:	dc.b 0
string_326:	dc.b $22,"PBUG",$22,0
string_327:	dc.b 0
string_328:	dc.b 0
string_329:	dc.b "OK",0
string_330:	dc.b "Insert",0
string_331:	dc.b "Overwrite",0
string_332:	dc.b " Cursor ",0
string_333:	dc.b 0
string_334:	dc.b 0
string_335:	dc.b "Alle",0
string_336:	dc.b "Debugger",0
string_337:	dc.b "Keine",0
string_338:	dc.b " Symbole ",0
string_339:	dc.b 0
string_340:	dc.b 0
string_341:	dc.b "9999",0
string_342:	dc.b "Keyrepeat:  ____",0
string_343:	dc.b "9999",0
string_344:	dc.b "9999",0
string_345:	dc.b "Keydelay:   ____",0
string_346:	dc.b "9999",0
string_347:	dc.b "9999",0
string_348:	dc.b "Mausrepeat: ____",0
string_349:	dc.b "9999",0
string_350:	dc.b "9999",0
string_351:	dc.b "Mausdelay:  ____",0
string_352:	dc.b "9999",0
string_353:	dc.b " Tastatur+Maus ",0
string_354:	dc.b 0
string_355:	dc.b 0
string_356:	dc.b "9999",0
string_357:	dc.b "Centronics: ____",0
string_358:	dc.b "9999",0
string_359:	dc.b "9999",0
string_360:	dc.b "RS232:      ____",0
string_361:	dc.b "9999",0
string_362:	dc.b "9999",0
string_363:	dc.b "MIDI:       ____",0
string_364:	dc.b "9999",0
string_365:	dc.b " Timeout ",0
string_366:	dc.b 0
string_367:	dc.b 0
string_368:	dc.b "Abbruch",0
string_369:	dc.b "Setzen",0
string_370:	dc.b "OK",0
string_371:	dc.b "Cheat",0
string_372:	dc.b "Cache",0
string_373:	dc.b "History",0
string_374:	dc.b "Invert",0
string_375:	dc.b "Getrez",0
string_376:	dc.b "Newfont",0
string_377:	dc.b "NewFormat",0
string_378:	dc.b "NewScreen",0
string_379:	dc.b " Konfigurieren ",0
string_380:	dc.b 0
string_381:	dc.b 0
string_382:	dc.b "Abbruch",0
string_383:	dc.b "Setzen",0
string_384:	dc.b "OK",0


IMAGE0:	dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w $0000,$0000,$0000,$0000,$0007,$FFE1,$FFFC,$3FFE
	dc.w $1FFF,$C7FF,$F1FF,$F870,$071F,$FFC0,$0007,$FFF1
	dc.w $FFFC,$7FFF,$1FFF,$C7FF,$F1FF,$FC70,$071F,$FFC0
	dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w $0000,$0000,$000F,$FFE3,$FFF8,$FFFE,$3FFF,$8FFF
	dc.w $E3FF,$F8E0,$0E3F,$FF80,$000F,$FFE3,$FFF0,$FFFE
	dc.w $3FFF,$0FFF,$C3FF,$F8E0,$0E3F,$FF00,$0000,$0000
	dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w $001C,$01C7,$0001,$C01C,$7000,$1C00,$0700,$71C0
	dc.w $1C70,$0000,$001C,$01C7,$0001,$C01C,$7000,$1C00
	dc.w $0700,$71C0,$1C70,$0000,$0000,$0000,$0000,$0000
	dc.w $0000,$0000,$0000,$0000,$0000,$0000,$003F,$FF8F
	dc.w $FC03,$FFF8,$E000,$3FF8,$0FFF,$C380,$38E0,$FE00
	dc.w $003F,$FF8F,$FE03,$FFF8,$E000,$3FF8,$0FFF,$C380
	dc.w $38E0,$FE00,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w $0000,$0000,$0000,$0000,$007F,$FF1F,$FC07,$FFF1
	dc.w $C000,$7FF0,$1FFF,$8700,$71C1,$FC00,$007F,$FE1F
	dc.w $F807,$FFF1,$C000,$7FE0,$1FFF,$8700,$71C1,$FC00
	dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w $0000,$0000,$00E0,$0038,$000E,$00E3,$8000,$E000
	dc.w $3803,$8E00,$E380,$3800,$00E0,$0038,$000E,$00E3
	dc.w $8000,$E000,$3803,$8E00,$E380,$3800,$0000,$0000
	dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w $01C0,$007F,$FF1C,$01C7,$FFF1,$FFFC,$7FFF,$1FFF
	dc.w $C7FF,$F000,$01C0,$007F,$FF1C,$01C7,$FFF1,$FFFC
	dc.w $7FFF,$1FFF,$C7FF,$F000,$0000,$0000,$0000,$0000
	dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0380,$00FF
	dc.w $FE38,$038F,$FFE3,$FFF8,$FFFE,$3FFF,$8FFF,$E000
	dc.w $0380,$00FF,$FC38,$038F,$FFC3,$FFF0,$FFFC,$3FFF
	dc.w $0FFF,$C000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w $0000,$0000,$0000,$0000,$0000,$0000


rs_frstr:	dc.l 0


rs_bitblk:	dc.l IMAGE0
	dc.w 20,27,0,0,2


rs_frimg:	dc.l 0


rs_tedinfo:	dc.l string_0,string_1,string_2
	dc.w 3,257,0,$1181,$AE2A,0,1,25
	dc.l string_4,string_5,string_6
	dc.w 3,257,0,$1181,$5A84,0,1,25
	dc.l string_7,string_8,string_9
	dc.w 3,0,0,$1181,$0,0,1,25
	dc.l string_10,string_11,string_12
	dc.w 3,0,0,$1181,$0,0,1,25
	dc.l string_13,string_14,string_15
	dc.w 3,48,0,$1181,$FFFF,0,1,25
	dc.l string_16,string_17,string_18
	dc.w 3,48,0,$1181,$FFFF,0,1,25
	dc.l string_19,string_20,string_21
	dc.w 3,48,0,$1181,$FFFF,0,1,25
	dc.l string_22,string_23,string_24
	dc.w 3,0,0,$1181,$0,0,1,25
	dc.l string_25,string_26,string_27
	dc.w 3,0,0,$1181,$0,0,1,25
	dc.l string_29,string_30,string_31
	dc.w 3,0,0,$1181,$0,0,1,25
	dc.l string_32,string_33,string_34
	dc.w 3,0,0,$1181,$0,0,1,25
	dc.l string_36,string_37,string_38
	dc.w 3,0,0,$1181,$0,0,1,25
	dc.l string_39,string_40,string_41
	dc.w 3,0,0,$1181,$0,0,1,25
	dc.l string_42,string_43,string_44
	dc.w 3,0,0,$1181,$0,0,1,25
	dc.l string_50,string_51,string_52
	dc.w 3,6,0,$1280,$0,-1,6,21
	dc.l string_53,string_54,string_55
	dc.w 3,6,0,$1280,$0,-1,6,21
	dc.l string_56,string_57,string_58
	dc.w 3,6,0,$1280,$0,-1,6,21
	dc.l string_59,string_60,string_61
	dc.w 3,6,0,$1280,$0,-1,6,21
	dc.l string_62,string_63,string_64
	dc.w 3,6,0,$1280,$0,-1,6,21
	dc.l string_65,string_66,string_67
	dc.w 3,6,0,$1280,$0,-1,6,21
	dc.l string_68,string_69,string_70
	dc.w 3,6,0,$1280,$0,-1,6,21
	dc.l string_71,string_72,string_73
	dc.w 3,6,0,$1280,$0,-1,6,21
	dc.l string_74,string_75,string_76
	dc.w 3,6,0,$1180,$0,-1,16,1
	dc.l string_79,string_80,string_81
	dc.w 3,48,2,$1180,$FFFF,0,13,1
	dc.l string_82,string_83,string_84
	dc.w 3,6,2,$11F0,$0,-1,1,5
	dc.l string_85,string_86,string_87
	dc.w 3,6,2,$11F0,$0,-1,1,4
	dc.l string_88,string_89,string_90
	dc.w 3,48,2,$1180,$FFFF,0,13,1
	dc.l string_91,string_92,string_93
	dc.w 3,6,0,$1280,$0,-1,6,21
	dc.l string_94,string_95,string_96
	dc.w 3,6,0,$1280,$0,-1,6,21
	dc.l string_97,string_98,string_99
	dc.w 3,6,0,$1280,$0,-1,6,21
	dc.l string_100,string_101,string_102
	dc.w 3,6,0,$1280,$0,-1,6,21
	dc.l string_103,string_104,string_105
	dc.w 3,6,0,$1280,$0,-1,6,21
	dc.l string_106,string_107,string_108
	dc.w 3,6,0,$1280,$0,-1,7,21
	dc.l string_109,string_110,string_111
	dc.w 3,6,0,$1280,$0,-1,7,21
	dc.l string_112,string_113,string_114
	dc.w 3,6,0,$1280,$0,-1,7,21
	dc.l string_115,string_116,string_117
	dc.w 3,6,2,$11F0,$0,-1,1,3
	dc.l string_118,string_119,string_120
	dc.w 3,6,2,$11F0,$0,-1,1,5
	dc.l string_121,string_122,string_123
	dc.w 3,6,2,$11F0,$0,-1,1,3
	dc.l string_124,string_125,string_126
	dc.w 3,6,0,$1180,$0,-1,18,1
	dc.l string_127,string_128,string_129
	dc.w 3,6,0,$1180,$0,-1,11,1
	dc.l string_132,string_133,string_134
	dc.w 3,48,2,$1180,$FFFF,0,13,1
	dc.l string_199,string_200,string_201
	dc.w 3,6,0,$1180,$0,-1,13,1
	dc.l string_202,string_203,string_204
	dc.w 3,6,0,$1180,$0,-1,9,1
	dc.l string_205,string_206,string_207
	dc.w 3,6,0,$1180,$0,-1,9,1
	dc.l string_211,string_212,string_213
	dc.w 3,257,0,$1280,$9EDC,0,6,25
	dc.l string_214,string_215,string_216
	dc.w 3,257,0,$1280,$9EDC,0,6,25
	dc.l string_217,string_218,string_219
	dc.w 3,6,0,$1180,$0,-1,8,1
	dc.l string_222,string_223,string_224
	dc.w 3,257,0,$1280,$9EDC,0,6,25
	dc.l string_225,string_226,string_227
	dc.w 3,6,0,$1180,$0,-1,10,1
	dc.l string_236,string_237,string_238
	dc.w 3,0,2,$1180,$0,0,16,1
	dc.l string_239,string_240,string_241
	dc.w 3,0,2,$1180,$0,0,16,1
	dc.l string_242,string_243,string_244
	dc.w 3,48,2,$1180,$FFFF,0,16,1
	dc.l string_245,string_246,string_247
	dc.w 3,257,2,$1180,$AE92,0,16,1
	dc.l string_248,string_249,string_250
	dc.w 3,-18428,2,$1180,$1,0,16,1
	dc.l string_251,string_252,string_253
	dc.w 3,0,2,$1180,$0,0,16,1
	dc.l string_254,string_255,string_256
	dc.w 3,6,0,$1180,$0,-1,8,1
	dc.l string_260,string_261,string_262
	dc.w 3,769,0,$1181,$1BF0,0,16,1
	dc.l string_263,string_264,string_265
	dc.w 3,72,0,$1181,$FFFF,0,16,1
	dc.l string_266,string_267,string_268
	dc.w 3,769,0,$1181,$23AC,0,16,1
	dc.l string_269,string_270,string_271
	dc.w 3,72,0,$1181,$FFFF,0,16,1
	dc.l string_272,string_273,string_274
	dc.w 3,257,0,$1181,$729C,0,16,1
	dc.l string_275,string_276,string_277
	dc.w 3,48,0,$1181,$FFFF,0,16,1
	dc.l string_278,string_279,string_280
	dc.w 3,257,0,$1181,$2D5A,0,16,1
	dc.l string_281,string_282,string_283
	dc.w 3,0,0,$1181,$0,0,16,1
	dc.l string_284,string_285,string_286
	dc.w 3,0,0,$1181,$0,0,16,1
	dc.l string_287,string_288,string_289
	dc.w 3,0,0,$1181,$0,0,16,1
	dc.l string_290,string_291,string_292
	dc.w 3,0,0,$1181,$0,0,16,1
	dc.l string_293,string_294,string_295
	dc.w 3,0,0,$1181,$0,0,16,1
	dc.l string_296,string_297,string_298
	dc.w 3,48,0,$1181,$FFFF,0,16,1
	dc.l string_299,string_300,string_301
	dc.w 3,48,2,$1180,$FFFF,0,14,1
	dc.l string_311,string_312,string_313
	dc.w 3,6,0,$1180,$0,-1,7,1
	dc.l string_314,string_315,string_316
	dc.w 3,6,0,$1180,$0,-1,7,1
	dc.l string_317,string_318,string_319
	dc.w 3,6,0,$1180,$0,-1,7,1
	dc.l string_320,string_321,string_322
	dc.w 3,6,0,$1180,$0,-1,7,1
	dc.l string_323,string_324,string_325
	dc.w 3,6,0,$1180,$0,-1,7,1
	dc.l string_326,string_327,string_328
	dc.w 3,6,0,$1180,$0,-1,7,1
	dc.l string_332,string_333,string_334
	dc.w 3,48,2,$1180,$FFFF,0,9,1
	dc.l string_338,string_339,string_340
	dc.w 3,48,2,$1180,$FFFF,0,10,1
	dc.l string_341,string_342,string_343
	dc.w 3,6,0,$1280,$0,-1,5,17
	dc.l string_344,string_345,string_346
	dc.w 3,6,0,$1280,$0,-1,5,17
	dc.l string_347,string_348,string_349
	dc.w 3,6,0,$1280,$0,-1,5,17
	dc.l string_350,string_351,string_352
	dc.w 3,6,0,$1280,$0,-1,5,17
	dc.l string_353,string_354,string_355
	dc.w 3,48,2,$1180,$FFFF,0,16,1
	dc.l string_356,string_357,string_358
	dc.w 3,6,0,$1280,$0,-1,5,17
	dc.l string_359,string_360,string_361
	dc.w 3,6,0,$1280,$0,-1,5,17
	dc.l string_362,string_363,string_364
	dc.w 3,6,0,$1280,$0,-1,5,17
	dc.l string_365,string_366,string_367
	dc.w 3,48,2,$1180,$FFFF,0,10,1
	dc.l string_379,string_380,string_381
	dc.w 3,48,2,$1180,$FFFF,0,16,1


rs_object:	dc.w -1,1,17,20,$0000,$0000
	dc.l $FF1100
	dc.w 0,0,24,16
	dc.w 2,-1,-1,30,$0001,$0000
	dc.l rs_tedinfo+0*28
	dc.w 0,0,24,1
	dc.w 3,-1,-1,28,$0000,$0008
	dc.l string_3
	dc.w 0,1,24,1
	dc.w 4,-1,-1,30,$0001,$0000
	dc.l rs_tedinfo+1*28
	dc.w 0,2,24,1
	dc.w 5,-1,-1,30,$0001,$0000
	dc.l rs_tedinfo+2*28
	dc.w 0,3,24,1
	dc.w 6,-1,-1,30,$0001,$0000
	dc.l rs_tedinfo+3*28
	dc.w 0,4,24,1
	dc.w 7,-1,-1,30,$0001,$0000
	dc.l rs_tedinfo+4*28
	dc.w 0,5,24,1
	dc.w 8,-1,-1,30,$0001,$0000
	dc.l rs_tedinfo+5*28
	dc.w 0,6,24,1
	dc.w 9,-1,-1,30,$0001,$0000
	dc.l rs_tedinfo+6*28
	dc.w 0,7,24,1
	dc.w 10,-1,-1,30,$0001,$0000
	dc.l rs_tedinfo+7*28
	dc.w 0,8,24,1
	dc.w 11,-1,-1,30,$0001,$0000
	dc.l rs_tedinfo+8*28
	dc.w 0,9,24,1
	dc.w 12,-1,-1,28,$0000,$0008
	dc.l string_28
	dc.w 0,10,24,1
	dc.w 13,-1,-1,30,$0001,$0000
	dc.l rs_tedinfo+9*28
	dc.w 0,11,24,1
	dc.w 14,-1,-1,30,$0001,$0000
	dc.l rs_tedinfo+10*28
	dc.w 0,12,24,1
	dc.w 15,-1,-1,28,$0000,$0008
	dc.l string_35
	dc.w 0,13,24,1
	dc.w 16,-1,-1,30,$0001,$0000
	dc.l rs_tedinfo+11*28
	dc.w 0,14,24,1
	dc.w 17,-1,-1,30,$0001,$0000
	dc.l rs_tedinfo+12*28
	dc.w 0,15,24,1
	dc.w 0,-1,-1,30,$0021,$0000
	dc.l rs_tedinfo+13*28
	dc.w 0,15,24,1

	dc.w -1,1,7,20,$0000,$0010
	dc.l $FF1014
	dc.w 0,0,26,13
	dc.w 3,2,2,20,$0000,$0000
	dc.l $FF1101
	dc.w 2,1,22,2051
	dc.w 1,-1,-1,23,$0000,$0000
	dc.l rs_bitblk+0*14
	dc.w 1,1,20,2817
	dc.w 4,-1,-1,28,$0000,$0000
	dc.l string_45
	dc.w 2,6,15,1
	dc.w 5,-1,-1,28,$0000,$0000
	dc.l string_46
	dc.w 2,8,11,1
	dc.w 6,-1,-1,28,$0000,$0000
	dc.l string_47
	dc.w 2,9,15,1
	dc.w 7,-1,-1,28,$0000,$0000
	dc.l string_48
	dc.w 2,10,17,1
	dc.w 0,-1,-1,28,$0020,$0000
	dc.l string_49
	dc.w 2,11,14,1

	dc.w -1,1,40,20,$0000,$0010
	dc.l $FF1404
	dc.w 0,0,52,22
	dc.w 10,2,9,25,$0000,$0000
	dc.l $11100
	dc.w 2,1,24,10
	dc.w 3,-1,-1,29,$0008,$0000
	dc.l rs_tedinfo+14*28
	dc.w 2,1,20,1
	dc.w 4,-1,-1,29,$0008,$0000
	dc.l rs_tedinfo+15*28
	dc.w 2,2,20,1
	dc.w 5,-1,-1,29,$0008,$0000
	dc.l rs_tedinfo+16*28
	dc.w 2,3,20,1
	dc.w 6,-1,-1,29,$0008,$0000
	dc.l rs_tedinfo+17*28
	dc.w 2,4,20,1
	dc.w 7,-1,-1,29,$0008,$0000
	dc.l rs_tedinfo+18*28
	dc.w 2,5,20,1
	dc.w 8,-1,-1,29,$0008,$0000
	dc.l rs_tedinfo+19*28
	dc.w 2,6,20,1
	dc.w 9,-1,-1,29,$0008,$0000
	dc.l rs_tedinfo+20*28
	dc.w 2,7,20,1
	dc.w 1,-1,-1,29,$0008,$0000
	dc.l rs_tedinfo+21*28
	dc.w 2,8,20,1
	dc.w 11,-1,-1,21,$0000,$0000
	dc.l rs_tedinfo+22*28
	dc.w 3,2048,15,1
	dc.w 14,12,13,25,$0000,$0000
	dc.l $11100
	dc.w 2,12,24,3
	dc.w 13,-1,-1,26,$0011,$0000
	dc.l string_77
	dc.w 2,1,9,1
	dc.w 11,-1,-1,26,$0011,$0000
	dc.l string_78
	dc.w 13,1,9,1
	dc.w 15,-1,-1,21,$0000,$0000
	dc.l rs_tedinfo+23*28
	dc.w 3,2059,12,1
	dc.w 18,16,17,25,$0000,$0000
	dc.l $11100
	dc.w 2,16,24,3
	dc.w 17,-1,-1,30,$0005,$0000
	dc.l rs_tedinfo+24*28
	dc.w 2,1,9,1
	dc.w 15,-1,-1,30,$0005,$0000
	dc.l rs_tedinfo+25*28
	dc.w 13,1,9,1
	dc.w 19,-1,-1,21,$0000,$0000
	dc.l rs_tedinfo+26*28
	dc.w 3,2063,12,1
	dc.w 33,20,32,25,$0000,$0000
	dc.l $11100
	dc.w 27,1,24,14
	dc.w 21,-1,-1,29,$0008,$0000
	dc.l rs_tedinfo+27*28
	dc.w 2,1,20,1
	dc.w 22,-1,-1,29,$0008,$0000
	dc.l rs_tedinfo+28*28
	dc.w 2,2,20,1
	dc.w 23,-1,-1,29,$0008,$0000
	dc.l rs_tedinfo+29*28
	dc.w 2,3,20,1
	dc.w 24,-1,-1,29,$0008,$0000
	dc.l rs_tedinfo+30*28
	dc.w 2,4,20,1
	dc.w 25,-1,-1,29,$0008,$0000
	dc.l rs_tedinfo+31*28
	dc.w 2,5,20,1
	dc.w 32,26,31,25,$0000,$0000
	dc.l $11100
	dc.w 0,7,24,7
	dc.w 27,-1,-1,29,$0008,$0000
	dc.l rs_tedinfo+32*28
	dc.w 2,1,20,1
	dc.w 28,-1,-1,29,$0008,$0000
	dc.l rs_tedinfo+33*28
	dc.w 2,2,20,1
	dc.w 29,-1,-1,29,$0008,$0000
	dc.l rs_tedinfo+34*28
	dc.w 2,3,20,1
	dc.w 30,-1,-1,30,$0015,$0000
	dc.l rs_tedinfo+35*28
	dc.w 2,5,6,1
	dc.w 31,-1,-1,30,$0015,$0000
	dc.l rs_tedinfo+36*28
	dc.w 9,5,6,1
	dc.w 25,-1,-1,30,$0015,$0000
	dc.l rs_tedinfo+37*28
	dc.w 16,5,6,1
	dc.w 19,-1,-1,21,$0000,$0000
	dc.l rs_tedinfo+38*28
	dc.w 1,2054,17,1
	dc.w 34,-1,-1,21,$0000,$0000
	dc.l rs_tedinfo+39*28
	dc.w 28,2048,10,1
	dc.w 37,35,36,25,$0000,$0000
	dc.l $11100
	dc.w 27,16,24,3
	dc.w 36,-1,-1,26,$0001,$0000
	dc.l string_130
	dc.w 2,1,9,1
	dc.w 34,-1,-1,26,$0001,$0000
	dc.l string_131
	dc.w 13,1,9,1
	dc.w 38,-1,-1,21,$0000,$0000
	dc.l rs_tedinfo+40*28
	dc.w 28,2063,12,1
	dc.w 39,-1,-1,26,$0005,$0000
	dc.l string_135
	dc.w 17,20,10,1
	dc.w 40,-1,-1,26,$0005,$0000
	dc.l string_136
	dc.w 29,20,10,1
	dc.w 0,-1,-1,26,$0027,$0000
	dc.l string_137
	dc.w 41,20,10,1

	dc.w -1,1,68,20,$0000,$0010
	dc.l $34FF10A0
	dc.w 0,0,60,22
	dc.w 50,2,49,25,$0000,$0000
	dc.l $11100
	dc.w 2,1,38,18
	dc.w 3,-1,-1,28,$0051,$0000
	dc.l string_138
	dc.w 1025,1,11,1
	dc.w 4,-1,-1,28,$0051,$0000
	dc.l string_139
	dc.w 1025,2,11,1
	dc.w 5,-1,-1,28,$0051,$0000
	dc.l string_140
	dc.w 1025,3,11,1
	dc.w 6,-1,-1,28,$0051,$0000
	dc.l string_141
	dc.w 1025,4,11,1
	dc.w 7,-1,-1,28,$0051,$0000
	dc.l string_142
	dc.w 1025,5,11,1
	dc.w 8,-1,-1,28,$0051,$0000
	dc.l string_143
	dc.w 1025,6,11,1
	dc.w 9,-1,-1,28,$0051,$0000
	dc.l string_144
	dc.w 1025,7,11,1
	dc.w 10,-1,-1,28,$0051,$0000
	dc.l string_145
	dc.w 1025,8,11,1
	dc.w 11,-1,-1,28,$0051,$0000
	dc.l string_146
	dc.w 1025,9,11,1
	dc.w 12,-1,-1,28,$0051,$0000
	dc.l string_147
	dc.w 1025,10,11,1
	dc.w 13,-1,-1,28,$0051,$0000
	dc.l string_148
	dc.w 1025,11,11,1
	dc.w 14,-1,-1,28,$0051,$0000
	dc.l string_149
	dc.w 1025,12,11,1
	dc.w 15,-1,-1,28,$0051,$0000
	dc.l string_150
	dc.w 1025,13,11,1
	dc.w 16,-1,-1,28,$0051,$0000
	dc.l string_151
	dc.w 1025,14,11,1
	dc.w 17,-1,-1,28,$0051,$0000
	dc.l string_152
	dc.w 1025,15,11,1
	dc.w 18,-1,-1,28,$0051,$0000
	dc.l string_153
	dc.w 1025,16,11,1
	dc.w 19,-1,-1,28,$0051,$0000
	dc.l string_154
	dc.w 1038,1,7,1
	dc.w 20,-1,-1,28,$0051,$0000
	dc.l string_155
	dc.w 1038,2,7,1
	dc.w 21,-1,-1,28,$0051,$0000
	dc.l string_156
	dc.w 1038,3,7,1
	dc.w 22,-1,-1,28,$0051,$0000
	dc.l string_157
	dc.w 1038,4,7,1
	dc.w 23,-1,-1,28,$0051,$0000
	dc.l string_158
	dc.w 1038,5,7,1
	dc.w 24,-1,-1,28,$0051,$0000
	dc.l string_159
	dc.w 1038,6,7,1
	dc.w 25,-1,-1,28,$0051,$0000
	dc.l string_160
	dc.w 1038,7,7,1
	dc.w 26,-1,-1,28,$0051,$0000
	dc.l string_161
	dc.w 1038,8,7,1
	dc.w 27,-1,-1,28,$0051,$0000
	dc.l string_162
	dc.w 1038,9,7,1
	dc.w 28,-1,-1,28,$0051,$0000
	dc.l string_163
	dc.w 1038,10,7,1
	dc.w 29,-1,-1,28,$0051,$0000
	dc.l string_164
	dc.w 1038,11,7,1
	dc.w 30,-1,-1,28,$0051,$0000
	dc.l string_165
	dc.w 1038,12,7,1
	dc.w 31,-1,-1,28,$0051,$0000
	dc.l string_166
	dc.w 1038,13,7,1
	dc.w 32,-1,-1,28,$0051,$0000
	dc.l string_167
	dc.w 1038,14,7,1
	dc.w 33,-1,-1,28,$0051,$0000
	dc.l string_168
	dc.w 1038,15,7,1
	dc.w 34,-1,-1,28,$0051,$0000
	dc.l string_169
	dc.w 1038,16,7,1
	dc.w 35,-1,-1,28,$0051,$0000
	dc.l string_170
	dc.w 24,1,12,1
	dc.w 36,-1,-1,28,$0051,$0000
	dc.l string_171
	dc.w 24,2,12,1
	dc.w 37,-1,-1,28,$0051,$0000
	dc.l string_172
	dc.w 24,3,12,1
	dc.w 38,-1,-1,28,$0051,$0000
	dc.l string_173
	dc.w 24,4,12,1
	dc.w 39,-1,-1,28,$0051,$0000
	dc.l string_174
	dc.w 24,5,12,1
	dc.w 40,-1,-1,28,$0051,$0000
	dc.l string_175
	dc.w 24,6,12,1
	dc.w 41,-1,-1,28,$0051,$0000
	dc.l string_176
	dc.w 24,7,12,1
	dc.w 42,-1,-1,28,$0051,$0000
	dc.l string_177
	dc.w 24,8,12,1
	dc.w 43,-1,-1,28,$0051,$0000
	dc.l string_178
	dc.w 24,9,12,1
	dc.w 44,-1,-1,28,$0051,$0000
	dc.l string_179
	dc.w 24,10,12,1
	dc.w 45,-1,-1,28,$0051,$0000
	dc.l string_180
	dc.w 24,11,12,1
	dc.w 46,-1,-1,28,$0051,$0000
	dc.l string_181
	dc.w 24,12,12,1
	dc.w 47,-1,-1,28,$0051,$0000
	dc.l string_182
	dc.w 24,13,12,1
	dc.w 48,-1,-1,28,$0051,$0000
	dc.l string_183
	dc.w 24,14,12,1
	dc.w 49,-1,-1,28,$0051,$0000
	dc.l string_184
	dc.w 24,15,12,1
	dc.w 1,-1,-1,28,$0051,$0000
	dc.l string_185
	dc.w 24,16,12,1
	dc.w 59,51,54,25,$0000,$0000
	dc.l $11180
	dc.w 42,1,16,12
	dc.w 52,-1,-1,26,$0011,$0000
	dc.l string_186
	dc.w 1,1,14,1
	dc.w 53,-1,-1,26,$0011,$0000
	dc.l string_187
	dc.w 1,3,14,1
	dc.w 54,-1,-1,26,$0011,$0000
	dc.l string_188
	dc.w 1,5,14,1
	dc.w 50,55,58,20,$0000,$0000
	dc.l $11180
	dc.w 0,7,16,5
	dc.w 56,-1,-1,26,$0041,$0000
	dc.l string_189
	dc.w 1,1,14,1
	dc.w 57,-1,-1,26,$0041,$0000
	dc.l string_190
	dc.w 1,1,14,1
	dc.w 58,-1,-1,26,$0041,$0000
	dc.l string_191
	dc.w 1,3,14,1
	dc.w 54,-1,-1,26,$0041,$0000
	dc.l string_192
	dc.w 1,3,14,1
	dc.w 63,60,62,25,$0000,$0000
	dc.l $11180
	dc.w 42,14,16,7
	dc.w 61,-1,-1,26,$0041,$0000
	dc.l string_193
	dc.w 1,1,14,1
	dc.w 62,-1,-1,26,$0041,$0000
	dc.l string_194
	dc.w 1,3,14,1
	dc.w 59,-1,-1,26,$0041,$0000
	dc.l string_195
	dc.w 1,5,14,1
	dc.w 64,-1,-1,26,$0005,$0000
	dc.l string_196
	dc.w 5,20,10,1
	dc.w 65,-1,-1,26,$0005,$0000
	dc.l string_197
	dc.w 17,20,10,1
	dc.w 66,-1,-1,26,$0007,$0000
	dc.l string_198
	dc.w 29,20,10,1
	dc.w 67,-1,-1,21,$0000,$0000
	dc.l rs_tedinfo+41*28
	dc.w 3,2048,12,1
	dc.w 68,-1,-1,21,$0000,$0000
	dc.l rs_tedinfo+42*28
	dc.w 43,2048,8,1
	dc.w 0,-1,-1,21,$0020,$0000
	dc.l rs_tedinfo+43*28
	dc.w 43,2061,8,1

	dc.w -1,1,15,20,$0000,$0010
	dc.l $FF1181
	dc.w 0,0,32,17
	dc.w 7,2,6,25,$0000,$0000
	dc.l $11100
	dc.w 2,1,28,7
	dc.w 3,-1,-1,28,$0000,$0000
	dc.l string_208
	dc.w 2,1,24,1
	dc.w 4,-1,-1,28,$0000,$0000
	dc.l string_209
	dc.w 2,2,24,1
	dc.w 5,-1,-1,28,$0000,$0000
	dc.l string_210
	dc.w 2,3,24,1
	dc.w 6,-1,-1,29,$0008,$0000
	dc.l rs_tedinfo+44*28
	dc.w 2,4,24,1
	dc.w 1,-1,-1,29,$0008,$0000
	dc.l rs_tedinfo+45*28
	dc.w 2,5,24,1
	dc.w 8,-1,-1,21,$0000,$0000
	dc.l rs_tedinfo+46*28
	dc.w 3,2048,7,1
	dc.w 12,9,11,25,$0000,$0000
	dc.l $11100
	dc.w 2,9,28,5
	dc.w 10,-1,-1,28,$0000,$0000
	dc.l string_220
	dc.w 2,1,24,1
	dc.w 11,-1,-1,28,$0000,$0000
	dc.l string_221
	dc.w 2,2,24,1
	dc.w 8,-1,-1,29,$0008,$0000
	dc.l rs_tedinfo+47*28
	dc.w 2,3,24,1
	dc.w 13,-1,-1,21,$0000,$0000
	dc.l rs_tedinfo+48*28
	dc.w 3,2056,9,1
	dc.w 14,-1,-1,26,$0005,$0000
	dc.l string_228
	dc.w 2,15,8,1
	dc.w 15,-1,-1,26,$0005,$0000
	dc.l string_229
	dc.w 12,15,8,1
	dc.w 0,-1,-1,26,$0027,$0000
	dc.l string_230
	dc.w 22,15,8,1

	dc.w -1,1,103,20,$0000,$0010
	dc.l $FF1100
	dc.w 0,0,1091,14
	dc.w 99,2,2,20,$0000,$0000
	dc.l $FF1114
	dc.w 2,2049,63,9
	dc.w 1,3,98,25,$0000,$0000
	dc.l $110
	dc.w 0,0,63,9
	dc.w 4,-1,-1,27,$0011,$0000
	dc.l $31FF1100
	dc.w 1,1,1539,1281
	dc.w 5,-1,-1,27,$0011,$0000
	dc.l $32FF1100
	dc.w 1796,1,1539,1281
	dc.w 6,-1,-1,27,$0011,$0000
	dc.l $33FF1100
	dc.w 1544,1,1539,1281
	dc.w 7,-1,-1,27,$0011,$0000
	dc.l $34FF1100
	dc.w 1292,1,1539,1281
	dc.w 8,-1,-1,27,$0011,$0000
	dc.l $35FF1100
	dc.w 1040,1,1539,1281
	dc.w 9,-1,-1,27,$0011,$0000
	dc.l $36FF1100
	dc.w 788,1,1539,1281
	dc.w 10,-1,-1,27,$0011,$0000
	dc.l $37FF1100
	dc.w 536,1,1539,1281
	dc.w 11,-1,-1,27,$0011,$0000
	dc.l $38FF1100
	dc.w 284,1,1539,1281
	dc.w 12,-1,-1,27,$0011,$0000
	dc.l $39FF1100
	dc.w 32,1,1539,1281
	dc.w 13,-1,-1,27,$0011,$0000
	dc.l $30FF1100
	dc.w 1827,1,1539,1281
	dc.w 14,-1,-1,27,$0011,$0000
	dc.l $65FF1100
	dc.w 1,3,770,1
	dc.w 15,-1,-1,27,$0011,$0000
	dc.l $31FF1100
	dc.w 1027,3,770,1
	dc.w 16,-1,-1,27,$0011,$0000
	dc.l $32FF1100
	dc.w 6,3,770,1
	dc.w 17,-1,-1,27,$0011,$0000
	dc.l $33FF1100
	dc.w 1032,3,770,1
	dc.w 18,-1,-1,27,$0011,$0000
	dc.l $34FF1100
	dc.w 11,3,770,1
	dc.w 19,-1,-1,27,$0011,$0000
	dc.l $35FF1100
	dc.w 1037,3,770,1
	dc.w 20,-1,-1,27,$0011,$0000
	dc.l $36FF1100
	dc.w 16,3,770,1
	dc.w 21,-1,-1,27,$0011,$0000
	dc.l $37FF1100
	dc.w 1042,3,770,1
	dc.w 22,-1,-1,27,$0011,$0000
	dc.l $38FF1100
	dc.w 21,3,770,1
	dc.w 23,-1,-1,27,$0011,$0000
	dc.l $39FF1100
	dc.w 1047,3,770,1
	dc.w 24,-1,-1,27,$0011,$0000
	dc.l $30FF1100
	dc.w 26,3,770,1
	dc.w 25,-1,-1,27,$0011,$0000
	dc.l $9EFF1100
	dc.w 1052,3,770,1
	dc.w 26,-1,-1,27,$0011,$0000
	dc.l $27FF1100
	dc.w 31,3,770,1
	dc.w 27,-1,-1,27,$0011,$0000
	dc.l $23FF1100
	dc.w 1057,3,770,1
	dc.w 28,-1,-1,27,$0011,$0000
	dc.l $62FF1100
	dc.w 36,3,1283,1
	dc.w 29,-1,-1,27,$0011,$0000
	dc.l $68FF1100
	dc.w 42,3,1283,1
	dc.w 30,-1,-1,27,$0011,$0000
	dc.l $75FF1100
	dc.w 1581,3,1283,1
	dc.w 31,-1,-1,27,$0011,$0000
	dc.l $28FF1100
	dc.w 52,3,770,1
	dc.w 32,-1,-1,27,$0011,$0000
	dc.l $29FF1100
	dc.w 1078,3,770,1
	dc.w 33,-1,-1,27,$0011,$0000
	dc.l $2FFF1100
	dc.w 57,3,770,1
	dc.w 34,-1,-1,27,$0011,$0000
	dc.l $2AFF1100
	dc.w 1083,3,770,1
	dc.w 35,-1,-1,27,$0011,$0000
	dc.l $74FF1100
	dc.w 1,260,1283,1
	dc.w 36,-1,-1,27,$0011,$0000
	dc.l $51FF1100
	dc.w 1540,260,770,1
	dc.w 37,-1,-1,27,$0011,$0000
	dc.l $57FF1100
	dc.w 519,260,770,1
	dc.w 38,-1,-1,27,$0011,$0000
	dc.l $45FF1100
	dc.w 1545,260,770,1
	dc.w 39,-1,-1,27,$0011,$0000
	dc.l $52FF1100
	dc.w 524,260,770,1
	dc.w 40,-1,-1,27,$0011,$0000
	dc.l $54FF1100
	dc.w 1550,260,770,1
	dc.w 41,-1,-1,27,$0011,$0000
	dc.l $5AFF1100
	dc.w 529,260,770,1
	dc.w 42,-1,-1,27,$0011,$0000
	dc.l $55FF1100
	dc.w 1555,260,770,1
	dc.w 43,-1,-1,27,$0011,$0000
	dc.l $49FF1100
	dc.w 534,260,770,1
	dc.w 44,-1,-1,27,$0011,$0000
	dc.l $4FFF1100
	dc.w 1560,260,770,1
	dc.w 45,-1,-1,27,$0011,$0000
	dc.l $50FF1100
	dc.w 539,260,770,1
	dc.w 46,-1,-1,27,$0011,$0000
	dc.l $9AFF1100
	dc.w 1565,260,770,1
	dc.w 47,-1,-1,27,$0011,$0000
	dc.l $2BFF1100
	dc.w 544,260,770,1
	dc.w 48,-1,-1,27,$0011,$0000
	dc.l $DFF1100
	dc.w 1570,260,770,258
	dc.w 49,-1,-1,27,$0011,$0000
	dc.l $64FF1100
	dc.w 549,260,770,1
	dc.w 50,-1,-1,27,$0011,$0000
	dc.l $69FF1100
	dc.w 42,260,770,1
	dc.w 51,-1,-1,27,$0011,$0000
	dc.l $1FF1100
	dc.w 1068,260,770,1
	dc.w 52,-1,-1,27,$0011,$0000
	dc.l $63FF1100
	dc.w 47,260,770,1
	dc.w 53,-1,-1,27,$0011,$0000
	dc.l $37FF1100
	dc.w 52,260,770,1
	dc.w 54,-1,-1,27,$0011,$0000
	dc.l $38FF1100
	dc.w 1078,260,770,1
	dc.w 55,-1,-1,27,$0011,$0000
	dc.l $39FF1100
	dc.w 57,260,770,1
	dc.w 56,-1,-1,27,$0011,$0000
	dc.l $2DFF1100
	dc.w 1083,260,770,1
	dc.w 57,-1,-1,27,$0001,$0000
	dc.l $63FF1100
	dc.w 1,517,1796,1
	dc.w 58,-1,-1,27,$0011,$0000
	dc.l $41FF1100
	dc.w 6,517,770,1
	dc.w 59,-1,-1,27,$0011,$0000
	dc.l $53FF1100
	dc.w 1032,517,770,1
	dc.w 60,-1,-1,27,$0011,$0000
	dc.l $44FF1100
	dc.w 11,517,770,1
	dc.w 61,-1,-1,27,$0011,$0000
	dc.l $46FF1100
	dc.w 1037,517,770,1
	dc.w 62,-1,-1,27,$0011,$0000
	dc.l $47FF1100
	dc.w 16,517,770,1
	dc.w 63,-1,-1,27,$0011,$0000
	dc.l $48FF1100
	dc.w 1042,517,770,1
	dc.w 64,-1,-1,27,$0011,$0000
	dc.l $4AFF1100
	dc.w 21,517,770,1
	dc.w 65,-1,-1,27,$0011,$0000
	dc.l $4BFF1100
	dc.w 1047,517,770,1
	dc.w 66,-1,-1,27,$0011,$0000
	dc.l $4CFF1100
	dc.w 26,517,770,1
	dc.w 67,-1,-1,27,$0011,$0000
	dc.l $99FF1100
	dc.w 1052,517,770,1
	dc.w 68,-1,-1,27,$0011,$0000
	dc.l $8EFF1100
	dc.w 31,517,770,1
	dc.w 69,-1,-1,27,$0011,$0000
	dc.l $7EFF1100
	dc.w 549,517,770,1
	dc.w 70,-1,-1,27,$0011,$0000
	dc.l $4FF1100
	dc.w 42,517,770,1
	dc.w 71,-1,-1,27,$0011,$0000
	dc.l $2FF1100
	dc.w 1068,517,770,1
	dc.w 72,-1,-1,27,$0011,$0000
	dc.l $3FF1100
	dc.w 47,517,770,1
	dc.w 73,-1,-1,27,$0011,$0000
	dc.l $34FF1100
	dc.w 52,517,770,1
	dc.w 74,-1,-1,27,$0011,$0000
	dc.l $35FF1100
	dc.w 1078,517,770,1
	dc.w 75,-1,-1,27,$0011,$0000
	dc.l $36FF1100
	dc.w 57,517,770,1
	dc.w 76,-1,-1,27,$0011,$0000
	dc.l $2BFF1100
	dc.w 1083,517,770,1
	dc.w 77,-1,-1,27,$0001,$0000
	dc.l $73FF1100
	dc.w 1,774,1283,1
	dc.w 78,-1,-1,27,$0011,$0000
	dc.l $3CFF1100
	dc.w 1540,774,770,1
	dc.w 79,-1,-1,27,$0011,$0000
	dc.l $59FF1100
	dc.w 519,774,770,1
	dc.w 80,-1,-1,27,$0011,$0000
	dc.l $58FF1100
	dc.w 1545,774,770,1
	dc.w 81,-1,-1,27,$0011,$0000
	dc.l $43FF1100
	dc.w 524,774,770,1
	dc.w 82,-1,-1,27,$0011,$0000
	dc.l $56FF1100
	dc.w 1550,774,770,1
	dc.w 83,-1,-1,27,$0011,$0000
	dc.l $42FF1100
	dc.w 529,774,770,1
	dc.w 84,-1,-1,27,$0011,$0000
	dc.l $4EFF1100
	dc.w 1555,774,770,1
	dc.w 85,-1,-1,27,$0011,$0000
	dc.l $4DFF1100
	dc.w 534,774,770,1
	dc.w 86,-1,-1,27,$0011,$0000
	dc.l $2CFF1100
	dc.w 1560,774,770,1
	dc.w 87,-1,-1,27,$0011,$0000
	dc.l $2EFF1100
	dc.w 539,774,770,1
	dc.w 88,-1,-1,27,$0011,$0000
	dc.l $2DFF1100
	dc.w 1565,774,770,1
	dc.w 89,-1,-1,27,$0001,$0000
	dc.l $73FF1100
	dc.w 544,774,1283,1
	dc.w 90,-1,-1,27,$0011,$0000
	dc.l $31FF1100
	dc.w 52,774,770,1
	dc.w 91,-1,-1,27,$0011,$0000
	dc.l $32FF1100
	dc.w 1078,774,770,1
	dc.w 92,-1,-1,27,$0011,$0000
	dc.l $33FF1100
	dc.w 57,774,770,1
	dc.w 93,-1,-1,27,$0011,$0000
	dc.l $DFF1100
	dc.w 1083,774,770,258
	dc.w 94,-1,-1,27,$0001,$0000
	dc.l $6CFF1100
	dc.w 42,7,1283,1
	dc.w 95,-1,-1,27,$0001,$0000
	dc.l $72FF1100
	dc.w 1581,7,1283,1
	dc.w 96,-1,-1,27,$0001,$0000
	dc.l $61FF1100
	dc.w 1540,1031,1283,1
	dc.w 97,-1,-1,27,$0011,$0000
	dc.l $20FF1100
	dc.w 1032,1031,1046,1
	dc.w 98,-1,-1,27,$0011,$0000
	dc.l $30FF1100
	dc.w 52,1031,1796,1
	dc.w 2,-1,-1,27,$0011,$0000
	dc.l $2EFF1100
	dc.w 57,1031,770,1
	dc.w 100,-1,-1,26,$0051,$0000
	dc.l string_231
	dc.w 2,12,12,1
	dc.w 101,-1,-1,26,$0051,$0000
	dc.l string_232
	dc.w 15,12,12,1
	dc.w 102,-1,-1,26,$0005,$0000
	dc.l string_233
	dc.w 33,12,10,1
	dc.w 103,-1,-1,26,$0005,$0000
	dc.l string_234
	dc.w 44,12,10,1
	dc.w 0,-1,-1,26,$0027,$0000
	dc.l string_235
	dc.w 55,12,10,1

	dc.w -1,1,23,20,$0000,$0010
	dc.l $FF1181
	dc.w 0,0,33,17
	dc.w 20,2,19,25,$0000,$0000
	dc.l $11100
	dc.w 2,1,29,13
	dc.w 3,-1,-1,21,$0000,$0000
	dc.l rs_tedinfo+49*28
	dc.w 2,1,15,1
	dc.w 4,-1,-1,21,$0000,$0000
	dc.l rs_tedinfo+50*28
	dc.w 2,3,15,1
	dc.w 5,-1,-1,21,$0000,$0000
	dc.l rs_tedinfo+51*28
	dc.w 2,5,15,1
	dc.w 6,-1,-1,21,$0000,$0000
	dc.l rs_tedinfo+52*28
	dc.w 2,7,15,1
	dc.w 7,-1,-1,21,$0000,$0000
	dc.l rs_tedinfo+53*28
	dc.w 2,9,15,1
	dc.w 8,-1,-1,21,$0000,$0000
	dc.l rs_tedinfo+54*28
	dc.w 2,11,15,1
	dc.w 9,-1,-1,27,$0040,$0000
	dc.l $2FF1100
	dc.w 19,1,3,1
	dc.w 10,-1,-1,27,$0040,$0000
	dc.l $2FF1100
	dc.w 19,3,3,1
	dc.w 11,-1,-1,27,$0040,$0000
	dc.l $2FF1100
	dc.w 19,5,3,1
	dc.w 12,-1,-1,27,$0040,$0000
	dc.l $2FF1100
	dc.w 19,7,3,1
	dc.w 13,-1,-1,27,$0040,$0000
	dc.l $2FF1100
	dc.w 19,9,3,1
	dc.w 14,-1,-1,27,$0040,$0000
	dc.l $2FF1100
	dc.w 19,11,3,1
	dc.w 15,-1,-1,27,$0040,$0000
	dc.l $1FF1100
	dc.w 23,1,3,1
	dc.w 16,-1,-1,27,$0040,$0000
	dc.l $1FF1100
	dc.w 23,3,3,1
	dc.w 17,-1,-1,27,$0040,$0000
	dc.l $1FF1100
	dc.w 23,5,3,1
	dc.w 18,-1,-1,27,$0040,$0000
	dc.l $1FF1100
	dc.w 23,7,3,1
	dc.w 19,-1,-1,27,$0040,$0000
	dc.l $1FF1100
	dc.w 23,9,3,1
	dc.w 1,-1,-1,27,$0040,$0000
	dc.l $1FF1100
	dc.w 23,11,3,1
	dc.w 21,-1,-1,21,$0000,$0000
	dc.l rs_tedinfo+55*28
	dc.w 3,2048,7,1
	dc.w 22,-1,-1,26,$0005,$0000
	dc.l string_257
	dc.w 3,15,8,1
	dc.w 23,-1,-1,26,$0005,$0000
	dc.l string_258
	dc.w 13,15,8,1
	dc.w 0,-1,-1,26,$0027,$0000
	dc.l string_259
	dc.w 23,15,8,1

	dc.w -1,1,20,20,$0000,$0010
	dc.l $FF1481
	dc.w 0,0,42,13
	dc.w 15,2,14,25,$0000,$0000
	dc.l $11100
	dc.w 2,1,34,9
	dc.w 3,-1,-1,21,$0051,$0000
	dc.l rs_tedinfo+56*28
	dc.w 1,1,15,1
	dc.w 4,-1,-1,21,$0051,$0000
	dc.l rs_tedinfo+57*28
	dc.w 1,2,15,1
	dc.w 5,-1,-1,21,$0051,$0000
	dc.l rs_tedinfo+58*28
	dc.w 1,3,15,1
	dc.w 6,-1,-1,21,$0051,$0000
	dc.l rs_tedinfo+59*28
	dc.w 1,4,15,1
	dc.w 7,-1,-1,21,$0051,$0000
	dc.l rs_tedinfo+60*28
	dc.w 1,5,15,1
	dc.w 8,-1,-1,21,$0051,$0000
	dc.l rs_tedinfo+61*28
	dc.w 1,6,15,1
	dc.w 9,-1,-1,21,$0051,$0000
	dc.l rs_tedinfo+62*28
	dc.w 1,7,15,1
	dc.w 10,-1,-1,21,$0051,$0000
	dc.l rs_tedinfo+63*28
	dc.w 18,1,15,1
	dc.w 11,-1,-1,21,$0051,$0000
	dc.l rs_tedinfo+64*28
	dc.w 18,2,15,1
	dc.w 12,-1,-1,21,$0051,$0000
	dc.l rs_tedinfo+65*28
	dc.w 18,3,15,1
	dc.w 13,-1,-1,21,$0051,$0000
	dc.l rs_tedinfo+66*28
	dc.w 18,4,15,1
	dc.w 14,-1,-1,21,$0051,$0000
	dc.l rs_tedinfo+67*28
	dc.w 18,5,15,1
	dc.w 1,-1,-1,21,$0051,$0000
	dc.l rs_tedinfo+68*28
	dc.w 18,6,15,1
	dc.w 16,-1,-1,21,$0000,$0000
	dc.l rs_tedinfo+69*28
	dc.w 3,2048,13,1
	dc.w 17,-1,-1,27,$0040,$0000
	dc.l $1011100
	dc.w 37,1,3,4
	dc.w 18,-1,-1,27,$0040,$0000
	dc.l $2011100
	dc.w 37,6,3,4
	dc.w 19,-1,-1,26,$0005,$0000
	dc.l string_302
	dc.w 6,11,10,1
	dc.w 20,-1,-1,26,$0005,$0000
	dc.l string_303
	dc.w 18,11,10,1
	dc.w 0,-1,-1,26,$0027,$0000
	dc.l string_304
	dc.w 30,11,10,1

	dc.w -1,1,14,20,$0000,$0010
	dc.l $FF1181
	dc.w 0,0,35,2065
	dc.w 14,2,13,25,$0000,$0000
	dc.l $11100
	dc.w 2,1,31,2061
	dc.w 3,-1,-1,26,$0005,$0000
	dc.l string_305
	dc.w 2,1,1042,1
	dc.w 4,-1,-1,26,$0005,$0000
	dc.l string_306
	dc.w 2,3,1042,1
	dc.w 5,-1,-1,26,$0005,$0000
	dc.l string_307
	dc.w 2,5,1042,1
	dc.w 6,-1,-1,26,$0005,$0000
	dc.l string_308
	dc.w 2,7,1042,1
	dc.w 7,-1,-1,26,$0005,$0000
	dc.l string_309
	dc.w 2,9,1042,1
	dc.w 8,-1,-1,26,$0005,$0000
	dc.l string_310
	dc.w 2,11,1042,1
	dc.w 9,-1,-1,21,$0000,$0000
	dc.l rs_tedinfo+70*28
	dc.w 23,1,6,1
	dc.w 10,-1,-1,21,$0000,$0000
	dc.l rs_tedinfo+71*28
	dc.w 23,3,6,1
	dc.w 11,-1,-1,21,$0000,$0000
	dc.l rs_tedinfo+72*28
	dc.w 23,5,6,1
	dc.w 12,-1,-1,21,$0000,$0000
	dc.l rs_tedinfo+73*28
	dc.w 23,7,6,1
	dc.w 13,-1,-1,21,$0000,$0000
	dc.l rs_tedinfo+74*28
	dc.w 23,9,6,1
	dc.w 1,-1,-1,21,$0000,$0000
	dc.l rs_tedinfo+75*28
	dc.w 23,11,6,1
	dc.w 0,-1,-1,26,$0027,$0000
	dc.l string_329
	dc.w 23,2063,10,1

	dc.w -1,1,24,20,$0000,$0010
	dc.l $FF1481
	dc.w 0,0,43,19
	dc.w 4,2,3,25,$0000,$0000
	dc.l $11100
	dc.w 2,1,26,3
	dc.w 3,-1,-1,26,$0011,$0000
	dc.l string_330
	dc.w 2,1,10,1
	dc.w 1,-1,-1,26,$0011,$0000
	dc.l string_331
	dc.w 14,1,10,1
	dc.w 5,-1,-1,21,$0000,$0000
	dc.l rs_tedinfo+76*28
	dc.w 3,2048,8,1
	dc.w 9,6,8,25,$0000,$0000
	dc.l $11100
	dc.w 2,2053,39,3
	dc.w 7,-1,-1,26,$0011,$0000
	dc.l string_335
	dc.w 2,1,10,1
	dc.w 8,-1,-1,26,$0011,$0000
	dc.l string_336
	dc.w 14,1,10,1
	dc.w 5,-1,-1,26,$0011,$0000
	dc.l string_337
	dc.w 26,1,10,1
	dc.w 10,-1,-1,21,$0000,$0000
	dc.l rs_tedinfo+77*28
	dc.w 3,5,9,1
	dc.w 15,11,14,25,$0000,$0000
	dc.l $11100
	dc.w 2,10,19,6
	dc.w 12,-1,-1,29,$0008,$0000
	dc.l rs_tedinfo+78*28
	dc.w 1,1,16,1
	dc.w 13,-1,-1,29,$0008,$0000
	dc.l rs_tedinfo+79*28
	dc.w 1,2,16,1
	dc.w 14,-1,-1,29,$0008,$0000
	dc.l rs_tedinfo+80*28
	dc.w 1,3,16,1
	dc.w 10,-1,-1,29,$0008,$0000
	dc.l rs_tedinfo+81*28
	dc.w 1,4,16,1
	dc.w 16,-1,-1,21,$0000,$0000
	dc.l rs_tedinfo+82*28
	dc.w 3,2057,15,1
	dc.w 20,17,19,25,$0000,$0000
	dc.l $11100
	dc.w 23,10,18,5
	dc.w 18,-1,-1,29,$0008,$0000
	dc.l rs_tedinfo+83*28
	dc.w 1,1,16,1
	dc.w 19,-1,-1,29,$0008,$0000
	dc.l rs_tedinfo+84*28
	dc.w 1,2,16,1
	dc.w 16,-1,-1,29,$0008,$0000
	dc.l rs_tedinfo+85*28
	dc.w 1,3,16,1
	dc.w 21,-1,-1,21,$0000,$0000
	dc.l rs_tedinfo+86*28
	dc.w 24,2057,9,1
	dc.w 22,-1,-1,26,$0005,$0000
	dc.l string_368
	dc.w 7,17,10,1
	dc.w 23,-1,-1,26,$0005,$0000
	dc.l string_369
	dc.w 19,17,10,1
	dc.w 24,-1,-1,26,$0007,$0000
	dc.l string_370
	dc.w 31,17,10,1
	dc.w 0,-1,-1,26,$0021,$0000
	dc.l string_371
	dc.w 30,2,8,1

	dc.w -1,1,12,20,$0000,$0010
	dc.l $FF1481
	dc.w 0,0,45,11
	dc.w 9,2,8,25,$0000,$0000
	dc.l $11100
	dc.w 2,1,41,7
	dc.w 3,-1,-1,26,$0001,$0000
	dc.l string_372
	dc.w 2,1,11,1
	dc.w 4,-1,-1,26,$0001,$0000
	dc.l string_373
	dc.w 15,1,11,1
	dc.w 5,-1,-1,26,$0001,$0000
	dc.l string_374
	dc.w 28,1,11,1
	dc.w 6,-1,-1,26,$0001,$0000
	dc.l string_375
	dc.w 2,3,11,1
	dc.w 7,-1,-1,26,$0001,$0000
	dc.l string_376
	dc.w 15,3,11,1
	dc.w 8,-1,-1,26,$0001,$0000
	dc.l string_377
	dc.w 28,3,11,1
	dc.w 1,-1,-1,26,$0001,$0000
	dc.l string_378
	dc.w 2,5,11,1
	dc.w 10,-1,-1,21,$0000,$0000
	dc.l rs_tedinfo+87*28
	dc.w 3,2048,15,1
	dc.w 11,-1,-1,26,$0005,$0000
	dc.l string_382
	dc.w 12,9,9,1
	dc.w 12,-1,-1,26,$0005,$0000
	dc.l string_383
	dc.w 23,9,9,1
	dc.w 0,-1,-1,26,$0027,$0000
	dc.l string_384
	dc.w 34,9,9,1


rs_trindex:	dc.l rs_object+0*24
	dc.l rs_object+18*24
	dc.l rs_object+26*24
	dc.l rs_object+67*24
	dc.l rs_object+136*24
	dc.l rs_object+152*24
	dc.l rs_object+256*24
	dc.l rs_object+280*24
	dc.l rs_object+301*24
	dc.l rs_object+316*24
	dc.l rs_object+341*24


rs_nstrings  equ 385 ; total number of strings
rs_nuser     equ 0 ; total number of USERBLKs
rs_nfrstr    equ 0 ; number of free strings
rs_nimages   equ 1 ; total number of images
rs_nbb       equ 1 ; number of BITBLKs
rs_nfrimg    equ 0 ; number of free images
rs_nib       equ 0 ; number of ICONBLKs
rs_nted      equ 88 ; number of TEDINFOs
rs_nobs      equ 354 ; total number of OBJECTs
rs_ntree     equ 11 ; number of OBJECT trees
