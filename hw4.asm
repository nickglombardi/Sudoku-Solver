.eqv QUIT 10
.eqv PRINT_STRING 4
.eqv PRINT_INT 1
.eqv NULL 0x0

.macro print_string(%address)
	li $v0, PRINT_STRING
	la $a0, %address
	syscall 
.end_macro

.macro print_string_reg(%reg)
	li $v0, PRINT_STRING
	la $a0, 0(%reg)
	syscall 
.end_macro

.macro print_newline
	li $v0, 11
	li $a0, '\n'
	syscall 
.end_macro

.macro print_space
	li $v0, 11
	li $a0, ' '
	syscall 
.end_macro

.macro print_int(%register)
	li $v0, 1
	add $a0, $zero, %register
	syscall
.end_macro

.macro print_char_addr(%address)
	li $v0, 11
	lb $a0, %address
	syscall
.end_macro

.macro print_char_reg(%reg)
	li $v0, 11
	move $a0, %reg
	syscall
.end_macro

#
# Computes the Nth number of the Hofsadter Female Sequence
# public int F (int n)
#
F:
	move $t0, $a0 #Move a0 into t0
	print_string(fString)
	print_int($t0)
	print_newline
	beqz $t0, returnOne #if (n==0)
	# else
	addi $sp, $sp, -8
	sw $ra, 0($sp)
	sw $t0, 4($sp)
	addi $t1, $t0, -1 # n - 1
	move $a0, $t1 # F(n-1)
	jal F
	move $a0, $v0 # M(F(n-1)
	jal M
	lw $ra, 0($sp)
	lw $t0, 4($sp)
	addi $sp, $sp, 8 #n - M(F(n-1))
	sub $t0, $t0, $v0
	move $v0, $t0
	j endOfF #End of F function
	
	returnOne: #return 1
		li $v0, 1
	
	endOfF:
	jr $ra

#
# Computes the Nth number of the Hofsadter Male Sequence
# public int M (int n)
#	
M:
	move $t0, $a0 #Move a0 into t0
	print_string(mString)
	print_int($t0)
	print_newline
	beqz $t0, returnZero #if (n==0)
	# else
	addi $sp, $sp, -8
	sw $ra, 0($sp)
	sw $t0, 4($sp)
	addi $t1, $t0, -1 # n - 1
	move $a0, $t1 # M(n-1)
	jal M
	move $a0, $v0 # F(M(n-1))
	jal F
	lw $ra, 0($sp)
	lw $t0, 4($sp)
	addi $sp, $sp, 8
	sub $t0, $t0, $v0 # n - F(M(n-1))
	move $v0, $t0
	j endOfM #End of M function
	
	returnZero: #return 0
		li $v0, 0
	
	endOfM:
	jr $ra
#
# Tak Function
# public int tak (int x, int y, int z)
#
tak:
	move $t0, $a0 # x
	move $t1, $a1 # y
	move $t2, $a2 # z
	bge $t1, $t0, returnZ
	addi $t3, $t0, -1 # x - 1
	addi $t4, $t1, -1 # x - 1
	addi $t5, $t2, -1 # x - 1
	addi $sp, $sp, -40
	sw $ra, 0($sp)
	sw $t0, 4($sp)
	sw $t1, 8($sp)
	sw $t2, 12($sp)
	sw $t3, 16($sp)
	sw $t4, 20($sp)
	sw $t5, 24($sp)
	
	#tak(x-1, y, z)
	move $a0, $t3
	move $a1, $t1
	move $a2, $t2
	jal tak
	
	sw $v0, 28($sp)
	lw $t0, 4($sp)
	lw $t1, 8($sp)
	lw $t2, 12($sp)
	lw $t3, 16($sp)
	lw $t4, 20($sp)
	lw $t5, 24($sp)
	
	# tak(y-1, z, x)
	move $a0, $t4
	move $a1, $t2
	move $a2, $t0
	jal tak
	
	sw $v0, 32($sp)
	lw $t0, 4($sp)
	lw $t1, 8($sp)
	lw $t2, 12($sp)
	lw $t3, 16($sp)
	lw $t4, 20($sp)
	lw $t5, 24($sp)
	
	# tak(z-1, x, y)
	move $a0, $t5
	move $a1, $t0
	move $a2, $t1
	jal tak
	
	# tak(tak(x-1, y, z), tak(y-1, z, x), tak(z-1, x, y))
	lw $a0, 28($sp)
	lw $a1, 32($sp)
	move $a2, $v0
	jal tak
	lw $ra, 0($sp)
	j endOfTak
	returnZ:
		move $v0, $t2
		jr $ra
	endOfTak:
	addi $sp, $sp, 40
	jr $ra

