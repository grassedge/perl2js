package P2JS::Node::ThreeTermOperator;

use strict;
use warnings;
use parent qw(P2JS::Node);

use P2JS::Node::Nop;

sub cond {
    my ($self) = @_;
    return $self->{cond} // P2JS::Node::Nop->new;
}

sub true_expr {
    my ($self) = @_;
    return $self->{true_expr} // P2JS::Node::Nop->new;
}

sub false_expr {
    my ($self) = @_;
    return $self->{false_expr} // P2JS::Node::Nop->new;
}

sub to_javascript {
    my ($self, $depth) = @_;
    return (
        $self->cond->to_javascript($depth),
        " ? ",
        $self->true_expr->to_javascript($depth),
        " : ",
        $self->false_expr->to_javascript($depth),
        ($self->next->is_nop ? () : (";\n" . $self->indent($depth))),
        $self->next->to_javascript($depth),
    );
}

1;
