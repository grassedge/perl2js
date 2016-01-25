package P2JS::Node::Branch;

use strict;
use warnings;
use parent qw(P2JS::Node);

use P2JS::Node::Nop;

sub left {
    my ($self) = @_;
    return $self->{left} // P2JS::Node::Nop->new;
}

sub right {
    my ($self) = @_;
    return $self->{right} // P2JS::Node::Nop->new;
}

sub to_javascript {
    my ($self, $depth) = @_;
    return (
        $self->left->to_javascript($depth),
        " " . $self->token->data . " ",
        $self->right->to_javascript($depth),
        $self->next->to_javascript($depth),
    );
}

1;
