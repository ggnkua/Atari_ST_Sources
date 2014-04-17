BCR	EQU     $FFFE           ; Port A Bus Control Register
HTX	EQU     $FFEB           ; Host Transmit Data Register
HSR   	EQU     $FFE9	; Host status register
RX	EQU     $FFEF           ; Serial Receive Data Register
TX	EQU     $FFEF           ; Serial Transmit Data Register
TSR	EQU     $FFEE	; don't care skip register
CRA  	EQU     $FFEC          	; SSI Control Register A
CRB   	EQU     $FFED           ; SSI Control Register B
SSR	EQU     $FFEE
IPR   	EQU     $FFFF           ; Interrupt Priority Register
PCC   	EQU     $FFE1           ; Port C Control Register
PCDDR 	EQU     $FFE3           ; Port C Data Direction Register

PBC	EQU     $ffe0			
HCR	EQU     $ffe8			
HRX	EQU     $ffeb			



  ORG       Y:$0000
; Buffer de r‚ception
  DC        $000000
  DC        $000000
; Buffer d'‚mission
  DC        $000000
  DC        $000000
; Buffer de travail
  DC        $000000
  DC        $000000
  DC        $000000
  DC        $000000


  ORG       P:$0000
P:0000 JMP       $0055	; Reset
  ORG       P:$000C
P:000C JSR       <$0040	; R‚ception de sample par le SSI
  ORG       P:$000E
P:000E JSR       <$0046	; Idem, avec erreur
  ORG       P:$0010
P:0010 JSR       <$0047	; Emission de sample par le SSI
  ORG       P:$0012
P:0012 JSR       <$004D	; Idem, avec erreur
  ORG       P:$0020
P:0020 JSR       <$004E	; R‚ception de donn‚es par le port HOST
  ORG       P:$0026
P:0026 JSR       <$0050	; HOST Command 0
  ORG       P:$0028
P:0028 JSR       <$0052	; HOST Command 1



  ORG       P:$0040

; R‚ception de sample par le SSI
P:0040 JCLR      #$03,X:<<SSR,$0044
P:0042 MOVE      #$00,R4		; Nouvelle frame
P:0043 NOP       
P:0044 MOVEP     X:<<RX,Y:(R4)+
P:0045 RTI       

; R‚ception de sample par le SSI avec erreur
P:0046 JMP       <$0040

; Emission de sample par le SSI
P:0047 JCLR      #$02,X:<<SSR,$004B
P:0049 MOVE      #$03,R1		; Nouvelle frame
P:004A NOP       
P:004B MOVEP     Y:(R1)+,X:<<TX
P:004C RTI       

; Emission de sample par le SSI
P:004D JMP       <$0047

; R‚ception de donn‚e par le port HOST
P:004E MOVEP     X:<<HTX,X:(R3)+
P:004F RTI       

; HOST command 0
P:0050 MOVE      #$00,R3
P:0051 RTI       

; HOST Command 1
P:0052 JSR       $0082
P:0054 RTI       

; Initialisation
P:0055 ORI       #$03,MR
P:0056 MOVEP     #>$000000,X:<<BCR
P:0058 MOVEP     #>$003800,X:<<IPR
P:005A MOVEP     #>$000001,X:<<PBC
P:005C MOVEP     #>$000005,X:<<HCR	; Autorise interruption Host Command et r‚ception
P:005E MOVE      #$00,R3
P:005F MOVEC     #<03,M3		; R3 modulo 4
P:0060 MOVE      #$00,R4
P:0061 MOVEC     #<01,M4		; R4 modulo 2
P:0062 MOVE      #$02,R1
P:0063 MOVEC     #<01,M1		; R1 modulo 2
P:0064 MOVEP     #>$004100,X:<<CRA	; SSI 16 bits, 2 mots par frame
P:0066 MOVEP     #>$0001F8,X:<<PCC
P:0068 BTST      #$04,X:<<SSR		; Underrun en transmission ?
P:0069 MOVEP     X:(R1)+,X:<<TX		; Envoie … bouffer au SSI
P:006A MOVEP     #>$00F800,X:<<CRB	; Network, transmissions et interruptions dans les 2 sens
P:006C ORI       #$04,OMR		; ROM s‚lectionn‚e de $100 … $1FF
P:006D ANDI      #$F0,MR
P:006E JSR       $0082

