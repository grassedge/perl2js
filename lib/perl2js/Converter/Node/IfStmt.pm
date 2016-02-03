package P2JS::Converter::Node::IfStmt;
use strict;
use warnings;
use parent 'P2JS::Converter::Node::BlockStmt';

use Compiler::Lexer::Token;

use P2JS::Converter::Node::Nop;
use P2JS::Converter::Node::SingleTermOperator;

use P2JS::Node::IfStmt;

sub expr { shift->{expr} // P2JS::Converter::Node::Nop->new; }
sub false_stmt { shift->{false_stmt} // P2JS::Converter::Node::Nop->new; }

sub to_js_ast {
    my ($self, $context) = @_;
    my $token = $self->token;
    my $expr;
    if ($token->name eq 'UnlessStmt') {
        $expr = P2JS::Converter::Node::SingleTermOperator->new(
            token => bless({
                data => '!',
                name => '', # TODO specify token name
            }, 'Compiler::Lexer::Token'),
            expr => $self->expr,
        );
    } else {
        $expr = $self->expr;
    }
    return P2JS::Node::IfStmt->new(
        token => $self->token,
        expr  => $expr->to_js_ast($context),
        statements => [ map { $_->to_js_ast($context) } @{$self->statements || []} ], # TODO why statements is undef ?
        false_stmt => $self->false_stmt->to_js_ast($context),
    );
}

1;
