#!/usr/bin/python3

# ==============================================================================
# DOWNLOAD A SELECTED SET OF NGS EXERIMENTS FROM ARRAY EXPRESS DATABASE
# FOR EACH EXERIMENT, A LIMITED NUMBER OF RAW FILES WILL BE DOWNLOADED
# AND PROCESSED WITH QUALITY CONTROL SOFTWARE.
# MORE DETAILS ON THE ARRAY EXPRESS API: 
#     https://www.ebi.ac.uk/arrayexpress/help/programmatic_access.html
#
# INPUTS:
# _ TYPE OF NGS ("RNA-seq of coding RNA"; "ChIP-seq")
# _ SPECIES ("homo sapiens"; "mus musculus")
# _ MAX NUMBER OF EXPERIMENTS
# _ MAX NUMBER OF RAW FILES PER EXPERIMENT
# _ MAX NUMBER OF PARALLEL THREADS
# _ OUTPUT DIRECTORY PATH
#
# OUTPUT:
# _ ae_exp.xml: XML FILE OF THE EXPERIMENTS FROM ARRAY EXPRESS
# _ ae_exp_base.tsv: TSV FILE OF THE EXPERIMENTS (PARSED FROM THE XML)
# _ ae_exp_bibl.tsv: TSV FILE OF THE EXPERIMENTS BIBLIO DATA (PARSED FROM THE XML)
# _ ae_exp_bioa.tsv: TSV FILE OF THE EXPERIMENTS BIO ASSAY DATA (PARSED FROM THE XML)
# _ ae_exp_prov.tsv: TSV FILE OF THE EXPERIMENTS PROVIDER DATA (PARSED FROM THE XML)
# _ ae_exp_samp.tsv: TSV FILE OF THE EXPERIMENTS SAMPLES DATA (PARSED FROM THE XML)
#
# CREATION DATE: 2018-05-15
#
# TO DO:
# 2018-05-16: select a min of "options.files" ftp files in the table of samples
# 2018-05-15: get URLs of files, download them, and process them
#
# TO DO HISTORY:
# 2018-05-15: complete get_citations, get URLs of files, download them, and process them
# 2018-05-15: implement as parameters: min_max_dates, min_max_totalfiles, min_max_citations
#
# ==============================================================================
from optparse import OptionParser
import urllib.request
import urllib.parse
import os.path
import lxml.etree as ET
import re
from datetime import datetime
import csv


# ==============================================================================
# PARSING ARGUMENTS
# ==============================================================================

def vararg_callback(option, opt_str, value, parser):
    assert value is None
    value = []

    def floatable(str):
        try:
            float(str)
            return True
        except ValueError:
            return False

    for arg in parser.rargs:
        # stop on --foo like options
        if arg[:2] == "--" and len(arg) > 2:
            break
        # stop on -a, but not on -3 or -3.0
        if arg[:1] == "-" and len(arg) > 1 and not floatable(arg):
            break
        value.append(arg)

    del parser.rargs[:len(value)]
    setattr(parser.values, option.dest, value)

usage = "usage: %prog [options]"
parser = OptionParser(usage=usage)

parser.add_option("-t", "--types", dest="types", action="callback", callback=vararg_callback, 
	help="list of NGS types (white-space-separated, and quoted). E.g.  -s 'RNA-seq of coding RNA' 'ChIP-seq'",
	default=['RNA-seq of coding RNA', 'ChIP-seq'])
parser.add_option("-s", "--species", dest="species", action="callback", callback=vararg_callback,
	help="list of species (white-space-separated, and quoted). E.g.  -s 'homo sapiens' 'mouse'",
	default=['homo sapiens', 'mus musculus'])
parser.add_option("-e", "--experiments", dest="experiments", 
	help="max number of experiments", metavar="N_EXP", type="int", default=1)
parser.add_option("-f", "--files", dest="files", 
	help="max number of files per experiment", metavar="N_FILES", type="int", default=1)
parser.add_option("-p", "--parallel-threads", dest="parallel", 
	help="max number of threads to use", metavar="N_THREADS", type="int", default=1)
