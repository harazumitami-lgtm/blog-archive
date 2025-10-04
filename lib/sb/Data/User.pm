# sb::Data::User - Module for Serene Bach
# == written by T.Otani <takuya.otani@gmail.com> ===
# == Copyright (C) 2004 SimpleBoxes/SerendipityNZ ==

package sb::Data::User;

use strict;

# ==================================================
# // module version
# ==================================================
use vars qw( $VERSION @ISA );
$VERSION = '0.06';
# 0.06 [2007/07/04] removed @mStruct and added elements
# 0.05 [2007/05/04] added imagetag option to edit
# 0.04 [2006/09/30] changed DEFAULT_OPTION
# 0.03 [2005/07/25] added cat_open option to edit
# 0.02 [2005/07/22] changed data structure to array
# 0.01 [2005/02/03] added auto_cat option to edit
# 0.00 [2005/02/02] generated

# ==================================================
# // configuration for inheritance / dependancy
# ==================================================
use sb::Data::Object ();
@ISA = qw( sb::Data::Object );
# ==================================================
# // declaration for constant value
# ==================================================
my %aOptionKeys = (
	'status'    => 0,  # ���ơ���������(̤����)
	'format'    => 1,  # �ե����ޥå�����
	'init_date' => 2,  # ���դι�������
	'comment'   => 3,  # �����ȼ�������
	'trackback' => 4,  # �ȥ�å��Хå���������
	'ping'      => 5,  # ����PING��������
	'sequel'    => 6,  # ��³����ɽ������
	'summary'   => 7,  # �ֳ��ס�ɽ������(̤����)
	'imagelist' => 8,  # ���᡼�����ץ����
	'imagemax'  => 9,  # ���᡼���ꥹ������
	'advanced'  => 10, # ���Ը�������
	'tb_option' => 11, # �ȥ�å��Хå����ץ����
	'edit_tool' => 12, # �ġ��륢������
	'auto_cat'  => 13, # ��Ϣ���ƥ��꡼���ץ����
	'cat_open'  => 14, # ���ƥ��꡼�󥪥ץ����
	'imagetag'  => 15, # ���������������ץ����
);
sub DEFAULT_OPTION  (){ '1:1:0:1:1:1:0:0:0:10:0:0:0000000001111111111111111111:0:0:0:' };
sub DEFALT_TOOLICON (){ "strong:strong\nem:em\np:p\nblockquote:quote\nul:ul\nli:li\np[class=&quot;note&quot;]:cust1\n:cust2\n:cust3\nhr[/]:hr\nol:ol\ndl:dl\ndt:dt\ndd:dd\ndel:del\nins:ins\nh3:h3\nh4:h4\ntable:table\ntr:tr\nth:th\ntd:td\ndiv[style=&quot;text-align&#58;left&quot;]:left\ndiv[style=&quot;text-align&#58;center&quot;]:center\ndiv[style=&quot;text-align&#58;right&quot;]:right" };
# ==================================================
# // declaration for data structure
# ==================================================
sub elements
{
	return(
		'id',     # id
		'wid',    # wid
		'name',   # ���������̾
		'pass',   # �ѥ����
		'real',   # ̾��
		'disp',   # ɽ������
		'mail',   # �᡼�륢�ɥ쥹
		'notice', # �᡼����������
		'stat',   # ��������ȥ�٥�
		'order',  # �¤ӽ�
		'prof',   # �ץ�ե���������
		'aws',    # ���ޥ��� id
		'edit',   # �Խ�����
		'ext',    # �ġ��륢����������
		'info',   # ͽ��ե������
		'img',    # ͽ��ե������
		'friend', # ͽ��ե������
		'cat',    # �ǥե���ȥ��ƥ��꡼����
		'form',   # �ץ�ե�����ե����ޥå�
		'ad_css', # �������̥������륷��������
	);
}
# ==================================================
# // public functions
# ==================================================
sub real
{
	my $self = shift;
	$self->{'real'} = shift if @_;
	return ($self->{'real'} ne '') ? $self->{'real'} : $self->{'name'};
}
sub pass
{
	my $self = shift;
	if ( @_ )
	{
		my $pass = shift;
		my $salt = '';
		my @tmps = ('a'..'z','A'..'Z','0'..'9','.','/');
		1 while ( length($salt .= $tmps[rand(@tmps)]) < 8 );
		$salt = '$1$' . $salt . '$' if (index(crypt('a','$1$a$'),'$1$a$') == 0);
		$self->{'pass'} = crypt($pass,$salt);
	}
	return( $self->{'pass'} );
}
sub set_option
{
	my $self = shift;
	my ($key,$value) = @_;
	my @option = split(':',$self->edit);
	$option[$aOptionKeys{$key}] = $value;
	$self->edit(join(':',@option) . ':');
}
sub get_option
{
	my $self = shift;
	my $key  = shift;
	my @option = split(':',$self->edit);
	return $option[$aOptionKeys{$key}];
}
sub get_option_keys
{
	my $self = shift;
	return keys(%aOptionKeys);
}
sub check_pass
{
	my $self = shift;
	my $input = shift;
	return( crypt($input,$self->{'pass'}) eq $self->{'pass'} );
}
sub initialize
{
	my $self  = shift;
	my %param = @_;
	$param{'wid'} |= 0;
	$param{'edit'} |= DEFAULT_OPTION;
	$param{'ext'} |= DEFALT_TOOLICON;
	$param{'stat'} = 2 if ($param{'stat'} eq '');
	$param{'order'} = $self->id;
	$self->SUPER::initialize(%param);
}
1;
__END__
