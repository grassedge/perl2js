package P2JS::Converter::Node::WhileStmt;
use strict;
use warnings;
use parent 'P2JS::Converter::Node';

sub expr { shift->{expr} }
sub true_stmt { shift->{true_stmt} }

1;
