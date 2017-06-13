#!perl -l

my %gates = ();
my @names = qw(0 & > A < B ^ |);

my @trans = qw(
	0  0  0  0  0  0  0  0
	1  1  1  0  1  1  1  3
	1  2  0  2  2  1  4  2
	4  3  0  3  3  1  4  3
	4  0  4  4  2  4  4  4
	5  5  1  2  5  5  6  5
	6  1  6  4  5  6  6  7
	7  3  4  7  7  6  7  7
);

gate: for (1..8**7) {
	$_ = sprintf '%o', $_;
	my @gate = map int, /./g;
	my $gate = y/0-7/UTE2XMYN/r;
	my @base = (1, 4, 6);
	my @results = (0, 0);

	for $state (@base) {
		$state = $trans[8*$state + $_] for @gate;
		next gate if $state == 2 || $state == 3 || $state == 5 || $state == 7;
		$results[0] = 2 * $results[0] + ($state == 4 || $state == 6);
		$results[1] = 2 * $results[1] + ($state == 1 || $state == 6);
	}

	my $name = join '', @names[@results];
	if (!$gates{$name}) {
		$gates{$name} = $gate;
		print "$name $gate";
	}

}
