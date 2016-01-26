package P2JS::Converter;

use strict;
use warnings;
use Compiler::Lexer;
use Compiler::Parser;

use Module::Load;

use P2JS::Context;

sub convert {
    my ($class, $script) = @_;

    my $lexer  = Compiler::Lexer->new();
    my $tokens = $lexer->tokenize($script);
    my $parser = Compiler::Parser->new();
    my $ast = $parser->parse($tokens);

    $ast->walk(sub {
        my ($node) = @_;
        my $ref = ref($node);
        $ref =~ s/Compiler::Parser/P2JS::Converter/;
        load $ref;
        bless $node, $ref;
    });

    my $context = P2JS::Context->new;
    my $root = $ast->root;
    my $ret = $root->to_js_ast($context);

    return join(
        '',
        (map { $_->to_javascript(0) } @{$context->imports}),
        (map { $_->to_javascript(0) } @{$context->classes}),
    );
}

1;
