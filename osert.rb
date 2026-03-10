#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'fileutils'
require 'date'
require 'shellwords'

colors = {
  red: "\e[31m",
  nocolor: "\e[0m"
}

certifications = [
  {
    exam: 'OSCP',
    template: [
      {
        name: 'Whoisflynn Improved Template v3.2',
        path: 'src/OSCP-exam-report-template_whoisflynn_v3.2.md'
      },
      {
        name: 'Official Offensive Security Template v1',
        path: 'src/OSCP-exam-report-template_OS_v1.md'
      },
      {
        name: 'Official Offensive Security Template v2',
        path: 'src/OSCP-exam-report-template_OS_v2.md'
      }
    ]
  },
  {
    exam: 'OSWA',
    template: [
      {
        name: 'Official Offensive Security Template v1',
        path: 'src/OSWA-exam-report-template_OS_v1.md'
      }
    ]
  },
  {
    exam: 'OSWE',
    template: [
      {
        name: 'Official Offensive Security Template v1',
        path: 'src/OSWE-exam-report-template_OS_v1.md'
      },
      {
        name: 'Noraj Improved Template v1',
        path: 'src/OSWE-exam-report-template_noraj_v1.md'
      },
      {
        name: 'XL-SEC Improved Template v1',
        path: 'src/OSWE-exam-report-template_xl-sec_v1.md'
      }
    ]
  },
  {
    exam: 'OSCE',
    template: [
      {
        name: 'Official Offensive Security Template v1',
        path: 'src/OSCE-exam-report-template_OS_v1.md'
      }
    ]
  },
  {
    exam: 'OSEE',
    template: [
      {
        name: 'Official Offensive Security Template v1',
        path: 'src/OSEE-exam-report-template_OS_v1.md'
      }
    ]
  },
  {
    exam: 'OSWP',
    template: [
      {
        name: 'Official Offensive Security Template v1',
        path: 'src/OSWP-exam-report-template_OS_v1.md'
      }
    ]
  },
  {
    exam: 'OSED',
    template: [
      {
        name: 'Official Offensive Security Template v1',
        path: 'src/OSED-exam-report-template_OS_v1.md'
      },
      {
        name: 'Epi Improved Template v1',
        path: 'src/OSED-exam-report-template_epi_v1.md'
      }
    ]
  },
  {
    exam: 'OSEP',
    template: [
      {
        name: 'Official Offensive Security Template v1',
        path: 'src/OSEP-exam-report-template_OS_v1.md'
      },
      {
        name: 'Ceso Improved Template v1',
        path: 'src/OSEP-exam-report-template_ceso_v1.md'
      }
    ]
  },
  {
    exam: 'OSDA',
    template: [
      {
        name: 'Official Offensive Security Template v1',
        path: 'src/OSDA-exam-report-template_OS_v1.md'
      }
    ]
  },
  {
    exam: 'OSMR',
    template: [
      {
        name: 'Official Offensive Security Template v1',
        path: 'src/OSMR-exam-report-template_OS_v1.md'
      }
    ]
  },
  {
    exam: 'OSTH',
    template: [
      {
        name: 'Official Offensive Security Template v1',
        path: 'src/OSTH-exam-report-template_OS_v1.md'
      }
    ]
  },
  {
    exam: 'OSIR',
    template: [
      {
        name: 'Official Offensive Security Template v1',
        path: 'src/OSIR-exam-report-template_OS_v1.md'
      }
    ]
  }
]

options = {
  'resource-path': '.'
}

subtext = <<~HELPMSG
  Markdown Templates for Offensive Security OSCP, OSWE, OSEE, OSWP, OSEP, OSED Exam Report.

  Sub-commands:
    init     :  Copy a template that you will use to write your report
    generate :  Generate your PDF report and 7z archive

  See 'osert COMMAND --help' for more information on a specific command.
HELPMSG

global = OptionParser.new do |opts|
  opts.banner = 'Usage: osert <subcommand> [options]'
  opts.separator ''
  opts.separator subtext
end

subcommands = {
  'init' => OptionParser.new do |opts|
    opts.banner = 'Usage: osert init [options]'
    opts.on('-o', '--output REPORT', 'File path to store a copy of the template to write your report')
  end,
  'generate' => OptionParser.new do |opts|
    opts.banner = 'Usage: osert generate [options]'
    opts.on('-i', '--input REPORT', 'File path to the markdown report to convert to PDF')
    opts.on('-o', '--output PDF', 'File path to store the PDF report')
    opts.on('-e', '--exam EXAM', 'The exam short name')
    opts.on('-s', '--osid OSID', 'Your Offensive Security ID')
    opts.on('-r', '--resource-path PATH', 'Complementary resources (e.g. images) path to include [Default: ./src]')
  end
}

