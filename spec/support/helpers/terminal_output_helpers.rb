module Armadura::Test
  module TerminalOutputHelpers
    def divider(title = '')
      total_length = 72
      start_length = 3

      string = ''
      string << ('-' * start_length)
      string << title
      string << '-' * (total_length - start_length - title.length)
      string << "\n"
      string
    end
  end
end
