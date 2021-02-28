require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord
    def self.table_name
        self.to_s.downcase.pluralize
    end

    def self.column_names
        DB[:conn].results_as_hash = true
        sql = "pragma table_info('#{self.table_name}')"

        table_info = DB[:conn].execute(sql)
        column_names = []
        table_info.map do |col_name|
            column_names << col_name['name']
        end
        column_names.compact
    end 

    def initialize(options={})
        options.each do |key, value|
            self.send("#{key}=", value)
        end
    end

    def table_name_for_insert
        self.class.table_name
    end

    def col_names_for_insert
        #binding.pry
        self.class.column_names.delete_if {|col| col == "id"}.join(", ")
    end

    def values_for_insert
        #binding.pry
        values = []
        self.class.column_names.each do |col_name|
            #binding.pry
            values << "'#{send(col_name)}'" unless send(col_name).nil?
            #binding.pry
        end
        values.join(", ")
    end

    def save
        sql = <<-SQL
            INSERT INTO #{table_name_for_insert} (#{col_names_for_insert})
            VALUES (#{values_for_insert})
        SQL
        DB[:conn].execute(sql)
        #binding.pry
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT * 
            FROM #{self.table_name}
            WHERE name = ?
        SQL
        #binding.pry
        DB[:conn].execute(sql,name)
    end

    def self.find_by(option)
        # binding.pry
       
       res = option.values[0].class == Fixnum ? option.values[0] : "'#{option.values[0]}'"

        sql = "SELECT * FROM #{self.table_name} WHERE #{option.keys.first} = #{res}" 
    #   binding.pry
        DB[:conn].execute(sql)
    end


end