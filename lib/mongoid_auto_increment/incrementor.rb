# This is a modified version of the code found on this blog post:
# http://ihswebdesign.com/blog/autoincrement-in-mongodb-with-ruby/
module MongoidAutoIncrement
  class Incrementor
    class Sequence
      def initialize(sequence, collection_name, seed, step, scope)
        @sequence = sequence.to_s
        @collection = collection_name.to_s
        @scope = scope || {}
        exists? || create(seed)
        @step = step.to_i
      end

      def inc
        if defined?(::Mongoid::VERSION) && ::Mongoid::VERSION >= '5'
          collection.find(query).find_one_and_update({ '$inc' => { number: @step } }, new: true, upsert: true, return_document: :after)['number']
        elsif defined?(::Mongoid::VERSION) && ::Mongoid::VERSION >= '3'
          collection.find(query).modify({ '$inc' => { number: @step } }, new: true, upsert: true)['number']
        else
          opts = {
            'query'  => query,
            'update' => { '$inc' => { 'number' => @step } },
            'new'    => true # return the modified document
          }
          collection.find_and_modify(opts)['number']
        end
      end

      def current
        if defined?(::Mongoid::VERSION) && ::Mongoid::VERSION >= '3'
          collection.find(query).one['number']
        else
          collection.find_one(query)['number']
        end
      end

      private

      def exists?
        collection.find(query).count > 0
      end

      def create(number)
        if ::Mongoid::VERSION >= '5'
          collection.insert_one(query.merge('number' => number))
        else
          collection.insert(query.merge('number' => number))
        end
      end

      def collection
        if defined?(::Mongoid::VERSION) && ::Mongoid::VERSION >= '5'
          Mongoid.default_client[@collection]
        elsif defined?(::Mongoid::VERSION) && ::Mongoid::VERSION >= '3'
          Mongoid.default_session[@collection]
        else
          Mongoid.database[@collection]
        end
      end

      def query
        @scope.merge('seq_name' => @sequence)
      end
    end

    def initialize(options = nil); end

    def inc(sequence, options, record)
      collection = options[:collection] || 'sequences'
      seed = options[:seed].to_i
      step = options[:step] || 1
      scope = resolve_scope(record, options[:scope])

      Sequence.new(sequence, collection, seed, step, scope).inc
    end

    private

    def resolve_scope(record, scope)
      Array(scope).each_with_object({}) do |scope_item, query|
        reflection = record.class.reflect_on_association(scope_item)

        if reflection
          scope_value = record.send(reflection.foreign_key)
          scope_item  = reflection.foreign_key
          query[scope_item] = scope_value
        else
          query[scope_item] = record.read_attribute(scope_item)
        end
      end
    end
  end
end
