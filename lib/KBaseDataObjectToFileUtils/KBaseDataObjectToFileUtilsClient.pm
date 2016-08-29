package KBaseDataObjectToFileUtils::KBaseDataObjectToFileUtilsClient;

use JSON::RPC::Client;
use POSIX;
use strict;
use Data::Dumper;
use URI;
use Bio::KBase::Exceptions;
my $get_time = sub { time, 0 };
eval {
    require Time::HiRes;
    $get_time = sub { Time::HiRes::gettimeofday() };
};

use Bio::KBase::AuthToken;

# Client version should match Impl version
# This is a Semantic Version number,
# http://semver.org
our $VERSION = "0.1.0";

=head1 NAME

KBaseDataObjectToFileUtils::KBaseDataObjectToFileUtilsClient

=head1 DESCRIPTION


** A KBase module: kb_blast
**
** This module contains methods for converting KBase Data Objects to common bioinformatics file formats
**


=cut

sub new
{
    my($class, $url, @args) = @_;
    

    my $self = {
	client => KBaseDataObjectToFileUtils::KBaseDataObjectToFileUtilsClient::RpcClient->new,
	url => $url,
	headers => [],
    };

    chomp($self->{hostname} = `hostname`);
    $self->{hostname} ||= 'unknown-host';

    #
    # Set up for propagating KBRPC_TAG and KBRPC_METADATA environment variables through
    # to invoked services. If these values are not set, we create a new tag
    # and a metadata field with basic information about the invoking script.
    #
    if ($ENV{KBRPC_TAG})
    {
	$self->{kbrpc_tag} = $ENV{KBRPC_TAG};
    }
    else
    {
	my ($t, $us) = &$get_time();
	$us = sprintf("%06d", $us);
	my $ts = strftime("%Y-%m-%dT%H:%M:%S.${us}Z", gmtime $t);
	$self->{kbrpc_tag} = "C:$0:$self->{hostname}:$$:$ts";
    }
    push(@{$self->{headers}}, 'Kbrpc-Tag', $self->{kbrpc_tag});

    if ($ENV{KBRPC_METADATA})
    {
	$self->{kbrpc_metadata} = $ENV{KBRPC_METADATA};
	push(@{$self->{headers}}, 'Kbrpc-Metadata', $self->{kbrpc_metadata});
    }

    if ($ENV{KBRPC_ERROR_DEST})
    {
	$self->{kbrpc_error_dest} = $ENV{KBRPC_ERROR_DEST};
	push(@{$self->{headers}}, 'Kbrpc-Errordest', $self->{kbrpc_error_dest});
    }

    #
    # This module requires authentication.
    #
    # We create an auth token, passing through the arguments that we were (hopefully) given.

    {
	my $token = Bio::KBase::AuthToken->new(@args);
	
	if (!$token->error_message)
	{
	    $self->{token} = $token->token;
	    $self->{client}->{token} = $token->token;
	}
        else
        {
	    #
	    # All methods in this module require authentication. In this case, if we
	    # don't have a token, we can't continue.
	    #
	    die "Authentication failed: " . $token->error_message;
	}
    }

    my $ua = $self->{client}->ua;	 
    my $timeout = $ENV{CDMI_TIMEOUT} || (30 * 60);	 
    $ua->timeout($timeout);
    bless $self, $class;
    #    $self->_validate_version();
    return $self;
}




=head2 TranslateNucToProtSeq

  $return = $obj->TranslateNucToProtSeq($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a KBaseDataObjectToFileUtils.TranslateNucToProtSeq_Params
$return is a KBaseDataObjectToFileUtils.TranslateNucToProtSeq_Output
TranslateNucToProtSeq_Params is a reference to a hash where the following keys are defined:
	nuc_seq has a value which is a string
	genetic_code has a value which is a string
TranslateNucToProtSeq_Output is a reference to a hash where the following keys are defined:
	prot_seq has a value which is a string

</pre>

=end html

=begin text

$params is a KBaseDataObjectToFileUtils.TranslateNucToProtSeq_Params
$return is a KBaseDataObjectToFileUtils.TranslateNucToProtSeq_Output
TranslateNucToProtSeq_Params is a reference to a hash where the following keys are defined:
	nuc_seq has a value which is a string
	genetic_code has a value which is a string
TranslateNucToProtSeq_Output is a reference to a hash where the following keys are defined:
	prot_seq has a value which is a string


=end text

=item Description

Methods for converting KBase Data Objects to common bioinformatics format files
**

=back

=cut

 sub TranslateNucToProtSeq
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function TranslateNucToProtSeq (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to TranslateNucToProtSeq:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'TranslateNucToProtSeq');
	}
    }

    my $url = $self->{url};
    my $result = $self->{client}->call($url, $self->{headers}, {
	    method => "KBaseDataObjectToFileUtils.TranslateNucToProtSeq",
	    params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'TranslateNucToProtSeq',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method TranslateNucToProtSeq",
					    status_line => $self->{client}->status_line,
					    method_name => 'TranslateNucToProtSeq',
				       );
    }
}
 


