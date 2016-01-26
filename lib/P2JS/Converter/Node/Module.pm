package P2JS::Converter::Node::Module;
use strict;
use warnings;
use parent 'P2JS::Converter::Node';

use P2JS::Converter::Node::Nop;
use P2JS::Node::Import;

sub args { shift->{args} // P2JS::Converter::Node::Nop->new; }

sub to_js_ast {
    my ($self, $context) = @_;
    my $token = $self->token;

    # translate various modules to JavaScript
    if      ($token->data eq 'strict') {
    } elsif ($token->data eq 'warnings') {
    } else {
        my $import = P2JS::Node::Import->new(
            token => $self->token,
        );
        $context->push_import($import);
    }
    return $self->next->to_js_ast($context);
}

1;
