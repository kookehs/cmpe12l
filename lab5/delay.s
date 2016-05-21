#include <WProgram.h>

.global myprog

.set noreorder

.text

.ent myprog

myprog:			lw		$a0, loopdelay
				lw		$a1, loopconstant
				and		$t0, $t0, $zero
				and		$t1, $t1, $zero
				
				la		$t2, beginstring
				jal		_ZN5Print7printlnEPKc
				nop

outerloop:		and		$t1, $t1, $zero

innerloop:		nop

				addi	$t1, $t1, 1
				sub		$t2, $a1, $t1
				bgtz	$t2, innerloop
				nop

				addi	$t0, $t0, 1
				sub		$t2, $a0, $t0
				bgtz	$t2, innerloop
				nop

				la		$t2, finishedstring
				jal		_ZN5Print7printlnEPKc
				nop

.end myprog

.data
beginstring:	.ascii	"Begin"
finishedstring:	.ascii	"Finished"
loopconstant:	.word	15999
loopdelay:		.word	1000
