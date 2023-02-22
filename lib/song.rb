require_relative "../config/environment.rb"
require 'active_support/inflector'

# A dynamic ORM allows us to map an existing database table to a class and write methods that can use nothing more than information regarding a soecific database to:
  # Create attr_accessors for a Ruby class
  # Create shareable methods for inserting, updating, selecting and deleting data from the database table

class Song

  # Takes the name of the class, referenced by the self keyword, turns it into a string with #to_s, downcases the string and then pluralizes it.
  # NOTE: The #pluralize method is provided by the 'active_support/inflector' code library required at the top.
  def self.table_name
    self.to_s.downcase.pluralize
  end

  # Querying a table for column names
  # PRAGMA table_info(<table name>)
  # THis will return an array of hashes describing the table itself
  # Each hash will contain info about one column.
  def self.column_names
    DB[:conn].results_as_hash = true
    # Accessing the name of the table we are querying
    sql = "pragma table_info('#{table_name}')"

    # Iterate over the resulting array of hashes to collect just the name of each column
    table_info = DB[:conn].execute(sql)
    column_names = []
    table_info.each do |row|
      column_names << row["name"]
    end
    column_names.compact # .compact gets rid of any nil values that may end up in our collection.
  end

  # Iterating over the column names stored in the column_names class method and set an attr_accessor for each one
  self.column_names.each do |col_name|
    attr_accessor col_name.to_sym # converting the column name string into a symbol with #to_sym
  end

  # Our method takes in an argument of options which defaults to an empty hash.
  # Iterate over the options hash and use #send method to interpolate the name of each hash key as a method that we set equal to the key's value
  def initialize(options={})
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def table_name_for_insert
    # Accesses the table name we want to INSERT into from inside our #save method
    self.class.table_name
  end

  def values_for_insert
    values = []
    # Push the return value of invoking a method via the #send method unless the value is nil
    # Turn them into a comma separated list contained in a string.
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end

  def col_names_for_insert
    # Grabbing the column names of the table associated with a given class
    # Should not include the id_column or insert a value for the id column
    # Need to remove "id" from the array of column names returned from the method call above.
    # Turn them into a comma separated list contained in a string.
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end

end



