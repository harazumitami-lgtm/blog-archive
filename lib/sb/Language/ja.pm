# sb::Language::ja - Module for Serene Bach
# == written by T.Otani <takuya.otani@gmail.com> ===
# == Copyright (C) 2004 SimpleBoxes/SerendipityNZ ==

package sb::Language::ja;

use strict;
use Carp;

# ==================================================
# // module version
# ==================================================
use vars qw( $VERSION @ISA );
$VERSION = '0.08';
# 0.08 [2010/05/09] added some words for aws
# 0.07 [2009/05/27] added some words for aws
# 0.06 [2007/07/22] changed words for Amazon Web Services
# 0.05 [2007/03/05] changed holiday to handle new law
# 0.04 [2007/02/09] added error_saved_as_closed and changed setup_msg_stat
# 0.03 [2006/11/09] added error_dup_catidx
# 0.02 [2006/02/04] changed some strings
# 0.01 [2005/09/28] changed convert to add converting tilda functionally
# 0.00 [2005/01/17] created

# ==================================================
# // configuration for inheritance / dependancy
# ==================================================
use sb::Config ();
use sb::Language ();
@ISA = qw( sb::Language );
# ==================================================
# // declaration for private variables
# ==================================================
my $aConvTilda = 1; # ������Ѵ��ե饰
my $pIncomingCode = undef; # ����������
# ==================================================
# // constructor
# ==================================================
sub get
{
	my $class = shift;
	my $self = $class->SUPER::get();
	$self->_init(); # initialize
	return($self);
}
sub new
{
	&get; # 'new' is alias for 'get'
}
# ==================================================
# // public functions (overriding)
# ==================================================
sub convert
{
	my $self = shift;
	my $text = shift;
	my $code = (@_) ? shift : $self->charcode;
	&Jcode::convert(\$text,$code,$pIncomingCode) if ($self->init);
	$text =~ s/\xE2\x80\xBE/\x7E/g if ($code eq 'utf8' and $code ne $pIncomingCode and $aConvTilda);
	return($text);
}
sub mailtext
{
	my $self = shift;
	my $text = shift;
	&Jcode::convert(\$text,'jis',$pIncomingCode) if ($self->init);
	return($text);
}
sub checkcode
{
	my $self = shift;
	my $text = shift;
	my $code = shift if (@_);
	if ($code)
	{
		$pIncomingCode = $code;
	}
	elsif ($text)
	{
		$pIncomingCode = &Jcode::getcode($text) if ($self->init);
	}
	return( $pIncomingCode );
}
sub holiday
{
	my $self = shift;
	my $year = shift; # ���ϥѥ�᡼��
	my %list = ( # �����ѥꥹ�� / �����Ȥ���Ϳ����줿ǯ�ν����ꥹ�ȤΥ�ե���󥹤��֤�
		'0101' => '����',
		'0211' => '����ǰ����',
		'0429' => '�ߤɤ����',
		'0503' => '��ˡ��ǰ��',
		'0505' => '���ɤ����',
		'1103' => 'ʸ������',
		'1123' => '��ϫ���դ���',
		'1223' => 'ŷ��������',
	);
	if ($year >= 2007)
	{
		$list{'0429'} = '���¤���';
		$list{'0504'} = '�ߤɤ����';
	}
	if ($year < 2000)
	{
		$list{'0115'} = '���ͤ���';
		$list{'1010'} = '�ΰ����';
	}
	else
	{
		for (my $day=8;$day<=14;$day++)
		{
			$day = &_pad0($day);
			$list{'01' . $day} = '���ͤ���' if (&_weekday($year,'01',$day) == 1);
			$list{'10' . $day} = '�ΰ����' if (&_weekday($year,'10',$day) == 1);
		}
	}
	if ($year < 2003)
	{
		$list{'0720'} = '������' if ($year > 1995);
		$list{'0915'} = '��Ϸ����';
	}
	else
	{
		for (my $day=15;$day<=21;$day++)
		{
			$day = &_pad0($day);
			$list{'07' . $day} = '������'   if (&_weekday($year,'07',$day) == 1);
			$list{'09' . $day} = '��Ϸ����' if (&_weekday($year,'09',$day) == 1);
		}
	}
	{ # ��ʬ/��ʬ���� // 1980ǯ����2099ǯ�ޤ�ͭ��
		my $spring = int(20.8431 + 0.242194*($year-1980)-int(($year-1980)/4));
		my $autumn = int(23.2488 + 0.242194*($year-1980)-int(($year-1980)/4));
		$list{'03' . $spring} = '��ʬ����';
		$list{'09' . $autumn} = '��ʬ����';
		$list{'09' . ($autumn-1)} = '��̱�ε���' if (&_weekday($year,'09',$autumn - 1) == 2);
		$list{'0504'} = '��̱�ε���' if (&_weekday($year,'05','04') > 1 and $year < 2007);
	}
	foreach my $date (keys(%list))
	{ # ���ص����׻�
		my $mon = substr($date,0,2);
		my $day = substr($date,2,2);
		$list{$mon . &_pad0($day + 1)} = '(���ص���)' if ( &_weekday($year,$mon,$day) == 0 );
	}
	return(\%list);
}
# ==================================================
# // private functions
# ==================================================
sub _init
{
	my $self = shift;
	return() if ( $self->charset );
	eval("require 'Jcode.pm'"); # �����饤�֥��ƤӽФ�
	croak($@) if ($@);
	my $check = ord("��"); # �ִ��פȽ񤤤ơ֤��Ȥ��פ��ɤ�
	if ($check == 0xb4 or $check ==  -76)
	{
		$self->charset('EUC-JP');
		$self->charcode('euc');
	}
	elsif ($check == 0x8a or $check == -118)
	{
		$self->charset('Shift_JIS');
		$self->charcode('sjis');
	}
	elsif ($check == 0xe6 or $check ==  -26)
	{
		$self->charset('UTF-8');
		$self->charcode('utf8');
	}
	elsif ($check == 0x1b)
	{
		$self->charset('iso-2022-jp');
		$self->charcode('jis');
	}
	else
	{ # �����ʥ�����
		croak("Unknown char code.");
	}
	# ���쥻�쥯��
	$self->string('language_ja'=>'���ܸ�');
	$self->string('language_en'=>'�Ѹ�');
	$self->string('language_fr'=>'�ե�󥹸�');
	# ��¸����
	$self->string('entryarchive_Individual'=>'���̵�����html��¸');
	$self->string('entryarchive_Monthly'   =>'���̥��������֤�html��¸');
	$self->string('entryarchive_None'      =>'�ȥåץڡ����Τ�html����');
	# �����Ϣ
	$self->string('setup_aws_stat'      =>'�����:����');
	$self->string('setup_msg_stat'      =>'�Ԥ�:����:�����');
	$self->string('setup_link_stat'     =>'����:�����');
	$self->string('setup_edit_stat'     =>'�����:����');
	$self->string('setup_edit_format'   =>'���Τޤ�:��ư����');
	$self->string('setup_edit_date'     =>'���Τޤ�:�Խ����˹���');
	$self->string('setup_edit_comment'  =>'�����դ��ʤ�:�����դ���:��ǧ��ɬ��');
	$self->string('setup_edit_trackback'=>'�����դ��ʤ�:�����դ���:��ǧ��ɬ��');
	# ��������
	$self->string('aws_genre_All' => '[����]');
	$self->string('aws_genre_Blended' => '[�֥��ɸ���]');
	$self->string('aws_genre_Apparel' => '��&amp;�ե��å����ʪ');
	$self->string('aws_genre_Automotive' => '����&amp;�Х�������');
	$self->string('aws_genre_Baby' => '�٥ӡ�&amp;�ޥ��˥ƥ�');
	$self->string('aws_genre_Beauty' => '����');
	$self->string('aws_genre_Books' => '�½�');
	$self->string('aws_genre_Classical' => '���饷�å�����');
	$self->string('aws_genre_DigitalMusic' => '�ǥ�����ߥ塼���å�');
	$self->string('aws_genre_DVD' => 'DVD');
	$self->string('aws_genre_Electronics' => '����&amp;�����');
	$self->string('aws_genre_ForeignBooks' => '�ν�');
	$self->string('aws_genre_GourmetFood' => '�����&amp;�ա���');
	$self->string('aws_genre_Grocery' => '����');
	$self->string('aws_genre_HealthPersonalCare' => '�إ륹&amp;�ӥ塼�ƥ���');
	$self->string('aws_genre_Hobbies' => '�ۥӡ�');
	$self->string('aws_genre_HomeGarden' => '�����ǥ˥�');
	$self->string('aws_genre_HomeImprovement' => 'DIY������');
	$self->string('aws_genre_Industrial' => '��������');
	$self->string('aws_genre_Jewelry' => '���奨�꡼');
	$self->string('aws_genre_KindleStore' => '����ɥ�');
	$self->string('aws_genre_Kitchen' => '�ۡ���&amp;���å���');
	$self->string('aws_genre_Lighting' => '����');
	$self->string('aws_genre_Magazines' => '����');
	$self->string('aws_genre_Merchants' => '��������');
	$self->string('aws_genre_Miscellaneous' => '����¾');
	$self->string('aws_genre_MP3Downloads' => 'MP3���������');
	$self->string('aws_genre_Music' => '����');
	$self->string('aws_genre_MusicalInstruments' => '�ڴ�');
	$self->string('aws_genre_MusicTracks' => '�ߥ塼���å��ȥ�å�');
	$self->string('aws_genre_OfficeProducts' => '���ե�������');
	$self->string('aws_genre_OutdoorLiving' => '�����ȥɥ�');
	$self->string('aws_genre_Outlet' => '�����ȥ�å�');
	$self->string('aws_genre_PCHardware' => 'PC');
	$self->string('aws_genre_PetSupplies' => '�ڥå�����');
	$self->string('aws_genre_Photo' => '�̿�');
	$self->string('aws_genre_Shoes' => '���塼��');
	$self->string('aws_genre_Software' => '���եȥ�����');
	$self->string('aws_genre_SoftwareVideoGames' => '���եȥ�����(������)');
	$self->string('aws_genre_SportingGoods' => '���ݡ���');
	$self->string('aws_genre_Tools' => '����');
	$self->string('aws_genre_Toys' => '�������');
	$self->string('aws_genre_UnboxVideo' => '�ӥǥ�(Ȣ�ʤ�)');
	$self->string('aws_genre_VHS' => '�ӥǥ�(VHS)');
	$self->string('aws_genre_Video' => '�ӥǥ�');
	$self->string('aws_genre_VideoGames' => '������');
	$self->string('aws_genre_Watches' => '����');
	$self->string('aws_genre_Wireless' => '̵������');
	$self->string('aws_genre_WirelessAccessories' => '̵�����������꡼');
	$self->string('aws_genre_ASIN' =>'ASIN');
	# �����⡼�ɥ�٥�
	$self->string('mode_new'      =>'��������');
	$self->string('mode_edit'     =>'�����Խ�');
	$self->string('mode_list'     =>'�����ꥹ��');
	$self->string('mode_upload'   =>'���åץ���');
	$self->string('mode_amazon'   =>'��������');
	$self->string('mode_category' =>'�������ƥ��꡼');
	$self->string('mode_link'     =>'���');
	$self->string('mode_profile'  =>'�ץ�ե�����');
	$self->string('mode_view'     =>'�����֥ڡ�����ǧ');
	$self->string('mode_rebuild'  =>'�ڡ�������');
	$self->string('mode_comment'  =>'������');
	$self->string('mode_trackback'=>'�ȥ�å��Хå�');
	$self->string('mode_refuse'   =>'��������');
	$self->string('mode_user'     =>'�桼����');
	$self->string('mode_template' =>'�ƥ�ץ졼��');
	$self->string('mode_config'   =>'�Ķ�����');
	$self->string('mode_editor'   =>'�Խ�����');
	$self->string('mode_help'     =>'�إ��');
	$self->string('mode_access'   =>'������������');
	$self->string('mode_status'   =>'���ơ�����');
	$self->string('mode_logout'   =>'��������');
	$self->string('mode_login'    =>'������');
	$self->string('mode_welcome'  =>'�褦����');
	$self->string('mode_bm'       =>'�����å����');
	$self->string('mode_edittemp' =>'�ƥ�ץ졼���Խ�');
	$self->string('mode_edituser' =>'�桼���������Խ�');
	# ��å������ѡ���
	$self->string('parts_noname'  =>'[̾��̤����]');
	$self->string('parts_notitle' =>'[̾��̤����]');
	$self->string('parts_arrow'   =>'��');
	$self->string('parts_sequel'  =>'³�����ɤ���');
	$self->string('parts_more_rss'=>'[³��������ޤ�]');
	$self->string('parts_com_num' =>'comments ');
	$self->string('parts_tb_num'  =>'trackbacks ');
	$self->string('parts_mailchar'=>'iso-2022-jp'); # �᡼�������ѥ�����
	$self->string('parts_no_cat'  =>'̤����');
	$self->string('parts_thumb'   =>' (����ͥ���)');
	$self->string('parts_withlink'=>' (���)');
	$self->string('parts_thumblst'=>' [*]');
	$self->string('parts_advuser' =>' [*]');
	$self->string('parts_tmpinfo' =>' [*]');
	$self->string('parts_formdate'=>'%Year%ǯ%Mon%��%Day%��');
	$self->string('parts_formtime'=>'%Hour%:%Min%:%Sec%');
	$self->string('parts_error'   =>'�������Ρ�');
	$self->string('parts_logout'  =>'�������Ȥ��ޤ�����');
	$self->string('parts_sentping'=>'��PING���������ޤ�����<br />');
	$self->string('parts_findtb'  =>'��Υȥ�å��Хå�URL�򸫤Ĥ��ޤ�����<br />');
	$self->string('parts_deleted' =>'�������ޤ�����<br />');
	$self->string('parts_confcomp'=>'�����ȿ�Ǥ��ޤ�����<br />');
	$self->string('parts_needmake'=>'����ޤǤε������Ф���ȿ�Ǥ�����ˤϺƹ��ۤ�ɬ�פǤ���');
	$self->string('parts_rec_make'=>'�ѹ�������ȿ�Ǥ�����ˤϺƹ��ۤ�ɬ�פǤ���');
	$self->string('parts_link_bld'=>'��<a href="%s?__mode=rebuild">�ƹ���</a><br />');
	$self->string('parts_buildcmp'=>'�ƹ��ۤ��ޤ������֥����֥ڡ�����ǧ�פ�ꤴ��ǧ��������');
	$self->string('parts_passchng'=>'�ѥ���ɤ��ѹ����ޤ����������󤷤ʤ����Ƥ���������<br />');
	$self->string('parts_userchng'=>'�桼����̾���ѹ����ޤ����������󤷤ʤ����Ƥ���������<br />');
	$self->string('parts_editcomp'=>'�Խ����ޤ�����<br />');
	$self->string('parts_new_comp'=>'�����������ޤ�����<br />');
	$self->string('parts_add_comp'=>'%d ���ɲä��ޤ�����<br />');
	$self->string('parts_sw_on'   =>'��������');
	$self->string('parts_sw_off'  =>'������ˤ���');
	$self->string('parts_showfile'=>'[�ܺ�...]');
	$self->string('parts_bm_close'=>'[�Ĥ���]');
	$self->string('parts_tempedit'=>'�Խ�');
	$self->string('parts_temp_use'=>'������');
	$self->string('parts_temp_can'=>'-');
	$self->string('parts_temp_sel'=>'���ѥƥ�ץ졼�Ȥ��ѹ����ޤ�����<br />');
	$self->string('parts_temp_css'=>'CSS�ƥ�ץ졼�Ȥ����Ƥ�ȿ�Ǥ��ޤ�����<br />');
	$self->string('parts_temp_add'=>'�ƥ�ץ졼�Ȥ��ɲ���¸���ޤ�����<br />');
	$self->string('parts_tempcomp'=>'HTML�ƥ�ץ졼�Ȥ򹹿����ޤ�����<br />');
	$self->string('parts_no_icon' =>'��������ʤ�');
	$self->string('parts_build_op'=>'[#%d] ���������֤κƹ��� (�ǿ�:%d-%d)');
	$self->string('parts_subj_tb' =>'[Serene Bach]�ȥ�å��Хå�����');
	$self->string('parts_subj_com'=>'[Serene Bach]����������');
	$self->string('parts_body_tb' =>'�ȥ�å��Хå���������ޤ�����');
	$self->string('parts_body_com'=>'�����Ȥ���Ƥ�����ޤ�����');
	$self->string('parts_extracat'=>'<script type="text/javascript">showCategorySelector(\'��Ϣ��\',\'����\');</script>');
	$self->string('parts_not_inst'=>'<strong style="color:red">%s�ϥ��󥹥ȡ��뤵��Ƥ��ޤ���</strong>');
	$self->string('parts_install' =>'<strong style="color:green">%s�ϥ��󥹥ȡ��뤵��Ƥ��ޤ���</strong>');
	$self->string('parts_no_file' =>'<strong style="color:red">��%s�פ�����ޤ���</strong>');
	$self->string('parts_unread'  =>'<strong style="color:red">��%s�פ��ɤ߹��ߤǤ��ޤ��󡣥ѡ��ߥå������ǧ���Ƥ���������</strong>');
	$self->string('parts_unwrite' =>'<strong style="color:red">��%s�פ��񤭹��ߤǤ��ޤ��󡣥ѡ��ߥå������ǧ���Ƥ���������</strong>');
	$self->string('parts_finefile'=>'<strong style="color:green">��%s�פ��������֤���Ƥ��ޤ���</strong>');
	# ���顼��å�����
	$self->string('error_not_allow'      =>'���ν�����Ԥ����¤�����ޤ���');
	$self->string('error_wrong_text'     =>'����ʸ���Ϥ����Ѥˤʤ�ޤ���');
	$self->string('error_wrong_pass'     =>'�ѥ���ɤ��ְ�äƤ��ޤ���');
	$self->string('error_file_open'      =>'�ե����뤬�����ޤ��� : ');
	$self->string('error_unsuppoted'     =>'���ݡ��Ȥ���Ƥ��ޤ��� : ');
	$self->string('error_unknown'        =>'ͽ�����ʤ����顼��ȯ�����ޤ�����');
	$self->string('error_file_lock'      =>'�ե������å�����Ƥ��ޤ���');
	$self->string('error_initialize'     =>'���ǧ�ڤ�����ޤ���Ǥ������⤦���٥��󥹥ȡ��뤷�ʤ����Ƥ���������');
	$self->string('error_expired'        =>'�������ͭ�����֤��᤮�Ƥ��ޤ���');
	$self->string('error_difference'     =>'��ǧ���ܤȰ��פ��ޤ���');
	$self->string('error_dup_dir'        =>'Ʊ̾�Υǥ��쥯�ȥ꤬����¸�ߤ��Ƥ��ޤ���');
	$self->string('error_failtomake'     =>'�����Ǥ��ޤ���Ǥ������ѡ��ߥå����ʤɤ򤴳�ǧ��������');
	$self->string('error_failtodel'      =>'����Ǥ��ޤ���Ǥ������ѡ��ߥå����ʤɤ򤴳�ǧ��������');
	$self->string('error_no_user'        =>'��������桼���������ޤ���');
	$self->string('error_no_entry'       =>'�������뵭��������ޤ���');
	$self->string('error_no_cat'         =>'�������륫�ƥ��꡼������ޤ���');
	$self->string('error_dup_cat'        =>'Ʊ̾�Υ��ƥ��꡼������¸�ߤ��ޤ���<br />');
	$self->string('error_no_name'        =>'̾�Τ����ꤵ��Ƥ��ޤ���');
	$self->string('error_exist_user'     =>'����Ʊ̾�Υ桼������¸�ߤ��ޤ���');
	$self->string('error_no_body'        =>'�������Ƥ�����ޤ���');
	$self->string('error_banned'         =>'��Ƥ�����դ��뤳�Ȥ��Ǥ��ޤ���');
	$self->string('error_doubled'        =>'������Ƥ���Ƥ��ޤ���');
	$self->string('error_no_comment'     =>'���������Ƥ�����ޤ���');
	$self->string('error_wait_msg'       =>'��������Ƥ��꤬�Ȥ��������ޤ�����Ƥ��줿�����Ȥϴ����Ԥξ�ǧ�塢ɽ������ޤ���');
	$self->string('error_res_msg'        =>'��������ƽ�������');
	$self->string('error_exist_cat'      =>'���Υ��ƥ��꡼�ϴ���¸�ߤ��Ƥ��ޤ���');
	$self->string('error_failtoadd'      =>'�ɲäǤ��ޤ���Ǥ�����');
	$self->string('error_inst_skipped'   =>'999 Skipped');
	$self->string('error_inst_load_temp' =>'�ƥ�ץ졼�Ȥ��ɹ��ߤ˼��Ԥ��ޤ�����');
	$self->string('error_inst_init'      =>'���󥹥ȡ���ν�����˼��Ԥ��ޤ�����');
	$self->string('error_installing'     =>'���󥹥ȡ������ͽ�����ʤ����顼��ȯ�����ޤ�����');
	$self->string('error_alredy_inst'    =>'���Ǥ˥��åȥ��å׺ѤߤǤ���');
	$self->string('error_dup_catidx'     =>'Ʊ����¸��Υ��ƥ��꡼��¸�ߤ��ޤ���[%s]<br />');
	$self->string('error_saved_as_closed'=>'��������Ƥ��꤬�Ȥ��������ޤ�����Ƥ��줿�����Ȥ����������¸����ޤ�����');
	# �����ѥѡ���
	$self->string('week_ja'     =>['��','��','��','��','��','��','��']);
	$self->string('week_jalong' =>['������','������','������','������','������','������','������']);
	$self->string('month_ja'    =>['���','���','����','�ͷ�','�޷�','ϻ��','����','Ȭ��','���','����','�����','�����']);
	$self->string('month_jalong'=>['�ӷ�','ǡ��','����','����','����','��̵��','ʸ��','�շ�','Ĺ��','��̵��','����','����']);
	return();
}
sub _pad0
{
	my $num = shift;
	return('0' . $num) if ($num < 10);
	return($num);
}
sub _weekday
{ # ����������programed by OHZAKI Hiroki��
	my ($year,$mon,$mday) = @_; # ���ϥѥ�᡼�� /ǯ,��,��/
	if ($mon == 1 or $mon == 2)
	{
		$year--;
		$mon += 12;
	}
	return(int($year + int($year / 4) - int($year / 100) + int($year / 400) + int((13 * $mon + 8) / 5) + $mday) % 7);
}
1;
