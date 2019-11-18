***********************************************
* Fichier contenant les routines de 'plot' en *
* 8 plans avec optimisation par indice.       *
* D1 : Bit … positionner                      *
* A2 --> Octet de destination                 *
* A5 --> Adresse de retour                    *
***********************************************

    .EXPORT plot_index8


p_8ind000:
    JMP     (A5)


p_8ind001:
    BSET    D1,0(A2)
    JMP     (A5)


p_8ind002:
    BSET    D1,2(A2)
    JMP     (A5)


p_8ind003:
    BSET    D1,0(A2)
    BSET    D1,2(A2)
    JMP     (A5)


p_8ind004:
    BSET    D1,4(A2)
    JMP     (A5)


p_8ind005:
    BSET    D1,0(A2)
    BSET    D1,4(A2)
    JMP     (A5)


p_8ind006:
    BSET    D1,2(A2)
    BSET    D1,4(A2)
    JMP     (A5)


p_8ind007:
    BSET    D1,0(A2)
    BSET    D1,2(A2)
    BSET    D1,4(A2)
    JMP     (A5)


p_8ind008:
    BSET    D1,6(A2)
    JMP     (A5)


p_8ind009:
    BSET    D1,0(A2)
    BSET    D1,6(A2)
    JMP     (A5)


p_8ind010:
    BSET    D1,2(A2)
    BSET    D1,6(A2)
    JMP     (A5)


p_8ind011:
    BSET    D1,0(A2)
    BSET    D1,2(A2)
    BSET    D1,6(A2)
    JMP     (A5)


p_8ind012:
    BSET    D1,4(A2)
    BSET    D1,6(A2)
    JMP     (A5)


p_8ind013:
    BSET    D1,0(A2)
    BSET    D1,4(A2)
    BSET    D1,6(A2)
    JMP     (A5)


p_8ind014:
    BSET    D1,2(A2)
    BSET    D1,4(A2)
    BSET    D1,6(A2)
    JMP     (A5)


p_8ind015:
    BSET    D1,0(A2)
    BSET    D1,2(A2)
    BSET    D1,4(A2)
    BSET    D1,6(A2)
    JMP     (A5)


p_8ind016:
    BSET    D1,8(A2)
    JMP     (A5)


p_8ind017:
    BSET    D1,0(A2)
    BSET    D1,8(A2)
    JMP     (A5)


p_8ind018:
    BSET    D1,2(A2)
    BSET    D1,8(A2)
    JMP     (A5)


p_8ind019:
    BSET    D1,0(A2)
    BSET    D1,2(A2)
    BSET    D1,8(A2)
    JMP     (A5)


p_8ind020:
    BSET    D1,4(A2)
    BSET    D1,8(A2)
    JMP     (A5)


p_8ind021:
    BSET    D1,0(A2)
    BSET    D1,4(A2)
    BSET    D1,8(A2)
    JMP     (A5)


p_8ind022:
    BSET    D1,2(A2)
    BSET    D1,4(A2)
    BSET    D1,8(A2)
    JMP     (A5)


p_8ind023:
    BSET    D1,0(A2)
    BSET    D1,2(A2)
    BSET    D1,4(A2)
    BSET    D1,8(A2)
    JMP     (A5)


p_8ind024:
    BSET    D1,6(A2)
    BSET    D1,8(A2)
    JMP     (A5)


p_8ind025:
    BSET    D1,0(A2)
    BSET    D1,6(A2)
    BSET    D1,8(A2)
    JMP     (A5)


p_8ind026:
    BSET    D1,2(A2)
    BSET    D1,6(A2)
    BSET    D1,8(A2)
    JMP     (A5)


p_8ind027:
    BSET    D1,0(A2)
    BSET    D1,2(A2)
    BSET    D1,6(A2)
    BSET    D1,8(A2)
    JMP     (A5)


p_8ind028:
    BSET    D1,4(A2)
    BSET    D1,6(A2)
    BSET    D1,8(A2)
    JMP     (A5)


p_8ind029:
    BSET    D1,0(A2)
    BSET    D1,4(A2)
    BSET    D1,6(A2)
    BSET    D1,8(A2)
    JMP     (A5)


p_8ind030:
    BSET    D1,2(A2)
    BSET    D1,4(A2)
    BSET    D1,6(A2)
    BSET    D1,8(A2)
    JMP     (A5)


p_8ind031:
    BSET    D1,0(A2)
    BSET    D1,2(A2)
    BSET    D1,4(A2)
    BSET    D1,6(A2)
    BSET    D1,8(A2)
    JMP     (A5)


p_8ind032:
    BSET    D1,10(A2)
    JMP     (A5)


p_8ind033:
    BSET    D1,0(A2)
    BSET    D1,10(A2)
    JMP     (A5)


p_8ind034:
    BSET    D1,2(A2)
    BSET    D1,10(A2)
    JMP     (A5)


p_8ind035:
    BSET    D1,0(A2)
    BSET    D1,2(A2)
    BSET    D1,10(A2)
    JMP     (A5)


p_8ind036:
    BSET    D1,4(A2)
    BSET    D1,10(A2)
    JMP     (A5)


p_8ind037:
    BSET    D1,0(A2)
    BSET    D1,4(A2)
    BSET    D1,10(A2)
    JMP     (A5)


p_8ind038:
    BSET    D1,2(A2)
    BSET    D1,4(A2)
    BSET    D1,10(A2)
    JMP     (A5)


