package P2JS::Node::ElseStmt;

use strict;
use warnings;
use parent qw(P2JS::Node);

use P2JS::Node::Nop;

sub stmt {
    my ($self) = @_;
    return $self->{stmt} // P2JS::Node::Nop->new;
}

sub to_javascript {
    my ($self, $depth) = @_;
    return (
        "{\n",
        ($self->stmt->is_nop ?
         () :
         ($self->indent($depth + 1),
          $self->stmt->to_javascript($depth + 1),
          "\n",
         )
        ),
        $self->indent($depth),
        "}",
        $self->next->to_javascript($depth),
    );
}

1;