=head2 GenomeToFASTA

  $return = $obj->GenomeToFASTA($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a KBaseDataObjectToFileUtils.GenomeAnnotationToFASTA_Params
$return is a KBaseDataObjectToFileUtils.GenomeAnnotationToFASTA_Output
GenomeAnnotationToFASTA_Params is a reference to a hash where the following keys are defined:
	genome_ref has a value which is a KBaseDataObjectToFileUtils.data_obj_ref
	file has a value which is a KBaseDataObjectToFileUtils.path_type
	dir has a value which is a KBaseDataObjectToFileUtils.path_type
	console has a value which is a reference to a list where each element is a KBaseDataObjectToFileUtils.log_msg
	invalid_msgs has a value which is a reference to a list where each element is a KBaseDataObjectToFileUtils.log_msg
	residue_type has a value which is a string
	feature_type has a value which is a string
	record_id_pattern has a value which is a KBaseDataObjectToFileUtils.pattern_type
	record_desc_pattern has a value which is a KBaseDataObjectToFileUtils.pattern_type
	case has a value which is a string
	linewrap has a value which is an int
data_obj_ref is a string
path_type is a string
log_msg is a string
pattern_type is a string
GenomeAnnotationToFASTA_Output is a reference to a hash where the following keys are defined:
	fasta_file_path has a value which is a KBaseDataObjectToFileUtils.path_type
	feature_ids has a value which is a reference to a list where each element is a string

</pre>

=end html

=begin text

$params is a KBaseDataObjectToFileUtils.GenomeAnnotationToFASTA_Params
$return is a KBaseDataObjectToFileUtils.GenomeAnnotationToFASTA_Output
GenomeAnnotationToFASTA_Params is a reference to a hash where the following keys are defined:
	genome_ref has a value which is a KBaseDataObjectToFileUtils.data_obj_ref
	file has a value which is a KBaseDataObjectToFileUtils.path_type
	dir has a value which is a KBaseDataObjectToFileUtils.path_type
	console has a value which is a reference to a list where each element is a KBaseDataObjectToFileUtils.log_msg
	invalid_msgs has a value which is a reference to a list where each element is a KBaseDataObjectToFileUtils.log_msg
	residue_type has a value which is a string
	feature_type has a value which is a string
	record_id_pattern has a value which is a KBaseDataObjectToFileUtils.pattern_type
	record_desc_pattern has a value which is a KBaseDataObjectToFileUtils.pattern_type
	case has a value which is a string
	linewrap has a value which is an int
data_obj_ref is a string
path_type is a string
log_msg is a string
pattern_type is a string
GenomeAnnotationToFASTA_Output is a reference to a hash where the following keys are defined:
	fasta_file_path has a value which is a KBaseDataObjectToFileUtils.path_type
	feature_ids has a value which is a reference to a list where each element is a string


=end text

=item Description

this should not be used, but is temporarily being retained to compare speed

=back

=cut

 sub GenomeToFASTA
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function GenomeToFASTA (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to GenomeToFASTA:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'GenomeToFASTA');
	}
    }

    my $url = $self->{url};
    my $result = $self->{client}->call($url, $self->{headers}, {
	    method => "KBaseDataObjectToFileUtils.GenomeToFASTA",
	    params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'GenomeToFASTA',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method GenomeToFASTA",
					    status_line => $self->{client}->status_line,
					    method_name => 'GenomeToFASTA',
				       );
    }
}
 


