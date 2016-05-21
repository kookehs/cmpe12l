#include <WProgram.h>

/* Push a register */
.macro  push reg
				sw			\reg, ($sp)
				addi		$sp, $sp, -4
.endm

/* Pop a register */
.macro  pop reg
				addi		$sp, $sp, 4
				lw			\reg, ($sp)
.endm

/* Jump to our customized routine by placing a jump at the vector 4 interrupt vector offset */
.section .vector_4,"xaw"
				j			T1_ISR

/* The .global will export the symbols so that the subroutines are callable from main.cpp */
.global PlayNote
.global SetupPort
.global SetupTimer 
.global	ProgramNote
.global	PlayNote

/* This starts the program code */
.text

/* We do not allow instruction reordering in our lab assignments. */
.set noreorder

/*********************************************************************
 * myprog()
 * This is where the PIC32 start-up code will jump to after initial
 * set-up.
 ********************************************************************/
.ent myprog

/* This should setup the ports */
SetupPort:		la			$t0, TRISD              # Load the address of TRISD

				li			$t1, 0x0008
				sw			$t1, 4($t0)             # Clear bit 3 as output for speaker

				li			$t1, 0x00E0
				sw			$t1, 8($t0)             # Set bits 5, 6, and 7 as input for buttons

                li          $t1, 0x0F00
                sw          $t1, 8($t0)             # Set bits 8, 9, 10, 11 as inputs for switches

				la			$t0, TRISF              # Load the address of TRISF
				
				li			$t1, 0x0002
				sw			$t1, 8($t0)             # Set bit 1 as input for button

                la			$t0, TRISE              # Load the address of TRISE

				li			$t1, 0x00FF
				sw			$t1, 4($t0)             # Clear all bits as output for LEDs

                la          $t0, PORTE              # Load address of PORTE

                li          $t1, 0x00FF
                sw          $t1, 0($t0)             # Turn on all LEDs

				jr			$ra
				nop

/* 
 * This should configure Timer 1 and the corresponding interrupts,
 * but it should not enable the timer.
 */
SetupTimer:		la			$t0, T1CON              # Load the address of T1CON

				li			$t1, 0xFFFF
				sw			$t1, 4($t0)             # Clear all bits of T1CON

				li			$t1, 0x0030
				sw			$t1, 8($t0)             # Set bits 4 and 5 to 256 (T1CKPS)

				la			$t0, TMR1               # Load the address of TMR1
				
				li			$t1, 0xFFFF
				sw			$t1, 4($t0)             # Clear all bits of TMR1

				la			$t0, PR1                # Load address of PR1

				li			$t1, 0x00FF
				sw			$t1, 0($t0)             # Set PR1 to 255

				la			$t0, IPC1               # Load address of IPC1

				li			$t1, 0x001C
				sw			$t1, 8($t0)             # Set bits 2, 3, and 4 for interrupt priority

				la			$t0, IFS0               # Load address of IFS0

				li			$t1, 0x0010
				sw			$t1, 4($t0)             # Clear bit 4 to reset interrupt flag
					
				la			$t0, IEC0               # Load address of IEC0

				li			$t1, 0x0010
				sw			$t1, 8($t0)             # Set bit 4 to enable interrupts

				jr			$ra
				nop

ClearButtons:   sw          $zero, button1
                sw          $zero, button2
                sw          $zero, button3
                sw          $zero, button4

                jr          $ra
                nop
                
ClearSwitches:  sw          $zero, switch1
                sw          $zero, switch2
                sw          $zero, switch3
                sw          $zero, switch4
                sw          $zero, switchvalue

                jr          $ra
                nop

CheckButtons:   lw          $t0, PORTF              # Load address of PORTF

                li          $t1, 0x0002             # Value of first button
                and         $t1, $t0, $t1           # Get desired bit
                sw          $t1, button1            # Store value into variable

                lw          $t0, PORTD              # Load address of PORTD

                li          $t1, 0x0020             # Value of second button
                and         $t1, $t0, $t1           # Get desired bit
                sw          $t1, button2            # Store value into variable

                li          $t1, 0x0040             # Value of third button
                and         $t1, $t0, $t1           # Get desired bit
                sw          $t1, button3            # Store value into variable

                li          $t1, 0x0080             # Value of fourth button
                and         $t1, $t0, $t1           # Get desired bit
                sw          $t1, button4            # Store value into variable

                jr          $ra
                nop

CheckSwitches:  lw          $t0, PORTD              # Load address of PORTD
                li          $t1, 0x0F00             # Load value of the switch mask

                and         $t0, $t0, $t1           # Apply the switch mask
                sw          $t0, switchvalue        # Store value of the switches into variable

                li          $t1, 0x0100             # Value of first switch
                and         $t1, $t0, $t1
                sne         $t2, $zero, $t1         # Set $t2 to 1 if not equal
                sw          $t2, switch1            # Store value into variable

                li          $t1, 0x0200             # Value of first switch
                and         $t1, $t0, $t1
                sne         $t2, $zero, $t1         # Set $t2 to 1 if not equal
                sw          $t2, switch2            # Store value into variable

                li          $t1, 0x0400             # Value of first switch
                and         $t1, $t0, $t1
                sne         $t2, $zero, $t1         # Set $t2 to 1 if not equal
                sw          $t2, switch3            # Store value into variable

                li          $t1, 0x0800             # Value of first switch
                and         $t1, $t0, $t1
                sne         $t2, $zero, $t1         # Set $t2 to 1 if not equal
                sw          $t2, switch4            # Store value into variable

                jr          $ra
                nop

