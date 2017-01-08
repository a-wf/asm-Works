############################################# PARTIE MACRO ###########################################################
		
# printf pour les entiers                     # on va utiliser la combinaisaison des deux printf pour les affichage de floattant
	.macro print_int (%x)
	
	li $v0, 1
	add $a0, $zero, %x
	syscall
	
	.end_macro
	
	# fonction printf pour les chaine de caractere
	.macro print_str (%str)
	
	.data
	
	myLabel: .asciiz %str

	.text
	li $v0, 4
	la $a0, myLabel
	syscall
	
	.end_macro
	
	# fct printf   un caractere   %str == registre
	
	.macro print_str2(%str)
	

	li $v0, 11
	add  $a0, %str, $zero
	syscall
	
	.end_macro
	
		
	
	
	# fct printf chaine caractere  %str === etq
	.macro print_str3 (%str)
	
	li $v0, 4
	la $a0, %str
	syscall
	
	.end_macro
	
	
	#fonction boucle for
	.macro for (%regIterator, %from, %to)
	
	add %regIterator, $zero, %from
	Loop:
	add %regIterator, %regIterator, 1
	ble %regIterator, %to, Loop
	
	.end_macro
	
	
	
	.macro end()
	
	li $v0 10
	syscall
	
	.end_macro
	
	
	
############################################# PARTIE DATA ###############################################################


.data

begin : .asciiz "*************************************************Calculatrice************************************* : \n"
.align 2 
chaine_input : .space 32
.align 2 
tab_op : .asciiz "fffffffffffffff"
.align 2 
tab_int : .word 0
			.word 0 
			.word 0
			.word 0 
			.word 0
			.word 0 
			.word 0
			.word 0 
			.word 0
			.word 0 
			.word 0 
			.word 0
			.word 0 
			.word 0
			.word 0 
			.word 0
			.word 0 
			.word 0
			.word 0 
			.word 0
			.word 0 
			.word '\0'
.align 2 
tab_bis : .asciiz "f"
.align 6
tab_bis2 : .asciiz "f"



######################################################### MAIN ########################################################


.text


main :  print_str ("\n*********************************** Calculatrice ************************************** \n\n") 
	
continuer : 
	jal clean_tab
	print_str("\n")
	print_str("b : conversion binaire			h : conversion hexadecimale\n")
	print_str ("Entrez votre calcul $: " )

	ori $a1,$zero,100
	la $a0,chaine_input
	ori,$v0,$zero,8
	syscall
	
	la $a0, chaine_input		# Entrée de l'utilisateur.
	la $a2,chaine_input # $a2 contient l'adresse de la chaine 
	ori $t3,$zero,0
	ori $t0,$zero,0
	ori $t4,$zero,0
	jal gestion_erreur		# Verfication des entrées.
	la $a0,chaine_input
	lb $t0, 0($a0)
	jal fonct_parenthese 
	
	
conversion:	
	la $s1,tab_op  # L'adresse de operartion est stockée dans $s1 
	la $a2,chaine_input # $a2 contient l'adresse de la chaine 
	lb $a3,0($a2)	     # $a3 contient le caractere de la chaine.
	ori $t1,$zero,0 	#$t1 compteur de boucle
	jal find_operand 	# detecte dans l'entrée les signes d'operation.
	la $a0,chaine_input	# adresse de chaine d'entrée.
	la $a2 ,tab_int	# adresse de tab_int
	jal fonction_tab_int # appel fonction 
	la $s1,tab_int
	lw $s2,0($s1)
	la $a1,($s2)
	la $s3,tab_op
	lb $s4,0($s3)
	la $a2,($s4)
	jal debut_interpreteur
	print_str("\n")
	print_str ("Résultat $: ")
	print_int($v1)
	#jal interpreteur_commande : lire les deux tableau et exécuter en consequence les instruction.
fin :
	#print_str("\n\n b : conversion binaire")
	#print_str("\n\n h : conversion hexadecimale")
	print_str("\n\n Continuer  :   oui  	  non \n\n")
	#jal interpreteur_commande : lire les deux tableau et exécuter en consequence les instruction.
	ori $v0,$zero,12
	syscall
	beq $v0,'o',continuer
	beq $v0,'O',continuer
	beq $v0,'N',quitter
	bne $v0,'n',.erreur
	quitter :			#### UTILE POUR N de quitter
	ori $v0,$zero,10
	syscall



find_operand : beq $a3,'+',store_operator  # trouve les operateurs dans une chaine de caractere.
	       beq $a3,'-',store_operator
	       beq $a3,'*',store_operator
	       beq $a3,'/',store_operator
	       beq $a3,'b',traduction_binaire
	       beq $a3,'h',traduction_hexadecimal
	       addi $a2,$a2,1
	       lb $a3,0($a2)
	       bne $a3,'\0',find_operand
	       jr $ra
	       
