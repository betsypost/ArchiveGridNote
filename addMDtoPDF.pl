#!/usr/bin/perl -w
   
use strict;
use FileHandle;

use Image::ExifTool;
use List::MoreUtils qw(uniq);

my %descriptions;
my %titles;
my %keywords;
my %authors;

main();

#-----------------------------------------------------------------------------
sub main 
{
   my $file = shift @ARGV
	if (@ARGV);							

	readDescription($file);

	# Read filename keys to process

	while ( my ($filename, $title) = each(%titles) ) 
	{
#    		$filename = $filename;

		# Create a new object
		my $exifTool = new Image::ExifTool;
		#$exifTool->Options('ListSplit');
	    
		#Set new values
		$exifTool->SetNewValue('Title', $titles{$filename}, AddValue => 0 );
		$exifTool->SetNewValue('Description', $descriptions{$filename}, AddValue => 0 );
		$exifTool->SetNewValue('Creator', 'John J. Burns Library Boston College', AddValue => 0 );
		$exifTool->SetNewValue('Author', 'John J. Burns Library Boston College', AddValue => 0 );


   		$exifTool->SetNewValue('Keywords');

		#handle subjects keywords

		chomp $keywords{$filename};
		
		my @subjects = split(/;/,$keywords{$filename});

		# de-dupe subjects

		my %seen = ();
		my @uniq_subjects = ();
		foreach my $item (@subjects) {

		$item =~ s/^\s+|^\t+|\s+$|\t+$//g;	
		    unless ($seen{$item}) {
        		# if we get here, we have not seen it before
        		$seen{$item} = 1;
        		push(@uniq_subjects, $item);
    			}
		}
		

		foreach (@uniq_subjects)
		{	
			
      		$_ =~ s/^\s+|^\t+|\s+$|\t+$//g;
			$exifTool->SetNewValue('Subject', $_, AddValue => 0);
			
		}




		#Write new values
		$exifTool->WriteInfo($filename);
		
	} 

}
       

#-----------------------------------------------------------------------------
sub readDescription 
{
    my $file = shift;
    
    my $fh = new FileHandle();
    $fh->open($file);
    
    while( not($fh->eof()) ) 
	{
	my $line = $fh->getline();
	my ($filename, $title, $description, $author, $keywords) = split(/\t/, $line);

	$titles{ $filename } = $title;
	$descriptions{ $filename } = $description;
	$authors{ $filename } = $author;
	$keywords{ $filename } = $keywords;
	
    }
}
=pod
Usage: addMDtoPDF.pl for-enhancing-pdf.txt

input.txt is tab delimited file that includes
1. File name of pdf finding aid
2. title (from MARC record)
3. description (from MARC record)
4. author (from MARC record)
5. keywords (from MARC record)

When run in a folder containing pdf finding aids, the file is identified using the file name and the rest of the metadata in the tab delimited file is embedded into the PDF with the corresponding file name.

betsy.post@bc.edu
Last update 8/15/2016


=cut