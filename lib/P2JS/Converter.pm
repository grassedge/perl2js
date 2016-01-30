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
    # SCALAR
    # ARRAY
    # HASH
    # CODE
    # REF
    # GLOB
    # LVALUE
    # FORMAT
    # IO
    # VSTRING
    # Regexp
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
        "'use strict';\n",
        "function print() { console.log.apply(console.log, arguments) }\n",
        "function warn() { console.warn.apply(console.log, arguments) }\n",
        "function ref(a) { return typeof (a) }\n",
        "function pop(a) { return Array.prototype.pop.call(a) }\n",
        "function shift(a) { return Array.prototype.shift.call(a) }\n",
        "function push(a, b) { return Array.prototype.push.call(a, b) }\n",
        "function unshift(a, b) { return Array.prototype.unshift.call(a, b) }\n",
        "function bless(obj, proto) {\n",
        "    var new_obj = {};\n",
        "    Object.keys(obj).forEach((key) => {\n",
        "        new_obj[key] = { value: obj[key] }\n",
        "    })\n",
        "    return Object.create(proto, new_obj)\n",
        "}\n",
        "function map(a, b) { return Array.prototype.map.call(b, a) }\n",
        "function join(a, b) { return Array.prototype.join.call(b, a) }\n",
        "function length(a) { return a.length }\n",
        "function range(a, b) {\n",
        "    var list = [];\n",
        "    for (var i = a; i <= b; i++) { list.push(i) }\n",
        "    return list\n",
        "}\n",
        "function string_multi(s, n) {\n",
        "    var str = '';\n",
        "    for (var i = 0; i < n; i++) { str += s }\n",
        "    return str\n",
        "}\n",
        "function default_or(a, b) { return ((a === undefined) || (a === null)) ? b : a }\n",
        (map { $_->to_javascript(0) } @{$context->imports}),
        "\n",
        (map { $_->to_javascript(0) } @{$context->classes}),
    );
}

1;
