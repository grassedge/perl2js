package P2JS::Node::WhileStmt;

use strict;
use warnings;
use parent qw(P2JS::Node);

use P2JS::Node::Nop;

sub expr {
    my ($self) = @_;
    return $self->{expr} // P2JS::Node::Nop->new;
}

sub true_stmt {
    my ($self) = @_;
    return $self->{true_stmt} // P2JS::Node::Nop->new;
}

sub to_javascript {
    my ($self, $depth) = @_;
    return (
        "while (",
        $self->expr->to_javascript,
        ") {\n",
        ($self->true_stmt->is_nop ?
         () :
         ($self->indent($depth + 1),
          $self->true_stmt->to_javascript($depth + 1),
          "\n",
         )
        ),
        $self->indent($depth),
        "}",
        ($self->next->is_nop ? () : ("\n" . $self->indent($depth))),
        $self->next->to_javascript($depth),
    );
}

1;
