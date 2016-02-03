package P2JS::Converter::Node::BlockStmt;

use strict;
use warnings;

use parent 'P2JS::Converter::Node';

sub new {
    my ($class, %args) = @_;
    $args{statements} ||= [];
    return bless \%args, $class;
}

sub statements {
    my ($self, $statements) = @_;
    if ($statements) {
        $self->{statements} = $statements;
    } else {
        return $self->{statements};
    }
}

sub push_statement {
    my ($self, $statement) = @_;
    push @{$self->{statements}}, $statement;
}

1;
