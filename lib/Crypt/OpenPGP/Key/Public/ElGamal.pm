# $Id: ElGamal.pm,v 1.4 2001/07/26 02:33:41 btrott Exp $

package Crypt::OpenPGP::Key::Public::ElGamal;
use strict;

use Crypt::OpenPGP::Util qw( bitsize);
use Crypt::OpenPGP::Key::Public;
use Crypt::OpenPGP::ErrorHandler;
use base qw( Crypt::OpenPGP::Key::Public Crypt::OpenPGP::ErrorHandler );

sub public_props { qw( p g y ) }
sub crypt_props { qw( a b ) }

sub size { bitsize($_[0]->p) }

sub init {
    my $key = shift;
    $key->{key_data} = shift || Crypt::OpenPGP::ElGamal::Public->new;
    $key;
}

sub keygen {
    return $_[0]->error("ElGamal key generation is not supported");
}

sub encrypt {
    my $key = shift;
    my($M) = @_;
    $key->{key_data}->encrypt($M);
}

package Crypt::OpenPGP::ElGamal::Public;
use strict;

use Crypt::OpenPGP::Util qw( mod_exp );
use Math::Pari qw( Mod lift gcd );

sub new { bless {}, $_[0] }

sub encrypt {
    my $key = shift;
    my($M) = @_;
    my $k = gen_k($key->p);
    my $a = mod_exp($key->g, $k, $key->p);
    my $b = mod_exp($key->y, $k, $key->p);
    $b = Mod($b, $key->p);
    $b = lift($b * $M);
    { a => $a, b => $b };
}

sub gen_k {
    my($p) = @_;
    ## XXX choose bitsize based on bitsize of $p
    my $bits = 198;
    my $p_minus1 = $p - 1;
    require Crypt::Random;
    my $k = Crypt::Random::makerandom( Size => $bits, Strength => 0 );
    {
        last if gcd($k, $p_minus1) == 1;
    }
    $k;
}

sub _getset {
    my $e = shift;
    sub {
        my $key = shift;
        $key->{$e} = shift if @_;
        $key->{$e};
    }
}

*p = _getset('p');
*g = _getset('g');
*y = _getset('y');

1;