; Boucle principale
P:0070 MOVE      #$00,B
P:0071 MOVE      R4,A
P:0072 CMP       B,A            
P:0073 JNE       <$0071	; Attend que R4 = 0 (nouvelle frame)
P:0074 MOVE      R4,A
P:0075 CMP       B,A            
P:0076 JEQ       <$0074	; Puis attend que R4 <> 0 (un sample re‡u pour cette frame)
P:0077 MOVE      Y:<$00,X0	; Transfert les 2 nouveaux samples
P:0078 MOVE      X0,Y:<$04	; dans le buffer de travail 1
P:0079 MOVE      Y:<$01,X0	; ...
P:007A MOVE      X0,Y:<$05	; ..
P:007B JSR       $00A7	; ...Traitement...
P:007D MOVE      Y:<$06,X0	; R‚cupŠre les 2 samples
P:007E MOVE      X0,Y:<$02	; r‚sultat et les
P:007F MOVE      Y:<$07,X0	; transfert dans le
P:0080 MOVE      X0,Y:<$03	; buffer d'‚mission
P:0081 JMP       <$0070

P:0082 JSR       $0093
P:0084 MOVE      #$00,A
P:0085 MOVEC     #>$00FFFF,M2	; Annule les modulos de R2 et R6
P:0087 MOVEC     #>$00FFFF,M6
P:0089 DO        X0,$008C
P:008B MOVE      A,X:(R2)+
P:008C NOP       
P:008D NOP       
P:008E NOP       
P:008F DO        Y0,$0092
P:0091 MOVE      A,Y:(R6)+
P:0092 RTI       

  ORG       X:$0000
; ParamŠtres du flanger
  DC        $266666	; 0.3 : Taux de reg‚n‚ration ?
  DC        $000032
  DC        $0000A8	; Additionneur d'adresse * 65536
  DC        $00012C	; 300

  ORG       X:$0040
  DC        $59999A	; 0.7
  DC        $FFFFFE	; Masque
  DC        $000000	; Compteur d'adresse * 65536

  ORG       P:$0093

P:0093 MOVE      #>$002000,R0	; Buffer 3
P:0097 MOVEC     #>$001FFF,M0
P:009E MOVE      #>$001000,R2	; R2 : table des sinus
P:009B MOVEC     #<FF,M2
P:00A2 MOVE      #>$002000,R6
P:0095 MOVE      #>$002000,R7
P:009C MOVE      #>$000600,N7
P:0099 MOVEC     #>$001FFF,M7
P:00A0 MOVE      #>$000001,X0
P:00A4 MOVE      #>$002000,Y0
P:00A6 RTS       

P:00A7 MOVE      X:$0042,A
P:00A9 MOVE      X:<$02,X0
P:00AA ADD       X0,A           
P:00AB MOVE      #$01,A2
P:00AC MOVE      A1,X:$0042
P:00AE REP       #$010
P:00AF ASR       A		; A = A / 65536
P:00B0 MOVE      A1,R2	; R2 = compteur/65536 + 256 (table de sinus)
P:00B1 MOVE      Y:<$04,A	; A contient le 1er sample du buffer Travail 1 (nouveau)
P:00B2 MOVE      Y:<$06,X0	; X0 celui de travail 2 (ancien)
P:00B3 MOVE      X:<$00,X1	; Multiplicateur (taux de reg‚n‚ration ?)
P:00B4 MACR      +X1,X0,A	; Mixe l'ancien sample d‚multipli‚ avec le nouveau
P:00B5 MOVE      A,Y:(R0)+	; R‚sultat dans le buffer 3
P:00B6 MOVE      Y:(R2),X0
P:00B7 MOVE      X:<$01,X1
P:00B8 MPYR      -X1,X0,A
P:00B9 MOVE      X:<$03,B	; B = 300
P:00BA SUB       B,A            X:$0041,X0	; A = A - 300
P:00BC AND       X0,A		; Masque -> A1 pair
P:00BD MOVE      A,N7		; Incr‚ment de R7 = A
P:00BE NOP       
P:00BF MOVE      Y:(R7+N7),X0
P:00C0 MOVE      X:$0040,X1
P:00C2 MPYR      +X1,X0,A       (R7)+
P:00C3 MOVE      A,Y:<$06
P:00C4 MOVE      Y:<$05,A
P:00C5 MOVE      Y:<$07,X0
P:00C6 MOVE      X:<$00,X1
P:00C7 MACR      +X1,X0,A       
P:00C8 MOVE      A,Y:(R0)+
P:00C9 MOVE      Y:(R7+N7),X0
P:00CA MOVE      X:$0040,X1
P:00CC MPYR      +X1,X0,A       (R7)+
P:00CD MOVE      A,Y:<$07
P:00CE RTS       