=head2 GenomeAnnotationToFASTA

  $return = $obj->GenomeAnnotationToFASTA($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a KBaseDataObjectToFileUtils.GenomeAnnotationToFASTA_Params
$return is a KBaseDataObjectToFileUtils.GenomeAnnotationToFASTA_Output
GenomeAnnotationToFASTA_Params is a reference to a hash where the following keys are defined:
	genome_ref has a value which is a KBaseDataObjectToFileUtils.data_obj_ref
	file has a value which is a KBaseDataObjectToFileUtils.path_type
	dir has a value which is a KBaseDataObjectToFileUtils.path_type
	console has a value which is a reference to a list where each element is a KBaseDataObjectToFileUtils.log_msg
	invalid_msgs has a value which is a reference to a list where each element is a KBaseDataObjectToFileUtils.log_msg
	residue_type has a value which is a string
	feature_type has a value which is a string
	record_id_pattern has a value which is a KBaseDataObjectToFileUtils.pattern_type
	record_desc_pattern has a value which is a KBaseDataObjectToFileUtils.pattern_type
	case has a value which is a string
	linewrap has a value which is an int
data_obj_ref is a string
path_type is a string
log_msg is a string
pattern_type is a string
GenomeAnnotationToFASTA_Output is a reference to a hash where the following keys are defined:
	fasta_file_path has a value which is a KBaseDataObjectToFileUtils.path_type
	feature_ids has a value which is a reference to a list where each element is a string

</pre>

=end html

=begin text

$params is a KBaseDataObjectToFileUtils.GenomeAnnotationToFASTA_Params
$return is a KBaseDataObjectToFileUtils.GenomeAnnotationToFASTA_Output
GenomeAnnotationToFASTA_Params is a reference to a hash where the following keys are defined:
	genome_ref has a value which is a KBaseDataObjectToFileUtils.data_obj_ref
	file has a value which is a KBaseDataObjectToFileUtils.path_type
	dir has a value which is a KBaseDataObjectToFileUtils.path_type
	console has a value which is a reference to a list where each element is a KBaseDataObjectToFileUtils.log_msg
	invalid_msgs has a value which is a reference to a list where each element is a KBaseDataObjectToFileUtils.log_msg
	residue_type has a value which is a string
	feature_type has a value which is a string
	record_id_pattern has a value which is a KBaseDataObjectToFileUtils.pattern_type
	record_desc_pattern has a value which is a KBaseDataObjectToFileUtils.pattern_type
	case has a value which is a string
	linewrap has a value which is an int
data_obj_ref is a string
path_type is a string
log_msg is a string
pattern_type is a string
GenomeAnnotationToFASTA_Output is a reference to a hash where the following keys are defined:
	fasta_file_path has a value which is a KBaseDataObjectToFileUtils.path_type
	feature_ids has a value which is a reference to a list where each element is a string


=end text

=item Description



=back

=cut

 sub GenomeAnnotationToFASTA
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function GenomeAnnotationToFASTA (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to GenomeAnnotationToFASTA:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'GenomeAnnotationToFASTA');
	}
    }

    my $url = $self->{url};
    my $result = $self->{client}->call($url, $self->{headers}, {
	    method => "KBaseDataObjectToFileUtils.GenomeAnnotationToFASTA",
	    params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'GenomeAnnotationToFASTA',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method GenomeAnnotationToFASTA",
					    status_line => $self->{client}->status_line,
					    method_name => 'GenomeAnnotationToFASTA',
				       );
    }
}
 


