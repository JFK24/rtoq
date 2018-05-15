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
# 2018-05-15: complete get_citations, get URLs of files, download them, and process them
# 2018-05-15: implement as parameters: min_max_dates, min_max_totalfiles, min_max_citations

#
# TO DO HISTORY:
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
#else:
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
	if(not os.path.isfile(outfile) or os.path.getsize(file_ae_exp)<=0):
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
# SELECT AND DOWNLOAD INDIVIDUAL EXPERIMENTS METADATA AND RAW DATA FILES
# ==============================================================================
#with open(file_parse_exp_filt, "r") as fd:
#    rd = csv.reader(fd, delimiter="\t", quotechar='"')
#    for row in rd:
#        print(row)

# Define range for PMID age
# Define range for total raw files 
# Define range for number of citations
min_max_dates = ("2013-01-01", "2014-12-31")
min_max_totalfiles = (3, 50)
min_max_citations = (1, 10000)

def get_citations(pmid):
	import urllib.request
	opener = urllib.request.FancyURLopener({})
	url = "https://www.ncbi.nlm.nih.gov/pubmed/"+pmid
	f = opener.open(url)
	content = f.read(300)
	print(content)
	return(5)

#urllib.request.urlretrieve(ae_url, file_ae_exp)

# Get PMID
with open(file_parse_exp_filt, "r") as fd:
	rd = csv.reader(fd, delimiter="\t", quotechar='"')
	row_counter=0
	for row in rd:
#		print(row)
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
		# test validity
		select_nexp = (nexp>=min_max_totalfiles[0]) and (nexp<=min_max_totalfiles[1])
		if not select_nexp:
			continue

		select_date = datetime.strptime(min_max_dates[0], '%Y-%m-%d') <= datetime.strptime(date, '%Y-%m-%d') <= datetime.strptime(min_max_dates[1], '%Y-%m-%d')
		if not select_date:
			continue

##		n_cita = get_citations(pmid)
#		n_cita = 5
##		select_cita = min_max_citations[0] <= n_cita <= min_max_citations[1]
#		if not (min_max_citations[0] <= n_cita <= min_max_citations[1]):
#			continue

		print(" _ ".join([ae_id, date, str(pmid), str(nexp)]))
		row_counter+=1
		if row_counter>=options.experiments:
			break

#		if(select_nexp and select_date and select_cita):
#			row_counter+=1
#			print(" _ ".join([ae_id, date, str(pmid), str(nexp)]))

# Get number of citations (http request)
# Get metadata 
# Get files






