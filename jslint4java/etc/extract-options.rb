#!/usr/bin/env ruby
#
# Pull out the list of options from fulljslint.js.
#
# @(#) $Id$

opts = {
  # Hard-code these, as they're not part of the boolean options.
  "indent" => ['The number of spaces used for indentation (default is 4)', 'Integer'],
  'maxerr' => ['The maximum number of warnings reported (default is 50)', 'Integer'],
  # NB: Slight variant of original text.
  'predef' => ['The names of predefined global variables.', 'StringArray'],
}

File.open(ARGV[0]) do |fh|
  while line = fh.gets do
    # puts ">> #{line}"
    if (line =~ /\s+boolOptions\s*=\s*\{/) ... (line =~ /\}/)
      if md = line.match(/(\w+).*\/\/ (.*)/)
        opts[ md[1] ] = [md[2].capitalize, 'Boolean']
      end
    end
  end
end

indent = "    "
File.open(ARGV[1]) do |fh|
  while line = fh.gets do
    if line =~ /\/\/\s*BEGIN-OPTIONS/
      # Skip up to the end of the options section.
      while line !~ /\/\/\s*END-OPTIONS/
        line = fh.gets
      end
      
      # And start rewriting.
      puts "#{indent}//BEGIN-OPTIONS"
      allopts =  opts.keys.sort.map do |k|
        desc = opts[k][0]
        descEscaped = desc.gsub(/"/, '\\"')
        "#{indent}/** #{desc} */\n" +
        "#{indent}#{k.upcase}(\"#{descEscaped}\", #{opts[k][1]}.class)"
      end.join(",\n")
      puts "#{allopts};"
      puts "#{indent}//END-OPTIONS"
    else
      puts line
    end
  end
end
