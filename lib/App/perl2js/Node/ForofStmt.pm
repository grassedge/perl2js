package P2JS::Node::ForofStmt;

use strict;
use warnings;
use parent qw(P2JS::Node::BlockStmt);

use P2JS::Node::Nop;

sub cond {
    my ($self) = @_;
    return $self->{cond} // P2JS::Node::Nop->new;
}

sub itr {
    my ($self) = @_;
    return $self->{itr} // P2JS::Node::Nop->new;
}

sub to_javascript {
    my ($self, $depth) = @_;
    return (
        "for (",
        $self->itr->to_javascript,
        " of ",
        $self->cond->to_javascript,
        ") {\n",
        $self->sentences_to_javascript($depth + 1),
        $self->indent($depth),
        "}",
    );
}

1;
