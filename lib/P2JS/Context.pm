package P2JS::Context;

sub new {
    my ($class, %args) = @_;
    $args{imports} //= [];
    $args{classes} //= [];
    return bless \%args, $class;
}

sub clone {
    my ($self, $current) = @_;
    my $class = ref($self);
    return bless({
        %$self,
        current => $current,
    }, $class);
}

####

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
    my ($self) = @_;
    return $self->classes->[-1];
}

####

sub push_sentence {
    my ($self, $sentence) = @_;
    $self->current->push_sentence($sentence);
}

sub root {
    my ($self, $root) = @_;
    if ($root) {
        $self->{root} = $root;
        $self->current($root);
    } else {
        return $self->{root};
    }
}

sub current {
    my ($self, $current) = @_;
    if ($current) {
        $self->{current} = $current;
    } else {
        return $self->{current};
    }
}

1;
