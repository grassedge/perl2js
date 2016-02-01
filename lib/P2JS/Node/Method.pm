package P2JS::Node::Method;

use strict;
use warnings;
use parent qw(P2JS::Node::Block);

use P2JS::Node::Nop;

sub body {
    my ($self) = @_;
    return $self->{body} // P2JS::Node::Nop->new;
}

sub to_javascript {
    my ($self, $depth) = @_;
    return (
        $self->token->data . "() {\n",
        (scalar(@{$self->sentences}) ?
         ($self->indent($depth + 1),
          "if (this !== undefined) { Array.prototype.unshift.call(arguments, this) }\n",
          $self->indent($depth + 1),
          (join "\n", map { join '', $_->to_javascript($depth) } @{$self->sentences}),
          "\n",
         ) : ()
        ),
        $self->indent($depth),
        "}"
    );
}

1;