p_8ind039:
    BSET    D1,0(A2)
    BSET    D1,2(A2)
    BSET    D1,4(A2)
    BSET    D1,10(A2)
    JMP     (A5)


p_8ind040:
    BSET    D1,6(A2)
    BSET    D1,10(A2)
    JMP     (A5)


p_8ind041:
    BSET    D1,0(A2)
    BSET    D1,6(A2)
    BSET    D1,10(A2)
    JMP     (A5)


p_8ind042:
    BSET    D1,2(A2)
    BSET    D1,6(A2)
    BSET    D1,10(A2)
    JMP     (A5)


p_8ind043:
    BSET    D1,0(A2)
    BSET    D1,2(A2)
    BSET    D1,6(A2)
    BSET    D1,10(A2)
    JMP     (A5)


p_8ind044:
    BSET    D1,4(A2)
    BSET    D1,6(A2)
    BSET    D1,10(A2)
    JMP     (A5)


p_8ind045:
    BSET    D1,0(A2)
    BSET    D1,4(A2)
    BSET    D1,6(A2)
    BSET    D1,10(A2)
    JMP     (A5)


p_8ind046:
    BSET    D1,2(A2)
    BSET    D1,4(A2)
    BSET    D1,6(A2)
    BSET    D1,10(A2)
    JMP     (A5)


p_8ind047:
    BSET    D1,0(A2)
    BSET    D1,2(A2)
    BSET    D1,4(A2)
    BSET    D1,6(A2)
    BSET    D1,10(A2)
    JMP     (A5)


p_8ind048:
    BSET    D1,8(A2)
    BSET    D1,10(A2)
    JMP     (A5)


p_8ind049:
    BSET    D1,0(A2)
    BSET    D1,8(A2)
    BSET    D1,10(A2)
    JMP     (A5)


p_8ind050:
    BSET    D1,2(A2)
    BSET    D1,8(A2)
    BSET    D1,10(A2)
    JMP     (A5)


p_8ind051:
    BSET    D1,0(A2)
    BSET    D1,2(A2)
    BSET    D1,8(A2)
    BSET    D1,10(A2)
    JMP     (A5)


p_8ind052:
    BSET    D1,4(A2)
    BSET    D1,8(A2)
    BSET    D1,10(A2)
    JMP     (A5)


p_8ind053:
    BSET    D1,0(A2)
    BSET    D1,4(A2)
    BSET    D1,8(A2)
    BSET    D1,10(A2)
    JMP     (A5)


p_8ind054:
    BSET    D1,2(A2)
    BSET    D1,4(A2)
    BSET    D1,8(A2)
    BSET    D1,10(A2)
    JMP     (A5)


p_8ind055:
    BSET    D1,0(A2)
    BSET    D1,2(A2)
    BSET    D1,4(A2)
    BSET    D1,8(A2)
    BSET    D1,10(A2)
    JMP     (A5)


p_8ind056:
    BSET    D1,6(A2)
    BSET    D1,8(A2)
    BSET    D1,10(A2)
    JMP     (A5)


p_8ind057:
    BSET    D1,0(A2)
    BSET    D1,6(A2)
    BSET    D1,8(A2)
    BSET    D1,10(A2)
    JMP     (A5)


p_8ind058:
    BSET    D1,2(A2)
    BSET    D1,6(A2)
    BSET    D1,8(A2)
    BSET    D1,10(A2)
    JMP     (A5)


p_8ind059:
    BSET    D1,0(A2)
    BSET    D1,2(A2)
    BSET    D1,6(A2)
    BSET    D1,8(A2)
    BSET    D1,10(A2)
    JMP     (A5)


p_8ind060:
    BSET    D1,4(A2)
    BSET    D1,6(A2)
    BSET    D1,8(A2)
    BSET    D1,10(A2)
    JMP     (A5)


p_8ind061:
    BSET    D1,0(A2)
    BSET    D1,4(A2)
    BSET    D1,6(A2)
    BSET    D1,8(A2)
    BSET    D1,10(A2)
    JMP     (A5)


p_8ind062:
    BSET    D1,2(A2)
    BSET    D1,4(A2)
    BSET    D1,6(A2)
    BSET    D1,8(A2)
    BSET    D1,10(A2)
    JMP     (A5)


p_8ind063:
    BSET    D1,0(A2)
    BSET    D1,2(A2)
    BSET    D1,4(A2)
    BSET    D1,6(A2)
    BSET    D1,8(A2)
    BSET    D1,10(A2)
    JMP     (A5)


p_8ind064:
    BSET    D1,12(A2)
    JMP     (A5)


p_8ind065:
    BSET    D1,0(A2)
    BSET    D1,12(A2)
    JMP     (A5)


p_8ind066:
    BSET    D1,2(A2)
    BSET    D1,12(A2)
    JMP     (A5)


p_8ind067:
    BSET    D1,0(A2)
    BSET    D1,2(A2)
    BSET    D1,12(A2)
    JMP     (A5)


p_8ind068:
    BSET    D1,4(A2)
    BSET    D1,12(A2)
    JMP     (A5)


p_8ind069:
    BSET    D1,0(A2)
    BSET    D1,4(A2)
    BSET    D1,12(A2)
    JMP     (A5)


p_8ind070:
    BSET    D1,2(A2)
    BSET    D1,4(A2)
    BSET    D1,12(A2)
    JMP     (A5)


