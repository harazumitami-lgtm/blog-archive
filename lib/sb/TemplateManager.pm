# sb::TemplateManager - Module for Serene Bach
# == written by T.Otani <takuya.otani@gmail.com> ===
# == Copyright (C) 2004 SimpleBoxes/SerendipityNZ ==

package sb::TemplateManager;

use strict;
use integer;
use Carp;

# ==================================================
# // Module version
# ==================================================
use vars qw( $VERSION @ISA );
$VERSION = '0.02';
# 0.02 [2005/10/19] changed block structure to store contents as an array instead of text
# 0.01 [2005/10/18] added clear
# 0.00 [2004/11/17] generated

# ==================================================
# // configuration for inheritance / dependancy
# ==================================================
# ==================================================
# // declaration for constant value
# ==================================================
sub BLOCKS  (){ 0 }
sub DATA    (){ 1 }
sub NUMBER  (){ 2 }
# ==================================================
# // constructor
# ==================================================
sub new {
	my $class = shift;
	my $self = [];
	$self->[BLOCKS]  = []; # �ƥ�ץ졼�ȳ�Ǽ��
	$self->[DATA]    = {}; # Ÿ���ǡ�����Ǽ��
	$self->[NUMBER]  = 0;  # ������Ԥ��֥�å��ֹ�
	bless($self,$class);
	$self->_init(@_);
	return($self);
}
# ==================================================
# // destructor
# ==================================================
sub DESTROY {
	my $self = shift;
	return();
}
# ==================================================
# // public functions
# ==================================================
sub output { # �ƥ�ץ졼��Ÿ��
	my $self = shift;
	my $output = ''; # ���ϥѥ�᡼��
	for (my $i=0;$i<@{$self->[BLOCKS]};$i++) {
		my $rep = ($self->[BLOCKS][$i]{'name'} eq '_main')
		        ? 1
		        : $self->[DATA]{'block'}{$self->[BLOCKS][$i]{'name'}};
		for (my $j=0;$j<$rep;$j++) {
			for (my $k=0;$k<@{$self->[BLOCKS][$i]{'text'}};$k++) {
				my $line = $self->[BLOCKS][$i]{'text'}[$k];
				foreach my $key (@{$self->[BLOCKS][$i]{'tags'}}) {
					next if ( index($line,$key) == -1 );
					if ( defined($self->[DATA]{'tag'}{$key}[$j]) ) {
						$line =~ s/$key/$self->[DATA]{'tag'}{$key}[$j]/g;
					} else {
						$line =~ s/$key//g;
					}
				}
				$output .= $line . "\n";
			}
		}
	}
	return($output);
}
sub deleteBlock { # ����֥�å�������פʥ֥�å��������� (ex. sequel in entry)
	my $self  = shift;
	my $block = shift; # ���ϥѥ�᡼�� / �������֥�å�̾
	croak('lack of parameter') unless( defined($block) );
	if ( $self->existed($block) ) {
		my $check = 0;
		for (my $i=0;$i<@{$self->[BLOCKS]};$i++) {
			next if ($self->[BLOCKS][$i]{'name'} ne $block);
			$check = $i;
			last;
		}
		# �оݥ֥�å������夬Ʊ����
		if (  $check > 0 
		  and $check < $#{$self->[BLOCKS]} 
		  and $self->[BLOCKS][$check - 1]{'name'} eq $self->[BLOCKS][$check + 1]{'name'})
		{
			# �֥�å����ƤΥޡ���
			push(
				@{$self->[BLOCKS][$check - 1]{'text'}},
				@{$self->[BLOCKS][$check + 1]{'text'}}
			);
			# ���ѥ����Υޡ���
			push(
				@{$self->[BLOCKS][$check - 1]{'tags'}},
				@{$self->[BLOCKS][$check + 1]{'tags'}}
			);
			# �֥�å����
			splice(@{$self->[BLOCKS]},$check,2);
		}
	}
	return();
}
sub clear {
	my $self = shift;
	$self->[DATA]{'tag'} = {};
	foreach my $block ( keys(%{$self->[DATA]{'block'}}) ) {
		$self->[DATA]{'block'}{$block} = 0;
	}
}
sub tag { # ��������
	my $self = shift;
	my ($tag,$content) = @_; # ����̾ , ����
	my $num = $self->[NUMBER];
	if ( defined($tag) ) {
		# $self->[DATA]{'tag'}{'{' . $tag . '}'} = [] if ($num == 0); # �������Ƥν���� (��α)
		$self->[DATA]{'tag'}{'{' . $tag . '}'}[$num] = $content;
	} else {
		croak('Lack of parameters');
	}
	return();
}
sub num { # �֥�å��ֹ����
	my $self = shift;
	$self->[NUMBER] = shift; # ����
	return();
}
sub block { # �֥�å�����
	my $self  = shift;
	my ($block,$num) = @_; # �֥�å�̾ ,  �����֤���
	if ( defined($block) and defined($num) ) {
		$self->[DATA]{'block'}{$block} = $num;
	} else {
		croak('Lack of parameters');
	}
	return();
}
sub existed { # �֥�å���¸�ߤ��뤫�ɤ���
	my $self  = shift;
	my $block = shift; # �֥�å�̾
	if ( defined($block) ) {
		return( exists($self->[DATA]{'block'}{$block}) );
	} else {
		return( undef );
	}
}
sub unifyFor { # ���������첽
	my $self  = shift;
	my $tag   = shift; # ����̾
	my $block = shift; # �֥�å� (�֥�å������ꤵ�줿��硢���Υ֥�å���ʬ��������)
	my $key = '{' . $tag . '}';
	my $num  = @{$self->[DATA]{'tag'}{$key}}; # �����
	$num = $self->[DATA]{'block'}{$block} if ( defined($block) );
	my $content = $self->[DATA]{'tag'}{$key}[0];
	if ( defined($content) and $num > 1 ) {
		for (my $i=1;$i<$num;$i++) {
			$self->[DATA]{'tag'}{$key}[$i] = $content;
		}
	}
	return();
}
# ==================================================
# // private functions
# ==================================================
sub _init { # ������롼����
	my $self = shift;
	my $template = shift;
	croak('Need to set template') unless ( $template );
	$self->[DATA]{'tag'} = {};
	$self->[DATA]{'block'} = {};
	$self->_parseTemplate($template);
	return();
}
sub _parseTemplate { # �ƥ�ץ졼�ȥѡ���
	my $self = shift;
	my $template = shift;
	my $num = 0;
	my $cur = '_main';
	my @stack = ();
	{ # �����
		$self->[BLOCKS][$num] = {};
		$self->[BLOCKS][$num]{'text'} = [];
		$self->[BLOCKS][$num]{'tags'} = [];
		$self->[BLOCKS][$num]{'name'} = $cur;
		push(@stack,$cur);
	}
	foreach my $line (split("\n",$template)) {
		if ($line =~ /<\!-- BEGIN (\w+) -->/) {
			$num++;
			$cur = $1;
			$self->[BLOCKS][$num] = {};
			$self->[BLOCKS][$num]{'text'} = [];
			$self->[BLOCKS][$num]{'tags'} = [];
			$self->[BLOCKS][$num]{'name'} = $cur;
			$self->[DATA]{'block'}{$cur} = 0; # �֥�å������
			if ($cur eq 'entry') { # ����ȥ꡼�Ѥ����̽���
				push(@{$self->[BLOCKS][$num]{'text'}},'{sb_entry_marking}');
				push(@{$self->[BLOCKS][$num]{'tags'}},'{sb_entry_marking}');
			}
			push(@stack,$cur);
			next;
		} elsif (index($line,'<!-- END ') > -1) {
			if ($cur eq 'comment_area') { # ���å������� js �����Τ�������̽���
				push(@{$self->[BLOCKS][$num]{'text'}},'{sb_comment_js}');
				push(@{$self->[BLOCKS][$num]{'tags'}},'{sb_comment_js}');
			}
			$num++;
			pop(@stack);
			$cur = $stack[$#stack];
			$self->[BLOCKS][$num] = {};
			$self->[BLOCKS][$num]{'text'} = [];
			$self->[BLOCKS][$num]{'tags'} = [];
			$self->[BLOCKS][$num]{'name'} = $cur;
			next;
		}
		if ($line =~ /\{\w+?\}/) {
			push(@{$self->[BLOCKS][$num]{'tags'}},($line =~ /(\{\w+?\})/g));
		}
		push(@{$self->[BLOCKS][$num]{'text'}},$line);
	}
	return();
}
1; # end of package
