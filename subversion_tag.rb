=begin
  SubversionTag
  subversion_tag.rb
  Copyright (C) 2009 Terence Lee <hone02@gmail.com>

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.
=end
require 'discard_head_merge_strategy'

class SubversionTag
  class << self
    def new_tag(tag, git_branch)
      tag(tag)
      checkout(tag)
      merge(git_branch)
      resolve_files(unmerged_files)
      commit
      dcommit
    end

    def tag(tag)
      execute("git svn tag #{tag}")
    end

    def checkout(tag)
      execute("git checkout -b #{tag} svn/tags/#{tag}")
    end

    def merge(git_branch)
      execute("git merge #{git_branch}")
    end

    # finds the unmerged files and returns them
    def unmerged_files
      output_lines = `git status`.split("\n")
      unmerged_lines = output_lines.select {|line| /unmerged:\s+\w/.match(line) }
      unmerged_files = unmerged_lines.collect do |line|
        md = /unmerged:\s+(.+)$/.match(line) 
        md[1]
      end

      unmerged_files
    end

    # resolve conflicts on the files and add them back in for a commit
    def resolve_files(files)
      files.each do |file_name|
        if File.exist?(file_name)
          new_file = DiscardHeadMergeStrategy.resolve(file_name)
          File.open(file_name, 'w') {|file| file.print(new_file) }
          execute("git add #{file_name}")
        else
          execute("git rm #{file_name}")
        end
      end
    end

    def commit
      execute("git commit")
    end

    def dcommit
      execute("git svn dcommit")
    end

    private
    # displays command and executes it
    def execute(cmd)
      puts(cmd)
      system(cmd)
    end
  end

end

if $0 == __FILE__
  tag = ARGV[0]
  git_branch = ARGV[1]

  if tag.nil? and git_branch.nil?
    $stderr.puts "Usage: subversion_tag.rb <tag> <git_branch>"
  else
    SubversionTag.new_tag(tag, git_branch)
  end
end
