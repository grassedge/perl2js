package P2JS::Node::Method;

use strict;
use warnings;
use parent qw(P2JS::Node::BlockStmt);

use P2JS::Node::Nop;

sub to_javascript {
    my ($self, $depth) = @_;
    return (
        $self->token->data . "() {\n",
        (scalar(@{$self->statements}) ?
         ($self->indent($depth + 1),
          "if (this !== undefined) { Array.prototype.unshift.call(arguments, this) }\n",
          $self->sentences_to_javascript($depth + 1),
         ) : ()
        ),
        $self->indent($depth),
        "}"
    );
}

1;
