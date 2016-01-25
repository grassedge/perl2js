package P2JS::Converter::Node::Leaf;
use strict;
use warnings;
use parent 'P2JS::Converter::Node';

use P2JS::Converter::Node::Nop;
# use P2JS::Node::Leaf;

# sub to_js_ast {
#     my ($self, $context) = @_;
#     return P2JS::Node::Branch->new(
#         token => $self->token,
#         left  => $self->left->to_js_ast,
#         right => $self->right->to_js_ast,
#     );
# }

1;
