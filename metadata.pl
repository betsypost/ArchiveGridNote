#!C:/Perl/bin/perl -w
use strict;

use IO::File;
use utf8;
                                           

#Open file for output
my $outputfile = "output.txt";

my $fh = IO::File->new($outputfile, 'w')
	or die "unable to open output file for writing: $!";
binmode($fh, ':utf8');

#Call MARC reformatter
MARCreformatter();

#Close output file
$fh->close();


#########
#########
sub MARCreformatter {
#########
#opens a .mrk file (converted by MARCedit) and grabs some metadata from our finding aid project

	#change PERL default record delimiter
	$/="\n\n";

	while (<>) #here, ARGV is the MARC file
	{ 		
		chomp;
		my $record=$_;

		#get system number
		$record =~/=001\s\s(\d*)\n/;   ##get sys no from MARC record
		my $sysno=$1;


		#find some more MARC fields
		my $title;
		my $author;
		my $description;
		my $keywords;
				
		my @record_parts = split(/\n/, $record);
		foreach my $record_part (@record_parts) 
			{


				if ($record_part =~ m/245\s\s\d\d\$a/) 
					{	#identify title
						$title = substr($record_part,10); 
						$title = substr($title, 0, index($title, '$'));
						$title =~s/[.,]$//g;
						print "title is: $title\n";

					} 
						

				$author = "Boston College John J. Burns Library";


				if ($record_part =~ m/=520/) 
					{	#identify description (i.e. abstract)
						$description = $description.substr($record_part,10); 
						print "description is: $description\n";	
		
					} 

				if ($record_part =~ m/=6/) 
					{	#identify keywords
						my $is_genre=0;
						my $is_personal=0;
						if ($record_part =~ m/=655/) { $is_genre=1}
						if ($record_part =~ m/=600/) { $is_personal=1}

						$record_part = substr($record_part,10); 
						$record_part = substr($record_part, 0, index($record_part, '$'));

						
						if ($is_genre==1) {$record_part =~ s/\.$//}
						if ($is_personal==1) 
							{
								print "is personal\n";
								$record_part =~  s/,$//;
								$record_part =~  m/(^.*), (.*)/;
								$record_part = $2.' '.$1;
								print "first name is $2\n";
								print "last name is $1\n";
							}
						if ($record_part =~  m/[A-Za-z]{2,}\.$/)
							{
								$record_part =~  s/\.$//;
							}
						$record_part=~ s/^\s+|^\t+|\s+$|\t+$//g;
						$record_part=~ s/,//g;

						
						
						if ($keywords) {$keywords = $keywords.','.$record_part}
						else {$keywords = $record_part}

						


					} 
			
				
        		}
					print "$keywords\n";
			$fh->print("$sysno\t$title\t$author\t$description\t$keywords\n");	

	}


};
=pod
Usage: metadata.pl records.mrk

records.mrk is a file of MARC records that have been converted to the .mrk format using MARC edit.

The records are for collections that have pdf finding aids.  The script pulls out metadata that would be useful for enhancing the pdf properties of finding aids and puts them into a tab delimited file

betsy.post@bc.edu
Last update 8/15/2016


=cut