=head2 GenomeSetToFASTA

  $return = $obj->GenomeSetToFASTA($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a KBaseDataObjectToFileUtils.GenomeSetToFASTA_Params
$return is a KBaseDataObjectToFileUtils.GenomeSetToFASTA_Output
GenomeSetToFASTA_Params is a reference to a hash where the following keys are defined:
	genomeSet_ref has a value which is a KBaseDataObjectToFileUtils.data_obj_ref
	file has a value which is a KBaseDataObjectToFileUtils.path_type
	dir has a value which is a KBaseDataObjectToFileUtils.path_type
	console has a value which is a reference to a list where each element is a KBaseDataObjectToFileUtils.log_msg
	invalid_msgs has a value which is a reference to a list where each element is a KBaseDataObjectToFileUtils.log_msg
	residue_type has a value which is a string
	feature_type has a value which is a string
	record_id_pattern has a value which is a KBaseDataObjectToFileUtils.pattern_type
	record_desc_pattern has a value which is a KBaseDataObjectToFileUtils.pattern_type
	case has a value which is a string
	linewrap has a value which is an int
data_obj_ref is a string
path_type is a string
log_msg is a string
pattern_type is a string
GenomeSetToFASTA_Output is a reference to a hash where the following keys are defined:
	fasta_file_path has a value which is a KBaseDataObjectToFileUtils.path_type
	feature_ids has a value which is a reference to a list where each element is a string

</pre>

=end html

=begin text

$params is a KBaseDataObjectToFileUtils.GenomeSetToFASTA_Params
$return is a KBaseDataObjectToFileUtils.GenomeSetToFASTA_Output
GenomeSetToFASTA_Params is a reference to a hash where the following keys are defined:
	genomeSet_ref has a value which is a KBaseDataObjectToFileUtils.data_obj_ref
	file has a value which is a KBaseDataObjectToFileUtils.path_type
	dir has a value which is a KBaseDataObjectToFileUtils.path_type
	console has a value which is a reference to a list where each element is a KBaseDataObjectToFileUtils.log_msg
	invalid_msgs has a value which is a reference to a list where each element is a KBaseDataObjectToFileUtils.log_msg
	residue_type has a value which is a string
	feature_type has a value which is a string
	record_id_pattern has a value which is a KBaseDataObjectToFileUtils.pattern_type
	record_desc_pattern has a value which is a KBaseDataObjectToFileUtils.pattern_type
	case has a value which is a string
	linewrap has a value which is an int
data_obj_ref is a string
path_type is a string
log_msg is a string
pattern_type is a string
GenomeSetToFASTA_Output is a reference to a hash where the following keys are defined:
	fasta_file_path has a value which is a KBaseDataObjectToFileUtils.path_type
	feature_ids has a value which is a reference to a list where each element is a string


=end text

=item Description



=back

=cut

 sub GenomeSetToFASTA
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function GenomeSetToFASTA (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to GenomeSetToFASTA:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'GenomeSetToFASTA');
	}
    }

    my $url = $self->{url};
    my $result = $self->{client}->call($url, $self->{headers}, {
	    method => "KBaseDataObjectToFileUtils.GenomeSetToFASTA",
	    params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'GenomeSetToFASTA',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method GenomeSetToFASTA",
					    status_line => $self->{client}->status_line,
					    method_name => 'GenomeSetToFASTA',
				       );
    }
}
 