#
# Helper function for solving sudoku
# public boolean isSolution (int row, int col)
#
isSolution:
	beq $a0, 8, checkColumn
	j notSolution
	checkColumn:
		beq $a1, 8, itIsSolution
		j notSolution
	itIsSolution:
		li $v0, 1
		j endOfIsSolution
	notSolution:
		li $v0, 0
	endOfIsSolution:
	jr $ra

#
# Helper function for solving sudoku
# public void printSolution (byte[][] board)
#
printSolution:
	move $t0, $a0 # byte[][] board
	li $t1, 0 #Counter 1 (i)
	li $t2, 0 #Counter 2 (j)
	print_string(solutionString)
	print_newline
	loopI:
		beq $t1, 9, endOfPrintSolution
		loopJ:
			beq $t2, 9, incrementRow
			lb $t3, 0($t0)
			print_int($t3)
			print_space
			addi $t0, $t0, 1
			addi $t2, $t2, 1
			j loopJ
		incrementRow:
			print_newline
			addi $t1, $t1, 1
			li $t2, 0
			j loopI
	endOfPrintSolution:
	jr $ra

#
# Helper function for solving sudoku
# public (byte [], int) gridSet (byte[][] board, int row, int col)
#
gridSet:
	addi $sp, $sp, -8
	sw $s1, 0($sp)
	sw $s2, 4($sp)
	move $t0, $a0 #Board
	move $t1, $a1 #Row
	move $t2, $a2 #Column
	li $t3, 3
	li $t4, 0 # Count
	li $s1, 9 # amt per row
	div $t1, $t3 #r_start
	mflo $t1
	mul $t1, $t1, $t3

	div $t2, $t3 #c_start
	mflo $t2
	mul $t2, $t2, $t3 
	
	la $t3, gSet #G set
	
	addi $t5, $t1, 3 #r_start + 3
	addi $t6, $t2, 3 #c_start + 3
	move $t7, $t2
	rStartLoop:
		beq $t1, $t5, endOfGridSet
		cStartLoop:
			beq $t2, $t6, incrementR #Check if r_start = r_start + 3
			mul $s2, $s1, $t1 #9 * row
			add $s2, $s2, $t2 #9 * row + col
			add $s2, $s2, $t0 #Changes offset
			lb $s2, 0($s2) #Loads byte at the offset
			addi $t2, $t2, 1 #adds 1 to c_start
			bgtz $s2, addToGSet #Checks if board[i][j] > 0
			j cStartLoop
			addToGSet:
			sb $s2, 0($t3) #Stores byte to gSet
			addi $t3, $t3, 1 #Offset + 1 for gSet
			addi $t4, $t4, 1 #Count + 1
			j cStartLoop
		incrementR:
			addi $t1, $t1, 1 #r_start + 1
			move $t2, $t7 #c_start reset
			j rStartLoop
	endOfGridSet:
	lw $s1, 0($sp)
	lw $s2, 4($sp)
	addi $sp, $sp, 8
	move $v0, $t4 #Return count
	jr $ra

#
# Helper function for solving sudoku
# public (byte [], int) colSet (byte[][] board, int col)
#	
colSet:
	move $t0, $a0 #board
	move $t1, $a1 #col
	li $t3, 0 #count = 0
	li $t4, 0 # counter (i)
	li $t5, 9 # amt per row
	la $t6, cSet
	colLoop:
		beq $t4, 9, endOfColSet
		mul $t7, $t4, $t5 #Row * 9
		add $t7, $t7, $t1 #Row we are on + col
		add $t7, $t7, $t0 #Offset changed
		lb $t7, 0($t7)
		addi $t4, $t4, 1
		bgtz $t7, addToCSet
		j colLoop
		addToCSet:
			addi $t3, $t3, 1
			sb $t7, 0($t6)
			addi $t6, $t6, 1
			j colLoop
	endOfColSet:
	move $v0, $t3
	jr $ra

