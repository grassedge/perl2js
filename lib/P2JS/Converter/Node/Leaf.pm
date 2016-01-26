package P2JS::Converter::Node::Leaf;
use strict;
use warnings;
use parent 'P2JS::Converter::Node';

use P2JS::Node::Leaf;

sub to_js_ast {
    my ($self, $context) = @_;
    my $token = $self->token;
    my $name = $token->name;
    my $data = $token->data;

    my $current_class = '';
    if ($context->classes->[-1]) {
        $current_class = $context->classes->[-1]->token->data;
    }

    if ($name eq 'Int') {
        $token->{data} = $data;
    } elsif ($name eq 'Default') {
        if ($data eq 'undef') {
            $token->{data} = 'undefined';
        } else {
            $token->{data} = $self->cprint(ref($self) . ", " . $name . ": " . $data);
        }
    } elsif ($name eq 'ArgumentArray') {
        $token->{data} = "arguments";
    } elsif ($name eq 'LocalVar') {
        $token->{data} = "var " . substr($data, 1);
    } elsif ($name eq 'LocalArrayVar') {
        $token->{data} = "var " . substr($data, 1);
    } elsif ($name eq 'LocalHashVar') {
        $token->{data} = "var " . substr($data, 1);
    } elsif ($name eq 'GlobalVar') {
        $token->{data} = substr($data, 1);
    } elsif ($name eq 'GlobalHashVar') {
        $token->{data} = substr($data, 1);
    } elsif ($name eq 'Key') {
        $token->{data} = '"' . $data . '"';
    } elsif ($name eq 'Namespace') {
        $data =~ s/.+:://;
        $token->{data} = $data;
    } elsif ($name eq 'HashVar') {
        $token->{data} = substr($data, 1);
    } elsif ($name eq 'ArrayVar') {
        $token->{data} = substr($data, 1);
    } elsif ($name eq 'RegExp') {
        my $data = $self->data;
        $token->{data} = $data;
    } elsif ($name eq 'Var') {
        if ($data eq '$self') {
            $token->{data} = "this";
        } elsif ($data eq '$class') {
            $token->{data} = $current_class;
        } else {
            $token->{data} = substr($data, 1);
        }
    } elsif ($name eq 'SpecificKeyword') {
        if ($data eq '__PACKAGE__') {
            $token->{data} = $current_class;
        } else {
            $token->{data} = $self->cprint(ref($self) . ", " . $name . ": " . $data);
        }
    } elsif ($name eq 'SpecificValue') {
        if ($data eq '$_') {
            $token->{data} = $data;
        } else {
            $token->{data} = $self->cprint(ref($self) . ", " . $name . ": " . $data);
        }
    } elsif ($name eq 'String') {
        $token->{data} = '"' . $data . '"';
    } elsif ($name eq 'RawString') {
        $token->{data} = "'" . $data . "'";
    } else {
        $token->{data} = $self->cprint(ref($self) . ", " . $name . ": " . $data);
    }

    return P2JS::Node::Leaf->new(
        token => $self->token,
    );
}

1;