if ARGV.empty?
  abort(global.help)
else
  global.order!(into: options)
end
command = ARGV.shift
subcommands[command].order!(into: options)

def puts_prompt(*args)
  puts args if args.size == 1
  print '> '
end

def sed(file, text_i, text_o)
  text = File.read(file)
  File.open(file, 'w+') do |f|
    f.puts(text.sub(text_i, text_o))
  end
end

def build_resource_path(input, extra_path)
  # Include markdown directory so relative image paths are resolved from the .md location.
  input_dir = File.dirname(File.expand_path(input))
  paths = ['.', '/usr/share/osert/src', 'src']
  paths.concat(extra_path.to_s.split(':'))
  paths << input_dir

  paths.map! { |path| path.strip }
  paths.reject!(&:empty?)
  paths.uniq.join(':')
end

def executable_in_path?(cmd)
  ENV.fetch('PATH', '').split(File::PATH_SEPARATOR).any? do |dir|
    path = File.join(dir, cmd)
    File.file?(path) && File.executable?(path)
  end
end

def preview_command
  host_os = RUBY_PLATFORM.downcase
  return ['open', '-a', 'Preview'] if host_os.include?('darwin') && executable_in_path?('open')
  return ['xdg-open'] if executable_in_path?('xdg-open')

  nil
end

def pandoc_supports_option?(option)
  @pandoc_help ||= `pandoc --help 2>&1`
  @pandoc_help.include?(option)
end

def available_highlight_styles
  @available_highlight_styles ||= `pandoc --list-highlight-styles 2>/dev/null`.split("\n").map(&:strip).reject(&:empty?)
end

def preferred_highlight_style
  return 'idiomatic' if pandoc_supports_option?('--syntax-highlighting')

  preferred = %w[breezedark kate pygments]
  preferred.find { |style| available_highlight_styles.include?(style) } || available_highlight_styles.first || 'breezedark'
end

def build_highlight_argument(style)
  if pandoc_supports_option?('--syntax-highlighting')
    ["--syntax-highlighting=#{style}"]
  elsif pandoc_supports_option?('--listings')
    ['--listings']
  elsif pandoc_supports_option?('--highlight-style')
    ["--highlight-style=#{style}"]
  else
    []
  end
end

