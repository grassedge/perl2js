use strict;
use warnings;
use Compiler::Lexer;
use Data::Dumper;
use Compiler::Parser;
use Compiler::Parser::AST::Renderer;

my $filename = $ARGV[0];
open(my $fh, "<", $filename) or die("Cannot open $filename: $!");
my $script = do { local $/; <$fh> };

my $lexer  = Compiler::Lexer->new($filename);
my $tokens = $lexer->tokenize($script);




my $parser = Compiler::Parser->new();
my $ast = $parser->parse($tokens);
#warn Dumper $ast;
#Compiler::Parser::AST::Renderer->new->render($ast);

sub search {
    my ($node, $query) = @_;
    my $current = $node;
    while ($current) {
        my $success = 1;
        my $target = +{
            ref => ref($current),
            %{$current->token}
        };
        for my $key (keys %$query) {
            my $value = $query->{$key};
            if ($target->{$key} ne $value) {
                $success = 0;
            }
        }
        if ($success) {
            return $current;
        } else {
            my $body = $current->can('body') && $current->body;
            if ($body) {
                search($body, $query);
            }
            $current = $current->next;
        }
    }
}

sub cprint {
    my ($str) = @_;
    print "\033[32m" . $str . "\033[0m";
}

sub remove_node {
    my ($node) = @_;
    my $parent = $node->parent;
    next unless $parent;
    foreach my $branch (@{$parent->branches}, 'next') {
        my $child = $parent->{$branch};
        next unless ($child && $child == $node);
        $parent->{$branch} = $node->next;
    }
}

# Compiler::Parser::Node::Array
# Compiler::Parser::Node::ArrayRef
# Compiler::Parser::Node::Block
# Compiler::Parser::Node::Branch
# Compiler::Parser::Node::CodeDereference
# Compiler::Parser::Node::ControlStmt
# Compiler::Parser::Node::Dereference
# Compiler::Parser::Node::DoStmt
# Compiler::Parser::Node::ElseStmt
# Compiler::Parser::Node::ForStmt
# Compiler::Parser::Node::ForeachStmt
# Compiler::Parser::Node::Function
# Compiler::Parser::Node::FunctionCall
# Compiler::Parser::Node::Handle
# Compiler::Parser::Node::HandleRead
# Compiler::Parser::Node::Hash
# Compiler::Parser::Node::HashRef
# Compiler::Parser::Node::IfStmt
# Compiler::Parser::Node::Label
# Compiler::Parser::Node::Leaf
# Compiler::Parser::Node::List
# Compiler::Parser::Node::Module
# Compiler::Parser::Node::Package
# Compiler::Parser::Node::RegPrefix
# Compiler::Parser::Node::RegReplace
# Compiler::Parser::Node::Regexp
# Compiler::Parser::Node::Return
# Compiler::Parser::Node::SingleTermOperator
# Compiler::Parser::Node::ThreeTermOperator
# Compiler::Parser::Node::WhileStmt

my $INDENT = '    ';

my $skip_nodes = [];

