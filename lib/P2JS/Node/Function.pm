package P2JS::Node::Function;

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
        "export function " . $self->token->data . "() {\n",
        ($self->body->is_nop ?
         () :
         ($self->indent($depth + 1),
          "if (this !== undefined) { Array.prototype.unshift.call(arguments, this) }\n",
          $self->indent($depth + 1),
          $self->body->to_javascript($depth + 1),
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