store_operator : sb $a3,0($s1)	# stocke l'operateur dans un tableau prévu pour ce type.
	      	addi $s1,$s1,1
	      	addi $a2,$a2,1
	      	lb $a3,0($a2)
	      	bne $a3,'\0',find_operand
	        jr $ra


debut_interpreteur:
	
	addiu $sp,$sp,-60
	sw $ra,0($sp)
	sw $fp,4($sp)
	sw $a0, 8($sp)
	sw $a2, 12($sp)
	sw $s3, 16($sp)
	sw $s4, 20($sp)				
	sw $t1, 24($sp)
	sw $s1, 28($sp)
	sw $t0, 32($sp)
	sw $s2, 36($sp)
	sw $t2, 40($sp)
	

interpreteur_commande :  ### initialisation ##
	
		#	la $s3,tab_op ## $a2 -> adresse du tableau d'operation.
		 	ori $a0,$zero,0
		#	beq $a2,'(',parenthese
		#	addi $s3,$s3,1
		#	lb $s4,0($s3)			
		#	la $a2,0($s4)
		#	addi $t1,$t1,1
		#	bne $a2,'f',interpreteur_commande
			
			la $s3,tab_op ## $a2 -> adresse du tableau d'operation.
			lb $s4,0($s3)
			la $a2,($s4)
			ori $t1,$zero,0 ## on remet le compteur a zero.
			
			verifie_mult:
			beq $a2,'*',multiplication
			addi $s3,$s3,1
			lb $s4,0($s3)
			la $a2,($s4)
			addi $t1,$t1,1
			bne $a2,'f',verifie_mult
			
			
			la $s3,tab_op ## $a2 -> adresse du tableau d'operation.
			lb $s4,0($s3)
			la $a2,($s4)
			ori $t1,$zero,0 ## on remet le compteur a zero.
			
			verifie_div:
			beq $a2,'/',division
			addi $s3,$s3,1
			lb $s4,0($s3)
			la $a2,($s4)
			addi $t1,$t1,1
			bne $a2,'f',verifie_div
			
			la $s3,tab_op ## $a2 -> adresse du tableau d'operation.
			lb $s4,0($s3)
			la $a2,($s4)
			ori $t1,$zero,0 ## on remet le compteur a zero.
			
			plus_ou_moins:
			beq $a2,'+',addition
			beq $a2,'-',soustraction
			addi $s3,$s3,1
			lb $s4,0($s3)
			la $a2,($s4)
			addi $t1,$t1,1
			bne $a1,'f',plus_ou_moins
			# retour au main apres traitement.
			jr $ra
			## apres les operations a prioritée moins élevée. -> empiler la valeur sur la valeur d'avant. 

fin_interpreteur:
	
	lw $ra, 0($sp)	
	lw $fp, 4($sp)												
	lw $a0, 8($sp)
	lw $a2, 12($sp)
	lw $s3, 16($sp)
	lw $s4, 20($sp)				
	lw $t1, 24($sp)
	lw $s1, 28($sp)
	lw $t0, 32($sp)
	lw $s2, 36($sp)
	lw $t2, 40($sp)
		
	addiu $sp, $sp, 60
	jr      $ra 

#parenthese : 
		
addition :
	     sll $t1,$t1,2 	# ajustement de l'indice pour le tableau des INT
	     la $s1,tab_int
	     add $s1,$s1,$t1	# on met la bonne adresses des operandes pour le tableau des int
	     lw $s2,0($s1)
	     lw $t2,4($s1)	
	     add $t0,$t2,$s2	# calcul.
	     srl $t1,$t1,2
	     jal fct_refresh_tab
	     la $s3,tab_op			
	     lb $s4,0($s3)	# on remet les registres utilisés au bon endroit pour les utiliser.
	     la $a2,($s4)
	     bne $a2,'f',plus_ou_moins
	     ori $v1,$t0,0
	     j fin_interpreteur

soustraction : 
	       sll $t1,$t1,2 	# ajustement de l'indice pour le tableau des INT
	       la $s1,tab_int
	       add $s1,$s1,$t1	# on met la bonne adresses des operandes pour le tableau des int
	       lw $s2,0($s1)
	       lw $t2,4($s1)
	       sub $t0,$s2,$t2
	       srl $t1,$t1,2
	       jal fct_refresh_tab			
	       la $s3,tab_op
	       lb $s4,0($s3)	# on remet les registres utilisés au bon endroit pour les utiliser.
	       la $a2,($s4)
	       bne $a2,'f',plus_ou_moins
	       ori $v1,$t0,0
	       j fin_interpreteur
	       

multiplication : 
		sll $t1,$t1,2 	# ajustement de l'indice pour le tableau des INT
	        la $s1,tab_int
	        add $s1,$s1,$t1	# on met la bonne adresses des operandes pour le tableau des int
		lw $s2,0($s1)
	        lw $t2,4($s1)
	        mult $s2,$t2
	        mflo $t0
	        srl $t1,$t1,2
	        jal fct_refresh_tab
		la $s3,tab_op
	        lb $s4,0($s3)	# on remet les registres utilisés au bon endroit pour les utiliser.
	        la $a2,($s4)
	        bne $a2,'f',verifie_mult
	        ori $v1,$t0,0
	        j fin_interpreteur

