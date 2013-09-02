require 'json'
require 'bio'

module CallM
  class ParseException < Exception
  end

  class Jpath
    attr_reader :json

    attr_reader :proteins

    def initialize
      @json = {}
      @json['pathways'] = []
      @json['homology groups'] = []
      @json['units'] = []
      @json['components'] = []
      @json['proteins'] = []
    end

    def to_s
      #TODO: need to convert proteins
      @json['proteins'] = @proteins.collect{|pro| pro.to_json}
      JSON.dump @json
    end

    def add_protein(sequence_id, pubmed_id, function, source, other_attributes={})
      @proteins ||= []
      prot = Protein.new(sequence_id, pubmed_id, function, source, other_attributes)
      @proteins.push prot

      return prot
    end

    def next_callm_accession(type)
      things = @json[type.to_s]
      return 1 if things.nil?
      max_one = things.max {|c1,c2| c1.callm_numeric_id <=> c2.callm_numeric_id}
      return max_one.callm_numeric_id+1
    end

    def add_component(name, other_attributes={})
      # Make sure that another component of the same name
      if @json['components'] and @json['components'].find{|c| c.name == name}
        raise MalformedException, "A component of the name #{name} already exists in this jpath object"
      end

      attrs = {'name' => name}.merge(other_attributes)
      component = Component.new attrs
      component['accession'] = next_callm_accession :component

      @json['components'] ||= []
      @json['components'].push component.to_json

      return component
    end

    def get_component(name)
      @json['components'].find{|c| c.name == name}
    end



    class MalformedException < Exception; end

    class Component
      attr_accessor :properties
      attr_accessor :proteins

      def initialize(properties_hash)
        @properties = properties_hash
      end

      def callm_numeric_id
        full = @properties['accession']
        raise CallM::Jpath::MalformedException if full.nil?
        matches = full.match(/^CallMComponent(\d+)$/)
        raise CallM::Jpath::MalformedException if !matches
        return matches[1].to_i
      end

      def to_json
        #TODO: need to include proteins here as well?
        JSON.dump @properties
      end

      def add_protein(protein)
        @proteins ||= []
        @proteins.push protein
      end

      def []=(key, value)
        @properties[key] = value
      end
    end

    class Protein
      #Required attributes
      attr_accessor :sequence_id, :pubmed_id, :function, :source

      attr_reader :sequence

      #Optional attributes
      attr_accessor :other_properties

      def initialize(sequence_id, pubmed_id, function, source, other_properties={})
        @sequence_id = sequence_id
        @pubmed_id = pubmed_id
        @function = function
        @source = source
        @other_properties = other_properties
      end

      def sequence=(seq)
        # TODO: Ensure that the sequence is a protein sequence, not a nucleotide one, not random rubbish string
        sequence = seq
      end

      def to_json
        json = {
          'sequence_id' => @sequence_id,
          'pubmed_id' => @pubmed_id,
          'function' => @function,
          'source' => @source,
        }
        json['sequence'] = @sequence unless @sequence.nil?

        @other_properties.each do |key, value|
          json[key] = value
        end
        json
      end
    end
  end
end
