package Games::Goban;

use constant ORIGIN => ord("a");
use 5.006;
use strict;
use warnings;
use Carp;
our $VERSION = '0.01';
my %types = (
    go => 1,
    othello => 2,
    renju => 4,
    gomoku => 4,
);

=head1 NAME

Games::Goban - Board for playing go, renju, othello, etc.

=head1 SYNOPSIS

  use Games::Goban;
  my $board = new Games::Goban ( 
                size => 19,
                game => "go",
                white => "Seigen, Go",
                black => "Minoru, Kitani",
                referee => \&Games::Goban::Rules::Go,
  );

  $board->play("pd"); $board->play("dd");
  print $board->as_sgf;

=head1 DESCRIPTION

This is a generic module for handling goban-based board games.
Theoretically, it can be used to handle many of the other games which
can use Smart Game Format (SGF) but I want to keep it reasonably
restricted in order to keep it simple. 

=head1 METHODS

=head2 new(%options); 

Creates and initializes a new goban. The options and their legal
values (* marks defaults):

    size       9, 11, 13, 15, 17, *19 
    game       *go, othello, renju, gomoku
    white      Any text, default: "Miss White"
    black      Any text, default: "Mr Black"
    referee    Any subroutine, default: sub {1} # (All moves are valid) 

The referee subroutine takes a board object and a piece object, and
determines whether or not the move is legal. It also reports if the
game is won.

=cut

sub new { 
    my $class = shift;
    my %opts = @_;
    my $size = $opts{size} || 19;
    unless (grep {$size == $_} (9,11,13,15,17,19)) {
        croak "Illegal size $size (must be in 9,11,13,15,17,19)";
    }

    my $game = lc $opts{game} || 'go';
    croak "Unknown game $game" unless exists $types{$game};
    
    return bless {
        game => $game,
        board => {},
        moves => [],
        size => $size,
        black => $opts{black} || "Mr. Black",
        white => $opts{white} || "Miss White",
        callbacks => [],
        referee => $opts{referee} || sub { 1 },
        move => 1,
        magiccookie => "a0000",
        turn => 'b',
        
    }, $class;
}

=head2 move

    $ok = $board->move($position)

Takes a move, creates a Games::Goban::Piece object, and attempts to
place it on the board, subject to the constraints of the I<referee>. 
If this is not successful, it returns C<0> and sets C<$@> to be an error
message explaining why the move could not be made. If successful,
updates the board, updates the move number and the turn, and returns
true.

=cut

sub _check_pos {
    my $size = (shift)->{size};
    my $limit = chr($size+ORIGIN-1);
    my $move = lc shift;
    if ($move !~ /^([a-z])([a-z])$/ or !($1 le $limit and $2 le $limit)) 
    {
        local $Carp::CarpLevel=2;
        croak "Move $move not on board";
    }
    
    return $move;
}

sub move {
    my ($self, $move) = @_;
    $move = _check_pos($self,$move);
    my $stat = $self->{referee}->($self,$move);
    return $stat if !$stat;
    $self->{board}{$move} = bless {
        colour => $self->{turn},
        move  => $self->{move},
        position => $move,
        board => $self
    }, "Games::Goban::Piece";
    push @{$self->{moves}}, $self->{board}{$move};
    $self->{move}++;
    $self->{turn} = $self->{turn} eq "b" ? "w" : "b";
}

=head2 get

    $move = $board->get($position)

Gets the C<Games::Goban::Piece> object at the given location, if there
is one. Locations are specified as per SGF - a 19x19 board starts from
C<aa> in the top left corner, with C<tt> in the bottom right. C<i> does
not exist.

=cut

sub get {
    my ($self, $pos) = @_;
    $pos = _check_pos($self,$pos);
    return $self->{board}->{$pos};
}

=head2 size

    $size = $board->size

Returns the size of the goban.

=cut

sub size { $_[0]->{size} }

=head2 as_sgf

    $sgf = $board->as_sgf;

Returns a representation of the board as an SGF (Smart Game Format) file.

=cut

sub as_sgf {
    my $self = shift;
return "(;GM[$types{$self->{game}}]FF[4]AP[Games::Goban]SZ[$self->{size}]
PW[$self->{white}]PB[$self->{black}]\n".
(join "\n", map { ";".uc($_->color) ."[".$_->position."]CR[".$_->position."]" }
 @{$self->{moves}})
.")\n"
}