parser.add_option("-o", "--output-dir", dest="dir", 
	help="output directory", metavar="DIR", type="string", default=".")
parser.add_option("-x", "--xslt-dir", dest="xsltdir", 
	help="directory containing the following xslt files: parse_experiments.xslt, parse_experiments_bibliography.xslt, parse_experiments_bioassaydatagroups.xslt, parse_experiments_providers.xslt, parse_samples.xslt", metavar="DIR", type="string", default=".")
parser.add_option("-v", "--verbose", action="store_true", dest="verbose", default=True,
	help="maximize output messages [default]" )
parser.add_option("-q", "--quiet", action="store_false", dest="verbose",
	help="minimize output messages")

(options, args) = parser.parse_args()

if options.verbose:
	print ("Parameters:")
	print ("\ttypes: ", options.types)
	print ("\tspecies: ", options.species)
	print ("\texperiments: ", options.experiments)
	print ("\tfiles: ", options.files)
	print ("\tparallel: ", options.parallel)
	print ("\tdir: ", options.dir)
	print ("\txsltdir: ", options.xsltdir)

# ==============================================================================
# GET DESCRIPTION OF EXPERIMENTS IN XML
# ==============================================================================
# Get a subset of experiments
#wget -N -O $tOUTDIR/experiments.subset 'https://www.ebi.ac.uk/arrayexpress/xml/v3/experiments?raw=true&species="homo sapiens"+OR+"mus musculus"&exptype="RNA-seq of coding RNA"+OR+"ChIP-seq"'
ae_q_raw="raw=true"
ae_q_types="exptype="+'"{0}"'.format('"+OR+"'.join(options.types))
ae_q_species="species="+'"{0}"'.format('"+OR+"'.join(options.species))
ae_url = "https://www.ebi.ac.uk/arrayexpress/xml/v3/experiments?" + "&".join([ae_q_raw, ae_q_species, ae_q_types])
ae_url = urllib.parse.quote(ae_url, safe=':/?*=\'"&+')
file_ae_exp = os.path.join(options.dir, 'ae_exp.xml')

print("Downloading experiments metadata:")
if(os.path.isfile(file_ae_exp) and os.path.getsize(file_ae_exp)>0):
	print("\tFile exists: "+file_ae_exp)
else:
	urllib.request.urlretrieve(ae_url, file_ae_exp)


# ==============================================================================
# PROCESS XML FILE WITH XSLTS
# ==============================================================================
script_parse_exp_base = os.path.join(options.xsltdir, 'parse_experiments.xslt')
script_parse_exp_bibl = os.path.join(options.xsltdir, 'parse_experiments_bibliography.xslt')
script_parse_exp_bioa = os.path.join(options.xsltdir, 'parse_experiments_bioassaydatagroups.xslt')
script_parse_exp_prov = os.path.join(options.xsltdir, 'parse_experiments_providers.xslt')
#script_parse_exp_samp = os.path.join(options.xsltdir, 'parse_samples.xslt')

file_parse_exp_base = os.path.join(options.dir, 'ae_exp_base.tsv')
file_parse_exp_bibl = os.path.join(options.dir, 'ae_exp_bibl.tsv')
file_parse_exp_bioa = os.path.join(options.dir, 'ae_exp_bioa.tsv')
file_parse_exp_prov = os.path.join(options.dir, 'ae_exp_prov.tsv')
#file_parse_exp_samp = os.path.join(options.dir, 'ae_exp_samp.tsv')
file_parse_exp_filt = os.path.join(options.dir, 'ae_exp_filt.tsv')

script_outfile_pairs = (
	(script_parse_exp_base, file_parse_exp_base),
	(script_parse_exp_bibl, file_parse_exp_bibl),
	(script_parse_exp_bioa, file_parse_exp_bioa),
	(script_parse_exp_prov, file_parse_exp_prov),
#	(script_parse_exp_samp, file_parse_exp_samp)
)

# Process the xml with each xslt
print("XSLT processing:")
for pair in script_outfile_pairs:
	script, outfile = pair
	if(not os.path.isfile(outfile) or os.path.getsize(outfile)<=0):
		xml  = ET.parse(file_ae_exp)
		xslt = ET.parse(script)
		transform = ET.XSLT(xslt)
		tsv = transform(xml)
		with open(outfile, 'w') as the_file:
			the_file.write(str(tsv))
	else:
		print("\tFile exists: "+outfile)