p_8ind071:
    BSET    D1,0(A2)
    BSET    D1,2(A2)
    BSET    D1,4(A2)
    BSET    D1,12(A2)
    JMP     (A5)


p_8ind072:
    BSET    D1,6(A2)
    BSET    D1,12(A2)
    JMP     (A5)


p_8ind073:
    BSET    D1,0(A2)
    BSET    D1,6(A2)
    BSET    D1,12(A2)
    JMP     (A5)


p_8ind074:
    BSET    D1,2(A2)
    BSET    D1,6(A2)
    BSET    D1,12(A2)
    JMP     (A5)


p_8ind075:
    BSET    D1,0(A2)
    BSET    D1,2(A2)
    BSET    D1,6(A2)
    BSET    D1,12(A2)
    JMP     (A5)


p_8ind076:
    BSET    D1,4(A2)
    BSET    D1,6(A2)
    BSET    D1,12(A2)
    JMP     (A5)


p_8ind077:
    BSET    D1,0(A2)
    BSET    D1,4(A2)
    BSET    D1,6(A2)
    BSET    D1,12(A2)
    JMP     (A5)


p_8ind078:
    BSET    D1,2(A2)
    BSET    D1,4(A2)
    BSET    D1,6(A2)
    BSET    D1,12(A2)
    JMP     (A5)


p_8ind079:
    BSET    D1,0(A2)
    BSET    D1,2(A2)
    BSET    D1,4(A2)
    BSET    D1,6(A2)
    BSET    D1,12(A2)
    JMP     (A5)


p_8ind080:
    BSET    D1,8(A2)
    BSET    D1,12(A2)
    JMP     (A5)


p_8ind081:
    BSET    D1,0(A2)
    BSET    D1,8(A2)
    BSET    D1,12(A2)
    JMP     (A5)


p_8ind082:
    BSET    D1,2(A2)
    BSET    D1,8(A2)
    BSET    D1,12(A2)
    JMP     (A5)


p_8ind083:
    BSET    D1,0(A2)
    BSET    D1,2(A2)
    BSET    D1,8(A2)
    BSET    D1,12(A2)
    JMP     (A5)


p_8ind084:
    BSET    D1,4(A2)
    BSET    D1,8(A2)
    BSET    D1,12(A2)
    JMP     (A5)


p_8ind085:
    BSET    D1,0(A2)
    BSET    D1,4(A2)
    BSET    D1,8(A2)
    BSET    D1,12(A2)
    JMP     (A5)


p_8ind086:
    BSET    D1,2(A2)
    BSET    D1,4(A2)
    BSET    D1,8(A2)
    BSET    D1,12(A2)
    JMP     (A5)


p_8ind087:
    BSET    D1,0(A2)
    BSET    D1,2(A2)
    BSET    D1,4(A2)
    BSET    D1,8(A2)
    BSET    D1,12(A2)
    JMP     (A5)


p_8ind088:
    BSET    D1,6(A2)
    BSET    D1,8(A2)
    BSET    D1,12(A2)
    JMP     (A5)


p_8ind089:
    BSET    D1,0(A2)
    BSET    D1,6(A2)
    BSET    D1,8(A2)
    BSET    D1,12(A2)
    JMP     (A5)


p_8ind090:
    BSET    D1,2(A2)
    BSET    D1,6(A2)
    BSET    D1,8(A2)
    BSET    D1,12(A2)
    JMP     (A5)


p_8ind091:
    BSET    D1,0(A2)
    BSET    D1,2(A2)
    BSET    D1,6(A2)
    BSET    D1,8(A2)
    BSET    D1,12(A2)
    JMP     (A5)


p_8ind092:
    BSET    D1,4(A2)
    BSET    D1,6(A2)
    BSET    D1,8(A2)
    BSET    D1,12(A2)
    JMP     (A5)


p_8ind093:
    BSET    D1,0(A2)
    BSET    D1,4(A2)
    BSET    D1,6(A2)
    BSET    D1,8(A2)
    BSET    D1,12(A2)
    JMP     (A5)


p_8ind094:
    BSET    D1,2(A2)
    BSET    D1,4(A2)
    BSET    D1,6(A2)
    BSET    D1,8(A2)
    BSET    D1,12(A2)
    JMP     (A5)


p_8ind095:
    BSET    D1,0(A2)
    BSET    D1,2(A2)
    BSET    D1,4(A2)
    BSET    D1,6(A2)
    BSET    D1,8(A2)
    BSET    D1,12(A2)
    JMP     (A5)


p_8ind096:
    BSET    D1,10(A2)
    BSET    D1,12(A2)
    JMP     (A5)


p_8ind097:
    BSET    D1,0(A2)
    BSET    D1,10(A2)
    BSET    D1,12(A2)
    JMP     (A5)


p_8ind098:
    BSET    D1,2(A2)
    BSET    D1,10(A2)
    BSET    D1,12(A2)
    JMP     (A5)


p_8ind099:
    BSET    D1,0(A2)
    BSET    D1,2(A2)
    BSET    D1,10(A2)
    BSET    D1,12(A2)
    JMP     (A5)


p_8ind100:
    BSET    D1,4(A2)
    BSET    D1,10(A2)
    BSET    D1,12(A2)
    JMP     (A5)


p_8ind101:
    BSET    D1,0(A2)
    BSET    D1,4(A2)
    BSET    D1,10(A2)
    BSET    D1,12(A2)
    JMP     (A5)