=head2 FeatureSetToFASTA

  $return = $obj->FeatureSetToFASTA($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a KBaseDataObjectToFileUtils.FeatureSetToFASTA_Params
$return is a KBaseDataObjectToFileUtils.FeatureSetToFASTA_Output
FeatureSetToFASTA_Params is a reference to a hash where the following keys are defined:
	featureSet_ref has a value which is a KBaseDataObjectToFileUtils.data_obj_ref
	file has a value which is a KBaseDataObjectToFileUtils.path_type
	dir has a value which is a KBaseDataObjectToFileUtils.path_type
	console has a value which is a reference to a list where each element is a KBaseDataObjectToFileUtils.log_msg
	invalid_msgs has a value which is a reference to a list where each element is a KBaseDataObjectToFileUtils.log_msg
	residue_type has a value which is a string
	feature_type has a value which is a string
	record_id_pattern has a value which is a KBaseDataObjectToFileUtils.pattern_type
	record_desc_pattern has a value which is a KBaseDataObjectToFileUtils.pattern_type
	case has a value which is a string
	linewrap has a value which is an int
data_obj_ref is a string
path_type is a string
log_msg is a string
pattern_type is a string
FeatureSetToFASTA_Output is a reference to a hash where the following keys are defined:
	fasta_file_path has a value which is a KBaseDataObjectToFileUtils.path_type
	feature_ids has a value which is a reference to a list where each element is a string

</pre>

=end html

=begin text

$params is a KBaseDataObjectToFileUtils.FeatureSetToFASTA_Params
$return is a KBaseDataObjectToFileUtils.FeatureSetToFASTA_Output
FeatureSetToFASTA_Params is a reference to a hash where the following keys are defined:
	featureSet_ref has a value which is a KBaseDataObjectToFileUtils.data_obj_ref
	file has a value which is a KBaseDataObjectToFileUtils.path_type
	dir has a value which is a KBaseDataObjectToFileUtils.path_type
	console has a value which is a reference to a list where each element is a KBaseDataObjectToFileUtils.log_msg
	invalid_msgs has a value which is a reference to a list where each element is a KBaseDataObjectToFileUtils.log_msg
	residue_type has a value which is a string
	feature_type has a value which is a string
	record_id_pattern has a value which is a KBaseDataObjectToFileUtils.pattern_type
	record_desc_pattern has a value which is a KBaseDataObjectToFileUtils.pattern_type
	case has a value which is a string
	linewrap has a value which is an int
data_obj_ref is a string
path_type is a string
log_msg is a string
pattern_type is a string
FeatureSetToFASTA_Output is a reference to a hash where the following keys are defined:
	fasta_file_path has a value which is a KBaseDataObjectToFileUtils.path_type
	feature_ids has a value which is a reference to a list where each element is a string


=end text

=item Description



=back

=cut

 sub FeatureSetToFASTA
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function FeatureSetToFASTA (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to FeatureSetToFASTA:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'FeatureSetToFASTA');
	}
    }

    my $url = $self->{url};
    my $result = $self->{client}->call($url, $self->{headers}, {
	    method => "KBaseDataObjectToFileUtils.FeatureSetToFASTA",
	    params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'FeatureSetToFASTA',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method FeatureSetToFASTA",
					    status_line => $self->{client}->status_line,
					    method_name => 'FeatureSetToFASTA',
				       );
    }
}
 
  
sub status
{
    my($self, @args) = @_;
    if ((my $n = @args) != 0) {
        Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
                                   "Invalid argument count for function status (received $n, expecting 0)");
    }
    my $url = $self->{url};
    my $result = $self->{client}->call($url, $self->{headers}, {
        method => "KBaseDataObjectToFileUtils.status",
        params => \@args,
    });
    if ($result) {
        if ($result->is_error) {
            Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
                           code => $result->content->{error}->{code},
                           method_name => 'status',
                           data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
                          );
        } else {
            return wantarray ? @{$result->result} : $result->result->[0];
        }
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method status",
                        status_line => $self->{client}->status_line,
                        method_name => 'status',
                       );
    }
}
   

sub version {
    my ($self) = @_;
    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
        method => "KBaseDataObjectToFileUtils.version",
        params => [],
    });
    if ($result) {
        if ($result->is_error) {
            Bio::KBase::Exceptions::JSONRPC->throw(
                error => $result->error_message,
                code => $result->content->{code},
                method_name => 'FeatureSetToFASTA',
            );
        } else {
            return wantarray ? @{$result->result} : $result->result->[0];
        }
    } else {
        Bio::KBase::Exceptions::HTTP->throw(
            error => "Error invoking method FeatureSetToFASTA",
            status_line => $self->{client}->status_line,
            method_name => 'FeatureSetToFASTA',
        );
    }
}

sub _validate_version {
    my ($self) = @_;
    my $svr_version = $self->version();
    my $client_version = $VERSION;
    my ($cMajor, $cMinor) = split(/\./, $client_version);
    my ($sMajor, $sMinor) = split(/\./, $svr_version);
    if ($sMajor != $cMajor) {
        Bio::KBase::Exceptions::ClientServerIncompatible->throw(
            error => "Major version numbers differ.",
            server_version => $svr_version,
            client_version => $client_version
        );
    }
    if ($sMinor < $cMinor) {
        Bio::KBase::Exceptions::ClientServerIncompatible->throw(
            error => "Client minor version greater than Server minor version.",
            server_version => $svr_version,
            client_version => $client_version
        );
    }
    if ($sMinor > $cMinor) {
        warn "New client version available for KBaseDataObjectToFileUtils::KBaseDataObjectToFileUtilsClient\n";
    }
    if ($sMajor == 0) {
        warn "KBaseDataObjectToFileUtils::KBaseDataObjectToFileUtilsClient version is $svr_version. API subject to change.\n";
    }
}

=head1 TYPES



=head2 workspace_name

=over 4



=item Description

** The workspace object refs are of form:
**
**    objects = ws.get_objects([{'ref': params['workspace_id']+'/'+params['obj_name']}])
**
** "ref" means the entire name combining the workspace id and the object name
** "id" is a numerical identifier of the workspace or object, and should just be used for workspace
** "name" is a string identifier of a workspace or object.  This is received from Narrative.


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 sequence

=over 4



=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 data_obj_name

=over 4



=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 data_obj_ref

=over 4



