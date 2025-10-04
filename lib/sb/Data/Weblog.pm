# sb::Data::Weblog - Module for Serene Bach
# == written by T.Otani <takuya.otani@gmail.com> ===
# == Copyright (C) 2004 SimpleBoxes/SerendipityNZ ==

package sb::Data::Weblog;

use strict;

# ==================================================
# // module version
# ==================================================
use vars qw( $VERSION @ISA );
$VERSION = '0.03';
# 0.03 [2007/07/04] removed @mStruct and added elements
# 0.02 [2005/07/22] changed data structure to array
# 0.01 [2005/07/08] changed DEFAULT_PLUGIN
# 0.00 [2005/02/02] generated

# ==================================================
# // configuration for inheritance / dependancy
# ==================================================
use sb::Data::Object ();
@ISA = qw( sb::Data::Object );
# ==================================================
# // declaration for constant value
# ==================================================
sub DEFAULT_TITLE  (){ 'My first weblog' };
sub DEFAULT_PLUGIN (){ '[AccessLog.pm][Convert.pm]' };
# ==================================================
# // declaration for data structure
# ==================================================
sub elements
{
	return(
		'id',     # id
		'title',  # title
		'text',   # description
		'pacc',   # POP3 ���������
		'psrv',   # POP3 ������
		'psubj',  # POP3 �������֥�������
		'pfrom',  # POP3 ����������
		'pcat',   # POP3 ���ꥫ�ƥ��꡼
		'pthum',  # POP3 ����ͥ�������ե饰
		'pform',  # POP3 Ŭ�ѥե����ޥå�
		'pping',  # POP3 ���� ping ��������
		'pcron',  # POP3 �����������
		'ptime',  # POP3 �����ֳ�
		'ppass',  # POP3 �ѥ����
		'papop',  # POP3 APOPǧ������
		'ppath',  # POP3 access path
		'smtp',   # smtp �����Х��ɥ쥹 or sendmail �ѥ�
		'stype',  # �᡼�����Υ�����(smtp or sendmail)
		'ext',    # �ɲþ���
		'plugin', # plugins
	);
}
# ==================================================
# // public functions
# ==================================================
sub initialize
{
	my $self  = shift;
	my %param = @_;
	$param{'title'}  = DEFAULT_TITLE  if ($param{'title'} eq '');
	$param{'plugin'} = DEFAULT_PLUGIN if ($param{'plugin'} eq '');
	$self->SUPER::initialize(%param);
}
1;
__END__