division :  
	      sll $t1,$t1,2 	# ajustement de l'indice pour le tableau des INT
	      la $s1,tab_int
	      add $s1,$s1,$t1	# on met la bonne adresses des operandes pour le tableau des int
	      lw $s2,0($s1)
	      lw $t2,4($s1)
	      beq $t2,0,exeption_de_calcul
	      div $s2,$t2
	      mflo $t0
	      srl $t1,$t1,2
	      jal fct_refresh_tab
	      la $s3,tab_op
	      lb $s4,0($s3)	# on remet les registres utilisés au bon endroit pour les utiliser.
	      la $a2,($s4)
	      bne $a2,'f',verifie_div
	      ori $v1,$t0,0
	      j fin_interpreteur

exeption_de_calcul : print_str("Resultat $: indefini.\n")
		    j fin 	  

boucle_print_int : 
	
	lw $t4, 0($a2)
	beq $t4, '\0', suite				
	lw $t7, ($a2)
	addi $a2, $a2, 4

	j boucle_print_int				
		
suite:
	
	end()


#########################################  fonction_ parenthese ###########################

fonct_parenthese : 
	
	
	addiu $sp, $sp, -60
	
	sw $ra, 0($sp)	
	sw $fp, 4($sp)												
	sw $t0, 8($sp)				#contenue chaine_inout
	sw $t6, 12($sp)			
	sw $t2, 16($sp)			#contenue a1
	sw $t3, 20($sp)			#contenue a2
	sw $t4, 24($sp)
	sw $t5, 28($sp)
	sw $a1, 32($sp)			#tab_op
	sw $a2, 36($sp)			# tab_int
	sw $a0, 40($sp)			#a0 <-- chaine_input  juste initialement
	sw $t7, 44($sp)			#t7 <-- a0
	sw $t1, 48($sp)
	sw $v1, 52($sp)

	addiu $fp, $sp, 60
		
	la $a1, tab_op
	la $a2, tab_int
	lb $t2, 0($a1)
	lw $t3, 0($a2)
	add $t7, $zero, $a0
	addi $t4, $zero, 0			#compteur pour tableau indice,   pour déterminer la position de l'indice d'op dans le tableau
	addi $t5, $zero, 0
	add $t6, $zero, $a0
	jal clean_tab 

.find_parenthese : 
	
	beq $t0,'(',.while_1
	addi $a0,$a0,1
	lb $t0,0($a0)
	addi $t4, $t4, 1
	# bne $t0,')',find_parenthese						
	bne $t0,'\0',.find_parenthese
	j .fin_fct_parentese
	
.while_1:    #tableau a0 avec premier valeur '('
	
	addi $a0, $a0, 1
	lb $t0, 0($a0)
	beq $t0, ')', .suite_fct_parenthese
	beq $t0,'\0',.fin_fct_parentese
	jal fonct_parenthese 
	j .while_1
	
	
.suite_fct_parenthese: 
	#jal clean_tab 
	add $a0, $zero, $t7
	add $a0,$a0,$t4
	addi $a0,$a0,1
	lb $t0,0($a0)
	jal fct_find_op_bis
	add $a0, $zero, $t7
	add $a0,$a0,$t4
	addi $a0,$a0,1
	jal fonction_tab_int 

			#	voir dans  fonction refresh 			 	jal debut_interpreteur  #à verifier par selim 
											#		print_str2($t1)
											#		print_str("\n")
											#		print_str ("Résultat $: ")
											#		print_int($v1)
											#		add $t0, $zero, $v1
	
	add $a0, $zero, $t7
	add $a0,$a0,$t4
	
	jal fct_refresh_chaine
	
	add $a0, $zero, $t7
	add $a0,$a0,$t4
	lb $t0,0($a0)
	#print_str3(chaine_input)
	la $a0,chaine_input
	lb $t0,0($a0)
	ori $t1,$zero,0

verif_rendu_parentese : 	# verifie si le rendu est un nombre , au quel cas on rend le resultat.
				# cela nous evite aussi de planter le programme.car la fonction interpreteur de commande
				# ne gere pas le fait qu'il n'y est pas d'opérateur.
				
	beq $t0,'\0',verif_rendu_parentese2
	addi $t1,$t1,1
	addi $a0,$a0,1
	lb $t0,0($a0)
	beq $t0,'+',.fin_fct_parentese
	beq $t0,'*',.fin_fct_parentese
	beq $t0,'-',.fin_fct_parentese
	beq $t0,'/',.fin_fct_parentese
	j verif_rendu_parentese 
	 
