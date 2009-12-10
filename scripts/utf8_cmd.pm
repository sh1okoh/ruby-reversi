use warnings;
use strict;
use Encode;

select(STDERR), $| = 1;
select(STDOUT), $| = 1;

my $command = join(' ', @ARGV);
my $keyword = '';
eval {
	open(IN, "$command 2>&1 |") || die "($command)を開始できませんでした。: $!";
	binmode(IN, ":encoding(utf8)");

	until(eof(IN)) {
		my $c = getc(IN);
		print Encode::encode("shift_jis", $c);
		perform($c);
	}
	close(IN) || die "($command)を終了できませんでした。: $!";
};
if ($@) { print $@ }

sub perform {

	$keyword .= shift;
	$keyword = length($keyword) > 8 ? substr($keyword, 1, 8) : $keyword;

	my $enc = $keyword =~ /:e_sjis/ ? 'shift_jis'
			: $keyword =~ /:e_utf8/ ? 'utf8'
			: $keyword =~ /:!s/     ? 'shift_jis'
			: $keyword =~ /:!u/     ? 'utf8'
			: undef;
	if ($enc) {
		$keyword = "";
		binmode(IN);
		binmode(IN, ":encoding($enc)");
		print "\n#### change encoding to $enc! ####";
	}
}

