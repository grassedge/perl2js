package P2JS::Node::IfStmt;

use strict;
use warnings;
use parent qw(P2JS::Node::BlockStmt);

use P2JS::Node::Nop;

sub expr {
    my ($self) = @_;
    return $self->{expr} // P2JS::Node::Nop->new;
}

sub false_stmt {
    my ($self) = @_;
    return $self->{false_stmt} // P2JS::Node::Nop->new;
}

sub to_javascript {
    my ($self, $depth) = @_;
    return (
        "if (",
        $self->expr->to_javascript($depth),
        ") {\n",
        $self->sentences_to_javascript($depth + 1),
        $self->indent($depth),
        "}",
        ($self->false_stmt->is_nop ?
         () :
         (" else ",
          $self->false_stmt->to_javascript($depth),
         )
        ),
    );
}

1;
