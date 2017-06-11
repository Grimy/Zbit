#!perl -l

my @names = qw(0 & > A < B ^ |);
my $n = 6;

gate: for (0..10**$n) {
	s/./qw(l0 l1 l2 h1 h2 h3 o1 o2 ^0 ^2)[$&]/ge;
	$gate = $_;
	my @results = (0, 0);

for $A (0, 1) { for $B (0, 1) {
	my @Z = (0, $A, 0, $B, 0);
	my @prev_dir = (0, 0, 0, 0);
	while ($gate =~ /(.)(.)/g) {
		next unless $Z[$2];
		my $dir =
			$1 eq 'l' ? 1 :
			$1 eq 'h' ? -1 :
			$1 eq 'o' ? $prev_dir[$2] :
			$1 eq '^' ? 4 - $2 :
			die;
		next gate if $dir == 0;
		my $dest = $2 + $dir;
		die if $dest < 0;
		next if $Z[$dest];
		$Z[$2] = 0;
		$Z[$dest] = 1;
		$prev_dir[$dest] = $dir;
	}
	next gate if $Z[0] or $Z[2];
	$results[0] = 2 * $results[0] + $Z[1];
	$results[1] = 2 * $results[1] + $Z[3];
}}

	print "$gate:\t", @names[@results];

}
