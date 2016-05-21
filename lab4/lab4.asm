; Bill Lin (blin7)
; Section 6 Jay Roldan
; Due May 14, 2014
; Lab 4: Decimal Converter
; Partner: Bryan Truong

.ORIG x3000
START:

; Clear all registers
AND		R0, R0, #0
AND		R1, R1, #0
AND		R2, R2, #0
AND		R3, R3, #0
AND		R4, R4, #0
AND		R5, R5, #0
AND		R6, R6, #0
AND		R7, R7, #0

; Reset variables
ST		R0, CHARCOUNTER
ST		R0, INTEGER
ST		R0, INVALIDCHAR
ST		R0, SIGNFLAG

; Display prompt
LEA		R0, PROMPT
PUTS

; Get current char
GETCHAR:
GETC

; Check if exit char
LD		R1, EXITCHAR		; Subtract the decimal ascii value
ADD		R1, R0, R1		; of X from userinput
BRz		ISEXITCHAR

; Check if newline char
LD		R1, NEWLINECHAR		; Subtract the decimal ascii value
ADD		R1, R0, R1		; of newline from userinput
BRz		ISNEWLINECHAR

; Check if negative
LD		R1, NEGATIVECHAR	; Subtract the decimal ascii value
ADD		R1, R0, R1		; of - from userinput
BRz		ISNEGATIVECHAR

; Check if within range
LD		R1, MINIMUMASCII	; Load both the lowest and highest
LD		R2, MAXIMUMASCII	; decimal ascii values
ADD		R1, R0, R1		; Check if userinput is lower
BRn		ISINVALIDCHAR		; than lowest number
ADD		R2, R0, R2		; Check if userinput is higher
BRp		ISINVALIDCHAR		; than highest number
LD		R1, CHARCOUNTER
ADD		R1, R1, #1		; Increment the number of characters
ST		R1, CHARCOUNTER		; so far by one
PUTC

; Calculate digit
LD		R1, CHAROFFSET		; Subtract the deicmal ascii value
ADD		R2, R0, R1		; from userinput to obtain binary value

; Calculate integer
LD		R3, INTCOUNTER		; Load variables we will need
LD		R5, INTEGER
AND		R4, R4, #0		; Clear R4 each time

COUNTERLOOP:
ADD		R4, R4, R5		; Add integer to the total in R4
ADD		R3, R3, #-1		; ten times to simulate multiplying by 10
BRz		1
BRnzp		COUNTERLOOP
ADD		R4, R4, R2		; Add digit to out total
ST		R4, INTEGER		; Store our new integer
BRnzp		GETCHAR

; Handle invalid char
ISINVALIDCHAR:
AND	R1, R1, #0
ADD	R1, R1, #1			; Set invalid input flag
ST	R1, INVALIDCHAR
BRnzp	GETCHAR

; Handle exit char
ISEXITCHAR:
PUTC
LEA	R0, NEWLINE			; Print the exit string
PUTS					; and pause the program
LEA	R0, EXITSTRING
PUTS
HALT

; Handle newline char
ISNEWLINECHAR:
LD		R1, SIGNFLAG
ADD		R1, R1, #0		; Add zero to sign flag to
BRz		SETUPMASK		; check if positive or negative
BRnzp		CONVERTNUMBER

; Handle negative char and check position
ISNEGATIVECHAR:
LD		R2, CHARCOUNTER		; Use character counter to check
ADD		R1, R1, R2		; if we've gone past the first
BRnp		GETCHAR			; character position
AND		R1, R1, #0
ADD		R1, R1, #1		; Set sign flag
ST		R1, SIGNFLAG
ADD		R2, R2, #1		; Increment the number of characters
ST		R2, CHARCOUNTER		; so far by one
PUTC
BRnzp GETCHAR

; Convert number to Two's Complement
CONVERTNUMBER:
LD		R4, INTEGER
NOT		R4, R4			; Convert the number to
ADD		R4, R4, #1		; a negative Two's Complement
ST		R4, INTEGER

; Setup mask
SETUPMASK:
LD		R2, MASKCOUNTER
LD		R3, MASKTOTALSHIFT	; Load variables we will need
LD		R4, MASK
LEA		R0, NEWLINE
PUTS
BRnzp		COMPAREBITS

; Shift the mask to the right by one
MASKSHIFT:				; Shift to the right by shifting left
ADD		R4, R4, R4
BRz		1			; Overflow case
BRnp		1
ADD		R4, R4, #1		; Add 1 because of overflow
ADD		R2, R2, #-1
BRz		1
BRzp		MASKSHIFT
LD		R2, MASKCOUNTER		; Reset our counter
ADD		R3, R3, #-1
BRnzp		COMPAREBITS

