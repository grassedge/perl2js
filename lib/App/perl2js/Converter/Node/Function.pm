package P2JS::Converter::Node::Function;
use strict;
use warnings;
use parent 'P2JS::Converter::Node::BlockStmt';

use P2JS::Converter::Node::Nop;

use P2JS::Node::Function;
use P2JS::Node::FunctionExpression;
use P2JS::Node::Method;

sub prototype {
    my ($self) = @_;
    return $self->{prototype};
}

sub to_js_ast {
    my ($self, $context) = @_;
    my $current_block = $context->current_block;

    my $statements = $self->statements;
    my $token = $self->token;

    my $is_code_ref = $token->name ne 'Function';
    my $block;
    if ($is_code_ref) {
        $block = P2JS::Node::FunctionExpression->new(
            token => $token,
            statements => [
                map { $_->to_js_ast($context->clone($block)) } @$statements
            ],
        )
    } elsif ($current_block->isa('P2JS::Node::Class')) {
        $block = P2JS::Node::Method->new(
            token => $token,
            statements => [
                map { $_->to_js_ast($context->clone($block)) } @$statements
            ],
        )
    } else {
        $block = P2JS::Node::Function->new(
            token => $token,
            statements => [
                map { $_->to_js_ast($context->clone($block)) } @$statements
            ],
        )
    }

    return $block;
}

1;