# filter experiments
if(not os.path.isfile(file_parse_exp_filt) or os.path.getsize(file_parse_exp_filt)<=0):
	ae_q_raw=r"rawData,|scan,"
	ae_q_types='\\t{0}\\t'.format('\\t|\\t'.join(options.types))
	ae_q_species='\\t{0}\\t'.format('\\t|\\t'.join(options.species))
	ae_q_pmid=r"PMID:"
	#print(ae_q_raw)
	#print(ae_q_types)
	#print(ae_q_species)
	#print(ae_q_pmid)
	with open(file_parse_exp_filt, "w") as o:
		with open(file_parse_exp_base, "r") as f:
			for line in f:
				if(	re.findall(ae_q_raw, line, flags=re.IGNORECASE)
					and re.findall(ae_q_types, line, flags=re.IGNORECASE)
					and re.findall(ae_q_species, line, flags=re.IGNORECASE)
					and re.findall(ae_q_pmid, line, flags=re.IGNORECASE) 
					):
					o.write(line)
else:
	print("\tFile exists: "+file_parse_exp_filt)


# ==============================================================================
# SELECT INDIVIDUAL EXPERIMENTS (DATE, #FILES, #CITATIONS)
# ==============================================================================

def get_citations(pmid):
	"""Returns the number of citations to a PubMed (PubMed Central?) article 
	from PubMed Central (PMC) articles. Use moderately to avoid overloading
	PubMed servers.
	IN:  PubMed Identifier (PMID) of article A (integer)
	OUT: number of PMC articles citing A (integer)
	"""
	import urllib.request
	import re
	url = "https://www.ncbi.nlm.nih.gov/pubmed?linkname=pubmed_pubmed_citedin&from_uid="+pmid
	resp = urllib.request.urlopen(url)
	content_b = resp.read()
	content = content_b.decode()
	n=0
	match=re.search(r'Items: (\d+)', content)
	if match:
		n=int(match.group(1))
	return(n)

print("Selecting experiments:")
# Define ranges for PMID age, total raw files, and number of citations
min_max_dates = ("2013-01-01", "2016-12-31")
min_max_totalfiles = (3, 50)
min_max_citations = (1, 10000)
file_selec_exp = os.path.join(options.dir, 'ae_exp_sele.tsv')

if(not os.path.isfile(file_selec_exp) or os.path.getsize(file_selec_exp)<=0):
	with open(file_parse_exp_filt, "r") as fd, open(file_selec_exp, "w") as o:
		rd = csv.reader(fd, delimiter="\t", quotechar='"')
		row_counter=0
		for row in rd:
			# get/parse values
			ae_id=row[1]
			date=row[2]
			pmid=0
			nexp=0
			match=re.search(r'PMID:(\d+)', row[6])
			if match:
				pmid=match.group(1)
			match=re.search(r'(scan|rawData),(\d+)', row[7])
			if match:
				nexp=int(match.group(2))
#			print(" _ ".join([str(row_counter), ae_id, date, str(pmid), str(nexp)]))

			# test nexp validity
			select_nexp = (	(nexp>=min_max_totalfiles[0]) and 
							(nexp<=min_max_totalfiles[1]))
			if not select_nexp:
#				print("skip (nexp)")
				continue

			# test date validity
			select_date = 	datetime.strptime(min_max_dates[0], '%Y-%m-%d') <= datetime.strptime(date, '%Y-%m-%d') <= datetime.strptime(min_max_dates[1], '%Y-%m-%d')
			if not select_date:
#				print("skip (date)")
				continue

			# test n_cita validity
			n_cita = get_citations(pmid)
			print("\tCitations: "+ str(n_cita))
			select_cita = min_max_citations[0] <= n_cita <= min_max_citations[1]
			if not (min_max_citations[0] <= n_cita <= min_max_citations[1]):
