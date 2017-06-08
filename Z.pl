#!/usr/bin/perl -ln

push @_, sprintf("%0*b", length $&, shift) =~ /./g while /Ii*/g;
print(oct 'b' . join '', @_), last if /O/;
print STDERR s/.\K/ /gr;
y/AB/#;/;
@_[@-] = map { int eval join chr ord, @_[@-] } $&, $1 while /[&|^<>#;](.)/gi;
print STDERR "@_";
