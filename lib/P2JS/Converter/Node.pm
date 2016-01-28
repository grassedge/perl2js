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
# P2JS::Converter::Node::DoStmt
# P2JS::Converter::Node::Handle
# P2JS::Converter::Node::HandleRead
# P2JS::Converter::Node::Label
# P2JS::Converter::Node::RegReplace
# P2JS::Converter::Node::Regexp

1;
