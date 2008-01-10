package Senna::Ctx::Info;
use strict;
use warnings;
use base qw(Class::Accessor::Fast);

__PACKAGE__->mk_accessors(qw/fd com_status com_info/);

sub _new {
    my $class = shift;
    my %args;
    @args{qw(fd com_status com_info)} = @_;
    $class->SUPER::new( \%args );
}

1;
__END__

=head1 NAME

Senna::Ctx::Info - Abstraction For Values Returned From sen_ctx_info_get()

=head1 SYNOPSIS

  use Senna;
  my $ctx  = Senna::Ctx->open({ db => $db });
  my $info = $ctx->info_get;

=head1 METHODS

=head2 fd

=head2 com_status

=head2 com_info

=cut
