package P2JS::Node::PostSingleTermOperator;

use strict;
use warnings;
use parent qw(P2JS::Node);

use P2JS::Node::Nop;

sub expr {
    my ($self) = @_;
    return $self->{expr} // P2JS::Node::Nop->new;
}

sub to_javascript {
    my ($self, $depth) = @_;
    return (
        '(',
        $self->expr->to_javascript($depth),
        ')',
        $self->token->data,
    );
}

1;
