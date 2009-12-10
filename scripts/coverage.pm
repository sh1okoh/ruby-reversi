#
# 'etc\coverage'フォルダ直下のhtmlファイルを全てUTF8として扱うためのスクリプトです。
#
$parent = $ARGV[0];

opendir(DIR, $parent) || die "$!";
@names = grep(/\.html$/, grep(!/^\./, readdir(DIR)));
closedir(DIR) || die "$!";

foreach $name (@names) {
	$path = $parent . '\\' . $name;
	print "target:" . $path . " is replacing...\n";
	open(IN, $path) || die "$!";
	@buff = <IN>;
	close(IN) || die "$!";
	open(OUT, ">" . $path) || die "$!";
	foreach(@buff) {
		$_ =~ s/<head>/<head><meta http-equiv="content-type" content="text\/html; charset=UTF-8">/;
		print OUT $_;
	}
	close(OUT) || die "$!";
}
