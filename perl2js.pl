use strict;
use warnings;
use Compiler::Lexer;
use Compiler::Parser;
use Compiler::Parser::AST::Renderer;

use Compiler::Parser::Node::ArrayRef;

use Module::Load;

use P2JS::Context;
use P2JS::Converter::Node;
use P2JS::Node::Class;

my $filename = $ARGV[0];
open(my $fh, "<", $filename) or die("Cannot open $filename: $!");
my $script = do { local $/; <$fh> };

my $lexer  = Compiler::Lexer->new($filename);
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
# print join ";\n", @{$context->{imports}};
# print "\n\n";
# print @$ret;
# print "}\n";
use Data::Dumper;
warn Dumper $context;
for my $import (@{$context->imports}) {
    print $import->to_javascript(0);
}
for my $class (@{$context->classes}) {
    print $class->to_javascript(0);
}
