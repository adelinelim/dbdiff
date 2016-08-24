module Services
  class DiffGenerator
    def initialize
      @data_file_names = {}
      @filtered_diff = {}
      @sorted_nos = []
    end

    def generate
      save_differences_into_json
    end

    #need to run generate function before the belows
    def get_data_files_names
      @data_file_names
    end

    def get_filtered_diff
      @filtered_diff
    end

    def has_two_data_files?
      @sorted_nos = sorted_data_file_number
      @sorted_nos.size > 1
    end

    private

    def set_data_files_names
      @data_file_names = Hashie::Mash.new({
        first_file: "#{@sorted_nos[-2]}.json",
        second_file: "#{@sorted_nos[-1]}.json"
      })
    end

    def save_differences_into_json
      if has_two_data_files?
        set_data_files_names
        # Read File 1 => second last file
        t1 = read_data_file(@sorted_nos[-2])
        # Read File 2 => last file
        t2 = read_data_file(@sorted_nos[-1])
        @filtered_diff = DataComparison.new(t1, t2).generate
      end
    end

    def read_data_file(file_number)
      file = "data/#{file_number}.json"
      compare = File.read(file).to_data.deep_symbolize_keys
      compare[:tables]
    end

    def sorted_data_file_number
      all_files = Dir["data/*.json"]
      # sort all the data json files name
      all_files.map do |f|
        filenum = f.split('/').last.split('.').first
        if filenum.is_i?
          filenum.to_i
        end
      end.compact.sort
    end
  end
end