=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 path_type

=over 4



=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 pattern_type

=over 4



=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 log_msg

=over 4



=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 TranslateNucToProtSeq_Params

=over 4



=item Description

TranslateNucToProtSeq() Params


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
nuc_seq has a value which is a string
genetic_code has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
nuc_seq has a value which is a string
genetic_code has a value which is a string


=end text

=back



=head2 TranslateNucToProtSeq_Output

=over 4



=item Description

TranslateNucToProtSeq() Output


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
prot_seq has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
prot_seq has a value which is a string


=end text

=back



=head2 GenomeAnnotationToFASTA_Params

=over 4



=item Description

GenomeAnnotationToFASTA() Params


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
genome_ref has a value which is a KBaseDataObjectToFileUtils.data_obj_ref
file has a value which is a KBaseDataObjectToFileUtils.path_type
dir has a value which is a KBaseDataObjectToFileUtils.path_type
console has a value which is a reference to a list where each element is a KBaseDataObjectToFileUtils.log_msg
invalid_msgs has a value which is a reference to a list where each element is a KBaseDataObjectToFileUtils.log_msg
residue_type has a value which is a string
feature_type has a value which is a string
record_id_pattern has a value which is a KBaseDataObjectToFileUtils.pattern_type
record_desc_pattern has a value which is a KBaseDataObjectToFileUtils.pattern_type
case has a value which is a string
linewrap has a value which is an int

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
genome_ref has a value which is a KBaseDataObjectToFileUtils.data_obj_ref
file has a value which is a KBaseDataObjectToFileUtils.path_type
dir has a value which is a KBaseDataObjectToFileUtils.path_type
console has a value which is a reference to a list where each element is a KBaseDataObjectToFileUtils.log_msg
invalid_msgs has a value which is a reference to a list where each element is a KBaseDataObjectToFileUtils.log_msg
residue_type has a value which is a string
feature_type has a value which is a string
record_id_pattern has a value which is a KBaseDataObjectToFileUtils.pattern_type
record_desc_pattern has a value which is a KBaseDataObjectToFileUtils.pattern_type
case has a value which is a string
linewrap has a value which is an int


=end text

=back



=head2 GenomeAnnotationToFASTA_Output

=over 4



=item Description

GenomeAnnotationToFASTA() Output


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
fasta_file_path has a value which is a KBaseDataObjectToFileUtils.path_type
feature_ids has a value which is a reference to a list where each element is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
fasta_file_path has a value which is a KBaseDataObjectToFileUtils.path_type
feature_ids has a value which is a reference to a list where each element is a string


=end text

=back



=head2 GenomeSetToFASTA_Params

=over 4



=item Description

GenomeSetToFASTA() Params


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
genomeSet_ref has a value which is a KBaseDataObjectToFileUtils.data_obj_ref
file has a value which is a KBaseDataObjectToFileUtils.path_type
dir has a value which is a KBaseDataObjectToFileUtils.path_type
console has a value which is a reference to a list where each element is a KBaseDataObjectToFileUtils.log_msg
invalid_msgs has a value which is a reference to a list where each element is a KBaseDataObjectToFileUtils.log_msg
residue_type has a value which is a string
feature_type has a value which is a string
record_id_pattern has a value which is a KBaseDataObjectToFileUtils.pattern_type
record_desc_pattern has a value which is a KBaseDataObjectToFileUtils.pattern_type
case has a value which is a string
linewrap has a value which is an int

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
genomeSet_ref has a value which is a KBaseDataObjectToFileUtils.data_obj_ref
file has a value which is a KBaseDataObjectToFileUtils.path_type
dir has a value which is a KBaseDataObjectToFileUtils.path_type
console has a value which is a reference to a list where each element is a KBaseDataObjectToFileUtils.log_msg
invalid_msgs has a value which is a reference to a list where each element is a KBaseDataObjectToFileUtils.log_msg
residue_type has a value which is a string
feature_type has a value which is a string
record_id_pattern has a value which is a KBaseDataObjectToFileUtils.pattern_type
record_desc_pattern has a value which is a KBaseDataObjectToFileUtils.pattern_type
case has a value which is a string
linewrap has a value which is an int


=end text

=back



=head2 GenomeSetToFASTA_Output

=over 4



=item Description

