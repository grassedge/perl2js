# TODO: this package is not BlockStmt.
# field 'body' is used as statements in C::P::Node::Function.

package P2JS::Converter::Node::Return;
use strict;
use warnings;
use parent 'P2JS::Converter::Node::BlockStmt';

use P2JS::Node::Return;

sub to_js_ast {
    my ($self, $context) = @_;
    return P2JS::Node::Return->new(
        token => $self->token,
        statements => [ map { $_->to_js_ast($context) } @{$self->statements || []} ],
    );
}

1;
