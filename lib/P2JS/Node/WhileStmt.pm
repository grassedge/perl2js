package P2JS::Node::WhileStmt;

use strict;
use warnings;
use parent qw(P2JS::Node::BlockStmt);

use P2JS::Node::Nop;

sub expr {
    my ($self) = @_;
    return $self->{expr} // P2JS::Node::Nop->new;
}

sub to_javascript {
    my ($self, $depth) = @_;
    return (
        "while (",
        $self->expr->to_javascript,
        ") {\n",
        $self->sentences_to_javascript($depth + 1),
        $self->indent($depth),
        "}",
    );
}

1;