verif_rendu_parentese2 :
	blt $t1,100,return_input
		
	

 .fin_fct_parentese:
 	
	lw $ra, 0($sp)	
	lw $fp, 4($sp)												
	lw $t0, 8($sp)				#contenue chaine_inout
	lw $t6, 12($sp)			
	lw $t2, 16($sp)			#contenue a1
	lw $t3, 20($sp)			#contenue a2
	lw $t4, 24($sp)
	lw $t5, 28($sp)
	lw $a1, 32($sp)			#tab_op
	lw $a2, 36($sp)			# tab_int
	lw $a0, 40($sp)			#a0 <-- chaine_input
	lw $t7, 44($sp)			#t7 <-- a0
	lw $t1, 48($sp)
	lw $v1, 52($sp)

	addiu $sp, $sp, 60
	jr      $ra         # return
	
 
 

#########################################  fct clean tableaux ###########################


clean_tab : 

	addiu $sp, $sp, -60
	
	sw $ra, 0($sp)													
	sw $fp, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	sw $a1, 16($sp)
	sw $a2, 20($sp)

	addiu $fp, $sp, 60
	
	
	la $a1, tab_op				#charger les tableaux
	la $a2, tab_int
	lb $t2, 0($a1)
	lw $t3, 0($a2)
		
	addi $t4, $zero, 0			#compteur pour tableau indice,   pour déterminer la position de l'indice d'op dans le tableau
	
.tant_que_clean: 	
	beq $t2, 'f', .suite_clean
	addi $t2, $0, 'f'
	sb $t2, 0($a1)
	addi $a1,$a1,1
	lb $t2,0($a1)
	j .tant_que_clean

.suite_clean: 
	
.tant_que_clean_2: 
	
	beq $t3, '\0', .suite2_clean
	addi $t3, $0, 0
	sw $t3, 0($a2)
	addi $a2, $a2, 4
	lw $t3, 0($a2)
	j .tant_que_clean_2

 .suite2_clean:
 	
	la $a1, tab_bis
	lw $t3, 0($a1)
.tant_que_clean_3: 
	beq $t3, '\0', .suite3_clean
	addi $t3, $0, 0
	sw $t3, 0($a1)
	addi $a1, $a1, 4
	lw $t3, 0($a1)
	j .tant_que_clean_3
	
 .suite3_clean: 
 	la $a1, tab_bis2
	lw $t3, 0($a1)
 .tant_que_clean_4:
	beq $t3, '\0', .suite4_clean
	addi $t3, $0, 0
	sw $t3, 0($a1)
	addi $a2, $a1, 4
	lw $t3, 0($a1)
	j .tant_que_clean_4
	
.suite4_clean :

	lw $ra, 0($sp)													
	lw $fp, 4($sp)
	lw $t2, 8($sp)
	lw $t3, 12($sp)
	lw $a1, 16($sp)
	lw $a2, 20($sp)

	addiu $sp, $sp, 60
	jr      $ra         # return

#########################################  fct chercher operation bis #################################################

fct_find_op_bis: 
	
	addiu $sp, $sp, -60
	sw $ra, 0($sp)													
	sw $fp, 4($sp)
	sw $t0, 8($sp)
	sw $a0, 12($sp)
	sw $a2, 16($sp)

	
	addiu $fp, $sp, 60
	la $a1, tab_op

.find_operand_bis : 

	beq $t0,'+',.store_operator_bis  # trouve les operateurs dans une chaine de caractere.
	beq $t0,'-',.store_operator_bis
	beq $t0,'*',.store_operator_bis
	beq $t0,'/',.store_operator_bis
	addi $a0,$a0,1
	lb $t0,0($a0)
	bne $t0,')',.find_operand_bis
	
	j .suite_fct_fin_op
	       
.store_operator_bis : sb $t0,0($a1)	# stocke l'operateur dans un tableau prévu pour ce type.
	addi $a1,$a1,1
	addi $a0,$a0,1
	lb $t0,0($a0)
	bne $t0,')',.find_operand_bis
	
	j .suite_fct_fin_op
	
.suite_fct_fin_op : 

	lw $ra, 0($sp)													
	lw $fp, 4($sp)
	lw $t0, 8($sp)
	lw $a0, 12($sp)
	lw $a2, 16($sp)
	
	addiu $sp, $sp, 60
	jr      $ra         # return


#########################################  fonction_tab_int  ###########################
	
fonction_tab_int : 		
	
	addiu $sp, $sp, -60
	
	sw $ra, 0($sp)													
	sw $fp, 4($sp)
	sw $t0, 8($sp)
	sw $t6, 12($sp)
	sw $t5, 16($sp)
	sw $t1, 20($sp)
	sw $t2, 24($sp)
	sw $t3, 28($sp)
	sw $t9, 32($sp)
	sw $a2, 36($sp)
	sw $t4, 40($sp)
	
	addiu $fp, $sp, 60
	
	add $t0, $0, $a0 		# t0pointeur sur adr a0
	lb $t6, ($t0)
	add $t5, $zero, $a2			#t5 pointeur sur adr a2
	ori $t1, $zero, '0'		# la valeur du caractere '0', -->48
	ori $t2, $zero, '9' 		# ~~~~~~~~~~~~~ '9', --> 57
	

				
