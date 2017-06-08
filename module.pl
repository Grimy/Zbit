#!/bin/perl -n

binmode(STDOUT, ':utf8');
sub pak { map $_ ^ y// /rc, pack "w*", @_ }
print '@', pak $1, $2, $3 if /<enemy x="(.*?)" y="(.*?)" type="(.*?)"/;
print '^', pak $1, $2, $3, $4 if /<trap x="(.*?)" y="(.*?)" type="(.*?)" subtype="(.*?)"/;

if (/<tile x=".*?" y="(.*?)" type="(.*?)"/) {
	print '|' if $1 ne $y;
	$y = $1;
	print pak $2;
}