GenomeSetToFASTA() Output


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
fasta_file_path has a value which is a KBaseDataObjectToFileUtils.path_type
feature_ids has a value which is a reference to a list where each element is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
fasta_file_path has a value which is a KBaseDataObjectToFileUtils.path_type
feature_ids has a value which is a reference to a list where each element is a string


=end text

=back



=head2 FeatureSetToFASTA_Params

=over 4



=item Description

FeatureSetToFASTA() Params


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
featureSet_ref has a value which is a KBaseDataObjectToFileUtils.data_obj_ref
file has a value which is a KBaseDataObjectToFileUtils.path_type
dir has a value which is a KBaseDataObjectToFileUtils.path_type
console has a value which is a reference to a list where each element is a KBaseDataObjectToFileUtils.log_msg
invalid_msgs has a value which is a reference to a list where each element is a KBaseDataObjectToFileUtils.log_msg
residue_type has a value which is a string
feature_type has a value which is a string
record_id_pattern has a value which is a KBaseDataObjectToFileUtils.pattern_type
record_desc_pattern has a value which is a KBaseDataObjectToFileUtils.pattern_type
case has a value which is a string
linewrap has a value which is an int

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
featureSet_ref has a value which is a KBaseDataObjectToFileUtils.data_obj_ref
file has a value which is a KBaseDataObjectToFileUtils.path_type
dir has a value which is a KBaseDataObjectToFileUtils.path_type
console has a value which is a reference to a list where each element is a KBaseDataObjectToFileUtils.log_msg
invalid_msgs has a value which is a reference to a list where each element is a KBaseDataObjectToFileUtils.log_msg
residue_type has a value which is a string
feature_type has a value which is a string
record_id_pattern has a value which is a KBaseDataObjectToFileUtils.pattern_type
record_desc_pattern has a value which is a KBaseDataObjectToFileUtils.pattern_type
case has a value which is a string
linewrap has a value which is an int


=end text

=back



=head2 FeatureSetToFASTA_Output

=over 4



=item Description

FeatureSetToFASTA() Output


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
fasta_file_path has a value which is a KBaseDataObjectToFileUtils.path_type
feature_ids has a value which is a reference to a list where each element is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
fasta_file_path has a value which is a KBaseDataObjectToFileUtils.path_type
feature_ids has a value which is a reference to a list where each element is a string


=end text

=back



=cut

package KBaseDataObjectToFileUtils::KBaseDataObjectToFileUtilsClient::RpcClient;
use base 'JSON::RPC::Client';
use POSIX;
use strict;

#
# Override JSON::RPC::Client::call because it doesn't handle error returns properly.
#

sub call {
    my ($self, $uri, $headers, $obj) = @_;
    my $result;


    {
	if ($uri =~ /\?/) {
	    $result = $self->_get($uri);
	}
	else {
	    Carp::croak "not hashref." unless (ref $obj eq 'HASH');
	    $result = $self->_post($uri, $headers, $obj);
	}

    }

    my $service = $obj->{method} =~ /^system\./ if ( $obj );

    $self->status_line($result->status_line);

    if ($result->is_success) {

        return unless($result->content); # notification?

        if ($service) {
            return JSON::RPC::ServiceObject->new($result, $self->json);
        }

        return JSON::RPC::ReturnObject->new($result, $self->json);
    }
    elsif ($result->content_type eq 'application/json')
    {
        return JSON::RPC::ReturnObject->new($result, $self->json);
    }
    else {
        return;
    }
}


sub _post {
    my ($self, $uri, $headers, $obj) = @_;
    my $json = $self->json;

    $obj->{version} ||= $self->{version} || '1.1';

    if ($obj->{version} eq '1.0') {
        delete $obj->{version};
        if (exists $obj->{id}) {
            $self->id($obj->{id}) if ($obj->{id}); # if undef, it is notification.
        }
        else {
            $obj->{id} = $self->id || ($self->id('JSON::RPC::Client'));
        }
    }
    else {
        # $obj->{id} = $self->id if (defined $self->id);
	# Assign a random number to the id if one hasn't been set
	$obj->{id} = (defined $self->id) ? $self->id : substr(rand(),2);
    }

    my $content = $json->encode($obj);

    $self->ua->post(
        $uri,
        Content_Type   => $self->{content_type},
        Content        => $content,
        Accept         => 'application/json',
	@$headers,
	($self->{token} ? (Authorization => $self->{token}) : ()),
    );
}



1;