.tant_que : 
	
	beq $t6, ')', .fin
	beq $t6, '\0', .fin
		
	#print_str2($t6)						# verification
	slt $t3, $t2, $t6		# si la caratere est > '9' --> on decale le pointeur sur le caractere suivant 
	slt $t9, $t6, $t1	# si la caratere est  < '0' --> on decale le pointeur sur le caractere suivant 
	or $t3, $t3, $t9		
	beq $zero, $t3, .suite		 

.decal_op : 
	beq $t6, ')', .suite
	beq $t6, '\0',  .suite  #si la caratere est > '9' ||  < '0'   ET   different de '\0' alors continue

	addi $t0, $t0, 1
	lb $t6, ($t0)
	j .tant_que
	 
.suite :					
	add $a1, $zero, $t0		# a1 pointeur sur adr t0, ie : le caractere pointer par t0   dans la chaine a0
	
	jal atoi					
	

	add $t4, $zero, $v0		# le caractere converti en int  est stocker dans t4, puis dans t5 --> tab_int
	sw $t4, ($t5)
.tant_que2 :
	sub $t3, $t6, $t1		# si la caratere est > 0  --> on decale le pointeur sur le caractere suivant 
	bltz $t3, .continue 		# si la caratere est est >0   --> on decale le pointeur sur le caractere suivant 
	sub $t3, $t6, $t2		# si la caratere est <9  --> on decale le pointeur sur le caractere suivant 
	bgtz $t3, .continue
	
	addi $t0, $t0, 1
	lb $t6, ($t0)
	j .tant_que2
.continue: 	
	addi $t5, $t5, 4
	j .tant_que 
	

	
.fin : 
	
	la $v0, tab_int
	lw $ra, 0($sp)													
	lw $fp, 4($sp)
	lw $t0, 8($sp)
	lw $t6, 12($sp)
	lw $t5, 16($sp)
	lw $t1, 20($sp)
	lw $t2, 24($sp)
	lw $t3, 28($sp)
	lw $t9, 32($sp)
	lw $a2, 36($sp)
	lw $t4, 40($sp)
	addiu $sp, $sp, 60
	jr      $ra         # return
	

#########################################  fonction 	atoi  ###########################

#  int atoi ( const char *str );
#
# lit un entier (word) dans une chaine de caracteres (adresse str->$a0) 
#

atoi:

	addiu $sp, $sp, -32
	
	sw $ra, 4($sp)
	sw $fp, 8($sp)
	sw $t1, 12($sp)					#	t1 == 10sp
	sw $t0, 16($sp)				#	t0 == 14sp
	sw $t2, 20($sp)				#	t2 == 18sp
	sw $t3, 24($sp)				#	t3 == 22sp
	
	addiu $fp, $sp, 32
	
    or      $v0, $zero, $zero   # num = 0  
    or      $t1, $zero, $zero   # isNegative = false    									
    lb      $t0, 0($a1)														
    bne    $t0, '+', .isp      # si ce n'est pas positif -> saut vers isp
    addi   $a1, $a1, 1
.isp:
    lb      $t0, 0($a1)
    bne   $t0, '-', .num	#si ce n'est pas negatif -> saut vers num
    addi  $t1, $zero, 1       # isNegative = true
    addi  $a1, $a1, 1
.num:
    lb     $t0, 0($a1)
    slti   $t2, $t0, 58        # *str <= '9'							
    slti   $t3, $t0, '0'       # *str < '0'								
    beq     $t2, $zero, .done
    bne     $t3, $zero, .done
    sll     $t2, $v0, 1		# num << 1
    sll     $v0, $v0, 3		# num << 3
    add     $v0, $v0, $t2       # num *= 10 <=> num = (num << 3) + (num << 1)
    addi    $t0, $t0, -48
    add     $v0, $v0, $t0       # num += (*str - '0') : '0'=> valeur de la table ascii : 48
    addi    $a1, $a1, 1         # ++num
    j   .num
.done:
    beq     $t1, $zero, .out    # if (isNegative) num = -num
    sub     $v0, $zero, $v0
.out:

	lw $ra, 4($sp)
	lw $fp, 8($sp)
	lw $t1, 12($sp)					#	t1 == 10sp
	lw $t0, 16($sp)				#	t0 == 14sp
	lw $t2, 20($sp)				#	t2 == 18sp
	lw $t3, 24($sp)				#	t3 == 22sp
	addiu $sp, $sp, 32
    jr      $ra         # return


######################################### 	FONCTION ROUR RAFRAICHIR LES TABLEAUX ###########################

