package P2JS::Node::Class;

use strict;
use warnings;
use parent qw(P2JS::Node);

use P2JS::Node::Nop;

sub body {
    my ($self) = @_;
    return $self->{body} // P2JS::Node::Nop->new;
}

sub to_javascript {
    my ($self, $depth) = @_;
    return (
        "class ", $self->token->data,
        ($self->{super_class} ? (" extends ", $self->{super_class}) : ()),
        " {\n",
        ($self->body->is_nop ?
         () :
         ($self->indent($depth + 1),
          $self->body->to_javascript($depth + 1),
          "\n",
         )
        ),
        $self->indent($depth),
        "}\n",
        ($self->next->is_nop ? () : ($self->indent($depth))),
        $self->next->to_javascript($depth),
    );
}

1;
