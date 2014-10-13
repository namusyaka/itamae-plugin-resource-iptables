module Itamae
  module Plugin
    module Resource
      module Iptables
        module MultiportRule
          def self.prepended(base)
            base.class_eval do
              [:sport, :dport].each do |key|
                define_attribute key, type: [Fixnum, Range, Array]
                define_attribute :"not_#{key}", type: [Fixnum, Range, Array]
              end
            end
          end

          def build_rule(attrs)
            rule = super
            spec = PortSpecifier.new
            %w[dport sport].each do |key|
              if port = attrs[key]
                spec.and(key, port)
              elsif not_port = attrs["not_#{key}"]
                spec.not(key, not_port)
              end
            end
            super + spec.to_rule
          end

          class PortSpecifier
            def initialize
              @multiport = false
              @rule = []
            end

            def and(key, port)
              add_port_spec(key, port)
              self
            end

            def not(key, port)
              @rule << '!'
              add_port_spec(key, port)
              self
            end

            def to_rule
              if @multiport
                %w[--match multiport] + @rule
              else
                @rule
              end
            end

            private

            def add_port_spec(key, port)
              case port
              when Array
                @multiport = true
                @rule << "--#{key}s" << port.join(',')
              when Range
                @multiport = true
                start = port.begin
                finish = port.end
                if port.exclude_end?
                  finish -= 1
                end
                @rule << "--#{key}s" << "#{start}:#{finish}"
              when Fixnum
                @rule << "--#{key}" << port.to_s
              else
                raise "Wrong port specifier: #{port.inspect}"
              end
            end
          end
        end
      end
    end
  end
end
