#!/usr/bin/env ruby

#global libs
require 'optparse'
#require 'optparse/subcommand'
require 'pp'

#local requires
require 'version.rb'
require 'help.rb'
require 'builtin/struct/host.rb'
require 'builtin/struct/plataform.rb'
require 'builtin/hostsManager.rb'
require 'builtin/commandParser.rb'

#require './builtin/defaults.rb'
#require './builtin/handle_options.rb'
#require './builtin/host_actions.rb'
#require './builtin/host_apply.rb'
#require './builtin/paths.rb'

# pl = Plataform.new
# pl.add(Host.new('127.0.0.1', 'local.pense.com.br', pl))
# pl.add(Host.new('127.0.0.1', 'www.teste.com.br', pl))
# puts YAML::dump(pl)
# puts Marshal::dump(pl)
# print pl.toString()



#Main Class that parse commands and
class Commands

  CODES = %w[iso-2022-jp shift_jis euc-jp utf8 binary]
  CODE_ALIASES = { "jis" => "iso-2022-jp", "sjis" => "shift_jis" }

  def initialize(args)
    @help = Help.new
    @command = nil
    @options = parse(args)
    @hostManager = HostManager.new
  end

  def showHelp
    @help.list_commands
  end

  #represent if the args passed to Hoster script is blank
  def empty?
    @options[:empty]
  end

  def parse(args)
    options = {}
    options[:empty  ] = args.empty?
    options[:version] = false
    options[:help   ] = false
    options[:init   ] = false
    options[:verbose] = false

    options[:add     ] = false
    options[:ip      ] = '127.0.0.1'
    options[:host    ] = nil
    options[:plat    ] = "dev"

    options[:list   ] = false

    options[:edit   ] = false
    options[:apply  ] = false


    opt = SubcommandParser.new do |opts|

      @help.setOpts(opts)

      opts.banner = @help.getUsageString

      opts.separator ""
      opts.separator "Commands:"

      #subcommand INIT
      opts.cmd_on("init", "Create an empty host repository in the current folder.") do |cmd|
        options[:init] = true
      end

      #sucommand ADD
      opts.cmd_on("add", "Add a new HOST to current repository into a specific environment.") do |cmd|
        puts cmd
        options[:add] = true
        cmd.on("[-ip IP]", string, "set the IP address, default is 127.0.0.1") do |op|
          options[:ip] = op
        end
        cmd.on("-host HOST", string, "set the HOST address") do |op|
          options[:host] = op
        end

        cmd.on("-pl PLATAFORM", string, "set the PLATAFORM name, default dev") do |op|
          options[:plat] = op
        end


      end


      opts.separator ""
      opts.separator "Global Arguments:"

      opts.on_tail("-v", "--version", "Display the #{PROGNAME} version") do
        options[:version] = true
      end

       opts.on_tail("-h", "--help", "--usage", "Display the #{PROGNAME} help") do
         options[:help] = true
       end

      #mark to show more messages
      opts.on_tail("--[no-]verbose", "Set to show hoster output or not.") do
        options[:verbose] = true
      end
    end

    #subcommands
    #https://gist.github.com/rkumar/445735
    #http://stackoverflow.com/questions/2732894/using-rubys-optionparser-to-parse-sub-commands
    #https://github.com/bjeanes/optparse-subcommand
    #
    subcommands = {

    # 'add' => OptionParser.new do |opts|
    #
    #         #completion example https://github.com/rhysd/vim-optparse
    #         #mark to initialize hoster repository
    #         opts.on("Add a new HOST to current repository into a specific environment. \n --domain test.com \n [--ip] default 127.0.0.1 \n [--plataform] default DEV") do |arg|
    #           puts "peee weee"
    #           options[:add] = true
    #         end
    #
    #         #mark to initialize hoster repository
    #         opts.on("-i","--init", "Create an empty host repository in the current folder.") do
    #           options[:init] = true
    #         end
    #
    #
    #   end
    }

    #start parsin the commands
    begin
      opt.parse!(args)
      #opt.order!(args)
      puts args

      if(args.length == 1 && args[0] == "init")
        options[:init] = true
      end

      #subcommands[args.shift].order!(args)

      #if there is a invalid Option, help should be printed
      rescue OptionParser::InvalidOption
        @help.invalidOption
        showHelp()
      #if there a missing argument, show help
      rescue OptionParser::MissingArgument
        @help.missingArgument
        showHelp()
    end
    #end Parsing
    options
  end

  def run!

    if(@options[:help])
      showHelp()
    end

    if(@options[:version])
      version()
    end

    if(@options[:init])
      @hostManager.setVerbosity(@options[:verbose])
      @hostManager.initRepository()
    end


  end

end
