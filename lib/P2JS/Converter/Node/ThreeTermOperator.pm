package P2JS::Converter::Node::ThreeTermOperator;
use strict;
use warnings;
use parent 'P2JS::Converter::Node';

sub cond { shift->{cond} }
sub true_expr { shift->{true_expr} }
sub false_expr { shift->{false_expr} }

1;
