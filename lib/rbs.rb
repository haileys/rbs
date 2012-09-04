require "open3"
require "thread"

module RBS
  class Process
    attr_reader :input, :output, :status
    
    def initialize(args)
      @input, @output, @wait_thr = Open3.popen2e *args
    end
    
    def read(*args)
      output.read *args
    end
    
    def write(*args)
      input.write *args
    end
  end
  
  extend RBS
  
  def self.with_stack
    @@with_stack ||= []
  end
  
  def self.global(*args)
    args.flatten.each do |arg|
      Object.send :define_method, arg do |*args, &bk|
        RBS[arg, *args, &bk]
      end
      Object.send :private, arg
    end
  end
  
  def method_missing(sym, *args, &bk)
    self.[](sym, *args, &bk)
  end
  
  def [](sym, *args, &bk)
    unless `which #{sym}` and $?.success?
      sym = sym.to_s.gsub "_", "-"
    end
    
    shell_args = [sym.to_s]
    wait = true
    args.each do |arg|
      if arg.is_a? Hash
        arg.each do |k,v|
          if k == :_wait
            wait = v
            next
          end
          
          k = k.to_s.gsub "_", "-"
          if v == true
            shell_args << "--#{k}"
          else
            if k.size == 1
              shell_args << "-#{k}"
              shell_args << v
            else
              shell_args << "--#{k}=#{v}"
            end
          end
        end
      elsif arg.is_a? Symbol
        if arg.size == 1
          shell_args << "-#{arg}"
        else
          shell_args << "--#{arg}"
        end
      else
        shell_args << arg.to_s
      end
    end
    
    if block_given?
      RBS.with_stack << shell_args
      begin
        retn = yield
      ensure
        RBS.with_stack.pop
      end
      retn
    else
      proc = RBS::Process.new RBS.with_stack.flatten + shell_args
      if wait
        proc.read
      else
        proc
      end
    end
  end
end

def rbs(*args)
  if args.empty?
    RBS
  else
    RBS.global *args
  end
end