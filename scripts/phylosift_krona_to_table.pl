#!/usr/bin/perl -w
use strict;
use Getopt::Std;

# - - - - - H E A D E R - - - - - - - - - - - - - - - - -
#Goals of script:
#Parse krona plot result from phylosift.
#Input: folder with phylosift result folders in it.
#Process:
#	1. Load taxonomic hierarchy and abundance values.
#	2. Report phyla and class majority.
#	3. Determine if any deep taxonomic level represents a majority.
#	4. Report Kingdom, Phylumn, Class majorities and a deeper tax if present.

# - - - - - U S E R    V A R I A B L E S - - - - - - - -


# - - - - - G L O B A L  V A R I A B L E S  - - - - - -
my %options=();
getopts("p:x:r:h", \%options);

if ($options{h})
    {   print "\n\nHelp called:\nOptions:\n";
        print "-p = path to folder containing folders of phylosift results\n";
        print "-x = folder suffix\n";
	print "-r = folder prefix\n";
	print "-h = This help message\n\n";
	die;
    }

my %Bin_taxonomy;

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - M A I N - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


##Read Krona html
if (exists $options{x})
{
opendir(DIR, "$options{p}") or die "\n\nNada $options{p} you fool!!\n\n";
my $unid = 10001;
while (my $file = readdir(DIR))
    {	my $foldersuffix = qr/$options{x}/;
        $file =~ m/(.+)$foldersuffix$/;
	my $basename = $1;
	if ($file =~ m/$foldersuffix$/)
            {	$Bin_taxonomy{$unid}{'LIVE'} = 'FALSE';
		$Bin_taxonomy{$unid}{'Name'} = $basename;
		open(IN, "<".$options{p}."/".$file."/".$basename.".html") or die "\n\nNADA path to ".$options{p}."/".$basename.".html you FOOL!!!\n\n";
		my @html_data = <IN>; close(IN);
		foreach my $line (@html_data)
			{	if ($line =~ m/^\<br\>\<krona .+/)
					{	$Bin_taxonomy{$unid}{'LIVE'} = 'TRUE';
						my %Depth;
						$Depth{10}{'switch'} = 1;	#NULL Switch
						$Depth{10}{'count'} = 0;
						$Depth{11}{'switch'} = 0;	#Root
						$Depth{11}{'count'} = 0;
						$Depth{12}{'switch'} = 0;	#Cellular organisms
						$Depth{12}{'count'} = 0;
						$Depth{13}{'switch'} = 0;	#Domain
						$Depth{13}{'count'} = 0;
						$Depth{14}{'switch'} = 0;	#Phylum/Division
						$Depth{14}{'count'} = 0;
						$Depth{15}{'switch'} = 0;	#Class/Phylum
						$Depth{15}{'count'} = 0;
						$Depth{16}{'switch'} = 0;	#Order/Class
						$Depth{16}{'count'} = 0;
						$Depth{17}{'switch'} = 0;	#Family/Order
						$Depth{17}{'count'} = 0;
						$Depth{18}{'switch'} = 0;	#Genus/Family
						$Depth{18}{'count'} = 0;
						$Depth{19}{'switch'} = 0;	#Species/Genus
						$Depth{19}{'count'} = 0;
						$Depth{20}{'switch'} = 0;	#Genome/Species
						$Depth{20}{'count'} = 0;
						$Depth{21}{'switch'} = 0;	#Genome
						$Depth{21}{'count'} = 0;
						$Depth{22}{'switch'} = 0;	#Just in case
						$Depth{22}{'count'} = 0;
						$Depth{23}{'switch'} = 0;	# Shouldn't need. Warn if reach here.
						$Depth{23}{'count'} = 0;
						my @linesplit = split('><', $line);
						#foreach my $i (@linesplit){print "$i\n";} print "\n\n\n";
						#foreach my $i (sort keys %Depth){print "$i\n";}
						foreach my $carrots (@linesplit)
							{	#foreach my $i (sort keys %Depth){if ($Depth{$i}{'switch'} == 1){print "NODE IS NOW DEPTH $i\n";}}
								if ($carrots =~ m/^node/)
									{	foreach my $i (sort keys %Depth)
											{	if ($Depth{$i}{'switch'} == 1)
													{	my $number = $i;
														my $nextnumber = $number + 1;
														$Depth{$i}{'switch'} = 0;
														$Depth{$nextnumber}{'switch'} = 1;
														$Depth{$nextnumber}{'count'} += 1;
														$carrots =~ m/.+name=\"(.+)\" href.+/;
														my $name = $1;
														$Bin_taxonomy{$unid}{"depth_".$nextnumber}{'name_'.$Depth{$nextnumber}{'count'}} = $name;
														#print "NAME = $name\n";
														if ($nextnumber > 23)
															{	my $taxdept = $nextnumber - 10; 
																#print "WARNING: It seems that you have a greater taxonomic depth than expected. Depth = $taxdept\n";
															}
														last;
													}
											}
									}
								if ($carrots =~ m/^val\>/)
									{	foreach my $i (sort keys %Depth)
											{	if ($Depth{$i}{'switch'} == 1)
													{	$carrots =~ m/^val\>(.+)\<\/val$/;
														my $abund = $1;
														$Bin_taxonomy{$unid}{"depth_".$i}{'abundance_'.$Depth{$i}{'count'}} = $abund;
														#print "ABUND = $abund\n";
													}
											}
									
									}
								if ($carrots =~ m/^\/node/)
									{	foreach my $i (sort keys %Depth)
											{	if ($Depth{$i}{'switch'} == 1)
													{	my $number = $i;
														my $prevnumber = $i - 1;
														$Depth{$i}{'switch'} = 0;
														$Depth{$prevnumber}{'switch'} = 1;
														last;	
													}
											}	
									}
							}
						foreach my $i (sort keys %Depth)
							{ 	$Bin_taxonomy{$unid}{"depth_".$i}{'count'} = $Depth{$i}{'count'};}
					}	
			} 
            }
	$unid += 1;
    }
}

