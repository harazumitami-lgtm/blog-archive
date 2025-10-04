# sb::Language - Module for Serene Bach
# == written by T.Otani <takuya.otani@gmail.com> ===
# == Copyright (C) 2004 SimpleBoxes/SerendipityNZ ==

package sb::Language;

use strict;
use Carp;

# ==================================================
# // module version
# ==================================================
use vars qw( $VERSION @ISA );
$VERSION = '0.01';
# 0.01 [2007/03/14] changed string
# 0.00 [2005/01/17] generated

# ==================================================
# // configuration for inheritance / dependancy
# ==================================================
# ==================================================
# // declaration for class member
# ==================================================
my $mCharset = undef; # ����饯�������å�
my $mCode    = undef; # ʸ��������
my %mString  = ();    # ʸ��������
my $mInit    = 0;     # ������ե饰
my $mLang    = undef; # ���֥�������
# ==================================================
# // constructor
# ==================================================
sub new {
	my $class = shift;
	my $lang = shift if (@_);
	my $obj = undef;
	return($mLang) if ($mInit);
	eval {
		if ($lang) {
			eval("require sb::Language::$lang");
			$obj = "sb::Language::$lang"->get();
		} else {
			$obj = &get($class);
		}
	};
	croak("Fail to initialize" . $@) if (!$obj);
	return($obj);
}
sub get {
	my $class = shift;
	if ( !$mInit or !defined($mLang) ) {
		$mLang = {};
		bless($mLang,$class);
		&_base_init($class); # �����
	}
	return($mLang);
}
# ==================================================
# // destructor
# ==================================================
sub bye {
	my $class = shift;
	$mLang = undef;
}
sub DESTROY {
	my $self = shift;
	$mCharset = undef;
	$mCode    = undef;
	%mString  = ();
	$mInit    = undef;
	return();
}
# ==================================================
# // public functions
# ==================================================
sub code { # [��������] ���쥳����
	my $self = shift;
	return( $mLang->{'lang'} );
}
sub init { # [��������] ������Ѥߤ��ɤ���
	my $self = shift;
	return( $mInit );
}
sub charset { # [��������] ����饯�������å�
	my $self  = shift;
	$mCharset = shift if (@_);
	return( $mCharset );
}
sub charcode { # [��������] ʸ��������
	my $self = shift;
	$mCode   = shift if (@_);
	return( $mCode );
}
sub strings { # [��������] ʸ������������
	my $self = shift;
	my $strings = shift;
	%mString = %$strings if ( defined($strings) );
	return( \%mString );
}
sub string { # [��������] �Ƽ�ʸ����
	my $self = shift;
	my $key  = shift;
	return if ( !defined($key) );
	$mString{$key} = shift if (@_);
	return $mString{$key} if ( defined($mString{$key}) );
	return $key;
}
sub convert { # ʸ���������Ѵ�����
	my $self = shift;
	my $text = shift; # ����ʸ����
	my $code = shift if (@_); # ���ϥ�����
	return($text);
}
sub mailtext { # �᡼����ʸ���������Ѵ�����
	my $self = shift;
	my $text = shift; # ����ʸ����
	return($text);
}
sub checkcode { # ʸ�������ɸ���
	my $self = shift;
	my $text = shift; # ����ʸ����
	my $code = shift if (@_); # ���ꥳ����
	return( $mCode );
}
sub holiday { # �����Ѵ�ɽ
	my $self = shift;
	my $year = shift; # �о�ǯ
	my %list = (
		'0101' => 'New Year Holiday',
		'1225' => 'Christmas Holiday',
		'1226' => 'Boxing Day',
	);
	return(\%list);
}
sub code_for_charset {
	my $self = shift;
	my $charset = lc( shift() );
	my %aCharset = (
		'ascii'       => 'ascii',
		'iso-8859-1'  => 'ascii',
		'binary'      => 'binary',
		'euc-jp'      => 'euc',
		'shift_jis'   => 'sjis',
		'iso-2022-jp' => 'jis',
		'ucs2'        => 'ucs2',
		'utf-8'       => 'utf8',
		'utf-16'      => 'utf16',
	);
	return ($aCharset{$charset}) ? $aCharset{$charset} : $charset;
}
# ==================================================
# // private functions
# ==================================================
sub _base_init {
	return() if ($mInit);
	$mLang->{'lang'} = ($_[0] =~ /^(.+)::([^:]+)$/)[1];
	if (!$mLang->{'lang'}) {
		$mLang->{'lang'} = 'en';
		$mCharset = 'ASCII';
		$mCode    = 'ascii';
	}
	my %msg = ( # default strings
		# string arrays for week
		'week_en'     => ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'],
		'week_enlong' => ['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'],
		'week_fr'     => ['dim','lun','mar','mer','jeu','ven','sam'],
		'week_frlong' => ['dimanche','lundi','mardi','mercredi','jeudi','vendredi','samedi'],
		'week_ja'     => ['&#x65E5;','&#x6708;','&#x706B;','&#x6C34;','&#x6728;','&#x91D1;','&#x571F;'],
		'week_jalong' => ['&#x65E5;&#x66DC;&#x65E5;','&#x6708;&#x66DC;&#x65E5;','&#x706B;&#x66DC;&#x65E5;','&#x6C34;&#x66DC;&#x65E5;','&#x6728;&#x66DC;&#x65E5;','&#x91D1;&#x66DC;&#x65E5;','&#x571F;&#x66DC;&#x65E5;'],
		# string arrays for month
		'month_en'     => ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'],
		'month_enlong' => ['January','February','March','April','May','June','July','August','September','October','November','December'],
		'month_fr'     => ['jan','f&eacute;v','mar','avr','mai','juin','juil','ao&ucirc;','sep','oct','nov','d&eacute;c'],
		'month_frlong' => ['janvier','f&eacute;vrier','mars','avril','mai','juin','juillet','ao&ucirc;t','septembre','octobre','novembre','d&eacute;cembre'],
	);
	&strings('sb::Language',\%msg);
	$mInit = 1;
}
1; # end of package
__END__
# --------------------------------------------------------------------
# �ڸ��������ѥ⥸�塼���
# sb �����Ѥ����Ƽ�ʸ����δ��������Ԥ��⥸�塼��Ǥ���ʸ��������
# �Ѵ������� sb::Language �ǹԤ��ޤ���
# 
# [��ư]
# use sb::Language;
# my $lang = sb::Language->new($langCode); # $langCode : ���쥳����
# 
# sb::Language �⥸�塼��Ͼ��ñ��Υ��󥹥��󥹤��֤��ޤ���
# --------------------------------------------------------------------
# [����ʸ��]
# ��Perl�ˤ��¿�����б� in ���ˤ㤭�������� - ��˺Ͽ
#   http://homepage3.nifty.com/analog_only/notes/perl_i18n.html
# --------------------------------------------------------------------