#				print("skip (citations)")
				continue

	#		print(" _ ".join([ae_id, date, str(pmid), str(nexp)]))
			o.write("\t".join([ae_id, date, str(pmid), str(nexp), str(n_cita)])+"\n")
			row_counter+=1
			if row_counter>=options.experiments:
#				print("row_counter: "+ str(row_counter))
#				print("options.experiments: "+str(options.experiments))
				break
else:
	print("\tFile exists: "+file_selec_exp)


# ==============================================================================
# DOWNLOAD SAMPLES METADATA FOR SELECTED EXPERIMENTS
# ==============================================================================

file_ae_exp_samp = os.path.join(options.dir, 'ae_exp_samp.tsv')
dir_ae_exp_samp =  os.path.join(options.dir, 'samples')
if not os.path.exists(dir_ae_exp_samp):
    os.makedirs(dir_ae_exp_samp)

print("Downloading Samples metadata");
if(	os.path.isfile(file_selec_exp) and os.path.getsize(file_selec_exp)>=0 and
	(not os.path.isfile(file_ae_exp_samp) or os.path.getsize(file_ae_exp_samp)<=0)
	):
	with open(file_selec_exp, "r") as f, open(file_ae_exp_samp, "w") as o:
		# Do something
		aeidCounts = {}
		pmidCounts = {}
		for line in f:
			fields = line.split("\t")
			aeid=fields[0]
			pmid=fields[2]
			aeidCounts.setdefault(aeid, aeidCounts.get(aeid,0)+1)
			n_aeid=aeidCounts.get(aeid,0)
			pmidCounts.setdefault(pmid, pmidCounts.get(pmid,0)+1)
			n_pmid=pmidCounts.get(pmid,0)
			print("\tProcessing: "+aeid);
			print("\t\tAEID: "+str(pmid)+". Count: "+str(n_aeid))
			print("\t\tPMID: "+str(pmid)+". Count: "+str(n_pmid))
			if(n_aeid==1 and n_pmid==1):
				print("\t\tDownloading: "+aeid);
				ae_url = "https://www.ebi.ac.uk/arrayexpress/xml/v3/experiments/" + aeid + "/samples"
				ae_url = urllib.parse.quote(ae_url, safe=':/?*=\'"&+')
	#			print("\t"+ae_url)
				file_aeid = os.path.join(dir_ae_exp_samp, aeid+'.xml')
	#			print("\t"+file_aeid)
				if(not os.path.isfile(file_aeid) or os.path.getsize(file_aeid)<=0):
					urllib.request.urlretrieve(ae_url, file_aeid)
				else:
					print("\t\tFile exists: "+file_aeid)

				print("\t\tXSLT processing: "+aeid);
				script_parse_exp_samp = os.path.join(options.xsltdir, 'parse_samples.xslt')
#				print(script_parse_exp_samp)
	#			file_parse_aeid       = os.path.join(dir_ae_exp_samp, aeid+'.tsv')
	#			print(file_parse_aeid)
				script, infile = (script_parse_exp_samp, file_aeid)
				xml  = ET.parse(infile)
				xslt = ET.parse(script)
				transform = ET.XSLT(xslt)
				tsv = transform(xml)
				o.write(str(tsv))
else:
	print("\tFile exists: "+file_ae_exp_samp)


# ==============================================================================
# PARSE SAMPLES METADATA AND DOWNLOAD SOME FILES FROM EACH EXPERIMENT
# ==============================================================================

print("Downloading raw files:");

import pandas as pd
import numpy as np

df = pd.read_csv(file_ae_exp_samp, sep='\t', header=None)
#print(df.head())
print(df.describe())
df.columns = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P']
#print(df.head())
#print(df.tail())
print(df.shape)
df = df[df.J.notnull()]
print(df.shape)
df = df.drop_duplicates(subset='I')
print(df.shape)
#df = df.groupby('A').tail(options.files)
#df = df.groupby('A').apply(lambda x: x.sample(options.files))
#print(df.shape)
print(df.head(17))

# Existing FTP link = no NaN in col 9
# No paired-end sample (but may be replicates) = unique SRR id in col 8
# Order by experiment and SRR = Order by col 0 and 8
# Select a few rows per experiment