fct_refresh_tab:		 # prends un resultat d'une operation et l'indice d'operation,      les opération sont effectuée selon la demination , 
					#mais sont aussi effectuée dans l'ordre , pour les indices avec le meme niveau de domination
						
						#cette fonction ne renvoie rien,  c'est les tableau initiaux qui sont modifier

	addiu $sp, $sp, -60
	
	sw $ra, 0($sp)	
	sw $fp, 4($sp)												
	sw $t0, 8($sp)			#  t0  valeur du resultat d'operation effectuée
	sw $t1, 12($sp)			#  t1   l'indice d'opération effecutuée
	sw $t2, 16($sp)			
	sw $t3, 20($sp)
	sw $t4, 24($sp)
	sw $t5, 28($sp)
	sw $a1, 32($sp)
	sw $a2, 36($sp)
	
	addiu $fp, $sp, 60
	
	
	la $a1, tab_op				#charger les tableaux
	la $a2, tab_int
	lb $t2, 0($a1)
	lw $t3, 0($a2)
	
	
	addi $t4, $zero, 0			#compteur pour tableau indice,   pour déterminer la position de l'indice d'op dans le tableau
	

.suite2_fct_refresh_tab:
	
	la $a2,tab_int
	sll $t1,$t1,2	# decalage de 4 pour bien se positionner dans le tableau des int.
	add $a2,$t1,$a2	# positionnement de la premiere valeur a modifer
	srl $t1,$t1,2
	sw $t0, 0($a2)				#changer la case trouver par le resulat de l'oprération
	
	
	
.decalage_tab_int:
			
	addi $a2, $a2, 4
	lw $t5, 4($a2)				#effacer la case suivante, c-a-d le deuxieme nombre utliser pour l'opération, puis faire le décalage des nombres suivantes du tableau
	sw $t5, 0($a2)
	beq $t5, '\0', .suite3_fct_refresh_tab
	j .decalage_tab_int
	
.suite3_fct_refresh_tab: 
	la $a1,tab_op
	add $a1,$a1,$t1

	
.decalage_tab_op :			#effacer l'indice d'operation, et decalager les operations suivante vers la gauche

	lb $t5,1($a1)
	sb $t5, 0($a1)
	beq $t5, 'f', .suite4_fct_refresh_tab
	addi $a1, $a1, 1
	
	
	j .decalage_tab_op
	
 .suite4_fct_refresh_tab :			#fin de la fonction
 

	
	lw $ra, 0($sp)	
	lw $fp, 4($sp)												
	lw $t0, 8($sp)			#valeur du resultat d'operation effectuée
	lw $t1, 12($sp)			#l'indice d'opération effecutuée
	lw $t2, 16($sp)			
	lw $t3, 20($sp)
	lw $t4, 24($sp)
	lw $t5, 28($sp)
	lw $a1, 32($sp)
	lw $a2, 36($sp)
	addiu $sp, $sp, 60
	jr      $ra         # return
	
 




######################################### ######################################### ######################################### 
######################################### 	FONCTION ROUR RAFRAICHIR  CHAINE###########################

##############CHAINE##################

fct_refresh_chaine:		 

	
	addiu $sp, $sp, -60
	
	sw $ra, 4($sp)	
	sw $fp, 8($sp)	
	sw $t1, 12($sp)											
	sw $t2, 16($sp)			
	sw $a0, 20($sp)
	sw $a3, 24($sp)
	sw $a1, 28($sp)
	sw $a2, 32($sp)
	sw $t3, 36($sp)
	sw $s1, 40($sp)
	sw $t4, 44($sp)
	addiu $fp, $sp, 60
	
	add $t3, $zero, $a0
	add $a2, $zero, $a0
	add $a3, $zero, $a0
	add $a1, $zero, $a0
	add $t4, $zero, $a0
	addi $a1, $a1, 1
	addi $a2, $a2, 1
	addi $a0, $a0, 1
	addi $t0, $zero, 0
.while_refresh_chaine: 			#tableau a0 avec premier valeur '('
	
	
	add $a0, $t3, $t0
	lb $t1, 0($a0)
	beq $t1, ')', .suite_refresh_chaine
	beq $t1,'\0',.erreur
	
	.while2_refresh_chaine :
			
			
			lb $t2,1($a0)
			sb $t2, 0($a0)
			beq $t2, '\0', .end_while2_refresh_chaine 
			addi $a0, $a0, 1
			j .while2_refresh_chaine
 	
 	.end_while2_refresh_chaine : 
 	
 	#add $a1, $zero, $a2
 	#lb $t2,0($a1)
 	#beq $t2, ')', .suite_refresh_chaine
 	j .while_refresh_chaine
	
.suite_refresh_chaine: 
	
		


#.while_decal1_refresh_chaine :
#	
#	lb $t2,1($a2)
#	sb $t2, 0($a2)
#	beq $t2, '\0', .suite2_refresh_chaine
#	addi $a2, $a2, 1
#	
#	j .while_decal1_refresh_chaine
	
.suite2_refresh_chaine: 

	#print_str3(chaine_input)
	
	jal debut_interpreteur  #à verifier par selim 
	#print_int($v1)#test pour resultat de chaque parenthese.
	#print_str("\n")#test
	add $t1, $zero, $v1
	la $a1, tab_bis
	#
	add $a0, $zero, $t1
	
	jal fct_itoa
 	#
	
	
	##
	

	addi $t2, $zero, 0
	la $a1, tab_bis2
	.compt_taille_tabbis2_fin_while:   #trouver la taille de tab_bis2
		lb $t1, 0($a1)
		beq $t1, '\0', .suite3_refresh_chaine  
		addi $t2, $t2, 1
		addi $a1, $a1, 1
		j .compt_taille_tabbis2_fin_while	
		
		
