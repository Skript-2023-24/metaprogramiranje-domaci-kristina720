require "google_drive"

class Tabela
    include Enumerable

    attr_accessor :spreadsheet_id, :worksheet_number, :worksheet, :headers

    def initialize(spreadsheet_id, worksheet_number)
      @spreadsheet_id = spreadsheet_id
      @worksheet_number = worksheet_number
      @worksheet = authenticate_google
      @headers = worksheet.rows[0]
      #if @worksheet
        #@headers = worksheet.rows[0]
      #else
        #raise "greska"
      #end
    end

    def authenticate_google
        session = GoogleDrive::Session.from_config("config.json")
        #session.spreadsheet_by_key("1iUBRToTv8yZrpWUP_r8BNPiNUBRQifFEOO5okK-d59Y").worksheets[worksheet_number]
        spreadsheet = session.spreadsheet_by_key(@spreadsheet_id)

        if spreadsheet
            spreadsheet.worksheets[@worksheet_number]
        else
            raise "Nije moguce pristupiti odredjenoj tabeli"
        end
    end

    def print
        puts "Hederi: #{headers} "

        worksheet.rows[1..-1].each do |row|
           puts "Redovi: #{row}"
        end

    end

    def row(broj)
        puts "Red #{broj}: #{worksheet.rows[broj]}"
    end

    def [](header)
        hindex = headers.index(header)

        return nil unless hindex

        column = worksheet.rows[1..-1].map { |row| row[hindex] }
        Kolona.new(column, worksheet, hindex)
    end

    def method_missing(method_name, *args)
        modified_string = method_name.to_s.gsub(/\b\w/, &:capitalize)
        hindex = headers.index(modified_string)

        return nil unless hindex

        column = worksheet.rows[1..-1].map { |row| row[hindex] }
        Kolona.new(column, worksheet, hindex)
    end

    def each(&_block)
        worksheet.rows[1..-1].each do |row|
            row_str = row.join(", ")
            yield(row_str)
        end
    end

end

class Kolona
    include Enumerable

    attr_accessor :column, :worksheet, :hindex

    def initialize(column, worksheet, hindex)
      @column = column
      @worksheet = worksheet
      @hindex = hindex
    end

    def [](index)
      column[index - 1]
    end

    def []=(index, value)
      worksheet[index + 1, hindex + 1] = value
      column[index + 1] = value
      reload_column
    end

    def sum
        num_column = column.map(&:to_i)
        num_column.compact.sum
    end

    def avg
        num_column = column.map(&:to_i)
        values = num_column.compact
        none_zero = values.reject { |num| num.zero? }
        none_zero.empty? ? nil : (none_zero.sum / none_zero.length.to_f)
    end

    def method_missing(method_name, *args)
        rindex = column.index(method_name.to_s)

        return nil unless rindex

        worksheet.rows[rindex + 1]
    end

    def to_s
        column.map(&:to_s).join(' ')
    end

    def map(&_block)
        num_column = column.map(&:to_i)
        num_column.map do |row|
            yield(row)
        end
    end

    def select(&_block)
        num_column = column.map(&:to_i)
        num_column.select do |row|
            yield(row)
        end
    end

    def reduce(n = nil, &_block)
        num_column = column.map(&:to_i)
        num_column.reduce do |n, row|
            yield(n, row)
        end
    end

    private

    def reload_column
      column = worksheet.rows[1..-1].map { |row| row[hindex] }
    end
end
