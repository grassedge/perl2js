package P2JS::Node::CodeDereference;
use strict;
use warnings;
use parent 'P2JS::Node';

sub name { shift->{name} }
sub args { shift->{args} }

1;

__END__
