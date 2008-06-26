require 'tmpdir'

class Haskell
  def self.load(fname)
    new(File.read(fname))
  end

  def self.tuple_form(args)
    a = args.join(",") 
    return args.size == 1 ? a : "(#{a})"
  end

  def initialize(code, option={})
    @interpreter = option[:interpreter] || "runghc"
    @signetures = parse_signetures(code)
    @code = code
    @k = 0
  end

  def call(sig, *args)
    if String === sig 
      sig = @signetures.find{|sig| sig.name == sig}
      raise ArgumentError, "unknown method" if sig.nil?
    end

    src = make_src(@code, sig)
    path = make_tempfile(src)
    cmd = make_cmd(path, args)
    convert_result(`#{cmd}`.chomp, sig.ret)
  end

  def run(*args)
    call(@signetures[0], *args)
  end
  alias [] run

  def make_cmd(path, args)
    arg_list = Haskell.tuple_form(args.map{|x| x.inspect})
    arg_list.gsub!(/"/, '\\"')
    %Q<#{@interpreter} "#{path}" "#{arg_list}">
  end

  def convert_result(result, type)
    case type.to_s
    when "Integer"
      result.to_i
    when "String"
      result[1..-2] #cut \"
    else
      raise "unknown type: #{type}"
    end
  end

  TYPE_TABLE = [
    ["Int", Integer],
    ["String", String],
  ]
  class Signeture
    def initialize(name, args, ret)
      @name, @args, @ret = name, args, ret
    end
    attr_reader :name, :args, :ret

    def tuple_form
      Haskell.tuple_form(@args.map{|ty|TYPE_TABLE.rassoc(ty)[0]})
    end

    def tuple_vars
      "(" + make_vars().join(",") + ")"
    end

    def list_vars
      make_vars().join(" ")
    end

    # arity must be <= 26 :P
    def make_vars
      ("a".."z").to_a.slice(0, @args.size)
    end
  end

  def parse_signetures(code)
    code.scan(/^(\w+)\s*::\s*(\w+(\s*->\s*\w+)*)\s*$/).map do |sig|
      name = $1.strip
      args = $2.split(/->/).map{|x| 
        pair = TYPE_TABLE.assoc(x.strip)
        pair ? pair[1] : (raise ArgumentError, "unknown Haskell type #{x.strip}")
      }
      ret = args.pop
      Signeture.new(name, args, ret)
    end
  end

  def make_src(code, sig)
    src = "import System\n"
    src << code
    src << "\n"
    src << "main = do args <- getArgs\n"
    src << "          print $ apply #{sig.name} $ _read $ head args\n"
    src << "  where\n"
    src << "    _read :: String -> #{sig.tuple_form}\n"
    src << "    _read = read\n"
    src << "    apply f #{sig.tuple_vars} = f #{sig.list_vars}\n"
  end

  def make_tempfile(src)
    while File.exist?(fname = "rubiskell.#{Process.pid}.#{@k}.hs")
      @k += 1
    end
    open(fname, "w"){|f| f.write src }
    at_exit{ File.unlink(fname) }
    fname
  end
end
