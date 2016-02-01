package P2JS::Converter::Node::Function;
use strict;
use warnings;
use parent 'P2JS::Converter::Node';

use P2JS::Converter::Node::Nop;

use P2JS::Node::Function;
use P2JS::Node::FunctionExpression;
use P2JS::Node::Method;

sub body {
    my ($self) = @_;
    return $self->{body} // P2JS::Converter::Node::Nop->new;
}

sub prototype {
    my ($self) = @_;
    return $self->{prototype};
}

sub to_js_ast {
    my ($self, $context) = @_;
    my $next = $self->next;
    my $body = $self->body;

    my $token = $self->token;

    my $is_code_ref = $token->name ne 'Function';
    my $block;
    if ($is_code_ref) {
        $block = P2JS::Node::FunctionExpression->new(
            token => $token,
        )
    } else {
        $block = P2JS::Node::Method->new(
            token => $token,
        )
    }
    $context->push_sentence($block);
    if (!$next->is_nop) {
        $context->push_sentence($next->to_js_ast($context));
    }
    if (!$body->is_nop) {
        $body->to_js_ast($context->clone($block));
    }
}

1;
