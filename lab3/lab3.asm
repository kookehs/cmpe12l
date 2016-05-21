; Bill Lin (blin7)
; Section 6 Jay Roldan
; Due May 4, 2014
; Lab 3: Not My Number

; The memory address at which our program will start at
	.ORIG	x3000
	START:

; Clear all registers and reset misc
	LD	R0, MINIMUMASCII
	ST	R0, COUNTER
	AND	R0, R0, 0
	AND	R1, R0, 0
	AND	R2, R0, 0
	AND	R3, R0, 0
	AND	R4, R0, 0
	AND	R5, R0, 0
	AND	R6, R0, 0
	AND	R7, R0, 0

; Display greeting
	LEA	R0, GREETING
	PUTS

; Print new line
	LEA	R0, NEWLINE
	PUTS

; Display prompt
	LEA	R0, PROMPT
	PUTS

; Print new line
	LEA	R0, NEWLINE
	PUTS

; Get user input
	GETC
	PUTC

; Store user input
	ST	R0, USERINPUT
	
; Print new line
	LEA	R0, NEWLINE
	PUTS

; Check if user input is a newline character
	LD	R1, USERINPUT		
	LD	R2, NEWLINEASCII	; Load each number into a register
	NOT	R2, R2			; and NOT the second number
	ADD	R2, R2, #1		; then ADD #1 to it
	ADD	R1, R1, R2		; ADD the two numbers to perform subtraction
	BRz	ISNEWLINE

; Check if user input is 0
	LD	R1, USERINPUT
	LD	R2, ZEROASCII		; Load each number into a register
	NOT	R2, R2			; and NOT the second number
	ADD	R2, R2, #1		; then ADD #1 to it
	ADD	R1, R1, R2		; ADD the two numbers to perform subtraction
	BRz	ISZERO

; Check if user input is greater than 9
	LD	R1, USERINPUT
	LD	R2, MAXIMUMASCII	; Load each number into a register
	NOT	R2, R2			; and NOT the second number
	ADD	R2, R2, #1		; then ADD #1 to it
	ADD	R1, R1, R2		; ADD the two numbers to perform subtraction
	BRp	ISOUTSIDE		; if the result is positive then the number is greater

; Check if user input is lesser than 1
	LD	R3, USERINPUT
	LD	R4, MINIMUMASCII	; Load each number into a register
	NOT	R4, R4			; and NOT the second number
	ADD	R4, R4, #1		; then ADD #1 to it
	ADD	R3, R3, R4		; ADD the two numbers to perform subtraction
	BRn	ISOUTSIDE		; if the result is negative then the number is lesser
	
; User input is within 1 and 9
	BRnzp	ALLISGOOD		; Went through all possibilities therefore number is between 1 and 9
	
; Result of parsing printed here
	ISNEWLINE:			; If result is a newline
	LEA	R0, ISNEWLINECHAR	; then print the newline response
	PUTS
	HALT

	ISZERO:				; If result is a zero
	LEA	R0, ISZEROCHAR		; then print the zero response
	PUTS
	LEA	R0, NEWLINE		; Load newline for printing
	PUTS
	PUTS
	PUTS
	PUTS
	BRnzp	START

	ISOUTSIDE:
	LEA	R0, ISNOTWITHIN		; If result is not within range
	PUTS				; then print the not within repsonse
	LEA	R0, NEWLINE		; Load newline for printing
	PUTS
	PUTS
	PUTS
	PUTS
	BRnzp	START

; User input is between 1 and 9
	ALLISGOOD:
	LD	R1, COUNTER		; Load each value into a register
	LD	R2, USERINPUT

; Check if user input is equal to current counter
	BEGINLOOP:
	NOT	R3, R1			; NOT the counter and place it into R3
	ADD	R3, R3, #1		; ADD #1 to the inverse of the counter
	ADD	R4, R2, R3		; ADD user input and the counter
	BRnp	PRINTNUMBER		; if result is negative or positive print it
	BRz	INCREMENTCOUNTER	; if result is zero then increment counter and move on

; Check the counter's current position
	INCREMENTCOUNTER:
	ADD	R1, R1, #1		; Increment counter by #1
	ST	R1, COUNTER		; Store the modified counter into our label
	LD	R3, MAXIMUMASCII	; Load the highest number
	ADD	R3, R3, #1		; ADD #1 to it so it includes the highest number
	NOT	R3, R3			; NOT the highest value
	ADD	R3, R3, #1		; ADD #1 to it for subtraction
	ADD	R4, R1, R3		; ADD the two values
	BRnp	BEGINLOOP		; if result is not zero then counter has not reached the highest number
	BRz	PRINTRESPONSE		; if reuslt is zero then print final response

; Print current number
	PRINTNUMBER:
	LEA	R0, COUNTER		; Load counter for printing
	PUTS
	LEA	R0, WHITESPACE		; Load whitespace for printing
	PUTS
	BRnzp	INCREMENTCOUNTER	; Incrememnt counter after printing

; Print end response
	PRINTRESPONSE:
	LEA	R0, NEWLINE		; Load newline for printing
	PUTS
	LEA	R0, ISWITHIN		; Load final response for printing
	PUTS
	LEA	R0, NEWLINE		; Load newline for printing
	PUTS
	PUTS
	PUTS
	PUTS
	BRnzp	START			; Branch to the beginning to start over

; List of variables
	USERINPUT:	.FILL #0
	NEWLINEASCII:	.FILL #10
	ZEROASCII	.FILL #48
	MINIMUMASCII:	.FILL #49
	MAXIMUMASCII:	.FILL #57
	COUNTER:	.FILL #49

; List of strings
	WHITESPACE:	.STRINGZ " "
	NEWLINE:	.STRINGZ "\n"
	GREETING:	.STRINGZ "Old MacDonald Had a Farm"
	PROMPT:		.STRINGZ "If there's a moo there and a moo here, then how many cows say moo?"
	ISNEWLINECHAR:	.STRINGZ "C'mon take a guess!"
	ISZEROCHAR:	.STRINGZ "Zero! I said moo."
	ISNOTWITHIN:	.STRINGZ "C'mon not even close. Use your fingers to count!"
	ISWITHIN:	.STRINGZ "So many moos now!"

; End of code
	.END