#
# Helper function for solving sudoku
# public (byte [], int) rowSet (byte[][] board, int row)
#		
rowSet:
	move $t0, $a0 #board
	move $t1, $a1 #row
	li $t3, 0 #count = 0
	li $t4, 0 # counter (i)
	li $t5, 9 # amt per row
	la $t6, rSet
	mul $t1, $t1, $t5
	add $t0, $t0, $t1
	rowLoop:
		beq $t4, 9, endOfRowSet
		lb $t7, 0($t0)
		addi $t0, $t0, 1 # Shift board over 1
		addi $t4, $t4, 1 # Add one to counter (i)
		bgtz $t7, addRSet # Chcks to see if board[row][i] > 0 
		j rowLoop
		addRSet:
			sb $t7, 0($t6)
			addi $t6, $t6, 1 
			addi $t3, $t3, 1 # Add one to count
			j rowLoop
	endOfRowSet:
	move $v0, $t3
	jr $ra

#
# Helper function for solving sudoku
# public (byte [], int) colSet (byte[][] board, int row, int col)
#			
constructCandidates:
	move $t0, $a0 #Board
	move $t1, $a1 #Row
	move $t2, $a2 #Column
	move $t3, $a3 #Candidates
	li $t4, 0	  #Count
	addi $sp, $sp, -32
	sw $ra, 0($sp) 	#Return Address
	sw $t0, 4($sp)	#Board
	sw $t1, 8($sp)	#Row
	sw $t2, 12($sp)	#Col
	sw $t3, 16($sp)	#Candidates
	sw $t4, 20($sp)	#Count
	
	jal rowSet		
	sw $v0, 24($sp) #rLength
	lw $a0, 4($sp)	#Board
	lw $a1, 12($sp) #Column
	
	jal colSet
	sw $v0, 28($sp) #cLength
	lw $a0, 4($sp)	#Board
	lw $a1, 8($sp)  #Row
	lw $a2, 12($sp) #Column
	jal gridSet
	
	lw $ra, 0($sp)	#Return address
	lw $t0, 24($sp) #rLength
	lw $t1, 28($sp) #cLength
	move $t2, $v0	#gLength
	lw $t3, 16($sp) #Candidates
	lw $t4, 20($sp) #Count
	addi $sp, $sp, 32
	la $t5, rSet	#rSet
	li $t6, 1		#counter (i)
	checkerLoop:
		bgt $t6, 9, endOfConstructCandidates
		li $t7, 0 #temp counter
		checkRSetLoop:
			beq $t7, $t0, resetRSet
			lb $t8, 0($t5) #Loads first byte in rSet
			addi $t5, $t5, 1 #Offset for rSet increased
			addi $t7, $t7, 1 #Counter increased
			beq $t6, $t8, checkerLoopIncrement
			j checkRSetLoop
		resetRSet:
			li $t8, -1 #t8 is -1
			mul $t7, $t7, $t8 #Makes the temp counter negative
			add $t5, $t5, $t7 #Reset offset for rSet
			la $t5, cSet #Loads cSet into $t5
			li $t7, 0 #Reset temp counter
		checkCSetLoop:
			beq $t7, $t1, resetCSet
			lb $t8, 0($t5) #Loads first byte in cSet
			addi $t5, $t5, 1 #Offset for cSet increased
			addi $t7, $t7, 1 #Counter increased
			beq $t6, $t8, checkerLoopIncrement
			j checkCSetLoop
		resetCSet:
			li $t8, -1 #t8 is -1
			mul $t7, $t7, $t8 #Makes the temp counter negative
			add $t5, $t5, $t7 #Reset offset for cSet
			la $t5, gSet #Loads gSet into $t5
			li $t7, 0 #Reset temp counter
		checkGSetLoop:
			beq $t7, $t2, resetGSet
			lb $t8, 0($t5) #Loads first byte in gSet
			addi $t5, $t5, 1 #Offset for gSet increased
			addi $t7, $t7, 1 #Counter increased
			beq $t6, $t8, checkerLoopIncrement
			j checkGSetLoop
		resetGSet:
			li $t8, -1 #t8 is -1
			mul $t7, $t7, $t8 #Makes the temp counter negative
			add $t5, $t5, $t7 #Reset offset for cSet
		addToCandidates:
			sb $t6, 0($t3) #Stores i into candidates
			addi $t3, $t3, 1 #Offset of candidates + 1
			addi $t4, $t4, 1 #Count + 1
		checkerLoopIncrement:
			addi $t6, $t6, 1
			la $t5, rSet
			j checkerLoop
	endOfConstructCandidates:
	move $v0, $t4
	move $a3, $t3
	jr $ra

