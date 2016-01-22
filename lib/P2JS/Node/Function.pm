package P2JS::Node::Function;
use strict;
use warnings;
use parent 'P2JS::Node';

sub body { shift->{body} }
sub prototype { shift->{prototype} }

1;