p_8ind102:
    BSET    D1,2(A2)
    BSET    D1,4(A2)
    BSET    D1,10(A2)
    BSET    D1,12(A2)
    JMP     (A5)


p_8ind103:
    BSET    D1,0(A2)
    BSET    D1,2(A2)
    BSET    D1,4(A2)
    BSET    D1,10(A2)
    BSET    D1,12(A2)
    JMP     (A5)


p_8ind104:
    BSET    D1,6(A2)
    BSET    D1,10(A2)
    BSET    D1,12(A2)
    JMP     (A5)


p_8ind105:
    BSET    D1,0(A2)
    BSET    D1,6(A2)
    BSET    D1,10(A2)
    BSET    D1,12(A2)
    JMP     (A5)


p_8ind106:
    BSET    D1,2(A2)
    BSET    D1,6(A2)
    BSET    D1,10(A2)
    BSET    D1,12(A2)
    JMP     (A5)


p_8ind107:
    BSET    D1,0(A2)
    BSET    D1,2(A2)
    BSET    D1,6(A2)
    BSET    D1,10(A2)
    BSET    D1,12(A2)
    JMP     (A5)


p_8ind108:
    BSET    D1,4(A2)
    BSET    D1,6(A2)
    BSET    D1,10(A2)
    BSET    D1,12(A2)
    JMP     (A5)


p_8ind109:
    BSET    D1,0(A2)
    BSET    D1,4(A2)
    BSET    D1,6(A2)
    BSET    D1,10(A2)
    BSET    D1,12(A2)
    JMP     (A5)


p_8ind110:
    BSET    D1,2(A2)
    BSET    D1,4(A2)
    BSET    D1,6(A2)
    BSET    D1,10(A2)
    BSET    D1,12(A2)
    JMP     (A5)


p_8ind111:
    BSET    D1,0(A2)
    BSET    D1,2(A2)
    BSET    D1,4(A2)
    BSET    D1,6(A2)
    BSET    D1,10(A2)
    BSET    D1,12(A2)
    JMP     (A5)


p_8ind112:
    BSET    D1,8(A2)
    BSET    D1,10(A2)
    BSET    D1,12(A2)
    JMP     (A5)


p_8ind113:
    BSET    D1,0(A2)
    BSET    D1,8(A2)
    BSET    D1,10(A2)
    BSET    D1,12(A2)
    JMP     (A5)


p_8ind114:
    BSET    D1,2(A2)
    BSET    D1,8(A2)
    BSET    D1,10(A2)
    BSET    D1,12(A2)
    JMP     (A5)


p_8ind115:
    BSET    D1,0(A2)
    BSET    D1,2(A2)
    BSET    D1,8(A2)
    BSET    D1,10(A2)
    BSET    D1,12(A2)
    JMP     (A5)


p_8ind116:
    BSET    D1,4(A2)
    BSET    D1,8(A2)
    BSET    D1,10(A2)
    BSET    D1,12(A2)
    JMP     (A5)


p_8ind117:
    BSET    D1,0(A2)
    BSET    D1,4(A2)
    BSET    D1,8(A2)
    BSET    D1,10(A2)
    BSET    D1,12(A2)
    JMP     (A5)


p_8ind118:
    BSET    D1,2(A2)
    BSET    D1,4(A2)
    BSET    D1,8(A2)
    BSET    D1,10(A2)
    BSET    D1,12(A2)
    JMP     (A5)


p_8ind119:
    BSET    D1,0(A2)
    BSET    D1,2(A2)
    BSET    D1,4(A2)
    BSET    D1,8(A2)
    BSET    D1,10(A2)
    BSET    D1,12(A2)
    JMP     (A5)


p_8ind120:
    BSET    D1,6(A2)
    BSET    D1,8(A2)
    BSET    D1,10(A2)
    BSET    D1,12(A2)
    JMP     (A5)


p_8ind121:
    BSET    D1,0(A2)
    BSET    D1,6(A2)
    BSET    D1,8(A2)
    BSET    D1,10(A2)
    BSET    D1,12(A2)
    JMP     (A5)


p_8ind122:
    BSET    D1,2(A2)
    BSET    D1,6(A2)
    BSET    D1,8(A2)
    BSET    D1,10(A2)
    BSET    D1,12(A2)
    JMP     (A5)


p_8ind123:
    BSET    D1,0(A2)
    BSET    D1,2(A2)
    BSET    D1,6(A2)
    BSET    D1,8(A2)
    BSET    D1,10(A2)
    BSET    D1,12(A2)
    JMP     (A5)


p_8ind124:
    BSET    D1,4(A2)
    BSET    D1,6(A2)
    BSET    D1,8(A2)
    BSET    D1,10(A2)
    BSET    D1,12(A2)
    JMP     (A5)


p_8ind125:
    BSET    D1,0(A2)
    BSET    D1,4(A2)
    BSET    D1,6(A2)
    BSET    D1,8(A2)
    BSET    D1,10(A2)
    BSET    D1,12(A2)
    JMP     (A5)


p_8ind126:
    BSET    D1,2(A2)
    BSET    D1,4(A2)
    BSET    D1,6(A2)
    BSET    D1,8(A2)
    BSET    D1,10(A2)
    BSET    D1,12(A2)
    JMP     (A5)


p_8ind127:
    BSET    D1,0(A2)
    BSET    D1,2(A2)
    BSET    D1,4(A2)
    BSET    D1,6(A2)
    BSET    D1,8(A2)
    BSET    D1,10(A2)
    BSET    D1,12(A2)
    JMP     (A5)