=head2 as_text

    print $board->as_text(coords => 1)

Returns a printable text picture of the board, similar to that printed
by C<gnugo>. Black pieces are represented by C<X>, white pieces by C<O>,
and the latest move is bracketed. I<hoshi> points are in their normal
position for Go, and printed as an C<+>. Coordinates are not printed by
default, but can be enabled as suggested in the synopsis.

=cut

sub _is_hoshi {
    my ($size, $xy) = @_;
    return 1 if $xy =~ /[cg][cg]/ and $size eq 9;
    return 1 if $xy =~ /[dgk][dgk]/ and $size eq 13;
    return 1 if $xy =~ /[djp][djp]/ and $size eq 19;
}

sub as_text {
    my $board = shift;
    my %opts = @_;
    my $text;
    for my $y ('a'..chr($board->size + ORIGIN - 1)) {
        $text .= sprintf("%2i: ", $board->size - (ord($y) - ORIGIN)) 
            if $opts{coords};
        for my $x ('a'..chr($board->size + ORIGIN - 1)) {
            my $p = $board->get("$x$y");
            if ($p and $p->move == $board->{move}-1 and $text and substr($text,-1,1) ne "\n") { chop $text; $text.="("; }
            $text .= ($p ? 
                ($p->color eq "b" ? "X" : "O") : 
                (_is_hoshi($board->size, "$x$y") ? "+" : "."))." ";
            if ($p and $p->move == $board->{move}-1) { chop $text; $text.=")"; }
        }
        $text .= "\n";
    }
    return $text;
}


=head2 register

    my $key = $board->register(\&callback);

Register a calllback to be called after every move is made. This is
useful for analysis programs which wish to maintain statistics on the
board state. The C<key> returned from this can be fed to...

=cut

sub register {
    my ($board, $cb) = @_;
    push @{$board->{callbacks}}, $cb;
    return ++$board->{magiccookie};
}

=head2 notes

    $board->notes($key)->{score} += 5;

C<notes> returns a hash reference which can be used by a callback to
store local state about the board. 

=cut

sub notes {
    my ($board, $key) = @_;
    return $board->{notes}->{$key};
}

=head2 hash

    $hash = $board->hash

Provides a unique hash of the board position. If the phrase "positional
superko" means anything to you, you want to use this method. If not,
move along, nothing to see here.

=cut

sub _iterboard (&$) {
    my ($sub, $board) = @_;
    for my $x ('a'..chr($board->size + ord("a") - 1)) {
        for my $y ('a'..chr($board->size + ord("a") - 1)) {
            $sub->($board->get("$x$y"));
        }
    }

}

sub hash {
    my $board = shift;
    my $hash = chr(0) x 91;
    my $bit = 0;
    _iterboard {
        my $piece = shift;
        vec($hash, $bit, 2) = $piece->color eq "b" ? 1 : 2 if $piece;
        $bit += 3;
    } $board;
    return $hash;
}

package Games::Goban::Piece;

=head1 C<Games::Goban::Piece> methods

Here are the methods which can be called on a C<Games::Goban::Piece>
object, representing a piece on the board.

=cut

=head1 color

Returns "b" for a black piece and "w" for a white. C<colour> is also
provided for Anglophones.

=cut

sub color { $_[0]->{colour} }
sub colour { $_[0]->{colour} }

=head1 notes

Similar to the C<notes> method on the board class, this provides a 
private area for callbacks to scribble on.

=cut

sub notes { $_[0]->{notes}->{$_[1]} }

=head1 position

Returns the position of this piece, as a two-character string.
Incidentally, try to avoid taking references to C<Piece> objects, since
this stops them being destroyed in a timely fashion. Use a C<position>
and C<get> if you can get away with it, or take a weak reference if
you're worried about the piece going away or being replaced by another
one in that position.

=cut

sub position { $_[0]->{position} }

=head1 move

Returns the move number on which this piece was played.

=cut

sub move { $_[0]->{move} }

=head1 board

Returns the board object whence this piece came.

=cut

sub board { $_[0]->{board} }

1;

=head1 SEE ALSO

Smart Game Format: http://www.red-bean.com/sgf/

C<Games::Go::SGF>

The US Go Association: http://www.usgo.org/

=head1 AUTHOR

Simon Cozens, C<simon@cpan.org>