.suite3_refresh_chaine: 	
	addi $t0, $zero, 0
	beq $t2, 1, .suite4_refresh_chaine #
	
	.compt_taille_chaine_fin_while:   #trouver la fin de  chaine input, et determiner la taille entre l'emplacement actuel et la fin
		
		lb $t1, 0($t3)
		beq $t1, '\0', .suite4_refresh_chaine 
		addi $t0, $t0, 1
		addi $t3, $t3, 1
		j .compt_taille_chaine_fin_while
.suite4_refresh_chaine : 
		add $a1, $zero, $t2
		beq $t2, 0, .suite4_refresh_chaine_bis#
		addi $t2, $t2, -1
.suite4_refresh_chaine_bis:#
		add $a2, $zero, $t3
		add $s1, $zero, $t0
	.while_decalage_chaine_input_refresh_chaine: 
		beq $t2, 0, .suite5_refresh_chaine 
		
		
		.while2_decalage_chaine_input_refresh_chaine: 
			beq $t0, 0, .suite_while_decalage_refresh_chaine
			lb $t1, 0($t3)
			sb $t1, 1($t3)
			addi $t3, $t3, -1
			addi $t0, $t0, -1
			j .while2_decalage_chaine_input_refresh_chaine
	.suite_while_decalage_refresh_chaine:
		 addi $t2, $t2, -1
		 addi  $t3, $a2, 1
		 add $t0, $zero, $s1
		 j .while_decalage_chaine_input_refresh_chaine
		
.suite5_refresh_chaine: 
#print_str3(chaine_input)#test
	add $t2, $zero, $a1
	add $t3, $zero, $t4
	la $a1, tab_bis2
	bne $t2, 0, .suite5_refresh_chaine_bis#
		addi $t2, $t2, 1
		lb $t1, 0($a1)	
		bne $t1, 0, .suite5_refresh_chaine_bis
		addi $t1, $zero, '0'
		sb $t1 0($t3)
		j .suite6_refresh_chaine
.suite5_refresh_chaine_bis:#
.while_refresh_ajout_tabbis2_chiane_input: 	
	beq $t2, 0, .suite6_refresh_chaine 
	lb $t1, 0($a1)	
	sb $t1, 0($t3)
	addi $t3, $t3, 1
	addi $a1, $a1, 1
	addi $t2, $t2, -1
	j .while_refresh_ajout_tabbis2_chiane_input
	
.suite6_refresh_chaine:

	lw $ra, 4($sp)	
	lw $fp, 8($sp)	
	lw $t1, 12($sp)											
	lw $t2, 16($sp)			
	lw $a0, 20($sp)
	lw $a3, 24($sp)
	lw $a1, 28($sp)
	lw $a2, 32($sp)
	lw $t3, 36($sp)
	lw $s1, 40($sp)
	lw $t4, 44($sp)
	addiu $sp, $sp, 60
	jr      $ra         # return
	
 
######################################### FONCTION INT TO ALPHA ######################################### ######################################### 


fct_itoa:


	addiu $sp, $sp, -60
	
	sw $ra, 0($sp)	
	sw $fp, 4($sp)	
	sw $a0, 8($sp)											
	sw $t3, 12($sp)		
	sw $t0, 16($sp)
	sw $t1, 20($sp)
	sw $t2, 24($sp)
	sw $v0, 28($sp)
	sw $s0, 32($sp)
	sw $s1, 36($sp)
	addiu $fp, $sp, 60
	
	
	bnez $a0, .fct_itoa_non_zero 						# cas du 0

	li $t0, '0'
	sb $t0, 0($a1)
	sb $zero, 1($a1)
	li $v0, 1
	
	lw $ra, 0($sp)	
	lw $fp, 4($sp)	
	lw $a0, 8($sp)											
	lw $t3, 12($sp)			
	lw $t0, 16($sp)
	lw $t1, 20($sp)
	lw $t2, 24($sp)
	lw $v0, 28($sp)
	lw $s0, 32($sp)
	lw $s1, 36($sp)
	addiu $sp, $sp, 60
	jr      $ra         # return


.fct_itoa_non_zero:
	addi $t0, $zero, 10   					 # cas si negative
	li $v0, 0
	bgtz $a0, .fct_itoa_recurse

	li $t1, '-'
	sb $t1, 0($a1)
	addi $v0, $v0, 1
	neg $a0, $a0
	
.fct_itoa_recurse:

	
	div $a0, $t0 						# $a0/10
	mflo $s0 						# $s0 = quotient
	mfhi $s1 							# s1 = reste
	
	
#.fct_itoa_continue:
	
	
	#j .fct_itoa_recurse

