#!/bin/perl -l

use strict;
use warnings;

my @mem = map { 0 } 1..256;
my @r = (0, 0, 0, 0);

my @mnemonics = qw(
	copy swap cmp
	add sub mul div
	qget qset
	load save recv send
);

As a special case, swapping a register with itself will instead

# 4 I/O channels, 0 is used for inter-node communication, the rest is puzzle I/O
# 4 registers, r3 is IP

my @ops = (
	sub { $r[$a] = $r[$b] },
	sub { @r[$a, $b] = @r[$b, $a] },
	sub { $r[3] = $r[$b] if $r[$a] == 0 },
	sub { $r[3] = $r[$b] if $r[$a] != 0 },

	sub { $r[$a] += $r[$b] },
	sub { $r[$a] -= $r[$b] },
	sub { $r[$a] *= $r[$b] },
	sub { $r[$a] = $r[$b] ? $r[$a] / $r[$b] : 0 },

	sub { $r[$a] += 4 ** $b },
	sub { $r[$a] -= 4 ** $b },
	sub { "swiz" },
	sub { "resa" },

	sub { $r[$a] = $mem[$r[$b]] },
	sub { $mem[$r[$b]] = $r[$a] },
	sub { $r[$a] = <> },
	sub { print $r[$a] },
);

my $dp = 0;

while (<DATA>) {
	/([a-z]+) ([0-3]) ([0-3])/;
	my ($opcode) = grep { $mnemonics[$_] eq $1 } 0..15;
	$mem[$dp++] = ($opcode << 4) | ($2 << 2) | $3;
}

for (;;) {
	my $instr = $mem[$r[3]++];
	$r[3] %= 256;

	my $opcode = $instr >> 4;
	$a = ($instr >> 2) & 3;
	$b = $instr & 3;
	last unless defined $ops[$opcode]->();

	$r[$a] = int($r[$a]) % 256;
	$r[$b] = int($r[$b]) % 256;
}

=pod tuto

# Presentation of base-4

I expected everyone playing this early to know what base-4 is, so this section is TODO.

Quart = base-4 digit. Numbers are unsigned 4-quart, so in the 0-255 range.

# q104 reference manual

## Overview

The q104 is a low-power embedded processor. The core implements four 4-quart
registers and supports accesses to 4-quart memory addresses.

The core provides 4 serial input/output ports.

Each instruction is encoded in a single 4-quart number. The use of simple
instructions yields high efficiency and throughput: most instructions complete
in one clock cycle.

The arithmetic unit supports unsigned integer arithmetic only.

The q104 includes a 256-entry on-chip memory unit, used to store both
instructions and data.

## Register model

The q104 provides four registers. A, B, and Q are general purpose registers,
while I is the instruction pointer register.

Any of the four registers can be used as source and/or destination of most
instructions. The only exceptions are the `qget` and `qset` instructions, which
are restricted to operate on Q.

I contains the address of the next instruction. Whenever the processor is ready
to execute an instruction (usually, on each cycle), it fetches an instruction
from address I, then increments I by 1.

Instructions normally execute in order. Flow control is done by writing
to I the address where execution should continue.

## Instruction set

Instructions are encoded on 4 quarts. The first two quarts


### copy X Y

The content of Y is placed into X.

### swap X Y

Swaps the contents of X and Y.

As a special case, if X and Y are the same register, TODO

### cmp X Y

Compares the contents of X and Y. If they are equal,
1 is placed into X. Otherwise, 0 is placed into X.

### ??? X Y


### add X Y

The sum of the contents of X and Y is placed into X.

### sub X Y

The absolute difference between the contents of X and Y is placed into X.

### mul X Y

The product of the contents of X and Y is placed into X.

### div X Y

The quotient of the content of X divided by the content of Y is placed into X.
The remainder is not supplied as a result.

The result is rounded down. As a special case, dividing anything by 0 yields 0.


### inc X n

The nth quart of X is incremented by 1. In other words, 4^x is added to the contents of X.

### dec X n

The nth quart of X is decremented by 1. In other words, 4^x is added to the contents of X.

### qget X n

The nth quart of Q is placed into X.

Example: given Q = 0312, qget A 0 will set A to 2.

### qset i n

The nth quart of Q is set to i. Other quarts are unchanged.

Example: given Q = 0312, qset 2 3 will set Q to 2312.


### save X Y

The content of X is stored into the memory cell addressed by Y.

### load X Y

The memory cell addressed by Y is loaded into X.

### send X n

The content of X is sent to I/O port n. This operation hangs until the port becomes available.

### recv X n

A value is received from I/O port n and placed into X. 


# BLAH

There is no dedicated noop instruction. The assembler translates noop to
copy A A.

add, mul, inc, dec can cause overflow. If the result is greater than 255, it
wraps around to 0.


;;;; Fibonacci

; initialization: set A to 1
inc A

; main loop
out A
add A B
swap A B
dec I 1


;;;; Sequence reverser

qset 3 1
recv a
inc q
save a q
not a
copy b i
mul i a

0
dec q
load a q
send a
div a a
add a a
div i a


;;;; Sequence sorter

dec b
load q b
dec a
save q a
recv a
; if a non-zero jump to 1


@3333
send i

;;;; Sequence averager

qset 3 1

recv a
inc q
save a q
not a
add i a
div i i

dec q
load a q
qset 3 0
copy b a
div b q
qset 3 2
save q b
qset 3 0
mul q b
sub a q
inc b 3

qset 3 1
dec q
qget 3


=cut

__DATA__
copy 0 1
copy 0 0
recv 0 0
copy 1 0
dec 1 0
copy 2 1
dec 2 0
div 2 2
mul 3 2
copy 2 0
div 2 1
mul 2 1
sub 2 0
div 2 2
load 2 2
mul 2 3
inc 2 1
copy 3 2
copy 0 0
copy 0 0
send 0 0
sub 3 3
