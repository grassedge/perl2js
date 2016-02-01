package P2JS::Converter::Node::Nop;

use strict;
use warnings;
use parent qw(P2JS::Converter::Node);

use P2JS::Node::Nop;

sub to_js_ast {
    return P2JS::Node::Nop->new;
}

1;
