/*             Bill Lin --- blin7 
 *             Lab Section: 6 TTh
 *             TA:          Jay Roldan
 *             Due:         May 21, 2014
 */


#include <WProgram.h>

.global myprog

.set noreorder

.text

.ent myprog

myprog:			la          $a0, Serial
				la		    $a1, greetingstring
				jal		    _ZN5Print7printlnEPKc
				nop
                
                jal         enableswitch
                nop

                jal         enableled
                nop

                j           checkswitches
                nop

enableswitch:   la          $t0, TRISD                      # Load the address of TRISD
                li          $t1, 0xFFFF                     # Load the value to clear with
                sh          $t1, 4($t0)                     # Store the value enabling outputs
                li          $t1, 0x0300                     # Load the value that will be inputs
                sh          $t1, 8($t0)                     # Store the value enabling inputs

                jr          $ra
                nop

enableled:      la          $t0, TRISE                      # Load the address of TRISE
                li          $t1, 0x00FF                     # Load the value to clear with
                sh          $t1, 4($t0)                     # Store the value enabling outputs

                jr          $ra
                nop

clearled:       la          $t0, PORTE                      # Load the address of PORTE
                li          $t9, 0x00FF                     # Load the value to clear with
                sh          $t9, 4($t0)                     # Store the value clearing LEDs

                jr          $ra
                nop

checkswitches:  la          $a0, Serial
				la		    $a1, checkstring
				jal		    _ZN5Print7printlnEPKc
				nop

                lh          $t0, PORTD                      # Load the bits of PORTD
                lh          $t1, switchmask                 # Load the mask for the switch
                and         $t2, $t0, $t1                   # AND the two to get wanted bits

                la          $t0, PORTE                      # Load the address of PORTE

                li          $t1, 0x0000                     # Load the value to compare
                beq         $t1, $t2, zero
                nop

                li          $t1, 0x0100                     # Load the value to compare
                beq         $t1, $t2, zeroone
                nop

                li          $t1, 0x0200                     # Load the value to compare
                beq         $t1, $t2, onezero
                nop

                li          $t1, 0x0300                     # Load the value to compare
                beq         $t1, $t2, oneone
                nop

zero:           jal         clearled
                nop

                li          $a0, 0x03E8                     # Load a delay of 1000ms
                li          $t1, 0x00FF                     # Load the value of LEDs to turn on
                sh          $t1, 8($t0)                     # Store the value turning on LEDs

                jal         mydelay
                nop

                li          $t1, 0x00FF                     # Load the value of bits to invert
                sh          $t1, 12($t0)                    # Store the value inverting LEDs

                jal         mydelay
                nop

                j           checkswitches
                nop

zeroone:        li          $a0, 0x01F4                     # Load a delay of 500ms
                li          $t1, 0x0008                     # Load the value of the counter
                li          $t2, 0x0080                     # Load the value of initial LED

zerooneloop:    jal         clearled
                nop

                sh          $t2, 8($t0)                     # Store the value turning on LEDs
                srl         $t3, $t2, 1                     # Shift bits to the right
                or          $t2, $t2, $t3                   # OR with original value

                jal         mydelay
                nop

                sub         $t1, $t1, 1                     # Subtract 1 from counter
                bnez        $t1, zerooneloop                # Continue pattern until counter is zero
                nop

                j           checkswitches
                nop

onezero:        jal         clearled
                nop

                li          $a0, 0x07D0                     # Load a delay of 2000ms
                li          $t1, 0x0055                     # Load the value of initial LEDs
                sh          $t1, 8($t0)                     # Store the value turning on LEDs

                jal         mydelay
                nop

                li          $t1, 0x00FF                     # Load the value of bits to invert
                sh          $t1, 12($t0)                    # Store the value inverting LEDs

                jal         mydelay
                nop

                j           checkswitches
                nop

oneone:         jal         clearled
                nop
                
                li          $a0, 0x00C8                     # Load a delay of 200ms
                li          $t1, 0x0081                     # Load the value of initial LEDs
                sh          $t1, 8($t0)                     # Store the value turning on LEDs

                jal         mydelay
                nop

                jal         clearled
                nop

                li          $t1, 0x0042                     # Load the value of initial LEDs
                sh          $t1, 8($t0)                     # Store the value turning on LEDs

                jal         mydelay
                nop

                jal         clearled
                nop

                li          $t1, 0x0024                     # Load the value of initial LEDs
                sh          $t1, 8($t0)                     # Store the value turning on LEDs

                jal         mydelay
                nop

                jal         clearled
                nop

                li          $t1, 0x0018                     # Load the value of initial LEDs
                sh          $t1, 8($t0)                     # Store the value turning on LEDs

                jal         mydelay
                nop

                jal         clearled
                nop

                li          $t1, 0x0024                     # Load the value of initial LEDs
                sh          $t1, 8($t0)                     # Store the value turning on LEDs

                jal         mydelay
                nop

                jal         clearled
                nop

                li          $t1, 0x0042                     # Load the value of initial LEDs
                sh          $t1, 8($t0)                     # Store the value turning on LEDs

                jal         mydelay
                nop

                j           checkswitches
                nop

mydelay:        lw		    $a1, delayconstant              # Load the value of the constant
				and		    $t8, $t8, $zero                 # Clear register which will be a counter
				and		    $t9, $t9, $zero                 # Clear register which will be a counter

outerloop:		and		    $t9, $t9, $zero                 # Clear counter for next loop

innerloop:		nop

				addi	    $t9, $t9, 1                     # Add 1 to the counter
                bne         $a1, $t9, innerloop             # Continue until counter is equal
				nop

				addi	    $t8, $t8, 1                     # Add 1 to the counter
                bne         $a0, $t8, outerloop             # Continue until counter is equal
				nop

                jr          $ra
                nop

.end myprog

.data
beginstring:	.asciiz	    "Begin delay"
checkstring:    .asciiz     "Checking switches"
finishedstring:	.asciiz	    "Finished delay"
greetingstring: .asciiz     "Welcome to the light show"
delayconstant:	.word	    0x4E1F                          # Delay constant of 20,000
switchmask:     .word       0x0300                          # Switch mask for bits 8 and 9