sub traverse {
    my ($node) = @_;
    my $current = $node;
    while ($current) {
        my $pkg = ref($current);
        my $token = $current->token;
        my $depth = $current->indent;
        my $parent = $current->parent;

        if ($pkg eq '') {
        } elsif ($pkg eq 'Compiler::Parser::Node::Array') {
        } elsif ($pkg eq 'Compiler::Parser::Node::ArrayRef') {
            my $data_node = $current->data_node;
            print '[';
            traverse($data_node);
            print ']';
        # } elsif ($pkg eq 'Compiler::Parser::Node::Block') {
        } elsif ($pkg eq 'Compiler::Parser::Node::Branch') {
            my $left  = $current->left;
            my $right = $current->right;
            my $name = $token->name;
            my $data = $token->data;

            # if Assign branch is compiled as function parameters, skip this loop.
            my $skip = 0;

            if ($token->name eq 'Comma') {
                $data = $token->data . " ";
            } elsif ($token->name eq 'AlphabetOr') {
                $data = " || ";
            } elsif ($token->name eq 'Arrow') {
                $data = ' : ';
            } elsif ($token->name eq 'Assign') {
                for my $skip_node (@$skip_nodes) {
                    if ($current->left == $skip_node) {
                        $skip = 1;
                    }
                }
                $data = " " . $token->data . " ";
            } elsif ($token->name eq 'Pointer') {
                if (ref($right) eq 'Compiler::Parser::Node::FunctionCall' &&
                    $right->token->data eq 'new') {
                    $data = 'new';
                } else {
                    $data = ".";
                }
            } elsif ($token->name eq 'StringEqual') {
                $data = " === ";
            } else {
                cprint(ref($current) . ", " . $name . ": " . $data . "\n");
            }

            if ($skip) {
            } elsif ($data eq 'new') {
                print $data . ' ';
                traverse($left);
                print '(';
                my $args = $right->{args}->[0];
                traverse($right->{args}->[0]);
                print ")";
            } else {
                traverse($left);
                print $data;
                traverse($right);
            }

        # } elsif ($pkg eq 'Compiler::Parser::Node::CodeDereference') {
        # } elsif ($pkg eq 'Compiler::Parser::Node::ControlStmt') {
        } elsif ($pkg eq 'Compiler::Parser::Node::Dereference') {
            my $name = $token->name;
            my $data = $token->data;
            my $trimmed = substr($data, 2);
            # if ($name eq 'ArrayDereference') {
            if ($name eq 'HashDereference') {
                traverse($current->expr);
            } elsif ($name eq 'ShortArrayDereference') {
                my $trimmed = substr($data, 2);
                print "...${trimmed}";
            } elsif ($name eq 'ShortHashDereference') {
                print $trimmed;
            } else {
                cprint(ref($current) . ", " . $name . ": " . $data . "\n");
            }
            # print Dumper $current->expr;
        # } elsif ($pkg eq 'Compiler::Parser::Node::DoStmt') {
        # } elsif ($pkg eq 'Compiler::Parser::Node::ElseStmt') {
        # } elsif ($pkg eq 'Compiler::Parser::Node::ForStmt') {
        # } elsif ($pkg eq 'Compiler::Parser::Node::ForeachStmt') {
        } elsif ($pkg eq 'Compiler::Parser::Node::Function') {
            my $body = $current->body;
            my $function_name = $token->data;

            # parameter detection
            # TODO: shift operator, multiple assignment.
            my $parameters;
            if ($body) {
                my $assign = search($body, {
                    ref => 'Compiler::Parser::Node::Branch',
                    name => 'Assign'
                });
                if ($assign && $assign->right->token->name eq 'ArgumentArray') {
                    $parameters = $assign->left;
                    push(@$skip_nodes, $parameters);
                }
            }
            print "function ${function_name}(";
            traverse($parameters);
            print ") {";
            if ($body) {
                print "\n";
                print $INDENT x ($depth + 1);
                traverse($body);
            }
            print "\n";
            print $INDENT x ($depth);
            print "}";

        } elsif ($pkg eq 'Compiler::Parser::Node::FunctionCall') {
            my $function_name = $token->data;
            my $name = $token->name;
            my $args = $current->{args}->[0];
            if ($name eq 'BuiltinFunc') {
                if ($function_name eq 'print') { $function_name = 'console.log'; }
                if ($function_name eq 'warn')  { $function_name = 'console.warn'; }
                if ($function_name eq 'ref')  { $function_name = 'typeof'; }
                # if ($function_name ~~ ['pop', 'push'])  {
                #     my $obj = $args;
                #     $args = delete $args->{next};
                #     traverse($obj);
                #     print ".";
                # }
            }
            print "$function_name(";
            traverse($args);
            print ")";

        # } elsif ($pkg eq 'Compiler::Parser::Node::Handle') {
        # } elsif ($pkg eq 'Compiler::Parser::Node::HandleRead') {
        # } elsif ($pkg eq 'Compiler::Parser::Node::Hash') {
        } elsif ($pkg eq 'Compiler::Parser::Node::HashRef') {
            my $data_node = $current->data_node;
            print '{';
            traverse($data_node);
            print '}';
        } elsif ($pkg eq 'Compiler::Parser::Node::IfStmt') {
            my $true_stmt = $current->true_stmt;
            my $expr = $current->expr;

            print "if (";
            traverse($expr);
            print ") {\n";
            print $INDENT x ($depth + 1);

            traverse($true_stmt);

            print ";\n";
            print $INDENT x $depth;
            print "}";
        # } elsif ($pkg eq 'Compiler::Parser::Node::Label') {
        } elsif ($pkg eq 'Compiler::Parser::Node::Leaf') {
            my $name = $token->name;
            my $data = $token->data;
            if ($name eq 'Int') {
                print $data;
            } elsif ($name eq 'ArgumentArray') {
                print "arguments";
            } elsif ($name eq 'LocalVar') {
                print "var " . substr($data, 1);
            } elsif ($name eq 'GlobalVar') {
                print substr($data, 1);
            } elsif ($name eq 'GlobalHashVar') {
                print substr($data, 1);
            } elsif ($name eq 'Key') {
                print '"' . $data . '"';
            } elsif ($name eq 'Var') {
                # if ($data eq '$self') {
                #     print "this\n";
                # } else {
                # }
                    print substr($data, 1);
            } elsif ($name eq 'String') {
                print '"' . $data . '"';
            } elsif ($name eq 'RawString') {
                print "'" . $data . "'";
            } else {
                cprint(ref($current) . ", " . $name . ": " . $data . "\n");
            }

        } elsif ($pkg eq 'Compiler::Parser::Node::List') {
            my $data = $current->data_node;
            traverse($data);

        } elsif ($pkg eq 'Compiler::Parser::Node::Module') {
            my $module_name = $token->data;
            if ($module_name ~~ ['strict', 'warnings']) { }
            elsif ($module_name eq 'constant') {
                cprint 'TODO'
            }
            elsif ($module_name ~~ ['base', 'parent']) {
                my $base_name = $current->args->expr->token->data;
                my $path = $base_name;
                $path =~ s/::/\//g;
                $base_name =~ s/.+:://g;
                print "import { ${base_name} } from '${path}'";
            } else {
                my $path = $module_name;
                $path =~ s/::/\//;
                print "import { ${module_name} } from '${path}'\n";
            }

        } elsif ($pkg eq 'Compiler::Parser::Node::Package') {
            my $class_name = $token->data;
            $class_name =~ s/.+:://g;
            # TODO: support Mixin.
            my ($base) = grep {
                $_->data ~~ ['base', 'parent']
            } @{$current->find(node => 'Module')};
            if ($base) {
                my $base_name = $base->args->expr->token->data;
                $base_name =~ s/.+:://g;
                print "class ${class_name} extends ${base_name} {\n";
            } else {
                print "class ${class_name} {\n";
            }
        # } elsif ($pkg eq 'Compiler::Parser::Node::RegPrefix') {
        # } elsif ($pkg eq 'Compiler::Parser::Node::RegReplace') {
        # } elsif ($pkg eq 'Compiler::Parser::Node::Regexp') {
        } elsif ($pkg eq 'Compiler::Parser::Node::Return') {
            my $body = $current->body;
            print 'return ';
            traverse($body);
        # } elsif ($pkg eq 'Compiler::Parser::Node::SingleTermOperator') {
        # } elsif ($pkg eq 'Compiler::Parser::Node::ThreeTermOperator') {
        # } elsif ($pkg eq 'Compiler::Parser::Node::WhileStmt') {
        } else {
            print "\n";
            print $INDENT x $depth;
            cprint(ref($current) . ", " . $current->token->data);
            print "\n";
        }

        my $next = $current->next;
        if ($next) {
            print ";\n";
            print $INDENT x $depth;
        }
        $current = $next;
    }
}

print "\n\n";
# print Dumper $ast;
traverse($ast->root);
print "}\n";