; Compare the two bits
COMPAREBITS:
LD		R0, INTEGER
AND		R5, R0, R4		; Apply the mask
BRz		ISZERO			; and print 0 or 1
BRnp		ISONE

; Mask has found a one
ISONE:
LEA		R0, ONECHAR
PUTS
BRnzp		CHECKTOTAL

; Mask has found a zero
ISZERO:
LEA		R0, ZEROCHAR
PUTS
BRnzp		CHECKTOTAL

; Check if mask is finished
CHECKTOTAL:
ADD		R3, R3, #0
BRz		1			; If zero then setup hex mask
BRnzp		MASKSHIFT

; Setup hex mask
SETUPHEXMASK:
LD		R2, HEXCOUNTER
LD		R3, HEXTOTALSHIFT	; Load variables we will need
LD		R4, HEXMASK
LEA		R0, NEWLINE
PUTS
BRnzp		HEXCOMPARE

; Shift the mask to the right by one
HEXSHIFT:				; Shift to the right by shifting left
ADD		R4, R4, #0
BRn		2			; Check if number is negative
ADD		R4, R4, R4		; to account for overflow
BRnzp		2
ADD		R4, R4, R4
ADD		R4, R4, #1
ADD		R2, R2, #-1
BRz		1
BRzp		HEXSHIFT
LD		R2, HEXCOUNTER
ADD		R3, R3, #-1
BRnzp		HEXCOMPARE

; Compare 4 bits
HEXCOMPARE:
LD		R0, INTEGER		; Load variables we will need
LD		R6, HEXCOUNTER
AND		R0, R0, R4
BRz		13			; If value is zero skip ahead
ADD		R5, R3, #0
BRz		11			; If counter is zero skip ahead

; Get result
GETRESULT:				; Shift to the right by shifting left
ADD		R0, R0, #0
BRn		2			; Check if number is negative
ADD		R0, R0, R0		; to account for overflow
BRnzp		2
ADD		R0, R0, R0
ADD		R0, R0, #1
ADD		R6, R6, #-1
BRp		GETRESULT
LD		R6, HEXCOUNTER
ADD		R5, R5, #-1
BRp		GETRESULT

AND		R6, R6, #0		; Check if number is within
ADD		R6, R6, #9		; 0 and 9 so we can print
NOT		R6, R6			; either a number or a letter
ADD		R6, R6, #1
ADD		R6, R0, R6
BRnz		ISNUMBER
BRp		ISLETTER

; The 4 bits is a number
ISNUMBER:
LD		R5, CHAROFFSET
NOT		R5, R5			; Add an offset to get the
ADD		R5, R5, #1		; decimal ascii value
ADD		R0, R0, R5
PUTC
BRnzp		CHECKHEXTOTAL

; The 4 bits is a letter
ISLETTER:
LD		R5, HEXOFFSET		; Add an offset to get the
ADD		R0, R0, R5		; decimal ascii value
PUTC
BRnzp		CHECKHEXTOTAL

; Check if hex mask if finished
CHECKHEXTOTAL:
ADD		R3, R3, #0
BRz		1
BRnzp		HEXSHIFT

; Display text for invalid char
LD		R1, INVALIDCHAR
ADD		R1, R1, #0		; Check if the invalid input flag
BRz		4			; and print text accordingly
LEA		R0, NEWLINE
PUTS
LEA		R0, REMOVEDCHAR
PUTS
LEA		R0, NEWLINE
PUTS
PUTS
PUTS
PUTS
BRnzp		START

; List of variables
CHARCOUNTER	.FILL	#0
CHAROFFSET	.FILL	#-48
EXITCHAR	.FILL	#-88
HEXCOUNTER	.FILL	#12
HEXMASK		.FILL	xF000
HEXOFFSET	.FILL	#55
HEXTOTALSHIFT	.FILL	#3
INTCOUNTER	.FILL	#10
INTEGER		.FILL	#0
INVALIDCHAR	.FILL	#0
MASK		.FILL	x8000
MASKCOUNTER	.FILL	#15
MASKTOTALSHIFT	.FILL	#15
MINIMUMASCII	.FILL	#-48
MAXIMUMASCII	.FILL	#-57
NEGATIVECHAR	.FILL	#-45
NEWLINECHAR	.FILL	#-10
SIGNFLAG	.FILL	#0

; List of strings
EXITSTRING	.STRINGZ	"Goodbye"
NEWLINE		.STRINGZ	"\n"
ONECHAR		.STRINGZ	"1"
PROMPT		.STRINGZ	"Decimal number to convert: "
REMOVEDCHAR	.STRINGZ	"Invalid character(s) removed from result"
ZEROCHAR	.STRINGZ	"0"

; End of code
.END