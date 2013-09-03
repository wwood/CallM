require 'json'
require 'bio'

module CallM
  class ParseException < Exception
  end

  class Jpath
    attr_reader :json

    attr_reader :proteins, :components, :units, :pathways, :homology_groups

    def initialize
      @proteins = []
      @components = []
      @units = []
      @pathways = []
      @homology_groups = []
    end

    def to_s
      #TODO: need to convert proteins
      json = {}
      json['proteins'] = @proteins.collect{|pro| pro.to_json}
      json['components'] = @components.collect{|pro| pro.to_json}
      json
    end

    def add_protein(sequence_id, pubmed_id, function, source, other_attributes={})
      @proteins ||= []
      prot = Protein.new(sequence_id, pubmed_id, function, source, other_attributes)
      @proteins.push prot

      return prot
    end

    def next_callm_accession(type)
      #TODO: ensure that another accession with the same number is not known, locally at least
      return rand(9999999999)
    end

    def add_component(name, other_attributes={})
      # Make sure that another component of the same name
      if @components.find{|c| c.name == name}
        raise MalformedException, "A component of the name #{name} already exists in this jpath object"
      end

      attrs = {'name' => name}.merge(other_attributes)
      component = Component.new attrs
      component['accession'] = next_callm_accession :component

      @components.push component

      return component
    end

    def get_component(name)
      @components.find{|c| c.name == name}
    end

    def get_homology_group_by_name(name)
      return nil if @homology_groups.nil?
      return @homology_groups.find{|h| h.name == name}
    end

    def add_homology_group(name)
      @homology_groups ||= []
      new_homology_group = HomologyGroup.new name
      @homology_groups.push new_homology_group
      return new_homology_group
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
        @properties
      end

      def add_protein(protein)
        @proteins ||= []
        @proteins.push protein
      end

      def []=(key, value)
        @properties[key] = value
      end

      def name
        @properties['name']
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
        @sequence = seq
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
        if @sequence
          json['sequence'] = @sequence
        end
        json
      end
    end

    class HomologyGroup
      attr_accessor :name

      attr_reader :components

      def initialize(name)
        @name = name
        @components = []
      end

      def add_component(component)
        @components.push component
      end
    end
  end
end
