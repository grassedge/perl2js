package P2JS::Converter;

use strict;
use warnings;
use Compiler::Lexer;
use Compiler::Parser;

use Module::Load;

use P2JS::Context;

# http://perldoc.perl.org/perlfunc.html
my $runtime = {
    'print'  => "function print() { console.log(...arguments) }\n",
    'warn'   => "function warn() { console.log(...arguments) }\n",
    'ref'    => "function ref(a) { return typeof(a) }\n",
    'pop'    => "function pop(a) { return a.pop() }\n",
    # 'push'   => "function push(a) { }\n",
    # 'map'    => "function map(a) { }\n",
    # 'splice' => "function splice(a) { }\n",
    'bless'  => "function bless(obj, proto) { return Object.create(proto, obj) }\n",
    # 'join'   => "function join(a) { }\n",
    'length' => "function length(a) { return a.length }\n",
};

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
        "'use strict;'\n",
        (map { $_->to_javascript(0) } @{$context->imports}),
        "\n",
        (map { $_->to_javascript(0) } @{$context->classes}),
    );
}

1;
