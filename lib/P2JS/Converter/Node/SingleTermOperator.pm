package P2JS::Converter::Node::SingleTermOperator;
use strict;
use warnings;
use parent 'P2JS::Converter::Node';

use P2JS::Converter::Node::Nop;

use P2JS::Node::PostSingleTermOperator;
use P2JS::Node::PreSingleTermOperator;

sub expr { shift->{expr} // P2JS::Converter::Node::Nop->new; }

sub to_js_ast {
    my ($self, $context) = @_;
    my $token = $self->token;
    if ($token->data eq '++' ||
        $token->data eq '--') {
        # TODO. Compiler::Parser cannot distinguish pre/post.
        #       temporary use PostSingleTermOperator...
        return P2JS::Node::PostSingleTermOperator->new(
            token => $token,
            expr  => $self->expr->to_js_ast($context),
        );
    } elsif ($token->name eq 'Add') {
        # Add do nothing.
        $token->{data} = '';
        return P2JS::Node::PreSingleTermOperator->new(
            token => $token,
            expr  => $self->expr->to_js_ast($context),
        );
    } else {
        return P2JS::Node::PreSingleTermOperator->new(
            token => $token,
            expr  => $self->expr->to_js_ast($context),
        );
    }
}

1;
