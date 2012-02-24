module Attributed
  module Log
    extend self

    def notice(*data, &blk)
      data = to_data(data)
      message = "file=#{to_file} fun=#{to_fun} #{data}".strip
      if not blk
        $stdout.puts message[0,950]
        $stdout.flush
      else
        start = Time.now
        $stdout.puts "block=begin #{message}"[0,950]
        $stdout.flush
        result = yield
        $stdout.puts "block=finish elapsed=#{Time.now - start} #{message}"[0,950]
        $stdout.flush
        result
      end
    end

    def exception(e)
      message = to_message(e.message)
      trace = to_trace(e.backtrace)
      $stderr.puts "class=#{e.class} message=`#{message}' trace=#{trace[0, trace.size-4]}"[0,950]
      $stderr.flush
    end

    private

    def to_fun
      caller[1].match(/([^` ]*)'/) && $1.strip
    end

    def to_file
      caller[1].match(/#{Dir.getwd}\/lib\/([^\.]*)/) && $1.strip
    end

    def to_data(data)
      data.map do |i|
        case i
        when Hash
          i.map do |k, v|
            case v
            when Hash
              "#{k}=#"
            when NilClass
              "#{k}=nil"
            else
              "#{k}=#{v.to_s}"
              end
          end.compact.join(" ")
        else
          i.to_s
        end
      end.compact.join(" ")
    end

    def to_message(message)
      message.lines.to_a.first.strip
    end

    def to_trace(trace)
      trace.map do |i|
        i.match(/(#{Gem.dir}|#{Dir.getwd})\/(.*)/) && $2.strip
      end.compact
    end

  end
end
