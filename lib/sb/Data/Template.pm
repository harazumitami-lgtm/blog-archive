# sb::Data::Template - Module for Serene Bach
# == written by T.Otani <takuya.otani@gmail.com> ===
# == Copyright (C) 2004 SimpleBoxes/SerendipityNZ ==

package sb::Data::Template;

use strict;

# ==================================================
# // module version
# ==================================================
use vars qw( $VERSION @ISA );
$VERSION = '0.02';
# 0.02 [2007/07/04] removed @mStruct and added elements
# 0.01 [2005/07/22] changed data structure to array
# 0.00 [2005/02/02] generated

# ==================================================
# // configuration for inheritance / dependancy
# ==================================================
use sb::Data::Object ();
@ISA = qw( sb::Data::Object );
# ==================================================
# // declaration for constant value
# ==================================================
# ==================================================
# // declaration for data structure
# ==================================================
sub elements
{
	return(
		'id',    # id
		'wid',   # wid
		'use',   # ���ѥե饰
		'name',  # �ƥ�ץ졼��̾
		'gen',   # ������
		'mod',   # ������
		'info',  # �ƥ�ץ졼�Ⱦ���
		'main',  # �١����ƥ�ץ졼��
		'css',   # �������륷����
		'entry', # �����ƥ�ץ졼��
		'files', # ���ѥѡ���
	);
}
# ==================================================
# // public functions
# ==================================================
sub initialize
{
	my $self  = shift;
	my %param = @_;
	$param{'wid'} |= 0;
	$self->SUPER::initialize(%param);
}
1;
__END__
