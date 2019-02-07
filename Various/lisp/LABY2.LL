06601030305800
F0110030
9   [................................................]001
€‰CHEMINREELLEMENTPARCOURU
€
Lafonctionth‚s‚e€d‚critepr‚cedemmentrenvoielechemin
allantdupointded‚part…lasortiequ'elleatrouv‚.Mais
onpeutsedemanderquela‚t‚lechemineffectivementpar-
-courudanslelabyrinthe.Onpeutr‚pondre…ceproblŠmeen
donnantdansunelistetouslescouloirsparcourusavantd'
atteindrelasortie.

**

EngardantlamŠmestructurequedanslafonctionpr‚c‚dente
ons'aper‡oitqu'ilsuffitderajouterunesecondelisteen
paramŠtre(OnnepeutguŠremodifierlalisteinitialepuis-
-qu'ellen'estpasseulementlar‚ponsedelafonctionmais
aussile"coeur"dutravailpourretrouverlasortie.).
Cettesecondelisteseraidentique…lapremiŠre…ceciprŠs
qu'ellenesubirapaslatronquatureeffectu‚edansl'algo
au4emecas.Onauradoncainsitoutlescouloirsquiont‚t‚
sond‚parlafonction..

FONCTION:€

(de thes2€ (case liste liste2)
 (cond
   ((equal case ()) 
(thes (cadr (member (last2 liste) 
      (cassq (last2 (listetronq liste)) laby)))
      (listetronq liste)
      liste2 ))
   ((member case liste)
(thes (cadr (member case 
(cassq (last2 liste) laby))) 
liste   liste2))
   ((equal case '*) liste2)
   (t (thes (car (cassq case laby)) (consdroite liste case)
                                    (consdroite liste2 case)))
  )
)


APPELUTILISATEUR€:
Par:(dethesee2(case)
(thes2case()())
)


Exemple:
€
?(thesee2'd4)
?=(d4c4b4b5b6e4e5e6d6c6c5d5d7c7b7..b2b1a1)



€
















