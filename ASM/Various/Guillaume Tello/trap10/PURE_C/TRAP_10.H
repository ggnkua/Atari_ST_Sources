; prototype de la fonction TRAP 10
; se trouvant dans TRAP_10.O
; Guillaume TELLO gtello@wanadoo.fr

extern long trap_10(int fn,int subfn, void *buf);

; les constantes pour la valeur de retour

#define T10_NULL 0x4e554c4c		/* si fonction absente */
#define T10_UNKN 0x554e4b4e		/* si sous-fonction inconnue */
#define T10_OK   0x0000000a		/* 10=ok */
