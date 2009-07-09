=begin
  DiscardHeadMergeStrategy
  discard_head_merge_strategy.rb
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
# when merging in git and get a conflicted file, this will discard all head changes and keep the changes from the incoming merge file
class DiscardHeadMergeStrategy
  CONFLICT_HEAD_CHARS  = '<<<<<<<'
  CONFLICT_SPLIT_CHARS = '======='
  CONFLICT_MERGE_CHARS = '>>>>>>>'

  def self.resolve(conflict_file)
    lines = nil
    File.open(conflict_file) {|file| lines = file.readlines }
    new_file = Array.new

    while lines.any?
      new_file += skip_until(lines, CONFLICT_HEAD_CHARS)
      discard_until(lines, CONFLICT_SPLIT_CHARS)
      new_file += skip_until(lines, CONFLICT_MERGE_CHARS)
    end

    new_file.join
  end

  private
  # discard lines until you hit the matcher
  def self.discard_until(lines, matcher)
    line = nil
    while lines.any? && !/^#{matcher}/.match(line)
      line = lines.shift
    end

    lines
  end

  # return the lines skipped until you hit the matcher
  def self.skip_until(lines, matcher)
    keep_lines = Array.new
    line = nil
    while lines.any? && !/^#{matcher}/.match(line)
      keep_lines.push(line) if line
      line = lines.shift
    end
    # if hits end of file, push that last line back on or we'll lose it
    keep_lines.push(line) if lines.empty? and line

    keep_lines
  end
end