begin
  case command
  when 'init'
    # Choose a certification
    puts '[+] Choose a Certification:'
    certifications.each_with_index do |c, i|
      puts "#{colors[:red]}#{i}. #{c[:exam]}#{colors[:nocolor]}"
    end
    puts_prompt
    cert = certifications[gets.chomp.to_i]

    # Choose a template
    puts '[+] Choose a Template:'
    cert[:template].each_with_index do |t, i|
      puts "#{colors[:red]}#{i}. [#{cert[:exam]}] #{t[:name]}#{colors[:nocolor]}"
    end
    puts_prompt
    src = cert[:template][gets.chomp.to_i][:path]

    # Enter your OS id
    puts '[+] Enter your OS ID:'
    print '> OS-'
    osid = "OS-#{gets.chomp}"

    # Enter your email address
    puts_prompt '[+] Enter your email address as author:'
    author = gets.chomp

    if options[:output]
      output = options[:output]
    else
      puts_prompt '[+] Enter the path where you want to copy the report template:'
      output = gets.chomp
    end

    # The chosen template will be saved in the chosen directory
    begin
      FileUtils.cp(src, output)
    rescue Errno::ENOENT
      FileUtils.cp("/usr/share/osert/#{src}", output)
    end

    # Replace metadata in the report
    report = "#{output}/#{File.basename(src)}"
    sed(report, /^author:.*/, %(author: ["#{author}", "OSID: #{osid}"]))
    sed(report, /^date:.*/, %(date: "#{Date.today}"))

    print "[+] The #{colors[:red]}#{File.basename(src)}#{colors[:nocolor]} file is saved in"
    print " #{colors[:red]}#{output}#{colors[:nocolor]} folder."
    puts 'Edit it with your exam notes.'
    print "[+] Then, run #{colors[:red]}osert generate -i #{output}/#{File.basename(src)} -o #{output}#{colors[:nocolor]}"
    puts ' for getting your report.'
  when 'generate'
    puts '[+] Preparing your final report...'
    style = preferred_highlight_style

    if options[:input]
      input = options[:input]
    else
      puts_prompt '[+] Enter the file path where is your markdown report:'
      input = gets.chomp
    end

    if options[:output]
      output = options[:output]
    else
      puts_prompt '[+] Enter the path where you want to store the PDF report:'
      output = gets.chomp
    end

    if options[:exam]
      exam = options[:exam]
    else
      puts '[+] Choose a Certification:'
      certifications.each_with_index do |c, i|
        puts "#{colors[:red]}#{i}. #{c[:exam]}#{colors[:nocolor]}"
      end
      puts_prompt
      cert = certifications[gets.chomp.to_i]
      exam = cert[:exam]
    end

    if options[:osid]
      osid = options[:osid]
    else
      puts '[+] Enter your OS ID:'
      print '> OS-'
      osid = "OS-#{gets.chomp}"
    end

    # Generating report
    puts '[+] Generating report...'
    pdf = "#{output}/#{exam}-#{osid}-Exam-Report.pdf"
    resource_path = build_resource_path(input, options[:'resource-path'])
    inline_code_filter = File.expand_path('filters/inline_code_box.lua', __dir__)
    local_template = File.expand_path('src/templates/eisvogel.latex', __dir__)
    logo_path = File.expand_path('src/img/offsec-learning-partner.png', __dir__)
    template = File.exist?(local_template) ? local_template : 'eisvogel'
    template_arg = File.exist?(local_template) ? "--template #{template.shellescape} \\" : '--template eisvogel \\'
    logo_arg = File.exist?(logo_path) ? "-V titlepage-logo=#{logo_path.shellescape} \\" : ''
    footer_right = '\\thepage\\ /\\ \\pageref*{LastPage}'
    header_includes = '\\usepackage{lastpage}'
    highlight_args = build_highlight_argument(style)
    highlight_lines = highlight_args.map { |arg| "  #{arg} \\\n" }.join
    pandoc_cmd = <<~CMD
      pandoc #{input.shellescape} -o #{pdf.shellescape} \
        --from markdown+yaml_metadata_block+raw_html \
        #{template_arg}
        -V book=true \
        #{logo_arg}
        -V header-includes=#{header_includes.shellescape} \
        -V footer-right=#{footer_right.shellescape} \
        --pdf-engine=xelatex \
        --lua-filter=#{inline_code_filter.shellescape} \
        --table-of-contents \
        --toc-depth 6 \
        --number-sections \
        --top-level-division=chapter \
      #{highlight_lines}  --resource-path=#{resource_path.shellescape}
    CMD
    pandoc_output = `#{pandoc_cmd} 2>&1`

    unless $?.success?
      warn pandoc_output unless pandoc_output.strip.empty?
      abort("[!] Pandoc failed (exit #{$?.exitstatus}). PDF was not generated.")
    end

    abort('[!] Pandoc did not generate a PDF file. Check the error output above.') unless File.exist?(pdf)

    puts "[+] PDF generated at #{colors[:red]}#{pdf}#{colors[:nocolor]}"

    # Preview
    puts_prompt '[+] Do you want to preview the report? [Y/n]'
    choice = gets.chomp
    if choice.downcase == 'y' || choice.empty?
      if File.exist?(pdf)
        opener = preview_command
        if opener
          viewer = fork do
            exec(*opener, pdf)
          rescue Errno::ENOENT
            warn "[!] Preview command not found: #{opener.join(' ')}"
            exit! 1
          end
          Process.detach(viewer)
        else
          warn '[!] No preview command available (expected: open or xdg-open).'
        end
      else
        warn '[!] Preview skipped because PDF file was not found.'
      end
    end

    # Generating archive
    abort('[!] Cannot create archive because PDF file was not found.') unless File.exist?(pdf)
    puts '[+] Generating archive...'
    archive = "#{output}/#{exam}-#{osid}-Exam-Report.7z"
    `7z a #{archive.shellescape} #{File.expand_path(pdf.shellescape)}`

    # Optional lab report
    puts_prompt '[+] Do you want to add an external lab report? [Y/n]'
    choice = gets.chomp
    if choice.downcase == 'y' || choice.empty?
      puts_prompt '[+] Write the path of your lab PDF:'
      lab = gets.chomp
      puts '[+] Updating archive...'
      `7z a #{archive.shellescape} #{File.expand_path(lab.shellescape)}`
    end

    puts "[+] Archive generated at #{colors[:red]}#{archive}#{colors[:nocolor]}"

    # Calculate MD5
    puts '[+] Calculating MD5 of the archive...'
    require 'digest'
    md5 = Digest::MD5.hexdigest File.read(archive)
    puts "[+] Archive MD5 (upload integrity check): #{colors[:red]}#{md5}#{colors[:nocolor]}"
  end
rescue Errno::ENOENT => e
  puts e.message
  abort(subcommands[command].help)
end
