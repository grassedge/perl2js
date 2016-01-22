use strict;
use warnings;
use Compiler::Lexer;
use Compiler::Parser;
use Compiler::Parser::AST::Renderer;

use Compiler::Parser::Node::ArrayRef;

use P2JS::Node::Class;

my $filename = $ARGV[0];
open(my $fh, "<", $filename) or die("Cannot open $filename: $!");
my $script = do { local $/; <$fh> };

my $lexer  = Compiler::Lexer->new($filename);
my $tokens = $lexer->tokenize($script);
my $parser = Compiler::Parser->new();
my $ast = $parser->parse($tokens);


my $root = $ast->root;
    warn ref $root;
$root = bless $root, 'P2JS::Node::Class';
my $ret = $root->to_javascript;

print "\n\n";
print @$ret;
print "}\n";
