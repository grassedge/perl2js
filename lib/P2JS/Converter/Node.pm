package P2JS::Converter::Node;

use strict;
use warnings;
use parent qw(Compiler::Parser::Node);

use P2JS::Converter::Node::ArrayRef;
use Data::Dumper;

sub new {
    my ($class, %args) = @_;
    return bless \%args, $class;
}

sub next {
    my ($self) = @_;
    return $self->{next} // P2JS::Converter::Node::Nop->new;
}

sub is_nop {
    my ($self) = @_;
    return $self->isa("P2JS::Converter::Node::Nop");
}

sub to_js_ast {
    my ($self) = @_;
    warn "not implemented: " . ref ($self);
    return undef;
}

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
    my ($self, $str) = @_;
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
    if (ref($branch) ne 'P2JS::Converter::Node::Branch') {
        return {
            new_root => $branch,
            most_left => undef
        }
    }
    my $most_left;
    my $shift; $shift = sub {
        my ($branch) = @_;
        if (ref($branch->left) eq 'P2JS::Converter::Node::Branch') {
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

# P2JS::Converter::Node::Block
# P2JS::Converter::Node::CodeDereference
# P2JS::Converter::Node::ControlStmt
# P2JS::Converter::Node::DoStmt
# P2JS::Converter::Node::ForStmt
# P2JS::Converter::Node::ForeachStmt
# P2JS::Converter::Node::Handle
# P2JS::Converter::Node::HandleRead
# P2JS::Converter::Node::Label
# P2JS::Converter::Node::RegReplace
# P2JS::Converter::Node::Regexp

my $skip_nodes = [];
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

        } elsif ($pkg eq 'P2JS::Converter::Node::Dereference') {
            my $name = $token->name;
            my $data = $token->data;
            my $trimmed = substr($data, 2);
            if ($name eq 'ShortArrayDereference') {
                push @sentence, $trimmed;
            } elsif ($name eq 'ShortHashDereference') {
                push @sentence, $trimmed;
            } else {
                push @sentence, cprint(ref($current) . ", " . $name . ": " . $data);
            }

        } elsif ($pkg eq 'P2JS::Converter::Node::FunctionCall') {
            my $function_name = $token->data;
            my $name = $token->name;
            my $args = $current->{args}->[0];
            if ($name eq 'BuiltinFunc') {
                if ($function_name eq 'pop')  {
                    # pop take just one parameter.
                    push @sentence, @{traverse($args, $context)};
                    push @sentence, '.';
                    $args = undef;
                } elsif ($function_name eq 'length')  {
                    # length take just one parameter.
                    push @sentence, @{traverse($args, $context)};
                    push @sentence, '.';
                    $args = undef;
                } elsif (
                    $function_name eq 'push' ||
                    $function_name eq 'splice'
                )  {
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
                        }, 'P2JS::Converter::Node::Leaf'),
                    }, 'P2JS::Converter::Node::Branch';
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
                    }, 'P2JS::Converter::Node::Function';

                } elsif (
                    $function_name eq 'join'
                )  {
                    if (ref ($args) eq 'P2JS::Converter::Node::List') {
                        $args = $args->{data};
                    }
                    my $ret = shift_comma_branch($args);
                    push @sentence, @{traverse($ret->{new_root}, $context)};
                    push @sentence, '.';
                    $args = $ret->{most_left};
                } else {
                    push @sentence, cprint(ref($current) . ", " . $name . ": " . $function_name);
                }
            }

        }
    }
}

1;
