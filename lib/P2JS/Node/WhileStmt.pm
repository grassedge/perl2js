package P2JS::Node::WhileStmt;
use strict;
use warnings;
use parent 'P2JS::Node';

sub expr { shift->{expr} }
sub true_stmt { shift->{true_stmt} }

1;