.fct_itoa_write:
	add $t1, $a1, $v0
	addi $v0, $v0, 1
	addi $t2, $s1, 0x30 					# conversion  ASCII
	sb $t2, 0($t1) 							# store dans  t1
	sb $zero, 1($t1)
	beqz $s0,.fct_itoa_exit
	move $a0, $s0
	j .fct_itoa_recurse
	
	

	
.fct_itoa_exit:


		la $t2, tab_bis
	addi $t0, $zero, 0
	.compt_taille_tab_while:   #trouver la fin de tab_bis
		lb $t3, 0($t2)
		beq $t3, '\0', .suite_itoa_exit2
		addi $t0, $t0, 1
		addi $t2, $t2, 1
		j .compt_taille_tab_while
		
.suite_itoa_exit2:

	la $t1, tab_bis2
	
	.tant_que_inverse: 	
		addi $t2, $t2, -1
		beq $t0, 0, .suite_itoa_exit3
		lb $t3, 0($t2)
		sb $t3, 0($t1)
		addi $t1, $t1, 1
		addi $t0, $t0, -1
		j .tant_que_inverse	
	
	
 .suite_itoa_exit3: 	
	addi $t0, $t0, '\0'
	sb $t0, 0($t1)
	
	lw $ra, 0($sp)	
	lw $fp, 4($sp)	
	lw $a0, 8($sp)											
	lw $t3, 12($sp)
	lw $t0, 16($sp)
	lw $t1, 20($sp)
	lw $t2, 24($sp)
	lw $v0, 28($sp)
	lw $s0, 32($sp)
	lw $s1, 36($sp)
	addiu $sp, $sp, 60
	jr      $ra         # return


######################################################################################################################### ########	
	
###################################################### traduction binaire et hexadecimale ###############################

traduction_binaire : print_str ("Entrez le nombre a convertir en binaire $: ") 
		     print_str ("\n")
		     ori $v0,$zero,5
		     syscall
		     ori $a0,$v0,0
		     ori $v0,$zero,35
		     syscall
		     j fin
		     
		     
traduction_hexadecimal : print_str ("Entrez le nombre a convertir en hexadecimal $: ") 
		     	print_str ("\n")
		     	ori $v0,$zero,5
		     	syscall
		     	ori $a0,$v0,0
		     	ori $v0,$zero,34
		     	syscall
		     	j fin

################################################## fonction return_input ##############################################

return_input : 
		print_str ("Résultat $:") 
		print_str3(chaine_input)
		j fin


################################################## GESTION DES ERREURS  ################################################ 
.erreur : 
	print_str("$: erreur de saisie")
	j fin 

erreur_calculable : print_str ("\nerreur : l'entrée n'est pas une opération mathematique reconnue.\n")
		    j fin

# a la fin de ce traitement , la chaine input est forcement composé de deux operande et un operateur 
# exemple : "1+2 blablabla" , err2eu+r1 =>  le calcul est fait normalment
# "1" , "1+" , "1+a" constitue des erreur.  




gestion_erreur :  
		 lb $a3,0($a2)	     # $a3 contient le caractere de la chaine.
		 addi $a2,$a2,1
		 addi $t0,$t0,1
		 beq $a3,'+',ajouter_1_op  ### on peut faire plus grand que 40 et plus petit que 57
		 beq $a3,'*',ajouter_1_op  ### car les valeur prise en compte sont sur cet intervalle
		 beq $a3,'-',ajouter_1_op  ## mais probleme rencontré.
		 beq $a3,'/',ajouter_1_op
		 j continuer_gestion_erreur
		 ajouter_1_op : addi $t4,$t4,1
		 continuer_gestion_erreur :
		 beq $a3,'1',verifier_calculabilite
		 beq $a3,'2',verifier_calculabilite
		 beq $a3,'3',verifier_calculabilite
		 beq $a3,'4',verifier_calculabilite
		 beq $a3,'5',verifier_calculabilite
		 beq $a3,'6',verifier_calculabilite
		 beq $a3,'7',verifier_calculabilite
		 beq $a3,'8',verifier_calculabilite
		 beq $a3,'9',verifier_calculabilite
		 beq $a3,'0',verifier_calculabilite
		 beq $a3,'b',verifier_conversion # conversion 
		 beq $a3,'h',verifier_conversion #conversion
		 beq $a3,'\0',.erreur 	# si a la fin du traitement l'entrée  n'est pas calculable, l'utilisateur est renvoyé a une erreur d'entrée 
		 j gestion_erreur
		 


verifier_calculabilite :  addi $t3,$t3,1
		 bge $t3,2,continuer_verifier_calculabilite
		 j gestion_erreur
		 continuer_verifier_calculabilite :
		 bge $t4,1,calculable
		 j gestion_erreur

verifier_conversion : 
	beq $t0,1,conversion
	j .erreur

calculable :jr $ra
		

memoire_plus : 
memoire_Clear :
memoire_moins:
afficher_valeur_memoire :
