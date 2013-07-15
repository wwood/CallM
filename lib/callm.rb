require 'json'

module CallM
  class ParseException < Exception
  end

  class Jpath
    attr_reader :json

    def initialize
      @json = JSON.new
      @json['pathways'] = []
      @json['homology groups'] = []
      @json['units'] = []
      @json['components'] = []
      @json['proteins'] = []
    end

    def to_s
      @json.to_s
    end

    def add_protein(sequence_id, pubmed_id, function, source, other_attributes={})
      attrs = {
        'sequence_id' => sequence_id,
        'pubmed_id' => pubmed_id,
        'function' => function,
        'source' => source,
      }.merge(other_attributes)

      @json['proteins'] ||= []
      @json['proteins'].push(attrs)
    end

    def next_callm_accession(type)
      max_one = send(type).max {|c1,c2| c1.callm_numeric_id <=> c2.callm_numeric_id}
      return 1 if max_one.nil?
      return max_one.callm_numeric_id+1
    end

    def add_component(name, other_attributes)
      # Make sure that another component of the same name
      if components.find{|c| c.name == name}
        raise MalformedException, "A component of the name #{name} already exists in this jpath file"
      end

      attrs = {'name' => name}.merge(other_attributes)
      component = Component.new attrs
      component['accession'] = next_callm_accession :component

      @json['components'] ||= []
      @json['components'].push component.to_json

      return component
    end



    class MalformedException < Exception; end

    class Component
      attr_accessor :properties

      def initialize(properties_hash)
        @properties = properties_hash
      end

      def callm_numeric_id
        full = @properties['accession']
        raise CallM::Jpath::MalformedException if full.nil?
        matches = full.match(/^CallMComponent(\d+)$)
        raise CallM::Jpath::MalformedException if !matches
        return matches[1].to_i
      end

      def to_json
        JSON.new @properties
      end

      def add_protein(protein)
    end
  end
end