if (exists $options{r})
{
opendir(DIR, "$options{p}") or die "\n\nNada $options{p} you fool!!\n\n";
my $unid = 10001;
while (my $file = readdir(DIR))
    {	my $folderprefix = qr/$options{r}/;
        $file =~ m/^$folderprefix(.+)/;
	my $basename = $1;
	if ($file =~ m/^$folderprefix/)
            {	$Bin_taxonomy{$unid}{'LIVE'} = 'FALSE';
		$Bin_taxonomy{$unid}{'Name'} = $basename;
		open(IN, "<".$options{p}."/".$file."/".$basename.".html") or die "\n\nNADA path to ".$options{p}."/".$file."/".$basename.".fa.html you FOOL!!!\n\n";
		my @html_data = <IN>; close(IN);
		foreach my $line (@html_data)
			{	if ($line =~ m/^\<br\>\<krona .+/)
					{	$Bin_taxonomy{$unid}{'LIVE'} = 'TRUE';
						my %Depth;
						$Depth{10}{'switch'} = 1;	#NULL Switch
						$Depth{10}{'count'} = 0;
						$Depth{11}{'switch'} = 0;	#Root
						$Depth{11}{'count'} = 0;
						$Depth{12}{'switch'} = 0;	#Cellular organisms
						$Depth{12}{'count'} = 0;
						$Depth{13}{'switch'} = 0;	#Domain
						$Depth{13}{'count'} = 0;
						$Depth{14}{'switch'} = 0;	#Phylum/Division
						$Depth{14}{'count'} = 0;
						$Depth{15}{'switch'} = 0;	#Class/Phylum
						$Depth{15}{'count'} = 0;
						$Depth{16}{'switch'} = 0;	#Order/Class
						$Depth{16}{'count'} = 0;
						$Depth{17}{'switch'} = 0;	#Family/Order
						$Depth{17}{'count'} = 0;
						$Depth{18}{'switch'} = 0;	#Genus/Family
						$Depth{18}{'count'} = 0;
						$Depth{19}{'switch'} = 0;	#Species/Genus
						$Depth{19}{'count'} = 0;
						$Depth{20}{'switch'} = 0;	#Genome/Species
						$Depth{20}{'count'} = 0;
						$Depth{21}{'switch'} = 0;	#Genome
						$Depth{21}{'count'} = 0;
						$Depth{22}{'switch'} = 0;	#Just in case
						$Depth{22}{'count'} = 0;
						$Depth{23}{'switch'} = 0;	# Shouldn't need. Warn if reach here.
						$Depth{23}{'count'} = 0;
						my @linesplit = split('><', $line);
						#foreach my $i (@linesplit){print "$i\n";} print "\n\n\n";
						#foreach my $i (sort keys %Depth){print "$i\n";}
						foreach my $carrots (@linesplit)
							{	#foreach my $i (sort keys %Depth){if ($Depth{$i}{'switch'} == 1){print "NODE IS NOW DEPTH $i\n";}}
								if ($carrots =~ m/^node/)
									{	foreach my $i (sort keys %Depth)
											{	if ($Depth{$i}{'switch'} == 1)
													{	my $number = $i;
														my $nextnumber = $number + 1;
														$Depth{$i}{'switch'} = 0;
														$Depth{$nextnumber}{'switch'} = 1;
														$Depth{$nextnumber}{'count'} += 1;
														$carrots =~ m/.+name=\"(.+)\" href.+/;
														my $name = $1;
														$Bin_taxonomy{$unid}{"depth_".$nextnumber}{'name_'.$Depth{$nextnumber}{'count'}} = $name;
														#print "NAME = $name\n";
														if ($nextnumber > 23)
															{	my $taxdept = $nextnumber - 10; 
																print "WARNING: It seems that you have a greater taxonomic depth than expected. Depth = $taxdept\n";
															}
														last;
													}
											}
									}
								if ($carrots =~ m/^val\>/)
									{	foreach my $i (sort keys %Depth)
											{	if ($Depth{$i}{'switch'} == 1)
													{	$carrots =~ m/^val\>(.+)\<\/val$/;
														my $abund = $1;
														$Bin_taxonomy{$unid}{"depth_".$i}{'abundance_'.$Depth{$i}{'count'}} = $abund;
														#print "ABUND = $abund\n";
													}
											}
									
									}
								if ($carrots =~ m/^\/node/)
									{	foreach my $i (sort keys %Depth)
											{	if ($Depth{$i}{'switch'} == 1)
													{	my $number = $i;
														my $prevnumber = $i - 1;
														$Depth{$i}{'switch'} = 0;
														$Depth{$prevnumber}{'switch'} = 1;
														last;	
													}
											}	
									}
							}
						foreach my $i (sort keys %Depth)
							{ 	$Bin_taxonomy{$unid}{"depth_".$i}{'count'} = $Depth{$i}{'count'};}
					}	
			} 
            }
	$unid += 1;
    }
}


