# Phylosift to table

The purpose of this program is to quickly collect data from [Phylosift](https://phylosift.wordpress.com) [(GitHub link)](https://github.com/gjospin/PhyloSift) runs on multiple bins and collate into a single table.

The expectation of the input is that you have a **folder containing all the Phylosift output folders for each bin**. The program looks for the **[Krona](https://github.com/marbl/Krona) html file** and pulls the results from this file. I haven't found the other outfiles from Phylosift to be quite as informative as the Krona file, which is why I chose it.

## Dependencies

The only dependencies are a couple of Perl modules I regularly use. I think these are actually available in the Perl download, so not sure you really need to install anything. The modules are: ```strict``` & ```Getopt::Std```.

## Installation

Download the repository from GitHub: [Phylosift\_to\_table](https://github.com/seanmcallister/Phylosift_to_table)

## Usage

After installation, pull up the help information:

```
perl phylosift_krona_to_table.pl -h
```
This will give you:

```
Help called:
Options:
-p = path to folder containing folders of phylosift results
-x = folder suffix
-r = folder prefix
-h = This help message
```

### Example

I have an input folder that looks like this:

```
phylosift_results (folder/directory)
├── S1_bin1_out (folder/directory)
│   ├── S1_bin1.concat.jnlp
│   ├── S1_bin1.html
│   ├── S1_bin1.jplace
│   ├── S1_bin1.xml
│   ├── alignDir
│   ├── blastDir
│   ├── marker_summary.txt
│   ├── run_info.txt
│   ├── sequence_taxa.1.txt
│   ├── sequence_taxa.txt
│   ├── sequence_taxa_summary.1.txt
│   ├── sequence_taxa_summary.txt
│   ├── taxa_90pct_HPD.txt
│   ├── taxasummary.txt
│   └── treeDir
├── S1_bin2_out (folder/directory)
│   ├── S1_bin2.concat.jnlp
│   ├── S1_bin2.html
│   ├── S1_bin2.jplace
│   ├── S1_bin2.xml
│   ├── alignDir
│   ├── blastDir
│   ├── marker_summary.txt
│   ├── run_info.txt
│   ├── sequence_taxa.1.txt
│   ├── sequence_taxa.txt
│   ├── sequence_taxa_summary.1.txt
│   ├── sequence_taxa_summary.txt
│   ├── taxa_90pct_HPD.txt
│   ├── taxasummary.txt
│   └── treeDir
├── etc...
```
Thus ```phylosift_results``` is a folder containing all the phylosift output folders from all my bins; that folder is what you should put for ```-p```.

```S1_bin1_out``` and ```S1_bin2_out``` each have ```_out``` as a suffix to the bin name. That suffix is what is provided to ```-x```. If you have decided to name your Phylosift output folders with a prefix, such as ```phylosift_S1_bin1```, you can provide ```phylosift_``` to the ```-r``` option. You cannot have both a suffix and prefix.

Example command:

```
phylosift_krona_to_table.pl -p ./phylosift_results -x _out > S1_phylosift_resultstable.txt
```

This generates a table following some rules. Primarily, I'm interested in using this script to call a taxonomy for a bin, so I am looking for a majority rule. But I don't want to be too sloppy, so there are rules for what means a majority at different taxonomic levels. Multiple majority rule taxa are possible (and separated by ",") if they pass the majority cutoff for the taxonomic level.

|Taxonomic Level|Majority Cutoff|If below cutoff...|
|---|---|---|
|NULL|NA|WARNING: NO ASSIGNMENTS for bin|
|ROOT|100%|WARNING: ROOT is not assigned to 100% for bin|
|Cellular organism|100%|WARNING: Cellular organisms is not assigned to 100% for bin|
|Domain|90%|Unclassified microbe|
|Phylum|50%|Domain\_name (mixed)|
|Class|40%|Phylum\_name (abund) *[multi]*|
|Order|30%|Phylum\_name (abund), Class\_name (abund) *[multi]*|
|Family|30%|Phylum/Class/Order (abund) *[multi]*|
|Genus|25%|Phylum/Class/Order/Family (abund) *[multi]*|
|Species|25%|P/C/O/F/G (abund) *[multi]*|
|Subspecies/Genome|25%|P/C/O/F/G/S (abund) *[multi]*|
|Additional depths|25%|P/C/O/F/G/S/Sub or Genome (abund) *[multi]*|

The output for sample Sample 1 looks like:

|Bin name|Taxonomy (percent relative abundance)|||||||
|---|---|---|---|---|---|---|---|
|S1\_bin1|PROTEOBACTERIA (100)|GAMMAPROTEOBACTERIA (43.9969306483449)
|S1\_bin2|BACTEROIDETES/CHLOROBI GROUP (100)|BACTEROIDETES (100)|FLAVOBACTERIIA (100)|FLAVOBACTERIALES (57.1428571428571)|FLAVOBACTERIACEAE (44.092230634174)|
|S1\_bin3|PROTEOBACTERIA (100)|ZETAPROTEOBACTERIA (99.89503224484)|UNCLASSIFIED ZETAPROTEOBACTERIA (86.8889596220667)|ZETA PROTEOBACTERIUM SCGC AB 133 C04 (48.0392969962402),ZETA PROTEOBACTERIUM SCGC AB 137 I08 (36.5954238775949),|
|S1\_bin4|ARCHAEA (mixed)|
|WARNING: NO ASSIGNMENTS for bin S1\_bin5|
|S1\_bin5|BACTERIA (mixed)|
|S1\_bin6|Unclassified microbe|
|WARNING: Cellular organisms is not assigned to 100% for bin S1\_bin7|
|S1\_bin8|PLANCTOMYCETES (50)|CANDIDATE DIVISION NC10 (48.0386905602096),PHYCISPHAERAE (50),|
|S1\_bin9|PROTEOBACTERIA (100)|GAMMAPROTEOBACTERIA (50),ZETAPROTEOBACTERIA (50),|
|S1\_bin10|PROTEOBACTERIA (75.4290657552175)|DELTA/EPSILON SUBDIVISIONS (66.3622131607418)|DELTAPROTEOBACTERIA (66.3622131607418)|MYXOCOCCALES (49.1954721381515)|SORANGIINEAE (28.8032419805045)|POLYANGIACEAE (28.8032419805045)|SORANGIUM (28.8032419805045)|

In this example, bins 2/3/10 are a bit more specific, while bins 1/4/5/6 are not highly resolved by Phylosift. Bin 9 is split 50:50 between Zetaproteobacteria and Gammaproteobacteria. And bins 5/7 seem to have problems. Potentially phylosift didn't run properly on bin 5 (or didn't have any marker genes). And for bin 7, I tend to get this result when there are some viral hits in the Phylosift results (so should take a look at this manually to judge).

Please open an issue if you have any issues or questions. This program is provided without warranty or a guarantee of support. Thanks!!
