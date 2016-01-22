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
    # print "\033[32m /* " . $str . " */ \033[0m";
    return "\033[32m /* " . $str . " */ \033[0m";
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
    my ($node, $context) = @_;
    my $current = $node;
    my @block;
    while ($current) {
        my @sentence = ();
        my $pkg = ref($current);
        my $token = $current->token;
        my $depth = $current->indent;
        my $parent = $current->parent;

        if ($pkg eq '') {
        } elsif ($pkg eq 'Compiler::Parser::Node::Array') {
            my $idx = $current->idx;
            my $name = substr($token->data, 1);
            if ($name eq '_') {
                if ($idx == 0) {
                    push @sentence, 'this';
                } else {
                    push @sentence, 'arguments';
                    push @sentence, @{traverse($idx, $context)};
                }
            } else {
                push @sentence, $name;
                push @sentence, @{traverse($idx, $context)};
            }
        } elsif ($pkg eq 'Compiler::Parser::Node::ArrayRef') {
            my $data_node = $current->data_node;
            push @sentence, '[';
            push @sentence, @{traverse($data_node, $context)};
            push @sentence, ']';
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
            } elsif ($name eq 'GreaterEqual') {
                $data = " >= ";
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
                    push @sentence, @{traverse($left, $context)};
                    push @sentence, '[';
                    push @sentence, @{traverse($data_node, $context)};
                    push @sentence, ']';
                } else {
                    $data = ".";
                }
            } elsif ($token->name eq 'StringEqual') {
                $data = " === ";
            } elsif ($token->name eq 'StringAdd') {
                $data = " + ";
            } elsif ($token->name eq 'StringAddEqual') {
                $data = " = " . traverse($left, $context)->[0] . " + ";
            } else {
                push @sentence, cprint(ref($current) . ", " . $name . ": " . $data);
            }

            if ($skip) {
            } elsif ($data eq 'new') {
                push @sentence, $data . ' ';
                push @sentence, @{traverse($left, $context)};
                push @sentence, '(';
                my $args = $right->{args}->[0];
                push @sentence, @{traverse($right->{args}->[0], $context)};
                push @sentence, ")";
            } else {
                push @sentence, @{traverse($left, $context)};
                push @sentence, $data;
                push @sentence, @{traverse($right, $context)};
            }

        # } elsif ($pkg eq 'Compiler::Parser::Node::CodeDereference') {
        # } elsif ($pkg eq 'Compiler::Parser::Node::ControlStmt') {
        } elsif ($pkg eq 'Compiler::Parser::Node::Dereference') {
            my $name = $token->name;
            my $data = $token->data;
            my $trimmed = substr($data, 2);
            if ($name eq 'ArrayDereference') {
                push @sentence, @{traverse($current->expr, $context)};
            } elsif ($name eq 'HashDereference') {
                push @sentence, @{traverse($current->expr, $context)};
            } elsif ($name eq 'ShortArrayDereference') {
                push @sentence, $trimmed;
            } elsif ($name eq 'ShortHashDereference') {
                push @sentence, $trimmed;
            } else {
                push @sentence, cprint(ref($current) . ", " . $name . ": " . $data);
            }
        # } elsif ($pkg eq 'Compiler::Parser::Node::DoStmt') {
        } elsif ($pkg eq 'Compiler::Parser::Node::ElseStmt') {
            push @sentence, "e {\n";
            push @sentence, $INDENT x ($depth + 1);
            push @sentence, @{traverse($current->stmt, $context)};
            push @sentence, ";\n";
            push @sentence, $INDENT x $depth;
            push @sentence, "}";
        # } elsif ($pkg eq 'Compiler::Parser::Node::ForStmt') {
        # } elsif ($pkg eq 'Compiler::Parser::Node::ForeachStmt') {
        } elsif ($pkg eq 'Compiler::Parser::Node::Function') {
            my $body = $current->body;
            my $function_name = $token->data;
            my $code_ref = $token->name ne 'Function';

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
            if ($code_ref) {
                push @sentence, "(";
            } else {
                if ($method eq 'instance') {
                    push @sentence, "${function_name}(";
                } elsif ($method eq 'class') {
                    push @sentence, "static ${function_name}(";
                } else {
                    push @sentence, "static ${function_name}(";
                }
            }
            push @sentence, @{traverse($parameters, $context)};
            if ($code_ref) {
                push @sentence, ") => {";
            } else {
                push @sentence, ") {";
            }
            if ($body) {
                push @sentence, "\n";
                push @sentence, $INDENT x ($depth + 1);
                push @sentence, @{traverse($body, $context)};
            }
            push @sentence, "\n";
            push @sentence, $INDENT x ($depth);
            push @sentence, "}";

        } elsif ($pkg eq 'Compiler::Parser::Node::FunctionCall') {
            my $function_name = $token->data;
            my $name = $token->name;
            my $args = $current->{args}->[0];
            if ($name eq 'BuiltinFunc') {
                if ($function_name eq 'push @sentence,') { $function_name = 'console.log'; }
                elsif ($function_name eq 'warn')  { $function_name = 'console.warn'; }
                elsif ($function_name eq 'ref')  { $function_name = 'typeof'; }
                elsif ($function_name eq 'pop')  {
                    # pop take just one parameter.
                    push @sentence, @{traverse($args, $context)};
                    push @sentence, '.';
                    $args = undef;
                } elsif ($function_name eq 'push')  {
                    # 'push' take at least two parameters.
                    # so $args is Node::Branch / Comma.
                    my $ret = shift_comma_branch($args);
                    $args = $ret->{new_root};
                    push @sentence, @{traverse($ret->{most_left}, $context)};
                    push @sentence, '.';
                } elsif ($function_name eq 'bless')  {
                    # 'push' take just two parameters.
                    my $left = $args->left;
                    my $right = $args->right;
                    $args->{left} = bless +{
                        token => bless({
                            name => 'Pointer'
                        }, 'Compiler::Lexer::Token'),
                        left => $right,
                        right => bless({
                            token => bless({
                                name => 'Var',
                                data => '$prototype'
                            }, 'Compiler::Lexer::Token'),
                        }, 'Compiler::Parser::Node::Leaf'),
                    }, 'Compiler::Parser::Node::Branch';
                    $args->{right} = $left;
                    $function_name = 'Object.create'
                } elsif ($function_name eq 'map')  {
                    my $list = $current->{args}->[1];
                    push @sentence, @{traverse($list, $context)};
                    push @sentence, '.';

                    $args = bless +{
                        body => $args,
                        token => bless {
                            name => '',
                        }, 'Compiler::Lexer::Token',
                    }, 'Compiler::Parser::Node::Function';

                # } elsif ($function_name eq 'join')  {
                #     my $ret = shift_comma_branch($args);
                #     my $separater = $ret->{most_left};
                #     $args = $separater;
                #     if (!$separater) {
                #         warn "iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii";
                #     }
                #     push @sentence, Dumper $separater && $separater->token;
                # #     my $args = $ret->{most_left}; # separater.

                # #     if ($ret->{new_root}) {
                # #         push @sentence, @{traverse($ret->{new_root}, $context)};
                # #     } else {
                # #         push @sentence, '[].'
                # #     }
                } else {
                    push @sentence, cprint(ref($current) . ", " . $name . ": " . $function_name);
                }
            }
            push @sentence, "$function_name(";
            push @sentence, @{traverse($args, $context)};
            push @sentence, ")";

        # } elsif ($pkg eq 'Compiler::Parser::Node::Handle') {
        # } elsif ($pkg eq 'Compiler::Parser::Node::HandleRead') {
        } elsif ($pkg eq 'Compiler::Parser::Node::Hash') {
            my $key = $current->key;
            my $name = substr($token->data, 1);
            if ($name eq 'ENV') {
                push @sentence, 'process.env';
            } else {
                push @sentence, $name;
            }
            push @sentence, '[';
            push @sentence, @{traverse($key && $key->data_node, $context)};
            push @sentence, ']';

        } elsif ($pkg eq 'Compiler::Parser::Node::HashRef') {
            my $data_node = $current->data_node;
            push @sentence, '{';
            push @sentence, @{traverse($data_node, $context)};
            push @sentence, '}';
        } elsif ($pkg eq 'Compiler::Parser::Node::IfStmt') {
            my $true_stmt = $current->true_stmt;
            my $false_stmt = $current->false_stmt;
            my $expr = $current->expr;
            my $data = $token->data;

            if ($data eq 'unless') {
                push @sentence, "if (!(";
            } else {
                push @sentence, "if (";
            }
            push @sentence, @{traverse($expr, $context)};
            if ($data eq 'unless') {
                push @sentence, ")) {\n";
            } else {
                push @sentence, ") {\n";
            }
            push @sentence, $INDENT x ($depth + 1);

            push @sentence, @{traverse($true_stmt, $context)};

            push @sentence, ";\n";
            push @sentence, $INDENT x $depth;
            push @sentence, "}";
            if ($false_stmt) {
                push @sentence, " els";

                push @sentence, @{traverse($false_stmt, $context)};
            }
        # } elsif ($pkg eq 'Compiler::Parser::Node::Label') {
        } elsif ($pkg eq 'Compiler::Parser::Node::Leaf') {
            my $name = $token->name;
            my $data = $token->data;
            if ($name eq 'Int') {
                push @sentence, $data;
            } elsif ($name eq 'Default') {
                if ($data eq 'undef') {
                    push @sentence, 'undefined';
                } else {
                    push @sentence, cprint(ref($current) . ", " . $name . ": " . $data);
                }
            } elsif ($name eq 'ArgumentArray') {
                push @sentence, "arguments";
            } elsif ($name eq 'LocalVar') {
                push @sentence, "var " . substr($data, 1);
            } elsif ($name eq 'LocalArrayVar') {
                push @sentence, "var " . substr($data, 1);
            } elsif ($name eq 'LocalHashVar') {
                push @sentence, "var " . substr($data, 1);
            } elsif ($name eq 'GlobalVar') {
                push @sentence, substr($data, 1);
            } elsif ($name eq 'GlobalHashVar') {
                push @sentence, substr($data, 1);
            } elsif ($name eq 'Key') {
                push @sentence, '"' . $data . '"';
                # push @sentence, $data;
            } elsif ($name eq 'Namespace') {
                $data =~ s/.+:://;
                push @sentence, $data;
            } elsif ($name eq 'HashVar') {
                push @sentence, substr($data, 1);
            } elsif ($name eq 'ArrayVar') {
                push @sentence, substr($data, 1);
            } elsif ($name eq 'RegExp') {
                my $data = $current->data;
                push @sentence, $data;
            } elsif ($name eq 'Var') {
                if ($data eq '$self') {
                    push @sentence, "this";
                } elsif ($data eq '$class') {
                    push @sentence, $current_class;
                } else {
                    push @sentence, substr($data, 1);
                }
            } elsif ($name eq 'SpecificKeyword') {
                if ($data eq '__PACKAGE__') {
                    push @sentence, $current_class;
                } else {
                    push @sentence, cprint(ref($current) . ", " . $name . ": " . $data);
                }
            } elsif ($name eq 'SpecificValue') {
                if ($data eq '$_') {
                    push @sentence, $data;
                } else {
                    push @sentence, cprint(ref($current) . ", " . $name . ": " . $data);
                }
            } elsif ($name eq 'String') {
                push @sentence, '"' . $data . '"';
            } elsif ($name eq 'RawString') {
                push @sentence, "'" . $data . "'";
            } else {
                push @sentence, cprint(ref($current) . ", " . $name . ": " . $data);
            }

        } elsif ($pkg eq 'Compiler::Parser::Node::List') {
            my $data = $current->data_node;
            push @sentence, @{traverse($data, $context)};

        } elsif ($pkg eq 'Compiler::Parser::Node::Module') {
            my $module_name = $token->data;
            if ($module_name ~~ ['strict', 'warnings', 'utf8']) { }
            elsif ($module_name eq 'constant') {
                push @sentence, cprint 'TODO. "use constant" to const';
            }
            elsif ($module_name ~~ ['base', 'parent']) {
                my $base_name = $current->args->expr->token->data;
                my $path = $base_name;
                $path =~ s/::/\//g;
                $base_name =~ s/.+:://g;
                push @{$context->{imports}}, "import { ${base_name} } from '${path}'";
            } else {
                my $path = $module_name;
                $path =~ s/::/\//g;
                $module_name =~ s/.+:://g;
                push @{$context->{imports}}, "import { ${module_name} } from '${path}'";
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
                push @sentence, "class ${class_name} extends ${base_name} {\n";
            } else {
                push @sentence, "class ${class_name} {\n";
            }
            $current_class = $class_name;
            $current_package = $class_name;

        } elsif ($pkg eq 'Compiler::Parser::Node::RegPrefix') {
            my $name = $token->name;
            if ($name eq 'RegQuote') {
                push @sentence, "'";
                push @sentence, @{traverse($current->expr, $context)};
                push @sentence, "'";
            } else {
                push @sentence, cprint(ref($current) . ", " . $current->token->data);
            }
        # } elsif ($pkg eq 'Compiler::Parser::Node::RegReplace') {
        # } elsif ($pkg eq 'Compiler::Parser::Node::Regexp') {
        } elsif ($pkg eq 'Compiler::Parser::Node::Return') {
            my $body = $current->body;
            push @sentence, 'return ';
            push @sentence, @{traverse($body, $context)};
        } elsif ($pkg eq 'Compiler::Parser::Node::SingleTermOperator') {
            push @sentence, $token->data;
            push @sentence, @{traverse($current->expr, $context)};

        } elsif ($pkg eq 'Compiler::Parser::Node::ThreeTermOperator') {
            my $cond = $current->cond;
            my $true_expr = $current->true_expr;
            my $false_expr = $current->false_expr;
            push @sentence, @{traverse($cond, $context)};
            push @sentence, ' ? ';
            push @sentence, @{traverse($true_expr, $context)};
            push @sentence, ' : ';
            push @sentence, @{traverse($false_expr, $context)};
        } elsif ($pkg eq 'Compiler::Parser::Node::WhileStmt') {
            my $true_stmt = $current->true_stmt;
            my $expr = $current->expr;
            my $data = $token->data;
            if ($data eq 'until') {
                push @sentence, "while (!(";
            } else {
                push @sentence, "while (";
            }
            push @sentence, @{traverse($expr, $context)};
            if ($data eq 'until') {
                push @sentence, ")) {\n";
            } else {
                push @sentence, ") {\n";
            }
            push @sentence, $INDENT x ($depth + 1);

            push @sentence, @{traverse($true_stmt, $context)};

            push @sentence, ";\n";
            push @sentence, $INDENT x $depth;
            push @sentence, "}";
        } else {
            push @sentence, "\n";
            push @sentence, $INDENT x $depth;
            push @sentence, cprint(ref($current) . ", " . $current->token->data);
            push @sentence, "\n";
        }

        my $next = $current->next;
        if ($next && scalar @sentence) {
            push @sentence, ";\n";
            push @sentence, $INDENT x $depth;
        }
        push @block, @sentence;
        $current = $next;
    }
    return \@block;
}

print "\n\n";
# print Dumper $ast;
my $context = {
    imports => []
};

my $ret = traverse($ast->root, $context);
print join ";\n", @{$context->{imports}};
print "\n\n";
print @$ret;
print "}\n";