CheckResult:    push        $ra

                lw          $t0, switchvalue        # Load value of switches

                li          $t1, 0x0F00
                beq         $t0, $t1, PlayNote      # If all switches are on then play notes
                nop

                lw          $t0, switch1            # Load value of first switch
                bne         $zero, $t0, AssignNote  # If switch is on then assign a note
                nop

                pop         $ra

                jr          $ra
                nop

AssignNote:     push        $ra

                jal         ReadSignal              # Get value of the frequency
                nop

                move        $a0, $v0
                jal         FreqToPeriod            # Converty frequency to period
                nop

                move        $t0, $v0

                lw          $t1, button1            # Load value of first button
                beq         $zero, $t1, AN2         # If button is not pressed then move on
                nop
                sw          $t0, freq1              # Store frequency

AN2:            lw          $t1, button2            # Load value of second button
                beq         $zero, $t1, AN3         # If button is not pressed then move on
                nop
                sw          $t0, freq2              # Store frequency

AN3:            lw          $t1, button3            # Load value of third button
                beq         $zero, $t1, AN4         # If button is not pressed then move on
                nop
                sw          $t0, freq3              # Store frequency

AN4:            lw          $t1, button4            # Load value of fourth button
                beq         $zero, $t1, AN5         # If button is not pressed then move on
                nop
                sw          $t0, freq4              # Store frequency

AN5:            lw          $t1, switch2            # Load value of second switch
                beq         $zero, $t1, AN6         # If switch is not on then move on
                nop
                sw          $t0, freq5              # Store frequency

AN6:            lw          $t1, switch3            # Load value of third switch
                beq         $zero, $t1, ANRet       # If switch is not on then move on
                nop
                sw          $t0, freq6              # Store frequency
                
ANRet:          pop         $ra
                
                jr          $ra
                nop

ReadSignal:     push        $ra
                
                li          $a0, 0
                jal         analogRead              # Read frequency
                nop

                pop         $ra

                jr          $ra
                nop

/* This converts frequency to period */
FreqToPeriod:	beq         $zero, $a0, FTPRet      # If frequency is 0 then return
                nop
                
                li			$t0, 0x0002625A         # 80,000,000 / 256 / 2 = 156250
				div			$v0, $t0, $a0           # Divide frequency by 156250

FTPRet: 		jr			$ra
				nop

/* 
 * This should should enable the user to assign a tune to a button
 */
ProgramNote:	jal         ReadSignal              # Get value of frequency
                nop

                la          $a0, Serial
                move        $a1, $v0
                li          $a2, 10
                jal         _ZN5Print7printlnEii    # Print frequency
                nop

                jal         CheckButtons
                nop

                jal         CheckSwitches
                nop

                jal         CheckResult
                nop

                jal         ClearButtons
                nop

                jal         ClearSwitches
                nop

                li          $a0, 1
                jal         delay
                nop

                j           ProgramNote
                nop
	
/* Plays custom tone */	
PlayNote:		jal         ClearButtons
                nop

                jal         CheckButtons
                nop

                la			$t0, PR1                # Load address of PR1

                lw          $t1, button1            # Load value of first button
                beq         $zero, $t1, PN2         # If button is not pressed move on
                nop
                lw          $t1, freq1
                nop
                sw          $t1, 0($t0)             # Store frequency

PN2:            lw          $t1, button2            # Load value of second button
                beq         $zero, $t1, PN3         # If button is not pressed move on
                nop
                lw          $t1, freq2
                nop
                sw          $t1, 0($t0)             # Store frequency

PN3:            lw          $t1, button3            # Load value of third button
                beq         $zero, $t1, PN4         # If button is not pressed move on
                nop
                lw          $t1, freq3
                nop
                sw          $t1, 0($t0)             # Store frequency

PN4:            lw          $t1, button4            # Load value of fourth button
                beq         $zero, $t1, PNRet       # If button is not pressed move on
                nop
                lw          $t1, freq4
                nop
                sw          $t1, 0($t0)             # Store frequency

PNRet:          jal         EnableTimer
                nop

          		j           PlayNote
                nop
	
/* This procedure is not required, but I found it easier this way. It is not called from main.cpp. */
/* This turns on the timer to start counting */	
EnableTimer:	la			$t0, T1CON              # Load address of T1CON

				li			$t1, 0x8000
				sw			$t1, 8($t0)             # Set bit 15 to enable timer
	
				jr			$ra
				nop
	
/* This procedure is not required, but I found it easier this way. It is not called from main.cpp. */
/* This turns off the timer from counting */
DisableTimer:	la			$t0, T1CON              # Load address of T1CON
				
				li			$t1, 0x8000
				sw			$t1, 4($t0)             # Clear bit 15 to disable timer
	
				jr			$ra
				nop
	
/* The ISR should toggle the speaker output value and then clear and re-enable the interrupts. */
T1_ISR:			la			$t0, TRISD              # Load the address of TRISD

				li			$t1, 0x0008
				sw			$t1, 12($t0)            # Toggle bit 3 of the speaker

                la			$t0, IFS0               # Load address of IFS0

				li			$t1, 0x0010
				sw			$t1, 4($t0)             # Clear bit 4 to reset interrupt flag

				la			$t0, TMR1               # Load address of TMR1
				
				li			$t1, 0xFFFF
				sw			$t1, 4($t0)             # Clear all bits of TMR1
	
				eret
				nop

/* 
 * directive that marks end of 'myprog' function and registers
 * size in ELF output
 */
.end myprog

					 
.data
button1:        .word   0
button2:        .word   0
button3:        .word   0
button4:        .word   0
freq1:	        .word	0
freq2:	        .word	0
freq3:  	    .word	0
freq4:	        .word	0
freq5:          .word   0
freq6:          .word   0
switch1:        .word   0
switch2:        .word   0
switch3:        .word   0
switch4:        .word   0
switchmask:     .word   0x0F00
switchvalue:    .word   0
