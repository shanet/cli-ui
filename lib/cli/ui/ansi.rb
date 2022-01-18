# typed: true
require 'cli/ui'

module CLI
  module UI
    module ANSI
      extend T::Sig

      ESC = "\x1b"

      # ANSI escape sequences (like \x1b[31m) have zero width.
      # when calculating the padding width, we must exclude them.
      # This also implements a basic version of utf8 character width calculation like
      # we could get for real from something like utf8proc.
      #
      sig { params(str: T.untyped).returns(T.untyped) }
      def self.printing_width(str)
        zwj = T.let(false, T::Boolean)
        strip_codes(str).codepoints.reduce(0) do |acc, cp|
          if zwj
            zwj = false
            next acc
          end
          case cp
          when 0x200d # zero-width joiner
            zwj = true
            acc
          when "\n"
            acc
          else
            acc + 1
          end
        end
      end

      # Strips ANSI codes from a str
      #
      # ==== Attributes
      #
      # - +str+ - The string from which to strip codes
      #
      sig { params(str: T.untyped).returns(T.untyped) }
      def self.strip_codes(str)
        str.gsub(/\x1b\[[\d;]+[A-z]|\r/, '')
      end

      # Returns an ANSI control sequence
      #
      # ==== Attributes
      #
      # - +args+ - Argument to pass to the ANSI control sequence
      # - +cmd+ - ANSI control sequence Command
      #
      sig { params(args: T.untyped, cmd: T.untyped).returns(T.untyped) }
      def self.control(args, cmd)
        ESC + '[' + args + cmd
      end

      # https://en.wikipedia.org/wiki/ANSI_escape_code#graphics
      sig { params(params: T.untyped).returns(T.untyped) }
      def self.sgr(params)
        control(params.to_s, 'm')
      end

      # Cursor Movement

      # Move the cursor up n lines
      #
      # ==== Attributes
      #
      # * +n+ - number of lines by which to move the cursor up
      #
      sig { params(n: T.untyped).returns(T.untyped) }
      def self.cursor_up(n = 1)
        return '' if n.zero?
        control(n.to_s, 'A')
      end

      # Move the cursor down n lines
      #
      # ==== Attributes
      #
      # * +n+ - number of lines by which to move the cursor down
      #
      sig { params(n: T.untyped).returns(T.untyped) }
      def self.cursor_down(n = 1)
        return '' if n.zero?
        control(n.to_s, 'B')
      end

      # Move the cursor forward n columns
      #
      # ==== Attributes
      #
      # * +n+ - number of columns by which to move the cursor forward
      #
      sig { params(n: T.untyped).returns(T.untyped) }
      def self.cursor_forward(n = 1)
        return '' if n.zero?
        control(n.to_s, 'C')
      end

      # Move the cursor back n columns
      #
      # ==== Attributes
      #
      # * +n+ - number of columns by which to move the cursor back
      #
      sig { params(n: T.untyped).returns(T.untyped) }
      def self.cursor_back(n = 1)
        return '' if n.zero?
        control(n.to_s, 'D')
      end

      # Move the cursor to a specific column
      #
      # ==== Attributes
      #
      # * +n+ - The column to move to
      #
      sig { params(n: T.untyped).returns(T.untyped) }
      def self.cursor_horizontal_absolute(n = 1)
        cmd = control(n.to_s, 'G')
        cmd += control('1', 'D') if CLI::UI::OS.current.shift_cursor_on_line_reset?
        cmd
      end

      # Show the cursor
      #
      sig { returns(T.untyped) }
      def self.show_cursor
        control('', '?25h')
      end

      # Hide the cursor
      #
      sig { returns(T.untyped) }
      def self.hide_cursor
        control('', '?25l')
      end

      # Save the cursor position
      #
      sig { returns(T.untyped) }
      def self.cursor_save
        control('', 's')
      end

      # Restore the saved cursor position
      #
      sig { returns(T.untyped) }
      def self.cursor_restore
        control('', 'u')
      end

      # Move to the next line
      #
      sig { returns(T.untyped) }
      def self.next_line
        cursor_down + cursor_horizontal_absolute
      end

      # Move to the previous line
      #
      sig { returns(T.untyped) }
      def self.previous_line
        cursor_up + cursor_horizontal_absolute
      end

      sig { returns(T.untyped) }
      def self.clear_to_end_of_line
        control('', 'K')
      end
    end
  end
end