#
# sudoku solver function
# public (byte [], int) colSet (byte[][] board, int x, int y)
#	
sudoku:
	
	addi $sp, $sp, -56
	sw $ra, 52($sp)	#Return address
	sw $fp, 48($sp) #old fp
	la $fp, 32($sp) #new fp
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	sw $s6, 24($sp)
	sw $s7, 28($sp)
	move $s0, $a0 #Board
	move $s1, $a1 #int x
	move $s2, $a2 #int y
	
	print_string(sudokuString)
	print_int($s1)
	print_string(sudokuStringP2)
	print_int($s2)
	print_string(sudokuStringP3)
	print_newline
	beq $s2, -1, compute #Check if it is the initial call
	move $a0, $s1
	move $a1, $s2
	jal isSolution
	beqz $v0, compute
	finishedSukoku:
		move $a0, $s0
		jal printSolution
		li $t0, 1
		sb $t0, FINISHED
		j endOfSudoku
	compute:
		addi $s2, $s2, 1
		blt $s2, 9, checkIfNotBlank
		addi $s1, $s1, 1
		li $s2, 0
		checkIfNotBlank:
			li $t3, 9 #AMT of blocks per row
			mul $t4, $s1, $t3 #Calculate position
			add $t4, $t4, $s2 # ^^^^^
			add $t4, $s0, $t4 #Exact position in board
			lb $t4, 0($t4) #Loads byte from exact position
			
			beqz $t4, itsBlankBro
			move $a0, $s0
			move $a1, $s1
			move $a2, $s2
			jal sudoku
			j endOfSudoku
			
		itsBlankBro:
			
			
			move $a0, $s0 	#Board
			move $a1, $s1	#int x(row)
			move $a2, $s2	#int y(col)
			la $a3, 0($fp)#candidates
			jal constructCandidates
			sw $v0, 12($fp)	#Candidates length
			
			lw $s3, 12($fp) #length
			#lb $s7, 0($fp)
			li $s4, 0 #Counter(c)
			li $s6, 9 #amt of cells per row
			lastMOTHERFUCKINGLOOP:
				beq $s4, $s3, endOfSudoku
				mul $t5, $s1, $s6
				add $t5, $t5, $s2
				add $s5, $s0, $t5
				add $t8, $fp, $s4
				lb $t8, 0($t8)
				#sb $s7, 0($s5)
				sb $t8, 0($s5)
				move $a0, $s0
				move $a1, $s1
				move $a2, $s2
				jal sudoku
				#lw $ra, 20($fp)
				mul $t5, $s1, $s6
				add $t5, $t5, $s2
				add $s5, $s0, $t5
				li $t6, 0
				sb $t6, 0($s5)
				addi $s4, $s4, 1
				#addi $s7, $s7, 1
				la $t9, FINISHED
				lb $t9, 0($t9)
				bgtz $t9, endOfSudoku
				j lastMOTHERFUCKINGLOOP
	endOfSudoku:
	lw $ra, 52($sp)	#Return address
	lw $fp, 48($sp) #old fp
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $s5, 20($sp)
	lw $s6, 24($sp)
	lw $s7, 28($sp)
	addi $sp, $sp, 56
	jr $ra


.data

rSet: 		.byte 0:9
cSet: 		.byte 0:9
gSet: 		.byte 0:9
FINISHED: 	.byte 0
solutionString: .asciiz "Solution: "
sudokuString: .asciiz "Sukoku ["
sudokuStringP2: .asciiz "]["
sudokuStringP3: .asciiz "]"
fString:	.asciiz "F: "
mString:	.asciiz "M: "