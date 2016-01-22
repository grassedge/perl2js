package P2JS::Node::IfStmt;
use strict;
use warnings;
use parent 'P2JS::Node';

sub expr { shift->{expr} }
sub true_stmt { shift->{true_stmt} }
sub false_stmt { shift->{false_stmt} }

1;
