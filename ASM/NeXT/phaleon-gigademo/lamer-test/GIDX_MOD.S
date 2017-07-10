d0 -> Num‚ro de langue
d1 -> Num‚ro de question

a0 -> Adresse du fichier index
a1 -> Adresse du fichier texte correspondant

a1 <- Pointe sur le bloc 'Question' demand‚

calcule_index
 add.w d0,d0 
 add.w (a0,d0.w),a0
 add.w d1,d1
 move.w (a0,d1.w),d1
 add.w d1,d1
 add.w d1,d1
 addq.w #2,a1
 add.w d1,a1                 Pointe au bon endroit normalement
 rts
   
fichier_index incbin d:\question.idx
fichier_texte incbin d:\question.txt
 