####Make decisions
foreach my $bin (sort keys %Bin_taxonomy)
	{	if ($Bin_taxonomy{$bin}{'LIVE'} eq 'TRUE')
		{#print "$Bin_taxonomy{$bin}{'Name'}\n";
		my %Layers;
		foreach my $depth (11..23)
			{	my $depth_count = $Bin_taxonomy{$bin}{"depth_".$depth}{'count'};
				my $total_assigned_depth_abund = 0;
				foreach my $c (1..$Bin_taxonomy{$bin}{"depth_".$depth}{'count'})
					{$total_assigned_depth_abund += $Bin_taxonomy{$bin}{"depth_".$depth}{'abundance_'.$c};}
				#print "$total_assigned_depth_abund\n";
				$Layers{$depth}{'count'} = $depth_count;
				$Layers{$depth}{'total_assigned'} = $total_assigned_depth_abund;
			}
		my $total_abund = $Bin_taxonomy{$bin}{'depth_11'}{'abundance_1'};
		#foreach my $depth (11..23)
		if ($Bin_taxonomy{$bin}{'depth_11'}{'abundance_1'}/$total_abund == 1) #11=ROOT
			{	if ($Bin_taxonomy{$bin}{'depth_12'}{'abundance_1'}/$total_abund == 1) #12=Cellular organisms
					{	#if any assignment is over 90%, call it that and go to the next level. Else call it a mixed microbe bin.
						my @depth13_abund;
						my @depth13_names;
						foreach my $c (1..$Layers{13}{'count'}) #13=Domain
							{	push(@depth13_abund, $Bin_taxonomy{$bin}{'depth_13'}{'abundance_'.$c});
								push(@depth13_names, $Bin_taxonomy{$bin}{'depth_13'}{'name_'.$c});
							}
						my @good_loc;
						foreach my $loc (0..$#depth13_abund)
							{	if ($depth13_abund[$loc]/$total_abund >= 0.9)
									{push(@good_loc, $loc);}
							}
						if (scalar @good_loc == 1)
							{	my $DOMAIN_NAME = $depth13_names[$good_loc[0]];
								my $DOMAIN_ABUND = ($depth13_abund[$good_loc[0]]/$total_abund)*100;
								my @depth14_abund;
								my @depth14_names;
								foreach my $c (1..$Layers{14}{'count'}) #14=Phylum/Division
									{	push(@depth14_abund, $Bin_taxonomy{$bin}{'depth_14'}{'abundance_'.$c});
										push(@depth14_names, $Bin_taxonomy{$bin}{'depth_14'}{'name_'.$c});
									}
								my @good_14_loc;
								foreach my $loc (0..$#depth14_abund)
									{	if ($depth14_abund[$loc]/$total_abund >= 0.5)
											{push(@good_14_loc, $loc);}
									}
								if (scalar @good_14_loc == 1)
									{	my $PHYLUM_NAME = $depth14_names[$good_14_loc[0]];
										my $PHYLUM_ABUND = ($depth14_abund[$good_14_loc[0]]/$total_abund)*100;
										my @depth15_abund;
										my @depth15_names;
										foreach my $c (1..$Layers{15}{'count'}) #15=Class/Phylum
											{	push(@depth15_abund, $Bin_taxonomy{$bin}{'depth_15'}{'abundance_'.$c});
												push(@depth15_names, $Bin_taxonomy{$bin}{'depth_15'}{'name_'.$c});
											}
										my @good_15_loc;
										foreach my $loc (0..$#depth15_abund)
											{	if ($depth15_abund[$loc]/$total_abund >= 0.4)
													{push(@good_15_loc, $loc);}
											}
										if (scalar @good_15_loc == 1)
											{ 	my $CLASS_NAME = $depth15_names[$good_15_loc[0]];
												my $CLASS_ABUND = ($depth15_abund[$good_15_loc[0]]/$total_abund)*100;
												my @depth16_abund;
												my @depth16_names;
												foreach my $c (1..$Layers{16}{'count'}) #16=Order/Class
													{	push(@depth16_abund, $Bin_taxonomy{$bin}{'depth_16'}{'abundance_'.$c});
														push(@depth16_names, $Bin_taxonomy{$bin}{'depth_16'}{'name_'.$c});
													}
												my @good_16_loc;
												foreach my $loc (0..$#depth16_abund)
													{	if ($depth16_abund[$loc]/$total_abund >= 0.3)
															{push(@good_16_loc, $loc);}
													}
												if (scalar @good_16_loc == 1)
													{	my $ORDER_NAME = $depth16_names[$good_16_loc[0]];
														my $ORDER_ABUND = ($depth16_abund[$good_16_loc[0]]/$total_abund)*100;
														my @depth17_abund;
														my @depth17_names;
														foreach my $c (1..$Layers{17}{'count'}) #17=Family/Order
															{	push(@depth17_abund, $Bin_taxonomy{$bin}{'depth_17'}{'abundance_'.$c});
																push(@depth17_names, $Bin_taxonomy{$bin}{'depth_17'}{'name_'.$c});
															}
														my @good_17_loc;
														foreach my $loc (0..$#depth17_abund)
															{	if ($depth17_abund[$loc]/$total_abund >= 0.3)
																	{push(@good_17_loc, $loc);}
															}
														if (scalar @good_17_loc == 1)
															{	my $FAMILY_NAME = $depth17_names[$good_17_loc[0]];
																my $FAMILY_ABUND = ($depth17_abund[$good_17_loc[0]]/$total_abund)*100;
																my @depth18_abund;
																my @depth18_names;
																foreach my $c (1..$Layers{18}{'count'}) #18=Genus/Family
																	{	push(@depth18_abund, $Bin_taxonomy{$bin}{'depth_18'}{'abundance_'.$c});
																		push(@depth18_names, $Bin_taxonomy{$bin}{'depth_18'}{'name_'.$c});
																	}
																my @good_18_loc;
																foreach my $loc (0..$#depth18_abund)
																	{	if ($depth18_abund[$loc]/$total_abund >= 0.25)
																			{push(@good_18_loc, $loc);}
																	}
																if (scalar @good_18_loc == 1)
																	{	my $GENUS_NAME = $depth18_names[$good_18_loc[0]];
																		my $GENUS_ABUND = ($depth18_abund[$good_18_loc[0]]/$total_abund)*100;
																		my @depth19_abund;
																		my @depth19_names;
																		foreach my $c (1..$Layers{19}{'count'}) #19=Species/Genus
																			{	push(@depth19_abund, $Bin_taxonomy{$bin}{'depth_19'}{'abundance_'.$c});
																				push(@depth19_names, $Bin_taxonomy{$bin}{'depth_19'}{'name_'.$c});
																			}
																		my @good_19_loc;
																		foreach my $loc (0..$#depth19_abund)
																			{	if ($depth19_abund[$loc]/$total_abund >= 0.25)
																					{push(@good_19_loc, $loc);}
																			}
																		if (scalar @good_19_loc == 1)
																			{	my $SPECIES_NAME = $depth19_names[$good_19_loc[0]];
																				my $SPECIES_ABUND = ($depth19_abund[$good_19_loc[0]]/$total_abund)*100;
																				my @depth20_abund;
																				my @depth20_names;
																				foreach my $c (1..$Layers{20}{'count'}) #20=Genome/Species
																					{	push(@depth20_abund, $Bin_taxonomy{$bin}{'depth_20'}{'abundance_'.$c});
																						push(@depth20_names, $Bin_taxonomy{$bin}{'depth_20'}{'name_'.$c});
																					}
																				my @good_20_loc;
																				foreach my $loc (0..$#depth20_abund)
																					{	if ($depth20_abund[$loc]/$total_abund >= 0.25)
																							{push(@good_20_loc, $loc);}
																					}
																				if (scalar @good_20_loc == 1)
																					{	my $GENOME_NAME = $depth20_names[$good_20_loc[0]];
																						my $GENOME_ABUND = ($depth20_abund[$good_20_loc[0]]/$total_abund)*100;
																						my @depth21_abund;
																						my @depth21_names;
																						foreach my $c (1..$Layers{21}{'count'}) #21=NULL/Genome
																							{	push(@depth21_abund, $Bin_taxonomy{$bin}{'depth_21'}{'abundance_'.$c});
																								push(@depth21_names, $Bin_taxonomy{$bin}{'depth_21'}{'name_'.$c});
																							}
																						my @good_21_loc;
																						foreach my $loc (0..$#depth21_abund)
																							{	if ($depth21_abund[$loc]/$total_abund >= 0.25)
																									{push(@good_21_loc, $loc);}
																							}
																						if (scalar @good_21_loc == 1)
																							{	my $NULL_NAME = $depth21_names[$good_21_loc[0]];
																								my $NULL_ABUND = ($depth21_abund[$good_21_loc[0]]/$total_abund)*100;
																								print "$Bin_taxonomy{$bin}{'Name'}\t$PHYLUM_NAME ($PHYLUM_ABUND)\t$CLASS_NAME ($CLASS_ABUND)\t$ORDER_NAME ($ORDER_ABUND)\t$FAMILY_NAME ($FAMILY_ABUND)\t$GENUS_NAME ($GENUS_ABUND)\t$SPECIES_NAME ($SPECIES_ABUND)\t$GENOME_NAME ($GENOME_ABUND)\t$NULL_NAME ($NULL_ABUND)\n";
																								#if ($Layers{21}{'count'} > 0)
																								#	{print "\n\nWARNING: DEEPER DEPTHS POSSIBLE\n\n";}
																							}
																						else {print "$Bin_taxonomy{$bin}{'Name'}\t$PHYLUM_NAME ($PHYLUM_ABUND)\t$CLASS_NAME ($CLASS_ABUND)\t$ORDER_NAME ($ORDER_ABUND)\t$FAMILY_NAME ($FAMILY_ABUND)\t$GENUS_NAME ($GENUS_ABUND)\t$SPECIES_NAME ($SPECIES_ABUND)\t$GENOME_NAME ($GENOME_ABUND)\n";}
																					}
																				else {print "$Bin_taxonomy{$bin}{'Name'}\t$PHYLUM_NAME ($PHYLUM_ABUND)\t$CLASS_NAME ($CLASS_ABUND)\t$ORDER_NAME ($ORDER_ABUND)\t$FAMILY_NAME ($FAMILY_ABUND)\t$GENUS_NAME ($GENUS_ABUND)\t$SPECIES_NAME ($SPECIES_ABUND)\n";}
																				
																			}
																		else {print "$Bin_taxonomy{$bin}{'Name'}\t$PHYLUM_NAME ($PHYLUM_ABUND)\t$CLASS_NAME ($CLASS_ABUND)\t$ORDER_NAME ($ORDER_ABUND)\t$FAMILY_NAME ($FAMILY_ABUND)\t$GENUS_NAME ($GENUS_ABUND)\n";}
																	}
																if (scalar @good_18_loc > 1)
																	{	print "$Bin_taxonomy{$bin}{'Name'}\t$PHYLUM_NAME ($PHYLUM_ABUND)\t$CLASS_NAME ($CLASS_ABUND)\t$ORDER_NAME ($ORDER_ABUND)\t$FAMILY_NAME ($FAMILY_ABUND)\t";
																		foreach my $stuff (@good_18_loc)
																			{	my $abund_calc = ($depth18_abund[$stuff]/$total_abund)*100;
																				print "$depth18_names[$stuff] ($abund_calc),";	
																			}
																		print "\n";	
																	}
																if (scalar @good_18_loc < 1)
																	{print "$Bin_taxonomy{$bin}{'Name'}\t$PHYLUM_NAME ($PHYLUM_ABUND)\t$CLASS_NAME ($CLASS_ABUND)\t$ORDER_NAME ($ORDER_ABUND)\t$FAMILY_NAME ($FAMILY_ABUND)\n";}
															}
														if (scalar @good_17_loc > 1)
															{	print "$Bin_taxonomy{$bin}{'Name'}\t$PHYLUM_NAME ($PHYLUM_ABUND)\t$CLASS_NAME ($CLASS_ABUND)\t$ORDER_NAME ($ORDER_ABUND)\t";
																foreach my $stuff (@good_17_loc)
																	{	my $abund_calc = ($depth17_abund[$stuff]/$total_abund)*100;
																		print "$depth17_names[$stuff] ($abund_calc),";	
																	}
																print "\n";
															}
														if (scalar @good_17_loc < 1)
															{print "$Bin_taxonomy{$bin}{'Name'}\t$PHYLUM_NAME ($PHYLUM_ABUND)\t$CLASS_NAME ($CLASS_ABUND)\t$ORDER_NAME ($ORDER_ABUND)\n";}
													}
												if (scalar @good_16_loc > 1)
													{	print "$Bin_taxonomy{$bin}{'Name'}\t$PHYLUM_NAME ($PHYLUM_ABUND)\t$CLASS_NAME ($CLASS_ABUND)\t";
														foreach my $stuff (@good_16_loc)
															{	my $abund_calc = ($depth16_abund[$stuff]/$total_abund)*100;
																print "$depth16_names[$stuff] ($abund_calc),";	
															}
														print "\n";
													}
												if (scalar @good_16_loc < 1)
													{print "$Bin_taxonomy{$bin}{'Name'}\t$PHYLUM_NAME ($PHYLUM_ABUND)\t$CLASS_NAME ($CLASS_ABUND)\n";}
											}
										if (scalar @good_15_loc > 1)
											{print "$Bin_taxonomy{$bin}{'Name'}\t$PHYLUM_NAME ($PHYLUM_ABUND)\t";
											 foreach my $stuff (@good_15_loc)
												{	my $abund_calc = ($depth15_abund[$stuff]/$total_abund)*100;
													print "$depth15_names[$stuff] ($abund_calc),";	
												}
											 print "\n";
											}
										if (scalar @good_15_loc < 1)
											{print "$Bin_taxonomy{$bin}{'Name'}\t$PHYLUM_NAME ($PHYLUM_ABUND)\n";}
									}
								else {print "$Bin_taxonomy{$bin}{'Name'}\t$DOMAIN_NAME (mixed)\n";}
							}
						else {print "$Bin_taxonomy{$bin}{'Name'}\tUnclassified microbe\n";}
						
					}
				else {print "WARNING: Cellular organisms is not assigned to 100% for bin $Bin_taxonomy{$bin}{'Name'}\n";}
			}
		else {print "WARNING: ROOT is not assigned to 100% for bin $Bin_taxonomy{$bin}{'Name'}\n";}
		}
		if ($Bin_taxonomy{$bin}{'LIVE'} eq 'FALSE')
			{ print "WARNING: NO ASSIGNMENTS for bin $Bin_taxonomy{$bin}{'Name'}\n";}
		
	}


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - S U B R O U T I N E S - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


# - - - - - EOF - - - - - - - - - - - - - - - - - - - - - -
