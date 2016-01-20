use strict;
use warnings;
use Compiler::Lexer;
use Data::Dumper;
use Compiler::Parser;
use Compiler::Parser::AST::Renderer;

use Compiler::Parser::Node::ArrayRef;

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
    print "\033[32m /* " . $str . " */ \033[0m";
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

sub shift_comma_branch {
    my ($branch) = @_; # Node::Branch / Comma
    if (ref($branch) ne 'Compiler::Parser::Node::Branch') {
        return {
            new_root => $branch,
            most_left => undef
        }
    }
    my $most_left;
    my $shift; $shift = sub {
        my ($branch) = @_;
        if (ref($branch->left) eq 'Compiler::Parser::Node::Branch') {
            my $new_left = $shift->($branch->left);
            if ($new_left) {
                $branch->{left} = $new_left;
            }
            return;
        } else {
            $most_left = $branch->left;
            return $branch->right;
        }
    };
    # return new root node too.
    return {
        new_root => $shift->($branch) || $branch,
        most_left => $most_left
    };
}

my $INDENT = '    ';

my $skip_nodes = [];
my $current_package = '';
my $current_class = '';

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
            my $idx = $current->idx;
            my $name = substr($token->data, 1);
            if ($name eq '_') {
                print 'arguments';
            } else {
                print $name;
            }
            traverse($idx);
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
            } elsif ($token->name eq 'And') {
                $data = " && ";
            } elsif ($token->name eq 'Arrow') {
                $data = ' : ';
            } elsif ($token->name eq 'Assign') {
                for my $skip_node (@$skip_nodes) {
                    if ($left == $skip_node) {
                        $skip = 1;
                    }
                }
                if ($left->token->name eq 'LocalHashVar' &&
                    ref($right) eq 'Compiler::Parser::Node::List'
                    ) {
                    my $arrayref = bless +{
                        data => $right,
                        indent => $right->indent
                    }, 'Compiler::Parser::Node::HashRef';
                    $right->{parent} = $arrayref;
                    $right = $arrayref;
                }
                if ($left->token->name eq 'LocalArrayVar' &&
                    ref($right) eq 'Compiler::Parser::Node::List'
                    ) {
                    my $arrayref = bless +{
                        data => $right,
                        indent => $right->indent
                    }, 'Compiler::Parser::Node::ArrayRef';
                    $right->{parent} = $arrayref;
                    $right = $arrayref;
                }
                $data = " " . $token->data . " ";
            } elsif ($name eq 'EqualEqual') {
                $data = " == ";
            } elsif ($token->name eq 'Or') {
                $data = " || ";
            } elsif ($token->name eq 'Pointer') {
                if (ref($right) eq 'Compiler::Parser::Node::FunctionCall' &&
                    $right->token->data eq 'new') {
                    $data = 'new';
                } elsif (ref($right) eq 'Compiler::Parser::Node::ArrayRef') {
                    $data = "";
                } elsif (ref($right) eq 'Compiler::Parser::Node::HashRef') {
                    my $data_node = $right->data_node;
                    $skip = 1;
                    traverse($left);
                    print '[';
                    traverse($data_node);
                    print ']';
                } else {
                    $data = ".";
                }
            } elsif ($token->name eq 'StringEqual') {
                $data = " === ";
            } elsif ($token->name eq 'StringAdd') {
                $data = " + ";
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
            if ($name eq 'ArrayDereference') {
                traverse($current->expr);
            } elsif ($name eq 'HashDereference') {
                traverse($current->expr);
            } elsif ($name eq 'ShortArrayDereference') {
                print $trimmed;
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
            my $method = '';
            if ($body) {
                my $assign = search($body, {
                    ref => 'Compiler::Parser::Node::Branch',
                    name => 'Assign'
                });
                if ($assign &&
                    $assign->right->token->name eq 'ArgumentArray' &&
                    ref($assign->left) eq 'Compiler::Parser::Node::List') {
                    $parameters = $assign->left; # Node::List

                    push(@$skip_nodes, $parameters);

                    my $comma = $parameters->data_node; # Node::Branch / Comma
                    my $parent_comma = $comma;
                    my $most_left;
                    if (ref($parent_comma) ne 'Compiler::Parser::Node::Branch') {
                        $most_left = $parent_comma;
                    } else {
                        while (ref($parent_comma->left) eq 'Compiler::Parser::Node::Branch') {
                            $parent_comma = $parent_comma->left;
                        }
                        $most_left = $parent_comma->left;
                    }

                    if ($most_left->token->data eq '$self') {
                        $parameters->{data} =
                            shift_comma_branch($parameters->data_node)->{new_root};
                        $method = 'instance';
                    }
                    if ($most_left->token->data eq '$class') {
                        $parameters->{data} =
                            shift_comma_branch($parameters->data_node)->{new_root};
                        $method = 'class';
                    }
                }
            }
            if ($method eq 'instance') {
                print "${function_name}(";
            } elsif ($method eq 'class') {
                print "static ${function_name}(";
            } else {
                print "function ${function_name}(";
            }
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
                if ($function_name eq 'pop')  {
                    # pop take just one parameter.
                    traverse($args);
                    print '.';
                    $args = undef;
                }
                if ($function_name eq 'push')  {
                    # 'push' take at least two parameter.
                    # so $args is Node::Branch / Comma.
                    my $ret = shift_comma_branch($args);
                    $args = $ret->{new_root};
                    traverse($ret->{most_left});
                    print '.';
                }
            }
            print "$function_name(";
            traverse($args);
            print ")";

        # } elsif ($pkg eq 'Compiler::Parser::Node::Handle') {
        # } elsif ($pkg eq 'Compiler::Parser::Node::HandleRead') {
        # } elsif ($pkg eq 'Compiler::Parser::Node::Hash') {
            
        } elsif ($pkg eq 'Compiler::Parser::Node::HashRef') {
            # hash ref literal
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
            } elsif ($name eq 'LocalArrayVar') {
                print "var " . substr($data, 1);
            } elsif ($name eq 'LocalHashVar') {
                print "var " . substr($data, 1);
            } elsif ($name eq 'GlobalVar') {
                print substr($data, 1);
            } elsif ($name eq 'GlobalHashVar') {
                print substr($data, 1);
            } elsif ($name eq 'Key') {
                print '"' . $data . '"';
            } elsif ($name eq 'HashVar') {
                print substr($data, 1);
            } elsif ($name eq 'ArrayVar') {
                print substr($data, 1);
            } elsif ($name eq 'Var') {
                if ($data eq '$self') {
                    print "this";
                } elsif ($data eq '$class') {
                    print $current_class;
                } else {
                    print substr($data, 1);
                }
            } elsif ($name eq 'SpecificKeyword') {
                if ($data eq '__PACKAGE__') {
                    print $current_class;
                } else {
                    cprint(ref($current) . ", " . $name . ": " . $data . "\n");
                }
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
            if ($module_name ~~ ['strict', 'warnings', 'utf8']) { }
            elsif ($module_name eq 'constant') {
                cprint 'TODO. "use constant" to const';
            }
            elsif ($module_name ~~ ['base', 'parent']) {
                my $base_name = $current->args->expr->token->data;
                my $path = $base_name;
                $path =~ s/::/\//g;
                $base_name =~ s/.+:://g;
                print "import { ${base_name} } from '${path}'";
            } else {
                my $path = $module_name;
                $path =~ s/::/\//g;
                $module_name =~ s/.+:://g;
                print "import { ${module_name} } from '${path}'";
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
            $current_class = $class_name;
            $current_package = $class_name;

        # } elsif ($pkg eq 'Compiler::Parser::Node::RegPrefix') {
        # } elsif ($pkg eq 'Compiler::Parser::Node::RegReplace') {
        # } elsif ($pkg eq 'Compiler::Parser::Node::Regexp') {
        } elsif ($pkg eq 'Compiler::Parser::Node::Return') {
            my $body = $current->body;
            print 'return ';
            traverse($body);
        } elsif ($pkg eq 'Compiler::Parser::Node::SingleTermOperator') {
            print $token->data;
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