p_8ind128:
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind129:
    BSET    D1,0(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind130:
    BSET    D1,2(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind131:
    BSET    D1,0(A2)
    BSET    D1,2(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind132:
    BSET    D1,4(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind133:
    BSET    D1,0(A2)
    BSET    D1,4(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind134:
    BSET    D1,2(A2)
    BSET    D1,4(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind135:
    BSET    D1,0(A2)
    BSET    D1,2(A2)
    BSET    D1,4(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind136:
    BSET    D1,6(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind137:
    BSET    D1,0(A2)
    BSET    D1,6(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind138:
    BSET    D1,2(A2)
    BSET    D1,6(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind139:
    BSET    D1,0(A2)
    BSET    D1,2(A2)
    BSET    D1,6(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind140:
    BSET    D1,4(A2)
    BSET    D1,6(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind141:
    BSET    D1,0(A2)
    BSET    D1,4(A2)
    BSET    D1,6(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind142:
    BSET    D1,2(A2)
    BSET    D1,4(A2)
    BSET    D1,6(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind143:
    BSET    D1,0(A2)
    BSET    D1,2(A2)
    BSET    D1,4(A2)
    BSET    D1,6(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind144:
    BSET    D1,8(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind145:
    BSET    D1,0(A2)
    BSET    D1,8(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind146:
    BSET    D1,2(A2)
    BSET    D1,8(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind147:
    BSET    D1,0(A2)
    BSET    D1,2(A2)
    BSET    D1,8(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind148:
    BSET    D1,4(A2)
    BSET    D1,8(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind149:
    BSET    D1,0(A2)
    BSET    D1,4(A2)
    BSET    D1,8(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind150:
    BSET    D1,2(A2)
    BSET    D1,4(A2)
    BSET    D1,8(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind151:
    BSET    D1,0(A2)
    BSET    D1,2(A2)
    BSET    D1,4(A2)
    BSET    D1,8(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind152:
    BSET    D1,6(A2)
    BSET    D1,8(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind153:
    BSET    D1,0(A2)
    BSET    D1,6(A2)
    BSET    D1,8(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind154:
    BSET    D1,2(A2)
    BSET    D1,6(A2)
    BSET    D1,8(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind155:
    BSET    D1,0(A2)
    BSET    D1,2(A2)
    BSET    D1,6(A2)
    BSET    D1,8(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind156:
    BSET    D1,4(A2)
    BSET    D1,6(A2)
    BSET    D1,8(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind157:
    BSET    D1,0(A2)
    BSET    D1,4(A2)
    BSET    D1,6(A2)
    BSET    D1,8(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind158:
    BSET    D1,2(A2)
    BSET    D1,4(A2)
    BSET    D1,6(A2)
    BSET    D1,8(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind159:
    BSET    D1,0(A2)
    BSET    D1,2(A2)
    BSET    D1,4(A2)
    BSET    D1,6(A2)
    BSET    D1,8(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind160:
    BSET    D1,10(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind161:
    BSET    D1,0(A2)
    BSET    D1,10(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind162:
    BSET    D1,2(A2)
    BSET    D1,10(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind163:
    BSET    D1,0(A2)
    BSET    D1,2(A2)
    BSET    D1,10(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind164:
    BSET    D1,4(A2)
    BSET    D1,10(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind165:
    BSET    D1,0(A2)
    BSET    D1,4(A2)
    BSET    D1,10(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind166:
    BSET    D1,2(A2)
    BSET    D1,4(A2)
    BSET    D1,10(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind167:
    BSET    D1,0(A2)
    BSET    D1,2(A2)
    BSET    D1,4(A2)
    BSET    D1,10(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind168:
    BSET    D1,6(A2)
    BSET    D1,10(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind169:
    BSET    D1,0(A2)
    BSET    D1,6(A2)
    BSET    D1,10(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind170:
    BSET    D1,2(A2)
    BSET    D1,6(A2)
    BSET    D1,10(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind171:
    BSET    D1,0(A2)
    BSET    D1,2(A2)
    BSET    D1,6(A2)
    BSET    D1,10(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind172:
    BSET    D1,4(A2)
    BSET    D1,6(A2)
    BSET    D1,10(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind173:
    BSET    D1,0(A2)
    BSET    D1,4(A2)
    BSET    D1,6(A2)
    BSET    D1,10(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind174:
    BSET    D1,2(A2)
    BSET    D1,4(A2)
    BSET    D1,6(A2)
    BSET    D1,10(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind175:
    BSET    D1,0(A2)
    BSET    D1,2(A2)
    BSET    D1,4(A2)
    BSET    D1,6(A2)
    BSET    D1,10(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind176:
    BSET    D1,8(A2)
    BSET    D1,10(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind177:
    BSET    D1,0(A2)
    BSET    D1,8(A2)
    BSET    D1,10(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind178:
    BSET    D1,2(A2)
    BSET    D1,8(A2)
    BSET    D1,10(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind179:
    BSET    D1,0(A2)
    BSET    D1,2(A2)
    BSET    D1,8(A2)
    BSET    D1,10(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind180:
    BSET    D1,4(A2)
    BSET    D1,8(A2)
    BSET    D1,10(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind181:
    BSET    D1,0(A2)
    BSET    D1,4(A2)
    BSET    D1,8(A2)
    BSET    D1,10(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind182:
    BSET    D1,2(A2)
    BSET    D1,4(A2)
    BSET    D1,8(A2)
    BSET    D1,10(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind183:
    BSET    D1,0(A2)
    BSET    D1,2(A2)
    BSET    D1,4(A2)
    BSET    D1,8(A2)
    BSET    D1,10(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind184:
    BSET    D1,6(A2)
    BSET    D1,8(A2)
    BSET    D1,10(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind185:
    BSET    D1,0(A2)
    BSET    D1,6(A2)
    BSET    D1,8(A2)
    BSET    D1,10(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind186:
    BSET    D1,2(A2)
    BSET    D1,6(A2)
    BSET    D1,8(A2)
    BSET    D1,10(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind187:
    BSET    D1,0(A2)
    BSET    D1,2(A2)
    BSET    D1,6(A2)
    BSET    D1,8(A2)
    BSET    D1,10(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind188:
    BSET    D1,4(A2)
    BSET    D1,6(A2)
    BSET    D1,8(A2)
    BSET    D1,10(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind189:
    BSET    D1,0(A2)
    BSET    D1,4(A2)
    BSET    D1,6(A2)
    BSET    D1,8(A2)
    BSET    D1,10(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind190:
    BSET    D1,2(A2)
    BSET    D1,4(A2)
    BSET    D1,6(A2)
    BSET    D1,8(A2)
    BSET    D1,10(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind191:
    BSET    D1,0(A2)
    BSET    D1,2(A2)
    BSET    D1,4(A2)
    BSET    D1,6(A2)
    BSET    D1,8(A2)
    BSET    D1,10(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind192:
    BSET    D1,12(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind193:
    BSET    D1,0(A2)
    BSET    D1,12(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind194:
    BSET    D1,2(A2)
    BSET    D1,12(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind195:
    BSET    D1,0(A2)
    BSET    D1,2(A2)
    BSET    D1,12(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind196:
    BSET    D1,4(A2)
    BSET    D1,12(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind197:
    BSET    D1,0(A2)
    BSET    D1,4(A2)
    BSET    D1,12(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind198:
    BSET    D1,2(A2)
    BSET    D1,4(A2)
    BSET    D1,12(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind199:
    BSET    D1,0(A2)
    BSET    D1,2(A2)
    BSET    D1,4(A2)
    BSET    D1,12(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind200:
    BSET    D1,6(A2)
    BSET    D1,12(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind201:
    BSET    D1,0(A2)
    BSET    D1,6(A2)
    BSET    D1,12(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind202:
    BSET    D1,2(A2)
    BSET    D1,6(A2)
    BSET    D1,12(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind203:
    BSET    D1,0(A2)
    BSET    D1,2(A2)
    BSET    D1,6(A2)
    BSET    D1,12(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind204:
    BSET    D1,4(A2)
    BSET    D1,6(A2)
    BSET    D1,12(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind205:
    BSET    D1,0(A2)
    BSET    D1,4(A2)
    BSET    D1,6(A2)
    BSET    D1,12(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind206:
    BSET    D1,2(A2)
    BSET    D1,4(A2)
    BSET    D1,6(A2)
    BSET    D1,12(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind207:
    BSET    D1,0(A2)
    BSET    D1,2(A2)
    BSET    D1,4(A2)
    BSET    D1,6(A2)
    BSET    D1,12(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind208:
    BSET    D1,8(A2)
    BSET    D1,12(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind209:
    BSET    D1,0(A2)
    BSET    D1,8(A2)
    BSET    D1,12(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind210:
    BSET    D1,2(A2)
    BSET    D1,8(A2)
    BSET    D1,12(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind211:
    BSET    D1,0(A2)
    BSET    D1,2(A2)
    BSET    D1,8(A2)
    BSET    D1,12(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind212:
    BSET    D1,4(A2)
    BSET    D1,8(A2)
    BSET    D1,12(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind213:
    BSET    D1,0(A2)
    BSET    D1,4(A2)
    BSET    D1,8(A2)
    BSET    D1,12(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind214:
    BSET    D1,2(A2)
    BSET    D1,4(A2)
    BSET    D1,8(A2)
    BSET    D1,12(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind215:
    BSET    D1,0(A2)
    BSET    D1,2(A2)
    BSET    D1,4(A2)
    BSET    D1,8(A2)
    BSET    D1,12(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind216:
    BSET    D1,6(A2)
    BSET    D1,8(A2)
    BSET    D1,12(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind217:
    BSET    D1,0(A2)
    BSET    D1,6(A2)
    BSET    D1,8(A2)
    BSET    D1,12(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind218:
    BSET    D1,2(A2)
    BSET    D1,6(A2)
    BSET    D1,8(A2)
    BSET    D1,12(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind219:
    BSET    D1,0(A2)
    BSET    D1,2(A2)
    BSET    D1,6(A2)
    BSET    D1,8(A2)
    BSET    D1,12(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind220:
    BSET    D1,4(A2)
    BSET    D1,6(A2)
    BSET    D1,8(A2)
    BSET    D1,12(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind221:
    BSET    D1,0(A2)
    BSET    D1,4(A2)
    BSET    D1,6(A2)
    BSET    D1,8(A2)
    BSET    D1,12(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind222:
    BSET    D1,2(A2)
    BSET    D1,4(A2)
    BSET    D1,6(A2)
    BSET    D1,8(A2)
    BSET    D1,12(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind223:
    BSET    D1,0(A2)
    BSET    D1,2(A2)
    BSET    D1,4(A2)
    BSET    D1,6(A2)
    BSET    D1,8(A2)
    BSET    D1,12(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind224:
    BSET    D1,10(A2)
    BSET    D1,12(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind225:
    BSET    D1,0(A2)
    BSET    D1,10(A2)
    BSET    D1,12(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind226:
    BSET    D1,2(A2)
    BSET    D1,10(A2)
    BSET    D1,12(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind227:
    BSET    D1,0(A2)
    BSET    D1,2(A2)
    BSET    D1,10(A2)
    BSET    D1,12(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind228:
    BSET    D1,4(A2)
    BSET    D1,10(A2)
    BSET    D1,12(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind229:
    BSET    D1,0(A2)
    BSET    D1,4(A2)
    BSET    D1,10(A2)
    BSET    D1,12(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind230:
    BSET    D1,2(A2)
    BSET    D1,4(A2)
    BSET    D1,10(A2)
    BSET    D1,12(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind231:
    BSET    D1,0(A2)
    BSET    D1,2(A2)
    BSET    D1,4(A2)
    BSET    D1,10(A2)
    BSET    D1,12(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind232:
    BSET    D1,6(A2)
    BSET    D1,10(A2)
    BSET    D1,12(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind233:
    BSET    D1,0(A2)
    BSET    D1,6(A2)
    BSET    D1,10(A2)
    BSET    D1,12(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind234:
    BSET    D1,2(A2)
    BSET    D1,6(A2)
    BSET    D1,10(A2)
    BSET    D1,12(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind235:
    BSET    D1,0(A2)
    BSET    D1,2(A2)
    BSET    D1,6(A2)
    BSET    D1,10(A2)
    BSET    D1,12(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind236:
    BSET    D1,4(A2)
    BSET    D1,6(A2)
    BSET    D1,10(A2)
    BSET    D1,12(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind237:
    BSET    D1,0(A2)
    BSET    D1,4(A2)
    BSET    D1,6(A2)
    BSET    D1,10(A2)
    BSET    D1,12(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind238:
    BSET    D1,2(A2)
    BSET    D1,4(A2)
    BSET    D1,6(A2)
    BSET    D1,10(A2)
    BSET    D1,12(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind239:
    BSET    D1,0(A2)
    BSET    D1,2(A2)
    BSET    D1,4(A2)
    BSET    D1,6(A2)
    BSET    D1,10(A2)
    BSET    D1,12(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind240:
    BSET    D1,8(A2)
    BSET    D1,10(A2)
    BSET    D1,12(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind241:
    BSET    D1,0(A2)
    BSET    D1,8(A2)
    BSET    D1,10(A2)
    BSET    D1,12(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind242:
    BSET    D1,2(A2)
    BSET    D1,8(A2)
    BSET    D1,10(A2)
    BSET    D1,12(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind243:
    BSET    D1,0(A2)
    BSET    D1,2(A2)
    BSET    D1,8(A2)
    BSET    D1,10(A2)
    BSET    D1,12(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind244:
    BSET    D1,4(A2)
    BSET    D1,8(A2)
    BSET    D1,10(A2)
    BSET    D1,12(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind245:
    BSET    D1,0(A2)
    BSET    D1,4(A2)
    BSET    D1,8(A2)
    BSET    D1,10(A2)
    BSET    D1,12(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind246:
    BSET    D1,2(A2)
    BSET    D1,4(A2)
    BSET    D1,8(A2)
    BSET    D1,10(A2)
    BSET    D1,12(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind247:
    BSET    D1,0(A2)
    BSET    D1,2(A2)
    BSET    D1,4(A2)
    BSET    D1,8(A2)
    BSET    D1,10(A2)
    BSET    D1,12(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind248:
    BSET    D1,6(A2)
    BSET    D1,8(A2)
    BSET    D1,10(A2)
    BSET    D1,12(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind249:
    BSET    D1,0(A2)
    BSET    D1,6(A2)
    BSET    D1,8(A2)
    BSET    D1,10(A2)
    BSET    D1,12(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind250:
    BSET    D1,2(A2)
    BSET    D1,6(A2)
    BSET    D1,8(A2)
    BSET    D1,10(A2)
    BSET    D1,12(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind251:
    BSET    D1,0(A2)
    BSET    D1,2(A2)
    BSET    D1,6(A2)
    BSET    D1,8(A2)
    BSET    D1,10(A2)
    BSET    D1,12(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind252:
    BSET    D1,4(A2)
    BSET    D1,6(A2)
    BSET    D1,8(A2)
    BSET    D1,10(A2)
    BSET    D1,12(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind253:
    BSET    D1,0(A2)
    BSET    D1,4(A2)
    BSET    D1,6(A2)
    BSET    D1,8(A2)
    BSET    D1,10(A2)
    BSET    D1,12(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind254:
    BSET    D1,2(A2)
    BSET    D1,4(A2)
    BSET    D1,6(A2)
    BSET    D1,8(A2)
    BSET    D1,10(A2)
    BSET    D1,12(A2)
    BSET    D1,14(A2)
    JMP     (A5)


p_8ind255:
    BSET    D1,0(A2)
    BSET    D1,2(A2)
    BSET    D1,4(A2)
    BSET    D1,6(A2)
    BSET    D1,8(A2)
    BSET    D1,10(A2)
    BSET    D1,12(A2)
    BSET    D1,14(A2)
    JMP     (A5)



plot_index8:

    .DC.L    p_8ind000, p_8ind001, p_8ind002, p_8ind003, p_8ind004, p_8ind005, p_8ind006, p_8ind007
    .DC.L    p_8ind008, p_8ind009, p_8ind010, p_8ind011, p_8ind012, p_8ind013, p_8ind014, p_8ind015
    .DC.L    p_8ind016, p_8ind017, p_8ind018, p_8ind019, p_8ind020, p_8ind021, p_8ind022, p_8ind023
    .DC.L    p_8ind024, p_8ind025, p_8ind026, p_8ind027, p_8ind028, p_8ind029, p_8ind030, p_8ind031
    .DC.L    p_8ind032, p_8ind033, p_8ind034, p_8ind035, p_8ind036, p_8ind037, p_8ind038, p_8ind039
    .DC.L    p_8ind040, p_8ind041, p_8ind042, p_8ind043, p_8ind044, p_8ind045, p_8ind046, p_8ind047
    .DC.L    p_8ind048, p_8ind049, p_8ind050, p_8ind051, p_8ind052, p_8ind053, p_8ind054, p_8ind055
    .DC.L    p_8ind056, p_8ind057, p_8ind058, p_8ind059, p_8ind060, p_8ind061, p_8ind062, p_8ind063
    .DC.L    p_8ind064, p_8ind065, p_8ind066, p_8ind067, p_8ind068, p_8ind069, p_8ind070, p_8ind071
    .DC.L    p_8ind072, p_8ind073, p_8ind074, p_8ind075, p_8ind076, p_8ind077, p_8ind078, p_8ind079
    .DC.L    p_8ind080, p_8ind081, p_8ind082, p_8ind083, p_8ind084, p_8ind085, p_8ind086, p_8ind087
    .DC.L    p_8ind088, p_8ind089, p_8ind090, p_8ind091, p_8ind092, p_8ind093, p_8ind094, p_8ind095
    .DC.L    p_8ind096, p_8ind097, p_8ind098, p_8ind099, p_8ind100, p_8ind101, p_8ind102, p_8ind103
    .DC.L    p_8ind104, p_8ind105, p_8ind106, p_8ind107, p_8ind108, p_8ind109, p_8ind110, p_8ind111
    .DC.L    p_8ind112, p_8ind113, p_8ind114, p_8ind115, p_8ind116, p_8ind117, p_8ind118, p_8ind119
    .DC.L    p_8ind120, p_8ind121, p_8ind122, p_8ind123, p_8ind124, p_8ind125, p_8ind126, p_8ind127
    .DC.L    p_8ind128, p_8ind129, p_8ind130, p_8ind131, p_8ind132, p_8ind133, p_8ind134, p_8ind135
    .DC.L    p_8ind136, p_8ind137, p_8ind138, p_8ind139, p_8ind140, p_8ind141, p_8ind142, p_8ind143
    .DC.L    p_8ind144, p_8ind145, p_8ind146, p_8ind147, p_8ind148, p_8ind149, p_8ind150, p_8ind151
    .DC.L    p_8ind152, p_8ind153, p_8ind154, p_8ind155, p_8ind156, p_8ind157, p_8ind158, p_8ind159
    .DC.L    p_8ind160, p_8ind161, p_8ind162, p_8ind163, p_8ind164, p_8ind165, p_8ind166, p_8ind167
    .DC.L    p_8ind168, p_8ind169, p_8ind170, p_8ind171, p_8ind172, p_8ind173, p_8ind174, p_8ind175
    .DC.L    p_8ind176, p_8ind177, p_8ind178, p_8ind179, p_8ind180, p_8ind181, p_8ind182, p_8ind183
    .DC.L    p_8ind184, p_8ind185, p_8ind186, p_8ind187, p_8ind188, p_8ind189, p_8ind190, p_8ind191
    .DC.L    p_8ind192, p_8ind193, p_8ind194, p_8ind195, p_8ind196, p_8ind197, p_8ind198, p_8ind199
    .DC.L    p_8ind200, p_8ind201, p_8ind202, p_8ind203, p_8ind204, p_8ind205, p_8ind206, p_8ind207
    .DC.L    p_8ind208, p_8ind209, p_8ind210, p_8ind211, p_8ind212, p_8ind213, p_8ind214, p_8ind215
    .DC.L    p_8ind216, p_8ind217, p_8ind218, p_8ind219, p_8ind220, p_8ind221, p_8ind222, p_8ind223
    .DC.L    p_8ind224, p_8ind225, p_8ind226, p_8ind227, p_8ind228, p_8ind229, p_8ind230, p_8ind231
    .DC.L    p_8ind232, p_8ind233, p_8ind234, p_8ind235, p_8ind236, p_8ind237, p_8ind238, p_8ind239
    .DC.L    p_8ind240, p_8ind241, p_8ind242, p_8ind243, p_8ind244, p_8ind245, p_8ind246, p_8ind247
    .DC.L    p_8ind248, p_8ind249, p_8ind250, p_8ind251, p_8ind252, p_8ind253, p_8ind254, p_8ind255
