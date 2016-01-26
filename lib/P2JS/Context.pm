package P2JS::Context;

sub new {
    my ($class, %args) = @_;
    $args{imports} //= [];
    $args{classes} //= [];
    return bless \%args, $class;
}

sub imports {
    my ($self) = @_;
    return $self->{imports};
}

sub push_import {
    my ($self, $import) = @_;
    push @{$self->{imports}}, $import;
}

sub classes {
    my ($self) = @_;
    return $self->{classes};
}

sub push_class {
    my ($self, $class) = @_;
    push @{$self->{classes}}, $class;
}

sub current_class {
    
}

1;
