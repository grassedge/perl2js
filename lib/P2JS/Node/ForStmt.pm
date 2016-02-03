package P2JS::Node::ForStmt;

use strict;
use warnings;
use parent qw(P2JS::Node::BlockStmt);

use P2JS::Node::Nop;

sub init {
    my ($self) = @_;
    return $self->{init} // P2JS::Node::Nop->new;
}

sub cond {
    my ($self) = @_;
    return $self->{cond} // P2JS::Node::Nop->new;
}

sub progress {
    my ($self) = @_;
    return $self->{progress} // P2JS::Node::Nop->new;
}

sub to_javascript {
    my ($self, $depth) = @_;
    return (
        "for (",
        $self->init->to_javascript,
        "; ",
        $self->cond->to_javascript,
        "; ",
        $self->progress->to_javascript,
        ") {\n",
        $self->sentences_to_javascript($depth + 1),
        $self->indent($depth),
        "}",
    );
}

1;
