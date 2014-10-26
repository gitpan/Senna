#!perl
use strict;
use File::Temp;

my $HAS_ENCODE;

BEGIN
{
    $HAS_ENCODE = eval { require Encode };
    require Test::More;
    Test::More->import(tests => 22 - ($HAS_ENCODE ? 0 : 8));
}

BEGIN
{
    use_ok("Senna::Constants", "SEN_ENC_EUCJP");
    use_ok("Senna::Snippet");
}

my $WIDTH = 100;
my $MAX_RESULTS = 8;

my $text = <<EOM;
snippet(KWIC)��������뤿���API��

sen_snip *sen_snip_open(sen_encoding encoding, int flags, size_t width, unsigned int max_results,
                        const char *defaultopentag, const char *defaultclosetag,
                        sen_snip_mapping *mapping);

������sen_snip���󥹥��󥹤��������ޤ���
encoding�ˤϡ�sen_enc_default, sen_enc_none, sen_enc_euc_jp, sen_enc_utf8, sen_enc_sjis �Τ����줫����ꤷ�ޤ���
flags�ˤϡ�SEN_SNIP_NORMALIZE(���������Ƹ�����Ԥ�)������Ǥ��ޤ���
width�ϡ�snippet������Х���Ĺ�ǻ��ꤷ�ޤ���euc��sjis�ξ��ˤϤ���Ⱦʬ��utf-8�ξ��ˤϤ���1/3��Ĺ�������ܸ줬��Ǽ�Ǥ���Ǥ��礦��
max_results�ϡ�snippet�θĿ�����ꤷ�ޤ���
defaultopentag�ϡ�snippet��θ���ñ������ˤĤ���ʸ�������ꤷ�ޤ���
defaultclosetag�ϡ�snippet��θ���ñ��θ�ˤĤ���ʸ�������ꤷ�ޤ���
mapping�ϡ�(���ߤ�)NULL��-1����ꤷ�Ƥ���������-1����ꤹ��ȡ�HTML�Υ᥿ʸ����򥨥󥳡��ɤ���snippet����Ϥ��ޤ���
defaultopentag,defaultclosetag�λؤ����Ƥϡ�sen_snip_close��Ƥ֤ޤ��ѹ����ʤ��Ǥ���������
EOM

my $snip = Senna::Snippet->new(
    encoding    => SEN_ENC_EUCJP,
    width       => $WIDTH,
    max_results => $MAX_RESULTS,
);

$snip->add_cond(keyword => "sen");

my @r = $snip->exec(string => $text);
ok(scalar(@r) < $MAX_RESULTS, "results is less than $MAX_RESULTS");

foreach my $r (@r) {
    if ($HAS_ENCODE) {
        $r = Encode::decode('euc-jp', $r);
        ok(length($r) <= $WIDTH, "string size < $WIDTH");
    }
    like($r, qr|{sen}|, "sen is properly enclosed in {}");
}

$snip = Senna::Snippet->new(
    encoding    => SEN_ENC_EUCJP,
    width       => $WIDTH,
    max_results => $MAX_RESULTS,
);

$snip->add_cond(keyword => "snippet", open_tag => "<b>", close_tag => "</b>");

@r = $snip->exec(string => $text);
ok(scalar(@r) < $MAX_RESULTS, "results is less than $MAX_RESULTS");

foreach my $r (@r) {
    if ($HAS_ENCODE) {
        $r = Encode::decode('euc-jp', $r);
        ok(length($r) <= $WIDTH, "string size < $WIDTH");
    }
    like($r, qr|<b>snippet</b>|, "snippet is properly enclosed in {}");
}

1;