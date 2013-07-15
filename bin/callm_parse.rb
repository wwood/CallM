#!/usr/bin/env ruby

require 'optparse'
require 'bio-logger'
require 'json'
require 'csv'
require 'entrez'

SCRIPT_NAME = File.basename(__FILE__); LOG_NAME = SCRIPT_NAME.gsub('.rb','')

# Parse command line options into the options hash
options = {
  :logger => 'stderr',
  :log_level => 'info',
}

#PATHWAY = 'pathway'
#UNIT = 'unit'
#HOMOLOGY_GROUP = 'homology group'
#COMPONENT = 'component'

PROTEIN_PARSE = 'protein'
PATHWAY_PARSE = 'pathway'
UNIT_PARSE = 'unit'

possible_parse_types = [
  PROTEIN_PARSE,
  PATHWAY_PARSE,
  UNIT_PARSE,
]
o = OptionParser.new do |opts|
  opts.banner = "
    Usage: #{SCRIPT_NAME} --type <type> --csv <csv_file>  [options]

    Given a CSV of a protein or pathway curations, parse it and create a new .jpath file
    that encompasses the information given. Print the new .jpath file to STDOUT.\n\n"

  opts.separator "\Required:\n\n"
  opts.on("-t", "--type  TYPE", "One of 'proteins' or 'pathways'") do |arg|
    if !possible_types.include?(arg)
      raise "Unexpected type given. Expected one of #{possible_types.join(', ')}, found '#{arg}'"
    end
    options[:type] = arg
  end
  opts.on("--csv PATH_TO_CSV_FILE", "CSV file containing the curation information") do |arg|
    options[:csv] = arg
  end

#  opts.separator "\nOptional:\n\n"
#  opts.on("-p", "--previous-jpath PATH_TO_JPATH_FILE", "Don't start a new jpath file, build upon this one [default: none, create a new jpath file]") do |arg|
#    options[:previous_jpath] = arg
#  end

  # logger options
  opts.separator "\nVerbosity:\n\n"
  opts.on("-q", "--quiet", "Run quietly, set logging to ERROR level [default INFO]") {options[:log_level] = 'error'}
  opts.on("--logger filename",String,"Log to file [default #{options[:logger]}]") { |name| options[:logger] = name}
  opts.on("--trace options",String,"Set log level [default INFO]. e.g. '--trace debug' to set logging level to DEBUG"){|s| options[:log_level] = s}
end; o.parse!
if ARGV.length != 0 or !options[:type] or !options[:csv]
  $stderr.puts o
  exit 1
end
# Setup logging
Bio::Log::CLI.logger(options[:logger]); Bio::Log::CLI.trace(options[:log_level]); log = Bio::Log::LoggerPlus.new(LOG_NAME); Bio::Log::CLI.configure(LOG_NAME)

def fail_parse(reason)
  raise CallM::ParseException, reason
end

jpath = CallM::Jpath.new

case options[:type]
when PROTEIN_PARSE
  CSV.foreach(options[:csv], :headers => true) do |row|
    next if row[0].match(/^\s*\#/) #Skip comment lines
    unless row.length > 4
      fail_parse "Expected more columns in CSV file, found a row with #{row.length} cells: #{row.inspect}"
    end

    # Publication identifier (PubMed ID)
    pubmed_id = row[0]
    pubmed_id ||= ''
    pubmed_id.strip!
    unless pubmed_id.match(/^\d+$/)
      fail_parse "Unexpected PubMed (or no PubMed ID) found in row #{row.inspect}"
    end

    # Homology group (e.g. particulate monooxygenase subunit A)
    homology_group = row[1]
    homology_group ||= ''
    homology_group.strip!
    if homology_group == ''
      fail_parse "Homology group is required, failed to find one in this row: #{row.inspect}"
    end

    # Function. Leave blank if unknown
    function = row[2]
    function.strip unless function.nil?
    function = homology_group if function == '' or function.nil?

    # Protein Sequence ID (GenBank protein ID)
    sequence_id = row[3]
    sequence_id ||= ''
    sequence_id.strip!
    if sequence_id == ''
      fail_parse "Sequence ID left blank in this row: #{row.inspect}"
    end

    # (optional) Clade name (if the homology group has multiple clades with this function). Leave blank if function is unknown
    clade_name = row[4].strip unless row[4].nil? or row[4].strip==''

    # (optional) gene acronym
    acronym = row[4].strip unless row[4].nil? or row[4].strip==''


    # Reached the end means that we can add this protein to the json
    # Add the protein itself
    # Add a new component unless that component is already defined in the jpath
    # Add a new homology group unless already defined
    protein  = jpath.add_protein(sequence_id, pubmed_id, function, 'GenBank protein', {
      'clade_name' => clade_name,
      'acronym' => acronym,
      })

    component = jpath.get_component(function)
    component ||= jpath.add_component(function)
    component.add_protein protein

    hom = jpath.get_homology_group(homology_group)
    hom ||= jpath.add_homology_group(homology_group)
    unless hom.components.include?(component)
      hom.add_component component
    end

    if protein.sequence.nil? #Always true?
      fa = Entrez.EFetch('protein', id: sequence_id, retmode: :fasta)
      if fa.nil?
        log.error "Unable to fetch sequence for #{sequence_id}, skipping"
      else
        protein.sequence = Bio::FastaFormat.new(fa).seq
      end
    end
  end
else
  raise "handling of type #{options[:type]} not yet implemented"
end













